/**
Class Name : JIRAUpdateStatusCustomSettingRecords
Desciption : This class is used in update JIRA Status Mapping custom setting records with help of REST API. No need to update manually.
Date       : 18-Nov-2016
Author     : Suresh Babu Murugan

Execution:
Run below code in execute anonymous to create/update Status records in SFDC. Here "SFUST-51" JIRA issue number. Please use available issue key to update records.
JIRAUpdateStatusCustomSettingRecords.retrieveJIRAStatus('SFUST-51');
**/
public class JIRAUpdateStatusCustomSettingRecords {
    
    // This method used to retrieve JIRA status using JIRA Key (SPSUST-51)
    public static void retrieveJIRAStatus(String JIRAIssueKey){
        String JIRAStatus_JSON = '';
        if(system.Test.isRunningTest()){
            JIRAStatus_JSON = JIRATextFixture.jiraAllStatusResponse;
        }
        else{
            JIRAStatus_JSON = updateJIRAStatusinSFDC(JIRAIssueKey);
        }
        if(JIRAStatus_JSON != ''){
            JIRAStatusWrapper statusInformation = new JIRAStatusWrapper();
            statusInformation = (JIRAStatusWrapper) System.JSON.deserialize(JIRAStatus_JSON, JIRAStatusWrapper.class);
            system.debug(' statusInformation ====================>>'+statusInformation);
            updateSFDCCustomSettingwithJIRAStatus(statusInformation, JIRAIssueKey);
        }
    }
    
    // This method is used to update SFDC-JIRA Status Mapping custom setting with JIRA status information
    public static void updateSFDCCustomSettingwithJIRAStatus(JIRAStatusWrapper wrpResult, String JIRAIssueKey){
        Map<String, JIRA_Status_Mapping__c> mapJIRAStatus = JIRA_Status_Mapping__c.getall();
        String jiraKey = JIRAIssueKey.substringBefore('-') +'-%';
        List<JIRA_Status_Mapping__c> lstStatus = [SELECT Name, Id, Status_Code__c FROM JIRA_Status_Mapping__c WHERE Name LIKE : jiraKey];
        
        List<JIRA_Status_Mapping__c> upsertJIRAStatus = new List<JIRA_Status_Mapping__c>();
        if(wrpResult.transitions.size() > 0){
            for(cls_transitions tran: wrpResult.transitions){
                String formattedString = JIRAIssueKey.substringBefore('-') + '-' + tran.name; // Format : SPSUST-To Do (ProjectKEY-Status)
                // Create new Custom setting record in SFDC
                JIRA_Status_Mapping__c jStatus = new JIRA_Status_Mapping__c();
                jStatus.Name = formattedString;
                if(tran.name != null && tran.name != '')
                    jStatus.Status_Name__c = tran.name;
                if(tran.id != null && tran.id != '')
                    jStatus.Status_Code__c = tran.id;
                if(tran.to.description != null && tran.to.description != '')
                    jStatus.Description__c = tran.to.description;
                if(tran.to.statusCategory.key != null && tran.to.statusCategory.key != '')
                    jStatus.Key_Type__c = tran.to.statusCategory.key;
                if(tran.to.statusCategory.colorName != null && tran.to.statusCategory.colorName != '')
                    jStatus.Color_Name__c = tran.to.statusCategory.colorName;
                upsertJIRAStatus.add(jStatus);
            }
            system.debug('upsertJIRAStatus =======>'+upsertJIRAStatus);
            if(upsertJIRAStatus.size() > 0){
                delete lstStatus;
                upsert upsertJIRAStatus;
            }
        }
    }
    
    // Sends request to JIRA and returns the request body which should be a valid JSON.
    public static String updateJIRAStatusinSFDC(String JIRAIssueKey) {
        try {
            HttpRequest req = build_TransitionRequest(JIRAConnectorClass.baseUrl, JIRAConnectorClass.username, JIRAConnectorClass.password, JIRAIssueKey);
            HttpResponse res = JIRAConnectorClass.sendRequest(req);
            return res.getBody();
        } catch(System.CalloutException e) {
            System.debug(e);
            return '';
        }
    }
    
    // Constructs request needed to fetch JIRA issues from provided parameters.
    @testVisible private static HttpRequest build_TransitionRequest(String baseUrl, String username, String password, String JIRAIssueKey) {
        HttpRequest req = new HttpRequest();
        String basicAuthHeader = JIRAConnectorClass.authHeader(username, password);
        String endpoint = getTransitionEndpoint(baseUrl, JIRAIssueKey);
        req.setHeader('Authorization', basicAuthHeader);
        req.setHeader('Content-Type','application/json');
        req.setMethod('GET');
        req.setEndpoint(endpoint);
        return req;
    }
    
    // Creates the endpoint to fetch the issue from provided parameters.
    private static String getTransitionEndpoint(String baseUrl, String JIRAIssueKey) {
        return baseUrl + '/rest/api/2/issue/' + JIRAIssueKey + '/transitions'; // https://ejira.trimble.com/rest/api/2/issue/SFUST-23/transitions
    }
    
    // JIRA Status Information for the Requested Project
    @testVisible public class JIRAStatusWrapper {
        public String expand;  //transitions
        public List<cls_transitions> transitions;
    }
    class cls_transitions {
        public String id;  //11
        public String name;  //To Do
        public cls_to to;
    }
    class cls_to {
        public String self;  //https://ejira.trimble.com/rest/api/2/status/10001
        public String description;  //
        public String iconUrl;  //https://ejira.trimble.com/images/icons/subtask.gif
        public String name;  //To Do
        public String id;  //10001
        public cls_statusCategory statusCategory;
    }
    class cls_statusCategory {
        public String self;  //https://ejira.trimble.com/rest/api/2/statuscategory/2
        public Integer id;  //2
        public String key;  //new
        public String colorName;  //blue-gray
        public String name;  //To Do
    }
    /////
}