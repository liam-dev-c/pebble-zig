/// Font loading utilities
const c = @import("c");

/// Returns a system font by resource key string.
/// Example: `fonts.getSystem("RESOURCE_ID_GOTHIC_24_BOLD")`
pub fn getSystem(key: [*:0]const u8) c.GFont {
    return c.fonts_get_system_font(key);
}

/// Loads a custom font from a resource handle.
pub fn loadCustom(handle: c.ResHandle) c.GFont {
    return c.fonts_load_custom_font(handle);
}

/// Unloads a custom font previously loaded with `loadCustom`.
pub fn unloadCustom(font: c.GFont) void {
    c.fonts_unload_custom_font(font);
}
