@isTest(SeeAllData=true)
private class TestBatchImportDataMakeCallout {
	static testmethod void test() {
       GenerateTestData.createAccount();
       GenerateTestData.createAddress();
	   GenerateTestData.createAddressImportData();
       Map<String, String> calloutMap = new Map<String, String>();
       calloutMap.put(String.valueOf(GenerateTestData.acct.Id), String.valueOf(GenerateTestData.adrs.Id));
       system.debug('---calloutMap-Test----'+calloutMap);
       set<String> idset = new set<String>{GenerateTestData.adrs.Id};
       Import_Data__c imp = GenerateTestData.idcAdrs;
       GenerateTestData.importDataAdrsAttachment();
        
       Test.startTest();
           BatchImportDataMakeCallout bidmc = new BatchImportDataMakeCallout(calloutMap, idset, imp, 0, 0, GenerateTestData.impDtAdrsAttach.Id);
           Database.executeBatch(bidmc, imp.Batch_Size_Callout__c.intValue());
       Test.stopTest();
    }
    
    static testmethod void test2() {
       GenerateTestData.createAccount();
       GenerateTestData.createContact();
	   GenerateTestData.createContactImportData();
       Map<String, String> calloutMap = new Map<String, String>();
       calloutMap.put(String.valueOf(GenerateTestData.acct.Id), String.valueOf(GenerateTestData.ct.Id));
       system.debug('---calloutMap-Test----'+calloutMap);
       set<String> idset = new set<String>{GenerateTestData.ct.Id};
       Import_Data__c imp = GenerateTestData.idcnt;
       GenerateTestData.importDataCntAttachment();
        
       Test.startTest();
           BatchImportDataMakeCallout bidmc = new BatchImportDataMakeCallout(calloutMap, idset, imp, 0, 0, GenerateTestData.impDtCntAttach.Id);
           Database.executeBatch(bidmc, imp.Batch_Size_Callout__c.intValue());
       Test.stopTest();
    }
}