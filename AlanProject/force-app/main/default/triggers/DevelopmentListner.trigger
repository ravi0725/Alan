/***
Class Name : DevelopmentListner
Desciption : Trigger used to update Development record and sync with JIRA issues from SFDC
Date       : 19-Sep-2016
Author     : Suresh Babu Murugan
**/
trigger DevelopmentListner on Development__c (before insert, before update, after insert, after update) {
    // Update JIRA ticket from Salesforce Development
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        DevelopmentHandler.prepareJIRASyncData(Trigger.new, Trigger.OldMap, Trigger.isInsert, Trigger.isUpdate);
    }
    
    if(Trigger.isAfter && Trigger.isUpdate){
        // Send notification to SFDC Owner
        DevelopmentHandler.SendEmailtoSFDCOwner(Trigger.new, Trigger.oldmap);
        
        DevelopmentHandler.JIRASyncProcess(Trigger.new, Trigger.oldmap);
    }
}