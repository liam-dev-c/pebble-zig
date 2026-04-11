/// Vibration motor helpers
const c = @import("c");

pub fn shortPulse() void {
    c.vibes_short_pulse();
}

pub fn longPulse() void {
    c.vibes_long_pulse();
}

pub fn doublePulse() void {
    c.vibes_double_pulse();
}

pub fn cancel() void {
    c.vibes_cancel();
}
