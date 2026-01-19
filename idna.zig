const std = @import("std");
const extras = @import("extras");
const ucd = @import("unicode-ucd");
const normalization = @import("./normalization.zig");
const punycode = @import("./punycode.zig");

pub const @"2008" = @import("./2008.zig");

pub const table = @import("./table.zig");

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
        };
    }

    if (VerifyDnsLength) {
        //
    }

    return map.toOwnedSlice();
}

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
            try Validity_Criteria(label, CheckHyphens, true, false, UseSTD3ASCIIRules, CheckJoiners, CheckBidi);
        } else {
            // 1. Verify that the label meets the validity criteria in Section 4.1, Validity Criteria for the input Processing choice (Transitional or Nontransitional). If any of the validity criteria are not satisfied, record that there was an error.
            try Validity_Criteria(label, CheckHyphens, Transitional_Processing, !Transitional_Processing, UseSTD3ASCIIRules, CheckJoiners, CheckBidi);
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

fn Validity_Criteria(
    label: []const u8,
    CheckHyphens: bool,
    Transitional_Processing: bool, //deprecated,
    NonTransitional_Processing: bool, //deprecated,
    UseSTD3ASCIIRules: bool,
    CheckJoiners: bool,
    CheckBidi: bool,
) !void {
    // if (!isNFC(label)) return error.IDNAFailure; // TODO:
    if (CheckHyphens and label.len >= 4 and label[2] == '-' and label[3] == '-') return error.IDNAFailure;
    if (CheckHyphens and std.mem.startsWith(u8, label, "-")) return error.IDNAFailure;
    if (CheckHyphens and std.mem.endsWith(u8, label, "-")) return error.IDNAFailure;
    if (!CheckHyphens and std.mem.startsWith(u8, label, "xn--")) return error.IDNAFailure;
    if (std.mem.indexOfScalar(u8, label, '.') != null) return error.IDNAFailure;

    _ = Transitional_Processing;
    _ = NonTransitional_Processing;
    _ = UseSTD3ASCIIRules;
    _ = CheckJoiners;
    _ = CheckBidi;
}
