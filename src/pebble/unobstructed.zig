/// Unobstructed area service (Quick View / Timeline peek)
///
/// On platforms that don't have this API (e.g. aplite), `getBounds` falls back
/// to `layer_get_bounds` and `subscribe`/`unsubscribe` are no-ops.
const c = @import("c");

const supported = @hasDecl(c, "unobstructed_area_service_subscribe");

/// Mirrors `UnobstructedAreaHandlers` from pebble.h.
/// Defined here so it exists on all platforms (including aplite which lacks it).
pub const Handlers = if (supported) c.UnobstructedAreaHandlers else extern struct {
    will_change: ?*const fn (c.GRect, ?*anyopaque) callconv(.c) void = null,
    change: ?*const fn (c.AnimationProgress, ?*anyopaque) callconv(.c) void = null,
    did_change: ?*const fn (?*anyopaque) callconv(.c) void = null,
};

/// Returns the unobstructed (visible) bounds of the given layer.
pub fn getBounds(layer: *c.Layer) c.GRect {
    if (comptime supported) return c.layer_get_unobstructed_bounds(layer);
    return c.layer_get_bounds(layer);
}

/// Subscribes to unobstructed area change events.
pub fn subscribe(handlers: Handlers, context: ?*anyopaque) void {
    if (comptime supported) c.unobstructed_area_service_subscribe(handlers, context);
}

/// Unsubscribes from unobstructed area change events.
pub fn unsubscribe() void {
    if (comptime supported) c.unobstructed_area_service_unsubscribe();
}
