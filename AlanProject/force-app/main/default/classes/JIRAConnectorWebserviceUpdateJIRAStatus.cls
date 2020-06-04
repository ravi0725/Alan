/***
Class Name : JIRAConnectorWebserviceUpdateJIRAStatus
Desciption : This class is used in update JIRA status from SFDC
Date       : 21-Nov-2016
Author     : Suresh Babu Murugan
**/
global class JIRAConnectorWebserviceUpdateJIRAStatus {
    WebService static void updateJIRAStatus_futureCall(String baseUrl, String JIRAIssueKey, String statusCode) {
        try {
            HttpRequest req = buildRequest(baseUrl, JIRAConnectorClass.username, JIRAConnectorClass.password, JIRAIssueKey, statusCode);
            HttpResponse response = JIRAConnectorClass.sendRequest(req);
        } catch(System.CalloutException e) {        
            System.debug(e);
        }
    }
    
    @future (callout=true) WebService static void updateJIRAStatus(String baseUrl, String JIRAIssueKey, String statusCode) {
        try {
            HttpRequest req = buildRequest(baseUrl, JIRAConnectorClass.username, JIRAConnectorClass.password, JIRAIssueKey, statusCode);
            HttpResponse response = JIRAConnectorClass.sendRequest(req);
        } catch(System.CalloutException e) {        
            System.debug(e);
        }
    }
    
    public static HttpRequest buildRequest(String baseUrl, String username, String password, String JIRAKey, String sCode) {
        HttpRequest req = new HttpRequest();
        String basicAuthHeader = JIRAConnectorClass.authHeader(username, password);
        String endpoint = getEndpoint(baseUrl, JIRAKey);
        req.setHeader('Authorization', basicAuthHeader);
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        String updateJIRAStatusJSON= '{"transition": {"id": "'+ sCode +'"}}';
        req.setBody(updateJIRAStatusJSON);
        return req;
    }
    
    // Creates the endpoint to synchronize the issue from provided parameters.
    private static String getEndpoint(String baseUrl, String JIRAKey) {
        return baseUrl + '/rest/api/2/issue/'+ JIRAKey +'/transitions';
    }
}