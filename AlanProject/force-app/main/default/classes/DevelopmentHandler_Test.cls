/*****************************************************************************************
Name        : DevelopmentHandler_Test 
Description : Test class for Create JIRA Issue from SFDC 
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
Suresh Babu         15/Dec/2016          Created
******************************************************************************************/
@isTest private class DevelopmentHandler_Test {
    private static Profile prf = [Select Id from Profile where Name =: Label.API_Only];
    private static User apiUser;
    
    static void setUpData2(){
        Double rnNo = math.random() +2;
        apiUser = new User(ProfileId = prf.Id,Username = System.now().millisecond() + String.valueOf(rnNo)+ 'test2@test.com',
                           Alias = 'Test', Email='test@test.com',EmailEncodingKey='UTF-8', Firstname='TFS',Lastname='API User',LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US',TimeZoneSidKey='America/Chicago',Country='India',Division__c='Architecture');
        
        insert apiUser;
    }
    
    static void setUpData(){
        JIRATestData_Generate.createCustomSettingRecords();
        JIRATestData_Generate.createAccount();
        JIRATestData_Generate.createContact();
        JIRATestData_Generate.createCases();
        JIRATestData_Generate.createTechOps();
        JIRATestData_Generate.createDevelopments();
        
        User u = [SELECT Id, Division__c FROM USER WHERE Id =: system.UserInfo.getUserId()];
        u.Division__c = 'RE&WS';
        update u;
    }
    
    static testMethod void DevelopmentHandler_Test1(){
        system.Test.startTest();
        setUpData();
        // RESET Recurrence
        DevelopmentHandler.resetLaunchControl();
        
        JIRATestData_Generate.dev1.Code_Fix_Information__c = 'TEST Update';
        JIRATestData_Generate.dev1.Description__c = 'Desc Update';
        JIRATestData_Generate.dev1.JIRA_Code_Fix_Information__c = 'update 1';
        JIRATestData_Generate.dev1.JIRA_Description__c = 'jira desc';
        JIRATestData_Generate.dev1.JIRA_Status__c = 'Fix Failed';
        JIRATestData_Generate.dev1.JIRA_Issue_Assigned_User__c = 'agelber';
        update JIRATestData_Generate.dev1;
        
        // RESET Recurrence
        DevelopmentHandler.resetLaunchControl();
        JIRATestData_Generate.dev2.Code_Fix_Information__c = 'TEST Update';
        JIRATestData_Generate.dev2.Description__c = 'Desc Update';
        JIRATestData_Generate.dev2.JIRA_Code_Fix_Information__c = 'update 1';
        JIRATestData_Generate.dev2.JIRA_Description__c = 'jira desc';
        JIRATestData_Generate.dev2.JIRA_Status__c = 'Fix Failed';
        JIRATestData_Generate.dev2.JIRA_Issue_Assigned_User__c = 'agelber';
        update JIRATestData_Generate.dev2;
        
        // RESET Recurrence
        DevelopmentHandler.resetLaunchControl();
        JIRATestData_Generate.dev2.JIRA_Sync_Processing__c = false;
        JIRATestData_Generate.dev2.Code_Fix_Information__c = 'TEST Update';
        JIRATestData_Generate.dev2.Description__c = '<a href="https://www.google.com" target="_blank">test</a><br><a href="mailto:testmail@tst.cc" target="_blank">mail</a><br>test<br><img alt="User-added image" src="www.test.com/tst.png" style="height: 50px; width: 50px;"></img><br>ol><li>test 3</li><li>test 4</li></ol><br>ul><li>test1</li><li>test 2</li></ul><br><img alt="User-added image" src="www.test.com/tst.png"></img><ul><li>test1</li><li>test 2</li></ul><ol><li>test 3</li><li>test 4</li></ol>';
        JIRATestData_Generate.dev2.JIRA_Code_Fix_Information__c = 'update 1';
        JIRATestData_Generate.dev2.JIRA_Description__c = '[test|https://www.google.com]\n'+
            '[mailto:testmail@tst.cc]\n'+
            'test\n'+
            '!ww.test.com/tst.png|height= 50px; width= 50px;!\n'+
            '!ww.test.com/tst.png!\n\n'+
            '* test1\n'+
            '* test 2\n'+
            '# test 3\n'+
            '# test 4';
        JIRATestData_Generate.dev2.JIRA_Status__c = 'Fix Failed';
        JIRATestData_Generate.dev2.JIRA_Issue_Assigned_User__c = 'agelber';
        update JIRATestData_Generate.dev2;
        
        String emptyString;
        JIRA_HTMLtoWIKIConverter.convertHTMLtoWIKI(emptyString);
        
        String WIKItoHTML = '[test|https://www.google.com]\n'+
            '[mailto:testmail@tst.cc]\n'+
            'test\n'+
            '!ww.test.com/tst.png|height= 50px; width= 50px;!\n'+
            '!ww.test.com/tst.png!\n\n'+
            '* test1\n'+
            '* test 2\n'+
            '# test 3\n'+
            '# test 4';
        JIRA_HTMLtoWIKIConverter.convertWIKItoHTML(emptyString);
        JIRA_HTMLtoWIKIConverter.convertWIKItoHTML(WIKItoHTML);
        system.Test.stopTest();
    }
    
    static testMethod void DevelopmentHandler_Test2(){
        system.Test.startTest();
        setUpData();
        // RESET Recurrence
        DevelopmentHandler.resetLaunchControl();
        JIRATestData_Generate.dev2.JIRA_Code_Fix_Information__c = 'update 1';
        JIRATestData_Generate.dev2.JIRA_Description__c = 'jira desc';
        JIRATestData_Generate.dev2.JIRA_Status__c = 'Fix Failed';
        JIRATestData_Generate.dev2.JIRA_Issue_Assigned_User__c = 'agelber';
        update JIRATestData_Generate.dev2;
        
        system.Test.stopTest();
    }
    
    static testMethod void DevelopmentHandler_Test3(){
        system.Test.startTest();
        setUpData();
        setUpData2();
        
        system.runAs(apiUser){
            // RESET Recurrence
            DevelopmentHandler.resetLaunchControl();
            JIRATestData_Generate.dev2.OwnerId = apiUser.Id;
            update JIRATestData_Generate.dev2;
        }
        system.Test.stopTest();
    }

    static testMethod void DevelopmentHandler_Test4(){
        system.Test.startTest();
        setUpData();
        // RESET Recurrence
        DevelopmentHandler.resetLaunchControl();
        JIRATestData_Generate.dev2.Target_Release__c = 'CS_32';
        update JIRATestData_Generate.dev2;
        
        system.Test.stopTest();
    }

    static testMethod void DevelopmentHandler_Test5(){
        system.Test.startTest();
        setUpData();
        
        // RESET Recurrence
        DevelopmentHandler.resetLaunchControl();
        DevelopmentHandler.launchControl.put('JIRASyncProcess', 1);
        JIRATestData_Generate.dev2.JIRA_Issue_ID__c = 'SFC-123';
        JIRATestData_Generate.dev2.Target_Release__c = 'CS_32';
        update JIRATestData_Generate.dev2;
        system.Test.stopTest();
    }
}