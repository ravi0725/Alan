/*
* Company     : Trimble Inc.,
* Description : Controller for Page AddContactsOnSiteTechEvent to Add Multiple Contacts to OnsiteTechSupport Event.
* History     : 
* [12.MAR.2018] Suresh Babu Murugan - Code Created.
*/
public class AddContactsOnSiteTechEventCls {
    public Id eventId {get;set;}
    public Id accountId {get;set;}
    public String AccountName {get;set;}
    public Boolean isExceptionOccured {get;set;}
    public Boolean displayContacts {get;set;}
    public List<ContactWrapper> ContList;
    public List<Contact> ContactList {get;set;}
    public class defaultException extends Exception {}
    
    public AddContactsOnSiteTechEventCls(ApexPages.StandardController controller) {
        isExceptionOccured = FALSE;
        displayContacts = FALSE;
        try{
            eventId = system.currentPageReference().getParameters().get('id');
            accountId = system.currentPageReference().getParameters().get('accId');
        }
        catch(exception exp){
            ApexPages.Message expMsg = new ApexPages.Message(ApexPages.Severity.ERROR, exp.getMessage());
            ApexPages.addMessage(expMsg);
        }
    }
    
    public List<ContactWrapper> getContList() {
        return ContList;
    }
    
    public void setContList(List<ContactWrapper> s) {
        ContList= s;
    }
    
    public PageReference Search(){
        try{
            if(accountId == NULL){
                throw new defaultException('This Event should Related to any Account to proceed add contacts, click Cancel to link Account.');
            }
            else{
                Account acc = [SELECT Id, Name FROM Account WHERE Id =: accountId LIMIT 1];
                AccountName = acc.Name;
            }
            
            if(eventId == NULL){
                throw new defaultException('Event record not found...');
            }
            else{
                Event eve = [SELECT Id, RecordTypeName__c FROM Event WHERE Id =: eventId LIMIT 1];
                if(eve.RecordTypeName__c != 'Onsite Tech Support'){
                    throw new defaultException('Expecting Onsite Tech Support, But selected Event Type is: '+eve.RecordTypeName__c);
                }
            }
            //if no exception occured, search for related contacts.
            SearchContact();
        }
        catch(defaultException e){
            isExceptionOccured = TRUE;
            ApexPages.Message dMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            ApexPages.addMessage(dMsg);
        }
        catch(exception exp){
            isExceptionOccured = TRUE;
            ApexPages.Message expMsg = new ApexPages.Message(ApexPages.Severity.ERROR, exp.getMessage());
            ApexPages.addMessage(expMsg);
        }
        return null;
    }
    
    public PageReference SearchContact(){
        displayContacts = TRUE;
        Set<Id> setContactIds = new Set<Id>();
        for(Customer_Event__c cEvent : [SELECT Id, Name, Account__c, Contact__c, Event_Id__c, Event_Contact__c, Contact_Name__c FROM Customer_Event__c WHERE Event_Id__c =: eventId]){
            setContactIds.add(cEvent.Event_Contact__c);
        }
        
        ContactList =[SELECT Id, Name, Country_Code__c, Phone, Email, AccountId FROM Contact WHERE AccountId =: accountId AND Id NOT IN : setContactIds];
        
        if(this.ContList == null)
            this.ContList = new List<ContactWrapper>();
        else
            this.contList.clear();
        
        for(Contact con : ContactList){
            ContactWrapper cw = new ContactWrapper();
            cw.checked=false;
            cw.cat = con;
            system.debug('^^^^^^^^^^'+ContList);
            system.debug('^^^^^^^^^^'+cw);
            ContList.add(cw);  
        }
        
        if(contList.size()==0){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, Label.Info_Message));
            return null;
        }
        return null;
    }
    
    Public PageReference SelectedContact(){
        List<ContactWrapper> selcw = this.ContList;
        system.debug('^^^^^^'+selcw);
        Set<ID>ContId = new Set<Id>();
        for(ContactWrapper cw :selcw){
            if(cw.checked!=False){
                ContId.add(cw.cat.id);
                accountId = cw.cat.Accountid;
            }
        }
        
        List<Customer_Event__c> ceInsertList = new List<Customer_Event__c>();
        for(Id contactId: contId){
            Customer_Event__c cEvent = new Customer_Event__c();
            cEvent.Account__c = accountId;
            cEvent.Event_Id__c = eventId;
            cEvent.Event_Contact__c = contactId;
            ceInsertList.add(cEvent);
        }
        
        if(ceInsertList.size() > 0)insert ceInsertList;
        PageReference FinalPage = new PageReference('/'+eventId);
        return FinalPage;
    }
    
    // Contact Wrapper class
    public class ContactWrapper {
        public Boolean checked { get; set; }
        public Contact cat { get; set; }
        
        public ContactWrapper(){
            cat = new Contact();
            checked = false;
        }
        
        public ContactWrapper(Contact c){
            cat = c;
            checked = false;
        }
        
        public ContactWrapper(Contact c, Boolean checked){
            cat = c;
            this.checked = checked ;
        }
    }
}