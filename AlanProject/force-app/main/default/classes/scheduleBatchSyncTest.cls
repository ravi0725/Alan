@isTest(seeAllData=true)
private class scheduleBatchSyncTest{
    
    static testmethod void testschedule() {
    	GenerateTestData.createAccount();
        GenerateTestData.createAddress();
        GenerateTestData.createContact();
        System.currentPageReference().getParameters().put('Id', GenerateTestData.acc.Id);
        Test.startTest();
        scheduleBatchSync scheduleJob = new scheduleBatchSync(); 
        String CRON_EXP = '0 0 0 15 3 ? 2022';
        System.schedule(String.valueOf(system.now()),CRON_EXP,scheduleJob);
        Test.stopTest();
    }
}