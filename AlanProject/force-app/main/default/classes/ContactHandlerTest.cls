/*
*****************************************************************************************
    Name        : trimblecorpComTnvcussfdcoutbound_v4Test 
                            
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
 P M Mamata           19/07/2015          Created
*****************************************************************************************
*/

@isTest(seealldata = true)
private class ContactHandlerTest {
    static testmethod void testContactHandler(){
        ContactHandler cth = new ContactHandler();
        List<Contact> conList = new List<Contact>();
        GenerateTestData.createAccount();
        AccountCreationCalloutEX.recursiveCallFlag = false;
        GenerateTestData.createContact();
        update GenerateTestData.ct;
        conList.add(GenerateTestData.ct);
        ContactHandler.setLaunchControl();
        ContactHandler.validateDisableCallout(new List<Contact>{GenerateTestData.ct});
        ContactHandler.validateContactExternalKeyValue(new List<Contact>{GenerateTestData.ct},new Map<Id,Contact>{GenerateTestData.ct.Id=>GenerateTestData.ct});
        ContactHandler.resetLaunchControl();
        ContactHandler.configOutboundMessage(new List<Contact>{GenerateTestData.ct},new Map<Id,Contact>{GenerateTestData.ct.Id=>GenerateTestData.ct},new Map<Id,Contact>{GenerateTestData.ct.Id=>GenerateTestData.ct},true,false,false);
    }
}