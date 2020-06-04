/**
 * Company     : Trimble Inc.,
 * Description : This class is used in CustomerEventListner trigger.
 * History     :  
 * [20.SEP.2017] Suresh Babu Murugan  Created
 */
public class CustomerEventHandler {
    public static Map<String, Integer> launchControl;

    // static initialize
    static{
        resetLaunchControl();
    }

    //Reset trigger control
    public static void setLaunchControl(){
        launchControl = new Map<String, Integer>();
        launchControl.put('cEvents_insert', 1);
        launchControl.put('cEvents_update', 1);
        launchControl.put('cTrimFormstackResp', 1);
    }

    //Reset trigger control
    public static void resetLaunchControl(){
        launchControl = new Map<String, Integer>();
        launchControl.put('cEvents_insert', 0);
        launchControl.put('cEvents_update', 0);
        launchControl.put('cTrimFormstackResp', 0);
    }

    //Before Insert Customer Events
    public static void cEvents_insert(List<Customer_Event__c> lstCustEvents){
        if(launchControl.get('cEvents_insert') < 1){
            launchControl.put('cEvents_insert', launchControl.get('cEvents_insert') + 1);

            updateFormstackDetails(lstCustEvents);
        }
    }

    //Before Update Customer Events
    public static void cEvents_update(List<Customer_Event__c> lstCustEvents){
        if(launchControl.get('cEvents_update') < 1){
            launchControl.put('cEvents_update', launchControl.get('cEvents_update') + 1);
            
            updateFormstackDetails(lstCustEvents);
        }
    }

    public static void cTrimFormstackResp(List<Customer_Event__c> lstCustEvents){
        if(launchControl.get('cTrimFormstackResp') < 1){
            launchControl.put('cTrimFormstackResp', launchControl.get('cTrimFormstackResp') + 1);
            
            trimResponse(lstCustEvents);
        }
    }

    public static void updateFormstackDetails(List<Customer_Event__c> lstCustEvents){
        Set<Id> eventIDs = new Set<Id>();
        // validate Customer Event linked with Events
        for(Customer_Event__c cEvt : lstCustEvents){
            if(cEvt.Event_Id__c != null){
                eventIDs.add(cEvt.Event_Id__c);
            }
        }
        if(eventIDs != null){
            Map<Id, Event> mapEvents = returnEvents(eventIDs);

            for(Customer_Event__c cEvt: lstCustEvents){
                if(cEvt.Event_Id__c != null && mapEvents.containsKey(cEvt.Event_Id__c)){
                    cEvt.FS_Event_Type__c = mapEvents.get(cEvt.Event_Id__c).Type;
                    cEvt.FS_Email_Schedule_Date__c = mapEvents.get(cEvt.Event_Id__c).EndDateTime;
                }
            }
        }
    }

    public static Map<Id, Event> returnEvents(Set<Id> eIDs){
        Set<Id> setRecordTypeIDs = new Set<Id>();
        setRecordTypeIDs.add(Schema.SObjectType.Event.getRecordTypeInfosByName().get('Non-CH Schedule Events').getRecordTypeId());
        setRecordTypeIDs.add(Schema.SObjectType.Event.getRecordTypeInfosByName().get('Onsite Tech Support').getRecordTypeId());
        Map<Id, Event> mapEvents = new Map<Id, Event>([SELECT Id, Subject, Type, StartDateTime, EndDateTime FROM Event WHERE RecordTypeId IN : setRecordTypeIDs AND Id IN: eIDs]);
        return mapEvents;
    }

    public static void trimResponse(List<Customer_Event__c> lstCustEvents){
        Set<Id> evtIDs = new Set<Id>();
        Set<Id> AccIDs = new Set<Id>();
        Set<Id> ConIDs = new Set<Id>();
        for(Customer_Event__c cEvt : lstCustEvents){
            evtIDs.add(cEvt.Event_Id__c);
            AccIDs.add(cEvt.Account__c);
            ConIDs.add(cEvt.Event_Contact__c);
        }
        Map<Id, Event> mapEventDetails = new Map<Id, Event>([SELECT Id, Subject, Owner.Name FROM Event WHERE Id IN: evtIDs]);
        Map<Id, Account> mapAccountDetails = new Map<Id, Account>([SELECT Id, Name, Enterprise_Party_Number__c FROM Account WHERE Id IN: AccIDs]);
        Map<Id, Contact> mapContactDetails = new Map<Id, Contact>([SELECT Id, Salutation_DE__c, Name, FirstName, LastName, Email FROM Contact WHERE Id IN: ConIDs]);
        for(Customer_Event__c cEvt : lstCustEvents){
            
            // Update Default values:
            cEvt.FS_Participant_Name__c = mapContactDetails.get(cEvt.Event_Contact__c).Name;
            cEvt.FS_Email__c = mapContactDetails.get(cEvt.Event_Contact__c).Email; 
            cEvt.FS_Trainer_Name__c = mapEventDetails.get(cEvt.Event_Id__c).Owner.Name;
            cEvt.FS_Company_Name__c = mapAccountDetails.get(cEvt.Account__c).Name;
            cEvt.FS_Customer_Number__c = mapAccountDetails.get(cEvt.Account__c).Enterprise_Party_Number__c;
            
            if(cEvt.FS_Course_Rating__c != null && cEvt.FS_Course_Rating__c.contains('= ')){
                cEvt.FS_Course_Rating__c = cEvt.FS_Course_Rating__c.substringAfter('=').trim();
            }
            if(cEvt.FS_Trainer_Knowledge_Rating__c != null && cEvt.FS_Trainer_Knowledge_Rating__c.contains('=')){
                cEvt.FS_Trainer_Knowledge_Rating__c = cEvt.FS_Trainer_Knowledge_Rating__c.substringAfter('=').trim();
            }
            if(cEvt.FS_Trainer_Presentation_Rating__c != null && cEvt.FS_Trainer_Presentation_Rating__c.contains('=')){
                cEvt.FS_Trainer_Presentation_Rating__c = cEvt.FS_Trainer_Presentation_Rating__c.substringAfter('=').trim();
            }
            if(cEvt.FS_Trainer_Support_Rating__c != null && cEvt.FS_Trainer_Support_Rating__c.contains('=')){
                cEvt.FS_Trainer_Support_Rating__c = cEvt.FS_Trainer_Support_Rating__c.substringAfter('=').trim();
            }
            if(cEvt.FS_Training_Duration_Rating__c != null && cEvt.FS_Training_Duration_Rating__c.contains('=')){
                cEvt.FS_Training_Duration_Rating__c = cEvt.FS_Training_Duration_Rating__c.substringAfter('=').trim();
            }
            if(cEvt.FS_Training_Equipment_Rating__c != null && cEvt.FS_Training_Equipment_Rating__c.contains('=')){
                cEvt.FS_Training_Equipment_Rating__c = cEvt.FS_Training_Equipment_Rating__c.substringAfter('=').trim();
            }
            if(cEvt.FS_Training_General_Rating__c != null && cEvt.FS_Training_General_Rating__c.contains('=')){
                cEvt.FS_Training_General_Rating__c = cEvt.FS_Training_General_Rating__c.substringAfter('=').trim();
            }
            if(cEvt.FS_Training_Presentation_Rating__c != null && cEvt.FS_Training_Presentation_Rating__c.contains('=')){
                cEvt.FS_Training_Presentation_Rating__c = cEvt.FS_Training_Presentation_Rating__c.substringAfter('=').trim();
            }
            // Formstack adding 6 hours in time due to Timezone differences. Reducing the hours to fix the difference.
            if(cEvt.FS_Survey_Completed_Date__c != null){
                cEvt.FS_Survey_Completed_Date__c = cEvt.FS_Survey_Completed_Date__c.addHours(-6);
            }
        }
    }
}