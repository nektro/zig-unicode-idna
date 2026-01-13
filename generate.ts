import { closeSync, openSync } from "node:fs";

const unicode_version = "17.0.0";

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
  w.write(`\n`);

  //TODO:

  w.flush();
}
