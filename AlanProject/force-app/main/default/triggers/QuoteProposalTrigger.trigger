/*****************************************************************************************
  Name    : QuoteProposalTrigger 
  Desc    : Its an after insert trigger which would create Price List related to QuoteProposal.
  The Proposal Line Items are records which correspond to the Price List related to the Opportunity of QuoteProposal.              
  Project ITEM: ITEM-00712, ITEM-00785
  Modification Log : 
  ---------------------------------------------------------------------------
  Developer				Date            Description
  ---------------------------------------------------------------------------
  Sagar Mehta			11/01/2013       Created
  Suresh Babu Murugan	25/03/2019       Modified : APP-3806 : update Lines if Quote Address/Account changed
  ******************************************************************************************/

trigger QuoteProposalTrigger on Apttus_Proposal__Proposal__c(before insert, before update, after insert, after update, before delete) {
	if (trigger.isDelete && trigger.isBefore) {
		QuoteProposalHandler.validateRenewalProposal(trigger.old);
	}

	if (trigger.isBefore && trigger.isUpdate) {
		QuoteProposalHandler.makeProposalPrimary(trigger.new, trigger.oldMap);

		/* Updated By Suresh Babu Murugan on 23/11/2016: Due to Higher Discounts calculation update in CFD */
		QuoteHigherDiscountCalculation.higherDiscountCalculation(trigger.new);
		QuoteHigherDiscountCalculation_MEPNA.higherDiscountCalculation(trigger.new);
		/**** ****/

		QuoteProposalLineItemCategory.proposalLineItemType(Trigger.new);

		QuoteProposalHandler.syncPropsalLinesAddressAndAccounts(Trigger.new, Trigger.oldMap);
	}

	if (Trigger.isBefore && Trigger.isInsert && !RecursiveTriggerUtility.isBeforeInsertQuoteProposalTrigger) {
		RecursiveTriggerUtility.isBeforeInsertQuoteProposalTrigger = true;
		try {
			system.debug('trigger.new.get(0).Clone_ID__c ====>' + trigger.new.get(0).Clone_ID__c);
			system.debug(' --->' + trigger.new.get(0).Apttus_Proposal__Account__c);
			Apttus_Proposal__Proposal__c Prop = new Apttus_Proposal__Proposal__c();
			if (trigger.new.get(0).Clone_ID__c != null) {
				Prop = [select id, Apttus_Proposal__Account__c, Name, Obsolete_Quote__c from Apttus_Proposal__Proposal__c where Name = :trigger.new.get(0).Clone_ID__c];
				system.debug(' Prop =======>>' + Prop);
				system.debug('IS TRUE ==========>>' + Prop.Apttus_Proposal__Account__c + '== =>' + trigger.new.get(0).Apttus_Proposal__Account__c);
				if (trigger.new.get(0).Apttus_Proposal__Account__c != Null && Prop.Apttus_Proposal__Account__c == trigger.new.get(0).Apttus_Proposal__Account__c) {
					system.debug('>>>>Inside the IF Condition>>>>>>');
					QuoteProposalHandler.makeQuoteProposalObsolete(trigger.new, trigger.newMap);
					QuoteProposalHandler.makeProposalPrimary(trigger.new, new Map<Id, Apttus_Proposal__Proposal__c> ());
				}
				else
				trigger.new.get(0).Clone_ID__c = trigger.new.get(0).Name;
			}

			Set<Id> optyIdSet = new Set<Id> ();

			for (Apttus_Proposal__Proposal__c proposal : Trigger.new) {
				if (proposal.Clone_Id__c == null && trigger.isInsert) {
					proposal.Clone_Id__c = proposal.Name;
				}
				optyIdSet.add(proposal.Apttus_Proposal__Opportunity__c);
			}

			Map<Id, Opportunity> optyMap = new Map<Id, Opportunity> ([Select Id, Price_List__c, Selling_Division__c, Payment_Term__c, Bill_To_Account__r.EBS_Payment_Term__c, Legacy_Payment_Term_Opty__c, Ship_To_Account__c, Owner.Manager.name from Opportunity where Id IN :optyIdSet]);
			for (Apttus_Proposal__Proposal__c proposal : Trigger.new) {
				try {
					//checking opportunity map size 
					if (optyMap.size() > 0) {
						if (optyMap.containsKey(proposal.Apttus_Proposal__Opportunity__c)) {
							proposal.Apttus_QPConfig__PriceListId__c = optyMap.get(proposal.Apttus_Proposal__Opportunity__c).Price_List__c;
							if (optyMap.get(proposal.Apttus_Proposal__Opportunity__c).Ship_To_Account__c != null) {
								proposal.Ship_To_Account__c = optyMap.get(proposal.Apttus_Proposal__Opportunity__c).Ship_To_Account__c;
							}
						}

						if (proposal.Deposit_Required__c != null) {
							optyMap.get(proposal.Apttus_Proposal__Opportunity__c).Legacy_Payment_Term_Opty__c = optyMap.get(proposal.Apttus_Proposal__Opportunity__c).Payment_Term__c;
							optyMap.get(proposal.Apttus_Proposal__Opportunity__c).Payment_Term__c = 'N10';
						} else {
							if (optyMap.get(proposal.Apttus_Proposal__Opportunity__c).Legacy_Payment_Term_Opty__c != null) {
								optyMap.get(proposal.Apttus_Proposal__Opportunity__c).Payment_Term__c = optyMap.get(proposal.Apttus_Proposal__Opportunity__c).Legacy_Payment_Term_Opty__c;
							}
						}
						proposal.Sales_Rep_Manager__c = optymap.get(proposal.Apttus_Proposal__Opportunity__c).Owner.Manager.name;

						if (optyMap.get(proposal.Apttus_Proposal__Opportunity__c).Selling_Division__c.contains('MEP NA'))
						{
							MEP_NA_Payment_Method__c PayTerm = MEP_NA_Payment_Method__c.getValues(optyMap.get(proposal.Apttus_Proposal__Opportunity__c).Payment_Term__c);
							String PayMethod = PayTerm.Payment_Method__c;
							proposal.Payment_Method__c = PayMethod;

						}
					}
				} catch(Exception e) {
					proposal.addError(e.getMessage());
				}
			}

			List<Opportunity> opptyList = optyMap.values();
			update opptyList;
		} catch(Exception e) {
			System.debug('Exception =================>' + e.getMessage());
		}
	}

	if (Trigger.isBefore && Trigger.isUpdate && !RecursiveTriggerUtility.isBeforeUpdateQuoteProposalTrigger) {
		RecursiveTriggerUtility.isBeforeUpdateQuoteProposalTrigger = true;
		try {
			QuoteProposalHandler.proposalAccessValidation(trigger.new);
			Map<String, Id> recordTypeMap = RecursiveTriggerUtility.loadRecordTypeMap(Event.SObjectType);
			Set<Id> proposalIdSet = new Set<Id> ();
			Set<Id> optyIdupdateSet = new Set<Id> ();
			List<Event> eventlist = new List<Event> ();
			Map<Id, String> quoteoracleid = new Map<Id, String> ();
			for (Apttus_Proposal__Proposal__c proposal : Trigger.new) {
				quoteoracleid.put(proposal.id, proposal.Order__c);
				optyIdupdateSet.add(proposal.Apttus_Proposal__Opportunity__c);
				//system.debug('proposal.Apttus_Proposal__Opportunity__r.Owner.Manager.Username;');
				proposal.Sales_Rep_Manager__c = proposal.Apttus_Proposal__Opportunity__r.Owner.Manager.Username;
			}
			Map<Id, Opportunity> optyupdateMap = new Map<Id, Opportunity> ([Select Id, Bill_To_Account__r.EBS_Payment_Term__c, Payment_Term__c, Legacy_Payment_Term_Opty__c, Owner.Manager.name from Opportunity where Id IN :optyIdupdateSet]);

			if (quoteoracleid.size() > 0) {
				eventlist = [Select Id, WhatId from event where WhatId IN :quoteoracleid.keySet() and RecordTypeId = :recordTypeMap.get(Label.Event_Service_Delivery_Record_Type)];
				if (eventlist.size() > 0) {
					for (Event ev : eventlist) {
						ev.WhatId = quoteoracleid.get(ev.WhatId);
					}
					update eventlist;
				}
			}
			for (Apttus_Proposal__Proposal__c proposal : Trigger.new) {
				try {
					if (optyupdateMap.size() > 0) {
						if (optyupdateMap.containsKey(proposal.Apttus_Proposal__Opportunity__c)) {
							if (proposal.Deposit_Required__c != null) {
								optyupdateMap.get(proposal.Apttus_Proposal__Opportunity__c).Legacy_Payment_Term_Opty__c = optyupdateMap.get(proposal.Apttus_Proposal__Opportunity__c).Payment_Term__c;
								optyupdateMap.get(proposal.Apttus_Proposal__Opportunity__c).Payment_Term__c = 'N10';
							} else {
								if (optyupdateMap.get(proposal.Apttus_Proposal__Opportunity__c).Legacy_Payment_Term_Opty__c != null) {
									optyupdateMap.get(proposal.Apttus_Proposal__Opportunity__c).Payment_Term__c = optyupdateMap.get(proposal.Apttus_Proposal__Opportunity__c).Legacy_Payment_Term_Opty__c;
								}
							}
						}
						proposal.Sales_Rep_Manager__c = optyupdateMap.get(proposal.Apttus_Proposal__Opportunity__c).Owner.Manager.name;
						if (proposal.Payment_Method__c != Null && proposal.Payment_Method__c != '') {
							if (proposal.Payment_Method__c == 'eCheck') {
								optyupdateMap.get(proposal.Apttus_Proposal__Opportunity__c).Payment_Term__c = 'eCheck';
							} else if (proposal.Payment_Method__c == 'CREDIT CARD') {
								optyupdateMap.get(proposal.Apttus_Proposal__Opportunity__c).Payment_Term__c = 'CREDIT CARD';
							}
							else if (proposal.Payment_Method__c == 'WIRE TRANSFER') {
								optyupdateMap.get(proposal.Apttus_Proposal__Opportunity__c).Payment_Term__c = 'CASH IN ADVANCE';
							}
							else {
								optyupdateMap.get(proposal.Apttus_Proposal__Opportunity__c).Payment_Term__c = optyupdateMap.get(proposal.Apttus_Proposal__Opportunity__c).Bill_To_Account__r.EBS_Payment_Term__c;
							}
						} else {
							optyupdateMap.get(proposal.Apttus_Proposal__Opportunity__c).Payment_Term__c = optyupdateMap.get(proposal.Apttus_Proposal__Opportunity__c).Bill_To_Account__r.EBS_Payment_Term__c;
						}
					}
				} catch(Exception e) {
					proposal.addError(e.getMessage());
				}
			}

			List<Opportunity> opptyupdateList = optyupdateMap.values();
			update opptyupdateList;
		} catch(Exception e) {
			System.debug(e.getMessage());
		}
	}
	system.debug('------------------------' + trigger.IsUpdate);
	system.debug('------------------------' + RecursiveTriggerUtility.isAfterInsertQuoteProposalTrigger);
	if (Trigger.IsAfter && trigger.IsUpdate /*&& !RecursiveTriggerUtility.isAfterInsertQuoteProposalTrigger*/)
	{
		RecursiveTriggerUtility.isAfterInsertQuoteProposalTrigger = true;
		QuoteProposalHandler.SyncWithOpportunity(trigger.new, trigger.newMap);
		QuoteProposalHandler.defaultCarePackTerm(trigger.new);
	}

	if (Trigger.IsAfter && trigger.IsUpdate)
	{

		Set<Id> OppID = new Set<Id> ();
		Set<Id> ProposalID = new Set<Id> ();
		Set<String> ContID = new Set<String> ();
		set<String> accIds = new set<String> ();
		//List<Contact> ConList = new List<Contact>();
		for (Apttus_Proposal__Proposal__c Qt : trigger.new)
		{

			ProposalID.add(Qt.id);

		}
		List<Apttus_Proposal__Proposal__c> ProposalRec = [select id, Apttus_Proposal__Primary_Contact__r.AccountId, Bill_To_Contact__r.AccountId, Bill_To_Contact__r.FCH_Contact_Id__c, Apttus_Proposal__Primary_Contact__r.FCH_Contact_Id__c from Apttus_Proposal__Proposal__c where id in :ProposalID];

		//Code to Make a Dummy update on Contact if FCH Party ID is missing - Creates contact in EBS & FCH 
		system.debug('---------ProposalRec.get(0).Bill_To_Contact__c---------' + ProposalRec.get(0).Bill_To_Contact__c);
		if (ProposalRec.get(0).Bill_To_Contact__c != Null && ProposalRec.get(0).Apttus_Proposal__Primary_Contact__c != Null)
		{
			system.debug('---------ProposalRec.get(0).Bill_To_Contact__r.FCH_Contact_Id__c---------' + ProposalRec.get(0).Bill_To_Contact__r.FCH_Contact_Id__c);
			if (ProposalRec.get(0).Bill_To_Contact__r.FCH_Contact_Id__c == Null) {
				ContID.add(ProposalRec.get(0).Bill_To_Contact__c);
				if (ProposalRec.get(0).Bill_To_Contact__r.AccountId != null) accIds.add(ProposalRec.get(0).Bill_To_Contact__r.AccountId);
			}
			system.debug('---------ProposalRec.get(0).Apttus_Proposal__Primary_Contact__r.FCH_Contact_Id__c---------' + ProposalRec.get(0).Apttus_Proposal__Primary_Contact__r.FCH_Contact_Id__c);
			if (ProposalRec.get(0).Apttus_Proposal__Primary_Contact__r.FCH_Contact_Id__c == Null) {
				ContID.add(ProposalRec.get(0).Apttus_Proposal__Primary_Contact__c);
				if (ProposalRec.get(0).Bill_To_Contact__r.AccountId != null) accIds.add(ProposalRec.get(0).Apttus_Proposal__Primary_Contact__r.AccountId);
			}
			system.debug('---------ContID---------' + ContID);
			//ConList = [select id,AccountId from contact where id in:ContID];
		}
		system.debug('---------accIds---------' + accIds);
		if (accIds.size() == 1) {
			/*Utils.SkipFieldTracking = true;
			  Update ConList;*/
			List<String> accIdList = new List<String> ();
			accIdList.addAll(accIds);
			//AccountCreationCalloutEX.CallEBS(accIdList,'NoOp','Update','NoOp',ContID,new set<String>(),new Set<String>());
		}
	}
}