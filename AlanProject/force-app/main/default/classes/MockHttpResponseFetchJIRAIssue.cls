/*****************************************************************************************
Name        : MockHttpResponseFetchJIRAIssue 
Description : Mock test class for JIRA ticket creating from SFDC 
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
Suresh Babu         29/Sep/2016          Created
******************************************************************************************/
@isTest global class MockHttpResponseFetchJIRAIssue implements HttpCalloutMock {
    // Mocks respond method for testing in JIRAFetchIssuesControllerTest.
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setBody(JIRATextFixture.jiraFetchResponseBody);
        return res;
    }
}