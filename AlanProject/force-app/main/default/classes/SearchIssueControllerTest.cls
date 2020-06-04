/*
****************************************************************************************
 Name Controller        : SearchDefectControllerTest 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
 P M Mamata           05/08/2015          created
*****************************************************************************************
*/
@istest(seealldata=true)

private class SearchIssueControllerTest {
    static testmethod void searchdefectMeth(){
        GenerateTestData.createAccount();
        GenerateTestData.createContact();
        GenerateTestData.createParentCase();
        Case dcs = new Case();
        dcs.AccountId = GenerateTestData.acct.Id;
        dcs.ContactId = GenerateTestData.ct.Id; 
        dcs.Status = 'New';
        dcs.TFS_Id__c = '12345';
        dcs.Product__c = 'Prolog Converge';
        dcs.Origin = 'Chat';
        dcs.Serial_Number__c = '12345';        
        dcs.TFS_Id__c = '123456';
        dcs.Type = 'Software Defect';
        dcs.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('GCCM - Support Issue Record Type').getRecordTypeId();        
        insert dcs;
        
        GenerateTestData.dcs = dcs;
        GenerateTestData.createCase();

        Test.startTest();
        SearchIssueController sdc = new SearchIssueController(new ApexPages.Standardcontroller(GenerateTestData.cs));
        
        sdc.selectedIssueSFDCId = GenerateTestData.dcs.Id;
        sdc.selectedIssueTFSId = '12345';
        sdc.changeIssue();
        sdc.first();
        sdc.next();
        sdc.previous();
        sdc.last();
        sdc.AttachIssueToCase();
        sdc.tfsIdWorkItemMap = new Map<String,XmlnsOracleComTfssfdcTnvSearch.TfsWorkItemBean>();
        sdc.createIssueFromTFS();
        sdc.searchString = 'test';
        sdc.selectedProduct = 'Prolog Converge';
        sdc.SearchIssue();
        Test.stopTest();
    }

    static testmethod void searchdefectMeth1(){
        GenerateTestData.createAccount();
        GenerateTestData.createContact();
        GenerateTestData.createParentCase();
        Case dcs = new Case();
        dcs.AccountId = GenerateTestData.acct.Id;
        dcs.ContactId = GenerateTestData.ct.Id; 
        dcs.Status = 'New';
        dcs.TFS_Id__c = '12345';
        dcs.Product__c = 'Proliance';
        dcs.Origin = 'Chat';
        dcs.Serial_Number__c = '12345';        
        dcs.TFS_Id__c = '123456';
        dcs.Type = 'Software Defect';
        dcs.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('GCCM - Support Issue Record Type').getRecordTypeId();        
        insert dcs;
        
        GenerateTestData.dcs = dcs;
        GenerateTestData.createCase();

        Test.startTest();
        SearchIssueController sdc = new SearchIssueController(new ApexPages.Standardcontroller(GenerateTestData.cs));
        
        sdc.selectedIssueSFDCId = GenerateTestData.dcs.Id;
        sdc.selectedIssueTFSId = '12345';
        sdc.changeIssue();
        sdc.first();
        sdc.next();
        sdc.previous();
        sdc.last();
        sdc.AttachIssueToCase();
        sdc.tfsIdWorkItemMap = new Map<String,XmlnsOracleComTfssfdcTnvSearch.TfsWorkItemBean>();
        sdc.createIssueFromTFS();
        sdc.searchString = 'test';
        sdc.selectedProduct = 'Proliance';
        sdc.SearchIssue();
        Test.stopTest();
    }

    static testmethod void searchdefectMeth2(){
        GenerateTestData.createAccount();
        GenerateTestData.createContact();
        GenerateTestData.createParentCase();
        Case dcs = new Case();
        dcs.AccountId = GenerateTestData.acct.Id;
        dcs.ContactId = GenerateTestData.ct.Id; 
        dcs.Status = 'New';
        dcs.TFS_Id__c = '12345';
        dcs.Product__c = 'Prolog Converge';
        dcs.Origin = 'Chat';
        dcs.Serial_Number__c = '12345';        
        dcs.TFS_Id__c = '123456';
        dcs.Type = 'Software Defect';
        dcs.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('GCCM - Support Issue Record Type').getRecordTypeId();        
        insert dcs;
        
        GenerateTestData.dcs = dcs;
        GenerateTestData.createCase();

        Test.startTest();
        SearchIssueController sdc = new SearchIssueController(new ApexPages.Standardcontroller(GenerateTestData.cs));
        sdc.selectedIssueSFDCId = GenerateTestData.dcs.Id;
        sdc.selectedIssueTFSId = '12345';        
        sdc.changeIssue(); 
        sdc.searchString = 'test';
        sdc.SearchIssue();
        sdc.first();
        sdc.next();
        sdc.previous();
        sdc.last();
        sdc.AttachIssueToCase();
        sdc.tfsIdWorkItemMap = new Map<String,XmlnsOracleComTfssfdcTnvSearch.TfsWorkItemBean>();

        XmlnsOracleComTfssfdcTnvSearch.TfsWorkItemBean tData = new XmlnsOracleComTfssfdcTnvSearch.TfsWorkItemBean();
        tData.assignedTo = 'Suresh';
        tData.tfsId = '12345';
        tData.tittle = 'test';
        tData.description = 'test Desc';
        sdc.tfsIdWorkItemMap.put('12345', tData);

        sdc.createIssueFromTFS();
        Test.stopTest();
    }
    
    static testmethod void searchdefectMeth3(){
        GenerateTestData.createAccount();
        GenerateTestData.createContact();
        GenerateTestData.createParentCase();
        Case dcs = new Case();
        dcs.AccountId = GenerateTestData.acct.Id;
        dcs.ContactId = GenerateTestData.ct.Id; 
        dcs.Status = 'New';
        dcs.TFS_Id__c = '12345';
        dcs.Product__c = 'Prolog Converge';
        dcs.Origin = 'Chat';
        dcs.Serial_Number__c = '12345';        
        dcs.TFS_Id__c = '123456';
        dcs.Type = 'Software Defect';
        dcs.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('GCCM - Support Issue Record Type').getRecordTypeId();        
        insert dcs;
        
        Test.startTest();
        
        dcs.TFS_Id__c = null;
        dcs.Is_JIRA_Linked__c = true;
        update dcs;
        
        Test.stopTest();
    }
}