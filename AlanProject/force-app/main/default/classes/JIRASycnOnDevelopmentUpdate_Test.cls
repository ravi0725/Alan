/*****************************************************************************************
Name        : JIRASycnOnDevelopmentUpdate_Test 
Description : Test class for Create JIRA Issue from SFDC 
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
Suresh Babu         15/Dec/2016          Created
******************************************************************************************/
@isTest private class JIRASycnOnDevelopmentUpdate_Test {
    static void setUpData(){
        JIRATestData_Generate.createCustomSettingRecords();
        JIRATestData_Generate.createAccount();
        JIRATestData_Generate.createContact();
        JIRATestData_Generate.createCases();
        JIRATestData_Generate.createDevelopments();
        
        JIRATestData_Generate.dev1.JIRA_Issue_ID__c = 'SFUST-1';
        update JIRATestData_Generate.dev1;
    }
    
    // Tests Sync JIRA Issue from SFDC
    static testMethod void JIRASycnOnDevelopmentUpdate_Test1() {
        system.Test.startTest();
        setUpData();
        system.ApexPages.currentPage().getParameters().put('id', JIRATestData_Generate.dev1.Id);
        system.ApexPages.currentPage().getParameters().put('objType', 'Development__c');
        system.ApexPages.currentPage().getParameters().put('pKey', 'SFUST');
        system.ApexPages.currentPage().getParameters().put('iType', '8');
        
        List<Development__c> lstNewDev = [SELECT Id, JIRA_Issue_ID__c, Subject__c, JIRA_Description__c, JIRA_Code_Fix_Information__c, Status__c, Client_Name__c,
                               Internal_Priority__c, Rank__c, Est_Delivery_Date__c, SFDC_Reference__c, Category__c, Release_Found_In__c, Target_Release__c, Support_Case_1__c,
                               QA_Tech_Ops__c, JIRA_System_Info__c, Notes_and_Attachment_Links__c, SFDC_History__c, JIRA_Issue_Assigned_User__c,
                               SFDC_JIRA_Owner__c, Business_Use_Case__c, Deploy_to_All_Clients__c, SFDC_CreatedBy_User__c 
                               FROM 
                               Development__c 
                               WHERE 
                               id =: JIRATestData_Generate.dev1.Id limit 1];
        
        JIRATestData_Generate.dev1.Subject__c = 'Test Update';
        JIRATestData_Generate.dev1.Status__c = 'Closed No Fix';
        Map<Id, Development__c> mapOldDev = new Map<Id, Development__c>();
        
        mapOldDev.put(JIRATestData_Generate.dev1.Id, JIRATestData_Generate.dev1);
        
        system.Test.setMock(HttpCalloutMock.class, new MockHttpResponseFetchJIRAIssue());
        JIRASycnOnDevelopmentUpdate.updateJIRATicket(lstNewDev, mapOldDev);
        
        system.Test.stopTest();
    }
}