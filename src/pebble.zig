/// Pebble SDK bindings for Zig
///
/// ## Organization
///
/// - `c`           - Complete raw C API (auto-generated from pebble.h)
/// - `app`         - App lifecycle and logging
/// - `window`      - Window wrapper
/// - `layer`       - Layer, TextLayer, BitmapLayer wrappers
/// - `clock`       - Clock and tick timer
/// - `gcolor`      - GColor type and named color constants
/// - `app_message` - AppMessage send/receive helpers
/// - `app_sync`    - AppSync helpers
/// - `dictionary`  - Dictionary read/write helpers
/// - `tuple`       - Tuple value accessors and Tuplet constructors
/// - `bitmap`      - GBitmap wrapper
/// - `fonts`       - Font loading utilities
/// - `event`       - Battery and connection event subscriptions
///
/// For any API not yet wrapped, use `pebble.c` directly.
pub const c = @import("c");

// Submodules
pub const app = @import("pebble/app.zig");
pub const Window = @import("pebble/window.zig").Window;
pub const layer = @import("pebble/layer.zig");
pub const clock = @import("pebble/clock.zig");
pub const gcolor = @import("pebble/gcolor.zig");
pub const app_message = @import("pebble/app_message.zig");
pub const app_sync = @import("pebble/app_sync.zig");
pub const dictionary = @import("pebble/dictionary.zig");
pub const tuple = @import("pebble/tuple.zig");
pub const bitmap = @import("pebble/bitmap.zig");
pub const fonts = @import("pebble/fonts.zig");
pub const event = @import("pebble/event/root.zig");
pub const graphics = @import("pebble/graphics.zig");
pub const vibes = @import("pebble/vibes.zig");
pub const persist = @import("pebble/persist.zig");
pub const unobstructed = @import("pebble/unobstructed.zig");
pub const resources = @import("pebble/resources.zig");

// Wrapper re-exports
pub const Layer = layer.Layer;
pub const TextLayer = layer.TextLayer;
pub const BitmapLayer = layer.BitmapLayer;
pub const GBitmap = bitmap.GBitmap;

// ─── Type and constant re-exports from C API ─────────────────────────────────
// Sourced from types.zig; listed here so consumers write pebble.GCompOpSet etc.

const types = @import("pebble/types.zig");

pub const GPoint = types.GPoint;
pub const GSize = types.GSize;
pub const GRect = types.GRect;
pub const GFont = types.GFont;
pub const GContext = types.GContext;
pub const GBitmapFormat = types.GBitmapFormat;

pub const GTextAlignment = types.GTextAlignment;
pub const GTextAlignmentLeft = types.GTextAlignmentLeft;
pub const GTextAlignmentCenter = types.GTextAlignmentCenter;
pub const GTextAlignmentRight = types.GTextAlignmentRight;

pub const GCompOp = types.GCompOp;
pub const GCompOpAssign = types.GCompOpAssign;
pub const GCompOpAssignInverted = types.GCompOpAssignInverted;
pub const GCompOpOr = types.GCompOpOr;
pub const GCompOpAnd = types.GCompOpAnd;
pub const GCompOpClear = types.GCompOpClear;
pub const GCompOpSet = types.GCompOpSet;

pub const WindowHandlers = types.WindowHandlers;
pub const ClickRecognizer = types.ClickRecognizer;
pub const TimeUnits = types.TimeUnits;
pub const ResHandle = types.ResHandle;
pub const BatteryChargeState = types.BatteryChargeState;
pub const ConnectionHandlers = types.ConnectionHandlers;

pub const layer_get_bounds = types.layer_get_bounds;
pub const layer_get_frame = types.layer_get_frame;
pub const layer_add_child = types.layer_add_child;
pub const layer_mark_dirty = types.layer_mark_dirty;

pub const grect_equal = c.grect_equal;
pub const GCornerMask = c.GCornerMask;
pub const GCornerNone = c.GCornerNone;

// Platform feature flags (set at build time via build_options)
const build_options = @import("build_options");
pub const PBL_BW: bool = build_options.PBL_BW;
pub const PBL_COLOR: bool = build_options.PBL_COLOR;
pub const PBL_MICROPHONE: bool = build_options.PBL_MICROPHONE;
pub const PBL_COMPASS: bool = build_options.PBL_COMPASS;
pub const PBL_SMARTSTRAP: bool = build_options.PBL_SMARTSTRAP;
pub const PBL_SMARTSTRAP_POWER: bool = build_options.PBL_SMARTSTRAP_POWER;
pub const PBL_HEALTH: bool = build_options.PBL_HEALTH;
pub const PBL_RECT: bool = build_options.PBL_RECT;
pub const PBL_ROUND: bool = build_options.PBL_ROUND;
pub const PBL_DISPLAY_WIDTH: u16 = build_options.PBL_DISPLAY_WIDTH;
pub const PBL_DISPLAY_HEIGHT: u16 = build_options.PBL_DISPLAY_HEIGHT;
