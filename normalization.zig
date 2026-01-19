const std = @import("std");
const extras = @import("extras");
const ucd = @import("unicode-ucd");

const data = extras.StaticMultiList(ucd.unicode_data.Codepoint).initComptime(&ucd.unicode_data.data);
const data_first_gap = blk: {
    for (data.items[0], 0..) |cp, i| {
        if (cp != i) {
            break :blk i;
        }
    }
};
// comptime { @compileLog(data_first_gap); } // 888 as of 17.

// hangul syllable constants
const SBase = 0xAC00;
const LBase = 0x1100;
const VBase = 0x1161;
const TBase = 0x11A7;
const LCount = 19;
const VCount = 21;
const TCount = 28;
const NCount = VCount * TCount;
const SCount = LCount * NCount;

pub fn ToNFD(map: *extras.ManyArrayList(u8)) !void {
    try Decomposition(map, .canonical);
}

pub fn ToNFC(map: *extras.ManyArrayList(u8)) !void {
    try ToNFD(map);
    try CanonicalComposition(map);
}

pub fn ToNFKD(map: *extras.ManyArrayList(u8)) !void {
    try Decomposition(map, .compatibility);
}

pub fn ToNFKC(map: *extras.ManyArrayList(u8)) !void {
    try ToNFKD(map);
    try CanonicalComposition(map);
}

fn Decomposition(map: *extras.ManyArrayList(u8), kind: enum { canonical, compatibility }) !void {
    // fully decompose all codepoints in the string
    var n: usize = 0;
    while (n < map.lengths.items.len) : (n += 1) {
        const sl = map.items(n);
        const cp = std.unicode.utf8Decode(sl) catch unreachable;
        if (std.sort.binarySearch(u21, data.items[0], cp, extras.compareFnBasic(u21))) |j| {
            if (data.items[5][j] == .__none) continue;
            if ((data.items[5][j] == .__canonical) != (kind == .canonical)) continue;
            map.remove(n);
            for (data.items[6][j], 0..) |ktem, k| {
                var buf: [4]u8 = undefined;
                const l = std.unicode.utf8Encode(ktem, &buf) catch unreachable;
                try map.insertAt(n + k, buf[0..l]);
            }
            n += data.items[6][j].len - 1;
        }
    }
    // sort non-starters with respect to canonical ordering
    n = 0;
    while (n < map.lengths.items.len) : (n += 1) {
        const sln = map.items(n);
        const cp = std.unicode.utf8Decode(sln) catch unreachable;
        const ccc = cpCCC(cp);
        if (ccc == 0) continue; // starter copdepoint
        if (n == map.lengths.items.len - 1) break;
        var buf: [128]u8 = @splat(0);
        var len: u8 = 0;
        buf[0] = ccc;
        len += 1;
        for (n + 1..map.lengths.items.len) |j| {
            const slj = map.items(j);
            const dp = std.unicode.utf8Decode(slj) catch unreachable;
            const ddd = cpCCC(dp);
            if (ddd == 0) break;
            buf[len] = ddd;
            len += 1;
        }
        const S = struct {
            nstart: usize,
            buf: []u8,
            map: *extras.ManyArrayList(u8),

            pub fn lessThan(self: *const @This(), a: usize, b: usize) bool {
                return self.buf[a] < self.buf[b];
            }
            pub fn swap(self: *const @This(), a: usize, b: usize) void {
                std.mem.swap(u8, &self.buf[a], &self.buf[b]);
                self.map.swap(self.nstart + a, self.nstart + b);
            }
        };
        std.mem.sortContext(0, len, S{
            .nstart = n,
            .buf = buf[0..len],
            .map = map,
        });
        n += len;
    }
}

fn CanonicalComposition(map: *extras.ManyArrayList(u8)) !void {
    if (map.lengths.items.len < 2) {
        return;
    }

    if (map.lengths.items.len == 2) {
        const sll = map.items(0);
        const l = std.unicode.utf8Decode(sll) catch unreachable;
        const slc = map.items(1);
        const c = std.unicode.utf8Decode(slc) catch unreachable;

        for (&ucd.unicode_data.data) |d| {
            if (d[5] != .__canonical) continue;
            if (d[6].len != 2) continue;
            if (d[6][0] != l) continue;
            if (d[6][1] != c) continue;
            if (std.sort.binarySearch(u21, &ucd.composition_exclusions.data, d[0], extras.compareFnBasic(u21)) != null) continue;
            if (d[3] != 0) continue;

            var buf: [4]u8 = undefined;
            const len = std.unicode.utf8Encode(d[0], &buf) catch unreachable;
            try map.set(0, buf[0..len]);
            map.remove(1);
            break;
        }
        return;
    }

    var i: usize = 1;
    while (i < map.lengths.items.len) : (i += 1) {
        const slc = map.items(i);
        const c = std.unicode.utf8Decode(slc) catch unreachable;
        var j: usize = i - 1;
        var sll = map.items(j);
        var l = std.unicode.utf8Decode(sll) catch unreachable;
        while (j > 0) : (j -= 1) {
            sll = map.items(j);
            l = std.unicode.utf8Decode(sll) catch unreachable;
            if (cpCCC(l) == 0) break;
        }
        for (&ucd.unicode_data.data) |d| {
            if (d[5] != .__canonical) continue;
            if (d[6].len != 2) continue;
            if (d[6][0] != l) continue;
            if (d[6][1] != c) continue;
            if (std.sort.binarySearch(u21, &ucd.composition_exclusions.data, d[0], extras.compareFnBasic(u21)) != null) continue;
            if (d[3] != 0) continue;

            var buf: [4]u8 = undefined;
            const len = std.unicode.utf8Encode(d[0], &buf) catch unreachable;
            try map.set(j, buf[0..len]);
            map.remove(i);
            i -= 1;
            break;
        }
    }
    i = 0;
    while (i < map.lengths.items.len) : (i += 1) {
        const sll = map.items(i);
        const cpl = std.unicode.utf8Decode(sll) catch unreachable;
        if ((hangul_syllable_type(cpl) orelse continue) != .L) continue;
        std.debug.assert(cpl >= 0x1100 and cpl <= 0x1112);

        if (i + 1 == map.lengths.items.len) break;
        const slv = map.items(i + 1);
        const cpv = std.unicode.utf8Decode(slv) catch unreachable;
        if ((hangul_syllable_type(cpv) orelse continue) != .V) continue;
        std.debug.assert(cpv >= 0x1161 and cpv <= 0x1175);

        if (i + 2 == map.lengths.items.len) {
            //seq is only <L,V>
            try composeHangulSyllable2(map, i, cpl, cpv);
            continue;
        }

        const slt = map.items(i + 2);
        const cpt = std.unicode.utf8Decode(slt) catch unreachable;
        if ((hangul_syllable_type(cpt) orelse {
            // try composeHangulSyllable2(map, i, cpl, cpv);
            continue;
        }) != .T) {
            // try composeHangulSyllable2(map, i, cpl, cpv);
            continue;
        }
        std.debug.assert(cpt >= 0x11A8 and cpt <= 0x11C2);
        // seq is <L,V,T>
        try composeHangulSyllable3(map, i, cpl, cpv, cpt);
    }
}

fn cpCCC(cp: u21) u8 {
    if (cp < data_first_gap) {
        return data.items[3][cp];
    }
    if (std.sort.binarySearch(u21, data.items[0], cp, extras.compareFnBasic(u21))) |idx| {
        return data.items[3][idx];
    }
    // TODO: this happens to be correct but ucd.unicode_data needs to detect the block ranges
    return 0;
}

fn hangul_syllable_type(cp: u21) ?ucd.HangulSyllableType {
    // can't use std.sort.binarySearch on this set because it's not sorted
    // TODO: update ucd to have that property
    for (&ucd.hangul_syllable_type.data) |d| {
        if (cp >= d.from and cp <= d.to) {
            return d.prop;
        }
    }
    return null;
}

fn composeHangulSyllable2(map: *extras.ManyArrayList(u8), i: usize, cpl: u21, cpv: u21) !void {
    const LIndex = cpl - LBase;
    const VIndex = cpv - VBase;
    const LVIndex = LIndex * NCount + VIndex * TCount;
    const cps = SBase + LVIndex;
    var buf: [4]u8 = undefined;
    const len = std.unicode.utf8Encode(cps, &buf) catch unreachable;
    try map.set(i, buf[0..len]);
    map.remove(i + 1);
}

fn composeHangulSyllable3(map: *extras.ManyArrayList(u8), i: usize, cpl: u21, cpv: u21, cpt: u21) !void {
    const LIndex = cpl - LBase;
    const VIndex = cpv - VBase;
    const TIndex = cpt - TBase;
    const LVIndex = LIndex * NCount + VIndex * TCount;
    const cps = SBase + LVIndex + TIndex;
    var buf: [4]u8 = undefined;
    const len = std.unicode.utf8Encode(cps, &buf) catch unreachable;
    try map.set(i, buf[0..len]);
    map.remove(i + 1);
    map.remove(i + 1);
}
