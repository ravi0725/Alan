/*
****************************************************************************************
 Name Controller        : TechServiceHandlerTest 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
 P M Mamata           29/08/2015          created
*****************************************************************************************
*/
@istest(seealldata=true)
private class TechServiceHandlerTest {
    static testmethod void meth1(){
        
        GenerateTestData.createAccount();
        GenerateTestData.createContact();
        GenerateTestData.createParentCase();
        TechServiceHandler tsh = new TechServiceHandler();
        List<Tech_Service__c> newtechList = new List<Tech_Service__c>();
        Tech_Service__c ts = new Tech_Service__c();
        ts.Product__c = 'Proliance Customer Solutions';
        ts.Title__c = 'test title';
        ts.Status__c = 'New';
        ts.Type__c = 'Defect';
        ts.System_Case_Id__c = GenerateTestData.pcs.Id;
        insert ts;
        newtechList.add(ts);
        TechServiceHandler.resetLaunchControl();
        TechServiceHandler.attachTechServicesToCase(newtechList);
        TechServiceHandler.clearFields(newtechList);
        
        update ts;
    }
}