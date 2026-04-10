/// Connection state event subscription
const c = @import("c");

/// Subscribes to Pebble app and PebbleKit connection events.
pub fn subscribe(handlers: c.ConnectionHandlers) void {
    c.connection_service_subscribe(handlers);
}

/// Unsubscribes from connection events.
pub fn unsubscribe() void {
    c.connection_service_unsubscribe();
}

/// Returns true if the Pebble app is currently connected to the phone.
pub fn isPebbleAppConnected() bool {
    return c.connection_service_peek_pebble_app_connection();
}

/// Returns true if PebbleKit is currently connected.
pub fn isPebbleKitConnected() bool {
    return c.connection_service_peek_pebblekit_connection();
}
