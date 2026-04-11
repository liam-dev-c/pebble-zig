/// Persistent storage helpers
const c = @import("c");

/// Writes arbitrary data to persistent storage under the given key.
pub fn write(key: u32, data: anytype) void {
    _ = c.persist_write_data(key, &data, @sizeOf(@TypeOf(data)));
}

/// Reads data from persistent storage into the given pointer.
/// Returns the number of bytes read, or a negative error code.
pub fn read(key: u32, data: anytype) i32 {
    return @intCast(c.persist_read_data(key, data, @sizeOf(@typeInfo(@TypeOf(data)).pointer.child)));
}

/// Returns true if a value exists for the given key.
pub fn exists(key: u32) bool {
    return c.persist_exists(key);
}

/// Deletes the value for the given key.
pub fn delete(key: u32) void {
    _ = c.persist_delete(key);
}
