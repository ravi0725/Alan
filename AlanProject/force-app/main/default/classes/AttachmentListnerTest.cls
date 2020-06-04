/*****************************************************************************************
Name    : AttachmentListnerTest 
Modification Log : 
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
P M Mamata       27/08/2015          Created
Suresh Babu      12/17/2018          Modified
******************************************************************************************/
@isTest
private class AttachmentListnerTest {
    static void setUpData(){
        JIRATestData_Generate.createCustomSettingRecords();
        JIRATestData_Generate.createAccount();
        JIRATestData_Generate.createContact();
        JIRATestData_Generate.createCases();
        JIRATestData_Generate.createDevelopments();
        JIRATestData_Generate.createAttachments();
        JIRATestData_Generate.createNotes();
    }
    
    static testmethod void meth1(){
        setUpData();

        Test.startTest();
        List<Id> atList = new List<Id>();
        atList.add(JIRATestData_Generate.att4.Id);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseJIRAConnector());
        AttachmentListner.callTFS(atList);

        List<Attachment> attList = new List<Attachment>();
        AttachmentListner.AddAttachmentToCase(attList);
        AttachmentListner.setLaunchControl();
        Test.stopTest();
    }
    
    static testmethod void meth2(){
        setUpData();

        Test.startTest();
        List<Id> atList = new List<Id>();
        atList.add(JIRATestData_Generate.att3.Id);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseJIRAConnector());
        AttachmentListner.callTFS(atList);
        Test.stopTest();
    }

    static testmethod void meth3(){
        setUpData();

        Test.startTest();
        List<Attachment> attList = new List<Attachment>();
        attList.add(JIRATestData_Generate.att4);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseJIRAConnector());
        AttachmentListner.AddCaseAttachmentToIssue(attList);
        Test.stopTest();
    }
   /* static testmethod void meth2(){
        List<Id> atList = new List<Id>();
        test.startTest();
        GenerateTestData.createAccount();                
        GenerateTestData.createContact();
        Case dcs = new Case();
        dcs.AccountId = GenerateTestData.acct.Id;
        dcs.ContactId = GenerateTestData.ct.Id; 
        dcs.Status = 'New';
        dcs.TFS_Id__c = '12345';
        dcs.Product__c = 'Proliance';
        dcs.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(Label.GCCM_Support_Issue_Record_Type).getRecordTypeId();        
        insert dcs;
        GenerateTestData.dcs = dcs;
        GenerateTestData.createcaseAttachment();
        atList.add(GenerateTestData.attachment.Id);
        
        AttachmentListner.callTFS(atList);
        test.stopTest();
        AttachmentListner act = new AttachmentListner();
        
    }*/
}