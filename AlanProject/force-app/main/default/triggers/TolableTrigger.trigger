/**
 * Company     : Trimble Software Technology Pvt Ltd.,
 * Description : To Handle Translation For Formula Fields (Payment Terms From Opportunity, Opportunity Type From Opportunity) on Quotes / Proposal from Opportunity.
 * History     :
 * [02.APR.2014] Prince Leo Created
 * [03.DEC.2018] Suresh Babu Murugan : Modified : TT 142408 - New Template for RE&WS
 * [30.OCT.2019] Suresh Babu Murugan : Modified : APP-14245 - Salesforce CPQ Requires Quote Return
*/

trigger TolableTrigger on Apttus_Proposal__Proposal__c(before update, after update, before insert) {
	if (Trigger.IsUpdate && !RecursiveTriggerUtility.stopLineItemTrigger_ApprovalRequestListener) {
		List<opportunity> opp = new List<Opportunity> ();
		List<Apttus_Proposal__Proposal_Line_Item__c> LineItem = new List<Apttus_Proposal__Proposal_Line_Item__c> ();
		List<Account> AccList = new List<Account> ();
		Integer PositiveQ = 0, NegativeQ = 0, Subscription = 0;
		Set<Id> OppID = new Set<Id> ();
		Set<Id> PropID = new Set<ID> ();
		Set<Id> AccId = new Set<ID> ();
		Id profileId = userinfo.getProfileId();

		if (checkRecursive.isToLable()) {
			checkRecursive.setToLable();
			for (Apttus_Proposal__Proposal__c app : Trigger.new) {
				oppId.add(app.Apttus_Proposal__Opportunity__c);
				PropID.add(app.ID);
				AccId.add(app.Apttus_Proposal__Account__c);
			}
			system.debug(PropID);
			LineItem = [Select id, Apttus_QPConfig__Quantity2__c, Apttus_Proposal__Product__r.Business_Area__c, Apttus_Proposal__Product__r.ICC_Type__c from Apttus_Proposal__Proposal_Line_Item__c where Apttus_Proposal__Proposal__c in :PropID];
			//Apttus_Proposal__Proposal__c Proposal = [select id,Ship_To_Country__c,Ship_to_Address1__r.Country__c,convertCurrency(Initial_Price_Display__c),convertCurrency(Discounted_Price_Display__c),convertCurrency(Shipping_Fee__c),convertCurrency(Grand_Total_Display__c) from Apttus_Proposal__Proposal__c where id =: trigger.new.get(0).id];
			AccList = [Select id, Type from Account where id in :AccId];
			opp = [select id, toLabel(Payment_Term__c), toLabel(Type), Account_Sub_Type__c from Opportunity where id in :OppId];

			// Removing the logic : #APP-11063
			/*
			  for (Apttus_Proposal__Proposal__c ap : Trigger.new) {
			  for (Apttus_Proposal__Proposal_Line_Item__c quoLine : LineItem) {
			  if ((quoLine.Apttus_Proposal__Product__r.ICC_Type__c != Null && (quoLine.Apttus_Proposal__Product__r.ICC_Type__c == 'Scheduled Publications' || quoLine.Apttus_Proposal__Product__r.ICC_Type__c == 'Unscheduled Publications')) && quoLine.Apttus_Proposal__Product__r.Business_Area__c != Null && quoLine.Apttus_Proposal__Product__r.Business_Area__c == 'TRADE SERVICE') {
			  Subscription = Subscription + 1;
			  }
			  }
			  }
			 */
			for (Apttus_Proposal__Proposal__c ap : Trigger.new) {
				if (opp.size() > 0) {
					ap.Payment_Terms_In_Opportunity__c = opp[0].Payment_Term__c;
					ap.Opportunity_Type_From_Opportunity__c = opp[0].Type;

					if (ap.Billing_Frequency_Updated__c == False && (opp.get(0).Account_Sub_Type__c == 'Rental' || opp.get(0).Account_Sub_Type__c == 'Evaluation')) { // removed condition :  Subscription > 0 #APP-11063
						ap.Billing_Frequency__c = 'Month';
						ap.Billing_Frequency_Updated__c = True;
					}
				}
			}

			for (Apttus_Proposal__Proposal__c ap : Trigger.new) {
				if (trigger.oldmap.get(ap.id).Order_Type__c != trigger.newmap.get(ap.id).Order_Type__c && trigger.oldmap.get(ap.id).Order_Type__c != null)
				ap.Order_Type_Update__c = True;
				if (ap.Order_Type_Update__c == False && Trigger.Isupdate) {
					for (Apttus_Proposal__Proposal_Line_Item__c Li : LineItem) {
						if (Li.Apttus_QPConfig__Quantity2__c > 0)
						PositiveQ = PositiveQ + 1;
						else if (Li.Apttus_QPConfig__Quantity2__c< 0)
						NegativeQ = NegativeQ + 1;
					}
					/* if(Proposal != Null && !(Proposal.Ship_to_Address1__r.country__c.containsIgnoreCase('US') || Proposal.Ship_to_Address1__r.country__c.containsIgnoreCase('United States') || Proposal.Ship_to_Address1__r.country__c.containsIgnoreCase('Canada'))){
					  ap.Order_Type__c = 'EXT';
					  }*/
					if (AccList.size()> 0 && AccList.get(0).Type == 'GSA' && PositiveQ > 0 && NegativeQ > 0)
					ap.Order_Type__c = 'GSAUPG';
					else if (AccList.size() > 0 && AccList.get(0).Type == 'GSA')
					ap.Order_Type__c = 'GSA';
					else if (opp.size() > 0 && opp.get(0).Account_Sub_Type__c != Null && opp.get(0).Account_Sub_Type__c == 'Trial')
					ap.order_type__c = 'TRL';
					else if (opp.size() > 0 && opp.get(0).Account_Sub_Type__c != Null && (opp.get(0).Account_Sub_Type__c == 'Rental' || opp.get(0).Account_Sub_Type__c == 'Evaluation'))
					ap.order_type__c = 'RNT';
					else if (opp.size() > 0 && opp.get(0).Account_Sub_Type__c != Null && opp.get(0).Account_Sub_Type__c == 'Replacement')
					ap.order_type__c = 'RPL';
					else if (PositiveQ > 0 && NegativeQ > 0)
					ap.Order_Type__c = 'UPG';
					else if (PositiveQ > 0 && NegativeQ == 0)
					ap.Order_Type__c = 'REG';
					else if (PositiveQ == 0 && NegativeQ > 0)
					ap.Order_Type__c = 'RMA';
				}
			}
		}
		if (trigger.Isbefore && Trigger.Isupdate) {
			if (checkRecursive.isValidate()) {
				checkRecursive.setValidate();
				Boolean Acc, Add, Con;
				Map<ID, Account> AccMap = new Map<Id, Account> ([Select id, FCH_Party_ID__c, Leasing_Customer__c from Account where id = :trigger.new.get(0).Ship_To_Account__c or id = :trigger.new.get(0).Apttus_QPConfig__BillToAccountId__c]);
				Map<ID, Contact> ConMap = new Map<ID, Contact> ([Select id, FCH_Contact_Id__c from Contact where id = :trigger.new.get(0).Apttus_Proposal__Primary_Contact__c or id = :trigger.new.get(0).Bill_To_Contact__c]);
				Map<ID, Address__c> AddMap = new Map<Id, Address__c> ([Select id, FCH_Party_Site_ID__c from Address__c where id = :trigger.new.get(0).Ship_to_Address1__c or id = :trigger.new.get(0).Bill_to_Address__c]);


				for (Apttus_Proposal__Proposal__c ap : Trigger.new) {
					for (Account Ac : AccMap.values()) {
						if (Ac.Leasing_Customer__c == True) {
							ap.Renewal_Bill_To__c = 'SHIP-TO';
						}
					}
				}

				for (Account Ac : AccMap.values()) {
					if (Ac.FCH_Party_ID__c == Null) {
						Acc = True;
						break;
					}
				}
				for (Address__c Ad : AddMap.values()) {
					if (Ad.FCH_Party_Site_ID__c == Null) {
						Add = True;
						break;
					}
				}
				for (Contact co : ConMap.values()) {
					if (Co.FCH_Contact_Id__c == Null) {
						Con = True;
						break;
					}
				}

				if (Acc == True || Add == True || Con == True || trigger.new.get(0).Ship_To_Account__c == Null || trigger.new.get(0).Ship_To_Account__c == Null || trigger.new.get(0).Apttus_Proposal__Primary_Contact__c == Null || trigger.new.get(0).Bill_To_Contact__c == Null || trigger.new.get(0).Ship_to_Address1__c == Null || trigger.new.get(0).Bill_to_Address__c == Null) {
					// trigger.new.get(0).Can_Validate__c= True;
					trigger.new.get(0).Validate_Status__c = False;
				}
				else {
					trigger.new.get(0).Validate_Status__c = True;
					trigger.new.get(0).Can_Validate__c = False;
				}
				/* Apttus_Proposal__Proposal__c QuoteHeader = [select id,Ship_To_Account__r.FCH_Party_ID__c,Apttus_QPConfig__BillToAccountId__r.FCH_Party_ID__c, Apttus_QPConfig__ShipToAccountId__r.FCH_Party_ID__c, Bill_to_Address__r.FCH_Party_Site_ID__c, Ship_to_Address1__r.FCH_Party_Site_ID__c, Bill_To_Contact__r.FCH_Contact_Id__c, Apttus_Proposal__Primary_Contact__r.FCH_Contact_Id__c from Apttus_Proposal__Proposal__c where id=:trigger.new.get(0).id];
				  if(QuoteHeader.Apttus_QPConfig__BillToAccountId__r.FCH_Party_ID__c == Null || QuoteHeader.Ship_To_Account__r.FCH_Party_ID__c==Null || QuoteHeader.Bill_to_Address__r.FCH_Party_Site_ID__c==Null || QuoteHeader.Ship_to_Address1__r.FCH_Party_Site_ID__c==Null || QuoteHeader.Bill_To_Contact__r.FCH_Contact_Id__c==Null|| QuoteHeader.Apttus_Proposal__Primary_Contact__r.FCH_Contact_Id__c==Null)
				  trigger.new.get(0).Can_Validate__c= True;
				  else
				  trigger.new.get(0).Can_Validate__c= False;
				  RecControl = True;
				  system.debug('>>>>>>>>>Contact>>>>>>'+QuoteHeader.Bill_To_Contact__r.FCH_Contact_Id__c);
				  system.debug('>>>>>>>>>Contact>>>>>>'+trigger.new[0].Bill_To_Contact__c);
				  //update Trigger.new.get(0); */

				// TT 142408 - New Template for RE&WS
				Map<String, Date> mapServiceStart = new Map<String, Date> ();
				Map<String, Date> mapServiceEnd = new Map<String, Date> ();
				List<AggregateResult> lstPropLines = [SELECT MIN(Service_Start_Date__c) minStartDate, MAX(Service_End_Date__c) maxEndDate, Apttus_Proposal__Proposal__c pID FROM Apttus_Proposal__Proposal_Line_Item__c WHERE Apttus_Proposal__Proposal__c IN :PropID AND Service_Start_Date__c != NULL AND Service_End_Date__c != NULL GROUP BY Apttus_Proposal__Proposal__c];
				for (AggregateResult pItem : lstPropLines) {
					mapServiceStart.put(String.valueOf(pItem.get('pID')), Date.valueOf(pItem.get('minStartDate')));
					mapServiceEnd.put(String.valueOf(pItem.get('pID')), Date.valueOf(pItem.get('maxEndDate')));
				}

				for (Apttus_Proposal__Proposal__c prop : Trigger.new) {
					if (mapServiceStart.containsKey(prop.Id)) {
						prop.Service_Start_Date__c = mapServiceStart.get(prop.Id);
					}
					if (mapServiceEnd.containsKey(prop.Id)) {
						prop.Service_End_Date__c = mapServiceEnd.get(prop.Id);
					}
				}
			}
		}
	}
	// Added for validating if FCH IDs are available at Contact and Address Level
	if (trigger.Isbefore && Trigger.IsInsert && !RecursiveTriggerUtility.stopLineItemTrigger_ApprovalRequestListener) {
		List<Opportunity> QuoteHeader = new List<Opportunity> ();
		QuoteHeader = [select id, Ship_To_Account__r.FCH_Party_ID__c, Bill_To_Account__r.FCH_Party_ID__c, Bill_to_Address__r.FCH_Party_Site_ID__c, Ship_to_Address1__r.FCH_Party_Site_ID__c, Bill_To_Contact__r.FCH_Contact_Id__c, Primary_Contact__r.FCH_Contact_Id__c from opportunity where id = :trigger.new.get(0).Apttus_Proposal__Opportunity__c];
		if (QuoteHeader.size() > 0) {
			if (QuoteHeader.get(0).Bill_To_Account__r.FCH_Party_ID__c == Null || QuoteHeader.get(0).Ship_To_Account__r.FCH_Party_ID__c == Null || QuoteHeader.get(0).Bill_to_Address__r.FCH_Party_Site_ID__c == Null || QuoteHeader.get(0).Ship_to_Address1__r.FCH_Party_Site_ID__c == Null || QuoteHeader.get(0).Bill_To_Contact__c == Null || QuoteHeader.get(0).Primary_Contact__c == Null)
			trigger.new.get(0).Can_Validate__c = True;
		}
	}
}