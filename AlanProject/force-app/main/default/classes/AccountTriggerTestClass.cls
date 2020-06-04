/************************************************************************************
* Name          :    AccountTriggerTestClass
* Description   :    
* Author        :    Sagar

Modification Log
----------------
Date             Developer                Comments
------------------------------------------------------------------------------------------
                   Sagar                  Created
******************************************************************************************/
@isTest
public class AccountTriggerTestClass {
    private static MEPEuropeSalesRegion_del_del__c franceCode;
    private static Paris_Region_Mapping__c parisCode;
    private static List<Country_Region_Mapping__c> custList;
    private static List<Geospatial_Country_Region_Mapping__c> custRegMapList ;    
    private static Profile prf = [Select Id from Profile where Name =: Label.API_Only];
    private static User apiUser;
    private static User thisUser;
    private static Account acct;
    private static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Customer) Record Type').getRecordTypeId();
    private static Integer count=100;
    
    static void setUpData(){
        franceCode = new MEPEuropeSalesRegion_del_del__c(Name='France12345',Country__c='France',MEP_Europe_Sales_Region__c='test',Zip__c = '7566555');
        insert franceCode;
        
        parisCode = new Paris_Region_Mapping__c(Name='Paris12343',Country__c = 'France',Zip_Postal_Code__c = '75342433');
        insert parisCode;
        
        custList = new List<Country_Region_Mapping__c>();
        custList.add(new Country_Region_Mapping__c(name='India',Region__c='India'));
        custList.add(new Country_Region_Mapping__c(name='France',Region__c='France'));
        insert custList;
        
        custRegMapList = new List<Geospatial_Country_Region_Mapping__c>();
        custRegMapList.add(new Geospatial_Country_Region_Mapping__c(name='India',Region__c='India'));
        custRegMapList.add(new Geospatial_Country_Region_Mapping__c(name='France',Region__c='France'));
        insert custRegMapList;
        
        
        
        thisUser = [ select Id from User where Id = :UserInfo.getUserId()];
        
        apiUser = new User(ProfileId = prf.Id,Username = System.now().millisecond()+ Math.random() + 'test2@test.com',
                Alias = 'Test', Email='test@test.com',EmailEncodingKey='UTF-8', Firstname='Test',Lastname='Suite',LanguageLocaleKey='en_US',
                LocaleSidKey='en_US',TimeZoneSidKey='America/Chicago',Country='India');
       
        
    }
    
     /**
     * Method name  : testAfterMethod
     * Description  : This method covers the positive scenarios of account trigger
     * Return Type  : void
     * Parameter    : None
     **/
    static testMethod void testAfterMethod() {
        
        setUpData();    
        Test.startTest();
        
        Profile profile = [select Id from Profile where Name =: 'System Administrator'];        
        
        User user = new User();
        user.Username = 'sagamehta123@deloitte.com';
        user.Email = 'sagamehta@deloitte.com';
        user.LastName = 'Test';
        user.Alias = 'Test123';
        user.ProfileID = profile.Id;
        user.LocaleSidKey = 'en_US';
        user.LanguageLocaleKey = 'en_US';
        user.Country = 'India';
        user.TimeZoneSidKey = 'America/Los_Angeles';
        user.EmailEncodingKey='UTF-8';
        insert user;
        
        System.runAs(user) {
        
            Schema.SObjectType targetType = Schema.getGlobalDescribe().get('Account');
            Account a = (Account)targetType.newSObject();
            
            Map<String, Id> recordTypeMap = RecursiveTriggerUtility.loadRecordTypeMap(a.getSobjectType());
            
            Country_Region_Mapping__c countryMap = new Country_Region_Mapping__c();
            countryMap.Name = 'ABC';
            countryMap.Region__c = 'XYZ';
            insert countryMap; 
            
            Geospatial_Country_Region_Mapping__c geoCountryMap = new Geospatial_Country_Region_Mapping__c();
            geoCountryMap.Name = 'ABC';
            geoCountryMap.Region__c = 'XYZ';
            insert geoCountryMap;
                           
            Account account = new Account();
            account.Name = 'Test Assign Case Account';
            account.RecordTypeId = recordTypeMap.get(Label.Account_Pending_Record_Type);
            account.Account_Forecast_Owner__c = user.Id;
            account.Account_Status__c = 'Pending';
            account.Requested_Account_Record_Type__c = 'Association';
            account.BillingCountry = 'India';
            account.BillingCity = 'Pune';
            account.BillingStreet = 'A-202';
            account.Lifecycle_Stage__c='Customer';
            account.Account_Status__c = 'Active';
            account.currencyisocode ='USD';
            insert account;
            
            Forecast_Year__c fy = new Forecast_Year__c();
            //fy.Name = 'Test Account';
            fy.Account__c = account.Id;
            insert fy;
            
            System.assert(fy.Account__c == account.Id);
            
            Forecast_Qua__c qua = new Forecast_Qua__c (); 
            qua.FQ__c = 'Q1';
            qua.Forecast_Year__c = fy.Id;
            insert qua;
            
            System.assert(qua.Forecast_Year__c == fy.Id);
            
            Forecast_Week__c  week = new Forecast_Week__c ();
            week.Forecast_Quarter__c = qua.Id;        
            week.Week_Index__c = 1;
            week.Actual__c = 100;       
            insert week;
            
            System.assert(week.Forecast_Quarter__c == qua.Id);
            RecursiveTriggerUtility.isAccountRecursive = true;
            account.currencyisocode ='GBP';
            update account;
            
           /* System.assert(account.CurrencyIsoCode == fy.CurrencyIsoCode);
            System.assert(account.CurrencyIsoCode == qua.CurrencyIsoCode);
            System.assert(account.CurrencyIsoCode == week.CurrencyIsoCode);*/
            
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setComments('Approving request using Trigger');
            req.setAction('Approve');
            //req.setNextApproverIds(new Id[] {opp.Next_Approver__c});
            Id retVal = null;
    
            for(ProcessInstanceWorkitem workItem  : [Select p.Id from ProcessInstanceWorkitem p where p.ProcessInstance.TargetObjectId =: account.Id]){
                retVal = workItem.Id;
            }
            
            Id workItemId = retVal;
            //opp.addError(workItemId);
            if(workItemId == null){
                account.addError('Error Occured in Trigger');
            }else{
                req.setWorkitemId(workItemId);
                Approval.ProcessResult result =  Approval.process(req);
            }
        }    
        Test.stopTest();
    }
    
    static testMethod void testAccountUpdate00() {
        setUpData();
        Test.startTest();
            System.runAs(apiUser) {                      
        
                acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
                    BillingCountry = 'India',BillingCity = 'Pune',BillingStreet = 'A-202',OwnerId = thisUser.Id , Address1__c='Test-1',Address2__c='Test-2',
                    Address3__c='Test-3',Address4__c='Test-4');
                insert acct;        
        Account acctMerg;
         acctMerg = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
                    BillingCountry = 'India',BillingCity = 'Pune',BillingStreet = 'A-202',OwnerId = thisUser.Id , Address1__c='Test-1',Address2__c='Test-2',
                    Address3__c='Test-3',Address4__c='Test-4');
                insert acctMerg;        
        
                RecursiveTriggerUtility.isAccountRecursive = true;
                update acct;
                
                Database.Merge(acct,acctMerg,false);
            }
        
        Test.stopTest();
    
    }
    
    static testMethod void testAccountUpdate01() {
        setUpData();
        Test.startTest();
            acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
                    BillingCountry = 'India',BillingCity = 'Pune',BillingStreet = 'Test-1\r\nTest-2\r\nTest-3',OwnerId = thisUser.Id , Address1__c='Test-1',Address2__c='Test-2',
                    Address3__c='Test-3',Address4__c='Test-4');
            insert acct;        
        
            RecursiveTriggerUtility.isAccountRecursive = true;
            update acct;
        
        Test.stopTest();
    
    }
    
    static testMethod void testAccountUpdate02() {
        
        Test.startTest();
        Id prfId = [select ID from Profile where Name =: Label.API_Only].Id;
        String uniqueUserName = 'Admin' + DateTime.now().getTime() + '@testorg.com';
        User u = new User(Alias = 'ur1234', Email=uniqueUserName,
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = prfId,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName , Division__c = 'TAP');
        
        System.runAs(u){
            setUpData();
            acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
                    BillingCountry = Label.Democratic_Republic_Lao_People,BillingCity = 'Pune',BillingStreet = 'Test-1\r\nTest-2\r\nTest-3',OwnerId = thisUser.Id , Address1__c='Test-1',Address2__c='Test-2',
                    Address3__c='Test-3',Address4__c='Test-4');
            insert acct;   
        }
        Test.stopTest();
    
    }
    
    static testMethod void testAccountUpdate03() {
        setUpData();
        Test.startTest();
            acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
                    BillingCountry = 'France',BillingCity = 'Pune',BillingStreet = 'Test-1\r\nTest-2\r\nTest-3',BillingPostalCode='2345',OwnerId = thisUser.Id , Address1__c='Test-1',Address2__c='Test-2',
                    Address3__c='Test-3',Address4__c='Test-4');
            insert acct;   
        Test.stopTest();
    
    }
    
    static testMethod void testAccountUpdate04() {
        setUpData();
        Test.startTest();
            acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,Account_Status__c = 'Active',Requested_Account_Record_Type__c = 'Customer',
                    BillingCountry = 'France',Lifecycle_Stage__c='Customer',BillingCity = 'Pune',BillingStreet = 'Test-1\r\nTest-2\r\nTest-3',BillingPostalCode='752345',OwnerId = thisUser.Id , Address1__c='Test-1',Address2__c='Test-2',
                    Address3__c='Test-3',Address4__c='Test-4');
            insert acct;   
        
        Test.stopTest();
    
    }
    
    static testMethod void testAccountUpdate05() {
        String profileName = Label.Restrict_Callout_Profile + '%';
        Id prfId = [select ID from Profile where Name like: profileName limit 1].Id;
        String uniqueUserName = 'Admin' + DateTime.now().getTime() + '@testorg.com';
        User u = new User(Alias = 'ur1234', Email=uniqueUserName,
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = prfId,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName , Division__c = 'TAP');
        
        System.runAs(u){
            setUpData();
            Test.startTest();
            acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,Account_Status__c = 'Active',Requested_Account_Record_Type__c = 'Customer',
                               BillingCountry = 'France',Lifecycle_Stage__c='Customer',BillingCity = 'Pune',BillingStreet = 'Test-1\r\nTest-2\r\nTest-3',BillingPostalCode='752345',OwnerId = thisUser.Id , Address1__c='Test-1',Address2__c='Test-2',
                               Address3__c='Test-3',Address4__c='Test-4');
            insert acct;   
            
            RecursiveTriggerUtility.isAccountRecursive = true;
            delete acct;
            Test.stopTest();
        }
    }
}