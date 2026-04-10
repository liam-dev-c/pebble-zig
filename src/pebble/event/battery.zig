/// Battery state event subscription
const c = @import("c");

/// Subscribes to battery state change events.
pub fn subscribe(handler: c.BatteryStateHandler) void {
    c.battery_state_service_subscribe(handler);
}

/// Unsubscribes from battery state change events.
pub fn unsubscribe() void {
    c.battery_state_service_unsubscribe();
}

/// Returns the current battery state without subscribing.
pub fn peek() c.BatteryChargeState {
    return c.battery_state_service_peek();
}
