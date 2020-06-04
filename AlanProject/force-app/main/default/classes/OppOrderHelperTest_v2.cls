@isTest(seealldata=true)
public class OppOrderHelperTest_v2{
    static testmethod void OrderHelperMeth(){
        
        GenerateTestData.createAccount();
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();        
        GenerateTestData.createAddress();
        GenerateTestData.createProposal();
        GenerateTestData.createProduct2();
        Test.startTest();
        Apttus_Config2__ProductConfiguration__c acpcfg = new Apttus_Config2__ProductConfiguration__c();
        acpcfg.Name = 'test acpcfg';
        acpcfg.Apttus_QPConfig__Proposald__c = GenerateTestData.proposal.Id;
        acpcfg.Apttus_Config2__PriceListId__c = GenerateTestData.pricelist.Id;
        insert acpcfg;
         
        Order__c ord = new Order__c();
        ord.Account__c = GenerateTestData.acct.Id;
        ord.Related_Quote_Proposal__c = GenerateTestData.proposal.Id;
        Ord.Oracle_Order_Number__c = '1007';
        ord.Order_Status__c = 'BOOKED';
        insert ord;
        
        Order__c ord1 = new Order__c();
        ord1.Account__c = GenerateTestData.acct.Id;
        ord1.Related_Quote_Proposal__c = GenerateTestData.proposal.Id;
        ord1.Oracle_Order_Number__c = '1007';
        ord1.Order_Status__c = 'CLOSED';
        insert ord1;
        Test.stopTest();
    }
}