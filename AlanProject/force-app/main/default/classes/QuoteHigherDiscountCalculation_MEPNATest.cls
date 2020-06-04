/*
 * ****************************************************************************************
  Name    : QuoteHigherDiscountCalculation_MEPNATest 
  ---------------------------------------------------------------------------
  Developer              Date            Description
  ---------------------------------------------------------------------------
  Prince Leo          28/05/2019          Created
 *****************************************************************************************/
@isTest(seealldata = true)
private class QuoteHigherDiscountCalculation_MEPNATest {
	private static Apttus_Proposal__Proposal__c proposal;

	static testmethod void DisountTest1() {
		// Create Test Records
		CreateTestDataforthisClass();

		system.test.startTest();

		QuoteHigherDiscountCalculation_MEPNA.resetLaunchControl();
		update proposal;

		system.test.stopTest();
	}

	static void CreateTestDataforthisClass() {
		GenerateTestData.createAccount();
		GenerateTestData.createAddress();
		GenerateTestData.createPriceList();
		GenerateTestData.createOtherPriceList();
		GenerateTestData.createOpportunity();
		GenerateTestData.createProduct2();
		GenerateTestData.createPricebook2();
		GenerateTestData.createPriceBookEntry();

		List<Product2> lstProducts = new List<Product2> ();
		Product2 prd = new Product2(Name = 'test',
		                            isActive = true,
		                            Product_Category_Type__c = 'Subscription',
		                            Contract_Item_Type_Code__c = 'WARRANTY',
		                            Product_Line_Description__c = 'SAAShdskjhdsfkjtest',
		                            ProductCode = 'Test123',
		                            Family = 'Services');
		lstProducts.add(prd);

		Product2 prd1 = new Product2(Name = 'test',
		                             isActive = true,
		                             Product_Category_Type__c = 'Software',
		                             Contract_Item_Type_Code__c = 'WARRANTY',
		                             Product_Line_Description__c = 'SAAShdskjhdsfkjtest',
		                             ProductCode = 'Test123',
		                             Family = 'Services');
		lstProducts.add(prd1);

		Product2 prd2 = new Product2(Name = 'test',
		                             isActive = true,
		                             Product_Category_Type__c = 'Rental',
		                             Contract_Item_Type_Code__c = 'WARRANTY',
		                             Product_Line_Description__c = 'SAAShdskjhdsfkjtest',
		                             ProductCode = 'Test123',
		                             Family = 'Services');
		lstProducts.add(prd2);

		Product2 prd3 = new Product2(Name = 'test',
		                             isActive = true,
		                             Product_Category_Type__c = 'Software',
		                             Contract_Item_Type_Code__c = 'WARRANTY',
		                             Product_Line_Description__c = 'SAAShdskjhdsfkjtest',
		                             ProductCode = 'Test123',
		                             Family = 'Services');
		lstProducts.add(prd3);

		Product2 prd4 = new Product2(Name = 'test',
		                             isActive = true,
		                             Product_Category_Type__c = 'Others',
		                             Contract_Item_Type_Code__c = 'WARRANTY', ICC_Type__c = 'test',
		                             Product_Line_Description__c = 'SAAShdskjhdsfkjtest',
		                             ProductCode = 'Test123',
		                             Family = 'Services');
		lstProducts.add(prd4);

		Product2 prd5 = new Product2(Name = 'test',
		                             isActive = true,
		                             Product_Category_Type__c = 'Prof. Services',
		                             Contract_Item_Type_Code__c = 'WARRANTY',
		                             Product_Line_Description__c = 'SAAShdskjhdsfkjtest',
		                             ProductCode = 'Test123',
		                             Family = 'Services');
		lstProducts.add(prd5);

		Product2 prd6 = new Product2(Name = 'test',
		                             isActive = true,
		                             Product_Category_Type__c = 'SaaS',
		                             Contract_Item_Type_Code__c = 'WARRANTY',
		                             Product_Line_Description__c = 'SAAShdskjhdsfkjtest',
		                             ProductCode = 'Test123',
		                             Family = 'Services');
		lstProducts.add(prd6);

		Product2 prd7 = new Product2(Name = 'test',
		                             isActive = true,
		                             Product_Category_Type__c = 'Hardware',
		                             Contract_Item_Type_Code__c = 'WARRANTY',
		                             Product_Line_Description__c = 'SAAShdskjhdsfkjtest',
		                             ProductCode = 'Test123',
		                             Family = 'Services');
		lstProducts.add(prd7);
		insert lstProducts;

		Apttus_Config2__PriceList__c pricelist = new Apttus_Config2__PriceList__c();
		pricelist.Apttus_Config2__Active__c = true;
		pricelist.Name = 'MEP NA Standard Price List';
		pricelist.Legal_Entity__c = 'TIBV US BRANCH';
		insert pricelist;

		proposal = new Apttus_Proposal__Proposal__c();
		proposal.Apttus_Proposal__Proposal_Name__c = 'TestGenerateQuote'; //--added by Chandrakanth to overcome error of Null pointer exception related to Proposal Attachments
		proposal.Apttus_Proposal__Account__c = GenerateTestData.acct.Id;
		proposal.Apttus_QPConfig__BillToAccountId__c = GenerateTestData.acct.id;
		proposal.Apttus_Proposal__Opportunity__c = GenerateTestData.opp.Id;
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
		System.debug('+++++Selected Quote Pricelist :::::: ' + proposal.Pricelist_Name__c);
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
		                                                                                                         Apttus_QPConfig__ClassificationHierarchy__c = 'TIBV DE Test | Software | CAD Software',
		                                                                                                         Apttus_QPConfig__AdjustmentType__c = 'Price Override');

		Apttus_Proposal__Proposal_Line_Item__c proposalLine_SwHigh2 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_QPConfig__BasePrice__c = 140.48,
		                                                                                                         Apttus_Proposal__Proposal__c = proposal.Id,
		                                                                                                         CurrencyISOCode = 'USD',
		                                                                                                         Apttus_QPConfig__PriceListId__c = pricelist.Id,
		                                                                                                         Apttus_QPConfig__OptionId__c = prd1.Id,
		                                                                                                         Apttus_Proposal__Product__c = prd1.Id,
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
		                                                                                                         Apttus_QPConfig__ClassificationHierarchy__c = 'TIBV DE Test | Software | CAD Software',
		                                                                                                         Apttus_QPConfig__AdjustmentType__c = 'Price Override');
		Apttus_Proposal__Proposal_Line_Item__c proposalLine_SwHigh3 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_QPConfig__BasePrice__c = 140.48,
		                                                                                                         Apttus_Proposal__Proposal__c = proposal.Id,
		                                                                                                         CurrencyISOCode = 'USD',
		                                                                                                         Apttus_QPConfig__PriceListId__c = pricelist.Id,
		                                                                                                         Apttus_QPConfig__OptionId__c = prd2.Id,
		                                                                                                         Apttus_Proposal__Product__c = prd2.Id,
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
																												 Apttus_QPConfig__IsPrimaryLine__c = true,
		                                                                                                         Apttus_QPConfig__LineNumber__c = 67,
		                                                                                                         Apttus_QPConfig__NetAdjustmentPercent__c = 20,
		                                                                                                         Apttus_QPConfig__ExtendedPrice__c = 45,
		                                                                                                         Apttus_QPConfig__ClassificationHierarchy__c = '',
		                                                                                                         Apttus_QPConfig__AdjustmentType__c = 'Price Override',
																												 Service_Start_Date__c = System.today(),
																												 Service_End_Date__c = System.today().addYears(1));

		Apttus_Proposal__Proposal_Line_Item__c proposalLine_SwDisc1 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_QPConfig__BasePrice__c = 140.48,
		                                                                                                         Apttus_Proposal__Proposal__c = proposal.Id,
		                                                                                                         CurrencyISOCode = 'USD',
		                                                                                                         Apttus_QPConfig__PriceListId__c = pricelist.Id,
		                                                                                                         Apttus_QPConfig__OptionId__c = prd3.Id,
		                                                                                                         Apttus_Proposal__Product__c = prd3.Id,
		                                                                                                         Apttus_Proposal__Quantity__c = 92,
		                                                                                                         Apttus_QPConfig__Quantity2__c = 95,
		                                                                                                         Apttus_QPConfig__PriceUom__c = 'Each',
		                                                                                                         Apttus_QPConfig__ListPrice__c = 45,
		                                                                                                         Actual_List_Price__c = 45,
		                                                                                                         Apttus_QPConfig__NetPrice__c = 52,
		                                                                                                         Apttus_QPConfig__SellingTerm__c = 98,
		                                                                                                         Apttus_QPConfig__SellingFrequency__c = 'Work Unit',
		                                                                                                         Apttus_QPConfig__LineType__c = 'Product/Service',
		                                                                                                         Apttus_QPConfig__ChargeType__c = 'Standard Price',
		                                                                                                         Apttus_QPConfig__LineNumber__c = 67,
		                                                                                                         Apttus_QPConfig__NetAdjustmentPercent__c = - 20,
		                                                                                                         Apttus_QPConfig__ExtendedPrice__c = 45,
		                                                                                                         Apttus_QPConfig__ClassificationHierarchy__c = 'TIBV DE Test | Software | CAD Software',
		                                                                                                         Apttus_QPConfig__AdjustmentType__c = '% Discount');
		Apttus_Proposal__Proposal_Line_Item__c proposalLine_SwDisc2 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_QPConfig__BasePrice__c = 140.48,
		                                                                                                         Apttus_Proposal__Proposal__c = proposal.Id,
		                                                                                                         CurrencyISOCode = 'USD',
		                                                                                                         Apttus_QPConfig__PriceListId__c = pricelist.Id,
		                                                                                                         Apttus_QPConfig__OptionId__c = prd4.Id,
		                                                                                                         Apttus_Proposal__Product__c = prd4.Id,
		                                                                                                         Apttus_Proposal__Quantity__c = 92,
		                                                                                                         Apttus_QPConfig__Quantity2__c = 95,
		                                                                                                         Apttus_QPConfig__PriceUom__c = 'Each',
		                                                                                                         Apttus_QPConfig__ListPrice__c = 45,
		                                                                                                         Actual_List_Price__c = 35,
		                                                                                                         Apttus_QPConfig__NetPrice__c = 52,
		                                                                                                         Apttus_QPConfig__SellingTerm__c = 98,
		                                                                                                         Apttus_QPConfig__SellingFrequency__c = 'Work Unit',
		                                                                                                         Apttus_QPConfig__LineType__c = 'Product/Service',
		                                                                                                         Apttus_QPConfig__ChargeType__c = 'Standard Price',
		                                                                                                         Apttus_QPConfig__LineNumber__c = 67,
		                                                                                                         Apttus_QPConfig__NetAdjustmentPercent__c = - 20,
		                                                                                                         Apttus_QPConfig__ExtendedPrice__c = 45,
		                                                                                                         Apttus_QPConfig__ClassificationHierarchy__c = 'TIBV DE Test | Software | CAD Software',
		                                                                                                         Apttus_QPConfig__AdjustmentType__c = '% Discount');
		Apttus_Proposal__Proposal_Line_Item__c proposalLine_SwDisc3 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_QPConfig__BasePrice__c = 140.48,
		                                                                                                         Apttus_Proposal__Proposal__c = proposal.Id,
		                                                                                                         CurrencyISOCode = 'USD',
		                                                                                                         Apttus_QPConfig__PriceListId__c = pricelist.Id,
		                                                                                                         Apttus_QPConfig__OptionId__c = prd5.Id,
		                                                                                                         Apttus_Proposal__Product__c = prd5.Id,
		                                                                                                         Apttus_Proposal__Quantity__c = 92,
		                                                                                                         Apttus_QPConfig__Quantity2__c = 95,
		                                                                                                         Apttus_QPConfig__PriceUom__c = 'Each',
		                                                                                                         Apttus_QPConfig__ListPrice__c = 45,
		                                                                                                         Actual_List_Price__c = 45,
		                                                                                                         Apttus_QPConfig__NetPrice__c = 52,
		                                                                                                         Apttus_QPConfig__SellingTerm__c = 98,
		                                                                                                         Apttus_QPConfig__SellingFrequency__c = 'Work Unit',
		                                                                                                         Apttus_QPConfig__LineType__c = 'Product/Service',
		                                                                                                         Apttus_QPConfig__ChargeType__c = 'Standard Price',
		                                                                                                         Apttus_QPConfig__LineNumber__c = 67,
		                                                                                                         Apttus_QPConfig__NetAdjustmentPercent__c = - 20,
		                                                                                                         Apttus_QPConfig__ExtendedPrice__c = 45,
		                                                                                                         Apttus_QPConfig__ClassificationHierarchy__c = 'TIBV DE Test | Third Party Software | 3rd Party Software',
		                                                                                                         Apttus_QPConfig__AdjustmentType__c = '% Discount');
		Apttus_Proposal__Proposal_Line_Item__c proposalLine_SwDisc4 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_QPConfig__BasePrice__c = 140.48,
		                                                                                                         Apttus_Proposal__Proposal__c = proposal.Id,
		                                                                                                         CurrencyISOCode = 'USD',
		                                                                                                         Apttus_QPConfig__PriceListId__c = pricelist.Id,
		                                                                                                         Apttus_QPConfig__OptionId__c = prd6.Id,
		                                                                                                         Apttus_Proposal__Product__c = prd6.Id,
		                                                                                                         Apttus_Proposal__Quantity__c = 92,
		                                                                                                         Apttus_QPConfig__Quantity2__c = 95,
		                                                                                                         Apttus_QPConfig__PriceUom__c = 'Each',
		                                                                                                         Apttus_QPConfig__ListPrice__c = 45,
		                                                                                                         Actual_List_Price__c = 45,
		                                                                                                         Apttus_QPConfig__NetPrice__c = 52,
		                                                                                                         Apttus_QPConfig__SellingTerm__c = 98,
		                                                                                                         Apttus_QPConfig__SellingFrequency__c = 'Work Unit',
		                                                                                                         Apttus_QPConfig__LineType__c = 'Product/Service',
		                                                                                                         Apttus_QPConfig__ChargeType__c = 'Standard Price',
		                                                                                                         Apttus_QPConfig__LineNumber__c = 67,
		                                                                                                         Apttus_QPConfig__NetAdjustmentPercent__c = - 20,
		                                                                                                         Apttus_QPConfig__ExtendedPrice__c = 45,
		                                                                                                         Apttus_QPConfig__ClassificationHierarchy__c = 'TIBV DE Test | Services | Training',
		                                                                                                         Apttus_QPConfig__AdjustmentType__c = '% Discount');
		Apttus_Proposal__Proposal_Line_Item__c proposalLine_SwDisc5 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_QPConfig__BasePrice__c = 140.48,
		                                                                                                         Apttus_Proposal__Proposal__c = proposal.Id,
		                                                                                                         CurrencyISOCode = 'USD',
		                                                                                                         Apttus_QPConfig__PriceListId__c = pricelist.Id,
		                                                                                                         Apttus_QPConfig__OptionId__c = prd7.Id,
		                                                                                                         Apttus_Proposal__Product__c = prd7.Id,
		                                                                                                         Apttus_Proposal__Quantity__c = 92,
		                                                                                                         Apttus_QPConfig__Quantity2__c = 95,
		                                                                                                         Apttus_QPConfig__PriceUom__c = 'Each',
		                                                                                                         Apttus_QPConfig__ListPrice__c = 45,
		                                                                                                         Actual_List_Price__c = 45,
		                                                                                                         Apttus_QPConfig__NetPrice__c = 52,
		                                                                                                         Apttus_QPConfig__SellingTerm__c = 98,
		                                                                                                         Apttus_QPConfig__SellingFrequency__c = 'Work Unit',
		                                                                                                         Apttus_QPConfig__LineType__c = 'Product/Service',
		                                                                                                         Apttus_QPConfig__ChargeType__c = 'Standard Price',
		                                                                                                         Apttus_QPConfig__LineNumber__c = 67,
		                                                                                                         Apttus_QPConfig__NetAdjustmentPercent__c = - 20,
		                                                                                                         Apttus_QPConfig__ExtendedPrice__c = 45,
		                                                                                                         Apttus_QPConfig__ClassificationHierarchy__c = 'Services | Special Services',
		                                                                                                         Apttus_QPConfig__AdjustmentType__c = '% Discount');
		Apttus_Proposal__Proposal_Line_Item__c proposalLine_SwDisc6 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_QPConfig__BasePrice__c = 140.48,
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
		                                                                                                         Apttus_QPConfig__NetPrice__c = 52,
		                                                                                                         Apttus_QPConfig__SellingTerm__c = 98,
		                                                                                                         Apttus_QPConfig__SellingFrequency__c = 'Work Unit',
		                                                                                                         Apttus_QPConfig__LineType__c = 'Product/Service',
		                                                                                                         Apttus_QPConfig__ChargeType__c = 'Standard Price',
		                                                                                                         Apttus_QPConfig__LineNumber__c = 67,
		                                                                                                         Apttus_QPConfig__NetAdjustmentPercent__c = - 20,
		                                                                                                         Apttus_QPConfig__ExtendedPrice__c = 45,
		                                                                                                         Apttus_QPConfig__ClassificationHierarchy__c = 'Hardware | Workstation',
		                                                                                                         Apttus_QPConfig__AdjustmentType__c = '% Discount');
		Apttus_Proposal__Proposal_Line_Item__c proposalLine_SwDisc7 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_QPConfig__BasePrice__c = 140.48,
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
		                                                                                                         Apttus_QPConfig__NetPrice__c = 52,
		                                                                                                         Apttus_QPConfig__SellingTerm__c = 98,
		                                                                                                         Apttus_QPConfig__SellingFrequency__c = 'Work Unit',
		                                                                                                         Apttus_QPConfig__LineType__c = 'Product/Service',
		                                                                                                         Apttus_QPConfig__ChargeType__c = 'Standard Price',
		                                                                                                         Apttus_QPConfig__LineNumber__c = 67,
		                                                                                                         Apttus_QPConfig__NetAdjustmentPercent__c = - 20,
		                                                                                                         Apttus_QPConfig__ExtendedPrice__c = 45,
		                                                                                                         Apttus_QPConfig__ClassificationHierarchy__c = 'TIBV DE Test | Other | Fee',
		                                                                                                         Apttus_QPConfig__AdjustmentType__c = '% Discount');
		Apttus_Proposal__Proposal_Line_Item__c proposalLine_SwDisc8 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_QPConfig__BasePrice__c = 140.48,
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
		                                                                                                         Apttus_QPConfig__NetPrice__c = 52,
		                                                                                                         Apttus_QPConfig__SellingTerm__c = 98,
		                                                                                                         Apttus_QPConfig__SellingFrequency__c = 'Work Unit',
		                                                                                                         Apttus_QPConfig__LineType__c = 'Option',
		                                                                                                         Apttus_QPConfig__ChargeType__c = 'Maintenance Fee',
		                                                                                                         Apttus_QPConfig__LineNumber__c = 67,
		                                                                                                         Apttus_QPConfig__NetAdjustmentPercent__c = - 20,
		                                                                                                         Apttus_QPConfig__ExtendedPrice__c = 45,
		                                                                                                         Apttus_QPConfig__ClassificationHierarchy__c = '',
		                                                                                                         Apttus_QPConfig__AdjustmentType__c = '% Discount');
		lstpLineItems.add(proposalLine_SwHigh1);
		lstpLineItems.add(proposalLine_SwHigh2);
		lstpLineItems.add(proposalLine_SwHigh3);
		lstpLineItems.add(proposalLine_SwDisc1);
		lstpLineItems.add(proposalLine_SwDisc2);
		lstpLineItems.add(proposalLine_SwDisc3);
		lstpLineItems.add(proposalLine_SwDisc4);
		lstpLineItems.add(proposalLine_SwDisc5);
		lstpLineItems.add(proposalLine_SwDisc6);
		lstpLineItems.add(proposalLine_SwDisc7);
		lstpLineItems.add(proposalLine_SwDisc8);
		insert lstpLineItems;

		Apttus__APTS_Agreement__c apg = new Apttus__APTS_Agreement__c(Apttus__Contract_Start_Date__c = date.today(),
		                                                              Apttus__Contract_End_Date__c = date.today() + 5,
		                                                              ProServ_Type__c = 'Fixed Fee',
		                                                              Credit_Status__c = 'test',
		                                                              Credit_Approved__c = 'test Credit_Approved__c',
		                                                              CREDIT_LIMIT_AVAILABLE__C = 10,
		                                                              CREDIT_EXISTING_EXPOSURE__C = 10,
		                                                              CREDIT_CALCULATED_EXPOSURE__c = 10,
		                                                              CREDIT_TOTAL_EXPOSURE__c = 10,
		                                                              Fusion_Project_Number__c = 'test Fusion_Project_Number__c',
		                                                              Apttus_QPComply__RelatedProposalId__c = proposal.Id,
		                                                              Apttus__Status_Category__c = 'In Effect : Submitted',
		                                                              Apttus__Status__c = 'Activated',
		                                                              Apttus_CMConfig__PriceListId__c = pricelist.Id);
		insert apg;

	}

}