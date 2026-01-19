import { closeSync, openSync } from "node:fs";

const unicode_version = "17.0.0";
const encoder = new TextEncoder();

function stringEscape(s?: string) {
  if (!s) return "";
  return Array.from(encoder.encode(s.replace(/\\u([0-9A-F]{4})/g, (s) => String.fromCodePoint(parseInt(s.slice(2), 16)))))
    .map((x) => {
      if (x === 0x09) return "\\t";
      if (x === 0x0a) return "\\n";
      if (x === 0x0d) return "\\r";
      if (x === 0x20) return " ";
      if (x === 0x21) return "!";
      if (x === 0x22) return `\\"`;
      if (x >= 0x23 && x <= 0x26) return String.fromCodePoint(x);
      if (x === 0x27) return "'";
      if (x >= 0x28 && x <= 0x5b) return String.fromCodePoint(x);
      if (x === 0x5c) return "\\\\";
      if (x >= 0x5d && x <= 0x7e) return String.fromCodePoint(x);
      return `\\x${x.toString(16).padStart(2, "0")}`;
    })
    .join("");
}
const E = stringEscape;

{
  const source = `https://www.unicode.org/Public/${unicode_version}/idna/IdnaMappingTable.txt`;
  const response = await fetch(source);
  const data = await response.text();
  const lines = data.split("\n").filter((x) => !x.startsWith("#") && x.length > 0);
  const lines_clear = lines.map((x) => x.split("#")[0]!);
  const cols = lines_clear.map((x) => x.split(";").map((y) => y.trim()));

  closeSync(openSync("./table.zig", "w", 0o777));
  const f = Bun.file("./table.zig");
  const w = f.writer();

  w.write(`// This file is part of Unicode IDNA Compatibility Processing\n`);
  w.write(`// For documentation, see http://www.unicode.org/reports/tr46/\n`);
  w.write(`//\n`);
  w.write(`\n`);
  w.write(`// Based on the source file: ${source}\n`);
  w.write(`//\n`);
  w.write(`\n`);
  w.write(`pub const Row = struct {\n`);
  w.write(`    cp: u21,\n`);
  w.write(`    status: Status,\n`);
  w.write(`    mapping: []const u21,\n`);
  w.write(`    status2: Status2008,\n`);
  w.write(`};\n`);
  w.write(`\n`);
  w.write(`pub const RowRange = struct {\n`);
  w.write(`    from: u21,\n`);
  w.write(`    to: u21,\n`);
  w.write(`    status: Status,\n`);
  w.write(`    mapping: []const u21,\n`);
  w.write(`    status2: Status2008,\n`);
  w.write(`};\n`);
  w.write(`\n`);
  w.write(`pub const Status = enum {\n`);
  w.write(`    valid,\n`);
  w.write(`    ignored,\n`);
  w.write(`    mapped,\n`);
  w.write(`    deviation,\n`);
  w.write(`    disallowed,\n`);
  w.write(`};\n`);
  w.write(`\n`);
  w.write(`pub const Status2008 = enum {\n`);
  w.write(`    none,\n`);
  w.write(`    NV8,\n`);
  w.write(`    XV8,\n`);
  w.write(`};\n`);
  w.write(`\n`);
  w.write(`pub const data = [_]Row{\n`);
  {
    for (const c of cols.filter((x) => !x[0]!.includes(".."))) {
      w.write(`    .{ .cp = 0x${c[0]},`);
      w.write(` .status = .${c[1]},`);
      // prettier-ignore
      w.write(` .mapping = &.{${c[2]?.split(" ").filter(x => x.length > 0).map((x) => `0x${x}`).join(",") ?? ""}},`,);
      w.write(` .status2 = .${c[3] ?? "none"},`);
      w.write(` },\n`);
    }
  }
  w.write(`};\n`);
  w.write(`\n`);
  w.write(`pub const data_range = [_]RowRange{\n`);
  {
    for (const c of cols.filter((x) => x[0]!.includes(".."))) {
      w.write(`    .{ .from = 0x${c[0]!.split("..")[0]}, .to = 0x${c[0]!.split("..")[1]},`);
      w.write(` .status = .${c[1]},`);
      // prettier-ignore
      w.write(` .mapping = &.{${c[2]?.split(" ").filter(x => x.length > 0).map((x) => `0x${x}`).join(",") ?? ""}},`,);
      w.write(` .status2 = .${c[3] ?? "none"},`);
      w.write(` },\n`);
    }
  }
  w.write(`};\n`);
  w.flush();
}

{
  const source = `https://www.unicode.org/Public/${unicode_version}/idna/Idna2008.txt`;
  const response = await fetch(source);
  const data = await response.text();
  const lines = data.split("\n").filter((x) => !x.startsWith("#") && x.length > 0);
  const lines_clear = lines.map((x) => x.split("#")[0]!);
  const cols = lines_clear.map((x) => x.split(";").map((y) => y.trim()));

  closeSync(openSync("./2008.zig", "w", 0o777));
  const f = Bun.file("./2008.zig");
  const w = f.writer();

  w.write(`// This file is part of Unicode IDNA Compatibility Processing\n`);
  w.write(`// For documentation, see http://www.unicode.org/reports/tr46/\n`);
  w.write(`//\n`);
  w.write(`\n`);
  w.write(`// Based on the source file: ${source}\n`);
  w.write(`//\n`);
  w.write(`\n`);
  w.write(`pub const Prop = struct {\n`);
  w.write(`    cp: u21,\n`);
  w.write(`    category: Category\n`);
  w.write(`};\n`);
  w.write(`\n`);
  w.write(`pub const PropRange = struct {\n`);
  w.write(`    from: u21,\n`);
  w.write(`    to: u21,\n`);
  w.write(`    category: Category\n`);
  w.write(`};\n`);
  w.write(`\n`);
  w.write(`pub const Category = enum {\n`);
  w.write(`    pvalid,\n`);
  w.write(`    contextj,\n`);
  w.write(`    contexto,\n`);
  w.write(`    disallowed,\n`);
  w.write(`    unassigned,\n`);
  w.write(`};\n`);
  w.write(`\n`);
  w.write(`pub const data = [_]Prop{\n`);
  {
    for (const c of cols.filter((x) => !x[0]!.includes(".."))) {
      w.write(`    .{ .cp = 0x${c[0]}, .category = .${c[1]!.toLowerCase()} },\n`);
    }
  }
  w.write(`};\n`);
  w.write(`\n`);
  w.write(`pub const data_range = [_]PropRange{\n`);
  {
    for (const c of cols.filter((x) => x[0]!.includes(".."))) {
      w.write(`    .{ .from = 0x${c[0]!.split("..")[0]}, .to = 0x${c[0]!.split("..")[1]}, .category = .${c[1]!.toLowerCase()} },\n`);
    }
  }
  w.write(`};\n`);
  w.flush();
}

{
  const source = `https://www.unicode.org/Public/${unicode_version}/idna/IdnaTestV2.txt`;
  const response = await fetch(source);
  const data = await response.text();
  const lines = data.split("\n").filter((x) => !x.startsWith("#") && x.length > 0);
  const lines_clear = lines.map((x) => x.split("#")[0]!);
  const cols = lines_clear.map((x) => x.split(";").map((y) => y.trim()));

  closeSync(openSync("./testv2.zig", "w", 0o777));
  const f = Bun.file("./testv2.zig");
  const w = f.writer();

  w.write(`// This file is part of Unicode IDNA Compatibility Processing\n`);
  w.write(`// For documentation, see http://www.unicode.org/reports/tr46/\n`);
  w.write(`//\n`);
  w.write(`\n`);
  w.write(`// Based on the source file: ${source}\n`);
  w.write(`//\n`);
  w.write(`// zig fmt: off\n`);
  w.write(`\n`);
  w.write(`const std = @import("std");\n`);
  w.write(`const idna = @import("unicode-idna");\n`);
  w.write(`const expect = @import("expect").expect;\n`);

  w.write(`
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
`);
  w.write(`\n`);

  for (const i of cols) {
    const source = i[0];
    const toUnicode = i[1] || source;
    const toUnicodeStatus = i[2] || "[]";
    const toAsciiN = i[3] || toUnicode;
    const toAsciiNStatus = i[4] || toUnicodeStatus;
    const toAsciiT = i[5] || toAsciiN;
    const toAsciiTStatus = i[6] || toAsciiNStatus;

    if (toUnicodeStatus === "[]") w.write(`test { try toUnicodePass("${E(source)}", "${E(toUnicode)}"); }\n`);
    if (toAsciiNStatus === "[]") w.write(`test { try toAsciiPass("${E(source)}", "${E(toAsciiN)}", false); }\n`);
    if (toAsciiTStatus === "[]") w.write(`test { try toAsciiPass("${E(source)}", "${E(toAsciiT)}", true); }\n`);

    // if (toUnicodeStatus !== "[]") w.write(`test { try toUnicodeFail("${E(source)}"); }\n`);
    // if (toAsciiNStatus !== "[]") w.write(`test { try toAsciiFail("${E(source)}", false); }\n`);
    // if (toAsciiTStatus !== "[]") w.write(`test { try toAsciiFail("${E(source)}", true); }\n`);
  }

  w.flush();
}
