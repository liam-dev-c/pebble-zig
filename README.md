# pebble-zig

Zig bindings and build system for the [Pebble](https://developer.rebble.io/) smartwatch SDK.

All Pebble SDK functions are available via the raw `pebble.c` module (auto-generated from `pebble.h` at build time). Idiomatic Zig wrappers are provided for common APIs (Window, TextLayer, BitmapLayer, clock, events, etc.) — use `pebble.c` directly for anything not yet wrapped.

## Requirements

- [Zig](https://ziglang.org/) 0.15+
- [Pebble SDK](https://developer.rebble.io/) installed at `~/.pebble-sdk`

## Quick start

```bash
cd examples/hello-world

# Build for all platforms
pebble build

# Run on the basalt emulator
pebble install --emulator basalt

# Or target a specific emulator
pebble install --emulator chalk
pebble install --emulator aplite
```

## Using as a dependency

Add pebble-zig to your project's `build.zig.zon`:

```zig
.dependencies = .{
    .pebble_zig = .{
        .path = "path/to/pebble-zig",
    },
},
```

Then in your `build.zig`:

```zig
const pebble_build = @import("pebble_zig");

pub fn build(b: *std.Build) void {
    const pebble_zig = b.dependency("pebble_zig", .{});

    pebble_build.addPebbleApp(b, .{
        .name = "my-app",
        .root_source_file = b.path("src/main.zig"),
        .pebble_lib_path = pebble_zig.path("src/pebble.zig"),
    });
}
```

## Project structure

```
src/pebble.zig             Root module (re-exports everything)
src/pebble/app.zig         App lifecycle: eventLoop(), log/debug/info/warn/err
src/pebble/window.zig      Window wrapper
src/pebble/layer.zig       Layer, TextLayer, BitmapLayer wrappers
src/pebble/clock.zig       Clock and tick timer
src/pebble/gcolor.zig      GColor type and full named color palette
src/pebble/types.zig       Common type re-exports (GRect, GPoint, GFont, ...)
src/pebble/app_message.zig AppMessage send/receive helpers
src/pebble/tuple.zig       Tuple value helpers: getCString(), getUint32(), etc.
src/pebble/event/          Battery and connection event subscriptions
build.zig                  addPebbleApp() / addPebbleModule() + translate-c pipeline
```
