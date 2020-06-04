/*
****************************************************************************************
    Name Controller        : expressQuoteTest 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
 P M Mamata           19/08/2015          Updated
*****************************************************************************************
*/
 
@isTest(seealldata=true)
private class expressQuoteTest{
    
        static testmethod void meth1(){
        GenerateTestData.createAccount();
        system.currentPageReference().getParameters().put('id', GenerateTestData.acct.Id);         
        expressQuote eq = new expressQuote(new ApexPages.StandardController(GenerateTestData.acct));
        
    }
    
    static testmethod void getOpportunitySOmeth1(){
		GenerateTestData.createAccount();
        system.currentPageReference().getParameters().put('id', GenerateTestData.acct.Id);         
        expressQuote eq = new expressQuote(new ApexPages.StandardController(GenerateTestData.acct));
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();
		expressQuote.getOpportunitySO(GenerateTestData.opp.Id);
	}

    static testmethod void createQuoteOrProposalmeth1(){
        GenerateTestData.createAccount();
        system.currentPageReference().getParameters().put('id', GenerateTestData.acct.Id);         
        expressQuote eq = new expressQuote(new ApexPages.StandardController(GenerateTestData.acct));
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();
        system.debug('---------GenerateTestData.opp---------' + GenerateTestData.opp);
        expressQuote.createQuoteOrProposal(GenerateTestData.opp,GenerateTestData.acct.Id);
        
    }
    
    static testmethod void createQuoteOrProposalFromAgreementmeth1(){
		GenerateTestData.createAccount();
        system.currentPageReference().getParameters().put('id', GenerateTestData.acct.Id);         
        expressQuote eq = new expressQuote(new ApexPages.StandardController(GenerateTestData.acct));
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();        
        GenerateTestData.createAddress();
        GenerateTestData.createProposal();
        GenerateTestData.createAPTSAgreement();
        expressQuote.createQuoteOrProposalFromAgreement(GenerateTestData.opp,GenerateTestData.acct.Id,GenerateTestData.apg.Id);        
        
    }
    
    static testmethod void createDealFromProposalmeth(){
        GenerateTestData.createAccount();
        system.currentPageReference().getParameters().put('id', GenerateTestData.acct.Id);         
        expressQuote eq = new expressQuote(new ApexPages.StandardController(GenerateTestData.acct));
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();
        GenerateTestData.createAddress();
        GenerateTestData.createProposal();
        expressQuote.createDealFromProposal(GenerateTestData.proposal); 
        eq.cancel();
        eq.next();
    }
    
    static testmethod void createDealFromProposalmeth1(){
        GenerateTestData.createAccount();
        system.currentPageReference().getParameters().put('id', GenerateTestData.acct.Id);         
        expressQuote eq = new expressQuote(new ApexPages.StandardController(GenerateTestData.acct));
        eq.cancel();
        eq.next();        
    }    
    
    
    
}