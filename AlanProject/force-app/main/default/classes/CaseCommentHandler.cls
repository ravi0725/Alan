/*****************************************************************************************
  Name    : CaseCommentHandler
  Desc    : Class used for CaseComment trigger
 
  Modification Log : 
  ===========================================================================
  Developer				Date				Description
  ===========================================================================
  Suresh Babu Murugan		03/Apr/2019		Created
  Suresh Babu Murugan		03/Apr/2019		Added functionality to sync Case Comments to JIRA global Comment section
 ******************************************************************************************/
public class CaseCommentHandler {
	public static Map<String, Integer> mapLaunchControl;
	public static Boolean blnJIRACalloutRestrict = false;
	public static Boolean blnJIRAIDMappingRestrict = false;

	/**
	 * @description : Static initialize
	 */
	static {
		resetLaunchControl();
	}

	/**
	 * @description : Reset Trigger control (e.g. for testing)
	 */
	public static void resetLaunchControl() {
		mapLaunchControl = new Map<String, Integer> ();
		mapLaunchControl.put('afterTriggerCaseCommentActions', 0);
		mapLaunchControl.put('afterTriggerDeleteCaseCommentActions', 0);
	}

	/**
	 * @description : Set Trigger control (e.g. for testing)
	 */
	public static void setLaunchControl() {
		mapLaunchControl = new Map<String, Integer> ();
		mapLaunchControl.put('afterTriggerCaseCommentActions', 1);
		mapLaunchControl.put('afterTriggerDeleteCaseCommentActions', 1);
	}

	/**
	 * @description : Method used to return CaseComment JIRA mapping as map collection
	 * @param parentCaseId 
	 * @return : Map<Id, String> Key - CaseCommentId, Value - JIRA Comment ID
	 */
	public static Map<Id, String> returnCaseCommentJIRAIDMapping(Id parentCaseId) {
		Map<Id, String> mapCaseComments = new Map<Id, String> ();
		List<Case> lstCases = [SELECT Id, CaseComment_JIRA_Mapping__c FROM Case WHERE Id = :parentCaseId LIMIT 1];
		if (lstCases[0].CaseComment_JIRA_Mapping__c != null && lstCases[0].CaseComment_JIRA_Mapping__c.contains(';')) {
			List<String> lstFirstlevelSplit = (lstCases[0].CaseComment_JIRA_Mapping__c.contains(';') ? lstCases[0].CaseComment_JIRA_Mapping__c.split(';') : null);
			System.debug('lstFirstlevelSplit ====>' + lstFirstlevelSplit);
			if (lstFirstlevelSplit != null) {
				for (String spl : lstFirstlevelSplit) {
					List<String> lstSecondlevelSplit = (spl.contains('=>') ? spl.split('=>') : null);
					System.debug('lstSecondlevelSplit ====>' + lstSecondlevelSplit);
					if (lstSecondlevelSplit != null && lstSecondlevelSplit.size() == 2) {
						mapCaseComments.put(lstSecondlevelSplit.get(0).trim(), lstSecondlevelSplit.get(1).trim());
					}
				}
				System.debug(' mapCaseComments ==>' + mapCaseComments);
			}
		}
		return mapCaseComments;
	}

	/**
	 * @description : After Insert CaseComment actions
	 * @param lstCaseComments 
	 */
	public static void afterTriggerCaseCommentActions(List<CaseComment> lstCaseComments, Boolean blnIsAfter, Boolean blnIsInsert, Boolean blnIsUpdate) {
		if (mapLaunchControl.get('afterTriggerCaseCommentActions') < 1) {
			mapLaunchControl.put('afterTriggerCaseCommentActions', mapLaunchControl.get('afterTriggerCaseCommentActions') + 1);

			if (UserInfo.getName() != 'Data Administrator' && blnIsAfter && (blnIsInsert || blnIsUpdate)) {
				Set<Id> setCaseIDs = new Set<Id> ();
				Map<Id, String> mapCaseComments = new Map<Id, String> ();
				Map<Id, Id> mapCaseWithCaseComments = new Map<Id, Id> ();
				for (CaseComment cc : lstCaseComments) {
					setCaseIDs.add(cc.ParentId);
					mapCaseComments.put(cc.ParentId, cc.CommentBody);
					mapCaseWithCaseComments.put(cc.ParentId, cc.Id);
				}

				if (setCaseIDs.size() > 0) {
					List<Case> lstUpdateCases = [SELECT Id, Record_Type_Name__c, SPR__c, Application__c, TFS_Id__c, Product__c FROM Case WHERE Id IN :setCaseIDs];

					// Only sync to Space Scheduling JIRA when this values are changed in Cases
					for (Case cs : lstUpdateCases) {
						if (!CaseCommentHandler.blnJIRACalloutRestrict) {
							CaseCommentHandler.blnJIRACalloutRestrict = true;

							if (cs.Record_Type_Name__c == 'RE&WS - Support' && cs.SPR__c != null && (cs.Application__c == 'Space Scheduling' || cs.Application__c == 'Manhattan')) {
								system.debug('Do callout to update Comments to JIRA...................');
								JIRAConnectorWebserviceCalloutSync.synchronizeWithJIRAIssue(JIRAConnectorClass.baseUrl, JIRAConnectorClass.systemId, 'Case', cs.Id);
							}

							if (blnIsInsert && mapCaseComments.containsKey(cs.Id) && cs.Record_Type_Name__c == 'GCCM - Support Issue Record Type' && cs.TFS_Id__c != null && !cs.TFS_Id__c.isNumeric() && (cs.Product__c.contains('ProjectSight') || cs.Product__c.contains('Prolog') || cs.Product__c.contains('Proliance') || cs.Product__c.contains('Message Bus') || cs.Product__c.contains('Field Mgmt'))) {
								System.debug('Do callout to update Comments to JIRA...................');
								System.debug(mapCaseComments.get(cs.Id));
								PPMConnectorSyncJIRAStatus.updateJIRAComment(cs.TFS_Id__c, cs.Product__c, mapCaseComments.get(cs.Id), cs.Id, mapCaseWithCaseComments.get(cs.Id), true);
							}

							if (blnIsUpdate && mapCaseComments.containsKey(cs.Id) && cs.Record_Type_Name__c == 'GCCM - Support Issue Record Type' && cs.TFS_Id__c != null && !cs.TFS_Id__c.isNumeric() && (cs.Product__c.contains('ProjectSight') || cs.Product__c.contains('Prolog') || cs.Product__c.contains('Proliance') || cs.Product__c.contains('Message Bus') || cs.Product__c.contains('Field Mgmt'))) {
								PPMConnectorSyncJIRAStatus.updateJIRAComment(cs.TFS_Id__c, cs.Product__c, mapCaseComments.get(cs.Id), cs.Id, mapCaseWithCaseComments.get(cs.Id), false);
							}
						}
					}
				}
			}
		}
	}

	/**
	* @description 
	* @param lstOldCaseComments 
	* @param blnIsAfter 
	* @param blnIsDelete 
	*/ 
	public static void afterTriggerDeleteCaseCommentActions(List<CaseComment> lstOldCaseComments, Boolean blnIsAfter, Boolean blnIsDelete) {
		if (mapLaunchControl.get('afterTriggerDeleteCaseCommentActions') < 1) {
			mapLaunchControl.put('afterTriggerDeleteCaseCommentActions', mapLaunchControl.get('afterTriggerDeleteCaseCommentActions') + 1);

			if (blnIsAfter && blnIsDelete) {
				Set<Id> setCaseIDs = new Set<Id> ();
				Map<Id, String> mapCaseComments = new Map<Id, String> ();
				Map<Id, Id> mapCaseWithCaseComments = new Map<Id, Id> ();
				for (CaseComment cc : lstOldCaseComments) {
					setCaseIDs.add(cc.ParentId);
					mapCaseComments.put(cc.ParentId, cc.CommentBody);
					mapCaseWithCaseComments.put(cc.ParentId, cc.Id);
				}

				if (setCaseIDs.size() > 0) {
					List<Case> lstUpdateCases = [SELECT Id, Record_Type_Name__c, SPR__c, Application__c, TFS_Id__c, Product__c FROM Case WHERE Id IN :setCaseIDs];

					// Only sync to Space Scheduling JIRA when this values are changed in Cases
					for (Case cs : lstUpdateCases) {
						if (!CaseCommentHandler.blnJIRACalloutRestrict) {
							CaseCommentHandler.blnJIRACalloutRestrict = true;

							if (blnIsDelete && mapCaseComments.containsKey(cs.Id) && cs.Record_Type_Name__c == 'GCCM - Support Issue Record Type' && cs.TFS_Id__c != null && !cs.TFS_Id__c.isNumeric() && (cs.Product__c.contains('ProjectSight') || cs.Product__c.contains('Prolog') || cs.Product__c.contains('Proliance') || cs.Product__c.contains('Message Bus') || cs.Product__c.contains('Field Mgmt'))) {
								PPMConnectorSyncJIRAStatus.deleteJIRAComment(cs.TFS_Id__c, cs.Product__c,  cs.Id, mapCaseWithCaseComments.get(cs.Id), blnIsDelete);
							}
						}
					}
				}
			}
		}
	}
}