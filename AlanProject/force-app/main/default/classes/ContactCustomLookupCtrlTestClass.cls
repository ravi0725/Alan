/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.

 */
@isTest
public class ContactCustomLookupCtrlTestClass {

    private static Customer_Event__c custEvt;
    private static Country_Region_Mapping__c cust;
    private static Geospatial_Country_Region_Mapping__c custRegMap ;
    private static Account acct;
    private static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    private static Id eventNonCHRecTypeId = Schema.Sobjecttype.Event.getRecordTypeInfosByName().get('Non-CH Schedule Events').getRecordTypeId();
    private static Contact contact;
    private static Contact contact2;
    private static Event evt;
    private static User thisUser;
    
    static void setUpData(){
        
        cust = new Country_Region_Mapping__c(name='India',Region__c='India');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='India',Region__c='India');
        insert custRegMap;
        
        //thisUser = [select Id from User where Id = :UserInfo.getUserId()];
        String randomValue = String.valueOf(Math.random()+2);
        acct = new Account(Name = 'TestAcc'+randomValue,RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending', Phone='24556576351', Requested_Account_Record_Type__c = 'Customer',
            BillingCountry = 'India',BillingCity = 'Pune',BillingStreet = 'A-202');
        insert acct;
        
        DateTime dtStart = System.now();        
        DateTime dtEnd = dtStart.addDays(1);        
        evt = new Event(Type = 'Meeting - Demo',StartDateTime = dtStart, EndDateTime = dtEnd, Subject = 'Hardware Installation', RecordTypeId = eventNonCHRecTypeId);
        insert evt;
                
        contact = new Contact();
        contact.FirstName = 'Partner';
        contact.LastName = 'Con'+randomValue;
        contact.AccountId = acct.Id;
        contact.Preferred_Language__c = 'German';
        contact.MailingStreet='test1';
        contact.Mailingcity='testcity';
        contact.MailingState='teststate';
        contact.MailingPostalCode ='12345';
        contact.MailingCountry ='India';
        contact.Salutation = 'Mr.';
        contact.Phone = '0802345566';
        contact.MobilePhone = '8979594821';
        contact.Role_on_Account__c = 'Accounting';
        insert contact;
        
        contact2 = new Contact();
        contact2.FirstName = 'Partner2';
        contact2.LastName = 'Con2'+randomValue;
        contact2.AccountId = acct.Id;
        contact2.MailingCountry ='India';
        contact2.Email = 'test@test2.com';
        //contact.Customer_Event__c = 'Test';
        insert contact2;
        
        custEvt = new Customer_Event__c(Account__c=acct.id , Event_Id__c=evt.Id, Event_Contact__c = contact.Id, Contact_Confirmation__c = true);
        insert custEvt;
        
        contact.Customer_Event__c = custEvt.Id;
        update contact;
    }
    
     static testMethod void TestPageCustomController() {
        setUpData();
        Test.startTest(); 
            Pagereference pgRef = Page.ContactCustomLookup;
            pgRef.getParameters().put('eventId',evt.id);   
            pgRef.getParameters().put('accountId',acct.id);
         
            Test.setCurrentPage(pgRef);
            
            ContactCustomLookupCtrl contrl = new ContactCustomLookupCtrl();
            contrl.getContList();
            ContactCustomLookupCtrl.ContactWrapper cclCwWrap = new ContactCustomLookupCtrl.ContactWrapper();
            cclCwWrap.cat = contact;
            cclCwWrap.checked = true;
            List<ContactCustomLookupCtrl.ContactWrapper> cclcwWrapList = new List<ContactCustomLookupCtrl.ContactWrapper>();
            cclcwWrapList.add(cclCwWrap);
            contrl.setContList(cclcwWrapList);
            contrl.SelectedContact();
            contrl.Cancel();
        Test.stopTest();    
     }
     
    static testMethod void TestPageCustomController2() {
        setUpData();
        contact.AccountId = null;
        update contact;
        
        contact2.AccountId = null;
        update contact2;
        
        Contact contact3 = new Contact();
        contact3.FirstName = 'Partner3';
        contact3.LastName = 'Contact3';
        contact3.AccountId = acct.Id;
        contact3.MailingCountry ='India';
        contact3.Email = 'test@test3.com';
        //contact.Customer_Event__c = 'Test';
        insert contact3;
        
        Customer_Event__c custEvt2 = new Customer_Event__c(Account__c=acct.id , Event_Id__c=evt.Id, Event_Contact__c = contact3.Id, Contact_Confirmation__c = true);
        insert custEvt2;
        
        Event evt2 = new Event(Type = 'Meeting - Demo',StartDateTime = system.now(), EndDateTime = system.now()+2, Description = 'Account Name:'+acct.Name, WhatId = acct.Id, Subject = 'Hardware Installation2', RecordTypeId = eventNonCHRecTypeId);
        insert evt2;
        
        Test.startTest(); 
            Pagereference pgRef = Page.ContactCustomLookup;
            pgRef.getParameters().put('eventId',evt.id);   
            pgRef.getParameters().put('accountId',acct.id);
         
            Test.setCurrentPage(pgRef);
            
            ContactCustomLookupCtrl contrl = new ContactCustomLookupCtrl();
            contrl.getContList();
            ContactCustomLookupCtrl.ContactWrapper cclCwWrap = new ContactCustomLookupCtrl.ContactWrapper();
            cclCwWrap.cat = contact;
            cclCwWrap.checked = false;
            List<ContactCustomLookupCtrl.ContactWrapper> cclcwWrapList = new List<ContactCustomLookupCtrl.ContactWrapper>();
            cclcwWrapList.add(cclCwWrap);
            contrl.setContList(cclcwWrapList);
            contrl.SelectedContact();
            contrl.Cancel();
        Test.stopTest();    
     }
    
    static testMethod void TestPageCustomController3() {
        setUpData();
        contact.AccountId = null;
        update contact;
        
        contact2.AccountId = null;
        update contact2;
        
        Test.startTest(); 
            Pagereference pgRef = Page.ContactCustomLookup;
            pgRef.getParameters().put('eventId',evt.id);   
            pgRef.getParameters().put('accountId',acct.id);
         
            Test.setCurrentPage(pgRef);
            
            ContactCustomLookupCtrl contrl = new ContactCustomLookupCtrl();
            contrl.getContList();
            ContactCustomLookupCtrl.ContactWrapper cclCwWrap = new ContactCustomLookupCtrl.ContactWrapper();
            cclCwWrap.cat = contact;
            cclCwWrap.checked = false;
            List<ContactCustomLookupCtrl.ContactWrapper> cclcwWrapList = new List<ContactCustomLookupCtrl.ContactWrapper>();
            cclcwWrapList.add(cclCwWrap);
            contrl.setContList(cclcwWrapList);
            contrl.SelectedContact();
            contrl.Cancel();
        Test.stopTest();    
     }
    /*static testMethod void TestPageCustomController2() {
        setUpData();
        Test.startTest(); 
            Pagereference pgRef = Page.ContactCustomLookup;
            pgRef.getParameters().put('eventId',evt.id);   
            pgRef.getParameters().put('accountId',acct.id);
         
            Test.setCurrentPage(pgRef);
            
            ContactCustomLookupCtrl contrl = new ContactCustomLookupCtrl();
            contrl.LoadData();
            ContactCustomLookupCtrl.ContactWrapper ctwrap = new ContactCustomLookupCtrl.ContactWrapper();
            ctwrap.checked = true;
            ctwrap.cat.Id = contact2.Id;
            contrl.ContList.add(ctwrap);
            contrl.getContList();
            contrl.SelectedContact();
            contrl.Cancel();
        Test.stopTest();    
     }*/
}