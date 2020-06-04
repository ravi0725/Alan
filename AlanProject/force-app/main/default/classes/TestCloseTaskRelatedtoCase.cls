/*****************************************************************************************
Name    : TestCloseTaskRelatedtoCase 
Modification Log : 
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
Suresh Babu       15/07/2015          Created
******************************************************************************************/
@isTest(seealldata=true)
Private class TestCloseTaskRelatedtoCase {
    static testmethod void testTaskAutoClose(){
        test.startTest();
        List<Case> csList = new List<Case>();        
        List<Id> csId = new List<Id>();
        GenerateTestData.createAccount();
        GenerateTestData.createProduct2();
        GenerateTestData.createContact();        

        Asset ast = new Asset();
        ast.Name = 'Test Asset';
        ast.AccountId = GenerateTestdata.acct.Id;
        ast.Product2Id = GenerateTestData.prd.Id;
        ast.SerialNumber = '12345';
        insert ast;

        Case cs = new Case();
        cs.AccountId = GeneratetestData.acct.Id;
        cs.ContactId = GeneratetestData.ct.Id; 
        cs.Status = 'New';
        cs.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('GCCM - Support Case Record Type').getRecordTypeId();                
        cs.Product__c = 'Prolog Manager';
        cs.Origin = 'Chat';
        cs.Serial_Number__c = '12345';        
        cs.TFS_Id__c = '123456';        
        insert cs;
        
        Task ts = new Task();
        ts.ActivityDate = Date.today().addDays(7);
        ts.Subject='Sample Task';
        ts.WhatId = cs.Id;
        ts.OwnerId = UserInfo.getUserId();
        ts.Status ='In Progress';
        insert ts;
        
        csList.add(cs);
        csId.add(cs.Id);
        
        CloseTaskRelatedtoCase.removeUnwantedString(new Id[]{cs.Id});
        test.stopTest();    
    }
}