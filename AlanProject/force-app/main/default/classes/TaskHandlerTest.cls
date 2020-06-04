@isTest(SeeAllData = true)
public class TaskHandlerTest{
    static testmethod void testTaskHandler1(){
        Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
        Id conRecTypeId = Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get('Contact (Customer) Record Type').getRecordTypeId();
        Account acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,CurrencyIsoCode = 'USD',Payment_Term__c = 'CASH IN ADVANCE',Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer', Preferred_Language__c = 'American English',
            BillingCountry = 'United States',Restricted_Entity__c = Label.Not_Restricted,Annual_Support_Date__c = date.today(), BillingCity = 'Pune',BillingState = 'BillingState', BillingPostalCode = 'postal code',BillingStreet = 'A-202',Collector_Email__c = 'test@gmail.com');
        insert acct;
        
        Contact con = new Contact(RecordTypeId = conRecTypeId, LastName = 'testContact', Email = 'testmail@test.com', Preferred_Language__c = 'American English', Phone = '123456789', MobilePhone = '123456789');
        insert con;
        
        Task t = new Task(OwnerId = UserInfo.getUserId(), WhoId = con.Id);
        insert t;
    }
    
    static testmethod void testTaskHandler2(){
        Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
        Id conRecTypeId = Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get('Contact (Customer) Record Type').getRecordTypeId();
        Account acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,CurrencyIsoCode = 'USD',Payment_Term__c = 'CASH IN ADVANCE',Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer', Preferred_Language__c = 'American English',
            BillingCountry = 'United States',Restricted_Entity__c = Label.Not_Restricted,Annual_Support_Date__c = date.today(), BillingCity = 'Pune',BillingState = 'BillingState', BillingPostalCode = 'postal code',BillingStreet = 'A-202',Collector_Email__c = 'test@gmail.com');
        insert acct;
        
        Contact con = new Contact(RecordTypeId = conRecTypeId, LastName = 'testContact', Email = 'testmail@test.com', Preferred_Language__c = 'American English', Phone = '123456789', MobilePhone = '123456789');
        insert con;
        
        Opportunity opp = new Opportunity(AccountId = acct.Id, Name = 'Test Opp', StageName = 'New', CloseDate = system.today() + 30, Bill_To_Account__c = acct.Id);
        insert opp;
        
        User usr = [select Id, Division__c, Profile.Name from User where Division__c = 'MEP' AND Profile.Name = 'Sales Rep - MEP - Europe' limit 1];
        
        List<Task> tList = new List<Task>();
        
        Task t = new Task(OwnerId = usr.Id, WhoId = con.Id, WhatId = acct.Id, ActivityDate = system.now().Date() + 2, Subject = 'Task to be completed', Status = 'Not Started', Description = 'Task Complete Test');
        insert t;
        
        t.Status = 'Completed';
        tList.add(t);
        
        Task t1 = new Task(OwnerId = usr.Id, WhoId = con.Id, WhatId = acct.Id, ActivityDate = system.now().Date() + 2, Subject = 'Task to be completed1', Status = 'Not Started', Description = 'Task Complete Test1');
        insert t1;
        
        t1.Status = 'Completed';
        tList.add(t1);
        
        Task t2 = new Task(OwnerId = usr.Id, WhoId = con.Id, WhatId = opp.Id, ActivityDate = system.now().Date() + 2, Subject = 'Task to be completed2', Status = 'Not Started', Description = 'Task Complete Test2');
        insert t2;
        
        t2.Status = 'Completed';
        tList.add(t2);
        
        update tList;
    }
    
    static testmethod void testTaskHandler3(){
        Test.startTest();
            GenerateTestData.createAccount();
            
            List<Task> tList = new List<Task>();
        
            Task t = new Task(WhatId = GenerateTestData.acc.Id, ActivityDate = system.now().Date() + 2, Subject = 'Task to be completed', Status = 'Not Started', Description = 'Task Complete Test');
            insert t;
            
            t.status = 'completed';
            tList.add(t);
            
            update tList;
        Test.stopTest();
    }
}