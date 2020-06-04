/***
Class Name : JIRASycnOnCaseUpdate
Desciption : This class is used in Update JIRA Issue from SFDC on Case update
Date       : 15-Sep-2016
Author     : Suresh Babu Murugan
**/
public class JIRASycnOnCaseUpdate {
    public static boolean restrictRecurrence= false;
    public static void updateJIRATicket(List<Case> lstNewCases, Map<Id, Case> mapOldCases){
        for(Case cs: lstNewCases){
            if(cs.Record_Type_Name__c == 'RE&WS - Support' && cs.SPR__c != null && cs.Application__c == 'Space Scheduling' && 
               (cs.Description != mapOldCases.get(cs.Id).Description || cs.Subject != mapOldCases.get(cs.Id).Subject || cs.Functional_Area__c != mapOldCases.get(cs.Id).Functional_Area__c || cs.Account_Name__c != mapOldCases.get(cs.Id).Account_Name__c || 
                cs.Version_Found_In__c != mapOldCases.get(cs.Id).Version_Found_In__c || cs.Priority != mapOldCases.get(cs.Id).Priority || cs.Status != mapOldCases.get(cs.Id).Status)){
                    // Only sync to Space Scheduling JIRA when this values are changed in Cases
                    if(!restrictRecurrence){
                        restrictRecurrence = true;
                        JIRAConnectorWebserviceCalloutSync.synchronizeWithJIRAIssue(JIRAConnectorClass.baseUrl, JIRAConnectorClass.systemId, 'Case', cs.Id);
                    }
			}
            else if(cs.Record_Type_Name__c == 'RE&WS - Support' && cs.SPR__c != null && cs.Application__c == 'Manhattan' && 
               (cs.Description != mapOldCases.get(cs.Id).Description || cs.Subject != mapOldCases.get(cs.Id).Subject || cs.Account_Name__c != mapOldCases.get(cs.Id).Account_Name__c || 
                cs.Priority != mapOldCases.get(cs.Id).Priority || cs.Application_Environment_Affected__c != mapOldCases.get(cs.Id).Application_Environment_Affected__c || cs.Status != mapOldCases.get(cs.Id).Status)){
                    // Only sync to Manhattan JIRA when this values are changed in Cases
                    if(!restrictRecurrence){
                        restrictRecurrence = true;
                        JIRAConnectorWebserviceCalloutSync.synchronizeWithJIRAIssue(JIRAConnectorClass.baseUrl, JIRAConnectorClass.systemId, 'Case', cs.Id);
                    }
            }
        }
    }
}