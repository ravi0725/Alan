/***
Class Name : JIRAConnectorWebserviceUpdateJIRAEpic
Desciption : This class used to update JIRA Epic Link on creation of JIRA ticket from SFDC
Date       : 1-Dec-2016
Author     : Suresh Babu Murugan
**/
global class JIRAConnectorWebserviceUpdateJIRAEpic {
    WebService static void updateJIRAEpic(String baseUrl, String JIRAIssueKey, String epicLinkFieldID, String epicLinkCode) {
        try {
            HttpRequest req = buildRequest(baseUrl, JIRAConnectorClass.username, JIRAConnectorClass.password, JIRAIssueKey, epicLinkFieldID, epicLinkCode);
            HttpResponse response = JIRAConnectorClass.sendRequest(req);
        } catch(System.CalloutException e) {        
            System.debug(e);
        }
    }
    
    public static HttpRequest buildRequest(String baseUrl, String username, String password, String JIRAKey, String eFieldID, String eCode) {
        HttpRequest req = new HttpRequest();
        String basicAuthHeader = JIRAConnectorClass.authHeader(username, password);
        String endpoint = getEndpoint(baseUrl, JIRAKey);
        req.setHeader('Authorization', basicAuthHeader);
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(endpoint);
        req.setMethod('PUT');
        String updateJIRAStatusJSON= '{"fields":{"'+ eFieldID + '": "'+ eCode + '"}}';
        req.setBody(updateJIRAStatusJSON);
        return req;
    }
    
    // Creates the endpoint to synchronize the issue from provided parameters.
    private static String getEndpoint(String baseUrl, String JIRAKey) {
        return baseUrl + '/rest/api/2/issue/'+ JIRAKey;
    }
}