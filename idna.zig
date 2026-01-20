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
        //
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
    while (it.nextCodepointSlice()) |sl| {
        const cp = std.unicode.utf8Decode(sl) catch unreachable;
        const status, _, _ = mappingRow(cp);

        // 1. For Transitional Processing (deprecated), each value must be valid.
        // 2. For Nontransitional Processing, each value must be either valid or deviation.
        if (Transitional_Processing) {
            if (!(status == .valid)) return error.IDNAFailure;
        } else {
            if (!(status == .valid or status == .deviation)) return error.IDNAFailure;
        }

        // 3. In addition, if UseSTD3ASCIIRules=true and the code point is an ASCII code point (U+0000..U+007F), then it must be a lowercase letter (a-z), a digit (0-9), or a hyphen-minus (U+002D).
        // (Note: This excludes uppercase ASCII A-Z which are mapped in UTS #46 and disallowed in IDNA2008.)
        if (UseSTD3ASCIIRules and std.ascii.isAscii(sl[0])) {
            if (std.ascii.isLower(sl[0])) continue;
            if (std.ascii.isDigit(sl[0])) continue;
            if (sl[0] == '-') continue;
            return error.IDNAFailure;
        }
    }

    // 8. If CheckJoiners, the label must satisify the ContextJ rules from RFC 5892 Appendix A.
    if (CheckJoiners) {
        //
    }

    // 9. If CheckBidi, and if the domain name is a Bidi domain name, then the label must satisfy all six of the numbered conditions in RFC 5893 Section 2.
    if (CheckBidi) {
        // 1. The first character must be a character with Bidi property L, R, or AL.  If it has the R or AL property, it is an RTL label; if it has the L property, it is an LTR label.
        // 2. In an RTL label, only characters with the Bidi properties R, AL, AN, EN, ES, CS, ET, ON, BN, or NSM are allowed.
        // 3. In an RTL label, the end of the label must be a character with Bidi property R, AL, EN, or AN, followed by zero or more characters with Bidi property NSM.
        // 4. In an RTL label, if an EN is present, no AN may be present, and vice versa.
        // 5. In an LTR label, only characters with the Bidi properties L, EN, ES, CS, ET, ON, BN, or NSM are allowed.
        // 6. In an LTR label, the end of the label must be a character with Bidi property L or EN, followed by zero or more characters with Bidi property NSM.
        switch (first_p[4]) {
            .L => {
                it.i = 0;
                while (it.nextCodepointSlice()) |sl| {
                    const cp = std.unicode.utf8Decode(sl) catch unreachable;
                    const point = ucd.unicode_data.find(cp);
                    switch (point[4]) {
                        .L, .EN, .ES, .CS, .ET, .ON, .BN, .NSM => {},
                        else => return error.IDNAFailure,
                    }
                }
            },
            .R, .AL => {
                it.i = 0;
                var seen_en = false;
                var seen_an = false;
                while (it.nextCodepointSlice()) |sl| {
                    const cp = std.unicode.utf8Decode(sl) catch unreachable;
                    const point = ucd.unicode_data.find(cp);
                    switch (point[4]) {
                        .R, .AL, .AN, .EN, .ES, .CS, .ET, .ON, .BN, .NSM => {},
                        else => return error.IDNAFailure,
                    }
                    if (point[4] == .EN and seen_an) return error.IDNAFailure;
                    if (point[4] == .EN) seen_en = true;
                    if (point[4] == .AN and seen_en) return error.IDNAFailure;
                    if (point[4] == .AN) seen_an = true;
                }
            },
            else => return error.IDNAFailure,
        }
    }
}
