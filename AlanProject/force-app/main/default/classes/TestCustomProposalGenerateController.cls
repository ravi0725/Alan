/**
 * Company     : Trimble Software Technology Pvt Ltd.,
 * Description : 
 * History     :  

 * [30.4.2015] Ankur Patel  Created
 */
 @isTest(seeAllData = true)
public class TestCustomProposalGenerateController{
    private static testmethod void TestCustomProposalGenerateController1(){
        //GenerateTestData.customSettingRds();
        GenerateTestData.createAccount();
        GenerateTestData.createAddress();
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();
        GenerateTestData.createProduct2();
        //GenerateTestData.createPricebook2();
        //GenerateTestData.createPriceBookEntry();
        GenerateTestData.createProposal();
        system.debug('----proposal----'+GenerateTestData.Proposal);
        GenerateTestData.createAttachment();
        
        Apttus_Proposal__Proposal__c proposal = [select Id,User_s_Legal_Entity__c,Apttus_QPConfig__PriceListId__c from 
                            Apttus_Proposal__Proposal__c where Id =: GenerateTestData.proposal.Id];
        system.debug('-------------proposal------------' + proposal);  
        //GenerateTestData.createProposalSummary();
        //GenerateTestData.CreateProposalLineItem();
        //GenerateTestData.createProposalSummaryGroup();
        apexpages.currentpage().getParameters().put('Id',GenerateTestData.proposal.Id);
        Test.startTest();
            CustomProposalGenerateController temp = new CustomProposalGenerateController();
            temp.assignSessionId();
            if(temp.AttWrapList.size() > 0){
                temp.AttWrapList.get(0).checked = true;
            }
            temp.gotoPresent();
            temp.generateRandomNumber();
            temp.createEmailTemplate();
        Test.stopTest();
    }
}