/// Common Pebble type and constant re-exports for convenience.
/// All definitions here are aliases into the raw C bindings.
const c = @import("c");

// Geometry
pub const GPoint = c.GPoint;
pub const GSize  = c.GSize;
pub const GRect  = c.GRect;

// Graphics
pub const GFont  = c.GFont;
pub const GBitmap     = c.GBitmap;
pub const GContext    = c.GContext;
pub const GBitmapFormat = c.GBitmapFormat;

// Text alignment
pub const GTextAlignment      = c.GTextAlignment;
pub const GTextAlignmentLeft   = c.GTextAlignmentLeft;
pub const GTextAlignmentCenter = c.GTextAlignmentCenter;
pub const GTextAlignmentRight  = c.GTextAlignmentRight;

// Compositing
pub const GCompOp               = c.GCompOp;
pub const GCompOpAssign          = c.GCompOpAssign;
pub const GCompOpAssignInverted  = c.GCompOpAssignInverted;
pub const GCompOpOr              = c.GCompOpOr;
pub const GCompOpAnd             = c.GCompOpAnd;
pub const GCompOpClear           = c.GCompOpClear;
pub const GCompOpSet             = c.GCompOpSet;

// Time
pub const TimeUnits = c.TimeUnits;

// Resources
pub const ResHandle = c.ResHandle;

// Data
pub const Tuple              = c.Tuple;
pub const Tuplet             = c.Tuplet;
pub const DictionaryIterator = c.DictionaryIterator;
pub const DictionaryResult   = c.DictionaryResult;
pub const AppMessageResult   = c.AppMessageResult;
pub const AppSync            = c.AppSync;

// Events
pub const BatteryChargeState = c.BatteryChargeState;
pub const ConnectionHandlers = c.ConnectionHandlers;

// Window
pub const WindowHandlers  = c.WindowHandlers;
pub const ClickRecognizer = c.ClickRecognizer;

// Layer functions
pub const layer_get_bounds = c.layer_get_bounds;
pub const layer_get_frame  = c.layer_get_frame;
pub const layer_add_child  = c.layer_add_child;
pub const layer_mark_dirty = c.layer_mark_dirty;
