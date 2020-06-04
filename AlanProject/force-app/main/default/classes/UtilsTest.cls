/*****************************************************************************************
Name    : UtilsTest 
Modification Log : 
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
P M Mamata       28/08/2015          Created
******************************************************************************************/
@isTest(seealldata=true)
private class UtilsTest {
    static testmethod void meth1(){
        Utils ut = new Utils();
        Utils.getCreatableFieldsSOQL('Account','Name != null');
        Account acc = [select Id from Account limit 1];
        Map<Id,Account> newMap = new Map<Id,Account>();
        Map<Id,Account> oldMap = new Map<Id,Account>();
        newMap.put(acc.Id,acc);
        acc.Name = 'India34234234234';
        acc.Email__c = 'test@gmail.com';
        oldMap.put(acc.Id,acc);
        Utils.verifyFieldUpdate(newMap,oldMap,'Account','FCH Integration','FCHAccount');
    }
}