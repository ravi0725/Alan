/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.

 */
@isTest
public class CustomerEventExntTestClass {
    private static Id eventNonCHRecTypeId = Schema.Sobjecttype.Event.getRecordTypeInfosByName().get('Non-CH Schedule Events').getRecordTypeId();
    private static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    private static Country_Region_Mapping__c cust;
    private static Geospatial_Country_Region_Mapping__c custRegMap ;
    
    static testMethod void TestCustomerEventController() {
        cust = new Country_Region_Mapping__c(name='India',Region__c='India');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='India',Region__c='India');
        insert custRegMap;
        
        DateTime dtStart = System.now();
        DateTime dtEnd = dtStart.addDays(1);
        
        Account accnt = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,CurrencyIsoCode = 'USD',EBS_Payment_Term__c= 'CASH IN ADVANCE',Payment_Term__c = 'CASH IN ADVANCE',Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
                           FCH_Party_ID__c = '111111', Phone = '8989487421', Enterprise_Party_Number__c ='12345',BillingCountry = 'India',Restricted_Entity__c = Label.Not_Restricted,Annual_Support_Date__c = date.today(), BillingCity = 'Pune',BillingState = 'BillingState', BillingPostalCode = 'postal code',BillingStreet = 'A-202',Collector_Email__c = 'test@gmail.com');
        insert accnt;
        
        Contact contact = new Contact();
        contact.FirstName = 'Partner-1';
        contact.LastName = 'Contact-1';
        contact.AccountId = accnt.Id;
        contact.MailingCountry ='India';
        contact.Email = 'test@test-1.com';
        //contact.Customer_Event__c = 'Test';
        insert contact;
        
        Event evenObj = new Event(OwnerId= userinfo.getUserId(),Type = 'Meeting - Demo',StartDateTime = dtStart, EndDateTime = dtEnd, Subject = 'Hardware Installation', RecordTypeId = eventNonCHRecTypeId);
        insert evenObj;
        
        Customer_Event__c ce = new Customer_Event__c(Event_Id__c = evenObj.Id, Account__c = accnt.Id, Event_Contact__c = contact.Id, FS_Survey_Link_Sent__c = true, FS_Survey_Sent_Date__c=system.Date.today(), FS_Email_Schedule_Date__c=system.Date.today()+2);
        insert ce;
        
        ApexPages.StandardController sc = new ApexPages.standardController(evenObj);
         CustomerEventExnt extn = new CustomerEventExnt(sc);
         extn.LoadData();
         Customer_Event__c ce2 = new Customer_Event__c(Event_Id__c = evenObj.Id, Account__c = accnt.Id, Event_Contact__c = contact.Id, FS_Survey_Link_Sent__c = true, FS_Survey_Sent_Date__c=system.Date.today(), FS_Email_Schedule_Date__c=system.Date.today()+2);
         insert ce2;
         ce2.Contact_Confirmation__c = true;
         update ce2;
         
         CustomerEventExnt.contactWrapper cewrap = new CustomerEventExnt.contactWrapper(contact);
         cewrap.cnt = contact;
         cewrap.confirm = true;
         
         CustomerEventExnt.customerEventWrapper custEvWrap = new CustomerEventExnt.customerEventWrapper(ce);
        
         List<CustomerEventExnt.contactWrapper> cewrapList = new List<CustomerEventExnt.contactWrapper>();
         cewrapList.add(cewrap);
         
         Map<Id, Customer_Event__c> custMap = new Map<Id, Customer_Event__c>();
         custMap.put(ce.Id, ce);
         custMap.put(ce2.Id, ce2);
        
         Map<Id, List<CustomerEventExnt.contactWrapper>> eventCntactsMap = new Map<Id, List<CustomerEventExnt.contactWrapper>>();
         eventCntactsMap.put(contact.Id, cewrapList);
        
         CustomerEventExnt.mapsWrapper cemaps = new CustomerEventExnt.mapsWrapper(custMap, eventCntactsMap);
         
         extn.AddCustomers();
         extn.saveConfirmations();
         extn.cEventSendSurveyID = ce2.Id;
         extn.sendFormstackSurvey();
         extn.DeleteCustEvent();
         
        
     }
    
     static testMethod void TestPageCustomController2() {
        
        User oSystemAdmin = [select Id from User Where ProfileId = '00ei0000000sT9m' AND IsActive = true limit 1];
        
        DateTime dtStart = System.now();
        
        DateTime dtEnd = dtStart.addDays(1);
        
        Event evenObj = new Event(OwnerId= oSystemAdmin.Id,Type = 'Meeting - Demo',StartDateTime = dtStart, EndDateTime = dtEnd, Subject = 'Hardware Installation');
        insert evenObj;
        
         ApexPages.StandardController sc = new ApexPages.standardController(evenObj);
         CustomerEventExnt extn = new CustomerEventExnt(sc);
         extn.AddCustomers();
         extn.DeleteCustEvent();
         extn.LoadData();
     }
    
    /*static testMethod void TestPageCustomController() {
        
        cust = new Country_Region_Mapping__c(name='India',Region__c='India');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='India',Region__c='India');
        insert custRegMap;
        
        DateTime dtStart = System.now();
        DateTime dtEnd = dtStart.addDays(1);
        
        Event evenObj = new Event(OwnerId= userinfo.getUserId(),Type = 'Meeting - Demo',StartDateTime = dtStart, EndDateTime = dtEnd, Subject = 'Hardware Installation', RecordTypeId = eventNonCHRecTypeId);
        insert evenObj;
        
        Account acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
            BillingCountry = 'India',BillingCity = 'Pune',BillingStreet = 'A-202');
        insert acct;
        
        Contact contact = new Contact();
        contact.FirstName = 'Partner';
        contact.LastName = 'Contact';
        contact.AccountId = acct.Id;
        contact.MailingCountry ='India';
        contact.Email = 'test@test.com';
        //contact.Customer_Event__c = 'Test';
        insert contact;
        
        Customer_Event__c ce = new Customer_Event__c(Event_Id__c = evenObj.Id, Account__c = acct.Id, Event_Contact__c = contact.Id, FS_Survey_Link_Sent__c = true, FS_Survey_Sent_Date__c=system.Date.today(), FS_Email_Schedule_Date__c=system.Date.today()+2);
        insert ce;
        
        ApexPages.StandardController sc = new ApexPages.standardController(evenObj);
         CustomerEventExnt extn = new CustomerEventExnt(sc);
         extn.LoadData();
         Customer_Event__c ce2 = new Customer_Event__c(Event_Id__c = evenObj.Id, Account__c = acct.Id, Event_Contact__c = contact.Id, FS_Survey_Link_Sent__c = true, FS_Survey_Sent_Date__c=system.Date.today(), FS_Email_Schedule_Date__c=system.Date.today()+2);
         insert ce2;
         ce2.Contact_Confirmation__c = true;
         update ce2;
         CustomerEventExnt.contactWrapper cewrap = new CustomerEventExnt.contactWrapper(contact);
         cewrap.cnt = contact;
         cewrap.confirm = true;
         
         CustomerEventExnt.customerEventWrapper custEvWrap = new CustomerEventExnt.customerEventWrapper(ce);
        
         List<CustomerEventExnt.contactWrapper> cewrapList = new List<CustomerEventExnt.contactWrapper>();
         cewrapList.add(cewrap);
         
         Map<Id, Customer_Event__c> custMap = new Map<Id, Customer_Event__c>();
         custMap.put(ce.Id, ce);
         custMap.put(ce2.Id, ce2);
        
         Map<Id, List<CustomerEventExnt.contactWrapper>> eventCntactsMap = new Map<Id, List<CustomerEventExnt.contactWrapper>>();
         eventCntactsMap.put(contact.Id, cewrapList);
        
         CustomerEventExnt.mapsWrapper cemaps = new CustomerEventExnt.mapsWrapper(custMap, eventCntactsMap);
         
         extn.AddCustomers();
         extn.saveConfirmations();
         extn.cEventSendSurveyID = ce.Id;
         extn.sendFormstackSurvey();
         extn.DeleteCustEvent();
         
     }*/
}