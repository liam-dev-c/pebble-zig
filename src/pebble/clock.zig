/// Clock and tick-timer utilities
const c = @import("c");

/// Returns true if the watch is set to 24-hour time.
pub fn is24h() bool {
    return c.clock_is_24h_style();
}

/// Copies the current time as a formatted string into `buf`.
/// `buf` should be at least 8 bytes ("00:00 AM\0").
pub fn copyTimeString(buf: []u8) void {
    c.clock_copy_time_string(buf.ptr, @intCast(buf.len));
}

/// Copies the current timezone name into `buf`.
pub fn copyTimezone(buf: []u8) void {
    c.clock_get_timezone(buf.ptr, buf.len);
}

/// Subscribes to tick events. `handler` is called every `units` interval.
/// `units` is a bitmask of `c.TimeUnits` (e.g. `c.MINUTE_UNIT`).
pub fn tickSubscribe(units: c.TimeUnits, handler: c.TickHandler) void {
    c.tick_timer_service_subscribe(units, handler);
}

/// Unsubscribes from tick events.
pub fn tickUnsubscribe() void {
    c.tick_timer_service_unsubscribe();
}
