/*
****************************************************************************************
    Name Controller        : customShiptolookupPageControllerTest 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
 P M Mamata           23/07/2015          created
*****************************************************************************************
*/

@isTest(seealldata = true)
 
private class customShiptolookupPageControllerTest {
    static testmethod void customShipTestMeth(){
    Test.setCurrentPageReference(new PageReference('Page.customshiptolookup')); 
       Id accid = [Select Id from Account limit 1].Id;
        System.currentPageReference().getParameters().put('accountid',accid);
        System.currentPageReference().getParameters().put('lksrch',accid);
        customShiptolookupPageController cs = new customShiptolookupPageController();
        cs.search();
        if(cs.asset.Address_line1__c != null)
        cs.saveAccount();
        cs.getFormTag();
        cs.getTextBox();
        cs.performSearch(accid,accid);
    }
}