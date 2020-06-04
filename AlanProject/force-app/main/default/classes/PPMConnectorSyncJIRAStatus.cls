/*****************************************************************************************
  Name    : PPMConnectorSyncJIRAStatus
  Desc    : Used to sync update the JIRA staus to closed when GC/PPM SFDC Issue got closed
 
  Modification Log : 
  ===========================================================================
  Developer				Date			Description
  ===========================================================================
  Suresh Babu Murugan		12/Dec/2018		Created
  Suresh Babu Murugan		03/Apr/2019		Added functionality to sync Case Comments to JIRA global Comment section
 ******************************************************************************************/
global class PPMConnectorSyncJIRAStatus {
	/**
	 * @description : This method used to update related JIRA ticket when the Issue is closed in SFDC
	 * @param jProjectKey 
	 * @param productIssue 
	 */
	@Future(callout = true) WebService static void updateJIRAStatus(String jProjectKey, String productIssue) {
		try {
			if (jProjectKey != null && productIssue != null && TFS_Project_Config__c.getAll().get(productIssue) != null && TFS_Project_Config__c.getAll().get(productIssue).Run_JIRA_Integration__c) {
				HttpRequest req = buildTransitionRequest(JIRAIntegrationConfig.getEndPointURL('PPM'), JIRAIntegrationConfig.getUserName('PPM'), JIRAIntegrationConfig.getPassword('PPM'), jProjectKey, Integer.valueOf(TFS_Project_Config__c.getAll().get(productIssue).JIRA_Closed_Transision__c));
				System.debug('Req Body :::::' + req.getBody());
				HttpResponse response;
				if (!System.Test.isRunningTest()) {
					response = JIRAConnectorClass.sendRequest(req);
				}
				else {
					response = new HttpResponse();
					response.setStatusCode(200);
				}
				System.debug('response ===============>' + response);
			}
		} catch(System.CalloutException e) {
			System.debug(e);
		}
	}

	/**
	 * @description : This method used to update related JIRA ticket when the Issue Feature for updated in SFDC
	 * @param jProjectKey 
	 * @param productIssue 
	 * @param feature 
	 */
	@Future(callout = true) WebService static void updateJIRAComponent(String jProjectKey, String productIssue, String feature) {
		try {
			if (jProjectKey != null && productIssue != null && TFS_Project_Config__c.getAll().get(productIssue) != null && TFS_Project_Config__c.getAll().get(productIssue).Run_JIRA_Integration__c) {
				if (PPM_JIRA_Components__c.getAll().get(feature) != null && PPM_JIRA_Components__c.getAll().get(feature).JIRA_Id__c != null) {
					HttpRequest req = buildComponentRequest(JIRAIntegrationConfig.getEndPointURL('PPM'), JIRAIntegrationConfig.getUserName('PPM'), JIRAIntegrationConfig.getPassword('PPM'), jProjectKey, String.valueOf(PPM_JIRA_Components__c.getAll().get(feature).JIRA_Id__c));
					System.debug('Req Body :::::' + req.getBody());
					HttpResponse response;
					if (!System.Test.isRunningTest()) {
						response = JIRAConnectorClass.sendRequest(req);
					}
					else {
						response = new HttpResponse();
						response.setStatusCode(200);
					}
					System.debug('response ===============>' + response);
				}

			}
		} catch(System.CalloutException e) {
			System.debug(e);
		}
	}

	/**
	 * @author: Suresh Babu Murugan
	 * @description : This method used to sync Salesforce Comment to JIRA comment (e-Builder)
	 * @param jProjectKey 
	 * @param productIssue 
	 * @param latestComment 
	 */
	@Future(callout = true) Webservice static void updateJIRAComment(String jProjectKey, String productIssue, String latestComment, Id parentCaseId, Id caseCommentId, Boolean blnIsInsert) {
		try {
			if (jProjectKey != null && latestComment != null && productIssue != null && TFS_Project_Config__c.getAll().get(productIssue) != null && TFS_Project_Config__c.getAll().get(productIssue).Run_JIRA_Integration__c) {
				String updatedComment = UserInfo.getName() + ' added this Comment in Salesforce \r\n' + latestComment;
				updatedComment = (updatedComment.contains('\n') ? updatedComment.replaceAll('\r\n', '\\\\n') : updatedComment);
				HttpRequest req;
				Boolean blnIsUpdateJIRACommentMapping = false;
				if (blnIsInsert) {
					req = buildCommentRequest(JIRAIntegrationConfig.getEndPointURL('PPM'), JIRAIntegrationConfig.getUserName('PPM'), JIRAIntegrationConfig.getPassword('PPM'), jProjectKey, updatedComment, null);
					blnIsUpdateJIRACommentMapping = true;
				}
				else {
					Map<Id, String> mapCaseComments = CaseCommentHandler.returnCaseCommentJIRAIDMapping(parentCaseId);
					req = buildCommentRequest(JIRAIntegrationConfig.getEndPointURL('PPM'), JIRAIntegrationConfig.getUserName('PPM'), JIRAIntegrationConfig.getPassword('PPM'), jProjectKey, updatedComment, (mapCaseComments.containsKey(caseCommentId) ? mapCaseComments.get(caseCommentId) : null));
					if (!mapCaseComments.containsKey(caseCommentId)) {
						blnIsUpdateJIRACommentMapping = true;
					}
				}

				HttpResponse response;
				if (!System.Test.isRunningTest()) {
					response = JIRAConnectorClass.sendRequest(req);
				}
				else {
					response = new HttpResponse();
					response.setStatusCode(201);
					response.setBody('{"id":"123456"}');
				}
				if (blnIsUpdateJIRACommentMapping && response.getStatusCode() == 201) {
					Map<String, Object> mapResponseDetails = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
					if (mapResponseDetails.containsKey('id') && parentCaseId != null && caseCommentId != null) {
						Case oUpdateCase = [SELECT Id, CaseComment_JIRA_Mapping__c FROM Case WHERE Id = :parentCaseId];
						if (oUpdateCase.CaseComment_JIRA_Mapping__c == null) {
							oUpdateCase.CaseComment_JIRA_Mapping__c = caseCommentId + '=>' + mapResponseDetails.get('id') + ';';
						}
						else {
							oUpdateCase.CaseComment_JIRA_Mapping__c += caseCommentId + '=>' + mapResponseDetails.get('id') + ';';
						}
						update oUpdateCase;
					}
				}
			}
		}
		catch(System.CalloutException e) {
			System.debug(e);
		}
	}

	/**
	 * @author: Suresh Babu Murugan
	 * @description : This method used to DELETE JIRA Comment when Salesforce Comment deleted (e-Builder)
	 * @param jProjectKey 
	 * @param productIssue 
	 * @param parentCaseId 
	 * @param caseCommentId 
	 * @param blnIsDelete 
	 */
	@Future(callout = true) Webservice static void deleteJIRAComment(String jProjectKey, String productIssue, Id parentCaseId, Id caseCommentId, Boolean blnIsDelete) {
		try {
			if (blnIsDelete && jProjectKey != null && productIssue != null && parentCaseId != null && caseCommentId != null && TFS_Project_Config__c.getAll().get(productIssue) != null && TFS_Project_Config__c.getAll().get(productIssue).Run_JIRA_Integration__c) {
				HttpRequest req;
				Map<Id, String> mapCaseComments = CaseCommentHandler.returnCaseCommentJIRAIDMapping(parentCaseId);
				req = buildDeleteCommentRequest(JIRAIntegrationConfig.getEndPointURL('PPM'), JIRAIntegrationConfig.getUserName('PPM'), JIRAIntegrationConfig.getPassword('PPM'), jProjectKey, (mapCaseComments.containsKey(caseCommentId) ? mapCaseComments.get(caseCommentId) : null));
				HttpResponse response;
				if (!System.Test.isRunningTest()) {
					response = JIRAConnectorClass.sendRequest(req);
				}
				else {
					response = new HttpResponse();
					response.setStatusCode(204);
				}
				if (response.getStatusCode() == 204) {
					//Map<Id, String> mapCaseComments = CaseCommentHandler.returnCaseCommentJIRAIDMapping(parentCaseId);
					if (mapCaseComments != null && mapCaseComments.containsKey(caseCommentId)) {
						mapCaseComments.remove(caseCommentId);
						Case oUpdateCase = [SELECT Id, CaseComment_JIRA_Mapping__c FROM Case WHERE Id = :parentCaseId];
						String strUpdateCaseCommentJIRAKeys = '';
						for (Id cCommentId : mapCaseComments.keySet()) {
							strUpdateCaseCommentJIRAKeys += cCommentId + '=>' + mapCaseComments.get(cCommentId) + ';';
						}
						oUpdateCase.CaseComment_JIRA_Mapping__c = strUpdateCaseCommentJIRAKeys;
						update oUpdateCase;
					}
				}
			}
		}
		catch(System.CalloutException e) {
			System.debug(e);
		}
	}

	/**
	* @author: Suresh Babu Murugan
	* @description : This method used to POST Caseowner as JIRA issue watcher (e-Builder)
	* @param jProjectKey 
	* @param productIssue 
	* @param caseOwnerUserName 
	*/ 
	@Future(callout = true) WebService static void postJIRAWatcher(String jProjectKey, String productIssue, String caseOwnerUserName) {
		try {
			if (jProjectKey != null && productIssue != null && TFS_Project_Config__c.getAll().get(productIssue) != null && TFS_Project_Config__c.getAll().get(productIssue).Run_JIRA_Integration__c) {
				if (PPM_JIRA_User_Mapping__c.getAll().get(caseOwnerUserName) != null && PPM_JIRA_User_Mapping__c.getAll().get(caseOwnerUserName).JIRA_AccountId__c != null) {
					HttpRequest req = buildPostWatcherRequest( JIRAIntegrationConfig.getEndPointURL('PPM'), JIRAIntegrationConfig.getUserName('PPM'), JIRAIntegrationConfig.getPassword('PPM'), jProjectKey, String.valueOf(PPM_JIRA_User_Mapping__c.getAll().get(caseOwnerUserName).JIRA_AccountId__c));
					System.debug('Req Body :::::' + req.getBody());
					HttpResponse response;
					if (!System.Test.isRunningTest()) {
						response = JIRAConnectorClass.sendRequest(req);
					}
					else {
						response = new HttpResponse();
						response.setStatusCode(204);
					}
					System.debug('response ===============>' + response);
				}

			}
		} catch(System.CalloutException e) {
			System.debug(e);
		}
	}

	/**
	 * @description : Constructs request needed to synchronize a JIRA issue from provided parameters.
	 * @param baseUrl 
	 * @param username 
	 * @param password 
	 * @param jProjectKey 
	 * @param transID 
	 * @return : HTTP Request
	 */
	public static HttpRequest buildTransitionRequest(String baseUrl, String username, String password, String jProjectKey, Integer transID) {
		HttpRequest req = new HttpRequest();
		String basicAuthHeader = JIRAConnectorClass.authHeader(username, password);
		String endpoint = getTransitionEndpoint(baseUrl, jProjectKey);
		req.setHeader('Authorization', basicAuthHeader);
		req.setHeader('Accept', 'application/json');
		req.setHeader('Content-Type', 'application/json');
		req.setBody('{"transition":{"id": "' + transID + '"}}');
		req.setEndpoint(endpoint);
		req.setMethod('POST');
		return req;
	}

	/**
	 * @description : Constructs request needed to synchronize a JIRA issue from provided parameters.
	 * @param baseUrl 
	 * @param username 
	 * @param password 
	 * @param jProjectKey 
	 * @param componentID 
	 * @return : HTTP Request
	 */
	public static HttpRequest buildComponentRequest(String baseUrl, String username, String password, String jProjectKey, String componentID) {
		HttpRequest req = new HttpRequest();
		String basicAuthHeader = JIRAConnectorClass.authHeader(username, password);
		String endpoint = getComponentEndpoint(baseUrl, jProjectKey);
		req.setHeader('Authorization', basicAuthHeader);
		req.setHeader('Accept', 'application/json');
		req.setHeader('Content-Type', 'application/json');
		req.setBody('{"fields": {"components": [{"id": "' + componentID + '"}]}}');
		req.setEndpoint(endpoint);
		req.setMethod('PUT');
		return req;
	}

	/**
	 * @description : Build HTTP Request to push SFDC Comment to JIRA
	 * @param baseUrl 
	 * @param username 
	 * @param password 
	 * @param jProjectKey 
	 * @param sfdcComment 
	 * @return : HTTP Request
	 */
	public static HttpRequest buildCommentRequest(String baseUrl, String username, String password, String jProjectKey, String sfdcComment, String jCommentId) {
		HttpRequest req = new HttpRequest();
		String basicAuthHeader = JIRAConnectorClass.authHeader(username, password);
		String endpoint = getPostCommentEndpoint(baseUrl, jProjectKey, jCommentId);
		req.setHeader('Authorization', basicAuthHeader);
		req.setHeader('Accept', 'application/json');
		req.setHeader('Content-Type', 'application/json');
		req.setBody('{"body":{"type":"doc","version":1,"content":[{"type":"paragraph","content":[{"text":"' + sfdcComment + '","type":"text"}]}]}}');
		req.setEndpoint(endpoint);
		if (jCommentId != null && jCommentId != '') {
			req.setMethod('PUT');
		}
		else {
			req.setMethod('POST');
		}

		return req;
	}

	/**
	 * @description : Build HTPP Request to DELETE JIRA comment when SFDC Comment got deleted
	 * @param baseUrl 
	 * @param username 
	 * @param password 
	 * @param jProjectKey 
	 * @param jCommentId 
	 * @return : HTTP Request
	 */
	public static HttpRequest buildDeleteCommentRequest(String baseUrl, String username, String password, String jProjectKey, String jCommentId) {
		HttpRequest req = new HttpRequest();
		String basicAuthHeader = JIRAConnectorClass.authHeader(username, password);
		String endpoint = getPostCommentEndpoint(baseUrl, jProjectKey, jCommentId);
		req.setHeader('Authorization', basicAuthHeader);
		req.setEndpoint(endpoint);
		req.setMethod('DELETE');
		return req;
	}

	/**
	 * @description : Build HTPP Request to POST SFDC Case owner to JIRA Watcher
	 * @param baseUrl 
	 * @param username 
	 * @param password 
	 * @param jProjectKey 
	 * @param jUserAccountId 
	 * @return : HTTP Request
	 */
	public static HttpRequest buildPostWatcherRequest(String baseUrl, String username, String password, String jProjectKey, String jUserAccountId) {
		HttpRequest req = new HttpRequest();
		String basicAuthHeader = JIRAConnectorClass.authHeader(username, password);
		String endpoint = getPostWatcherEndpoint(baseUrl, jProjectKey);
		req.setHeader('Authorization', basicAuthHeader);
		req.setHeader('Accept', 'application/json');
		req.setHeader('Content-Type', 'application/json');
		req.setBody('"' + jUserAccountId + '"');
		req.setEndpoint(endpoint);
		req.setMethod('POST');
		return req;
	}

	/**
	 * @description : Creates the endpoint to synchronize the issue from provided parameters.
	 * @param baseUrl : Base JIRA instance URL
	 * @param jProjectKey : JIRA ticket Key
	 * @return : Full end point URL
	 */
	private static String getTransitionEndpoint(String baseUrl, String jProjectKey) {
		return baseUrl + '/rest/api/3/issue/' + jProjectKey + '/transitions';
	}

	/**
	 * @description : Creates the endpoint to synchronize the issue from provided parameters.
	 * @param baseUrl : Base JIRA instance URL
	 * @param jProjectKey : JIRA ticket Key
	 * @return : Full end point URL
	 */
	private static String getComponentEndpoint(String baseUrl, String jProjectKey) {
		return baseUrl + '/rest/api/3/issue/' + jProjectKey;
	}

	/**
	 * @description : Creates the endpoint to push Salesforce Case Comment to the JIRA issue from provided parameters.
	 * @param baseUrl : Base JIRA instance URL
	 * @param jProjectKey : JIRA ticket Key
	 * @return : Full end point URL
	 */
	private static String getPostCommentEndpoint(String baseUrl, String jProjectKey, String jiraCommentId) {
		if (jiraCommentId != null && jiraCommentId != '') {
			return baseUrl + '/rest/api/3/issue/' + jProjectKey + '/comment/' + jiraCommentId;
		}
		else {
			return baseUrl + '/rest/api/3/issue/' + jProjectKey + '/comment';
		}
	}

	/**
	 * @description : : Creates the endpoint to add Case owner as Watcher in JIRA issue from provided parameters.
	 * @param baseUrl : Base JIRA instance URL
	 * @param jProjectKey : JIRA ticket Key
	 * @return : Full end point URL
	 */
	private static String getPostWatcherEndpoint(String baseUrl, String jProjectKey) {
		return baseUrl + '/rest/api/3/issue/' + jProjectKey + '/watchers';
	}
}