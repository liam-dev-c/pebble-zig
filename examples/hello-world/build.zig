const std = @import("std");
const pebble_build = @import("pebble_zig");

pub fn build(b: *std.Build) void {
    const pebble_zig = b.dependency("pebble_zig", .{});

    pebble_build.addPebbleApp(b, .{
        .name = "hello-world",
        .root_source_file = b.path("src/main.zig"),
        .pebble_lib_path = pebble_zig.path("src/pebble.zig"),
    });
}
