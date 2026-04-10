/// Convenience helpers for Pebble Tuple values.
///
/// The raw C `Tuple` type uses a flexible array member for its value.
/// These helpers provide safe access to the typed value fields.
const c = @import("c");
const std = @import("std");

pub const Tuple = c.Tuple;

/// Returns the value as a null-terminated C string pointer.
/// Only valid when `tuple.type` is `TUPLE_CSTRING`.
pub fn getCString(tuple: *const Tuple) [*:0]const u8 {
    const val = tuple.value();
    return @ptrCast(&val[0].cstring);
}

/// Returns the value as a Zig slice (not null-terminated).
/// Only valid when `tuple.type` is `TUPLE_BYTE_ARRAY` or `TUPLE_CSTRING`.
pub fn getData(tuple: *const Tuple) []const u8 {
    const val = tuple.value();
    const ptr: [*]const u8 = @ptrCast(&val[0].data);
    return ptr[0..tuple.length];
}

/// Returns the value as a u32.
/// Only valid when `tuple.type` is `TUPLE_UINT`.
pub fn getUint32(tuple: *const Tuple) u32 {
    return tuple.value()[0].uint32;
}

/// Returns the value as an i32.
/// Only valid when `tuple.type` is `TUPLE_INT`.
pub fn getInt32(tuple: *const Tuple) i32 {
    return tuple.value()[0].int32;
}

/// Returns the value as a u16.
pub fn getUint16(tuple: *const Tuple) u16 {
    return tuple.value()[0].uint16;
}

/// Returns the value as an i16.
pub fn getInt16(tuple: *const Tuple) i16 {
    return tuple.value()[0].int16;
}

/// Returns the value as a u8.
pub fn getUint8(tuple: *const Tuple) u8 {
    return tuple.value()[0].uint8;
}

/// Returns the value as an i8.
pub fn getInt8(tuple: *const Tuple) i8 {
    return tuple.value()[0].int8;
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
