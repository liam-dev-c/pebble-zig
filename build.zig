const std = @import("std");

// ─── Public API ──────────────────────────────────────────────────────────────

pub const PebbleAppOptions = struct {
    name: []const u8,
    root_source_file: std.Build.LazyPath,
    /// Path to this package's src/pebble.zig.
    /// Defaults to the pebble-zig package root when used as a dependency.
    pebble_lib_path: ?std.Build.LazyPath = null,
    /// Directory that contains pebble.h (the SDK include path).
    /// Auto-discovered from ~/.pebble-sdk if not set.
    pebble_sdk_include_path: ?std.Build.LazyPath = null,
    /// Output path for the generated keys Zig file (from package.json).
    /// Defaults to "src/generated_keys.zig".
    keys_output_path: []const u8 = "src/generated_keys.zig",
};

/// Creates and returns the `pebble` module configured for the Pebble target.
/// `optimize` and `defines` must already be resolved by the caller.
pub fn addPebbleModule(
    b: *std.Build,
    options: PebbleAppOptions,
    optimize: std.builtin.OptimizeMode,
    defines: PlatformDefines,
) *std.Build.Module {
    const target = pebbleTarget(b);

    const build_options = b.addOptions();
    build_options.addOption(bool, "PBL_BW",               defines.PBL_BW);
    build_options.addOption(bool, "PBL_COLOR",            defines.PBL_COLOR);
    build_options.addOption(bool, "PBL_MICROPHONE",       defines.PBL_MICROPHONE);
    build_options.addOption(bool, "PBL_COMPASS",          defines.PBL_COMPASS);
    build_options.addOption(bool, "PBL_SMARTSTRAP",       defines.PBL_SMARTSTRAP);
    build_options.addOption(bool, "PBL_SMARTSTRAP_POWER", defines.PBL_SMARTSTRAP_POWER);
    build_options.addOption(bool, "PBL_HEALTH",           defines.PBL_HEALTH);
    build_options.addOption(bool, "PBL_RECT",             defines.PBL_RECT);
    build_options.addOption(bool, "PBL_ROUND",            defines.PBL_ROUND);

    const pebble_lib = options.pebble_lib_path orelse b.path("src/pebble.zig");

    // Generate c.zig from SDK headers
    const c_zig = generateCBindings(b, options.pebble_sdk_include_path);

    const pebble_mod = b.addModule("pebble", .{
        .root_source_file = pebble_lib,
        .target = target,
        .optimize = optimize,
        .link_libc = false,
        .single_threaded = true,
        .sanitize_c = .off,
        .pic = true,
        .unwind_tables = std.builtin.UnwindTables.none,
        .omit_frame_pointer = true,
    });
    pebble_mod.addImport("build_options", build_options.createModule());
    pebble_mod.addImport("c", c_zig);

    return pebble_mod;
}

/// Builds a Pebble app `.o` file and installs it to
/// `zig-out/{PLATFORM_NAME}/{name}.o` for the Pebble SDK linker to pick up.
pub fn addPebbleApp(b: *std.Build, options: PebbleAppOptions) void {
    generateKeys(b.allocator, "package.json", options.keys_output_path, "generated") catch |err| {
        std.debug.print("Warning: failed to generate keys from package.json: {}\n", .{err});
    };

    const platform_name = b.option([]const u8, "PLATFORM_NAME", "Platform name (aplite/basalt/chalk/diorite/emery)") orelse "basalt";
    const defines_str = b.option([]const u8, "DEFINES", "Comma-separated platform defines from Pebble SDK") orelse "";
    const defines = parsePlatformDefines(defines_str);
    const optimize = b.standardOptimizeOption(.{ .preferred_optimize_mode = .ReleaseSmall });
    const target = pebbleTarget(b);

    const pebble_mod = addPebbleModule(b, options, optimize, defines);

    const app_mod = b.addModule(options.name, .{
        .root_source_file = options.root_source_file,
        .target = target,
        .optimize = optimize,
        .link_libc = false,
        .single_threaded = true,
        .sanitize_c = .off,
        .pic = true,
        .unwind_tables = std.builtin.UnwindTables.none,
        .omit_frame_pointer = true,
    });
    app_mod.addImport("pebble", pebble_mod);

    const obj = b.addObject(.{
        .name = options.name,
        .root_module = app_mod,
    });

    const output_path = b.fmt("{s}/{s}.o", .{ platform_name, options.name });
    const install_obj = b.addInstallFile(obj.getEmittedBin(), output_path);
    b.default_step.dependOn(&install_obj.step);
}

// ─── C bindings generation ──────────────────────────────────────────────────

/// Generates the "c" module from Pebble SDK headers as a build DAG step:
///   1. Write stub headers into the build cache
///   2. Preprocess pebble.h with arm-none-eabi-gcc -E -nostdinc using stubs
///   3. Strip preprocessor line markers
///   4. Run zig translate-c on the result
fn generateCBindings(b: *std.Build, sdk_include_override: ?std.Build.LazyPath) *std.Build.Module {
    _ = sdk_include_override;

    const sdk_path = discoverSdkPath(b.allocator) orelse
        @panic("Pebble SDK not found at ~/.pebble-sdk. Install the SDK or set pebble_sdk_include_path.");

    const pebble_include_path = b.pathJoin(&.{ sdk_path, "sdk-core/pebble/basalt/include" });
    const arm_gcc = discoverArmGcc(b.allocator) orelse
        @panic("arm-none-eabi-gcc not found. Install Pebble SDK toolchain.");

    // Step 1: Write stub headers into the build cache
    const wf = b.addWriteFiles();
    _ = wf.add("stubs/stdint.h",  STUB_STDINT);
    _ = wf.add("stubs/stddef.h",  STUB_STDDEF);
    _ = wf.add("stubs/stdbool.h", STUB_STDBOOL);
    _ = wf.add("stubs/stdio.h",   STUB_STDIO);
    _ = wf.add("stubs/stdlib.h",  STUB_STDLIB);
    _ = wf.add("stubs/string.h",  STUB_STRING);
    _ = wf.add("stubs/time.h",    STUB_TIME);
    _ = wf.add("stubs/locale.h",  STUB_LOCALE);
    _ = wf.add("message_keys.auto.h", "#pragma once\n");
    _ = wf.add("src/resource_ids.auto.h", "#pragma once\n");
    const wf_dir = wf.getDirectory();

    // Step 2: Preprocess pebble.h with arm-none-eabi-gcc using stubs
    const preprocess = b.addSystemCommand(&.{arm_gcc});
    preprocess.addArgs(&.{ "-E", "-nostdinc" });
    preprocess.addPrefixedDirectoryArg("-I", wf_dir.path(b, "stubs"));
    preprocess.addPrefixedDirectoryArg("-I", wf_dir);
    preprocess.addPrefixedDirectoryArg("-I", .{ .cwd_relative = pebble_include_path });
    preprocess.addArgs(&.{
        "-DPBL_COLOR",  "-DPBL_BW",
        "-DPBL_RECT",   "-DPBL_ROUND",
        "-DPBL_HEALTH", "-DPBL_MICROPHONE",
        "-DPBL_COMPASS", "-DPBL_SMARTSTRAP", "-DPBL_SMARTSTRAP_POWER",
    });
    preprocess.addArg(b.pathJoin(&.{ pebble_include_path, "pebble.h" }));
    preprocess.setStdIn(.{ .none = {} });
    const preprocessed = preprocess.captureStdOut();

    // Step 3: Strip preprocessor line markers and write to a .h file
    const strip = b.addSystemCommand(&.{ "bash", "-c", "sed '/^#/d' \"$1\" > \"$2\"", "_" });
    strip.addFileArg(preprocessed);
    const stripped_h = strip.addOutputFileArg("preprocessed.h");

    // Step 4: Run zig translate-c → c.zig
    const translate = b.addSystemCommand(&.{
        "bash", "-c", "zig translate-c -target thumb-freestanding-eabi \"$1\" > \"$2\"", "_",
    });
    translate.addFileArg(stripped_h);
    const c_zig_raw = translate.addOutputFileArg("c.zig");

    // Step 5: Fix GColor8 — translate-c emits an opaque {} for the anonymous
    // bitfield struct inside the union, which Zig rejects.  Strip those lines
    // so the union keeps only its `argb: u8` member and compiles cleanly.
    const patch = b.addSystemCommand(&.{
        "bash", "-c",
        "sed -e '/^const struct_unnamed_[0-9]* = opaque {};$/d'" ++
        "    -e '/^    unnamed_[0-9]*: struct_unnamed_[0-9]*,$/d'" ++
        "    \"$1\" > \"$2\"",
        "_",
    });
    patch.addFileArg(c_zig_raw);
    const c_zig_source = patch.addOutputFileArg("c.zig");

    return b.createModule(.{
        .root_source_file = c_zig_source,
        .target = pebbleTarget(b),
        .link_libc = false,
        .single_threaded = true,
    });
}

fn discoverSdkPath(allocator: std.mem.Allocator) ?[]const u8 {
    const home = std.posix.getenv("HOME") orelse return null;
    const path = std.fmt.allocPrint(allocator, "{s}/.pebble-sdk/SDKs/current", .{home}) catch return null;
    std.fs.cwd().access(path, .{}) catch {
        allocator.free(path);
        return null;
    };
    return path;
}

fn discoverArmGcc(allocator: std.mem.Allocator) ?[]const u8 {
    const home = std.posix.getenv("HOME") orelse return null;
    const path = std.fmt.allocPrint(
        allocator,
        "{s}/.pebble-sdk/SDKs/current/toolchain/arm-none-eabi/bin/arm-none-eabi-gcc",
        .{home},
    ) catch return null;
    std.fs.cwd().access(path, .{}) catch {
        allocator.free(path);
        return "arm-none-eabi-gcc";
    };
    return path;
}

// ─── Stub header contents ────────────────────────────────────────────────────

const STUB_STDINT =
    \\#pragma once
    \\typedef signed char int8_t;
    \\typedef unsigned char uint8_t;
    \\typedef signed short int16_t;
    \\typedef unsigned short uint16_t;
    \\typedef signed int int32_t;
    \\typedef unsigned int uint32_t;
    \\typedef signed long long int64_t;
    \\typedef unsigned long long uint64_t;
    \\typedef int intptr_t;
    \\typedef unsigned int uintptr_t;
    \\#define INT8_MIN (-128)
    \\#define INT8_MAX 127
    \\#define UINT8_MAX 255
    \\#define INT16_MIN (-32768)
    \\#define INT16_MAX 32767
    \\#define UINT16_MAX 65535
    \\#define INT32_MIN (-2147483647-1)
    \\#define INT32_MAX 2147483647
    \\#define UINT32_MAX 4294967295U
    \\
;

const STUB_STDDEF =
    \\#pragma once
    \\typedef unsigned int size_t;
    \\typedef int ptrdiff_t;
    \\#define NULL ((void *)0)
    \\#define offsetof(type, member) __builtin_offsetof(type, member)
    \\
;

const STUB_STDBOOL =
    \\#pragma once
    \\#define bool _Bool
    \\#define true 1
    \\#define false 0
    \\
;

const STUB_STDIO =
    \\#pragma once
    \\#include <stddef.h>
    \\
;

const STUB_STDLIB =
    \\#pragma once
    \\#include <stddef.h>
    \\
;

const STUB_STRING =
    \\#pragma once
    \\#include <stddef.h>
    \\
;

const STUB_TIME =
    \\#pragma once
    \\typedef long time_t;
    \\#define TZ_LEN 6
    \\
;

const STUB_LOCALE =
    \\#pragma once
    \\
;

// ─── Helpers ─────────────────────────────────────────────────────────────────

fn pebbleTarget(b: *std.Build) std.Build.ResolvedTarget {
    return b.resolveTargetQuery(.{
        .cpu_arch = .thumb,
        .os_tag = .freestanding,
        .abi = .eabi,
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m4 },
        .cpu_features_add = std.Target.arm.featureSet(&[_]std.Target.arm.Feature{
            std.Target.arm.Feature.fp_armv8d16sp,
        }),
    });
}

pub const PlatformDefines = struct {
    PBL_BW: bool              = false,
    PBL_COLOR: bool           = false,
    PBL_MICROPHONE: bool      = false,
    PBL_COMPASS: bool         = false,
    PBL_SMARTSTRAP: bool      = false,
    PBL_SMARTSTRAP_POWER: bool= false,
    PBL_HEALTH: bool          = false,
    PBL_RECT: bool            = false,
    PBL_ROUND: bool           = false,
};

pub fn parsePlatformDefines(defines_str: []const u8) PlatformDefines {
    var d = PlatformDefines{};
    var iter = std.mem.splitScalar(u8, defines_str, ',');
    while (iter.next()) |define| {
        if (std.mem.eql(u8, define, "PBL_BW"))               d.PBL_BW = true;
        if (std.mem.eql(u8, define, "PBL_COLOR"))            d.PBL_COLOR = true;
        if (std.mem.eql(u8, define, "PBL_MICROPHONE"))       d.PBL_MICROPHONE = true;
        if (std.mem.eql(u8, define, "PBL_COMPASS"))          d.PBL_COMPASS = true;
        if (std.mem.eql(u8, define, "PBL_SMARTSTRAP"))       d.PBL_SMARTSTRAP = true;
        if (std.mem.eql(u8, define, "PBL_SMARTSTRAP_POWER")) d.PBL_SMARTSTRAP_POWER = true;
        if (std.mem.eql(u8, define, "PBL_HEALTH"))           d.PBL_HEALTH = true;
        if (std.mem.eql(u8, define, "PBL_RECT"))             d.PBL_RECT = true;
        if (std.mem.eql(u8, define, "PBL_ROUND"))            d.PBL_ROUND = true;
    }
    return d;
}

/// Reads package.json and emits a Zig file with resource IDs and message key constants.
pub fn generateKeys(
    allocator: std.mem.Allocator,
    package_json_path: []const u8,
    zig_output_path: []const u8,
    c_output_dir: []const u8,
) !void {
    const package_json = try std.fs.cwd().readFileAlloc(allocator, package_json_path, 10 * 1024 * 1024);
    defer allocator.free(package_json);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, package_json, .{});
    defer parsed.deinit();

    var zig_buf = std.ArrayList(u8){};
    defer zig_buf.deinit(allocator);
    const zw = zig_buf.writer(allocator);
    try zw.writeAll("// Auto-generated from package.json — do not edit\n\n");

    var res_buf = std.ArrayList(u8){};
    defer res_buf.deinit(allocator);
    const rw = res_buf.writer(allocator);
    try rw.writeAll("#pragma once\n// Auto-generated from package.json\n\n");

    var msg_buf = std.ArrayList(u8){};
    defer msg_buf.deinit(allocator);
    const mw = msg_buf.writer(allocator);
    try mw.writeAll("#pragma once\n// Auto-generated from package.json\n\n");

    try zw.writeAll("// Resource IDs\n");
    if (parsed.value.object.get("pebble")) |pebble| {
        if (pebble.object.get("resources")) |resources| {
            if (resources.object.get("media")) |media| {
                for (media.array.items, 0..) |item, i| {
                    const name = item.object.get("name").?.string;
                    var upper_buf: [256]u8 = undefined;
                    const upper = toUpper(name, &upper_buf);
                    try zw.print("pub const RESOURCE_ID_{s} = {d};\n", .{ upper, i + 1 });
                    try rw.print("#define RESOURCE_ID_{s} {d}\n", .{ upper, i + 1 });
                }
            }
        }
    }

    try zw.writeAll("\n// Message Keys\n");
    if (parsed.value.object.get("pebble")) |pebble| {
        if (pebble.object.get("messageKeys")) |message_keys| {
            for (message_keys.array.items, 0..) |item, i| {
                const key = item.string;
                try zw.print("pub const MESSAGE_KEY_{s} = {d};\n", .{ key, 10000 + i });
                try mw.print("#define MESSAGE_KEY_{s} {d}\n", .{ key, 10000 + i });
            }
        }
    }

    if (std.mem.lastIndexOfScalar(u8, zig_output_path, '/')) |end| {
        std.fs.cwd().makePath(zig_output_path[0..end]) catch {};
    }
    try std.fs.cwd().writeFile(.{ .sub_path = zig_output_path, .data = zig_buf.items });

    std.fs.cwd().makePath(c_output_dir) catch {};
    const src_dir = try std.fmt.allocPrint(allocator, "{s}/src", .{c_output_dir});
    defer allocator.free(src_dir);
    std.fs.cwd().makePath(src_dir) catch {};

    const res_path = try std.fmt.allocPrint(allocator, "{s}/src/resource_ids.auto.h", .{c_output_dir});
    defer allocator.free(res_path);
    const msg_path = try std.fmt.allocPrint(allocator, "{s}/message_keys.auto.h", .{c_output_dir});
    defer allocator.free(msg_path);
    try std.fs.cwd().writeFile(.{ .sub_path = res_path, .data = res_buf.items });
    try std.fs.cwd().writeFile(.{ .sub_path = msg_path, .data = msg_buf.items });
}

fn toUpper(input: []const u8, buf: *[256]u8) []const u8 {
    const len = @min(input.len, 256);
    for (0..len) |i| buf[i] = std.ascii.toUpper(input[i]);
    return buf[0..len];
}

// ─── build() — no-op for the library itself ──────────────────────────────────

pub fn build(_: *std.Build) void {
    // pebble-zig is a library package; there is nothing to build on its own.
    // Apps consume it via addPebbleApp() or addPebbleModule() above.
}
