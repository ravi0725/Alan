@isTest(seealldata = true)
public class AccountViewEnhancementSummaryCtrlTest {
	private static Country_Region_Mapping__c cust;
	private Double AccountCurrency;
	private static Geospatial_Country_Region_Mapping__c custRegMap;
	private static Account acct;
	private static User thisUser;
	private static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();

	public static TestMethod void AccountView_v1() {

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
		//Insert Product    
		Product2 pro = new Product2();
		pro.name = 'SWART MWin Software-Update-Vertrag Vollvers. 1. licence';
		pro.ProductCode = '4211131';
		pro.Oracle_ID__c = '1233516';
		Pro.Status__c = 'Active';
		Pro.CurrencyIsoCode = 'USD';
		pro.sub_type__c = 'Hardware';
		Pro.IsActive = True;
		Pro.Product_Group__c = 'Services';
		insert pro;

		//Enter Asset details
		Asset ass = new Asset();
		ass.name = 'Test';
		ass.Product2id = pro.id;
		ass.Accountid = acct.id;
		insert ass;

		// Enter Entitlement Details
		Entitlement ent = new Entitlement();
		ent.Accountid = acct.id;
		ent.Name = 'Test';
		//ent.supported_Product_Family_Roll_up__c='Hardware';
		ent.Annual_Cost__c = 230;
		ent.CurrencyIsoCode = 'USD';
		ent.Asset_Effectivity__c = 'Active';
		ent.Entitlement_Product__c = pro.id;
		ent.Assetid = ass.id;
		insert ent;

		//Currency data 
		CurrencyType CurrType = [SELECT IsoCode, ConversionRate FROM CurrencyType where IsoCode = 'USD'];

		AccountViewEnhancementSummaryCtrl controller = new AccountViewEnhancementSummaryCtrl(new ApexPages.StandardController(acct));
		controller.getCorporateCurrencyValue(ent.CurrencyIsoCode, ent.Annual_Cost__c);
		AccountViewEnhancementSummaryCtrl.SummaryWrapper wrap = new AccountViewEnhancementSummaryCtrl.SummaryWrapper('USD');
		controller.getTargetCurrencyValue(acct.CurrencyIsoCode, ent.CurrencyIsoCode, ent.Annual_Cost__c);
		Test.stopTest();
	}

	public static TestMethod void AccountView_v2() {

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
		//Insert Product    
		Product2 pro = new Product2();
		pro.name = 'SWART MWin Software-Update-Vertrag Vollvers. 1. licence';
		pro.ProductCode = '4211131';
		pro.Oracle_ID__c = '1233516';
		Pro.Status__c = 'Active';
		Pro.CurrencyIsoCode = 'USD';
		pro.sub_type__c = 'Software';
		Pro.IsActive = True;
		Pro.Product_Group__c = 'Services';
		insert pro;

		//Enter Asset details
		Asset ass = new Asset();
		ass.name = 'Test';
		ass.Product2id = pro.id;
		ass.Accountid = acct.id;
		insert ass;

		// Enter Entitlement Details
		List<Entitlement> lstEnts = new List<Entitlement> ();
		Entitlement ent = new Entitlement();
		ent.Accountid = acct.id;
		ent.Name = 'Test';
		//ent.supported_Product_Family_Roll_up__c='Hardware';
		ent.Annual_Cost__c = 230;
		ent.CurrencyIsoCode = 'USD';
		ent.Asset_Effectivity__c = 'Active';
		ent.Entitlement_Product__c = pro.id;
		ent.Assetid = ass.id;
		ent.StartDate = System.today();
		ent.EndDate = System.today().addYears(1);
		lstEnts.add(ent);

		Entitlement ent1 = new Entitlement();
		ent1.Accountid = acct.id;
		ent1.Name = 'Test';
		ent1.Annual_Cost__c = 230;
		ent1.CurrencyIsoCode = 'USD';
		ent1.Asset_Effectivity__c = 'Active';
		ent1.Entitlement_Product__c = pro.id;
		ent1.Assetid = ass.id;
		ent1.StartDate = System.today();
		ent1.EndDate = System.today().addMonths(10);
		lstEnts.add(ent1);

		insert lstEnts;

		//Currency data 
		CurrencyType CurrType = [SELECT IsoCode, ConversionRate FROM CurrencyType where IsoCode = 'USD'];

		AccountViewEnhancementSummaryCtrl controller = new AccountViewEnhancementSummaryCtrl(new ApexPages.StandardController(acct));
		controller.getCorporateCurrencyValue(ent.CurrencyIsoCode, ent.Annual_Cost__c);
		AccountViewEnhancementSummaryCtrl.SummaryWrapper wrap = new AccountViewEnhancementSummaryCtrl.SummaryWrapper('USD');
		controller.getTargetCurrencyValue(acct.CurrencyIsoCode, ent.CurrencyIsoCode, ent.Annual_Cost__c);
		Test.stopTest();
	}
}