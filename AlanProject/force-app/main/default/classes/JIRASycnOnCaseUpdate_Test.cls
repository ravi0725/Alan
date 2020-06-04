/*****************************************************************************************
Name        : JIRASyncIssueCtrl_Test 
Description : Test class for Create JIRA Issue from SFDC 
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
Suresh Babu         29/Sep/2016          Created
******************************************************************************************/
@isTest private class JIRASycnOnCaseUpdate_Test {
    private static Country_Region_Mapping__c cust;
    private static Geospatial_Country_Region_Mapping__c custRegMap ;
    private static Account acct;
    private static Contact ct;
    private static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    private static Entitlement ent;
    private static Case pcs, pcs1, pcs2;
    private static User apiUser;
    private static Profile prf = [Select Id from Profile where Name =: Label.API_Only];
      
    static void setUpData(){
        
        cust = new Country_Region_Mapping__c(name='India',Region__c='India');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='India',Region__c='India');
        insert custRegMap;
        
        List<JIRA_System_Config__c> lstJIRASys = new List<JIRA_System_Config__c>();
        
        JIRA_System_Config__c jiraSysteminfo = new JIRA_System_Config__c();
        jiraSysteminfo.Name = 'JIRA_Sandbox';
        jiraSysteminfo.End_Point_URL__c = 'http://jira.com';
        jiraSysteminfo.Password__c = 'yourJIRApassword';
        jiraSysteminfo.User_Name__c = 'yourJIRAusername';
        jiraSysteminfo.System_Id__c = '1';
        lstJIRASys.add(jiraSysteminfo);
        
        JIRA_System_Config__c jiraSysteminfo1 = new JIRA_System_Config__c();
        jiraSysteminfo1.Name = 'JIRA_Production';
        jiraSysteminfo1.End_Point_URL__c = 'http://jira.com';
        jiraSysteminfo1.Password__c = 'yourJIRApassword';
        jiraSysteminfo1.User_Name__c = 'yourJIRAusername';
        jiraSysteminfo1.System_Id__c = '1';
        lstJIRASys.add(jiraSysteminfo1);
        
        insert lstJIRASys;
        
        //thisUser = [select Id from User where Id = :UserInfo.getUserId()];
        
        acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
            BillingCountry = 'India',BillingCity = 'Pune',BillingStreet = 'A-202', Phone = '(408) 481-6246' );
        insert acct;
        
        ct = new Contact();
        ct.LastName = 'Test last name';
        ct.AccountId = acct.Id;
        ct.Phone = '(408) 481-6246';
        ct.Preferred_Language__c = 'American English';
        ct.Email = 'test@gmail.com';
        ct.MailingStreet='test1';
        ct.Mailingcity='testcity';
        ct.MailingState='teststate';
        ct.MailingPostalCode ='12345';
        ct.MailingCountry = 'India';
        insert ct;
        
        List<Case> lstCases = new List<Case>();
        pcs = new Case();
        pcs.AccountId = acct.Id;
        pcs.ContactId = ct.Id; 
        pcs.Status = 'New';
        pcs.Application__c = 'Space Scheduling';
        pcs.SPR__c = 'PO-1';
        pcs.Description = 'Test Desc';
        pcs.Subject = 'Subject testing11111';
        pcs.Functional_Area__c = 'Touch Screen Integration';
        pcs.Version_Found_In__c = '1.10';
        pcs.Priority = 'HIGH';
        pcs.Status = 'Open';
        pcs.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('RE&WS - Support').getRecordTypeId();        
        lstCases.add(pcs);
        
        pcs1 = new Case();
        pcs1.AccountId = acct.Id;
        pcs1.ContactId = ct.Id; 
        pcs1.Status = 'New';
        pcs1.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('RE&WS - Support').getRecordTypeId();        
        lstCases.add(pcs1);
        
        pcs2 = new Case();
        pcs2.AccountId = acct.Id;
        pcs2.ContactId = ct.Id; 
        pcs2.Status = 'New';
        pcs2.Application__c = 'Manhattan';
        pcs2.SPR__c = 'PO-1';
        pcs2.Description = 'Test Desc';
        pcs2.Subject = 'Subject testing11111';
        pcs2.Functional_Area__c = 'Touch Screen Integration';
        pcs2.Version_Found_In__c = '1.10';
        pcs2.Priority = 'HIGH';
        pcs2.Status = 'Open';
        pcs2.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('RE&WS - Support').getRecordTypeId();        
        lstCases.add(pcs2);
        insert lstCases;

        apiUser = new User(ProfileId = prf.Id,Username = System.now().millisecond() + 'test2@test.com',
                Alias = 'Test', Email='test@test.com',EmailEncodingKey='UTF-8', Firstname='Test-1',Lastname='Suite-1',LanguageLocaleKey='en_US',
                LocaleSidKey='en_US',TimeZoneSidKey='America/Chicago',Country='India');
        
        System.runAs(apiUser){
            ent = new Entitlement(name='Test', AccountId=acct.Id,supported_Product_Family_Roll_up__c='CAD Software');
            insert ent;
        }
    }
    
    // Tests Sync JIRA Issue from SFDC
    static testMethod void JIRASycnOnCaseUpdate_Test1() {
        system.Test.startTest();
        setUpData();
        system.ApexPages.currentPage().getParameters().put('id', pcs.Id);
        system.ApexPages.currentPage().getParameters().put('objType', 'Case');
        system.ApexPages.currentPage().getParameters().put('pKey', 'SFC');
        system.ApexPages.currentPage().getParameters().put('iType', '8');
        
        List<Case> lstNewCs = [SELECT Id, Record_Type_Name__c, SPR__c, Application__c, Description, Subject, Functional_Area__c, Account_Name__c, Version_Found_In__c, Priority, Status, Epic_Link__c FROM Case WHERE id =: pcs.Id limit 1];
        
        pcs.Status = 'Watch';
        Map<Id, Case> mapOldCS = new Map<Id, Case>();
        mapOldCs.put(pcs.Id, pcs);
        
        system.debug('pcs ===>'+lstNewCs);
        system.debug('mapOldCS ===>'+mapOldCS);
        system.debug('pcs ===>'+pcs.RecordType.Name);
        system.debug('pcs ===>'+pcs.Record_Type_Name__c);
        system.Test.setMock(HttpCalloutMock.class, new MockHttpResponseFetchJIRAIssue());
        JIRASycnOnCaseUpdate.updateJIRATicket(lstNewCs, mapOldCs);
        
        system.Test.stopTest();
    }

    // Tests Sync JIRA Issue from SFDC
    static testMethod void JIRASycnOnCaseUpdate_Test2() {
        system.Test.startTest();
        setUpData();
        system.ApexPages.currentPage().getParameters().put('id', pcs2.Id);
        system.ApexPages.currentPage().getParameters().put('objType', 'Case');
        system.ApexPages.currentPage().getParameters().put('pKey', 'SFC');
        system.ApexPages.currentPage().getParameters().put('iType', '8');
        
        List<Case> lstNewCs = [SELECT Id, Record_Type_Name__c, SPR__c, Application__c, Description, Subject, Functional_Area__c, Account_Name__c, Version_Found_In__c, Priority, Status, Epic_Link__c FROM Case WHERE id =: pcs2.Id limit 1];
        
        pcs2.Status = 'Watch';
        Map<Id, Case> mapOldCS = new Map<Id, Case>();
        mapOldCs.put(pcs2.Id, pcs2);
        
        system.debug('pcs2 ===>'+lstNewCs);
        system.debug('mapOldCS ===>'+mapOldCS);
        system.debug('pcs2 ===>'+pcs2.RecordType.Name);
        system.debug('pcs2 ===>'+pcs2.Record_Type_Name__c);
        system.Test.setMock(HttpCalloutMock.class, new MockHttpResponseFetchJIRAIssue());
        JIRASycnOnCaseUpdate.updateJIRATicket(lstNewCs, mapOldCs);
        
        system.Test.stopTest();
    }
}