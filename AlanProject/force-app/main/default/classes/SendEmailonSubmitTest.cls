/*
****************************************************************************************
    Name Controller        : SendEmailonSubmitTest 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
 P M Mamata           24/07/2015          created
*****************************************************************************************
*/
@istest(seealldata=true)

private class SendEmailonSubmitTest {
    static testmethod void SendEmailMeth(){
        SendEmailonSubmitOrderController sb  = new SendEmailonSubmitOrderController();
        GenerateTestData.createAccount();
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();
        GenerateTestData.createProduct2();
        GenerateTestData.createPricebook2();
        GenerateTestData.createPriceBookEntry();
        GenerateTestData.createAddress(); 
        GenerateTestData.createProposal();
               
        
        Apttus__APTS_Agreement__c apg = new Apttus__APTS_Agreement__c();
        apg.CurrencyIsoCode = 'USD';
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
        insert apg;
        
        Apttus_CMConfig__AgreementSummaryGroup__c acg = new Apttus_CMConfig__AgreementSummaryGroup__c();
        acg.Name = 'Test Aptus CMCongig';
        acg.Apttus_CMConfig__NetPrice__c = 100;
        acg.Apttus_CMConfig__ChargeType__c = 'Implementation Fee';
        acg.Apttus_CMConfig__AgreementId__c = apg.id;
        acg.Apttus_CMConfig__LineType__c = 'Category Total';
        acg.Apttus_CMConfig__ItemSequence__c = 109;
        acg.Apttus_CMConfig__LineNumber__c = 123;
        insert acg;
        
        System.debug('------apg-------'+apg);
        sb.SendEmailToCredit(GenerateTestData.proposal.Id,apg.Id);
        sb.SendEmailToAdmin();
        sb.StartProcess();
    }
}