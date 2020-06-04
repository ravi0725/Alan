@isTest
private class FC_TestCreateChangeOrderController {

    private static testmethod void testCreateProposal() {
        setup();
        
        User adminUser = [select Id from User where Username = 'test-sysadmin@trimble.com' limit 1];
		RecordType rt = [select Id from RecordType where Name = 'Master Saas Agreement' limit 1];
		
        Test.startTest();
        
        Account[] accounts = FC_TestDataGenerator.generateAccounts();
        System.assertEquals(true, accounts.size() > 0);
        System.runAs(adminUser) {
            insert accounts;
        }
        Apttus__APTS_Agreement__c[] agreements = FC_TestDataGenerator.generateAgreements(rt, accounts);
        System.assertEquals(true, agreements.size() > 0);
        insert agreements;

        PageReference testPage = Page.FC_CreateChangeOrder;
        testPage.getParameters().put('id', agreements[0].Id);
        Test.setCurrentPage(testPage);
        ApexPages.StandardController standardController = new ApexPages.StandardController(agreements[0]);
        FC_CreateChangeOrderController controller = new FC_CreateChangeOrderController(standardController);
        PageReference pr = controller.beginChangeOrderProcess();
        System.assert(pr != null);

        Test.stopTest();
        
    }
    
    private static void setup() {
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
    }
}