/// Pebble app lifecycle and logging utilities
const c = @import("c");

/// Starts the Pebble app event loop. Blocks until the app exits.
pub fn eventLoop() void {
    c.app_event_loop();
}

/// Emit a log message at the given level.
/// `fmt` must be a null-terminated C format string literal.
pub inline fn log(comptime level: c_int, comptime fmt: [*:0]const u8, args: anytype) void {
    const src = @src();
    @call(.auto, c.app_log, .{ @as(u8, @intCast(level)), src.file, @as(c_int, @intCast(src.line)), fmt } ++ args);
}

pub inline fn debug(comptime fmt: [*:0]const u8, args: anytype) void {
    log(c.APP_LOG_LEVEL_DEBUG, fmt, args);
}

pub inline fn info(comptime fmt: [*:0]const u8, args: anytype) void {
    log(c.APP_LOG_LEVEL_INFO, fmt, args);
}

pub inline fn warn(comptime fmt: [*:0]const u8, args: anytype) void {
    log(c.APP_LOG_LEVEL_WARNING, fmt, args);
}

pub inline fn err(comptime fmt: [*:0]const u8, args: anytype) void {
    log(c.APP_LOG_LEVEL_ERROR, fmt, args);
}
