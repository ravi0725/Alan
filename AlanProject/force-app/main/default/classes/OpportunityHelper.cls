/*****************************************************************************************
  Name        : OpportunityHelper
  Desc        : Used to handel Opportunity trigger code
  ---------------------------------------------------------------------------
  Developer              Date            Description
  ---------------------------------------------------------------------------
  Ankur Patel           25/04/2015          Created
  Suresh Babu Murugan   06/NOV/2019         Modified: CRMS-12 : New Request Add logic for New Logo, same as MEP
  Suresh Babu Murugan   31/MAR/2020         Modified: APP-21132 : New Product Growth Value & Opportunity Line Seats Field
 ******************************************************************************************/
public with sharing class OpportunityHelper {
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
		launchControl.put('OpportunityBeforeDeleteHandler', 0);
		launchControl.put('updateProposalPaymentTerm', 0);
		launchControl.put('runApprovalProcess', 0);
		launchControl.put('validatePaymentTerm', 0);
		launchControl.put('RollupOpptyLines', 0);
		launchControl.put('validateRenewalOpportunity', 0);
		launchControl.put('updateBusinessArea', 0);
		launchControl.put('updateBusinessUnit', 0);
		launchControl.put('validateMEPNAEstimatingBusinessArea', 0);
	}

	// Reset Trigger control (e.g. for testing)
	public static void setLaunchControl() {
		launchControl = new Map<String, Integer> ();
		launchControl.put('OpportunityBeforeDeleteHandler', 1);
		launchControl.put('updateProposalPaymentTerm', 1);
		launchControl.put('runApprovalProcess', 1);
		launchControl.put('validatePaymentTerm', 1);
		launchControl.put('RollupOpptyLines', 1);
		launchControl.put('validateRenewalOpportunity', 1);
		launchControl.put('updateBusinessArea', 1);
		launchControl.put('validateMEPNAEstimatingBusinessArea', 1);
		launchControl.put('updateBusinessUnit', 1);
	}

	//Only System Administrator and Data Administrator profile user can delete Renewal Opportunity
	public static void validateRenewalOpportunity(List<Opportunity> oldOppList) {
		if (launchControl.get('validateRenewalOpportunity') < 1) {
			launchControl.put('validateRenewalOpportunity', launchControl.get('validateRenewalOpportunity') + 1);
			for (Opportunity opp : oldOppList) {
				if (opp.Account_Sub_Type__c == 'Renewal') {
					String profileName = [select Name from Profile where Id = :Userinfo.getProfileId()].Name;
					if (profileName != 'System Administrator' && profileName != 'Data Administrator' && !profileName.contains('MEP NA')) {
						opp.addError('Renewal Opportunity cannot be deleted.');
					}
				}
			}
		}
	}

	/*When an Opportunity with below parameters is marked “Closed – Won”,  need to automatically create a Case in backend:
	  Opportunity Sub Type = “Renewal” AND Opportunity Renewal_Status__c != blank/null AND Related Quote has MEP Estimating products i.e. Quote line item’s (product) Business Area = MEP ESTIMATING */

	public static void validateMEPNAEstimatingBusinessArea(Boolean blnInsert, Boolean blnUpdate, List<Opportunity> lstNewOpportunities, Map<Id, Opportunity> mapOldOpportunities) {
		if (launchControl.get('validateMEPNAEstimatingBusinessArea') < 1) {
			launchControl.put('validateMEPNAEstimatingBusinessArea', launchControl.get('validateMEPNAEstimatingBusinessArea') + 1);
			system.debug('====In function ====');
			Set<Id> setOpptyIDs = new Set<Id> ();
			for (Opportunity oOpportunity : lstNewOpportunities) {
				if ((blnUpdate ? mapOldOpportunities.get(oOpportunity.id).StageName != oOpportunity.StageName && oOpportunity.StageName == '6 - Closed Won' : false) &&
				    oOpportunity.Account_Sub_Type__c == 'Renewal' && oOpportunity.Renewal_Status__c != null && oOpportunity.Renewal_Status__c != '') {
					setOpptyIDs.add(oOpportunity.Id);
				}
			}

			system.debug('=====setOpptyIDs=====' + setOpptyIDs);
			if (setOpptyIDs.size() > 0) {
				List<Group> lstOwnerIdFromQueue = new List<Group> ();
				lstOwnerIdFromQueue = [SELECT ID FROM Group WHERE Type = 'Queue' AND Name = 'MEPNA - Order Ops Queue'];

				List<Case> lstInsertCases = new List<Case> ();
				for (Opportunity oOpportunity :[SELECT Id, AccountId, Bill_To_Contact__c, (SELECT Id, OpportunityId FROM OpportunityLineItems WHERE Product2.Business_Area__c = 'MEP ESTIMATING' AND Product2.Type__c != 'ESTIMATING-TRAINING') FROM Opportunity WHERE ID IN :setOpptyIDs]) {
					system.debug('====oOpportunity.OpportunityLineItems.size()===' + oOpportunity.OpportunityLineItems.size());
					if (oOpportunity.OpportunityLineItems.size() > 0) {
						Case oCase = caseHandler.createCaseAfterOpportunityOrderProcess(oOpportunity.AccountId, oOpportunity.Bill_To_Contact__c, 'Welcome back to Estimation. Please assist customer with activation', lstOwnerIdFromQueue, '', '');
						oCase.RelatedOpportunity__c = oOpportunity.Id;
						lstInsertCases.add(oCase);
					}
				}

				system.debug('===lstInsertCases===' + lstInsertCases);
				insert lstInsertCases;
			}
		}
	}

	public static void OpportunityBeforeDeleteHandler(List<SObject> oldOppList) {
		if (launchControl.get('OpportunityBeforeDeleteHandler') < 1) {
			launchControl.put('OpportunityBeforeDeleteHandler', launchControl.get('OpportunityBeforeDeleteHandler') + 1);
			for (SObject temp : oldOppList) {
				Opportunity opp = (Opportunity) temp;
				try {
					system.debug(opp.Opportunity_Owner_s_Division__c + '------------------userInfo.getProfileId()------------------' + userInfo.getProfileId());
					if (System.Label.Delete_MEP_Opportunity_Permitted_Profiles.contains(userInfo.getProfileId()) && opp.Opportunity_Owner_s_Division__c != 'MEP') {
						Throw new Trimble_CustomException('Insufficient Privilege.', true);
					}
				} catch(Trimble_CustomException ex) {
					opp.addError(ex.getMessage());
				}
			}
		}
	}

	public static void updateProposalPaymentTerm(Map<Id, Opportunity> newOppMap, Map<Id, Opportunity> oldOppMap) {
		/*
		  if(launchControl.get('updateProposalPaymentTerm') < 0){
		  launchControl.put('updateProposalPaymentTerm',launchControl.get('updateProposalPaymentTerm') + 1);
		  List<Apttus_Proposal__Proposal__c> updateProposalList = new List<Apttus_Proposal__Proposal__c>();
		  Set<Id> setOpptyId = new Set<Id>();
		 
		  for(Opportunity newOpp: newOppMap.values()){
		  setOpptyId.add(newOpp.Id);
		  }
		 
		  if(!setOpptyId.isEmpty()){
		  for(Apttus_Proposal__Proposal__c proposal : [select Id,Apttus_Proposal__Payment_Term__c,Apttus_Proposal__Opportunity__c
		  from Apttus_Proposal__Proposal__c where 
		  Apttus_Proposal__Opportunity__c in : setOpptyId and Apttus_Proposal__Primary__c = true]){
		 
		  if(newOppMap.get(proposal.Apttus_Proposal__Opportunity__c).Payment_Term_Approval_Status__c == 'Approved'){
		  proposal.Payment_Terms_In_Opportunity__c = newOppMap.get(proposal.Apttus_Proposal__Opportunity__c).Payment_Term__c;
		  updateProposalList.add(proposal);
		  }
		  }
		  for(Id oppId : newOppMap.keySet()){
		  if(newOppMap.get(oppId).Payment_Term__c != oldOppMap.get(oppId).Payment_Term__c && newOppMap.get(oppId).Trigger_Approval__c == True){
		  newOppMap.get(oppId).Old_Payment_Term__c = newOppMap.get(oppId).Payment_Term__c;
		  newOppMap.get(oppId).Payment_Term__c = oldOppMap.get(oppId).Payment_Term__c;
		  }
		  if(newOppMap.get(oppId).Payment_Term__c != oldOppMap.get(oppId).Payment_Term__c && newOppMap.get(oppId).Trigger_Approval__c == False){
		  newOppMap.get(oppId).Payment_Term__c = newOppMap.get(oppId).Payment_Term__c;
		  }
		  if(newOppMap.get(oppId).Payment_Term_Approval_Status__c != oldOppMap.get(oppId).Payment_Term_Approval_Status__c && newOppMap.get(oppId).Payment_Term_Approval_Status__c == 'Approved')
		  newOppMap.get(oppId).Payment_Term__c = newOppMap.get(oppId).Old_Payment_Term__c;
		 
		 
		  }
		  if(updateProposalList.size() > 0){
		  //  update updateProposalList;
		  }
		  }
		  }*/
	}


	public static void runApprovalProcess(Map<Id, Opportunity> newOppMap, Map<Id, Opportunity> oldOppMap) {
		/*
		  //List<Opportunity> oppList = new List<Opportunity>();
		  for(Opportunity opp : newOppMap.values()){
		  Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
		  req2.getWorkitemId();
		  System.debug('req2>>>'+req2);
		  system.debug('opp.Trigger_Approval__c>>>'+opp.Trigger_Approval__c);
		  system.debug('oldOppMap.get(opp.ID).Trigger_Approval__c>>>'+oldOppMap.get(opp.ID).Trigger_Approval__c);
		  // if(opp.Trigger_Approval__c != oldOppMap.get(opp.ID).Trigger_Approval__c && opp.Trigger_Approval__c){ 
		  if(opp.Trigger_Approval__c ==True){
		  try{
		  if ( launchControl.get('runApprovalProcess') < 1 ) {
		  launchControl.put('runApprovalProcess',launchControl.get('runApprovalProcess') + 1);
		 
		  Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
		  app.setObjectId(opp.id);
		 
		  Approval.ProcessResult result = Approval.process(app);
		  }
		  }catch(Exception ex){
		  system.debug('--------ex--------' + ex);
		  if(!test.isRunningTest())   
		  opp.addError(ex.getMessage());
		  }
		 
		  }
		 
		  }
		 
		 */ }
	//this method will check the Custom setting Country and Region based standard Payment Term
	public static void validatePaymentTerm(Map<Id, Opportunity> newOppMap, Map<Id, Opportunity> oldOppMap) {
		/*                     if(launchControl.get('validatePaymentTerm') < 1 ) {
		  launchControl.put('validatePaymentTerm',launchControl.get('validatePaymentTerm') + 1);
		  Map<String, String> mapAccountConuntryRegion = new Map<String, String>();
		  List<String> listPaymentTerms = new List<String>();
		  Set<String> setPaymentTerms = new set<String>();
		  String strPaymentTerm;
		  Id opptyAccountId;
		  Decimal decOldPaymentNumber;
		  Decimal decNewPaymentNumber;
		 
		  for(Opportunity opp : newOppMap.values()){
		  opptyAccountId = opp.AccountId;
		  }
		 
		  for(Account acc : [select BillingCountry, Region__c from Account Where Id =: opptyAccountId]){
		  mapAccountConuntryRegion.put(acc.BillingCountry, acc.Region__c);
		  }
		 
		  Map<String, Country_Region_Mapping__c> mapCountRegionPaymentTerm = Country_Region_Mapping__c.getall();
		  for(Country_Region_Mapping__c mapCRPT : mapCountRegionPaymentTerm.values()){
		  if(mapAccountConuntryRegion.containsKey(mapCRPT.Name)){
		  if(mapCRPT.Standard_Payment_Term__c != null){
		  listPaymentTerms = mapCRPT.Standard_Payment_Term__c.split('\\;');
		  }
		  }
		  }
		 
		  for(String payTerm : listPaymentTerms ){
		  setPaymentTerms.add(payTerm);
		  }
		 
		  Map<String, Payment_Term_Order__c> mapPaymentTermNoDays = Payment_Term_Order__c.getall();
		 
		  for(Opportunity oldMap : oldOppMap.values()){
		  if(oldMap.Payment_Term__c != null){
		  decOldPaymentNumber = mapPaymentTermNoDays.get(oldMap.Payment_Term__c).Number_of_Days__c;
		  }
		  } 
		 
		  for(Opportunity opp : newOppMap.values()){
		  if(opp.Payment_Term__c != null){
		  decNewPaymentNumber = mapPaymentTermNoDays.get(opp.Payment_Term__c).Number_of_Days__c;
		 
		  system.debug('>>>>>>>>>>>>>>>'+decNewPaymentNumber);
		  system.debug('>>>>>>>>>>>>>>>'+decOldPaymentNumber);
		  if(!setPaymentTerms.contains(opp.Payment_Term__c) && decNewPaymentNumber > decOldPaymentNumber){
		  opp.Trigger_Approval__c = true;
		  }else{
		  opp.Trigger_Approval__c = false;
		 
		  }
		  }
		  }
		 
		  }*/
	}

	Public Static void RollupOpptyLines(Map<Id, Opportunity> newOppMap) {
		system.debug('------------RollupOpptyLines-----------' + launchControl.get('RollupOpptyLines'));
		// if(launchControl.get('RollupOpptyLines') < 1 ) {
		launchControl.put('RollupOpptyLines', launchControl.get('RollupOpptyLines') + 1);
		set<Id> oppIdSet = new set<Id> ();
		for (Opportunity opp : newOppMap.values()) {
			system.debug('------------opp.Price_List_Name__c-----------' + opp.Price_List_Name__c);
			//opp.Price_List__c == null condition is added for Lifting Solutions division
			if ((opp.Price_List_Name__c != null ? (!Opp.Price_List_Name__c.contains('TIBV') && opp.HasOpportunityLineItem == True) : false) ||
			(opp.Selling_Division__c == 'Lifting Solutions' && opp.HasOpportunityLineItem)) {
				opp.Total_Software_Currency__c = 0;
				opp.Total_Prof_Serv__c = 0;
				opp.Total_SaaS__c = 0;
				opp.Total_Maintenance_Currency__c = 0;
				opp.Total_Service_Currency__c = 0;
				opp.Total_Hardware_Currency__c = 0;
				opp.Total_Others__c = 0;
				opp.Total_Subscription__c = 0;
				opp.Total_Rental__c = 0;
				opp.MEPNA_Total_Training__c = 0;
				oppIdSet.add(opp.Id);
			}

		}
		String availBusinessArea = '';
		Set<String> SetStr = new Set<String> ();
		system.debug('------------oppIdSet-----------' + oppIdSet);
		for (OpportunityLineItem LineItem :[SELECT Id, OpportunityId, Opportunity.Price_List__r.Division__c, Product2.Business_Area__c, Product2.ICC_Type__c, Product2.Product_Category_Type__c, TotalPrice FROM OpportunityLineItem WHERE Opportunityid IN :oppIdSet AND TotalPrice != null]) {

			if (LineItem.Product2.Business_Area__c != Null)
			SetStr.add(LineItem.Product2.Business_Area__c);

			if (deletedLineItemIds != null ? !deletedLineItemIds.contains(LineItem.Id) : true) {
				system.debug('------------newOppMap.get(LineItem.OpportunityId)-----------' + newOppMap.get(LineItem.OpportunityId));
				if (LineItem.Product2.Product_Category_Type__c == 'Software')
				newOppMap.get(LineItem.OpportunityId).Total_Software_Currency__c = newOppMap.get(LineItem.OpportunityId).Total_Software_Currency__c + LineItem.TotalPrice;
				if (LineItem.Product2.Product_Category_Type__c == 'Service')
				newOppMap.get(LineItem.OpportunityId).Total_Service_Currency__c = newOppMap.get(LineItem.OpportunityId).Total_Service_Currency__c + LineItem.TotalPrice;
				if (LineItem.Product2.Product_Category_Type__c == 'Maintenance')
				newOppMap.get(LineItem.OpportunityId).Total_Maintenance_Currency__c = newOppMap.get(LineItem.OpportunityId).Total_Maintenance_Currency__c + LineItem.TotalPrice;
				if (LineItem.Product2.Product_Category_Type__c == 'SaaS')
				newOppMap.get(LineItem.OpportunityId).Total_SaaS__c = newOppMap.get(LineItem.OpportunityId).Total_SaaS__c + LineItem.TotalPrice;
				if (LineItem.Product2.Product_Category_Type__c == 'Prof. Services')
				newOppMap.get(LineItem.OpportunityId).Total_Prof_Serv__c = newOppMap.get(LineItem.OpportunityId).Total_Prof_Serv__c + LineItem.TotalPrice;
				if (LineItem.Product2.Product_Category_Type__c == 'Hardware')
				newOppMap.get(LineItem.OpportunityId).Total_Hardware_Currency__c = newOppMap.get(LineItem.OpportunityId).Total_Hardware_Currency__c + LineItem.TotalPrice;
				if (LineItem.Product2.Product_Category_Type__c == 'Others' && LineItem.opportunity.Price_List__r.Division__c != Null && LineItem.opportunity.Price_List__r.Division__c != 'MEP NA')
				newOppMap.get(LineItem.OpportunityId).Total_Others__c = newOppMap.get(LineItem.OpportunityId).Total_Others__c + LineItem.TotalPrice;
				if (LineItem.Product2.Product_Category_Type__c == 'Subscription')
				newOppMap.get(LineItem.OpportunityId).Total_Subscription__c = newOppMap.get(LineItem.OpportunityId).Total_Subscription__c + LineItem.TotalPrice;

				//Added for MEPNA     
				if (LineItem.Product2.Product_Category_Type__c == 'Rental')
				newOppMap.get(LineItem.OpportunityId).Total_Rental__c = newOppMap.get(LineItem.OpportunityId).Total_Rental__c + LineItem.TotalPrice;

				if (LineItem.opportunity.Price_List__r.Division__c != Null && LineItem.opportunity.Price_List__r.Division__c == 'MEP NA' && (LineItem.Product2.ICC_Type__c == 'Training - Hardware' || LineItem.Product2.ICC_Type__c == 'Training - Software'))
				newOppMap.get(LineItem.OpportunityId).MEPNA_Total_Training__c = newOppMap.get(LineItem.OpportunityId).MEPNA_Total_Training__c + LineItem.TotalPrice;

				if (LineItem.opportunity.Price_List__r.Division__c != Null && LineItem.opportunity.Price_List__r.Division__c == 'MEP NA' && LineItem.Product2.Product_Category_Type__c == 'Others' && !(LineItem.Product2.ICC_Type__c == 'Training - Hardware' || LineItem.Product2.ICC_Type__c == 'Training - Software'))
				newOppMap.get(LineItem.OpportunityId).Total_Others__c = newOppMap.get(LineItem.OpportunityId).Total_Others__c + LineItem.TotalPrice;

				if (LineItem.opportunity.Price_List__r.Division__c != Null && LineItem.opportunity.Price_List__r.Division__c == 'MEP NA')
				newOppMap.get(LineItem.OpportunityId).MEPNA_Total_Estimating__c = newOppMap.get(LineItem.OpportunityId).Total_SaaS__c + newOppMap.get(LineItem.OpportunityId).Total_Software_Currency__c;
				/*   for(String Str : SetStr)
				  {
				  availBusinessArea += Str+ ';';
				  }
				  // availBusinessArea = availBusinessArea .removeEnd(';');
				 
				  newOppMap.get(LineItem.OpportunityId).Opportunity_Product_Business_Area__c = availBusinessArea;     */
			}
		}

		//  }
	}

	//This method is used to derive the Business Unit of the Opportunity based on the Bill To and Ship To Country (Similar Logic on Apttus Agreement Object) 
	//This method is used to derive the Business Unit of the Opportunity based on the Bill To and Ship To Country (Similar Logic on Apttus Agreement Object) 
	Public static void updateBusinessUnit(Map<Id, Opportunity> newOppMap)
	{
		Map<String, Country_To_BU_Map__c> countryBUMap;
		Map<String, Reseller_LE_and_OU__c> resellerBUMap;
		/*Set<String> setRevenueNum = new Set<String>();
		  Set<ID> setOppID = new Set<ID>();
		  for(Opportunity Opp : newOppMap.values()){
		  if(Opp.Revenue_Arrangement_Number__c!=Null) setRevenueNum.add(Opp.Revenue_Arrangement_Number__c);
		  setOppID.add(Opp.id);
		  }*/

		countryBUMap = Country_To_BU_Map__c.getAll();
		resellerBUMap = Reseller_LE_and_OU__c.getAll();
		Map<ID, Opportunity> mapOppData = new Map<Id, Opportunity> ([select id, Bill_To_Account__c, Price_List__r.Division__c, Opportunity_Number__c, Bill_To_Account__r.EBS_Legal_Entity__c, Bill_to_Address__r.Country__c, Ship_to_Address1__r.Country__c from Opportunity where id in :newOppMap.values()]);
		//Map<String,Opportunity>revnueDupcheck = new Map<String,Opportunity>();

		/* for(Opportunity Opp : [select id,Mavenlink_Project_Number__c,Revenue_Arrangement_Number__c  from Opportunity where Mavenlink_Project_Number__c!=Null and Revenue_Arrangement_Number__c in: setRevenueNum])
		  {
		  if(!setOppID.contains(Opp.id))
		  revnueDupcheck.put(Opp.Revenue_Arrangement_Number__c,Opp);
		  }*/

		String REST_OF_WORLD = 'Rest of World';
		if (launchControl.get('updateBusinessUnit') < 1) {
			launchControl.put('updateBusinessUnit', launchControl.get('updateBusinessUnit') + 1);
			String billToCountry, shipToCountry;
			String billToLegalEntity;
			String billToAccountID;
			String PriceListDivision;

			Map<String, Reseller_LE_and_OU__c> mapResellerLEOU = new Map<String, Reseller_LE_and_OU__c> ();
			for (Opportunity Opp : newOppMap.values())
			{
				try {
					// newOppMap.get(Opp.id).Revenue_Arrangement_Number__c = mapOppData.get(opp.id).Opportunity_Number__c;
					/* if(newOppMap.get(Opp.id).Revenue_Arrangement_Number__c!= Null && revnueDupcheck.get(newOppMap.get(Opp.id).Revenue_Arrangement_Number__c) != Null)
					  newOppMap.get(Opp.id).Revenue_Arrangement_Number__c.adderror('This revenue arrangement number is already associated with project# '+revnueDupcheck.get(newOppMap.get(Opp.id).Revenue_Arrangement_Number__c).Mavenlink_Project_Number__c);*/

					for (Reseller_LE_and_OU__c reseller : resellerBUMap.values()) {
						mapResellerLEOU.put(reseller.Account_Id__c, reseller);
					}
					system.debug('>>>>>>>mapOppData>>>>>>>>>>>>>' + mapOppData);
					system.debug('>>>>>>>opp.id>>>>>>>>>>>>>' + opp.id);
					billToAccountID = mapOppData.get(opp.id).Bill_To_Account__c;
					billToLegalEntity = mapOppData.get(opp.id).Bill_To_Account__r.EBS_Legal_Entity__c;
					billToCountry = mapOppData.get(opp.id).Bill_to_Address__r.Country__c;
					shipToCountry = mapOppData.get(opp.id).Ship_to_Address1__r.Country__c;
					PriceListDivision = mapOppData.get(opp.id).Price_List__r.Division__c;
				}
				catch(System.NullPointerException ex) {
					//billToAccountName = null;
					billToAccountID = null;
					billToCountry = null;
					shipToCountry = null;
					billToLegalEntity = null;
				}
				// Additional COnditions added for MEP NA 
				if (PriceListDivision != Null && PriceListDivision != '' && String.isNotBlank(billToCountry) && PriceListDivision == 'MEP NA' && billToCountry == 'United States')
				{
					newOppMap.get(opp.id).Legal_Entity__c = 'Trimble Inc.';

				}
				else if (PriceListDivision != Null && PriceListDivision != '' && String.isNotBlank(billToCountry) && PriceListDivision == 'MEP NA' && billToCountry != 'United States')
				{
					newOppMap.get(opp.id).Legal_Entity__c = 'Trimble Europe B.V.';

				}
				if (mapResellerLEOU.containsKey(billToAccountID)) {
					newOppMap.get(opp.id).Legal_Entity__c = mapResellerLEOU.get(billToAccountID).Legal_Entity__c;
				} else if (String.isNotBlank(billToLegalEntity)) {
					newOppMap.get(opp.id).Legal_Entity__c = billToLegalEntity;
				} else {

					if (newOppMap.get(opp.id).Selling_Division__c == 'MEP')
					{
						if (String.isNotBlank(billToCountry) && billToCountry == shipToCountry) {
							Country_To_BU_Map__c record = countryBUMap.get(newOppMap.get(opp.id).Selling_division__c + '-' + billToCountry);
							// Bill To and Ship To are same and not in Lookup 
							if (record == null) {
								record = countryBUMap.get('MEP-REST_OF_THE_WORLD');
							}
							if (record != null) {
								newOppMap.get(opp.id).Legal_Entity__c = record.Legal_Entity__c;
							}
						}
						// Bill To and Ship To are different and Not in Lookup 
						else
						{
							Country_To_BU_Map__c record = countryBUMap.get('MEP-REST_OF_THE_WORLD');
							if (record != null)
							newOppMap.get(opp.id).Legal_Entity__c = record.Legal_Entity__c;
						}
					}
					else
					{
						if (String.isNotBlank(billToCountry) && billToCountry == shipToCountry) {
							Country_To_BU_Map__c record = countryBUMap.get(billToCountry);
							// Bill To and Ship To are same and not in Lookup 
							if (record == null) {
								record = countryBUMap.get(REST_OF_WORLD);
							}
							if (record != null) {
								newOppMap.get(opp.id).Legal_Entity__c = record.Legal_Entity__c;
							}
						}
						// Bill To and Ship To are different and Not in Lookup 
						else
						{
							Country_To_BU_Map__c record = countryBUMap.get(REST_OF_WORLD);
							if (record != null)
							newOppMap.get(opp.id).Legal_Entity__c = record.Legal_Entity__c;
						}
					}
				}
			}
		}
	}

	// This method collects all the business area of the Product lines of an Opportunity and updates the same on Opportunity Header level at Opportunity_Product_Business_Area__c  field
	Public static void updateBusinessArea(List<Opportunity> opptyList)
	{
		if (launchControl.get('updateBusinessArea') < 1) {
			launchControl.put('updateBusinessArea', launchControl.get('updateBusinessArea') + 1);

			Set<Id> setOpptyIDs = new Set<Id> ();
			for (Opportunity Oppty : opptyList) {
				setOpptyIDs.add(Oppty.Id);
			}
			List<OpportunityLineItem> LineItemList = new List<OpportunityLineItem> ();
			LineItemList = [select id, OpportunityId, opportunity.Price_List__r.Division__c, Product2.Business_Area__c, Product2.ICC_Type__c, Product2.Product_Category_Type__c, TotalPrice from OpportunityLineItem
			                where Opportunityid in :setOpptyIDs];
			map<ID, Set<String>> FinalMap = new Map<ID, Set<String>> ();
			Set<String> SetStr;
			for (Opportunity Op : opptyList)
			{
				SetStr = new Set<String> ();
				for (OpportunityLineItem OpLine : LineItemList)
				{
					if (OpLine.OpportunityId == Op.id)
					{
						SetStr.add(OpLine.Product2.Business_Area__c);
					}
				}
				FinalMap.put(Op.Id, SetStr);
			}

			for (Opportunity Op : opptyList)
			{
				String availbusinessarea = '';
				if (FinalMap.get(op.id) != Null) {
					for (String Str : FinalMap.get(op.id))
					{
						availbusinessarea += Str + ';';
					}
					availbusinessarea = availbusinessarea.removeEnd(';');
					op.Opportunity_Product_Business_Area__c = availbusinessarea;
				}

			}


		}

	}
	// Added to Update Product Growth on Opportunity Lines - MEP and MEPNA division
	Public static void UpdateProductGrowth(List<Opportunity> OpptyList) {

		ID AccountID = OpptyList.get(0).Accountid;
		ID OpportunityID = OpptyList.get(0).id;
		List<OpportunityLineItem> OpportunityLinesList = new List<OpportunityLineItem> ();
		List<OpportunityLineItem> UpdateOpportunityLinesList = new List<OpportunityLineItem> ();
		List<Asset> OppAssets = new List<Asset> ();
		List<Entitlement> OppEntitlements = new List<Entitlement> ();
		List<Product_Line_and_Division__mdt> ProductLineData = new List<Product_Line_and_Division__mdt> ();
		Map<String, String> mapProductLines = new Map<String, String> ();
		Set<String> EntitlementProductLineSet = new Set<String> ();

		OpportunityLinesList = [SELECT Id, Quantity, Quantity_Disp__c, Type__c, Product2.Product_Line__c, Product2.Seat_Count__c FROM OpportunityLineItem WHERE Opportunityid = :OpportunityID];
		OppAssets = [select id, product2.Product_Line__c, (select id, Entitlement_Product__r.Product_Line__c, Asset.product2.Product_Line__c from entitlements where Accountid = :AccountID and Asset.Status != 'Cancelled') from Asset where Accountid = :AccountID and Status != 'Cancelled'];
		ProductLineData = [select id, Division__c, Product_Line__c from Product_Line_and_Division__mdt where Division__c != null];

		for (Product_Line_and_Division__mdt data : ProductLineData)
		{
			mapProductLines.put(data.Product_Line__c, data.Division__c);
		}

		for (Asset Ast : OppAssets)
		{
			if (Ast.Entitlements.size() > 0) {
				for (Entitlement Ent : Ast.Entitlements)
				{
					EntitlementProductLineSet.add(Ent.Entitlement_Product__r.Product_Line__c);
					OppEntitlements.add(Ent);

				}
				EntitlementProductLineSet.add(Ast.product2.Product_Line__c);
			}

		}

		for (OpportunityLineItem OpLine : OpportunityLinesList)
		{
			Boolean isReadytoUpdate = false;
			// Scenario 1: Renewal Line's Product Growth set to "Renewal"
			if (OpLine.Type__c == 'Renewal')
			{
				Opline.Product_Growth__c = 'Renewal';
				isReadytoUpdate = true;
			}
			// Scenario 2: New Customer with Trimble, customer not having any Assets/Entitlements
			else if (OppEntitlements.size() == 0 && OppAssets.size() == 0)
			{
				Opline.Product_Growth__c = 'New Logo Trimble';
				isReadytoUpdate = true;
			}
			// Scenario 3: Existing Customer with Assets/Entitlements, and buying other division Product
			else if ((OppEntitlements.size() > 0 || OppAssets.size() == 0) && !EntitlementProductLineSet.contains(OpLine.Product2.Product_Line__c) && mapProductLines.containsKey(OpLine.Product2.Product_Line__c) && mapProductLines.get(OpLine.Product2.Product_Line__c) != null)
			{
				Opline.Product_Growth__c = 'New Logo ' + mapProductLines.get(OpLine.Product2.Product_Line__c);
				isReadytoUpdate = true;
			}
			// Scenario 4: Existing Customer with Assets/Entitlements, and buying same Product Line which they already own.
			else if ((OppEntitlements.size() > 0 || OppAssets.size() == 0) && EntitlementProductLineSet.contains(OpLine.Product2.Product_Line__c) && mapProductLines.containsKey(OpLine.Product2.Product_Line__c) && mapProductLines.get(OpLine.Product2.Product_Line__c) != null)
			{
				Opline.Product_Growth__c = 'Existing Customer, Existing Business';
				isReadytoUpdate = true;
			}
			// Scenario 5: Existing Customer with Assets/Entitlements, already bought Product from the division, but buying different Product Line
			else if ((OppEntitlements.size() > 0 || OppAssets.size() == 0) && !EntitlementProductLineSet.contains(OpLine.Product2.Product_Line__c) && mapProductLines.containsKey(OpLine.Product2.Product_Line__c) && mapProductLines.get(OpLine.Product2.Product_Line__c) != null)
			{
				Opline.Product_Growth__c = 'Existing Customer, New Business';
				isReadytoUpdate = true;
			}

			if (OpLine.Product2.Seat_Count__c != null && OpLine.Product2.Seat_Count__c.isNumeric()) {
				if (OpLine.Quantity_Disp__c != null) {
					Opline.Seats__c = Integer.valueOf(OpLine.Quantity_Disp__c * Integer.valueOf(OpLine.Product2.Seat_Count__c));
					isReadytoUpdate = true;
				}
				else if (OpLine.Quantity != null) {
					Opline.Seats__c = Integer.valueOf(OpLine.Quantity * Integer.valueOf(OpLine.Product2.Seat_Count__c));
					isReadytoUpdate = true;
				}
			}

			if (isReadytoUpdate)
			{
				UpdateOpportunityLinesList.add(Opline);
			}
		}
		if (UpdateOpportunityLinesList.size() > 0) update UpdateOpportunityLinesList;
	}


	// Added to Update Service Start Date and End date of Line Item and Proposal Line Item From Opportunity 
	public static void updateStartdateEnddate(List<Opportunity> OpptyList) {

		List<Apttus_Proposal__Proposal__c> ProposalList = new List<Apttus_Proposal__Proposal__c> ();
		List<Apttus_Config2__ProductConfiguration__c> ProdConfigList = new List<Apttus_Config2__ProductConfiguration__c> ();
		List<Apttus_Config2__LineItem__c> LineItem = new List<Apttus_Config2__LineItem__c> ();
		List<Apttus_Proposal__Proposal_Line_Item__c> ProposalLineItem = new List<Apttus_Proposal__Proposal_Line_Item__c> ();
		List<Apttus_Config2__LineItem__c> UpdateLineItem = new List<Apttus_Config2__LineItem__c> ();
		List<Apttus_Proposal__Proposal_Line_Item__c> UpdateProposalLineItem = new List<Apttus_Proposal__Proposal_Line_Item__c> ();
		Set<ID> ProposalID = new Set<ID> ();
		Set<ID> ProductConfigID = new Set<ID> ();
		Set<ID> OPPID = new Set<ID> ();

		for (opportunity Op : OpptyList)
		{
			OPPID.add(Op.Id);
		}
		for (Apttus_Proposal__Proposal__c Pro :[select id from Apttus_Proposal__Proposal__c where Apttus_Proposal__Opportunity__c IN :OPPID and Apttus_Proposal__Primary__c = TRUE])
		{
			ProposalID.add(Pro.Id);
		}

		for (Apttus_Config2__ProductConfiguration__c Config :[Select id from Apttus_Config2__ProductConfiguration__c where Apttus_QPConfig__Proposald__c IN :ProposalID and Apttus_Config2__Status__c = 'Finalized'])
		{
			ProductConfigID.add(Config.Id);
		}
		LineItem = [select id, Service_Start_Date__c, Service_End_date__c, Apttus_Config2__ProductId__c from Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c IN :ProductConfigID];
		ProposalLineItem = [select id, Service_Start_Date__c, Service_End_date__c, Apttus_Proposal__Product__c from Apttus_Proposal__Proposal_Line_Item__c where Apttus_Proposal__Proposal__c IN :ProposalID];
		for (Apttus_Config2__LineItem__c Li : LineItem)
		{
			Li.Service_Start_Date__c = System.today() + 3;
			Li.Service_End_date__c = Li.Service_Start_Date__c.addmonths(5) - 1;
			UpdateLineItem.add(Li);

		}


		for (Apttus_Proposal__Proposal_Line_Item__c ProLi : ProposalLineItem)
		{

			ProLi.Service_Start_Date__c = System.today() + 3;
			ProLi.Service_End_date__c = ProLi.Service_Start_Date__c.addmonths(5) - 1;
			UpdateProposalLineItem.add(ProLi);

		}

		system.debug('>>>>>>>>>OPPID>>>>>>>>>>>>>' + OPPID);
		system.debug('>>>>>>>>>ProposalID>>>>>>>>>>>>>' + ProposalID);
		system.debug('>>>>>>>>>ProductConfigID>>>>>>>>>>>>>' + ProductConfigID);
		system.debug('>>>>>>>>>UpdateLineItem>>>>>>>>>>>>>' + UpdateLineItem);
		system.debug('>>>>>>>>>UpdateProposalLineItem>>>>>>>>>>>>>' + UpdateProposalLineItem);


		if (UpdateLineItem.size() > 0) update UpdateLineItem;
		if (UpdateProposalLineItem.size() > 0) update UpdateProposalLineItem;
	}

	public static Boolean IsWeekendDay(Date dateParam)
	{
		boolean result = false;
		system.debug('dateParam = ' + dateParam);
		//Recover the day of the week
		Date startOfWeek = dateParam.toStartOfWeek();
		system.debug('startOfWeek = ' + startOfWeek);
		Integer dayOfWeek = dateParam.day() - startOfWeek.day();
		system.debug('dayOfWeek = ' + dayOfWeek);
		result = dayOfWeek == 0 || dayOfWeek == 6 ? true : false;
		system.debug('result = ' + result);
		return result;
	}


	public static Date AddBusinessDays(Date StartDate, integer BusinessDaysToAdd)
	{
		//Add or decrease in BusinessDaysToAdd days 
		Date finalDate = StartDate;
		system.debug('finaldate = ' + finalDate);
		integer direction = BusinessDaysToAdd< 0 ? - 1 : 1;
		system.debug('direction = ' + direction);
		while (BusinessDaysToAdd != 0)
		{
			finalDate = finalDate.AddDays(direction);
			system.debug('BusinessDaysToAdd = ' + BusinessDaysToAdd);
			system.debug('finaldate = ' + finalDate);
			if (!isWeekendDay(finalDate))
			{
				BusinessDaysToAdd -= direction;

			}
		}

		return finalDate;
	}
}