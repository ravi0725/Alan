/*****************************************************************************************
  Name    : CaseHandler
  Modification Log : 
  ---------------------------------------------------------------------------
  Developer              Date            Description
  ---------------------------------------------------------------------------
  Ankur Patel       03/08/2015          Created
 ******************************************************************************************/
public class CaseHandler {
	public static Map<String, Integer> launchControl;
	public static String errorMessage;
	public static boolean bl = true;
	public static boolean sendTFSItegration = true;
	// Static initialize
	static {
		resetLaunchControl();
	}

	// Reset Trigger control (e.g. for testing)
	public static void resetLaunchControl() {
		launchControl = new Map<String, Integer> ();
		launchControl.put('configCase', 0);
		launchControl.put('notifyCaseOwnersForPlanningPriority', 0);
		launchControl.put('copyChatTranscriptsToCloneCase', 0);
		launchControl.put('attachIssueToCase', 0);
		launchControl.put('populateProductCaseGCCM', 0);
		launchControl.put('Case24HoursNotification', 1);
		launchControl.put('clearFields', 0);
		launchControl.put('createTFSTrackingHistory', 0);
		launchControl.put('validateBeforeTFSCallout', 0);
		launchControl.put('CaseCountOnIssue', 0);
		launchControl.put('setStatusReason', 0);
		launchControl.put('TFSIntegrationCheck', 0);
		launchControl.put('MEPNACaseConfig', 0);
		launchControl.put('updateContactLastSurveyDate', 0);
		launchControl.put('TAPCaseConfig', 0);
		launchControl.put('validateOpenActivityRelatedToCase', 0);
	}

	// Reset Trigger control (e.g. for testing)
	public static void setLaunchControl() {
		launchControl = new Map<String, Integer> ();
		launchControl.put('configCase', 1);
		launchControl.put('notifyCaseOwnersForPlanningPriority', 1);
		launchControl.put('copyChatTranscriptsToCloneCase', 1);
		launchControl.put('attachIssueToCase', 1);
		launchControl.put('populateProductCaseGCCM', 1);
		launchControl.put('Case24HoursNotification', 1);
		launchControl.put('clearFields', 1);
		launchControl.put('createTFSTrackingHistory', 1);
		launchControl.put('validateBeforeTFSCallout', 1);
		launchControl.put('CaseCountOnIssue', 1);
		launchControl.put('setStatusReason', 1);
		launchControl.put('TFSIntegrationCheck', 1);
		launchControl.put('MEPNACaseConfig', 1);
		launchControl.put('updateContactLastSurveyDate', 1);
		launchControl.put('TAPCaseConfig', 1);
		launchControl.put('validateOpenActivityRelatedToCase', 1);
	}


	//Update Last Survey Date on Contact
	public static void updateContactLastSurveyDate(List<Case> lstCases, Map<Id, Case> mapOldCases) {
		if (launchControl.get('updateContactLastSurveyDate') < 1) {
			List<Contact> lstContacts = new List<Contact> ();
			for (Case oCase : lstCases) {
				system.debug('-------oCase.Survey_Email_Sent_Date__c-------' + oCase.Survey_Email_Sent_Date__c);
				if (oCase.ContactId != null && ((oCase.Record_Type_Name__c == 'MEP Customer Support' && oCase.Status == 'Closed' && oCase.Status != mapOldCases.get(oCase.Id).Status &&
				                                 oCase.Representative_Knowledge__c == null && oCase.Survey_Email_Sent_Date__c != mapOldCases.get(oCase.Id).Survey_Email_Sent_Date__c) ||
				(oCase.Record_Type_Name__c == 'TAP - Customer Support' && oCase.Status == 'Closed' && oCase.Status != mapOldCases.get(oCase.Id).Status
				 && oCase.Survey_Email_Sent_Date__c != mapOldCases.get(oCase.Id).Survey_Email_Sent_Date__c))) {
					Contact oContact = new Contact();
					oContact.Id = oCase.ContactId;
					oContact.Last_Case_Survey_Sent__c = date.today();
					lstContacts.add(oContact);
				}
			}
			system.debug('-------lstContacts-------' + lstContacts);
			if (lstContacts.size() > 0) {
				launchControl.put('updateContactLastSurveyDate', 1);
				Map<Id, String> mapErrorContacts = new Map<Id, String> ();
				Integer iCount = 0;
				for (Database.saveResult result : Database.update(lstContacts, false)) {
					system.debug('-------result.isSuccess()-------' + result.isSuccess());
					if (!result.isSuccess()) {
						for (Database.Error er : result.getErrors()) {
							mapErrorContacts.put(lstContacts[iCount].Id, er.getMessage());
							system.debug('-------er.getMessage()-------' + er.getMessage());
						}
					}
					iCount++;
				}

				for (Case oCase : lstCases) {
					if (mapErrorContacts.containsKey(oCase.ContactId)) {
						oCase.addError(mapErrorContacts.get(oCase.ContactId));
					}
				}
			}
		}
	}

	//Populate default Entitlement and business hours for MEP NA case
	public static void MEPNACaseConfig(List<Case> lstNewCases) {
		if (launchControl.get('MEPNACaseConfig') < 1) {
			launchControl.put('MEPNACaseConfig', launchControl.get('MEPNACaseConfig') + 1);
			List<Case> lstCases = new List<Case> ();
			for (Case oCase : lstNewCases) {
				if (oCase.Record_Type_Name__c == Label.MEP_NA_Case_Record_Type) {
					lstCases.add(oCase);
				}
			}
			system.debug('--------lstCases--------' + lstCases);
			if (lstCases.size() > 0) {
				Map<String, Id> mapBusinessHours = new Map<String, Id> ();
				Id entitlementId = null;
				for (Entitlement oEntitlement :[select Id from Entitlement where Name = :Label.MEPNA_Default_Entitlement]) {
					entitlementId = oEntitlement.Id;
				}

				for (BusinessHours oBusinessHours :[select ID, Name from BusinessHours where name like 'MEPNA%']) {
					mapBusinessHours.put(oBusinessHours.Name, oBusinessHours.Id);
				}
				system.debug('--------entitlementId--------' + entitlementId);

				Map<String, String> mapBusinessHoursConfig = new Map<String, String> ();
				for (MEPNA_Business_Hours_Config__c oBusinessHoursConfig : MEPNA_Business_Hours_Config__c.getAll().Values()) {
					mapBusinessHoursConfig.put(oBusinessHoursConfig.Product__c, oBusinessHoursConfig.Business_Hours__c);
				}

				for (Case oCase : lstCases) {
					if (!MEPNA_Default_Business_Hour_Users__c.getAll().containsKey(userinfo.getUserName())) {
						if (mapBusinessHoursConfig.containskey(oCase.Product_MEP__c)) {
							if (mapBusinessHours.containsKey(mapBusinessHoursConfig.get(oCase.Product_MEP__c))) oCase.BusinessHoursId = mapBusinessHours.get(mapBusinessHoursConfig.get(oCase.Product_MEP__c));
							else if (mapBusinessHours.containsKey('MEPNA - QuickPen Support')) oCase.BusinessHoursId = mapBusinessHours.get('MEPNA - QuickPen Support');
						} else if (mapBusinessHoursConfig.containskey(oCase.Product_Family_Plancal__c)) {
							if (mapBusinessHours.containsKey(mapBusinessHoursConfig.get(oCase.Product_Family_Plancal__c))) oCase.BusinessHoursId = mapBusinessHours.get(mapBusinessHoursConfig.get(oCase.Product_Family_Plancal__c));
							else if (mapBusinessHours.containsKey('MEPNA - QuickPen Support')) oCase.BusinessHoursId = mapBusinessHours.get('MEPNA - QuickPen Support');
						} else if (mapBusinessHours.containsKey('MEPNA - QuickPen Support')) oCase.BusinessHoursId = mapBusinessHours.get('MEPNA - QuickPen Support');
					} else {
						oCase.BusinessHoursId = mapBusinessHours.get('MEPNA - Default Business Hours');
					}

					//Default entitlement
					if (oCase.Record_Type_Name__c == Label.MEP_NA_Case_Record_Type)
					oCase.EntitlementId = entitlementId;
					system.debug('--------oCase--------' + oCase);
				}
			}
		}
	}

	//Populate default Entitlement and business hours for TAP case
	public static void TAPCaseConfig(List<Case> newCaseList) {
		Id businessHoursId;
		boolean tapCase = false;
		Map<Id, Contact> contactMap = new Map<Id, Contact> ();
		Map<Id, Entitlement> asstEntMap = new Map<Id, Entitlement> ();
		Map<Id, Asset> asstAccountMap = new Map<Id, Asset> ();

		for (Case cs : newCaseList) {
			if (cs.Record_Type_Name__c == 'TAP - Customer Support' && cs.AssetId != NULL) {
				asstEntMap.put(cs.AssetId, null);
				asstAccountMap.put(cs.AssetId, null);
			}

			if (cs.Record_Type_Name__c == 'TAP - Customer Support') {
				tapCase = true;
			}

			if (cs.Record_Type_Name__c == 'TAP - Customer Support' && cs.ContactId != null) {
				contactMap.put(cs.contactId, null);
			}
		}

		if (tapCase) {
			for (BusinessHours bh :[select ID, Name from BusinessHours where name like 'TAP - Business Hours']) {
				businessHoursId = bh.Id;
			}
		}

		if (contactMap.size() > 0) {
			for (Contact contactCountry :[SELECT Selected_Address__c, Address__r.country__c, Address__r.State__c, Address__r.City__c, ID FROM contact WHERE ID IN :contactMap.keyset()]) {
				contactMap.put(contactCountry.ID, contactCountry);
			}
		}
		system.debug('MAP =============' + contactMap);
		ID EntitlementId;
		for (Asset asst :[SELECT ID, Name, Account.name, SerialNumber,
		(select Id, StartDate, EndDate, Entitlement_Product__r.Product_Group__c, Entitlement_Product__r.Product_Line__c, Bill_To_Account__r.name, Geofence_Region__c, Bill_To_Address__r.Price_List__c, Duration__c, Days_Left__c
		 from Entitlements
		 ORDER BY EndDate DESC
		 LIMIT 1)
		     FROM Asset
		     where Id in :asstEntMap.keySet() OR Name = :Label.Trimble_TAP_Generic_Asset]) {
			if (asst.Entitlements.size() > 0)
			asstEntMap.put(asst.Id, asst.Entitlements.get(0));
			asstAccountMap.put(asst.Id, asst);
			if (asst.Name == Label.Trimble_TAP_Generic_Asset && asst.Entitlements.size() > 0)
			EntitlementId = asst.Entitlements.get(0).Id;
		}

		system.debug('----------asstEntMap------' + asstEntMap);
		for (Case cs : newCaseList) {
			if (cs.Record_Type_Name__c == 'TAP - Customer Support') {
				cs.BusinessHoursId = businessHoursId;
			}

			if (cs.Record_Type_Name__c == 'TAP - Customer Support' && cs.ContactId != null && contactMap.containsKey(cs.ContactId)) {
				cs.Contact_Address__c = contactMap.get(cs.contactID).Selected_Address__c;
			}
			if (cs.Record_Type_Name__c == 'TAP - Customer Support' && (cs.EntitlementId == NULL || cs.EntitlementId == EntitlementId)) {
				if (asstEntMap.get(cs.AssetId) != NULL) {
					cs.Serial_Number__c = asstAccountMap.get(cs.AssetId).SerialNumber;
					cs.EntitlementId = asstEntMap.get(cs.AssetId).Id;
					cs.Entitlement_Start_Date__c = asstEntMap.get(cs.AssetId).StartDate;
					cs.Entitlement_End_Date__c = asstEntMap.get(cs.AssetId).EndDate;
					cs.More_Information__c = 'Entitlement Invoice To Name : ' + (asstEntMap.get(cs.AssetId).Bill_To_Account__r.name != NULL ? asstEntMap.get(cs.AssetId).Bill_To_Account__r.name : '') + '\n' +
					'Geofence : ' + (asstEntMap.get(cs.AssetId).Geofence_Region__c != NULL ? asstEntMap.get(cs.AssetId).Geofence_Region__c : '') + '\n' +
					'Price List : ' + (asstEntMap.get(cs.AssetId).Bill_To_Address__r.Price_List__c != NULL ? asstEntMap.get(cs.AssetId).Bill_To_Address__r.Price_List__c : '') + '\n' +
					'Duration : ' + (asstEntMap.get(cs.AssetId).Duration__c != NULL ? string.valueOf(asstEntMap.get(cs.AssetId).Duration__c) : '') + '\n' +
					'Days Left : ' + asstEntMap.get(cs.AssetId).Days_Left__c + '\n' +
					'Asset Owner : ' + asstAccountMap.get(cs.AssetId).Account.name + '\n';
				}
				if (cs.EntitlementId == NULL)
				cs.EntitlementId = EntitlementId;
				system.debug('----------cs.EntitlementId------' + cs.EntitlementId);
			}
			system.debug(String.isBlank(cs.To_Address__c) + '----------cs.Record_Type_Name__c------' + (cs.Record_Type_Name__c == 'TAP - Customer Support'));
			system.debug((cs.Origin != 'Email') + '----------cs.Record_Type_Name__c------' + (cs.ContactId != null));
			if (cs.Record_Type_Name__c == 'TAP - Customer Support' && cs.ContactId != null && cs.Origin != 'Email' && String.isBlank(cs.To_Address__c) && Country_Region_Mapping__c.getAll().containsKey(contactMap.get(cs.contactID).Address__r.country__c)) {
				cs.Language__c = Country_Region_Mapping__c.getAll().get(contactMap.get(cs.contactID).Address__r.country__c).TAPLanguage__c;
				system.debug('----------cs.Language__c------' + cs.Language__c);
			} else if (cs.Record_Type_Name__c == 'TAP - Customer Support' && cs.Origin == 'Email' && !String.isBlank(cs.To_Address__c) && TAP_Email_Language_Mapping__c.getAll().containsKey(cs.To_Address__c)) {
				cs.Language__c = TAP_Email_Language_Mapping__c.getAll().get(cs.To_Address__c).Language__c;
			} else if (cs.Record_Type_Name__c == 'TAP - Customer Support' && cs.Origin == 'Email' && !String.isBlank(cs.CC_Address__c) && TAP_Email_Language_Mapping__c.getAll().containsKey(cs.CC_Address__c)) {
				cs.Language__c = TAP_Email_Language_Mapping__c.getAll().get(cs.CC_Address__c).Language__c;
			} else {
				cs.Language__c = 'E_AM';
			}
			system.debug('----------cs.Language__c------' + cs.Language__c);
		}

	}

	public static void removeCreditCardNumber(List<Case> newCaseList) {
		String reGexVisa = '\\d\\d\\d\\d[ -]?\\d\\d\\d\\d[ -]?\\d\\d\\d\\d[ -]?\\d\\d\\d\\d';

		for (Case cs : newCaseList) {
			if (cs.Record_Type_Name__c == 'TAP - Customer Support' && cs.Description != NULL) {
				cs.Description = cs.Description.replaceAll(reGexVisa, 'XXXX XXXX XXXX XXXX');
				cs.Short_Description__c = cs.Short_Description__c.replaceAll(reGexVisa, 'XXXX XXXX XXXX XXXX').left(255);
			}
		}
	}

	public static void validateOpenActivityRelatedToCase(List<Case> csList) {
		if (launchControl.get('validateOpenActivityRelatedToCase') < 1) {
			launchControl.put('validateOpenActivityRelatedToCase', 1);
			Map<Id, Case> csClosedMap = new Map<Id, Case> ([select Id, (select Id from Tasks where Status != 'Completed'),
			(Select ID from Events where EndDateTime >= :system.now()) from Case where Id in :csList]);
			for (Case cs : csList) {
				if (cs.Record_Type_Name__c == 'TAP - Customer Support' && (cs.Status == 'Closed' || cs.Status == 'Closed, Not a Support Case') && (csClosedMap.get(cs.Id).Tasks.size() != 0 || csClosedMap.get(cs.Id).Events.size() != 0)) {
					cs.addError('This case cannot be closed because it has open activities.');
				}
			}
		}
	}

	// Reset Trigger control (e.g. for testing)
	public static void setStatusReason(List<Case> newCaseList, Map<Id, Case> oldCaseMap) {
		if (launchControl.get('setStatusReason') < 1) {
			launchControl.put('setStatusReason', launchControl.get('setStatusReason') + 1);
			for (Case cs : newCaseList) {
				if (cs.Record_Type_Name__c == Label.GCCM_Support_Case_Record_Type) {
					string objPrefix = (String) cs.OwnerId;
					String statusReason = (cs.status_reason__c == null ? '' : cs.status_reason__c);
					if (cs.OwnerId != oldCaseMap.get(cs.ID).OwnerId && cs.Status != 'Closed' && !statusReason.contains('Escalated')) {
						if (objPrefix.left(3) != '00G') {
							cs.Status = 'Open';
							cs.status_reason__c = 'Assigned to Analyst';
						} else {
							cs.Status = 'Open';
							cs.status_reason__c = 'New Unassigned';
						}
					}
				}
			}
		}
	}

	// Create Case from Opportunity and Order
	public static case createCaseAfterOpportunityOrderProcess(ID accountId, ID billToContactId, String sSubject, List<Group> lstOwnerIdFromQueue, String sOracleOrderNumber, String sQuoteNumber) {
		Case oCase = new Case();
		oCase.Origin = 'Phone';
		oCase.AccountId = accountId;
		oCase.Product_Family_Plancal__c = 'Estimation';
		oCase.Type = 'Support';
		oCase.Severity_c__c = 'Severity 3: Moderate';
		oCase.Status = 'New';
		oCase.Subject = sSubject;
		oCase.OwnerId = (lstOwnerIdFromQueue.size() > 0 ? lstOwnerIdFromQueue.get(0).Id : null);
		oCase.ContactId = billToContactId;
		oCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MEP Customer Support').getRecordTypeId();
		oCase.IsOrderFulfillmentCase__c = true;
		if (sOracleOrderNumber != '')
		oCase.OrderNumber__c = sOracleOrderNumber;
		if (sQuoteNumber != '')
		oCase.QuoteNumber__c = sQuoteNumber;

		return oCase;
	}

	//Method to populate No if Linked Issues to Case
	public static void CaseCountOnIssue(List<Case> newCaseList, Map<Id, Case> oldCaseMap) {
		set<Id> issueLinkToCase = new set<Id> ();
		List<Case> updateCase = new List<Case> ();
		Map<Id, String> mapAccountNames = new Map<Id, String> ();
		if (launchControl.get('CaseCountOnIssue') < 1) {
			launchControl.put('CaseCountOnIssue', launchControl.get('CaseCountOnIssue') + 1);
			for (Case cs : newCaseList) {

				if (cs.Defect__c != null && cs.Record_Type_Name__c == Label.GCCM_Support_Case_Record_Type) {
					issueLinkToCase.add(cs.Defect__c);
				} else if (cs.Defect__c == null && (oldCaseMap.size() > 0 ? oldCaseMap.get(cs.Id).Defect__c != null : false)) {
					Case tempCs = new Case();
					tempCs.Id = oldCaseMap.get(cs.Id).Defect__c;
					tempCs.No_Of_Linked_SI_s__c = 0;
					updateCase.add(tempCs);
				}
			}

			for (AggregateResult accAG :[SELECT Account.Name accName, Defect__c defect FROM Case WHERE Defect__c IN :issueLinkToCase GROUP BY Account.Name, Defect__c]) {
				if (mapAccountNames.containsKey(accAG.get('defect').toString())) {
					mapAccountNames.put(Id.valueOf(accAG.get('defect').toString()), mapAccountNames.get(accAG.get('defect').toString()) + '\n' + accAG.get('accName'));
				}
				else {
					mapAccountNames.put(Id.valueOf(accAG.get('defect').toString()), accAG.get('accName').toString());
				}
			}

			if (issueLinkToCase.size() > 0) {
				for (AggregateResult ag :[Select count(ID) total, Defect__c defect from Case where Defect__c in :issueLinkToCase group by Defect__c]) {
					if (((decimal) ag.get('total')) > 0) {
						Case cs = new Case();
						cs.Id = (Id) ag.get('defect');
						cs.No_Of_Linked_SI_s__c = (decimal) ag.get('total');
						cs.Support_Issue_Customer_Names__c = (mapAccountNames.containsKey(ag.get('defect').toString()) ? mapAccountNames.get(ag.get('defect').toString()) : null);
						updateCase.add(cs);
					}
				}
			}
			if (updateCase.size() > 0) {
				CaseHandler.setLaunchControl();
				launchControl.put('validateBeforeTFSCallout', 0);
				update updateCase;
			}
		}
	}

	//--------------new method start for September release-----------------
	public static void createTFSTrackingHistory(Map<Id, Case> csMap, List<Case> csList, boolean isInsert) {
		if (launchControl.get('createTFSTrackingHistory') < 1) {
			launchControl.put('createTFSTrackingHistory', launchControl.get('createTFSTrackingHistory') + 1);
			List<Tracking_Field_History__c> fthList = new List<Tracking_Field_History__c> ();
			for (Case cs : csList) {
				if (!isInsert) {
					if (csMap.get(cs.Id).TFS_Status__c != cs.TFS_Status__c && cs.Record_Type_Name__c == Label.GCCM_Support_Issue_Record_Type) {
						Tracking_Field_History__c fth = new Tracking_Field_History__c();
						fth.Old_Value__c = csMap.get(cs.Id).TFS_Status__c;
						fth.New_Value__c = cs.TFS_Status__c;
						fth.Changed_Date__c = system.now();
						fth.Case__c = cs.Id;
						fth.User__c = userinfo.getUserId();
						fth.Field_Name__c = 'TFS Status';
						fthList.add(fth);
					}
				} else if (isInsert) {
					if (cs.TFS_Status__c != null && cs.Record_Type_Name__c == Label.GCCM_Support_Issue_Record_Type) {
						Tracking_Field_History__c fth = new Tracking_Field_History__c();
						fth.Old_Value__c = '';
						fth.New_Value__c = cs.TFS_Status__c;
						fth.Changed_Date__c = system.now();
						fth.Case__c = cs.Id;
						fth.User__c = userinfo.getUserId();
						fth.Field_Name__c = 'TFS Status';
						fthList.add(fth);
					}
				}

			}
			if (fthList.size() > 0) insert fthList;
		}
	}
	//--------------new method end-----------------

	public static void Case24HoursNotification(List<Case> newCaseList, map<Id, Case> oldMap) {
		if (launchControl.get('Case24HoursNotification') < 1) {
			launchControl.put('Case24HoursNotification', launchControl.get('Case24HoursNotification') + 1);
			Datetime CurrentDate = system.Now();
			Datetime Case24HoursTimeStamp;

			//Get the id for buisness hours for GCCM 24/5_Support
			BusinessHours stdBusinessHours = [select id from businesshours where Name = :Label.GCCM_24_5_Support];
			//23 hours = 82800000 milliseconds and 24 hours == 86400000 milliseconds
			//Used 23 hours in the trigger because it will add 1 more hours from time based workflow
			Case24HoursTimeStamp = BusinessHours.addGmt(stdBusinessHours.id, CurrentDate, 86400000);

			for (Case cs : newCaseList) {
				if (cs.Case24HoursTimeStamp__c == null && cs.Record_Type_Name__c == Label.GCCM_Support_Case_Record_Type &&
				    cs.To_Address__c != null && cs.To_Address__c != '' && cs.Origin == 'Email' &&
				    cs.To_Address__c != oldMap.get(cs.Id).To_Address__c) {
					cs.Case24HoursTimeStamp__c = Case24HoursTimeStamp;
				}
			}
		}
	}

	//Method to populate Product and Product Family on case based on linked Asset
	public static void populateProductCaseGCCM(List<Case> csIdList, Map<Id, Case> oldMap) {
		if (launchControl.get('populateProductCaseGCCM') < 1) {
			launchControl.put('populateProductCaseGCCM', launchControl.get('populateProductCaseGCCM') + 1);
			List<Id> assetIdList = new List<Id> ();
			for (Case c : csIdList) {
				if (c.Record_Type_Name__c == Label.GCCM_Support_Case_Record_Type && c.AssetId != null &&
				(oldMap.containsKey(c.Id) ? c.AssetId != oldMap.get(c.Id).AssetId : true))
				assetIdList.add(c.AssetId);
			}

			if (assetIdList.size() > 0) {
				Map<Id, Asset> assetMap = new Map<Id, Asset> ();
				assetMap = new Map<Id, Asset> ([Select Id, Product2Id, Product2.Family from Asset where Id IN :assetIdList]);

				for (Case c : csIdList) {
					try {
						if (assetMap != null && assetMap.containsKey(c.AssetId))
						c.ProductId = assetMap.get(c.AssetId).Product2Id;
						c.Product_Family_Plancal__c = assetMap.get(c.AssetId).Product2.Family;
					} catch(Exception e) {
						c.addError(e.getMessage());
					}
				}
			}
		}
	}

	//Method to make callout and send issue details to TFS
	public static void makeCallout(List<Id> csIdList, boolean isupdate, boolean sendInteration) {
		try {
			errorMessage = '';
			Case cs = [select Id, WorkAround__c, Case.Assigned_Date__c, Case.Work_Product__c, Product__c, Assigned_To__c,
			           ParentId, Features__c, Resolution_Type__c, ClosedDate, Private_Notes__c, CreatedBy.Name, Resolution__c,
			           Notes__c, Fixed_In_Build__c, Steps_To_Reproduce__c, Found_In_Build__c, Status, Severity_c__c, Owner.Name, CaseNumber,
			           CreatedDate, Required_By__c,
			           Subject, Description, Type, TFS_Id__c, Record_Type_Name__c from Case where Id = :csIdList.get(0)];
			xmlnsOracleComTfssfdcTnvsfdcoutbound.CaseParamsType reqParam = new xmlnsOracleComTfssfdcTnvsfdcoutbound.CaseParamsType();

			TFS_Project_Config__c TFSConfig;

			if (TFS_Project_Config__c.getAll().get(cs.Product__c) != null ? TFS_Project_Config__c.getAll().get(cs.Product__c).Run_Integration__c : false) {
				TFSConfig = TFS_Project_Config__c.getAll().get(cs.Product__c);

				reqParam.TfsID = (cs.TFS_ID__c == null ? '' : cs.TFS_ID__c);
				system.debug('--------TfsID------------' + reqParam.TfsID);

				reqParam.Division = TFS_Project_Config__c.getAll().get(cs.Product__c).Division__c;

				reqParam.CaseNumber = cs.CaseNumber;
				system.debug('--------CaseNumber ------------' + reqParam.CaseNumber);

				reqParam.Description = (cs.Description == null ? '' : '\n' + cs.Description);
				reqParam.Description = reqParam.Description.replaceAll('\n', '<br>');
				if (reqParam.Division == 'Proliance') {
					List<Case> SIList = new List<Case> ();

					SIList = [select CaseNumber, Subject from CAse where Defect__c = :cs.Id];
					system.debug('--------SIList  ------------' + SIList);
					if (SIList.size() > 0) {
						reqParam.Description = reqParam.Description + '<br/><b>Related Cases : </b>';
						for (Case si : SIList) {
							reqParam.Description = reqParam.Description + '<br/>' + si.CaseNumber + ' - ' + si.Subject;
						}
					}
					system.debug('--------cs.Required_By__c------------' + cs.Required_By__c);
					if (cs.Required_By__c != null) reqParam.requiredByDate = cs.Required_By__c.month() + '-' + cs.Required_By__c.day() + '-' + cs.Required_By__c.year();
				}

				system.debug('--------Description ------------' + reqParam.Description);


				String severity;
				if (cs.Record_Type_Name__c == Label.GCCM_Support_Issue_Record_Type) severity = (cs.Severity_c__c == '1' ? '1 - Critical' : (cs.Severity_c__c == '2' ? '2 - High' : (cs.Severity_c__c == '3' ? '3 - Medium' : (cs.Severity_c__c == '4' ? '4 - Low' : ''))));
				reqParam.Severity = severity;
				system.debug('--------Severity ------------' + reqParam.Severity);

				reqParam.FoundInBuild = (cs.Found_In_Build__c == null ? '' : cs.Found_In_Build__c);
				system.debug('--------FoundInBuild ------------' + reqParam.FoundInBuild);

				reqParam.status = (cs.Status.contains('Closed') ? 'Closed' : '');
				system.debug('--------status ------------' + reqParam.status);

				reqParam.StepsToReproduce = (cs.Steps_To_Reproduce__c == null ? '' : '<br/>' + cs.Steps_To_Reproduce__c.replaceAll('\n', '<br/>'));
				system.debug('--------StepsToReproduce ------------' + reqParam.StepsToReproduce);

				reqParam.WorkAround = (cs.WorkAround__c == null ? '' : '<br/>' + cs.WorkAround__c.replaceAll('\n', '<br/>'));
				system.debug('--------WorkAround ------------' + reqParam.WorkAround);

				if (reqParam.Division != 'Proliance') reqParam.Notes = (cs.Notes__c == null ? '' : cs.Notes__c);
				system.debug('--------Notes ------------' + reqParam.Notes);

				/*if(reqParam.Division == 'Proliance') reqParam.Type_x = 'Enhancement Request';
				  else*/ reqParam.Type_x = (cs.Type == null ? '' : cs.Type);
				system.debug('--------Type_x------------' + reqParam.Type_x);



				reqParam.Features = (cs.Features__c == null ? '' : cs.Features__c);
				system.debug('--------Features ------------' + reqParam.Features);

				reqParam.WorkProduct = (cs.Work_Product__c != null ? cs.Work_Product__c : '');
				reqParam.Product = (cs.Product__c != null ? cs.Product__c : '');
				reqParam.CreatedBy = cs.CreatedBy.Name;
				system.debug('--------CreatedBy ------------' + reqParam.CreatedBy);

				reqParam.Subject = (cs.Subject == null ? '' : cs.Subject);
				system.debug('--------Subject ------------' + reqParam.Subject);

				reqParam.PrivateNotes = (cs.Private_Notes__c == null ? '' : cs.Private_Notes__c);
				system.debug('--------PrivateNotes ------------' + reqParam.PrivateNotes);

				reqParam.Area = TFSConfig.Area__c; // Area

				if (reqParam.Division == 'GCCM') reqParam.Iteration = TFSConfig.Iteration__c;
				else if (reqParam.Division == 'Proliance' && cs.Type == 'Enhancement Request') reqParam.Iteration = TFSConfig.Iteration__c + ' - ENHANCEMENT REQUESTS';
				else if (reqParam.Division == 'Proliance' && cs.Type != 'Enhancement Request') reqParam.Iteration = TFSConfig.Iteration__c + ' - All Versions';

				if (!sendInteration) reqParam.Iteration = '';
				if (reqParam.Division != 'Proliance') {
					reqParam.isConnect = TFSConfig.isConnect__c;
					reqParam.isConverge = TFSConfig.isConverge__c;
					reqParam.isManager = TFSConfig.isManager__c;
					reqParam.isSky = TFSConfig.isSky__c;
					reqParam.isIpad = TFSConfig.isIpad__c;
					reqParam.isWinTablet = TFSConfig.isWinTablet__c;
					reqParam.isOther = TFSConfig.isOther__c;
					reqParam.isIgnition = TFSConfig.isIgnition__c;
					reqParam.isWebService = TFSConfig.isWebService__c;
					reqParam.isPrologMobile = TFSConfig.isPrologMobile__c;
					reqParam.isProjectSightWeb = TFSConfig.isProjectSightWeb__c;
					reqParam.isProjectSightMobile = TFSConfig.isProjectSightMobile__c;
					reqParam.ProjectName = TFSConfig.Project_Name__c;
					//if(!isupdate){
					String effectedProduct = '<b>Affected Product : </b> ';
					if (TFSConfig.isConnect__c == 'Yes') effectedProduct = effectedProduct + 'Connect';
					if (TFSConfig.isConverge__c == 'Yes') effectedProduct = effectedProduct + 'Converge';
					if (TFSConfig.isIgnition__c == 'Yes') effectedProduct = effectedProduct + 'Ignition';
					if (TFSConfig.isIpad__c == 'Yes') effectedProduct = effectedProduct + 'Ipad';
					if (TFSConfig.isManager__c == 'Yes') effectedProduct = effectedProduct + 'Manager';
					if (TFSConfig.isOther__c == 'Yes') effectedProduct = effectedProduct + 'Other';
					if (TFSConfig.isProjectSightMobile__c == 'Yes') effectedProduct = effectedProduct + 'ProjectSightMobile';
					if (TFSConfig.isProjectSightWeb__c == 'Yes') effectedProduct = effectedProduct + 'ProjectSightWeb';
					if (TFSConfig.isPrologMobile__c == 'Yes') effectedProduct = effectedProduct + 'PrologMobile';
					if (TFSConfig.isSky__c == 'Yes') effectedProduct = effectedProduct + 'Sky';
					if (TFSConfig.isWebService__c == 'Yes') effectedProduct = effectedProduct + 'WebService';
					if (TFSConfig.isWindowTablet__c == 'Yes') effectedProduct = effectedProduct + 'WindowTablet';
					if (TFSConfig.isWinTablet__c == 'Yes') effectedProduct = effectedProduct + 'WinTablet';
					reqParam.Description = (reqParam.Description == null ? '' : reqParam.Description + '<br>' + effectedProduct);
					//}
					reqParam.FixedInBuild = (cs.Fixed_In_Build__c != null ? cs.Fixed_In_Build__c : '');
				} else {
					reqParam.ProjectName = TFSConfig.Project_Name__c;
				}

				reqParam.ResolutionNotes = cs.Resolution__c;
				system.debug('---------------reqParam.ResolutionNotes---------' + reqParam.ResolutionNotes);
				system.debug('--------Area ------------' + reqParam.Area);
				system.debug('--------Iteration ------------' + reqParam.Iteration);
				system.debug('--------ProjectName ------------' + reqParam.ProjectName);

				List<AggregateResult> agrList = [Select parentId, Count(Id) LinkedIssue from Case where Defect__c = :cs.Id group by parentId];
				system.debug('--------agrList------------' + agrList);
				if (agrList.size() > 0) {
					Integer cnt = Integer.valueOf(agrList.get(0).get('LinkedIssue'));
					reqParam.LinkedIssue = ((cnt != 0) ? String.valueOf(agrList.get(0).get('LinkedIssue')) : '0');
					reqParam.numberOfLinkedSI = reqParam.LinkedIssue;
					system.debug('--------LinkedIssue ------------' + reqParam.LinkedIssue);
					system.debug('--------numberOfLinkedSI ------------' + reqParam.numberOfLinkedSI);
				} else {
					reqParam.LinkedIssue = '0';
					reqParam.numberOfLinkedSI = reqParam.LinkedIssue;
				}

				system.debug('--------reqParam ------------' + reqParam);
				xmlnsOracleComTfssfdcTnvsfdcoutbound.TnvSfdcOutboundToTfsBPELProcess_pt temp = new xmlnsOracleComTfssfdcTnvsfdcoutbound.TnvSfdcOutboundToTfsBPELProcess_pt();
				temp.timeout_x = 120000;
				xmlnsOracleComTfssfdcTnvsfdcoutbound.CaseParamsResultType responseParam = new xmlnsOracleComTfssfdcTnvsfdcoutbound.CaseParamsResultType();
				if (!test.isRunningTest()) {
					responseParam = temp.process(reqParam);
				} else if (test.isRunningTest() && bl) {
					responseParam.tfsid = '123';
					cs.TFS_Id__c = null;
				} else if (test.isRunningTest() && !bl) {
					responseParam.tfsid = '0';
					cs.TFS_Id__c = null;
				}

				system.debug('--------responseParam------------' + responseParam.tfsid);
				if (responseParam.tfsid != null && responseParam.tfsid != '0' && responseParam.tfsid != '') {
					cs.TFS_Id__c = String.valueOf(responseParam.tfsid).trim();
					cs.Integration_Exception_Message__c = 'Success';
					launchControl.put('validateBeforeTFSCallout', launchControl.get('validateBeforeTFSCallout') + 1);
					update cs;
				} else if (responseParam.tfsid == '0' && !responseParam.errorMessage.contains('No actions in Update XML')) {
					cs.TFS_Id__c = (cs.TFS_Id__c != '' && cs.TFS_Id__c != null ? cs.TFS_Id__c : '');
					system.debug('--------responseParam------------' + (responseParam.status + ' : ' + responseParam.errorMessage));
					String error = (responseParam.status + ' : ' + responseParam.errorMessage).left(255);
					cs.Integration_Exception_Message__c = error;
					launchControl.put('validateBeforeTFSCallout', launchControl.get('validateBeforeTFSCallout') + 1);
					update cs;
					errorMessage = 'Integration failed. Please try again.';
				} else if (responseParam.tfsid == '0' && responseParam.errorMessage.contains('No actions in Update XML')) {
					cs.Integration_Exception_Message__c = 'Success';
					launchControl.put('validateBeforeTFSCallout', launchControl.get('validateBeforeTFSCallout') + 1);
					update cs;
				}
			} else {
				cs.Id = csIdList.get(0);
				cs.Integration_Exception_Message__c = 'Failed : Integration failed. Product is not configured in Salesforce. Please contact Salesforce Support Team.';
				//launchControl.put('callTFS',launchControl.get('callTFS') + 1);
				update cs;
				errorMessage = 'Integration failed. Product is not configured in Salesforce. Please contact Salesforce Support Team.';
			}
		} catch(Exception ex) {
			Case cs = new Case();
			cs.Id = csIdList.get(0);
			cs.Integration_Exception_Message__c = 'Failed' + ex.getMessage().left(245);
			//launchControl.put('callTFS',launchControl.get('callTFS') + 1);
			update cs;
			errorMessage = 'Integration failed. Please try again.';

		}
	}

	@Future(callout = true)
	public static void callTFS(List<Id> csIdList, Boolean isUpdate, boolean sendItegration) {
		system.debug(launchControl.get('callTFS') + '---------------idList---------' + csIdList.size());
		if (csIdList.size() == 1) {
			makeCallOut(csIdList, isUpdate, sendItegration);
		}
	}

	public static void validateBeforeTFSCallout(List<Case> newList, Map<Id, Case> newMap, Map<Id, Case> oldMap, boolean isInsert, boolean isUpdate) {
		if (launchControl.get('validateBeforeTFSCallout') < 1) {
			launchControl.put('validateBeforeTFSCallout', launchControl.get('validateBeforeTFSCallout') + 1);
			boolean runIntegration = false;
			set<Id> validIds = new set<ID> ();
			if (isUpdate) {
				validIds = Utils.verifyFieldUpdate(newMap, oldMap, 'Case', 'TFS Integration', 'TFS');
				CaseHandler.sendTFSItegration = false;
			}
			else if (isInsert) validIds = newMap.keySet();
			system.debug('---------validIds---------' + validIds);
			List<Id> tempIdList = new List<Id> ();
			tempIdList.addAll(validIds);

			if (tempIdList.size() == 1 && newMap.get(tempIdList.get(0)) != null) {
				Case cs = newMap.get(tempIdList.get(0));
				TFS_Project_Config__c TFSConfig;
				if (TFS_Project_Config__c.getAll().get(cs.Product__c) != null)
				runIntegration = TFS_Project_Config__c.getAll().get(cs.Product__c).Run_Integration__c;
				if (runIntegration) callTFS(tempIdList, isUpdate, sendTFSItegration);
			}
		}
	}

	//Method to validate if Product  values is configured in TFS Project Integration or not
	public static void TFSIntegrationCheck(List<Case> newCSList) {
		system.debug('----------launchControl.get()---------' + launchControl.get('TFSIntegrationCheck'));
		if (launchControl.get('TFSIntegrationCheck') < 1) {
			launchControl.put('TFSIntegrationCheck', launchControl.get('TFSIntegrationCheck') + 1);

			for (Case cs : newCSList) {
				system.debug('----------cs.Product__c---------' + cs.Product__c);
				if (cs.Record_Type_Name__c == Label.GCCM_Support_Issue_Record_Type && !cs.Product__c.contains('ProjectSight') && !cs.Product__c.contains('Prolog') && !cs.Product__c.contains('Proliance') && !cs.Product__c.contains('Message Bus') && !cs.Product__c.contains('Field Mgmt')) {
					system.debug('----------TFSConfig---------' + TFS_Project_Config__c.getAll().get(cs.Product__c));
					TFS_Project_Config__c TFSConfig = TFS_Project_Config__c.getAll().get(cs.Product__c);
					if (TFSConfig != null) {
						boolean runIntegration = TFS_Project_Config__c.getAll().get(cs.Product__c).Run_Integration__c;
						system.debug('----------runIntegration---------' + runIntegration);
						cs.Integration_Exception_Message__c = (runIntegration ? cs.Integration_Exception_Message__c : cs.Product__c + ' is not configured in TFS Integration. Please contact Salesforce Support Team.');
					} else if (TFSConfig == null) {
						cs.Integration_Exception_Message__c = cs.Product__c + ' is not configured in TFS Integration. Please contact Salesforce Support Team.';
					}
					system.debug('----------cs.Integration_Exception_Message__c---------' + cs.Integration_Exception_Message__c);
				} else if (cs.Record_Type_Name__c == Label.GCCM_Support_Issue_Record_Type && (cs.Product__c.contains('ProjectSight') || cs.Product__c.contains('Prolog') || cs.Product__c.contains('Proliance') || cs.Product__c.contains('Message Bus') || cs.Product__c.contains('Field Mgmt'))) {
					cs.Integration_Exception_Message__c = cs.Product__c + ' is configured with JIRA now.';
				}
			}
		}
	}

	//Method to populate No if Linked Issues,Asset, Account, Product based on matching serial number to Case
	public static void configCase(List<Case> newCSList) {
		if (launchControl.get('configCase') < 1) {
			launchControl.put('configCase', launchControl.get('configCase') + 1);

			List<Case> csList = new List<Case> ();
			Map<Id, Id> accConMap = new Map<Id, Id> ();
			Map<String, Asset> serialNumberAssetMap = new Map<String, Asset> ();
			for (Case cs : newCSList) {
				if (cs.Record_Type_Name__c == Label.GCCM_Support_Issue_Record_Type || cs.Record_Type_Name__c == Label.GCCM_Support_Case_Record_Type) {
					if (cs.Clone_Case_Number__c != null && cs.Clone_Case_Number__c != '') {
						cs.Source_System_ID__c = '';
						cs.Source_System__c = '';
						cs.Case24HoursTimeStamp__c = null;
						if (trigger.isInsert) cs.Integration_Exception_Message__c = '';
					}

					if (cs.Temp_Case_Id__c != null &&
					    cs.Record_Type_Name__c == Label.GCCM_Support_Issue_Record_Type) {
						cs.No_Of_Linked_SI_s__c = 1;
					}

					if (cs.Serial_Number__c != null && cs.Origin == 'LiveChat') {
						csList.add(cs);
						serialNumberAssetMap.put(cs.Serial_Number__c, null);
					}
				}
			}
			if (serialNumberAssetMap.size() > 0) {
				System.debug('==========================serialNumberAssetMap============================' + serialNumberAssetMap);
				for (Asset ass :[Select SerialNumber, AccountId, Id, Product2Id from Asset where SerialNumber in :serialNumberAssetMap.keySet()]) {
					serialNumberAssetMap.put(ass.SerialNumber, ass);
				}

				for (Case cs : csList) {
					if (serialNumberAssetMap.get(cs.Serial_Number__c) != null) {
						cs.AccountId = serialNumberAssetMap.get(cs.Serial_Number__c).AccountId;
						cs.AssetId = serialNumberAssetMap.get(cs.Serial_Number__c).Id;
						cs.ProductId = serialNumberAssetMap.get(cs.Serial_Number__c).Product2Id;
					}
				}
			}
		}
	}

	//Method to notify case Owner about Planning Priority changes on Case
	public static void notifyCaseOwnersForPlanningPriority(List<Case> csList, Map<Id, Case> csMap) {
		try {
			System.debug('================launchControl===============' + launchControl);
			System.debug('=================csList===========================' + csList);
			System.debug('==================csMap===========================' + csMap);
			if (launchControl.get('notifyCaseOwnersForPlanningPriority') < 1) {
				launchControl.put('notifyCaseOwnersForPlanningPriority', launchControl.get('notifyCaseOwnersForPlanningPriority') + 1);
				Map<Id, List<String>> defectIdEmails = new Map<Id, List<String>> ();
				Map<Id, Id> tempCaseIds = new Map<Id, Id> ();
				for (Case cs : csList) {
					System.debug('==============cs.Planning_Priority__c=====================' + cs.Planning_Priority__c);
					if (cs.Record_Type_Name__c == Label.GCCM_Support_Issue_Record_Type &&
					(csMap.containsKey(cs.Id) ? cs.Planning_Priority__c != csMap.get(cs.Id).Planning_Priority__c : cs.Planning_Priority__c != null)) {
						defectIdEmails.put(cs.Id, new List<String> ());
						if (cs.Temp_Case_Id__c != null && cs.Temp_Case_Id__c != '') {
							tempCaseIds.put((Id) cs.Temp_Case_Id__c, cs.Id);
						}
					}
					// Upon checking the fixed in build(PLM) email notificaiton is sent to child case owners. (REQ[100768]) && cs.Fixed_in_Build_PLM__c == True
					if (cs.Record_Type_Name__c == Label.GCCM_Support_Issue_Record_Type &&
					(csMap.containsKey(cs.id) ? cs.Fixed_in_Build_PLM__c != csMap.get(cs.Id).Fixed_in_Build_PLM__c : null)) {
						defectIdEmails.put(cs.Id, new List<String> ());
						if (cs.Temp_Case_Id__c != null && cs.Temp_Case_Id__c != '') {
							tempCaseIds.put((Id) cs.Temp_Case_Id__c, cs.Id);
						}
					}
				}

				if (tempCaseIds.size() > 0 || defectIdEmails.size() > 0) {
					for (Case cs :[Select Id, Defect__c, Owner.Email, OwnerID from Case where(Defect__c in :defectIdEmails.keySet() OR Id in :tempCaseIds.keySet()) and
					     Record_Type_Name__c = :Label.GCCM_Support_Case_Record_Type]) {
						if (cs.Owner.Email != null && cs.Owner.Email != '') {
							if (defectIdEmails.get(cs.Defect__c != null ? cs.Defect__c : tempCaseIds.get(cs.Id)) == null)
							defectIdEmails.put(cs.Defect__c != null ? cs.Defect__c : tempCaseIds.get(cs.Id), new List<String> ());

							defectIdEmails.get(cs.Defect__c != null ? cs.Defect__c : tempCaseIds.get(cs.Id)).add(cs.Owner.Email);
						}
					}


					System.debug('==============defectIdEmails=====================' + defectIdEmails);
					List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage> ();
					Contact c;
					for (Contact con :[select id, Email from Contact where email<> null and AccountId = '001i000000kVaNyAAK' and Id != '003i000000jAT7s' limit 1]) {
						c = con;
					}
					if (c != null) {
						for (Case cs : csList) {
							if (cs.Record_Type_Name__c == Label.GCCM_Support_Issue_Record_Type &&
							(csMap.containsKey(cs.Id) ? cs.Planning_Priority__c != csMap.get(cs.Id).Planning_Priority__c : cs.Planning_Priority__c != null)
							    && defectIdEmails.get(cs.Id).size() > 0) {
								System.debug('==============defectIdEmails.get(cs.Id)=====================' + defectIdEmails.get(cs.Id));

								Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
								msg.setTemplateId([select Id from EmailTemplate where DeveloperNAme = :Label.GCCM_Priority_Case_Template_Ad].Id);
								msg.setWhatId(cs.Id);
								msg.setTargetObjectId(c.Id);
								msg.setBccSender(false);
								msg.setUseSignature(false);
								msg.setSaveAsActivity(false);
								msg.setToAddresses(defectIdEmails.get(cs.Id));
								lstMsgs.add(msg);
							}
							else if (cs.Record_Type_Name__c == Label.GCCM_Support_Issue_Record_Type && defectIdEmails.get(cs.Id).size() > 0 && cs.Fixed_in_Build_PLM__c == True)
							{
								Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
								msg.setTemplateId([select Id from EmailTemplate where DeveloperNAme = :Label.GCCM_Fixed_in_Build].Id); //Label.GCCM_Fixed_in_Build
								msg.setWhatId(cs.Id);
								msg.setTargetObjectId(c.Id);
								msg.setBccSender(false);
								msg.setUseSignature(false);
								msg.setSaveAsActivity(false);
								msg.setToAddresses(defectIdEmails.get(cs.Id));
								lstMsgs.add(msg);

							}
						}
					}
					system.debug('--------------' + lstMsgs);
					if (lstMsgs.size() > 0) {
						// Send the emails in a transaction, then roll it back
						Savepoint sp = Database.setSavepoint();
						system.debug('--------------' + Messaging.sendEmail(lstMsgs));
						Database.rollback(sp);

						List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage> ();
						for (Messaging.SingleEmailMessage email : lstMsgs) {
							Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
							emailToSend.setToAddresses(email.getToAddresses());
							emailToSend.setPlainTextBody(email.getPlainTextBody());
							emailToSend.setHTMLBody(email.getHTMLBody());
							emailToSend.setSubject(email.getSubject());
							lstMsgsToSend.add(emailToSend);
						}
						system.debug('--------------' + lstMsgsToSend);
						system.debug('--------------' + Messaging.sendEmail(lstMsgsToSend));
					}
				}
			}
		} catch(Exception ex) {

		}
	}

	//Method to set Temp Case Id value to blank
	public static void clearFields(List<Case> csList) {
		if (launchControl.get('clearFields') < 1) {
			launchControl.put('clearFields', launchControl.get('clearFields') + 1);
			for (Case cs : csList) {
				if (cs.Record_Type_Name__c == Label.GCCM_Support_Case_Record_Type) cs.Temp_Case_Id__c = '';
			}
		}
	}

	//Method to copy chat transcripts on case clone
	public static void copyChatTranscriptsToCloneCase(List<Case> newCases) {

		if (launchControl.get('copyChatTranscriptsToCloneCase') < 1) {
			launchControl.put('copyChatTranscriptsToCloneCase', launchControl.get('copyChatTranscriptsToCloneCase') + 1);
			Map<String, Id> csMap = new Map<String, Id> ();
			for (Case cs : newCases) {
				if (cs.Clone_Case_Number__c != null && cs.Clone_Case_Number__c != '' &&
				    cs.Record_Type_Name__c == Label.GCCM_Support_Case_Record_Type) {
					csMap.put(cs.Clone_Case_Number__c, cs.Id);
				}
			}
			System.debug('==================csMap===========================' + csMap);
			if (csMap.size() > 0) {
				List<LiveChatTranscript> insertTranscripts = new List<LiveChatTranscript> ();
				LiveChatTranscript transcript = new LiveChatTranscript();
				for (LiveChatTranscript chat :[select Case.CaseNumber, AccountId, Abandoned
				     , Body, Browser, BrowserLanguage, CaseID, ContactID
				     , IpAddress, LiveChatButtonID, LiveChatDeploymentID,
				     LiveChatVisitorID, Location,
				     Platform, ReferrerUri, ScreenResolution, SkillId, Status,
				     SupervisorTranscriptBody, UserAgent, AverageResponseTimeOperator, AverageResponseTimeVisitor,
				     ChatDuration, EndedBy, EndTime, LastReferencedDate, LastViewedDate, LeadID, MaxResponseTimeOperator,
				     MaxResponseTimeVisitor, Name, OperatorMessageCount, OwnerID, RequestTime, StartTime, VisitorMessageCount
				     , WaitTime from LiveChatTranscript where
				     Case.CaseNumber in :csMap.keySet()]) {

					transcript = new LiveChatTranscript();
					transcript = chat.clone(false, false, false, false);
					transcript.CaseId = csMap.get(Chat.Case.CaseNumber);
					insertTranscripts.add(transcript);
				}
				if (insertTranscripts.size() > 0) {
					insert insertTranscripts;
				}
			}
		}
	}

	//Method to link new Issue to Case 
	public static void attachIssueToCase(List<Case> newCases) {
		if (launchControl.get('attachIssueToCase') < 1) {
			launchControl.put('attachIssueToCase', launchControl.get('attachIssueToCase') + 1);
			List<Case> updateList = new List<Case> ();
			Case csObj;
			for (Case cs : newCases) {
				if ((/*cs.Record_Type_Name__c == Label.RE_WS_Proliance_Support_Issue_Record_Type ||*/
				     cs.Record_Type_Name__c == Label.GCCM_Support_Issue_Record_Type) && cs.Temp_Case_Id__c != null) {
					csObj = new Case();
					csObj.Defect__c = cs.Id;
					csObj.Id = cs.Temp_Case_Id__c;
					system.debug('--------csObj----------' + csObj);
					updateList.add(csObj);
				}
			}

			if (updateList.size() > 0) {
				setLaunchControl();
				system.debug('--------updateList----------' + updateList);
				update updateList;
			}
		}
	}

}