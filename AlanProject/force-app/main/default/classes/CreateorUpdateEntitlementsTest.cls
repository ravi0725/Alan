@isTest
private class CreateorUpdateEntitlementsTest {

	private static Country_Region_Mapping__c cust;
	private static Geospatial_Country_Region_Mapping__c custRegMap;
	private static Account acct;
	private static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
	private static User thisUser;
	private static Product2 prod;
	private static Product2 prod1;
	private static Asset asst;
	private static List<CreateorUpdateEntitlements.requestdata> reqServ00 = new List<CreateorUpdateEntitlements.requestdata> ();
	private static List<CreateorUpdateEntitlements.requestdata> reqServ01 = new List<CreateorUpdateEntitlements.requestdata> ();
	private static List<CreateorUpdateEntitlements.requestdata> reqServ02 = new List<CreateorUpdateEntitlements.requestdata> ();
	private static List<CreateorUpdateEntitlements.requestdata> reqServ03 = new List<CreateorUpdateEntitlements.requestdata> ();
	private static List<CreateorUpdateEntitlements.requestdata> reqServ04 = new List<CreateorUpdateEntitlements.requestdata> ();
	private static List<CreateorUpdateEntitlements.requestdata> reqServ05 = new List<CreateorUpdateEntitlements.requestdata> ();
	private static List<CreateorUpdateEntitlements.requestdata> reqServ06 = new List<CreateorUpdateEntitlements.requestdata> ();
	private static List<CreateorUpdateEntitlements.requestdata> reqServ07 = new List<CreateorUpdateEntitlements.requestdata> ();

	private static List<Entitlement> entList = new List<Entitlement> ();

	static void setUpData() {

		cust = new Country_Region_Mapping__c(name = 'India', Region__c = 'India');
		insert cust;

		custRegMap = new Geospatial_Country_Region_Mapping__c(name = 'India', Region__c = 'India');
		insert custRegMap;

		thisUser = [select Id from User where Id = :UserInfo.getUserId()];

		acct = new Account(Name = 'Test Assign Case Account', RecordTypeId = acctRecTypeId, Account_Status__c = 'Pending', Requested_Account_Record_Type__c = 'Customer',
		                   BillingCountry = 'India', BillingCity = 'Pune', BillingStreet = 'A-202', OwnerId = thisUser.Id, FCH_Party_ID__c = '100', Phone = '111-111-1111', BillingState = 'Goa',
		                   BillingPostalCode = '343220');
		insert acct;

		asst = new Asset(name = 'Test Asset', AccountId = acct.Id, Asset_Oracle_ID__c = 'Test');
		insert asst;

		prod = new Product2();
		prod.IsActive = true;
		prod.Name = 'ABC';
		prod.Certificate__c = 'C1';
		prod.Contract_Item_Type_Code__c = 'WARRANTY';
		prod.ProductCode = 'pCode1';
		prod.business_Area__c = 'MEP PROFESSIONAL SERVICES';
		insert prod;

		prod1 = new Product2();
		prod1.IsActive = true;
		prod1.Name = 'ABC';
		prod1.Certificate__c = 'C1';
		prod1.Contract_Item_Type_Code__c = 'WARRANTY';
		prod1.ProductCode = 'pCode2';
		prod1.business_Area__c = 'PROJECT SOFTWARE SOLUTIONS';
		insert prod1;

		RecursiveTriggerUtility.isAccountRecursive = true;
		entList.add(new Entitlement(name = 'Test Entitlement', AccountId = acct.Id, Contract_Number__c = 'Test', Type = 'New', Asset_Sequence__c = 'Seq', AssetId = asst.Id, Product_Code__c = 'pCode2', supported_Product_Family_Roll_up__c = 'CAD Software'));
		entList.add(new Entitlement(name = 'Test Entitlement', AccountId = acct.Id, Contract_Number__c = 'Test', Type = 'New', Asset_Sequence__c = 'Seq', AssetId = asst.Id, supported_Product_Family_Roll_up__c = 'Business Software'));
		entList.add(new Entitlement(name = 'Test Entitlement', AccountId = acct.Id, Contract_Number__c = 'Test', Type = 'New', Asset_Sequence__c = 'Seq', AssetId = asst.Id, supported_Product_Family_Roll_up__c = 'Hardware'));
		entList.add(new Entitlement(name = 'Test Entitlement', AccountId = acct.Id, Contract_Number__c = 'Test', Type = 'New', Asset_Sequence__c = 'Seq', AssetId = asst.Id, supported_Product_Family_Roll_up__c = 'Tekla'));
		entList.add(new Entitlement(name = 'Test Entitlement', AccountId = acct.Id, Contract_Number__c = 'Test', Type = 'New', Asset_Sequence__c = 'Seq', AssetId = asst.Id, supported_Product_Family_Roll_up__c = 'IES'));
		insert entList;

		CreateorUpdateEntitlements.requestdata req00 = new CreateorUpdateEntitlements.requestdata();
		req00.EntitlementAsset = asst.Asset_Oracle_ID__c;
		req00.EntitlementAccountMasterID = acct.FCH_Party_ID__c;
		req00.EntitlementAccountName = 'Test';
		req00.EntitlementName = entList[0].Contract_Number__c;
		req00.EntitlementType = entList[0].Type;
		req00.EntitlementProductFamily = 'Test';
		req00.EntitlementStatus = 'Test';
		req00.EntitlementStartDate = '2013-04-17T19:09:27.000Z';
		req00.EntitlementEndDate = '2015-04-17T19:09:27.000Z';
		req00.AssetEffectivity = 'TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest';
		req00.AssetEffectivityStartdate = '2013-04-17T19:09:27.000Z';
		req00.AssetEffectivityEnddate = '2015-04-17T19:09:27.000Z';
		req00.AnnualCost = '100';
		req00.AssetSequence = entList[0].Asset_Sequence__c;
		req00.AnnualCostCurrency = 'USD';
		req00.ProductCode = prod1.productcode;

		CreateorUpdateEntitlements.requestdata req01 = new CreateorUpdateEntitlements.requestdata();
		req01.EntitlementAsset = asst.Asset_Oracle_ID__c;
		req01.EntitlementAccountMasterID = acct.FCH_Party_ID__c;
		req01.EntitlementAccountName = 'Test';
		req01.EntitlementName = entList[0].Contract_Number__c;
		req01.EntitlementType = entList[0].Type;
		req01.EntitlementProductFamily = 'Test';
		req01.EntitlementStatus = 'Test';
		req01.EntitlementStartDate = '2013-04-17T19:09:27.000Z';
		req01.EntitlementEndDate = '2015-04-17T19:09:27.000Z';
		req01.AssetEffectivity = 'TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest';
		req01.AssetEffectivityStartdate = '2013-04-17T19:09:27.000Z';
		req01.AssetEffectivityEnddate = '2015-04-17T19:09:27.000Z';
		req01.AnnualCost = '100';
		req01.AssetSequence = entList[0].Asset_Sequence__c;
		req01.AnnualCostCurrency = 'USD';
		req01.ProductCode = prod.productcode;

		CreateorUpdateEntitlements.requestdata req02 = new CreateorUpdateEntitlements.requestdata();
		req02.EntitlementAsset = asst.Asset_Oracle_ID__c;
		req02.EntitlementAccountMasterID = acct.FCH_Party_ID__c;
		req02.EntitlementAccountName = 'Test';
		req02.EntitlementName = '';
		req02.EntitlementType = entList[0].Type;
		req02.EntitlementProductFamily = 'Test';
		req02.EntitlementStatus = 'Test';
		req02.EntitlementStartDate = '2013-04-17T19:09:27.000Z';
		req02.EntitlementEndDate = '2015-04-17T19:09:27.000Z';
		req02.AssetEffectivity = 'TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest';
		req02.AssetEffectivityStartdate = '2013-04-17T19:09:27.000Z';
		req02.AssetEffectivityEnddate = '2015-04-17T19:09:27.000Z';
		req02.AnnualCost = '100';
		req02.AssetSequence = entList[0].Asset_Sequence__c;
		req02.AnnualCostCurrency = 'USD';
		req02.ProductCode = prod1.productcode;

		CreateorUpdateEntitlements.requestdata req03 = new CreateorUpdateEntitlements.requestdata();
		req03.EntitlementAsset = asst.Asset_Oracle_ID__c;
		req03.EntitlementAccountMasterID = acct.FCH_Party_ID__c;
		req03.EntitlementAccountName = '';
		req03.EntitlementName = entList[0].Contract_Number__c;
		req03.EntitlementType = entList[0].Type;
		req03.EntitlementProductFamily = 'Test';
		req03.EntitlementStatus = 'Test';
		req03.EntitlementStartDate = '2013-04-17T19:09:27.000Z';
		req03.EntitlementEndDate = '2015-04-17T19:09:27.000Z';
		req03.AssetEffectivity = 'TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest';
		req03.AssetEffectivityStartdate = '2013-04-17T19:09:27.000Z';
		req03.AssetEffectivityEnddate = '2015-04-17T19:09:27.000Z';
		req03.AnnualCost = '100';
		req03.AssetSequence = entList[0].Asset_Sequence__c;
		req03.AnnualCostCurrency = 'USD';
		req03.ProductCode = prod1.productcode;

		CreateorUpdateEntitlements.requestdata req04 = new CreateorUpdateEntitlements.requestdata();
		req04.EntitlementAsset = asst.Asset_Oracle_ID__c;
		req04.EntitlementAccountMasterID = acct.FCH_Party_ID__c;
		req04.EntitlementAccountName = 'Test';
		req04.EntitlementName = entList[0].Contract_Number__c;
		req04.EntitlementType = '';
		req04.EntitlementProductFamily = 'Test';
		req04.EntitlementStatus = 'Test';
		req04.EntitlementStartDate = '2013-04-17T19:09:27.000Z';
		req04.EntitlementEndDate = '2015-04-17T19:09:27.000Z';
		req04.AssetEffectivity = 'TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest';
		req04.AssetEffectivityStartdate = '2013-04-17T19:09:27.000Z';
		req04.AssetEffectivityEnddate = '2015-04-17T19:09:27.000Z';
		req04.AnnualCost = '100';
		req04.AssetSequence = entList[0].Asset_Sequence__c;
		req04.AnnualCostCurrency = 'USD';
		req04.ProductCode = prod.productcode;

		CreateorUpdateEntitlements.requestdata req05 = new CreateorUpdateEntitlements.requestdata();
		req05.EntitlementAsset = asst.Asset_Oracle_ID__c;
		req05.EntitlementAccountMasterID = acct.FCH_Party_ID__c;
		req05.EntitlementAccountName = 'Test';
		req05.EntitlementName = entList[0].Contract_Number__c;
		req05.EntitlementType = entList[0].Type;
		req05.EntitlementProductFamily = 'Test';
		req05.EntitlementStatus = 'Test';
		req05.EntitlementStartDate = '2013-04-17T19:09:27.000Z';
		req05.EntitlementEndDate = '2015-04-17T19:09:27.000Z';
		req05.AssetEffectivity = 'TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest';
		req05.AssetEffectivityStartdate = '2013-04-17T19:09:27.000Z';
		req05.AssetEffectivityEnddate = '2015-04-17T19:09:27.000Z';
		req05.AnnualCost = '100';
		req05.AssetSequence = entList[0].Asset_Sequence__c;
		req05.AnnualCostCurrency = 'USD';
		req05.ProductCode = '';

		CreateorUpdateEntitlements.requestdata req06 = new CreateorUpdateEntitlements.requestdata();
		req06.EntitlementAsset = asst.Asset_Oracle_ID__c;
		req06.EntitlementAccountMasterID = acct.FCH_Party_ID__c;
		req06.EntitlementAccountName = 'Test';
		req06.EntitlementName = entList[0].Contract_Number__c;
		req06.EntitlementType = entList[0].Type;
		req06.EntitlementProductFamily = 'Test';
		req06.EntitlementStatus = 'Test';
		req06.EntitlementStartDate = '2013-04-17T19:09:27.000Z';
		req06.EntitlementEndDate = '2015-04-17T19:09:27.000Z';
		req06.AssetEffectivity = 'TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest';
		req06.AssetEffectivityStartdate = '2013-04-17T19:09:27.000Z';
		req06.AssetEffectivityEnddate = '2015-04-17T19:09:27.000Z';
		req06.AnnualCost = '100';
		req06.AssetSequence = '';
		req06.AnnualCostCurrency = 'USD';
		req06.ProductCode = prod1.productcode;

		CreateorUpdateEntitlements.requestdata req07 = new CreateorUpdateEntitlements.requestdata();
		req07.EntitlementAsset = asst.Asset_Oracle_ID__c;
		req07.EntitlementAccountMasterID = '';
		req07.EntitlementAccountName = 'Test';
		req07.EntitlementName = entList[0].Contract_Number__c;
		req07.EntitlementType = entList[0].Type;
		req07.EntitlementProductFamily = 'Test';
		req07.EntitlementStatus = 'Test';
		req07.EntitlementStartDate = '2013-04-17T19:09:27.000Z';
		req07.EntitlementEndDate = '2015-04-17T19:09:27.000Z';
		req07.AssetEffectivity = 'TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest';
		req07.AssetEffectivityStartdate = '2013-04-17T19:09:27.000Z';
		req07.AssetEffectivityEnddate = '2015-04-17T19:09:27.000Z';
		req07.AnnualCost = '100';
		req07.AssetSequence = entList[0].Asset_Sequence__c;
		req07.AnnualCostCurrency = 'USD';
		req07.ProductCode = prod1.productcode;

		reqServ00.add(req00);
		reqServ01.add(req01);
		reqServ02.add(req02);
		reqServ03.add(req03);
		reqServ04.add(req04);
		reqServ05.add(req05);
		reqServ06.add(req06);
		reqServ07.add(req07);

	}

	private static testmethod void testCreatePriceListService00() {

		setUpData();
		Test.startTest();
		List<CreateorUpdateEntitlements.ResponseWraperClass> resList = CreateorUpdateEntitlements.CreateServiceLine(reqServ00);

		Test.stopTest();
	}
	private static testmethod void testCreatePriceListService01() {

		setUpData();
		Test.startTest();
		List<CreateorUpdateEntitlements.ResponseWraperClass> resList = CreateorUpdateEntitlements.CreateServiceLine(reqServ01);

		Test.stopTest();
	}
	private static testmethod void testCreatePriceListService02() {

		setUpData();
		Test.startTest();
		List<CreateorUpdateEntitlements.ResponseWraperClass> resList = CreateorUpdateEntitlements.CreateServiceLine(reqServ02);

		Test.stopTest();
	}
	private static testmethod void testCreatePriceListService03() {

		setUpData();
		Test.startTest();
		List<CreateorUpdateEntitlements.ResponseWraperClass> resList = CreateorUpdateEntitlements.CreateServiceLine(reqServ03);

		Test.stopTest();
	}
	private static testmethod void testCreatePriceListService04() {

		setUpData();
		Test.startTest();
		List<CreateorUpdateEntitlements.ResponseWraperClass> resList = CreateorUpdateEntitlements.CreateServiceLine(reqServ04);

		Test.stopTest();
	}
	private static testmethod void testCreatePriceListService05() {

		setUpData();
		Test.startTest();
		List<CreateorUpdateEntitlements.ResponseWraperClass> resList = CreateorUpdateEntitlements.CreateServiceLine(reqServ05);

		Test.stopTest();
	}
	private static testmethod void testCreatePriceListService06() {

		setUpData();
		Test.startTest();
		List<CreateorUpdateEntitlements.ResponseWraperClass> resList = CreateorUpdateEntitlements.CreateServiceLine(reqServ06);

		Test.stopTest();
	}
	private static testmethod void testCreatePriceListService07() {

		setUpData();
		Test.startTest();
		List<CreateorUpdateEntitlements.ResponseWraperClass> resList = CreateorUpdateEntitlements.CreateServiceLine(reqServ07);

		Test.stopTest();
	}


}