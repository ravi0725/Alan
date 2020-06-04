/*****************************************************************************************
  Name        : OpportunityLineItemHelper
  Desc        : Used to handel Opportunity Line Item trigger code
  ---------------------------------------------------------------------------
  Developer              Date            Description
  ---------------------------------------------------------------------------
  Ankur Patel			21/10/2016          Created
  Suresh Babu Murugan	18/02/2019          Modified - Update ARR on Opportunity (APP-2527)
  Suresh Babu Murugan	22-JULY-2019		Modified : APP-8123-Changes needed for Auto-Generated SSM Renewals
  Suresh Babu Murugan	11-OCT-2019			Modified : Update ARR Calculation
  Suresh Babu Murugan	30-MAR-2020			Modified : Update ARR Calculation
 ******************************************************************************************/
public class OpportunityLineItemHelper {
	public static Map<String, Integer> launchControl;
	public static set<Id> deletedLineItemIds;
	public static boolean HasOpptyLines = False;
	// Static initialize
	static {
		resetLaunchControl();
	}

	// Reset Trigger control (e.g. for testing)
	public static void resetLaunchControl() {
		launchControl = new Map<String, Integer> ();
		launchControl.put('populateSerialNumbersOnOpportunity', 0);
	}

	// Reset Trigger control (e.g. for testing)
	public static void setLaunchControl() {
		launchControl = new Map<String, Integer> ();
		launchControl.put('populateSerialNumbersOnOpportunity', 1);
	}


	//Only System Administrator and Data Administrator profile user can delete Renewal Opportunity
	public static void populateSerialNumbersOnOpportunity(List<OpportunityLineitem> OppLiTmList) {
		if (launchControl.get('populateSerialNumbersOnOpportunity') < 1) {
			launchControl.put('populateSerialNumbersOnOpportunity', launchControl.get('populateSerialNumbersOnOpportunity') + 1);

			Map<Id, set<String>> oppSerialNumbers = new Map<Id, set<String>> ();
			Map<Id, Double> mapOpportunityARR = new Map<Id, Double> (); // Map Key: OpportunityId, Value: Currency
			List<Opportunity> updateOppList = new List<Opportunity> ();
			Map<Object, List<String>> mapOppProductPicklist = new Map<Object, List<String>> ();
			Map<Id, Set<String>> mapUniqueProductCategory = new Map<Id, Set<String>> ();
			Map<Id, String> mapFinalOppProduct = new Map<Id, String> ();
			Map<Id, String> mapFinalOwnerAssignment = new Map<Id, String> ();
			for (OpportunityLineItem oppLiTm : OppLiTmList) {
				oppSerialNumbers.put(oppLiTm.OpportunityId, new set<String> ());
			}

			Map<String, String> mapOppProductAssign = new Map<String, String> ();
			Map<String, String> mapOppOwners_UserName = new Map<String, String> ();
			for (Renewal_Product_Allocation__mdt renewalOppConfig :[SELECT DeveloperName, MasterLabel, Business_Area__c, Opportunity_Product__c, Opportunity_Owner__c FROM Renewal_Product_Allocation__mdt]) {
				mapOppProductAssign.put(renewalOppConfig.MasterLabel, renewalOppConfig.Opportunity_Product__c);
				if (renewalOppConfig.Opportunity_Owner__c != null && renewalOppConfig.Opportunity_Owner__c != '') mapOppOwners_UserName.put(renewalOppConfig.MasterLabel, renewalOppConfig.Opportunity_Owner__c);
			}

			mapOppProductPicklist = getDependentPicklistValues('Opportunity', 'Opportunity_Product__c'); // This section updates Opportunity's Opportunity Product for Renewal Quote. Ref : APP-8123

			List<OpportunityLineItem> lstOppLines = [SELECT Id, Name, OpportunityId, Opportunity.Selling_Division__c, Opportunity.Opportunity_Product__c, Opportunity.Renewal_Lines_Count__c, Service_Start_Date__c, Service_End_Date__c, Quantity,
			                                         Extended_Price__c, ProductCode, Asset__c, Asset__r.SerialNumber, Type__c, Product2.Name, Product2.Type__c, Staging__c, Include_ARR_Calculation__c
			                                         FROM OpportunityLineItem
			                                         WHERE OpportunityId IN :oppSerialNumbers.keySet() ORDER BY OpportunityId];
			for (OpportunityLineItem oppLiTm : lstOppLines) {
				if (oppLiTm.Asset__c != null && oppLiTm.Asset__r.SerialNumber != null && oppLiTm.Asset__r.SerialNumber != '') {
					oppSerialNumbers.get(oppLiTm.OpportunityId).add(oppLiTm.Asset__r.SerialNumber);
				}

				if (oppLiTm.Include_ARR_Calculation__c == FALSE && oppLiTm.Service_Start_Date__c != null && oppLiTm.Service_End_Date__c != null && oppLiTm.Opportunity.Renewal_Lines_Count__c != null && oppLiTm.Opportunity.Renewal_Lines_Count__c > 0 && oppLiTm.Opportunity.Selling_Division__c == 'MEP NA') {
					oppLiTm.Include_ARR_Calculation__c = true;
				}

				if (oppLiTm.Service_Start_Date__c != null && oppLiTm.Service_End_Date__c != null && oppLiTm.Extended_Price__c != null && oppLiTm.Include_ARR_Calculation__c) {
					If (!oppLiTm.Service_Start_Date__c.isSameDay(oppLiTm.Service_End_Date__c)) {
						Decimal oLineARR = calculateARR(oppLiTm.Service_Start_Date__c, oppLiTm.Service_End_Date__c, oppLiTm.Extended_Price__c);
						System.debug(' oLineARR ::::::::' + oLineARR);
						if (mapOpportunityARR.containsKey(oppLiTm.OpportunityId)) {
							mapOpportunityARR.put(oppLiTm.OpportunityId, mapOpportunityARR.get(oppLiTm.OpportunityId) + oLineARR);
						}
						else {
							mapOpportunityARR.put(oppLiTm.OpportunityId, oLineARR);
						}
					}
				}

				// This section updates Opportunity's Opportunity Product for Renewal Quote. Ref : APP-8123
				if (oppLiTm.Opportunity.Selling_Division__c != null && oppLiTm.Opportunity.Selling_Division__c == 'MEP NA' && oppLiTm.Opportunity.Opportunity_Product__c == null && oppLiTm.Type__c == 'Renewal' && oppLiTm.Staging__c != null && oppLiTm.Product2.Type__c != null) {
					if (mapUniqueProductCategory.containsKey(oppLiTm.OpportunityId)) {
						Set<String> setTemp1 = mapUniqueProductCategory.get(oppLiTm.OpportunityId);
						setTemp1.add(oppLiTm.Product2.Type__c);
						mapUniqueProductCategory.put(oppLiTm.OpportunityId, setTemp1);
					}
					else {
						Set<String> setTemp1 = new Set<String> ();
						setTemp1.add(oppLiTm.Product2.Type__c);
						mapUniqueProductCategory.put(oppLiTm.OpportunityId, setTemp1);
					}
				}
				// END
			}
			// This section updates Opportunity's Opportunity Product for Renewal Quote. Ref : APP-8123
			List<String> mepnaOpportunityProducts = (mapOppProductPicklist.containsKey('MEP NA') ? mapOppProductPicklist.get('MEP NA') : null);
			for (Id oppIdKey : mapUniqueProductCategory.keySet()) {
				Set<String> setFinalOppProduct = new Set<String> ();
				String strFinalOppProduct = '';
				if (mapUniqueProductCategory.get(oppIdKey).size() > 0) {
					List<String> lstPossibleOppOwner = new List<String> ();
					for (String pName : mapUniqueProductCategory.get(oppIdKey)) {
						System.debug(' pName ::::::::' + pName);
						if (mapOppProductAssign.containsKey(pName) && mepnaOpportunityProducts.contains(mapOppProductAssign.get(pName))) {
							setFinalOppProduct.add(mapOppProductAssign.get(pName));

							if (mapOppOwners_UserName.containsKey(pName)) {
								lstPossibleOppOwner.add(mapOppOwners_UserName.get(pName));
							}
						}
					}

					Map<String, Integer> tmpOwnerCount = new Map<String, Integer> ();
					for (String key : lstPossibleOppOwner) {
						if (!tmpOwnerCount.containsKey(key)) {
							tmpOwnerCount.put(key, 0);
						}
						Integer currentInt = tmpOwnerCount.get(key) + 1;
						tmpOwnerCount.put(key, currentInt);
					}
					List<Integer> lstTempCount = new List<Integer> ();
					lstTempCount = tmpOwnerCount.values();
					lstTempCount.sort();
					Integer LargeNum = (lstTempCount.size() > 0 ? lstTempCount.get(lstTempCount.size() - 1) : 0);
					for (String uName : tmpOwnerCount.keySet()) {
						System.debug('...ENTRY...');
						if (tmpOwnerCount.get(uName) == LargeNum) {
							System.debug('...BIGEST...' + uName);
							mapFinalOwnerAssignment.put(oppIdKey, uName);
							break;
						}
					}
					System.debug(' setFinalOppProduct ::::::::' + setFinalOppProduct);
					for (String finalOp : setFinalOppProduct) {
						strFinalOppProduct += finalOp + ';';
					}
					mapFinalOppProduct.put(oppIdKey, strFinalOppProduct);
					System.debug(' mapFinalOppProduct ::::::::' + mapFinalOppProduct);
				}
			}
			// END
			Map<String, Id> mapSFDCUsers = new Map<String, Id> ();
			for (User usr :[select Id, Username, Email from User where Username IN :mapFinalOwnerAssignment.values() AND isActive = true]) {
				mapSFDCUsers.put(usr.Username, usr.Id);
			}
			for (Opportunity oppRecord :[SELECT Id, Serial_Numbers__c, Annual_Recurring_Revenue__c, Opportunity_Product__c FROM Opportunity WHERE Id IN :oppSerialNumbers.keySet()]) {
				string str = '';
				Boolean isReadytoUpdate = false;
				for (string serialnumber : oppSerialNumbers.get(oppRecord.Id)) {
					str = serialNumber + ',' + str;
				}
				if (str != '') {
					oppRecord.Serial_Numbers__c = str.removeEnd(',');
					isReadytoUpdate = true;
				}
				if (mapOpportunityARR.containsKey(oppRecord.Id)) {
					oppRecord.Annual_Recurring_Revenue__c = mapOpportunityARR.get(oppRecord.Id);
					isReadytoUpdate = true;
				}
				if (mapFinalOppProduct.containsKey(oppRecord.Id) && oppRecord.Opportunity_Product__c == null) {
					oppRecord.Opportunity_Product__c = mapFinalOppProduct.get(oppRecord.Id);
					isReadytoUpdate = true;
				}
				if (mapFinalOwnerAssignment.containsKey(oppRecord.Id) && mapSFDCUsers.containsKey(mapFinalOwnerAssignment.get(oppRecord.Id))) {
					oppRecord.OwnerId = mapSFDCUsers.get(mapFinalOwnerAssignment.get(oppRecord.Id));
				}
				System.debug(' Annual_Recurring_Revenue__c ====:' + oppRecord.Annual_Recurring_Revenue__c);
				if (isReadytoUpdate) updateOppList.add(oppRecord);
			}
			if (updateOppList.size() > 0) {
				CreateRenewalOpportunityFromEBS.runOpportunityTrigger = false;
				CreateRenewalOpportunityFromEBS.runOpportunityLineItemTrigger = false;
				CreateRenewalOpportunityFromEBS.setLaunchControl();
				update updateOppList;
			}
		}
	}

	public static Map<Object, List<String>> getDependentPicklistValues(String sObjectName, String fieldName) {
		return getDependentPicklistValues(Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap().get(fieldName));
	}
	/*
	  @description : This method return available dependent picklist value for MEP NA Renewal Quotes.
	 */
	private static Map<Object, List<String>> getDependentPicklistValues(Schema.sObjectField dependToken) {
		Schema.DescribeFieldResult depend = dependToken.getDescribe();
		Schema.sObjectField controlToken = depend.getController();
		if (controlToken == null) return null;
		Schema.DescribeFieldResult control = controlToken.getDescribe();
		List<Schema.PicklistEntry> controlEntries =
		(control.getType() == Schema.DisplayType.Boolean
		 ? null
		 : control.getPicklistValues()
		);

		String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
		Map<Object, List<String>> dependentPicklistValues = new Map<Object, List<String>> ();
		for (Schema.PicklistEntry entry : depend.getPicklistValues()) if (entry.isActive())
		{
			List<String> base64chars =
			String.valueOf
			(((Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')
			).split('');
			for (Integer index = 0; index<(controlEntries != null ? controlEntries.size() : 2); index++)
			{

				Object controlValue =
				(controlEntries == null
				 ? (Object) (index == 1)
				 : (Object) (controlEntries[index].isActive() ? controlEntries[index].getValue() : null)
				);
				if (controlValue != null && !dependentPicklistValues.containsKey(controlValue))
				{
					dependentPicklistValues.put(controlValue, new List<String> ());
				}
				Integer bitIndex = index / 6, bitShift = 5 - Math.mod(index, 6);
				if (base64chars.size()> 2) {
					if (controlValue == null || (base64map.indexOf(base64chars[bitIndex]) & (1 < < bitShift)) == 0)
					continue;
					dependentPicklistValues.get(controlValue).add(entry.getValue());
				}
			}
		}
		return dependentPicklistValues;
	}

	/**
	 * @description			:	This method return ARR amount per lines.
	 * @param sDate			:	Start Date of the contract
	 * @param eDate			:	End Date of the contract
	 * @param cAnnualCost	:	Extended Price of Opportunity Line
	 * @return				:	Decimal ARR Amount
	 */
	private static Decimal calculateARR(Date sDate, Date eDate, Decimal cAnnualCost) {
		Decimal returnARR = 0.0;
		String sOutput = CalculateDuration.MonthsandDays(sDate, eDate);
		List<String> lstOutputs = (sOutput.contains(':') ? sOutput.split(':') : null);
		if (lstOutputs != null && lstOutputs.size() == 2) {
			Integer iMonths = Integer.valueof(lstOutputs.get(0));
			Integer iDays = Integer.valueof(lstOutputs.get(1));
			System.debug(' CalculateDuration DIFF : ' + iMonths + ' :: ' + iDays);

			// Annual amount calculation
			if (iMonths == 12) {
				returnARR = cAnnualCost;
			}
			// Multi-Year amount calculation
			else if (iMonths > 12) {
				returnARR = (cAnnualCost / iMonths * 12);
			}
			// Monthly contract amoung calculation
			else if (iMonths == 1 && iDays == 0) {
				returnARR = (cAnnualCost * 12);
			}
			// All others
			else {
				returnARR = cAnnualCost;
			}
		}
		return returnARR;
	}
}