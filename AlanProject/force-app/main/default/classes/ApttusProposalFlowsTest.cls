@isTest(seealldata = true)
private class ApttusProposalFlowsTest {
	static testmethod void test_method_one() {
		GenerateTestData.createAccount();        
        GenerateTestData.createPriceList();
        OpportunityHelper.setLaunchControl();
        AddressHandler.setLaunchControl();     
        LineItemHelper.setLaunchControl();
        RecursiveTriggerUtility.isBeforeInsertQuoteProposalTrigger = true;
        RecursiveTriggerUtility.isBeforeUpdateQuoteProposalTrigger = true;
        GenerateTestData.createOpportunity();
        GenerateTestData.createAddress();
        GenerateTestData.createProposal();
		GenerateTestData.createProduct2();
        GenerateTestData.CreateProposalLineItem1();

		List<Id> lstProps = new List<Id>();
		lstProps.add(GenerateTestData.proposal.Id);
		test.startTest();
		ApttusProposalFlows.updateProposalServiceDates(lstProps);
		test.stopTest();
	}

	static testmethod void test_method_two() {
		GenerateTestData.createAccount();        
        GenerateTestData.createPriceList();
        OpportunityHelper.setLaunchControl();
        AddressHandler.setLaunchControl();     
        LineItemHelper.setLaunchControl();
        RecursiveTriggerUtility.isBeforeInsertQuoteProposalTrigger = true;
        RecursiveTriggerUtility.isBeforeUpdateQuoteProposalTrigger = true;
        GenerateTestData.createOpportunity();
        GenerateTestData.createAddress();
        GenerateTestData.createProposal();
		GenerateTestData.createProduct2();
        GenerateTestData.CreateProposalLineItem1();

		GenerateTestData.proposalLiTm1.Service_Start_Date__c = system.today();
		GenerateTestData.proposalLiTm1.Service_End_Date__c = system.today().addYears(1);
		update GenerateTestData.proposalLiTm1;

		List<Id> lstProps = new List<Id>();
		lstProps.add(GenerateTestData.proposal.Id);
		test.startTest();
		ApttusProposalFlows.updateProposalServiceDates(lstProps);
		test.stopTest();
	}
}