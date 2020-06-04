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

public class PortalAnnouncementController{

   public List<Partner_Announcements__c> announcementList{get;set;}
   
   public PortalAnnouncementController(){
       announcementList = new List<Partner_Announcements__c>();
       
       announcementList = [Select Id, Product_Name__c, Product_Description__c, Product_Image__c, IsDisplay__c from Partner_Announcements__c where IsDisplay__c =: true];   
   }
}