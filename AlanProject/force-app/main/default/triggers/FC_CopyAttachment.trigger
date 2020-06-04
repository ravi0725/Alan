trigger FC_CopyAttachment on Attachment (after insert) {
    FC_CopyAtttachmentHandler handler = new FC_CopyAtttachmentHandler();
    handler.onAfterInsertAttachment(Trigger.new);
}