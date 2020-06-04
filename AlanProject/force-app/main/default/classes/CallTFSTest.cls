/*****************************************************************************************
Name    : CallTFSTest 
Modification Log : 
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
P M Mamata       27/08/2015          Created
******************************************************************************************/
@isTest(seealldata=true)
private class CallTFSTest {
    static testmethod void meth1(){
        GenerateTestData.createAccount();
        GenerateTestData.createContact();
        GenerateTestData.createParentCase();
        GenerateTestData.createdefectCase();
        GenerateTestData.createCase();
        List<Id> idList = new List<Id>();
        idList.add(GenerateTestData.dcs.Id);
        CallTFS ctfs = new CallTFS(new ApexPages.StandardController(GenerateTestData.cs));
        ctfs.makeCallOut();
    }
}