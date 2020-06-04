/*
****************************************************************************************
    Name Controller        : CreditCheckEmailServiceTest 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
 P M Mamata           26/07/2015          created
*****************************************************************************************
*/
@istest(seealldata=true)
private class CreditCheckEmailServiceTest {
    static testmethod void creditcheckEmailMeth(){
        
        GenerateTestData.createAccount();
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();
        GenerateTestData.createAddress();
        GenerateTestData.createProposal();
        
        Apttus_Proposal__Proposal__c app = [SELECT Name FROM Apttus_Proposal__Proposal__c WHERE Id =:GenerateTestData.proposal.Id];
        System.debug('-----------GenerateTestData.proposal---------------'+GenerateTestData.proposal);
        System.debug('-----------GenerateTestData.proposal.Name---------------'+GenerateTestData.proposal.Name);
        System.debug('-----------Apttus_Proposal__Proposal__c app---------------'+app);
        
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        
        email.Subject = app.Name;
        email.plainTextBody = 'approved Test email plain tectbody approved email body\n approve 2225256325\n approvedTitle';
        email.fromAddress = 'someaddress@email.com';
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
                                                     
        
       /* GenerateTestData.createAPTSAgreement();
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
        apg.Apttus_QPComply__RelatedProposalId__c = app.Id;
        apg.Apttus__Status_Category__c = 'Credit Check Hold';
        apg.Apttus__Status__c='Hold';
        apg.Apttus_CMConfig__PriceListId__c = GenerateTestData.pricelist.Id;
        insert apg;*/
        CreditCheckEmailService cces = new CreditCheckEmailService();
        cces.handleInboundEmail(email,envelope);
       // System.debug('----Q-00030281------apg.Apttus_QPComply__RelatedProposalId__r.Name------------'+apg.Apttus_QPComply__RelatedProposalId__r.Name);
       // Apttus__APTS_Agreement__c apgs = [Select id,Apttus__Status_Category__c ,Apttus__Status__c,Credit_Status__c,Credit_Approved__c,Fusion_Project_Number__c,Total_Agreement_Value_Formula__c,Apttus__Contract_Start_Date__c, Apttus__Contract_End_Date__c from Apttus__APTS_Agreement__c where Id =: apg.Id];
       // System.debug('=========apgs==========='+apgs+'=============app.Name============'+app.Name);
        
        //CreditCheckEmailService.CallEBSForSubmitOrder(GenerateTestData.proposal.Id,apg.Id);
        
    }
}