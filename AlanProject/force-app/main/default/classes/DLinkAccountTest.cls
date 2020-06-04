/*
*****************************************************************************************
    Name        : DLinkAccount Test class 
                            
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
 P M Mamata           20/07/2015          Created
*****************************************************************************************
*/

@isTest(seeAllData=true)
private class DLinkAccountTest {
    static testmethod void dLinkTestMethod1(){
        GenerateTestData.createAccount();   
        System.currentPageReference().getParameters().put('Id', GenerateTestData.acc.Id);
        DLinkAccount dLink = new DLinkAccount(); 
        dLink.UpdateChildRecords();
    }
}