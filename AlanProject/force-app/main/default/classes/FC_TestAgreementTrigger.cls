@isTest(SeeAllData = true)
public class FC_TestAgreementTrigger {
	static testMethod void testAgreementTrigger() {
		system.Test.startTest();
		GenerateTestData.createAccount();
		GenerateTestData.createAddress();
		GenerateTestData.createPriceList();
		GenerateTestData.createProduct2();
		GenerateTestData.prd.ICC_Type__c = 'Scheduled Publications';
		GenerateTestData.prd.Business_Area__c = 'TRADE SERVICE';
		update GenerateTestData.prd;
		GenerateTestData.createAsset();
		GenerateTestData.createOpportunity();
		GenerateTestData.createProposal();

		Apttus__APTS_Agreement__c APTSAGMT = new Apttus__APTS_Agreement__c();
		APTSAGMT.Fusion_Project_Number__c = 'test';
		APTSAGMT.Apttus__Contract_Start_Date__c = date.today();
		APTSAGMT.Apttus__Contract_End_Date__c = date.today() + 5;
		APTSAGMT.ProServ_Type__c = 'Fixed Fee';
		APTSAGMT.Credit_Status__c = 'test';
		APTSAGMT.Credit_Approved__c = 'test Credit_Approved__c';
		APTSAGMT.CREDIT_LIMIT_AVAILABLE__C = 10;
		APTSAGMT.CREDIT_EXISTING_EXPOSURE__C = 10;
		APTSAGMT.CREDIT_CALCULATED_EXPOSURE__c = 10;
		APTSAGMT.CREDIT_TOTAL_EXPOSURE__c = 10;
		APTSAGMT.Fusion_Project_Number__c = 'test Fusion_Project_Number__c';
		APTSAGMT.Apttus_QPComply__RelatedProposalId__c = GenerateTestData.proposal.Id;
		APTSAGMT.Apttus__Status_Category__c = 'In Signatures';
		APTSAGMT.Apttus__Status__c = 'Activated';
		APTSAGMT.Apttus_CMConfig__PriceListId__c = GenerateTestData.pricelist.Id;
		insert APTSAGMT;

		Apttus__AgreementLineItem__c aglt = new Apttus__AgreementLineItem__c();
		aglt.Apttus__AgreementId__c = APTSAGMT.Id;
		aglt.Apttus__NetPrice__c = 10;
		insert aglt;

		APTSAGMT.Apttus__Status_Category__c = 'In Effect';
		update APTSAGMT;
		system.Test.stopTest();
	}

	static testMethod void testAgreementTrigger2() {
		system.Test.startTest();
		GenerateTestData.createAccount();
		GenerateTestData.createAddress();
		GenerateTestData.createPriceList();
		GenerateTestData.createProduct2();
		GenerateTestData.prd.ICC_Type__c = 'Scheduled Publications';
		GenerateTestData.prd.Business_Area__c = 'TRADE SERVICE';
		update GenerateTestData.prd;
		GenerateTestData.createAsset();
		GenerateTestData.createOpportunity();
		GenerateTestData.createProposal();

		Apttus__APTS_Agreement__c APTSAGMT = new Apttus__APTS_Agreement__c();
		APTSAGMT.Fusion_Project_Number__c = 'test';
		APTSAGMT.Apttus__Contract_Start_Date__c = date.today();
		APTSAGMT.Apttus__Contract_End_Date__c = date.today() + 5;
		APTSAGMT.ProServ_Type__c = 'Fixed Fee';
		APTSAGMT.Credit_Status__c = 'test';
		APTSAGMT.Credit_Approved__c = 'test Credit_Approved__c';
		APTSAGMT.CREDIT_LIMIT_AVAILABLE__C = 10;
		APTSAGMT.CREDIT_EXISTING_EXPOSURE__C = 10;
		APTSAGMT.CREDIT_CALCULATED_EXPOSURE__c = 10;
		APTSAGMT.CREDIT_TOTAL_EXPOSURE__c = 10;
		APTSAGMT.Fusion_Project_Number__c = 'test Fusion_Project_Number__c';
		APTSAGMT.Apttus_QPComply__RelatedProposalId__c = GenerateTestData.proposal.Id;
		APTSAGMT.Apttus__Status_Category__c = 'In Signatures';
		APTSAGMT.Apttus__Status__c = 'Activated';
		APTSAGMT.Apttus_CMConfig__PriceListId__c = GenerateTestData.pricelist.Id;
		insert APTSAGMT;

		Apttus__AgreementLineItem__c aglt = new Apttus__AgreementLineItem__c();
		aglt.Apttus__AgreementId__c = APTSAGMT.Id;
		aglt.Apttus__NetPrice__c = 10;
		insert aglt;

		try {
			APTSAGMT.Apttus__Status_Category__c = 'In Effect';
			APTSAGMT.Includes_Professional_Services__c = TRUE;
			APTSAGMT.ProServ_Type__c = null;
			update APTSAGMT;
		}
		catch(Exception e) {
			Boolean expectedExceptionThrown = (e.getMessage().contains('If Professional Services = TRUE') ? true : false);
			System.AssertEquals(expectedExceptionThrown, true);
		}

		try {
			APTSAGMT.Apttus__Status_Category__c = 'In Effect';
			APTSAGMT.Includes_Professional_Services__c = TRUE;
			APTSAGMT.ProServ_Type__c = 'Fixed Fee';
			APTSAGMT.Apttus__Contract_Start_Date__c = null;
			update APTSAGMT;
		}
		catch(Exception e) {
			Boolean expectedExceptionThrown = (e.getMessage().contains('If Professional Services = TRUE') ? true : false);
			System.AssertEquals(expectedExceptionThrown, true);
		}

		try {
			APTSAGMT.Apttus__Status_Category__c = 'In Effect';
			APTSAGMT.Includes_Professional_Services__c = TRUE;
			APTSAGMT.ProServ_Type__c = 'Fixed Fee';
			APTSAGMT.Apttus__Contract_Start_Date__c = System.today();
			APTSAGMT.Apttus__Contract_End_Date__c = null;
			update APTSAGMT;
		}
		catch(Exception e) {
			Boolean expectedExceptionThrown = (e.getMessage().contains('If Professional Services = TRUE') ? true : false);
			System.AssertEquals(expectedExceptionThrown, true);
		}

		system.Test.stopTest();
	}

	static testMethod void testAgreementTrigger3() {
		system.Test.startTest();
		GenerateTestData.createAccount();

		GenerateTestData.acct.EBS_Legal_Entity__c = 'Trimble Inc.';
		update GenerateTestData.acct;

		GenerateTestData.createAddress();
		GenerateTestData.createPriceList();
		GenerateTestData.createProduct2();
		GenerateTestData.prd.ICC_Type__c = 'Scheduled Publications';
		GenerateTestData.prd.Business_Area__c = 'TRADE SERVICE';
		update GenerateTestData.prd;
		GenerateTestData.createAsset();
		GenerateTestData.createOpportunity();
		GenerateTestData.createProposal();

		Apttus__APTS_Agreement__c APTSAGMT = new Apttus__APTS_Agreement__c();
		APTSAGMT.Fusion_Project_Number__c = 'test';
		APTSAGMT.Apttus__Contract_Start_Date__c = date.today();
		APTSAGMT.Apttus__Contract_End_Date__c = date.today() + 5;
		APTSAGMT.ProServ_Type__c = 'Fixed Fee';
		APTSAGMT.Credit_Status__c = 'test';
		APTSAGMT.Credit_Approved__c = 'test Credit_Approved__c';
		APTSAGMT.CREDIT_LIMIT_AVAILABLE__C = 10;
		APTSAGMT.CREDIT_EXISTING_EXPOSURE__C = 10;
		APTSAGMT.CREDIT_CALCULATED_EXPOSURE__c = 10;
		APTSAGMT.CREDIT_TOTAL_EXPOSURE__c = 10;
		APTSAGMT.Fusion_Project_Number__c = 'test Fusion_Project_Number__c';
		APTSAGMT.Apttus_QPComply__RelatedProposalId__c = GenerateTestData.proposal.Id;
		APTSAGMT.Apttus__Status_Category__c = 'In Signatures';
		APTSAGMT.Apttus__Status__c = 'Activated';
		APTSAGMT.Apttus_CMConfig__PriceListId__c = GenerateTestData.pricelist.Id;
		insert APTSAGMT;

		Apttus__AgreementLineItem__c aglt = new Apttus__AgreementLineItem__c();
		aglt.Apttus__AgreementId__c = APTSAGMT.Id;
		aglt.Apttus__NetPrice__c = 10;
		insert aglt;

		APTSAGMT.Apttus__Status_Category__c = 'In Effect';
		update APTSAGMT;
		system.Test.stopTest();
	}
}