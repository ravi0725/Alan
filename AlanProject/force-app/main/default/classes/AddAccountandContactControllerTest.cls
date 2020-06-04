@isTest
Private class AddAccountandContactControllerTest{
    
    private static Customer_Event__c custEvt;
    private static Country_Region_Mapping__c cust;
    private static Geospatial_Country_Region_Mapping__c custRegMap ;
    private static Account acct;
    private static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    private static Id eventNonCHRecTypeId = Schema.Sobjecttype.Event.getRecordTypeInfosByName().get('Non-CH Schedule Events').getRecordTypeId();
    private static Contact contact;
    private static Event evt;
    private static User thisUser;
        
    static void setUpData(){
        
        cust = new Country_Region_Mapping__c(name='India',Region__c='India');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='India',Region__c='India');
        insert custRegMap;
        
        thisUser = [select Id from User where Id = :UserInfo.getUserId()];
        String randomValue = String.valueOf(Math.random()+2);
        acct = new Account(Name = 'Test Acc'+randomValue,RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending', Phone='2455657651', Requested_Account_Record_Type__c = 'Customer',
            BillingCountry = 'India',BillingCity = 'Pune',BillingStreet = 'A-202');
        insert acct;
        
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
        contact.Role_on_Account__c = 'Accounting';
        insert contact;
        
        DateTime dtStart = System.now();        
        DateTime dtEnd = dtStart.addDays(1);  
        evt = new Event(OwnerId= thisUser.Id, WhatId = acct.Id, Type = 'Meeting - Demo',StartDateTime = dtStart, EndDateTime = dtEnd, Subject = 'Hardware Installation', RecordTypeId = eventNonCHRecTypeId);
        insert evt;
        
        custEvt = new Customer_Event__c(Account__c=acct.id , Customer_Related_Contact__c=contact.Id , Event_Id__c=evt.Id, Event_Contact__c = contact.Id);
        insert custEvt;
        
    }
    
    private static testmethod void testSearch(){
            setUpData();
            Test.startTest(); 
                Pagereference pgRef = Page.competitorAssetsAccountPage;
                pgRef.getParameters().put('id',custEvt.Event_Id__c);
                pgRef.getParameters().put('selectedCategoryId',acct.id);
                Test.setCurrentPage(pgRef);
                
                AddAccountandContactController cont = new AddAccountandContactController(new ApexPages.StandardController(evt));
                cont.SearchText='Test';
                cont.Search();
                cont.SearchContact();
                cont.getContList();
                AddAccountandContactController.ContactWrapper aaccwrap = new AddAccountandContactController.ContactWrapper(contact);
        		AddAccountandContactController.ContactWrapper aaccwrap2 = new AddAccountandContactController.ContactWrapper(contact, true);
        		List<AddAccountandContactController.ContactWrapper> aaccWrapList = new List<AddAccountandContactController.ContactWrapper>();
        		aaccWrapList.add(aaccwrap2);
        		cont.setContList(aaccWrapList);
        		cont.SelectedContact();
            Test.stopTest();        
    }
    
    /*private static testmethod void testSearch2(){
            setUpData();
            DateTime dtStart = System.now();        
            DateTime dtEnd = dtStart.addDays(1);        
            evt = new Event(OwnerId= thisUser.Id,Type = 'Meeting - Demo',StartDateTime = dtStart, EndDateTime = dtEnd, Subject = 'Hardware Installation');
            insert evt;
            Test.startTest(); 
                Pagereference pgRef = Page.competitorAssetsAccountPage;
                pgRef.getParameters().put('id',custEvt.Event_Id__c);
                pgRef.getParameters().put('selectedCategoryId',acct.id);
                Test.setCurrentPage(pgRef);
                
                AddAccountandContactController cont = new AddAccountandContactController(new ApexPages.StandardController(evt));
                cont.SearchText='Test';
                cont.Search();
                cont.SearchContact();
                cont.getContList();
                cont.SelectedContact();
            Test.stopTest();        
    }*/
}