/// Safe wrappers around Pebble layer types
const c = @import("c");
const gcolor = @import("gcolor.zig");

/// Safe wrapper around a generic Pebble Layer.
pub const Layer = struct {
    raw: *c.Layer,

    pub fn create(bounds: c.GRect) ?Layer {
        const raw = c.layer_create(bounds) orelse return null;
        return Layer{ .raw = raw };
    }

    pub fn fromRaw(raw: *c.Layer) Layer {
        return Layer{ .raw = raw };
    }

    pub fn destroy(self: Layer) void {
        c.layer_destroy(self.raw);
    }

    pub fn getBounds(self: Layer) c.GRect {
        return c.layer_get_bounds(self.raw);
    }

    pub fn getFrame(self: Layer) c.GRect {
        return c.layer_get_frame(self.raw);
    }

    pub fn addChild(self: Layer, child: *c.Layer) void {
        c.layer_add_child(self.raw, child);
    }

    pub fn markDirty(self: Layer) void {
        c.layer_mark_dirty(self.raw);
    }

    /// Sets a custom draw procedure for this layer.
    pub fn setUpdateProc(self: Layer, proc: c.LayerUpdateProc) void {
        c.layer_set_update_proc(self.raw, proc);
    }

    pub fn setHidden(self: Layer, hidden: bool) void {
        c.layer_set_hidden(self.raw, hidden);
    }

    pub fn setFrame(self: Layer, frame: c.GRect) void {
        c.layer_set_frame(self.raw, frame);
    }

    pub fn getRaw(self: Layer) *c.Layer {
        return self.raw;
    }
};

/// Safe wrapper around a Pebble TextLayer.
pub const TextLayer = struct {
    raw: *c.TextLayer,

    pub fn create(frame: c.GRect) ?TextLayer {
        const raw = c.text_layer_create(frame) orelse return null;
        return TextLayer{ .raw = raw };
    }

    pub fn destroy(self: TextLayer) void {
        c.text_layer_destroy(self.raw);
    }

    /// Sets the text displayed. The string must outlive this call (static or app-managed).
    pub fn setText(self: TextLayer, text: [*:0]const u8) void {
        c.text_layer_set_text(self.raw, text);
    }

    pub fn setTextAlignment(self: TextLayer, alignment: c.GTextAlignment) void {
        c.text_layer_set_text_alignment(self.raw, alignment);
    }

    pub fn setTextColor(self: TextLayer, color: gcolor.GColor) void {
        c.text_layer_set_text_color(self.raw, @bitCast(color));
    }

    pub fn setBackgroundColor(self: TextLayer, color: gcolor.GColor) void {
        c.text_layer_set_background_color(self.raw, @bitCast(color));
    }

    pub fn setFont(self: TextLayer, font: c.GFont) void {
        c.text_layer_set_font(self.raw, font);
    }

    pub fn setHidden(self: TextLayer, hidden: bool) void {
        c.layer_set_hidden(self.asLayer(), hidden);
    }

    pub fn setFrame(self: TextLayer, frame: c.GRect) void {
        c.layer_set_frame(self.asLayer(), frame);
    }

    pub fn getFrame(self: TextLayer) c.GRect {
        return c.layer_get_frame(self.asLayer());
    }

    /// Returns the underlying Layer pointer so this layer can be added to a parent.
    pub fn asLayer(self: TextLayer) *c.Layer {
        return c.text_layer_get_layer(self.raw).?;
    }

    pub fn getRaw(self: TextLayer) *c.TextLayer {
        return self.raw;
    }
};

/// Safe wrapper around a Pebble BitmapLayer.
pub const BitmapLayer = struct {
    raw: *c.BitmapLayer,

    pub fn create(frame: c.GRect) ?BitmapLayer {
        const raw = c.bitmap_layer_create(frame) orelse return null;
        return BitmapLayer{ .raw = raw };
    }

    pub fn destroy(self: BitmapLayer) void {
        c.bitmap_layer_destroy(self.raw);
    }

    pub fn setBitmap(self: BitmapLayer, bitmap: ?*c.GBitmap) void {
        c.bitmap_layer_set_bitmap(self.raw, bitmap);
    }

    pub fn setCompositingMode(self: BitmapLayer, mode: c.GCompOp) void {
        c.bitmap_layer_set_compositing_mode(self.raw, mode);
    }

    pub fn setHidden(self: BitmapLayer, hidden: bool) void {
        c.layer_set_hidden(self.asLayer(), hidden);
    }

    /// Returns the underlying Layer pointer so this layer can be added to a parent.
    pub fn asLayer(self: BitmapLayer) *c.Layer {
        return c.bitmap_layer_get_layer(self.raw).?;
    }

    pub fn getRaw(self: BitmapLayer) *c.BitmapLayer {
        return self.raw;
    }
};
