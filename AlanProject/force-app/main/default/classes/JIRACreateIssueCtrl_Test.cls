/*****************************************************************************************
Name        : JIRACreateIssueCtrl_Test 
Description : Test class for Create JIRA Issue from SFDC 
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
Suresh Babu         29/Sep/2016          Created
******************************************************************************************/
@isTest private class JIRACreateIssueCtrl_Test {
    static void setUpData(){
        JIRATestData_Generate.createCustomSettingRecords();
        JIRATestData_Generate.createAccount();
        JIRATestData_Generate.createContact();
        JIRATestData_Generate.createCases();
        JIRATestData_Generate.createDevelopments();
    }
    
    // Tests Create JIRA Issue from SFDC
    static testMethod void JIRACreateIssueCtrlTest1() {
        system.Test.startTest();
        setUpData();
        system.ApexPages.currentPage().getParameters().put('id', JIRATestData_Generate.pcs.Id);
        system.ApexPages.currentPage().getParameters().put('objType', 'Case');
        system.ApexPages.currentPage().getParameters().put('pKey', 'SFC');
        system.ApexPages.currentPage().getParameters().put('iType', '8');
        
        JIRACreateIssueCtrl ctrl = new JIRACreateIssueCtrl();
        
        ctrl.lstJIRADetails = new List<JIRACreateIssueCtrl.JIRAIssue>();
        JIRACreateIssueCtrl.JIRAIssue isu = new JIRACreateIssueCtrl.JIRAIssue();
        isu.url = 'www.google.com';
        isu.key = 'PO-1';
        isu.summary = 'test1';
        isu.project = 'test1';
        isu.reporter = 'test1';
        isu.status = 'test1';
        isu.resolution = 'test1';
        isu.type = 'test1';
        isu.assignee = 'test1';
        isu.description = 'test1';
        isu.priority = 'test1';
        isu.due_date = 'test1';
        
        ctrl.lstJIRADetails.add(isu);
        
        system.Test.setMock(HttpCalloutMock.class, new MockHttpResponseFetchJIRAIssue());
        ctrl.fetchLinkedIssues(JIRATextFixture.baseUrl, JIRATextFixture.systemId,
                                                         JIRATextFixture.objectType, JIRATextFixture.objectId, JIRATextFixture.projectKey, JIRATextFixture.issueType);
        system.Test.stopTest();
    }
    
    // Tests Create JIRA Issue from SFDC
    static testMethod void JIRACreateIssueCtrlTest2() {
        system.Test.startTest();
        setUpData();
        system.ApexPages.currentPage().getParameters().put('id', JIRATestData_Generate.pcs.Id);
        system.ApexPages.currentPage().getParameters().put('objType', 'Case');
        system.ApexPages.currentPage().getParameters().put('pKey', 'SFC');
        system.ApexPages.currentPage().getParameters().put('iType', '8');
        
        JIRACreateIssueCtrl ctrl = new JIRACreateIssueCtrl();
        
        system.Test.setMock(HttpCalloutMock.class, new MockHttpResponseCreateJIRAIssue());
        ctrl.doCallout();
        
        system.Test.stopTest();
    }
    
    // Tests Create JIRA Issue from SFDC
    static testMethod void JIRACreateIssueCtrlTest3() {
        system.Test.startTest();
        setUpData();
        system.ApexPages.currentPage().getParameters().put('id', JIRATestData_Generate.pcs1.Id);
        system.ApexPages.currentPage().getParameters().put('objType', 'Case');
        system.ApexPages.currentPage().getParameters().put('pKey', 'SFC');
        system.ApexPages.currentPage().getParameters().put('iType', '8');
        
        JIRACreateIssueCtrl ctrl = new JIRACreateIssueCtrl();
        
        system.Test.setMock(HttpCalloutMock.class, new MockHttpResponseFetchJIRAIssue());
        
        ctrl.doCallout();
        ctrl.cancelPage();
        system.Test.stopTest();
    }
    
    // Tests Create JIRA Issue from SFDC
    static testMethod void JIRACreateIssueCtrlTest4() {
        system.Test.startTest();
        setUpData();
        system.ApexPages.currentPage().getParameters().put('id', JIRATestData_Generate.dev1.Id);
        system.ApexPages.currentPage().getParameters().put('objType', 'Development__c');
        system.ApexPages.currentPage().getParameters().put('pKey', 'SFUST');
        system.ApexPages.currentPage().getParameters().put('iType', '8');
        
        JIRACreateIssueCtrl ctrl = new JIRACreateIssueCtrl();
        
        ctrl.lstJIRADetails = new List<JIRACreateIssueCtrl.JIRAIssue>();
        JIRACreateIssueCtrl.JIRAIssue isu = new JIRACreateIssueCtrl.JIRAIssue();
        isu.url = 'www.google.com';
        isu.key = 'PO-1';
        isu.summary = 'test1';
        isu.project = 'test1';
        isu.reporter = 'test1';
        isu.status = 'test1';
        isu.resolution = 'test1';
        isu.type = 'test1';
        isu.assignee = 'test1';
        isu.description = 'test1';
        isu.priority = 'test1';
        isu.due_date = 'test1';
        
        ctrl.lstJIRADetails.add(isu);
        
        system.Test.setMock(HttpCalloutMock.class, new MockHttpResponseFetchJIRAIssue());
        ctrl.fetchLinkedIssues(JIRATextFixture.baseUrl, JIRATextFixture.systemId,
                                                         'Development__c', JIRATextFixture.objectId, JIRATextFixture.projectKey, JIRATextFixture.issueType);
        system.Test.stopTest();
    }
    
    // Tests Create JIRA Issue from SFDC
    static testMethod void JIRACreateIssueCtrlTest5() {
        system.Test.startTest();
        setUpData();
        system.ApexPages.currentPage().getParameters().put('id', JIRATestData_Generate.dev1.Id);
        system.ApexPages.currentPage().getParameters().put('objType', 'Development__c');
        system.ApexPages.currentPage().getParameters().put('pKey', 'SFUST');
        system.ApexPages.currentPage().getParameters().put('iType', '8');
        
        JIRACreateIssueCtrl ctrl = new JIRACreateIssueCtrl();
        
        system.Test.setMock(HttpCalloutMock.class, new MockHttpResponseCreateJIRAIssue());
        ctrl.doCallout();
        
        system.Test.stopTest();
    }
    
    // Tests Create JIRA Issue from SFDC
    static testMethod void JIRACreateIssueCtrlTest6() {
        system.Test.startTest();
        setUpData();
        system.ApexPages.currentPage().getParameters().put('id', JIRATestData_Generate.dev2.Id);
        system.ApexPages.currentPage().getParameters().put('objType', 'Development__c');
        system.ApexPages.currentPage().getParameters().put('pKey', 'SFUST');
        system.ApexPages.currentPage().getParameters().put('iType', '8');
        
        JIRACreateIssueCtrl ctrl = new JIRACreateIssueCtrl();
        
        system.Test.setMock(HttpCalloutMock.class, new MockHttpResponseCreateJIRAIssue());
        ctrl.doCallout();
        
        system.Test.stopTest();
    }
}