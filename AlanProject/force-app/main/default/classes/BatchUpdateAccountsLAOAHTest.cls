/*
Class Name:  BatchUpdateAccountsLAOAHTest
Description:  To do unit test class BatchUpdateAccountsLastActivityOwnerAH
Author: Chandrakanth Malayathi
CreatedDate:  January 29, 2018
*/
@isTest(SeeAllData=true)
public class BatchUpdateAccountsLAOAHTest {
    static testMethod void BatchUpdateAccountsLAOAHTestV1() {
        List<Account> accList = [select Id, Name, Last_Activity_Owner__c, (select Id, WhatId, AccountId, ActivityDate, Status, OwnerId, isTask from ActivityHistories where ActivityDate <> null order by ActivityDate DESC) from Account where Account_Division__c Includes ('MEP') AND (Last_Activity_Owner__c = null OR Last_Activity_Owner__c = '')];
        
        system.debug('--accAcctIds--'+accList);
		Test.startTest();        
            Database.QueryLocator QL;
            Database.BatchableContext BC;
            List<Account> AcctList = new List<Account>();
            BatchUpdateAccountsLastActivityOwnerAH buao = new BatchUpdateAccountsLastActivityOwnerAH();
            QL = buao.start(bc);
            
            Database.QueryLocatorIterator QIT =  QL.iterator();
            while (QIT.hasNext())
            {
                Account Acc = (Account)QIT.next();            
                System.debug(Acc);
                AcctList.add(Acc);
            }        
            
            buao.execute(BC, accList);
            buao.finish(BC);
        Test.stopTest();
    }
}