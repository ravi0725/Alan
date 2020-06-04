/**
 * Test class for Formstack MEP setup
 * */
@isTest
private class FromstackTestClass {
    private static testmethod void CaseFormStackUpdateProcess_Test(){
        system.Test.startTest();
        Country_Region_Mapping__c cust = new Country_Region_Mapping__c(name='India',Region__c='India');
        insert cust;
        
        Geospatial_Country_Region_Mapping__c custRegMap = new Geospatial_Country_Region_Mapping__c(name='India',Region__c='India');
        insert custRegMap;
        
        Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
        Account acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
            BillingCountry = 'India',BillingCity = 'Pune',BillingStreet = 'A-202', Phone = '(408) 481-6246' );
        insert acct;
        
        Contact ct = new Contact();
        ct.LastName = 'Test last name';
        ct.AccountId = acct.Id;
        ct.Preferred_Language__c = 'American English';
        ct.Email = 'test@gmail.com';
        ct.MailingStreet='test1';
        ct.Mailingcity='testcity';
        ct.MailingState='teststate';
        ct.MailingPostalCode ='12345';
        ct.MailingCountry = 'India';
        insert ct;
        
        Case cs = new Case();
        cs.AccountId = acct.Id;
        cs.ContactId = ct.Id;
        cs.Status = 'New';
        cs.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Case (Plancal Customer) Record Type').getRecordTypeId();
        cs.Product__c = 'Prolog Manager';
        cs.Origin = 'Chat';
        cs.Serial_Number__c = '12345';        
        cs.TFS_Id__c = '123456';
        cs.Survey_Received_Date__c = system.today();
        cs.Representative_Knowledge__c = 'TEST 1 = test value1';
        cs.Product_Satisfaction__c = 'TEST 2 = test value2';
        cs.Response_Time__c = 'TEST 3 = test value3';
        cs.Support_Time__c = 'TEST 4 = test value4';
        
        insert cs;
        
        // Begin test
        List<Id> caseIDs = new List<Id>();
        caseIDs.add(cs.Id);
        CaseFormStackUpdateProcess.removeUnwantedString(caseIDs);
        
        CaseFormStackDummyUpdate.dummyUpdate(caseIDs);
        
        CaseFormStackUpdateContactDate.updateContactSurveySentDate(caseIDs);
        system.Test.stopTest();
    }
}