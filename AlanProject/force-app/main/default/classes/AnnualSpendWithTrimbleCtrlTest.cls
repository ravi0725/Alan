/*
 ****************************************************************************************
  Name        : AnnualSpendWithTrimbleCtrlTest
  ---------------------------------------------------------------------------
  Developer              Date            Description
  ---------------------------------------------------------------------------
  Suresh Babu         20/NOV/2019          Created
 *****************************************************************************************/
@isTest(seealldata = true)
private class AnnualSpendWithTrimbleCtrlTest {
	private static Country_Region_Mapping__c cust;
	private Double AccountCurrency;
	private static Geospatial_Country_Region_Mapping__c custRegMap;
	private static Account acct;
	private static User thisUser;
	private static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();

	public static TestMethod void AccountView_v1() {
		Id pricebookId = Test.getStandardPricebookId();

		// Enter User Details
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		User u = new User(Alias = 'standt', Email = 'standarduser@testorg.com',
		                  EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
		                  LocaleSidKey = 'en_US', ProfileId = p.Id, DefaultCurrencyIsoCode = 'USD', CurrencyIsoCode = 'USD',
		                  TimeZoneSidKey = 'America/Los_Angeles', UserName = 'DevTestUser@testorg.com');
		insert u;
		//Enter Account Details
		Test.startTest();
		acct = new Account(Name = 'Test Assign Case Account', RecordTypeId = acctRecTypeId, CurrencyIsoCode = 'USD', EBS_Payment_Term__c = 'CASH IN ADVANCE', Payment_Term__c = 'CASH IN ADVANCE', Account_Status__c = 'Pending', Requested_Account_Record_Type__c = 'Customer',
		                   FCH_Party_ID__c = '111111', Enterprise_Party_Number__c = '12345', Shipping_Method__c = 'N/A', Payment_Method__c = 'Credit Card', Freight_Term__c = 'UPS2-Air-Air Express Plus', BillingCountry = 'India', Restricted_Entity__c = Label.Not_Restricted, Annual_Support_Date__c = date.today(), BillingCity = 'Pune', BillingState = 'Maharashtra', BillingPostalCode = '600091', BillingStreet = 'A-202', Collector_Email__c = 'test@gmail.com');
		insert acct;

		//Insert Contact
		Contact ct = new Contact();
		ct.LastName = 'Test last name';
		ct.AccountId = acct.Id;
		ct.Preferred_Language__c = 'American English';
		ct.Email = 'test@gmail.com';
		ct.MailingStreet = 'test1';
		ct.Mailingcity = 'testcity';
		ct.MailingState = 'California';
		ct.MailingPostalCode = '12345';
		ct.MailingCountry = 'United States';
		insert ct;

		//Insert Address
		Address__c adrs1;
		adrs1 = new Address__c(Name = 'Test Address', validation_Status__c = 'Corrected', FCH_Party_Site_Id__c = '222222', Account__c = acct.Id, Country__c = 'United States', Bill_To__c = true, Ship_To__c = true, Address_Line1__c = 'addrs4', Address_Line2__c = 'addrs4', Address_Line3__c = 'addrs4', Address_Line4__c = 'addrs4', City__c = 'city', State__c = 'California', Zip__c = 'zip');
		insert adrs1;

		//Insert Pricelist
		Apttus_Config2__PriceList__c pricelist = new Apttus_Config2__PriceList__c();
		pricelist.Apttus_Config2__Active__c = true;
		pricelist.Name = 'TIBV CH Test';
		pricelist.Legal_Entity__c = 'TIBV SWISS BRANCH';
		pricelist.Business_Area__c = 'MANHATTAN SOFTWARE';
		insert pricelist;

		//Insert Product
		Product2 pro = new Product2();
		pro.name = 'SWART MWin Software-Update-Vertrag Vollvers. 1. licence';
		pro.ProductCode = '4211131';
		pro.Oracle_ID__c = '1233516';
		pro.Status__c = 'Active';
		pro.CurrencyIsoCode = 'USD';
		pro.sub_type__c = 'Hardware';
		pro.IsActive = True;
		pro.Product_Group__c = 'Services';
		pro.Business_Area__c = 'Plancal';
		insert pro;

		Opportunity opp = new Opportunity();
		opp.AccountId = acct.Id;
		opp.StageName = 'Inquiry';
		opp.Closedate = date.today() + 7;
		opp.Name = 'Opp1';
		opp.Bill_To_Account__c = acct.Id;
		opp.Ship_To_Account__c = acct.id;
		opp.Bill_To_Contact__c = ct.Id;
		opp.Primary_Contact__c = ct.id;
		opp.Bill_to_Address__c = adrs1.id;
		opp.Ship_to_Address1__c = adrs1.id;
		opp.Payment_Term__c = 'CASH IN ADVANCE';
		opp.OwnerId = UserInfo.getUserId();
		opp.Selling_Division__c = 'MEP NA';
		opp.StageName = '6 - Closed Won';
		opp.CloseDate = System.today().addYears(- 1);
		insert opp;

		PriceBookEntry pbe = new PriceBookEntry();
		pbe.PriceBook2ID = pricebookId;
		pbe.Product2Id = pro.Id;
		pbe.UnitPrice = 1;
		pbe.IsActive = True;
		insert pbe;

		List<OpportunityLineItem> opLineList = new List<OpportunityLineItem> ();
		OpportunityLineItem oli = new OpportunityLineItem();
		oli.OpportunityId = opp.Id;
		oli.Quantity = 45;
		oli.UnitPrice = 456;
		oli.PricebookEntryId = pbe.Id;
		oli.Service_Start_Date__c = system.today();
		oli.Service_End_Date__c = system.today().addYears(1);
		oli.Include_ARR_Calculation__c = true;
		oli.Staging__c = '123456789';
		oli.Type__c = 'Renewal';
		opLineList.add(oli);

		OpportunityLineItem oli1 = new OpportunityLineItem();
		oli1.OpportunityId = opp.Id;
		oli1.Quantity = 75;
		oli1.UnitPrice = 756;
		oli1.PricebookEntryId = pbe.Id;
		oli1.Service_Start_Date__c = system.today();
		oli1.Service_End_Date__c = system.today().addYears(3);
		oli.Include_ARR_Calculation__c = true;
		opLineList.add(oli1);
		insert opLineList;

		AnnualSpendWithTrimbleCtrl controller = new AnnualSpendWithTrimbleCtrl(new ApexPages.StandardController(acct));
		controller.getCorporateCurrencyValue(oli.CurrencyIsoCode, oli.TotalPrice);
		controller.getMapIsEmpty();
		AnnualSpendWithTrimbleCtrl.SummaryWrapper wrap = new AnnualSpendWithTrimbleCtrl.SummaryWrapper('USD');
		Test.stopTest();
	}
}