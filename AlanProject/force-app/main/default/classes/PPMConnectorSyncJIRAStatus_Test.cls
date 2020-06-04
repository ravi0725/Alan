/*****************************************************************************************
Name        : PPMConnectorSyncJIRAStatus_Test 
Description : Test class for PPM JIRA 
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
Suresh Babu         17/Dec/2018          Created
******************************************************************************************/
@isTest
private class PPMConnectorSyncJIRAStatus_Test {
	static void setUpData(){
        JIRATestData_Generate.createCustomSettingRecords();
        JIRATestData_Generate.createAccount();
        JIRATestData_Generate.createContact();
        JIRATestData_Generate.createCases();
        JIRATestData_Generate.createDevelopments();
        JIRATestData_Generate.createAttachments();
        JIRATestData_Generate.createNotes();
    }

	@isTest static void PPMConnectorSyncJIRAStatus_Test1() {
		setUpData();

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseJIRAConnector());
		PPMConnectorSyncJIRAStatus.updateJIRAStatus('PL-12', 'ProjectSight Web');
		Test.stopTest();
	}
	
	@isTest static void PPMConnectorSyncJIRAStatus_Test2() {
		setUpData();

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseJIRAConnector());
		PPMConnectorSyncJIRAStatus.updateJIRAComponent('PL-12', 'ProjectSight Web', 'Drawings');
		Test.stopTest();
	}

	@isTest static void PPMConnectorSyncJIRAStatus_Test3() {
		setUpData();

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseJIRAConnector());
		JIRATestData_Generate.PPMcs1.Status = 'Returned';
		update JIRATestData_Generate.PPMcs1;

		Test.stopTest();
	}
}