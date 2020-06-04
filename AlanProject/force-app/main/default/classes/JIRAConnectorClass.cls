/***
    Class Name : JIRAConnectorClass
    Desciption : This class is used in connect with JIRA.
    Date       : 07-Jun-2016
    Author     : Suresh Babu Murugan
**/
public class JIRAConnectorClass {
    public static String baseUrl = JIRAIntegrationConfig.getEndPointURL('JIRA'); // Base URL of your JIRA instance
    public static String systemId = JIRAIntegrationConfig.getSystemId('JIRA'); // Salesforce Connector System ID in JIRA
    public static String username = JIRAIntegrationConfig.getUserName('JIRA');  // JIRA username
    public static String password = JIRAIntegrationConfig.getPassword('JIRA'); // JIRA password
    
    public static String warningMessage {get;set;}
    
    // Constructs Basic Http Authentication header from provided credentials
    public static String authHeader(String u, String p) {
        Blob headerValue = Blob.valueOf(u + ':' + p);
        return 'Basic ' + EncodingUtil.base64Encode(headerValue);
    }
    
    // Sends a request and returns the response
    public static HttpResponse sendRequest(HttpRequest req) {
        Http http = new Http();
        return http.send(req);
    }
}