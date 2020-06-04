global class JIRAConnectorWebserviceCalloutSync {
	
    @future (callout=true) WebService static void synchronizeWithJIRAIssueWithStatus(String baseUrl, String systemId, String objectType, String objectId, String JIRAIssueKey, String statusCode) {
        try {
			HttpRequest req = buildRequest(baseUrl, JIRAConnectorClass.username, JIRAConnectorClass.password, systemId, objectType, objectId);
            HttpResponse response = JIRAConnectorClass.sendRequest(req);
            system.debug('response ===========================>>'+response);
            
            if(response.getStatusCode() == 200 && statusCode != '' ){ // If successfully Synchronized ticket.
            	// Update Status to JIRA
                //sleep(10000); // Idle for 10 Seconds
                JIRAConnectorWebserviceUpdateJIRAStatus.updateJIRAStatus_futureCall(baseUrl, JIRAIssueKey, statusCode);
            }
        } catch(System.CalloutException e) {        
			System.debug(e);
		}
	}
    
	@future (callout=true) WebService static void synchronizeWithJIRAIssue(String baseUrl, String systemId, String objectType, String caseId) {
		try {
			HttpRequest req = buildRequest(baseUrl, JIRAConnectorClass.username, JIRAConnectorClass.password, systemId, objectType, caseId);
            HttpResponse response = JIRAConnectorClass.sendRequest(req);
            system.debug('response ===========================>>'+response);
		} catch(System.CalloutException e) {        
			System.debug(e);
		}
	}
	
	// Constructs request needed to synchronize a JIRA issue from provided parameters.
	public static HttpRequest buildRequest(String baseUrl, String username, String password,
										   String systemId, String objectType, String caseId) {
		HttpRequest req = new HttpRequest();
		String basicAuthHeader = JIRAConnectorClass.authHeader(username, password);
		String endpoint = getEndpoint(baseUrl, systemId, objectType, caseId);
		req.setHeader('Authorization', basicAuthHeader);
		req.setHeader('Content-Type', 'application/json');
		req.setHeader('Content-Length', '0');
		req.setEndpoint(endpoint);
		req.setMethod('PUT');
		return req;
	}
	
	// Creates the endpoint to synchronize the issue from provided parameters.
	private static String getEndpoint(String baseUrl, String systemId, String objectType, String caseId) {
		return baseUrl + '/rest/customware/connector/1.0/' + systemId + '/' + objectType +  '/' + caseId + '/issue/synchronize.json';
	}

	public static void sleep(Long milliSeconds){
		Long timeDiff = 0;
		DateTime firstTime = System.now();
		do{
			timeDiff = System.now().getTime() - firstTime.getTime();
		}
		while(timeDiff <= milliSeconds);
	}	
}