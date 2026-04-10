/// Convenience helpers for Pebble Tuple values.
///
/// The raw C `Tuple` type has a flexible array member `value[]` that
/// zig translate-c cannot represent (emits opaque {}).  build.zig patches
/// the generated c.zig to inject a concrete packed-struct definition that
/// contains only the header fields (key, type, length).  The variable-length
/// value bytes immediately follow the header in memory; access them via the
/// helpers below which use pointer arithmetic.
const c = @import("c");
const std = @import("std");

pub const Tuple = c.Tuple;

/// Pointer to the value bytes that follow the Tuple header in memory.
inline fn valueBytes(tuple: *const c.Tuple) [*]const u8 {
    return @as([*]const u8, @ptrCast(tuple)) + @sizeOf(c.Tuple);
}

/// Returns the value as a null-terminated C string pointer.
/// Only valid when `tuple.type` is `TUPLE_CSTRING`.
pub fn getCString(tuple: *const Tuple) [*:0]const u8 {
    return @ptrCast(valueBytes(tuple));
}

/// Returns the value as a Zig slice.
/// Only valid when `tuple.type` is `TUPLE_BYTE_ARRAY` or `TUPLE_CSTRING`.
pub fn getData(tuple: *const Tuple) []const u8 {
    return valueBytes(tuple)[0..tuple.length];
}

/// Returns the value as a u32.
/// Only valid when `tuple.type` is `TUPLE_UINT` and `tuple.length` is 4.
pub fn getUint32(tuple: *const Tuple) u32 {
    return @as(*align(1) const u32, @ptrCast(valueBytes(tuple))).*;
}

/// Returns the value as an i32.
/// Only valid when `tuple.type` is `TUPLE_INT` and `tuple.length` is 4.
pub fn getInt32(tuple: *const Tuple) i32 {
    return @as(*align(1) const i32, @ptrCast(valueBytes(tuple))).*;
}

/// Returns the value as a u16.
/// Only valid when `tuple.type` is `TUPLE_UINT` and `tuple.length` is 2.
pub fn getUint16(tuple: *const Tuple) u16 {
    return @as(*align(1) const u16, @ptrCast(valueBytes(tuple))).*;
}

/// Returns the value as an i16.
/// Only valid when `tuple.type` is `TUPLE_INT` and `tuple.length` is 2.
pub fn getInt16(tuple: *const Tuple) i16 {
    return @as(*align(1) const i16, @ptrCast(valueBytes(tuple))).*;
}

/// Returns the value as a u8.
/// Only valid when `tuple.type` is `TUPLE_UINT` and `tuple.length` is 1.
pub fn getUint8(tuple: *const Tuple) u8 {
    return valueBytes(tuple)[0];
}

/// Returns the value as an i8.
/// Only valid when `tuple.type` is `TUPLE_INT` and `tuple.length` is 1.
pub fn getInt8(tuple: *const Tuple) i8 {
    return @bitCast(valueBytes(tuple)[0]);
}

// ─── Tuplet construction helpers (for AppSync initial values) ────────────────

pub const Tuplet = c.Tuplet;

/// Creates a Tuplet containing a null-terminated C string.
pub fn tupletCString(key: u32, cstring: [*:0]const u8) Tuplet {
    return Tuplet{
        .type = c.TUPLE_CSTRING,
        .key = key,
        .unnamed_0 = .{
            .cstring = .{
                .data = cstring,
                .length = @intCast(std.mem.len(cstring) + 1),
            },
        },
    };
}

/// Creates a Tuplet containing an unsigned integer.
pub fn tupletInteger(key: u32, value: u32) Tuplet {
    return Tuplet{
        .type = c.TUPLE_UINT,
        .key = key,
        .unnamed_0 = .{
            .integer = .{
                .storage = value,
                .width = @sizeOf(u32),
            },
        },
    };
}
