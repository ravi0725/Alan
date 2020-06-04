/************************************************************************************
* Name          :    PortalAnnouncementController
* Description   :    
* Author        :    Sagar

Modification Log
----------------
Date             Developer                Comments
------------------------------------------------------------------------------------------
                   Sagar                  Created 
******************************************************************************************/

@isTest
public class PortalAnnouncementControllerTestClass{
   
     /**
     * Method name  : testConstructor
     * Description  : This method covers the code of constructor
     * Return Type  : void
     * Parameter    : None
     **/
   static testMethod void testConstructor(){
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
         Partner_Announcements__c pa = new Partner_Announcements__c();
         pa.isDisplay__c = true;
         pa.Product_Description__c = 'test';
         pa.Product_Name__c = 'true';
         insert pa;          
         PortalAnnouncementController controller = new PortalAnnouncementController();                
       }  
       Test.stopTest();        
   }
}