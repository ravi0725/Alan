/*
****************************************************************************************
 Name Controller        : SubmitorderFromEmailServiceTest 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
 P M Mamata           30/07/2015          created
*****************************************************************************************
*/
@istest(seealldata=true)

private class SubmitorderFromEmailServiceTest {
		
    static testmethod void SubmitorderFromEmailServiceMeth(){
        GenerateTestData.createAccount();
        GenerateTestData.createAddress();
        GenerateTestData.createPriceList();
        GenerateTestData.createProduct2();
                
        test.startTest();
            GenerateTestData.createOpportunity();
            GenerateTestData.createProposal();
            GenerateTestData.CreateProposalLineItem();
        	GenerateTestData.proposal.Cart_Line_Sequence_Changed__c = true;
        	update GenerateTestData.proposal;
        
        	Apttus__APTS_Agreement__c apg = new Apttus__APTS_Agreement__c();
            apg.Fusion_Project_Number__c = 'test';        
            apg.Apttus__Contract_Start_Date__c = date.today();
            apg.Apttus__Contract_End_Date__c = date.today() + 5;        
            apg.ProServ_Type__c = 'Fixed Fee';
            apg.Credit_Status__c = 'test';
            apg.Credit_Approved__c = 'test Credit_Approved__c';
            apg.CREDIT_LIMIT_AVAILABLE__C = 10;
            apg.CREDIT_EXISTING_EXPOSURE__C = 10;
            apg.CREDIT_CALCULATED_EXPOSURE__c = 10; 
            apg.CREDIT_TOTAL_EXPOSURE__c = 10;        
            apg.Fusion_Project_Number__c = 'test Fusion_Project_Number__c'; 
            apg.Apttus_QPComply__RelatedProposalId__c = GenerateTestData.proposal.Id;
            apg.Apttus__Status_Category__c = 'In Effect : Submitted';
            apg.Apttus__Status__c='Activated';
            apg.Apttus_CMConfig__PriceListId__c = GenerateTestData.pricelist.Id;
            apg.Apttus__Status_Category__c ='In Effect : Submitted';
            apg.Apttus__Status__c='Activated';
            insert apg;
        
            SubmitorderFromEmailService sub = new SubmitorderFromEmailService();
        	sub.SubmitOrder(GenerateTestData.proposal.Id, '1');
    	test.stopTest();
    }
    
    static testmethod void SubmitorderFromEmailServiceMeth2(){
        GenerateTestData.createAccount();
        GenerateTestData.createAddress();
        GenerateTestData.createPriceList();
        GenerateTestData.createProduct2();
        
        test.startTest();
            GenerateTestData.createOpportunity();
            GenerateTestData.createProposal();
            GenerateTestData.CreateProposalLineItem();
        	
        	GenerateTestData.proposalLiTm.Apttus_QPConfig__Quantity2__c = -10;
        	update GenerateTestData.proposalLiTm;
        
        	Apttus__APTS_Agreement__c apg = new Apttus__APTS_Agreement__c();
            apg.Fusion_Project_Number__c = 'test';        
            apg.Apttus__Contract_Start_Date__c = date.today();
            apg.Apttus__Contract_End_Date__c = date.today() + 5;        
            apg.ProServ_Type__c = 'Fixed Fee';
            apg.Credit_Status__c = 'test';
            apg.Credit_Approved__c = 'test Credit_Approved__c';
            apg.CREDIT_LIMIT_AVAILABLE__C = 10;
            apg.CREDIT_EXISTING_EXPOSURE__C = 10;
            apg.CREDIT_CALCULATED_EXPOSURE__c = 10; 
            apg.CREDIT_TOTAL_EXPOSURE__c = 10;        
            apg.Fusion_Project_Number__c = 'test Fusion_Project_Number__c'; 
            apg.Apttus_QPComply__RelatedProposalId__c = GenerateTestData.proposal.Id;
            apg.Apttus__Status_Category__c = 'In Effect : Submitted';
            apg.Apttus__Status__c='Activated';
            apg.Apttus_CMConfig__PriceListId__c = GenerateTestData.pricelist.Id;
            apg.Apttus__Status_Category__c ='In Effect : Submitted';
            apg.Apttus__Status__c='Activated';
            insert apg;
        
            SubmitorderFromEmailService sub = new SubmitorderFromEmailService();
        	sub.SubmitOrder(GenerateTestData.proposal.Id, '0');
    	test.stopTest();
    }
    
    static testmethod void SubmitorderFromEmailServiceMeth3(){
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
        GenerateTestData.CreateProposalLineItem();
        GenerateTestData.proposalLiTm.Apttus_QPConfig__Quantity2__c = -10;
        GenerateTestData.proposalLiTm.Apttus_Proposal__Product__c = GenerateTestData.prd.Id;
        GenerateTestData.proposalLiTm.Bill_to_Address__c = GenerateTestData.adrs.Id;
        GenerateTestData.proposalLiTm.Ship_to_Address1__c = GenerateTestData.adrs.Id;
        GenerateTestData.proposalLiTm.Apttus_QPConfig__OptionId__c = GenerateTestData.prd.Id;
        GenerateTestData.proposalLiTm.Apttus_QPConfig__ChargeType__c = 'Maintenance Fee'; 
        update GenerateTestData.proposalLiTm;
        
        Apttus__APTS_Agreement__c apg = new Apttus__APTS_Agreement__c();
        apg.Fusion_Project_Number__c = 'test';        
        apg.Apttus__Contract_Start_Date__c = date.today();
        apg.Apttus__Contract_End_Date__c = date.today() + 5;        
        apg.ProServ_Type__c = 'Fixed Fee';
        apg.Credit_Status__c = 'test';
        apg.Credit_Approved__c = 'test Credit_Approved__c';
        apg.CREDIT_LIMIT_AVAILABLE__C = 10;
        apg.CREDIT_EXISTING_EXPOSURE__C = 10;
        apg.CREDIT_CALCULATED_EXPOSURE__c = 10; 
        apg.CREDIT_TOTAL_EXPOSURE__c = 10;        
        apg.Fusion_Project_Number__c = 'test Fusion_Project_Number__c'; 
        apg.Apttus_QPComply__RelatedProposalId__c = GenerateTestData.proposal.Id;
        apg.Apttus__Status_Category__c = 'In Effect : Submitted';
        apg.Apttus__Status__c='Activated';
        apg.Apttus_CMConfig__PriceListId__c = GenerateTestData.pricelist.Id;
        apg.Apttus__Status_Category__c ='In Effect : Submitted';
        apg.Apttus__Status__c='Activated';
        insert apg;
        test.startTest();
            SubmitorderFromEmailService sub = new SubmitorderFromEmailService();
        	sub.SubmitOrder(GenerateTestData.proposal.Id, '1');
    	test.stopTest();
    }
    
}