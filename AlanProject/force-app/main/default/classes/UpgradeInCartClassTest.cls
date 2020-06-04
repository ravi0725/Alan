/**
 * Company     : Trimble Software Technology Pvt Ltd.,
 * Description : Controller class for CreateSSM
 * History     :  

 * [16.10.2014] Ankur Patel  Created
 */
 @isTest(seeAllData=true)
public class UpgradeInCartClassTest{
    private static testmethod void TestUpgradeInCartClass1(){
        Test.startTest();
            //GenerateTestData.customSettingRds();
            GenerateTestData.createPriceList();
            GenerateTestData.createAccount();
            GenerateTestData.createAddress();
            GenerateTestData.createOpportunity();
            GenerateTestData.createProduct2();
            GenerateTestData.createPricebook2();
            GenerateTestData.createPriceBookEntry();  
            GenerateTestData.createProposal();
            //GenerateTestData.createProposalSummary();
            GenerateTestData.createAsset();
            Asset Ass = GenerateTestData.asst;
            Product2 Prr = GenerateTestData.Prd; 
            Apttus_Proposal__Proposal__c proposal = GenerateTestData.proposal;
            Apttus_CPQApi.CPQ.CreateCartRequestDO request = new Apttus_CPQApi.CPQ.CreateCartRequestDO();
            request.QuoteId = proposal.Id;
            Apttus_CPQApi.CPQ.CreateCartResponseDO response = Apttus_CPQApi.CPQWebService.createCart(request);
            Id cartId = response.CartId;
            GenerateTestData.CreateLineItem(cartId);
            GenerateTestData.createTempObject(cartId);
            GenerateTestData.createAssetLineItem();
            ApexPages.CurrentPage().getParameters().put('configRequestId',GenerateTestData.tempObj.Id);
            ApexPages.CurrentPage().getParameters().put('id',cartId);
            UpgradeInCartClass temp = new UpgradeInCartClass();
           temp.selectedAssetId = Ass.Id;
          
            if(temp.AssWrapList.size() > 0){
                temp.AssWrapList.get(0).Checked = true;
                temp.AssWrapList.get(0).cat.ID = Ass.Id;
                temp.AssWrapList.get(0).cat.Available_Quantity__c=2;
                temp.AssWrapList.get(0).cat.Quantity_To_be_Upgraded__c=2;
                temp.AssWrapList.get(0).cat.Reason_Code__c = 'Upgrade';
                temp.AssWrapList.get(0).cat.Updated_Price__c = 2500;
                temp.AssWrapList.get(0).cat.Quantity = 2;
                temp.AssWrapList.get(0).cat.Product2Id=Prr.id; 
            }
            
             
           // temp.gotoPricing();
           
        Test.stopTest();
    }  
    
    private static testmethod void TestUpgradeInCartClass2(){
        Test.startTest();
            //GenerateTestData.customSettingRds();
            GenerateTestData.createPriceList();
            GenerateTestData.createAccount();
            GenerateTestData.createAddress();
            GenerateTestData.createOpportunity();
            GenerateTestData.createProduct2();
            GenerateTestData.createPricebook2();
            GenerateTestData.createPriceBookEntry();   
            GenerateTestData.createProposal();
            //GenerateTestData.createProposalSummary();
            GenerateTestData.createAsset();
            
            
            Apttus_Proposal__Proposal__c proposal = GenerateTestData.proposal;
            Apttus_CPQApi.CPQ.CreateCartRequestDO request = new Apttus_CPQApi.CPQ.CreateCartRequestDO();
            request.QuoteId = proposal.Id;
            Apttus_CPQApi.CPQ.CreateCartResponseDO response = Apttus_CPQApi.CPQWebService.createCart(request);
            Id cartId = response.CartId;
            GenerateTestData.CreateLineItem(cartId);
            GenerateTestData.createTempObject(cartId);
            GenerateTestData.createAssetLineItem();
            ApexPages.CurrentPage().getParameters().put('configRequestId',GenerateTestData.tempObj.Id);
            ApexPages.CurrentPage().getParameters().put('id',cartId);
            UpgradeInCartClass temp = new UpgradeInCartClass();
            temp.gotoPricing();
            
        Test.stopTest();
    }  
}