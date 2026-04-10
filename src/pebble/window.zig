/// Safe wrapper around a Pebble Window
const c = @import("c");
const gcolor = @import("gcolor.zig");

pub const Window = struct {
    raw: *c.Window,

    /// Creates a new window. Returns null if allocation fails.
    pub fn create() ?Window {
        const raw = c.window_create() orelse return null;
        return Window{ .raw = raw };
    }

    /// Wraps an existing raw window pointer (e.g. from a window handler callback).
    pub fn fromRaw(raw: *c.Window) Window {
        return Window{ .raw = raw };
    }

    /// Destroys the window and frees its resources.
    pub fn destroy(self: Window) void {
        c.window_destroy(self.raw);
    }

    /// Pushes the window onto the window stack.
    pub fn push(self: Window, animated: bool) void {
        c.window_stack_push(self.raw, animated);
    }

    /// Gets the root layer of the window.
    pub fn getRootLayer(self: Window) *c.Layer {
        return c.window_get_root_layer(self.raw).?;
    }

    /// Sets lifecycle handlers (load/unload/appear/disappear).
    /// Pass null for any handler you don't need.
    pub fn setHandlers(self: Window, handlers: c.WindowHandlers) void {
        c.window_set_window_handlers(self.raw, handlers);
    }

    /// Sets the click config provider for the window.
    pub fn setClickConfigProvider(self: Window, provider: c.ClickConfigProvider) void {
        c.window_set_click_config_provider(self.raw, provider);
    }

    /// Sets the background color of the window.
    pub fn setBackgroundColor(self: Window, color: gcolor.GColor) void {
        c.window_set_background_color(self.raw, @bitCast(color));
    }

    /// Stores arbitrary user data on the window.
    pub fn setUserData(self: Window, data: ?*anyopaque) void {
        c.window_set_user_data(self.raw, data);
    }

    /// Retrieves the user data stored on the window.
    pub fn getUserData(self: Window) ?*anyopaque {
        return c.window_get_user_data(self.raw);
    }

    /// Returns the underlying raw pointer for advanced / unwrapped API use.
    pub fn getRaw(self: Window) *c.Window {
        return self.raw;
    }
};
