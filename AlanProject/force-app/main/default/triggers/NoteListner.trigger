/***
Class Name : NoteListner
Desciption : This trigger is used to update JIRA issue when Notes got created or edited in SFDC
Date       : 20-Sep-2016
Author     : Suresh Babu Murugan
**/
trigger NoteListner on Note (after insert, after update, after delete) {
    if(Trigger.isAfter){
        if(Trigger.isInsert || Trigger.isUpdate){
            // Update JIRA on Note creation and updation
            NotesHandler.developmentNotesUpdate(Trigger.New);
        }
        else if(Trigger.isDelete){
            // Update JIRA on Note deletion
            NotesHandler.developmentNoteDelete(Trigger.Old);
        }
    }
}