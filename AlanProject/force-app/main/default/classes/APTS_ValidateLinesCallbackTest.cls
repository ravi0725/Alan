/**
* Company     : Trimble Software Technology Pvt Ltd.,
* Description : Controller class for CreateSSM
* History     :

* [16.10.2014] Ankur Patel  Created
*/
@isTest(seeAllData=true)
public class APTS_ValidateLinesCallbackTest{
  public static APTS_ValidateLinesCallback temp;
  private static testmethod void TestAPTS_ValidateLinesCallback1(){
    Test.startTest();
    temp = new APTS_ValidateLinesCallback();
    //GenerateTestData.customSettingRds();
    GenerateTestData.createPriceList();
    GenerateTestData.createAccount();
    GenerateTestData.createAddress();
    GenerateTestData.createOpportunity();
    GenerateTestData.createProduct2();
    GenerateTestData.createPricebook2();
    GenerateTestData.createPriceBookEntry();
    GenerateTestData.createProposal();
    GenerateTestData.createProposalSummary();

    Apttus_Proposal__Proposal__c proposal = GenerateTestData.proposal;
    Apttus_CPQApi.CPQ.CreateCartRequestDO request = new Apttus_CPQApi.CPQ.CreateCartRequestDO();
    request.QuoteId = proposal.Id;
    Apttus_CPQApi.CPQ.CreateCartResponseDO response = Apttus_CPQApi.CPQWebService.createCart(request);
    Id cartId = response.CartId;
    GenerateTestData.CreateLineItem(cartId);
    temp.validateCart(null);
    temp.validateRampLineItems(null,null);
    Test.stopTest();
  }
}