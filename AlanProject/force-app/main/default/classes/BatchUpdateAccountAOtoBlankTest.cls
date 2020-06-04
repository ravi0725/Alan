/*
Class Name:  BatchUpdateAccountAOtoBlankTest
Description:  To do unit test class BatchUpdateAccountActivityOwnertoBlank
Author: Chandrakanth Malayathi
CreatedDate:  February 05, 2018
*/
@isTest
public class BatchUpdateAccountAOtoBlankTest {
    private static Country_Region_Mapping__c cust;
    private static Geospatial_Country_Region_Mapping__c custRegMap ;
    private static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    
    static testMethod void BatchUpdateAccountActivityOwnerToBlankTest1() {
        cust = new Country_Region_Mapping__c(name='India',Region__c='India');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='India',Region__c='India');
        insert custRegMap;
        
        String randomValue = String.valueOf(Math.random());
        Account acct = new Account();
        acct.Name = 'Test Acc'+randomValue;
        acct.RecordTypeId = acctRecTypeId;
        acct.Account_Status__c = 'Pending';
        acct.Phone='2455657651';
        acct.Requested_Account_Record_Type__c = 'Customer';
        acct.BillingCountry = 'India';
        acct.BillingCity = 'Pune';
        acct.BillingStreet = 'A-202';
        acct.Account_Division__c = 'MEP';
        acct.Last_Activity_Owner__c = 'Chandrakanth Malayathi';
        insert acct;
        
        Test.startTest();        
            Database.QueryLocator QL;
            Database.BatchableContext BC;
            List<Account> AcctList = new List<Account>();
            BatchUpdateAccountActivityOwnerToBlank buao = new BatchUpdateAccountActivityOwnerToBlank();
            QL = buao.start(bc);
            
            Database.QueryLocatorIterator QIT =  QL.iterator();
            while (QIT.hasNext())
            {
                Account Acc = (Account)QIT.next();            
                System.debug(acct);
                AcctList.add(acct);
            }        
            
            buao.execute(BC, AcctList);
            buao.finish(BC);
        Test.stopTest();
    }
}