/*
****************************************************************************************
    Name Controller        : CreditCheckEmailNotTest 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
 P M Mamata           24/07/2015          created
*****************************************************************************************
*/
@istest(seealldata=true)
private class CreditCheckEmailNotTest {
    static testmethod void CreditCheckEmailMeth(){
        GenerateTestData.createAccount();    
        Credit_Details_Tab_Customer_Account__c cd = new Credit_Details_Tab_Customer_Account__c();
        cd.Available_Credit_Line_ACL__c = 100.00;
        cd.Account__c = GenerateTestData.acct.Id;
        cd.Currency__c = 'USD';
        insert cd;
        PageReference pRef = Page.CreditCheckEmailNotificationOppty; 
        System.debug('----------GenerateTestData.acct.Id------------'+GenerateTestData.acct.Id);
		pRef.getParameters().put('AcctId', GenerateTestData.acct.Id);
        pRef.getParameters().put('Currency', 'USD');        
        Test.setCurrentPage(pRef);
        CreditCheckEmailNotControllerAgree  ca = new CreditCheckEmailNotControllerAgree();
        ca.closePopup();
        ca.showPopup();
        ca.Cont();
        ca.SendEmail();
    }
}