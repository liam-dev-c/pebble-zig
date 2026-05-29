/// Graphics drawing helpers
const c = @import("c");
const gcolor = @import("gcolor.zig");

// union_GColor8 is opaque in Zig 0.16.0 (C bitfields); redeclare with u8 to match the ABI.
extern fn graphics_context_set_stroke_color(ctx: ?*c.GContext, color: u8) void;
extern fn graphics_context_set_fill_color(ctx: ?*c.GContext, color: u8) void;
extern fn graphics_context_set_text_color(ctx: ?*c.GContext, color: u8) void;

pub fn setStrokeColor(ctx: ?*c.GContext, color: gcolor.GColor) void {
    graphics_context_set_stroke_color(ctx, color.argb);
}

pub fn setFillColor(ctx: ?*c.GContext, color: gcolor.GColor) void {
    graphics_context_set_fill_color(ctx, color.argb);
}

pub fn setTextColor(ctx: ?*c.GContext, color: gcolor.GColor) void {
    graphics_context_set_text_color(ctx, color.argb);
}

pub fn setAntialiased(ctx: ?*c.GContext, enable: bool) void {
    c.graphics_context_set_antialiased(ctx, enable);
}

pub fn drawLine(ctx: ?*c.GContext, p0: c.GPoint, p1: c.GPoint) void {
    c.graphics_draw_line(ctx, p0, p1);
}

pub fn drawRect(ctx: ?*c.GContext, rect: c.GRect) void {
    c.graphics_draw_rect(ctx, rect);
}

pub fn fillRect(ctx: ?*c.GContext, rect: c.GRect, corner_radius: u16, corner_mask: c.GCornerMask) void {
    c.graphics_fill_rect(ctx, rect, corner_radius, corner_mask);
}

pub fn drawRoundRect(ctx: ?*c.GContext, rect: c.GRect, corner_radius: u16) void {
    c.graphics_draw_round_rect(ctx, rect, corner_radius);
}

pub fn drawCircle(ctx: ?*c.GContext, p: c.GPoint, radius: u16) void {
    c.graphics_draw_circle(ctx, p, radius);
}

pub fn fillCircle(ctx: ?*c.GContext, p: c.GPoint, radius: u16) void {
    c.graphics_fill_circle(ctx, p, radius);
}
