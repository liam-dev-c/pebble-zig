/// Safe wrapper around Pebble GBitmap
const c = @import("c");

pub const GBitmap = struct {
    raw: *c.GBitmap,

    /// Creates a bitmap from a resource ID (e.g. from generated_keys).
    pub fn createWithResource(resource_id: u32) ?GBitmap {
        const raw = c.gbitmap_create_with_resource(resource_id) orelse return null;
        return GBitmap{ .raw = raw };
    }

    /// Creates a blank bitmap with the given size and format.
    pub fn createBlank(size: c.GSize, format: c.GBitmapFormat) ?GBitmap {
        const raw = c.gbitmap_create_blank(size, format) orelse return null;
        return GBitmap{ .raw = raw };
    }

    /// Destroys the bitmap and frees its resources.
    pub fn destroy(self: GBitmap) void {
        c.gbitmap_destroy(self.raw);
    }

    /// Returns the bounds of the bitmap.
    pub fn getBounds(self: GBitmap) c.GRect {
        return c.gbitmap_get_bounds(self.raw);
    }

    pub fn getRaw(self: GBitmap) *c.GBitmap {
        return self.raw;
    }
};
