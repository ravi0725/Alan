@isTest(seeAlldata=true)
private class FC_TestSetAgreementStatusController {
    static testMethod void testMeth1() {
        GenerateTestData.createAccount();
        GenerateTestData.createAddress();
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();
        GenerateTestData.createProposal();
        GenerateTestData.createAPTSAgreement();
    	FC_SetAgreementStatusController temp = new FC_SetAgreementStatusController(new ApexPages.StandardController(GenerateTestData.apg));
        temp.setStatus();
    }
    
    
    /*static testMethod void testAgreementStatus() {
        setup();
        RecordType rt = [select Id from RecordType where Name = 'Master Saas Agreement' limit 1];
        Apttus__APTS_Agreement__c[] agreements = FC_TestDataGenerator.generateAgreements(rt, 
            [select Id, Name,
                BillingCity,
                BillingCountry,
                BillingState,
                Industry from Account]);
        insert agreements;
    }
    
    static void setup() {
        FC_TestDataGenerator.insertSetupData();
        
        Profile profile = [select Id from Profile where Name = 'System Administrator' limit 1];    
        
        User user = new User();
        user.Username = 'test2@trimble.com';
        user.Email = 'test2@trimble.com';
        user.LastName = 'Test';
        user.Alias = 'Test123';
        user.ProfileID = profile.Id;
        user.LocaleSidKey = 'en_US';
        user.LanguageLocaleKey = 'en_US';
        user.Country = 'United States';
        user.TimeZoneSidKey = 'America/Los_Angeles';
        user.EmailEncodingKey='UTF-8';
        insert user;

        
        Account[] accounts = FC_TestDataGenerator.generateAccounts();
        System.runAs(user) {
            insert accounts;
        }
    }*/
}