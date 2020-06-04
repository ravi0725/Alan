/**
 * Company     : Trimble Software Technology Pvt Ltd.,
 * Description : Test class for SyncWithOpportunityExt
 * History     :  

 * [12.1.2015] Ankur Patel  Created
 */
 @isTest(seeAllData=true)
public class TestSyncWithOpportunityExt{
    static void setUpData(){
        GenerateTestData.createAccount();
        GenerateTestData.createAddress();
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();
        GenerateTestData.createProduct2();
        GenerateTestData.createPricebook2();
        GenerateTestData.createPriceBookEntry();
        GenerateTestData.createProposal();
        GenerateTestData.createProposalSummary();
        GenerateTestData.CreateProposalLineItem();
        GenerateTestData.createProposalSummaryGroup();
    }
    
    private static testmethod void TestMethod1(){
        setUpData();
        Test.startTest();
           ApexPages.StandardController sc = new ApexPages.StandardController(GenerateTestData.proposal);
           SyncWithOpportunityExt temp = new SyncWithOpportunityExt(sc);
           temp.UpdateOppty();
        Test.stopTest();
    } 
    
    private static testmethod void TestMethod2(){
        setUpData();
        Test.startTest();
            PriceBookEntry pbe = new PriceBookEntry();
            pbe.CurrencyISOCode = 'USD';
            pbe.PriceBook2ID = [select ID,PriceBook2Id from Opportunity where Id =: GenerateTestData.opp.Id].PriceBook2Id;
            pbe.Product2Id = GenerateTestData.prd.Id;
            pbe.IsActive = true;
            pbe.UnitPrice = 1;
            pbe.UseStandardPrice = false;
            insert pbe;
        
           OpportunityLineItem oppLiTm = new OpportunityLineItem();
           oppLiTm.OpportunityId = GenerateTestData.opp.Id;
           oppLiTm.PriceBookEntryId = pbe.Id;
           oppLiTm.Quantity = 10;
           oppLiTm.UnitPrice = 10;
           insert oppLiTm;
           ApexPages.StandardController sc = new ApexPages.StandardController(GenerateTestData.proposal);
           SyncWithOpportunityExt temp = new SyncWithOpportunityExt(sc);
           temp.UpdateOppty();
        Test.stopTest();
    }   
}