/************************************************************************************
* Name          :    PartnerInternalSupportControllerTestClass
* Description   :    
* Author        :    Sagar

Modification Log
----------------
Date             Developer                Comments
------------------------------------------------------------------------------------------
                   Sagar                  Created
******************************************************************************************/
@isTest
public class PartnerInternalSupportTestClass{

    private static Country_Region_Mapping__c cust;
    private static Geospatial_Country_Region_Mapping__c custRegMap ;
     private static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    static void setUpData(){
        
        cust = new Country_Region_Mapping__c(name='India',Region__c='India');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='India',Region__c='India');
        insert custRegMap;
    }   
    /**
     * Method name  : testredirectToComponent
     * Description  : This method covers the positive scenarios of redirectToComponent method
     * Return Type  : void
     * Parameter    : None
     **/
    static testMethod void testredirectToComponent() {
        setUpData();
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
        //insert user;
        
       // System.runAs(user) { 
            Account account = new Account(Name = 'Test Trimble',RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
                                BillingCountry = 'India',BillingCity = 'Pune',BillingStreet = 'A-202');
            insert account;
                                    
            PageReference pageRef = Page.partnerInternalCaseSupport;
            Test.setCurrentPage(pageRef);
            Apexpages.currentpage().getparameters().put('ctype', '1');
            PartnerInternalSupportController pisc = new PartnerInternalSupportController();            
            pisc.redirectToComponent();            
       // }
        Test.stopTest();
    }
    
    /**
     * Method name  : testredirectToComponentNegativescenarios
     * Description  : This method covers the negative scenarios of testredirectToComponentNegativescenarios method
     * Return Type  : void
     * Parameter    : None
     **/
    static testMethod void testredirectToComponentNegativescenarios() {
        setUpData();
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
        //insert user;
        
        System.runAs(user) {             
                                    
            PageReference pageRef = Page.partnerInternalCaseSupport;
            Test.setCurrentPage(pageRef);
            Apexpages.currentpage().getparameters().put('ctype', '1');
            PartnerInternalSupportController pisc = new PartnerInternalSupportController();            
            pisc.redirectToComponent();            
        }
        Test.stopTest();
    }
    
    /**
     * Method name  : testredirectToComponentPortalScenarios
     * Description  : This method covers the positive and negative scenarios of testredirectToComponentPortalScenarios method
     * Return Type  : void
     * Parameter    : None
     **/
    static testMethod void testredirectToComponentPortalScenarios() {
        setUpData();
        User sysUser = [select id from User where Profile.Name = 'System Administrator' and isActive = true and UserRoleId != null Limit 1];
        
        Profile profile = [select Id from Profile where Name =: 'Trimble Standard Partner Portal User'];
        
        Account paccount = new Account(Name='Test',BillingCountry = 'India',BillingCity = 'Pune',BillingStreet = 'A-202',OwnerID=sysUser.id);
        insert paccount;
        
        Contact contact = new Contact();
        contact.AccountId = paccount.Id;
        contact.FirstName = 'ABC';
        contact.LastName = 'EFG';
        contact.MailingCountry ='India';
        insert contact;
        User user = new User();
        //system.runas(sysUser){
            user.Username = 'sagamehta123@deloitte.com';
            user.Email = 'sagamehta@deloitte.com';
            user.LastName = 'Test';
            user.Alias = 'Test123';
            user.ContactId = contact.Id;
            user.ProfileID = profile.Id;
            //user.UserRoleId = role.Id;
            user.LocaleSidKey = 'en_US';
            user.LanguageLocaleKey = 'en_US';
            user.Country = 'India';
            user.Division__c = 'Infrastructure';
            user.TimeZoneSidKey = 'America/Los_Angeles';
            user.EmailEncodingKey='UTF-8';
            //insert user;
       //}
       //System.runAs(user) { 
            Test.startTest();               
            Account account = new Account(Name='Trimble',BillingCountry = 'India',BillingCity = 'Pune',BillingStreet = 'A-202');
            insert account;
                                    
            PageReference pageRef = Page.partnerInternalCaseSupport;
            Test.setCurrentPage(pageRef);
            Apexpages.currentpage().getparameters().put('ctype', '2');
            PartnerInternalSupportController pisc = new PartnerInternalSupportController();            
            pisc.redirectToComponent();            
        //}
        Test.stopTest();
    }    

}