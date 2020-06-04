/**
 * Company     : Trimble Software Technology Pvt Ltd.,
 * Description : 
 * History     :  
 
 * [18.09.2014] Prince Leo  Created
 * [04.11.2019] Suresh Babu Murugan		Modified : For ARR Calculation, added new field mapping from Quote lines to Opportunity lines.
*/
public with sharing class SyncWithOpportunityExt {
	public String errorMsg { get; set; }
	Public Apttus_Proposal__Proposal__c Prop;
	Opportunity op;
	Public ID ProposalID { get; set; }
	Apttus_Proposal__Proposal__c Proposal;
	List<OpportunityLineItem> InsertoppLine = new List<OpportunityLineItem> ();
	List<Apttus_Proposal__Proposal_Line_Item__c> ProposalLine = new List<Apttus_Proposal__Proposal_Line_Item__c> ();
	public SyncWithOpportunityExt(ApexPages.StandardController controller) {
		ProposalID = controller.getId();
		system.debug('--sync--proposalId--' + ProposalID);
		this.Prop = (Apttus_Proposal__Proposal__c) controller.getRecord();
		system.debug('---sync--Prop--' + this.Prop);
		Proposal = [SELECT Id, Software_Total_Disp__c, Service_Total_Disp__c, Maintenance_Total_Disp__C, Software_Net_Price__c, Service_Net_Price__c, Hardware_Discount_Disp__c,
		            Maintenance_Disc_Disp__c, Service_Discount2__c, Software_Disc_2dec__c, Hardware_Total_Disp__c, Apttus_Proposal__Primary__c, Hardware_Total__c, Maintenance_Total__c,
		            Service_Total__c, Software_Total__c, Discounted_Amount__c, Apttus_Proposal__Opportunity__c, Discounted_Price_Display__c
		            FROM Apttus_Proposal__Proposal__c
		            WHERE Id = :ProposalID];
		system.debug('---sync---proposal---' + Proposal);
		op = [SELECT Id, Price_List_Name__c, Pricebook2Id, CurrencyISOCode, Total_Hardware_Currency__c, Total_Maintenance_Currency__c,
		      Total_Service_Currency__c, Total_Software_Currency__c, Discount__c, Amount
		      FROM Opportunity
		      WHERE Id = :Proposal.Apttus_Proposal__Opportunity__c];
		system.debug('----sync--op--' + op);
		ProposalLine = [SELECT Id, Type__c, Service_Start_Date__c, Service_End_Date__c, Apttus_QPConfig__DerivedFromId__r.Staging__c, Apttus_QPConfig__DerivedFromId__r.Contract__c,
		                Apttus_QPConfig__DerivedFromId__r.Service_Line__c, Apttus_Proposal__Product__r.Oracle_Id__c, Discount_Amount__c, Apttus_QPConfig__NetAdjustmentPercent__c,
		                Apttus_QPConfig__ListPrice__c, Quantity_Disp__c, Apttus_Proposal__Product__c, Apttus_QPConfig__OptionId__c, Apttus_QPConfig__NetPrice__c, Apttus_QPConfig__DerivedFromId__r.Apttus_Config2__AssetId__c,
		                Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__r.Name, Apttus_QPConfig__DerivedFromId__r.Price_List_Division__c, Include_ARR_Calculation__c, Unit_Selling_Price__c
		                FROM Apttus_Proposal__Proposal_Line_Item__c
		                WHERE Apttus_Proposal__Proposal__c = :ProposalID AND((Apttus_QPConfig__OptionId__c != Null AND Apttus_QPConfig__ListPrice__c != Null) OR((Apttus_QPConfig__OptionId__c = Null AND Apttus_QPConfig__ListPrice__c != Null)))];
		system.debug('---sync---ProposalLine---' + ProposalLine);
	}

	public void UpdateOppty() {

		system.debug('-------------Proposal.Apttus_Proposal__Primary__c--------------' + Proposal.Apttus_Proposal__Primary__c);
		try {
			if (Proposal.Apttus_Proposal__Primary__c == True) {
				Map<Id, Id> prdPbeMap = new Map<Id, Id> ();
				Map<Id, Id> stdPrdPbeMap = new Map<Id, Id> ();
				Id stdPRiceBookId = [SELECT Id FROM PriceBook2 WHERE IsStandard = true].Id;
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
				for (PriceBookEntry pbe :[SELECT Id, isActive, Product2id, Pricebook2id, Pricebook2.IsStandard FROM PriceBookEntry WHERE Product2id in :prdPbeMap.keySet()
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
						pbe = new PriceBookEntry();
						pbe.Pricebook2Id = stdPRiceBookId;
						pbe.Product2Id = key;
						pbe.CurrencyIsoCode = op.CurrencyIsoCode;
						pbe.UnitPrice = 0;
						pbe.IsActive = true;
						pbeList.add(pbe);
					}
				}


				for (String key : prdPbeMap.keySet()) {
					if (prdPbeMap.get(key) == null) {
						pbe = new PriceBookEntry();
						pbe.Pricebook2Id = op.Pricebook2Id;
						pbe.Product2Id = key;
						pbe.CurrencyIsoCode = op.CurrencyIsoCode;
						pbe.UnitPrice = 0;
						pbe.IsActive = true;
						pbeList.add(pbe);
					}
				}
				if (pbeList.size() > 0) {
					insert pbeList;
				}
				for (PriceBookEntry pbe1 :[SELECT Id, Product2Id FROM PriceBookEntry WHERE Id IN :pbeList AND Pricebook2.IsStandard = false]) {
					prdPbeMap.put(pbe1.Product2id, pbe.Id);
				}

				List<OpportunityLineItem> OppLine = new List<OpportunityLineItem> ();
				OppLine = [SELECT Id, Product2id, UnitPrice, Staging__c, Contract__c, Service_Line__c FROM OpportunityLineItem WHERE Opportunityid = :op.Id];
				OpportunityHelper.deletedLineItemIds = new set<Id> ();
				for (OpportunityLineItem oppLiTm : OppLine) {
					OpportunityHelper.deletedLineItemIds.add(oppLiTm.Id);
				}

				for (Apttus_Proposal__Proposal_Line_Item__c PropLine : ProposalLine)
				{
					OpportunityLineItem oppLiTm = new OpportunityLineItem();
					oppLiTm.Staging__c = PropLine.Apttus_QPConfig__DerivedFromId__r.Staging__c;
					oppLiTm.Contract__c = PropLine.Apttus_QPConfig__DerivedFromId__r.Contract__c;
					oppLiTm.Service_Line__c = PropLine.Apttus_QPConfig__DerivedFromId__r.Service_Line__c;
					oppLiTm.Asset__c = PropLine.Apttus_QPConfig__DerivedFromId__r.Apttus_Config2__AssetId__c;
					oppLiTm.Opportunityid = op.id;
					oppLiTm.Service_Start_Date__c = propLine.Service_Start_Date__c;
					oppLiTm.Service_End_Date__c = propLine.Service_End_Date__c;
					oppLiTm.Type__c = propLine.Type__c;
					if (PropLine.Apttus_QPConfig__OptionId__c != Null)
					oppLiTm.PricebookEntryId = prdPbeMap.get(PropLine.Apttus_QPConfig__OptionId__c);
					else
					oppLiTm.PricebookEntryId = prdPbeMap.get(PropLine.Apttus_Proposal__Product__c);
					system.debug('--------------------------' + PropLine.Discount_Amount__c);
					system.debug('--------------------------' + PropLine.Apttus_QPConfig__NetAdjustmentPercent__c);
					if (PropLine.Discount_Amount__c > 0 || PropLine.Apttus_QPConfig__NetAdjustmentPercent__c > 0 || (propLine.Service_Start_Date__c != Null && propLine.Service_End_Date__c != Null && propLine.Service_Start_Date__c.daysbetween(propLine.Service_End_Date__c) > 366 && propLine.Apttus_QPConfig__DerivedFromId__r.Price_List_Division__c != Null && propLine.Apttus_QPConfig__DerivedFromId__r.Price_List_Division__c == 'MEP NA')) {

						oppLiTm.UnitPrice = PropLine.Apttus_QPConfig__NetPrice__c / PropLine.Quantity_Disp__c;
						oppLiTm.Quantity = PropLine.Quantity_Disp__c;
						oppLiTm.Quantity_Disp__c = PropLine.Quantity_Disp__c;
						oppLiTm.Discount = 0;
						//oppLiTm.UnitPrice = PropLine.Apttus_QPConfig__NetAdjustmentPercent__c>100 ? PropLine.Apttus_QPConfig__NetPrice__c : PropLine.Discount_Amount__c;
						if (propLine.Apttus_Proposal__Product__r.Oracle_Id__c != Null && propLine.Apttus_Proposal__Product__r.Oracle_Id__c == 'SFDC_ONLY' && propLine.Apttus_QPConfig__OptionId__c == Null) oppLiTm.UnitPrice = 0;
						else
						{
							oppLiTm.UnitPrice = PropLine.Apttus_QPConfig__NetPrice__c / PropLine.Quantity_Disp__c;
							oppLiTm.Quantity = PropLine.Quantity_Disp__c;
							oppLiTm.Quantity_Disp__c = PropLine.Quantity_Disp__c;
							//oppLiTm.Discount = math.abs(PropLine.Apttus_QPConfig__NetAdjustmentPercent__c);
							//oppLiTm.UnitPrice = (PropLine.Apttus_QPConfig__ListPrice__c== Null || PropLine.Quantity_Disp__c == null || PropLine.Quantity_Disp__c == 0) ? 0 : PropLine.Apttus_QPConfig__ListPrice__c;

						}
					}
					else
					{
						oppLiTm.Quantity = PropLine.Quantity_Disp__c;
						oppLiTm.Quantity_Disp__c = PropLine.Quantity_Disp__c;
						oppLiTm.Discount = math.abs(PropLine.Apttus_QPConfig__NetAdjustmentPercent__c);
						oppLiTm.UnitPrice = (PropLine.Unit_Selling_Price__c == Null || PropLine.Quantity_Disp__c == null || PropLine.Quantity_Disp__c == 0) ? 0 : PropLine.Unit_Selling_Price__c;
					}
					system.debug(oppLiTm.UnitPrice + '--------------oppLiTm.TotalPRice------------' + oppLiTm.TotalPRice);
					system.debug(oppLiTm.UnitPrice + '--------------oppLiTm.Quantity------------' + oppLiTm.Quantity);
					if (PropLine.Service_Start_Date__c != null && PropLine.Service_End_Date__c != null && PropLine.Include_ARR_Calculation__c) {
						oppLiTm.Include_ARR_Calculation__c = true;
					}
					InsertoppLine.add(oppLiTm);
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
				errorMsg = '';
				system.debug('>>>>>>>>' + op.Amount);
			}
		} catch(Exception ex) {
			errorMsg = ex.getMessage();
		}
	}
}