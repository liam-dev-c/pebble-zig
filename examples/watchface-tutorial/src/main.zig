/// Pebble watchface tutorial — part 6 (Zig port)
///
/// Features: custom fonts, date, weather (Open-Meteo), battery meter,
/// Bluetooth icon, Clay settings (bg/text color, °C/°F, show date),
/// and unobstructed-area (Quick View) support.
const std = @import("std");
const pebble = @import("pebble");
const c = pebble.c;
const keys = @import("generated_keys.zig");

// ─── Settings ────────────────────────────────────────────────────────────────

const SETTINGS_KEY: u32 = 1;

/// Persistent settings — layout must match across saves/loads.
const Settings = extern struct {
    background_color: pebble.gcolor.GColor = pebble.gcolor.GColorBlack,
    text_color: pebble.gcolor.GColor = pebble.gcolor.GColorWhite,
    temperature_unit: bool = false, // false = Celsius, true = Fahrenheit
    show_date: bool = true,
};

var settings = Settings{};

fn defaultSettings() void {
    settings = Settings{};
}

fn saveSettings() void {
    _ = c.persist_write_data(SETTINGS_KEY, &settings, @sizeOf(Settings));
}

fn loadSettings() void {
    defaultSettings();
    _ = c.persist_read_data(SETTINGS_KEY, &settings, @sizeOf(Settings));
}

// ─── App state ───────────────────────────────────────────────────────────────

var main_window: ?pebble.Window = null;
var time_layer: ?pebble.TextLayer = null;
var date_layer: ?pebble.TextLayer = null;
var weather_layer: ?pebble.TextLayer = null;
var time_font: c.GFont = undefined;
var date_font: c.GFont = undefined;
var battery_layer: ?pebble.Layer = null;
var battery_level: i32 = 0;
var bt_icon_layer: ?pebble.BitmapLayer = null;
var bt_icon_bitmap: ?pebble.bitmap.GBitmap = null;
var window_layer: *c.Layer = undefined;

var time_buf: [8:0]u8 = std.mem.zeroes([8:0]u8);
var date_buf: [16:0]u8 = std.mem.zeroes([16:0]u8);
var weather_buf: [42:0]u8 = std.mem.zeroes([42:0]u8);

// ─── Helpers ─────────────────────────────────────────────────────────────────

/// Convert a Clay 0xRRGGBB integer to a Pebble GColor (2 bits per channel).
fn gcolorFromHex(hex: i32) pebble.gcolor.GColor {
    const h: u32 = @bitCast(hex);
    const r: u2 = @intCast(((h >> 16) & 0xFF) >> 6);
    const g: u2 = @intCast(((h >> 8) & 0xFF) >> 6);
    const b: u2 = @intCast((h & 0xFF) >> 6);
    return pebble.gcolor.makeColor(3, r, g, b);
}

fn updateDisplay() void {
    if (main_window) |win| win.setBackgroundColor(settings.background_color);
    if (time_layer) |tl| tl.setTextColor(settings.text_color);
    if (date_layer) |dl| {
        dl.setTextColor(settings.text_color);
        dl.setHidden(!settings.show_date);
    }
    if (weather_layer) |wl| wl.setTextColor(settings.text_color);
    if (battery_layer) |bl| bl.markDirty();
}

// ─── Time / date ─────────────────────────────────────────────────────────────

fn updateTime() void {
    var temp: c.time_t = c.time(null);
    const tick_time = c.localtime(&temp);
    const fmt: [*:0]const u8 = if (pebble.clock.is24h()) "%H:%M" else "%I:%M";
    _ = c.strftime(&time_buf, time_buf.len, fmt, tick_time);
    if (time_layer) |tl| tl.setText(&time_buf);
    _ = c.strftime(&date_buf, date_buf.len, "%a %b %d", tick_time);
    if (date_layer) |dl| dl.setText(&date_buf);
}

fn tickHandler(tick_time: ?*c.tm, _: c.TimeUnits) callconv(.c) void {
    updateTime();
    if (tick_time) |t| {
        if (@mod(t.tm_min, 30) == 0) requestWeather();
    }
}

fn requestWeather() void {
    var iter: ?*c.DictionaryIterator = null;
    pebble.app_message.outboxBegin(&iter);
    if (iter) |i| {
        _ = pebble.dictionary.writeUint8(i, keys.MESSAGE_KEY_REQUEST_WEATHER, 1);
        pebble.app_message.outboxSend();
    }
}

// ─── Battery ─────────────────────────────────────────────────────────────────

fn batteryCallback(state: c.BatteryChargeState) callconv(.c) void {
    battery_level = state.charge_percent;
    if (battery_layer) |bl| bl.markDirty();
}

fn batteryUpdateProc(layer: ?*c.Layer, ctx: ?*c.GContext) callconv(.c) void {
    const bounds = pebble.layer_get_bounds(layer);
    const bar_width: i16 = @intCast(@divTrunc(
        battery_level * (@as(i32, bounds.size.w) - 4),
        100,
    ));

    pebble.graphics.setStrokeColor(ctx, settings.text_color);
    pebble.graphics.drawRoundRect(ctx, bounds, 2);

    const bar_color: pebble.gcolor.GColor = if (pebble.PBL_COLOR) blk: {
        if (battery_level <= 20) break :blk pebble.gcolor.GColorRed;
        if (battery_level <= 40) break :blk pebble.gcolor.GColorChromeYellow;
        break :blk pebble.gcolor.GColorGreen;
    } else settings.text_color;

    pebble.graphics.setFillColor(ctx, bar_color);
    pebble.graphics.fillRect(
        ctx,
        c.GRect{
            .origin = .{ .x = 2, .y = 2 },
            .size = .{ .w = bar_width, .h = bounds.size.h - 4 },
        },
        1,
        pebble.GCornerNone,
    );
}

// ─── Bluetooth ───────────────────────────────────────────────────────────────

fn bluetoothCallback(connected: bool) callconv(.c) void {
    if (bt_icon_layer) |bl| bl.setHidden(connected);
    if (!connected) pebble.vibes.doublePulse();
}

// ─── AppMessage ──────────────────────────────────────────────────────────────

fn inboxReceived(iterator: ?*c.DictionaryIterator, _: ?*anyopaque) callconv(.c) void {
    const iter = iterator orelse return;

    const temp_tuple = pebble.dictionary.find(iter, keys.MESSAGE_KEY_TEMPERATURE);
    const cond_tuple = pebble.dictionary.find(iter, keys.MESSAGE_KEY_CONDITIONS);

    if (temp_tuple != null and cond_tuple != null) {
        var temp_value: i32 = pebble.tuple.getInt32(temp_tuple.?);
        const unit: [*:0]const u8 = if (settings.temperature_unit) blk: {
            temp_value = @divTrunc(temp_value * 9, 5) + 32;
            break :blk "\xc2\xb0F"; // °F in UTF-8
        } else "\xc2\xb0C"; // °C in UTF-8

        const cond_str = pebble.tuple.getCString(cond_tuple.?);
        _ = c.snprintf(&weather_buf, weather_buf.len, "%d%s %s", temp_value, unit, cond_str);
        if (weather_layer) |wl| wl.setText(&weather_buf);
    }

    var need_save = false;

    if (pebble.dictionary.find(iter, keys.MESSAGE_KEY_BackgroundColor)) |t| {
        settings.background_color = gcolorFromHex(pebble.tuple.getInt32(t));
        need_save = true;
    }
    if (pebble.dictionary.find(iter, keys.MESSAGE_KEY_TextColor)) |t| {
        settings.text_color = gcolorFromHex(pebble.tuple.getInt32(t));
        need_save = true;
    }
    if (pebble.dictionary.find(iter, keys.MESSAGE_KEY_TemperatureUnit)) |t| {
        settings.temperature_unit = pebble.tuple.getInt32(t) == 1;
        need_save = true;
        requestWeather();
    }
    if (pebble.dictionary.find(iter, keys.MESSAGE_KEY_ShowDate)) |t| {
        settings.show_date = pebble.tuple.getInt32(t) == 1;
        need_save = true;
    }

    if (need_save) {
        saveSettings();
        updateDisplay();
    }
}

fn inboxDropped(_: c.AppMessageResult, _: ?*anyopaque) callconv(.c) void {
    pebble.app.err("Message dropped!", .{});
}

fn outboxFailed(_: ?*c.DictionaryIterator, _: c.AppMessageResult, _: ?*anyopaque) callconv(.c) void {
    pebble.app.err("Outbox send failed!", .{});
}

fn outboxSent(_: ?*c.DictionaryIterator, _: ?*anyopaque) callconv(.c) void {
    pebble.app.info("Outbox send success!", .{});
}

// ─── Unobstructed area ───────────────────────────────────────────────────────

fn repositionLayers() void {
    const bounds = pebble.unobstructed.getBounds(window_layer);
    const block_height: i16 = 56 + 30;
    const time_y: i16 = @divTrunc(bounds.size.h, 2) - @divTrunc(block_height, 2) - 10;
    const date_y: i16 = time_y + 56;
    const weather_y: i16 = bounds.size.h - (if (pebble.PBL_ROUND) @as(i16, 40) else @as(i16, 30));

    if (time_layer) |tl| {
        var frame = tl.getFrame();
        frame.origin.y = time_y;
        tl.setFrame(frame);
    }
    if (date_layer) |dl| {
        var frame = dl.getFrame();
        frame.origin.y = date_y;
        dl.setFrame(frame);
    }
    if (weather_layer) |wl| {
        var frame = wl.getFrame();
        frame.origin.y = weather_y;
        wl.setFrame(frame);
    }
}

fn unobstructedWillChange(_: c.GRect, _: ?*anyopaque) callconv(.c) void {
    if (bt_icon_layer) |bl| bl.setHidden(true);
}

fn unobstructedChange(_: c.AnimationProgress, _: ?*anyopaque) callconv(.c) void {
    repositionLayers();
}

fn unobstructedDidChange(_: ?*anyopaque) callconv(.c) void {
    const full = pebble.layer_get_bounds(window_layer);
    const unobstructed_bounds = pebble.unobstructed.getBounds(window_layer);
    const obstructed = !pebble.grect_equal(&full, &unobstructed_bounds);
    if (bt_icon_layer) |bl| {
        bl.setHidden(if (obstructed) true else pebble.event.connection.isPebbleAppConnected());
    }
}

// ─── Window handlers ─────────────────────────────────────────────────────────

fn windowLoad(raw_window: ?*c.Window) callconv(.c) void {
    const win = pebble.Window.fromRaw(raw_window.?);
    window_layer = win.getRootLayer();
    const bounds = pebble.layer_get_bounds(window_layer);

    time_font = pebble.fonts.loadCustom(pebble.resources.getHandle(keys.RESOURCE_ID_FONT_JERSEY_56));
    date_font = pebble.fonts.loadCustom(pebble.resources.getHandle(keys.RESOURCE_ID_FONT_JERSEY_24));

    const block_height: i16 = 56 + 30;
    const time_y: i16 = @divTrunc(bounds.size.h, 2) - @divTrunc(block_height, 2) - 10;
    const date_y: i16 = time_y + 56;

    time_layer = pebble.TextLayer.create(.{
        .origin = .{ .x = 0, .y = time_y },
        .size = .{ .w = bounds.size.w, .h = 60 },
    });
    if (time_layer) |tl| {
        tl.setBackgroundColor(pebble.gcolor.GColorClear);
        tl.setTextColor(settings.text_color);
        tl.setFont(time_font);
        tl.setTextAlignment(pebble.GTextAlignmentCenter);
    }

    date_layer = pebble.TextLayer.create(.{
        .origin = .{ .x = 0, .y = date_y },
        .size = .{ .w = bounds.size.w, .h = 30 },
    });
    if (date_layer) |dl| {
        dl.setBackgroundColor(pebble.gcolor.GColorClear);
        dl.setTextColor(settings.text_color);
        dl.setFont(date_font);
        dl.setTextAlignment(pebble.GTextAlignmentCenter);
    }

    const weather_y: i16 = bounds.size.h - (if (pebble.PBL_ROUND) @as(i16, 40) else @as(i16, 30));
    weather_layer = pebble.TextLayer.create(.{
        .origin = .{ .x = 0, .y = weather_y },
        .size = .{ .w = bounds.size.w, .h = 25 },
    });
    if (weather_layer) |wl| {
        wl.setBackgroundColor(pebble.gcolor.GColorClear);
        wl.setTextColor(settings.text_color);
        wl.setFont(pebble.fonts.getSystem("FONT_KEY_GOTHIC_18"));
        wl.setTextAlignment(pebble.GTextAlignmentCenter);
        wl.setText("Loading...");
    }

    const bar_width: i16 = @divTrunc(bounds.size.w, 2);
    const bar_x: i16 = @divTrunc(bounds.size.w - bar_width, 2);
    const bar_y: i16 = if (pebble.PBL_ROUND)
        @divTrunc(bounds.size.h, 8)
    else
        @divTrunc(bounds.size.h, 28);
    battery_layer = pebble.Layer.create(.{
        .origin = .{ .x = bar_x, .y = bar_y },
        .size = .{ .w = bar_width, .h = 8 },
    });
    if (battery_layer) |bl| bl.setUpdateProc(&batteryUpdateProc);

    bt_icon_bitmap = pebble.bitmap.GBitmap.createWithResource(keys.RESOURCE_ID_IMAGE_BT_ICON);
    const bt_y: i16 = bar_y + 12;
    bt_icon_layer = pebble.BitmapLayer.create(.{
        .origin = .{ .x = @divTrunc(bounds.size.w - 30, 2), .y = bt_y },
        .size = .{ .w = 30, .h = 30 },
    });
    if (bt_icon_layer) |bil| {
        bil.setBitmap(if (bt_icon_bitmap) |bm| bm.getRaw() else null);
        bil.setCompositingMode(pebble.GCompOpSet);
    }

    if (time_layer) |tl| pebble.layer_add_child(window_layer, tl.asLayer());
    if (date_layer) |dl| pebble.layer_add_child(window_layer, dl.asLayer());
    if (weather_layer) |wl| pebble.layer_add_child(window_layer, wl.asLayer());
    if (battery_layer) |bl| pebble.layer_add_child(window_layer, bl.getRaw());
    if (bt_icon_layer) |bil| pebble.layer_add_child(window_layer, bil.asLayer());

    updateDisplay();
    repositionLayers();
    unobstructedDidChange(null);

    pebble.unobstructed.subscribe(pebble.unobstructed.Handlers{
        .will_change = &unobstructedWillChange,
        .change = &unobstructedChange,
        .did_change = &unobstructedDidChange,
    }, null);
}

fn windowUnload(_: ?*c.Window) callconv(.c) void {
    if (time_layer) |tl| { tl.destroy(); time_layer = null; }
    if (date_layer) |dl| { dl.destroy(); date_layer = null; }
    if (weather_layer) |wl| { wl.destroy(); weather_layer = null; }
    pebble.fonts.unloadCustom(time_font);
    pebble.fonts.unloadCustom(date_font);
    if (battery_layer) |bl| { bl.destroy(); battery_layer = null; }
    if (bt_icon_bitmap) |bm| { bm.destroy(); bt_icon_bitmap = null; }
    if (bt_icon_layer) |bil| { bil.destroy(); bt_icon_layer = null; }
}

// ─── App lifecycle ────────────────────────────────────────────────────────────

fn init() void {
    loadSettings();

    main_window = pebble.Window.create();
    if (main_window) |win| {
        win.setBackgroundColor(settings.background_color);
        win.setHandlers(.{
            .load = &windowLoad,
            .appear = null,
            .disappear = null,
            .unload = &windowUnload,
        });
        win.push(true);
    }

    updateTime();

    pebble.clock.tickSubscribe(pebble.clock.MINUTE_UNIT, &tickHandler);

    pebble.event.battery.subscribe(&batteryCallback);
    batteryCallback(pebble.event.battery.peek());

    pebble.event.connection.subscribe(.{
        .pebble_app_connection_handler = &bluetoothCallback,
        .pebblekit_connection_handler = null,
    });

    pebble.app_message.registerInboxReceived(&inboxReceived);
    pebble.app_message.registerInboxDropped(&inboxDropped);
    pebble.app_message.registerOutboxFailed(&outboxFailed);
    pebble.app_message.registerOutboxSent(&outboxSent);
    pebble.app_message.open(256, 256);
}

fn deinit() void {
    if (main_window) |win| win.destroy();
}

pub export fn main() void {
    init();
    pebble.app.eventLoop();
    deinit();
}
