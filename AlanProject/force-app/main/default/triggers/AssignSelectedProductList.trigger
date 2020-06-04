/*****************************************************************************************
  Name    : AssignSelectedProductList 
  Desc    : Quote/Proposal Trigger
  Modification Log : 
  ---------------------------------------------------------------------------
  Developer                 Date            Description
  ---------------------------------------------------------------------------
  Sagar Mehta			30/APR/2014     Created
 ******************************************************************************************/
trigger AssignSelectedProductList on Apttus_Proposal__Proposal__c(before insert, before update) {
	if (!RecursiveTriggerUtility.isBeforeAssignSelectedProductList) {
		RecursiveTriggerUtility.isBeforeAssignSelectedProductList = true;
		List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id = :userinfo.getProfileId() LIMIT 1];
		List<opportunity> opp = new List<Opportunity> ();
		Set<Id> OppID = new Set<Id> ();
		String MyProflieName = PROFILE.get(0).Name;
		//Code to Check if the Bill to Ship to Address is changed
		if (Trigger.IsUpdate) {
			for (Apttus_Proposal__Proposal__c Qt : trigger.new)
			{

				if (((trigger.oldmap.get(qt.id).Bill_to_Address__c != trigger.Newmap.get(qt.id).Bill_to_Address__c) || (trigger.oldmap.get(qt.id).Apttus_QPConfig__BillToAccountId__c != trigger.Newmap.get(qt.id).Apttus_QPConfig__BillToAccountId__c))
				    || ((trigger.oldmap.get(qt.id).Ship_to_Address1__c != trigger.Newmap.get(qt.id).Ship_to_Address1__c) || (trigger.oldmap.get(qt.id).Ship_To_Account__c != trigger.Newmap.get(qt.id).Ship_To_Account__c)))
				Qt.Address_Changed__c = true;
				if (trigger.oldmap.get(qt.id).Apttus_QPConfig__BillToAccountId__c != Null && trigger.oldmap.get(qt.id).Apttus_QPConfig__BillToAccountId__c != trigger.Newmap.get(qt.id).Apttus_QPConfig__BillToAccountId__c)
				Qt.Bill_to_Address_Changed__c = true;
			}
		}

		//Code to make Tax Value as Null at time of Cloning the Quote
		for (Apttus_Proposal__Proposal__c Qt : trigger.new)
		{
			oppId.add(Qt.Apttus_Proposal__Opportunity__c);
			if (Trigger.Isinsert && MyProflieName.contains('MEP'))
			Qt.Tax__c = Null;
			else if (Trigger.IsInsert)
			Qt.Tax__c = 0;
		}
		opp = [select id, toLabel(Payment_Term__c), toLabel(Type) from Opportunity where id in :OppId];

		//Code to Prevent Quote Creation if the Opportunity is Under Approval
		if (Trigger.Isinsert && opp.size() > 0)
		{
			// ProcessInstance pr = [ Select Id,Status From ProcessInstance WHERE TargetObjectId =: opp.get(0).Id AND Status = 'Pending' ];
			// system.debug('>>>>>>>>pr >>>>'+pr.Status);
			Boolean RecordLock = ![Select Id From ProcessInstance WHERE TargetObjectId = :opp.get(0).Id AND Status = 'Pending'].isEmpty();
			system.debug('>>>>>>>>OppID>>>>' + RecordLock);
			if (RecordLock == True) {
				system.debug('>>>>>>>>OppID>>>>' + opp.get(0).Id);
				system.debug('>>>>>>>>OppID>>>>' + RecordLock);
				trigger.new.get(0).adderror('Opportunity Record is Locked for Approval');
			}
		}


		Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c();
		proposal = trigger.new[0];
		proposal.Selected_Products_List__c = null;
		List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemList = new List<Apttus_Proposal__Proposal_Line_Item__c> ();

		//Create a set to store the Category Name of Proposal Line Item, usign set ensures the category names are unique.
		Set<String> categoryNameSet = new Set<String> ();
		String categoryName = '';
		proposalLineItemList = [select Id, Apttus_QPConfig__OptionId__r.Name, Apttus_QPConfig__OptionId__c, Apttus_Proposal__Product__c,
		                        Apttus_Proposal__Product__r.Name, Apttus_QPConfig__ClassificationId__c, Apttus_QPConfig__ClassificationId__r.Name, Apttus_QPConfig__ChargeType__c,
		                        Apttus_QPConfig__PriceListId__c, Apttus_QPConfig__PriceListId__r.Name, Apttus_Proposal__Product__r.ICC_Type__c
		                        from Apttus_Proposal__Proposal_Line_Item__c where Apttus_Proposal__Proposal__c = :proposal.Id];

		Boolean isUpdateShippingMethod_FTG = false;
		for (Apttus_Proposal__Proposal_Line_Item__c ali : proposalLineItemList) {
			if (proposal.Selected_Products_List__c == null) {
				proposal.Selected_Products_List__c = ali.Apttus_Proposal__Product__r.Name;
			} else if (proposal.Selected_Products_List__c != null && !proposal.Selected_Products_List__c.contains(ali.Apttus_Proposal__Product__r.Name)) {
				proposal.Selected_Products_List__c += ',' + ali.Apttus_Proposal__Product__r.Name;
			} else if (ali != null && ali.Apttus_QPConfig__OptionId__c == null) {
				proposal.Selected_Products_List__c += ',' + ali.Apttus_QPConfig__OptionId__r.Name;
			} else if (proposal.Selected_Products_List__c != null && !proposal.Selected_Products_List__c.contains(ali.Apttus_QPConfig__OptionId__r.Name)) {
				proposal.Selected_Products_List__c += ',' + ali.Apttus_QPConfig__OptionId__r.Name;
			}

			if (ali.Apttus_QPConfig__ClassificationId__c != null) {
				if (ali.Apttus_QPConfig__ChargeType__c == Label.Maintenance_Fee) {
					categoryNameSet.add(ali.Apttus_QPConfig__ClassificationId__r.Name + ', ' + Label.Maintenance_Fee);
				} else {
					categoryNameSet.add(ali.Apttus_QPConfig__ClassificationId__r.Name);
				}
			}

			if (ali.Apttus_QPConfig__PriceListId__c != null && ali.Apttus_QPConfig__PriceListId__r.Name != null &&
			(ali.Apttus_QPConfig__PriceListId__r.Name.contains('TIBV AT FTG Price List') || ali.Apttus_QPConfig__PriceListId__r.Name.contains('TIBV DE FTG Price List') || ali.Apttus_QPConfig__PriceListId__r.Name.contains('TIBV FR FTG Price List') || ali.Apttus_QPConfig__PriceListId__r.Name.contains('TIBV NL FTG Price List') || ali.Apttus_QPConfig__PriceListId__r.Name.contains('TIBV UK FTG Price List')) &&
			    ali.Apttus_Proposal__Product__c != null && ali.Apttus_Proposal__Product__r.ICC_Type__c != null && (ali.Apttus_Proposal__Product__r.ICC_Type__c == 'Hardware and Accessories' || ali.Apttus_Proposal__Product__r.ICC_Type__c == 'Kits')) {
				isUpdateShippingMethod_FTG = true;
			}
		}
		for (String category : categoryNameSet) {
			if (categoryName == '') {
				categoryName = category;
			} else {
				categoryName += ', ' + category;
			}
		}
		if (categoryName != '') {
			proposal.Selected_Sub_Group__c = categoryName;
		} else {
			proposal.Selected_Sub_Group__c = '';
		}

		if (isUpdateShippingMethod_FTG) {
			proposal.Freight_Method__c = 'UPS Standard';
			proposal.Freight_Terms__c = 'FCA (Eindhoven)';
		}
	}
}