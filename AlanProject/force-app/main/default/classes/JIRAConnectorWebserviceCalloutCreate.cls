/***
Class Name : JIRAConnectorWebserviceCalloutCreate
Desciption : This class is used in Create JIRA Issue from SFDC
Date       : 07-Jun-2016
Author     : Suresh Babu Murugan
**/
global class JIRAConnectorWebserviceCalloutCreate {
    @future (callout=true) WebService static void createIssue(String baseUrl, String systemId, String objectType, String objectId, String projectKey, String issueType) {
        try {
            HttpRequest req = buildRequest(baseUrl, JIRAConnectorClass.username, JIRAConnectorClass.password, systemId, objectType, objectId, projectKey, issueType);
            
            // Restrict update again on Creating JIRA ticket from SFDC
            JIRASycnOnDevelopmentUpdate.restrictRecurrence = true;
            
            HttpResponse response = JIRAConnectorClass.sendRequest(req);
            system.debug('req.setHeader ==>'+req.getHeader('Authorization'));
            system.debug('req ===>'+req);
            
            system.debug('HttpResponse ===>'+response);
            system.debug('HttpResponse ===>'+response.getBody());
            
            if(response.getStatusCode() == 200){ // If successfully Created ticket.
                Map<String, Object> mp = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                system.debug('mp ============>>>'+mp);
                // Update Space Scheduling JIRA issue with Epic Link (SPSCH-280/Support Tickets)
                if(objectType == 'Case'){
                    Case cs = [SELECT Id, Application__c FROM Case WHERE Id =: objectId limit 1];
                    system.debug(' Application ======>>>'+cs.Application__c);

                    if(mp.containsKey('issueKey') && cs.Application__c == 'Space Scheduling'){
                        String JIRAKey = String.valueOf(mp.get('issueKey'));
                        JIRAConnectorWebserviceUpdateJIRAEpic.updateJIRAEpic(baseUrl, JIRAKey, 'customfield_10106', 'SPSCH-280');
                    }
                    else if(mp.containsKey('issueKey') && cs.Application__c == 'Manhattan'){
                        String JIRAKey = String.valueOf(mp.get('issueKey'));
                        JIRAConnectorWebserviceUpdateJIRAEpic.updateJIRAEpic(baseUrl, JIRAKey, 'customfield_10106', 'RECSA-1');
                    }
                }
                
                
                // Update JIRA Issue Key to Development record
                if(objectType == 'Development__c'){
                    Development__c dev = [SELECT Id, Name, JIRA_Issue_ID__c, Status__c FROM Development__c WHERE Id =: objectId limit 1];
                    
                    if(mp.containsKey('issueKey')){
                        String JIRAKey = String.valueOf(mp.get('issueKey')); 
                        if(JIRAKey != ''){
                            dev.JIRA_Issue_ID__c = JIRAKey;
                            
                            // Update JIRA Status from SFDC
                            system.debug('JIRAKey ==================>>>'+JIRAKey+' =========>'+dev.Status__c+' ======>'+dev.JIRA_Issue_ID__c);
                            Map<String, JIRA_Status_Mapping__c> mapJIRAStatusCodes = JIRA_Status_Mapping__c.getAll();
                            
                            String SFDCStatusformatted = 'SFDC-'+dev.Status__c;
                            if(mapJIRAStatusCodes.containsKey(SFDCStatusformatted)){ // Is status mapping available in custom setting ?
                                if(mapJIRAStatusCodes.get(SFDCStatusformatted).Is_Status_Mapping__c){ // Double check the record is used for status mapping ?
                                    String projectKeywithStatus = dev.JIRA_Issue_ID__c.substringBefore('-') + '-' + mapJIRAStatusCodes.get(SFDCStatusformatted).Status_Name__c; // should like (SPSUST-TO DO)
                                    system.debug('projectKeywithStatus =====>'+projectKeywithStatus);
                                    
                                    if(mapJIRAStatusCodes.containsKey(projectKeywithStatus)){
                                        // Do update JIRA Status if the mapping is available in SFDC custom setting (JIRA Status Mapping)
                                        JIRAConnectorWebserviceUpdateJIRAStatus.updateJIRAStatus_futureCall(JIRAConnectorClass.baseUrl, dev.JIRA_Issue_ID__c, mapJIRAStatusCodes.get(projectKeywithStatus).Status_Code__c);
                                        system.debug('Callout executed.....');
                                    }
                                }
                            }
                            
                            update dev;
                        }
                    }
                }
            }
            
        } catch(System.CalloutException e) {
            System.debug(e);
        }
    }
    
    // Constructs request needed to create a JIRA issue from provided parameters.
    @testVisible private static HttpRequest buildRequest(String baseUrl, String username, String password,
                                                         String systemId, String objectType, String objectId,
                                                         String projectKey, String issueType) {
                                                             HttpRequest req = new HttpRequest();
                                                             system.debug(' User Name=>'+username);
                                                             system.debug(' password=>'+password);
                                                             
                                                             String basicAuthHeader = JIRAConnectorClass.authHeader(username, password);
                                                             String endpoint = getEndpoint(baseUrl, systemId, objectType, objectId);
                                                             req.setHeader('Authorization', basicAuthHeader);
                                                             req.setHeader('Content-Type','application/json');
                                                             req.setMethod('POST');
                                                             req.setEndpoint(endpoint);
                                                             String CreateIssueinJIraJson= '{"project":"' + projectKey + '", "issueType":"' + issueType + '"}';
                                                             //String JSONData = JSON.serializePretty(CreateIssueinJIraJson); 
                                                             req.setBody(CreateIssueinJIraJson);
                                                             return req;
                                                         }
    
    // Creates the endpoint to create the issue from provided parameters.
    private static String getEndpoint(String baseUrl, String systemId, String objectType, String objectId) {
        String URLs = baseUrl + '/rest/customware/connector/1.0/' + systemId + '/' + objectType + '/' + objectId + '/issue/create.json';
        system.debug('URLs= ===>'+URLs);
        return URLs;
    }
}