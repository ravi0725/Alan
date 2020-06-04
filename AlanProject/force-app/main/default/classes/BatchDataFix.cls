/*****************************************************************************************
  Name    : BatchDataFix 
  Desc    : Used to autofix the Sync with Opportunity Issue using batch mode 
  Modification Log :
  ---------------------------------------------------------------------------
  Developer              Date            Description
  ---------------------------------------------------------------------------
  Prince Leo           21/05/2019          Created
 ******************************************************************************************/
Global class BatchDataFix Implements Database.batchable<sobject>, Schedulable {
	global final string query;

	/**
	 * @description Executes the scheduled Apex job. 
	 * @param sc contains the job ID
	 */
	global void execute(SchedulableContext sc) {
		BatchDataFix b = new BatchDataFix();
		database.executebatch(b, 1);
	}

	global BatchDataFix() {
		if (test.isrunningTest())
		query = 'SELECT Id FROM Apttus_Proposal__Proposal__c WHERE Amount_Check__c = FALSE LIMIT 1';
		else
		query = 'SELECT Id FROM Apttus_Proposal__Proposal__c WHERE Amount_Check__c = FALSE AND Apttus_Proposal__Primary__c = TRUE AND Apttus_Proposal__Approval_Stage__c NOT IN (\'Draft\', \'Approval Required\', \'In Review\', \'Denied\', \'Approval Rejected\', \'Cancelled\', \'Generated\') AND Apttus_Proposal__Opportunity__r.StageName NOT IN (\'Closed Lost\', \'Closed / Merged\', \'Closed / Migrated\') AND Apttus_Proposal__Opportunity__r.HasOpportunityLineItem = TRUE AND Quote_Validated__c = TRUE ORDER BY LastModifiedDate DESC LIMIT 1000';
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		system.debug('********' + Database.getQueryLocator(query));
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<SObject> scope) {
		List<Apttus_Proposal__Proposal__c> batchList = new List<Apttus_Proposal__Proposal__c> ();
		batchList = scope;
		Id ProposalID = batchList.get(0).Id;

		Apttus_Proposal__Proposal__c Proposal;
		List<OpportunityLineItem> InsertoppLine = new List<OpportunityLineItem> ();
		List<Apttus_Proposal__Proposal_Line_Item__c> ProposalLine = new List<Apttus_Proposal__Proposal_Line_Item__c> ();
		Opportunity op;

		Proposal = [Select id, Software_Total_Disp__c, Service_Total_Disp__c, Maintenance_Total_Disp__C, Software_Net_Price__c, Service_Net_Price__c, Hardware_Discount_Disp__c, Maintenance_Disc_Disp__c, Service_Discount2__c, Software_Disc_2dec__c, Hardware_Total_Disp__c, Apttus_Proposal__Primary__c, Hardware_Total__c, Maintenance_Total__c, Service_Total__c, Software_Total__c, Discounted_Amount__c, Apttus_Proposal__Opportunity__c, Discounted_Price_Display__c from Apttus_Proposal__Proposal__c where id = :ProposalID];
		system.debug('---sync---proposal---' + Proposal);
		op = [Select id, Price_List_Name__c, priceBook2id, CurrencyISOCode, Total_Hardware_Currency__c, Total_Maintenance_Currency__c, Total_Service_Currency__c, Total_Software_Currency__c, Discount__c, Amount from opportunity where id = :Proposal.Apttus_Proposal__Opportunity__c];
		system.debug('----sync--op--' + op);
		ProposalLine = [Select id, Type__c, Service_Start_Date__c, Service_End_Date__c, Apttus_QPConfig__DerivedFromId__r.Staging__c, Apttus_QPConfig__DerivedFromId__r.Contract__c,
		                Apttus_QPConfig__DerivedFromId__r.Service_Line__c, Apttus_Proposal__Product__r.Oracle_Id__c, Discount_Amount__c, Apttus_QPConfig__NetAdjustmentPercent__c, Apttus_QPConfig__ListPrice__c, Quantity_Disp__c, Apttus_Proposal__Product__c, Apttus_QPConfig__OptionId__c, Apttus_QPConfig__NetPrice__c,
		                Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__r.Name, Apttus_QPConfig__DerivedFromId__r.Price_List_Division__c, Apttus_QPConfig__DerivedFromId__r.Apttus_Config2__AssetId__c, Unit_Selling_Price__c
		                from Apttus_Proposal__Proposal_Line_Item__c where Apttus_Proposal__Proposal__c = :ProposalID and((Apttus_QPConfig__OptionId__c != Null and Apttus_QPConfig__ListPrice__c != Null) or((Apttus_QPConfig__OptionId__c = Null and Apttus_QPConfig__ListPrice__c != Null)))];
		system.debug('---sync---ProposalLine---' + ProposalLine);

		try {
			if (Proposal.Apttus_Proposal__Primary__c == True) {
				Map<Id, Id> prdPbeMap = new Map<Id, Id> ();
				Map<Id, Id> stdPrdPbeMap = new Map<Id, Id> ();
				Id stdPRiceBookId = [select Id from PriceBook2 where IsStandard = true].Id;
				for (Apttus_Proposal__Proposal_Line_Item__c PropLine : ProposalLine) {
					if (PropLine.Apttus_QPConfig__OptionId__c != Null) {
						prdPbeMap.put(PropLine.Apttus_QPConfig__OptionId__c, null);
						stdPrdPbeMap.put(PropLine.Apttus_QPConfig__OptionId__c, null);
					} else {
						prdPbeMap.put(PropLine.Apttus_Proposal__Product__c, null);
						stdPrdPbeMap.put(PropLine.Apttus_Proposal__Product__c, null);
					}
				}
				List<PriceBookEntry> pbeList = new List<PriceBookEntry> ();
				for (PriceBookEntry pbe :[select Id, isActive, Product2id, Pricebook2id, Pricebook2.IsStandard from PriceBookEntry where Product2id in :prdPbeMap.keySet()
				     and CurrencyISOCode = :op.CurrencyISOCode and(PriceBook2Id = :op.Pricebook2Id or
				                                                   Pricebook2.IsStandard = true)]) {
					if (pbe.Pricebook2.IsStandard) {
						if (pbe.IsActive) {
							stdPrdPbeMap.put(pbe.Product2id, pbe.Id);
						} else {
							stdPrdPbeMap.put(pbe.Product2id, pbe.Id);
							pbe.IsActive = true;
							pbeList.add(pbe);
						}
					} else {
						if (pbe.IsActive) {
							prdPbeMap.put(pbe.Product2id, pbe.Id);
						} else {
							prdPbeMap.put(pbe.Product2id, pbe.Id);
							pbe.IsActive = true;
							pbeList.add(pbe);
						}
					}
				}
				if (pbeList.size() > 0) {
					update pbeList;
				}
				pbeList = new List<PriceBookEntry> ();
				PriceBookEntry pbe = new PriceBookEntry();


				for (String key : stdPrdPbeMap.keySet()) {
					if (stdPrdPbeMap.get(key) == null) {
						pbe = new PriceBookEntry(); pbe.Pricebook2Id = stdPRiceBookId; pbe.Product2Id = key; pbe.CurrencyIsoCode = op.CurrencyIsoCode; pbe.UnitPrice = 0; pbe.IsActive = true; pbeList.add(pbe);
					}
				}


				for (String key : prdPbeMap.keySet()) {
					if (prdPbeMap.get(key) == null) {
						pbe = new PriceBookEntry(); pbe.Pricebook2Id = op.Pricebook2Id; pbe.Product2Id = key; pbe.CurrencyIsoCode = op.CurrencyIsoCode; pbe.UnitPrice = 0; pbe.IsActive = true; pbeList.add(pbe);
					}
				}
				if (pbeList.size() > 0) {
					insert pbeList;
				}
				for (PriceBookEntry pbe1 :[select Id, Product2id from PriceBookEntry where Id in :pbeList and
				     Pricebook2.IsStandard = false]) {
					prdPbeMap.put(pbe1.Product2id, pbe.Id);
				}

				List<OpportunityLineItem> OppLine = new List<OpportunityLineItem> ();
				OppLine = [Select id, Product2id, UnitPrice, Staging__c, Contract__c, Service_Line__c from OpportunityLineItem
				           where Opportunityid = :op.id];
				OpportunityHelper.deletedLineItemIds = new set<Id> ();
				for (OpportunityLineItem oppLiTm : OppLine) {
					OpportunityHelper.deletedLineItemIds.add(oppLiTm.Id);
				}

				for (Apttus_Proposal__Proposal_Line_Item__c PropLine : ProposalLine)
				{
					OpportunityLineItem Opp = new OpportunityLineItem();
					opp.Staging__c = PropLine.Apttus_QPConfig__DerivedFromId__r.Staging__c;
					opp.Contract__c = PropLine.Apttus_QPConfig__DerivedFromId__r.Contract__c;
					opp.Service_Line__c = PropLine.Apttus_QPConfig__DerivedFromId__r.Service_Line__c;
					opp.Asset__c = PropLine.Apttus_QPConfig__DerivedFromId__r.Apttus_Config2__AssetId__c;
					opp.Opportunityid = op.id;
					opp.Service_Start_Date__c = propLine.Service_Start_Date__c;
					opp.Service_End_Date__c = propLine.Service_End_Date__c;
					opp.Type__c = propLine.Type__c;
					if (PropLine.Apttus_QPConfig__OptionId__c != Null)
					opp.PricebookEntryId = prdPbeMap.get(PropLine.Apttus_QPConfig__OptionId__c);
					else
					opp.PricebookEntryId = prdPbeMap.get(PropLine.Apttus_Proposal__Product__c);
					system.debug('--------------------------' + PropLine.Discount_Amount__c);
					system.debug('--------------------------' + PropLine.Apttus_QPConfig__NetAdjustmentPercent__c);
					if (PropLine.Discount_Amount__c > 0 || PropLine.Apttus_QPConfig__NetAdjustmentPercent__c > 0 || (propLine.Service_Start_Date__c != Null && propLine.Service_End_Date__c != Null && propLine.Service_Start_Date__c.daysbetween(propLine.Service_End_Date__c) > 366 && propLine.Apttus_QPConfig__DerivedFromId__r.Price_List_Division__c != Null && propLine.Apttus_QPConfig__DerivedFromId__r.Price_List_Division__c == 'MEP NA')) {

						opp.UnitPrice = PropLine.Apttus_QPConfig__NetPrice__c / PropLine.Quantity_Disp__c;
						opp.Quantity = PropLine.Quantity_Disp__c;
						opp.Discount = 0;
						//opp.UnitPrice = PropLine.Apttus_QPConfig__NetAdjustmentPercent__c>100 ? PropLine.Apttus_QPConfig__NetPrice__c : PropLine.Discount_Amount__c;
						if (propLine.Apttus_Proposal__Product__r.Oracle_Id__c != Null && propLine.Apttus_Proposal__Product__r.Oracle_Id__c == 'SFDC_ONLY' && propLine.Apttus_QPConfig__OptionId__c == Null) opp.UnitPrice = 0;
						else
						{
							opp.UnitPrice = PropLine.Apttus_QPConfig__NetPrice__c / PropLine.Quantity_Disp__c;
							opp.Quantity = PropLine.Quantity_Disp__c;
							//opp.Discount = math.abs(PropLine.Apttus_QPConfig__NetAdjustmentPercent__c);
							//Opp.UnitPrice = (PropLine.Apttus_QPConfig__ListPrice__c== Null || PropLine.Quantity_Disp__c == null || PropLine.Quantity_Disp__c == 0) ? 0 : PropLine.Apttus_QPConfig__ListPrice__c;
						}
					}
					else
					{
						opp.Quantity = PropLine.Quantity_Disp__c;
						opp.Discount = math.abs(PropLine.Apttus_QPConfig__NetAdjustmentPercent__c);
						Opp.UnitPrice = (PropLine.Unit_Selling_Price__c == Null || PropLine.Quantity_Disp__c == null || PropLine.Quantity_Disp__c == 0) ? 0 : PropLine.Unit_Selling_Price__c;
					}
					system.debug(Opp.UnitPrice + '--------------Opp.TotalPRice------------' + Opp.TotalPRice);
					system.debug(Opp.UnitPrice + '--------------opp.Quantity------------' + opp.Quantity);
					InsertoppLine.add(Opp);
				}
				system.debug('--------------InsertoppLine------------' + InsertoppLine);
				if (InsertoppLine.size() > 0)
				{
					if (!Test.isRunningTest()) OpportunityLineItemHelper.launchControl.put('populateSerialNumbersOnOpportunity', 0);
					else OpportunityLineItemHelper.launchControl.put('populateSerialNumbersOnOpportunity', 1);
					Insert InsertoppLine;

					if (op.Price_List_Name__c.contains('TIBV')) {
						op.Total_Hardware_Currency__c = Proposal.Hardware_Total_Disp__c;
						op.Total_Maintenance_Currency__c = Proposal.Maintenance_Total_Disp__c;
						op.Total_Service_Currency__c = Proposal.Service_Total_Disp__c;
						op.Total_Software_Currency__c = Proposal.Software_Total_Disp__c;
					}
					OpportunityHelper.launchControl.put('RollupOpptyLines', 0);
					Update op;
				}
				if (OppLine.size() > 0) {
					if (!Test.isRunningTest()) OpportunityLineItemHelper.launchControl.put('populateSerialNumbersOnOpportunity', 0);
					else OpportunityLineItemHelper.launchControl.put('populateSerialNumbersOnOpportunity', 1);
					Delete OppLine;
				}

				system.debug('>>>>>>>>' + op.Amount);
			}
		} catch(Exception ex) {
			System.debug(' ERROR EXCEPTION :::' + ex.getTypeName());
			System.debug(' ERROR EXCEPTION :::' + ex.getLineNumber());
			System.debug(' ERROR EXCEPTION :::' + ex.getMessage());
			System.debug(' ERROR EXCEPTION :::' + ex.getCause());
		}
	}

	global void finish(Database.BatchableContext BC) { }
}