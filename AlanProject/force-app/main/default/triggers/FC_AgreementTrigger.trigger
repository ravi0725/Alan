trigger FC_AgreementTrigger on Apttus__APTS_Agreement__c(before insert, before update) {

	private static final String REST_OF_WORLD = 'Rest of World';

	Apttus_Proposal__Proposal__c[] quotesToUpdate = new List<Apttus_Proposal__Proposal__c> ();
	Map<Id, Apttus__APTS_Agreement__c> enhancedAgreementMap;
	Map<Id, RecordType> recordTypes;
	Map<String, Country_To_BU_Map__c> countryBUMap;
	Map<String, BU_To_Template_Map__c> BuTemplateMap;
	Map<String, Reseller_LE_and_OU__c> resellerBUMap;

	bulkBefore();

	for (Apttus__APTS_Agreement__c agreement : Trigger.new) {

		if (Trigger.isBefore) {
			if (Trigger.isInsert) {
				if (recordTypes.get(agreement.recordTypeId).DeveloperName == 'SOW_Only' || recordTypes.get(agreement.recordTypeId).DeveloperName == 'MSA') {
					if (isProfServ(agreement)) {
						agreement.Includes_Professional_Services__c = true;
					}
				}
				//setPPMBusinessUnit(agreement);

				validateTemplate(agreement);
			}
			if (Trigger.isUpdate) {
				// APP-7408 : If Professional Services = TRUE, Agreement Dates & ProServ Type cannot be blank
				if (agreement.Includes_Professional_Services__c == TRUE) {
					if (agreement.ProServ_Type__c == null) {
						agreement.ProServ_Type__c.addError('If Professional Services = TRUE, the ProServ Type cannot be blank. Please select the appropriate value to save this record.');
					}
					else if (agreement.Apttus__Contract_Start_Date__c == null) {
						agreement.Apttus__Contract_Start_Date__c.addError('If Professional Services = TRUE, Agreement Start Date cannot be blank.');
					}
					else if (agreement.Apttus__Contract_End_Date__c == null) {
						agreement.Apttus__Contract_End_Date__c.addError('If Professional Services = TRUE, Agreement End Date cannot be blank.');
					}
				}

				// END


				if (recordTypes.get(agreement.recordTypeId).DeveloperName == 'SOW_Only' || recordTypes.get(agreement.recordTypeId).DeveloperName == 'MSA') {
					if (isProfServ(agreement)) {
						agreement.Includes_Professional_Services__c = true;
					}
				}
				if (isStatusChangedTo(agreement, 'In Effect') &&
				    agreement.Apttus_QPComply__RelatedProposalId__c != null) {
					quotesToUpdate.add(new Apttus_Proposal__Proposal__c(
					                                                    Id = agreement.Apttus_QPComply__RelatedProposalId__c,
					                                                    Apttus_Proposal__Approval_Stage__c = 'Accepted'));
				}
				setPPMBusinessUnit(agreement);
				validateTemplate(agreement);
			}
		}
	}

	update quotesToUpdate;


	private Boolean isStatusChangedTo(Apttus__APTS_Agreement__c agreement, String statusCategory) {
		Apttus__APTS_Agreement__c oldAgreement = Trigger.oldMap.get(agreement.Id);
		return agreement.Apttus__Status_Category__c == statusCategory && oldAgreement.Apttus__Status_Category__c != statusCategory;

	}

	private void bulkBefore() {
		recordTypes = new Map<Id, RecordType> ([select DeveloperName from RecordType]);
		countryBUMap = Country_To_BU_Map__c.getAll();
		BuTemplateMap = BU_To_Template_Map__c.getAll();
		resellerBUMap = Reseller_LE_and_OU__c.getAll();
		enhancedAgreementMap = new Map<Id, Apttus__APTS_Agreement__c> ([select Apttus__Related_Opportunity__r.Mavenlink_Project_Number__c, Apttus_QPComply__RelatedProposalId__r.Bill_to_Address__r.Country__c,
		                                                               Apttus_QPComply__RelatedProposalId__r.Ship_to_Address1__r.Country__c, Apttus_QPComply__RelatedProposalId__r.Apttus_QPConfig__BillToAccountId__r.EBS_Legal_Entity__c,
		                                                               Apttus_QPComply__RelatedProposalId__r.Apttus_QPConfig__BillToAccountId__r.Name, Apttus_QPComply__RelatedProposalId__r.Apttus_QPConfig__BillToAccountId__r.Enterprise_Party_Number__c,
		                                                               Apttus_QPComply__RelatedProposalId__r.Apttus_QPConfig__BillToAccountId__c from Apttus__APTS_Agreement__c where Id in :Trigger.new]);
	}

	private Boolean isProfServ(Apttus__APTS_Agreement__c agreement) {
		if ([select Id from Apttus__AgreementLineItem__c where Apttus__AgreementId__c = :agreement.Id and Product_Type__c = 'Professional Services'].size() > 0) {
			return true;
		} else {
			return false;
		}
	}

	private void setPPMBusinessUnit(Apttus__APTS_Agreement__c agreement) {
		Apttus__APTS_Agreement__c enhancedAgreement = enhancedAgreementMap.get(agreement.Id);
		String billToCountry, shipToCountry;
		String billToLegalEntity;
		//String billToAccountName;
		String billToAccountID;
		Map<String, Reseller_LE_and_OU__c> mapResellerLEOU = new Map<String, Reseller_LE_and_OU__c> ();
		try {
			for (Reseller_LE_and_OU__c reseller : resellerBUMap.values()) {
				mapResellerLEOU.put(reseller.Account_Id__c, reseller);
			}
			//system.debug('--------enhancedAgreement----------' + enhancedAgreement.Apttus_QPComply__RelatedProposalId__c);
			system.debug('--------enhancedAgreement----------' + enhancedAgreement);
			//billToAccountName = enhancedAgreement.Apttus_QPComply__RelatedProposalId__r.Apttus_QPConfig__BillToAccountId__r.Name;
			billToAccountID = enhancedAgreement.Apttus_QPComply__RelatedProposalId__r.Apttus_QPConfig__BillToAccountId__c;
			billToLegalEntity = enhancedAgreement.Apttus_QPComply__RelatedProposalId__r.Apttus_QPConfig__BillToAccountId__r.EBS_Legal_Entity__c;
			billToCountry = enhancedAgreement.Apttus_QPComply__RelatedProposalId__r.Bill_to_Address__r.Country__c;
			shipToCountry = enhancedAgreement.Apttus_QPComply__RelatedProposalId__r.Ship_to_Address1__r.Country__c;
		} catch(System.NullPointerException ex) {
			//billToAccountName = null;
			billToAccountID = null;
			billToCountry = null;
			shipToCountry = null;
			billToLegalEntity = null;
		}
		if (mapResellerLEOU.containsKey(billToAccountID)) {
			agreement.Business_Unit__c = mapResellerLEOU.get(billToAccountID).Business_Unit__c;
		} else if (String.isNotBlank(billToLegalEntity)) {
			map<String, Country_To_BU_Map__c> LeBumap = new map<string, Country_To_BU_Map__c> ();
			for (Country_To_BU_Map__c BUmap : countryBUMap.values()) {
				LeBumap.put(BUmap.Legal_Entity__c, BUmap);
			}

			if (LeBumap.containsKey(billToLegalEntity)) {
				agreement.Business_Unit__c = LeBumap.get(billToLegalEntity).Business_Unit__c;
			}
		} else {
			if (String.isNotBlank(billToCountry) && billToCountry == shipToCountry) {
				Country_To_BU_Map__c record = countryBUMap.get(billToCountry);
				if (record == null) {
					record = countryBUMap.get(REST_OF_WORLD);
				}
				if (record != null) {
					agreement.Business_Unit__c = record.Business_unit__c;
				}
			}
		}
	}

	private void validateTemplate(Apttus__APTS_Agreement__c agreement) {
		if (String.isNotBlank(agreement.Template_Key__c)) {
			BU_To_Template_Map__c record = BuTemplateMap.get(agreement.Template_Key__c.split(':') [0]);
			if (record != null) {
				if (record.Business_Unit__c != agreement.Business_Unit__c) {
					agreement.Template_Key__c.addError('Template \'' + agreement.Template_Key__c.split(':') [0] + '\' is invalid for Business Unit \'' + agreement.Business_Unit__c + '\'');
				}
			}
		}
	}
}