/*
*****************************************************************************************
    Name        : AddressTriggerHandlerTest
                            
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
 Suresh Babu Murugan    04/Nov/2015          Created
*****************************************************************************************
*/

@isTest(SeeAllData = true)
private class AddressTriggerHandlerTest{
    static testmethod void AddressTriggerHandlerTest_1(){
        Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
        Account acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
            BillingCountry = 'India',BillingCity = 'Pune',BillingStreet = 'A-202',OwnerId = UserInfo.getUserId() ,FCH_Party_ID__c='100',Phone='111-111-1111',BillingState='Goa',
            BillingPostalCode ='343220',Lifecycle_Stage__c='Customer',Site_Name__c='test',Account_Forecast_Owner__c=UserInfo.getUserId());
        insert acct;

        
        List<Address__c> lstAddresses = [SELECT
                                        Id, Name, Address_line1__c, Address_line2__c, Address_line3__c, Address_line4__c, City__c,
                                        Country__c, County__c, State__c, Zip__c, Account__c, Primary__c
                                        FROM 
                                        Address__c 
                                        WHERE 
                                        Primary__c = true AND 
                                        Account__c = : acct.Id ORDER BY Name];
        system.Test.startTest();
            Address__c adr = lstAddresses[0];
            adr.Zip__c = '343221';
            RecursiveTriggerUtility.isAddressRecursive = true;
            update adr;
        system.Test.stopTest();
    }
}