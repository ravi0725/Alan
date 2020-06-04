@isTest(seeAllData=true)
private class FC_TestAgreementUtil {
    static testMethod void testMeth1() {
        GenerateTestData.createAccount();
        GenerateTestData.createAddress();
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();
        GenerateTestData.createProposal();
        GenerateTestData.createAPTSAgreement();
    	FC_AgreementUtil.addInfoToOpportunity(GenerateTestData.apg.Id,GenerateTestData.opp);
    }
    
    static testMethod void testMeth2() {
        GenerateTestData.createAccount();
        GenerateTestData.createAddress();
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();
    	FC_AgreementUtil.addInfoToOpportunity(null,GenerateTestData.opp);
    }
    
   /* static testMethod void testUtil() {
        setup();
        Test.startTest();
        Apttus__APTS_Agreement__c agreement = [select Id from Apttus__APTS_Agreement__c limit 1];
        agreement.Name = 'special test agreement';
        
        Opportunity testOpp = [select Id from Opportunity limit 1];
        testOpp.Payment_Term__c = 'net 30';
        testOpp.Selling_Division__c = 'test division';
        update testOpp;
        agreement.Apttus__Related_Opportunity__c = testOpp.Id;
        update agreement;
        
        Opportunity targetOpportunity = new Opportunity(Name = 'target test opp');
        
        
        FC_AgreementUtil.addInfoToOpportunity(agreement.Id, targetOpportunity);
        Test.stopTest();
        System.assertEquals('net 30', targetOpportunity.Payment_Term__c);
        System.assertEquals('test division', targetOpportunity.Selling_Division__c);
    }
    
    static void setup() {
        FC_TestDataGenerator.insertSetupData();
        
        Profile profile = [select Id from Profile where Name = 'System Administrator' limit 1];    
        
        User usr = new User();
        usr.Username = 'test-sysadmin@trimble.com';
        usr.Email = 'test@trimble.com';
        usr.LastName = 'Test';
        usr.Alias = 'Test123';
        usr.ProfileID = profile.Id;
        usr.LocaleSidKey = 'en_US';
        usr.LanguageLocaleKey = 'en_US';
        usr.Country = 'United States';
        usr.TimeZoneSidKey = 'America/Los_Angeles';
        usr.EmailEncodingKey='UTF-8';
        insert usr;
        
        RecordType rt = [select Id from RecordType where Name = 'Master Saas Agreement' limit 1];
        
        // create accounts
        Account[] accounts = FC_TestDataGenerator.generateAccounts();
        System.runAs(usr) {
            insert accounts;
            Contact[] contacts = FC_TestDataGenerator.generateContacts(accounts);
            insert contacts;
        }
        Apttus_Config2__PriceList__c priceList = FC_TestDataGenerator.generatePriceList();
        insert priceList;
        Opportunity[] opportunities = FC_TestDataGenerator.generateOpportunities(accounts);
        insert opportunities;
        Apttus_Proposal__Proposal__c[] proposals = FC_TestDataGenerator.generateProposals(opportunities, priceList);
        insert proposals;
        Apttus__APTS_Agreement__c[] agreements = FC_TestDataGenerator.generateAgreements(rt, proposals);
        insert agreements;
    }*/
}