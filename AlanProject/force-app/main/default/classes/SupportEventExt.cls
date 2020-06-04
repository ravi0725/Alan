/**
 * Company     : Trimble Software Technology Pvt Ltd.,
 * Description : Controller Class For SupportEvent Visualforce Page
 * History     :  

 * [09.06.2014] Prince Leo  Created
 */
public with sharing class SupportEventExt{
 public Id eventId {get;set;}
 Public String ExtDescription {get;set;}
 Public Boolean saved {get;set;}
 public SupportEventExt(ApexPages.StandardController controller) {
             
        eventId = System.currentPageReference().getParameters().get('id');
        List<Support_Event__c> SuppEvent = new List<Support_Event__c>();
        
       SuppEvent = [Select id, External_Description__c from Support_Event__c where Event_ID__c =:eventId];
        if(SuppEvent.size()==1)
        {
       ExtDescription = SuppEvent[0].External_Description__c;  
        }
        else
        {
        ExtDescription =' ';
        }
      
         }
    Public Void PerformDML()
      {
      saved = True;
         List<Support_Event__c> SuppEvent = new List<Support_Event__c>();
         SuppEvent = [Select id, External_Description__c from Support_Event__c where Event_ID__c =:eventId];
        if(SuppEvent.size()==0)
        {
       Support_Event__c SE = new Support_Event__c(External_Description__c = ExtDescription,Event_ID__c = eventId);
       insert SE;
      }   
      else if(SuppEvent.size()==1)
        {
        system.debug('&&&&&&&&&&&&&&'+SuppEvent[0].id);
       SuppEvent[0].External_Description__c =ExtDescription;
       update SuppEvent[0];
      }
      ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,Label.Save_Successful);
      ApexPages.addMessage(myMsg);
      
     }
   
   
        
     }