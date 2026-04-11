/// Resource loading helpers
const c = @import("c");

/// Returns a handle for the given resource ID.
pub fn getHandle(resource_id: u32) c.ResHandle {
    return c.resource_get_handle(resource_id);
}
