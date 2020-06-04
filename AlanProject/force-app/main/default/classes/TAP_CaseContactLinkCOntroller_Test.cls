@isTest(seealldata = true)

private class TAP_CaseContactLinkCOntroller_Test {
    static testmethod void TAP_CaseContactLinkCOntroller_Test() {
        test.startTest();
        GenerateTestData.createAccount();
        GenerateTestData.createContact();
        GenerateTestData.createParentCase();

        CaseHandler.resetLaunchControl();
        Case cs = new Case();
        cs.AccountId = GenerateTestData.acct.Id;
        cs.ContactId = GenerateTestData.ct.Id;
        cs.Status = 'New';
        cs.suppliedemail = 'a@a.com';
        insert cs;
            
        ApexPages.StandardController sc = new ApexPages.StandardController(cs);
        TAP_CaseContactLinkController tap = new TAP_CaseContactLinkController(sc);
        
        PageReference pageRef = Page.TAP_CaseContactLink_Page;
        pageRef.getParameters().put('id', String.valueOf(cs.Id));
        Test.setCurrentPage(pageRef);
    }
}