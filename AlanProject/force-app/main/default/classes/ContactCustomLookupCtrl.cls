/**
 * Company     : Trimble Software Technology Pvt Ltd.,
 * Description : .
 * History     :  

 * [28.Nov.2013] Srinivasan Babu  Created
 */
public class ContactCustomLookupCtrl {
    Set<ID>nConID = new Set<ID>();
    public Id custeveId;
    public Id eventId {get;set;}
    public Id accountId {get;set;}
    public Id acctId;
    public List<Contact> listContact {get;set;}
    public boolean shouldRedirect {get;set;}{shouldRedirect = false;}
    public string url {get;set;}
    public string SelectedContId { get; set; }
    Public List<ContactWrapper> ContList;
    Public Boolean disablebutton {get;set;}
    public Map<Id, Customer_Event__c> ceMap {get; set;}
    Public list<Customer_Event__c> ListUpdate = new List<Customer_Event__c>();
    
    public List<ContactWrapper> getContList() {
        return ContList;
    }
    
    public void setContList(List<ContactWrapper> s) {
        ContList= s;
    }
    
    public ContactCustomLookupCtrl(){
        eventId = System.currentPageReference().getParameters().get('eventId');
        accountId = System.currentPageReference().getParameters().get('accountId');
        LoadData();
        system.debug('SelectedContId>>>>'+SelectedContId);
    }
    
    public void LoadData(){
        listContact = new List<Contact>();
        ceMap = new Map<Id, Customer_Event__c>();
        for(Customer_Event__c oCustEvent : [select Id, Account__c,
                       Account__r.Name,
                       Account__r.BillingStreet,
                       Account__r.BillingState,
                       Account__r.BillingCountry,Contact_Names__c,
                       Account__r.BillingCity,
                       Event_Id__c, Event_Contact__c, Contact_Name__c from Customer_Event__c where Event_Id__c =: eventId AND Account__r.Id =: accountId]){
                    system.debug('--contact--'+oCustEvent.Event_Contact__c);
            if(!ceMap.containsKey(oCustEvent.Event_Contact__c)){
                ceMap.put(oCustEvent.Event_Contact__c, oCustEvent);
            }                                 
        }
    
        system.debug('--ceMap--'+ceMap+'/n'+ceMap.Values().size());
        if(this.ContList == null)
        this.ContList = new List<ContactWrapper>();
        
        listContact = [Select Id, LastName, FirstName,Customer_Event__c,Country_Code__c,phone,Email, Name from Contact where AccountId =: accountId];
        for(contact con : listContact)
        {
            ContactWrapper cw = new ContactWrapper();
            if(ceMap.containsKey(con.Id)){
                cw.checked=true;
                nConID.add(con.id);
            }
            cw.cat = con;
            ContList.add(cw);  
        }
            
        if(listContact.size()==0){
            disablebutton = True;
        }
    }
    
    public PageReference SelectedContact(){
        List<Customer_Event__c> deleteCEList = new List<Customer_Event__c>();
        List<Customer_Event__c> insertCEList = new List<Customer_Event__c>();
        List<ContactWrapper> selcw = this.ContList;
        Set<ID>ContId = new Set<Id>();
        Set<ID>ConIdDel = new Set<ID>();
        system.debug('--ceMap-2-'+ceMap+'/n'+ceMap.Values().size());
        for(ContactWrapper cw :selcw)
        {
            if(cw.checked==True)
            {
                ContId.add(cw.cat.id);
                system.debug('--ceMapContains--'+ceMap.containsKey(cw.cat.id));
                if(!ceMap.containsKey(cw.cat.id)){
                    Customer_Event__c ce = new Customer_Event__c();
                    ce.Event_Id__c = eventId;
                    ce.Account__c = accountId;
                    ce.Event_Contact__c = cw.cat.id;
                    insertCEList.add(ce);
                }
            }
            else
            {
                ConIdDel.add(cw.cat.id);
                if(ceMap.containsKey(cw.cat.id)){
                    deleteCEList.add(ceMap.get(cw.cat.id));
                }
            } 
        }
        
        system.debug('--insertCEList--'+insertCEList);
        if(insertCEList.size() > 0)
        insert insertCEList;
        system.debug('--eventId--'+eventId);
        if(deleteCEList.size() > 0)
        delete deleteCEList; 
        
        //If No contacts are selected then.
        if(ContId.size()==0)
        {
            List<Contact> ConLi = [select id,Name,Country_Code__c,Phone,Email,Account.Name from contact where id in:nConID];
            String TotalCont=' ';
            String AccName=' ';
            String sDesc=' ';
            String oBjType=' ';
            
            system.debug('--eventId--'+eventId);
            Event e = [Select id,Description,whatid,whoid,what.Name,who.Name from event where id=:eventId];
            
            for(Contact c : ConLi)
            {
                AccName = c.Account.Name;
                TotalCont = TotalCont + 'Contact Name: ' +c.Name + ', Country Code: ' +c.Country_Code__c + ', Phone: '+c.Phone +', Email: '+c.Email+' ';
                e.Description = e.Description.replace(TotalCont,' ');
                TotalCont=' ';
                system.debug('This is the New Value'+e.Description);
            }
            e.Description = e.Description.trim().replaceall(';;',';');  
            if(e.WhatId!=null)
            ObjType = String.valueof(e.WhatId).substring(0,3);
            
            if(e.WhatId!=null && ObjType=='001')
            sDesc = 'Related To: '+e.What.Name+';';
            
            if(e.WhoId!=null)
            sDesc =sDesc+' Name: '+ e.Who.Name+';';
            
            system.debug('&&&&&&&&&&'+TotalCont);
            system.debug('&&&&&&&&&&'+sDesc);
            
            AccName = 'Account Name: '+AccName;
            e.Description = e.Description.replaceall(AccName,' ');
            e.Description = e.Description.replaceFirst(sDesc,' ');
            
            update e;
            
        }
   
        PageReference FinalPage;
        FinalPage=new PageReference('/'+eventId);
        url = '/'+eventId;        
        shouldRedirect = true;
        return FinalPage;
    }
    
    public PageReference Cancel() {
        PageReference FinalPage;
        FinalPage=new PageReference('/'+eventId);
        url = '/'+eventId;        
        shouldRedirect = true;
        return FinalPage;
    }  
    
    public class ContactWrapper {
        public Boolean checked { get; set; }
        public Contact cat { get; set; }
    }
}