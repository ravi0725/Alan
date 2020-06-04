/*****************************************************************************************
Name        : JIRAConnectorWebserviceCalloutCreateTest 
Description : Mock test class for JIRA ticket creating from SFDC 
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
Suresh Babu         29/Sep/2016          Created
******************************************************************************************/
@isTest
public class JIRAConnectorWebserviceCalloutCreateTest {
    static void setUpData(){
        JIRATestData_Generate.createCustomSettingRecords();
        JIRATestData_Generate.createAccount();
        JIRATestData_Generate.createContact();
        JIRATestData_Generate.createCases();
        JIRATestData_Generate.createDevelopments();
    }
    
    // Tests createIssue method in JIRAConnectorWebserviceCalloutCreate.
    static testMethod void createIssueTest_Case() {
        Test.startTest();
        setUpData();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCreateJIRAIssue());
        JIRAConnectorWebserviceCalloutCreate.createIssue(JIRATextFixture.baseUrl, JIRATextFixture.systemId,
                                                         JIRATextFixture.objectType, JIRATestData_Generate.pcs.Id, JIRATextFixture.projectKey, JIRATextFixture.issueType);
        Test.stopTest();
    }
    
    // Tests createIssue method in JIRAConnectorWebserviceCalloutCreate.
    static testMethod void createIssueTest_Case1() {
        Test.startTest();
        setUpData();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCreateJIRAIssue());
        JIRAConnectorWebserviceCalloutCreate.createIssue(JIRATextFixture.baseUrl, JIRATextFixture.systemId,
                                                         JIRATextFixture.objectType, JIRATestData_Generate.pcs2.Id, JIRATextFixture.projectKey, JIRATextFixture.issueType);
        Test.stopTest();
    }

    // Tests createIssue method in JIRAConnectorWebserviceCalloutCreate.
    static testMethod void createIssueTest_Dev() {
        Test.startTest();
        setUpData();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCreateJIRAIssue());
        JIRAConnectorWebserviceCalloutCreate.createIssue(JIRATextFixture.baseUrl, JIRATextFixture.systemId,
                                                         'Development__c', JIRATestData_Generate.dev1.Id, JIRATextFixture.projectKey, JIRATextFixture.issueType);
        Test.stopTest();
    }
    
    // Tests buildRequest method in JIRAConnectorWebserviceCalloutCreate.
    static testMethod void buildRequestTest_Case() {
        setUpData();
        HttpRequest req = JIRAConnectorWebserviceCalloutCreate.buildRequest(JIRATextFixture.baseUrl, JIRATextFixture.username,
                                                                            JIRATextFixture.password, JIRATextFixture.systemId, JIRATextFixture.objectType, JIRATextFixture.objectId,
                                                                            JIRATextFixture.projectKey, JIRATextFixture.issueType);
        System.assertEquals(req.getMethod(), 'POST');
        System.assertEquals(req.getEndpoint(), 'http://jira.com/rest/customware/connector/1.0/1/Case/1/issue/create.json');
    }
    
    // Tests buildRequest method in JIRAConnectorWebserviceCalloutCreate.
    static testMethod void buildRequestTest_Dev() {
        setUpData();
        HttpRequest req = JIRAConnectorWebserviceCalloutCreate.buildRequest(JIRATextFixture.baseUrl, JIRATextFixture.username,
                                                                            JIRATextFixture.password, JIRATextFixture.systemId, 'Development__c', JIRATestData_Generate.dev1.Id,
                                                                            JIRATextFixture.projectKey, JIRATextFixture.issueType);
        System.assertEquals(req.getMethod(), 'POST');
    }
}