@isTest
private class CaseAcceptOverrideControllerTest{
    
    public static List<Case> caseList;
     
    static void setUpData(){    
        caseList = new List<Case>();
        Case case1 = new Case();
        case1.I_need_assistance_with__c = 'Help or Training (e.g. how to export a report)';
        case1.Type = 'New Problem';
        case1.Status = 'New';
        case1.Subject = 'Test Subject';
        case1.Priority = 'Level 3: Medium';        
        caseList.add(case1);
        insert caseList;                        
    }   
    
    /**
     * Method name  : testCheckOwner
     * Description  : This method covers the positive scenarios of CaseAcceptOverrideController
     * Return Type  : void
     * Parameter    : None
     **/
    static testMethod void testCheckOwner(){
        setUpData();        
        Test.startTest();
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caseList);
        sc.setSelected(caseList);
        PageReference pageRef = Page.CaseAcceptOverride;        
        CaseAcceptOverrideController cao = new CaseAcceptOverrideController(sc); 
        cao.checkOwner();
        Test.stopTest();  
    }
    
    /**
     * Method name  : testRedirect
     * Description  : This method covers the positive scenarios of CaseAcceptOverrideController
     * Return Type  : void
     * Parameter    : None
     **/
    static testMethod void testRedirect(){
        setUpData();
        Test.startTest();
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caseList);
        sc.setSelected(caseList);
        PageReference pageRef = Page.CaseAcceptOverride;
        Test.setCurrentPage(pageRef);
        CaseAcceptOverrideController cao = new CaseAcceptOverrideController(sc); 
        cao.redirect();
        Test.stopTest();  
    }
    
    /**
     * Method name  : testRedirect
     * Description  : This method covers the negative scenarios of CaseAcceptOverrideController
     * Return Type  : void
     * Parameter    : None
     **/
    static testMethod void testNegativeCheckOwner(){
        Profile profile = [select Id from Profile where Name =: 'System Administrator'];    
        User user = new User();
        user.Username = 'sagamehta123@deloitte.com';
        user.Email = 'sagamehta@deloitte.com';
        user.LastName = 'Test';
        user.Alias = 'Test123';
        user.ProfileID = profile.Id;
        user.LocaleSidKey = 'en_US';
        user.LanguageLocaleKey = 'en_US';
        user.Country = 'India';
        user.Division__c = 'Infrastructure';
        user.TimeZoneSidKey = 'America/Los_Angeles';
        user.EmailEncodingKey='UTF-8';
        insert user;
        Group g = [Select Id from Group where DeveloperName = 'Plancal_Business_Support_Queue_CH'];        
        caseList = new List<Case>();
        Case case1 = new Case();
        case1.I_need_assistance_with__c = 'Help or Training (e.g. how to export a report)';
        case1.Type = 'New Problem';
        case1.Status = 'New';
        case1.Subject = 'Test Subject';
        case1.Priority = 'Level 3: Medium';
        case1.OwnerId = g.Id;        
        caseList.add(case1);
        insert caseList;                
        System.runAs(user) {            
            Test.startTest();
            ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caseList);
            sc.setSelected(caseList);
            PageReference pageRef = Page.CaseAcceptOverride;
            Test.setCurrentPage(pageRef);
            CaseAcceptOverrideController cao = new CaseAcceptOverrideController(sc); 
            cao.checkOwner();
        }    
        Test.stopTest();  
    }     
}