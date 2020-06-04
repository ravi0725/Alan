/**
* Company     : Trimble Inc.,
* Description : Test Class for Batch class creating CustomerEvents 
* History     :  

* [22.01.2018] Chandrakanth Malayathi  Created
*/
@isTest
private class BatchCreateCustomerEventWithContactTest {
    
	private static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    private static Id eventNonCHRecTypeId = Schema.Sobjecttype.Event.getRecordTypeInfosByName().get('Non-CH Schedule Events').getRecordTypeId();
    private static Account acct;
    private static Contact ct;
    private static Event evt;
    private static Customer_Event__c cEvent;
    
    private static void TestData(){
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
        ct.FirstName = 'Test First Name';
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
        cEvent.Contact_Names__c = ct.FirstName + ' ' + ct.LastName + ' /';
        insert cEvent;
    }
    
    static testmethod void TestBatchCreateCustomerEventWithContact1(){
        TestData();
        Test.startTest();
            BatchCreateCustomerEventWithContact obj = new BatchCreateCustomerEventWithContact();
            DataBase.executeBatch(obj); 
        Test.stopTest();
	}
    
    static testmethod void TestBatchCreateCustomerEventWithContact2(){
        TestData();
        
        Contact ct2 = new Contact();
        ct2.FirstName = 'Test First Name1';
        ct2.LastName = 'Test last name1';
        ct2.AccountId = acct.Id;
        ct2.Preferred_Language__c = 'American English';
        ct2.Email = 'test1@gmail.com';
        ct2.MailingStreet='test12';
        ct2.Mailingcity='testcity1';
        ct2.MailingState='teststate1';
        ct2.MailingPostalCode ='123455';
        ct2.MailingCountry = 'United States';
        ct2.Salutation = 'Mr.';
        ct2.Phone = '0802345566';
        ct2.Role_on_Account__c = 'Accounting';
        insert ct2;
        
        Customer_Event__c cEvent2 = new Customer_Event__c();
        cEvent2.Account__c = evt.WhatId;
        cEvent2.Event_Id__c = evt.Id;
        cEvent2.Contact_Names__c = ct.FirstName + ' ' + ct.LastName + ' / ' + ct2.FirstName + ' ' + ct2.LastName + ' /';
        insert cEvent2;
        
        Test.startTest();
            BatchCreateCustomerEventWithContact obj = new BatchCreateCustomerEventWithContact();
            DataBase.executeBatch(obj); 
        Test.stopTest();
	}
}