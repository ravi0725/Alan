/**
 * Company     : Trimble Inc.,
 * Description : This class is used in EventListner trigger.
 * History     :  
 * [25.SEP.2017] Suresh Babu Murugan  Created
**/
public with sharing class EventTriggerHandler {
    public static Map<String, Integer> launchControl;

    // static initialize
    static{
        resetLaunchControl();
    }

    //Set trigger control
    public static void setLaunchControl(){
        launchControl = new Map<String, Integer>();
        launchControl.put('UpdateCustomerEvents', 1);
    }

    //Reset trigger control
    public static void resetLaunchControl(){
        launchControl = new Map<String, Integer>();
        launchControl.put('UpdateCustomerEvents', 0);
    }

    // Update related Customer eveents only if the Event is Non-CH Schedule Events
    public static void UpdateCustomerEvents(List<Event> lstEvents){
        if(launchControl.get('UpdateCustomerEvents') < 1){
            launchControl.put('UpdateCustomerEvents', launchControl.get('UpdateCustomerEvents') + 1);

            Set<Id> setEventIDs = new Set<Id>();
            Set<Id> setUserIDs = new Set<Id>();
            Map<Id, Datetime> eventEndDate = new Map<Id, Datetime>();
            Map<Id, String> eventType = new Map<Id, String>();
            Map<Id, String> eventSubject = new Map<Id, String>();
            Map<Id, String> eventOwnerName = new Map<Id, String>();
            
            for(Event evt: lstEvents){
                if(evt.RecordTypeName__c == 'Non-CH Schedule Events' || evt.RecordTypeName__c == 'Onsite Tech Support'){
                	setUserIDs.add(evt.OwnerId);
                }
            }
            Map<Id, User> mapUsers = new Map<Id, User>([SELECT Id, Name FROM User WHERE Id IN: setUserIDs]);
            
            for(Event evt: lstEvents){
                if(evt.RecordTypeName__c == 'Non-CH Schedule Events' || evt.RecordTypeName__c == 'Onsite Tech Support'){
                    setEventIDs.add(evt.Id);
                    eventEndDate.put(evt.Id, evt.EndDateTime);
                    eventType.put(evt.Id, evt.Type);
                    eventSubject.put(evt.Id, evt.Subject);
                    eventOwnerName.put(evt.Id, mapUsers.get(evt.OwnerId).Name);
                }
            }

            if(setEventIDs.size() > 0){
                Map<Id, List<Customer_Event__c>> mapCustEvents = returnCustomerEvents(setEventIDs);
                List<Customer_Event__c> updateCustEvents = new List<Customer_Event__c>();
                for(String evtId : mapCustEvents.keySet()){
                    for(Customer_Event__c cEvt: mapCustEvents.get(evtId)){
                        cEvt.FS_Email_Schedule_Date__c = eventEndDate.get(evtId);
                        cEvt.FS_Event_Type__c = eventType.get(evtId);
                        cEvt.Event_Subject__c = eventSubject.get(evtId);
                        cEvt.Event_Owner_Name__c = eventOwnerName.get(evtId);
                        cEvt.Event_End_Date__c = String.valueOf(eventEndDate.get(evtId).day());
                        cEvt.Event_End_Month__c = String.valueOf(eventEndDate.get(evtId).month());
                        cEvt.Event_End_Year__c = String.valueOf(eventEndDate.get(evtId).year());
                        
                        updateCustEvents.add(cEvt);
                    }
                }

                // Prevent execution Customer Event trigger
                if(updateCustEvents.size() > 0){
                    CustomerEventHandler.setLaunchControl();
                    update updateCustEvents;
                }
            }
        }
    }

    // Query related Customer Events=> KEY: EventID, Value: CustomerEvent
    public static Map<Id, List<Customer_Event__c>> returnCustomerEvents(Set<Id> eIDs){
        List<Customer_Event__c> lstCustEvents = [SELECT Id, Name, Event_Id__c, FS_Email_Schedule_Date__c, FS_Event_Type__c FROM Customer_Event__c WHERE Event_Id__c IN : eIDs];
        Map<Id, List<Customer_Event__c>> mapCEvents = new Map<Id, List<Customer_Event__c>>();
        for(Customer_Event__c cEvt: lstCustEvents){
            if(mapCEvents.containsKey(cEvt.Event_Id__c)){
                mapCEvents.get(cEvt.Event_Id__c).add(cEvt);
            }
            else{
                List<Customer_Event__c> tempCEvt = new List<Customer_Event__c>();
                tempCEvt.add(cEvt);
                mapCEvents.put(cEvt.Event_Id__c, tempCEvt);
            }
        }
        return mapCEvents;
    }
}