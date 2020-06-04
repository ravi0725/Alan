/*
****************************************************************************************
    Name Controller        : Cross_Division_Quote_ApprovalCntrlTest 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
 P M Mamata           19/08/2015          Created
*****************************************************************************************
*/

@isTest(seealldata=true)
private class Cross_Division_Quote_ApprovalCntrlTest {
   
    static testmethod void TestCrossDivision(){
    	Test.setCurrentPageReference(new PageReference('Page.Cross_Division_Quote_Approval'));
        GenerateTestData.createAccount();
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();
        
        System.currentPageReference().getParameters().put('id', GenerateTestData.opp.Id);
        System.currentPageReference().getParameters().put('id', GenerateTestData.acct.Id);
    	Cross_Division_Quote_ApprovalCntrl cd = new Cross_Division_Quote_ApprovalCntrl();  
        cd.closePopup();
        cd.showPopup();
        cd.exit();
        cd.SendEmail();
    }
    

}