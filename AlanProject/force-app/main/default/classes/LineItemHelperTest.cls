/*
 ****************************************************************************************
  Name Controller        : LineItemHelperTest 
  ---------------------------------------------------------------------------
  Developer              Date            Description
  ---------------------------------------------------------------------------
  Suresh Babu           27/11/2017		Created
 *****************************************************************************************
*/

@isTest(seealldata = true)
private class LineItemHelperTest {

	@isTest static void test_method_one() {
		// Implement test code
		GenerateTestData.createAccount();
		GenerateTestData.createPriceList();
		GenerateTestData.createOpportunity();
		GenerateTestData.createAddress();
		GenerateTestData.createProposal();
		GenerateTestData.createProduct2();
		GenerateTestData.createAsset();
		Apttus_Config2__ProductConfiguration__c acpcfg = new Apttus_Config2__ProductConfiguration__c();
		acpcfg.Name = 'test acpcfg';
		acpcfg.Apttus_QPConfig__Proposald__c = GenerateTestData.proposal.Id;
		acpcfg.Apttus_Config2__PriceListId__c = GenerateTestData.pricelist.Id;
		insert acpcfg;

		test.startTest();

		Apttus_Config2__LineItem__c standardliTm = new Apttus_Config2__LineItem__c();
		standardliTm.Apttus_Config2__LineNumber__c = 1;
		standardliTm.Apttus_Config2__LineSequence__c = 1;
		standardliTm.Apttus_Config2__ItemSequence__c = 2;
		standardliTm.Apttus_Config2__ConfigurationId__c = acpcfg.Id;
		standardliTm.Apttus_Config2__Quantity__c = 1;
		standardliTm.Apttus_Config2__ProductId__c = GenerateTestData.prd.Id;
		standardliTm.Apttus_Config2__PrimaryLineNumber__c = 1;
		standardliTm.Parent_Line_Number__c = null;
		standardliTm.Apttus_Config2__IsPrimaryLine__c = true;
		standardliTm.Duration__c = 2;
		standardliTm.Apttus_Config2__OptionId__c = GenerateTestData.prd.Id;
		standardliTm.Duration_UOM__c = 'Year';
		standardliTm.Asset_Oracle_ID__c = '391G';
		standardliTm.Service_Start_Date__c = system.today();
		standardliTm.Service_End_Date__c = system.today() + 50;
		standardliTm.Apttus_Config2__ChargeType__c = 'Maintenance Fee';
		standardliTm.Apttus_Config2__LineType__c = 'Option';
		standardliTm.Apttus_Config2__ListPrice__c = 30.00;
		standardliTm.Actual_List_Price__c = 30.00;
		standardliTm.EBS_Discount_Percentage__c = 5;
		standardliTm.Apttus_Config2__IsOptionRollupLine__c = false;
		standardliTm.Parent_Line_Number__c = null;
		standardliTm.Apttus_Config2__AdjustmentAmount__c = 100;
		standardliTm.Apttus_Config2__AdjustmentType__c = '% Discount';
		standardliTm.Apttus_Config2__PriceListId__c = GenerateTestData.pricelist1.id;
		insert standardliTm;
		system.debug('--------standardliTm-------' + standardliTm);

		LineItemHelper.resetLaunchControl();
		RecursiveTriggerUtility.recursiveCallLineItemTrigger = false;

		standardliTm.Service_Start_Date__c = system.today() + 1;
		standardliTm.Apttus_Config2__Quantity__c = 2;
		standardliTm.Apttus_Config2__LineSequence__c = 2;
		standardliTm.Apttus_Config2__IsCustomPricing__c = true;
		update standardliTm;

		LineItemHelper.resetLaunchControl();
		RecursiveTriggerUtility.recursiveCallLineItemTrigger = false;
		delete standardliTm;

		test.stopTest();
	}

	@isTest static void test_method_two() {
		// Implement test code
		GenerateTestData.createAccount();
		GenerateTestData.createPriceList();
		GenerateTestData.createAddress();
		RecursiveTriggerUtility.isSetPriceBookDefaultTriggerRecursive = true;
		Opportunity opp = new Opportunity();
		opp.AccountId = GenerateTestData.acct.Id;
		opp.StageName = 'Inquery';
		opp.Closedate = date.today() + 7;
		opp.Name = 'Opp1';
		opp.CurrencyISOCode = 'USD';
		opp.Price_List__c = GenerateTestData.pricelist.Id;
		opp.Selling_Division__c = 'MEP NA';
		opp.Ship_To_Account__c = GenerateTestData.acct.ID;
		opp.Payment_Term__c = 'CASH IN ADVANCE';
		opp.Type = 'New Business';
		opp.Account_Sub_Type__c = 'Additional Licenses';
		opp.OwnerId = UserInfo.getUserId();
		opp.Pricebook2Id = Test.getStandardPricebookId();
		insert opp;
		
		Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c();
        proposal.Apttus_Proposal__Proposal_Name__c='TestGenerateQuote';//--added by Chandrakanth to overcome error of Null pointer exception related to Proposal Attachments
        proposal.Apttus_Proposal__Account__c = GenerateTestData.acct.Id;
        proposal.Apttus_QPConfig__BillToAccountId__c = GenerateTestData.acct.id;
        proposal.Apttus_Proposal__Opportunity__c = opp.Id;
        proposal.Apttus_QPConfig__PriceListId__c = GenerateTestData.pricelist.Id;
        proposal.Ship_To_Account__c = GenerateTestData.acct.Id;
        proposal.Bill_to_Address__c  = GenerateTestData.adrs.Id;
        proposal.OwnerId = UserInfo.getUserId();
        proposal.Apttus_Proposal__Primary__c = true;
        proposal.Industry__c ='Electrical';
        proposal.Freight_Method__c ='N/A';
        proposal.Freight_Terms__c ='N/A';
        proposal.Payment_Method__c ='INVOICE';
        proposal.Clone_ID__c='Q-00012683';
        insert proposal;

		GenerateTestData.createProduct2();
		GenerateTestData.createAsset();
		PriceBookEntry pbe = new PriceBookEntry();
		pbe.CurrencyISOCode = 'USD';
		pbe.PriceBook2ID = Test.getStandardPricebookId();
		pbe.Product2Id = GenerateTestData.prd.Id;
		pbe.IsActive = true;
		pbe.UnitPrice = 1;
		pbe.UseStandardPrice = false;
		insert pbe;

		OpportunityLineItem oli = new OpportunityLineItem();
		oli.OpportunityId = opp.Id;
		oli.Quantity = 45;
		oli.UnitPrice = 456;
		oli.PricebookEntryId = pbe.Id;
		oli.Product2Id = GenerateTestData.prd.Id;
		insert oli;

		LineItemHelper.LineItemList = new List<OpportunityLineItem> ();
		LineItemHelper.LineItemList.add(oli);

		Apttus_Config2__ProductConfiguration__c acpcfg = new Apttus_Config2__ProductConfiguration__c();
		acpcfg.Name = 'test acpcfg';
		acpcfg.Apttus_QPConfig__Proposald__c = proposal.Id;
		acpcfg.Apttus_Config2__PriceListId__c = GenerateTestData.pricelist.Id;
		insert acpcfg;

		Test.startTest();

		Apttus_Config2__LineItem__c standardliTm = new Apttus_Config2__LineItem__c();
		standardliTm.Apttus_Config2__LineNumber__c = 1;
		standardliTm.Apttus_Config2__LineSequence__c = 1;
		standardliTm.Apttus_Config2__ItemSequence__c = 2;
		standardliTm.Apttus_Config2__ConfigurationId__c = acpcfg.Id;
		standardliTm.Apttus_Config2__Quantity__c = 1;
		standardliTm.Apttus_Config2__ProductId__c = GenerateTestData.prd.Id;
		standardliTm.Apttus_Config2__PrimaryLineNumber__c = 1;
		standardliTm.Parent_Line_Number__c = null;
		standardliTm.Apttus_Config2__IsPrimaryLine__c = true;
		standardliTm.Duration__c = 2;
		standardliTm.Apttus_Config2__OptionId__c = GenerateTestData.prd.Id;
		standardliTm.Duration_UOM__c = 'Year';
		standardliTm.Asset_Oracle_ID__c = '391G';
		standardliTm.Service_Start_Date__c = system.today();
		standardliTm.Service_End_Date__c = system.today() + 50;
		standardliTm.Apttus_Config2__ChargeType__c = 'Maintenance Fee';
		standardliTm.Apttus_Config2__LineType__c = 'Option';
		standardliTm.Apttus_Config2__ListPrice__c = 30.00;
		standardliTm.Actual_List_Price__c = 30.00;
		standardliTm.EBS_Discount_Percentage__c = 5;
		standardliTm.Apttus_Config2__IsOptionRollupLine__c = false;
		standardliTm.Parent_Line_Number__c = null;
		standardliTm.Apttus_Config2__AdjustmentAmount__c = 100;
		standardliTm.Apttus_Config2__AdjustmentType__c = '% Discount';
		standardliTm.Apttus_Config2__PriceListId__c = GenerateTestData.pricelist1.id;
		insert standardliTm;
		system.debug('--------standardliTm-------' + standardliTm);

		LineItemHelper.resetLaunchControl();
		RecursiveTriggerUtility.recursiveCallLineItemTrigger = false;
		standardliTm.Schedule_Ship_Date__c = System.now();
		Decimal tstDec = 1.23;
		LineItemHelper.setFieldValue('DECIMAL', tstDec, 'Actual_List_Price__c', standardliTm);
		LineItemHelper.setFieldValue('REFERENCE', standardliTm.Apttus_Config2__OptionId__c, 'Parent_Line_Number__c', standardliTm);
		LineItemHelper.setFieldValue('DATETIME', standardliTm.Schedule_Ship_Date__c, 'Schedule_Ship_Date__c', standardliTm);
		LineItemHelper.setFieldValue('DATE', standardliTm.Service_Start_Date__c, 'Service_Start_Date__c', standardliTm);
		LineItemHelper.setFieldValue('BOOLEAN', 'TRUE', 'Defer_Billing__c', standardliTm);
		Test.stopTest();
	}
}