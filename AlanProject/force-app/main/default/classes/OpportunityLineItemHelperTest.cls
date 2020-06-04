/*
 * ****************************************************************************************
  Name        : OpportunityLineItemHelperTest
  ---------------------------------------------------------------------------
  Developer              Date            Description
  ---------------------------------------------------------------------------
  Suresh Babu         04/03/2019          Created
 *
 *****************************************************************************************/
@istest(seealldata = true)
private class OpportunityLineItemHelperTest {
	static testmethod void meth1() {
		User u = [SELECT Id, Profile.Name FROM User where Profile.Name like 'Sales Ops - MEP - Europe' AND isactive = true LIMIT 1];
		Id pricebookId = Test.getStandardPricebookId();
		Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
		Account acct = new Account(Name = 'Test Assign Case Account', RecordTypeId = acctRecTypeId, CurrencyIsoCode = 'USD', Payment_Term__c = 'CASH IN ADVANCE', Account_Status__c = 'Pending', Requested_Account_Record_Type__c = 'Customer',
		                           BillingCountry = 'United States', EBS_Payment_Term__c = '30 NET', Restricted_Entity__c = Label.Not_Restricted, Annual_Support_Date__c = date.today(), BillingCity = 'Pune', BillingState = 'California', BillingPostalCode = 'postal code', BillingStreet = 'A-202', Collector_Email__c = 'test@gmail.com');
		insert acct;

		contact ct = new contact();
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

		Address__c adrs1;
		adrs1 = new Address__c(Name = 'Test Address', validation_Status__c = 'Corrected', FCH_Party_Site_Id__c = '222222', Account__c = acct.Id, Country__c = 'United States', Bill_To__c = true, Ship_To__c = true, Address_Line1__c = 'addrs4', Address_Line2__c = 'addrs4', Address_Line3__c = 'addrs4', Address_Line4__c = 'addrs4', City__c = 'city', State__c = 'California', Zip__c = 'zip');
		insert adrs1;

		Apttus_Config2__PriceList__c pricelist = new Apttus_Config2__PriceList__c();

		pricelist.Apttus_Config2__Active__c = true;
		pricelist.Name = 'TIBV CH Test';
		pricelist.Legal_Entity__c = 'TIBV SWISS BRANCH';
		pricelist.Business_Area__c = 'MANHATTAN SOFTWARE';
		insert pricelist;
		system.runAs(u) {


			List<Opportunity> opList = new List<Opportunity> ();
			List<OpportunityLineItem> opLineList = new List<OpportunityLineItem> ();
			Map<Id, Opportunity> opMap = new Map<Id, Opportunity> ();
			/*
			  Opportunity opp1 = new Opportunity();
			  opp1.AccountId = acct.Id;
			  opp1.StageName = 'Inquery';
			  opp1.Closedate = date.today() + 7;
			  opp1.Name = 'Opp1';
			  opp1.Ship_To_Account__c = acct.ID;
			  opp1.Payment_Term__c = 'CASH IN ADVANCE';
			  opp1.OwnerId = UserInfo.getUserId();
			  opp1.Bill_To_Account__c = acct.Id;
			  opp1.Ship_To_Account__c = acct.id;
			  opp1.Bill_To_Contact__c = ct.Id;
			  opp1.Primary_Contact__c =ct.id;
			  opp1.Bill_to_Address__c = adrs1.id;
			  opp1.Ship_to_Address1__c = adrs1.id;
			  //opp1.Payment_Term_Approval_Status__c = 'Approved';        
			  insert opp1;
			  opList.add(opp1);    
			  opp1.Payment_Term__c = 'N10'; 
			  opp1.Trigger_Approval__c = true;    
			  opp1.CloseDate = date.today() +15;
			  //update opp1;        
			  opMap.put(opp1.Id,opp1);
			 */
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
			insert opp;
			opMap.put(opp.Id, opp);
			opList.add(opp);
			Product2 prd = new Product2();
			prd.Name = 'test';
			prd.isActive = true;
			prd.ProductCode = 'Test123';
			prd.Product_Category_Type__c = 'Software';
			prd.Type__c = 'CAD SOFTWARE';
			insert prd;

			Opportunity o = [SELECT Pricebook2Id FROM Opportunity WHERE Id = :opp.Id];

			PriceBookEntry pbe = new PriceBookEntry();
			pbe.PriceBook2ID = pricebookId;
			pbe.Product2Id = prd.Id;
			pbe.UnitPrice = 1;
			pbe.IsActive = True;
			insert pbe;

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
			oli1.Include_ARR_Calculation__c = true;
			opLineList.add(oli1);
			insert opLineList;
			/*
			  Address__c adrs = new Address__c(Name = 'Test Address',Validation_Status__c='Corrected',Account__c = acct.Id, Country__c = 'UNITED STATES',Bill_To__c = true,Ship_To__c=true,Address_Line1__c = 'addrs4',Address_Line2__c = 'addrs4',Address_Line3__c = 'addrs4',Address_Line4__c = 'addrs4',City__c = 'city',State__c = 'California',Zip__c = 'zip');
			  insert adrs;
			 
			  Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c();
			  proposal.Apttus_Proposal__Account__c = acct.Id;
			  proposal.Apttus_Proposal__Opportunity__c =opp1.Id;
			  proposal.Apttus_QPConfig__PriceListId__c = pricelist.Id;
			  proposal.Ship_To_Account__c = acct.Id;
			  proposal.Bill_to_Address__c  = adrs.Id;
			  proposal.Ship_to_Address1__c = adrs.Id;
			  proposal.Apttus_QPConfig__BillToAccountId__c =acct.Id;
			  proposal.OwnerId = UserInfo.getUserId();
			  proposal.Apttus_Proposal__Primary__c = true;
			  proposal.Can_Validate__c = false;
			  //insert proposal;            
			 
			  OpportunityHelper op = new OpportunityHelper();
			  OpportunityHelper.OpportunityBeforeDeleteHandler(opList);       
			 */
			OpportunityLineItemHelper.resetLaunchControl();
			OpportunityLineItemHelper.populateSerialNumbersOnOpportunity(opLineList);
			OpportunityLineItemHelper.setLaunchControl();
		}
	}
}