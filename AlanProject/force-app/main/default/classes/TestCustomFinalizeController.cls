@isTest(seealldata=true)
public class TestCustomFinalizeController {
    static testmethod void CustomFinalizeControllerTest1(){
        GenerateTestData.createAccount();
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();        
        GenerateTestData.createAddress();
        GenerateTestData.createProposal();
        GenerateTestData.createProduct2();
        
        Apttus_Config2__ProductConfiguration__c acpcfg = new Apttus_Config2__ProductConfiguration__c();
        acpcfg.Name = 'test acpcfg1';
        acpcfg.Apttus_QPConfig__Proposald__c = GenerateTestData.proposal.Id;
        acpcfg.Apttus_Config2__PriceListId__c = GenerateTestData.pricelist.Id;
        insert acpcfg;
        
        /*acpcfg = new Apttus_Config2__ProductConfiguration__c();
        acpcfg.Name = 'test acpcfg2';
        acpcfg.Apttus_QPConfig__Proposald__c = GenerateTestData.proposal.Id;
        acpcfg.Apttus_Config2__PriceListId__c = GenerateTestData.pricelist.Id;
        insert acpcfg;*/
        
        System.currentPageReference().getParameters().put('id', acpcfg.Id);
        System.currentPageReference().getParameters().put('configRequestId', acpcfg.Id);
        CustomFinalizeController finalize = new CustomFinalizeController();
        finalize.backtocart();
        finalize.errorPopup = false;
        finalize.FinalizeError = false;
        finalize.AdvancedPricingflag = false;
        finalize.validateAdvancePriceFlag();
        finalize.callFinalize();
        finalize.AdvancedPricingflag = true;
        finalize.validateAdvancePriceFlag();
        finalize.callFinalize();
        finalize.ApproalStage = 'In Review';
        finalize.callFinalize();
    }
}