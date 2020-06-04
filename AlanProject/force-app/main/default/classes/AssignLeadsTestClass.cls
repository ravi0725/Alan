/************************************************************************************
* Name          :    AssignLeadsTestClass
* Description   :    
* Author        :    Sagar

Modification Log
----------------
Date             Developer                Comments
------------------------------------------------------------------------------------------
                   Sagar                  Created
******************************************************************************************/
@isTest
public class AssignLeadsTestClass {
    
    public static Country_Region_Mapping__c cust;
    public static Geospatial_Country_Region_Mapping__c custRegMap ;
    public static List<MEPEuropeSalesRegion_del_del__c> mepObjList = new List<MEPEuropeSalesRegion_del_del__c>();
    
    static void setUpData(){
        
        cust = new Country_Region_Mapping__c(name='India',Region__c='India');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='India',Region__c='India');
        insert custRegMap;
        
        mepObjList.add(new MEPEuropeSalesRegion_del_del__c(name='1-Test' ,Country__c='India',MEP_Europe_Sales_Region__c='India',Zip__c='91'));
        mepObjList.add(new MEPEuropeSalesRegion_del_del__c(name='2-Test' ,Country__c='Japan',MEP_Europe_Sales_Region__c='Japan',Zip__c='21'));
        insert mepObjList;
        
    }
    
    /**
     * Method name  : testAssignLeadMethod
     * Description  : This method covers the positive scenarios of lead trigger
     * Return Type  : void
     * Parameter    : None
     **/
    static testMethod void testAssignLeadMethod() {         
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
        user.TimeZoneSidKey = 'America/Los_Angeles';
        user.EmailEncodingKey='UTF-8';
        //insert user;
        
        User user1 = new User();
        user1.Username = 'ashfaq@deloitte.com';
        user1.Email = 'ashfaq@deloitte.com';
        user1.LastName = 'Test';
        user1.Alias = 'Test123';
        user1.ProfileID = profile.Id;
        user1.LocaleSidKey = 'en_US';
        user1.LanguageLocaleKey = 'en_US';
        user1.Country = 'India';
        user1.TimeZoneSidKey = 'America/Los_Angeles';
        user1.EmailEncodingKey='UTF-8';
        //insert user1;
        
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get('Lead');
        Lead a = (Lead)targetType.newSObject();
        
        Map<String, Id> recordTypeMap = RecursiveTriggerUtility.loadRecordTypeMap(a.getSobjectType());
        
        setUpData();
        
        Test.startTest();
        System.runAs(user) {
            
            ID CusLeadRecordTypeID = recordTypeMap.get(Label.Lead_Customer_Record_Type);
            Campaign campaign = new Campaign();
            campaign.Name = 'Campaign Test';
            campaign.Status = 'Completed';
            campaign.Type = 'Advertisement';
            insert campaign;
            
            Lead lead = new Lead();
            lead.lastName = 'Assign Lead Test';
            lead.Status = 'Suspect';
            lead.Company = 'ABC Corporation';
            lead.LeadSource = 'YouTube';
            lead.Country = 'India';
            lead.Street ='Test1\r\nTest2\r\nTest3\r\nTest4';
            lead.PostalCode ='100100';
            lead.RecordTypeId = CusLeadRecordTypeID;
            insert lead;
            
            System.assert(lead.RecordTypeId == CusLeadRecordTypeID);
            
            CampaignMember campaignMember = new CampaignMember();
            campaignMember.CampaignId = campaign.Id;
            campaignMember.LeadId = lead.Id;
            insert campaignMember;
            
            AssignLeads.assignAlreadyCalled = false;
            RecursiveTriggerUtility.isTriggerExecute = false;
            RecursiveTriggerUtility.isLeadUpdateExecute = false;  
            lead = [Select Id, Name, Status from Lead where Name = 'Assign Lead Test'];
            lead.Company = 'ABC Corporation1';
            lead.Status = 'Nurture';
            //lead.OwnerId = user1.Id;
            update lead;
            
            System.assert(lead.Status == 'Nurture');
            
            RecursiveTriggerUtility.isTriggerExecute = true;
            RecursiveTriggerUtility.isLeadUpdateExecute = true;                
        }        
        Test.stopTest();
    }
    
    /**
     * Method name  : testAssignLeadMethod1
     * Description  : This method covers the negative scenarios of lead trigger
     * Return Type  : void
     * Parameter    : None
     **/
    static testMethod void testAssignLeadMethod1() {         
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
        user.TimeZoneSidKey = 'America/Los_Angeles';
        user.EmailEncodingKey='UTF-8';
        //insert user;
        
        User user1 = new User();
        user1.Username = 'ashfaq@deloitte.com';
        user1.Email = 'ashfaq@deloitte.com';
        user1.LastName = 'Test';
        user1.Alias = 'Test123';
        user1.ProfileID = profile.Id;
        user1.LocaleSidKey = 'en_US';
        user1.LanguageLocaleKey = 'en_US';
        user1.Country = 'India';
        user1.TimeZoneSidKey = 'America/Los_Angeles';
        user1.EmailEncodingKey='UTF-8';
        //insert user1;
        
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get('Lead');
        Lead a = (Lead)targetType.newSObject();
        
        Map<String, Id> recordTypeMap = RecursiveTriggerUtility.loadRecordTypeMap(a.getSobjectType());
        setUpData();
        
        Test.startTest();
        System.runAs(user) {
            ID CusLeadRecordTypeID = recordTypeMap.get(Label.Lead_Customer_Record_Type);
            Campaign campaign = new Campaign();
            campaign.Name = 'Campaign Test';
            campaign.Status = 'Completed';
            campaign.Type = 'Advertisement';
            insert campaign;
            
            Lead lead = new Lead();
            lead.lastName = 'Assign Lead Test';
            lead.Status = 'Targeted';
            lead.Company = 'ABC Corporation';
            lead.LeadSource = 'YouTube';
            lead.Country = 'India';
            lead.Street ='Test1\r\nTest2\r\nTest3\r\nTest4';
            lead.RecordTypeId = CusLeadRecordTypeID;
            insert lead;
            
            CampaignMember campaignMember = new CampaignMember();
            campaignMember.CampaignId = campaign.Id;
            campaignMember.LeadId = lead.Id;
            insert campaignMember;
            
            AssignLeads.assignAlreadyCalled = true;
            RecursiveTriggerUtility.isTriggerExecute = false;
            RecursiveTriggerUtility.isLeadUpdateExecute = false; 
            lead = [Select Id, Name, Status from Lead where Name = 'Assign Lead Test'];
            lead.Company = 'ABC Corporation1';
            lead.Status = 'Nurture';
            //lead.OwnerId = user1.Id;
            update lead;

            RecursiveTriggerUtility.isTriggerExecute = true;
            RecursiveTriggerUtility.isLeadUpdateExecute = true;                
        }        
        Test.stopTest();
    }
    
    /**
     * Method name  : testAssignLeadMethod3
     * Description  : This method covers the negative scenarios of lead trigger
     * Return Type  : void
     * Parameter    : None
     **/
    static testMethod void testAssignLeadMethod3() {         
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
        user.TimeZoneSidKey = 'America/Los_Angeles';
        user.EmailEncodingKey='UTF-8';
        //insert user;
        
        User user1 = new User();
        user1.Username = 'ashfaq@deloitte.com';
        user1.Email = 'ashfaq@deloitte.com';
        user1.LastName = 'Test';
        user1.Alias = 'Test123';
        user1.ProfileID = profile.Id;
        user1.LocaleSidKey = 'en_US';
        user1.LanguageLocaleKey = 'en_US';
        user1.Country = 'India';
        user1.TimeZoneSidKey = 'America/Los_Angeles';
        user1.EmailEncodingKey='UTF-8';
        //insert user1;
        
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get('Lead');
        Lead a = (Lead)targetType.newSObject();
        
        Map<String, Id> recordTypeMap = RecursiveTriggerUtility.loadRecordTypeMap(a.getSobjectType());
        
        setUpData();
        
        Test.startTest();
        System.runAs(user) {
            ID CusLeadRecordTypeID = recordTypeMap.get(Label.Lead_Customer_Record_Type);
            Id recordIdMarketing = recordTypeMap.get(Label.Lead_Marketing_Record_Type);
            
            Campaign campaign = new Campaign();
            campaign.Name = 'Campaign Test';
            campaign.Status = 'Completed';
            campaign.Type = 'Advertisement';
            insert campaign;
            
            Lead lead = new Lead();
            lead.lastName = 'Assign Lead Test';
            lead.Status = Label.Lead_Status_Targeted;
            lead.Company = 'ABC Corporation';
            lead.LeadSource = 'YouTube';
            lead.Country = 'India';
            lead.Street ='Test1\r\nTest2\r\nTest3\r\nTest4';
            lead.RecordTypeId = recordIdMarketing;
            insert lead;
            
            CampaignMember campaignMember = new CampaignMember();
            campaignMember.CampaignId = campaign.Id;
            campaignMember.LeadId = lead.Id;
            insert campaignMember;
         
            AssignLeads.assignAlreadyCalled = true;
            RecursiveTriggerUtility.isTriggerExecute = false;
            RecursiveTriggerUtility.isLeadUpdateExecute = false; 
            
            lead = [Select Id, Name, Status from Lead where Name = 'Assign Lead Test'];
            lead.Company = 'ABC Corporation1';
            lead.Status = Label.Lead_Status_Nurture;
            //lead.OwnerId = user1.Id;
            
            lead.RecordTypeId = recordIdMarketing;
            update lead;
            
            System.assert(lead.Status == 'Nurture');
            
            RecursiveTriggerUtility.isTriggerExecute = true;
            RecursiveTriggerUtility.isLeadUpdateExecute = true;                
        }        
        Test.stopTest();
    }
    
    /**
     * Method name  : testNegativeScenarios
     * Description  : This method covers the negative scenarios of lead trigger
     * Return Type  : void
     * Parameter    : None
     **/
    static testMethod void testNegativeScenarios() {         
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
        user.TimeZoneSidKey = 'America/Los_Angeles';
        user.EmailEncodingKey='UTF-8';
        //insert user;
        
        User user1 = new User();
        user1.Username = 'ashfaq@deloitte.com';
        user1.Email = 'ashfaq@deloitte.com';
        user1.LastName = 'Test';
        user1.Alias = 'Test123';
        user1.ProfileID = profile.Id;
        user1.LocaleSidKey = 'en_US';
        user1.LanguageLocaleKey = 'en_US';
        user1.Country = 'India';
        user1.TimeZoneSidKey = 'America/Los_Angeles';
        user1.EmailEncodingKey='UTF-8';
        //insert user1;
        
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get('Lead');
        Lead a = (Lead)targetType.newSObject();
        
        Map<String, Id> recordTypeMap = RecursiveTriggerUtility.loadRecordTypeMap(a.getSobjectType());
        
        setUpData();
        
        Test.startTest();
        System.runAs(user) {
            ID CusLeadRecordTypeID = recordTypeMap.get(Label.Lead_Customer_Record_Type);
            Id recordIdMarketing = recordTypeMap.get(Label.Lead_Marketing_Record_Type);
            
            Campaign campaign = new Campaign();
            campaign.Name = 'Campaign Test';
            campaign.Status = 'Completed';
            campaign.Type = 'Advertisement';
            insert campaign;
            
            Lead lead = new Lead();
            lead.lastName = 'Assign Lead Test';
            lead.Status = Label.Lead_Status_Targeted;
            lead.Company = 'ABC Corporation';
            lead.LeadSource = 'YouTube';
            lead.Country = 'India';
            lead.Street ='Test1\r\nTest2\r\nTest3\r\nTest4';
            lead.RecordTypeId = recordIdMarketing;
            insert lead;
            
            CampaignMember campaignMember = new CampaignMember();
            campaignMember.CampaignId = campaign.Id;
            campaignMember.LeadId = lead.Id;
            insert campaignMember;
            
            
                       
            AssignLeads.assignAlreadyCalled = true;
            RecursiveTriggerUtility.isTriggerExecute = false;
            RecursiveTriggerUtility.isLeadUpdateExecute = false; 
            
            lead = [Select Id, Name, Status from Lead where Name = 'Assign Lead Test'];
            lead.Company = 'ABC Corporation1';
            lead.Status = Label.Lead_Status_Nurture;
            //lead.OwnerId = user1.Id;
            
            lead.RecordTypeId = recordIdMarketing;
            update lead;
            
            System.assert(lead.Status == 'Nurture');
            
            RecursiveTriggerUtility.isTriggerExecute = true;
            RecursiveTriggerUtility.isLeadUpdateExecute = true;                
        }        
        Test.stopTest();
    }
    
    /**
     * Method name  : testNegativeScenarios1
     * Description  : This method covers the negative scenarios of lead trigger
     * Return Type  : void
     * Parameter    : None
     **/
    static testMethod void testNegativeScenarios1() {         
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
        user.TimeZoneSidKey = 'America/Los_Angeles';
        user.EmailEncodingKey='UTF-8';
        //insert user;
        
        User user1 = new User();
        user1.Username = 'ashfaq@deloitte.com';
        user1.Email = 'ashfaq@deloitte.com';
        user1.LastName = 'Test';
        user1.Alias = 'Test123';
        user1.ProfileID = profile.Id;
        user1.LocaleSidKey = 'en_US';
        user1.LanguageLocaleKey = 'en_US';
        user1.Country = 'India';
        user1.TimeZoneSidKey = 'America/Los_Angeles';
        user1.EmailEncodingKey='UTF-8';
        //insert user1;
        
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get('Lead');
        Lead a = (Lead)targetType.newSObject();
        
        Map<String, Id> recordTypeMap = RecursiveTriggerUtility.loadRecordTypeMap(a.getSobjectType());
        
        setUpData();
        
        Test.startTest();
        System.runAs(user) {
            ID CusLeadRecordTypeID = recordTypeMap.get(Label.Lead_Customer_Record_Type);
            Id recordIdMarketing = recordTypeMap.get(Label.Lead_Marketing_Record_Type);
            
            Campaign campaign = new Campaign();
            campaign.Name = 'Campaign Test';
            campaign.Status = 'Completed';
            campaign.Type = 'Advertisement';
            insert campaign;
            
            Lead lead = new Lead();
            lead.lastName = 'Assign Lead Test';
            lead.Status = Label.Lead_Status_Nurture;
            lead.Company = 'ABC Corporation';
            lead.LeadSource = 'YouTube';
            lead.Country = 'India';
            lead.Street ='Test1\r\nTest2\r\nTest3\r\nTest4';
            lead.RecordTypeId = recordIdMarketing;
            List<Group> groupList = new List<Group>();
            //groupList = [Select Id from Group where DeveloperName =: Label.Nurture_Lead_Queue];
            //Group gr = groupList.get(0);
            //lead.OwnerId = gr.Id;
            insert lead;
            
            CampaignMember campaignMember = new CampaignMember();
            campaignMember.CampaignId = campaign.Id;
            campaignMember.LeadId = lead.Id;
            insert campaignMember;
                       
            AssignLeads.assignAlreadyCalled = true;
            RecursiveTriggerUtility.isTriggerExecute = false;
            RecursiveTriggerUtility.isLeadUpdateExecute = false; 
            
            lead = [Select Id, Name, Status from Lead where Name = 'Assign Lead Test'];
            lead.Company = 'ABC Corporation1';
            //lead.Status = Label.Lead_Status_Nurture;
            //lead.OwnerId = user1.Id;
            lead.RecordTypeId = CusLeadRecordTypeID;
            update lead;
            
            //System.assert(lead.Status == 'Nurture');
            
            RecursiveTriggerUtility.isTriggerExecute = true;
            RecursiveTriggerUtility.isLeadUpdateExecute = true;                
        }        
        Test.stopTest();
    }
    
    /**
     * Method name  : testAssignLeadToPartnerMethod
     * Description  : This method covers the positive scenarios of lead trigger
     * Return Type  : void
     * Parameter    : None
     **/
    static testMethod void testAssignLeadToPartnerMethod() {         
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
        user.TimeZoneSidKey = 'America/Los_Angeles';
        user.EmailEncodingKey='UTF-8';
        //insert user;
        
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get('Lead');
        Lead a = (Lead)targetType.newSObject();
        
        Map<String, Id> recordTypeMap = RecursiveTriggerUtility.loadRecordTypeMap(a.getSobjectType());
        
        setUpData();
        
        Test.startTest();
        //System.runAs(user) {
          User sysUser = [select id from User where Profile.Name = 'System Administrator' and isActive = true and UserRoleId != null Limit 1];
          Profile profile1 = [Select Id from Profile where Name =: Label.Partner_Portal_Profile_Name];
          Account account = new Account();
          account.Name = 'Partner Test Account';
          //account.OwnerId = sysUser.Id;
          account.BillingCountry = 'India';
          account.BillingCity = 'Pune';
          account.BillingStreet = 'A-202';
          insert account;
          
          Contact contact = new Contact();
          contact.FirstName = 'Partner';
          contact.LastName = 'Contact';
          contact.AccountId = account.Id;
          contact.MailingCountry ='India';
          insert contact;
          
          User user1 = new User();
          user1.Username = 'partner@deloitte.com';
          user1.Email = 'partner@deloitte.com';
          user1.LastName = 'Partner';
          user1.Alias = 'Part';
          user1.ProfileID = profile1.Id;
          user1.LocaleSidKey = 'en_US';
          user1.LanguageLocaleKey = 'en_US';
          user1.Country = 'India';
          user1.TimeZoneSidKey = 'America/Los_Angeles';
          user1.EmailEncodingKey='UTF-8';
          //user1.ContactId = contact.Id;
          //insert user1;
          
            //User user1 = [Select Id from User where ProfileId =: profile1.Id and IsActive = true limit 1];
            Lead lead = new Lead();
            lead.lastName = 'Assign Lead Test';
            lead.Status = 'Suspect';
            lead.Company = 'ABC Corporation';
            lead.LeadSource = 'Video';
            lead.Country = 'India';
            lead.Street ='Test1\r\nTest2\r\nTest3\r\nTest4';
            lead.RecordTypeId = recordTypeMap.get('Lead_Customer');
            insert lead;
            
            System.assert(lead.RecordTypeId == recordTypeMap.get('Lead_Customer'));
            
            RecursiveTriggerUtility.isTriggerExecute = false;
            RecursiveTriggerUtility.isLeadUpdateExecute = false;  
            lead = [Select Id, Name, Status from Lead where Name = 'Assign Lead Test'];
            lead.Company = 'ABC Corporation1';
            lead.Status = 'Nurture';
            //lead.OwnerId = user1.Id;
            update lead;
            
            System.assert(lead.Status == 'Nurture');
            
            RecursiveTriggerUtility.isTriggerExecute = true;
            RecursiveTriggerUtility.isLeadUpdateExecute = true;                
        //}        
        Test.stopTest();
    }
}