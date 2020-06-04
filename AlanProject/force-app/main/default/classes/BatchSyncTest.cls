@isTest
private class BatchSyncTest{
    
    private static List<Failed_Callout_Accounts__c> recordList = new List<Failed_Callout_Accounts__c>();      
    private static User thisUser ;
    private static Account acct ;
    private static Country_Region_Mapping__c cust;
    private static Geospatial_Country_Region_Mapping__c custRegMap ;
    private static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId(); 
    
    static void setUpData(){
        
        cust = new Country_Region_Mapping__c(name='India',Region__c='India');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='India',Region__c='India');
        insert custRegMap;  
        
        thisUser = [select Id from User where Id = :UserInfo.getUserId()];
        
        acct = new Account(Name = 'Test',RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
            BillingCountry = 'India',BillingCity = 'Pune',BillingStreet = 'A-202',OwnerId = thisUser.Id ,FCH_Party_ID__c= '100',Phone='111-111-1111',BillingState='Goa',
            BillingPostalCode ='343220',Lifecycle_Stage__c='Customer',Site_Name__c='test',Address1__c='Test',Address2__c='Test',
            Address3__c='Test',Address4__c='Test',Account_Forecast_Owner__c=thisUser.Id);
        insert acct;

        Failed_Callout_Accounts__c failedAcc = new Failed_Callout_Accounts__c(Name='Test',CurrencyIsoCode='USD',Account_id__c=acct.Id);
        recordList.add(failedAcc);

        insert recordList;
        
    }
    
    static testmethod void testBatchSync() {
       
       String query = 'Select ID,Name,Account_id__c from Failed_Callout_Accounts__c Limit 1';

       setUpData();    
       Test.startTest();       
           BatchSync bch = new BatchSync();
           bch.query = query;
           Database.executeBatch(bch,1);
           
           Integer i = [SELECT COUNT() FROM Failed_Callout_Accounts__c];
           System.assertEquals(i, 1);
       Test.stopTest();
    }
}