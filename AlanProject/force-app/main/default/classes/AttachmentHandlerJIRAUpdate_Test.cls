/*****************************************************************************************
Name        : AttachmentHandlerJIRAUpdate_Test 
Description : Test class for Create JIRA Issue from SFDC 
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
Suresh Babu         29/Sep/2016          Created
******************************************************************************************/
@isTest private class AttachmentHandlerJIRAUpdate_Test {
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
    static testMethod void AttachmentHandlerJIRAUpdate_Test1() {
        setUpData();
        system.Test.startTest();
        
        AttachmentHandlerJIRAUpdate.restrictRecurrence = false;
        List<Attachment> lstAtts = [SELECT Id, ContentType, ParentId FROM Attachment WHERE Id =: JIRATestData_Generate.att1.Id limit 1];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseJIRAConnector());
        AttachmentHandlerJIRAUpdate.syncJIRAforCaseAttachments_update(lstAtts);
        
        system.Test.stopTest();
    }
    
    // Tests Sync JIRA Issue from SFDC
    static testMethod void AttachmentHandlerJIRAUpdate_Test2() {
        setUpData();
        system.Test.startTest();
        
        AttachmentHandlerJIRAUpdate.restrictRecurrence = false;
        List<Attachment> lstAtts = [SELECT Id, ContentType, ParentId FROM Attachment WHERE Id =: JIRATestData_Generate.att1.Id limit 1];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseJIRAConnector());
        AttachmentHandlerJIRAUpdate.syncJIRAforCaseAttachments_delete(lstAtts);
        
        system.Test.stopTest();
    }
    
    // Tests Sync JIRA Issue from SFDC
    static testMethod void AttachmentHandlerJIRAUpdate_Test3() {
        setUpData();
        system.Test.startTest();
        
        AttachmentHandlerJIRAUpdate.restrictRecurrence = false;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseJIRAConnector());
        delete JIRATestData_Generate.att1;
        system.Test.stopTest();
    }
    
    // Tests Sync JIRA Issue from SFDC
    static testMethod void AttachmentHandlerJIRAUpdate_Test4() {
        setUpData();
        system.Test.startTest();
        
        AttachmentHandlerJIRAUpdate.restrictRecurrence = false;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseJIRAConnector());
        delete JIRATestData_Generate.att2;
        system.Test.stopTest();
    }
    
    // Tests Sync JIRA Issue from SFDC
    static testMethod void AttachmentHandlerJIRAUpdate_Test5() {
        setUpData();
        system.Test.startTest();
        
        AttachmentHandlerJIRAUpdate.restrictRecurrence = false;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseJIRAConnector());
        delete JIRATestData_Generate.Note1;
        system.Test.stopTest();
    }
    
    // Tests Sync JIRA Issue from SFDC
    static testMethod void AttachmentHandlerJIRAUpdate_Test6() {
        setUpData();
        system.Test.startTest();
        
        AttachmentHandlerJIRAUpdate.restrictRecurrence = false;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseJIRAConnector());
        
        JIRATestData_Generate.Note1.Body = 'TEST Update NOTE 1';
        update JIRATestData_Generate.Note1;
        system.Test.stopTest();
    }

    // Tests Sync JIRA Issue from SFDC
    static testMethod void AttachmentHandlerJIRAUpdate_Test7() {
        setUpData();
        system.Test.startTest();
        
        AttachmentHandlerJIRAUpdate.restrictRecurrence = false;
        List<Attachment> lstAtts = [SELECT Id, ContentType, ParentId FROM Attachment WHERE Id =: JIRATestData_Generate.att3.Id limit 1];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseJIRAConnector());
        AttachmentHandlerJIRAUpdate.syncJIRAforCaseAttachments_update(lstAtts);
        system.Test.stopTest();
        
        //JCFS.JiraTriggerTestHelper.testAfterInsert(JIRATestData_Generate.att3);
    }

    // Tests Sync JIRA Issue from SFDC
    static testMethod void AttachmentHandlerJIRAUpdate_Test8() {
        setUpData();
        system.Test.startTest();
        
        AttachmentHandlerJIRAUpdate.restrictRecurrence = false;
        List<Attachment> lstAtts = [SELECT Id, ContentType, ParentId FROM Attachment WHERE Id =: JIRATestData_Generate.att3.Id limit 1];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseJIRAConnector());
        AttachmentHandlerJIRAUpdate.syncJIRAforCaseAttachments_delete(lstAtts);
        system.Test.stopTest();
        
        //JCFS.JiraTriggerTestHelper.testAfterInsert(JIRATestData_Generate.att3);
    }

    // Tests PPM JIRA Sync/Create funtionality
    static testMethod void AttachmentHandlerJIRAUpdate_Test9() {
        setUpData();
        system.Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseJIRAConnector());
        JIRAIssue_Create_GCCMCtrl cont1 = new JIRAIssue_Create_GCCMCtrl(new ApexPages.StandardController(JIRATestData_Generate.PPMcs1));
        JIRAIssue_Comments_GCCMCtrl cont2 = new JIRAIssue_Comments_GCCMCtrl(new ApexPages.StandardController(JIRATestData_Generate.PPMcs1));

        JIRAIssue_Create_GCCMCtrl cont3 = new JIRAIssue_Create_GCCMCtrl(new ApexPages.StandardController(JIRATestData_Generate.PPMcs2));
        JIRAIssue_Comments_GCCMCtrl cont4 = new JIRAIssue_Comments_GCCMCtrl(new ApexPages.StandardController(JIRATestData_Generate.PPMcs2));

        system.Test.stopTest();
    }
}