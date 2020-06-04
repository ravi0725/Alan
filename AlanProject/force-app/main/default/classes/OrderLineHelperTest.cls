@isTest(seealldata=true)
public class OrderLineHelperTest{
    static testmethod void OrderLineHelperMeth(){
        
        GenerateTestData.createAccount();
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();
        GenerateTestData.createAddress();
        GenerateTestData.createProposal();
        GenerateTestData.createProduct2();
        Apttus_Config2__ProductConfiguration__c acpcfg = new Apttus_Config2__ProductConfiguration__c();
        acpcfg.Name = 'test acpcfg';
        acpcfg.Apttus_QPConfig__Proposald__c = GenerateTestData.proposal.Id;
        acpcfg.Apttus_Config2__PriceListId__c = GenerateTestData.pricelist.Id;
        insert acpcfg;
        
        Order__c ord = new Order__c();
        ord.Account__c = GenerateTestData.acct.Id;
        ord.Related_Quote_Proposal__c = GenerateTestData.proposal.Id;
        ord.Order_Status__c = 'BOOKED';
        insert ord;
        
        Order_Line_Item__c OrdLi = new Order_Line_Item__c();
        OrdLi.Order__c = Ord.id;
        OrdLi.Order_Line_Order_Status__c ='CLOSED';
        insert OrdLi;
        
        Order_Line_Item__c  OrdLiUp = new Order_Line_Item__c(id=OrdLi.id);
        Update OrdLiup; 
        
    }
}