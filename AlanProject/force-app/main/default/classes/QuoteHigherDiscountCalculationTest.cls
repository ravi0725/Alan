/*
* ****************************************************************************************
Name		: QuoteHigherDiscountCalculationTest
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
Suresh Babu Murugan    22/11/2016		Created
*****************************************************************************************/
@isTest(seealldata=true)
private class QuoteHigherDiscountCalculationTest {
    
    static testmethod void DisountTest1(){
        // Create Test Records
        CreateTestDataforthisClass();
        
        system.test.startTest();
        
        QuoteHigherDiscountCalculation.resetLaunchControl();
        update GenerateTestData.proposal;
        
        system.test.stopTest();
    }
    
    static void CreateTestDataforthisClass(){
        GenerateTestData.createAccount();
        GenerateTestData.createAddress();
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();
        GenerateTestData.createProduct2();
        GenerateTestData.createPricebook2();
        GenerateTestData.createPriceBookEntry();
        GenerateTestData.createProposal();
        system.debug('proposal ID ++++++++++++++++++'+GenerateTestData.proposal.Id);
        
        Product2 prd = new Product2(Name = 'test',
                                    isActive = true,
                                    Product_Category_Type__c ='Subscription',
                                    Contract_Item_Type_Code__c = 'WARRANTY',
                                    Product_Line_Description__c = 'SAAShdskjhdsfkjtest',
                                    ProductCode = 'Test123',
                                    Family = 'Services');
        insert prd;
        
        // Create Catagory
        Apttus_Config2__ClassificationName__c catG = new Apttus_Config2__ClassificationName__c(
            Name = 'TIBV DE Test',
            Apttus_Config2__Active__c = true,
            Apttus_Config2__HierarchyLabel__c = 'TIBV DE Test',
            Apttus_Config2__Type__c = 'Offering'
        );
        Database.insert(catG);

        // Create CatehoeryHierarchy
        List<Apttus_Config2__ClassificationHierarchy__c> lstInsertCatH = new List<Apttus_Config2__ClassificationHierarchy__c>();
        Apttus_Config2__ClassificationHierarchy__c catH1 = new Apttus_Config2__ClassificationHierarchy__c(
            Name = 'TIBV DE Test',
            Apttus_Config2__Label__c = 'TIBV DE Test',
            Apttus_Config2__Left__c = 1,
            Apttus_Config2__Right__c = 10,
            Apttus_Config2__Level__c = 0,
            Apttus_Config2__HierarchyId__c = catG.Id
        );
        Database.insert(catH1);

        Apttus_Config2__ClassificationHierarchy__c catH2 = new Apttus_Config2__ClassificationHierarchy__c(
            Name = 'Software',
            Apttus_Config2__Label__c = 'Software',
            Apttus_Config2__Left__c = 2,
            Apttus_Config2__Right__c = 5,
            Apttus_Config2__Level__c = 1,
            Apttus_Config2__HierarchyId__c = catG.Id,
            Apttus_Config2__PrimordialId__c = catH1.Id,
            Apttus_Config2__AncestorId__c = catH1.Id
        );
        lstInsertCatH.add(catH2);
        Apttus_Config2__ClassificationHierarchy__c catH3 = new Apttus_Config2__ClassificationHierarchy__c(
            Name = 'Third Party Software',
            Apttus_Config2__Label__c = 'Third Party Software',
            Apttus_Config2__Left__c = 6,
            Apttus_Config2__Right__c = 12,
            Apttus_Config2__Level__c = 1,
            Apttus_Config2__HierarchyId__c = catG.Id,
            Apttus_Config2__PrimordialId__c = catH1.Id,
            Apttus_Config2__AncestorId__c = catH1.Id
        );
        lstInsertCatH.add(catH3);
        Apttus_Config2__ClassificationHierarchy__c catH4 = new Apttus_Config2__ClassificationHierarchy__c(
            Name = 'Services',
            Apttus_Config2__Label__c = 'Services',
            Apttus_Config2__Left__c = 13,
            Apttus_Config2__Right__c = 18,
            Apttus_Config2__Level__c = 1,
            Apttus_Config2__HierarchyId__c = catG.Id,
            Apttus_Config2__PrimordialId__c = catH1.Id,
            Apttus_Config2__AncestorId__c = catH1.Id
        );
        lstInsertCatH.add(catH4);
        Apttus_Config2__ClassificationHierarchy__c catH5 = new Apttus_Config2__ClassificationHierarchy__c(
            Name = 'Hardware',
            Apttus_Config2__Label__c = 'Hardware',
            Apttus_Config2__Left__c = 19,
            Apttus_Config2__Right__c = 24,
            Apttus_Config2__Level__c = 1,
            Apttus_Config2__HierarchyId__c = catG.Id,
            Apttus_Config2__PrimordialId__c = catH1.Id,
            Apttus_Config2__AncestorId__c = catH1.Id
        );
        lstInsertCatH.add(catH5);
        Apttus_Config2__ClassificationHierarchy__c catH6 = new Apttus_Config2__ClassificationHierarchy__c(
            Name = 'Other',
            Apttus_Config2__Label__c = 'Other',
            Apttus_Config2__Left__c = 25,
            Apttus_Config2__Right__c = 30,
            Apttus_Config2__Level__c = 1,
            Apttus_Config2__HierarchyId__c = catG.Id,
            Apttus_Config2__PrimordialId__c = catH1.Id,
            Apttus_Config2__AncestorId__c = catH1.Id
        );
        lstInsertCatH.add(catH6);
        Database.insert(lstInsertCatH);

        Apttus_Config2__ClassificationHierarchy__c catH7 = new Apttus_Config2__ClassificationHierarchy__c(
            Name = 'CAD Software',
            Apttus_Config2__Label__c = 'CAD Software',
            Apttus_Config2__Left__c = 3,
            Apttus_Config2__Right__c = 4,
            Apttus_Config2__Level__c = 2,
            Apttus_Config2__HierarchyId__c = catG.Id,
            Apttus_Config2__PrimordialId__c = catH1.Id,
            Apttus_Config2__AncestorId__c = catH2.Id
        );
        lstInsertCatH.add(catH7);
        Apttus_Config2__ClassificationHierarchy__c catH8 = new Apttus_Config2__ClassificationHierarchy__c(
            Name = '3rd Party Software',
            Apttus_Config2__Label__c = '3rd Party Software',
            Apttus_Config2__Left__c = 7,
            Apttus_Config2__Right__c = 8,
            Apttus_Config2__Level__c = 2,
            Apttus_Config2__HierarchyId__c = catG.Id,
            Apttus_Config2__PrimordialId__c = catH1.Id,
            Apttus_Config2__AncestorId__c = catH3.Id
        );
        lstInsertCatH.add(catH8);
        Apttus_Config2__ClassificationHierarchy__c catH9 = new Apttus_Config2__ClassificationHierarchy__c(
            Name = 'Training',
            Apttus_Config2__Label__c = 'Training',
            Apttus_Config2__Left__c = 14,
            Apttus_Config2__Right__c = 15,
            Apttus_Config2__Level__c = 2,
            Apttus_Config2__HierarchyId__c = catG.Id,
            Apttus_Config2__PrimordialId__c = catH1.Id,
            Apttus_Config2__AncestorId__c = catH4.Id
        );
        lstInsertCatH.add(catH9);
        Apttus_Config2__ClassificationHierarchy__c catH10 = new Apttus_Config2__ClassificationHierarchy__c(
            Name = 'Special Services',
            Apttus_Config2__Label__c = 'Special Services',
            Apttus_Config2__Left__c = 16,
            Apttus_Config2__Right__c = 17,
            Apttus_Config2__Level__c = 2,
            Apttus_Config2__HierarchyId__c = catG.Id,
            Apttus_Config2__PrimordialId__c = catH1.Id,
            Apttus_Config2__AncestorId__c = catH4.Id
        );
        lstInsertCatH.add(catH10);
        Apttus_Config2__ClassificationHierarchy__c catH11 = new Apttus_Config2__ClassificationHierarchy__c(
            Name = 'Workstation',
            Apttus_Config2__Label__c = 'Workstation',
            Apttus_Config2__Left__c = 20,
            Apttus_Config2__Right__c = 21,
            Apttus_Config2__Level__c = 2,
            Apttus_Config2__HierarchyId__c = catG.Id,
            Apttus_Config2__PrimordialId__c = catH1.Id,
            Apttus_Config2__AncestorId__c = catH5.Id
        );
        lstInsertCatH.add(catH11);
        Apttus_Config2__ClassificationHierarchy__c catH12 = new Apttus_Config2__ClassificationHierarchy__c(
            Name = 'Other',
            Apttus_Config2__Label__c = 'Other',
            Apttus_Config2__Left__c = 26,
            Apttus_Config2__Right__c = 27,
            Apttus_Config2__Level__c = 2,
            Apttus_Config2__HierarchyId__c = catG.Id,
            Apttus_Config2__PrimordialId__c = catH1.Id,
            Apttus_Config2__AncestorId__c = catH6.Id
        );
        lstInsertCatH.add(catH12);
        Database.upsert(lstInsertCatH);

        List<Apttus_Proposal__Proposal_Line_Item__c> lstpLineItems = new List<Apttus_Proposal__Proposal_Line_Item__c>();
        Apttus_Proposal__Proposal_Line_Item__c proposalLine_SwHigh1 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_QPConfig__BasePrice__c = 140.48,
                                                                                                                Apttus_Proposal__Proposal__c = GenerateTestData.proposal.Id,
                                                                                                                CurrencyISOCode = 'USD',
                                                                                                                Apttus_QPConfig__PriceListId__c = GenerateTestData.pricelist.Id,
                                                                                                                Apttus_QPConfig__OptionId__c = prd.Id,
                                                                                                                Apttus_Proposal__Product__c = prd.Id,
                                                                                                                Apttus_Proposal__Quantity__c = 92,
                                                                                                                Apttus_QPConfig__Quantity2__c = 95,
                                                                                                                Apttus_QPConfig__PriceUom__c = 'Each',
                                                                                                                Apttus_QPConfig__ListPrice__c = 45,
                                                                                                                Actual_List_Price__c = 45,
                                                                                                                Apttus_QPConfig__NetPrice__c = 545,
                                                                                                                Apttus_QPConfig__SellingTerm__c = 98,
                                                                                                                Apttus_QPConfig__SellingFrequency__c = 'Work Unit',
                                                                                                                Apttus_QPConfig__LineType__c = 'Product/Service',
                                                                                                                Apttus_QPConfig__ChargeType__c = 'Standard Price',
                                                                                                                Apttus_QPConfig__LineNumber__c = 67,
                                                                                                                Apttus_QPConfig__NetAdjustmentPercent__c = 20,
                                                                                                                Apttus_QPConfig__ExtendedPrice__c = 45,
                                                                                                                Apttus_QPConfig__ClassificationHierarchy__c = 'TIBV DE Test | Software | CAD Software',
                                                                                                                Apttus_QPConfig__AdjustmentType__c = 'Price Override');
        
        Apttus_Proposal__Proposal_Line_Item__c proposalLine_SwHigh2 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_QPConfig__BasePrice__c = 140.48,
                                                                                                                Apttus_Proposal__Proposal__c = GenerateTestData.proposal.Id,
                                                                                                                CurrencyISOCode = 'USD',
                                                                                                                Apttus_QPConfig__PriceListId__c = GenerateTestData.pricelist.Id,
                                                                                                                Apttus_QPConfig__OptionId__c = prd.Id,
                                                                                                                Apttus_Proposal__Product__c = prd.Id,
                                                                                                                Apttus_Proposal__Quantity__c = 92,
                                                                                                                Apttus_QPConfig__Quantity2__c = 95,
                                                                                                                Apttus_QPConfig__PriceUom__c = 'Each',
                                                                                                                Apttus_QPConfig__ListPrice__c = 45,
                                                                                                                Actual_List_Price__c = 35,
                                                                                                                Apttus_QPConfig__NetPrice__c = 545,
                                                                                                                Apttus_QPConfig__SellingTerm__c = 98,
                                                                                                                Apttus_QPConfig__SellingFrequency__c = 'Work Unit',
                                                                                                                Apttus_QPConfig__LineType__c = 'Product/Service',
                                                                                                                Apttus_QPConfig__ChargeType__c = 'Standard Price',
                                                                                                                Apttus_QPConfig__LineNumber__c = 67,
                                                                                                                Apttus_QPConfig__NetAdjustmentPercent__c = 20,
                                                                                                                Apttus_QPConfig__ExtendedPrice__c = 45,
                                                                                                                Apttus_QPConfig__ClassificationHierarchy__c = 'TIBV DE Test | Software | CAD Software',
                                                                                                                Apttus_QPConfig__AdjustmentType__c = 'Price Override');
        Apttus_Proposal__Proposal_Line_Item__c proposalLine_SwHigh3 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_QPConfig__BasePrice__c = 140.48,
                                                                                                                Apttus_Proposal__Proposal__c = GenerateTestData.proposal.Id,
                                                                                                                CurrencyISOCode = 'USD',
                                                                                                                Apttus_QPConfig__PriceListId__c = GenerateTestData.pricelist.Id,
                                                                                                                Apttus_QPConfig__OptionId__c = prd.Id,
                                                                                                                Apttus_Proposal__Product__c = prd.Id,
                                                                                                                Apttus_Proposal__Quantity__c = 92,
                                                                                                                Apttus_QPConfig__Quantity2__c = 95,
                                                                                                                Apttus_QPConfig__PriceUom__c = 'Each',
                                                                                                                Apttus_QPConfig__ListPrice__c = 45,
                                                                                                                Actual_List_Price__c = 35,
                                                                                                                Apttus_QPConfig__NetPrice__c = 545,
                                                                                                                Apttus_QPConfig__SellingTerm__c = 98,
                                                                                                                Apttus_QPConfig__SellingFrequency__c = 'Work Unit',
                                                                                                                Apttus_QPConfig__LineType__c = 'Option',
                                                                                                                Apttus_QPConfig__ChargeType__c = 'Maintenance Fee',
                                                                                                                Apttus_QPConfig__LineNumber__c = 67,
                                                                                                                Apttus_QPConfig__NetAdjustmentPercent__c = 20,
                                                                                                                Apttus_QPConfig__ExtendedPrice__c = 45,
                                                                                                                Apttus_QPConfig__ClassificationHierarchy__c = '',
                                                                                                                Apttus_QPConfig__AdjustmentType__c = 'Price Override');
        
        Apttus_Proposal__Proposal_Line_Item__c proposalLine_SwDisc1 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_QPConfig__BasePrice__c = 140.48,
                                                                                                                Apttus_Proposal__Proposal__c = GenerateTestData.proposal.Id,
                                                                                                                CurrencyISOCode = 'USD',
                                                                                                                Apttus_QPConfig__PriceListId__c = GenerateTestData.pricelist.Id,
                                                                                                                Apttus_QPConfig__OptionId__c = prd.Id,
                                                                                                                Apttus_Proposal__Product__c = prd.Id,
                                                                                                                Apttus_Proposal__Quantity__c = 92,
                                                                                                                Apttus_QPConfig__Quantity2__c = 95,
                                                                                                                Apttus_QPConfig__PriceUom__c = 'Each',
                                                                                                                Apttus_QPConfig__ListPrice__c = 45,
                                                                                                                Actual_List_Price__c = 45,
                                                                                                                Apttus_QPConfig__NetPrice__c = 52,
                                                                                                                Apttus_QPConfig__SellingTerm__c = 98,
                                                                                                                Apttus_QPConfig__SellingFrequency__c = 'Work Unit',
                                                                                                                Apttus_QPConfig__LineType__c = 'Product/Service',
                                                                                                                Apttus_QPConfig__ChargeType__c = 'Standard Price',
                                                                                                                Apttus_QPConfig__LineNumber__c = 67,
                                                                                                                Apttus_QPConfig__NetAdjustmentPercent__c = -20,
                                                                                                                Apttus_QPConfig__ExtendedPrice__c = 45,
                                                                                                                Apttus_QPConfig__ClassificationHierarchy__c = 'TIBV DE Test | Software | CAD Software',
                                                                                                                Apttus_QPConfig__AdjustmentType__c = '% Discount');
        Apttus_Proposal__Proposal_Line_Item__c proposalLine_SwDisc2 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_QPConfig__BasePrice__c = 140.48,
                                                                                                                Apttus_Proposal__Proposal__c = GenerateTestData.proposal.Id,
                                                                                                                CurrencyISOCode = 'USD',
                                                                                                                Apttus_QPConfig__PriceListId__c = GenerateTestData.pricelist.Id,
                                                                                                                Apttus_QPConfig__OptionId__c = prd.Id,
                                                                                                                Apttus_Proposal__Product__c = prd.Id,
                                                                                                                Apttus_Proposal__Quantity__c = 92,
                                                                                                                Apttus_QPConfig__Quantity2__c = 95,
                                                                                                                Apttus_QPConfig__PriceUom__c = 'Each',
                                                                                                                Apttus_QPConfig__ListPrice__c = 45,
                                                                                                                Actual_List_Price__c = 35,
                                                                                                                Apttus_QPConfig__NetPrice__c = 52,
                                                                                                                Apttus_QPConfig__SellingTerm__c = 98,
                                                                                                                Apttus_QPConfig__SellingFrequency__c = 'Work Unit',
                                                                                                                Apttus_QPConfig__LineType__c = 'Product/Service',
                                                                                                                Apttus_QPConfig__ChargeType__c = 'Standard Price',
                                                                                                                Apttus_QPConfig__LineNumber__c = 67,
                                                                                                                Apttus_QPConfig__NetAdjustmentPercent__c = -20,
                                                                                                                Apttus_QPConfig__ExtendedPrice__c = 45,
                                                                                                                Apttus_QPConfig__ClassificationHierarchy__c = 'TIBV DE Test | Software | CAD Software',
                                                                                                                Apttus_QPConfig__AdjustmentType__c = '% Discount');
        Apttus_Proposal__Proposal_Line_Item__c proposalLine_SwDisc3 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_QPConfig__BasePrice__c = 140.48,
                                                                                                                Apttus_Proposal__Proposal__c = GenerateTestData.proposal.Id,
                                                                                                                CurrencyISOCode = 'USD',
                                                                                                                Apttus_QPConfig__PriceListId__c = GenerateTestData.pricelist.Id,
                                                                                                                Apttus_QPConfig__OptionId__c = prd.Id,
                                                                                                                Apttus_Proposal__Product__c = prd.Id,
                                                                                                                Apttus_Proposal__Quantity__c = 92,
                                                                                                                Apttus_QPConfig__Quantity2__c = 95,
                                                                                                                Apttus_QPConfig__PriceUom__c = 'Each',
                                                                                                                Apttus_QPConfig__ListPrice__c = 45,
                                                                                                                Actual_List_Price__c = 45,
                                                                                                                Apttus_QPConfig__NetPrice__c = 52,
                                                                                                                Apttus_QPConfig__SellingTerm__c = 98,
                                                                                                                Apttus_QPConfig__SellingFrequency__c = 'Work Unit',
                                                                                                                Apttus_QPConfig__LineType__c = 'Product/Service',
                                                                                                                Apttus_QPConfig__ChargeType__c = 'Standard Price',
                                                                                                                Apttus_QPConfig__LineNumber__c = 67,
                                                                                                                Apttus_QPConfig__NetAdjustmentPercent__c = -20,
                                                                                                                Apttus_QPConfig__ExtendedPrice__c = 45,
                                                                                                                Apttus_QPConfig__ClassificationHierarchy__c = 'TIBV DE Test | Third Party Software | 3rd Party Software',
                                                                                                                Apttus_QPConfig__AdjustmentType__c = '% Discount');
        Apttus_Proposal__Proposal_Line_Item__c proposalLine_SwDisc4 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_QPConfig__BasePrice__c = 140.48,
                                                                                                                Apttus_Proposal__Proposal__c = GenerateTestData.proposal.Id,
                                                                                                                CurrencyISOCode = 'USD',
                                                                                                                Apttus_QPConfig__PriceListId__c = GenerateTestData.pricelist.Id,
                                                                                                                Apttus_QPConfig__OptionId__c = prd.Id,
                                                                                                                Apttus_Proposal__Product__c = prd.Id,
                                                                                                                Apttus_Proposal__Quantity__c = 92,
                                                                                                                Apttus_QPConfig__Quantity2__c = 95,
                                                                                                                Apttus_QPConfig__PriceUom__c = 'Each',
                                                                                                                Apttus_QPConfig__ListPrice__c = 45,
                                                                                                                Actual_List_Price__c = 45,
                                                                                                                Apttus_QPConfig__NetPrice__c = 52,
                                                                                                                Apttus_QPConfig__SellingTerm__c = 98,
                                                                                                                Apttus_QPConfig__SellingFrequency__c = 'Work Unit',
                                                                                                                Apttus_QPConfig__LineType__c = 'Product/Service',
                                                                                                                Apttus_QPConfig__ChargeType__c = 'Standard Price',
                                                                                                                Apttus_QPConfig__LineNumber__c = 67,
                                                                                                                Apttus_QPConfig__NetAdjustmentPercent__c = -20,
                                                                                                                Apttus_QPConfig__ExtendedPrice__c = 45,
                                                                                                                Apttus_QPConfig__ClassificationHierarchy__c = 'TIBV DE Test | Services | Training',
                                                                                                                Apttus_QPConfig__AdjustmentType__c = '% Discount');
        Apttus_Proposal__Proposal_Line_Item__c proposalLine_SwDisc5 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_QPConfig__BasePrice__c = 140.48,
                                                                                                                Apttus_Proposal__Proposal__c = GenerateTestData.proposal.Id,
                                                                                                                CurrencyISOCode = 'USD',
                                                                                                                Apttus_QPConfig__PriceListId__c = GenerateTestData.pricelist.Id,
                                                                                                                Apttus_QPConfig__OptionId__c = prd.Id,
                                                                                                                Apttus_Proposal__Product__c = prd.Id,
                                                                                                                Apttus_Proposal__Quantity__c = 92,
                                                                                                                Apttus_QPConfig__Quantity2__c = 95,
                                                                                                                Apttus_QPConfig__PriceUom__c = 'Each',
                                                                                                                Apttus_QPConfig__ListPrice__c = 45,
                                                                                                                Actual_List_Price__c = 45,
                                                                                                                Apttus_QPConfig__NetPrice__c = 52,
                                                                                                                Apttus_QPConfig__SellingTerm__c = 98,
                                                                                                                Apttus_QPConfig__SellingFrequency__c = 'Work Unit',
                                                                                                                Apttus_QPConfig__LineType__c = 'Product/Service',
                                                                                                                Apttus_QPConfig__ChargeType__c = 'Standard Price',
                                                                                                                Apttus_QPConfig__LineNumber__c = 67,
                                                                                                                Apttus_QPConfig__NetAdjustmentPercent__c = -20,
                                                                                                                Apttus_QPConfig__ExtendedPrice__c = 45,
                                                                                                                Apttus_QPConfig__ClassificationHierarchy__c = 'Services | Special Services',
                                                                                                                Apttus_QPConfig__AdjustmentType__c = '% Discount');
        Apttus_Proposal__Proposal_Line_Item__c proposalLine_SwDisc6 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_QPConfig__BasePrice__c = 140.48,
                                                                                                                Apttus_Proposal__Proposal__c = GenerateTestData.proposal.Id,
                                                                                                                CurrencyISOCode = 'USD',
                                                                                                                Apttus_QPConfig__PriceListId__c = GenerateTestData.pricelist.Id,
                                                                                                                Apttus_QPConfig__OptionId__c = prd.Id,
                                                                                                                Apttus_Proposal__Product__c = prd.Id,
                                                                                                                Apttus_Proposal__Quantity__c = 92,
                                                                                                                Apttus_QPConfig__Quantity2__c = 95,
                                                                                                                Apttus_QPConfig__PriceUom__c = 'Each',
                                                                                                                Apttus_QPConfig__ListPrice__c = 45,
                                                                                                                Actual_List_Price__c = 45,
                                                                                                                Apttus_QPConfig__NetPrice__c = 52,
                                                                                                                Apttus_QPConfig__SellingTerm__c = 98,
                                                                                                                Apttus_QPConfig__SellingFrequency__c = 'Work Unit',
                                                                                                                Apttus_QPConfig__LineType__c = 'Product/Service',
                                                                                                                Apttus_QPConfig__ChargeType__c = 'Standard Price',
                                                                                                                Apttus_QPConfig__LineNumber__c = 67,
                                                                                                                Apttus_QPConfig__NetAdjustmentPercent__c = -20,
                                                                                                                Apttus_QPConfig__ExtendedPrice__c = 45,
                                                                                                                Apttus_QPConfig__ClassificationHierarchy__c = 'Hardware | Workstation',
                                                                                                                Apttus_QPConfig__AdjustmentType__c = '% Discount');
        Apttus_Proposal__Proposal_Line_Item__c proposalLine_SwDisc7 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_QPConfig__BasePrice__c = 140.48,
                                                                                                                Apttus_Proposal__Proposal__c = GenerateTestData.proposal.Id,
                                                                                                                CurrencyISOCode = 'USD',
                                                                                                                Apttus_QPConfig__PriceListId__c = GenerateTestData.pricelist.Id,
                                                                                                                Apttus_QPConfig__OptionId__c = prd.Id,
                                                                                                                Apttus_Proposal__Product__c = prd.Id,
                                                                                                                Apttus_Proposal__Quantity__c = 92,
                                                                                                                Apttus_QPConfig__Quantity2__c = 95,
                                                                                                                Apttus_QPConfig__PriceUom__c = 'Each',
                                                                                                                Apttus_QPConfig__ListPrice__c = 45,
                                                                                                                Actual_List_Price__c = 45,
                                                                                                                Apttus_QPConfig__NetPrice__c = 52,
                                                                                                                Apttus_QPConfig__SellingTerm__c = 98,
                                                                                                                Apttus_QPConfig__SellingFrequency__c = 'Work Unit',
                                                                                                                Apttus_QPConfig__LineType__c = 'Product/Service',
                                                                                                                Apttus_QPConfig__ChargeType__c = 'Standard Price',
                                                                                                                Apttus_QPConfig__LineNumber__c = 67,
                                                                                                                Apttus_QPConfig__NetAdjustmentPercent__c = -20,
                                                                                                                Apttus_QPConfig__ExtendedPrice__c = 45,
                                                                                                                Apttus_QPConfig__ClassificationHierarchy__c = 'TIBV DE Test | Other | Fee',
                                                                                                                Apttus_QPConfig__AdjustmentType__c = '% Discount');
        Apttus_Proposal__Proposal_Line_Item__c proposalLine_SwDisc8 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_QPConfig__BasePrice__c = 140.48,
                                                                                                                Apttus_Proposal__Proposal__c = GenerateTestData.proposal.Id,
                                                                                                                CurrencyISOCode = 'USD',
                                                                                                                Apttus_QPConfig__PriceListId__c = GenerateTestData.pricelist.Id,
                                                                                                                Apttus_QPConfig__OptionId__c = prd.Id,
                                                                                                                Apttus_Proposal__Product__c = prd.Id,
                                                                                                                Apttus_Proposal__Quantity__c = 92,
                                                                                                                Apttus_QPConfig__Quantity2__c = 95,
                                                                                                                Apttus_QPConfig__PriceUom__c = 'Each',
                                                                                                                Apttus_QPConfig__ListPrice__c = 45,
                                                                                                                Actual_List_Price__c = 45,
                                                                                                                Apttus_QPConfig__NetPrice__c = 52,
                                                                                                                Apttus_QPConfig__SellingTerm__c = 98,
                                                                                                                Apttus_QPConfig__SellingFrequency__c = 'Work Unit',
                                                                                                                Apttus_QPConfig__LineType__c = 'Option',
                                                                                                                Apttus_QPConfig__ChargeType__c = 'Maintenance Fee',
                                                                                                                Apttus_QPConfig__LineNumber__c = 67,
                                                                                                                Apttus_QPConfig__NetAdjustmentPercent__c = -20,
                                                                                                                Apttus_QPConfig__ExtendedPrice__c = 45,
                                                                                                                Apttus_QPConfig__ClassificationHierarchy__c = '',
                                                                                                                Apttus_QPConfig__AdjustmentType__c = '% Discount');
        lstpLineItems.add(proposalLine_SwHigh1);
        lstpLineItems.add(proposalLine_SwHigh2);
        lstpLineItems.add(proposalLine_SwHigh3);
        lstpLineItems.add(proposalLine_SwDisc1);
        lstpLineItems.add(proposalLine_SwDisc2);
        lstpLineItems.add(proposalLine_SwDisc3);
        lstpLineItems.add(proposalLine_SwDisc4);
        lstpLineItems.add(proposalLine_SwDisc5);
        lstpLineItems.add(proposalLine_SwDisc6);
        lstpLineItems.add(proposalLine_SwDisc7);
        lstpLineItems.add(proposalLine_SwDisc8);
        insert lstpLineItems;
        
        Apttus__APTS_Agreement__c apg = new Apttus__APTS_Agreement__c(Apttus__Contract_Start_Date__c = date.today(),
                                                                      Apttus__Contract_End_Date__c = date.today() + 5,
                                                                      ProServ_Type__c = 'Fixed Fee',
                                                                      Credit_Status__c = 'test',
                                                                      Credit_Approved__c = 'test Credit_Approved__c',
                                                                      CREDIT_LIMIT_AVAILABLE__C = 10,
                                                                      CREDIT_EXISTING_EXPOSURE__C = 10,
                                                                      CREDIT_CALCULATED_EXPOSURE__c = 10,
                                                                      CREDIT_TOTAL_EXPOSURE__c = 10,
                                                                      Fusion_Project_Number__c = 'test Fusion_Project_Number__c',
                                                                      Apttus_QPComply__RelatedProposalId__c = GenerateTestData.proposal.Id,
                                                                      Apttus__Status_Category__c = 'In Effect : Submitted',
                                                                      Apttus__Status__c='Activated',
                                                                      Apttus_CMConfig__PriceListId__c = GenerateTestData.pricelist.Id);
        insert apg;
        
    }
    
}