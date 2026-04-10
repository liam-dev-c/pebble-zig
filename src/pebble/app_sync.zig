/// AppSync helpers — keeps a local dictionary in sync with the phone.
const c = @import("c");

pub const AppSync = c.AppSync;
pub const TupleChangedCallback = c.AppSyncTupleChangedCallback;
pub const ErrorCallback = c.AppSyncErrorCallback;

/// Initialises an AppSync session.
///   - `sync`: pointer to caller-owned AppSync struct
///   - `buffer`: caller-owned buffer for the sync dictionary
///   - `initial_values`: array of Tuplet initial key/value pairs
///   - `tuple_changed`: called when a key's value changes
///   - `error_cb`: called on sync errors
///   - `context`: user data passed to callbacks
pub fn init(
    sync: *AppSync,
    buffer: []u8,
    initial_values: []const c.Tuplet,
    tuple_changed: TupleChangedCallback,
    error_cb: ErrorCallback,
    context: ?*anyopaque,
) void {
    c.app_sync_init(
        sync,
        buffer.ptr,
        @intCast(buffer.len),
        @constCast(initial_values.ptr),
        @intCast(initial_values.len),
        tuple_changed,
        error_cb,
        context,
    );
}

/// Tears down an AppSync session.
pub fn deinit(sync: *AppSync) void {
    c.app_sync_deinit(sync);
}

/// Gets the current Tuple for a given key from the local sync dictionary.
pub fn get(sync: *const AppSync, key: u32) ?*const c.Tuple {
    return c.app_sync_get(sync, key);
}
