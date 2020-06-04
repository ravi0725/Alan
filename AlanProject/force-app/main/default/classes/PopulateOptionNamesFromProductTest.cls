@isTest(seealldata=true)
private class PopulateOptionNamesFromProductTest {
    
    static testmethod void meth1(){
        GenerateTestData.createAccount();
        GenerateTestData.createAddress();
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();
        GenerateTestData.createProduct2();
        GenerateTestData.createProposal();
        Apttus_Proposal__Proposal_Line_Item__c proposalLiTm = new Apttus_Proposal__Proposal_Line_Item__c();
        proposalLiTm.Apttus_QPConfig__BasePrice__c = 140.48;
        proposalLiTm.Apttus_Proposal__Proposal__c = GenerateTestData.proposal.Id;
        proposalLiTm.CurrencyISOCode = 'USD';
        proposalLiTm.Apttus_QPConfig__PriceListId__c = GenerateTestData.pricelist.Id;
        proposalLiTm.Apttus_QPConfig__OptionId__c = GenerateTestData.prd.Id;        
        proposalLiTm.Apttus_Proposal__Product__c = GenerateTestData.prd.Id;        
        proposalLiTm.Apttus_Proposal__Quantity__c = 92;
        proposalLiTm.Apttus_QPConfig__Quantity2__c = 95;
        proposalLiTm.Apttus_QPConfig__PriceUom__c = 'Each';
        proposalLiTm.Apttus_QPConfig__ListPrice__c = 45;
        proposalLiTm.Apttus_QPConfig__NetPrice__c = 65;
        proposalLiTm.Apttus_QPConfig__SellingTerm__c = 98;
        proposalLiTm.Apttus_QPConfig__SellingFrequency__c = 'Work Unit';
        proposalLiTm.Apttus_QPConfig__LineType__c = 'Product/Service';
        proposalLiTm.Apttus_QPConfig__OptionId__c = GenerateTestData.prd.Id;
        proposalLiTm.Apttus_QPConfig__ChargeType__c = 'Maintenance Fee';
        proposalLiTm.Apttus_QPConfig__LineNumber__c = 67;
        insert proposalLiTm;
        
    }
}