/*
****************************************************************************************
    Name Controller        : CreateQuoteFromOpptyTest 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
 Suresh Babu           24/01/2018       Created
*****************************************************************************************
*/
@isTest(seealldata=true)
public class CreateQuoteFromOpptyTest {
	static testmethod void CreditCheckMeth(){
        GenerateTestData.createAccount();
        GenerateTestData.createAddress();
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity(); 
        
        ApexPages.StandardController sc = new ApexPages.StandardController(GenerateTestData.opp);
        CreateQuoteFromOppty cOpp = new CreateQuoteFromOppty(sc);
        
        PageReference pRef = Page.CreateQuoteFromOpptyPage;
        pRef.getParameters().put('id', GenerateTestData.acct.Id);		
        Test.setCurrentPage(pRef);
        
        cOpp.cont();
        cOpp.test();
    }
}