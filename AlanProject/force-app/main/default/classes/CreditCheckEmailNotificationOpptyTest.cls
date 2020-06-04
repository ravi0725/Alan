/*
****************************************************************************************
    Name Controller        : custombilltolookupPageControllerTest 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
 P M Mamata           23/07/2015          created
*****************************************************************************************
*/
@isTest(seealldata = true)
private class CreditCheckEmailNotificationOpptyTest {
    static testmethod void CreditCheckEmailMeth(){        
        GenerateTestData.createAccount();
        //GenerateTestData.createOpportunity();
        PageReference pRef = Page.CreditCheckEmailNotificationOppty; 
        System.debug('----------GenerateTestData.acct.Id------------'+GenerateTestData.acct.Id);
		pRef.getParameters().put('AcctId', GenerateTestData.acct.Id);		
        //pRef.getParameters().put('id', GenerateTestData.opp.Id);
        Test.setCurrentPage(pRef);
		
        CreditCheckEmailNotificationOppty cc = new CreditCheckEmailNotificationOppty();
        cc.closePopup();
        cc.showPopup();
        cc.cont();
        cc.SendEmail();
        
    }
}