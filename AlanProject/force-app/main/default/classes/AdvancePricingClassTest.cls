/*
 ****************************************************************************************
  Name Controller        : AdvancePricingClassTest 
  ---------------------------------------------------------------------------
  Developer              Date            Description
  ---------------------------------------------------------------------------
  P M Mamata           19/08/2015          Created
 *****************************************************************************************
*/

@isTest(seealldata = true)
public class AdvancePricingClassTest {
	static testmethod void advancePricingTest1() {

		Test.setCurrentPageReference(new PageReference('Page.AdvancePricingPage'));
		GenerateTestData.createAccount();
		GenerateTestData.createPriceList();
		GenerateTestData.createOpportunity();
		GenerateTestData.createAddress();
		GenerateTestData.createProposal();
		GenerateTestData.createProduct2();
		Apttus_Config2__ProductConfiguration__c acpcfg = new Apttus_Config2__ProductConfiguration__c();
		acpcfg.Name = 'test acpcfg';
		acpcfg.Apttus_QPConfig__Proposald__c = GenerateTestData.proposal.Id;
		acpcfg.Apttus_Config2__PriceListId__c = GenerateTestData.pricelist.Id;
		insert acpcfg;


		Apttus_Config2__LineItem__c standardliTm = new Apttus_Config2__LineItem__c();
		//standardliTm.Apttus_Config2__ChargeType__c = 'Standard Price';
		//standardliTm.Apttus_Config2__IsPrimaryLine__c = true;
		standardliTm.Apttus_Config2__ItemSequence__c = 1;
		standardliTm.Apttus_Config2__LineNumber__c = 1;
		standardliTm.Apttus_Config2__ConfigurationId__c = acpcfg.Id;
		standardliTm.Apttus_Config2__Quantity__c = 2;
		standardliTm.Apttus_Config2__ProductId__c = GenerateTestData.prd.Id;
		standardliTm.Apttus_Config2__PrimaryLineNumber__c = 1;
		standardliTm.Apttus_Config2__IsOptionRollupLine__c = true;
		standardliTm.Duration__c = 1;
		standardliTm.service_Start_Date__c = date.newinstance(2016, 04, 01);
		standardliTm.service_End_date__c = system.today() + 50;
		standardliTm.Duration_UOM__c = 'Year';
		standardliTm.Apttus_Config2__ChargeType__c = 'Maintenance Fee';
		standardliTm.Apttus_Config2__IsOptionRollupLine__c = False;
		standardliTm.Apttus_Config2__AdjustmentAmount__c = 100;
		standardliTm.Apttus_Config2__AdjustmentType__c = '% Discount';
		standardliTm.Apttus_Config2__PriceListId__c = GenerateTestData.pricelist1.id;
		//standardliTm.Asset_Oracle_ID__c = 'test';
		insert standardliTm;
		system.debug('--------standardliTm-------' + standardliTm);
		system.debug('--------standardliTm-------' + standardliTm);

		String litmName = [select Name from Apttus_Config2__LineItem__c where Id = :standardliTm.Id limit 1].Name;

		xmlnsOracleComAppsOntSoaproviderPl_v10.OutputParameters_element o = new xmlnsOracleComAppsOntSoaproviderPl_v10.OutputParameters_element();
		o.X_SFDC_LINEOUT_TBL = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINEOUT_TBL_TYPE();
		xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINEOUT_TBL_TYPE o1 = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINEOUT_TBL_TYPE();
		o1.X_SFDC_LINEOUT_TBL_ITEM = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINEOUT_REC_TYPE[] { };
		xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINEOUT_REC_TYPE testxml = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINEOUT_REC_TYPE();
		testxml.PROPOSAL_ID = GenerateTestData.proposal.Id;
		testxml.PROPOSAL_LINE_ID = litmName;
		testxml.PROPOSAL_SERV_REF_LINE = 'test serv';
		testxml.SERV_START_DATE = System.now();
		testxml.SERV_END_DATE = System.now() + 50;
		testxml.DISCOUNT_EBS_CALCULATED = '18';
		testxml.SELLING_PRICE_EBS_CALCULATED = '20';
		o1.X_SFDC_LINEOUT_TBL_ITEM.add(testxml);
		o.X_SFDC_LINEOUT_TBL = o1;
		system.debug('--------testxml.PROPOSAL_LINE_ID-------' + testxml.PROPOSAL_LINE_ID);

		System.currentPageReference().getParameters().put('id', acpcfg.Id);
		test.startTest();
		AdvancePricingclass apc = new AdvancePricingclass();
		o.X_STATUS = 'SUCCESS';
		o.X_TAX_AMOUNT = 10;
		apc.o = o;
		apc.Temp();

		test.stopTest();
	}
	static testmethod void advancePricingTest2() {

		Test.setCurrentPageReference(new PageReference('Page.AdvancePricingPage'));
		GenerateTestData.createAccount();
		GenerateTestData.createPriceList();
		GenerateTestData.createOpportunity();
		GenerateTestData.createAddress();
		GenerateTestData.createProposal();
		GenerateTestData.createProduct2();
		Apttus_Config2__ProductConfiguration__c acpcfg = new Apttus_Config2__ProductConfiguration__c();
		acpcfg.Name = 'test acpcfg';
		acpcfg.Apttus_QPConfig__Proposald__c = GenerateTestData.proposal.Id;
		acpcfg.Apttus_Config2__PriceListId__c = GenerateTestData.pricelist.Id;
		insert acpcfg;


		Apttus_Config2__LineItem__c standardliTm = new Apttus_Config2__LineItem__c();
		standardliTm.Apttus_Config2__ItemSequence__c = 1;
		standardliTm.Apttus_Config2__LineNumber__c = 1;
		standardliTm.Apttus_Config2__ConfigurationId__c = acpcfg.Id;
		standardliTm.Apttus_Config2__Quantity__c = 2;
		standardliTm.Apttus_Config2__ProductId__c = GenerateTestData.prd.Id;
		standardliTm.Apttus_Config2__PrimaryLineNumber__c = 1;
		standardliTm.Apttus_Config2__IsOptionRollupLine__c = true;
		standardliTm.Duration__c = 1;
		standardliTm.Duration_UOM__c = 'Year';
		standardliTm.service_Start_Date__c = system.today();
		standardliTm.service_End_date__c = system.today() + 50;
		standardliTm.Apttus_Config2__ChargeType__c = 'Maintenance Fee';
		standardliTm.Apttus_Config2__IsOptionRollupLine__c = False;
		standardliTm.Apttus_Config2__AdjustmentAmount__c = 100;
		standardliTm.Apttus_Config2__AdjustmentType__c = '% Discount';
		standardliTm.Apttus_Config2__PriceListId__c = GenerateTestData.pricelist1.id;
		//standardliTm.Asset_Oracle_ID__c = 'test';
		insert standardliTm;
		system.debug('--------standardliTm-------' + standardliTm);
		system.debug('--------standardliTm-------' + standardliTm);

		xmlnsOracleComAppsOntSoaproviderPl_v10.OutputParameters_element o = new xmlnsOracleComAppsOntSoaproviderPl_v10.OutputParameters_element();
		o.X_SFDC_LINEOUT_TBL = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINEOUT_TBL_TYPE();
		xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINEOUT_TBL_TYPE o1 = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINEOUT_TBL_TYPE();
		o1.X_SFDC_LINEOUT_TBL_ITEM = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINEOUT_REC_TYPE[] { };
		xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINEOUT_REC_TYPE testxml = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINEOUT_REC_TYPE();
		testxml.PROPOSAL_ID = GenerateTestData.proposal.Id;
		testxml.PROPOSAL_LINE_ID = 'test serv';
		testxml.PROPOSAL_SERV_REF_LINE = 'test serv';
		testxml.SERV_START_DATE = System.now();
		testxml.SERV_END_DATE = System.now() + 50;
		testxml.DISCOUNT_EBS_CALCULATED = '18';
		testxml.SELLING_PRICE_EBS_CALCULATED = '20';
		o1.X_SFDC_LINEOUT_TBL_ITEM.add(testxml);
		o.X_SFDC_LINEOUT_TBL = o1;
		system.debug('--------testxml.PROPOSAL_LINE_ID-------' + testxml.PROPOSAL_LINE_ID);

		System.currentPageReference().getParameters().put('id', acpcfg.Id);
		test.startTest();
		AdvancePricingclass apc = new AdvancePricingclass();
		o.X_STATUS = 'ERROR';
		apc.o = o;
		apc.Temp();

		test.stopTest();
	}

	static testmethod void advancePricingTest3() {
		Test.setCurrentPageReference(new PageReference('Page.AdvancePricingPage'));
		GenerateTestData.createAccount();
		GenerateTestData.createPriceList();
		GenerateTestData.createOpportunity();
		GenerateTestData.createAddress();
		GenerateTestData.createProposal();
		GenerateTestData.createProduct2();
		Apttus_Config2__ProductConfiguration__c acpcfg = new Apttus_Config2__ProductConfiguration__c();
		acpcfg.Name = 'test acpcfg';
		acpcfg.Apttus_QPConfig__Proposald__c = GenerateTestData.proposal.Id;
		acpcfg.Apttus_Config2__PriceListId__c = GenerateTestData.pricelist.Id;
		insert acpcfg;


		Apttus_Config2__LineItem__c standardliTm = new Apttus_Config2__LineItem__c();
		standardliTm.Apttus_Config2__ItemSequence__c = 1;
		standardliTm.Apttus_Config2__LineNumber__c = 1;
		standardliTm.Apttus_Config2__ConfigurationId__c = acpcfg.Id;
		standardliTm.Apttus_Config2__Quantity__c = 2;
		standardliTm.Apttus_Config2__ProductId__c = GenerateTestData.prd.Id;
		standardliTm.Apttus_Config2__PrimaryLineNumber__c = 1;
		standardliTm.Apttus_Config2__IsOptionRollupLine__c = true;
		standardliTm.Duration__c = 1;
		standardliTm.Duration_UOM__c = 'Year';
		standardliTm.service_Start_Date__c = system.today();
		standardliTm.service_End_date__c = system.today() + 50;
		standardliTm.Apttus_Config2__ChargeType__c = 'Maintenance Fee';
		standardliTm.Apttus_Config2__IsOptionRollupLine__c = False;
		standardliTm.Apttus_Config2__AdjustmentAmount__c = 100;
		standardliTm.Apttus_Config2__AdjustmentType__c = '% Discount';
		standardliTm.Apttus_Config2__PriceListId__c = GenerateTestData.pricelist1.id;
		//standardliTm.Asset_Oracle_ID__c = 'test';
		insert standardliTm;
		system.debug('--------standardliTm-------' + standardliTm);

		System.currentPageReference().getParameters().put('id', acpcfg.Id);
		test.startTest();
		AdvancePricingclass apc = new AdvancePricingclass();
		apc.displayPopup = false;
		apc.callActionMethod();
		apc.cancelquote();
		apc.showPopup();
		apc.closePopup();
		apc.cancelPage();
		test.stopTest();
	}

	static testmethod void advancePricingTest4() {
		Test.setCurrentPageReference(new PageReference('Page.AdvancePricingPage'));
		GenerateTestData.createAccount();
		GenerateTestData.createPriceList();
		GenerateTestData.createOpportunity();
		GenerateTestData.createAddress();
		GenerateTestData.createProposal();
		GenerateTestData.createProduct2();
		Apttus_Config2__ProductConfiguration__c acpcfg = new Apttus_Config2__ProductConfiguration__c();
		acpcfg.Name = 'test acpcfg';
		acpcfg.Apttus_QPConfig__Proposald__c = GenerateTestData.proposal.Id;
		acpcfg.Apttus_Config2__PriceListId__c = GenerateTestData.pricelist.Id;
		insert acpcfg;


		Apttus_Config2__LineItem__c standardliTm = new Apttus_Config2__LineItem__c();
		standardliTm.Apttus_Config2__ItemSequence__c = 1;
		standardliTm.Apttus_Config2__LineNumber__c = 1;
		standardliTm.Apttus_Config2__ConfigurationId__c = acpcfg.Id;
		standardliTm.Apttus_Config2__Quantity__c = 2;
		standardliTm.Apttus_Config2__ProductId__c = GenerateTestData.prd.Id;
		standardliTm.Apttus_Config2__PrimaryLineNumber__c = 1;
		standardliTm.Apttus_Config2__IsOptionRollupLine__c = true;
		standardliTm.Duration__c = 1;
		standardliTm.Duration_UOM__c = 'Year';
		standardliTm.service_Start_Date__c = system.today();
		standardliTm.service_End_date__c = system.today() + 50;
		standardliTm.Apttus_Config2__ChargeType__c = 'Maintenance Fee';
		standardliTm.Apttus_Config2__LineType__c = 'Misc';
		standardliTm.Apttus_Config2__IsOptionRollupLine__c = False;
		standardliTm.Apttus_Config2__AdjustmentAmount__c = 100;
		standardliTm.Apttus_Config2__AdjustmentType__c = '% Discount';
		standardliTm.Apttus_Config2__PriceListId__c = GenerateTestData.pricelist1.id;
		//standardliTm.Asset_Oracle_ID__c = 'test';
		insert standardliTm;
		system.debug('--------standardliTm-------' + standardliTm);

		System.currentPageReference().getParameters().put('id', acpcfg.Id);
		test.startTest();
		AdvancePricingclass apc = new AdvancePricingclass();
		apc.displayPopup = false;
		apc.stopLoading = true;
		apc.errorPopup = true;
		apc.callActionMethod();

		apc.errorPopup = false;
		test.stopTest();
	}


	static testmethod void advancePricingTest5() {
		Test.setCurrentPageReference(new PageReference('Page.AdvancePricingPage'));
		GenerateTestData.createAccount();
		GenerateTestData.createPriceList();
		GenerateTestData.createOpportunity();
		GenerateTestData.createAddress();
		GenerateTestData.createProposal();
		GenerateTestData.createProduct2();
		Apttus_Config2__ProductConfiguration__c acpcfg = new Apttus_Config2__ProductConfiguration__c();
		acpcfg.Name = 'test acpcfg';
		acpcfg.Apttus_QPConfig__Proposald__c = GenerateTestData.proposal.Id;
		acpcfg.Apttus_Config2__PriceListId__c = GenerateTestData.pricelist1.Id;
		insert acpcfg;


		Apttus_Config2__LineItem__c standardliTm = new Apttus_Config2__LineItem__c();
		standardliTm.Apttus_Config2__ItemSequence__c = 1;
		standardliTm.Apttus_Config2__LineNumber__c = 1;
		standardliTm.Apttus_Config2__ConfigurationId__c = acpcfg.Id;
		standardliTm.Apttus_Config2__Quantity__c = 2;
		standardliTm.Apttus_Config2__ProductId__c = GenerateTestData.prd.Id;
		standardliTm.Apttus_Config2__PrimaryLineNumber__c = 1;
		standardliTm.Apttus_Config2__IsOptionRollupLine__c = true;
		standardliTm.Duration__c = 1;
		standardliTm.Duration_UOM__c = 'Year';
		standardliTm.service_Start_Date__c = system.today();
		standardliTm.service_End_date__c = system.today() + 50;
		standardliTm.Apttus_Config2__ChargeType__c = 'Maintenance Fee';
		standardliTm.Apttus_Config2__IsOptionRollupLine__c = False;
		standardliTm.Apttus_Config2__AdjustmentAmount__c = 100;
		standardliTm.Apttus_Config2__AdjustmentType__c = '% Discount';
		standardliTm.Apttus_Config2__PriceListId__c = GenerateTestData.pricelist1.id;
		//standardliTm.Asset_Oracle_ID__c = 'test';
		insert standardliTm;
		system.debug('--------standardliTm-------' + standardliTm);

		System.currentPageReference().getParameters().put('id', acpcfg.Id);
		test.startTest();
		AdvancePricingclass apc = new AdvancePricingclass();
		apc.displayPopup = false;
		apc.stopLoading = true;
		apc.errorPopup = true;
		apc.rollupDiscount();
		apc.updateDiscountAndDuration();

		apc.errorPopup = false;
		test.stopTest();
	}

	static testmethod void advancePricingTest6() {
		Test.setCurrentPageReference(new PageReference('Page.AdvancePricingPage'));
		GenerateTestData.createAccount();
		GenerateTestData.createPriceList();
		GenerateTestData.createOpportunity();
		GenerateTestData.createAddress();
		GenerateTestData.createProposal();
		GenerateTestData.createProduct2();
		Apttus_Config2__ProductConfiguration__c acpcfg = new Apttus_Config2__ProductConfiguration__c();
		acpcfg.Name = 'test acpcfg';
		acpcfg.Apttus_QPConfig__Proposald__c = GenerateTestData.proposal.Id;
		acpcfg.Apttus_Config2__PriceListId__c = GenerateTestData.pricelist.Id;
		insert acpcfg;


		Apttus_Config2__LineItem__c standardliTm = new Apttus_Config2__LineItem__c();
		standardliTm.Apttus_Config2__ItemSequence__c = 1;
		standardliTm.Apttus_Config2__LineNumber__c = 1;
		standardliTm.Apttus_Config2__ConfigurationId__c = acpcfg.Id;
		standardliTm.Apttus_Config2__Quantity__c = 2;
		standardliTm.Apttus_Config2__ProductId__c = GenerateTestData.prd.Id;
		standardliTm.Apttus_Config2__PrimaryLineNumber__c = 1;
		standardliTm.Apttus_Config2__IsOptionRollupLine__c = true;
		standardliTm.Duration__c = 1;
		standardliTm.Duration_UOM__c = 'Year';
		standardliTm.service_Start_Date__c = system.today();
		standardliTm.service_End_date__c = system.today() + 50;
		standardliTm.Apttus_Config2__ChargeType__c = 'Maintenance Fee';
		standardliTm.Apttus_Config2__IsOptionRollupLine__c = False;
		standardliTm.Apttus_Config2__AdjustmentAmount__c = 100;
		standardliTm.Apttus_Config2__AdjustmentType__c = '% Discount';
		standardliTm.Apttus_Config2__PriceListId__c = GenerateTestData.pricelist1.id;
		//standardliTm.Asset_Oracle_ID__c = 'test';
		insert standardliTm;
		system.debug('--------standardliTm-------' + standardliTm);

		System.currentPageReference().getParameters().put('id', acpcfg.Id);
		test.startTest();
		AdvancePricingclass apc = new AdvancePricingclass();
		apc.displayPopup = false;
		apc.stopLoading = true;
		apc.errorPopup = true;
		apc.Split();
		apc.Reprice();
		//apc.doUpdatePrice();
		apc.errorPopup = false;
		test.stopTest();
	}

	static testmethod void advancePricingTest7() {
		Test.setCurrentPageReference(new PageReference('Page.AdvancePricingPage'));
		GenerateTestData.createAccount();
		GenerateTestData.createPriceList();
		GenerateTestData.createOpportunity();
		GenerateTestData.createAddress();
		GenerateTestData.createProposal();
		GenerateTestData.createProduct2();
		Apttus_Config2__ProductConfiguration__c acpcfg = new Apttus_Config2__ProductConfiguration__c();
		acpcfg.Name = 'test acpcfg';
		acpcfg.Apttus_QPConfig__Proposald__c = GenerateTestData.proposal.Id;
		acpcfg.Apttus_Config2__PriceListId__c = GenerateTestData.pricelist.Id;
		insert acpcfg;

		LisT<Apttus_Config2__LineItem__c> liTmList = new List<Apttus_Config2__LineItem__c> ();
		Apttus_Config2__LineItem__c standardliTm = new Apttus_Config2__LineItem__c();
		standardliTm.Apttus_Config2__LineNumber__c = 1;
		standardliTm.Apttus_Config2__ItemSequence__c = 2;
		standardliTm.Apttus_Config2__ConfigurationId__c = acpcfg.Id;
		standardliTm.Apttus_Config2__Quantity__c = 2;
		standardliTm.Apttus_Config2__ProductId__c = GenerateTestData.prd.Id;
		standardliTm.Apttus_Config2__PrimaryLineNumber__c = 1;
		standardliTm.Parent_Line_Number__c = null;
		standardliTm.Apttus_Config2__IsPrimaryLine__c = true;
		standardliTm.Duration__c = 2;
		standardliTm.Apttus_Config2__OptionId__c = GenerateTestData.prd.Id;
		standardliTm.Duration_UOM__c = 'Year';
		standardliTm.Asset_Oracle_ID__c = 'test';
		standardliTm.service_Start_Date__c = system.today();
		standardliTm.service_End_date__c = system.today() + 50;
		standardliTm.Apttus_Config2__ChargeType__c = 'Maintenance Fee';
		standardliTm.Apttus_Config2__LineType__c = 'Option';
		standardliTm.Apttus_Config2__IsOptionRollupLine__c = false;
		standardliTm.Parent_Line_Number__c = null;
		standardliTm.Apttus_Config2__AdjustmentAmount__c = 100;
		standardliTm.Apttus_Config2__AdjustmentType__c = '% Discount';
		standardliTm.Apttus_Config2__PriceListId__c = GenerateTestData.pricelist1.id;
		//standardliTm.Asset_Oracle_ID__c = 'test';
		liTmList.add(standardliTm);
		insert liTmList;

		system.debug('--------standardliTm-------' + standardliTm);

		System.currentPageReference().getParameters().put('id', acpcfg.Id);
		test.startTest();
		AdvancePricingclass apc = new AdvancePricingclass();
		apc.displayPopup = false;
		apc.stopLoading = true;
		apc.errorPopup = true;
		apc.split();
		test.stopTest();
	}

	static testmethod void advancePricingTest8() {
		Test.setCurrentPageReference(new PageReference('Page.AdvancePricingPage'));
		GenerateTestData.createAccount();
		GenerateTestData.createPriceList();
		GenerateTestData.createOpportunity();
		GenerateTestData.createAddress();
		GenerateTestData.createProposal();
		GenerateTestData.createProduct2();

		system.debug('>>>>>>>DIVISION>>>>>>>>' + GenerateTestData.pricelist1.Division__c);

		Apttus_Config2__ProductConfiguration__c acpcfg = new Apttus_Config2__ProductConfiguration__c();
		acpcfg.Name = 'test acpcfg';
		acpcfg.Apttus_QPConfig__Proposald__c = GenerateTestData.proposal.Id;
		acpcfg.Apttus_Config2__PriceListId__c = GenerateTestData.pricelist1.Id;
		insert acpcfg;

		LisT<Apttus_Config2__LineItem__c> liTmList = new List<Apttus_Config2__LineItem__c> ();
		Apttus_Config2__LineItem__c standardliTm = new Apttus_Config2__LineItem__c();
		standardliTm.Apttus_Config2__LineNumber__c = 1;
		standardliTm.Apttus_Config2__ItemSequence__c = 1;
		standardliTm.Apttus_Config2__ConfigurationId__c = acpcfg.Id;
		standardliTm.Apttus_Config2__Quantity__c = 2;
		standardliTm.Apttus_Config2__ProductId__c = GenerateTestData.prd.Id;
		standardliTm.Apttus_Config2__PrimaryLineNumber__c = 1;
		standardliTm.Parent_Line_Number__c = null;
		standardliTm.Apttus_Config2__IsPrimaryLine__c = true;
		standardliTm.Duration__c = 3;
		standardliTm.Apttus_Config2__OptionId__c = GenerateTestData.prd.Id;
		standardliTm.Duration_UOM__c = 'Year';
		standardliTm.Asset_Oracle_ID__c = 'test';
		standardliTm.service_Start_Date__c = system.today();
		standardliTm.service_End_date__c = system.today() + 50;
		standardliTm.Apttus_Config2__ChargeType__c = 'Maintenance Fee';
		standardliTm.Apttus_Config2__LineType__c = 'Option';
		standardliTm.Apttus_Config2__IsOptionRollupLine__c = true;
		standardliTm.Apttus_Config2__AdjustmentAmount__c = 100;
		standardliTm.Apttus_Config2__AdjustmentType__c = '% Discount';
		standardliTm.Apttus_Config2__PriceListId__c = GenerateTestData.pricelist1.id;
		liTmList.add(standardliTm);

		standardliTm = new Apttus_Config2__LineItem__c();
		standardliTm.Apttus_Config2__LineNumber__c = 1;
		standardliTm.Apttus_Config2__ItemSequence__c = 2;
		standardliTm.Apttus_Config2__ConfigurationId__c = acpcfg.Id;
		standardliTm.Apttus_Config2__Quantity__c = 2;
		standardliTm.Apttus_Config2__ProductId__c = GenerateTestData.prd.Id;
		standardliTm.Apttus_Config2__PrimaryLineNumber__c = 1;
		standardliTm.Parent_Line_Number__c = null;
		standardliTm.Apttus_Config2__IsPrimaryLine__c = true;
		standardliTm.Duration__c = 3;
		standardliTm.service_Start_Date__c = system.today();
		standardliTm.service_End_date__c = system.today() + 50;
		standardliTm.Apttus_Config2__OptionId__c = GenerateTestData.prd.Id;
		standardliTm.Duration_UOM__c = 'Year';
		standardliTm.Asset_Oracle_ID__c = 'test';
		standardliTm.Apttus_Config2__ChargeType__c = 'Maintenance Fee';
		standardliTm.Apttus_Config2__LineType__c = 'Option';
		standardliTm.Apttus_Config2__IsOptionRollupLine__c = false;
		standardliTm.Parent_Line_Number__c = null;
		standardliTm.Apttus_Config2__AdjustmentAmount__c = 100;
		standardliTm.Apttus_Config2__AdjustmentType__c = '% Discount';
		standardliTm.Apttus_Config2__PriceListId__c = GenerateTestData.pricelist1.id;
		//standardliTm.Asset_Oracle_ID__c = 'test';
		liTmList.add(standardliTm);
		insert liTmList;

		system.debug('--------standardliTm-------' + standardliTm);
		system.debug('--------standardliTm DIVISION-------' + standardliTm.Apttus_Config2__PriceListId__r.Division__c);

		System.currentPageReference().getParameters().put('id', acpcfg.Id);
		test.startTest();
		AdvancePricingclass apc = new AdvancePricingclass();
		apc.displayPopup = false;
		apc.stopLoading = true;
		apc.errorPopup = true;
		apc.PriceListSplit = FALSE;
		apc.split();
		test.stopTest();
	}

	static testmethod void advancePricingTest9() {
		Test.setCurrentPageReference(new PageReference('Page.AdvancePricingPage'));
		GenerateTestData.createAccount();
		GenerateTestData.createPriceList();
		GenerateTestData.createOpportunity();
		GenerateTestData.createAddress();
		GenerateTestData.createProposal();
		GenerateTestData.createProduct2();
		Apttus_Config2__ProductConfiguration__c acpcfg = new Apttus_Config2__ProductConfiguration__c();
		acpcfg.Name = 'test acpcfg';
		acpcfg.Apttus_QPConfig__Proposald__c = GenerateTestData.proposal.Id;
		acpcfg.Apttus_Config2__PriceListId__c = GenerateTestData.pricelist.Id;
		insert acpcfg;


		Apttus_Config2__LineItem__c standardliTm = new Apttus_Config2__LineItem__c();
		standardliTm.Apttus_Config2__LineNumber__c = 1;
		standardliTm.Apttus_Config2__ItemSequence__c = 1;
		standardliTm.Apttus_Config2__ConfigurationId__c = acpcfg.Id;
		standardliTm.Apttus_Config2__Quantity__c = 2;
		standardliTm.Apttus_Config2__ProductId__c = GenerateTestData.prd.Id;
		standardliTm.Apttus_Config2__PrimaryLineNumber__c = 1;
		standardliTm.Apttus_Config2__IsPrimaryLine__c = true;
		standardliTm.Duration__c = 1;
		standardliTm.service_Start_Date__c = system.today();
		standardliTm.service_End_date__c = system.today() + 50;
		standardliTm.Duration_UOM__c = 'Year';
		standardliTm.Asset_Oracle_ID__c = 'test';
		standardliTm.Apttus_Config2__ChargeType__c = 'Maintenance Fee';
		standardliTm.Apttus_Config2__LineType__c = 'Product/Service';
		standardliTm.Apttus_Config2__IsOptionRollupLine__c = true;
		standardliTm.Apttus_Config2__AdjustmentAmount__c = 100;
		standardliTm.Apttus_Config2__AdjustmentType__c = '% Discount';
		standardliTm.Apttus_Config2__PriceListId__c = GenerateTestData.pricelist1.id;
		//standardliTm.Asset_Oracle_ID__c = 'test';
		insert standardliTm;
		system.debug('--------standardliTm-------' + standardliTm);

		System.currentPageReference().getParameters().put('id', acpcfg.Id);
		test.startTest();
		AdvancePricingclass apc = new AdvancePricingclass();
		apc.displayPopup = false;
		apc.stopLoading = true;
		apc.errorPopup = true;
		apc.split();
		apc.UpdateTax('1');
		apc.errorPopup = false;
		test.stopTest();
	}

	static testmethod void advancePricingTest10() {
		Test.setCurrentPageReference(new PageReference('Page.AdvancePricingPage'));
		GenerateTestData.createAccount();
		GenerateTestData.createPriceList();
		GenerateTestData.createOpportunity();
		GenerateTestData.createAddress();
		GenerateTestData.createProposal();
		GenerateTestData.createProduct2();
		Apttus_Config2__ProductConfiguration__c acpcfg = new Apttus_Config2__ProductConfiguration__c();
		acpcfg.Name = 'test acpcfg';
		acpcfg.Apttus_QPConfig__Proposald__c = GenerateTestData.proposal.Id;
		acpcfg.Apttus_Config2__PriceListId__c = GenerateTestData.pricelist.Id;
		insert acpcfg;

		LisT<Apttus_Config2__LineItem__c> liTmList = new List<Apttus_Config2__LineItem__c> ();
		Apttus_Config2__LineItem__c standardliTm = new Apttus_Config2__LineItem__c();
		standardliTm.Apttus_Config2__LineNumber__c = 1;
		standardliTm.Apttus_Config2__ItemSequence__c = 1;
		standardliTm.Apttus_Config2__ConfigurationId__c = acpcfg.Id;
		standardliTm.Apttus_Config2__Quantity__c = 2;
		standardliTm.Apttus_Config2__ProductId__c = GenerateTestData.prd.Id;
		standardliTm.Apttus_Config2__PrimaryLineNumber__c = 1;
		standardliTm.Parent_Line_Number__c = null;
		standardliTm.Apttus_Config2__IsPrimaryLine__c = true;
		standardliTm.Duration__c = 2;
		standardliTm.Apttus_Config2__OptionId__c = GenerateTestData.prd.Id;
		standardliTm.Duration_UOM__c = 'Year';
		standardliTm.Asset_Oracle_ID__c = 'test';
		standardliTm.service_Start_Date__c = system.today();
		standardliTm.service_End_date__c = system.today() + 50;
		standardliTm.Apttus_Config2__ChargeType__c = 'Maintenance Fee';
		standardliTm.Apttus_Config2__LineType__c = 'Option';
		standardliTm.Apttus_Config2__IsOptionRollupLine__c = true;
		standardliTm.Apttus_Config2__AdjustmentAmount__c = 100;
		standardliTm.Apttus_Config2__AdjustmentType__c = '% Discount';
		standardliTm.Apttus_Config2__PriceListId__c = GenerateTestData.pricelist1.id;
		liTmList.add(standardliTm);

		standardliTm = new Apttus_Config2__LineItem__c();
		standardliTm.Apttus_Config2__LineNumber__c = 1;
		standardliTm.Apttus_Config2__ItemSequence__c = 2;
		standardliTm.Apttus_Config2__ConfigurationId__c = acpcfg.Id;
		standardliTm.Apttus_Config2__Quantity__c = 2;
		standardliTm.Apttus_Config2__ProductId__c = GenerateTestData.prd.Id;
		standardliTm.Apttus_Config2__PrimaryLineNumber__c = 1;
		standardliTm.Parent_Line_Number__c = null;
		standardliTm.Apttus_Config2__IsPrimaryLine__c = true;
		standardliTm.Duration__c = 2;
		standardliTm.Apttus_Config2__OptionId__c = GenerateTestData.prd.Id;
		standardliTm.Duration_UOM__c = 'Year';
		standardliTm.Asset_Oracle_ID__c = 'test';
		standardliTm.Apttus_Config2__ChargeType__c = 'Maintenance Fee';
		standardliTm.Apttus_Config2__LineType__c = 'Option';
		standardliTm.Apttus_Config2__IsOptionRollupLine__c = false;
		standardliTm.Parent_Line_Number__c = null;
		standardliTm.Apttus_Config2__AdjustmentAmount__c = 100;
		standardliTm.Apttus_Config2__AdjustmentType__c = '% Discount';
		standardliTm.service_Start_Date__c = system.today();
		standardliTm.service_End_date__c = system.today() + 50;
		//standardliTm.Asset_Oracle_ID__c = 'test';
		liTmList.add(standardliTm);
		insert liTmList;

		system.debug('--------standardliTm-------' + standardliTm);

		System.currentPageReference().getParameters().put('id', acpcfg.Id);
		test.startTest();
		AdvancePricingclass apc = new AdvancePricingclass();
		apc.displayPopup = false;
		apc.stopLoading = true;
		apc.errorPopup = true;
		apc.PriceListSplit = false;
		apc.split();
		apc.reprice2();
		test.stopTest();
	}
	static testmethod void advancePricingTest11() {
		Test.setCurrentPageReference(new PageReference('Page.AdvancePricingPage'));
		GenerateTestData.createAccount();
		GenerateTestData.createPriceList();
		GenerateTestData.createOpportunity();
		GenerateTestData.createAddress();
		GenerateTestData.createProposal();
		GenerateTestData.createProduct2();

		GenerateTestData.prd.Contract_Item_Type_Code__c = 'SERVICE';
		update GenerateTestData.prd;

		Apttus_Config2__ProductConfiguration__c acpcfg = new Apttus_Config2__ProductConfiguration__c();
		acpcfg.Name = 'test acpcfg';
		acpcfg.Apttus_QPConfig__Proposald__c = GenerateTestData.proposal.Id;
		acpcfg.Apttus_Config2__PriceListId__c = GenerateTestData.pricelist.Id;
		insert acpcfg;

		Apttus_Config2__LineItem__c standardliTm = new Apttus_Config2__LineItem__c();
		standardliTm.Apttus_Config2__LineNumber__c = 1;
		standardliTm.Apttus_Config2__ItemSequence__c = 1;
		standardliTm.Apttus_Config2__ConfigurationId__c = acpcfg.Id;
		standardliTm.Apttus_Config2__Quantity__c = - 1;
		standardliTm.Apttus_Config2__ProductId__c = GenerateTestData.prd.Id;
		standardliTm.Apttus_Config2__OptionId__c = GenerateTestData.prd.Id;
		standardliTm.Apttus_Config2__PrimaryLineNumber__c = 1;
		standardliTm.Apttus_Config2__IsPrimaryLine__c = true;
		standardliTm.Duration__c = 4;
		standardliTm.Service_Start_Date__c = system.today();
		standardliTm.Service_End_date__c = system.today() + 50;
		standardliTm.Duration_UOM__c = 'Year';
		standardliTm.Asset_Oracle_ID__c = 'test';
		standardliTm.Type__c = 'Renewal';
		standardliTm.Apttus_Config2__ChargeType__c = 'Maintenance Fee';
		standardliTm.Apttus_Config2__LineType__c = 'Product/Service';
		standardliTm.Apttus_Config2__IsOptionRollupLine__c = true;
		standardliTm.Apttus_Config2__AdjustmentAmount__c = 100;
		standardliTm.Apttus_Config2__AdjustmentType__c = '% Discount';
		standardliTm.Apttus_Config2__PriceListId__c = GenerateTestData.pricelist1.id;
		//standardliTm.Asset_Oracle_ID__c = 'test';
		insert standardliTm;
		system.debug('--------standardliTm-------' + standardliTm);

		System.currentPageReference().getParameters().put('id', acpcfg.Id);
		test.startTest();
		AdvancePricingclass apc = new AdvancePricingclass();

		apc.displayPopup = false;
		apc.stopLoading = true;
		apc.errorPopup = true;
		apc.PriceListSplit = FALSE;
		apc.split();
		apc.UpdateTax('1');
		apc.errorPopup = false;

		apc.flowUI = 'Angular';
		apc.url = 'CartDetailView';
		apc.cancelPagecart();
		apc.cancelPage();

		apc.flowUI = 'ngCPQ';
		apc.cancelPagecart();

		apc.flowUI = 'Default';
		apc.url = 'CartDetailView';
		apc.cancelPage();

		apc.flowUI = 'ngCPQ';
		apc.url = 'CartDetailView';
		apc.cancelPage();

		apc.flowUI = 'Default';
		apc.url = 'ProductAttributeDetail';
		apc.cancelPage();

		apc.flowUI = 'Angular';
		apc.url = 'ProductAttributeDetail';
		apc.cancelPage();

		apc.flowUI = 'Default';
		apc.url = 'Bundle';
		apc.cancelPage();

		apc.flowUI = 'Angular';
		apc.url = 'Bundle';
		apc.cancelPage();

		apc.doUpdatePrice();

		// Increase Code Coverage
		apc.MaxDate = system.today();
		apc.SplitYear = 1.2;
		apc.finalRes = true;
		apc.creditcheck = false;
		apc.ProfessionalService = true;
		apc.OracleIntegrationError = 'Test Exception';
		////
		test.stopTest();
	}
	static testmethod void advancePricingTest12() {
		Test.setCurrentPageReference(new PageReference('Page.AdvancePricingPage'));
		GenerateTestData.createAccount();
		GenerateTestData.createPriceList();
		GenerateTestData.createOpportunity();
		GenerateTestData.createAddress();
		GenerateTestData.createProposal();
		GenerateTestData.createProduct2();

		GenerateTestData.prd.Contract_Item_Type_Code__c = 'SERVICE';
		update GenerateTestData.prd;

		Apttus_Config2__ProductConfiguration__c acpcfg = new Apttus_Config2__ProductConfiguration__c();
		acpcfg.Name = 'test acpcfg';
		acpcfg.Apttus_QPConfig__Proposald__c = GenerateTestData.proposal.Id;
		acpcfg.Apttus_Config2__PriceListId__c = GenerateTestData.pricelist1.Id;
		insert acpcfg;

		Apttus_Config2__LineItem__c standardliTm = new Apttus_Config2__LineItem__c();
		standardliTm.Apttus_Config2__LineNumber__c = 1;
		standardliTm.Apttus_Config2__ItemSequence__c = 1;
		standardliTm.Apttus_Config2__ConfigurationId__c = acpcfg.Id;
		standardliTm.Apttus_Config2__Quantity__c = - 1;
		standardliTm.Apttus_Config2__ProductId__c = GenerateTestData.prd.Id;
		standardliTm.Apttus_Config2__OptionId__c = GenerateTestData.prd.Id;
		standardliTm.Apttus_Config2__PrimaryLineNumber__c = 1;
		standardliTm.Apttus_Config2__IsPrimaryLine__c = true;
		standardliTm.Duration__c = 4;
		standardliTm.Service_Start_Date__c = system.today();
		standardliTm.Service_End_date__c = system.today() + 50;
		standardliTm.Duration_UOM__c = 'Year';
		standardliTm.Type__c = 'New Buy';
		standardliTm.Apttus_Config2__ChargeType__c = 'Maintenance Fee';
		standardliTm.Apttus_Config2__LineType__c = 'Product/Service';
		standardliTm.Apttus_Config2__IsOptionRollupLine__c = true;
		standardliTm.Apttus_Config2__AdjustmentAmount__c = 100;
		standardliTm.Apttus_Config2__AdjustmentType__c = '% Discount';
		standardliTm.Apttus_Config2__PriceListId__c = GenerateTestData.pricelist1.id;
		standardliTm.service_Start_date__c = system.today();
		standardliTm.service_End_date__c = system.today() + 30;
		standardliTm.Type__c = 'Renewal';
		//standardliTm.Asset_Oracle_ID__c = 'test';
		insert standardliTm;
		system.debug('--------standardliTm-------' + standardliTm);

		System.currentPageReference().getParameters().put('id', acpcfg.Id);
		test.startTest();
		AdvancePricingclass apc = new AdvancePricingclass();

		apc.displayPopup = false;
		apc.stopLoading = true;
		apc.errorPopup = true;
		apc.PriceListSplit = FALSE;
		apc.split();
		apc.UpdateTax('1');

		apc.rollupDiscount();
		apc.updateDiscountAndDuration();

		apc.errorPopup = false;
		test.stopTest();
	}

	static testmethod void advancePricingTest13() {
		Test.setCurrentPageReference(new PageReference('Page.AdvancePricingPage'));
		GenerateTestData.createAccount();
		GenerateTestData.createPriceList();
		GenerateTestData.createOpportunity();
		GenerateTestData.createAddress();
		GenerateTestData.createProposal();
		GenerateTestData.createProduct2();

		GenerateTestData.prd.ICC_Type__c = 'Scheduled Publications';
		GenerateTestData.prd.Business_Area__c = 'TRADE SERVICE';
		GenerateTestData.prd.Contract_Item_Type_Code__c = 'SERVICE';
		update GenerateTestData.prd;

		GenerateTestData.proposal.Cart_Line_Sequence_Changed__c = true;
		GenerateTestData.proposal.Surcharge_Percentage__c = '10%';
		update GenerateTestData.proposal;

		Apttus_Config2__ProductConfiguration__c acpcfg = new Apttus_Config2__ProductConfiguration__c();
		acpcfg.Name = 'test acpcfg';
		acpcfg.Apttus_QPConfig__Proposald__c = GenerateTestData.proposal.Id;
		acpcfg.Apttus_Config2__PriceListId__c = GenerateTestData.pricelist1.Id;
		insert acpcfg;

		Apttus_Config2__LineItem__c standardliTm = new Apttus_Config2__LineItem__c();
		standardliTm.Apttus_Config2__LineNumber__c = 1;
		standardliTm.Apttus_Config2__ItemSequence__c = 1;
		standardliTm.Apttus_Config2__ConfigurationId__c = acpcfg.Id;
		standardliTm.Apttus_Config2__Quantity__c = - 1;
		standardliTm.Apttus_Config2__ProductId__c = GenerateTestData.prd.Id;
		standardliTm.Apttus_Config2__OptionId__c = GenerateTestData.prd.Id;
		standardliTm.Apttus_Config2__PrimaryLineNumber__c = 1;
		standardliTm.Apttus_Config2__IsPrimaryLine__c = true;
		standardliTm.Duration__c = 4;
		standardliTm.Service_Start_Date__c = system.today();
		standardliTm.Service_End_date__c = system.today() + 50;
		standardliTm.Duration_UOM__c = 'Year';
		standardliTm.Type__c = 'New Buy';
		standardliTm.Apttus_Config2__ChargeType__c = 'Maintenance Fee';
		standardliTm.Apttus_Config2__LineType__c = 'Product/Service';
		standardliTm.Apttus_Config2__IsOptionRollupLine__c = true;
		standardliTm.Apttus_Config2__AdjustmentAmount__c = 100;
		standardliTm.Apttus_Config2__AdjustmentType__c = '% Discount';
		standardliTm.Apttus_Config2__PriceListId__c = GenerateTestData.pricelist1.id;
		standardliTm.service_Start_date__c = system.today();
		standardliTm.service_End_date__c = system.today() + 30;
		standardliTm.Type__c = 'Renewal';
		//standardliTm.Asset_Oracle_ID__c = 'test';
		insert standardliTm;
		system.debug('--------standardliTm-------' + standardliTm);

		System.currentPageReference().getParameters().put('id', acpcfg.Id);
		test.startTest();
		Map<String, String> tempMap = new Map<String, String> ();
		tempMap.put('id', acpcfg.Id);
		AdvancePricingclass apc = new AdvancePricingclass(tempMap);

		apc.displayPopup = false;
		apc.stopLoading = true;
		apc.errorPopup = true;
		apc.PriceListSplit = FALSE;
		apc.split();
		apc.UpdateTax('1');

		apc.rollupDiscount();
		apc.updateDiscountAndDuration();

		apc.errorPopup = false;
		apc.callHardwareKitpage();
		test.stopTest();
	}

}