/// Graphics drawing helpers
const c = @import("c");
const gcolor = @import("gcolor.zig");

pub fn setStrokeColor(ctx: ?*c.GContext, color: gcolor.GColor) void {
    c.graphics_context_set_stroke_color(ctx, @bitCast(color));
}

pub fn setFillColor(ctx: ?*c.GContext, color: gcolor.GColor) void {
    c.graphics_context_set_fill_color(ctx, @bitCast(color));
}

pub fn setTextColor(ctx: ?*c.GContext, color: gcolor.GColor) void {
    c.graphics_context_set_text_color(ctx, @bitCast(color));
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
