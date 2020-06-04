/**
 * Company     : Trimble Software Technology Pvt Ltd.,
 * Description : .
 * History     :  

 * [16.OCT.2013] Srinivasan Babu  Created
 */
public class CustomerEventExnt{
    
    public Id eventId {get;set;}
    public List<Customer_Event__c> listCustomer {get;set;}
    Public List<Contact> Con {get;set;}
    public Customer_Event__c oCustomerEvent {get;set;}
    public string SelectedCustEventId { get; set; }
    public string eventAcctId {get; set;}
    public String cEventSendSurveyID {get; set;}
    public boolean shouldRedirect {get;set;}{shouldRedirect = false;}
    public string url {get;set;}
    public Map<Id, Customer_Event__c> mapCustomers {get; set;}
    Private Map<Id,List<Contact>>mapContact;
    public Map<Id, List<String>> contactsMap {get; set;}
    public Map<Id, List<contactWrapper>> eventContactsMap {get;set;}
    public List<contactWrapper> contactWrapperList {get; set;}
    public Map<Id, Boolean> eventContactsRenderMap {get; set;}
    public mapsWrapper mapWrapper{get; set;}
    public List<customerEventWrapper> custEventWrapperList {get; set;}
    public Map<String, List<customerEventWrapper>> custEventWrapMap {get; set;}
    public List<Customer_Event__c> custEventsList {get; set;}
    public Map<String, Account> customersMap {get; set;}
    public Boolean enableSurvey {get;set;}
        
     public CustomerEventExnt(ApexPages.StandardController controller) {
        
        eventId = System.currentPageReference().getParameters().get('id');
        listCustomer = new List<Customer_Event__c>();
        oCustomerEvent = new Customer_Event__c();
        contactsMap = new Map<Id, List<String>>();
        eventContactsMap = new Map<Id, List<contactWrapper>>();
        contactWrapperList = new List<contactWrapper>();
        eventContactsRenderMap = new Map<Id, Boolean>();
        custEventWrapperList = new List<customerEventWrapper>();
        custEventWrapMap = new Map<String, List<customerEventWrapper>>();
        custEventsList = new List<Customer_Event__c>();
        customersMap = new Map<String, Account>();
        LoadData();
    }
    
    public void LoadData(){
        Set<Id> CustomerEventId = new Set<Id>();
        Set<Id> AccId = new Set<Id>();
        set<string> contactIdsSet = new set<string>();
        mapCustomers = new Map<Id, Customer_Event__c>();
        for(Customer_Event__c oCustEvent : [select Id, Account__c,
                                                   Account__r.Id,
                                                   Account__r.Name,
                                                   Account__r.BillingStreet,
                                                   Account__r.BillingState,
                                                   Account__r.BillingCountry,
                                                   Account__r.BillingCity,
                                                   Event_Id__c,
                                                   Event_Contact__c, Event_Contact__r.Email, Event_Contact__r.Stop_Training_Survey__c,
                                                   Contact_Names__c, Contact_Ids__c,
                                                   Customer_Related_Contact__c,
                                                   Contact__c, Contact_Name__c,
                                                   Contact_Confirmation__c, Contact_Confirmation_Status__c, 
                                                   FS_Survey_Completed_Date__c, FS_Survey_Link_Sent__c  from Customer_Event__c where Event_Id__c =:eventId ]){
                                                            
           mapCustomers.put(oCustEvent.Account__c, oCustEvent);
           CustomerEventId.add(oCustEvent.Id);
           AccId.add(oCustEvent.Account__c);
           custEventsList.add(oCustEvent);
        }
        Map<Id, Account> accsMap = new Map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingCountry from Account where Id IN:AccId]);
        for(Id acc: accsMap.keySet()){
            customersMap.put(accsMap.get(acc).Name, accsMap.get(acc));
        }
        listCustomer = mapCustomers.values();
        listCustomer.sort();
        system.debug('---listCustomer--'+listcustomer.size()+'----'+listCustomer);
        for(Customer_Event__c custEvent: custEventsList){
            customerEventWrapper ceWrap = new customerEventWrapper(custEvent);
            
            if(!custEventWrapMap.containsKey(ceWrap.ce.Account__r.Name)){
                custEventWrapMap.put(ceWrap.ce.Account__r.Name, new List<customerEventWrapper>());
            }
            custEventWrapMap.get(ceWrap.ce.Account__r.Name).add(ceWrap);
            custEventWrapperList.add(ceWrap);
        }
        system.debug('--map--'+custEventWrapMap);
        
        enableSurvey = FALSE;
        if(eventId != NULL){
            Event eve = [SELECT Id, Subject, RecordTypeName__c FROM Event WHERE Id =: eventId LIMIT 1];
            if(eve.RecordTypeName__c == 'Non-CH Schedule Events' || eve.RecordTypeName__c == 'Onsite Tech Support'){
                enableSurvey = TRUE;
            }
        }
        
        /*if(contactIdsSet.size() > 0){
            Con = [select id, Name,Accountid,Customer_Event__c,Customer_Event__r.Account__c,Confirmed_for_Event__c, Confirmation_Status__c from contact where Id IN: contactIdsSet and Accountid in:AccId];
         
            for(Contact cnt: Con){
                system.debug('---con---'+con);
                if(!eventContactsMap.containsKey(cnt.Customer_Event__r.Account__c)){
                    eventContactsMap.put(cnt.Customer_Event__r.Account__c, new List<contactWrapper>());
                    eventContactsRenderMap.put(cnt.Customer_Event__r.Account__c,true);
                }
                contactWrapper cntWrap = new contactWrapper(cnt);
                eventContactsMap.get(cnt.Customer_Event__r.Account__c).add(cntWrap);
                contactWrapperList.add(cntWrap);            
            }
            
            for(Id eId: mapCustomers.keySet()){
                if(!eventContactsMap.containsKey(eId)){
                    system.debug('---eId---'+eId);
                    mapCustomers.remove(eId);
                    system.debug('---eId-2--'+mapCustomers.keySet()+'--eventskey--'+eventContactsMap.keySet());
                }
            }
            system.debug('---eventContactsMap---'+eventContactsMap);  
            mapWrapper = new mapsWrapper(mapCustomers, eventContactsMap);
        }*/
        //listCustomer = mapCustomers.values();
    }
    
    public pageReference saveConfirmations(){
        List<Customer_Event__c> updateCustEventList = new List<Customer_Event__c>();
        for(customerEventWrapper cew: custEventWrapperList){
            system.debug('--ceWrap--'+cew);
            if(cew.ceConfirm == true){
                cew.ce.Contact_Confirmation__c = true;
            }else{
                cew.ce.Contact_Confirmation__c = false;
            }
            updateCustEventList.add(cew.ce);
        }
        
        if(updateCustEventList.size() > 0){
            update updateCustEventList;
        }
        
        /*List<Contact> updateCntList = new List<Contact>();
        for(contactWrapper cw: contactWrapperList){
            system.debug('--cntWrap--'+cw);
            if(cw.confirm == true){
                cw.cnt.Confirmed_for_Event__c = true;
            }else{
                cw.cnt.Confirmed_for_Event__c = false;
            }
            updateCntList.add(cw.cnt);
        }
        
        if(updateCntList.size() > 0){
            update updateCntList;
        }*/
        pageReference pr = new pageReference('/apex/CustomerEvent?id='+eventId);
        pr.setRedirect(true);
        
        return pr;
    }
    
    public PageReference AddCustomers(){
        if(oCustomerEvent.Account__c != null && !mapCustomers.ContainsKey(oCustomerEvent.Account__c)){
            
            Customer_Event__c oNewCustomerEvent = new Customer_Event__c();
            oNewCustomerEvent.Account__c = oCustomerEvent.Account__c;
            oNewCustomerEvent.Event_Id__c = eventId;
            insert oNewCustomerEvent;
        }
         url = '/'+eventId;        
         shouldRedirect = true;
         return null;
    }
    
    public PageReference DeleteCustEvent()
    {
        if(string.isNotBlank(eventAcctId))
        Delete [select id from Customer_Event__c where Event_Id__c =: eventId AND Account__r.Id =: eventAcctId];
        /*
       // find the Customer_Event__c record within the collection
       system.debug('--SelectedCustEventId--'+SelectedCustEventId+'\n'+listCustomer);
       Customer_Event__c tobeDeleted = null;
       for(Customer_Event__c a : listCustomer)
        if (a.Id == SelectedCustEventId) {
          tobeDeleted = a;
          system.debug('----tobeDeleted--2--'+tobeDeleted);
          break;
        }
      
       //if Customer_Event__c record found delete it
       if (tobeDeleted != null) {
        system.debug('----tobedeleted----'+tobeDeleted);
        Delete tobeDeleted; 
       }
       */
       url = '/'+eventId;        
       shouldRedirect = true;
       return null;
    }
    
    public PageReference sendFormstackSurvey(){
    	if(string.isNotBlank(cEventSendSurveyID)){
    		system.Debug(' cEventSendSurveyID ===>'+cEventSendSurveyID);
    		Customer_Event__c cEvent = [SELECT Id, Name, Event_Contact__r.Email, Contact_Confirmation__c, FS_Survey_Link_Sent__c, FS_Survey_Sent_Date__c, FS_Email_Schedule_Date__c FROM Customer_Event__c WHERE Id=:cEventSendSurveyID LIMIT 1];
    		if(cEvent != null && cEvent.Contact_Confirmation__c == true && cEvent.Event_Contact__r.Email != null){
				cEvent.FS_Survey_Link_Sent__c = true;
				cEvent.FS_Survey_Sent_Date__c = system.now();
				cEvent.FS_Email_Schedule_Date__c = system.now();
				system.Debug(' cEventSendSurveyID ===>'+cEvent.FS_Email_Schedule_Date__c);
				update cEvent;
				shouldRedirect = true;
				url = '/'+eventId;
			}
    	}
    	return null;
    }
    
    public class customerEventWrapper{
        public Customer_Event__c ce {get; set;}
        public boolean ceConfirm {get; set;}
        
        public customerEventWrapper(Customer_Event__c cEvent){
            ce = cEvent;
            ceConfirm = (ce.Contact_Confirmation__c == True? ce.Contact_Confirmation__c:false);
            system.debug('--ceConfirm--'+ceConfirm);
        }
    }
    
    public class contactWrapper{
        public Contact cnt {get; set;}
        public boolean confirm {get; set;}
        
        public contactWrapper(Contact ct){
            cnt = ct;
            confirm = (ct.Confirmed_for_Event__c == True? ct.Confirmed_for_Event__c:false);
            system.debug('--confirm--'+confirm);
        }
    }  
    
    public class mapsWrapper{
        public Map<Id, Customer_Event__c> mapCustomers {get; set;}
        public Map<Id, List<contactWrapper>> eventContactsMap {get; set;}
        public List<Customer_Event__c> customersList{get; set;}
        
        public mapsWrapper(Map<Id, Customer_Event__c> mapCust, Map<Id, List<contactWrapper>> eventCntsMap){
            mapCustomers = mapCust;
            eventContactsMap = eventCntsMap;
            customersList = new List<Customer_Event__c>();
            customersList = mapCustomers.values();
        }
    }
}