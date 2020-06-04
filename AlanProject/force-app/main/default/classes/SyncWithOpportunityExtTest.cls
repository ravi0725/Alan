/*
 ****************************************************************************************
  Name Controller        : SyncWithOpportunityExtTest 
  ---------------------------------------------------------------------------
  Developer              Date            Description
  ---------------------------------------------------------------------------
  P M Mamata           24/08/2015          Created
 *****************************************************************************************
*/

@isTest(seealldata = true)
private class SyncWithOpportunityExtTest {
	static testmethod void meth1() {
		GenerateTestData.createAccount();
		GenerateTestData.createAddress();
		GenerateTestData.createPriceList();
		GenerateTestData.createOpportunity();
		GenerateTestData.createProposal();
		GenerateTestData.createProduct2();

		GenerateTestData.CreateProposalLineItem();
		GenerateTestData.proposalLiTm.Apttus_QPConfig__NetAdjustmentPercent__c = 10;
		GenerateTestData.proposalLiTm.Include_ARR_Calculation__c = true;
		GenerateTestData.proposalLiTm.Service_Start_Date__c = System.today();
		GenerateTestData.proposalLiTm.Service_End_Date__c = System.today().addYears(1);
		update GenerateTestData.proposalLiTm;

		GenerateTestData.createPriceBookEntry();
		SyncWithOpportunityExt ext = new SyncWithOpportunityExt(new ApexPages.StandardController(GenerateTestData.proposal));
		ext.UpdateOppty();


		//Batch_Data_Fix_Object__c batchObj = new Batch_Data_Fix_Object__c(Record_ID__c = GenerateTestData.proposal.id);
		//insert batchObj;

		BatchDataFix bdf = new BatchDataFix();
		Id batchID = database.executebatch(bdf);
		//System.abortJob(batchID);
	}

	static testmethod void UpdateOpptyTestMeth() {
		GenerateTestData.createAccount();
		GenerateTestData.createAddress();
		GenerateTestData.createPriceList();
		GenerateTestData.createOpportunity();
		GenerateTestData.createProposal();
		GenerateTestData.createProduct2();
		GenerateTestData.CreateProposalLineItem();
		SyncWithOpportunityExt ext = new SyncWithOpportunityExt(new ApexPages.StandardController(GenerateTestData.proposal));

	}

	static testmethod void meth2() {
		GenerateTestData.createAccount();
		GenerateTestData.createAddress();
		GenerateTestData.createPriceList();
		GenerateTestData.createOpportunity();
		GenerateTestData.createProposal();
		GenerateTestData.createProduct2();

		GenerateTestData.CreateProposalLineItem();
		GenerateTestData.proposalLiTm.Apttus_QPConfig__NetAdjustmentPercent__c = 10;
		GenerateTestData.proposalLiTm.Include_ARR_Calculation__c = true;
		GenerateTestData.proposalLiTm.Service_Start_Date__c = System.today();
		GenerateTestData.proposalLiTm.Service_End_Date__c = System.today().addYears(1);
		update GenerateTestData.proposalLiTm;

		GenerateTestData.createPriceBookEntry();
		SyncWithOpportunityExt ext = new SyncWithOpportunityExt(new ApexPages.StandardController(GenerateTestData.proposal));
		ext.UpdateOppty();

		BatchRenewalOppDataFix bdf = new BatchRenewalOppDataFix();
		Id batchID = database.executebatch(bdf);
	}
}