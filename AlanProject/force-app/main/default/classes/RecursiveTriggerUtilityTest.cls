/*
*****************************************************************************************
    Name        : RecursiveTriggerUtilityTest
                            
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
 Suresh Babu Murugan    04/Nov/2015          Created
*****************************************************************************************
*/

@isTest
private class RecursiveTriggerUtilityTest{
    
    static testmethod void RecursiveTriggerUtilityTest1(){
        system.Test.startTest();
        
        RecursiveTriggerUtility rUtility = new RecursiveTriggerUtility();
        
        system.Test.stopTest();
    }
}