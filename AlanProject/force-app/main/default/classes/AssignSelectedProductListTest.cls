/*
 * ****************************************************************************************
  Name		:	AssignSelectedProductListTest
  Desc		:	Test class for AssignSelectedProductList Trigger
  ---------------------------------------------------------------------------
  Developer              Date            Description
  ---------------------------------------------------------------------------
  Suresh Babu Murugan    13/APR/2020		Created
 *****************************************************************************************/
@isTest(seealldata = true)
private class AssignSelectedProductListTest {
	public static Apttus_Config2__PriceList__c pricelist;
	public static Opportunity opp;
	public static Apttus_Proposal__Proposal__c proposal;
	public static Product2 prd;
	public static PriceBookEntry pbe;

	static testmethod void AssignSelectedProductListTest_01() {
		// Create Test Records
		CreateTestDataforthisClass();

		system.test.startTest();

		RecursiveTriggerUtility.isBeforeAssignSelectedProductList = false;
		update proposal;

		system.test.stopTest();
	}

	static void CreateTestDataforthisClass() {
		GenerateTestData.createAccount();
		GenerateTestData.createAddress();

		pricelist = new Apttus_Config2__PriceList__c();
		pricelist.Apttus_Config2__Active__c = true;
		pricelist.Name = 'TIBV DE FTG Price List';
		pricelist.Legal_Entity__c = 'TIBV SWISS BRANCH';
		pricelist.Business_Area__c = 'PLANCAL';
		pricelist.Division__c = 'Plancal';
		insert pricelist;

		opp = new Opportunity();
		opp.AccountId = GenerateTestData.acct.Id;
		opp.StageName = 'Inquery';
		opp.Closedate = date.today() + 7;
		opp.Name = 'Opp1';
		opp.CurrencyISOCode = 'USD';
		opp.Price_List__c = pricelist.Id;
		opp.Selling_Division__c = 'MEP NA';
		opp.Ship_To_Account__c = GenerateTestData.acct.ID;
		opp.Payment_Term__c = 'CASH IN ADVANCE';
		opp.Type = 'New Business';
		opp.Account_Sub_Type__c = 'Additional Licenses';
		opp.OwnerId = UserInfo.getUserId();
		insert opp;

		prd = new Product2();
		prd.Name = 'test';
		prd.isActive = true;
		prd.Product_Category_Type__c = 'Subscription';
		prd.Contract_Item_Type_Code__c = 'WARRANTY';
		prd.Product_Line_Description__c = 'SAAShdskjhdsfkjtest  ';
		prd.ProductCode = 'Test123';
		prd.Business_Area__c = 'MANHATTAN SOFTWARE';
		prd.Family = 'Services';
		prd.ICC_Type__c = 'Hardware and Accessories';
		insert prd;


		// Create Catagory
		Apttus_Config2__ClassificationName__c catG = new Apttus_Config2__ClassificationName__c(
		                                                                                       Name = 'TIBV DE Test',
		                                                                                       Apttus_Config2__Active__c = true,
		                                                                                       Apttus_Config2__HierarchyLabel__c = 'TIBV DE Test',
		                                                                                       Apttus_Config2__Type__c = 'Offering'
		);
		Database.insert(catG);

		// Create CatehoeryHierarchy
		List<Apttus_Config2__ClassificationHierarchy__c> lstInsertCatH = new List<Apttus_Config2__ClassificationHierarchy__c> ();
		Apttus_Config2__ClassificationHierarchy__c catH1 = new Apttus_Config2__ClassificationHierarchy__c(
		                                                                                                  Name = 'TIBV DE Test',
		                                                                                                  Apttus_Config2__Label__c = 'TIBV DE Test',
		                                                                                                  Apttus_Config2__Left__c = 1,
		                                                                                                  Apttus_Config2__Right__c = 10,
		                                                                                                  Apttus_Config2__Level__c = 0,
		                                                                                                  Apttus_Config2__HierarchyId__c = catG.Id
		);
		Database.insert(catH1);

		Apttus_Config2__ClassificationHierarchy__c catH2 = new Apttus_Config2__ClassificationHierarchy__c(
		                                                                                                  Name = 'Software',
		                                                                                                  Apttus_Config2__Label__c = 'Software',
		                                                                                                  Apttus_Config2__Left__c = 2,
		                                                                                                  Apttus_Config2__Right__c = 5,
		                                                                                                  Apttus_Config2__Level__c = 1,
		                                                                                                  Apttus_Config2__HierarchyId__c = catG.Id,
		                                                                                                  Apttus_Config2__PrimordialId__c = catH1.Id,
		                                                                                                  Apttus_Config2__AncestorId__c = catH1.Id
		);
		lstInsertCatH.add(catH2);
		Apttus_Config2__ClassificationHierarchy__c catH3 = new Apttus_Config2__ClassificationHierarchy__c(
		                                                                                                  Name = 'Third Party Software',
		                                                                                                  Apttus_Config2__Label__c = 'Third Party Software',
		                                                                                                  Apttus_Config2__Left__c = 6,
		                                                                                                  Apttus_Config2__Right__c = 12,
		                                                                                                  Apttus_Config2__Level__c = 1,
		                                                                                                  Apttus_Config2__HierarchyId__c = catG.Id,
		                                                                                                  Apttus_Config2__PrimordialId__c = catH1.Id,
		                                                                                                  Apttus_Config2__AncestorId__c = catH1.Id
		);
		lstInsertCatH.add(catH3);
		Apttus_Config2__ClassificationHierarchy__c catH4 = new Apttus_Config2__ClassificationHierarchy__c(
		                                                                                                  Name = 'Services',
		                                                                                                  Apttus_Config2__Label__c = 'Services',
		                                                                                                  Apttus_Config2__Left__c = 13,
		                                                                                                  Apttus_Config2__Right__c = 18,
		                                                                                                  Apttus_Config2__Level__c = 1,
		                                                                                                  Apttus_Config2__HierarchyId__c = catG.Id,
		                                                                                                  Apttus_Config2__PrimordialId__c = catH1.Id,
		                                                                                                  Apttus_Config2__AncestorId__c = catH1.Id
		);
		lstInsertCatH.add(catH4);
		Apttus_Config2__ClassificationHierarchy__c catH5 = new Apttus_Config2__ClassificationHierarchy__c(
		                                                                                                  Name = 'Hardware',
		                                                                                                  Apttus_Config2__Label__c = 'Hardware',
		                                                                                                  Apttus_Config2__Left__c = 19,
		                                                                                                  Apttus_Config2__Right__c = 24,
		                                                                                                  Apttus_Config2__Level__c = 1,
		                                                                                                  Apttus_Config2__HierarchyId__c = catG.Id,
		                                                                                                  Apttus_Config2__PrimordialId__c = catH1.Id,
		                                                                                                  Apttus_Config2__AncestorId__c = catH1.Id
		);
		lstInsertCatH.add(catH5);
		Apttus_Config2__ClassificationHierarchy__c catH6 = new Apttus_Config2__ClassificationHierarchy__c(
		                                                                                                  Name = 'Other',
		                                                                                                  Apttus_Config2__Label__c = 'Other',
		                                                                                                  Apttus_Config2__Left__c = 25,
		                                                                                                  Apttus_Config2__Right__c = 30,
		                                                                                                  Apttus_Config2__Level__c = 1,
		                                                                                                  Apttus_Config2__HierarchyId__c = catG.Id,
		                                                                                                  Apttus_Config2__PrimordialId__c = catH1.Id,
		                                                                                                  Apttus_Config2__AncestorId__c = catH1.Id
		);
		lstInsertCatH.add(catH6);
		Database.insert(lstInsertCatH);

		GenerateTestData.createPricebook2();

		pbe = new PriceBookEntry();
		pbe.CurrencyISOCode = 'USD';
		pbe.PriceBook2ID = test.getStandardPricebookId();
		pbe.Product2Id = prd.Id;
		pbe.IsActive = true;
		pbe.UnitPrice = 1;
		pbe.UseStandardPrice = false;
		insert pbe;

		proposal = new Apttus_Proposal__Proposal__c();
		proposal.Apttus_Proposal__Proposal_Name__c = 'TestGenerateQuote'; //--added by Chandrakanth to overcome error of Null pointer exception related to Proposal Attachments
		proposal.Apttus_Proposal__Account__c = GenerateTestData.acct.Id;
		proposal.Apttus_QPConfig__BillToAccountId__c = GenerateTestData.acct.id;
		proposal.Apttus_Proposal__Opportunity__c = opp.Id;
		proposal.Apttus_QPConfig__PriceListId__c = pricelist.Id;
		proposal.Ship_To_Account__c = GenerateTestData.acct.Id;
		proposal.Bill_to_Address__c = GenerateTestData.adrs.Id;
		proposal.OwnerId = UserInfo.getUserId();
		proposal.Apttus_Proposal__Primary__c = true;
		proposal.Industry__c = 'Electrical';
		proposal.Freight_Method__c = 'N/A';
		proposal.Freight_Terms__c = 'N/A';
		proposal.Payment_Method__c = 'INVOICE';
		proposal.Clone_ID__c = 'Q-00012683';
		insert proposal;
		system.debug('proposal ID ++++++++++++++++++' + proposal.Id);

		List<Apttus_Proposal__Proposal_Line_Item__c> lstpLineItems = new List<Apttus_Proposal__Proposal_Line_Item__c> ();
		Apttus_Proposal__Proposal_Line_Item__c proposalLine_SwHigh1 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_QPConfig__BasePrice__c = 140.48,
		                                                                                                         Apttus_Proposal__Proposal__c = proposal.Id,
		                                                                                                         CurrencyISOCode = 'USD',
		                                                                                                         Apttus_QPConfig__PriceListId__c = pricelist.Id,
		                                                                                                         Apttus_QPConfig__OptionId__c = prd.Id,
		                                                                                                         Apttus_Proposal__Product__c = prd.Id,
		                                                                                                         Apttus_Proposal__Quantity__c = 92,
		                                                                                                         Apttus_QPConfig__Quantity2__c = 95,
		                                                                                                         Apttus_QPConfig__PriceUom__c = 'Each',
		                                                                                                         Apttus_QPConfig__ListPrice__c = 45,
		                                                                                                         Actual_List_Price__c = 45,
		                                                                                                         Apttus_QPConfig__NetPrice__c = 545,
		                                                                                                         Apttus_QPConfig__SellingTerm__c = 98,
		                                                                                                         Apttus_QPConfig__SellingFrequency__c = 'Work Unit',
		                                                                                                         Apttus_QPConfig__LineType__c = 'Product/Service',
		                                                                                                         Apttus_QPConfig__ChargeType__c = 'Standard Price',
		                                                                                                         Apttus_QPConfig__LineNumber__c = 67,
		                                                                                                         Apttus_QPConfig__NetAdjustmentPercent__c = 20,
		                                                                                                         Apttus_QPConfig__ExtendedPrice__c = 45,
		                                                                                                         Apttus_QPConfig__ClassificationHierarchy__c = 'TIBV DE FTG Price List | Software | CAD Software',
		                                                                                                         Apttus_QPConfig__AdjustmentType__c = 'Price Override',
		                                                                                                         Apttus_QPConfig__ClassificationId__c = catH5.Id);

		Apttus_Proposal__Proposal_Line_Item__c proposalLine_SwHigh2 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_QPConfig__BasePrice__c = 140.48,
		                                                                                                         Apttus_Proposal__Proposal__c = proposal.Id,
		                                                                                                         CurrencyISOCode = 'USD',
		                                                                                                         Apttus_QPConfig__PriceListId__c = pricelist.Id,
		                                                                                                         Apttus_QPConfig__OptionId__c = prd.Id,
		                                                                                                         Apttus_Proposal__Product__c = prd.Id,
		                                                                                                         Apttus_Proposal__Quantity__c = 92,
		                                                                                                         Apttus_QPConfig__Quantity2__c = 95,
		                                                                                                         Apttus_QPConfig__PriceUom__c = 'Each',
		                                                                                                         Apttus_QPConfig__ListPrice__c = 45,
		                                                                                                         Actual_List_Price__c = 35,
		                                                                                                         Apttus_QPConfig__NetPrice__c = 545,
		                                                                                                         Apttus_QPConfig__SellingTerm__c = 98,
		                                                                                                         Apttus_QPConfig__SellingFrequency__c = 'Work Unit',
		                                                                                                         Apttus_QPConfig__LineType__c = 'Product/Service',
		                                                                                                         Apttus_QPConfig__ChargeType__c = 'Standard Price',
		                                                                                                         Apttus_QPConfig__LineNumber__c = 67,
		                                                                                                         Apttus_QPConfig__NetAdjustmentPercent__c = 20,
		                                                                                                         Apttus_QPConfig__ExtendedPrice__c = 45,
		                                                                                                         Apttus_QPConfig__ClassificationHierarchy__c = 'TIBV DE FTG Price List | Software | CAD Software',
		                                                                                                         Apttus_QPConfig__AdjustmentType__c = 'Price Override',
		                                                                                                         Apttus_QPConfig__ClassificationId__c = catH1.Id);
		Apttus_Proposal__Proposal_Line_Item__c proposalLine_SwHigh3 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_QPConfig__BasePrice__c = 140.48,
		                                                                                                         Apttus_Proposal__Proposal__c = proposal.Id,
		                                                                                                         CurrencyISOCode = 'USD',
		                                                                                                         Apttus_QPConfig__PriceListId__c = pricelist.Id,
		                                                                                                         Apttus_QPConfig__OptionId__c = prd.Id,
		                                                                                                         Apttus_Proposal__Product__c = prd.Id,
		                                                                                                         Apttus_Proposal__Quantity__c = 92,
		                                                                                                         Apttus_QPConfig__Quantity2__c = 95,
		                                                                                                         Apttus_QPConfig__PriceUom__c = 'Each',
		                                                                                                         Apttus_QPConfig__ListPrice__c = 45,
		                                                                                                         Actual_List_Price__c = 35,
		                                                                                                         Apttus_QPConfig__NetPrice__c = 545,
		                                                                                                         Apttus_QPConfig__SellingTerm__c = 98,
		                                                                                                         Apttus_QPConfig__SellingFrequency__c = 'Work Unit',
		                                                                                                         Apttus_QPConfig__LineType__c = 'Option',
		                                                                                                         Apttus_QPConfig__ChargeType__c = 'Maintenance Fee',
		                                                                                                         Apttus_QPConfig__LineNumber__c = 67,
		                                                                                                         Apttus_QPConfig__NetAdjustmentPercent__c = 20,
		                                                                                                         Apttus_QPConfig__ExtendedPrice__c = 45,
		                                                                                                         Apttus_QPConfig__ClassificationHierarchy__c = '',
		                                                                                                         Apttus_QPConfig__AdjustmentType__c = 'Price Override');
		lstpLineItems.add(proposalLine_SwHigh1);
		lstpLineItems.add(proposalLine_SwHigh2);
		lstpLineItems.add(proposalLine_SwHigh3);
		insert lstpLineItems;
	}
}