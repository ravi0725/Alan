/***
Class Name : AttachmentUpdatetoJIRA
Desciption : This trigger is used to update JIRA issue when Attachment got created or edited in SFDC
Date       : 20-Sep-2016
Author     : Suresh Babu Murugan
**/
trigger AttachmentUpdatetoJIRA on Attachment (after insert, after update, after delete) {
    public static boolean restrictRecurrence= false;
    Set<Id> CaseIDs = new Set<Id>();
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        // Update JIRA on Attachment updates for RE&WS Case records.
        AttachmentHandlerJIRAUpdate.syncJIRAforCaseAttachments_update(Trigger.New);
        
        /**** Development Coding part **/
        // Update JIRA on Attachment updates for Development records.
        AttachmentHandlerJIRAUpdate.developmentAttachmentUpdate(Trigger.New);
    }
    
    else if(Trigger.isAfter && Trigger.isDelete){
        // Update JIRA on Attachment updates for RE&WS Case records.
        AttachmentHandlerJIRAUpdate.syncJIRAforCaseAttachments_delete(Trigger.Old);
        
        /**** Development Coding part **/
        // Update JIRA on Attachment updates for Development records.
        AttachmentHandlerJIRAUpdate.developmentAttachmentDelete(Trigger.Old);
    }
    
}