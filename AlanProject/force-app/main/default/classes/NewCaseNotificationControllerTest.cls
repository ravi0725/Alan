/*****************************************************************************************
Name    : NewCaseNotificationControllerTest 
Modification Log : 
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
P M Mamata       28/08/2015          Created
******************************************************************************************/
@isTest(seealldata=true)
private class NewCaseNotificationControllerTest {
    static testmethod void meth1(){
       	List<UserRole> r = new List<UserRole>([SELECT Id FROM UserRole WHERE Name = 'GCCM - Support Manager']);
        if(r.size() > 0){
            User u = new user();
            u.Id = userInfo.getUserId();
            u.UserRoleId = r.get(0).Id;
            update u;
        }
        NewCaseNotificationController ncnc = new NewCaseNotificationController();
        ncnc.caseDetails();    
    }
    
    static testmethod void meth2(){
        GenerateTestData.createAccount();
        GenerateTestData.createContact();
        GenerateTestData.createParentCase();
        NewCaseNotificationController ncnc = new NewCaseNotificationController();       
        ncnc.CaseIds = GenerateTestData.pcs.Id;
        ncnc.notifyUserFlag = true;
        ncnc.caseDetails();   
    }
    static testmethod void meth3(){
        List<User> u = [SELECT Id FROM User WHERE UserRole.Name = 'RE&WS Support Manager - Americas' AND IsActive = True];
        if(u.size() > 0){
            System.runAs(u.get(0)){
                NewCaseNotificationController ncnc = new NewCaseNotificationController();   
            }
        }        
    }
    
    static testmethod void TAPNewCaseNotificationMethod1(){
        // Setup test data
        // Create a unique UserName
        String uniqueUserName = 'Admin' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name like 'TAP%' limit 1];
        User u = new User(Alias = 'ur1234', Email=uniqueUserName,
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName , Division__c = 'TAP');
        
        System.runAs(u){
            NewCaseNotificationController ncnc = new NewCaseNotificationController();   
        }
    }
}