/************************************************************************************
* Name          :    AcceptRejectHelperTestClass
* Description   :    
* Author        :    Sagar

Modification Log
----------------
Date             Developer                Comments
------------------------------------------------------------------------------------------
                   Sagar                  Created
******************************************************************************************/
@isTest
public class AcceptRejectHelperTestClass {
  
  /**
     * Method name  : testAcceptLeadMethod
     * Description  : This method covers the positive and negative scenarios of acceptLead method
     * Return Type  : void
     * Parameter    : None
     **/
     
 
  public static Id recordType = Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get('Lead (Customer) Record Type').getRecordTypeId();
  public static Profile profile = [select Id from Profile where Name =: 'System Administrator'];
  public static User user;
  public static Country_Region_Mapping__c cust;
  
  static void setUp(){
  
    cust = new Country_Region_Mapping__c(name='India',Region__c='India');
    insert cust;
    
    user = new User();
    user.Username = 'sagamehta123@deloitte.com';
    user.Email = 'sagamehta@deloitte.com';
    user.LastName = 'Test';
    user.Alias = 'Test123';
    user.ProfileID = profile.Id;
    user.LocaleSidKey = 'en_US';
    user.LanguageLocaleKey = 'en_US';
    user.Country = 'United States';
    user.TimeZoneSidKey = 'America/Los_Angeles';
    user.EmailEncodingKey='UTF-8';
    Database.insert(user);
        
  }
    
    
  static testMethod void testAcceptLeadMethod() {
        setUp();
        Test.startTest();
        
        System.runAs(user) {                
          
          Lead newLead = new Lead(        
          LastName = 'Test Lead',
          company='test company',
          isPartnerReject__c=false,
          Lead_Accept_TimeStamp__c = DateTime.newInstance(System.now().year(), System.now().month(), System.now().day(), System.now().hour(), 0, 0) ,
          ownerid=user.id,
          Country='India',
          RecordTypeId = recordType);          
            
          insert newLead;
          //System.assert(newLead.Country__c == 'India');
          System.assert(newLead.OwnerId == user.Id);
          Id leadId = AcceptRejectHelperClass.acceptLead(newLead.Id);
        }
        Test.stopTest();
    }
  
  /**
     * Method name  : testRejectLead
     * Description  : This method covers the positive and negative scenarios of rejectLead method
     * Return Type  : void
     * Parameter    : None
     **/
  static testMethod void testRejectLead() {
        setUp();
        Test.startTest();
        
        System.runAs(user) {         
        
        Lead newLead = new Lead(        
          LastName = 'Test Lead',
          company='test company',
          isPartnerReject__c=false,
          Lead_Accept_TimeStamp__c = DateTime.newInstance(System.now().year(), System.now().month(), System.now().day(), System.now().hour(), 0, 0) ,
          ownerid=user.id,
          Country='India',
          RecordTypeId = recordType);
          
          insert newLead;
          //System.assert(newLead.Country__c == 'India');
          System.assert(newLead.OwnerId == user.Id);
          AcceptRejectHelperClass.rejectLead(newLead.Id, 'Lead rejected');
        }
        Test.stopTest();
  }

}