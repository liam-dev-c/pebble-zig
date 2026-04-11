/// Clock and tick-timer utilities
const c = @import("c");

pub const SECOND_UNIT: c.TimeUnits = 1 << 0;
pub const MINUTE_UNIT: c.TimeUnits = 1 << 1;
pub const HOUR_UNIT: c.TimeUnits = 1 << 2;
pub const DAY_UNIT: c.TimeUnits = 1 << 3;
pub const MONTH_UNIT: c.TimeUnits = 1 << 4;
pub const YEAR_UNIT: c.TimeUnits = 1 << 5;

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
