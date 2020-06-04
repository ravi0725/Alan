/*
****************************************************************************************
 Name Controller        : QuoteProposalLineItemCategoryTest 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
 Prince Leo           19/05/2018          created
*****************************************************************************************
*/
@istest(SeeAllData=true)

private class QuoteProposalLineItemCategoryTest {
	static testmethod void QuoteProposalLineItemCategoryTest1(){
        test.startTest();
            GenerateTestData.createAccount();
            GenerateTestData.createAddress();
            //GenerateTestData.createPriceList();
        	Id acctId = GenerateTestData.acct.Id;
        	
            Apttus_Config2__PriceList__c prilst = new Apttus_Config2__PriceList__c();
            prilst.Apttus_Config2__Active__c = true;
        	prilst.Name = 'temp MEP NA Standard Price List - USD';
            prilst.Legal_Entity__c = '';
            prilst.Business_Area__c = 'ACCUBID';
        	insert prilst;
        	
            //GenerateTestData.createProduct2();
        	Product2 prd1 = new Product2();
            prd1.Name = 'test';
            prd1.isActive = true;
            prd1.Product_Category_Type__c ='SaaS';
            prd1.Contract_Item_Type_Code__c = 'WARRANTY';
            prd1.Product_Line_Description__c = 'hdskjhdsfkjtest SAAS';
            prd1.ProductCode = 'Test456'; 
        	insert prd1;
        	
            Opportunity opp = new Opportunity();
            opp.AccountId = acctId;
            opp.StageName = 'Inquery';
            opp.Closedate = date.today() + 7;
            opp.Name = 'Opp1';
            opp.CurrencyISOCode = 'USD';
            opp.Price_List__c = prilst.id;
            opp.Selling_Division__c ='MEP NA';
            opp.Ship_To_Account__c = acctId;
            opp.Payment_Term__c = 'CASH IN ADVANCE';
            opp.Type = 'New Business';
            opp.Account_Sub_Type__c ='Additional Licenses';
            opp.OwnerId = UserInfo.getUserId();
            insert opp;
        	        
        	Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c();
            proposal.Apttus_Proposal__Proposal_Name__c='TestGenerateQuote';//--added by Chandrakanth to overcome error of Null pointer exception related to Proposal Attachments
            proposal.Apttus_Proposal__Account__c = acctId;
            proposal.Apttus_QPConfig__BillToAccountId__c = acctId;
            proposal.Apttus_Proposal__Opportunity__c = opp.Id;
            proposal.Apttus_QPConfig__PriceListId__c = prilst.Id; 
            proposal.Ship_To_Account__c = acctId;
            proposal.Bill_to_Address__c  = GenerateTestData.adrs.Id;
            proposal.OwnerId = UserInfo.getUserId();
            proposal.Apttus_Proposal__Primary__c = true;
            proposal.Industry__c ='Electrical';
            proposal.Freight_Method__c ='N/A';
            proposal.Freight_Terms__c ='N/A';
            proposal.Payment_Method__c ='INVOICE';
            proposal.Clone_ID__c='Q-00012683';
            insert proposal;
        	
        	Apttus_Proposal__Proposal_Line_Item__c proposalLiTm = new Apttus_Proposal__Proposal_Line_Item__c();
            proposalLiTm.Apttus_QPConfig__BasePrice__c = 140.48;
            proposalLiTm.Apttus_Proposal__Proposal__c = proposal.Id;
            proposalLiTm.CurrencyISOCode = 'USD';
            proposalLiTm.Apttus_QPConfig__PriceListId__c = prilst.Id;
            proposalLiTm.Apttus_QPConfig__OptionId__c = prd1.Id;        
            proposalLiTm.Apttus_Proposal__Product__c = prd1.Id;        
            proposalLiTm.Apttus_Proposal__Quantity__c = 92;
            proposalLiTm.Apttus_QPConfig__Quantity2__c = 95;
            proposalLiTm.Apttus_QPConfig__PriceUom__c = 'Each';
            proposalLiTm.Apttus_QPConfig__ListPrice__c = 45;
            proposalLiTm.Apttus_QPConfig__NetPrice__c = 65;
            proposalLiTm.Apttus_QPConfig__SellingTerm__c = 98;
            proposalLiTm.Apttus_QPConfig__SellingFrequency__c = 'Work Unit';
            proposalLiTm.Apttus_QPConfig__LineType__c = 'Product/Service';
            proposalLiTm.Apttus_QPConfig__OptionId__c = prd1.Id;
            proposalLiTm.Apttus_QPConfig__ChargeType__c = 'Maintenance Fee';
            proposalLiTm.Apttus_QPConfig__LineNumber__c = 67;
            insert proposalLiTm;
                
            QuoteProposalLineItemCategory qplic = new QuoteProposalLineItemCategory();
        	QuoteProposalLineItemCategory.resetLaunchControl();
        	QuoteProposalLineItemCategory.launchControl.put('proposalLineItemType', 0);
        	//QuoteProposalLineItemCategory.
        	
        	List<Apttus_Proposal__Proposal__c> newProposalList = new List<Apttus_Proposal__Proposal__c>();
        	newProposalList.add(proposal);
        
        	QuoteProposalLineItemCategory.proposalLineItemType(newProposalList);
    	test.stopTest();
    }
}