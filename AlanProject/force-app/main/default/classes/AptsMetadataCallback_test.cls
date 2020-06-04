@isTest 
 private class AptsMetadataCallback_test
 {
    static testMethod void getSObjectTypeTest()
    {      
        String sObjectName1 = 'ClassificationHierarchy__c';
        String sObjectName2 = 'Apttus_Config2__ClassificationHierarchy__c';
    
        Test.StartTest();
        AptsMetadataCallback MDCB = new AptsMetadataCallback();
        Map<String, Schema.SObjectType> typeMap;
        MDCB.getSObjectType(sObjectName1);
        MDCB.getSObjectType(sObjectName2);
        MDCB.getSObjectType('Account');
        Test.StopTest();
    }
 }