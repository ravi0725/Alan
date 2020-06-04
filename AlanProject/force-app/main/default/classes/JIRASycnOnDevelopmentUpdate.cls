/***
Class Name : JIRASycnOnDevelopmentUpdate
Desciption : This class is used in Update JIRA Issue from SFDC on Development update
Date       : 15-Sep-2016
Author     : Suresh Babu Murugan
**/
public class JIRASycnOnDevelopmentUpdate {
    public static boolean restrictRecurrence= false;
    public static void updateJIRATicket(List<Development__c> lstNewDevs, Map<Id, Development__c> mapOldDevs){
        for(Development__c dev: lstNewDevs){
            if(dev.JIRA_Issue_ID__c != null &&(
                dev.Subject__c != mapOldDevs.get(dev.Id).Subject__c ||
                dev.JIRA_Description__c != mapOldDevs.get(dev.Id).JIRA_Description__c ||
                dev.JIRA_Code_Fix_Information__c != mapOldDevs.get(dev.Id).JIRA_Code_Fix_Information__c ||
                dev.Status__c != mapOldDevs.get(dev.Id).Status__c ||
                dev.Client_Name__c != mapOldDevs.get(dev.Id).Client_Name__c ||
                dev.Internal_Priority__c != mapOldDevs.get(dev.Id).Internal_Priority__c ||
                dev.Rank__c != mapOldDevs.get(dev.Id).Rank__c ||
                dev.Est_Delivery_Date__c != mapOldDevs.get(dev.Id).Est_Delivery_Date__c ||
                dev.SFDC_Reference__c != mapOldDevs.get(dev.Id).SFDC_Reference__c ||
                dev.Category__c != mapOldDevs.get(dev.Id).Category__c ||
                dev.Release_Found_In__c != mapOldDevs.get(dev.Id).Release_Found_In__c ||
                dev.Target_Release__c != mapOldDevs.get(dev.Id).Target_Release__c ||
                dev.Support_Case_1__c != mapOldDevs.get(dev.Id).Support_Case_1__c ||
                dev.QA_Tech_Ops__c != mapOldDevs.get(dev.Id).QA_Tech_Ops__c ||
                dev.JIRA_System_Info__c != mapOldDevs.get(dev.Id).JIRA_System_Info__c ||
                dev.Notes_and_Attachment_Links__c != mapOldDevs.get(dev.Id).Notes_and_Attachment_Links__c ||
                dev.SFDC_History__c != mapOldDevs.get(dev.Id).SFDC_History__c ||
                dev.SFDC_JIRA_Owner__c != mapOldDevs.get(dev.Id).SFDC_JIRA_Owner__c ||
                dev.Business_Use_Case__c != mapOldDevs.get(dev.Id).Business_Use_Case__c ||
                dev.Deploy_to_All_Clients__c != mapOldDevs.get(dev.Id).Deploy_to_All_Clients__c ||
                dev.SFDC_CreatedBy_User__c != mapOldDevs.get(dev.Id).SFDC_CreatedBy_User__c ||
                dev.Check_In_Date__c != mapOldDevs.get(dev.Id).Check_In_Date__c ||
                dev.Tech_Op_Info__c != mapOldDevs.get(dev.Id).Tech_Op_Info__c ||
                dev.Branch_1__c != mapOldDevs.get(dev.Id).Branch_1__c ||
                dev.Branch_2__c != mapOldDevs.get(dev.Id).Branch_2__c ||
                dev.Branch_3__c != mapOldDevs.get(dev.Id).Branch_3__c ||
                dev.Branch_4__c != mapOldDevs.get(dev.Id).Branch_4__c ||
                dev.Branch_Other__c != mapOldDevs.get(dev.Id).Branch_Other__c ||
                dev.Generic_Subject__c != mapOldDevs.get(dev.Id).Generic_Subject__c ||
                dev.Steps_to_Reproduce__c != mapOldDevs.get(dev.Id).Steps_to_Reproduce__c ||
                dev.Error_Displayed_to_User__c != mapOldDevs.get(dev.Id).Error_Displayed_to_User__c ||
                dev.To_Sustaining__c != mapOldDevs.get(dev.Id).To_Sustaining__c
            )){
                //dev.JIRA_Issue_Assigned_User__c != mapOldDevs.get(dev.Id).JIRA_Issue_Assigned_User__c ||
                if(!restrictRecurrence){
                    restrictRecurrence = true;
                    
                    if(dev.Status__c != mapOldDevs.get(dev.Id).Status__c){
                        system.debug('JIRA_Issue_ID__c ==================>>>'+dev.JIRA_Issue_ID__c);
                        Map<String, JIRA_Status_Mapping__c> mapJIRAStatusCodes = JIRA_Status_Mapping__c.getAll();
                        
                        String SFDCStatusformatted = 'SFDC-'+dev.Status__c;
                        system.debug('SFDCStatusformatted =============>'+SFDCStatusformatted);
                        system.debug('mapJIRAStatusCodes =========================>'+mapJIRAStatusCodes);
                        if(mapJIRAStatusCodes.containsKey(SFDCStatusformatted) && mapJIRAStatusCodes.get(SFDCStatusformatted).Is_Status_Mapping__c){ // Is status mapping available in custom setting ? // Double check the record is used for status mapping ?
                            String projectKeywithStatus = dev.JIRA_Issue_ID__c.substringBefore('-') + '-' + mapJIRAStatusCodes.get(SFDCStatusformatted).Status_Name__c; // should like (SPSUST-TO DO)
                            system.debug('projectKeywithStatus =====>'+projectKeywithStatus);
                            
                            if(mapJIRAStatusCodes.containsKey(projectKeywithStatus)){
                                // Do update JIRA Status if the mapping is available in SFDC custom setting (JIRA Status Mapping)
                                JIRAConnectorWebserviceCalloutSync.synchronizeWithJIRAIssueWithStatus(JIRAConnectorClass.baseUrl, JIRAConnectorClass.systemId, 'Development__c', dev.Id, dev.JIRA_Issue_ID__c, mapJIRAStatusCodes.get(projectKeywithStatus).Status_Code__c);
                                system.debug('Callout executed.....');
                            }
                        }
                        else{
                            JIRAConnectorWebserviceCalloutSync.synchronizeWithJIRAIssue(JIRAConnectorClass.baseUrl, JIRAConnectorClass.systemId, 'Development__c', dev.Id);
                        }
                    }
                    else{
                        JIRAConnectorWebserviceCalloutSync.synchronizeWithJIRAIssue(JIRAConnectorClass.baseUrl, JIRAConnectorClass.systemId, 'Development__c', dev.Id);
                    }
                }
            }
        }
    }
    
}