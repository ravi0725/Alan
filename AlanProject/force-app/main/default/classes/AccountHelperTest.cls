/*
*****************************************************************************************
    Name        : AccountHelperTest 
                            
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
 P M Mamata           20/07/2015          Created
*****************************************************************************************
*/

@isTest(seeAllData=true)
private class AccountHelperTest {
    static testmethod void accountHelperMeth(){
        List<Account> acList = new List<Account>();
        AccountHelper ah = new AccountHelper();
        GenerateTestData.createAccount();        
        acList.add(GenerateTestData.acct);
        GenerateTestData.createAccount();        
        acList.add(GenerateTestData.acct);
        GenerateTestData.createAccount();        
        acList.add(GenerateTestData.acct);
        GenerateTestData.createAccount();        
        acList.add(GenerateTestData.acct);
        AccountHelper.createAddress(GenerateTestData.acct);
        AccountHelper.CreateAddressRdFromBillToAddress(acList);
    }
    
    static testmethod void accountHelper_UpdateAddress(){
        Map<Id, Account> newAccMap = new Map<Id, Account>();
        Map<Id, Account> oldAccMap = new Map<Id, Account>();
        Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
        Account acct = new Account();
        acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
            BillingCountry = 'India',BillingCity = 'Pune',BillingStreet = 'A-202',OwnerId = UserInfo.getUserId() ,FCH_Party_ID__c='100',Phone='111-111-1111',BillingState='Goa',
            BillingPostalCode ='343220',Lifecycle_Stage__c='Customer',Site_Name__c='test',Account_Forecast_Owner__c=UserInfo.getUserId());
        insert acct;

        oldAccMap.put(acct.Id, acct);
        
        Account newAcc = new Account(Id=acct.Id, Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,CurrencyIsoCode = 'USD',Payment_Term__c = 'CASH IN ADVANCE', Account_Status__c = 'Active',Requested_Account_Record_Type__c = 'Customer',
            BillingCountry = 'United States',Restricted_Entity__c = Label.Not_Restricted,Annual_Support_Date__c = date.today(), BillingCity = 'Chennai',BillingState = 'BillingState', BillingPostalCode = 'postal code',BillingStreet = 'A-203',Collector_Email__c = 'test@gmail.com', Lifecycle_Stage__c = 'Customer');
        newAccMap.put(newAcc.Id, newAcc);
        system.Test.startTest();
            AccountHelper.updateAddressFromBillToAddress(newAccMap, oldAccMap);
            
            List<Account> lstOLDAccs = new List<Account>();
            lstOLDAccs.add(acct);
            AccountHelper.getmergeData(lstOLDAccs);
            AccountHelper.getRelatedRecords(acct);
        	AccountHelper.setLaunchControl();
        	AccountHelper.validateAccountExternalKeyValue(new List<Account>{acct},new Map<Id,Account>{acct.Id=>acct});
            AccountHelper.accountMerge(new Map<Id,Account>{acct.Id=>acct});
        	AccountHelper.resetLaunchControl();
            AccountHelper.SendEmailOnCreditCheck(acct.Id);
        system.Test.stopTest();
    }
}