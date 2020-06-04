/**
* Company     : Trimble Inc.,
* Description : Controller class for CustomerEventListner Trigger 
* History     :  

* [12.01.2018] Suresh Babu Murugan  Created
*/
@isTest
private class CustomerEventListnerTest {
    private static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    private static Id eventNonCHRecTypeId = Schema.Sobjecttype.Event.getRecordTypeInfosByName().get('Non-CH Schedule Events').getRecordTypeId();
    private static Account acct;
    private static Contact ct;
    private static Event evt;
    private static Customer_Event__c cEvent;
    
    static testmethod void TestCustEventTrigger1(){
        TestDataSetup();
        
        Test.startTest();
        
        CustomerEventHandler.resetLaunchControl();
        cEvent.Contact_Confirmation__c = TRUE;
        update cEvent;
        
        Test.stopTest();
    }
    
    static testmethod void TestCustEventTrigger2(){
        TestDataSetup();
        String uniqueUserName = 'apiuser' + DateTime.now().getTime() + '@testuser.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='API Only' LIMIT 1];
        User u = new User(Alias = 'apitst', Email='testapiuser@testuser.com',
                          EmailEncodingKey='UTF-8', LastName='API User', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName=uniqueUserName);
        
        Test.startTest();
        System.runAs(u) {
            
            CustomerEventHandler.resetLaunchControl();
            cEvent.Contact_Confirmation__c = TRUE;
            cEvent.FS_Course_Rating__c = 'TEST Content 1 = Val1';
            cEvent.FS_Trainer_Knowledge_Rating__c = 'TEST Content 1 = Val1';
            cEvent.FS_Trainer_Presentation_Rating__c = 'TEST Content 1 = Val1';
            cEvent.FS_Trainer_Support_Rating__c = 'TEST Content 1 = Val1';
            cEvent.FS_Training_Duration_Rating__c = 'TEST Content 1 = Val1';
            cEvent.FS_Training_Equipment_Rating__c = 'TEST Content 1 = Val1';
            cEvent.FS_Training_General_Rating__c = 'TEST Content 1 = Val1';
            cEvent.FS_Training_Presentation_Rating__c = 'TEST Content 1 = Val1';
            cEvent.FS_Survey_Completed_Date__c = system.now().addHours(6);
            update cEvent;
        }
        Test.stopTest();
    }
    
    private static void TestDataSetup(){
        Country_Region_Mapping__c cmap = new Country_Region_Mapping__c();
        cmap.Name = 'United States';
        cmap.Region__c = 'North America';
        insert cmap;
        
        Geospatial_Country_Region_Mapping__c gmap = new Geospatial_Country_Region_Mapping__c();
        gmap.Name = 'United States';
        gmap.Region__c = 'North America';
        insert gmap;
        
        acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,CurrencyIsoCode = 'USD',EBS_Payment_Term__c= 'CASH IN ADVANCE',Payment_Term__c = 'CASH IN ADVANCE',Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
                           FCH_Party_ID__c = '111111', Phone = '8989487421', Enterprise_Party_Number__c ='12345',BillingCountry = 'United States',Restricted_Entity__c = Label.Not_Restricted,Annual_Support_Date__c = date.today(), BillingCity = 'Pune',BillingState = 'BillingState', BillingPostalCode = 'postal code',BillingStreet = 'A-202',Collector_Email__c = 'test@gmail.com');
        insert acct;
        
        ct = new Contact();
        ct.LastName = 'Test last name';
        ct.AccountId = acct.Id;
        ct.Preferred_Language__c = 'American English';
        ct.Email = 'test@gmail.com';
        ct.MailingStreet='test1';
        ct.Mailingcity='testcity';
        ct.MailingState='teststate';
        ct.MailingPostalCode ='12345';
        ct.MailingCountry = 'United States';
        ct.Salutation = 'Mr.';
        ct.Phone = '0802345566';
        ct.Role_on_Account__c = 'Accounting';
        insert ct;
        
        datetime datestart = system.now();
		datetime dateend = system.now().addHours(1);
        evt = new Event();
        evt.Subject= 'Test Non CH Event';
        evt.WhatId = acct.Id;
        evt.WhoId = ct.Id;
        evt.Type = 'Other';
        evt.ActivityDate = date.today();
        evt.DurationInMinutes = 30;
        evt.ActivityDateTime = datestart;
        evt.RecordTypeId = eventNonCHRecTypeId;
        evt.StartDateTime = datestart;
        evt.EndDateTime = dateend;
        evt.DurationInMinutes = 60;
        evt.Type = 'External Meeting';
        evt.Description = 'TEST Description';
        insert evt;
        
        cEvent = new Customer_Event__c();
        cEvent.Account__c = evt.WhatId;
        cEvent.Event_Id__c = evt.Id;
        cEvent.Event_Contact__c = ct.Id;
        insert cEvent;
    }
}