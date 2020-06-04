/*
 * ****************************************************************************************
  Name        : TestSetpricebookdefault
  ---------------------------------------------------------------------------
  Developer              Date            Description
  ---------------------------------------------------------------------------
  Suresh Babu          09/03/2016          Created
 *
 *****************************************************************************************/
@istest(SeeAllData = True)
private class TestSetpricebookdefault {
	static testmethod void pTest1() {
		User MEPUser = [SELECT Id FROM User where Profile.Name like '%MEP%' AND isactive = true LIMIT 1];
		Id pricebookId = Test.getStandardPricebookId();
		Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
		Account acct = new Account(Name = 'Test Assign Case Account', RecordTypeId = acctRecTypeId, CurrencyIsoCode = 'USD', Payment_Term__c = 'CASH IN ADVANCE', Account_Status__c = 'Pending', Requested_Account_Record_Type__c = 'Customer',
		                           BillingCountry = 'Switzerland', Restricted_Entity__c = Label.Not_Restricted, Annual_Support_Date__c = date.today(), BillingCity = 'San Francisco', BillingState = 'California', BillingPostalCode = '94109', BillingStreet = '3250 VAN NESS AVE', Collector_Email__c = 'test@gmail.com');
		Account acct1 = new Account(Name = 'Test Assign Case Account', RecordTypeId = acctRecTypeId, CurrencyIsoCode = 'USD', Payment_Term__c = 'CASH IN ADVANCE', Account_Status__c = 'Pending', Requested_Account_Record_Type__c = 'Customer',
		                            BillingCountry = 'United States', Restricted_Entity__c = Label.Not_Restricted, Annual_Support_Date__c = date.today(), BillingCity = 'San Francisco', BillingState = 'California', BillingPostalCode = '94109', BillingStreet = '3250 VAN NESS AVE', Collector_Email__c = 'test@gmail.com');
		List<Account> aList = new List<Account> ();
		aList.add(acct); aList.add(acct1);
		insert aList;

		List<Contact> cList = new List<Contact> ();
		Contact ct = new Contact();
		ct.LastName = 'Test last name';
		ct.AccountId = acct.Id;
		ct.Preferred_Language__c = 'American English';
		ct.Email = 'test@gmail.com';
		ct.MailingCountry = 'Switzerland';
		cList.add(ct);

		Contact ct1 = new Contact();
		ct1.LastName = 'Test last name';
		ct1.AccountId = acct1.Id;
		ct1.Preferred_Language__c = 'American English';
		ct1.Email = 'test@gmail.com';
		ct1.MailingCountry = 'United States';
		cList.add(ct1);
		insert cList;

		List<Address__c> adList = new List<Address__c> ();
		Address__c adrs = new Address__c(Name = 'Test Address', Validation_Status__c = 'Corrected', FCH_Party_Site_Id__c = '222222', Account__c = acct.Id, Country__c = 'Switzerland', Bill_To__c = true, Ship_To__c = true, Address_Line1__c = '3250 VAN NESS AVE', City__c = 'San Francisco', State__c = 'California', Zip__c = '94109');
		Address__c adrs1 = new Address__c(Name = 'Test Address', Validation_Status__c = 'Corrected', FCH_Party_Site_Id__c = '222222', Account__c = acct1.Id, Country__c = 'United States', Bill_To__c = true, Ship_To__c = true, Address_Line1__c = '3250 VAN NESS AVE', City__c = 'San Francisco', State__c = 'California', Zip__c = '94109');
		adList.add(adrs);
		adList.add(adrs1);
		insert adList;

		List<Apttus_Config2__PriceList__c> pList = new List<Apttus_Config2__PriceList__c> ();
		Apttus_Config2__PriceList__c pricelist1 = new Apttus_Config2__PriceList__c();
		pricelist1.Apttus_Config2__Active__c = true;
		pricelist1.Name = 'TIBV CH Test';
		pricelist1.Legal_Entity__c = 'TIBV SWISS BRANCH';
		pricelist1.Business_Area__c = 'MANHATTAN SOFTWARE';
		pricelist1.Division__c = 'Plancal';
		pList.add(pricelist1);

		Apttus_Config2__PriceList__c pricelist2 = new Apttus_Config2__PriceList__c();
		pricelist2.Apttus_Config2__Active__c = true;
		pricelist2.Name = 'MANHATTAN Test';
		pricelist2.Business_Area__c = 'MANHATTAN SOFTWARE';
		pricelist2.Division__c = 'RE&WS';
		pList.add(pricelist2);

		Apttus_Config2__PriceList__c pricelist3 = new Apttus_Config2__PriceList__c();
		pricelist3.Apttus_Config2__Active__c = true;
		pricelist3.Name = 'GCCM Test';
		pricelist3.Business_Area__c = 'CONTRACTOR PROJECT SOFTWARE';
		pricelist3.Division__c = 'GCCM';
		pList.add(pricelist3);

		Apttus_Config2__PriceList__c pricelist4 = new Apttus_Config2__PriceList__c();
		pricelist4.Apttus_Config2__Active__c = true;
		pricelist4.Name = 'MEPNA Test';
		pricelist4.Business_Area__c = 'CONTRACTOR PROJECT SOFTWARE';
		pricelist4.Division__c = 'MEP NA';
		pList.add(pricelist4);

		insert pList;

		system.runAs(MEPUser) {
			Opportunity opp1 = new Opportunity();
			opp1.AccountId = acct.Id;
			opp1.StageName = 'Inquery';
			opp1.Closedate = date.today() + 7;
			opp1.Name = 'Opp1';
			opp1.Ship_To_Account__c = acct.ID;
			opp1.Payment_Term__c = 'CASH IN ADVANCE';
			opp1.OwnerId = UserInfo.getUserId();
			opp1.Bill_To_Account__c = acct.Id;
			opp1.Ship_To_Account__c = acct.Id;
			opp1.Bill_To_Contact__c = ct.Id;
			opp1.Primary_Contact__c = ct.Id;
			opp1.Bill_to_Address__c = adrs.Id;
			opp1.Ship_to_Address1__c = adrs.Id;
			opp1.Price_List__c = pricelist1.Id;
			insert opp1;
			
            RecursiveTriggerUtility.isSetPriceBookDefaultTriggerRecursive = false;
			Opportunity opp2 = new Opportunity();
			opp2.AccountId = acct.Id;
			opp2.StageName = 'Inquery';
			opp2.Closedate = date.today() + 7;
			opp2.Name = 'opp2';
			opp2.Ship_To_Account__c = acct.ID;
			opp2.Payment_Term__c = 'CASH IN ADVANCE';
			opp2.OwnerId = UserInfo.getUserId();
			opp2.Bill_To_Account__c = acct.Id;
			opp2.Ship_To_Account__c = acct.Id;
			opp2.Bill_To_Contact__c = ct.Id;
			opp2.Primary_Contact__c = ct.Id;
			opp2.Bill_to_Address__c = adrs.Id;
			opp2.Ship_to_Address1__c = adrs.Id;
			opp2.Selling_Division__c = 'Lifting Solutions';
			insert opp2;
            
            RecursiveTriggerUtility.isSetPriceBookDefaultTriggerRecursive = false;
			opp1.Payment_Term__c = 'N10';
			opp1.Trigger_Approval__c = true;
			update opp1;
            
            RecursiveTriggerUtility.isSetPriceBookDefaultTriggerRecursive = false;
			opp1.Payment_Term__c = 'N10';
			opp1.Trigger_Approval__c = true;
			opp2.Selling_Division__c = 'MEP NA';
			opp2.Opportunity_Product__c = 'CrewSight';
			opp2.Price_List__c = pricelist4.Id;
			update opp1;
		}
	}

	static testmethod void pTest2() {
		User GCCMUser = [SELECT Id FROM User where Profile.Name like 'Sales Ops - GCCM%' AND isactive = true LIMIT 1];
		Id pricebookId = Test.getStandardPricebookId();
		Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
		Account acct = new Account(Name = 'Test Assign Case Account', RecordTypeId = acctRecTypeId, CurrencyIsoCode = 'USD', Payment_Term__c = 'CASH IN ADVANCE', Account_Status__c = 'Pending', Requested_Account_Record_Type__c = 'Customer',
		                           BillingCountry = 'Switzerland', Restricted_Entity__c = Label.Not_Restricted, Annual_Support_Date__c = date.today(), BillingCity = 'San Francisco', BillingState = 'California', BillingPostalCode = '94109', BillingStreet = '3250 VAN NESS AVE', Collector_Email__c = 'test@gmail.com');
		Account acct1 = new Account(Name = 'Test Assign Case Account', RecordTypeId = acctRecTypeId, CurrencyIsoCode = 'USD', Payment_Term__c = 'CASH IN ADVANCE', Account_Status__c = 'Pending', Requested_Account_Record_Type__c = 'Customer',
		                            BillingCountry = 'United States', Restricted_Entity__c = Label.Not_Restricted, Annual_Support_Date__c = date.today(), BillingCity = 'San Francisco', BillingState = 'California', BillingPostalCode = '94109', BillingStreet = '3250 VAN NESS AVE', Collector_Email__c = 'test@gmail.com');
		List<Account> aList = new List<Account> ();
		aList.add(acct); aList.add(acct1);
		insert aList;

		List<Contact> cList = new List<Contact> ();
		Contact ct = new Contact();
		ct.LastName = 'Test last name';
		ct.AccountId = acct.Id;
		ct.Preferred_Language__c = 'American English';
		ct.Email = 'test@gmail.com';
		ct.MailingCountry = 'Switzerland';
		cList.add(ct);

		Contact ct1 = new Contact();
		ct1.LastName = 'Test last name';
		ct1.AccountId = acct1.Id;
		ct1.Preferred_Language__c = 'American English';
		ct1.Email = 'test@gmail.com';
		ct1.MailingCountry = 'United States';
		cList.add(ct1);
		insert cList;

		List<Address__c> adList = new List<Address__c> ();
		Address__c adrs = new Address__c(Name = 'Test Address', Validation_Status__c = 'Corrected', FCH_Party_Site_Id__c = '222222', Account__c = acct.Id, Country__c = 'Switzerland', Bill_To__c = true, Ship_To__c = true, Address_Line1__c = '3250 VAN NESS AVE', City__c = 'San Francisco', State__c = 'California', Zip__c = '94109');
		Address__c adrs1 = new Address__c(Name = 'Test Address', Validation_Status__c = 'Corrected', FCH_Party_Site_Id__c = '222222', Account__c = acct1.Id, Country__c = 'United States', Bill_To__c = true, Ship_To__c = true, Address_Line1__c = '3250 VAN NESS AVE', City__c = 'San Francisco', State__c = 'California', Zip__c = '94109');
		adList.add(adrs);
		adList.add(adrs1);
		insert adList;

		List<Apttus_Config2__PriceList__c> pList = new List<Apttus_Config2__PriceList__c> ();
		Apttus_Config2__PriceList__c pricelist1 = new Apttus_Config2__PriceList__c();
		pricelist1.Apttus_Config2__Active__c = true;
		pricelist1.Name = 'TIBV CH Test';
		pricelist1.Legal_Entity__c = 'TIBV SWISS BRANCH';
		pricelist1.Business_Area__c = 'MANHATTAN SOFTWARE';
		pricelist1.Division__c = 'Plancal';
		pList.add(pricelist1);

		Apttus_Config2__PriceList__c pricelist2 = new Apttus_Config2__PriceList__c();
		pricelist2.Apttus_Config2__Active__c = true;
		pricelist2.Name = 'MANHATTAN Test';
		pricelist2.Business_Area__c = 'MANHATTAN SOFTWARE';
		pricelist2.Division__c = 'RE&WS';
		pList.add(pricelist2);

		Apttus_Config2__PriceList__c pricelist3 = new Apttus_Config2__PriceList__c();
		pricelist3.Apttus_Config2__Active__c = true;
		pricelist3.Name = 'GCCM Test';
		pricelist3.Business_Area__c = 'CONTRACTOR PROJECT SOFTWARE';
		pricelist3.Division__c = 'GCCM';
		pList.add(pricelist3);

		Apttus_Config2__PriceList__c pricelist4 = new Apttus_Config2__PriceList__c();
		pricelist4.Apttus_Config2__Active__c = true;
		pricelist4.Name = 'MEPNA Test';
		pricelist4.Business_Area__c = 'CONTRACTOR PROJECT SOFTWARE';
		pricelist4.Division__c = 'MEP NA';
		pList.add(pricelist4);

		insert pList;

		system.runAs(GCCMUser) {
			List<Opportunity> opList = new List<Opportunity> ();
			Opportunity opp2 = new Opportunity();
			opp2.AccountId = acct1.Id;
			opp2.StageName = 'Inquery';
			opp2.Closedate = date.today() + 7;
			opp2.Name = 'Opp2';
			opp2.Ship_To_Account__c = acct1.ID;
			opp2.Payment_Term__c = 'CASH IN ADVANCE';
			opp2.OwnerId = UserInfo.getUserId();
			opp2.Bill_To_Account__c = acct1.Id;
			opp2.Ship_To_Account__c = acct1.Id;
			opp2.Bill_To_Contact__c = ct1.Id;
			opp2.Primary_Contact__c = ct1.Id;
			opp2.Bill_to_Address__c = adrs1.Id;
			opp2.Ship_to_Address1__c = adrs1.Id;
			opp2.Price_List__c = pricelist2.Id;

			Opportunity opp3 = new Opportunity();
			opp3.AccountId = acct1.Id;
			opp3.StageName = 'Inquery';
			opp3.Closedate = date.today() + 7;
			opp3.Name = 'Opp3';
			opp3.Ship_To_Account__c = acct1.ID;
			opp3.Payment_Term__c = 'CASH IN ADVANCE';
			opp3.OwnerId = UserInfo.getUserId();
			opp3.Bill_To_Account__c = acct1.Id;
			opp3.Ship_To_Account__c = acct1.Id;
			opp3.Bill_To_Contact__c = ct1.Id;
			opp3.Primary_Contact__c = ct1.Id;
			opp3.Bill_to_Address__c = adrs1.Id;
			opp3.Ship_to_Address1__c = adrs1.Id;
			opp3.Price_List__c = pricelist3.Id;

			Opportunity opp4 = new Opportunity();
			opp4.AccountId = acct1.Id;
			opp4.StageName = 'Inquery';
			opp4.Closedate = date.today() + 7;
			opp4.Name = 'opp4';
			opp4.Ship_To_Account__c = acct1.ID;
			opp4.Payment_Term__c = 'CASH IN ADVANCE';
			opp4.OwnerId = UserInfo.getUserId();
			opp4.Bill_To_Account__c = acct1.Id;
			opp4.Ship_To_Account__c = acct1.Id;
			opp4.Bill_To_Contact__c = ct1.Id;
			opp4.Primary_Contact__c = ct1.Id;
			opp4.Bill_to_Address__c = adrs1.Id;
			opp4.Ship_to_Address1__c = adrs1.Id;
			opp4.Price_List__c = pricelist4.Id;
			opp4.Opportunity_Product__c = 'CrewSight';

			opList.add(opp2);
			opList.add(opp3);
			opList.add(opp4);
			insert opList;
			
            RecursiveTriggerUtility.isSetPriceBookDefaultTriggerRecursive = false;
			opp2.Payment_Term__c = 'N10';
			opp2.Trigger_Approval__c = true;
			opp2.Price_List__c = pricelist3.Id;
			update opp2;
            
            RecursiveTriggerUtility.isSetPriceBookDefaultTriggerRecursive = false;
			opp3.Payment_Term__c = 'N10';
			opp3.Trigger_Approval__c = true;
			opp3.Price_List__c = pricelist2.Id;
			update opp3;
            
            RecursiveTriggerUtility.isSetPriceBookDefaultTriggerRecursive = false;
			opp3.Payment_Term__c = 'N10';
			opp3.Trigger_Approval__c = true;
			opp3.Price_List__c = pricelist4.Id;
			update opp3;
		}
	}
}