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

private class custombilltolookupPageControllerTest {
    
    static testmethod void custombillMeth(){
           Id accid = [Select Id from Account limit 1].Id;
        System.currentPageReference().getParameters().put('accountid',accid);
        System.currentPageReference().getParameters().put('lksrch',accid);
        custombilltolookupPageController cb = new custombilltolookupPageController();
             
        cb.search();
        if(cb.asset.Address_line1__c != null)
            cb.saveAccount();
        
        cb.getFormTag();
        cb.getTextBox();              
        cb.performSearch(accid,accid);
    }
    
}