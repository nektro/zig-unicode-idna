// This file is part of Unicode IDNA Compatibility Processing
// For documentation, see http://www.unicode.org/reports/tr46/
//

// Based on the source file: https://www.unicode.org/Public/17.0.0/idna/IdnaTestV2.txt
//
// zig fmt: off

const std = @import("std");
const idna = @import("unicode-idna");
const expect = @import("expect").expect;

fn toUnicodePass(
    source: []const u8,
    expected: []const u8,
) !void {
    const allocator = std.testing.allocator;
    const result = try idna.ToUnicode(allocator, source, true, true, true, true, false, false);
    defer allocator.free(result);
    try expect(result).toEqualString(expected);
}

fn toUnicodeFail(
    source: []const u8,
) !void {
    const allocator = std.testing.allocator;
    const result = idna.ToUnicode(allocator, source, true, true, true, true, false, false) catch |err| switch (err) {
        error.IDNAFailure => return,
        error.OutOfMemory => return error.OutOfMemory,
    };
    defer allocator.free(result);
    return error.ShouldHaveFailed;
}

fn toAsciiPass(
    source: []const u8,
    expected: []const u8,
    Transitional_Processing: bool,
) !void {
    const allocator = std.testing.allocator;
    const result = try idna.ToASCII(allocator, source, true, true, true, true, Transitional_Processing, true, false);
    defer allocator.free(result);
    try expect(result).toEqualString(expected);
}

fn toAsciiFail(
    source: []const u8,
    Transitional_Processing: bool,
) !void {
    const allocator = std.testing.allocator;
    const result = idna.ToASCII(allocator, source, true, true, true, true, Transitional_Processing, true, false) catch |err| switch (err) {
        error.IDNAFailure => return,
        error.OutOfMemory => return error.OutOfMemory,
    };
    defer allocator.free(result);
    return error.ShouldHaveFailed;
}

test { try toUnicodePass("fass.de", "fass.de"); }
test { try toAsciiPass("fass.de", "fass.de", false); }
test { try toAsciiPass("fass.de", "fass.de", true); }
test { try toUnicodePass("fa\xc3\x9f.de", "fa\xc3\x9f.de"); }
test { try toAsciiPass("fa\xc3\x9f.de", "xn--fa-hia.de", false); }
test { try toAsciiPass("fa\xc3\x9f.de", "fass.de", true); }
test { try toUnicodePass("Fa\xc3\x9f.de", "fa\xc3\x9f.de"); }
test { try toAsciiPass("Fa\xc3\x9f.de", "xn--fa-hia.de", false); }
test { try toAsciiPass("Fa\xc3\x9f.de", "fass.de", true); }
test { try toUnicodePass("xn--fa-hia.de", "fa\xc3\x9f.de"); }
test { try toAsciiPass("xn--fa-hia.de", "xn--fa-hia.de", false); }
test { try toAsciiPass("xn--fa-hia.de", "xn--fa-hia.de", true); }
test { try toUnicodePass("\xc3\xa0.\xd7\x90\xcc\x88", "\xc3\xa0.\xd7\x90\xcc\x88"); }
test { try toAsciiPass("\xc3\xa0.\xd7\x90\xcc\x88", "xn--0ca.xn--ssa73l", false); }
test { try toAsciiPass("\xc3\xa0.\xd7\x90\xcc\x88", "xn--0ca.xn--ssa73l", true); }
test { try toUnicodePass("a\xcc\x80.\xd7\x90\xcc\x88", "\xc3\xa0.\xd7\x90\xcc\x88"); }
test { try toAsciiPass("a\xcc\x80.\xd7\x90\xcc\x88", "xn--0ca.xn--ssa73l", false); }
test { try toAsciiPass("a\xcc\x80.\xd7\x90\xcc\x88", "xn--0ca.xn--ssa73l", true); }
test { try toUnicodePass("A\xcc\x80.\xd7\x90\xcc\x88", "\xc3\xa0.\xd7\x90\xcc\x88"); }
test { try toAsciiPass("A\xcc\x80.\xd7\x90\xcc\x88", "xn--0ca.xn--ssa73l", false); }
test { try toAsciiPass("A\xcc\x80.\xd7\x90\xcc\x88", "xn--0ca.xn--ssa73l", true); }
test { try toUnicodePass("\xc3\x80.\xd7\x90\xcc\x88", "\xc3\xa0.\xd7\x90\xcc\x88"); }
test { try toAsciiPass("\xc3\x80.\xd7\x90\xcc\x88", "xn--0ca.xn--ssa73l", false); }
test { try toAsciiPass("\xc3\x80.\xd7\x90\xcc\x88", "xn--0ca.xn--ssa73l", true); }
test { try toUnicodePass("xn--0ca.xn--ssa73l", "\xc3\xa0.\xd7\x90\xcc\x88"); }
test { try toAsciiPass("xn--0ca.xn--ssa73l", "xn--0ca.xn--ssa73l", false); }
test { try toAsciiPass("xn--0ca.xn--ssa73l", "xn--0ca.xn--ssa73l", true); }
test { try toUnicodePass("\xc3\xa0\xcc\x88.\xd7\x90", "\xc3\xa0\xcc\x88.\xd7\x90"); }
test { try toAsciiPass("\xc3\xa0\xcc\x88.\xd7\x90", "xn--0ca81i.xn--4db", false); }
test { try toAsciiPass("\xc3\xa0\xcc\x88.\xd7\x90", "xn--0ca81i.xn--4db", true); }
test { try toUnicodePass("a\xcc\x80\xcc\x88.\xd7\x90", "\xc3\xa0\xcc\x88.\xd7\x90"); }
test { try toAsciiPass("a\xcc\x80\xcc\x88.\xd7\x90", "xn--0ca81i.xn--4db", false); }
test { try toAsciiPass("a\xcc\x80\xcc\x88.\xd7\x90", "xn--0ca81i.xn--4db", true); }
test { try toUnicodePass("A\xcc\x80\xcc\x88.\xd7\x90", "\xc3\xa0\xcc\x88.\xd7\x90"); }
test { try toAsciiPass("A\xcc\x80\xcc\x88.\xd7\x90", "xn--0ca81i.xn--4db", false); }
test { try toAsciiPass("A\xcc\x80\xcc\x88.\xd7\x90", "xn--0ca81i.xn--4db", true); }
test { try toUnicodePass("\xc3\x80\xcc\x88.\xd7\x90", "\xc3\xa0\xcc\x88.\xd7\x90"); }
test { try toAsciiPass("\xc3\x80\xcc\x88.\xd7\x90", "xn--0ca81i.xn--4db", false); }
test { try toAsciiPass("\xc3\x80\xcc\x88.\xd7\x90", "xn--0ca81i.xn--4db", true); }
test { try toUnicodePass("xn--0ca81i.xn--4db", "\xc3\xa0\xcc\x88.\xd7\x90"); }
test { try toAsciiPass("xn--0ca81i.xn--4db", "xn--0ca81i.xn--4db", false); }
test { try toAsciiPass("xn--0ca81i.xn--4db", "xn--0ca81i.xn--4db", true); }
test { try toAsciiPass("a\xe2\x80\x8cb", "ab", true); }
test { try toAsciiPass("A\xe2\x80\x8cB", "ab", true); }
test { try toAsciiPass("A\xe2\x80\x8cb", "ab", true); }
test { try toUnicodePass("ab", "ab"); }
test { try toAsciiPass("ab", "ab", false); }
test { try toAsciiPass("ab", "ab", true); }
test { try toUnicodePass("a\xe0\xa5\x8d\xe2\x80\x8cb", "a\xe0\xa5\x8d\xe2\x80\x8cb"); }
test { try toAsciiPass("a\xe0\xa5\x8d\xe2\x80\x8cb", "xn--ab-fsf604u", false); }
test { try toAsciiPass("a\xe0\xa5\x8d\xe2\x80\x8cb", "xn--ab-fsf", true); }
test { try toUnicodePass("A\xe0\xa5\x8d\xe2\x80\x8cB", "a\xe0\xa5\x8d\xe2\x80\x8cb"); }
test { try toAsciiPass("A\xe0\xa5\x8d\xe2\x80\x8cB", "xn--ab-fsf604u", false); }
test { try toAsciiPass("A\xe0\xa5\x8d\xe2\x80\x8cB", "xn--ab-fsf", true); }
test { try toUnicodePass("A\xe0\xa5\x8d\xe2\x80\x8cb", "a\xe0\xa5\x8d\xe2\x80\x8cb"); }
test { try toAsciiPass("A\xe0\xa5\x8d\xe2\x80\x8cb", "xn--ab-fsf604u", false); }
test { try toAsciiPass("A\xe0\xa5\x8d\xe2\x80\x8cb", "xn--ab-fsf", true); }
test { try toUnicodePass("xn--ab-fsf", "a\xe0\xa5\x8db"); }
test { try toAsciiPass("xn--ab-fsf", "xn--ab-fsf", false); }
test { try toAsciiPass("xn--ab-fsf", "xn--ab-fsf", true); }
test { try toUnicodePass("a\xe0\xa5\x8db", "a\xe0\xa5\x8db"); }
test { try toAsciiPass("a\xe0\xa5\x8db", "xn--ab-fsf", false); }
test { try toAsciiPass("a\xe0\xa5\x8db", "xn--ab-fsf", true); }
test { try toUnicodePass("A\xe0\xa5\x8dB", "a\xe0\xa5\x8db"); }
test { try toAsciiPass("A\xe0\xa5\x8dB", "xn--ab-fsf", false); }
test { try toAsciiPass("A\xe0\xa5\x8dB", "xn--ab-fsf", true); }
test { try toUnicodePass("A\xe0\xa5\x8db", "a\xe0\xa5\x8db"); }
test { try toAsciiPass("A\xe0\xa5\x8db", "xn--ab-fsf", false); }
test { try toAsciiPass("A\xe0\xa5\x8db", "xn--ab-fsf", true); }
test { try toUnicodePass("xn--ab-fsf604u", "a\xe0\xa5\x8d\xe2\x80\x8cb"); }
test { try toAsciiPass("xn--ab-fsf604u", "xn--ab-fsf604u", false); }
test { try toAsciiPass("xn--ab-fsf604u", "xn--ab-fsf604u", true); }
test { try toAsciiPass("a\xe2\x80\x8db", "ab", true); }
test { try toAsciiPass("A\xe2\x80\x8dB", "ab", true); }
test { try toAsciiPass("A\xe2\x80\x8db", "ab", true); }
test { try toUnicodePass("a\xe0\xa5\x8d\xe2\x80\x8db", "a\xe0\xa5\x8d\xe2\x80\x8db"); }
test { try toAsciiPass("a\xe0\xa5\x8d\xe2\x80\x8db", "xn--ab-fsf014u", false); }
test { try toAsciiPass("a\xe0\xa5\x8d\xe2\x80\x8db", "xn--ab-fsf", true); }
test { try toUnicodePass("A\xe0\xa5\x8d\xe2\x80\x8dB", "a\xe0\xa5\x8d\xe2\x80\x8db"); }
test { try toAsciiPass("A\xe0\xa5\x8d\xe2\x80\x8dB", "xn--ab-fsf014u", false); }
test { try toAsciiPass("A\xe0\xa5\x8d\xe2\x80\x8dB", "xn--ab-fsf", true); }
test { try toUnicodePass("A\xe0\xa5\x8d\xe2\x80\x8db", "a\xe0\xa5\x8d\xe2\x80\x8db"); }
test { try toAsciiPass("A\xe0\xa5\x8d\xe2\x80\x8db", "xn--ab-fsf014u", false); }
test { try toAsciiPass("A\xe0\xa5\x8d\xe2\x80\x8db", "xn--ab-fsf", true); }
test { try toUnicodePass("xn--ab-fsf014u", "a\xe0\xa5\x8d\xe2\x80\x8db"); }
test { try toAsciiPass("xn--ab-fsf014u", "xn--ab-fsf014u", false); }
test { try toAsciiPass("xn--ab-fsf014u", "xn--ab-fsf014u", true); }
test { try toUnicodePass("\xc2\xa1", "\xc2\xa1"); }
test { try toAsciiPass("\xc2\xa1", "xn--7a", false); }
test { try toAsciiPass("\xc2\xa1", "xn--7a", true); }
test { try toUnicodePass("xn--7a", "\xc2\xa1"); }
test { try toAsciiPass("xn--7a", "xn--7a", false); }
test { try toAsciiPass("xn--7a", "xn--7a", true); }
test { try toUnicodePass("\xe1\xa7\x9a", "\xe1\xa7\x9a"); }
test { try toAsciiPass("\xe1\xa7\x9a", "xn--pkf", false); }
test { try toAsciiPass("\xe1\xa7\x9a", "xn--pkf", true); }
test { try toUnicodePass("xn--pkf", "\xe1\xa7\x9a"); }
test { try toAsciiPass("xn--pkf", "xn--pkf", false); }
test { try toAsciiPass("xn--pkf", "xn--pkf", true); }
test { try toUnicodePass("\xea\xad\xa0", "\xea\xad\xa0"); }
test { try toAsciiPass("\xea\xad\xa0", "xn--3y9a", false); }
test { try toAsciiPass("\xea\xad\xa0", "xn--3y9a", true); }
test { try toUnicodePass("xn--3y9a", "\xea\xad\xa0"); }
test { try toAsciiPass("xn--3y9a", "xn--3y9a", false); }
test { try toAsciiPass("xn--3y9a", "xn--3y9a", true); }
test { try toUnicodePass("1234567890\xc3\xa41234567890123456789012345678901234567890123456", "1234567890\xc3\xa41234567890123456789012345678901234567890123456"); }
test { try toUnicodePass("1234567890a\xcc\x881234567890123456789012345678901234567890123456", "1234567890\xc3\xa41234567890123456789012345678901234567890123456"); }
test { try toUnicodePass("1234567890A\xcc\x881234567890123456789012345678901234567890123456", "1234567890\xc3\xa41234567890123456789012345678901234567890123456"); }
test { try toUnicodePass("1234567890\xc3\x841234567890123456789012345678901234567890123456", "1234567890\xc3\xa41234567890123456789012345678901234567890123456"); }
test { try toUnicodePass("xn--12345678901234567890123456789012345678901234567890123456-fxe", "1234567890\xc3\xa41234567890123456789012345678901234567890123456"); }
test { try toUnicodePass("www.eXample.cOm", "www.example.com"); }
test { try toAsciiPass("www.eXample.cOm", "www.example.com", false); }
test { try toAsciiPass("www.eXample.cOm", "www.example.com", true); }
test { try toUnicodePass("B\xc3\xbccher.de", "b\xc3\xbccher.de"); }
test { try toAsciiPass("B\xc3\xbccher.de", "xn--bcher-kva.de", false); }
test { try toAsciiPass("B\xc3\xbccher.de", "xn--bcher-kva.de", true); }
test { try toUnicodePass("Bu\xcc\x88cher.de", "b\xc3\xbccher.de"); }
test { try toAsciiPass("Bu\xcc\x88cher.de", "xn--bcher-kva.de", false); }
test { try toAsciiPass("Bu\xcc\x88cher.de", "xn--bcher-kva.de", true); }
test { try toUnicodePass("bu\xcc\x88cher.de", "b\xc3\xbccher.de"); }
test { try toAsciiPass("bu\xcc\x88cher.de", "xn--bcher-kva.de", false); }
test { try toAsciiPass("bu\xcc\x88cher.de", "xn--bcher-kva.de", true); }
test { try toUnicodePass("b\xc3\xbccher.de", "b\xc3\xbccher.de"); }
test { try toAsciiPass("b\xc3\xbccher.de", "xn--bcher-kva.de", false); }
test { try toAsciiPass("b\xc3\xbccher.de", "xn--bcher-kva.de", true); }
test { try toUnicodePass("B\xc3\x9cCHER.DE", "b\xc3\xbccher.de"); }
test { try toAsciiPass("B\xc3\x9cCHER.DE", "xn--bcher-kva.de", false); }
test { try toAsciiPass("B\xc3\x9cCHER.DE", "xn--bcher-kva.de", true); }
test { try toUnicodePass("BU\xcc\x88CHER.DE", "b\xc3\xbccher.de"); }
test { try toAsciiPass("BU\xcc\x88CHER.DE", "xn--bcher-kva.de", false); }
test { try toAsciiPass("BU\xcc\x88CHER.DE", "xn--bcher-kva.de", true); }
test { try toUnicodePass("xn--bcher-kva.de", "b\xc3\xbccher.de"); }
test { try toAsciiPass("xn--bcher-kva.de", "xn--bcher-kva.de", false); }
test { try toAsciiPass("xn--bcher-kva.de", "xn--bcher-kva.de", true); }
test { try toUnicodePass("\xc3\x96BB", "\xc3\xb6bb"); }
test { try toAsciiPass("\xc3\x96BB", "xn--bb-eka", false); }
test { try toAsciiPass("\xc3\x96BB", "xn--bb-eka", true); }
test { try toUnicodePass("O\xcc\x88BB", "\xc3\xb6bb"); }
test { try toAsciiPass("O\xcc\x88BB", "xn--bb-eka", false); }
test { try toAsciiPass("O\xcc\x88BB", "xn--bb-eka", true); }
test { try toUnicodePass("o\xcc\x88bb", "\xc3\xb6bb"); }
test { try toAsciiPass("o\xcc\x88bb", "xn--bb-eka", false); }
test { try toAsciiPass("o\xcc\x88bb", "xn--bb-eka", true); }
test { try toUnicodePass("\xc3\xb6bb", "\xc3\xb6bb"); }
test { try toAsciiPass("\xc3\xb6bb", "xn--bb-eka", false); }
test { try toAsciiPass("\xc3\xb6bb", "xn--bb-eka", true); }
test { try toUnicodePass("\xc3\x96bb", "\xc3\xb6bb"); }
test { try toAsciiPass("\xc3\x96bb", "xn--bb-eka", false); }
test { try toAsciiPass("\xc3\x96bb", "xn--bb-eka", true); }
test { try toUnicodePass("O\xcc\x88bb", "\xc3\xb6bb"); }
test { try toAsciiPass("O\xcc\x88bb", "xn--bb-eka", false); }
test { try toAsciiPass("O\xcc\x88bb", "xn--bb-eka", true); }
test { try toUnicodePass("xn--bb-eka", "\xc3\xb6bb"); }
test { try toAsciiPass("xn--bb-eka", "xn--bb-eka", false); }
test { try toAsciiPass("xn--bb-eka", "xn--bb-eka", true); }
test { try toUnicodePass("FA\xe1\xba\x9e.de", "fa\xc3\x9f.de"); }
test { try toAsciiPass("FA\xe1\xba\x9e.de", "xn--fa-hia.de", false); }
test { try toAsciiPass("FA\xe1\xba\x9e.de", "fass.de", true); }
test { try toUnicodePass("FA\xe1\xba\x9e.DE", "fa\xc3\x9f.de"); }
test { try toAsciiPass("FA\xe1\xba\x9e.DE", "xn--fa-hia.de", false); }
test { try toAsciiPass("FA\xe1\xba\x9e.DE", "fass.de", true); }
test { try toUnicodePass("\xce\xb2\xcf\x8c\xce\xbb\xce\xbf\xcf\x82.com", "\xce\xb2\xcf\x8c\xce\xbb\xce\xbf\xcf\x82.com"); }
test { try toAsciiPass("\xce\xb2\xcf\x8c\xce\xbb\xce\xbf\xcf\x82.com", "xn--nxasmm1c.com", false); }
test { try toAsciiPass("\xce\xb2\xcf\x8c\xce\xbb\xce\xbf\xcf\x82.com", "xn--nxasmq6b.com", true); }
test { try toUnicodePass("\xce\xb2\xce\xbf\xcc\x81\xce\xbb\xce\xbf\xcf\x82.com", "\xce\xb2\xcf\x8c\xce\xbb\xce\xbf\xcf\x82.com"); }
test { try toAsciiPass("\xce\xb2\xce\xbf\xcc\x81\xce\xbb\xce\xbf\xcf\x82.com", "xn--nxasmm1c.com", false); }
test { try toAsciiPass("\xce\xb2\xce\xbf\xcc\x81\xce\xbb\xce\xbf\xcf\x82.com", "xn--nxasmq6b.com", true); }
test { try toUnicodePass("\xce\x92\xce\x9f\xcc\x81\xce\x9b\xce\x9f\xce\xa3.COM", "\xce\xb2\xcf\x8c\xce\xbb\xce\xbf\xcf\x83.com"); }
test { try toAsciiPass("\xce\x92\xce\x9f\xcc\x81\xce\x9b\xce\x9f\xce\xa3.COM", "xn--nxasmq6b.com", false); }
test { try toAsciiPass("\xce\x92\xce\x9f\xcc\x81\xce\x9b\xce\x9f\xce\xa3.COM", "xn--nxasmq6b.com", true); }
test { try toUnicodePass("\xce\x92\xce\x8c\xce\x9b\xce\x9f\xce\xa3.COM", "\xce\xb2\xcf\x8c\xce\xbb\xce\xbf\xcf\x83.com"); }
test { try toAsciiPass("\xce\x92\xce\x8c\xce\x9b\xce\x9f\xce\xa3.COM", "xn--nxasmq6b.com", false); }
test { try toAsciiPass("\xce\x92\xce\x8c\xce\x9b\xce\x9f\xce\xa3.COM", "xn--nxasmq6b.com", true); }
test { try toUnicodePass("\xce\xb2\xcf\x8c\xce\xbb\xce\xbf\xcf\x83.com", "\xce\xb2\xcf\x8c\xce\xbb\xce\xbf\xcf\x83.com"); }
test { try toAsciiPass("\xce\xb2\xcf\x8c\xce\xbb\xce\xbf\xcf\x83.com", "xn--nxasmq6b.com", false); }
test { try toAsciiPass("\xce\xb2\xcf\x8c\xce\xbb\xce\xbf\xcf\x83.com", "xn--nxasmq6b.com", true); }
test { try toUnicodePass("\xce\xb2\xce\xbf\xcc\x81\xce\xbb\xce\xbf\xcf\x83.com", "\xce\xb2\xcf\x8c\xce\xbb\xce\xbf\xcf\x83.com"); }
test { try toAsciiPass("\xce\xb2\xce\xbf\xcc\x81\xce\xbb\xce\xbf\xcf\x83.com", "xn--nxasmq6b.com", false); }
test { try toAsciiPass("\xce\xb2\xce\xbf\xcc\x81\xce\xbb\xce\xbf\xcf\x83.com", "xn--nxasmq6b.com", true); }
test { try toUnicodePass("\xce\x92\xce\xbf\xcc\x81\xce\xbb\xce\xbf\xcf\x83.com", "\xce\xb2\xcf\x8c\xce\xbb\xce\xbf\xcf\x83.com"); }
test { try toAsciiPass("\xce\x92\xce\xbf\xcc\x81\xce\xbb\xce\xbf\xcf\x83.com", "xn--nxasmq6b.com", false); }
test { try toAsciiPass("\xce\x92\xce\xbf\xcc\x81\xce\xbb\xce\xbf\xcf\x83.com", "xn--nxasmq6b.com", true); }
test { try toUnicodePass("\xce\x92\xcf\x8c\xce\xbb\xce\xbf\xcf\x83.com", "\xce\xb2\xcf\x8c\xce\xbb\xce\xbf\xcf\x83.com"); }
test { try toAsciiPass("\xce\x92\xcf\x8c\xce\xbb\xce\xbf\xcf\x83.com", "xn--nxasmq6b.com", false); }
test { try toAsciiPass("\xce\x92\xcf\x8c\xce\xbb\xce\xbf\xcf\x83.com", "xn--nxasmq6b.com", true); }
test { try toUnicodePass("xn--nxasmq6b.com", "\xce\xb2\xcf\x8c\xce\xbb\xce\xbf\xcf\x83.com"); }
test { try toAsciiPass("xn--nxasmq6b.com", "xn--nxasmq6b.com", false); }
test { try toAsciiPass("xn--nxasmq6b.com", "xn--nxasmq6b.com", true); }
test { try toUnicodePass("\xce\x92\xce\xbf\xcc\x81\xce\xbb\xce\xbf\xcf\x82.com", "\xce\xb2\xcf\x8c\xce\xbb\xce\xbf\xcf\x82.com"); }
test { try toAsciiPass("\xce\x92\xce\xbf\xcc\x81\xce\xbb\xce\xbf\xcf\x82.com", "xn--nxasmm1c.com", false); }
test { try toAsciiPass("\xce\x92\xce\xbf\xcc\x81\xce\xbb\xce\xbf\xcf\x82.com", "xn--nxasmq6b.com", true); }
test { try toUnicodePass("\xce\x92\xcf\x8c\xce\xbb\xce\xbf\xcf\x82.com", "\xce\xb2\xcf\x8c\xce\xbb\xce\xbf\xcf\x82.com"); }
test { try toAsciiPass("\xce\x92\xcf\x8c\xce\xbb\xce\xbf\xcf\x82.com", "xn--nxasmm1c.com", false); }
test { try toAsciiPass("\xce\x92\xcf\x8c\xce\xbb\xce\xbf\xcf\x82.com", "xn--nxasmq6b.com", true); }
test { try toUnicodePass("xn--nxasmm1c.com", "\xce\xb2\xcf\x8c\xce\xbb\xce\xbf\xcf\x82.com"); }
test { try toAsciiPass("xn--nxasmm1c.com", "xn--nxasmm1c.com", false); }
test { try toAsciiPass("xn--nxasmm1c.com", "xn--nxasmm1c.com", true); }
test { try toUnicodePass("xn--nxasmm1c", "\xce\xb2\xcf\x8c\xce\xbb\xce\xbf\xcf\x82"); }
test { try toAsciiPass("xn--nxasmm1c", "xn--nxasmm1c", false); }
test { try toAsciiPass("xn--nxasmm1c", "xn--nxasmm1c", true); }
test { try toUnicodePass("\xce\xb2\xcf\x8c\xce\xbb\xce\xbf\xcf\x82", "\xce\xb2\xcf\x8c\xce\xbb\xce\xbf\xcf\x82"); }
test { try toAsciiPass("\xce\xb2\xcf\x8c\xce\xbb\xce\xbf\xcf\x82", "xn--nxasmm1c", false); }
test { try toAsciiPass("\xce\xb2\xcf\x8c\xce\xbb\xce\xbf\xcf\x82", "xn--nxasmq6b", true); }
test { try toUnicodePass("\xce\xb2\xce\xbf\xcc\x81\xce\xbb\xce\xbf\xcf\x82", "\xce\xb2\xcf\x8c\xce\xbb\xce\xbf\xcf\x82"); }
test { try toAsciiPass("\xce\xb2\xce\xbf\xcc\x81\xce\xbb\xce\xbf\xcf\x82", "xn--nxasmm1c", false); }
test { try toAsciiPass("\xce\xb2\xce\xbf\xcc\x81\xce\xbb\xce\xbf\xcf\x82", "xn--nxasmq6b", true); }
test { try toUnicodePass("\xce\x92\xce\x9f\xcc\x81\xce\x9b\xce\x9f\xce\xa3", "\xce\xb2\xcf\x8c\xce\xbb\xce\xbf\xcf\x83"); }
test { try toAsciiPass("\xce\x92\xce\x9f\xcc\x81\xce\x9b\xce\x9f\xce\xa3", "xn--nxasmq6b", false); }
test { try toAsciiPass("\xce\x92\xce\x9f\xcc\x81\xce\x9b\xce\x9f\xce\xa3", "xn--nxasmq6b", true); }
test { try toUnicodePass("\xce\x92\xce\x8c\xce\x9b\xce\x9f\xce\xa3", "\xce\xb2\xcf\x8c\xce\xbb\xce\xbf\xcf\x83"); }
test { try toAsciiPass("\xce\x92\xce\x8c\xce\x9b\xce\x9f\xce\xa3", "xn--nxasmq6b", false); }
test { try toAsciiPass("\xce\x92\xce\x8c\xce\x9b\xce\x9f\xce\xa3", "xn--nxasmq6b", true); }
test { try toUnicodePass("\xce\xb2\xcf\x8c\xce\xbb\xce\xbf\xcf\x83", "\xce\xb2\xcf\x8c\xce\xbb\xce\xbf\xcf\x83"); }
test { try toAsciiPass("\xce\xb2\xcf\x8c\xce\xbb\xce\xbf\xcf\x83", "xn--nxasmq6b", false); }
test { try toAsciiPass("\xce\xb2\xcf\x8c\xce\xbb\xce\xbf\xcf\x83", "xn--nxasmq6b", true); }
test { try toUnicodePass("\xce\xb2\xce\xbf\xcc\x81\xce\xbb\xce\xbf\xcf\x83", "\xce\xb2\xcf\x8c\xce\xbb\xce\xbf\xcf\x83"); }
test { try toAsciiPass("\xce\xb2\xce\xbf\xcc\x81\xce\xbb\xce\xbf\xcf\x83", "xn--nxasmq6b", false); }
test { try toAsciiPass("\xce\xb2\xce\xbf\xcc\x81\xce\xbb\xce\xbf\xcf\x83", "xn--nxasmq6b", true); }
test { try toUnicodePass("\xce\x92\xce\xbf\xcc\x81\xce\xbb\xce\xbf\xcf\x83", "\xce\xb2\xcf\x8c\xce\xbb\xce\xbf\xcf\x83"); }
test { try toAsciiPass("\xce\x92\xce\xbf\xcc\x81\xce\xbb\xce\xbf\xcf\x83", "xn--nxasmq6b", false); }
test { try toAsciiPass("\xce\x92\xce\xbf\xcc\x81\xce\xbb\xce\xbf\xcf\x83", "xn--nxasmq6b", true); }
test { try toUnicodePass("\xce\x92\xcf\x8c\xce\xbb\xce\xbf\xcf\x83", "\xce\xb2\xcf\x8c\xce\xbb\xce\xbf\xcf\x83"); }
test { try toAsciiPass("\xce\x92\xcf\x8c\xce\xbb\xce\xbf\xcf\x83", "xn--nxasmq6b", false); }
test { try toAsciiPass("\xce\x92\xcf\x8c\xce\xbb\xce\xbf\xcf\x83", "xn--nxasmq6b", true); }
test { try toUnicodePass("xn--nxasmq6b", "\xce\xb2\xcf\x8c\xce\xbb\xce\xbf\xcf\x83"); }
test { try toAsciiPass("xn--nxasmq6b", "xn--nxasmq6b", false); }
test { try toAsciiPass("xn--nxasmq6b", "xn--nxasmq6b", true); }
test { try toUnicodePass("\xce\x92\xcf\x8c\xce\xbb\xce\xbf\xcf\x82", "\xce\xb2\xcf\x8c\xce\xbb\xce\xbf\xcf\x82"); }
test { try toAsciiPass("\xce\x92\xcf\x8c\xce\xbb\xce\xbf\xcf\x82", "xn--nxasmm1c", false); }
test { try toAsciiPass("\xce\x92\xcf\x8c\xce\xbb\xce\xbf\xcf\x82", "xn--nxasmq6b", true); }
test { try toUnicodePass("\xce\x92\xce\xbf\xcc\x81\xce\xbb\xce\xbf\xcf\x82", "\xce\xb2\xcf\x8c\xce\xbb\xce\xbf\xcf\x82"); }
test { try toAsciiPass("\xce\x92\xce\xbf\xcc\x81\xce\xbb\xce\xbf\xcf\x82", "xn--nxasmm1c", false); }
test { try toAsciiPass("\xce\x92\xce\xbf\xcc\x81\xce\xbb\xce\xbf\xcf\x82", "xn--nxasmq6b", true); }
test { try toUnicodePass("www.\xe0\xb7\x81\xe0\xb7\x8a\xe2\x80\x8d\xe0\xb6\xbb\xe0\xb7\x93.com", "www.\xe0\xb7\x81\xe0\xb7\x8a\xe2\x80\x8d\xe0\xb6\xbb\xe0\xb7\x93.com"); }
test { try toAsciiPass("www.\xe0\xb7\x81\xe0\xb7\x8a\xe2\x80\x8d\xe0\xb6\xbb\xe0\xb7\x93.com", "www.xn--10cl1a0b660p.com", false); }
test { try toAsciiPass("www.\xe0\xb7\x81\xe0\xb7\x8a\xe2\x80\x8d\xe0\xb6\xbb\xe0\xb7\x93.com", "www.xn--10cl1a0b.com", true); }
test { try toUnicodePass("WWW.\xe0\xb7\x81\xe0\xb7\x8a\xe2\x80\x8d\xe0\xb6\xbb\xe0\xb7\x93.COM", "www.\xe0\xb7\x81\xe0\xb7\x8a\xe2\x80\x8d\xe0\xb6\xbb\xe0\xb7\x93.com"); }
test { try toAsciiPass("WWW.\xe0\xb7\x81\xe0\xb7\x8a\xe2\x80\x8d\xe0\xb6\xbb\xe0\xb7\x93.COM", "www.xn--10cl1a0b660p.com", false); }
test { try toAsciiPass("WWW.\xe0\xb7\x81\xe0\xb7\x8a\xe2\x80\x8d\xe0\xb6\xbb\xe0\xb7\x93.COM", "www.xn--10cl1a0b.com", true); }
test { try toUnicodePass("Www.\xe0\xb7\x81\xe0\xb7\x8a\xe2\x80\x8d\xe0\xb6\xbb\xe0\xb7\x93.com", "www.\xe0\xb7\x81\xe0\xb7\x8a\xe2\x80\x8d\xe0\xb6\xbb\xe0\xb7\x93.com"); }
test { try toAsciiPass("Www.\xe0\xb7\x81\xe0\xb7\x8a\xe2\x80\x8d\xe0\xb6\xbb\xe0\xb7\x93.com", "www.xn--10cl1a0b660p.com", false); }
test { try toAsciiPass("Www.\xe0\xb7\x81\xe0\xb7\x8a\xe2\x80\x8d\xe0\xb6\xbb\xe0\xb7\x93.com", "www.xn--10cl1a0b.com", true); }
test { try toUnicodePass("www.xn--10cl1a0b.com", "www.\xe0\xb7\x81\xe0\xb7\x8a\xe0\xb6\xbb\xe0\xb7\x93.com"); }
test { try toAsciiPass("www.xn--10cl1a0b.com", "www.xn--10cl1a0b.com", false); }
test { try toAsciiPass("www.xn--10cl1a0b.com", "www.xn--10cl1a0b.com", true); }
test { try toUnicodePass("www.\xe0\xb7\x81\xe0\xb7\x8a\xe0\xb6\xbb\xe0\xb7\x93.com", "www.\xe0\xb7\x81\xe0\xb7\x8a\xe0\xb6\xbb\xe0\xb7\x93.com"); }
test { try toAsciiPass("www.\xe0\xb7\x81\xe0\xb7\x8a\xe0\xb6\xbb\xe0\xb7\x93.com", "www.xn--10cl1a0b.com", false); }
test { try toAsciiPass("www.\xe0\xb7\x81\xe0\xb7\x8a\xe0\xb6\xbb\xe0\xb7\x93.com", "www.xn--10cl1a0b.com", true); }
test { try toUnicodePass("WWW.\xe0\xb7\x81\xe0\xb7\x8a\xe0\xb6\xbb\xe0\xb7\x93.COM", "www.\xe0\xb7\x81\xe0\xb7\x8a\xe0\xb6\xbb\xe0\xb7\x93.com"); }
test { try toAsciiPass("WWW.\xe0\xb7\x81\xe0\xb7\x8a\xe0\xb6\xbb\xe0\xb7\x93.COM", "www.xn--10cl1a0b.com", false); }
test { try toAsciiPass("WWW.\xe0\xb7\x81\xe0\xb7\x8a\xe0\xb6\xbb\xe0\xb7\x93.COM", "www.xn--10cl1a0b.com", true); }
test { try toUnicodePass("Www.\xe0\xb7\x81\xe0\xb7\x8a\xe0\xb6\xbb\xe0\xb7\x93.com", "www.\xe0\xb7\x81\xe0\xb7\x8a\xe0\xb6\xbb\xe0\xb7\x93.com"); }
test { try toAsciiPass("Www.\xe0\xb7\x81\xe0\xb7\x8a\xe0\xb6\xbb\xe0\xb7\x93.com", "www.xn--10cl1a0b.com", false); }
test { try toAsciiPass("Www.\xe0\xb7\x81\xe0\xb7\x8a\xe0\xb6\xbb\xe0\xb7\x93.com", "www.xn--10cl1a0b.com", true); }
test { try toUnicodePass("www.xn--10cl1a0b660p.com", "www.\xe0\xb7\x81\xe0\xb7\x8a\xe2\x80\x8d\xe0\xb6\xbb\xe0\xb7\x93.com"); }
test { try toAsciiPass("www.xn--10cl1a0b660p.com", "www.xn--10cl1a0b660p.com", false); }
test { try toAsciiPass("www.xn--10cl1a0b660p.com", "www.xn--10cl1a0b660p.com", true); }
test { try toUnicodePass("\xd9\x86\xd8\xa7\xd9\x85\xd9\x87\xe2\x80\x8c\xd8\xa7\xdb\x8c", "\xd9\x86\xd8\xa7\xd9\x85\xd9\x87\xe2\x80\x8c\xd8\xa7\xdb\x8c"); }
test { try toAsciiPass("\xd9\x86\xd8\xa7\xd9\x85\xd9\x87\xe2\x80\x8c\xd8\xa7\xdb\x8c", "xn--mgba3gch31f060k", false); }
test { try toAsciiPass("\xd9\x86\xd8\xa7\xd9\x85\xd9\x87\xe2\x80\x8c\xd8\xa7\xdb\x8c", "xn--mgba3gch31f", true); }
test { try toUnicodePass("xn--mgba3gch31f", "\xd9\x86\xd8\xa7\xd9\x85\xd9\x87\xd8\xa7\xdb\x8c"); }
test { try toAsciiPass("xn--mgba3gch31f", "xn--mgba3gch31f", false); }
test { try toAsciiPass("xn--mgba3gch31f", "xn--mgba3gch31f", true); }
test { try toUnicodePass("\xd9\x86\xd8\xa7\xd9\x85\xd9\x87\xd8\xa7\xdb\x8c", "\xd9\x86\xd8\xa7\xd9\x85\xd9\x87\xd8\xa7\xdb\x8c"); }
test { try toAsciiPass("\xd9\x86\xd8\xa7\xd9\x85\xd9\x87\xd8\xa7\xdb\x8c", "xn--mgba3gch31f", false); }
test { try toAsciiPass("\xd9\x86\xd8\xa7\xd9\x85\xd9\x87\xd8\xa7\xdb\x8c", "xn--mgba3gch31f", true); }
test { try toUnicodePass("xn--mgba3gch31f060k", "\xd9\x86\xd8\xa7\xd9\x85\xd9\x87\xe2\x80\x8c\xd8\xa7\xdb\x8c"); }
test { try toAsciiPass("xn--mgba3gch31f060k", "xn--mgba3gch31f060k", false); }
test { try toAsciiPass("xn--mgba3gch31f060k", "xn--mgba3gch31f060k", true); }
test { try toUnicodePass("xn--mgba3gch31f060k.com", "\xd9\x86\xd8\xa7\xd9\x85\xd9\x87\xe2\x80\x8c\xd8\xa7\xdb\x8c.com"); }
test { try toAsciiPass("xn--mgba3gch31f060k.com", "xn--mgba3gch31f060k.com", false); }
test { try toAsciiPass("xn--mgba3gch31f060k.com", "xn--mgba3gch31f060k.com", true); }
test { try toUnicodePass("\xd9\x86\xd8\xa7\xd9\x85\xd9\x87\xe2\x80\x8c\xd8\xa7\xdb\x8c.com", "\xd9\x86\xd8\xa7\xd9\x85\xd9\x87\xe2\x80\x8c\xd8\xa7\xdb\x8c.com"); }
test { try toAsciiPass("\xd9\x86\xd8\xa7\xd9\x85\xd9\x87\xe2\x80\x8c\xd8\xa7\xdb\x8c.com", "xn--mgba3gch31f060k.com", false); }
test { try toAsciiPass("\xd9\x86\xd8\xa7\xd9\x85\xd9\x87\xe2\x80\x8c\xd8\xa7\xdb\x8c.com", "xn--mgba3gch31f.com", true); }
test { try toUnicodePass("\xd9\x86\xd8\xa7\xd9\x85\xd9\x87\xe2\x80\x8c\xd8\xa7\xdb\x8c.COM", "\xd9\x86\xd8\xa7\xd9\x85\xd9\x87\xe2\x80\x8c\xd8\xa7\xdb\x8c.com"); }
test { try toAsciiPass("\xd9\x86\xd8\xa7\xd9\x85\xd9\x87\xe2\x80\x8c\xd8\xa7\xdb\x8c.COM", "xn--mgba3gch31f060k.com", false); }
test { try toAsciiPass("\xd9\x86\xd8\xa7\xd9\x85\xd9\x87\xe2\x80\x8c\xd8\xa7\xdb\x8c.COM", "xn--mgba3gch31f.com", true); }
test { try toUnicodePass("xn--mgba3gch31f.com", "\xd9\x86\xd8\xa7\xd9\x85\xd9\x87\xd8\xa7\xdb\x8c.com"); }
test { try toAsciiPass("xn--mgba3gch31f.com", "xn--mgba3gch31f.com", false); }
test { try toAsciiPass("xn--mgba3gch31f.com", "xn--mgba3gch31f.com", true); }
test { try toUnicodePass("\xd9\x86\xd8\xa7\xd9\x85\xd9\x87\xd8\xa7\xdb\x8c.com", "\xd9\x86\xd8\xa7\xd9\x85\xd9\x87\xd8\xa7\xdb\x8c.com"); }
test { try toAsciiPass("\xd9\x86\xd8\xa7\xd9\x85\xd9\x87\xd8\xa7\xdb\x8c.com", "xn--mgba3gch31f.com", false); }
test { try toAsciiPass("\xd9\x86\xd8\xa7\xd9\x85\xd9\x87\xd8\xa7\xdb\x8c.com", "xn--mgba3gch31f.com", true); }
test { try toUnicodePass("\xd9\x86\xd8\xa7\xd9\x85\xd9\x87\xd8\xa7\xdb\x8c.COM", "\xd9\x86\xd8\xa7\xd9\x85\xd9\x87\xd8\xa7\xdb\x8c.com"); }
test { try toAsciiPass("\xd9\x86\xd8\xa7\xd9\x85\xd9\x87\xd8\xa7\xdb\x8c.COM", "xn--mgba3gch31f.com", false); }
test { try toAsciiPass("\xd9\x86\xd8\xa7\xd9\x85\xd9\x87\xd8\xa7\xdb\x8c.COM", "xn--mgba3gch31f.com", true); }
test { try toUnicodePass("a.b\xef\xbc\x8ec\xe3\x80\x82d\xef\xbd\xa1", "a.b.c.d."); }
test { try toUnicodePass("a.b.c\xe3\x80\x82d\xe3\x80\x82", "a.b.c.d."); }
test { try toUnicodePass("A.B.C\xe3\x80\x82D\xe3\x80\x82", "a.b.c.d."); }
test { try toUnicodePass("A.b.c\xe3\x80\x82D\xe3\x80\x82", "a.b.c.d."); }
test { try toUnicodePass("a.b.c.d.", "a.b.c.d."); }
test { try toUnicodePass("A.B\xef\xbc\x8eC\xe3\x80\x82D\xef\xbd\xa1", "a.b.c.d."); }
test { try toUnicodePass("A.b\xef\xbc\x8ec\xe3\x80\x82D\xef\xbd\xa1", "a.b.c.d."); }
test { try toUnicodePass("U\xcc\x88.xn--tda", "\xc3\xbc.\xc3\xbc"); }
test { try toAsciiPass("U\xcc\x88.xn--tda", "xn--tda.xn--tda", false); }
test { try toAsciiPass("U\xcc\x88.xn--tda", "xn--tda.xn--tda", true); }
test { try toUnicodePass("\xc3\x9c.xn--tda", "\xc3\xbc.\xc3\xbc"); }
test { try toAsciiPass("\xc3\x9c.xn--tda", "xn--tda.xn--tda", false); }
test { try toAsciiPass("\xc3\x9c.xn--tda", "xn--tda.xn--tda", true); }
test { try toUnicodePass("\xc3\xbc.xn--tda", "\xc3\xbc.\xc3\xbc"); }
test { try toAsciiPass("\xc3\xbc.xn--tda", "xn--tda.xn--tda", false); }
test { try toAsciiPass("\xc3\xbc.xn--tda", "xn--tda.xn--tda", true); }
test { try toUnicodePass("u\xcc\x88.xn--tda", "\xc3\xbc.\xc3\xbc"); }
test { try toAsciiPass("u\xcc\x88.xn--tda", "xn--tda.xn--tda", false); }
test { try toAsciiPass("u\xcc\x88.xn--tda", "xn--tda.xn--tda", true); }
test { try toUnicodePass("U\xcc\x88.XN--TDA", "\xc3\xbc.\xc3\xbc"); }
test { try toAsciiPass("U\xcc\x88.XN--TDA", "xn--tda.xn--tda", false); }
test { try toAsciiPass("U\xcc\x88.XN--TDA", "xn--tda.xn--tda", true); }
test { try toUnicodePass("\xc3\x9c.XN--TDA", "\xc3\xbc.\xc3\xbc"); }
test { try toAsciiPass("\xc3\x9c.XN--TDA", "xn--tda.xn--tda", false); }
test { try toAsciiPass("\xc3\x9c.XN--TDA", "xn--tda.xn--tda", true); }
test { try toUnicodePass("\xc3\x9c.xn--Tda", "\xc3\xbc.\xc3\xbc"); }
test { try toAsciiPass("\xc3\x9c.xn--Tda", "xn--tda.xn--tda", false); }
test { try toAsciiPass("\xc3\x9c.xn--Tda", "xn--tda.xn--tda", true); }
test { try toUnicodePass("U\xcc\x88.xn--Tda", "\xc3\xbc.\xc3\xbc"); }
test { try toAsciiPass("U\xcc\x88.xn--Tda", "xn--tda.xn--tda", false); }
test { try toAsciiPass("U\xcc\x88.xn--Tda", "xn--tda.xn--tda", true); }
test { try toUnicodePass("xn--tda.xn--tda", "\xc3\xbc.\xc3\xbc"); }
test { try toAsciiPass("xn--tda.xn--tda", "xn--tda.xn--tda", false); }
test { try toAsciiPass("xn--tda.xn--tda", "xn--tda.xn--tda", true); }
test { try toUnicodePass("\xc3\xbc.\xc3\xbc", "\xc3\xbc.\xc3\xbc"); }
test { try toAsciiPass("\xc3\xbc.\xc3\xbc", "xn--tda.xn--tda", false); }
test { try toAsciiPass("\xc3\xbc.\xc3\xbc", "xn--tda.xn--tda", true); }
test { try toUnicodePass("u\xcc\x88.u\xcc\x88", "\xc3\xbc.\xc3\xbc"); }
test { try toAsciiPass("u\xcc\x88.u\xcc\x88", "xn--tda.xn--tda", false); }
test { try toAsciiPass("u\xcc\x88.u\xcc\x88", "xn--tda.xn--tda", true); }
test { try toUnicodePass("U\xcc\x88.U\xcc\x88", "\xc3\xbc.\xc3\xbc"); }
test { try toAsciiPass("U\xcc\x88.U\xcc\x88", "xn--tda.xn--tda", false); }
test { try toAsciiPass("U\xcc\x88.U\xcc\x88", "xn--tda.xn--tda", true); }
test { try toUnicodePass("\xc3\x9c.\xc3\x9c", "\xc3\xbc.\xc3\xbc"); }
test { try toAsciiPass("\xc3\x9c.\xc3\x9c", "xn--tda.xn--tda", false); }
test { try toAsciiPass("\xc3\x9c.\xc3\x9c", "xn--tda.xn--tda", true); }
test { try toUnicodePass("\xc3\x9c.\xc3\xbc", "\xc3\xbc.\xc3\xbc"); }
test { try toAsciiPass("\xc3\x9c.\xc3\xbc", "xn--tda.xn--tda", false); }
test { try toAsciiPass("\xc3\x9c.\xc3\xbc", "xn--tda.xn--tda", true); }
test { try toUnicodePass("U\xcc\x88.u\xcc\x88", "\xc3\xbc.\xc3\xbc"); }
test { try toAsciiPass("U\xcc\x88.u\xcc\x88", "xn--tda.xn--tda", false); }
test { try toAsciiPass("U\xcc\x88.u\xcc\x88", "xn--tda.xn--tda", true); }
test { try toUnicodePass("a1.com", "a1.com"); }
test { try toAsciiPass("a1.com", "a1.com", false); }
test { try toAsciiPass("a1.com", "a1.com", true); }
test { try toUnicodePass("\xe6\x97\xa5\xe6\x9c\xac\xe8\xaa\x9e\xe3\x80\x82\xef\xbc\xaa\xef\xbc\xb0", "\xe6\x97\xa5\xe6\x9c\xac\xe8\xaa\x9e.jp"); }
test { try toAsciiPass("\xe6\x97\xa5\xe6\x9c\xac\xe8\xaa\x9e\xe3\x80\x82\xef\xbc\xaa\xef\xbc\xb0", "xn--wgv71a119e.jp", false); }
test { try toAsciiPass("\xe6\x97\xa5\xe6\x9c\xac\xe8\xaa\x9e\xe3\x80\x82\xef\xbc\xaa\xef\xbc\xb0", "xn--wgv71a119e.jp", true); }
test { try toUnicodePass("\xe6\x97\xa5\xe6\x9c\xac\xe8\xaa\x9e\xe3\x80\x82JP", "\xe6\x97\xa5\xe6\x9c\xac\xe8\xaa\x9e.jp"); }
test { try toAsciiPass("\xe6\x97\xa5\xe6\x9c\xac\xe8\xaa\x9e\xe3\x80\x82JP", "xn--wgv71a119e.jp", false); }
test { try toAsciiPass("\xe6\x97\xa5\xe6\x9c\xac\xe8\xaa\x9e\xe3\x80\x82JP", "xn--wgv71a119e.jp", true); }
test { try toUnicodePass("\xe6\x97\xa5\xe6\x9c\xac\xe8\xaa\x9e\xe3\x80\x82jp", "\xe6\x97\xa5\xe6\x9c\xac\xe8\xaa\x9e.jp"); }
test { try toAsciiPass("\xe6\x97\xa5\xe6\x9c\xac\xe8\xaa\x9e\xe3\x80\x82jp", "xn--wgv71a119e.jp", false); }
test { try toAsciiPass("\xe6\x97\xa5\xe6\x9c\xac\xe8\xaa\x9e\xe3\x80\x82jp", "xn--wgv71a119e.jp", true); }
test { try toUnicodePass("\xe6\x97\xa5\xe6\x9c\xac\xe8\xaa\x9e\xe3\x80\x82Jp", "\xe6\x97\xa5\xe6\x9c\xac\xe8\xaa\x9e.jp"); }
test { try toAsciiPass("\xe6\x97\xa5\xe6\x9c\xac\xe8\xaa\x9e\xe3\x80\x82Jp", "xn--wgv71a119e.jp", false); }
test { try toAsciiPass("\xe6\x97\xa5\xe6\x9c\xac\xe8\xaa\x9e\xe3\x80\x82Jp", "xn--wgv71a119e.jp", true); }
test { try toUnicodePass("xn--wgv71a119e.jp", "\xe6\x97\xa5\xe6\x9c\xac\xe8\xaa\x9e.jp"); }
test { try toAsciiPass("xn--wgv71a119e.jp", "xn--wgv71a119e.jp", false); }
test { try toAsciiPass("xn--wgv71a119e.jp", "xn--wgv71a119e.jp", true); }
test { try toUnicodePass("\xe6\x97\xa5\xe6\x9c\xac\xe8\xaa\x9e.jp", "\xe6\x97\xa5\xe6\x9c\xac\xe8\xaa\x9e.jp"); }
test { try toAsciiPass("\xe6\x97\xa5\xe6\x9c\xac\xe8\xaa\x9e.jp", "xn--wgv71a119e.jp", false); }
test { try toAsciiPass("\xe6\x97\xa5\xe6\x9c\xac\xe8\xaa\x9e.jp", "xn--wgv71a119e.jp", true); }
test { try toUnicodePass("\xe6\x97\xa5\xe6\x9c\xac\xe8\xaa\x9e.JP", "\xe6\x97\xa5\xe6\x9c\xac\xe8\xaa\x9e.jp"); }
test { try toAsciiPass("\xe6\x97\xa5\xe6\x9c\xac\xe8\xaa\x9e.JP", "xn--wgv71a119e.jp", false); }
test { try toAsciiPass("\xe6\x97\xa5\xe6\x9c\xac\xe8\xaa\x9e.JP", "xn--wgv71a119e.jp", true); }
test { try toUnicodePass("\xe6\x97\xa5\xe6\x9c\xac\xe8\xaa\x9e.Jp", "\xe6\x97\xa5\xe6\x9c\xac\xe8\xaa\x9e.jp"); }
test { try toAsciiPass("\xe6\x97\xa5\xe6\x9c\xac\xe8\xaa\x9e.Jp", "xn--wgv71a119e.jp", false); }
test { try toAsciiPass("\xe6\x97\xa5\xe6\x9c\xac\xe8\xaa\x9e.Jp", "xn--wgv71a119e.jp", true); }
test { try toUnicodePass("\xe6\x97\xa5\xe6\x9c\xac\xe8\xaa\x9e\xe3\x80\x82\xef\xbd\x8a\xef\xbd\x90", "\xe6\x97\xa5\xe6\x9c\xac\xe8\xaa\x9e.jp"); }
test { try toAsciiPass("\xe6\x97\xa5\xe6\x9c\xac\xe8\xaa\x9e\xe3\x80\x82\xef\xbd\x8a\xef\xbd\x90", "xn--wgv71a119e.jp", false); }
test { try toAsciiPass("\xe6\x97\xa5\xe6\x9c\xac\xe8\xaa\x9e\xe3\x80\x82\xef\xbd\x8a\xef\xbd\x90", "xn--wgv71a119e.jp", true); }
test { try toUnicodePass("\xe6\x97\xa5\xe6\x9c\xac\xe8\xaa\x9e\xe3\x80\x82\xef\xbc\xaa\xef\xbd\x90", "\xe6\x97\xa5\xe6\x9c\xac\xe8\xaa\x9e.jp"); }
test { try toAsciiPass("\xe6\x97\xa5\xe6\x9c\xac\xe8\xaa\x9e\xe3\x80\x82\xef\xbc\xaa\xef\xbd\x90", "xn--wgv71a119e.jp", false); }
test { try toAsciiPass("\xe6\x97\xa5\xe6\x9c\xac\xe8\xaa\x9e\xe3\x80\x82\xef\xbc\xaa\xef\xbd\x90", "xn--wgv71a119e.jp", true); }
test { try toUnicodePass("\xe2\x98\x95", "\xe2\x98\x95"); }
test { try toAsciiPass("\xe2\x98\x95", "xn--53h", false); }
test { try toAsciiPass("\xe2\x98\x95", "xn--53h", true); }
test { try toUnicodePass("xn--53h", "\xe2\x98\x95"); }
test { try toAsciiPass("xn--53h", "xn--53h", false); }
test { try toAsciiPass("xn--53h", "xn--53h", true); }
test { try toUnicodePass("1.xn--assbcssssssssdssssssssssssssssessssssssssssssssssssxssssssssssssssssssssysssssssssssssssssz-pxq1419aa", "1.assbcssssssssd\xcf\x83\xcf\x83ssssssssssssssssessssssssssssssssssssxssssssssssssssssssssysssssssssssssss\xc5\x9dssz"); }
test { try toUnicodePass("1.assbcssssssssd\xcf\x83\xcf\x83ssssssssssssssssessssssssssssssssssssxssssssssssssssssssssysssssssssssssss\xc5\x9dssz", "1.assbcssssssssd\xcf\x83\xcf\x83ssssssssssssssssessssssssssssssssssssxssssssssssssssssssssysssssssssssssss\xc5\x9dssz"); }
test { try toUnicodePass("1.assbcssssssssd\xcf\x83\xcf\x83ssssssssssssssssessssssssssssssssssssxssssssssssssssssssssyssssssssssssssss\xcc\x82ssz", "1.assbcssssssssd\xcf\x83\xcf\x83ssssssssssssssssessssssssssssssssssssxssssssssssssssssssssysssssssssssssss\xc5\x9dssz"); }
test { try toUnicodePass("1.ASSBCSSSSSSSSD\xce\xa3\xce\xa3SSSSSSSSSSSSSSSSESSSSSSSSSSSSSSSSSSSSXSSSSSSSSSSSSSSSSSSSSYSSSSSSSSSSSSSSSS\xcc\x82SSZ", "1.assbcssssssssd\xcf\x83\xcf\x83ssssssssssssssssessssssssssssssssssssxssssssssssssssssssssysssssssssssssss\xc5\x9dssz"); }
test { try toUnicodePass("1.ASSBCSSSSSSSSD\xce\xa3\xce\xa3SSSSSSSSSSSSSSSSESSSSSSSSSSSSSSSSSSSSXSSSSSSSSSSSSSSSSSSSSYSSSSSSSSSSSSSSS\xc5\x9cSSZ", "1.assbcssssssssd\xcf\x83\xcf\x83ssssssssssssssssessssssssssssssssssssxssssssssssssssssssssysssssssssssssss\xc5\x9dssz"); }
test { try toUnicodePass("1.Assbcssssssssd\xcf\x83\xcf\x83ssssssssssssssssessssssssssssssssssssxssssssssssssssssssssysssssssssssssss\xc5\x9dssz", "1.assbcssssssssd\xcf\x83\xcf\x83ssssssssssssssssessssssssssssssssssssxssssssssssssssssssssysssssssssssssss\xc5\x9dssz"); }
test { try toUnicodePass("1.Assbcssssssssd\xcf\x83\xcf\x83ssssssssssssssssessssssssssssssssssssxssssssssssssssssssssyssssssssssssssss\xcc\x82ssz", "1.assbcssssssssd\xcf\x83\xcf\x83ssssssssssssssssessssssssssssssssssssxssssssssssssssssssssysssssssssssssss\xc5\x9dssz"); }
test { try toAsciiPass("\xe2\x80\x8cx\xe2\x80\x8dn\xe2\x80\x8c-\xe2\x80\x8d-b\xc3\x9f", "xn--bss", true); }
test { try toAsciiPass("\xe2\x80\x8cX\xe2\x80\x8dN\xe2\x80\x8c-\xe2\x80\x8d-BSS", "xn--bss", true); }
test { try toAsciiPass("\xe2\x80\x8cx\xe2\x80\x8dn\xe2\x80\x8c-\xe2\x80\x8d-bss", "xn--bss", true); }
test { try toAsciiPass("\xe2\x80\x8cX\xe2\x80\x8dn\xe2\x80\x8c-\xe2\x80\x8d-Bss", "xn--bss", true); }
test { try toUnicodePass("xn--bss", "\xe5\xa4\x99"); }
test { try toAsciiPass("xn--bss", "xn--bss", false); }
test { try toAsciiPass("xn--bss", "xn--bss", true); }
test { try toUnicodePass("\xe5\xa4\x99", "\xe5\xa4\x99"); }
test { try toAsciiPass("\xe5\xa4\x99", "xn--bss", false); }
test { try toAsciiPass("\xe5\xa4\x99", "xn--bss", true); }
test { try toAsciiPass("\xe2\x80\x8cX\xe2\x80\x8dn\xe2\x80\x8c-\xe2\x80\x8d-B\xc3\x9f", "xn--bss", true); }
test { try toUnicodePass("\xcb\xa3\xcd\x8f\xe2\x84\x95\xe2\x80\x8b\xef\xb9\xa3\xc2\xad\xef\xbc\x8d\xe1\xa0\x8c\xe2\x84\xac\xef\xb8\x80\xc5\xbf\xe2\x81\xa4\xf0\x9d\x94\xb0\xf3\xa0\x87\xaf\xef\xac\x84", "\xe5\xa4\xa1\xe5\xa4\x9e\xe5\xa4\x9c\xe5\xa4\x99"); }
test { try toAsciiPass("\xcb\xa3\xcd\x8f\xe2\x84\x95\xe2\x80\x8b\xef\xb9\xa3\xc2\xad\xef\xbc\x8d\xe1\xa0\x8c\xe2\x84\xac\xef\xb8\x80\xc5\xbf\xe2\x81\xa4\xf0\x9d\x94\xb0\xf3\xa0\x87\xaf\xef\xac\x84", "xn--bssffl", false); }
test { try toAsciiPass("\xcb\xa3\xcd\x8f\xe2\x84\x95\xe2\x80\x8b\xef\xb9\xa3\xc2\xad\xef\xbc\x8d\xe1\xa0\x8c\xe2\x84\xac\xef\xb8\x80\xc5\xbf\xe2\x81\xa4\xf0\x9d\x94\xb0\xf3\xa0\x87\xaf\xef\xac\x84", "xn--bssffl", true); }
test { try toUnicodePass("x\xcd\x8fN\xe2\x80\x8b-\xc2\xad-\xe1\xa0\x8cB\xef\xb8\x80s\xe2\x81\xa4s\xf3\xa0\x87\xafffl", "\xe5\xa4\xa1\xe5\xa4\x9e\xe5\xa4\x9c\xe5\xa4\x99"); }
test { try toAsciiPass("x\xcd\x8fN\xe2\x80\x8b-\xc2\xad-\xe1\xa0\x8cB\xef\xb8\x80s\xe2\x81\xa4s\xf3\xa0\x87\xafffl", "xn--bssffl", false); }
test { try toAsciiPass("x\xcd\x8fN\xe2\x80\x8b-\xc2\xad-\xe1\xa0\x8cB\xef\xb8\x80s\xe2\x81\xa4s\xf3\xa0\x87\xafffl", "xn--bssffl", true); }
test { try toUnicodePass("x\xcd\x8fn\xe2\x80\x8b-\xc2\xad-\xe1\xa0\x8cb\xef\xb8\x80s\xe2\x81\xa4s\xf3\xa0\x87\xafffl", "\xe5\xa4\xa1\xe5\xa4\x9e\xe5\xa4\x9c\xe5\xa4\x99"); }
test { try toAsciiPass("x\xcd\x8fn\xe2\x80\x8b-\xc2\xad-\xe1\xa0\x8cb\xef\xb8\x80s\xe2\x81\xa4s\xf3\xa0\x87\xafffl", "xn--bssffl", false); }
test { try toAsciiPass("x\xcd\x8fn\xe2\x80\x8b-\xc2\xad-\xe1\xa0\x8cb\xef\xb8\x80s\xe2\x81\xa4s\xf3\xa0\x87\xafffl", "xn--bssffl", true); }
test { try toUnicodePass("X\xcd\x8fN\xe2\x80\x8b-\xc2\xad-\xe1\xa0\x8cB\xef\xb8\x80S\xe2\x81\xa4S\xf3\xa0\x87\xafFFL", "\xe5\xa4\xa1\xe5\xa4\x9e\xe5\xa4\x9c\xe5\xa4\x99"); }
test { try toAsciiPass("X\xcd\x8fN\xe2\x80\x8b-\xc2\xad-\xe1\xa0\x8cB\xef\xb8\x80S\xe2\x81\xa4S\xf3\xa0\x87\xafFFL", "xn--bssffl", false); }
test { try toAsciiPass("X\xcd\x8fN\xe2\x80\x8b-\xc2\xad-\xe1\xa0\x8cB\xef\xb8\x80S\xe2\x81\xa4S\xf3\xa0\x87\xafFFL", "xn--bssffl", true); }
test { try toUnicodePass("X\xcd\x8fn\xe2\x80\x8b-\xc2\xad-\xe1\xa0\x8cB\xef\xb8\x80s\xe2\x81\xa4s\xf3\xa0\x87\xafffl", "\xe5\xa4\xa1\xe5\xa4\x9e\xe5\xa4\x9c\xe5\xa4\x99"); }
test { try toAsciiPass("X\xcd\x8fn\xe2\x80\x8b-\xc2\xad-\xe1\xa0\x8cB\xef\xb8\x80s\xe2\x81\xa4s\xf3\xa0\x87\xafffl", "xn--bssffl", false); }
test { try toAsciiPass("X\xcd\x8fn\xe2\x80\x8b-\xc2\xad-\xe1\xa0\x8cB\xef\xb8\x80s\xe2\x81\xa4s\xf3\xa0\x87\xafffl", "xn--bssffl", true); }
test { try toUnicodePass("xn--bssffl", "\xe5\xa4\xa1\xe5\xa4\x9e\xe5\xa4\x9c\xe5\xa4\x99"); }
test { try toAsciiPass("xn--bssffl", "xn--bssffl", false); }
test { try toAsciiPass("xn--bssffl", "xn--bssffl", true); }
test { try toUnicodePass("\xe5\xa4\xa1\xe5\xa4\x9e\xe5\xa4\x9c\xe5\xa4\x99", "\xe5\xa4\xa1\xe5\xa4\x9e\xe5\xa4\x9c\xe5\xa4\x99"); }
test { try toAsciiPass("\xe5\xa4\xa1\xe5\xa4\x9e\xe5\xa4\x9c\xe5\xa4\x99", "xn--bssffl", false); }
test { try toAsciiPass("\xe5\xa4\xa1\xe5\xa4\x9e\xe5\xa4\x9c\xe5\xa4\x99", "xn--bssffl", true); }
test { try toUnicodePass("\xcb\xa3\xcd\x8f\xe2\x84\x95\xe2\x80\x8b\xef\xb9\xa3\xc2\xad\xef\xbc\x8d\xe1\xa0\x8c\xe2\x84\xac\xef\xb8\x80S\xe2\x81\xa4\xf0\x9d\x94\xb0\xf3\xa0\x87\xafFFL", "\xe5\xa4\xa1\xe5\xa4\x9e\xe5\xa4\x9c\xe5\xa4\x99"); }
test { try toAsciiPass("\xcb\xa3\xcd\x8f\xe2\x84\x95\xe2\x80\x8b\xef\xb9\xa3\xc2\xad\xef\xbc\x8d\xe1\xa0\x8c\xe2\x84\xac\xef\xb8\x80S\xe2\x81\xa4\xf0\x9d\x94\xb0\xf3\xa0\x87\xafFFL", "xn--bssffl", false); }
test { try toAsciiPass("\xcb\xa3\xcd\x8f\xe2\x84\x95\xe2\x80\x8b\xef\xb9\xa3\xc2\xad\xef\xbc\x8d\xe1\xa0\x8c\xe2\x84\xac\xef\xb8\x80S\xe2\x81\xa4\xf0\x9d\x94\xb0\xf3\xa0\x87\xafFFL", "xn--bssffl", true); }
test { try toUnicodePass("x\xcd\x8fN\xe2\x80\x8b-\xc2\xad-\xe1\xa0\x8cB\xef\xb8\x80S\xe2\x81\xa4s\xf3\xa0\x87\xafFFL", "\xe5\xa4\xa1\xe5\xa4\x9e\xe5\xa4\x9c\xe5\xa4\x99"); }
test { try toAsciiPass("x\xcd\x8fN\xe2\x80\x8b-\xc2\xad-\xe1\xa0\x8cB\xef\xb8\x80S\xe2\x81\xa4s\xf3\xa0\x87\xafFFL", "xn--bssffl", false); }
test { try toAsciiPass("x\xcd\x8fN\xe2\x80\x8b-\xc2\xad-\xe1\xa0\x8cB\xef\xb8\x80S\xe2\x81\xa4s\xf3\xa0\x87\xafFFL", "xn--bssffl", true); }
test { try toUnicodePass("\xcb\xa3\xcd\x8f\xe2\x84\x95\xe2\x80\x8b\xef\xb9\xa3\xc2\xad\xef\xbc\x8d\xe1\xa0\x8c\xe2\x84\xac\xef\xb8\x80s\xe2\x81\xa4\xf0\x9d\x94\xb0\xf3\xa0\x87\xafffl", "\xe5\xa4\xa1\xe5\xa4\x9e\xe5\xa4\x9c\xe5\xa4\x99"); }
test { try toAsciiPass("\xcb\xa3\xcd\x8f\xe2\x84\x95\xe2\x80\x8b\xef\xb9\xa3\xc2\xad\xef\xbc\x8d\xe1\xa0\x8c\xe2\x84\xac\xef\xb8\x80s\xe2\x81\xa4\xf0\x9d\x94\xb0\xf3\xa0\x87\xafffl", "xn--bssffl", false); }
test { try toAsciiPass("\xcb\xa3\xcd\x8f\xe2\x84\x95\xe2\x80\x8b\xef\xb9\xa3\xc2\xad\xef\xbc\x8d\xe1\xa0\x8c\xe2\x84\xac\xef\xb8\x80s\xe2\x81\xa4\xf0\x9d\x94\xb0\xf3\xa0\x87\xafffl", "xn--bssffl", true); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b", "123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b"); }
test { try toAsciiPass("123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b", "123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b", false); }
test { try toAsciiPass("123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b", "123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b", true); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b.", "123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b."); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890123.1234567890123456789012345678901234567890123456789012345678901c", "123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890123.1234567890123456789012345678901234567890123456789012345678901c"); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.1234567890123456789012345678901234567890123456789012345678901234.123456789012345678901234567890123456789012345678901234567890123.12345678901234567890123456789012345678901234567890123456789a", "123456789012345678901234567890123456789012345678901234567890123.1234567890123456789012345678901234567890123456789012345678901234.123456789012345678901234567890123456789012345678901234567890123.12345678901234567890123456789012345678901234567890123456789a"); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.1234567890123456789012345678901234567890123456789012345678901234.123456789012345678901234567890123456789012345678901234567890123.12345678901234567890123456789012345678901234567890123456789a.", "123456789012345678901234567890123456789012345678901234567890123.1234567890123456789012345678901234567890123456789012345678901234.123456789012345678901234567890123456789012345678901234567890123.12345678901234567890123456789012345678901234567890123456789a."); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.1234567890123456789012345678901234567890123456789012345678901234.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b", "123456789012345678901234567890123456789012345678901234567890123.1234567890123456789012345678901234567890123456789012345678901234.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b"); }
test { try toUnicodePass("\xc3\xa41234567890123456789012345678901234567890123456789012345", "\xc3\xa41234567890123456789012345678901234567890123456789012345"); }
test { try toAsciiPass("\xc3\xa41234567890123456789012345678901234567890123456789012345", "xn--1234567890123456789012345678901234567890123456789012345-9te", false); }
test { try toAsciiPass("\xc3\xa41234567890123456789012345678901234567890123456789012345", "xn--1234567890123456789012345678901234567890123456789012345-9te", true); }
test { try toUnicodePass("a\xcc\x881234567890123456789012345678901234567890123456789012345", "\xc3\xa41234567890123456789012345678901234567890123456789012345"); }
test { try toAsciiPass("a\xcc\x881234567890123456789012345678901234567890123456789012345", "xn--1234567890123456789012345678901234567890123456789012345-9te", false); }
test { try toAsciiPass("a\xcc\x881234567890123456789012345678901234567890123456789012345", "xn--1234567890123456789012345678901234567890123456789012345-9te", true); }
test { try toUnicodePass("A\xcc\x881234567890123456789012345678901234567890123456789012345", "\xc3\xa41234567890123456789012345678901234567890123456789012345"); }
test { try toAsciiPass("A\xcc\x881234567890123456789012345678901234567890123456789012345", "xn--1234567890123456789012345678901234567890123456789012345-9te", false); }
test { try toAsciiPass("A\xcc\x881234567890123456789012345678901234567890123456789012345", "xn--1234567890123456789012345678901234567890123456789012345-9te", true); }
test { try toUnicodePass("\xc3\x841234567890123456789012345678901234567890123456789012345", "\xc3\xa41234567890123456789012345678901234567890123456789012345"); }
test { try toAsciiPass("\xc3\x841234567890123456789012345678901234567890123456789012345", "xn--1234567890123456789012345678901234567890123456789012345-9te", false); }
test { try toAsciiPass("\xc3\x841234567890123456789012345678901234567890123456789012345", "xn--1234567890123456789012345678901234567890123456789012345-9te", true); }
test { try toUnicodePass("xn--1234567890123456789012345678901234567890123456789012345-9te", "\xc3\xa41234567890123456789012345678901234567890123456789012345"); }
test { try toAsciiPass("xn--1234567890123456789012345678901234567890123456789012345-9te", "xn--1234567890123456789012345678901234567890123456789012345-9te", false); }
test { try toAsciiPass("xn--1234567890123456789012345678901234567890123456789012345-9te", "xn--1234567890123456789012345678901234567890123456789012345-9te", true); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa4123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b", "123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa4123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b"); }
test { try toAsciiPass("123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa4123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b", "123456789012345678901234567890123456789012345678901234567890123.xn--1234567890123456789012345678901234567890123456789012345-kue.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b", false); }
test { try toAsciiPass("123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa4123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b", "123456789012345678901234567890123456789012345678901234567890123.xn--1234567890123456789012345678901234567890123456789012345-kue.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b", true); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.1234567890a\xcc\x88123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b", "123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa4123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b"); }
test { try toAsciiPass("123456789012345678901234567890123456789012345678901234567890123.1234567890a\xcc\x88123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b", "123456789012345678901234567890123456789012345678901234567890123.xn--1234567890123456789012345678901234567890123456789012345-kue.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b", false); }
test { try toAsciiPass("123456789012345678901234567890123456789012345678901234567890123.1234567890a\xcc\x88123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b", "123456789012345678901234567890123456789012345678901234567890123.xn--1234567890123456789012345678901234567890123456789012345-kue.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b", true); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.1234567890A\xcc\x88123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890B", "123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa4123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b"); }
test { try toAsciiPass("123456789012345678901234567890123456789012345678901234567890123.1234567890A\xcc\x88123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890B", "123456789012345678901234567890123456789012345678901234567890123.xn--1234567890123456789012345678901234567890123456789012345-kue.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b", false); }
test { try toAsciiPass("123456789012345678901234567890123456789012345678901234567890123.1234567890A\xcc\x88123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890B", "123456789012345678901234567890123456789012345678901234567890123.xn--1234567890123456789012345678901234567890123456789012345-kue.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b", true); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\x84123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890B", "123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa4123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b"); }
test { try toAsciiPass("123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\x84123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890B", "123456789012345678901234567890123456789012345678901234567890123.xn--1234567890123456789012345678901234567890123456789012345-kue.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b", false); }
test { try toAsciiPass("123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\x84123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890B", "123456789012345678901234567890123456789012345678901234567890123.xn--1234567890123456789012345678901234567890123456789012345-kue.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b", true); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.xn--1234567890123456789012345678901234567890123456789012345-kue.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b", "123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa4123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b"); }
test { try toAsciiPass("123456789012345678901234567890123456789012345678901234567890123.xn--1234567890123456789012345678901234567890123456789012345-kue.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b", "123456789012345678901234567890123456789012345678901234567890123.xn--1234567890123456789012345678901234567890123456789012345-kue.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b", false); }
test { try toAsciiPass("123456789012345678901234567890123456789012345678901234567890123.xn--1234567890123456789012345678901234567890123456789012345-kue.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b", "123456789012345678901234567890123456789012345678901234567890123.xn--1234567890123456789012345678901234567890123456789012345-kue.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b", true); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa4123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b.", "123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa4123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b."); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.1234567890a\xcc\x88123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b.", "123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa4123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b."); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.1234567890A\xcc\x88123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890B.", "123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa4123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b."); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\x84123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890B.", "123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa4123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b."); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.xn--1234567890123456789012345678901234567890123456789012345-kue.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b.", "123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa4123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b."); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa4123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.1234567890123456789012345678901234567890123456789012345678901c", "123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa4123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.1234567890123456789012345678901234567890123456789012345678901c"); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.1234567890a\xcc\x88123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.1234567890123456789012345678901234567890123456789012345678901c", "123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa4123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.1234567890123456789012345678901234567890123456789012345678901c"); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.1234567890A\xcc\x88123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.1234567890123456789012345678901234567890123456789012345678901C", "123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa4123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.1234567890123456789012345678901234567890123456789012345678901c"); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\x84123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.1234567890123456789012345678901234567890123456789012345678901C", "123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa4123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.1234567890123456789012345678901234567890123456789012345678901c"); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.xn--1234567890123456789012345678901234567890123456789012345-kue.123456789012345678901234567890123456789012345678901234567890123.1234567890123456789012345678901234567890123456789012345678901c", "123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa4123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.1234567890123456789012345678901234567890123456789012345678901c"); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa41234567890123456789012345678901234567890123456.123456789012345678901234567890123456789012345678901234567890123.12345678901234567890123456789012345678901234567890123456789a", "123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa41234567890123456789012345678901234567890123456.123456789012345678901234567890123456789012345678901234567890123.12345678901234567890123456789012345678901234567890123456789a"); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.1234567890a\xcc\x881234567890123456789012345678901234567890123456.123456789012345678901234567890123456789012345678901234567890123.12345678901234567890123456789012345678901234567890123456789a", "123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa41234567890123456789012345678901234567890123456.123456789012345678901234567890123456789012345678901234567890123.12345678901234567890123456789012345678901234567890123456789a"); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.1234567890A\xcc\x881234567890123456789012345678901234567890123456.123456789012345678901234567890123456789012345678901234567890123.12345678901234567890123456789012345678901234567890123456789A", "123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa41234567890123456789012345678901234567890123456.123456789012345678901234567890123456789012345678901234567890123.12345678901234567890123456789012345678901234567890123456789a"); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\x841234567890123456789012345678901234567890123456.123456789012345678901234567890123456789012345678901234567890123.12345678901234567890123456789012345678901234567890123456789A", "123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa41234567890123456789012345678901234567890123456.123456789012345678901234567890123456789012345678901234567890123.12345678901234567890123456789012345678901234567890123456789a"); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.xn--12345678901234567890123456789012345678901234567890123456-fxe.123456789012345678901234567890123456789012345678901234567890123.12345678901234567890123456789012345678901234567890123456789a", "123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa41234567890123456789012345678901234567890123456.123456789012345678901234567890123456789012345678901234567890123.12345678901234567890123456789012345678901234567890123456789a"); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa41234567890123456789012345678901234567890123456.123456789012345678901234567890123456789012345678901234567890123.12345678901234567890123456789012345678901234567890123456789a.", "123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa41234567890123456789012345678901234567890123456.123456789012345678901234567890123456789012345678901234567890123.12345678901234567890123456789012345678901234567890123456789a."); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.1234567890a\xcc\x881234567890123456789012345678901234567890123456.123456789012345678901234567890123456789012345678901234567890123.12345678901234567890123456789012345678901234567890123456789a.", "123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa41234567890123456789012345678901234567890123456.123456789012345678901234567890123456789012345678901234567890123.12345678901234567890123456789012345678901234567890123456789a."); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.1234567890A\xcc\x881234567890123456789012345678901234567890123456.123456789012345678901234567890123456789012345678901234567890123.12345678901234567890123456789012345678901234567890123456789A.", "123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa41234567890123456789012345678901234567890123456.123456789012345678901234567890123456789012345678901234567890123.12345678901234567890123456789012345678901234567890123456789a."); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\x841234567890123456789012345678901234567890123456.123456789012345678901234567890123456789012345678901234567890123.12345678901234567890123456789012345678901234567890123456789A.", "123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa41234567890123456789012345678901234567890123456.123456789012345678901234567890123456789012345678901234567890123.12345678901234567890123456789012345678901234567890123456789a."); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.xn--12345678901234567890123456789012345678901234567890123456-fxe.123456789012345678901234567890123456789012345678901234567890123.12345678901234567890123456789012345678901234567890123456789a.", "123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa41234567890123456789012345678901234567890123456.123456789012345678901234567890123456789012345678901234567890123.12345678901234567890123456789012345678901234567890123456789a."); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa41234567890123456789012345678901234567890123456.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b", "123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa41234567890123456789012345678901234567890123456.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b"); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.1234567890a\xcc\x881234567890123456789012345678901234567890123456.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b", "123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa41234567890123456789012345678901234567890123456.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b"); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.1234567890A\xcc\x881234567890123456789012345678901234567890123456.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890B", "123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa41234567890123456789012345678901234567890123456.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b"); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\x841234567890123456789012345678901234567890123456.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890B", "123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa41234567890123456789012345678901234567890123456.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b"); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.xn--12345678901234567890123456789012345678901234567890123456-fxe.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b", "123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa41234567890123456789012345678901234567890123456.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b"); }
test { try toUnicodePass("A0", "a0"); }
test { try toAsciiPass("A0", "a0", false); }
test { try toAsciiPass("A0", "a0", true); }
test { try toUnicodePass("0A", "0a"); }
test { try toAsciiPass("0A", "0a", false); }
test { try toAsciiPass("0A", "0a", true); }
test { try toUnicodePass("\xd7\x90\xd7\x87", "\xd7\x90\xd7\x87"); }
test { try toAsciiPass("\xd7\x90\xd7\x87", "xn--vdbr", false); }
test { try toAsciiPass("\xd7\x90\xd7\x87", "xn--vdbr", true); }
test { try toUnicodePass("xn--vdbr", "\xd7\x90\xd7\x87"); }
test { try toAsciiPass("xn--vdbr", "xn--vdbr", false); }
test { try toAsciiPass("xn--vdbr", "xn--vdbr", true); }
test { try toUnicodePass("\xd7\x909\xd7\x87", "\xd7\x909\xd7\x87"); }
test { try toAsciiPass("\xd7\x909\xd7\x87", "xn--9-ihcz", false); }
test { try toAsciiPass("\xd7\x909\xd7\x87", "xn--9-ihcz", true); }
test { try toUnicodePass("xn--9-ihcz", "\xd7\x909\xd7\x87"); }
test { try toAsciiPass("xn--9-ihcz", "xn--9-ihcz", false); }
test { try toAsciiPass("xn--9-ihcz", "xn--9-ihcz", true); }
test { try toUnicodePass("\xd7\x90\xd7\xaa", "\xd7\x90\xd7\xaa"); }
test { try toAsciiPass("\xd7\x90\xd7\xaa", "xn--4db6c", false); }
test { try toAsciiPass("\xd7\x90\xd7\xaa", "xn--4db6c", true); }
test { try toUnicodePass("xn--4db6c", "\xd7\x90\xd7\xaa"); }
test { try toAsciiPass("xn--4db6c", "xn--4db6c", false); }
test { try toAsciiPass("xn--4db6c", "xn--4db6c", true); }
test { try toUnicodePass("\xd7\x90\xd7\xb3\xd7\xaa", "\xd7\x90\xd7\xb3\xd7\xaa"); }
test { try toAsciiPass("\xd7\x90\xd7\xb3\xd7\xaa", "xn--4db6c0a", false); }
test { try toAsciiPass("\xd7\x90\xd7\xb3\xd7\xaa", "xn--4db6c0a", true); }
test { try toUnicodePass("xn--4db6c0a", "\xd7\x90\xd7\xb3\xd7\xaa"); }
test { try toAsciiPass("xn--4db6c0a", "xn--4db6c0a", false); }
test { try toAsciiPass("xn--4db6c0a", "xn--4db6c0a", true); }
test { try toUnicodePass("\xd7\x907\xd7\xaa", "\xd7\x907\xd7\xaa"); }
test { try toAsciiPass("\xd7\x907\xd7\xaa", "xn--7-zhc3f", false); }
test { try toAsciiPass("\xd7\x907\xd7\xaa", "xn--7-zhc3f", true); }
test { try toUnicodePass("xn--7-zhc3f", "\xd7\x907\xd7\xaa"); }
test { try toAsciiPass("xn--7-zhc3f", "xn--7-zhc3f", false); }
test { try toAsciiPass("xn--7-zhc3f", "xn--7-zhc3f", true); }
test { try toUnicodePass("\xd7\x90\xd9\xa7\xd7\xaa", "\xd7\x90\xd9\xa7\xd7\xaa"); }
test { try toAsciiPass("\xd7\x90\xd9\xa7\xd7\xaa", "xn--4db6c6t", false); }
test { try toAsciiPass("\xd7\x90\xd9\xa7\xd7\xaa", "xn--4db6c6t", true); }
test { try toUnicodePass("xn--4db6c6t", "\xd7\x90\xd9\xa7\xd7\xaa"); }
test { try toAsciiPass("xn--4db6c6t", "xn--4db6c6t", false); }
test { try toAsciiPass("xn--4db6c6t", "xn--4db6c6t", true); }
test { try toUnicodePass("\xe0\xae\xb9\xe0\xaf\x8d\xe2\x80\x8d", "\xe0\xae\xb9\xe0\xaf\x8d\xe2\x80\x8d"); }
test { try toAsciiPass("\xe0\xae\xb9\xe0\xaf\x8d\xe2\x80\x8d", "xn--dmc4b194h", false); }
test { try toAsciiPass("\xe0\xae\xb9\xe0\xaf\x8d\xe2\x80\x8d", "xn--dmc4b", true); }
test { try toUnicodePass("xn--dmc4b", "\xe0\xae\xb9\xe0\xaf\x8d"); }
test { try toAsciiPass("xn--dmc4b", "xn--dmc4b", false); }
test { try toAsciiPass("xn--dmc4b", "xn--dmc4b", true); }
test { try toUnicodePass("\xe0\xae\xb9\xe0\xaf\x8d", "\xe0\xae\xb9\xe0\xaf\x8d"); }
test { try toAsciiPass("\xe0\xae\xb9\xe0\xaf\x8d", "xn--dmc4b", false); }
test { try toAsciiPass("\xe0\xae\xb9\xe0\xaf\x8d", "xn--dmc4b", true); }
test { try toUnicodePass("xn--dmc4b194h", "\xe0\xae\xb9\xe0\xaf\x8d\xe2\x80\x8d"); }
test { try toAsciiPass("xn--dmc4b194h", "xn--dmc4b194h", false); }
test { try toAsciiPass("xn--dmc4b194h", "xn--dmc4b194h", true); }
test { try toAsciiPass("\xe0\xae\xb9\xe2\x80\x8d", "xn--dmc", true); }
test { try toUnicodePass("xn--dmc", "\xe0\xae\xb9"); }
test { try toAsciiPass("xn--dmc", "xn--dmc", false); }
test { try toAsciiPass("xn--dmc", "xn--dmc", true); }
test { try toUnicodePass("\xe0\xae\xb9", "\xe0\xae\xb9"); }
test { try toAsciiPass("\xe0\xae\xb9", "xn--dmc", false); }
test { try toAsciiPass("\xe0\xae\xb9", "xn--dmc", true); }
test { try toUnicodePass("\xe0\xae\xb9\xe0\xaf\x8d\xe2\x80\x8c", "\xe0\xae\xb9\xe0\xaf\x8d\xe2\x80\x8c"); }
test { try toAsciiPass("\xe0\xae\xb9\xe0\xaf\x8d\xe2\x80\x8c", "xn--dmc4by94h", false); }
test { try toAsciiPass("\xe0\xae\xb9\xe0\xaf\x8d\xe2\x80\x8c", "xn--dmc4b", true); }
test { try toUnicodePass("xn--dmc4by94h", "\xe0\xae\xb9\xe0\xaf\x8d\xe2\x80\x8c"); }
test { try toAsciiPass("xn--dmc4by94h", "xn--dmc4by94h", false); }
test { try toAsciiPass("xn--dmc4by94h", "xn--dmc4by94h", true); }
test { try toAsciiPass("\xe0\xae\xb9\xe2\x80\x8c", "xn--dmc", true); }
test { try toUnicodePass("\xd9\x84\xd9\xb0\xe2\x80\x8c\xdb\xad\xdb\xaf", "\xd9\x84\xd9\xb0\xe2\x80\x8c\xdb\xad\xdb\xaf"); }
test { try toAsciiPass("\xd9\x84\xd9\xb0\xe2\x80\x8c\xdb\xad\xdb\xaf", "xn--ghb2gxqia7523a", false); }
test { try toAsciiPass("\xd9\x84\xd9\xb0\xe2\x80\x8c\xdb\xad\xdb\xaf", "xn--ghb2gxqia", true); }
test { try toUnicodePass("xn--ghb2gxqia", "\xd9\x84\xd9\xb0\xdb\xad\xdb\xaf"); }
test { try toAsciiPass("xn--ghb2gxqia", "xn--ghb2gxqia", false); }
test { try toAsciiPass("xn--ghb2gxqia", "xn--ghb2gxqia", true); }
test { try toUnicodePass("\xd9\x84\xd9\xb0\xdb\xad\xdb\xaf", "\xd9\x84\xd9\xb0\xdb\xad\xdb\xaf"); }
test { try toAsciiPass("\xd9\x84\xd9\xb0\xdb\xad\xdb\xaf", "xn--ghb2gxqia", false); }
test { try toAsciiPass("\xd9\x84\xd9\xb0\xdb\xad\xdb\xaf", "xn--ghb2gxqia", true); }
test { try toUnicodePass("xn--ghb2gxqia7523a", "\xd9\x84\xd9\xb0\xe2\x80\x8c\xdb\xad\xdb\xaf"); }
test { try toAsciiPass("xn--ghb2gxqia7523a", "xn--ghb2gxqia7523a", false); }
test { try toAsciiPass("xn--ghb2gxqia7523a", "xn--ghb2gxqia7523a", true); }
test { try toUnicodePass("\xd9\x84\xd9\xb0\xe2\x80\x8c\xdb\xaf", "\xd9\x84\xd9\xb0\xe2\x80\x8c\xdb\xaf"); }
test { try toAsciiPass("\xd9\x84\xd9\xb0\xe2\x80\x8c\xdb\xaf", "xn--ghb2g3qq34f", false); }
test { try toAsciiPass("\xd9\x84\xd9\xb0\xe2\x80\x8c\xdb\xaf", "xn--ghb2g3q", true); }
test { try toUnicodePass("xn--ghb2g3q", "\xd9\x84\xd9\xb0\xdb\xaf"); }
test { try toAsciiPass("xn--ghb2g3q", "xn--ghb2g3q", false); }
test { try toAsciiPass("xn--ghb2g3q", "xn--ghb2g3q", true); }
test { try toUnicodePass("\xd9\x84\xd9\xb0\xdb\xaf", "\xd9\x84\xd9\xb0\xdb\xaf"); }
test { try toAsciiPass("\xd9\x84\xd9\xb0\xdb\xaf", "xn--ghb2g3q", false); }
test { try toAsciiPass("\xd9\x84\xd9\xb0\xdb\xaf", "xn--ghb2g3q", true); }
test { try toUnicodePass("xn--ghb2g3qq34f", "\xd9\x84\xd9\xb0\xe2\x80\x8c\xdb\xaf"); }
test { try toAsciiPass("xn--ghb2g3qq34f", "xn--ghb2g3qq34f", false); }
test { try toAsciiPass("xn--ghb2g3qq34f", "xn--ghb2g3qq34f", true); }
test { try toUnicodePass("\xd9\x84\xe2\x80\x8c\xdb\xad\xdb\xaf", "\xd9\x84\xe2\x80\x8c\xdb\xad\xdb\xaf"); }
test { try toAsciiPass("\xd9\x84\xe2\x80\x8c\xdb\xad\xdb\xaf", "xn--ghb25aga828w", false); }
test { try toAsciiPass("\xd9\x84\xe2\x80\x8c\xdb\xad\xdb\xaf", "xn--ghb25aga", true); }
test { try toUnicodePass("xn--ghb25aga", "\xd9\x84\xdb\xad\xdb\xaf"); }
test { try toAsciiPass("xn--ghb25aga", "xn--ghb25aga", false); }
test { try toAsciiPass("xn--ghb25aga", "xn--ghb25aga", true); }
test { try toUnicodePass("\xd9\x84\xdb\xad\xdb\xaf", "\xd9\x84\xdb\xad\xdb\xaf"); }
test { try toAsciiPass("\xd9\x84\xdb\xad\xdb\xaf", "xn--ghb25aga", false); }
test { try toAsciiPass("\xd9\x84\xdb\xad\xdb\xaf", "xn--ghb25aga", true); }
test { try toUnicodePass("xn--ghb25aga828w", "\xd9\x84\xe2\x80\x8c\xdb\xad\xdb\xaf"); }
test { try toAsciiPass("xn--ghb25aga828w", "xn--ghb25aga828w", false); }
test { try toAsciiPass("xn--ghb25aga828w", "xn--ghb25aga828w", true); }
test { try toUnicodePass("\xd9\x84\xe2\x80\x8c\xdb\xaf", "\xd9\x84\xe2\x80\x8c\xdb\xaf"); }
test { try toAsciiPass("\xd9\x84\xe2\x80\x8c\xdb\xaf", "xn--ghb65a953d", false); }
test { try toAsciiPass("\xd9\x84\xe2\x80\x8c\xdb\xaf", "xn--ghb65a", true); }
test { try toUnicodePass("xn--ghb65a", "\xd9\x84\xdb\xaf"); }
test { try toAsciiPass("xn--ghb65a", "xn--ghb65a", false); }
test { try toAsciiPass("xn--ghb65a", "xn--ghb65a", true); }
test { try toUnicodePass("\xd9\x84\xdb\xaf", "\xd9\x84\xdb\xaf"); }
test { try toAsciiPass("\xd9\x84\xdb\xaf", "xn--ghb65a", false); }
test { try toAsciiPass("\xd9\x84\xdb\xaf", "xn--ghb65a", true); }
test { try toUnicodePass("xn--ghb65a953d", "\xd9\x84\xe2\x80\x8c\xdb\xaf"); }
test { try toAsciiPass("xn--ghb65a953d", "xn--ghb65a953d", false); }
test { try toAsciiPass("xn--ghb65a953d", "xn--ghb65a953d", true); }
test { try toAsciiPass("\xd9\x84\xd9\xb0\xe2\x80\x8c\xdb\xad", "xn--ghb2gxq", true); }
test { try toUnicodePass("xn--ghb2gxq", "\xd9\x84\xd9\xb0\xdb\xad"); }
test { try toAsciiPass("xn--ghb2gxq", "xn--ghb2gxq", false); }
test { try toAsciiPass("xn--ghb2gxq", "xn--ghb2gxq", true); }
test { try toUnicodePass("\xd9\x84\xd9\xb0\xdb\xad", "\xd9\x84\xd9\xb0\xdb\xad"); }
test { try toAsciiPass("\xd9\x84\xd9\xb0\xdb\xad", "xn--ghb2gxq", false); }
test { try toAsciiPass("\xd9\x84\xd9\xb0\xdb\xad", "xn--ghb2gxq", true); }
test { try toAsciiPass("\xdb\xaf\xe2\x80\x8c\xdb\xaf", "xn--cmba", true); }
test { try toUnicodePass("xn--cmba", "\xdb\xaf\xdb\xaf"); }
test { try toAsciiPass("xn--cmba", "xn--cmba", false); }
test { try toAsciiPass("xn--cmba", "xn--cmba", true); }
test { try toUnicodePass("\xdb\xaf\xdb\xaf", "\xdb\xaf\xdb\xaf"); }
test { try toAsciiPass("\xdb\xaf\xdb\xaf", "xn--cmba", false); }
test { try toAsciiPass("\xdb\xaf\xdb\xaf", "xn--cmba", true); }
test { try toAsciiPass("\xd9\x84\xe2\x80\x8c", "xn--ghb", true); }
test { try toUnicodePass("xn--ghb", "\xd9\x84"); }
test { try toAsciiPass("xn--ghb", "xn--ghb", false); }
test { try toAsciiPass("xn--ghb", "xn--ghb", true); }
test { try toUnicodePass("\xd9\x84", "\xd9\x84"); }
test { try toAsciiPass("\xd9\x84", "xn--ghb", false); }
test { try toAsciiPass("\xd9\x84", "xn--ghb", true); }
test { try toUnicodePass("ascii", "ascii"); }
test { try toAsciiPass("ascii", "ascii", false); }
test { try toAsciiPass("ascii", "ascii", true); }
test { try toUnicodePass("unicode.org", "unicode.org"); }
test { try toAsciiPass("unicode.org", "unicode.org", false); }
test { try toAsciiPass("unicode.org", "unicode.org", true); }
test { try toUnicodePass("\xef\xa5\x91\xf0\xaf\xa1\xa8\xf0\xaf\xa1\xb4\xf0\xaf\xa4\x9f\xf0\xaf\xa5\x9f\xf0\xaf\xa6\xbf", "\xe9\x99\x8b\xe3\x9b\xbc\xe5\xbd\x93\xf0\xa4\x8e\xab\xe7\xab\xae\xe4\x97\x97"); }
test { try toAsciiPass("\xef\xa5\x91\xf0\xaf\xa1\xa8\xf0\xaf\xa1\xb4\xf0\xaf\xa4\x9f\xf0\xaf\xa5\x9f\xf0\xaf\xa6\xbf", "xn--snl253bgitxhzwu2arn60c", false); }
test { try toAsciiPass("\xef\xa5\x91\xf0\xaf\xa1\xa8\xf0\xaf\xa1\xb4\xf0\xaf\xa4\x9f\xf0\xaf\xa5\x9f\xf0\xaf\xa6\xbf", "xn--snl253bgitxhzwu2arn60c", true); }
test { try toUnicodePass("\xe9\x99\x8b\xe3\x9b\xbc\xe5\xbd\x93\xf0\xa4\x8e\xab\xe7\xab\xae\xe4\x97\x97", "\xe9\x99\x8b\xe3\x9b\xbc\xe5\xbd\x93\xf0\xa4\x8e\xab\xe7\xab\xae\xe4\x97\x97"); }
test { try toAsciiPass("\xe9\x99\x8b\xe3\x9b\xbc\xe5\xbd\x93\xf0\xa4\x8e\xab\xe7\xab\xae\xe4\x97\x97", "xn--snl253bgitxhzwu2arn60c", false); }
test { try toAsciiPass("\xe9\x99\x8b\xe3\x9b\xbc\xe5\xbd\x93\xf0\xa4\x8e\xab\xe7\xab\xae\xe4\x97\x97", "xn--snl253bgitxhzwu2arn60c", true); }
test { try toUnicodePass("xn--snl253bgitxhzwu2arn60c", "\xe9\x99\x8b\xe3\x9b\xbc\xe5\xbd\x93\xf0\xa4\x8e\xab\xe7\xab\xae\xe4\x97\x97"); }
test { try toAsciiPass("xn--snl253bgitxhzwu2arn60c", "xn--snl253bgitxhzwu2arn60c", false); }
test { try toAsciiPass("xn--snl253bgitxhzwu2arn60c", "xn--snl253bgitxhzwu2arn60c", true); }
test { try toUnicodePass("\xe9\x9b\xbb\xf0\xa1\x8d\xaa\xe5\xbc\xb3\xe4\x8e\xab\xe7\xaa\xae\xe4\xb5\x97", "\xe9\x9b\xbb\xf0\xa1\x8d\xaa\xe5\xbc\xb3\xe4\x8e\xab\xe7\xaa\xae\xe4\xb5\x97"); }
test { try toAsciiPass("\xe9\x9b\xbb\xf0\xa1\x8d\xaa\xe5\xbc\xb3\xe4\x8e\xab\xe7\xaa\xae\xe4\xb5\x97", "xn--kbo60w31ob3z6t3av9z5b", false); }
test { try toAsciiPass("\xe9\x9b\xbb\xf0\xa1\x8d\xaa\xe5\xbc\xb3\xe4\x8e\xab\xe7\xaa\xae\xe4\xb5\x97", "xn--kbo60w31ob3z6t3av9z5b", true); }
test { try toUnicodePass("xn--kbo60w31ob3z6t3av9z5b", "\xe9\x9b\xbb\xf0\xa1\x8d\xaa\xe5\xbc\xb3\xe4\x8e\xab\xe7\xaa\xae\xe4\xb5\x97"); }
test { try toAsciiPass("xn--kbo60w31ob3z6t3av9z5b", "xn--kbo60w31ob3z6t3av9z5b", false); }
test { try toAsciiPass("xn--kbo60w31ob3z6t3av9z5b", "xn--kbo60w31ob3z6t3av9z5b", true); }
test { try toUnicodePass("xn--A-1ga", "a\xc3\xb6"); }
test { try toAsciiPass("xn--A-1ga", "xn--a-1ga", false); }
test { try toAsciiPass("xn--A-1ga", "xn--a-1ga", true); }
test { try toUnicodePass("a\xc3\xb6", "a\xc3\xb6"); }
test { try toAsciiPass("a\xc3\xb6", "xn--a-1ga", false); }
test { try toAsciiPass("a\xc3\xb6", "xn--a-1ga", true); }
test { try toUnicodePass("ao\xcc\x88", "a\xc3\xb6"); }
test { try toAsciiPass("ao\xcc\x88", "xn--a-1ga", false); }
test { try toAsciiPass("ao\xcc\x88", "xn--a-1ga", true); }
test { try toUnicodePass("AO\xcc\x88", "a\xc3\xb6"); }
test { try toAsciiPass("AO\xcc\x88", "xn--a-1ga", false); }
test { try toAsciiPass("AO\xcc\x88", "xn--a-1ga", true); }
test { try toUnicodePass("A\xc3\x96", "a\xc3\xb6"); }
test { try toAsciiPass("A\xc3\x96", "xn--a-1ga", false); }
test { try toAsciiPass("A\xc3\x96", "xn--a-1ga", true); }
test { try toUnicodePass("A\xc3\xb6", "a\xc3\xb6"); }
test { try toAsciiPass("A\xc3\xb6", "xn--a-1ga", false); }
test { try toAsciiPass("A\xc3\xb6", "xn--a-1ga", true); }
test { try toUnicodePass("Ao\xcc\x88", "a\xc3\xb6"); }
test { try toAsciiPass("Ao\xcc\x88", "xn--a-1ga", false); }
test { try toAsciiPass("Ao\xcc\x88", "xn--a-1ga", true); }
test { try toUnicodePass("\xef\xbc\x9d\xcc\xb8", "\xe2\x89\xa0"); }
test { try toAsciiPass("\xef\xbc\x9d\xcc\xb8", "xn--1ch", false); }
test { try toAsciiPass("\xef\xbc\x9d\xcc\xb8", "xn--1ch", true); }
test { try toUnicodePass("\xe2\x89\xa0", "\xe2\x89\xa0"); }
test { try toAsciiPass("\xe2\x89\xa0", "xn--1ch", false); }
test { try toAsciiPass("\xe2\x89\xa0", "xn--1ch", true); }
test { try toUnicodePass("=\xcc\xb8", "\xe2\x89\xa0"); }
test { try toAsciiPass("=\xcc\xb8", "xn--1ch", false); }
test { try toAsciiPass("=\xcc\xb8", "xn--1ch", true); }
test { try toUnicodePass("xn--1ch", "\xe2\x89\xa0"); }
test { try toAsciiPass("xn--1ch", "xn--1ch", false); }
test { try toAsciiPass("xn--1ch", "xn--1ch", true); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.1234567890A\xcc\x88123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b", "123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa4123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b"); }
test { try toAsciiPass("123456789012345678901234567890123456789012345678901234567890123.1234567890A\xcc\x88123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b", "123456789012345678901234567890123456789012345678901234567890123.xn--1234567890123456789012345678901234567890123456789012345-kue.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b", false); }
test { try toAsciiPass("123456789012345678901234567890123456789012345678901234567890123.1234567890A\xcc\x88123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b", "123456789012345678901234567890123456789012345678901234567890123.xn--1234567890123456789012345678901234567890123456789012345-kue.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b", true); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\x84123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b", "123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa4123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b"); }
test { try toAsciiPass("123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\x84123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b", "123456789012345678901234567890123456789012345678901234567890123.xn--1234567890123456789012345678901234567890123456789012345-kue.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b", false); }
test { try toAsciiPass("123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\x84123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b", "123456789012345678901234567890123456789012345678901234567890123.xn--1234567890123456789012345678901234567890123456789012345-kue.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b", true); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.1234567890A\xcc\x88123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b.", "123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa4123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b."); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\x84123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b.", "123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa4123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b."); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.1234567890A\xcc\x88123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.1234567890123456789012345678901234567890123456789012345678901c", "123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa4123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.1234567890123456789012345678901234567890123456789012345678901c"); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\x84123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.1234567890123456789012345678901234567890123456789012345678901c", "123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa4123456789012345678901234567890123456789012345.123456789012345678901234567890123456789012345678901234567890123.1234567890123456789012345678901234567890123456789012345678901c"); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.1234567890A\xcc\x881234567890123456789012345678901234567890123456.123456789012345678901234567890123456789012345678901234567890123.12345678901234567890123456789012345678901234567890123456789a", "123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa41234567890123456789012345678901234567890123456.123456789012345678901234567890123456789012345678901234567890123.12345678901234567890123456789012345678901234567890123456789a"); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\x841234567890123456789012345678901234567890123456.123456789012345678901234567890123456789012345678901234567890123.12345678901234567890123456789012345678901234567890123456789a", "123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa41234567890123456789012345678901234567890123456.123456789012345678901234567890123456789012345678901234567890123.12345678901234567890123456789012345678901234567890123456789a"); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.1234567890A\xcc\x881234567890123456789012345678901234567890123456.123456789012345678901234567890123456789012345678901234567890123.12345678901234567890123456789012345678901234567890123456789a.", "123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa41234567890123456789012345678901234567890123456.123456789012345678901234567890123456789012345678901234567890123.12345678901234567890123456789012345678901234567890123456789a."); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\x841234567890123456789012345678901234567890123456.123456789012345678901234567890123456789012345678901234567890123.12345678901234567890123456789012345678901234567890123456789a.", "123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa41234567890123456789012345678901234567890123456.123456789012345678901234567890123456789012345678901234567890123.12345678901234567890123456789012345678901234567890123456789a."); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.1234567890A\xcc\x881234567890123456789012345678901234567890123456.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b", "123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa41234567890123456789012345678901234567890123456.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b"); }
test { try toUnicodePass("123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\x841234567890123456789012345678901234567890123456.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b", "123456789012345678901234567890123456789012345678901234567890123.1234567890\xc3\xa41234567890123456789012345678901234567890123456.123456789012345678901234567890123456789012345678901234567890123.123456789012345678901234567890123456789012345678901234567890b"); }
test { try toUnicodePass("\xea\xa1\xa3.\xdf\x8f", "\xea\xa1\xa3.\xdf\x8f"); }
test { try toAsciiPass("\xea\xa1\xa3.\xdf\x8f", "xn--8c9a.xn--qsb", false); }
test { try toAsciiPass("\xea\xa1\xa3.\xdf\x8f", "xn--8c9a.xn--qsb", true); }
test { try toUnicodePass("xn--8c9a.xn--qsb", "\xea\xa1\xa3.\xdf\x8f"); }
test { try toAsciiPass("xn--8c9a.xn--qsb", "xn--8c9a.xn--qsb", false); }
test { try toAsciiPass("xn--8c9a.xn--qsb", "xn--8c9a.xn--qsb", true); }
test { try toAsciiPass("\xe2\x80\x8d\xe2\x89\xa0\xe1\xa2\x99\xe2\x89\xaf.\xec\x86\xa3-\xe1\xa1\xb4\xe1\x82\xa0", "xn--jbf911clb.xn----p9j493ivi4l", true); }
test { try toAsciiPass("\xe2\x80\x8d=\xcc\xb8\xe1\xa2\x99>\xcc\xb8.\xe1\x84\x89\xe1\x85\xa9\xe1\x86\xbe-\xe1\xa1\xb4\xe1\x82\xa0", "xn--jbf911clb.xn----p9j493ivi4l", true); }
test { try toAsciiPass("\xe2\x80\x8d=\xcc\xb8\xe1\xa2\x99>\xcc\xb8.\xe1\x84\x89\xe1\x85\xa9\xe1\x86\xbe-\xe1\xa1\xb4\xe2\xb4\x80", "xn--jbf911clb.xn----p9j493ivi4l", true); }
test { try toAsciiPass("\xe2\x80\x8d\xe2\x89\xa0\xe1\xa2\x99\xe2\x89\xaf.\xec\x86\xa3-\xe1\xa1\xb4\xe2\xb4\x80", "xn--jbf911clb.xn----p9j493ivi4l", true); }
test { try toUnicodePass("xn--jbf911clb.xn----p9j493ivi4l", "\xe2\x89\xa0\xe1\xa2\x99\xe2\x89\xaf.\xec\x86\xa3-\xe1\xa1\xb4\xe2\xb4\x80"); }
test { try toAsciiPass("xn--jbf911clb.xn----p9j493ivi4l", "xn--jbf911clb.xn----p9j493ivi4l", false); }
test { try toAsciiPass("xn--jbf911clb.xn----p9j493ivi4l", "xn--jbf911clb.xn----p9j493ivi4l", true); }
test { try toUnicodePass("\xe2\x89\xa0\xe1\xa2\x99\xe2\x89\xaf.\xec\x86\xa3-\xe1\xa1\xb4\xe2\xb4\x80", "\xe2\x89\xa0\xe1\xa2\x99\xe2\x89\xaf.\xec\x86\xa3-\xe1\xa1\xb4\xe2\xb4\x80"); }
test { try toAsciiPass("\xe2\x89\xa0\xe1\xa2\x99\xe2\x89\xaf.\xec\x86\xa3-\xe1\xa1\xb4\xe2\xb4\x80", "xn--jbf911clb.xn----p9j493ivi4l", false); }
test { try toAsciiPass("\xe2\x89\xa0\xe1\xa2\x99\xe2\x89\xaf.\xec\x86\xa3-\xe1\xa1\xb4\xe2\xb4\x80", "xn--jbf911clb.xn----p9j493ivi4l", true); }
test { try toUnicodePass("=\xcc\xb8\xe1\xa2\x99>\xcc\xb8.\xe1\x84\x89\xe1\x85\xa9\xe1\x86\xbe-\xe1\xa1\xb4\xe2\xb4\x80", "\xe2\x89\xa0\xe1\xa2\x99\xe2\x89\xaf.\xec\x86\xa3-\xe1\xa1\xb4\xe2\xb4\x80"); }
test { try toAsciiPass("=\xcc\xb8\xe1\xa2\x99>\xcc\xb8.\xe1\x84\x89\xe1\x85\xa9\xe1\x86\xbe-\xe1\xa1\xb4\xe2\xb4\x80", "xn--jbf911clb.xn----p9j493ivi4l", false); }
test { try toAsciiPass("=\xcc\xb8\xe1\xa2\x99>\xcc\xb8.\xe1\x84\x89\xe1\x85\xa9\xe1\x86\xbe-\xe1\xa1\xb4\xe2\xb4\x80", "xn--jbf911clb.xn----p9j493ivi4l", true); }
test { try toUnicodePass("=\xcc\xb8\xe1\xa2\x99>\xcc\xb8.\xe1\x84\x89\xe1\x85\xa9\xe1\x86\xbe-\xe1\xa1\xb4\xe1\x82\xa0", "\xe2\x89\xa0\xe1\xa2\x99\xe2\x89\xaf.\xec\x86\xa3-\xe1\xa1\xb4\xe2\xb4\x80"); }
test { try toAsciiPass("=\xcc\xb8\xe1\xa2\x99>\xcc\xb8.\xe1\x84\x89\xe1\x85\xa9\xe1\x86\xbe-\xe1\xa1\xb4\xe1\x82\xa0", "xn--jbf911clb.xn----p9j493ivi4l", false); }
test { try toAsciiPass("=\xcc\xb8\xe1\xa2\x99>\xcc\xb8.\xe1\x84\x89\xe1\x85\xa9\xe1\x86\xbe-\xe1\xa1\xb4\xe1\x82\xa0", "xn--jbf911clb.xn----p9j493ivi4l", true); }
test { try toUnicodePass("\xe2\x89\xa0\xe1\xa2\x99\xe2\x89\xaf.\xec\x86\xa3-\xe1\xa1\xb4\xe1\x82\xa0", "\xe2\x89\xa0\xe1\xa2\x99\xe2\x89\xaf.\xec\x86\xa3-\xe1\xa1\xb4\xe2\xb4\x80"); }
test { try toAsciiPass("\xe2\x89\xa0\xe1\xa2\x99\xe2\x89\xaf.\xec\x86\xa3-\xe1\xa1\xb4\xe1\x82\xa0", "xn--jbf911clb.xn----p9j493ivi4l", false); }
test { try toAsciiPass("\xe2\x89\xa0\xe1\xa2\x99\xe2\x89\xaf.\xec\x86\xa3-\xe1\xa1\xb4\xe1\x82\xa0", "xn--jbf911clb.xn----p9j493ivi4l", true); }
test { try toUnicodePass("\xe7\xb9\xb1\xf0\x91\x96\xbf\xe2\x80\x8d.8\xe3\x80\x82", "\xe7\xb9\xb1\xf0\x91\x96\xbf\xe2\x80\x8d.8."); }
test { try toUnicodePass("xn--gl0as212a.i.", "\xe7\xb9\xb1\xf0\x91\x96\xbf.i."); }
test { try toUnicodePass("\xe7\xb9\xb1\xf0\x91\x96\xbf.i.", "\xe7\xb9\xb1\xf0\x91\x96\xbf.i."); }
test { try toUnicodePass("\xe7\xb9\xb1\xf0\x91\x96\xbf.I.", "\xe7\xb9\xb1\xf0\x91\x96\xbf.i."); }
test { try toUnicodePass("xn--1ug6928ac48e.i.", "\xe7\xb9\xb1\xf0\x91\x96\xbf\xe2\x80\x8d.i."); }
test { try toUnicodePass("\xe7\xb9\xb1\xf0\x91\x96\xbf\xe2\x80\x8d.i.", "\xe7\xb9\xb1\xf0\x91\x96\xbf\xe2\x80\x8d.i."); }
test { try toUnicodePass("\xe7\xb9\xb1\xf0\x91\x96\xbf\xe2\x80\x8d.I.", "\xe7\xb9\xb1\xf0\x91\x96\xbf\xe2\x80\x8d.i."); }
test { try toUnicodePass("xn--ss-59d.", "ss\xdb\xab."); }
test { try toUnicodePass("ss\xdb\xab.", "ss\xdb\xab."); }
test { try toUnicodePass("SS\xdb\xab.", "ss\xdb\xab."); }
test { try toUnicodePass("Ss\xdb\xab.", "ss\xdb\xab."); }
test { try toUnicodePass("\xf0\x9e\xa4\xb7.\xf0\x90\xae\x90\xf0\x9e\xa2\x81\xf0\x90\xb9\xa0\xd8\xa4", "\xf0\x9e\xa4\xb7.\xf0\x90\xae\x90\xf0\x9e\xa2\x81\xf0\x90\xb9\xa0\xd8\xa4"); }
test { try toAsciiPass("\xf0\x9e\xa4\xb7.\xf0\x90\xae\x90\xf0\x9e\xa2\x81\xf0\x90\xb9\xa0\xd8\xa4", "xn--ve6h.xn--jgb1694kz0b2176a", false); }
test { try toAsciiPass("\xf0\x9e\xa4\xb7.\xf0\x90\xae\x90\xf0\x9e\xa2\x81\xf0\x90\xb9\xa0\xd8\xa4", "xn--ve6h.xn--jgb1694kz0b2176a", true); }
test { try toUnicodePass("\xf0\x9e\xa4\xb7.\xf0\x90\xae\x90\xf0\x9e\xa2\x81\xf0\x90\xb9\xa0\xd9\x88\xd9\x94", "\xf0\x9e\xa4\xb7.\xf0\x90\xae\x90\xf0\x9e\xa2\x81\xf0\x90\xb9\xa0\xd8\xa4"); }
test { try toAsciiPass("\xf0\x9e\xa4\xb7.\xf0\x90\xae\x90\xf0\x9e\xa2\x81\xf0\x90\xb9\xa0\xd9\x88\xd9\x94", "xn--ve6h.xn--jgb1694kz0b2176a", false); }
test { try toAsciiPass("\xf0\x9e\xa4\xb7.\xf0\x90\xae\x90\xf0\x9e\xa2\x81\xf0\x90\xb9\xa0\xd9\x88\xd9\x94", "xn--ve6h.xn--jgb1694kz0b2176a", true); }
test { try toUnicodePass("\xf0\x9e\xa4\x95.\xf0\x90\xae\x90\xf0\x9e\xa2\x81\xf0\x90\xb9\xa0\xd9\x88\xd9\x94", "\xf0\x9e\xa4\xb7.\xf0\x90\xae\x90\xf0\x9e\xa2\x81\xf0\x90\xb9\xa0\xd8\xa4"); }
test { try toAsciiPass("\xf0\x9e\xa4\x95.\xf0\x90\xae\x90\xf0\x9e\xa2\x81\xf0\x90\xb9\xa0\xd9\x88\xd9\x94", "xn--ve6h.xn--jgb1694kz0b2176a", false); }
test { try toAsciiPass("\xf0\x9e\xa4\x95.\xf0\x90\xae\x90\xf0\x9e\xa2\x81\xf0\x90\xb9\xa0\xd9\x88\xd9\x94", "xn--ve6h.xn--jgb1694kz0b2176a", true); }
test { try toUnicodePass("\xf0\x9e\xa4\x95.\xf0\x90\xae\x90\xf0\x9e\xa2\x81\xf0\x90\xb9\xa0\xd8\xa4", "\xf0\x9e\xa4\xb7.\xf0\x90\xae\x90\xf0\x9e\xa2\x81\xf0\x90\xb9\xa0\xd8\xa4"); }
test { try toAsciiPass("\xf0\x9e\xa4\x95.\xf0\x90\xae\x90\xf0\x9e\xa2\x81\xf0\x90\xb9\xa0\xd8\xa4", "xn--ve6h.xn--jgb1694kz0b2176a", false); }
test { try toAsciiPass("\xf0\x9e\xa4\x95.\xf0\x90\xae\x90\xf0\x9e\xa2\x81\xf0\x90\xb9\xa0\xd8\xa4", "xn--ve6h.xn--jgb1694kz0b2176a", true); }
test { try toUnicodePass("xn--ve6h.xn--jgb1694kz0b2176a", "\xf0\x9e\xa4\xb7.\xf0\x90\xae\x90\xf0\x9e\xa2\x81\xf0\x90\xb9\xa0\xd8\xa4"); }
test { try toAsciiPass("xn--ve6h.xn--jgb1694kz0b2176a", "xn--ve6h.xn--jgb1694kz0b2176a", false); }
test { try toAsciiPass("xn--ve6h.xn--jgb1694kz0b2176a", "xn--ve6h.xn--jgb1694kz0b2176a", true); }
test { try toUnicodePass("\xf0\x9e\xa4\xa5\xf3\xa0\x85\xae\xef\xbc\x8e\xe1\xa1\x84\xe1\x82\xae", "\xf0\x9e\xa4\xa5.\xe1\xa1\x84\xe2\xb4\x8e"); }
test { try toAsciiPass("\xf0\x9e\xa4\xa5\xf3\xa0\x85\xae\xef\xbc\x8e\xe1\xa1\x84\xe1\x82\xae", "xn--de6h.xn--37e857h", false); }
test { try toAsciiPass("\xf0\x9e\xa4\xa5\xf3\xa0\x85\xae\xef\xbc\x8e\xe1\xa1\x84\xe1\x82\xae", "xn--de6h.xn--37e857h", true); }
test { try toUnicodePass("\xf0\x9e\xa4\xa5\xf3\xa0\x85\xae.\xe1\xa1\x84\xe1\x82\xae", "\xf0\x9e\xa4\xa5.\xe1\xa1\x84\xe2\xb4\x8e"); }
test { try toAsciiPass("\xf0\x9e\xa4\xa5\xf3\xa0\x85\xae.\xe1\xa1\x84\xe1\x82\xae", "xn--de6h.xn--37e857h", false); }
test { try toAsciiPass("\xf0\x9e\xa4\xa5\xf3\xa0\x85\xae.\xe1\xa1\x84\xe1\x82\xae", "xn--de6h.xn--37e857h", true); }
test { try toUnicodePass("\xf0\x9e\xa4\xa5\xf3\xa0\x85\xae.\xe1\xa1\x84\xe2\xb4\x8e", "\xf0\x9e\xa4\xa5.\xe1\xa1\x84\xe2\xb4\x8e"); }
test { try toAsciiPass("\xf0\x9e\xa4\xa5\xf3\xa0\x85\xae.\xe1\xa1\x84\xe2\xb4\x8e", "xn--de6h.xn--37e857h", false); }
test { try toAsciiPass("\xf0\x9e\xa4\xa5\xf3\xa0\x85\xae.\xe1\xa1\x84\xe2\xb4\x8e", "xn--de6h.xn--37e857h", true); }
test { try toUnicodePass("\xf0\x9e\xa4\x83\xf3\xa0\x85\xae.\xe1\xa1\x84\xe1\x82\xae", "\xf0\x9e\xa4\xa5.\xe1\xa1\x84\xe2\xb4\x8e"); }
test { try toAsciiPass("\xf0\x9e\xa4\x83\xf3\xa0\x85\xae.\xe1\xa1\x84\xe1\x82\xae", "xn--de6h.xn--37e857h", false); }
test { try toAsciiPass("\xf0\x9e\xa4\x83\xf3\xa0\x85\xae.\xe1\xa1\x84\xe1\x82\xae", "xn--de6h.xn--37e857h", true); }
test { try toUnicodePass("\xf0\x9e\xa4\x83\xf3\xa0\x85\xae.\xe1\xa1\x84\xe2\xb4\x8e", "\xf0\x9e\xa4\xa5.\xe1\xa1\x84\xe2\xb4\x8e"); }
test { try toAsciiPass("\xf0\x9e\xa4\x83\xf3\xa0\x85\xae.\xe1\xa1\x84\xe2\xb4\x8e", "xn--de6h.xn--37e857h", false); }
test { try toAsciiPass("\xf0\x9e\xa4\x83\xf3\xa0\x85\xae.\xe1\xa1\x84\xe2\xb4\x8e", "xn--de6h.xn--37e857h", true); }
test { try toUnicodePass("xn--de6h.xn--37e857h", "\xf0\x9e\xa4\xa5.\xe1\xa1\x84\xe2\xb4\x8e"); }
test { try toAsciiPass("xn--de6h.xn--37e857h", "xn--de6h.xn--37e857h", false); }
test { try toAsciiPass("xn--de6h.xn--37e857h", "xn--de6h.xn--37e857h", true); }
test { try toUnicodePass("\xf0\x9e\xa4\xa5.\xe1\xa1\x84\xe2\xb4\x8e", "\xf0\x9e\xa4\xa5.\xe1\xa1\x84\xe2\xb4\x8e"); }
test { try toAsciiPass("\xf0\x9e\xa4\xa5.\xe1\xa1\x84\xe2\xb4\x8e", "xn--de6h.xn--37e857h", false); }
test { try toAsciiPass("\xf0\x9e\xa4\xa5.\xe1\xa1\x84\xe2\xb4\x8e", "xn--de6h.xn--37e857h", true); }
test { try toUnicodePass("\xf0\x9e\xa4\x83.\xe1\xa1\x84\xe1\x82\xae", "\xf0\x9e\xa4\xa5.\xe1\xa1\x84\xe2\xb4\x8e"); }
test { try toAsciiPass("\xf0\x9e\xa4\x83.\xe1\xa1\x84\xe1\x82\xae", "xn--de6h.xn--37e857h", false); }
test { try toAsciiPass("\xf0\x9e\xa4\x83.\xe1\xa1\x84\xe1\x82\xae", "xn--de6h.xn--37e857h", true); }
test { try toUnicodePass("\xf0\x9e\xa4\x83.\xe1\xa1\x84\xe2\xb4\x8e", "\xf0\x9e\xa4\xa5.\xe1\xa1\x84\xe2\xb4\x8e"); }
test { try toAsciiPass("\xf0\x9e\xa4\x83.\xe1\xa1\x84\xe2\xb4\x8e", "xn--de6h.xn--37e857h", false); }
test { try toAsciiPass("\xf0\x9e\xa4\x83.\xe1\xa1\x84\xe2\xb4\x8e", "xn--de6h.xn--37e857h", true); }
test { try toUnicodePass("\xf0\x9e\xa4\xa5\xf3\xa0\x85\xae\xef\xbc\x8e\xe1\xa1\x84\xe2\xb4\x8e", "\xf0\x9e\xa4\xa5.\xe1\xa1\x84\xe2\xb4\x8e"); }
test { try toAsciiPass("\xf0\x9e\xa4\xa5\xf3\xa0\x85\xae\xef\xbc\x8e\xe1\xa1\x84\xe2\xb4\x8e", "xn--de6h.xn--37e857h", false); }
test { try toAsciiPass("\xf0\x9e\xa4\xa5\xf3\xa0\x85\xae\xef\xbc\x8e\xe1\xa1\x84\xe2\xb4\x8e", "xn--de6h.xn--37e857h", true); }
test { try toUnicodePass("\xf0\x9e\xa4\x83\xf3\xa0\x85\xae\xef\xbc\x8e\xe1\xa1\x84\xe1\x82\xae", "\xf0\x9e\xa4\xa5.\xe1\xa1\x84\xe2\xb4\x8e"); }
test { try toAsciiPass("\xf0\x9e\xa4\x83\xf3\xa0\x85\xae\xef\xbc\x8e\xe1\xa1\x84\xe1\x82\xae", "xn--de6h.xn--37e857h", false); }
test { try toAsciiPass("\xf0\x9e\xa4\x83\xf3\xa0\x85\xae\xef\xbc\x8e\xe1\xa1\x84\xe1\x82\xae", "xn--de6h.xn--37e857h", true); }
test { try toUnicodePass("\xf0\x9e\xa4\x83\xf3\xa0\x85\xae\xef\xbc\x8e\xe1\xa1\x84\xe2\xb4\x8e", "\xf0\x9e\xa4\xa5.\xe1\xa1\x84\xe2\xb4\x8e"); }
test { try toAsciiPass("\xf0\x9e\xa4\x83\xf3\xa0\x85\xae\xef\xbc\x8e\xe1\xa1\x84\xe2\xb4\x8e", "xn--de6h.xn--37e857h", false); }
test { try toAsciiPass("\xf0\x9e\xa4\x83\xf3\xa0\x85\xae\xef\xbc\x8e\xe1\xa1\x84\xe2\xb4\x8e", "xn--de6h.xn--37e857h", true); }
test { try toUnicodePass("\xf0\x9e\xa4\xa5.\xe1\xa1\x84\xe1\x82\xae", "\xf0\x9e\xa4\xa5.\xe1\xa1\x84\xe2\xb4\x8e"); }
test { try toAsciiPass("\xf0\x9e\xa4\xa5.\xe1\xa1\x84\xe1\x82\xae", "xn--de6h.xn--37e857h", false); }
test { try toAsciiPass("\xf0\x9e\xa4\xa5.\xe1\xa1\x84\xe1\x82\xae", "xn--de6h.xn--37e857h", true); }
test { try toAsciiPass("\xdd\x96\xe3\x80\x82\xe3\x85\xa4\xe2\x80\x8d\xcf\x82", "xn--9ob.xn--4xa", true); }
test { try toAsciiPass("\xdd\x96\xe3\x80\x82\xe1\x85\xa0\xe2\x80\x8d\xcf\x82", "xn--9ob.xn--4xa", true); }
test { try toAsciiPass("\xdd\x96\xe3\x80\x82\xe1\x85\xa0\xe2\x80\x8d\xce\xa3", "xn--9ob.xn--4xa", true); }
test { try toAsciiPass("\xdd\x96\xe3\x80\x82\xe1\x85\xa0\xe2\x80\x8d\xcf\x83", "xn--9ob.xn--4xa", true); }
test { try toUnicodePass("xn--9ob.xn--4xa", "\xdd\x96.\xcf\x83"); }
test { try toAsciiPass("xn--9ob.xn--4xa", "xn--9ob.xn--4xa", false); }
test { try toAsciiPass("xn--9ob.xn--4xa", "xn--9ob.xn--4xa", true); }
test { try toUnicodePass("\xdd\x96.\xcf\x83", "\xdd\x96.\xcf\x83"); }
test { try toAsciiPass("\xdd\x96.\xcf\x83", "xn--9ob.xn--4xa", false); }
test { try toAsciiPass("\xdd\x96.\xcf\x83", "xn--9ob.xn--4xa", true); }
test { try toUnicodePass("\xdd\x96.\xce\xa3", "\xdd\x96.\xcf\x83"); }
test { try toAsciiPass("\xdd\x96.\xce\xa3", "xn--9ob.xn--4xa", false); }
test { try toAsciiPass("\xdd\x96.\xce\xa3", "xn--9ob.xn--4xa", true); }
test { try toAsciiPass("\xdd\x96\xe3\x80\x82\xe3\x85\xa4\xe2\x80\x8d\xce\xa3", "xn--9ob.xn--4xa", true); }
test { try toAsciiPass("\xdd\x96\xe3\x80\x82\xe3\x85\xa4\xe2\x80\x8d\xcf\x83", "xn--9ob.xn--4xa", true); }
test { try toUnicodePass("\xc3\x9f\xef\xbd\xa1\xf0\x90\x8b\xb3\xe1\x82\xac\xe0\xbe\xb8", "\xc3\x9f.\xf0\x90\x8b\xb3\xe2\xb4\x8c\xe0\xbe\xb8"); }
test { try toAsciiPass("\xc3\x9f\xef\xbd\xa1\xf0\x90\x8b\xb3\xe1\x82\xac\xe0\xbe\xb8", "xn--zca.xn--lgd921mvv0m", false); }
test { try toAsciiPass("\xc3\x9f\xef\xbd\xa1\xf0\x90\x8b\xb3\xe1\x82\xac\xe0\xbe\xb8", "ss.xn--lgd921mvv0m", true); }
test { try toUnicodePass("\xc3\x9f\xe3\x80\x82\xf0\x90\x8b\xb3\xe1\x82\xac\xe0\xbe\xb8", "\xc3\x9f.\xf0\x90\x8b\xb3\xe2\xb4\x8c\xe0\xbe\xb8"); }
test { try toAsciiPass("\xc3\x9f\xe3\x80\x82\xf0\x90\x8b\xb3\xe1\x82\xac\xe0\xbe\xb8", "xn--zca.xn--lgd921mvv0m", false); }
test { try toAsciiPass("\xc3\x9f\xe3\x80\x82\xf0\x90\x8b\xb3\xe1\x82\xac\xe0\xbe\xb8", "ss.xn--lgd921mvv0m", true); }
test { try toUnicodePass("\xc3\x9f\xe3\x80\x82\xf0\x90\x8b\xb3\xe2\xb4\x8c\xe0\xbe\xb8", "\xc3\x9f.\xf0\x90\x8b\xb3\xe2\xb4\x8c\xe0\xbe\xb8"); }
test { try toAsciiPass("\xc3\x9f\xe3\x80\x82\xf0\x90\x8b\xb3\xe2\xb4\x8c\xe0\xbe\xb8", "xn--zca.xn--lgd921mvv0m", false); }
test { try toAsciiPass("\xc3\x9f\xe3\x80\x82\xf0\x90\x8b\xb3\xe2\xb4\x8c\xe0\xbe\xb8", "ss.xn--lgd921mvv0m", true); }
test { try toUnicodePass("SS\xe3\x80\x82\xf0\x90\x8b\xb3\xe1\x82\xac\xe0\xbe\xb8", "ss.\xf0\x90\x8b\xb3\xe2\xb4\x8c\xe0\xbe\xb8"); }
test { try toAsciiPass("SS\xe3\x80\x82\xf0\x90\x8b\xb3\xe1\x82\xac\xe0\xbe\xb8", "ss.xn--lgd921mvv0m", false); }
test { try toAsciiPass("SS\xe3\x80\x82\xf0\x90\x8b\xb3\xe1\x82\xac\xe0\xbe\xb8", "ss.xn--lgd921mvv0m", true); }
test { try toUnicodePass("ss\xe3\x80\x82\xf0\x90\x8b\xb3\xe2\xb4\x8c\xe0\xbe\xb8", "ss.\xf0\x90\x8b\xb3\xe2\xb4\x8c\xe0\xbe\xb8"); }
test { try toAsciiPass("ss\xe3\x80\x82\xf0\x90\x8b\xb3\xe2\xb4\x8c\xe0\xbe\xb8", "ss.xn--lgd921mvv0m", false); }
test { try toAsciiPass("ss\xe3\x80\x82\xf0\x90\x8b\xb3\xe2\xb4\x8c\xe0\xbe\xb8", "ss.xn--lgd921mvv0m", true); }
test { try toUnicodePass("Ss\xe3\x80\x82\xf0\x90\x8b\xb3\xe1\x82\xac\xe0\xbe\xb8", "ss.\xf0\x90\x8b\xb3\xe2\xb4\x8c\xe0\xbe\xb8"); }
test { try toAsciiPass("Ss\xe3\x80\x82\xf0\x90\x8b\xb3\xe1\x82\xac\xe0\xbe\xb8", "ss.xn--lgd921mvv0m", false); }
test { try toAsciiPass("Ss\xe3\x80\x82\xf0\x90\x8b\xb3\xe1\x82\xac\xe0\xbe\xb8", "ss.xn--lgd921mvv0m", true); }
test { try toUnicodePass("ss.xn--lgd921mvv0m", "ss.\xf0\x90\x8b\xb3\xe2\xb4\x8c\xe0\xbe\xb8"); }
test { try toAsciiPass("ss.xn--lgd921mvv0m", "ss.xn--lgd921mvv0m", false); }
test { try toAsciiPass("ss.xn--lgd921mvv0m", "ss.xn--lgd921mvv0m", true); }
test { try toUnicodePass("ss.\xf0\x90\x8b\xb3\xe2\xb4\x8c\xe0\xbe\xb8", "ss.\xf0\x90\x8b\xb3\xe2\xb4\x8c\xe0\xbe\xb8"); }
test { try toAsciiPass("ss.\xf0\x90\x8b\xb3\xe2\xb4\x8c\xe0\xbe\xb8", "ss.xn--lgd921mvv0m", false); }
test { try toAsciiPass("ss.\xf0\x90\x8b\xb3\xe2\xb4\x8c\xe0\xbe\xb8", "ss.xn--lgd921mvv0m", true); }
test { try toUnicodePass("SS.\xf0\x90\x8b\xb3\xe1\x82\xac\xe0\xbe\xb8", "ss.\xf0\x90\x8b\xb3\xe2\xb4\x8c\xe0\xbe\xb8"); }
test { try toAsciiPass("SS.\xf0\x90\x8b\xb3\xe1\x82\xac\xe0\xbe\xb8", "ss.xn--lgd921mvv0m", false); }
test { try toAsciiPass("SS.\xf0\x90\x8b\xb3\xe1\x82\xac\xe0\xbe\xb8", "ss.xn--lgd921mvv0m", true); }
test { try toUnicodePass("Ss.\xf0\x90\x8b\xb3\xe1\x82\xac\xe0\xbe\xb8", "ss.\xf0\x90\x8b\xb3\xe2\xb4\x8c\xe0\xbe\xb8"); }
test { try toAsciiPass("Ss.\xf0\x90\x8b\xb3\xe1\x82\xac\xe0\xbe\xb8", "ss.xn--lgd921mvv0m", false); }
test { try toAsciiPass("Ss.\xf0\x90\x8b\xb3\xe1\x82\xac\xe0\xbe\xb8", "ss.xn--lgd921mvv0m", true); }
test { try toUnicodePass("xn--zca.xn--lgd921mvv0m", "\xc3\x9f.\xf0\x90\x8b\xb3\xe2\xb4\x8c\xe0\xbe\xb8"); }
test { try toAsciiPass("xn--zca.xn--lgd921mvv0m", "xn--zca.xn--lgd921mvv0m", false); }
test { try toAsciiPass("xn--zca.xn--lgd921mvv0m", "xn--zca.xn--lgd921mvv0m", true); }
test { try toUnicodePass("\xc3\x9f.\xf0\x90\x8b\xb3\xe2\xb4\x8c\xe0\xbe\xb8", "\xc3\x9f.\xf0\x90\x8b\xb3\xe2\xb4\x8c\xe0\xbe\xb8"); }
test { try toAsciiPass("\xc3\x9f.\xf0\x90\x8b\xb3\xe2\xb4\x8c\xe0\xbe\xb8", "xn--zca.xn--lgd921mvv0m", false); }
test { try toAsciiPass("\xc3\x9f.\xf0\x90\x8b\xb3\xe2\xb4\x8c\xe0\xbe\xb8", "ss.xn--lgd921mvv0m", true); }
test { try toUnicodePass("\xc3\x9f\xef\xbd\xa1\xf0\x90\x8b\xb3\xe2\xb4\x8c\xe0\xbe\xb8", "\xc3\x9f.\xf0\x90\x8b\xb3\xe2\xb4\x8c\xe0\xbe\xb8"); }
test { try toAsciiPass("\xc3\x9f\xef\xbd\xa1\xf0\x90\x8b\xb3\xe2\xb4\x8c\xe0\xbe\xb8", "xn--zca.xn--lgd921mvv0m", false); }
test { try toAsciiPass("\xc3\x9f\xef\xbd\xa1\xf0\x90\x8b\xb3\xe2\xb4\x8c\xe0\xbe\xb8", "ss.xn--lgd921mvv0m", true); }
test { try toUnicodePass("SS\xef\xbd\xa1\xf0\x90\x8b\xb3\xe1\x82\xac\xe0\xbe\xb8", "ss.\xf0\x90\x8b\xb3\xe2\xb4\x8c\xe0\xbe\xb8"); }
test { try toAsciiPass("SS\xef\xbd\xa1\xf0\x90\x8b\xb3\xe1\x82\xac\xe0\xbe\xb8", "ss.xn--lgd921mvv0m", false); }
test { try toAsciiPass("SS\xef\xbd\xa1\xf0\x90\x8b\xb3\xe1\x82\xac\xe0\xbe\xb8", "ss.xn--lgd921mvv0m", true); }
test { try toUnicodePass("ss\xef\xbd\xa1\xf0\x90\x8b\xb3\xe2\xb4\x8c\xe0\xbe\xb8", "ss.\xf0\x90\x8b\xb3\xe2\xb4\x8c\xe0\xbe\xb8"); }
test { try toAsciiPass("ss\xef\xbd\xa1\xf0\x90\x8b\xb3\xe2\xb4\x8c\xe0\xbe\xb8", "ss.xn--lgd921mvv0m", false); }
test { try toAsciiPass("ss\xef\xbd\xa1\xf0\x90\x8b\xb3\xe2\xb4\x8c\xe0\xbe\xb8", "ss.xn--lgd921mvv0m", true); }
test { try toUnicodePass("Ss\xef\xbd\xa1\xf0\x90\x8b\xb3\xe1\x82\xac\xe0\xbe\xb8", "ss.\xf0\x90\x8b\xb3\xe2\xb4\x8c\xe0\xbe\xb8"); }
test { try toAsciiPass("Ss\xef\xbd\xa1\xf0\x90\x8b\xb3\xe1\x82\xac\xe0\xbe\xb8", "ss.xn--lgd921mvv0m", false); }
test { try toAsciiPass("Ss\xef\xbd\xa1\xf0\x90\x8b\xb3\xe1\x82\xac\xe0\xbe\xb8", "ss.xn--lgd921mvv0m", true); }
test { try toUnicodePass("\xe1\x9a\xad\xef\xbd\xa1\xf0\x9d\x8c\xa0\xc3\x9f\xf0\x96\xab\xb1", "\xe1\x9a\xad.\xf0\x9d\x8c\xa0\xc3\x9f\xf0\x96\xab\xb1"); }
test { try toAsciiPass("\xe1\x9a\xad\xef\xbd\xa1\xf0\x9d\x8c\xa0\xc3\x9f\xf0\x96\xab\xb1", "xn--hwe.xn--zca4946pblnc", false); }
test { try toAsciiPass("\xe1\x9a\xad\xef\xbd\xa1\xf0\x9d\x8c\xa0\xc3\x9f\xf0\x96\xab\xb1", "xn--hwe.xn--ss-ci1ub261a", true); }
test { try toUnicodePass("\xe1\x9a\xad\xe3\x80\x82\xf0\x9d\x8c\xa0\xc3\x9f\xf0\x96\xab\xb1", "\xe1\x9a\xad.\xf0\x9d\x8c\xa0\xc3\x9f\xf0\x96\xab\xb1"); }
test { try toAsciiPass("\xe1\x9a\xad\xe3\x80\x82\xf0\x9d\x8c\xa0\xc3\x9f\xf0\x96\xab\xb1", "xn--hwe.xn--zca4946pblnc", false); }
test { try toAsciiPass("\xe1\x9a\xad\xe3\x80\x82\xf0\x9d\x8c\xa0\xc3\x9f\xf0\x96\xab\xb1", "xn--hwe.xn--ss-ci1ub261a", true); }
test { try toUnicodePass("\xe1\x9a\xad\xe3\x80\x82\xf0\x9d\x8c\xa0SS\xf0\x96\xab\xb1", "\xe1\x9a\xad.\xf0\x9d\x8c\xa0ss\xf0\x96\xab\xb1"); }
test { try toAsciiPass("\xe1\x9a\xad\xe3\x80\x82\xf0\x9d\x8c\xa0SS\xf0\x96\xab\xb1", "xn--hwe.xn--ss-ci1ub261a", false); }
test { try toAsciiPass("\xe1\x9a\xad\xe3\x80\x82\xf0\x9d\x8c\xa0SS\xf0\x96\xab\xb1", "xn--hwe.xn--ss-ci1ub261a", true); }
test { try toUnicodePass("\xe1\x9a\xad\xe3\x80\x82\xf0\x9d\x8c\xa0ss\xf0\x96\xab\xb1", "\xe1\x9a\xad.\xf0\x9d\x8c\xa0ss\xf0\x96\xab\xb1"); }
test { try toAsciiPass("\xe1\x9a\xad\xe3\x80\x82\xf0\x9d\x8c\xa0ss\xf0\x96\xab\xb1", "xn--hwe.xn--ss-ci1ub261a", false); }
test { try toAsciiPass("\xe1\x9a\xad\xe3\x80\x82\xf0\x9d\x8c\xa0ss\xf0\x96\xab\xb1", "xn--hwe.xn--ss-ci1ub261a", true); }
test { try toUnicodePass("\xe1\x9a\xad\xe3\x80\x82\xf0\x9d\x8c\xa0Ss\xf0\x96\xab\xb1", "\xe1\x9a\xad.\xf0\x9d\x8c\xa0ss\xf0\x96\xab\xb1"); }
test { try toAsciiPass("\xe1\x9a\xad\xe3\x80\x82\xf0\x9d\x8c\xa0Ss\xf0\x96\xab\xb1", "xn--hwe.xn--ss-ci1ub261a", false); }
test { try toAsciiPass("\xe1\x9a\xad\xe3\x80\x82\xf0\x9d\x8c\xa0Ss\xf0\x96\xab\xb1", "xn--hwe.xn--ss-ci1ub261a", true); }
test { try toUnicodePass("xn--hwe.xn--ss-ci1ub261a", "\xe1\x9a\xad.\xf0\x9d\x8c\xa0ss\xf0\x96\xab\xb1"); }
test { try toAsciiPass("xn--hwe.xn--ss-ci1ub261a", "xn--hwe.xn--ss-ci1ub261a", false); }
test { try toAsciiPass("xn--hwe.xn--ss-ci1ub261a", "xn--hwe.xn--ss-ci1ub261a", true); }
test { try toUnicodePass("\xe1\x9a\xad.\xf0\x9d\x8c\xa0ss\xf0\x96\xab\xb1", "\xe1\x9a\xad.\xf0\x9d\x8c\xa0ss\xf0\x96\xab\xb1"); }
test { try toAsciiPass("\xe1\x9a\xad.\xf0\x9d\x8c\xa0ss\xf0\x96\xab\xb1", "xn--hwe.xn--ss-ci1ub261a", false); }
test { try toAsciiPass("\xe1\x9a\xad.\xf0\x9d\x8c\xa0ss\xf0\x96\xab\xb1", "xn--hwe.xn--ss-ci1ub261a", true); }
test { try toUnicodePass("\xe1\x9a\xad.\xf0\x9d\x8c\xa0SS\xf0\x96\xab\xb1", "\xe1\x9a\xad.\xf0\x9d\x8c\xa0ss\xf0\x96\xab\xb1"); }
test { try toAsciiPass("\xe1\x9a\xad.\xf0\x9d\x8c\xa0SS\xf0\x96\xab\xb1", "xn--hwe.xn--ss-ci1ub261a", false); }
test { try toAsciiPass("\xe1\x9a\xad.\xf0\x9d\x8c\xa0SS\xf0\x96\xab\xb1", "xn--hwe.xn--ss-ci1ub261a", true); }
test { try toUnicodePass("\xe1\x9a\xad.\xf0\x9d\x8c\xa0Ss\xf0\x96\xab\xb1", "\xe1\x9a\xad.\xf0\x9d\x8c\xa0ss\xf0\x96\xab\xb1"); }
test { try toAsciiPass("\xe1\x9a\xad.\xf0\x9d\x8c\xa0Ss\xf0\x96\xab\xb1", "xn--hwe.xn--ss-ci1ub261a", false); }
test { try toAsciiPass("\xe1\x9a\xad.\xf0\x9d\x8c\xa0Ss\xf0\x96\xab\xb1", "xn--hwe.xn--ss-ci1ub261a", true); }
test { try toUnicodePass("xn--hwe.xn--zca4946pblnc", "\xe1\x9a\xad.\xf0\x9d\x8c\xa0\xc3\x9f\xf0\x96\xab\xb1"); }
test { try toAsciiPass("xn--hwe.xn--zca4946pblnc", "xn--hwe.xn--zca4946pblnc", false); }
test { try toAsciiPass("xn--hwe.xn--zca4946pblnc", "xn--hwe.xn--zca4946pblnc", true); }
test { try toUnicodePass("\xe1\x9a\xad.\xf0\x9d\x8c\xa0\xc3\x9f\xf0\x96\xab\xb1", "\xe1\x9a\xad.\xf0\x9d\x8c\xa0\xc3\x9f\xf0\x96\xab\xb1"); }
test { try toAsciiPass("\xe1\x9a\xad.\xf0\x9d\x8c\xa0\xc3\x9f\xf0\x96\xab\xb1", "xn--hwe.xn--zca4946pblnc", false); }
test { try toAsciiPass("\xe1\x9a\xad.\xf0\x9d\x8c\xa0\xc3\x9f\xf0\x96\xab\xb1", "xn--hwe.xn--ss-ci1ub261a", true); }
test { try toUnicodePass("\xe1\x9a\xad\xef\xbd\xa1\xf0\x9d\x8c\xa0SS\xf0\x96\xab\xb1", "\xe1\x9a\xad.\xf0\x9d\x8c\xa0ss\xf0\x96\xab\xb1"); }
test { try toAsciiPass("\xe1\x9a\xad\xef\xbd\xa1\xf0\x9d\x8c\xa0SS\xf0\x96\xab\xb1", "xn--hwe.xn--ss-ci1ub261a", false); }
test { try toAsciiPass("\xe1\x9a\xad\xef\xbd\xa1\xf0\x9d\x8c\xa0SS\xf0\x96\xab\xb1", "xn--hwe.xn--ss-ci1ub261a", true); }
test { try toUnicodePass("\xe1\x9a\xad\xef\xbd\xa1\xf0\x9d\x8c\xa0ss\xf0\x96\xab\xb1", "\xe1\x9a\xad.\xf0\x9d\x8c\xa0ss\xf0\x96\xab\xb1"); }
test { try toAsciiPass("\xe1\x9a\xad\xef\xbd\xa1\xf0\x9d\x8c\xa0ss\xf0\x96\xab\xb1", "xn--hwe.xn--ss-ci1ub261a", false); }
test { try toAsciiPass("\xe1\x9a\xad\xef\xbd\xa1\xf0\x9d\x8c\xa0ss\xf0\x96\xab\xb1", "xn--hwe.xn--ss-ci1ub261a", true); }
test { try toUnicodePass("\xe1\x9a\xad\xef\xbd\xa1\xf0\x9d\x8c\xa0Ss\xf0\x96\xab\xb1", "\xe1\x9a\xad.\xf0\x9d\x8c\xa0ss\xf0\x96\xab\xb1"); }
test { try toAsciiPass("\xe1\x9a\xad\xef\xbd\xa1\xf0\x9d\x8c\xa0Ss\xf0\x96\xab\xb1", "xn--hwe.xn--ss-ci1ub261a", false); }
test { try toAsciiPass("\xe1\x9a\xad\xef\xbd\xa1\xf0\x9d\x8c\xa0Ss\xf0\x96\xab\xb1", "xn--hwe.xn--ss-ci1ub261a", true); }
test { try toUnicodePass("\xf0\x9e\xa5\x93\xef\xbc\x8e\xdc\x98", "\xf0\x9e\xa5\x93.\xdc\x98"); }
test { try toAsciiPass("\xf0\x9e\xa5\x93\xef\xbc\x8e\xdc\x98", "xn--of6h.xn--inb", false); }
test { try toAsciiPass("\xf0\x9e\xa5\x93\xef\xbc\x8e\xdc\x98", "xn--of6h.xn--inb", true); }
test { try toUnicodePass("\xf0\x9e\xa5\x93.\xdc\x98", "\xf0\x9e\xa5\x93.\xdc\x98"); }
test { try toAsciiPass("\xf0\x9e\xa5\x93.\xdc\x98", "xn--of6h.xn--inb", false); }
test { try toAsciiPass("\xf0\x9e\xa5\x93.\xdc\x98", "xn--of6h.xn--inb", true); }
test { try toUnicodePass("xn--of6h.xn--inb", "\xf0\x9e\xa5\x93.\xdc\x98"); }
test { try toAsciiPass("xn--of6h.xn--inb", "xn--of6h.xn--inb", false); }
test { try toAsciiPass("xn--of6h.xn--inb", "xn--of6h.xn--inb", true); }
test { try toUnicodePass("\xe1\x82\xba\xf0\x90\x8b\xb8\xf3\xa0\x84\x84\xe3\x80\x82\xf0\x9d\x9f\x9d\xed\x9f\xb6\xe1\x80\xba", "\xe2\xb4\x9a\xf0\x90\x8b\xb8.5\xed\x9f\xb6\xe1\x80\xba"); }
test { try toAsciiPass("\xe1\x82\xba\xf0\x90\x8b\xb8\xf3\xa0\x84\x84\xe3\x80\x82\xf0\x9d\x9f\x9d\xed\x9f\xb6\xe1\x80\xba", "xn--ilj2659d.xn--5-dug9054m", false); }
test { try toAsciiPass("\xe1\x82\xba\xf0\x90\x8b\xb8\xf3\xa0\x84\x84\xe3\x80\x82\xf0\x9d\x9f\x9d\xed\x9f\xb6\xe1\x80\xba", "xn--ilj2659d.xn--5-dug9054m", true); }
test { try toUnicodePass("\xe1\x82\xba\xf0\x90\x8b\xb8\xf3\xa0\x84\x84\xe3\x80\x825\xed\x9f\xb6\xe1\x80\xba", "\xe2\xb4\x9a\xf0\x90\x8b\xb8.5\xed\x9f\xb6\xe1\x80\xba"); }
test { try toAsciiPass("\xe1\x82\xba\xf0\x90\x8b\xb8\xf3\xa0\x84\x84\xe3\x80\x825\xed\x9f\xb6\xe1\x80\xba", "xn--ilj2659d.xn--5-dug9054m", false); }
test { try toAsciiPass("\xe1\x82\xba\xf0\x90\x8b\xb8\xf3\xa0\x84\x84\xe3\x80\x825\xed\x9f\xb6\xe1\x80\xba", "xn--ilj2659d.xn--5-dug9054m", true); }
test { try toUnicodePass("\xe2\xb4\x9a\xf0\x90\x8b\xb8\xf3\xa0\x84\x84\xe3\x80\x825\xed\x9f\xb6\xe1\x80\xba", "\xe2\xb4\x9a\xf0\x90\x8b\xb8.5\xed\x9f\xb6\xe1\x80\xba"); }
test { try toAsciiPass("\xe2\xb4\x9a\xf0\x90\x8b\xb8\xf3\xa0\x84\x84\xe3\x80\x825\xed\x9f\xb6\xe1\x80\xba", "xn--ilj2659d.xn--5-dug9054m", false); }
test { try toAsciiPass("\xe2\xb4\x9a\xf0\x90\x8b\xb8\xf3\xa0\x84\x84\xe3\x80\x825\xed\x9f\xb6\xe1\x80\xba", "xn--ilj2659d.xn--5-dug9054m", true); }
test { try toUnicodePass("xn--ilj2659d.xn--5-dug9054m", "\xe2\xb4\x9a\xf0\x90\x8b\xb8.5\xed\x9f\xb6\xe1\x80\xba"); }
test { try toAsciiPass("xn--ilj2659d.xn--5-dug9054m", "xn--ilj2659d.xn--5-dug9054m", false); }
test { try toAsciiPass("xn--ilj2659d.xn--5-dug9054m", "xn--ilj2659d.xn--5-dug9054m", true); }
test { try toUnicodePass("\xe2\xb4\x9a\xf0\x90\x8b\xb8.5\xed\x9f\xb6\xe1\x80\xba", "\xe2\xb4\x9a\xf0\x90\x8b\xb8.5\xed\x9f\xb6\xe1\x80\xba"); }
test { try toAsciiPass("\xe2\xb4\x9a\xf0\x90\x8b\xb8.5\xed\x9f\xb6\xe1\x80\xba", "xn--ilj2659d.xn--5-dug9054m", false); }
test { try toAsciiPass("\xe2\xb4\x9a\xf0\x90\x8b\xb8.5\xed\x9f\xb6\xe1\x80\xba", "xn--ilj2659d.xn--5-dug9054m", true); }
test { try toUnicodePass("\xe1\x82\xba\xf0\x90\x8b\xb8.5\xed\x9f\xb6\xe1\x80\xba", "\xe2\xb4\x9a\xf0\x90\x8b\xb8.5\xed\x9f\xb6\xe1\x80\xba"); }
test { try toAsciiPass("\xe1\x82\xba\xf0\x90\x8b\xb8.5\xed\x9f\xb6\xe1\x80\xba", "xn--ilj2659d.xn--5-dug9054m", false); }
test { try toAsciiPass("\xe1\x82\xba\xf0\x90\x8b\xb8.5\xed\x9f\xb6\xe1\x80\xba", "xn--ilj2659d.xn--5-dug9054m", true); }
test { try toUnicodePass("\xe2\xb4\x9a\xf0\x90\x8b\xb8\xf3\xa0\x84\x84\xe3\x80\x82\xf0\x9d\x9f\x9d\xed\x9f\xb6\xe1\x80\xba", "\xe2\xb4\x9a\xf0\x90\x8b\xb8.5\xed\x9f\xb6\xe1\x80\xba"); }
test { try toAsciiPass("\xe2\xb4\x9a\xf0\x90\x8b\xb8\xf3\xa0\x84\x84\xe3\x80\x82\xf0\x9d\x9f\x9d\xed\x9f\xb6\xe1\x80\xba", "xn--ilj2659d.xn--5-dug9054m", false); }
test { try toAsciiPass("\xe2\xb4\x9a\xf0\x90\x8b\xb8\xf3\xa0\x84\x84\xe3\x80\x82\xf0\x9d\x9f\x9d\xed\x9f\xb6\xe1\x80\xba", "xn--ilj2659d.xn--5-dug9054m", true); }
test { try toUnicodePass("\xe2\x89\xa0.\xe1\xa0\xbf", "\xe2\x89\xa0.\xe1\xa0\xbf"); }
test { try toAsciiPass("\xe2\x89\xa0.\xe1\xa0\xbf", "xn--1ch.xn--y7e", false); }
test { try toAsciiPass("\xe2\x89\xa0.\xe1\xa0\xbf", "xn--1ch.xn--y7e", true); }
test { try toUnicodePass("=\xcc\xb8.\xe1\xa0\xbf", "\xe2\x89\xa0.\xe1\xa0\xbf"); }
test { try toAsciiPass("=\xcc\xb8.\xe1\xa0\xbf", "xn--1ch.xn--y7e", false); }
test { try toAsciiPass("=\xcc\xb8.\xe1\xa0\xbf", "xn--1ch.xn--y7e", true); }
test { try toUnicodePass("xn--1ch.xn--y7e", "\xe2\x89\xa0.\xe1\xa0\xbf"); }
test { try toAsciiPass("xn--1ch.xn--y7e", "xn--1ch.xn--y7e", false); }
test { try toAsciiPass("xn--1ch.xn--y7e", "xn--1ch.xn--y7e", true); }
test { try toUnicodePass("\xdc\xa3\xd6\xa3\xef\xbd\xa1\xe3\x8c\xaa", "\xdc\xa3\xd6\xa3.\xe3\x83\x8f\xe3\x82\xa4\xe3\x83\x84"); }
test { try toAsciiPass("\xdc\xa3\xd6\xa3\xef\xbd\xa1\xe3\x8c\xaa", "xn--ucb18e.xn--eck4c5a", false); }
test { try toAsciiPass("\xdc\xa3\xd6\xa3\xef\xbd\xa1\xe3\x8c\xaa", "xn--ucb18e.xn--eck4c5a", true); }
test { try toUnicodePass("\xdc\xa3\xd6\xa3\xe3\x80\x82\xe3\x83\x8f\xe3\x82\xa4\xe3\x83\x84", "\xdc\xa3\xd6\xa3.\xe3\x83\x8f\xe3\x82\xa4\xe3\x83\x84"); }
test { try toAsciiPass("\xdc\xa3\xd6\xa3\xe3\x80\x82\xe3\x83\x8f\xe3\x82\xa4\xe3\x83\x84", "xn--ucb18e.xn--eck4c5a", false); }
test { try toAsciiPass("\xdc\xa3\xd6\xa3\xe3\x80\x82\xe3\x83\x8f\xe3\x82\xa4\xe3\x83\x84", "xn--ucb18e.xn--eck4c5a", true); }
test { try toUnicodePass("xn--ucb18e.xn--eck4c5a", "\xdc\xa3\xd6\xa3.\xe3\x83\x8f\xe3\x82\xa4\xe3\x83\x84"); }
test { try toAsciiPass("xn--ucb18e.xn--eck4c5a", "xn--ucb18e.xn--eck4c5a", false); }
test { try toAsciiPass("xn--ucb18e.xn--eck4c5a", "xn--ucb18e.xn--eck4c5a", true); }
test { try toUnicodePass("\xdc\xa3\xd6\xa3.\xe3\x83\x8f\xe3\x82\xa4\xe3\x83\x84", "\xdc\xa3\xd6\xa3.\xe3\x83\x8f\xe3\x82\xa4\xe3\x83\x84"); }
test { try toAsciiPass("\xdc\xa3\xd6\xa3.\xe3\x83\x8f\xe3\x82\xa4\xe3\x83\x84", "xn--ucb18e.xn--eck4c5a", false); }
test { try toAsciiPass("\xdc\xa3\xd6\xa3.\xe3\x83\x8f\xe3\x82\xa4\xe3\x83\x84", "xn--ucb18e.xn--eck4c5a", true); }
test { try toUnicodePass("xn--skb", "\xda\xb9"); }
test { try toAsciiPass("xn--skb", "xn--skb", false); }
test { try toAsciiPass("xn--skb", "xn--skb", true); }
test { try toUnicodePass("\xda\xb9", "\xda\xb9"); }
test { try toAsciiPass("\xda\xb9", "xn--skb", false); }
test { try toAsciiPass("\xda\xb9", "xn--skb", true); }
test { try toUnicodePass("\xc3\x9f\xe0\xa7\x81\xe1\xb7\xad\xe3\x80\x82\xd8\xa08\xe2\x82\x85", "\xc3\x9f\xe0\xa7\x81\xe1\xb7\xad.\xd8\xa085"); }
test { try toAsciiPass("\xc3\x9f\xe0\xa7\x81\xe1\xb7\xad\xe3\x80\x82\xd8\xa08\xe2\x82\x85", "xn--zca266bwrr.xn--85-psd", false); }
test { try toAsciiPass("\xc3\x9f\xe0\xa7\x81\xe1\xb7\xad\xe3\x80\x82\xd8\xa08\xe2\x82\x85", "xn--ss-e2f077r.xn--85-psd", true); }
test { try toUnicodePass("\xc3\x9f\xe0\xa7\x81\xe1\xb7\xad\xe3\x80\x82\xd8\xa085", "\xc3\x9f\xe0\xa7\x81\xe1\xb7\xad.\xd8\xa085"); }
test { try toAsciiPass("\xc3\x9f\xe0\xa7\x81\xe1\xb7\xad\xe3\x80\x82\xd8\xa085", "xn--zca266bwrr.xn--85-psd", false); }
test { try toAsciiPass("\xc3\x9f\xe0\xa7\x81\xe1\xb7\xad\xe3\x80\x82\xd8\xa085", "xn--ss-e2f077r.xn--85-psd", true); }
test { try toUnicodePass("SS\xe0\xa7\x81\xe1\xb7\xad\xe3\x80\x82\xd8\xa085", "ss\xe0\xa7\x81\xe1\xb7\xad.\xd8\xa085"); }
test { try toAsciiPass("SS\xe0\xa7\x81\xe1\xb7\xad\xe3\x80\x82\xd8\xa085", "xn--ss-e2f077r.xn--85-psd", false); }
test { try toAsciiPass("SS\xe0\xa7\x81\xe1\xb7\xad\xe3\x80\x82\xd8\xa085", "xn--ss-e2f077r.xn--85-psd", true); }
test { try toUnicodePass("ss\xe0\xa7\x81\xe1\xb7\xad\xe3\x80\x82\xd8\xa085", "ss\xe0\xa7\x81\xe1\xb7\xad.\xd8\xa085"); }
test { try toAsciiPass("ss\xe0\xa7\x81\xe1\xb7\xad\xe3\x80\x82\xd8\xa085", "xn--ss-e2f077r.xn--85-psd", false); }
test { try toAsciiPass("ss\xe0\xa7\x81\xe1\xb7\xad\xe3\x80\x82\xd8\xa085", "xn--ss-e2f077r.xn--85-psd", true); }
test { try toUnicodePass("Ss\xe0\xa7\x81\xe1\xb7\xad\xe3\x80\x82\xd8\xa085", "ss\xe0\xa7\x81\xe1\xb7\xad.\xd8\xa085"); }
test { try toAsciiPass("Ss\xe0\xa7\x81\xe1\xb7\xad\xe3\x80\x82\xd8\xa085", "xn--ss-e2f077r.xn--85-psd", false); }
test { try toAsciiPass("Ss\xe0\xa7\x81\xe1\xb7\xad\xe3\x80\x82\xd8\xa085", "xn--ss-e2f077r.xn--85-psd", true); }
test { try toUnicodePass("xn--ss-e2f077r.xn--85-psd", "ss\xe0\xa7\x81\xe1\xb7\xad.\xd8\xa085"); }
test { try toAsciiPass("xn--ss-e2f077r.xn--85-psd", "xn--ss-e2f077r.xn--85-psd", false); }
test { try toAsciiPass("xn--ss-e2f077r.xn--85-psd", "xn--ss-e2f077r.xn--85-psd", true); }
test { try toUnicodePass("ss\xe0\xa7\x81\xe1\xb7\xad.\xd8\xa085", "ss\xe0\xa7\x81\xe1\xb7\xad.\xd8\xa085"); }
test { try toAsciiPass("ss\xe0\xa7\x81\xe1\xb7\xad.\xd8\xa085", "xn--ss-e2f077r.xn--85-psd", false); }
test { try toAsciiPass("ss\xe0\xa7\x81\xe1\xb7\xad.\xd8\xa085", "xn--ss-e2f077r.xn--85-psd", true); }
test { try toUnicodePass("SS\xe0\xa7\x81\xe1\xb7\xad.\xd8\xa085", "ss\xe0\xa7\x81\xe1\xb7\xad.\xd8\xa085"); }
test { try toAsciiPass("SS\xe0\xa7\x81\xe1\xb7\xad.\xd8\xa085", "xn--ss-e2f077r.xn--85-psd", false); }
test { try toAsciiPass("SS\xe0\xa7\x81\xe1\xb7\xad.\xd8\xa085", "xn--ss-e2f077r.xn--85-psd", true); }
test { try toUnicodePass("Ss\xe0\xa7\x81\xe1\xb7\xad.\xd8\xa085", "ss\xe0\xa7\x81\xe1\xb7\xad.\xd8\xa085"); }
test { try toAsciiPass("Ss\xe0\xa7\x81\xe1\xb7\xad.\xd8\xa085", "xn--ss-e2f077r.xn--85-psd", false); }
test { try toAsciiPass("Ss\xe0\xa7\x81\xe1\xb7\xad.\xd8\xa085", "xn--ss-e2f077r.xn--85-psd", true); }
test { try toUnicodePass("xn--zca266bwrr.xn--85-psd", "\xc3\x9f\xe0\xa7\x81\xe1\xb7\xad.\xd8\xa085"); }
test { try toAsciiPass("xn--zca266bwrr.xn--85-psd", "xn--zca266bwrr.xn--85-psd", false); }
test { try toAsciiPass("xn--zca266bwrr.xn--85-psd", "xn--zca266bwrr.xn--85-psd", true); }
test { try toUnicodePass("\xc3\x9f\xe0\xa7\x81\xe1\xb7\xad.\xd8\xa085", "\xc3\x9f\xe0\xa7\x81\xe1\xb7\xad.\xd8\xa085"); }
test { try toAsciiPass("\xc3\x9f\xe0\xa7\x81\xe1\xb7\xad.\xd8\xa085", "xn--zca266bwrr.xn--85-psd", false); }
test { try toAsciiPass("\xc3\x9f\xe0\xa7\x81\xe1\xb7\xad.\xd8\xa085", "xn--ss-e2f077r.xn--85-psd", true); }
test { try toUnicodePass("SS\xe0\xa7\x81\xe1\xb7\xad\xe3\x80\x82\xd8\xa08\xe2\x82\x85", "ss\xe0\xa7\x81\xe1\xb7\xad.\xd8\xa085"); }
test { try toAsciiPass("SS\xe0\xa7\x81\xe1\xb7\xad\xe3\x80\x82\xd8\xa08\xe2\x82\x85", "xn--ss-e2f077r.xn--85-psd", false); }
test { try toAsciiPass("SS\xe0\xa7\x81\xe1\xb7\xad\xe3\x80\x82\xd8\xa08\xe2\x82\x85", "xn--ss-e2f077r.xn--85-psd", true); }
test { try toUnicodePass("ss\xe0\xa7\x81\xe1\xb7\xad\xe3\x80\x82\xd8\xa08\xe2\x82\x85", "ss\xe0\xa7\x81\xe1\xb7\xad.\xd8\xa085"); }
test { try toAsciiPass("ss\xe0\xa7\x81\xe1\xb7\xad\xe3\x80\x82\xd8\xa08\xe2\x82\x85", "xn--ss-e2f077r.xn--85-psd", false); }
test { try toAsciiPass("ss\xe0\xa7\x81\xe1\xb7\xad\xe3\x80\x82\xd8\xa08\xe2\x82\x85", "xn--ss-e2f077r.xn--85-psd", true); }
test { try toUnicodePass("Ss\xe0\xa7\x81\xe1\xb7\xad\xe3\x80\x82\xd8\xa08\xe2\x82\x85", "ss\xe0\xa7\x81\xe1\xb7\xad.\xd8\xa085"); }
test { try toAsciiPass("Ss\xe0\xa7\x81\xe1\xb7\xad\xe3\x80\x82\xd8\xa08\xe2\x82\x85", "xn--ss-e2f077r.xn--85-psd", false); }
test { try toAsciiPass("Ss\xe0\xa7\x81\xe1\xb7\xad\xe3\x80\x82\xd8\xa08\xe2\x82\x85", "xn--ss-e2f077r.xn--85-psd", true); }
test { try toUnicodePass("\xef\xb8\x8d\xe0\xaa\x9b\xe3\x80\x82\xe5\xb5\xa8", "\xe0\xaa\x9b.\xe5\xb5\xa8"); }
test { try toAsciiPass("\xef\xb8\x8d\xe0\xaa\x9b\xe3\x80\x82\xe5\xb5\xa8", "xn--6dc.xn--tot", false); }
test { try toAsciiPass("\xef\xb8\x8d\xe0\xaa\x9b\xe3\x80\x82\xe5\xb5\xa8", "xn--6dc.xn--tot", true); }
test { try toUnicodePass("xn--6dc.xn--tot", "\xe0\xaa\x9b.\xe5\xb5\xa8"); }
test { try toAsciiPass("xn--6dc.xn--tot", "xn--6dc.xn--tot", false); }
test { try toAsciiPass("xn--6dc.xn--tot", "xn--6dc.xn--tot", true); }
test { try toUnicodePass("\xe0\xaa\x9b.\xe5\xb5\xa8", "\xe0\xaa\x9b.\xe5\xb5\xa8"); }
test { try toAsciiPass("\xe0\xaa\x9b.\xe5\xb5\xa8", "xn--6dc.xn--tot", false); }
test { try toAsciiPass("\xe0\xaa\x9b.\xe5\xb5\xa8", "xn--6dc.xn--tot", true); }
test { try toUnicodePass("xn--t6f5138v", "\xf0\xa6\x80\xbe\xe1\xb3\xa0"); }
test { try toAsciiPass("xn--t6f5138v", "xn--t6f5138v", false); }
test { try toAsciiPass("xn--t6f5138v", "xn--t6f5138v", true); }
test { try toUnicodePass("\xf0\xa6\x80\xbe\xe1\xb3\xa0", "\xf0\xa6\x80\xbe\xe1\xb3\xa0"); }
test { try toAsciiPass("\xf0\xa6\x80\xbe\xe1\xb3\xa0", "xn--t6f5138v", false); }
test { try toAsciiPass("\xf0\xa6\x80\xbe\xe1\xb3\xa0", "xn--t6f5138v", true); }
test { try toAsciiPass("\xe1\xa1\x99\xe2\x80\x8c\xef\xbd\xa1\xe2\x89\xaf\xf0\x90\x8b\xb2\xe2\x89\xa0", "xn--p8e.xn--1ch3a7084l", true); }
test { try toAsciiPass("\xe1\xa1\x99\xe2\x80\x8c\xef\xbd\xa1>\xcc\xb8\xf0\x90\x8b\xb2=\xcc\xb8", "xn--p8e.xn--1ch3a7084l", true); }
test { try toAsciiPass("\xe1\xa1\x99\xe2\x80\x8c\xe3\x80\x82\xe2\x89\xaf\xf0\x90\x8b\xb2\xe2\x89\xa0", "xn--p8e.xn--1ch3a7084l", true); }
test { try toAsciiPass("\xe1\xa1\x99\xe2\x80\x8c\xe3\x80\x82>\xcc\xb8\xf0\x90\x8b\xb2=\xcc\xb8", "xn--p8e.xn--1ch3a7084l", true); }
test { try toUnicodePass("xn--p8e.xn--1ch3a7084l", "\xe1\xa1\x99.\xe2\x89\xaf\xf0\x90\x8b\xb2\xe2\x89\xa0"); }
test { try toAsciiPass("xn--p8e.xn--1ch3a7084l", "xn--p8e.xn--1ch3a7084l", false); }
test { try toAsciiPass("xn--p8e.xn--1ch3a7084l", "xn--p8e.xn--1ch3a7084l", true); }
test { try toUnicodePass("\xe1\xa1\x99.\xe2\x89\xaf\xf0\x90\x8b\xb2\xe2\x89\xa0", "\xe1\xa1\x99.\xe2\x89\xaf\xf0\x90\x8b\xb2\xe2\x89\xa0"); }
test { try toAsciiPass("\xe1\xa1\x99.\xe2\x89\xaf\xf0\x90\x8b\xb2\xe2\x89\xa0", "xn--p8e.xn--1ch3a7084l", false); }
test { try toAsciiPass("\xe1\xa1\x99.\xe2\x89\xaf\xf0\x90\x8b\xb2\xe2\x89\xa0", "xn--p8e.xn--1ch3a7084l", true); }
test { try toUnicodePass("\xe1\xa1\x99.>\xcc\xb8\xf0\x90\x8b\xb2=\xcc\xb8", "\xe1\xa1\x99.\xe2\x89\xaf\xf0\x90\x8b\xb2\xe2\x89\xa0"); }
test { try toAsciiPass("\xe1\xa1\x99.>\xcc\xb8\xf0\x90\x8b\xb2=\xcc\xb8", "xn--p8e.xn--1ch3a7084l", false); }
test { try toAsciiPass("\xe1\xa1\x99.>\xcc\xb8\xf0\x90\x8b\xb2=\xcc\xb8", "xn--p8e.xn--1ch3a7084l", true); }
test { try toAsciiPass("\xe2\x84\xb2\xe1\x9f\x92\xe2\x80\x8d\xef\xbd\xa1\xe2\x89\xa0\xe2\x80\x8d\xe2\x80\x8c", "xn--u4e969b.xn--1ch", true); }
test { try toAsciiPass("\xe2\x84\xb2\xe1\x9f\x92\xe2\x80\x8d\xef\xbd\xa1=\xcc\xb8\xe2\x80\x8d\xe2\x80\x8c", "xn--u4e969b.xn--1ch", true); }
test { try toAsciiPass("\xe2\x84\xb2\xe1\x9f\x92\xe2\x80\x8d\xe3\x80\x82\xe2\x89\xa0\xe2\x80\x8d\xe2\x80\x8c", "xn--u4e969b.xn--1ch", true); }
test { try toAsciiPass("\xe2\x84\xb2\xe1\x9f\x92\xe2\x80\x8d\xe3\x80\x82=\xcc\xb8\xe2\x80\x8d\xe2\x80\x8c", "xn--u4e969b.xn--1ch", true); }
test { try toAsciiPass("\xe2\x85\x8e\xe1\x9f\x92\xe2\x80\x8d\xe3\x80\x82=\xcc\xb8\xe2\x80\x8d\xe2\x80\x8c", "xn--u4e969b.xn--1ch", true); }
test { try toAsciiPass("\xe2\x85\x8e\xe1\x9f\x92\xe2\x80\x8d\xe3\x80\x82\xe2\x89\xa0\xe2\x80\x8d\xe2\x80\x8c", "xn--u4e969b.xn--1ch", true); }
test { try toUnicodePass("xn--u4e969b.xn--1ch", "\xe2\x85\x8e\xe1\x9f\x92.\xe2\x89\xa0"); }
test { try toAsciiPass("xn--u4e969b.xn--1ch", "xn--u4e969b.xn--1ch", false); }
test { try toAsciiPass("xn--u4e969b.xn--1ch", "xn--u4e969b.xn--1ch", true); }
test { try toUnicodePass("\xe2\x85\x8e\xe1\x9f\x92.\xe2\x89\xa0", "\xe2\x85\x8e\xe1\x9f\x92.\xe2\x89\xa0"); }
test { try toAsciiPass("\xe2\x85\x8e\xe1\x9f\x92.\xe2\x89\xa0", "xn--u4e969b.xn--1ch", false); }
test { try toAsciiPass("\xe2\x85\x8e\xe1\x9f\x92.\xe2\x89\xa0", "xn--u4e969b.xn--1ch", true); }
test { try toUnicodePass("\xe2\x85\x8e\xe1\x9f\x92.=\xcc\xb8", "\xe2\x85\x8e\xe1\x9f\x92.\xe2\x89\xa0"); }
test { try toAsciiPass("\xe2\x85\x8e\xe1\x9f\x92.=\xcc\xb8", "xn--u4e969b.xn--1ch", false); }
test { try toAsciiPass("\xe2\x85\x8e\xe1\x9f\x92.=\xcc\xb8", "xn--u4e969b.xn--1ch", true); }
test { try toUnicodePass("\xe2\x84\xb2\xe1\x9f\x92.=\xcc\xb8", "\xe2\x85\x8e\xe1\x9f\x92.\xe2\x89\xa0"); }
test { try toAsciiPass("\xe2\x84\xb2\xe1\x9f\x92.=\xcc\xb8", "xn--u4e969b.xn--1ch", false); }
test { try toAsciiPass("\xe2\x84\xb2\xe1\x9f\x92.=\xcc\xb8", "xn--u4e969b.xn--1ch", true); }
test { try toUnicodePass("\xe2\x84\xb2\xe1\x9f\x92.\xe2\x89\xa0", "\xe2\x85\x8e\xe1\x9f\x92.\xe2\x89\xa0"); }
test { try toAsciiPass("\xe2\x84\xb2\xe1\x9f\x92.\xe2\x89\xa0", "xn--u4e969b.xn--1ch", false); }
test { try toAsciiPass("\xe2\x84\xb2\xe1\x9f\x92.\xe2\x89\xa0", "xn--u4e969b.xn--1ch", true); }
test { try toAsciiPass("\xe2\x85\x8e\xe1\x9f\x92\xe2\x80\x8d\xef\xbd\xa1=\xcc\xb8\xe2\x80\x8d\xe2\x80\x8c", "xn--u4e969b.xn--1ch", true); }
test { try toAsciiPass("\xe2\x85\x8e\xe1\x9f\x92\xe2\x80\x8d\xef\xbd\xa1\xe2\x89\xa0\xe2\x80\x8d\xe2\x80\x8c", "xn--u4e969b.xn--1ch", true); }
test { try toUnicodePass("xn--9-mfs8024b.", "9\xe9\x9a\x81\xe2\xaf\xae."); }
test { try toUnicodePass("9\xe9\x9a\x81\xe2\xaf\xae.", "9\xe9\x9a\x81\xe2\xaf\xae."); }
test { try toAsciiPass("\xd9\xbd\xe0\xa5\x83.\xf0\x9e\xa4\x93\xe2\x80\x8d", "xn--2ib43l.xn--te6h", true); }
test { try toAsciiPass("\xd9\xbd\xe0\xa5\x83.\xf0\x9e\xa4\xb5\xe2\x80\x8d", "xn--2ib43l.xn--te6h", true); }
test { try toUnicodePass("xn--2ib43l.xn--te6h", "\xd9\xbd\xe0\xa5\x83.\xf0\x9e\xa4\xb5"); }
test { try toAsciiPass("xn--2ib43l.xn--te6h", "xn--2ib43l.xn--te6h", false); }
test { try toAsciiPass("xn--2ib43l.xn--te6h", "xn--2ib43l.xn--te6h", true); }
test { try toUnicodePass("\xd9\xbd\xe0\xa5\x83.\xf0\x9e\xa4\xb5", "\xd9\xbd\xe0\xa5\x83.\xf0\x9e\xa4\xb5"); }
test { try toAsciiPass("\xd9\xbd\xe0\xa5\x83.\xf0\x9e\xa4\xb5", "xn--2ib43l.xn--te6h", false); }
test { try toAsciiPass("\xd9\xbd\xe0\xa5\x83.\xf0\x9e\xa4\xb5", "xn--2ib43l.xn--te6h", true); }
test { try toUnicodePass("\xd9\xbd\xe0\xa5\x83.\xf0\x9e\xa4\x93", "\xd9\xbd\xe0\xa5\x83.\xf0\x9e\xa4\xb5"); }
test { try toAsciiPass("\xd9\xbd\xe0\xa5\x83.\xf0\x9e\xa4\x93", "xn--2ib43l.xn--te6h", false); }
test { try toAsciiPass("\xd9\xbd\xe0\xa5\x83.\xf0\x9e\xa4\x93", "xn--2ib43l.xn--te6h", true); }
test { try toUnicodePass("\xea\xa7\x90\xd3\x80\xe1\xae\xaa\xe0\xa3\xb6\xef\xbc\x8e\xeb\x88\xb5", "\xea\xa7\x90\xd3\x8f\xe1\xae\xaa\xe0\xa3\xb6.\xeb\x88\xb5"); }
test { try toAsciiPass("\xea\xa7\x90\xd3\x80\xe1\xae\xaa\xe0\xa3\xb6\xef\xbc\x8e\xeb\x88\xb5", "xn--s5a04sn4u297k.xn--2e1b", false); }
test { try toAsciiPass("\xea\xa7\x90\xd3\x80\xe1\xae\xaa\xe0\xa3\xb6\xef\xbc\x8e\xeb\x88\xb5", "xn--s5a04sn4u297k.xn--2e1b", true); }
test { try toUnicodePass("\xea\xa7\x90\xd3\x80\xe1\xae\xaa\xe0\xa3\xb6\xef\xbc\x8e\xe1\x84\x82\xe1\x85\xaf\xe1\x86\xbc", "\xea\xa7\x90\xd3\x8f\xe1\xae\xaa\xe0\xa3\xb6.\xeb\x88\xb5"); }
test { try toAsciiPass("\xea\xa7\x90\xd3\x80\xe1\xae\xaa\xe0\xa3\xb6\xef\xbc\x8e\xe1\x84\x82\xe1\x85\xaf\xe1\x86\xbc", "xn--s5a04sn4u297k.xn--2e1b", false); }
test { try toAsciiPass("\xea\xa7\x90\xd3\x80\xe1\xae\xaa\xe0\xa3\xb6\xef\xbc\x8e\xe1\x84\x82\xe1\x85\xaf\xe1\x86\xbc", "xn--s5a04sn4u297k.xn--2e1b", true); }
test { try toUnicodePass("\xea\xa7\x90\xd3\x80\xe1\xae\xaa\xe0\xa3\xb6.\xeb\x88\xb5", "\xea\xa7\x90\xd3\x8f\xe1\xae\xaa\xe0\xa3\xb6.\xeb\x88\xb5"); }
test { try toAsciiPass("\xea\xa7\x90\xd3\x80\xe1\xae\xaa\xe0\xa3\xb6.\xeb\x88\xb5", "xn--s5a04sn4u297k.xn--2e1b", false); }
test { try toAsciiPass("\xea\xa7\x90\xd3\x80\xe1\xae\xaa\xe0\xa3\xb6.\xeb\x88\xb5", "xn--s5a04sn4u297k.xn--2e1b", true); }
test { try toUnicodePass("\xea\xa7\x90\xd3\x80\xe1\xae\xaa\xe0\xa3\xb6.\xe1\x84\x82\xe1\x85\xaf\xe1\x86\xbc", "\xea\xa7\x90\xd3\x8f\xe1\xae\xaa\xe0\xa3\xb6.\xeb\x88\xb5"); }
test { try toAsciiPass("\xea\xa7\x90\xd3\x80\xe1\xae\xaa\xe0\xa3\xb6.\xe1\x84\x82\xe1\x85\xaf\xe1\x86\xbc", "xn--s5a04sn4u297k.xn--2e1b", false); }
test { try toAsciiPass("\xea\xa7\x90\xd3\x80\xe1\xae\xaa\xe0\xa3\xb6.\xe1\x84\x82\xe1\x85\xaf\xe1\x86\xbc", "xn--s5a04sn4u297k.xn--2e1b", true); }
test { try toUnicodePass("\xea\xa7\x90\xd3\x8f\xe1\xae\xaa\xe0\xa3\xb6.\xe1\x84\x82\xe1\x85\xaf\xe1\x86\xbc", "\xea\xa7\x90\xd3\x8f\xe1\xae\xaa\xe0\xa3\xb6.\xeb\x88\xb5"); }
test { try toAsciiPass("\xea\xa7\x90\xd3\x8f\xe1\xae\xaa\xe0\xa3\xb6.\xe1\x84\x82\xe1\x85\xaf\xe1\x86\xbc", "xn--s5a04sn4u297k.xn--2e1b", false); }
test { try toAsciiPass("\xea\xa7\x90\xd3\x8f\xe1\xae\xaa\xe0\xa3\xb6.\xe1\x84\x82\xe1\x85\xaf\xe1\x86\xbc", "xn--s5a04sn4u297k.xn--2e1b", true); }
test { try toUnicodePass("\xea\xa7\x90\xd3\x8f\xe1\xae\xaa\xe0\xa3\xb6.\xeb\x88\xb5", "\xea\xa7\x90\xd3\x8f\xe1\xae\xaa\xe0\xa3\xb6.\xeb\x88\xb5"); }
test { try toAsciiPass("\xea\xa7\x90\xd3\x8f\xe1\xae\xaa\xe0\xa3\xb6.\xeb\x88\xb5", "xn--s5a04sn4u297k.xn--2e1b", false); }
test { try toAsciiPass("\xea\xa7\x90\xd3\x8f\xe1\xae\xaa\xe0\xa3\xb6.\xeb\x88\xb5", "xn--s5a04sn4u297k.xn--2e1b", true); }
test { try toUnicodePass("xn--s5a04sn4u297k.xn--2e1b", "\xea\xa7\x90\xd3\x8f\xe1\xae\xaa\xe0\xa3\xb6.\xeb\x88\xb5"); }
test { try toAsciiPass("xn--s5a04sn4u297k.xn--2e1b", "xn--s5a04sn4u297k.xn--2e1b", false); }
test { try toAsciiPass("xn--s5a04sn4u297k.xn--2e1b", "xn--s5a04sn4u297k.xn--2e1b", true); }
test { try toUnicodePass("\xea\xa7\x90\xd3\x8f\xe1\xae\xaa\xe0\xa3\xb6\xef\xbc\x8e\xe1\x84\x82\xe1\x85\xaf\xe1\x86\xbc", "\xea\xa7\x90\xd3\x8f\xe1\xae\xaa\xe0\xa3\xb6.\xeb\x88\xb5"); }
test { try toAsciiPass("\xea\xa7\x90\xd3\x8f\xe1\xae\xaa\xe0\xa3\xb6\xef\xbc\x8e\xe1\x84\x82\xe1\x85\xaf\xe1\x86\xbc", "xn--s5a04sn4u297k.xn--2e1b", false); }
test { try toAsciiPass("\xea\xa7\x90\xd3\x8f\xe1\xae\xaa\xe0\xa3\xb6\xef\xbc\x8e\xe1\x84\x82\xe1\x85\xaf\xe1\x86\xbc", "xn--s5a04sn4u297k.xn--2e1b", true); }
test { try toUnicodePass("\xea\xa7\x90\xd3\x8f\xe1\xae\xaa\xe0\xa3\xb6\xef\xbc\x8e\xeb\x88\xb5", "\xea\xa7\x90\xd3\x8f\xe1\xae\xaa\xe0\xa3\xb6.\xeb\x88\xb5"); }
test { try toAsciiPass("\xea\xa7\x90\xd3\x8f\xe1\xae\xaa\xe0\xa3\xb6\xef\xbc\x8e\xeb\x88\xb5", "xn--s5a04sn4u297k.xn--2e1b", false); }
test { try toAsciiPass("\xea\xa7\x90\xd3\x8f\xe1\xae\xaa\xe0\xa3\xb6\xef\xbc\x8e\xeb\x88\xb5", "xn--s5a04sn4u297k.xn--2e1b", true); }
test { try toUnicodePass("xn--9hb7344k.", "\xf0\x90\xab\x87\xd9\xa1."); }
test { try toUnicodePass("\xf0\x90\xab\x87\xd9\xa1.", "\xf0\x90\xab\x87\xd9\xa1."); }
test { try toUnicodePass("\xdf\xa5.\xda\xb5", "\xdf\xa5.\xda\xb5"); }
test { try toAsciiPass("\xdf\xa5.\xda\xb5", "xn--dtb.xn--okb", false); }
test { try toAsciiPass("\xdf\xa5.\xda\xb5", "xn--dtb.xn--okb", true); }
test { try toUnicodePass("xn--dtb.xn--okb", "\xdf\xa5.\xda\xb5"); }
test { try toAsciiPass("xn--dtb.xn--okb", "xn--dtb.xn--okb", false); }
test { try toAsciiPass("xn--dtb.xn--okb", "xn--dtb.xn--okb", true); }
test { try toUnicodePass("xn--3e6h", "\xf0\x9e\xa4\xbf"); }
test { try toAsciiPass("xn--3e6h", "xn--3e6h", false); }
test { try toAsciiPass("xn--3e6h", "xn--3e6h", true); }
test { try toUnicodePass("\xf0\x9e\xa4\xbf", "\xf0\x9e\xa4\xbf"); }
test { try toAsciiPass("\xf0\x9e\xa4\xbf", "xn--3e6h", false); }
test { try toAsciiPass("\xf0\x9e\xa4\xbf", "xn--3e6h", true); }
test { try toUnicodePass("\xf0\x9e\xa4\x9d", "\xf0\x9e\xa4\xbf"); }
test { try toAsciiPass("\xf0\x9e\xa4\x9d", "xn--3e6h", false); }
test { try toAsciiPass("\xf0\x9e\xa4\x9d", "xn--3e6h", true); }
test { try toUnicodePass("\xda\xb9\xef\xbc\x8e\xe1\xa1\xb3\xe1\x85\x9f", "\xda\xb9.\xe1\xa1\xb3"); }
test { try toAsciiPass("\xda\xb9\xef\xbc\x8e\xe1\xa1\xb3\xe1\x85\x9f", "xn--skb.xn--g9e", false); }
test { try toAsciiPass("\xda\xb9\xef\xbc\x8e\xe1\xa1\xb3\xe1\x85\x9f", "xn--skb.xn--g9e", true); }
test { try toUnicodePass("\xda\xb9.\xe1\xa1\xb3\xe1\x85\x9f", "\xda\xb9.\xe1\xa1\xb3"); }
test { try toAsciiPass("\xda\xb9.\xe1\xa1\xb3\xe1\x85\x9f", "xn--skb.xn--g9e", false); }
test { try toAsciiPass("\xda\xb9.\xe1\xa1\xb3\xe1\x85\x9f", "xn--skb.xn--g9e", true); }
test { try toUnicodePass("xn--skb.xn--g9e", "\xda\xb9.\xe1\xa1\xb3"); }
test { try toAsciiPass("xn--skb.xn--g9e", "xn--skb.xn--g9e", false); }
test { try toAsciiPass("xn--skb.xn--g9e", "xn--skb.xn--g9e", true); }
test { try toUnicodePass("\xda\xb9.\xe1\xa1\xb3", "\xda\xb9.\xe1\xa1\xb3"); }
test { try toAsciiPass("\xda\xb9.\xe1\xa1\xb3", "xn--skb.xn--g9e", false); }
test { try toAsciiPass("\xda\xb9.\xe1\xa1\xb3", "xn--skb.xn--g9e", true); }
test { try toAsciiPass("\xc3\x9f\xe2\x80\x8c\xea\xab\xb6\xe1\xa2\xa5\xef\xbc\x8e\xe2\x8a\xb6\xe1\x83\x81\xe1\x82\xb6", "xn--ss-4epx629f.xn--ifh802b6a", true); }
test { try toAsciiPass("\xc3\x9f\xe2\x80\x8c\xea\xab\xb6\xe1\xa2\xa5.\xe2\x8a\xb6\xe1\x83\x81\xe1\x82\xb6", "xn--ss-4epx629f.xn--ifh802b6a", true); }
test { try toAsciiPass("\xc3\x9f\xe2\x80\x8c\xea\xab\xb6\xe1\xa2\xa5.\xe2\x8a\xb6\xe2\xb4\xa1\xe2\xb4\x96", "xn--ss-4epx629f.xn--ifh802b6a", true); }
test { try toAsciiPass("SS\xe2\x80\x8c\xea\xab\xb6\xe1\xa2\xa5.\xe2\x8a\xb6\xe1\x83\x81\xe1\x82\xb6", "xn--ss-4epx629f.xn--ifh802b6a", true); }
test { try toAsciiPass("ss\xe2\x80\x8c\xea\xab\xb6\xe1\xa2\xa5.\xe2\x8a\xb6\xe2\xb4\xa1\xe2\xb4\x96", "xn--ss-4epx629f.xn--ifh802b6a", true); }
test { try toAsciiPass("Ss\xe2\x80\x8c\xea\xab\xb6\xe1\xa2\xa5.\xe2\x8a\xb6\xe1\x83\x81\xe2\xb4\x96", "xn--ss-4epx629f.xn--ifh802b6a", true); }
test { try toUnicodePass("xn--ss-4epx629f.xn--ifh802b6a", "ss\xea\xab\xb6\xe1\xa2\xa5.\xe2\x8a\xb6\xe2\xb4\xa1\xe2\xb4\x96"); }
test { try toAsciiPass("xn--ss-4epx629f.xn--ifh802b6a", "xn--ss-4epx629f.xn--ifh802b6a", false); }
test { try toAsciiPass("xn--ss-4epx629f.xn--ifh802b6a", "xn--ss-4epx629f.xn--ifh802b6a", true); }
test { try toUnicodePass("ss\xea\xab\xb6\xe1\xa2\xa5.\xe2\x8a\xb6\xe2\xb4\xa1\xe2\xb4\x96", "ss\xea\xab\xb6\xe1\xa2\xa5.\xe2\x8a\xb6\xe2\xb4\xa1\xe2\xb4\x96"); }
test { try toAsciiPass("ss\xea\xab\xb6\xe1\xa2\xa5.\xe2\x8a\xb6\xe2\xb4\xa1\xe2\xb4\x96", "xn--ss-4epx629f.xn--ifh802b6a", false); }
test { try toAsciiPass("ss\xea\xab\xb6\xe1\xa2\xa5.\xe2\x8a\xb6\xe2\xb4\xa1\xe2\xb4\x96", "xn--ss-4epx629f.xn--ifh802b6a", true); }
test { try toUnicodePass("SS\xea\xab\xb6\xe1\xa2\xa5.\xe2\x8a\xb6\xe1\x83\x81\xe1\x82\xb6", "ss\xea\xab\xb6\xe1\xa2\xa5.\xe2\x8a\xb6\xe2\xb4\xa1\xe2\xb4\x96"); }
test { try toAsciiPass("SS\xea\xab\xb6\xe1\xa2\xa5.\xe2\x8a\xb6\xe1\x83\x81\xe1\x82\xb6", "xn--ss-4epx629f.xn--ifh802b6a", false); }
test { try toAsciiPass("SS\xea\xab\xb6\xe1\xa2\xa5.\xe2\x8a\xb6\xe1\x83\x81\xe1\x82\xb6", "xn--ss-4epx629f.xn--ifh802b6a", true); }
test { try toUnicodePass("Ss\xea\xab\xb6\xe1\xa2\xa5.\xe2\x8a\xb6\xe1\x83\x81\xe2\xb4\x96", "ss\xea\xab\xb6\xe1\xa2\xa5.\xe2\x8a\xb6\xe2\xb4\xa1\xe2\xb4\x96"); }
test { try toAsciiPass("Ss\xea\xab\xb6\xe1\xa2\xa5.\xe2\x8a\xb6\xe1\x83\x81\xe2\xb4\x96", "xn--ss-4epx629f.xn--ifh802b6a", false); }
test { try toAsciiPass("Ss\xea\xab\xb6\xe1\xa2\xa5.\xe2\x8a\xb6\xe1\x83\x81\xe2\xb4\x96", "xn--ss-4epx629f.xn--ifh802b6a", true); }
test { try toAsciiPass("\xc3\x9f\xe2\x80\x8c\xea\xab\xb6\xe1\xa2\xa5\xef\xbc\x8e\xe2\x8a\xb6\xe2\xb4\xa1\xe2\xb4\x96", "xn--ss-4epx629f.xn--ifh802b6a", true); }
test { try toAsciiPass("SS\xe2\x80\x8c\xea\xab\xb6\xe1\xa2\xa5\xef\xbc\x8e\xe2\x8a\xb6\xe1\x83\x81\xe1\x82\xb6", "xn--ss-4epx629f.xn--ifh802b6a", true); }
test { try toAsciiPass("ss\xe2\x80\x8c\xea\xab\xb6\xe1\xa2\xa5\xef\xbc\x8e\xe2\x8a\xb6\xe2\xb4\xa1\xe2\xb4\x96", "xn--ss-4epx629f.xn--ifh802b6a", true); }
test { try toAsciiPass("Ss\xe2\x80\x8c\xea\xab\xb6\xe1\xa2\xa5\xef\xbc\x8e\xe2\x8a\xb6\xe1\x83\x81\xe2\xb4\x96", "xn--ss-4epx629f.xn--ifh802b6a", true); }
test { try toUnicodePass("\xe2\x89\xa0\xe3\x80\x82\xf0\x9f\x9e\xb3\xf0\x9d\x9f\xb2", "\xe2\x89\xa0.\xf0\x9f\x9e\xb36"); }
test { try toAsciiPass("\xe2\x89\xa0\xe3\x80\x82\xf0\x9f\x9e\xb3\xf0\x9d\x9f\xb2", "xn--1ch.xn--6-dl4s", false); }
test { try toAsciiPass("\xe2\x89\xa0\xe3\x80\x82\xf0\x9f\x9e\xb3\xf0\x9d\x9f\xb2", "xn--1ch.xn--6-dl4s", true); }
test { try toUnicodePass("=\xcc\xb8\xe3\x80\x82\xf0\x9f\x9e\xb3\xf0\x9d\x9f\xb2", "\xe2\x89\xa0.\xf0\x9f\x9e\xb36"); }
test { try toAsciiPass("=\xcc\xb8\xe3\x80\x82\xf0\x9f\x9e\xb3\xf0\x9d\x9f\xb2", "xn--1ch.xn--6-dl4s", false); }
test { try toAsciiPass("=\xcc\xb8\xe3\x80\x82\xf0\x9f\x9e\xb3\xf0\x9d\x9f\xb2", "xn--1ch.xn--6-dl4s", true); }
test { try toUnicodePass("\xe2\x89\xa0\xe3\x80\x82\xf0\x9f\x9e\xb36", "\xe2\x89\xa0.\xf0\x9f\x9e\xb36"); }
test { try toAsciiPass("\xe2\x89\xa0\xe3\x80\x82\xf0\x9f\x9e\xb36", "xn--1ch.xn--6-dl4s", false); }
test { try toAsciiPass("\xe2\x89\xa0\xe3\x80\x82\xf0\x9f\x9e\xb36", "xn--1ch.xn--6-dl4s", true); }
test { try toUnicodePass("=\xcc\xb8\xe3\x80\x82\xf0\x9f\x9e\xb36", "\xe2\x89\xa0.\xf0\x9f\x9e\xb36"); }
test { try toAsciiPass("=\xcc\xb8\xe3\x80\x82\xf0\x9f\x9e\xb36", "xn--1ch.xn--6-dl4s", false); }
test { try toAsciiPass("=\xcc\xb8\xe3\x80\x82\xf0\x9f\x9e\xb36", "xn--1ch.xn--6-dl4s", true); }
test { try toUnicodePass("xn--1ch.xn--6-dl4s", "\xe2\x89\xa0.\xf0\x9f\x9e\xb36"); }
test { try toAsciiPass("xn--1ch.xn--6-dl4s", "xn--1ch.xn--6-dl4s", false); }
test { try toAsciiPass("xn--1ch.xn--6-dl4s", "xn--1ch.xn--6-dl4s", true); }
test { try toUnicodePass("\xe2\x89\xa0.\xf0\x9f\x9e\xb36", "\xe2\x89\xa0.\xf0\x9f\x9e\xb36"); }
test { try toAsciiPass("\xe2\x89\xa0.\xf0\x9f\x9e\xb36", "xn--1ch.xn--6-dl4s", false); }
test { try toAsciiPass("\xe2\x89\xa0.\xf0\x9f\x9e\xb36", "xn--1ch.xn--6-dl4s", true); }
test { try toUnicodePass("=\xcc\xb8.\xf0\x9f\x9e\xb36", "\xe2\x89\xa0.\xf0\x9f\x9e\xb36"); }
test { try toAsciiPass("=\xcc\xb8.\xf0\x9f\x9e\xb36", "xn--1ch.xn--6-dl4s", false); }
test { try toAsciiPass("=\xcc\xb8.\xf0\x9f\x9e\xb36", "xn--1ch.xn--6-dl4s", true); }
test { try toUnicodePass("j", "j"); }
test { try toAsciiPass("j", "j", false); }
test { try toAsciiPass("j", "j", true); }
test { try toUnicodePass("xn--rt6a.", "\xe9\xb1\x8a."); }
test { try toUnicodePass("\xe9\xb1\x8a.", "\xe9\xb1\x8a."); }
test { try toUnicodePass("xn--4-0bd15808a.", "\xf0\x9e\xa4\xba\xdf\x8c4."); }
test { try toUnicodePass("\xf0\x9e\xa4\xba\xdf\x8c4.", "\xf0\x9e\xa4\xba\xdf\x8c4."); }
test { try toUnicodePass("\xf0\x9e\xa4\x98\xdf\x8c4.", "\xf0\x9e\xa4\xba\xdf\x8c4."); }
test { try toUnicodePass("\xe2\xbe\x86\xef\xbc\x8e\xea\xa1\x88\xef\xbc\x95\xe2\x89\xaf\xc3\x9f", "\xe8\x88\x8c.\xea\xa1\x885\xe2\x89\xaf\xc3\x9f"); }
test { try toAsciiPass("\xe2\xbe\x86\xef\xbc\x8e\xea\xa1\x88\xef\xbc\x95\xe2\x89\xaf\xc3\x9f", "xn--tc1a.xn--5-qfa988w745i", false); }
test { try toAsciiPass("\xe2\xbe\x86\xef\xbc\x8e\xea\xa1\x88\xef\xbc\x95\xe2\x89\xaf\xc3\x9f", "xn--tc1a.xn--5ss-3m2a5009e", true); }
test { try toUnicodePass("\xe2\xbe\x86\xef\xbc\x8e\xea\xa1\x88\xef\xbc\x95>\xcc\xb8\xc3\x9f", "\xe8\x88\x8c.\xea\xa1\x885\xe2\x89\xaf\xc3\x9f"); }
test { try toAsciiPass("\xe2\xbe\x86\xef\xbc\x8e\xea\xa1\x88\xef\xbc\x95>\xcc\xb8\xc3\x9f", "xn--tc1a.xn--5-qfa988w745i", false); }
test { try toAsciiPass("\xe2\xbe\x86\xef\xbc\x8e\xea\xa1\x88\xef\xbc\x95>\xcc\xb8\xc3\x9f", "xn--tc1a.xn--5ss-3m2a5009e", true); }
test { try toUnicodePass("\xe8\x88\x8c.\xea\xa1\x885\xe2\x89\xaf\xc3\x9f", "\xe8\x88\x8c.\xea\xa1\x885\xe2\x89\xaf\xc3\x9f"); }
test { try toAsciiPass("\xe8\x88\x8c.\xea\xa1\x885\xe2\x89\xaf\xc3\x9f", "xn--tc1a.xn--5-qfa988w745i", false); }
test { try toAsciiPass("\xe8\x88\x8c.\xea\xa1\x885\xe2\x89\xaf\xc3\x9f", "xn--tc1a.xn--5ss-3m2a5009e", true); }
test { try toUnicodePass("\xe8\x88\x8c.\xea\xa1\x885>\xcc\xb8\xc3\x9f", "\xe8\x88\x8c.\xea\xa1\x885\xe2\x89\xaf\xc3\x9f"); }
test { try toAsciiPass("\xe8\x88\x8c.\xea\xa1\x885>\xcc\xb8\xc3\x9f", "xn--tc1a.xn--5-qfa988w745i", false); }
test { try toAsciiPass("\xe8\x88\x8c.\xea\xa1\x885>\xcc\xb8\xc3\x9f", "xn--tc1a.xn--5ss-3m2a5009e", true); }
test { try toUnicodePass("\xe8\x88\x8c.\xea\xa1\x885>\xcc\xb8SS", "\xe8\x88\x8c.\xea\xa1\x885\xe2\x89\xafss"); }
test { try toAsciiPass("\xe8\x88\x8c.\xea\xa1\x885>\xcc\xb8SS", "xn--tc1a.xn--5ss-3m2a5009e", false); }
test { try toAsciiPass("\xe8\x88\x8c.\xea\xa1\x885>\xcc\xb8SS", "xn--tc1a.xn--5ss-3m2a5009e", true); }
test { try toUnicodePass("\xe8\x88\x8c.\xea\xa1\x885\xe2\x89\xafSS", "\xe8\x88\x8c.\xea\xa1\x885\xe2\x89\xafss"); }
test { try toAsciiPass("\xe8\x88\x8c.\xea\xa1\x885\xe2\x89\xafSS", "xn--tc1a.xn--5ss-3m2a5009e", false); }
test { try toAsciiPass("\xe8\x88\x8c.\xea\xa1\x885\xe2\x89\xafSS", "xn--tc1a.xn--5ss-3m2a5009e", true); }
test { try toUnicodePass("\xe8\x88\x8c.\xea\xa1\x885\xe2\x89\xafss", "\xe8\x88\x8c.\xea\xa1\x885\xe2\x89\xafss"); }
test { try toAsciiPass("\xe8\x88\x8c.\xea\xa1\x885\xe2\x89\xafss", "xn--tc1a.xn--5ss-3m2a5009e", false); }
test { try toAsciiPass("\xe8\x88\x8c.\xea\xa1\x885\xe2\x89\xafss", "xn--tc1a.xn--5ss-3m2a5009e", true); }
test { try toUnicodePass("\xe8\x88\x8c.\xea\xa1\x885>\xcc\xb8ss", "\xe8\x88\x8c.\xea\xa1\x885\xe2\x89\xafss"); }
test { try toAsciiPass("\xe8\x88\x8c.\xea\xa1\x885>\xcc\xb8ss", "xn--tc1a.xn--5ss-3m2a5009e", false); }
test { try toAsciiPass("\xe8\x88\x8c.\xea\xa1\x885>\xcc\xb8ss", "xn--tc1a.xn--5ss-3m2a5009e", true); }
test { try toUnicodePass("\xe8\x88\x8c.\xea\xa1\x885>\xcc\xb8Ss", "\xe8\x88\x8c.\xea\xa1\x885\xe2\x89\xafss"); }
test { try toAsciiPass("\xe8\x88\x8c.\xea\xa1\x885>\xcc\xb8Ss", "xn--tc1a.xn--5ss-3m2a5009e", false); }
test { try toAsciiPass("\xe8\x88\x8c.\xea\xa1\x885>\xcc\xb8Ss", "xn--tc1a.xn--5ss-3m2a5009e", true); }
test { try toUnicodePass("\xe8\x88\x8c.\xea\xa1\x885\xe2\x89\xafSs", "\xe8\x88\x8c.\xea\xa1\x885\xe2\x89\xafss"); }
test { try toAsciiPass("\xe8\x88\x8c.\xea\xa1\x885\xe2\x89\xafSs", "xn--tc1a.xn--5ss-3m2a5009e", false); }
test { try toAsciiPass("\xe8\x88\x8c.\xea\xa1\x885\xe2\x89\xafSs", "xn--tc1a.xn--5ss-3m2a5009e", true); }
test { try toUnicodePass("xn--tc1a.xn--5ss-3m2a5009e", "\xe8\x88\x8c.\xea\xa1\x885\xe2\x89\xafss"); }
test { try toAsciiPass("xn--tc1a.xn--5ss-3m2a5009e", "xn--tc1a.xn--5ss-3m2a5009e", false); }
test { try toAsciiPass("xn--tc1a.xn--5ss-3m2a5009e", "xn--tc1a.xn--5ss-3m2a5009e", true); }
test { try toUnicodePass("xn--tc1a.xn--5-qfa988w745i", "\xe8\x88\x8c.\xea\xa1\x885\xe2\x89\xaf\xc3\x9f"); }
test { try toAsciiPass("xn--tc1a.xn--5-qfa988w745i", "xn--tc1a.xn--5-qfa988w745i", false); }
test { try toAsciiPass("xn--tc1a.xn--5-qfa988w745i", "xn--tc1a.xn--5-qfa988w745i", true); }
test { try toUnicodePass("\xe2\xbe\x86\xef\xbc\x8e\xea\xa1\x88\xef\xbc\x95>\xcc\xb8SS", "\xe8\x88\x8c.\xea\xa1\x885\xe2\x89\xafss"); }
test { try toAsciiPass("\xe2\xbe\x86\xef\xbc\x8e\xea\xa1\x88\xef\xbc\x95>\xcc\xb8SS", "xn--tc1a.xn--5ss-3m2a5009e", false); }
test { try toAsciiPass("\xe2\xbe\x86\xef\xbc\x8e\xea\xa1\x88\xef\xbc\x95>\xcc\xb8SS", "xn--tc1a.xn--5ss-3m2a5009e", true); }
test { try toUnicodePass("\xe2\xbe\x86\xef\xbc\x8e\xea\xa1\x88\xef\xbc\x95\xe2\x89\xafSS", "\xe8\x88\x8c.\xea\xa1\x885\xe2\x89\xafss"); }
test { try toAsciiPass("\xe2\xbe\x86\xef\xbc\x8e\xea\xa1\x88\xef\xbc\x95\xe2\x89\xafSS", "xn--tc1a.xn--5ss-3m2a5009e", false); }
test { try toAsciiPass("\xe2\xbe\x86\xef\xbc\x8e\xea\xa1\x88\xef\xbc\x95\xe2\x89\xafSS", "xn--tc1a.xn--5ss-3m2a5009e", true); }
test { try toUnicodePass("\xe2\xbe\x86\xef\xbc\x8e\xea\xa1\x88\xef\xbc\x95\xe2\x89\xafss", "\xe8\x88\x8c.\xea\xa1\x885\xe2\x89\xafss"); }
test { try toAsciiPass("\xe2\xbe\x86\xef\xbc\x8e\xea\xa1\x88\xef\xbc\x95\xe2\x89\xafss", "xn--tc1a.xn--5ss-3m2a5009e", false); }
test { try toAsciiPass("\xe2\xbe\x86\xef\xbc\x8e\xea\xa1\x88\xef\xbc\x95\xe2\x89\xafss", "xn--tc1a.xn--5ss-3m2a5009e", true); }
test { try toUnicodePass("\xe2\xbe\x86\xef\xbc\x8e\xea\xa1\x88\xef\xbc\x95>\xcc\xb8ss", "\xe8\x88\x8c.\xea\xa1\x885\xe2\x89\xafss"); }
test { try toAsciiPass("\xe2\xbe\x86\xef\xbc\x8e\xea\xa1\x88\xef\xbc\x95>\xcc\xb8ss", "xn--tc1a.xn--5ss-3m2a5009e", false); }
test { try toAsciiPass("\xe2\xbe\x86\xef\xbc\x8e\xea\xa1\x88\xef\xbc\x95>\xcc\xb8ss", "xn--tc1a.xn--5ss-3m2a5009e", true); }
test { try toUnicodePass("\xe2\xbe\x86\xef\xbc\x8e\xea\xa1\x88\xef\xbc\x95>\xcc\xb8Ss", "\xe8\x88\x8c.\xea\xa1\x885\xe2\x89\xafss"); }
test { try toAsciiPass("\xe2\xbe\x86\xef\xbc\x8e\xea\xa1\x88\xef\xbc\x95>\xcc\xb8Ss", "xn--tc1a.xn--5ss-3m2a5009e", false); }
test { try toAsciiPass("\xe2\xbe\x86\xef\xbc\x8e\xea\xa1\x88\xef\xbc\x95>\xcc\xb8Ss", "xn--tc1a.xn--5ss-3m2a5009e", true); }
test { try toUnicodePass("\xe2\xbe\x86\xef\xbc\x8e\xea\xa1\x88\xef\xbc\x95\xe2\x89\xafSs", "\xe8\x88\x8c.\xea\xa1\x885\xe2\x89\xafss"); }
test { try toAsciiPass("\xe2\xbe\x86\xef\xbc\x8e\xea\xa1\x88\xef\xbc\x95\xe2\x89\xafSs", "xn--tc1a.xn--5ss-3m2a5009e", false); }
test { try toAsciiPass("\xe2\xbe\x86\xef\xbc\x8e\xea\xa1\x88\xef\xbc\x95\xe2\x89\xafSs", "xn--tc1a.xn--5ss-3m2a5009e", true); }
test { try toUnicodePass("\xf0\x9e\xa4\xaa.\xcf\x82", "\xf0\x9e\xa4\xaa.\xcf\x82"); }
test { try toAsciiPass("\xf0\x9e\xa4\xaa.\xcf\x82", "xn--ie6h.xn--3xa", false); }
test { try toAsciiPass("\xf0\x9e\xa4\xaa.\xcf\x82", "xn--ie6h.xn--4xa", true); }
test { try toUnicodePass("\xf0\x9e\xa4\x88.\xce\xa3", "\xf0\x9e\xa4\xaa.\xcf\x83"); }
test { try toAsciiPass("\xf0\x9e\xa4\x88.\xce\xa3", "xn--ie6h.xn--4xa", false); }
test { try toAsciiPass("\xf0\x9e\xa4\x88.\xce\xa3", "xn--ie6h.xn--4xa", true); }
test { try toUnicodePass("\xf0\x9e\xa4\xaa.\xcf\x83", "\xf0\x9e\xa4\xaa.\xcf\x83"); }
test { try toAsciiPass("\xf0\x9e\xa4\xaa.\xcf\x83", "xn--ie6h.xn--4xa", false); }
test { try toAsciiPass("\xf0\x9e\xa4\xaa.\xcf\x83", "xn--ie6h.xn--4xa", true); }
test { try toUnicodePass("\xf0\x9e\xa4\x88.\xcf\x83", "\xf0\x9e\xa4\xaa.\xcf\x83"); }
test { try toAsciiPass("\xf0\x9e\xa4\x88.\xcf\x83", "xn--ie6h.xn--4xa", false); }
test { try toAsciiPass("\xf0\x9e\xa4\x88.\xcf\x83", "xn--ie6h.xn--4xa", true); }
test { try toUnicodePass("xn--ie6h.xn--4xa", "\xf0\x9e\xa4\xaa.\xcf\x83"); }
test { try toAsciiPass("xn--ie6h.xn--4xa", "xn--ie6h.xn--4xa", false); }
test { try toAsciiPass("xn--ie6h.xn--4xa", "xn--ie6h.xn--4xa", true); }
test { try toUnicodePass("\xf0\x9e\xa4\x88.\xcf\x82", "\xf0\x9e\xa4\xaa.\xcf\x82"); }
test { try toAsciiPass("\xf0\x9e\xa4\x88.\xcf\x82", "xn--ie6h.xn--3xa", false); }
test { try toAsciiPass("\xf0\x9e\xa4\x88.\xcf\x82", "xn--ie6h.xn--4xa", true); }
test { try toUnicodePass("xn--ie6h.xn--3xa", "\xf0\x9e\xa4\xaa.\xcf\x82"); }
test { try toAsciiPass("xn--ie6h.xn--3xa", "xn--ie6h.xn--3xa", false); }
test { try toAsciiPass("xn--ie6h.xn--3xa", "xn--ie6h.xn--3xa", true); }
test { try toUnicodePass("\xf0\x9e\xa4\xaa.\xce\xa3", "\xf0\x9e\xa4\xaa.\xcf\x83"); }
test { try toAsciiPass("\xf0\x9e\xa4\xaa.\xce\xa3", "xn--ie6h.xn--4xa", false); }
test { try toAsciiPass("\xf0\x9e\xa4\xaa.\xce\xa3", "xn--ie6h.xn--4xa", true); }
test { try toAsciiPass("\xe2\x80\x8c\xe1\x82\xba\xef\xbd\xa1\xcf\x82", "xn--ilj.xn--4xa", true); }
test { try toAsciiPass("\xe2\x80\x8c\xe1\x82\xba\xe3\x80\x82\xcf\x82", "xn--ilj.xn--4xa", true); }
test { try toAsciiPass("\xe2\x80\x8c\xe2\xb4\x9a\xe3\x80\x82\xcf\x82", "xn--ilj.xn--4xa", true); }
test { try toAsciiPass("\xe2\x80\x8c\xe1\x82\xba\xe3\x80\x82\xce\xa3", "xn--ilj.xn--4xa", true); }
test { try toAsciiPass("\xe2\x80\x8c\xe2\xb4\x9a\xe3\x80\x82\xcf\x83", "xn--ilj.xn--4xa", true); }
test { try toUnicodePass("xn--ilj.xn--4xa", "\xe2\xb4\x9a.\xcf\x83"); }
test { try toAsciiPass("xn--ilj.xn--4xa", "xn--ilj.xn--4xa", false); }
test { try toAsciiPass("xn--ilj.xn--4xa", "xn--ilj.xn--4xa", true); }
test { try toUnicodePass("\xe2\xb4\x9a.\xcf\x83", "\xe2\xb4\x9a.\xcf\x83"); }
test { try toAsciiPass("\xe2\xb4\x9a.\xcf\x83", "xn--ilj.xn--4xa", false); }
test { try toAsciiPass("\xe2\xb4\x9a.\xcf\x83", "xn--ilj.xn--4xa", true); }
test { try toUnicodePass("\xe1\x82\xba.\xce\xa3", "\xe2\xb4\x9a.\xcf\x83"); }
test { try toAsciiPass("\xe1\x82\xba.\xce\xa3", "xn--ilj.xn--4xa", false); }
test { try toAsciiPass("\xe1\x82\xba.\xce\xa3", "xn--ilj.xn--4xa", true); }
test { try toUnicodePass("\xe2\xb4\x9a.\xcf\x82", "\xe2\xb4\x9a.\xcf\x82"); }
test { try toAsciiPass("\xe2\xb4\x9a.\xcf\x82", "xn--ilj.xn--3xa", false); }
test { try toAsciiPass("\xe2\xb4\x9a.\xcf\x82", "xn--ilj.xn--4xa", true); }
test { try toUnicodePass("\xe1\x82\xba.\xcf\x82", "\xe2\xb4\x9a.\xcf\x82"); }
test { try toAsciiPass("\xe1\x82\xba.\xcf\x82", "xn--ilj.xn--3xa", false); }
test { try toAsciiPass("\xe1\x82\xba.\xcf\x82", "xn--ilj.xn--4xa", true); }
test { try toUnicodePass("xn--ilj.xn--3xa", "\xe2\xb4\x9a.\xcf\x82"); }
test { try toAsciiPass("xn--ilj.xn--3xa", "xn--ilj.xn--3xa", false); }
test { try toAsciiPass("xn--ilj.xn--3xa", "xn--ilj.xn--3xa", true); }
test { try toUnicodePass("\xe1\x82\xba.\xcf\x83", "\xe2\xb4\x9a.\xcf\x83"); }
test { try toAsciiPass("\xe1\x82\xba.\xcf\x83", "xn--ilj.xn--4xa", false); }
test { try toAsciiPass("\xe1\x82\xba.\xcf\x83", "xn--ilj.xn--4xa", true); }
test { try toAsciiPass("\xe2\x80\x8c\xe2\xb4\x9a\xef\xbd\xa1\xcf\x82", "xn--ilj.xn--4xa", true); }
test { try toAsciiPass("\xe2\x80\x8c\xe1\x82\xba\xef\xbd\xa1\xce\xa3", "xn--ilj.xn--4xa", true); }
test { try toAsciiPass("\xe2\x80\x8c\xe2\xb4\x9a\xef\xbd\xa1\xcf\x83", "xn--ilj.xn--4xa", true); }
test { try toUnicodePass("\xe6\xb7\xbd\xe3\x80\x82\xe1\xa0\xbe", "\xe6\xb7\xbd.\xe1\xa0\xbe"); }
test { try toAsciiPass("\xe6\xb7\xbd\xe3\x80\x82\xe1\xa0\xbe", "xn--34w.xn--x7e", false); }
test { try toAsciiPass("\xe6\xb7\xbd\xe3\x80\x82\xe1\xa0\xbe", "xn--34w.xn--x7e", true); }
test { try toUnicodePass("xn--34w.xn--x7e", "\xe6\xb7\xbd.\xe1\xa0\xbe"); }
test { try toAsciiPass("xn--34w.xn--x7e", "xn--34w.xn--x7e", false); }
test { try toAsciiPass("xn--34w.xn--x7e", "xn--34w.xn--x7e", true); }
test { try toUnicodePass("\xe6\xb7\xbd.\xe1\xa0\xbe", "\xe6\xb7\xbd.\xe1\xa0\xbe"); }
test { try toAsciiPass("\xe6\xb7\xbd.\xe1\xa0\xbe", "xn--34w.xn--x7e", false); }
test { try toAsciiPass("\xe6\xb7\xbd.\xe1\xa0\xbe", "xn--34w.xn--x7e", true); }
test { try toUnicodePass("\xea\xa1\xa0\xef\xbc\x8e\xdb\xb2", "\xea\xa1\xa0.\xdb\xb2"); }
test { try toAsciiPass("\xea\xa1\xa0\xef\xbc\x8e\xdb\xb2", "xn--5c9a.xn--fmb", false); }
test { try toAsciiPass("\xea\xa1\xa0\xef\xbc\x8e\xdb\xb2", "xn--5c9a.xn--fmb", true); }
test { try toUnicodePass("\xea\xa1\xa0.\xdb\xb2", "\xea\xa1\xa0.\xdb\xb2"); }
test { try toAsciiPass("\xea\xa1\xa0.\xdb\xb2", "xn--5c9a.xn--fmb", false); }
test { try toAsciiPass("\xea\xa1\xa0.\xdb\xb2", "xn--5c9a.xn--fmb", true); }
test { try toUnicodePass("xn--5c9a.xn--fmb", "\xea\xa1\xa0.\xdb\xb2"); }
test { try toAsciiPass("xn--5c9a.xn--fmb", "xn--5c9a.xn--fmb", false); }
test { try toAsciiPass("xn--5c9a.xn--fmb", "xn--5c9a.xn--fmb", true); }
test { try toAsciiPass("\xf0\x9d\x9f\x99\xef\xbd\xa1\xe2\x80\x8d\xf0\x9d\x9f\xb8\xe2\x80\x8d\xe2\x81\xb7", "1.27", true); }
test { try toAsciiPass("1\xe3\x80\x82\xe2\x80\x8d2\xe2\x80\x8d7", "1.27", true); }
test { try toUnicodePass("1.2h", "1.2h"); }
test { try toAsciiPass("1.2h", "1.2h", false); }
test { try toAsciiPass("1.2h", "1.2h", true); }
test { try toAsciiPass("\xe2\x80\x8c\xe1\x82\xa1\xe7\x95\x9d\xe2\x80\x8d\xef\xbc\x8e\xe2\x89\xae", "xn--skjy82u.xn--gdh", true); }
test { try toAsciiPass("\xe2\x80\x8c\xe1\x82\xa1\xe7\x95\x9d\xe2\x80\x8d\xef\xbc\x8e<\xcc\xb8", "xn--skjy82u.xn--gdh", true); }
test { try toAsciiPass("\xe2\x80\x8c\xe1\x82\xa1\xe7\x95\x9d\xe2\x80\x8d.\xe2\x89\xae", "xn--skjy82u.xn--gdh", true); }
test { try toAsciiPass("\xe2\x80\x8c\xe1\x82\xa1\xe7\x95\x9d\xe2\x80\x8d.<\xcc\xb8", "xn--skjy82u.xn--gdh", true); }
test { try toAsciiPass("\xe2\x80\x8c\xe2\xb4\x81\xe7\x95\x9d\xe2\x80\x8d.<\xcc\xb8", "xn--skjy82u.xn--gdh", true); }
test { try toAsciiPass("\xe2\x80\x8c\xe2\xb4\x81\xe7\x95\x9d\xe2\x80\x8d.\xe2\x89\xae", "xn--skjy82u.xn--gdh", true); }
test { try toUnicodePass("xn--skjy82u.xn--gdh", "\xe2\xb4\x81\xe7\x95\x9d.\xe2\x89\xae"); }
test { try toAsciiPass("xn--skjy82u.xn--gdh", "xn--skjy82u.xn--gdh", false); }
test { try toAsciiPass("xn--skjy82u.xn--gdh", "xn--skjy82u.xn--gdh", true); }
test { try toUnicodePass("\xe2\xb4\x81\xe7\x95\x9d.\xe2\x89\xae", "\xe2\xb4\x81\xe7\x95\x9d.\xe2\x89\xae"); }
test { try toAsciiPass("\xe2\xb4\x81\xe7\x95\x9d.\xe2\x89\xae", "xn--skjy82u.xn--gdh", false); }
test { try toAsciiPass("\xe2\xb4\x81\xe7\x95\x9d.\xe2\x89\xae", "xn--skjy82u.xn--gdh", true); }
test { try toUnicodePass("\xe2\xb4\x81\xe7\x95\x9d.<\xcc\xb8", "\xe2\xb4\x81\xe7\x95\x9d.\xe2\x89\xae"); }
test { try toAsciiPass("\xe2\xb4\x81\xe7\x95\x9d.<\xcc\xb8", "xn--skjy82u.xn--gdh", false); }
test { try toAsciiPass("\xe2\xb4\x81\xe7\x95\x9d.<\xcc\xb8", "xn--skjy82u.xn--gdh", true); }
test { try toUnicodePass("\xe1\x82\xa1\xe7\x95\x9d.<\xcc\xb8", "\xe2\xb4\x81\xe7\x95\x9d.\xe2\x89\xae"); }
test { try toAsciiPass("\xe1\x82\xa1\xe7\x95\x9d.<\xcc\xb8", "xn--skjy82u.xn--gdh", false); }
test { try toAsciiPass("\xe1\x82\xa1\xe7\x95\x9d.<\xcc\xb8", "xn--skjy82u.xn--gdh", true); }
test { try toUnicodePass("\xe1\x82\xa1\xe7\x95\x9d.\xe2\x89\xae", "\xe2\xb4\x81\xe7\x95\x9d.\xe2\x89\xae"); }
test { try toAsciiPass("\xe1\x82\xa1\xe7\x95\x9d.\xe2\x89\xae", "xn--skjy82u.xn--gdh", false); }
test { try toAsciiPass("\xe1\x82\xa1\xe7\x95\x9d.\xe2\x89\xae", "xn--skjy82u.xn--gdh", true); }
test { try toAsciiPass("\xe2\x80\x8c\xe2\xb4\x81\xe7\x95\x9d\xe2\x80\x8d\xef\xbc\x8e<\xcc\xb8", "xn--skjy82u.xn--gdh", true); }
test { try toAsciiPass("\xe2\x80\x8c\xe2\xb4\x81\xe7\x95\x9d\xe2\x80\x8d\xef\xbc\x8e\xe2\x89\xae", "xn--skjy82u.xn--gdh", true); }
test { try toUnicodePass("\xf0\x9f\x95\xbc\xef\xbc\x8e\xef\xbe\xa0", "\xf0\x9f\x95\xbc."); }
test { try toUnicodePass("\xf0\x9f\x95\xbc.\xe1\x85\xa0", "\xf0\x9f\x95\xbc."); }
test { try toUnicodePass("xn--my8h.", "\xf0\x9f\x95\xbc."); }
test { try toUnicodePass("\xf0\x9f\x95\xbc.", "\xf0\x9f\x95\xbc."); }
test { try toUnicodePass("\xcf\x82\xe1\x83\x85\xe3\x80\x82\xdd\x9a", "\xcf\x82\xe2\xb4\xa5.\xdd\x9a"); }
test { try toAsciiPass("\xcf\x82\xe1\x83\x85\xe3\x80\x82\xdd\x9a", "xn--3xa403s.xn--epb", false); }
test { try toAsciiPass("\xcf\x82\xe1\x83\x85\xe3\x80\x82\xdd\x9a", "xn--4xa203s.xn--epb", true); }
test { try toUnicodePass("\xcf\x82\xe2\xb4\xa5\xe3\x80\x82\xdd\x9a", "\xcf\x82\xe2\xb4\xa5.\xdd\x9a"); }
test { try toAsciiPass("\xcf\x82\xe2\xb4\xa5\xe3\x80\x82\xdd\x9a", "xn--3xa403s.xn--epb", false); }
test { try toAsciiPass("\xcf\x82\xe2\xb4\xa5\xe3\x80\x82\xdd\x9a", "xn--4xa203s.xn--epb", true); }
test { try toUnicodePass("\xce\xa3\xe1\x83\x85\xe3\x80\x82\xdd\x9a", "\xcf\x83\xe2\xb4\xa5.\xdd\x9a"); }
test { try toAsciiPass("\xce\xa3\xe1\x83\x85\xe3\x80\x82\xdd\x9a", "xn--4xa203s.xn--epb", false); }
test { try toAsciiPass("\xce\xa3\xe1\x83\x85\xe3\x80\x82\xdd\x9a", "xn--4xa203s.xn--epb", true); }
test { try toUnicodePass("\xcf\x83\xe2\xb4\xa5\xe3\x80\x82\xdd\x9a", "\xcf\x83\xe2\xb4\xa5.\xdd\x9a"); }
test { try toAsciiPass("\xcf\x83\xe2\xb4\xa5\xe3\x80\x82\xdd\x9a", "xn--4xa203s.xn--epb", false); }
test { try toAsciiPass("\xcf\x83\xe2\xb4\xa5\xe3\x80\x82\xdd\x9a", "xn--4xa203s.xn--epb", true); }
test { try toUnicodePass("\xce\xa3\xe2\xb4\xa5\xe3\x80\x82\xdd\x9a", "\xcf\x83\xe2\xb4\xa5.\xdd\x9a"); }
test { try toAsciiPass("\xce\xa3\xe2\xb4\xa5\xe3\x80\x82\xdd\x9a", "xn--4xa203s.xn--epb", false); }
test { try toAsciiPass("\xce\xa3\xe2\xb4\xa5\xe3\x80\x82\xdd\x9a", "xn--4xa203s.xn--epb", true); }
test { try toUnicodePass("xn--4xa203s.xn--epb", "\xcf\x83\xe2\xb4\xa5.\xdd\x9a"); }
test { try toAsciiPass("xn--4xa203s.xn--epb", "xn--4xa203s.xn--epb", false); }
test { try toAsciiPass("xn--4xa203s.xn--epb", "xn--4xa203s.xn--epb", true); }
test { try toUnicodePass("\xcf\x83\xe2\xb4\xa5.\xdd\x9a", "\xcf\x83\xe2\xb4\xa5.\xdd\x9a"); }
test { try toAsciiPass("\xcf\x83\xe2\xb4\xa5.\xdd\x9a", "xn--4xa203s.xn--epb", false); }
test { try toAsciiPass("\xcf\x83\xe2\xb4\xa5.\xdd\x9a", "xn--4xa203s.xn--epb", true); }
test { try toUnicodePass("\xce\xa3\xe1\x83\x85.\xdd\x9a", "\xcf\x83\xe2\xb4\xa5.\xdd\x9a"); }
test { try toAsciiPass("\xce\xa3\xe1\x83\x85.\xdd\x9a", "xn--4xa203s.xn--epb", false); }
test { try toAsciiPass("\xce\xa3\xe1\x83\x85.\xdd\x9a", "xn--4xa203s.xn--epb", true); }
test { try toUnicodePass("\xce\xa3\xe2\xb4\xa5.\xdd\x9a", "\xcf\x83\xe2\xb4\xa5.\xdd\x9a"); }
test { try toAsciiPass("\xce\xa3\xe2\xb4\xa5.\xdd\x9a", "xn--4xa203s.xn--epb", false); }
test { try toAsciiPass("\xce\xa3\xe2\xb4\xa5.\xdd\x9a", "xn--4xa203s.xn--epb", true); }
test { try toUnicodePass("xn--3xa403s.xn--epb", "\xcf\x82\xe2\xb4\xa5.\xdd\x9a"); }
test { try toAsciiPass("xn--3xa403s.xn--epb", "xn--3xa403s.xn--epb", false); }
test { try toAsciiPass("xn--3xa403s.xn--epb", "xn--3xa403s.xn--epb", true); }
test { try toUnicodePass("\xcf\x82\xe2\xb4\xa5.\xdd\x9a", "\xcf\x82\xe2\xb4\xa5.\xdd\x9a"); }
test { try toAsciiPass("\xcf\x82\xe2\xb4\xa5.\xdd\x9a", "xn--3xa403s.xn--epb", false); }
test { try toAsciiPass("\xcf\x82\xe2\xb4\xa5.\xdd\x9a", "xn--4xa203s.xn--epb", true); }
test { try toAsciiPass("\xda\xbc\xef\xbd\xa1\xe2\x80\x8d\xe1\xba\x8f\xe2\x80\x8c\xe1\xa1\xa4", "xn--vkb.xn--08e172a", true); }
test { try toAsciiPass("\xda\xbc\xef\xbd\xa1\xe2\x80\x8dy\xcc\x87\xe2\x80\x8c\xe1\xa1\xa4", "xn--vkb.xn--08e172a", true); }
test { try toAsciiPass("\xda\xbc\xe3\x80\x82\xe2\x80\x8d\xe1\xba\x8f\xe2\x80\x8c\xe1\xa1\xa4", "xn--vkb.xn--08e172a", true); }
test { try toAsciiPass("\xda\xbc\xe3\x80\x82\xe2\x80\x8dy\xcc\x87\xe2\x80\x8c\xe1\xa1\xa4", "xn--vkb.xn--08e172a", true); }
test { try toAsciiPass("\xda\xbc\xe3\x80\x82\xe2\x80\x8dY\xcc\x87\xe2\x80\x8c\xe1\xa1\xa4", "xn--vkb.xn--08e172a", true); }
test { try toAsciiPass("\xda\xbc\xe3\x80\x82\xe2\x80\x8d\xe1\xba\x8e\xe2\x80\x8c\xe1\xa1\xa4", "xn--vkb.xn--08e172a", true); }
test { try toUnicodePass("xn--vkb.xn--08e172a", "\xda\xbc.\xe1\xba\x8f\xe1\xa1\xa4"); }
test { try toAsciiPass("xn--vkb.xn--08e172a", "xn--vkb.xn--08e172a", false); }
test { try toAsciiPass("xn--vkb.xn--08e172a", "xn--vkb.xn--08e172a", true); }
test { try toUnicodePass("\xda\xbc.\xe1\xba\x8f\xe1\xa1\xa4", "\xda\xbc.\xe1\xba\x8f\xe1\xa1\xa4"); }
test { try toAsciiPass("\xda\xbc.\xe1\xba\x8f\xe1\xa1\xa4", "xn--vkb.xn--08e172a", false); }
test { try toAsciiPass("\xda\xbc.\xe1\xba\x8f\xe1\xa1\xa4", "xn--vkb.xn--08e172a", true); }
test { try toUnicodePass("\xda\xbc.y\xcc\x87\xe1\xa1\xa4", "\xda\xbc.\xe1\xba\x8f\xe1\xa1\xa4"); }
test { try toAsciiPass("\xda\xbc.y\xcc\x87\xe1\xa1\xa4", "xn--vkb.xn--08e172a", false); }
test { try toAsciiPass("\xda\xbc.y\xcc\x87\xe1\xa1\xa4", "xn--vkb.xn--08e172a", true); }
test { try toUnicodePass("\xda\xbc.Y\xcc\x87\xe1\xa1\xa4", "\xda\xbc.\xe1\xba\x8f\xe1\xa1\xa4"); }
test { try toAsciiPass("\xda\xbc.Y\xcc\x87\xe1\xa1\xa4", "xn--vkb.xn--08e172a", false); }
test { try toAsciiPass("\xda\xbc.Y\xcc\x87\xe1\xa1\xa4", "xn--vkb.xn--08e172a", true); }
test { try toUnicodePass("\xda\xbc.\xe1\xba\x8e\xe1\xa1\xa4", "\xda\xbc.\xe1\xba\x8f\xe1\xa1\xa4"); }
test { try toAsciiPass("\xda\xbc.\xe1\xba\x8e\xe1\xa1\xa4", "xn--vkb.xn--08e172a", false); }
test { try toAsciiPass("\xda\xbc.\xe1\xba\x8e\xe1\xa1\xa4", "xn--vkb.xn--08e172a", true); }
test { try toAsciiPass("\xda\xbc\xef\xbd\xa1\xe2\x80\x8dY\xcc\x87\xe2\x80\x8c\xe1\xa1\xa4", "xn--vkb.xn--08e172a", true); }
test { try toAsciiPass("\xda\xbc\xef\xbd\xa1\xe2\x80\x8d\xe1\xba\x8e\xe2\x80\x8c\xe1\xa1\xa4", "xn--vkb.xn--08e172a", true); }
test { try toAsciiPass("\xf0\x90\xa9\x97\xe2\x80\x8d\xef\xbd\xa1\xe1\x82\xa9\xe1\x82\xb5", "xn--pt9c.xn--0kjya", true); }
test { try toAsciiPass("\xf0\x90\xa9\x97\xe2\x80\x8d\xe3\x80\x82\xe1\x82\xa9\xe1\x82\xb5", "xn--pt9c.xn--0kjya", true); }
test { try toAsciiPass("\xf0\x90\xa9\x97\xe2\x80\x8d\xe3\x80\x82\xe2\xb4\x89\xe2\xb4\x95", "xn--pt9c.xn--0kjya", true); }
test { try toAsciiPass("\xf0\x90\xa9\x97\xe2\x80\x8d\xe3\x80\x82\xe1\x82\xa9\xe2\xb4\x95", "xn--pt9c.xn--0kjya", true); }
test { try toUnicodePass("xn--pt9c.xn--0kjya", "\xf0\x90\xa9\x97.\xe2\xb4\x89\xe2\xb4\x95"); }
test { try toAsciiPass("xn--pt9c.xn--0kjya", "xn--pt9c.xn--0kjya", false); }
test { try toAsciiPass("xn--pt9c.xn--0kjya", "xn--pt9c.xn--0kjya", true); }
test { try toUnicodePass("\xf0\x90\xa9\x97.\xe2\xb4\x89\xe2\xb4\x95", "\xf0\x90\xa9\x97.\xe2\xb4\x89\xe2\xb4\x95"); }
test { try toAsciiPass("\xf0\x90\xa9\x97.\xe2\xb4\x89\xe2\xb4\x95", "xn--pt9c.xn--0kjya", false); }
test { try toAsciiPass("\xf0\x90\xa9\x97.\xe2\xb4\x89\xe2\xb4\x95", "xn--pt9c.xn--0kjya", true); }
test { try toUnicodePass("\xf0\x90\xa9\x97.\xe1\x82\xa9\xe1\x82\xb5", "\xf0\x90\xa9\x97.\xe2\xb4\x89\xe2\xb4\x95"); }
test { try toAsciiPass("\xf0\x90\xa9\x97.\xe1\x82\xa9\xe1\x82\xb5", "xn--pt9c.xn--0kjya", false); }
test { try toAsciiPass("\xf0\x90\xa9\x97.\xe1\x82\xa9\xe1\x82\xb5", "xn--pt9c.xn--0kjya", true); }
test { try toUnicodePass("\xf0\x90\xa9\x97.\xe1\x82\xa9\xe2\xb4\x95", "\xf0\x90\xa9\x97.\xe2\xb4\x89\xe2\xb4\x95"); }
test { try toAsciiPass("\xf0\x90\xa9\x97.\xe1\x82\xa9\xe2\xb4\x95", "xn--pt9c.xn--0kjya", false); }
test { try toAsciiPass("\xf0\x90\xa9\x97.\xe1\x82\xa9\xe2\xb4\x95", "xn--pt9c.xn--0kjya", true); }
test { try toAsciiPass("\xf0\x90\xa9\x97\xe2\x80\x8d\xef\xbd\xa1\xe2\xb4\x89\xe2\xb4\x95", "xn--pt9c.xn--0kjya", true); }
test { try toAsciiPass("\xf0\x90\xa9\x97\xe2\x80\x8d\xef\xbd\xa1\xe1\x82\xa9\xe2\xb4\x95", "xn--pt9c.xn--0kjya", true); }
test { try toUnicodePass("\xf0\xb2\xa4\xb120.\xe9\x9f\xb3.\xea\xa1\xa61.", "\xf0\xb2\xa4\xb120.\xe9\x9f\xb3.\xea\xa1\xa61."); }
test { try toUnicodePass("xn--20-9802c.xn--0w5a.xn--1-eg4e.", "\xf0\xb2\xa4\xb120.\xe9\x9f\xb3.\xea\xa1\xa61."); }
test { try toUnicodePass("\xe1\x82\xb5\xe3\x80\x82\xdb\xb0\xe2\x89\xae\xc3\x9f\xdd\x85", "\xe2\xb4\x95.\xdb\xb0\xe2\x89\xae\xc3\x9f\xdd\x85"); }
test { try toAsciiPass("\xe1\x82\xb5\xe3\x80\x82\xdb\xb0\xe2\x89\xae\xc3\x9f\xdd\x85", "xn--dlj.xn--zca912alh227g", false); }
test { try toAsciiPass("\xe1\x82\xb5\xe3\x80\x82\xdb\xb0\xe2\x89\xae\xc3\x9f\xdd\x85", "xn--dlj.xn--ss-jbe65aw27i", true); }
test { try toUnicodePass("\xe1\x82\xb5\xe3\x80\x82\xdb\xb0<\xcc\xb8\xc3\x9f\xdd\x85", "\xe2\xb4\x95.\xdb\xb0\xe2\x89\xae\xc3\x9f\xdd\x85"); }
test { try toAsciiPass("\xe1\x82\xb5\xe3\x80\x82\xdb\xb0<\xcc\xb8\xc3\x9f\xdd\x85", "xn--dlj.xn--zca912alh227g", false); }
test { try toAsciiPass("\xe1\x82\xb5\xe3\x80\x82\xdb\xb0<\xcc\xb8\xc3\x9f\xdd\x85", "xn--dlj.xn--ss-jbe65aw27i", true); }
test { try toUnicodePass("\xe2\xb4\x95\xe3\x80\x82\xdb\xb0<\xcc\xb8\xc3\x9f\xdd\x85", "\xe2\xb4\x95.\xdb\xb0\xe2\x89\xae\xc3\x9f\xdd\x85"); }
test { try toAsciiPass("\xe2\xb4\x95\xe3\x80\x82\xdb\xb0<\xcc\xb8\xc3\x9f\xdd\x85", "xn--dlj.xn--zca912alh227g", false); }
test { try toAsciiPass("\xe2\xb4\x95\xe3\x80\x82\xdb\xb0<\xcc\xb8\xc3\x9f\xdd\x85", "xn--dlj.xn--ss-jbe65aw27i", true); }
test { try toUnicodePass("\xe2\xb4\x95\xe3\x80\x82\xdb\xb0\xe2\x89\xae\xc3\x9f\xdd\x85", "\xe2\xb4\x95.\xdb\xb0\xe2\x89\xae\xc3\x9f\xdd\x85"); }
test { try toAsciiPass("\xe2\xb4\x95\xe3\x80\x82\xdb\xb0\xe2\x89\xae\xc3\x9f\xdd\x85", "xn--dlj.xn--zca912alh227g", false); }
test { try toAsciiPass("\xe2\xb4\x95\xe3\x80\x82\xdb\xb0\xe2\x89\xae\xc3\x9f\xdd\x85", "xn--dlj.xn--ss-jbe65aw27i", true); }
test { try toUnicodePass("\xe1\x82\xb5\xe3\x80\x82\xdb\xb0\xe2\x89\xaeSS\xdd\x85", "\xe2\xb4\x95.\xdb\xb0\xe2\x89\xaess\xdd\x85"); }
test { try toAsciiPass("\xe1\x82\xb5\xe3\x80\x82\xdb\xb0\xe2\x89\xaeSS\xdd\x85", "xn--dlj.xn--ss-jbe65aw27i", false); }
test { try toAsciiPass("\xe1\x82\xb5\xe3\x80\x82\xdb\xb0\xe2\x89\xaeSS\xdd\x85", "xn--dlj.xn--ss-jbe65aw27i", true); }
test { try toUnicodePass("\xe1\x82\xb5\xe3\x80\x82\xdb\xb0<\xcc\xb8SS\xdd\x85", "\xe2\xb4\x95.\xdb\xb0\xe2\x89\xaess\xdd\x85"); }
test { try toAsciiPass("\xe1\x82\xb5\xe3\x80\x82\xdb\xb0<\xcc\xb8SS\xdd\x85", "xn--dlj.xn--ss-jbe65aw27i", false); }
test { try toAsciiPass("\xe1\x82\xb5\xe3\x80\x82\xdb\xb0<\xcc\xb8SS\xdd\x85", "xn--dlj.xn--ss-jbe65aw27i", true); }
test { try toUnicodePass("\xe2\xb4\x95\xe3\x80\x82\xdb\xb0<\xcc\xb8ss\xdd\x85", "\xe2\xb4\x95.\xdb\xb0\xe2\x89\xaess\xdd\x85"); }
test { try toAsciiPass("\xe2\xb4\x95\xe3\x80\x82\xdb\xb0<\xcc\xb8ss\xdd\x85", "xn--dlj.xn--ss-jbe65aw27i", false); }
test { try toAsciiPass("\xe2\xb4\x95\xe3\x80\x82\xdb\xb0<\xcc\xb8ss\xdd\x85", "xn--dlj.xn--ss-jbe65aw27i", true); }
test { try toUnicodePass("\xe2\xb4\x95\xe3\x80\x82\xdb\xb0\xe2\x89\xaess\xdd\x85", "\xe2\xb4\x95.\xdb\xb0\xe2\x89\xaess\xdd\x85"); }
test { try toAsciiPass("\xe2\xb4\x95\xe3\x80\x82\xdb\xb0\xe2\x89\xaess\xdd\x85", "xn--dlj.xn--ss-jbe65aw27i", false); }
test { try toAsciiPass("\xe2\xb4\x95\xe3\x80\x82\xdb\xb0\xe2\x89\xaess\xdd\x85", "xn--dlj.xn--ss-jbe65aw27i", true); }
test { try toUnicodePass("\xe1\x82\xb5\xe3\x80\x82\xdb\xb0\xe2\x89\xaeSs\xdd\x85", "\xe2\xb4\x95.\xdb\xb0\xe2\x89\xaess\xdd\x85"); }
test { try toAsciiPass("\xe1\x82\xb5\xe3\x80\x82\xdb\xb0\xe2\x89\xaeSs\xdd\x85", "xn--dlj.xn--ss-jbe65aw27i", false); }
test { try toAsciiPass("\xe1\x82\xb5\xe3\x80\x82\xdb\xb0\xe2\x89\xaeSs\xdd\x85", "xn--dlj.xn--ss-jbe65aw27i", true); }
test { try toUnicodePass("\xe1\x82\xb5\xe3\x80\x82\xdb\xb0<\xcc\xb8Ss\xdd\x85", "\xe2\xb4\x95.\xdb\xb0\xe2\x89\xaess\xdd\x85"); }
test { try toAsciiPass("\xe1\x82\xb5\xe3\x80\x82\xdb\xb0<\xcc\xb8Ss\xdd\x85", "xn--dlj.xn--ss-jbe65aw27i", false); }
test { try toAsciiPass("\xe1\x82\xb5\xe3\x80\x82\xdb\xb0<\xcc\xb8Ss\xdd\x85", "xn--dlj.xn--ss-jbe65aw27i", true); }
test { try toUnicodePass("xn--dlj.xn--ss-jbe65aw27i", "\xe2\xb4\x95.\xdb\xb0\xe2\x89\xaess\xdd\x85"); }
test { try toAsciiPass("xn--dlj.xn--ss-jbe65aw27i", "xn--dlj.xn--ss-jbe65aw27i", false); }
test { try toAsciiPass("xn--dlj.xn--ss-jbe65aw27i", "xn--dlj.xn--ss-jbe65aw27i", true); }
test { try toUnicodePass("\xe2\xb4\x95.\xdb\xb0\xe2\x89\xaess\xdd\x85", "\xe2\xb4\x95.\xdb\xb0\xe2\x89\xaess\xdd\x85"); }
test { try toAsciiPass("\xe2\xb4\x95.\xdb\xb0\xe2\x89\xaess\xdd\x85", "xn--dlj.xn--ss-jbe65aw27i", false); }
test { try toAsciiPass("\xe2\xb4\x95.\xdb\xb0\xe2\x89\xaess\xdd\x85", "xn--dlj.xn--ss-jbe65aw27i", true); }
test { try toUnicodePass("\xe2\xb4\x95.\xdb\xb0<\xcc\xb8ss\xdd\x85", "\xe2\xb4\x95.\xdb\xb0\xe2\x89\xaess\xdd\x85"); }
test { try toAsciiPass("\xe2\xb4\x95.\xdb\xb0<\xcc\xb8ss\xdd\x85", "xn--dlj.xn--ss-jbe65aw27i", false); }
test { try toAsciiPass("\xe2\xb4\x95.\xdb\xb0<\xcc\xb8ss\xdd\x85", "xn--dlj.xn--ss-jbe65aw27i", true); }
test { try toUnicodePass("\xe1\x82\xb5.\xdb\xb0<\xcc\xb8SS\xdd\x85", "\xe2\xb4\x95.\xdb\xb0\xe2\x89\xaess\xdd\x85"); }
test { try toAsciiPass("\xe1\x82\xb5.\xdb\xb0<\xcc\xb8SS\xdd\x85", "xn--dlj.xn--ss-jbe65aw27i", false); }
test { try toAsciiPass("\xe1\x82\xb5.\xdb\xb0<\xcc\xb8SS\xdd\x85", "xn--dlj.xn--ss-jbe65aw27i", true); }
test { try toUnicodePass("\xe1\x82\xb5.\xdb\xb0\xe2\x89\xaeSS\xdd\x85", "\xe2\xb4\x95.\xdb\xb0\xe2\x89\xaess\xdd\x85"); }
test { try toAsciiPass("\xe1\x82\xb5.\xdb\xb0\xe2\x89\xaeSS\xdd\x85", "xn--dlj.xn--ss-jbe65aw27i", false); }
test { try toAsciiPass("\xe1\x82\xb5.\xdb\xb0\xe2\x89\xaeSS\xdd\x85", "xn--dlj.xn--ss-jbe65aw27i", true); }
test { try toUnicodePass("\xe1\x82\xb5.\xdb\xb0\xe2\x89\xaeSs\xdd\x85", "\xe2\xb4\x95.\xdb\xb0\xe2\x89\xaess\xdd\x85"); }
test { try toAsciiPass("\xe1\x82\xb5.\xdb\xb0\xe2\x89\xaeSs\xdd\x85", "xn--dlj.xn--ss-jbe65aw27i", false); }
test { try toAsciiPass("\xe1\x82\xb5.\xdb\xb0\xe2\x89\xaeSs\xdd\x85", "xn--dlj.xn--ss-jbe65aw27i", true); }
test { try toUnicodePass("\xe1\x82\xb5.\xdb\xb0<\xcc\xb8Ss\xdd\x85", "\xe2\xb4\x95.\xdb\xb0\xe2\x89\xaess\xdd\x85"); }
test { try toAsciiPass("\xe1\x82\xb5.\xdb\xb0<\xcc\xb8Ss\xdd\x85", "xn--dlj.xn--ss-jbe65aw27i", false); }
test { try toAsciiPass("\xe1\x82\xb5.\xdb\xb0<\xcc\xb8Ss\xdd\x85", "xn--dlj.xn--ss-jbe65aw27i", true); }
test { try toUnicodePass("xn--dlj.xn--zca912alh227g", "\xe2\xb4\x95.\xdb\xb0\xe2\x89\xae\xc3\x9f\xdd\x85"); }
test { try toAsciiPass("xn--dlj.xn--zca912alh227g", "xn--dlj.xn--zca912alh227g", false); }
test { try toAsciiPass("xn--dlj.xn--zca912alh227g", "xn--dlj.xn--zca912alh227g", true); }
test { try toUnicodePass("\xe2\xb4\x95.\xdb\xb0\xe2\x89\xae\xc3\x9f\xdd\x85", "\xe2\xb4\x95.\xdb\xb0\xe2\x89\xae\xc3\x9f\xdd\x85"); }
test { try toAsciiPass("\xe2\xb4\x95.\xdb\xb0\xe2\x89\xae\xc3\x9f\xdd\x85", "xn--dlj.xn--zca912alh227g", false); }
test { try toAsciiPass("\xe2\xb4\x95.\xdb\xb0\xe2\x89\xae\xc3\x9f\xdd\x85", "xn--dlj.xn--ss-jbe65aw27i", true); }
test { try toUnicodePass("\xe2\xb4\x95.\xdb\xb0<\xcc\xb8\xc3\x9f\xdd\x85", "\xe2\xb4\x95.\xdb\xb0\xe2\x89\xae\xc3\x9f\xdd\x85"); }
test { try toAsciiPass("\xe2\xb4\x95.\xdb\xb0<\xcc\xb8\xc3\x9f\xdd\x85", "xn--dlj.xn--zca912alh227g", false); }
test { try toAsciiPass("\xe2\xb4\x95.\xdb\xb0<\xcc\xb8\xc3\x9f\xdd\x85", "xn--dlj.xn--ss-jbe65aw27i", true); }
test { try toAsciiPass("\xf0\x9e\xa4\xa8\xef\xbd\xa1\xea\xa1\x8f\xe2\x80\x8d\xe2\x80\x8c", "xn--ge6h.xn--oc9a", true); }
test { try toAsciiPass("\xf0\x9e\xa4\xa8\xe3\x80\x82\xea\xa1\x8f\xe2\x80\x8d\xe2\x80\x8c", "xn--ge6h.xn--oc9a", true); }
test { try toAsciiPass("\xf0\x9e\xa4\x86\xe3\x80\x82\xea\xa1\x8f\xe2\x80\x8d\xe2\x80\x8c", "xn--ge6h.xn--oc9a", true); }
test { try toUnicodePass("xn--ge6h.xn--oc9a", "\xf0\x9e\xa4\xa8.\xea\xa1\x8f"); }
test { try toAsciiPass("xn--ge6h.xn--oc9a", "xn--ge6h.xn--oc9a", false); }
test { try toAsciiPass("xn--ge6h.xn--oc9a", "xn--ge6h.xn--oc9a", true); }
test { try toUnicodePass("\xf0\x9e\xa4\xa8.\xea\xa1\x8f", "\xf0\x9e\xa4\xa8.\xea\xa1\x8f"); }
test { try toAsciiPass("\xf0\x9e\xa4\xa8.\xea\xa1\x8f", "xn--ge6h.xn--oc9a", false); }
test { try toAsciiPass("\xf0\x9e\xa4\xa8.\xea\xa1\x8f", "xn--ge6h.xn--oc9a", true); }
test { try toUnicodePass("\xf0\x9e\xa4\x86.\xea\xa1\x8f", "\xf0\x9e\xa4\xa8.\xea\xa1\x8f"); }
test { try toAsciiPass("\xf0\x9e\xa4\x86.\xea\xa1\x8f", "xn--ge6h.xn--oc9a", false); }
test { try toAsciiPass("\xf0\x9e\xa4\x86.\xea\xa1\x8f", "xn--ge6h.xn--oc9a", true); }
test { try toAsciiPass("\xf0\x9e\xa4\x86\xef\xbd\xa1\xea\xa1\x8f\xe2\x80\x8d\xe2\x80\x8c", "xn--ge6h.xn--oc9a", true); }
test { try toUnicodePass("\xe9\xbd\x99--\xf0\x9d\x9f\xb0.\xc3\x9f", "\xe9\xbd\x99--4.\xc3\x9f"); }
test { try toAsciiPass("\xe9\xbd\x99--\xf0\x9d\x9f\xb0.\xc3\x9f", "xn----4-p16k.xn--zca", false); }
test { try toAsciiPass("\xe9\xbd\x99--\xf0\x9d\x9f\xb0.\xc3\x9f", "xn----4-p16k.ss", true); }
test { try toUnicodePass("\xe9\xbd\x99--4.\xc3\x9f", "\xe9\xbd\x99--4.\xc3\x9f"); }
test { try toAsciiPass("\xe9\xbd\x99--4.\xc3\x9f", "xn----4-p16k.xn--zca", false); }
test { try toAsciiPass("\xe9\xbd\x99--4.\xc3\x9f", "xn----4-p16k.ss", true); }
test { try toUnicodePass("\xe9\xbd\x99--4.SS", "\xe9\xbd\x99--4.ss"); }
test { try toAsciiPass("\xe9\xbd\x99--4.SS", "xn----4-p16k.ss", false); }
test { try toAsciiPass("\xe9\xbd\x99--4.SS", "xn----4-p16k.ss", true); }
test { try toUnicodePass("\xe9\xbd\x99--4.ss", "\xe9\xbd\x99--4.ss"); }
test { try toAsciiPass("\xe9\xbd\x99--4.ss", "xn----4-p16k.ss", false); }
test { try toAsciiPass("\xe9\xbd\x99--4.ss", "xn----4-p16k.ss", true); }
test { try toUnicodePass("\xe9\xbd\x99--4.Ss", "\xe9\xbd\x99--4.ss"); }
test { try toAsciiPass("\xe9\xbd\x99--4.Ss", "xn----4-p16k.ss", false); }
test { try toAsciiPass("\xe9\xbd\x99--4.Ss", "xn----4-p16k.ss", true); }
test { try toUnicodePass("xn----4-p16k.ss", "\xe9\xbd\x99--4.ss"); }
test { try toAsciiPass("xn----4-p16k.ss", "xn----4-p16k.ss", false); }
test { try toAsciiPass("xn----4-p16k.ss", "xn----4-p16k.ss", true); }
test { try toUnicodePass("xn----4-p16k.xn--zca", "\xe9\xbd\x99--4.\xc3\x9f"); }
test { try toAsciiPass("xn----4-p16k.xn--zca", "xn----4-p16k.xn--zca", false); }
test { try toAsciiPass("xn----4-p16k.xn--zca", "xn----4-p16k.xn--zca", true); }
test { try toUnicodePass("\xe9\xbd\x99--\xf0\x9d\x9f\xb0.SS", "\xe9\xbd\x99--4.ss"); }
test { try toAsciiPass("\xe9\xbd\x99--\xf0\x9d\x9f\xb0.SS", "xn----4-p16k.ss", false); }
test { try toAsciiPass("\xe9\xbd\x99--\xf0\x9d\x9f\xb0.SS", "xn----4-p16k.ss", true); }
test { try toUnicodePass("\xe9\xbd\x99--\xf0\x9d\x9f\xb0.ss", "\xe9\xbd\x99--4.ss"); }
test { try toAsciiPass("\xe9\xbd\x99--\xf0\x9d\x9f\xb0.ss", "xn----4-p16k.ss", false); }
test { try toAsciiPass("\xe9\xbd\x99--\xf0\x9d\x9f\xb0.ss", "xn----4-p16k.ss", true); }
test { try toUnicodePass("\xe9\xbd\x99--\xf0\x9d\x9f\xb0.Ss", "\xe9\xbd\x99--4.ss"); }
test { try toAsciiPass("\xe9\xbd\x99--\xf0\x9d\x9f\xb0.Ss", "xn----4-p16k.ss", false); }
test { try toAsciiPass("\xe9\xbd\x99--\xf0\x9d\x9f\xb0.Ss", "xn----4-p16k.ss", true); }
test { try toAsciiPass("\xf0\xb2\xae\x9a\xef\xbc\x99\xea\x8d\xa9\xe1\x9f\x93\xef\xbc\x8e\xe2\x80\x8d\xc3\x9f", "xn--9-i0j5967eg3qz.ss", true); }
test { try toAsciiPass("\xf0\xb2\xae\x9a9\xea\x8d\xa9\xe1\x9f\x93.\xe2\x80\x8d\xc3\x9f", "xn--9-i0j5967eg3qz.ss", true); }
test { try toAsciiPass("\xf0\xb2\xae\x9a9\xea\x8d\xa9\xe1\x9f\x93.\xe2\x80\x8dSS", "xn--9-i0j5967eg3qz.ss", true); }
test { try toAsciiPass("\xf0\xb2\xae\x9a9\xea\x8d\xa9\xe1\x9f\x93.\xe2\x80\x8dss", "xn--9-i0j5967eg3qz.ss", true); }
test { try toUnicodePass("xn--9-i0j5967eg3qz.ss", "\xf0\xb2\xae\x9a9\xea\x8d\xa9\xe1\x9f\x93.ss"); }
test { try toAsciiPass("xn--9-i0j5967eg3qz.ss", "xn--9-i0j5967eg3qz.ss", false); }
test { try toAsciiPass("xn--9-i0j5967eg3qz.ss", "xn--9-i0j5967eg3qz.ss", true); }
test { try toUnicodePass("\xf0\xb2\xae\x9a9\xea\x8d\xa9\xe1\x9f\x93.ss", "\xf0\xb2\xae\x9a9\xea\x8d\xa9\xe1\x9f\x93.ss"); }
test { try toAsciiPass("\xf0\xb2\xae\x9a9\xea\x8d\xa9\xe1\x9f\x93.ss", "xn--9-i0j5967eg3qz.ss", false); }
test { try toAsciiPass("\xf0\xb2\xae\x9a9\xea\x8d\xa9\xe1\x9f\x93.ss", "xn--9-i0j5967eg3qz.ss", true); }
test { try toUnicodePass("\xf0\xb2\xae\x9a9\xea\x8d\xa9\xe1\x9f\x93.SS", "\xf0\xb2\xae\x9a9\xea\x8d\xa9\xe1\x9f\x93.ss"); }
test { try toAsciiPass("\xf0\xb2\xae\x9a9\xea\x8d\xa9\xe1\x9f\x93.SS", "xn--9-i0j5967eg3qz.ss", false); }
test { try toAsciiPass("\xf0\xb2\xae\x9a9\xea\x8d\xa9\xe1\x9f\x93.SS", "xn--9-i0j5967eg3qz.ss", true); }
test { try toAsciiPass("\xf0\xb2\xae\x9a\xef\xbc\x99\xea\x8d\xa9\xe1\x9f\x93\xef\xbc\x8e\xe2\x80\x8dSS", "xn--9-i0j5967eg3qz.ss", true); }
test { try toAsciiPass("\xf0\xb2\xae\x9a\xef\xbc\x99\xea\x8d\xa9\xe1\x9f\x93\xef\xbc\x8e\xe2\x80\x8dss", "xn--9-i0j5967eg3qz.ss", true); }
test { try toAsciiPass("\xf0\xb2\xae\x9a9\xea\x8d\xa9\xe1\x9f\x93.\xe2\x80\x8dSs", "xn--9-i0j5967eg3qz.ss", true); }
test { try toAsciiPass("\xf0\xb2\xae\x9a\xef\xbc\x99\xea\x8d\xa9\xe1\x9f\x93\xef\xbc\x8e\xe2\x80\x8dSs", "xn--9-i0j5967eg3qz.ss", true); }
test { try toUnicodePass("\xea\x97\xb7\xf0\x91\x86\x80.\xdd\x9d\xf0\x90\xa9\x92", "\xea\x97\xb7\xf0\x91\x86\x80.\xdd\x9d\xf0\x90\xa9\x92"); }
test { try toAsciiPass("\xea\x97\xb7\xf0\x91\x86\x80.\xdd\x9d\xf0\x90\xa9\x92", "xn--ju8a625r.xn--hpb0073k", false); }
test { try toAsciiPass("\xea\x97\xb7\xf0\x91\x86\x80.\xdd\x9d\xf0\x90\xa9\x92", "xn--ju8a625r.xn--hpb0073k", true); }
test { try toUnicodePass("xn--ju8a625r.xn--hpb0073k", "\xea\x97\xb7\xf0\x91\x86\x80.\xdd\x9d\xf0\x90\xa9\x92"); }
test { try toAsciiPass("xn--ju8a625r.xn--hpb0073k", "xn--ju8a625r.xn--hpb0073k", false); }
test { try toAsciiPass("xn--ju8a625r.xn--hpb0073k", "xn--ju8a625r.xn--hpb0073k", true); }
test { try toUnicodePass("\xcf\x82.\xd9\x81\xd9\x85\xd9\x8a\xf0\x9f\x9e\x9b1.", "\xcf\x82.\xd9\x81\xd9\x85\xd9\x8a\xf0\x9f\x9e\x9b1."); }
test { try toUnicodePass("\xce\xa3.\xd9\x81\xd9\x85\xd9\x8a\xf0\x9f\x9e\x9b1.", "\xcf\x83.\xd9\x81\xd9\x85\xd9\x8a\xf0\x9f\x9e\x9b1."); }
test { try toUnicodePass("\xcf\x83.\xd9\x81\xd9\x85\xd9\x8a\xf0\x9f\x9e\x9b1.", "\xcf\x83.\xd9\x81\xd9\x85\xd9\x8a\xf0\x9f\x9e\x9b1."); }
test { try toUnicodePass("xn--4xa.xn--1-gocmu97674d.", "\xcf\x83.\xd9\x81\xd9\x85\xd9\x8a\xf0\x9f\x9e\x9b1."); }
test { try toUnicodePass("xn--3xa.xn--1-gocmu97674d.", "\xcf\x82.\xd9\x81\xd9\x85\xd9\x8a\xf0\x9f\x9e\x9b1."); }
test { try toUnicodePass("xn--hva754s.", "\xe2\xb4\x96\xcd\xa6."); }
test { try toUnicodePass("\xe2\xb4\x96\xcd\xa6.", "\xe2\xb4\x96\xcd\xa6."); }
test { try toUnicodePass("\xe1\x82\xb6\xcd\xa6.", "\xe2\xb4\x96\xcd\xa6."); }
test { try toAsciiPass("\xe0\xa2\xbb\xef\xbc\x8e\xe2\x80\x8c\xe1\x82\xa3\xf0\x9e\x80\x92", "xn--hzb.xn--ukj4430l", true); }
test { try toAsciiPass("\xe0\xa2\xbb.\xe2\x80\x8c\xe1\x82\xa3\xf0\x9e\x80\x92", "xn--hzb.xn--ukj4430l", true); }
test { try toAsciiPass("\xe0\xa2\xbb.\xe2\x80\x8c\xe2\xb4\x83\xf0\x9e\x80\x92", "xn--hzb.xn--ukj4430l", true); }
test { try toUnicodePass("xn--hzb.xn--ukj4430l", "\xe0\xa2\xbb.\xe2\xb4\x83\xf0\x9e\x80\x92"); }
test { try toAsciiPass("xn--hzb.xn--ukj4430l", "xn--hzb.xn--ukj4430l", false); }
test { try toAsciiPass("xn--hzb.xn--ukj4430l", "xn--hzb.xn--ukj4430l", true); }
test { try toUnicodePass("\xe0\xa2\xbb.\xe2\xb4\x83\xf0\x9e\x80\x92", "\xe0\xa2\xbb.\xe2\xb4\x83\xf0\x9e\x80\x92"); }
test { try toAsciiPass("\xe0\xa2\xbb.\xe2\xb4\x83\xf0\x9e\x80\x92", "xn--hzb.xn--ukj4430l", false); }
test { try toAsciiPass("\xe0\xa2\xbb.\xe2\xb4\x83\xf0\x9e\x80\x92", "xn--hzb.xn--ukj4430l", true); }
test { try toUnicodePass("\xe0\xa2\xbb.\xe1\x82\xa3\xf0\x9e\x80\x92", "\xe0\xa2\xbb.\xe2\xb4\x83\xf0\x9e\x80\x92"); }
test { try toAsciiPass("\xe0\xa2\xbb.\xe1\x82\xa3\xf0\x9e\x80\x92", "xn--hzb.xn--ukj4430l", false); }
test { try toAsciiPass("\xe0\xa2\xbb.\xe1\x82\xa3\xf0\x9e\x80\x92", "xn--hzb.xn--ukj4430l", true); }
test { try toAsciiPass("\xe0\xa2\xbb\xef\xbc\x8e\xe2\x80\x8c\xe2\xb4\x83\xf0\x9e\x80\x92", "xn--hzb.xn--ukj4430l", true); }
test { try toAsciiPass("\xe2\x80\x8d\xe6\x94\x8c\xea\xaf\xad\xe3\x80\x82\xe1\xa2\x96-\xe1\x82\xb8", "xn--p9ut19m.xn----mck373i", true); }
test { try toAsciiPass("\xe2\x80\x8d\xe6\x94\x8c\xea\xaf\xad\xe3\x80\x82\xe1\xa2\x96-\xe2\xb4\x98", "xn--p9ut19m.xn----mck373i", true); }
test { try toUnicodePass("xn--p9ut19m.xn----mck373i", "\xe6\x94\x8c\xea\xaf\xad.\xe1\xa2\x96-\xe2\xb4\x98"); }
test { try toAsciiPass("xn--p9ut19m.xn----mck373i", "xn--p9ut19m.xn----mck373i", false); }
test { try toAsciiPass("xn--p9ut19m.xn----mck373i", "xn--p9ut19m.xn----mck373i", true); }
test { try toUnicodePass("\xe6\x94\x8c\xea\xaf\xad.\xe1\xa2\x96-\xe2\xb4\x98", "\xe6\x94\x8c\xea\xaf\xad.\xe1\xa2\x96-\xe2\xb4\x98"); }
test { try toAsciiPass("\xe6\x94\x8c\xea\xaf\xad.\xe1\xa2\x96-\xe2\xb4\x98", "xn--p9ut19m.xn----mck373i", false); }
test { try toAsciiPass("\xe6\x94\x8c\xea\xaf\xad.\xe1\xa2\x96-\xe2\xb4\x98", "xn--p9ut19m.xn----mck373i", true); }
test { try toUnicodePass("\xe6\x94\x8c\xea\xaf\xad.\xe1\xa2\x96-\xe1\x82\xb8", "\xe6\x94\x8c\xea\xaf\xad.\xe1\xa2\x96-\xe2\xb4\x98"); }
test { try toAsciiPass("\xe6\x94\x8c\xea\xaf\xad.\xe1\xa2\x96-\xe1\x82\xb8", "xn--p9ut19m.xn----mck373i", false); }
test { try toAsciiPass("\xe6\x94\x8c\xea\xaf\xad.\xe1\xa2\x96-\xe1\x82\xb8", "xn--p9ut19m.xn----mck373i", true); }
test { try toAsciiPass("\xe2\x80\x8c\xea\x96\xa8.16.3\xed\x88\x92\xdb\xb3", "xn--9r8a.16.xn--3-nyc0117m", true); }
test { try toAsciiPass("\xe2\x80\x8c\xea\x96\xa8.16.3\xe1\x84\x90\xe1\x85\xad\xe1\x86\xa9\xdb\xb3", "xn--9r8a.16.xn--3-nyc0117m", true); }
test { try toUnicodePass("xn--9r8a.16.xn--3-nyc0117m", "\xea\x96\xa8.16.3\xed\x88\x92\xdb\xb3"); }
test { try toAsciiPass("xn--9r8a.16.xn--3-nyc0117m", "xn--9r8a.16.xn--3-nyc0117m", false); }
test { try toAsciiPass("xn--9r8a.16.xn--3-nyc0117m", "xn--9r8a.16.xn--3-nyc0117m", true); }
test { try toUnicodePass("\xea\x96\xa8.16.3\xed\x88\x92\xdb\xb3", "\xea\x96\xa8.16.3\xed\x88\x92\xdb\xb3"); }
test { try toAsciiPass("\xea\x96\xa8.16.3\xed\x88\x92\xdb\xb3", "xn--9r8a.16.xn--3-nyc0117m", false); }
test { try toAsciiPass("\xea\x96\xa8.16.3\xed\x88\x92\xdb\xb3", "xn--9r8a.16.xn--3-nyc0117m", true); }
test { try toUnicodePass("\xea\x96\xa8.16.3\xe1\x84\x90\xe1\x85\xad\xe1\x86\xa9\xdb\xb3", "\xea\x96\xa8.16.3\xed\x88\x92\xdb\xb3"); }
test { try toAsciiPass("\xea\x96\xa8.16.3\xe1\x84\x90\xe1\x85\xad\xe1\x86\xa9\xdb\xb3", "xn--9r8a.16.xn--3-nyc0117m", false); }
test { try toAsciiPass("\xea\x96\xa8.16.3\xe1\x84\x90\xe1\x85\xad\xe1\x86\xa9\xdb\xb3", "xn--9r8a.16.xn--3-nyc0117m", true); }
test { try toUnicodePass("xn--1-5bt6845n.", "1\xf0\x9d\xa8\x99\xe2\xb8\x96."); }
test { try toUnicodePass("1\xf0\x9d\xa8\x99\xe2\xb8\x96.", "1\xf0\x9d\xa8\x99\xe2\xb8\x96."); }
test { try toUnicodePass("xn--ss-f4j.b.", "ss\xe1\x80\xba.b."); }
test { try toUnicodePass("ss\xe1\x80\xba.b.", "ss\xe1\x80\xba.b."); }
test { try toUnicodePass("SS\xe1\x80\xba.B.", "ss\xe1\x80\xba.b."); }
test { try toUnicodePass("Ss\xe1\x80\xba.b.", "ss\xe1\x80\xba.b."); }
test { try toUnicodePass("SS\xe1\x80\xba.b.", "ss\xe1\x80\xba.b."); }
test { try toUnicodePass("\xdb\x8c\xf0\x90\xa8\xbf\xef\xbc\x8e\xc3\x9f\xe0\xbe\x84\xf0\x91\x8d\xac", "\xdb\x8c\xf0\x90\xa8\xbf.\xc3\x9f\xe0\xbe\x84\xf0\x91\x8d\xac"); }
test { try toAsciiPass("\xdb\x8c\xf0\x90\xa8\xbf\xef\xbc\x8e\xc3\x9f\xe0\xbe\x84\xf0\x91\x8d\xac", "xn--clb2593k.xn--zca216edt0r", false); }
test { try toAsciiPass("\xdb\x8c\xf0\x90\xa8\xbf\xef\xbc\x8e\xc3\x9f\xe0\xbe\x84\xf0\x91\x8d\xac", "xn--clb2593k.xn--ss-toj6092t", true); }
test { try toUnicodePass("\xdb\x8c\xf0\x90\xa8\xbf.\xc3\x9f\xe0\xbe\x84\xf0\x91\x8d\xac", "\xdb\x8c\xf0\x90\xa8\xbf.\xc3\x9f\xe0\xbe\x84\xf0\x91\x8d\xac"); }
test { try toAsciiPass("\xdb\x8c\xf0\x90\xa8\xbf.\xc3\x9f\xe0\xbe\x84\xf0\x91\x8d\xac", "xn--clb2593k.xn--zca216edt0r", false); }
test { try toAsciiPass("\xdb\x8c\xf0\x90\xa8\xbf.\xc3\x9f\xe0\xbe\x84\xf0\x91\x8d\xac", "xn--clb2593k.xn--ss-toj6092t", true); }
test { try toUnicodePass("\xdb\x8c\xf0\x90\xa8\xbf.SS\xe0\xbe\x84\xf0\x91\x8d\xac", "\xdb\x8c\xf0\x90\xa8\xbf.ss\xe0\xbe\x84\xf0\x91\x8d\xac"); }
test { try toAsciiPass("\xdb\x8c\xf0\x90\xa8\xbf.SS\xe0\xbe\x84\xf0\x91\x8d\xac", "xn--clb2593k.xn--ss-toj6092t", false); }
test { try toAsciiPass("\xdb\x8c\xf0\x90\xa8\xbf.SS\xe0\xbe\x84\xf0\x91\x8d\xac", "xn--clb2593k.xn--ss-toj6092t", true); }
test { try toUnicodePass("\xdb\x8c\xf0\x90\xa8\xbf.ss\xe0\xbe\x84\xf0\x91\x8d\xac", "\xdb\x8c\xf0\x90\xa8\xbf.ss\xe0\xbe\x84\xf0\x91\x8d\xac"); }
test { try toAsciiPass("\xdb\x8c\xf0\x90\xa8\xbf.ss\xe0\xbe\x84\xf0\x91\x8d\xac", "xn--clb2593k.xn--ss-toj6092t", false); }
test { try toAsciiPass("\xdb\x8c\xf0\x90\xa8\xbf.ss\xe0\xbe\x84\xf0\x91\x8d\xac", "xn--clb2593k.xn--ss-toj6092t", true); }
test { try toUnicodePass("xn--clb2593k.xn--ss-toj6092t", "\xdb\x8c\xf0\x90\xa8\xbf.ss\xe0\xbe\x84\xf0\x91\x8d\xac"); }
test { try toAsciiPass("xn--clb2593k.xn--ss-toj6092t", "xn--clb2593k.xn--ss-toj6092t", false); }
test { try toAsciiPass("xn--clb2593k.xn--ss-toj6092t", "xn--clb2593k.xn--ss-toj6092t", true); }
test { try toUnicodePass("xn--clb2593k.xn--zca216edt0r", "\xdb\x8c\xf0\x90\xa8\xbf.\xc3\x9f\xe0\xbe\x84\xf0\x91\x8d\xac"); }
test { try toAsciiPass("xn--clb2593k.xn--zca216edt0r", "xn--clb2593k.xn--zca216edt0r", false); }
test { try toAsciiPass("xn--clb2593k.xn--zca216edt0r", "xn--clb2593k.xn--zca216edt0r", true); }
test { try toUnicodePass("\xdb\x8c\xf0\x90\xa8\xbf\xef\xbc\x8eSS\xe0\xbe\x84\xf0\x91\x8d\xac", "\xdb\x8c\xf0\x90\xa8\xbf.ss\xe0\xbe\x84\xf0\x91\x8d\xac"); }
test { try toAsciiPass("\xdb\x8c\xf0\x90\xa8\xbf\xef\xbc\x8eSS\xe0\xbe\x84\xf0\x91\x8d\xac", "xn--clb2593k.xn--ss-toj6092t", false); }
test { try toAsciiPass("\xdb\x8c\xf0\x90\xa8\xbf\xef\xbc\x8eSS\xe0\xbe\x84\xf0\x91\x8d\xac", "xn--clb2593k.xn--ss-toj6092t", true); }
test { try toUnicodePass("\xdb\x8c\xf0\x90\xa8\xbf\xef\xbc\x8ess\xe0\xbe\x84\xf0\x91\x8d\xac", "\xdb\x8c\xf0\x90\xa8\xbf.ss\xe0\xbe\x84\xf0\x91\x8d\xac"); }
test { try toAsciiPass("\xdb\x8c\xf0\x90\xa8\xbf\xef\xbc\x8ess\xe0\xbe\x84\xf0\x91\x8d\xac", "xn--clb2593k.xn--ss-toj6092t", false); }
test { try toAsciiPass("\xdb\x8c\xf0\x90\xa8\xbf\xef\xbc\x8ess\xe0\xbe\x84\xf0\x91\x8d\xac", "xn--clb2593k.xn--ss-toj6092t", true); }
test { try toUnicodePass("\xdb\x8c\xf0\x90\xa8\xbf.Ss\xe0\xbe\x84\xf0\x91\x8d\xac", "\xdb\x8c\xf0\x90\xa8\xbf.ss\xe0\xbe\x84\xf0\x91\x8d\xac"); }
test { try toAsciiPass("\xdb\x8c\xf0\x90\xa8\xbf.Ss\xe0\xbe\x84\xf0\x91\x8d\xac", "xn--clb2593k.xn--ss-toj6092t", false); }
test { try toAsciiPass("\xdb\x8c\xf0\x90\xa8\xbf.Ss\xe0\xbe\x84\xf0\x91\x8d\xac", "xn--clb2593k.xn--ss-toj6092t", true); }
test { try toUnicodePass("\xdb\x8c\xf0\x90\xa8\xbf\xef\xbc\x8eSs\xe0\xbe\x84\xf0\x91\x8d\xac", "\xdb\x8c\xf0\x90\xa8\xbf.ss\xe0\xbe\x84\xf0\x91\x8d\xac"); }
test { try toAsciiPass("\xdb\x8c\xf0\x90\xa8\xbf\xef\xbc\x8eSs\xe0\xbe\x84\xf0\x91\x8d\xac", "xn--clb2593k.xn--ss-toj6092t", false); }
test { try toAsciiPass("\xdb\x8c\xf0\x90\xa8\xbf\xef\xbc\x8eSs\xe0\xbe\x84\xf0\x91\x8d\xac", "xn--clb2593k.xn--ss-toj6092t", true); }
test { try toUnicodePass("xn--8-ngo.", "8\xe2\x89\xae."); }
test { try toUnicodePass("8\xe2\x89\xae.", "8\xe2\x89\xae."); }
test { try toUnicodePass("8<\xcc\xb8.", "8\xe2\x89\xae."); }
test { try toUnicodePass("\xe7\xbe\x9a\xef\xbd\xa1\xe2\x89\xaf", "\xe7\xbe\x9a.\xe2\x89\xaf"); }
test { try toAsciiPass("\xe7\xbe\x9a\xef\xbd\xa1\xe2\x89\xaf", "xn--xt0a.xn--hdh", false); }
test { try toAsciiPass("\xe7\xbe\x9a\xef\xbd\xa1\xe2\x89\xaf", "xn--xt0a.xn--hdh", true); }
test { try toUnicodePass("\xe7\xbe\x9a\xef\xbd\xa1>\xcc\xb8", "\xe7\xbe\x9a.\xe2\x89\xaf"); }
test { try toAsciiPass("\xe7\xbe\x9a\xef\xbd\xa1>\xcc\xb8", "xn--xt0a.xn--hdh", false); }
test { try toAsciiPass("\xe7\xbe\x9a\xef\xbd\xa1>\xcc\xb8", "xn--xt0a.xn--hdh", true); }
test { try toUnicodePass("\xe7\xbe\x9a\xe3\x80\x82\xe2\x89\xaf", "\xe7\xbe\x9a.\xe2\x89\xaf"); }
test { try toAsciiPass("\xe7\xbe\x9a\xe3\x80\x82\xe2\x89\xaf", "xn--xt0a.xn--hdh", false); }
test { try toAsciiPass("\xe7\xbe\x9a\xe3\x80\x82\xe2\x89\xaf", "xn--xt0a.xn--hdh", true); }
test { try toUnicodePass("\xe7\xbe\x9a\xe3\x80\x82>\xcc\xb8", "\xe7\xbe\x9a.\xe2\x89\xaf"); }
test { try toAsciiPass("\xe7\xbe\x9a\xe3\x80\x82>\xcc\xb8", "xn--xt0a.xn--hdh", false); }
test { try toAsciiPass("\xe7\xbe\x9a\xe3\x80\x82>\xcc\xb8", "xn--xt0a.xn--hdh", true); }
test { try toUnicodePass("xn--xt0a.xn--hdh", "\xe7\xbe\x9a.\xe2\x89\xaf"); }
test { try toAsciiPass("xn--xt0a.xn--hdh", "xn--xt0a.xn--hdh", false); }
test { try toAsciiPass("xn--xt0a.xn--hdh", "xn--xt0a.xn--hdh", true); }
test { try toUnicodePass("\xe7\xbe\x9a.\xe2\x89\xaf", "\xe7\xbe\x9a.\xe2\x89\xaf"); }
test { try toAsciiPass("\xe7\xbe\x9a.\xe2\x89\xaf", "xn--xt0a.xn--hdh", false); }
test { try toAsciiPass("\xe7\xbe\x9a.\xe2\x89\xaf", "xn--xt0a.xn--hdh", true); }
test { try toUnicodePass("\xe7\xbe\x9a.>\xcc\xb8", "\xe7\xbe\x9a.\xe2\x89\xaf"); }
test { try toAsciiPass("\xe7\xbe\x9a.>\xcc\xb8", "xn--xt0a.xn--hdh", false); }
test { try toAsciiPass("\xe7\xbe\x9a.>\xcc\xb8", "xn--xt0a.xn--hdh", true); }
test { try toUnicodePass("xn--ye6h", "\xf0\x9e\xa4\xba"); }
test { try toAsciiPass("xn--ye6h", "xn--ye6h", false); }
test { try toAsciiPass("xn--ye6h", "xn--ye6h", true); }
test { try toUnicodePass("\xf0\x9e\xa4\xba", "\xf0\x9e\xa4\xba"); }
test { try toAsciiPass("\xf0\x9e\xa4\xba", "xn--ye6h", false); }
test { try toAsciiPass("\xf0\x9e\xa4\xba", "xn--ye6h", true); }
test { try toUnicodePass("\xf0\x9e\xa4\x98", "\xf0\x9e\xa4\xba"); }
test { try toAsciiPass("\xf0\x9e\xa4\x98", "xn--ye6h", false); }
test { try toAsciiPass("\xf0\x9e\xa4\x98", "xn--ye6h", true); }
test { try toUnicodePass("\xf0\x9d\x9f\x9b\xef\xbc\x8e\xef\xa7\xb8", "3.\xe7\xac\xa0"); }
test { try toAsciiPass("\xf0\x9d\x9f\x9b\xef\xbc\x8e\xef\xa7\xb8", "3.xn--6vz", false); }
test { try toAsciiPass("\xf0\x9d\x9f\x9b\xef\xbc\x8e\xef\xa7\xb8", "3.xn--6vz", true); }
test { try toUnicodePass("\xf0\x9d\x9f\x9b\xef\xbc\x8e\xe7\xac\xa0", "3.\xe7\xac\xa0"); }
test { try toAsciiPass("\xf0\x9d\x9f\x9b\xef\xbc\x8e\xe7\xac\xa0", "3.xn--6vz", false); }
test { try toAsciiPass("\xf0\x9d\x9f\x9b\xef\xbc\x8e\xe7\xac\xa0", "3.xn--6vz", true); }
test { try toUnicodePass("3.\xe7\xac\xa0", "3.\xe7\xac\xa0"); }
test { try toAsciiPass("3.\xe7\xac\xa0", "3.xn--6vz", false); }
test { try toAsciiPass("3.\xe7\xac\xa0", "3.xn--6vz", true); }
test { try toUnicodePass("3.xn--6vz", "3.\xe7\xac\xa0"); }
test { try toAsciiPass("3.xn--6vz", "3.xn--6vz", false); }
test { try toAsciiPass("3.xn--6vz", "3.xn--6vz", true); }
test { try toUnicodePass("xn--1ch.", "\xe2\x89\xa0."); }
test { try toUnicodePass("\xe2\x89\xa0.", "\xe2\x89\xa0."); }
test { try toUnicodePass("=\xcc\xb8.", "\xe2\x89\xa0."); }
test { try toUnicodePass("f", "f"); }
test { try toAsciiPass("f", "f", false); }
test { try toAsciiPass("f", "f", true); }
test { try toAsciiPass("\xe2\x80\x8d\xe3\xa8\xb2\xef\xbd\xa1\xc3\x9f", "xn--9bm.ss", true); }
test { try toAsciiPass("\xe2\x80\x8d\xe3\xa8\xb2\xe3\x80\x82\xc3\x9f", "xn--9bm.ss", true); }
test { try toAsciiPass("\xe2\x80\x8d\xe3\xa8\xb2\xe3\x80\x82SS", "xn--9bm.ss", true); }
test { try toAsciiPass("\xe2\x80\x8d\xe3\xa8\xb2\xe3\x80\x82ss", "xn--9bm.ss", true); }
test { try toAsciiPass("\xe2\x80\x8d\xe3\xa8\xb2\xe3\x80\x82Ss", "xn--9bm.ss", true); }
test { try toUnicodePass("xn--9bm.ss", "\xe3\xa8\xb2.ss"); }
test { try toAsciiPass("xn--9bm.ss", "xn--9bm.ss", false); }
test { try toAsciiPass("xn--9bm.ss", "xn--9bm.ss", true); }
test { try toUnicodePass("\xe3\xa8\xb2.ss", "\xe3\xa8\xb2.ss"); }
test { try toAsciiPass("\xe3\xa8\xb2.ss", "xn--9bm.ss", false); }
test { try toAsciiPass("\xe3\xa8\xb2.ss", "xn--9bm.ss", true); }
test { try toUnicodePass("\xe3\xa8\xb2.SS", "\xe3\xa8\xb2.ss"); }
test { try toAsciiPass("\xe3\xa8\xb2.SS", "xn--9bm.ss", false); }
test { try toAsciiPass("\xe3\xa8\xb2.SS", "xn--9bm.ss", true); }
test { try toUnicodePass("\xe3\xa8\xb2.Ss", "\xe3\xa8\xb2.ss"); }
test { try toAsciiPass("\xe3\xa8\xb2.Ss", "xn--9bm.ss", false); }
test { try toAsciiPass("\xe3\xa8\xb2.Ss", "xn--9bm.ss", true); }
test { try toAsciiPass("\xe2\x80\x8d\xe3\xa8\xb2\xef\xbd\xa1SS", "xn--9bm.ss", true); }
test { try toAsciiPass("\xe2\x80\x8d\xe3\xa8\xb2\xef\xbd\xa1ss", "xn--9bm.ss", true); }
test { try toAsciiPass("\xe2\x80\x8d\xe3\xa8\xb2\xef\xbd\xa1Ss", "xn--9bm.ss", true); }
test { try toUnicodePass("\xf0\x9d\x9f\x8e\xe3\x80\x82\xe7\x94\xaf", "0.\xe7\x94\xaf"); }
test { try toAsciiPass("\xf0\x9d\x9f\x8e\xe3\x80\x82\xe7\x94\xaf", "0.xn--qny", false); }
test { try toAsciiPass("\xf0\x9d\x9f\x8e\xe3\x80\x82\xe7\x94\xaf", "0.xn--qny", true); }
test { try toUnicodePass("0\xe3\x80\x82\xe7\x94\xaf", "0.\xe7\x94\xaf"); }
test { try toAsciiPass("0\xe3\x80\x82\xe7\x94\xaf", "0.xn--qny", false); }
test { try toAsciiPass("0\xe3\x80\x82\xe7\x94\xaf", "0.xn--qny", true); }
test { try toUnicodePass("0.xn--qny", "0.\xe7\x94\xaf"); }
test { try toAsciiPass("0.xn--qny", "0.xn--qny", false); }
test { try toAsciiPass("0.xn--qny", "0.xn--qny", true); }
test { try toUnicodePass("0.\xe7\x94\xaf", "0.\xe7\x94\xaf"); }
test { try toAsciiPass("0.\xe7\x94\xaf", "0.xn--qny", false); }
test { try toAsciiPass("0.\xe7\x94\xaf", "0.xn--qny", true); }
test { try toUnicodePass("\xf0\x9f\x82\xb4\xe1\x82\xab.\xe2\x89\xae", "\xf0\x9f\x82\xb4\xe2\xb4\x8b.\xe2\x89\xae"); }
test { try toAsciiPass("\xf0\x9f\x82\xb4\xe1\x82\xab.\xe2\x89\xae", "xn--2kj7565l.xn--gdh", false); }
test { try toAsciiPass("\xf0\x9f\x82\xb4\xe1\x82\xab.\xe2\x89\xae", "xn--2kj7565l.xn--gdh", true); }
test { try toUnicodePass("\xf0\x9f\x82\xb4\xe1\x82\xab.<\xcc\xb8", "\xf0\x9f\x82\xb4\xe2\xb4\x8b.\xe2\x89\xae"); }
test { try toAsciiPass("\xf0\x9f\x82\xb4\xe1\x82\xab.<\xcc\xb8", "xn--2kj7565l.xn--gdh", false); }
test { try toAsciiPass("\xf0\x9f\x82\xb4\xe1\x82\xab.<\xcc\xb8", "xn--2kj7565l.xn--gdh", true); }
test { try toUnicodePass("\xf0\x9f\x82\xb4\xe2\xb4\x8b.<\xcc\xb8", "\xf0\x9f\x82\xb4\xe2\xb4\x8b.\xe2\x89\xae"); }
test { try toAsciiPass("\xf0\x9f\x82\xb4\xe2\xb4\x8b.<\xcc\xb8", "xn--2kj7565l.xn--gdh", false); }
test { try toAsciiPass("\xf0\x9f\x82\xb4\xe2\xb4\x8b.<\xcc\xb8", "xn--2kj7565l.xn--gdh", true); }
test { try toUnicodePass("\xf0\x9f\x82\xb4\xe2\xb4\x8b.\xe2\x89\xae", "\xf0\x9f\x82\xb4\xe2\xb4\x8b.\xe2\x89\xae"); }
test { try toAsciiPass("\xf0\x9f\x82\xb4\xe2\xb4\x8b.\xe2\x89\xae", "xn--2kj7565l.xn--gdh", false); }
test { try toAsciiPass("\xf0\x9f\x82\xb4\xe2\xb4\x8b.\xe2\x89\xae", "xn--2kj7565l.xn--gdh", true); }
test { try toUnicodePass("xn--2kj7565l.xn--gdh", "\xf0\x9f\x82\xb4\xe2\xb4\x8b.\xe2\x89\xae"); }
test { try toAsciiPass("xn--2kj7565l.xn--gdh", "xn--2kj7565l.xn--gdh", false); }
test { try toAsciiPass("xn--2kj7565l.xn--gdh", "xn--2kj7565l.xn--gdh", true); }
test { try toUnicodePass("xn--gky8837e.", "\xe7\x92\xbc\xf0\x9d\xa8\xad."); }
test { try toUnicodePass("\xe7\x92\xbc\xf0\x9d\xa8\xad.", "\xe7\x92\xbc\xf0\x9d\xa8\xad."); }
test { try toAsciiPass("\xe2\x80\x8d\xed\x8a\x9b.\xdc\x96", "xn--157b.xn--gnb", true); }
test { try toAsciiPass("\xe2\x80\x8d\xe1\x84\x90\xe1\x85\xb1\xe1\x87\x82.\xdc\x96", "xn--157b.xn--gnb", true); }
test { try toUnicodePass("xn--157b.xn--gnb", "\xed\x8a\x9b.\xdc\x96"); }
test { try toAsciiPass("xn--157b.xn--gnb", "xn--157b.xn--gnb", false); }
test { try toAsciiPass("xn--157b.xn--gnb", "xn--157b.xn--gnb", true); }
test { try toUnicodePass("\xed\x8a\x9b.\xdc\x96", "\xed\x8a\x9b.\xdc\x96"); }
test { try toAsciiPass("\xed\x8a\x9b.\xdc\x96", "xn--157b.xn--gnb", false); }
test { try toAsciiPass("\xed\x8a\x9b.\xdc\x96", "xn--157b.xn--gnb", true); }
test { try toUnicodePass("\xe1\x84\x90\xe1\x85\xb1\xe1\x87\x82.\xdc\x96", "\xed\x8a\x9b.\xdc\x96"); }
test { try toAsciiPass("\xe1\x84\x90\xe1\x85\xb1\xe1\x87\x82.\xdc\x96", "xn--157b.xn--gnb", false); }
test { try toAsciiPass("\xe1\x84\x90\xe1\x85\xb1\xe1\x87\x82.\xdc\x96", "xn--157b.xn--gnb", true); }
test { try toAsciiPass("\xf0\x9d\x9f\xa04\xf3\xa0\x87\x97\xf0\x9d\x88\xbb\xef\xbc\x8e\xe2\x80\x8d\xf0\x90\x8b\xb5\xe2\x9b\xa7\xe2\x80\x8d", "xn--84-s850a.xn--59h6326e", true); }
test { try toAsciiPass("84\xf3\xa0\x87\x97\xf0\x9d\x88\xbb.\xe2\x80\x8d\xf0\x90\x8b\xb5\xe2\x9b\xa7\xe2\x80\x8d", "xn--84-s850a.xn--59h6326e", true); }
test { try toUnicodePass("xn--84-s850a.xn--59h6326e", "84\xf0\x9d\x88\xbb.\xf0\x90\x8b\xb5\xe2\x9b\xa7"); }
test { try toAsciiPass("xn--84-s850a.xn--59h6326e", "xn--84-s850a.xn--59h6326e", false); }
test { try toAsciiPass("xn--84-s850a.xn--59h6326e", "xn--84-s850a.xn--59h6326e", true); }
test { try toUnicodePass("84\xf0\x9d\x88\xbb.\xf0\x90\x8b\xb5\xe2\x9b\xa7", "84\xf0\x9d\x88\xbb.\xf0\x90\x8b\xb5\xe2\x9b\xa7"); }
test { try toAsciiPass("84\xf0\x9d\x88\xbb.\xf0\x90\x8b\xb5\xe2\x9b\xa7", "xn--84-s850a.xn--59h6326e", false); }
test { try toAsciiPass("84\xf0\x9d\x88\xbb.\xf0\x90\x8b\xb5\xe2\x9b\xa7", "xn--84-s850a.xn--59h6326e", true); }
test { try toUnicodePass("\xe2\x89\xae\xf0\x9d\x9f\x95\xef\xbc\x8e\xe8\xac\x96\xc3\x9f\xe2\x89\xaf", "\xe2\x89\xae7.\xe8\xac\x96\xc3\x9f\xe2\x89\xaf"); }
test { try toAsciiPass("\xe2\x89\xae\xf0\x9d\x9f\x95\xef\xbc\x8e\xe8\xac\x96\xc3\x9f\xe2\x89\xaf", "xn--7-mgo.xn--zca892oly5e", false); }
test { try toAsciiPass("\xe2\x89\xae\xf0\x9d\x9f\x95\xef\xbc\x8e\xe8\xac\x96\xc3\x9f\xe2\x89\xaf", "xn--7-mgo.xn--ss-xjvv174c", true); }
test { try toUnicodePass("<\xcc\xb8\xf0\x9d\x9f\x95\xef\xbc\x8e\xe8\xac\x96\xc3\x9f>\xcc\xb8", "\xe2\x89\xae7.\xe8\xac\x96\xc3\x9f\xe2\x89\xaf"); }
test { try toAsciiPass("<\xcc\xb8\xf0\x9d\x9f\x95\xef\xbc\x8e\xe8\xac\x96\xc3\x9f>\xcc\xb8", "xn--7-mgo.xn--zca892oly5e", false); }
test { try toAsciiPass("<\xcc\xb8\xf0\x9d\x9f\x95\xef\xbc\x8e\xe8\xac\x96\xc3\x9f>\xcc\xb8", "xn--7-mgo.xn--ss-xjvv174c", true); }
test { try toUnicodePass("\xe2\x89\xae7.\xe8\xac\x96\xc3\x9f\xe2\x89\xaf", "\xe2\x89\xae7.\xe8\xac\x96\xc3\x9f\xe2\x89\xaf"); }
test { try toAsciiPass("\xe2\x89\xae7.\xe8\xac\x96\xc3\x9f\xe2\x89\xaf", "xn--7-mgo.xn--zca892oly5e", false); }
test { try toAsciiPass("\xe2\x89\xae7.\xe8\xac\x96\xc3\x9f\xe2\x89\xaf", "xn--7-mgo.xn--ss-xjvv174c", true); }
test { try toUnicodePass("<\xcc\xb87.\xe8\xac\x96\xc3\x9f>\xcc\xb8", "\xe2\x89\xae7.\xe8\xac\x96\xc3\x9f\xe2\x89\xaf"); }
test { try toAsciiPass("<\xcc\xb87.\xe8\xac\x96\xc3\x9f>\xcc\xb8", "xn--7-mgo.xn--zca892oly5e", false); }
test { try toAsciiPass("<\xcc\xb87.\xe8\xac\x96\xc3\x9f>\xcc\xb8", "xn--7-mgo.xn--ss-xjvv174c", true); }
test { try toUnicodePass("<\xcc\xb87.\xe8\xac\x96SS>\xcc\xb8", "\xe2\x89\xae7.\xe8\xac\x96ss\xe2\x89\xaf"); }
test { try toAsciiPass("<\xcc\xb87.\xe8\xac\x96SS>\xcc\xb8", "xn--7-mgo.xn--ss-xjvv174c", false); }
test { try toAsciiPass("<\xcc\xb87.\xe8\xac\x96SS>\xcc\xb8", "xn--7-mgo.xn--ss-xjvv174c", true); }
test { try toUnicodePass("\xe2\x89\xae7.\xe8\xac\x96SS\xe2\x89\xaf", "\xe2\x89\xae7.\xe8\xac\x96ss\xe2\x89\xaf"); }
test { try toAsciiPass("\xe2\x89\xae7.\xe8\xac\x96SS\xe2\x89\xaf", "xn--7-mgo.xn--ss-xjvv174c", false); }
test { try toAsciiPass("\xe2\x89\xae7.\xe8\xac\x96SS\xe2\x89\xaf", "xn--7-mgo.xn--ss-xjvv174c", true); }
test { try toUnicodePass("\xe2\x89\xae7.\xe8\xac\x96ss\xe2\x89\xaf", "\xe2\x89\xae7.\xe8\xac\x96ss\xe2\x89\xaf"); }
test { try toAsciiPass("\xe2\x89\xae7.\xe8\xac\x96ss\xe2\x89\xaf", "xn--7-mgo.xn--ss-xjvv174c", false); }
test { try toAsciiPass("\xe2\x89\xae7.\xe8\xac\x96ss\xe2\x89\xaf", "xn--7-mgo.xn--ss-xjvv174c", true); }
test { try toUnicodePass("<\xcc\xb87.\xe8\xac\x96ss>\xcc\xb8", "\xe2\x89\xae7.\xe8\xac\x96ss\xe2\x89\xaf"); }
test { try toAsciiPass("<\xcc\xb87.\xe8\xac\x96ss>\xcc\xb8", "xn--7-mgo.xn--ss-xjvv174c", false); }
test { try toAsciiPass("<\xcc\xb87.\xe8\xac\x96ss>\xcc\xb8", "xn--7-mgo.xn--ss-xjvv174c", true); }
test { try toUnicodePass("<\xcc\xb87.\xe8\xac\x96Ss>\xcc\xb8", "\xe2\x89\xae7.\xe8\xac\x96ss\xe2\x89\xaf"); }
test { try toAsciiPass("<\xcc\xb87.\xe8\xac\x96Ss>\xcc\xb8", "xn--7-mgo.xn--ss-xjvv174c", false); }
test { try toAsciiPass("<\xcc\xb87.\xe8\xac\x96Ss>\xcc\xb8", "xn--7-mgo.xn--ss-xjvv174c", true); }
test { try toUnicodePass("\xe2\x89\xae7.\xe8\xac\x96Ss\xe2\x89\xaf", "\xe2\x89\xae7.\xe8\xac\x96ss\xe2\x89\xaf"); }
test { try toAsciiPass("\xe2\x89\xae7.\xe8\xac\x96Ss\xe2\x89\xaf", "xn--7-mgo.xn--ss-xjvv174c", false); }
test { try toAsciiPass("\xe2\x89\xae7.\xe8\xac\x96Ss\xe2\x89\xaf", "xn--7-mgo.xn--ss-xjvv174c", true); }
test { try toUnicodePass("xn--7-mgo.xn--ss-xjvv174c", "\xe2\x89\xae7.\xe8\xac\x96ss\xe2\x89\xaf"); }
test { try toAsciiPass("xn--7-mgo.xn--ss-xjvv174c", "xn--7-mgo.xn--ss-xjvv174c", false); }
test { try toAsciiPass("xn--7-mgo.xn--ss-xjvv174c", "xn--7-mgo.xn--ss-xjvv174c", true); }
test { try toUnicodePass("xn--7-mgo.xn--zca892oly5e", "\xe2\x89\xae7.\xe8\xac\x96\xc3\x9f\xe2\x89\xaf"); }
test { try toAsciiPass("xn--7-mgo.xn--zca892oly5e", "xn--7-mgo.xn--zca892oly5e", false); }
test { try toAsciiPass("xn--7-mgo.xn--zca892oly5e", "xn--7-mgo.xn--zca892oly5e", true); }
test { try toUnicodePass("<\xcc\xb8\xf0\x9d\x9f\x95\xef\xbc\x8e\xe8\xac\x96SS>\xcc\xb8", "\xe2\x89\xae7.\xe8\xac\x96ss\xe2\x89\xaf"); }
test { try toAsciiPass("<\xcc\xb8\xf0\x9d\x9f\x95\xef\xbc\x8e\xe8\xac\x96SS>\xcc\xb8", "xn--7-mgo.xn--ss-xjvv174c", false); }
test { try toAsciiPass("<\xcc\xb8\xf0\x9d\x9f\x95\xef\xbc\x8e\xe8\xac\x96SS>\xcc\xb8", "xn--7-mgo.xn--ss-xjvv174c", true); }
test { try toUnicodePass("\xe2\x89\xae\xf0\x9d\x9f\x95\xef\xbc\x8e\xe8\xac\x96SS\xe2\x89\xaf", "\xe2\x89\xae7.\xe8\xac\x96ss\xe2\x89\xaf"); }
test { try toAsciiPass("\xe2\x89\xae\xf0\x9d\x9f\x95\xef\xbc\x8e\xe8\xac\x96SS\xe2\x89\xaf", "xn--7-mgo.xn--ss-xjvv174c", false); }
test { try toAsciiPass("\xe2\x89\xae\xf0\x9d\x9f\x95\xef\xbc\x8e\xe8\xac\x96SS\xe2\x89\xaf", "xn--7-mgo.xn--ss-xjvv174c", true); }
test { try toUnicodePass("\xe2\x89\xae\xf0\x9d\x9f\x95\xef\xbc\x8e\xe8\xac\x96ss\xe2\x89\xaf", "\xe2\x89\xae7.\xe8\xac\x96ss\xe2\x89\xaf"); }
test { try toAsciiPass("\xe2\x89\xae\xf0\x9d\x9f\x95\xef\xbc\x8e\xe8\xac\x96ss\xe2\x89\xaf", "xn--7-mgo.xn--ss-xjvv174c", false); }
test { try toAsciiPass("\xe2\x89\xae\xf0\x9d\x9f\x95\xef\xbc\x8e\xe8\xac\x96ss\xe2\x89\xaf", "xn--7-mgo.xn--ss-xjvv174c", true); }
test { try toUnicodePass("<\xcc\xb8\xf0\x9d\x9f\x95\xef\xbc\x8e\xe8\xac\x96ss>\xcc\xb8", "\xe2\x89\xae7.\xe8\xac\x96ss\xe2\x89\xaf"); }
test { try toAsciiPass("<\xcc\xb8\xf0\x9d\x9f\x95\xef\xbc\x8e\xe8\xac\x96ss>\xcc\xb8", "xn--7-mgo.xn--ss-xjvv174c", false); }
test { try toAsciiPass("<\xcc\xb8\xf0\x9d\x9f\x95\xef\xbc\x8e\xe8\xac\x96ss>\xcc\xb8", "xn--7-mgo.xn--ss-xjvv174c", true); }
test { try toUnicodePass("<\xcc\xb8\xf0\x9d\x9f\x95\xef\xbc\x8e\xe8\xac\x96Ss>\xcc\xb8", "\xe2\x89\xae7.\xe8\xac\x96ss\xe2\x89\xaf"); }
test { try toAsciiPass("<\xcc\xb8\xf0\x9d\x9f\x95\xef\xbc\x8e\xe8\xac\x96Ss>\xcc\xb8", "xn--7-mgo.xn--ss-xjvv174c", false); }
test { try toAsciiPass("<\xcc\xb8\xf0\x9d\x9f\x95\xef\xbc\x8e\xe8\xac\x96Ss>\xcc\xb8", "xn--7-mgo.xn--ss-xjvv174c", true); }
test { try toUnicodePass("\xe2\x89\xae\xf0\x9d\x9f\x95\xef\xbc\x8e\xe8\xac\x96Ss\xe2\x89\xaf", "\xe2\x89\xae7.\xe8\xac\x96ss\xe2\x89\xaf"); }
test { try toAsciiPass("\xe2\x89\xae\xf0\x9d\x9f\x95\xef\xbc\x8e\xe8\xac\x96Ss\xe2\x89\xaf", "xn--7-mgo.xn--ss-xjvv174c", false); }
test { try toAsciiPass("\xe2\x89\xae\xf0\x9d\x9f\x95\xef\xbc\x8e\xe8\xac\x96Ss\xe2\x89\xaf", "xn--7-mgo.xn--ss-xjvv174c", true); }
test { try toUnicodePass("xn--ss-bh7o", "ss\xf0\x91\x93\x83"); }
test { try toAsciiPass("xn--ss-bh7o", "xn--ss-bh7o", false); }
test { try toAsciiPass("xn--ss-bh7o", "xn--ss-bh7o", true); }
test { try toUnicodePass("ss\xf0\x91\x93\x83", "ss\xf0\x91\x93\x83"); }
test { try toAsciiPass("ss\xf0\x91\x93\x83", "xn--ss-bh7o", false); }
test { try toAsciiPass("ss\xf0\x91\x93\x83", "xn--ss-bh7o", true); }
test { try toUnicodePass("SS\xf0\x91\x93\x83", "ss\xf0\x91\x93\x83"); }
test { try toAsciiPass("SS\xf0\x91\x93\x83", "xn--ss-bh7o", false); }
test { try toAsciiPass("SS\xf0\x91\x93\x83", "xn--ss-bh7o", true); }
test { try toUnicodePass("Ss\xf0\x91\x93\x83", "ss\xf0\x91\x93\x83"); }
test { try toAsciiPass("Ss\xf0\x91\x93\x83", "xn--ss-bh7o", false); }
test { try toAsciiPass("Ss\xf0\x91\x93\x83", "xn--ss-bh7o", true); }
test { try toUnicodePass("xn--qekw60d.xn--gd9a", "\xe3\x83\xb6\xe4\x92\xa9.\xea\xa1\xaa"); }
test { try toAsciiPass("xn--qekw60d.xn--gd9a", "xn--qekw60d.xn--gd9a", false); }
test { try toAsciiPass("xn--qekw60d.xn--gd9a", "xn--qekw60d.xn--gd9a", true); }
test { try toUnicodePass("\xe3\x83\xb6\xe4\x92\xa9.\xea\xa1\xaa", "\xe3\x83\xb6\xe4\x92\xa9.\xea\xa1\xaa"); }
test { try toAsciiPass("\xe3\x83\xb6\xe4\x92\xa9.\xea\xa1\xaa", "xn--qekw60d.xn--gd9a", false); }
test { try toAsciiPass("\xe3\x83\xb6\xe4\x92\xa9.\xea\xa1\xaa", "xn--qekw60d.xn--gd9a", true); }
test { try toAsciiPass("\xe2\xbe\x87.\xd9\xbd\xf0\x9e\xa4\xb4\xda\xbb\xe2\x80\x8d", "xn--8c1a.xn--2ib8jn539l", true); }
test { try toAsciiPass("\xe8\x88\x9b.\xd9\xbd\xf0\x9e\xa4\xb4\xda\xbb\xe2\x80\x8d", "xn--8c1a.xn--2ib8jn539l", true); }
test { try toAsciiPass("\xe8\x88\x9b.\xd9\xbd\xf0\x9e\xa4\x92\xda\xbb\xe2\x80\x8d", "xn--8c1a.xn--2ib8jn539l", true); }
test { try toUnicodePass("xn--8c1a.xn--2ib8jn539l", "\xe8\x88\x9b.\xd9\xbd\xf0\x9e\xa4\xb4\xda\xbb"); }
test { try toAsciiPass("xn--8c1a.xn--2ib8jn539l", "xn--8c1a.xn--2ib8jn539l", false); }
test { try toAsciiPass("xn--8c1a.xn--2ib8jn539l", "xn--8c1a.xn--2ib8jn539l", true); }
test { try toUnicodePass("\xe8\x88\x9b.\xd9\xbd\xf0\x9e\xa4\xb4\xda\xbb", "\xe8\x88\x9b.\xd9\xbd\xf0\x9e\xa4\xb4\xda\xbb"); }
test { try toAsciiPass("\xe8\x88\x9b.\xd9\xbd\xf0\x9e\xa4\xb4\xda\xbb", "xn--8c1a.xn--2ib8jn539l", false); }
test { try toAsciiPass("\xe8\x88\x9b.\xd9\xbd\xf0\x9e\xa4\xb4\xda\xbb", "xn--8c1a.xn--2ib8jn539l", true); }
test { try toUnicodePass("\xe8\x88\x9b.\xd9\xbd\xf0\x9e\xa4\x92\xda\xbb", "\xe8\x88\x9b.\xd9\xbd\xf0\x9e\xa4\xb4\xda\xbb"); }
test { try toAsciiPass("\xe8\x88\x9b.\xd9\xbd\xf0\x9e\xa4\x92\xda\xbb", "xn--8c1a.xn--2ib8jn539l", false); }
test { try toAsciiPass("\xe8\x88\x9b.\xd9\xbd\xf0\x9e\xa4\x92\xda\xbb", "xn--8c1a.xn--2ib8jn539l", true); }
test { try toAsciiPass("\xe2\xbe\x87.\xd9\xbd\xf0\x9e\xa4\x92\xda\xbb\xe2\x80\x8d", "xn--8c1a.xn--2ib8jn539l", true); }
test { try toUnicodePass("xn--hcb32bni", "\xda\xbd\xd9\xa3\xd6\x96"); }
test { try toAsciiPass("xn--hcb32bni", "xn--hcb32bni", false); }
test { try toAsciiPass("xn--hcb32bni", "xn--hcb32bni", true); }
test { try toUnicodePass("\xda\xbd\xd9\xa3\xd6\x96", "\xda\xbd\xd9\xa3\xd6\x96"); }
test { try toAsciiPass("\xda\xbd\xd9\xa3\xd6\x96", "xn--hcb32bni", false); }
test { try toAsciiPass("\xda\xbd\xd9\xa3\xd6\x96", "xn--hcb32bni", true); }
test { try toAsciiPass("\xd8\xbd\xf0\x91\x88\xbe\xef\xbc\x8e\xd9\x89\xe2\x80\x8d\xea\xa4\xab", "xn--8gb2338k.xn--lhb0154f", true); }
test { try toAsciiPass("\xd8\xbd\xf0\x91\x88\xbe.\xd9\x89\xe2\x80\x8d\xea\xa4\xab", "xn--8gb2338k.xn--lhb0154f", true); }
test { try toUnicodePass("xn--8gb2338k.xn--lhb0154f", "\xd8\xbd\xf0\x91\x88\xbe.\xd9\x89\xea\xa4\xab"); }
test { try toAsciiPass("xn--8gb2338k.xn--lhb0154f", "xn--8gb2338k.xn--lhb0154f", false); }
test { try toAsciiPass("xn--8gb2338k.xn--lhb0154f", "xn--8gb2338k.xn--lhb0154f", true); }
test { try toUnicodePass("\xd8\xbd\xf0\x91\x88\xbe.\xd9\x89\xea\xa4\xab", "\xd8\xbd\xf0\x91\x88\xbe.\xd9\x89\xea\xa4\xab"); }
test { try toAsciiPass("\xd8\xbd\xf0\x91\x88\xbe.\xd9\x89\xea\xa4\xab", "xn--8gb2338k.xn--lhb0154f", false); }
test { try toAsciiPass("\xd8\xbd\xf0\x91\x88\xbe.\xd9\x89\xea\xa4\xab", "xn--8gb2338k.xn--lhb0154f", true); }
test { try toUnicodePass("\xe1\x83\x81\xe1\x82\xb16\xcc\x98\xe3\x80\x82\xc3\x9f\xe1\xac\x83", "\xe2\xb4\xa1\xe2\xb4\x916\xcc\x98.\xc3\x9f\xe1\xac\x83"); }
test { try toAsciiPass("\xe1\x83\x81\xe1\x82\xb16\xcc\x98\xe3\x80\x82\xc3\x9f\xe1\xac\x83", "xn--6-8cb7433a2ba.xn--zca894k", false); }
test { try toAsciiPass("\xe1\x83\x81\xe1\x82\xb16\xcc\x98\xe3\x80\x82\xc3\x9f\xe1\xac\x83", "xn--6-8cb7433a2ba.xn--ss-2vq", true); }
test { try toUnicodePass("\xe2\xb4\xa1\xe2\xb4\x916\xcc\x98\xe3\x80\x82\xc3\x9f\xe1\xac\x83", "\xe2\xb4\xa1\xe2\xb4\x916\xcc\x98.\xc3\x9f\xe1\xac\x83"); }
test { try toAsciiPass("\xe2\xb4\xa1\xe2\xb4\x916\xcc\x98\xe3\x80\x82\xc3\x9f\xe1\xac\x83", "xn--6-8cb7433a2ba.xn--zca894k", false); }
test { try toAsciiPass("\xe2\xb4\xa1\xe2\xb4\x916\xcc\x98\xe3\x80\x82\xc3\x9f\xe1\xac\x83", "xn--6-8cb7433a2ba.xn--ss-2vq", true); }
test { try toUnicodePass("\xe1\x83\x81\xe1\x82\xb16\xcc\x98\xe3\x80\x82SS\xe1\xac\x83", "\xe2\xb4\xa1\xe2\xb4\x916\xcc\x98.ss\xe1\xac\x83"); }
test { try toAsciiPass("\xe1\x83\x81\xe1\x82\xb16\xcc\x98\xe3\x80\x82SS\xe1\xac\x83", "xn--6-8cb7433a2ba.xn--ss-2vq", false); }
test { try toAsciiPass("\xe1\x83\x81\xe1\x82\xb16\xcc\x98\xe3\x80\x82SS\xe1\xac\x83", "xn--6-8cb7433a2ba.xn--ss-2vq", true); }
test { try toUnicodePass("\xe2\xb4\xa1\xe2\xb4\x916\xcc\x98\xe3\x80\x82ss\xe1\xac\x83", "\xe2\xb4\xa1\xe2\xb4\x916\xcc\x98.ss\xe1\xac\x83"); }
test { try toAsciiPass("\xe2\xb4\xa1\xe2\xb4\x916\xcc\x98\xe3\x80\x82ss\xe1\xac\x83", "xn--6-8cb7433a2ba.xn--ss-2vq", false); }
test { try toAsciiPass("\xe2\xb4\xa1\xe2\xb4\x916\xcc\x98\xe3\x80\x82ss\xe1\xac\x83", "xn--6-8cb7433a2ba.xn--ss-2vq", true); }
test { try toUnicodePass("\xe1\x83\x81\xe2\xb4\x916\xcc\x98\xe3\x80\x82Ss\xe1\xac\x83", "\xe2\xb4\xa1\xe2\xb4\x916\xcc\x98.ss\xe1\xac\x83"); }
test { try toAsciiPass("\xe1\x83\x81\xe2\xb4\x916\xcc\x98\xe3\x80\x82Ss\xe1\xac\x83", "xn--6-8cb7433a2ba.xn--ss-2vq", false); }
test { try toAsciiPass("\xe1\x83\x81\xe2\xb4\x916\xcc\x98\xe3\x80\x82Ss\xe1\xac\x83", "xn--6-8cb7433a2ba.xn--ss-2vq", true); }
test { try toUnicodePass("xn--6-8cb7433a2ba.xn--ss-2vq", "\xe2\xb4\xa1\xe2\xb4\x916\xcc\x98.ss\xe1\xac\x83"); }
test { try toAsciiPass("xn--6-8cb7433a2ba.xn--ss-2vq", "xn--6-8cb7433a2ba.xn--ss-2vq", false); }
test { try toAsciiPass("xn--6-8cb7433a2ba.xn--ss-2vq", "xn--6-8cb7433a2ba.xn--ss-2vq", true); }
test { try toUnicodePass("\xe2\xb4\xa1\xe2\xb4\x916\xcc\x98.ss\xe1\xac\x83", "\xe2\xb4\xa1\xe2\xb4\x916\xcc\x98.ss\xe1\xac\x83"); }
test { try toAsciiPass("\xe2\xb4\xa1\xe2\xb4\x916\xcc\x98.ss\xe1\xac\x83", "xn--6-8cb7433a2ba.xn--ss-2vq", false); }
test { try toAsciiPass("\xe2\xb4\xa1\xe2\xb4\x916\xcc\x98.ss\xe1\xac\x83", "xn--6-8cb7433a2ba.xn--ss-2vq", true); }
test { try toUnicodePass("\xe1\x83\x81\xe1\x82\xb16\xcc\x98.SS\xe1\xac\x83", "\xe2\xb4\xa1\xe2\xb4\x916\xcc\x98.ss\xe1\xac\x83"); }
test { try toAsciiPass("\xe1\x83\x81\xe1\x82\xb16\xcc\x98.SS\xe1\xac\x83", "xn--6-8cb7433a2ba.xn--ss-2vq", false); }
test { try toAsciiPass("\xe1\x83\x81\xe1\x82\xb16\xcc\x98.SS\xe1\xac\x83", "xn--6-8cb7433a2ba.xn--ss-2vq", true); }
test { try toUnicodePass("\xe1\x83\x81\xe2\xb4\x916\xcc\x98.Ss\xe1\xac\x83", "\xe2\xb4\xa1\xe2\xb4\x916\xcc\x98.ss\xe1\xac\x83"); }
test { try toAsciiPass("\xe1\x83\x81\xe2\xb4\x916\xcc\x98.Ss\xe1\xac\x83", "xn--6-8cb7433a2ba.xn--ss-2vq", false); }
test { try toAsciiPass("\xe1\x83\x81\xe2\xb4\x916\xcc\x98.Ss\xe1\xac\x83", "xn--6-8cb7433a2ba.xn--ss-2vq", true); }
test { try toUnicodePass("xn--6-8cb7433a2ba.xn--zca894k", "\xe2\xb4\xa1\xe2\xb4\x916\xcc\x98.\xc3\x9f\xe1\xac\x83"); }
test { try toAsciiPass("xn--6-8cb7433a2ba.xn--zca894k", "xn--6-8cb7433a2ba.xn--zca894k", false); }
test { try toAsciiPass("xn--6-8cb7433a2ba.xn--zca894k", "xn--6-8cb7433a2ba.xn--zca894k", true); }
test { try toUnicodePass("\xe2\xb4\xa1\xe2\xb4\x916\xcc\x98.\xc3\x9f\xe1\xac\x83", "\xe2\xb4\xa1\xe2\xb4\x916\xcc\x98.\xc3\x9f\xe1\xac\x83"); }
test { try toAsciiPass("\xe2\xb4\xa1\xe2\xb4\x916\xcc\x98.\xc3\x9f\xe1\xac\x83", "xn--6-8cb7433a2ba.xn--zca894k", false); }
test { try toAsciiPass("\xe2\xb4\xa1\xe2\xb4\x916\xcc\x98.\xc3\x9f\xe1\xac\x83", "xn--6-8cb7433a2ba.xn--ss-2vq", true); }
test { try toUnicodePass("xn--7zv.", "\xe6\xa2\x89."); }
test { try toUnicodePass("\xe6\xa2\x89.", "\xe6\xa2\x89."); }
test { try toAsciiPass("\xe0\xa1\x93\xef\xbc\x8e\xe2\x80\x8c\xc3\x9f", "xn--iwb.ss", true); }
test { try toAsciiPass("\xe0\xa1\x93.\xe2\x80\x8c\xc3\x9f", "xn--iwb.ss", true); }
test { try toAsciiPass("\xe0\xa1\x93.\xe2\x80\x8cSS", "xn--iwb.ss", true); }
test { try toAsciiPass("\xe0\xa1\x93.\xe2\x80\x8css", "xn--iwb.ss", true); }
test { try toUnicodePass("xn--iwb.ss", "\xe0\xa1\x93.ss"); }
test { try toAsciiPass("xn--iwb.ss", "xn--iwb.ss", false); }
test { try toAsciiPass("xn--iwb.ss", "xn--iwb.ss", true); }
test { try toUnicodePass("\xe0\xa1\x93.ss", "\xe0\xa1\x93.ss"); }
test { try toAsciiPass("\xe0\xa1\x93.ss", "xn--iwb.ss", false); }
test { try toAsciiPass("\xe0\xa1\x93.ss", "xn--iwb.ss", true); }
test { try toUnicodePass("\xe0\xa1\x93.SS", "\xe0\xa1\x93.ss"); }
test { try toAsciiPass("\xe0\xa1\x93.SS", "xn--iwb.ss", false); }
test { try toAsciiPass("\xe0\xa1\x93.SS", "xn--iwb.ss", true); }
test { try toAsciiPass("\xe0\xa1\x93\xef\xbc\x8e\xe2\x80\x8cSS", "xn--iwb.ss", true); }
test { try toAsciiPass("\xe0\xa1\x93\xef\xbc\x8e\xe2\x80\x8css", "xn--iwb.ss", true); }
test { try toAsciiPass("\xe0\xa1\x93.\xe2\x80\x8cSs", "xn--iwb.ss", true); }
test { try toAsciiPass("\xe0\xa1\x93\xef\xbc\x8e\xe2\x80\x8cSs", "xn--iwb.ss", true); }
test { try toAsciiPass("\xf0\x90\xab\x9c\xf0\x91\x8c\xbc\xe2\x80\x8d\xef\xbc\x8e\xe5\xa9\x80", "xn--ix9c26l.xn--q0s", true); }
test { try toAsciiPass("\xf0\x90\xab\x9c\xf0\x91\x8c\xbc\xe2\x80\x8d.\xe5\xa9\x80", "xn--ix9c26l.xn--q0s", true); }
test { try toUnicodePass("xn--ix9c26l.xn--q0s", "\xf0\x90\xab\x9c\xf0\x91\x8c\xbc.\xe5\xa9\x80"); }
test { try toAsciiPass("xn--ix9c26l.xn--q0s", "xn--ix9c26l.xn--q0s", false); }
test { try toAsciiPass("xn--ix9c26l.xn--q0s", "xn--ix9c26l.xn--q0s", true); }
test { try toUnicodePass("\xf0\x90\xab\x9c\xf0\x91\x8c\xbc.\xe5\xa9\x80", "\xf0\x90\xab\x9c\xf0\x91\x8c\xbc.\xe5\xa9\x80"); }
test { try toAsciiPass("\xf0\x90\xab\x9c\xf0\x91\x8c\xbc.\xe5\xa9\x80", "xn--ix9c26l.xn--q0s", false); }
test { try toAsciiPass("\xf0\x90\xab\x9c\xf0\x91\x8c\xbc.\xe5\xa9\x80", "xn--ix9c26l.xn--q0s", true); }
test { try toUnicodePass("\xf0\x90\xab\x80\xef\xbc\x8e\xda\x89\xf0\x91\x8c\x80", "\xf0\x90\xab\x80.\xda\x89\xf0\x91\x8c\x80"); }
test { try toAsciiPass("\xf0\x90\xab\x80\xef\xbc\x8e\xda\x89\xf0\x91\x8c\x80", "xn--pw9c.xn--fjb8658k", false); }
test { try toAsciiPass("\xf0\x90\xab\x80\xef\xbc\x8e\xda\x89\xf0\x91\x8c\x80", "xn--pw9c.xn--fjb8658k", true); }
test { try toUnicodePass("\xf0\x90\xab\x80.\xda\x89\xf0\x91\x8c\x80", "\xf0\x90\xab\x80.\xda\x89\xf0\x91\x8c\x80"); }
test { try toAsciiPass("\xf0\x90\xab\x80.\xda\x89\xf0\x91\x8c\x80", "xn--pw9c.xn--fjb8658k", false); }
test { try toAsciiPass("\xf0\x90\xab\x80.\xda\x89\xf0\x91\x8c\x80", "xn--pw9c.xn--fjb8658k", true); }
test { try toUnicodePass("xn--pw9c.xn--fjb8658k", "\xf0\x90\xab\x80.\xda\x89\xf0\x91\x8c\x80"); }
test { try toAsciiPass("xn--pw9c.xn--fjb8658k", "xn--pw9c.xn--fjb8658k", false); }
test { try toAsciiPass("xn--pw9c.xn--fjb8658k", "xn--pw9c.xn--fjb8658k", true); }
test { try toUnicodePass("xn--r97c.", "\xf0\x90\x8b\xb7."); }
test { try toUnicodePass("\xf0\x90\x8b\xb7.", "\xf0\x90\x8b\xb7."); }
