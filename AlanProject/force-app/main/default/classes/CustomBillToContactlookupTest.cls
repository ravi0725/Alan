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
private class CustomBillToContactlookupTest {
    static testmethod void CustomBillMeth(){
        Id accid = [Select Id from Account limit 1].Id;
        System.currentPageReference().getParameters().put('accountid',accid);
        System.currentPageReference().getParameters().put('lksrch',accid);
		CustomBillToContactlookupPageController cb = new CustomBillToContactlookupPageController();
        
        system.debug('----------' + accId);
		cb.search();
		cb.getFormTag();
		cb.getTextBox();        
        
    }
}