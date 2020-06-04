/**
Class Name : JIRACreateIssueCtrl
Desciption : This class is used in Create JIRA Issue from SFDC
Date       : 07-Jun-2016
Author     : Suresh Babu Murugan
**/
public class JIRACreateIssueCtrl {
    public List<JIRAIssue> lstJIRADetails {get;set;}
    public Boolean alreadyLinkedwithJIRA {get;set;} // Boolean denotes, Case was already linked with JIRA
    public String messagetoUser {get;set;}
    public Boolean errorPopup {get;set;}
    public Id CaseId {get;set;}
    public String retURL {get;set;}
    public String objectTypeURL {get;set;}
    public String projectKeyURL {get;set;}
    public String issueTypeURL {get;set;}
    
    public JIRACreateIssueCtrl() {
        errorPopup = false;
        CaseId = System.currentPageReference().getParameters().get('id');
        objectTypeURL = System.currentPageReference().getParameters().get('objType');
        projectKeyURL = System.currentPageReference().getParameters().get('pKey');
        issueTypeURL = System.currentPageReference().getParameters().get('iType');
        
        lstJIRADetails = new List<JIRAIssue>();
        retURL = '/'+ CaseId;
    }
    
    public Pagereference cancelPage(){
        return new Pagereference('/'+CaseId);
    }
    
    public void doCallout(){
        system.debug('CaseId ===>'+CaseId);
        
        if(CaseId.getSobjectType() == Case.SobjectType){
            // Check the Case is related to Space Scheduling
            Case cs = [SELECT Id, Application__c, RecordType.Name FROM Case WHERE Id =: CaseId limit 1];
            if(cs.RecordType.Name == 'RE&WS - Support' && (cs.Application__c == 'Space Scheduling' || cs.Application__c == 'Manhattan')){
                fetchLinkedIssues(JIRAConnectorClass.baseUrl, JIRAConnectorClass.systemId, objectTypeURL, CaseId, projectKeyURL, issueTypeURL);
            }
            else{
                messagetoUser = 'Space Scheduling or Manhattan related Cases only can able to create JIRA issue from SFDC. Please verify the Case.';
                errorPopup = true;
            }    
        }
        else if(CaseId.getSobjectType() == Development__c.SobjectType){
            // Check the Development is already linked with existing JIRA ticket.
            Development__c dev = [SELECT Id, Name, Subject__c, OwnerId, JIRA_Issue_ID__c, Description__c, Code_Fix_Information__c, JIRA_Description__c, JIRA_Code_Fix_Information__c, (SELECT Id, Name, ParentId, ContentType, BodyLength, LastModifiedBy.Name, CreatedBy.Name FROM Attachments), (SELECT Body, Id, Title, ParentId, LastModifiedBy.Name,CreatedBy.Name FROM Notes) FROM Development__c WHERE Id =: CaseId limit 1];
            
            if(dev.JIRA_Issue_ID__c == null){
                // Update JIRA Assigned User to SFDC Owner based on the User mapping provided
                List<JIRA_Development_User_Mapping__c> lstUMapping = [SELECT Id, Name, JIRA_User_Name__c, Role_Department__c, SFDC_Name__c, SFDC_User_ID__c, SFDC_User_Name__c FROM JIRA_Development_User_Mapping__c limit 49999];
                Map<String, JIRA_Development_User_Mapping__c> mapAllUserMappings = new Map<String, JIRA_Development_User_Mapping__c>();
                
                for(JIRA_Development_User_Mapping__c uMapping : lstUMapping){
                    uMapping.Name = uMapping.Name.toLowerCase();
                    mapAllUserMappings.put(uMapping.Name, uMapping);
                }
                if(dev.JIRA_Code_Fix_Information__c == null || dev.JIRA_Description__c == null){
                    if(dev.Description__c != null){
                        dev.Description__c = dev.Description__c + '.';
                    }
                    if(dev.Code_Fix_Information__c != null){
                        dev.Code_Fix_Information__c = dev.Code_Fix_Information__c + '.';
                    }
                    
                    // Update Owner between JIRA and SFDC
                    if(dev.OwnerId != null){
                        Boolean JIRAOwnerUpdated = false;
                        for(JIRA_Development_User_Mapping__c uMapping : mapAllUserMappings.values()){
                            if(uMapping.SFDC_User_ID__c == dev.OwnerId){
                                dev.SFDC_JIRA_Owner__c = uMapping.Name.toLowerCase();
                                //dev.JIRA_Issue_Assigned_User__c = uMapping.Name.toLowerCase();
                                dev.JIRA_Issue_Assigned_User__c = uMapping.JIRA_User_Name__c;
                                JIRAOwnerUpdated = true;
                                break;
                            }
                        }
                        
                        // Current SFDC owner does not have JIRA access or not included in mapping 
                        if(!JIRAOwnerUpdated){
                            dev.SFDC_JIRA_Owner__c = 'Unassigned';
                            dev.JIRA_Issue_Assigned_User__c = 'Unassigned';
                        }
                    }
                    update dev;
                }
                
                if(dev.Notes.size() > 0){
                    Note n = dev.Notes[0];
                    update n;
                }
                else if(dev.Attachments.size() > 0){
                    Attachment a = dev.Attachments[0];
                    update a;
                }
            }
            
            if(dev.Subject__c != null){
                fetchLinkedIssues(JIRAConnectorClass.baseUrl, JIRAConnectorClass.systemId, objectTypeURL, CaseId, projectKeyURL, issueTypeURL);
            }
        }
    }
    
    @testVisible private void fetchLinkedIssues(String baseUrl, String systemId, String objectType, String objectId, String projectKey, String issueType){
        system.debug('objectId ==============>'+objectId);
        alreadyLinkedwithJIRA = false;
        String FetchResultJson = checkAlreadyLinked(objectType, objectId);
        String issueKeys = '';
        system.debug('FetchResultJson ========>>>'+FetchResultJson);
        // If there no exception
        if(FetchResultJson != ''){
            lstJIRADetails = (List<JIRAIssue>)JSON.deserialize(FetchResultJson , List<JIRAIssue>.class);
            system.debug('lstJIRADetails ===>'+lstJIRADetails);
        }
        if(lstJIRADetails.size() >= 1){
            alreadyLinkedwithJIRA = true;
            for(JIRAIssue jIssue: lstJIRADetails){
                if(issueKeys == ''){
                    issueKeys += '<a href="'+jIssue.url+'" target="_blank">'+jIssue.key+'</a>';
                    //issueKeys += jIssue.key;
                }
                else{
                    issueKeys += ', ' + '<a href="'+jIssue.url+'" target="_blank">'+jIssue.key+'</a>';
                }
            }
            
            if(objectType == 'Case'){
                messagetoUser = 'This Case already Linked with following JIRA Issue/s: ' + issueKeys;
            }
            else if(objectType == 'Development__c'){
                messagetoUser = 'This Development ticket already Linked with following JIRA Issue/s: ' + issueKeys;
            }
            system.debug('messagetoUser ===>'+messagetoUser);
        }
        // If there is no Issue linked, we are good to create JIRA Issue
        if(!alreadyLinkedwithJIRA){
            if(objectType == 'Case'){
                JIRAConnectorWebserviceCalloutCreate.createIssue(baseUrl, systemId, objectType, objectId, projectKey, issueType);
                messagetoUser = 'JIRA issue is being created. Please click the Back button and refresh the browser to see the update.';
            }
            else if(objectType == 'Development__c'){
                JIRAConnectorWebserviceCalloutCreate.createIssue(baseUrl, systemId, objectType, objectId, projectKey, issueType);
                messagetoUser = 'JIRA issue is being created. Please click the Back button and refresh the browser to see the update.';
                
                JIRAConnectorWebserviceCalloutSync.synchronizeWithJIRAIssue(JIRAConnectorClass.baseUrl, JIRAConnectorClass.systemId, objectType, objectId);
            }
        }
        errorPopup = true;
    }
    
    // Sends request to JIRA and returns the request body which should be a valid JSON.
    private static String checkAlreadyLinked(String objectType, String objectId) {
        try {
            HttpRequest req = build_FetchRequest(JIRAConnectorClass.baseUrl, JIRAConnectorClass.username, JIRAConnectorClass.password, JIRAConnectorClass.systemId, objectType, objectId);
            HttpResponse res = JIRAConnectorClass.sendRequest(req);
            return res.getBody();
        } catch(System.CalloutException e) {
            System.debug(e);
            return '';
        }
    }
    
    // Constructs request needed to fetch JIRA issues from provided parameters.
    @testVisible private static HttpRequest build_FetchRequest(String baseUrl, String username, String password,
                                                               String systemId, String objectType, String objectId) {
                                                                   HttpRequest req = new HttpRequest();
                                                                   String basicAuthHeader = JIRAConnectorClass.authHeader(username, password);
                                                                   String endpoint = getFetchEndpoint(baseUrl, systemId, objectType, objectId);
                                                                   req.setHeader('Authorization', basicAuthHeader);
                                                                   req.setHeader('Content-Type','application/json');
                                                                   req.setMethod('GET');
                                                                   req.setEndpoint(endpoint);
                                                                   return req;
                                                               }
    
    // Creates the endpoint to fetch the issue from provided parameters.
    private static String getFetchEndpoint(String baseUrl, String systemId, String objectType, String objectId) {
        return baseUrl + '/rest/customware/connector/1.0/' + systemId + '/' + objectType + '/' + objectId + '/issue/fetch.json';
    }
    
    // JIRA Issue Object.
    @testVisible class JIRAIssue {
        @testVisible public String summary { get; }
        @testVisible public String project { get; }
        @testVisible public String reporter { get; }
        @testVisible public String key { get;}
        @testVisible public String status { get; }
        @testVisible public String resolution { get; }
        @testVisible public String url { get; }
        @testVisible public String type { get; }
        @testVisible public String assignee { get; }
        @testVisible public String description { get; }
        @testVisible public String priority { get; }
        @testVisible public String due_date { get; }
    }
}