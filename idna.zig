const std = @import("std");
const extras = @import("extras");
const ucd = @import("unicode-ucd");
const normalization = @import("./normalization.zig");
const punycode = @import("./punycode.zig");

pub const @"2008" = @import("./2008.zig");

pub const table = @import("./table.zig");

// https://unicode.org/reports/tr46/#ToASCII
pub fn ToASCII(
    allocator: std.mem.Allocator,
    domain_name: []const u8,
    CheckHyphens: bool,
    CheckBidi: bool,
    CheckJoiners: bool,
    UseSTD3ASCIIRules: bool,
    Transitional_Processing: bool, //deprecated
    VerifyDnsLength: bool,
    IgnoreInvalidPunycode: bool,
) ![]u8 {
    var map = extras.ManyArrayList(u8).init(allocator);
    defer map.deinit();

    try Processing(&map, domain_name, UseSTD3ASCIIRules, CheckHyphens, CheckBidi, CheckJoiners, Transitional_Processing, IgnoreInvalidPunycode);

    map.lengths.clearRetainingCapacity();
    var it2 = std.mem.splitScalar(u8, map.list.items, '.');
    while (it2.next()) |label| {
        try map.lengths.append(map.allocator, label.len);
        try map.lengths.append(map.allocator, 1);
    }
    _ = map.lengths.orderedRemove(map.lengths.items.len - 1);
    for (0..map.lengths.items.len) |n| {
        punycode.encode(&map, n) catch |err| switch (err) {
            error.InvalidPunycode => return error.IDNAFailure,
            error.OutOfMemory => |e| return e,
        };
    }

    if (VerifyDnsLength) {
        // 1. The length of the domain name, excluding the root label and its dot, is from 1 to 253.
        if (map.list.items.len < 1) return error.IDNAFailure;
        if (map.list.items.len > 253) return error.IDNAFailure;
        // 2. The length of each label is from 1 to 63.
        for (map.lengths.items, 0..) |l, n| {
            if (n % 2 == 1) continue;
            if (l < 1 or l > 63) return error.IDNAFailure;
        }
    }

    return map.toOwnedSlice();
}

// https://unicode.org/reports/tr46/#ToUnicode
pub fn ToUnicode(
    allocator: std.mem.Allocator,
    domain_name: []const u8,
    CheckHyphens: bool,
    CheckBidi: bool,
    CheckJoiners: bool,
    UseSTD3ASCIIRules: bool,
    Transitional_Processing: bool, //deprecated
    IgnoreInvalidPunycode: bool,
) ![]u8 {
    var map = extras.ManyArrayList(u8).init(allocator);
    defer map.deinit();
    try Processing(&map, domain_name, UseSTD3ASCIIRules, CheckHyphens, CheckBidi, CheckJoiners, Transitional_Processing, IgnoreInvalidPunycode);
    return map.toOwnedSlice();
}

// https://unicode.org/reports/tr46/#Processing
fn Processing(
    map: *extras.ManyArrayList(u8),
    domain_name: []const u8,
    UseSTD3ASCIIRules: bool,
    CheckHyphens: bool,
    CheckBidi: bool,
    CheckJoiners: bool,
    Transitional_Processing: bool, //deprecated
    IgnoreInvalidPunycode: bool,
) !void {
    try map.list.ensureUnusedCapacity(map.allocator, domain_name.len);
    try map.lengths.ensureUnusedCapacity(map.allocator, domain_name.len);
    // 1. Map. For each code point in the domain_name string, look up the Status value in Section 5, IDNA Mapping Table, and take the following actions:
    var it = std.unicode.Utf8View.initUnchecked(domain_name).iterator();
    while (it.nextCodepointSlice()) |sl| {
        const cp = std.unicode.utf8Decode(sl) catch unreachable;
        const status, const mapping, const status2 = mappingRow(cp);
        _ = status2;
        sw: switch (status) {
            .valid => {
                try map.appendSlice(try map.add(), sl);
            },
            .ignored => {
                //nop
            },
            .mapped => {
                if (Transitional_Processing and cp == 'ẞ') {
                    try map.appendSlice(try map.add(), "s");
                    try map.appendSlice(try map.add(), "s");
                    continue;
                }
                for (mapping) |p| {
                    var buf: [4]u8 = undefined;
                    const l = std.unicode.utf8Encode(p, &buf) catch unreachable;
                    try map.appendSlice(try map.add(), buf[0..l]);
                }
            },
            .deviation => {
                continue :sw if (Transitional_Processing) .mapped else .valid;
            },
            .disallowed => {
                continue :sw .valid;
            },
        }
    }

    // 2. Normalize. Normalize the domain_name string to Unicode Normalization Form C.
    // https://unicode.org/reports/tr15/
    if (!isNFC(map)) try normalization.ToNFC(map);

    // 3. Break. Break the string into labels at U+002E ( . ) FULL STOP.
    map.lengths.clearRetainingCapacity();
    var it2 = std.mem.splitScalar(u8, map.list.items, '.');
    while (it2.next()) |label| {
        try map.lengths.append(map.allocator, label.len);
        try map.lengths.append(map.allocator, 1);
    }
    _ = map.lengths.orderedRemove(map.lengths.items.len - 1);

    // 4. Convert/Validate. For each label in the domain_name string:
    for (0..map.lengths.items.len) |n| {
        var label = map.items(n);
        if (std.mem.eql(u8, label, ".")) continue;
        if (std.mem.startsWith(u8, label, "xn--")) {
            // 1. If the label contains any non-ASCII code point (i.e., a code point greater than U+007F), record that there was an error, and continue with the next label.
            if (!extras.matchesAll(u8, label, std.ascii.isAscii)) return error.IDNAFailure;
            // 2. Attempt to convert the rest of the label to Unicode according to Punycode [RFC3492]. If that conversion fails and if not IgnoreInvalidPunycode, record that there was an error, and continue with the next label. Otherwise replace the original label in the string by the results of the conversion.
            punycode.decode(map, n) catch |err| switch (err) {
                error.InvalidPunycode => if (!IgnoreInvalidPunycode) return error.IDNAFailure,
                else => |e| return e,
            };
            label = map.items(n);
            // 3. If the label is empty, or if the label contains only ASCII code points, record that there was an error.
            if (label.len == 0) return error.IDNAFailure;
            if (extras.matchesAll(u8, label, std.ascii.isAscii)) return error.IDNAFailure;
            // 4. Verify that the label meets the validity criteria in Section 4.1, Validity Criteria for Nontransitional Processing. If any of the validity criteria are not satisfied, record that there was an error.
        } else {
            // 1. Verify that the label meets the validity criteria in Section 4.1, Validity Criteria for the input Processing choice (Transitional or Nontransitional). If any of the validity criteria are not satisfied, record that there was an error.
        }
    }

    var domain_is_bidi = false;
    it = std.unicode.Utf8View.initUnchecked(map.list.items).iterator();
    while (it.nextCodepointSlice()) |s| {
        const c = std.unicode.utf8Decode(s) catch unreachable;
        const p = ucd.unicode_data.find(c);
        switch (p[4]) {
            .R, .AL, .AN => domain_is_bidi = true,
            else => {},
        }
    }

    for (0..map.lengths.items.len) |n| {
        const label = map.items(n);
        if (std.mem.eql(u8, label, ".")) continue;

        if (!extras.matchesAll(u8, label, std.ascii.isAscii)) {
            // label was punycode converted above
            // 4. Verify that the label meets the validity criteria in Section 4.1, Validity Criteria for Nontransitional Processing. If any of the validity criteria are not satisfied, record that there was an error.
            try Validity_Criteria(label, CheckHyphens, false, UseSTD3ASCIIRules, CheckJoiners, CheckBidi and domain_is_bidi);
        } else {
            // label was already ascii
            // 1. Verify that the label meets the validity criteria in Section 4.1, Validity Criteria for the input Processing choice (Transitional or Nontransitional). If any of the validity criteria are not satisfied, record that there was an error.
            try Validity_Criteria(label, CheckHyphens, Transitional_Processing, UseSTD3ASCIIRules, CheckJoiners, CheckBidi and domain_is_bidi);
        }
    }
}

//
//
//

fn mappingRow(cp: u21) struct { table.Status, []const u21, table.Status2008 } {
    if (std.sort.binarySearch(table.Row, &table.data, cp, extras.compareFnField(u21, table.Row, .cp))) |idx| {
        const row = table.data[idx];
        return .{ row.status, row.mapping, row.status2 };
    }
    if (std.sort.binarySearch(table.RowRange, &table.data_range, cp, extras.compareFnRange(u21, table.RowRange, .from, .to))) |idx| {
        const row = table.data_range[idx];
        return .{ row.status, row.mapping, row.status2 };
    }
    unreachable;
}

// TODO:
fn isNFC(map: *const extras.ManyArrayList(u8)) bool {
    _ = map;
    return false;
}

// https://unicode.org/reports/tr46/#Validity_Criteria
fn Validity_Criteria(
    label: []const u8,
    CheckHyphens: bool,
    Transitional_Processing: bool, //deprecated,
    UseSTD3ASCIIRules: bool,
    CheckJoiners: bool,
    CheckBidi: bool,
) !void {
    // Each of the following criteria must be satisfied for a non-empty label:
    if (label.len == 0) return;
    // 1. The label must be in Unicode Normalization Form NFC.
    {}
    // 2. If CheckHyphens, the label must not contain a U+002D HYPHEN-MINUS character in both the third and fourth positions.
    if (CheckHyphens and label.len >= 4 and label[2] == '-' and label[3] == '-') return error.IDNAFailure;
    // 3. If CheckHyphens, the label must neither begin nor end with a U+002D HYPHEN-MINUS character.
    if (CheckHyphens and std.mem.startsWith(u8, label, "-")) return error.IDNAFailure;
    if (CheckHyphens and std.mem.endsWith(u8, label, "-")) return error.IDNAFailure;
    // 4. If not CheckHyphens, the label must not begin with “xn--”.
    if (!CheckHyphens and std.mem.startsWith(u8, label, "xn--")) return error.IDNAFailure;
    // 5. The label must not contain a U+002E ( . ) FULL STOP.
    if (std.mem.indexOfScalar(u8, label, '.') != null) return error.IDNAFailure;

    // 6. The label must not begin with a combining mark, that is: General_Category=Mark.
    const first_b = label[0];
    const first_l = std.unicode.utf8ByteSequenceLength(first_b) catch unreachable;
    const first_c = std.unicode.utf8Decode(label[0..first_l]) catch unreachable;
    const first_p = ucd.unicode_data.find(first_c);
    if (first_p[2] == .M) return error.IDNAFailure;
    if (first_p[2] == .Combining_Mark) return error.IDNAFailure;
    if (first_p[2] == .Mc) return error.IDNAFailure;
    if (first_p[2] == .Me) return error.IDNAFailure;
    if (first_p[2] == .Mn) return error.IDNAFailure;

    // 7. Each code point in the label must only have certain Status values according to Section 5, IDNA Mapping Table:
    var it = std.unicode.Utf8View.initUnchecked(label).iterator();
    var prev_ccc: u8 = 0;
    var prev_cp: u21 = 0;

    // 8. If CheckJoiners, the label must satisify the ContextJ rules from RFC 5892 Appendix A.
    var point_2before: ucd.unicode_data.Codepoint = ucd.unicode_data.data[0];
    var point_before: ucd.unicode_data.Codepoint = ucd.unicode_data.data[0];
    var zwnj_state: enum { start, dual_joining, transparent1, zwnj, transparent2, right_joining } = .start;
    var check_zwnj_state: ?bool = null;

    // 9. If CheckBidi, and if the domain name is a Bidi domain name, then the label must satisfy all six of the numbered conditions in RFC 5893 Section 2.
    // 9.1. The first character must be a character with Bidi property L, R, or AL.  If it has the R or AL property, it is an RTL label; if it has the L property, it is an LTR label.
    // 9.2. In an RTL label, only characters with the Bidi properties R, AL, AN, EN, ES, CS, ET, ON, BN, or NSM are allowed.
    // 9.3. In an RTL label, the end of the label must be a character with Bidi property R, AL, EN, or AN, followed by zero or more characters with Bidi property NSM.
    // 9.4. In an RTL label, if an EN is present, no AN may be present, and vice versa.
    // 9.5. In an LTR label, only characters with the Bidi properties L, EN, ES, CS, ET, ON, BN, or NSM are allowed.
    // 9.6. In an LTR label, the end of the label must be a character with Bidi property L or EN, followed by zero or more characters with Bidi property NSM.
    var seen_en = false;
    var seen_an = false;
    var last_bidi_class: ucd.BidiClass = .NSM;
    if (CheckBidi) {
        switch (first_p[4]) {
            .L => {},
            .R, .AL => {},
            else => return error.IDNAFailure,
        }
    }

    while (it.nextCodepointSlice()) |sl| {
        const cp = std.unicode.utf8Decode(sl) catch unreachable;
        const status, _, _ = mappingRow(cp);

        // [V1]
        const ccc = normalization.cpCCC(cp);
        if (prev_ccc > ccc and ccc > 0) return error.IDNAFailure;
        for (&ucd.derived_normalization_props.nfc_qc_n.data) |d| if (cp == d) return error.IDNAFailure;
        for (&ucd.derived_normalization_props.nfc_qc_n.data_range) |d| if (cp >= d.from and cp <= d.to) return error.IDNAFailure;
        for (&ucd.derived_normalization_props.nfc_qc_m.data) |d| if (cp == d) {
            for (&ucd.unicode_data.data) |r| {
                if (r[5] != .__canonical) continue;
                if (r[6].len != 2) continue;
                if (r[6][0] != prev_cp) continue;
                if (r[6][1] != cp) continue;
                if (std.sort.binarySearch(u21, &ucd.composition_exclusions.data, r[0], extras.compareFnBasic(u21)) != null) continue;
                // if (r[3] != 0) continue;
                return error.IDNAFailure;
            }
        };
        for (&ucd.derived_normalization_props.nfc_qc_m.data_range) |d| if (cp >= d.from and cp <= d.to) {
            for (&ucd.unicode_data.data) |r| {
                if (r[5] != .__canonical) continue;
                if (r[6].len != 2) continue;
                if (r[6][0] != prev_cp) continue;
                if (r[6][1] != cp) continue;
                if (std.sort.binarySearch(u21, &ucd.composition_exclusions.data, r[0], extras.compareFnBasic(u21)) != null) continue;
                // if (r[3] != 0) continue;
                return error.IDNAFailure;
            }
        };
        prev_ccc = ccc;
        prev_cp = cp;

        // 1. For Transitional Processing (deprecated), each value must be valid.
        // 2. For Nontransitional Processing, each value must be either valid or deviation.
        if (Transitional_Processing) {
            if (!(status == .valid)) return error.IDNAFailure;
        } else {
            if (!(status == .valid or status == .deviation)) return error.IDNAFailure;
        }

        // 3. In addition, if UseSTD3ASCIIRules=true and the code point is an ASCII code point (U+0000..U+007F), then it must be a lowercase letter (a-z), a digit (0-9), or a hyphen-minus (U+002D).
        // (Note: This excludes uppercase ASCII A-Z which are mapped in UTS #46 and disallowed in IDNA2008.)
        if (UseSTD3ASCIIRules and std.ascii.isAscii(sl[0])) blk: {
            if (std.ascii.isLower(sl[0])) break :blk;
            if (std.ascii.isDigit(sl[0])) break :blk;
            if (sl[0] == '-') break :blk;
            return error.IDNAFailure;
        }

        const p = ucd.unicode_data.find(cp);

        if (CheckJoiners) {
            // Appendix A.1.  ZERO WIDTH NON-JOINER
            if (cp == 0x200C) {
                if (check_zwnj_state == null) check_zwnj_state = true;
                if (point_before[3] == 9) check_zwnj_state = false;
            }
            switch (zwnj_state) {
                .start => {
                    if (Joining_Type(cp)) |t| {
                        if (t == .L) zwnj_state = .dual_joining;
                        if (t == .D) zwnj_state = .dual_joining;
                    }
                },
                .dual_joining => {
                    if (Joining_Type(cp)) |t| {
                        switch (t) {
                            .T => zwnj_state = .transparent1,
                            .L, .D => {},
                            else => zwnj_state = .transparent1,
                        }
                    } else {
                        zwnj_state = .transparent1;
                    }
                    if (cp == 0x200C) zwnj_state = .zwnj;
                },
                .transparent1 => {
                    if (cp == 0x200C) {
                        zwnj_state = .zwnj;
                    } else {
                        zwnj_state = .start;
                    }
                },
                .zwnj => {
                    if (Joining_Type(cp)) |t| {
                        switch (t) {
                            .T => zwnj_state = .transparent2,
                            .R, .D => zwnj_state = .right_joining,
                            .L => zwnj_state = .dual_joining,
                            else => zwnj_state = .transparent2,
                        }
                    } else {
                        zwnj_state = .transparent2;
                    }
                },
                .transparent2 => {
                    if (Joining_Type(cp)) |t| {
                        switch (t) {
                            .R, .D => zwnj_state = .right_joining,
                            .L => zwnj_state = .dual_joining,
                            else => zwnj_state = .start,
                        }
                    } else {
                        zwnj_state = .start;
                    }
                },
                .right_joining => {
                    //rule passed
                },
            }
            // Appendix A.2.  ZERO WIDTH JOINER
            if (cp == 0x200D and point_before[3] != 9) return error.IDNAFailure;
            // Appendix A.3.  MIDDLE DOT
            if (point_before[0] == 0x00B7 and !(point_2before[0] == 0x006C and cp == 0x006C)) return error.IDNAFailure;
            // Appendix A.4.  GREEK LOWER NUMERAL SIGN (KERAIA)
            if (point_before[0] == 0x0375 and !(Script(cp) == .Greek)) return error.IDNAFailure;
            // Appendix A.5.  HEBREW PUNCTUATION GERESH
            if (cp == 0x05F3 and !(Script(point_before[0]) == .Hebrew)) return error.IDNAFailure;
            // Appendix A.6.  HEBREW PUNCTUATION GERSHAYIM
            if (cp == 0x05F4 and !(Script(point_before[0]) == .Hebrew)) return error.IDNAFailure;
            // Appendix A.7.  KATAKANA MIDDLE DOT
            if (false) return error.IDNAFailure;
            // Appendix A.8.  ARABIC-INDIC DIGITS
            if (false) return error.IDNAFailure;
            // Appendix A.9.  EXTENDED ARABIC-INDIC DIGITS
            if (false) return error.IDNAFailure;
        }
        point_2before = point_before;
        point_before = p;

        if (CheckBidi) {
            switch (first_p[4]) {
                .L => {
                    switch (p[4]) {
                        .L, .EN, .ES, .CS, .ET, .ON, .BN => |cl| last_bidi_class = cl,
                        .NSM => {},
                        else => return error.IDNAFailure,
                    }
                },
                .R, .AL => {
                    switch (p[4]) {
                        .R, .AL, .AN, .EN, .ES, .CS, .ET, .ON, .BN => |cl| last_bidi_class = cl,
                        .NSM => {},
                        else => return error.IDNAFailure,
                    }
                    if (p[4] == .EN and seen_an) return error.IDNAFailure;
                    if (p[4] == .EN) seen_en = true;
                    if (p[4] == .AN and seen_en) return error.IDNAFailure;
                    if (p[4] == .AN) seen_an = true;
                },
                else => unreachable,
            }
        }
    }
    if (CheckJoiners) {
        if (check_zwnj_state == true and zwnj_state != .right_joining) return error.IDNAFailure;
    }
    if (CheckBidi) {
        switch (first_p[4]) {
            .L => {
                switch (last_bidi_class) {
                    .L, .EN => {},
                    else => return error.IDNAFailure,
                }
            },
            .R, .AL => {
                switch (last_bidi_class) {
                    .R, .AL, .EN, .AN => {},
                    else => return error.IDNAFailure,
                }
            },
            else => unreachable,
        }
    }
}

fn Script(cp: u21) ucd.ScriptLong {
    for (&ucd.scripts.data) |d| {
        if (cp >= d.from and cp <= d.to) {
            return d.script;
        }
    }
    unreachable;
}
fn Joining_Type(cp: u21) ?ucd.arabic_shaping.Joining.Type {
    for (&ucd.arabic_shaping.data) |d| {
        if (cp == d.codepoint) {
            return d.joining_type;
        }
    }
    return null;
}
