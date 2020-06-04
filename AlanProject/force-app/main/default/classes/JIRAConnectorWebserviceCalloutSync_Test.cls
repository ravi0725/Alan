/*****************************************************************************************
Name        : JIRAConnectorWebserviceCalloutSync_Test 
Description : Test class for JIRA ticket Sync from SFDC 
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
Suresh Babu         29/Sep/2016          Created
******************************************************************************************/
@isTest private class JIRAConnectorWebserviceCalloutSync_Test {
    static void setUpData(){
        List<JIRA_System_Config__c> lstJIRASys = new List<JIRA_System_Config__c>();
        JIRA_System_Config__c jiraSysteminfo = new JIRA_System_Config__c();
        jiraSysteminfo.Name = 'JIRA_Sandbox';
        jiraSysteminfo.End_Point_URL__c = 'http://jira.com';
        jiraSysteminfo.Password__c = 'yourJIRApassword';
        jiraSysteminfo.User_Name__c = 'yourJIRAusername';
        jiraSysteminfo.System_Id__c = '1';
        lstJIRASys.add(jiraSysteminfo);
        
        JIRA_System_Config__c jiraSysteminfo1 = new JIRA_System_Config__c();
        jiraSysteminfo1.Name = 'JIRA_Production';
        jiraSysteminfo1.End_Point_URL__c = 'http://jira.com';
        jiraSysteminfo1.Password__c = 'yourJIRApassword';
        jiraSysteminfo1.User_Name__c = 'yourJIRAusername';
        jiraSysteminfo1.System_Id__c = '1';
        lstJIRASys.add(jiraSysteminfo1);
        insert lstJIRASys;
    }
    
    // Tests createIssue method in JIRAConnectorWebserviceCalloutCreate.
    static testMethod void createIssueTest1() {
        Test.startTest();
        setUpData();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseJIRAConnector());
        JIRAConnectorWebserviceCalloutSync.synchronizeWithJIRAIssue(JIRATextFixture.baseUrl, JIRATextFixture.systemId, JIRATextFixture.objectType, JIRATextFixture.caseId);

        JIRAConnectorWebserviceCalloutSync.sleep(1000);
        Test.stopTest();
    }
    
    // Tests createIssue method in JIRAConnectorWebserviceCalloutCreate.
    static testMethod void createIssueTest2() {
        Test.startTest();
        setUpData();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseJIRAConnector());
        JIRAConnectorWebserviceCalloutSync.synchronizeWithJIRAIssueWithStatus(JIRATextFixture.baseUrl, JIRATextFixture.systemId, JIRATextFixture.objectType, JIRATextFixture.caseId, JIRATextFixture.jIssueKey, JIRATextFixture.sCode);
        Test.stopTest();
    }

    // Tests buildRequest method in JIRAConnectorWebserviceCalloutCreate.
    static testMethod void buildRequestTest() {
        setUpData();
        HttpRequest req = JIRAConnectorWebserviceCalloutSync.buildRequest(JIRATextFixture.baseUrl, JIRATextFixture.username,
                                                                          JIRATextFixture.password, JIRATextFixture.systemId, JIRATextFixture.objectType, JIRATextFixture.caseId);
        System.assertEquals(req.getMethod(), 'PUT');
        System.assertEquals(req.getEndpoint(), 'http://jira.com/rest/customware/connector/1.0/1/Case/1/issue/synchronize.json');
    }
}