/*****************************************************************************************
Name        : NotesHandler_Test 
Description : Test class for Create JIRA Issue from SFDC 
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
Suresh Babu         16/Dec/2016          Created
******************************************************************************************/
@isTest private class NotesHandler_Test {
    static void setUpData(){
        JIRATestData_Generate.createCustomSettingRecords();
        JIRATestData_Generate.createAccount();
        JIRATestData_Generate.createContact();
        JIRATestData_Generate.createCases();
        JIRATestData_Generate.createDevelopments();
        JIRATestData_Generate.createAttachments();
        JIRATestData_Generate.createNotes();
    }
    
    // Tests Sync JIRA Issue from SFDC
    static testMethod void NotesHandler_Test1() {
        system.Test.startTest();
        setUpData();
        // RESET Recurrence
        NotesHandler.resetLaunchControl();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseJIRAConnector());
        JIRATestData_Generate.Note1.Body = 'TEST Update 1';
        update JIRATestData_Generate.Note1;
        system.Test.stopTest();
    }
    
    // Tests Sync JIRA Issue from SFDC
    static testMethod void NotesHandler_Test2() {
        system.Test.startTest();
        setUpData();
        // RESET Recurrence
        NotesHandler.resetLaunchControl();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseJIRAConnector());
        delete JIRATestData_Generate.Note1;
        system.Test.stopTest();
    }
}