/***
Class Name : NotesHandler
Desciption : Handler class for Notes Updates
Date       : 27-Sep-2016
Author     : Suresh Babu Murugan
**/
public class NotesHandler {
    public static Map<String, Integer> launchControl;
    public static boolean restrictRecurrence= false;
    // Static initialize
    static {
        resetLaunchControl();
    }
    // Reset Trigger control (e.g. for testing)
    public static void resetLaunchControl() {
        launchControl = new Map<String, Integer>();
        launchControl.put('developmentNotesUpdate',0);
        launchControl.put('developmentNoteDelete', 0);
    }
    
    public static void developmentNotesUpdate(List<Note> lstNewNotes){
        if(launchControl.get('developmentNotesUpdate') < 1){
            launchControl.put('developmentNotesUpdate',launchControl.get('developmentNotesUpdate') + 1);
            
            Set<Id> DevelopmentIDs = new Set<Id>();
            for(Note nt : lstNewNotes){
                //Check if added attachment is related to Case or not
                if(nt.ParentId.getSobjectType() == Development__c.SobjectType){
                    DevelopmentIDs.add(nt.ParentId);
                }
            }
            
            List<Development__c> lstDevUpdate = new List<Development__c>();
            List<Development__c> lstDevs = [SELECT Id, Name, JIRA_Issue_ID__c, (SELECT Id, Name, ParentId, ContentType, BodyLength, LastModifiedBy.Name, CreatedBy.Name FROM Attachments), (SELECT Body, Id, Title, ParentId, LastModifiedBy.Name,CreatedBy.Name FROM Notes) FROM Development__c WHERE Id IN : DevelopmentIDs];
            for(Development__c dev: lstDevs){
                String NotesDetails = '';
                // Group all available Notes and attachments to Development record
                for(Note nts : dev.Notes){
                    NotesDetails += 'Note: ' + nts.Title + '\n' +
                        'Comment: \n' + nts.Body + '\n' +
                        'Created By: ' + nts.CreatedBy.Name + ' | ' + 'Updated By: ' + nts.LastModifiedBy.Name + '\n' +
                        'Link: ' + 'https://' + System.URL.getSalesforceBaseUrl().getHost() + '/' + nts.Id  + '\n\n';
                }
                
                for(Attachment att: dev.Attachments){
                    NotesDetails += 'Attachment: ' + att.Name + '\n'+
                        'Type: ' + att.ContentType + '\n'+
                        'Created By: ' + att.CreatedBy.Name + ' | ' + 'Updated By: ' + att.LastModifiedBy.Name + '\n' +
                        'Link: ' + 'https://' + System.URL.getSalesforceBaseUrl().getHost() + '/' + att.Id  + '\n\n';
                }
                
                dev.Notes_and_Attachment_Links__c = NotesDetails;
                lstDevUpdate.add(dev);
            }
            
            if(lstDevUpdate.size() > 0)
                update lstDevUpdate;
        }
    }
    
    public static void developmentNoteDelete(List<Note> lstOldNotes){
        if(launchControl.get('developmentNoteDelete') < 1){
            launchControl.put('developmentNoteDelete',launchControl.get('developmentNoteDelete') + 1);
            
            Set<Id> DevelopmentIDs = new Set<Id>();
            for(Note nt : lstOldNotes){
                //Check if added attachment is related to Case or not
                if(nt.ParentId.getSobjectType() == Development__c.SobjectType){
                    DevelopmentIDs.add(nt.ParentId);
                }
            }
            
            List<Development__c> lstDevUpdate = new List<Development__c>();
            List<Development__c> lstDevs = [SELECT Id, Name, JIRA_Issue_ID__c, (SELECT Id, Name, ParentId, ContentType, BodyLength, LastModifiedBy.Name, CreatedBy.Name FROM Attachments), (SELECT Body, Id, Title, ParentId, LastModifiedBy.Name,CreatedBy.Name FROM Notes) FROM Development__c WHERE Id IN : DevelopmentIDs];
            for(Development__c dev: lstDevs){
                String NotesDetails = '';
                // Group all available Notes and attachments to Development record
                for(Note nts : dev.Notes){
                    NotesDetails += 'Note: ' + nts.Title + '\n' +
                        'Comment: \n' + nts.Body + '\n' +
                        'Created By: ' + nts.CreatedBy.Name + ' | ' + 'Updated By: ' + nts.LastModifiedBy.Name + '\n' +
                        'Link: ' + 'https://' + System.URL.getSalesforceBaseUrl().getHost() + '/' + nts.Id  + '\n\n';
                }
                
                for(Attachment att: dev.Attachments){
                    NotesDetails += 'Attachment: ' + att.Name + '\n'+
                        'Type: ' + att.ContentType + '\n'+
                        'Created By: ' + att.CreatedBy.Name + ' | ' + 'Updated By: ' + att.LastModifiedBy.Name + '\n' +
                        'Link: ' + 'https://' + System.URL.getSalesforceBaseUrl().getHost() + '/' + att.Id  + '\n\n';
                }
                
                dev.Notes_and_Attachment_Links__c = NotesDetails;
                lstDevUpdate.add(dev);
            }
            
            if(lstDevUpdate.size() > 0)
                update lstDevUpdate;
        }
    }
}