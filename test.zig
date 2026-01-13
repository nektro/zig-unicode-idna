const std = @import("std");
const idna = @import("unicode-idna");

test {
    _ = @import("./testv2.zig");
}
test {
    _ = &idna.@"2008".data;
    _ = &idna.@"2008".data_range;
}
test {
    _ = &idna.table.data;
    _ = &idna.table.data_range;
}
