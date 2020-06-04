/*****************************************************************************************
Name        : JIRAUpdateStatusCustomSettingRecordsTest 
Description : Mock test class for JIRA ticket creating from SFDC 
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
Suresh Babu         16/Dec/2016          Created
******************************************************************************************/
@isTest private class JIRAUpdateStatusCustomSettingRecordsTest {
	static void setUpData(){
        JIRATestData_Generate.createCustomSettingRecords();
    }
    
    static testMethod void JIRAUpdateStatusCustomSettingRecordsTest1() {
    	system.Test.startTest();
        setUpData();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseJIRAStatusUpdate());
        JIRAUpdateStatusCustomSettingRecords.retrieveJIRAStatus('SFUST-23');
        
        JIRAUpdateStatusCustomSettingRecords.build_TransitionRequest(JIRATextFixture.baseUrl, JIRATextFixture.username, JIRATextFixture.password, 'SFUST-23');
        system.Test.stopTest();
    }
}