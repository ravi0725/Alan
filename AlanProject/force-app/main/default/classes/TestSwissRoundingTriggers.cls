/**
 * Company     : Trimble Software Technology Pvt Ltd.,
 * Description : Controller class for CreateSSM
 * History     :  

 * [16.10.2014] Ankur Patel  Created
 */
 @isTest(seeAllData=true)
public class TestSwissRoundingTriggers{
    private static testmethod void TestRoundingonProposalLineItem1(){
        Test.startTest();
            //GenerateTestData.customSettingRds();
            GenerateTestData.createAccount();
        	GenerateTestData.createAddress();
            GenerateTestData.createPriceList();
            GenerateTestData.createOpportunity();
            GenerateTestData.createProduct2();
            GenerateTestData.createPricebook2();
            GenerateTestData.createPriceBookEntry();
            GenerateTestData.createProposal();
            system.debug('-------------PriceList------------' + [select Legal_Entity__c,Apttus_Config2__Active__c from 
                                Apttus_Config2__PriceList__c where Id =: GenerateTestData.PriceList.Id]); 
            Apttus_Proposal__Proposal__c proposal = [select Id,User_s_Legal_Entity__c,Apttus_QPConfig__PriceListId__c from 
                                Apttus_Proposal__Proposal__c where Id =: GenerateTestData.proposal.Id];
            system.debug('-------------proposal------------' + proposal);  
            GenerateTestData.createProposalSummary();
            GenerateTestData.CreateProposalLineItem();
            GenerateTestData.createProposalSummaryGroup();
                      
            Apttus_Proposal__Proposal_Line_Item__c proposalLiTm = [select Id,Price_List_Legal_Entity__c from 
                                Apttus_Proposal__Proposal_Line_Item__c where Id =: GenerateTestData.proposalLiTm.Id];
            proposalLiTm.Extended_Price_Disp_Rounding__c = 100.12;
            proposalLiTm.Base_Price_Disp_Rounded__c = 100.12;
            system.debug('-------------proposalLiTm------------' + proposalLiTm.Price_List_Legal_Entity__c);
            update proposalLiTm;
            
            
        Test.stopTest();
    }
    
     private static testmethod void TestRoundingonProposalLineItem2(){
        Test.startTest();
            //GenerateTestData.customSettingRds();
            GenerateTestData.createAccount();
         	GenerateTestData.createAddress();
            GenerateTestData.createOtherPriceList();
            GenerateTestData.createOpportunity();
            GenerateTestData.createProduct2();
            GenerateTestData.createPricebook2();
            GenerateTestData.createPriceBookEntry();
            GenerateTestData.createProposal();
            system.debug('-------------PriceList------------' + [select Legal_Entity__c,Apttus_Config2__Active__c from 
                                Apttus_Config2__PriceList__c where Id =: GenerateTestData.PriceList.Id]); 
            Apttus_Proposal__Proposal__c proposal = [select Id,User_s_Legal_Entity__c,Apttus_QPConfig__PriceListId__c from 
                                Apttus_Proposal__Proposal__c where Id =: GenerateTestData.proposal.Id];
            system.debug('-------------proposal------------' + proposal);  
            GenerateTestData.createProposalSummary();
            GenerateTestData.CreateProposalLineItem();
            GenerateTestData.createProposalSummaryGroup();
                      
            Apttus_Proposal__Proposal_Line_Item__c proposalLiTm = [select Id,Price_List_Legal_Entity__c from 
                                Apttus_Proposal__Proposal_Line_Item__c where Id =: GenerateTestData.proposalLiTm.Id];
            proposalLiTm.Extended_Price_Disp_Rounding__c = 100.12;
            proposalLiTm.Base_Price_Disp_Rounded__c = 100.12;
            system.debug('-------------proposalLiTm------------' + proposalLiTm.Price_List_Legal_Entity__c);
            update proposalLiTm;
            
            
        Test.stopTest();
    }
}