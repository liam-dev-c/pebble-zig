/// AppMessage send/receive helpers
const c = @import("c");

/// Opens the AppMessage inbox and outbox with the given sizes (bytes).
pub fn open(size_in: u32, size_out: u32) void {
    _ = c.app_message_open(size_in, size_out);
}

/// Registers a callback for when a new message arrives in the inbox.
pub fn registerInboxReceived(callback: c.AppMessageInboxReceived) void {
    c.app_message_register_inbox_received(callback);
}

/// Registers a callback for when an inbox message is dropped.
pub fn registerInboxDropped(callback: c.AppMessageInboxDropped) void {
    c.app_message_register_inbox_dropped(callback);
}

/// Registers a callback for when an outbox message is sent successfully.
pub fn registerOutboxSent(callback: c.AppMessageOutboxSent) void {
    c.app_message_register_outbox_sent(callback);
}

/// Registers a callback for when an outbox message fails to send.
pub fn registerOutboxFailed(callback: c.AppMessageOutboxFailed) void {
    c.app_message_register_outbox_failed(callback);
}

/// Begins composing an outbox message. Returns a pointer to the iterator.
pub fn outboxBegin(iter: *?*c.DictionaryIterator) void {
    _ = c.app_message_outbox_begin(@ptrCast(iter));
}

/// Sends the composed outbox message.
pub fn outboxSend() void {
    _ = c.app_message_outbox_send();
}
