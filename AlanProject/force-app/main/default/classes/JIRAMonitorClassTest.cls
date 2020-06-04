/*****************************************************************************************
Name    : JIRAMonitorClassTest 
Modification Log : 
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
Suresh Babu       	03/28/2017          Created
******************************************************************************************/
@isTest
private class JIRAMonitorClassTest {
	static void setUpData(){
		JIRATestData_Generate.createCustomSettingRecords();
		JIRATestData_Generate.createAccount();
		JIRATestData_Generate.createContact();
		JIRATestData_Generate.createCases();
		JIRATestData_Generate.createDevelopments();
	}

	// Tests Create JIRA Issue from SFDC
	static testMethod void JIRAMonitorClassTest1() {
		system.Test.startTest();
		setUpData();
		
		system.Test.setMock(HttpCalloutMock.class, new MockHttpResponseFetchJIRAIssue());
		JIRAMonitorClass sh1 = new JIRAMonitorClass();      
		String sch = '0 0 23 * * ?';
		system.schedule('Test check', sch, sh1);
		
		system.Test.stopTest();
	}

	static testMethod void JIRACredentialValidationTest(){
		Test.startTest();
		setUpData();
		JIRAMonitorClass.recipientAddress = new List<String>();
		JIRAMonitorClass.recipientAddress.add('testmail@tst.com');

		JIRAMonitorClass.expectedCode = 200;
		JIRAMonitorClass.JIRACredentialValidation(JIRATextFixture.jIssueKey, JIRATextFixture.objectId, JIRATextFixture.objectType);
		
		JIRAMonitorClass.expectedCode = 401;
		JIRAMonitorClass.JIRACredentialValidation(JIRATextFixture.jIssueKey, JIRATextFixture.objectId, JIRATextFixture.objectType);

		JIRAMonitorClass.expectedCode = 404;
		JIRAMonitorClass.JIRACredentialValidation(JIRATextFixture.jIssueKey, JIRATextFixture.objectId, JIRATextFixture.objectType);
		
		JIRAMonitorClass.expectedCode = 501;
		JIRAMonitorClass.JIRACredentialValidation(JIRATextFixture.jIssueKey, JIRATextFixture.objectId, JIRATextFixture.objectType);
		
		Test.stopTest();
	}
	
	static testMethod void JIRAIssueValidationTest(){
		Test.startTest();
		setUpData();
		JIRAMonitorClass.recipientAddress = new List<String>();
		JIRAMonitorClass.recipientAddress.add('testmail@tst.com');

		JIRAMonitorClass.expectedCode = 200;
		JIRAMonitorClass.JIRAIssueValidation(JIRATextFixture.jIssueKey, JIRATextFixture.objectId, JIRATextFixture.objectType, JIRATextFixture.bAuth);

		JIRAMonitorClass.expectedCode = 404;
		JIRAMonitorClass.JIRAIssueValidation(JIRATextFixture.jIssueKey, JIRATextFixture.objectId, JIRATextFixture.objectType, JIRATextFixture.bAuth);

		JIRAMonitorClass.expectedCode = 501;
		JIRAMonitorClass.JIRAIssueValidation(JIRATextFixture.jIssueKey, JIRATextFixture.objectId, JIRATextFixture.objectType, JIRATextFixture.bAuth);

		Test.stopTest();
	}

	static testMethod void JIRASyncValidationTest(){
		Test.startTest();
		setUpData();
		JIRAMonitorClass.recipientAddress = new List<String>();
		JIRAMonitorClass.recipientAddress.add('testmail@tst.com');

		JIRAMonitorClass.expectedCode = 200;
		JIRAMonitorClass.JIRASyncValidation(JIRATextFixture.jIssueKey, JIRATextFixture.objectId, JIRATextFixture.objectType, JIRATextFixture.bAuth);
		
		JIRAMonitorClass.expectedCode = 500;
		JIRAMonitorClass.JIRASyncValidation(JIRATextFixture.jIssueKey, JIRATextFixture.objectId, JIRATextFixture.objectType, JIRATextFixture.bAuth);
		
		JIRAMonitorClass.expectedCode = 501;
		JIRAMonitorClass.JIRASyncValidation(JIRATextFixture.jIssueKey, JIRATextFixture.objectId, JIRATextFixture.objectType, JIRATextFixture.bAuth);
		
		Test.stopTest();
	}

    static testMethod void JIRATransitionValidationTest() {
    	system.Test.startTest();
        setUpData();
        JIRAMonitorClass.recipientAddress = new List<String>();
		JIRAMonitorClass.recipientAddress.add('testmail@tst.com');

        JIRAMonitorClass.expectedCode = 200;
        JIRAMonitorClass.JIRATransitionValidation(JIRATextFixture.jIssueKey, JIRATextFixture.objectId, JIRATextFixture.objectType);

        JIRAMonitorClass.expectedCode = 400;
        JIRAMonitorClass.JIRATransitionValidation(JIRATextFixture.jIssueKey, JIRATextFixture.objectId, JIRATextFixture.objectType);
        system.Test.stopTest();
    }
}