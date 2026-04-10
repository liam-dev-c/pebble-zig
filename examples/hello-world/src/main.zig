/// Hello World — minimal pebble-zig example
///
/// Displays "Hello from Zig!" in a TextLayer centered on screen.
const pebble = @import("pebble");
const c = pebble.c;

// ─── App state ───────────────────────────────────────────────────────────────

var main_window: ?pebble.Window = null;
var text_layer: ?pebble.TextLayer = null;

// ─── Window handlers ─────────────────────────────────────────────────────────

export fn windowLoad(raw_window: ?*c.Window) void {
    const win = pebble.Window.fromRaw(raw_window.?);
    const root = win.getRootLayer();
    const bounds = pebble.layer_get_bounds(root);

    // Center a TextLayer in the middle of the screen
    text_layer = pebble.TextLayer.create(.{
        .origin = .{
            .x = 0,
            .y = @divTrunc(bounds.size.h, 2) - 12,
        },
        .size = .{ .w = bounds.size.w, .h = 28 },
    });

    if (text_layer) |tl| {
        tl.setText("Hello from Zig!");
        tl.setTextAlignment(pebble.GTextAlignmentCenter);
        tl.setBackgroundColor(pebble.gcolor.GColorClear);
        tl.setTextColor(pebble.gcolor.GColorBlack);
        tl.setFont(pebble.fonts.getSystem("RESOURCE_ID_GOTHIC_24_BOLD"));
        pebble.layer_add_child(root, tl.asLayer());
    }

    pebble.app.info("Window loaded", .{});
}

export fn windowUnload(_: ?*c.Window) void {
    if (text_layer) |tl| {
        tl.destroy();
        text_layer = null;
    }
}

// ─── App lifecycle ────────────────────────────────────────────────────────────

fn init() void {
    main_window = pebble.Window.create();

    if (main_window) |win| {
        if (pebble.PBL_COLOR) {
            win.setBackgroundColor(pebble.gcolor.GColorWhite);
        }

        win.setHandlers(.{
            .load = @ptrCast(&windowLoad),
            .appear = null,
            .disappear = null,
            .unload = @ptrCast(&windowUnload),
        });
        win.push(true);
    }
}

fn deinit() void {
    if (main_window) |win| {
        win.destroy();
        main_window = null;
    }
}

pub export fn main() void {
    init();
    pebble.app.eventLoop();
    deinit();
}
