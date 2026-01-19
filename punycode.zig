const std = @import("std");
const extras = @import("extras");

const base = 36;
const tmin = 1;
const tmax = 26;
const skew = 38;
const damp = 700;
const initial_bias = 72;
const initial_n = 128;
const delimiter = '-';

pub fn decode(map: *extras.ManyArrayList(u8), map_n: usize) !void {
    var input = map.items(map_n);
    var offset: usize = 0;
    const initial_len = input.len;
    // std.debug.assert(std.mem.startsWith(u8, map.items(n), "xn--"));
    offset += 4;
    input = input[offset..initial_len];

    var word_n: u32 = 0;
    word_n += initial_n;

    // let n = initial_n
    var n: u21 = 128;
    // let i = 0
    var i: u32 = 0;
    // let bias = initial_bias
    var bias: u32 = initial_bias;
    // let output = an empty string indexed from 0
    // output is ascii so output_length as codepoint or bytes is the same
    var output_length: u32 = 0;
    // consume all code points before the last delimiter (if there is one) and copy them to output, fail on any non-basic code point
    // if more than zero code points were consumed then consume one more (which will be the last delimiter)
    if (std.mem.lastIndexOfScalar(u8, input, delimiter)) |idx| {
        // we're passing input as what we're appending so we have to ensure the backing allocation is not invalidated by calling append
        try map.list.ensureUnusedCapacity(map.allocator, idx);
        input = map.items(map_n)[offset..initial_len];
        try map.appendSlice(map_n, input[0..idx]);
        offset += idx + 1;
        input = input[idx + 1 ..];
        output_length += @intCast(idx);
    }
    // while the input is not exhausted do begin
    while (offset < initial_len) {
        // let oldi = i
        const oldi = i;
        // let w = 1
        var w: u32 = 1;
        // for k = base to infinity in steps of base do begin
        var k: u32 = base;
        while (true) : (k += base) {
            // consume a code point, or fail if there was none to consume
            if (input.len == 0) return error.InvalidPunycode;
            const sl = input[0 .. std.unicode.utf8ByteSequenceLength(input[0]) catch unreachable];
            offset += sl.len;
            input = input[sl.len..];
            // let digit = the code point's digit-value, fail if it has none
            const cp = std.unicode.utf8Decode(sl) catch unreachable;
            const digit: u32 = blk: {
                if (cp >= 'A' and cp <= 'Z') break :blk cp - 'A';
                if (cp >= 'a' and cp <= 'z') break :blk cp - 'a';
                if (cp >= '0' and cp <= '9') break :blk cp - '0' + 26;
                return error.InvalidPunycode;
            };
            // let i = i + digit * w, fail on overflow
            i = std.math.add(u32, i, std.math.mul(u32, digit, w) catch return error.InvalidPunycode) catch return error.InvalidPunycode;
            // let t = tmin if k <= bias {+ tmin}, or
            //         tmax if k >= bias + tmax, or k - bias otherwise
            const t = if (k <= bias) tmin else if (k >= bias + tmax) tmax else k - bias;
            // if digit < t then break
            if (digit < t) break;
            // let w = w * (base - t), fail on overflow
            w = w * (base - t);
        }
        // let bias = adapt(i - oldi, length(output) + 1, test oldi is 0?)
        bias = adapt(i - oldi, output_length + 1, oldi == 0);
        // let n = n + i div (length(output) + 1), fail on overflow
        n = std.math.add(u21, n, @intCast(i / (output_length + 1))) catch return error.InvalidPunycode;
        // let i = i mod (length(output) + 1)
        i = i % (output_length + 1);
        // {if n is a basic code point then fail}
        std.debug.assert(n > std.math.maxInt(u7));
        // insert n into output at position i
        if (i == output_length) {
            var buf: [4]u8 = undefined;
            const len = std.unicode.utf8Encode(n, &buf) catch unreachable;
            try map.appendSlice(map_n, buf[0..len]);
            input = map.items(map_n)[offset..initial_len];
            output_length += 1;
        } else {
            var ioff: usize = 0;
            var cpi: usize = 0;
            var it = std.unicode.Utf8View.initUnchecked(map.items(map_n)[initial_len..]).iterator();
            while (it.nextCodepointSlice()) |sl| {
                if (cpi == i) break;
                ioff += sl.len;
                cpi += 1;
            }
            var buf: [4]u8 = undefined;
            const len = std.unicode.utf8Encode(n, &buf) catch unreachable;
            try map.replace(map_n, initial_len + ioff, 0, buf[0..len]);
            input = map.items(map_n)[offset..initial_len];
            output_length += 1;
        }
        // increment i
        i += 1;
    }

    try map.replace(map_n, 0, initial_len, "");
}

fn adapt(delta_: u32, numpoints: u32, firsttime: bool) u32 {
    var delta = delta_;
    // if firsttime then let delta = delta div damp
    // else let delta = delta div 2
    delta = if (firsttime) delta / damp else delta / 2;
    // let delta = delta + (delta div numpoints)
    delta = delta + (delta / numpoints);
    // let k = 0
    var k: u32 = 0;
    // while delta > ((base - tmin) * tmax) div 2 do begin
    while (delta > ((base - tmin) * tmax) / 2) {
        // let delta = delta div (base - tmin)
        delta /= base - tmin;
        // let k = k + base
        k += base;
    }
    // return k + (((base - tmin + 1) * delta) div (delta + skew))
    return k + (((base - tmin + 1) * delta) / (delta + skew));
}

// TODO:
pub fn encode(map: *extras.ManyArrayList(u8), n: usize) !void {
    _ = map;
    _ = n;
}
