/*
*****************************************************************************************
    Name        : trimblecorpComTnvcussfdcoutbound_v1Test 
                            
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
 P M Mamata           19/07/2015          Created
*****************************************************************************************
*/

@isTest(seeAllData=true)
private class MultiselectControllerTest{
    static testmethod void testtrimble(){
        MultiselectController temp = new MultiselectController();
        temp.rightOptions = new List<SelectOption>();
        temp.leftOptions = new List<SelectOption>();
        temp.leftOptionsHidden = 'test&test';
        temp.rightOptionsHidden = 'test1&test1';
        temp.totalAvail = 2;
        temp.totalSelected = 1;
    }
    

}