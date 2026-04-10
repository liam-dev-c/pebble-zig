/// Dictionary write helpers
const c = @import("c");

pub const DictionaryIterator = c.DictionaryIterator;
pub const DictionaryResult = c.DictionaryResult;

/// Begins writing to a dictionary buffer.
pub fn writeBegin(iter: *DictionaryIterator, buffer: []u8) DictionaryResult {
    return c.dict_write_begin(iter, buffer.ptr, @intCast(buffer.len));
}

/// Writes a null-terminated C string to the dictionary.
pub fn writeCString(iter: *DictionaryIterator, key: u32, value: [*:0]const u8) DictionaryResult {
    return c.dict_write_cstring(iter, key, value);
}

/// Writes raw data bytes to the dictionary.
pub fn writeData(iter: *DictionaryIterator, key: u32, data: []const u8) DictionaryResult {
    return c.dict_write_data(iter, key, @constCast(data.ptr), @intCast(data.len));
}

/// Writes an integer value to the dictionary.
pub fn writeInt(iter: *DictionaryIterator, key: u32, value: *const anyopaque, width: u8, signed: bool) DictionaryResult {
    return c.dict_write_int(iter, key, value, width, signed);
}

/// Convenience: writes an i32 to the dictionary.
pub fn writeInt32(iter: *DictionaryIterator, key: u32, value: i32) DictionaryResult {
    return c.dict_write_int32(iter, key, value);
}

/// Convenience: writes a u32 to the dictionary.
pub fn writeUint32(iter: *DictionaryIterator, key: u32, value: u32) DictionaryResult {
    return c.dict_write_uint32(iter, key, value);
}

/// Convenience: writes a u16 to the dictionary.
pub fn writeUint16(iter: *DictionaryIterator, key: u32, value: u16) DictionaryResult {
    return c.dict_write_uint16(iter, key, value);
}

/// Convenience: writes a u8 to the dictionary.
pub fn writeUint8(iter: *DictionaryIterator, key: u32, value: u8) DictionaryResult {
    return c.dict_write_uint8(iter, key, value);
}

/// Finalises writing and returns the size of the dictionary.
pub fn writeEnd(iter: *DictionaryIterator) u32 {
    return c.dict_write_end(iter);
}

/// Looks up a Tuple by key in a dictionary iterator.
pub fn find(iter: *DictionaryIterator, key: u32) ?*c.Tuple {
    return c.dict_find(iter, key);
}

/// Reads the first Tuple from a serialised buffer.
pub fn readBeginFromBuffer(iter: *DictionaryIterator, buffer: []u8) ?*c.Tuple {
    return c.dict_read_begin_from_buffer(iter, buffer.ptr, @intCast(buffer.len));
}

/// Advances to the next Tuple.
pub fn readNext(iter: *DictionaryIterator) ?*c.Tuple {
    return c.dict_read_next(iter);
}
