/*****************************************************************************************
    Name    : LeadCreationFromReferalControllerTest 
    Desc    : Used for test coverage of the code implemented in LeadCreationFromReferalController class. 
                            
    Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Ashfaq Mohammed       5/27/2013          Created
******************************************************************************************/
@isTest
public class LeadCreationFromReferalControllerTest {
    
    /**
     * Method name  : testReferral
     * Description  : This method covers the positive scenarios of LeadCreationFromReferalController
     * Return Type  : void
     * Parameter    : None
     **/
    static testMethod void testReferral() { 
        Test.startTest();
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
        System.runAs(user) {        
            Referral__c referral = new Referral__c();
            //referral.Name = 'Test Referral'; 
            referral.Contact_First_Name__c = 'Test First Name';
            referral.Contact_Last_Name__c = 'Test Last Name'; 
            referral.Phone__c = '9820098200';
            referral.Company__c = 'Test Company';
            referral.Email__c = 'sagamehta@deloitte.com';
            referral.Description__c = 'Test Desc'; 
            referral.Street__c = 'Test Street';
            referral.City__c = 'Test City';
            referral.State_Province__c = 'Test State';
            referral.Country__c = 'Test Country';
            referral.Zip_Postal_Code__c = '400068';
            referral.Product_Type__c = 'Test Product Type';
            referral.Ownerid = user.Id;
            insert referral;
                        
            ApexPages.StandardController sc = new ApexPages.StandardController(referral);
            PageReference pageRef = Page.LeadCreationFromReferral;
            Test.setCurrentPage(pageRef);
            Apexpages.currentpage().getparameters().put('id', referral.Id);
            LeadCreationFromReferalController fsc = new LeadCreationFromReferalController(sc);        
            fsc.redirectURL();            
        }
        Test.stopTest();    
    }

}