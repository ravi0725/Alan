/***
Class Name : AttachmentHandlerJIRAUpdate
Desciption : Handler class for Attachment Updates
Date       : 27-Sep-2016
Author     : Suresh Babu Murugan
**/
public class AttachmentHandlerJIRAUpdate {
    public static Map<String, Integer> launchControl;
    public static boolean restrictRecurrence= false;
    // Static initialize
    static {
        resetLaunchControl();
    }
    // Reset Trigger control (e.g. for testing)
    public static void resetLaunchControl() {
        launchControl = new Map<String, Integer>();
        launchControl.put('syncJIRAforCaseAttachments_update',0);
        launchControl.put('syncJIRAforCaseAttachments_delete', 0);
        launchControl.put('developmentAttachmentDelete', 0);
        launchControl.put('developmentAttachmentUpdate', 0);
    }

    public static void syncJIRAforCaseAttachments_update(List<Attachment> lstNewAttachments){
        if(launchControl.get('syncJIRAforCaseAttachments_update') < 1){
            launchControl.put('syncJIRAforCaseAttachments_update',launchControl.get('syncJIRAforCaseAttachments_update') + 1);

            Set<Id> CaseIDs = new Set<Id>();
            for(Attachment att : lstNewAttachments){
                //Check if added attachment is related to Case or not
                if(att.ParentId.getSobjectType() == Case.SobjectType){
                    CaseIDs.add(att.ParentId);
                }
            }

            List<Case> lstCases = [SELECT Id, Record_Type_Name__c, SPR__c, Application__c, TFS_Id__c, Product__c FROM Case WHERE Id IN : CaseIDs];
            List<Case> lstCasesToBePushed = new List<Case>();
            for(Case cs: lstCases){
                if(cs.Record_Type_Name__c == 'RE&WS - Support' && cs.SPR__c != null && cs.Application__c == 'Space Scheduling'){
                    if(!restrictRecurrence){
                        restrictRecurrence = true;
                        system.debug('Do callout to update Comments to JIRA...................');
                        JIRAConnectorWebserviceCalloutSync.synchronizeWithJIRAIssue(JIRAConnectorClass.baseUrl, JIRAConnectorClass.systemId, 'Case', cs.Id);
                    }
                }
                // Sync attachment to JIRA cloud for PPM
                if(cs.Record_Type_Name__c == 'GCCM - Support Issue Record Type' && cs.TFS_Id__c != null && (cs.Product__c.contains('ProjectSight') || cs.Product__c.contains('Prolog') || cs.Product__c.contains('Proliance') || cs.Product__c.contains('Message Bus') || cs.Product__c.contains('Field Mgmt'))){
                    if(!restrictRecurrence){
                        restrictRecurrence = true;
                        lstCasesToBePushed.add(cs);
                    }
                }
            }
              if(lstCasesToBePushed.size() > 0 && !Test.isRunningTest()){
                JCFS.API.pushUpdatesToJira(lstCasesToBePushed, Trigger.old);
            }
        }
    }

    public static void syncJIRAforCaseAttachments_delete(List<Attachment> lstOldAttachments){
        if(launchControl.get('syncJIRAforCaseAttachments_delete') < 1){
            launchControl.put('syncJIRAforCaseAttachments_delete',launchControl.get('syncJIRAforCaseAttachments_delete') + 1);

            Set<Id> CaseIDs = new Set<Id>();
            for(Attachment att : lstOldAttachments){
                //Check if added attachment is related to Case or not
                if(att.ParentId.getSobjectType() == Case.SobjectType){
                    CaseIDs.add(att.ParentId);
                }
            }

            List<Case> lstCases = [SELECT Id, Record_Type_Name__c, SPR__c, Application__c, TFS_Id__c, Product__c FROM Case WHERE Id IN : CaseIDs];
            List<Case> lstCasesToBePushed = new List<Case>();
            for(Case cs: lstCases){
                if(cs.Record_Type_Name__c == 'RE&WS - Support' && cs.SPR__c != null && cs.Application__c == 'Space Scheduling'){
                    if(!restrictRecurrence){
                        restrictRecurrence = true;
                        system.debug('Do callout to update Comments to JIRA...................');
                        JIRAConnectorWebserviceCalloutSync.synchronizeWithJIRAIssue(JIRAConnectorClass.baseUrl, JIRAConnectorClass.systemId, 'Case', cs.Id);
                    }
                }
                // Sync attachment to JIRA cloud for PPM
                if(cs.Record_Type_Name__c == 'GCCM - Support Issue Record Type' && cs.TFS_Id__c != null && (cs.Product__c.contains('ProjectSight') || cs.Product__c.contains('Prolog') || cs.Product__c.contains('Proliance') || cs.Product__c.contains('Message Bus') || cs.Product__c.contains('Field Mgmt'))){
                    if(!restrictRecurrence){
                        restrictRecurrence = true;
                        lstCasesToBePushed.add(cs);
                    }
                }
            }
            if(lstCasesToBePushed.size() > 0  && !Test.isRunningTest()){
                JCFS.API.pushUpdatesToJira(lstCasesToBePushed, Trigger.old);
            }
        }
    }

    public static void developmentAttachmentUpdate(List<Attachment> lstNewAttachments){
        if(launchControl.get('developmentAttachmentUpdate') < 1){
            launchControl.put('developmentAttachmentUpdate',launchControl.get('developmentAttachmentUpdate') + 1);

            Set<Id> DevelopmentIDs = new Set<Id>();
            for(Attachment at : lstNewAttachments){
                //Check if added attachment is related to Case or not
                if(at.ParentId.getSobjectType() == Development__c.SobjectType){
                    DevelopmentIDs.add(at.ParentId);
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

    public static void developmentAttachmentDelete(List<Attachment> lstOldAttachments){
        if(launchControl.get('developmentAttachmentDelete') < 1){
            launchControl.put('developmentAttachmentDelete',launchControl.get('developmentAttachmentDelete') + 1);

            Set<Id> DevelopmentIDs = new Set<Id>();
            for(Attachment at : lstOldAttachments){
                //Check if added attachment is related to Case or not
                if(at.ParentId.getSobjectType() == Development__c.SobjectType){
                    DevelopmentIDs.add(at.ParentId);
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