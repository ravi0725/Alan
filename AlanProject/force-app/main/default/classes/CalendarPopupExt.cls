/**
 * Company     : Trimble Software Technology Pvt Ltd.,
 * Description : Controller Class For PopupPage Visualforce Page
 * History     :  

 * [09.05.2014] Prince Leo  Created
 */
public without sharing class CalendarPopupExt{
    
    public Id eventId {get;set;}
    public List<Customer_Event__c> listCustomer {get;set;}
    Public List<Contact> Con {get;set;}
    public Customer_Event__c oCustomerEvent {get;set;}
    public string SelectedCustEventId { get; set; }
    public string url {get;set;}
    private Map<Id, Customer_Event__c> mapCustomers;
    Private Map<Id,List<Contact>>mapContact;
    public String startString {get;private set;}
    public String endString {get;private set;}
    public String dtFormat = 'EEE, d MMM yyyy HH:mm:ss';
    private String timeZone = UserInfo.getTimeZone().getID();
    public Event ev{get;set;}
    public Account acc{get;set;}
    public CalendarPopupExt(ApexPages.StandardController controller) {
             
        eventId = System.currentPageReference().getParameters().get('id');
        Ev= [select id,subject,Who.Name,what.Name,Mobile_Phone__c,StartDateTime,EndDateTime from Event where id=:eventId];
        if((Ev.whatId != null ? String.valueof(Ev.whatId).startswith('001') : false)){
            acc = [select Id,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry from Account where ID =: ev.WhatId];
        } 
  if(ev != null)
  {
    DateTime startDT = Ev.StartDateTime;
    DateTime endDT = Ev.EndDateTime;
    startString = startDT.format(dtFormat, timeZone);
    endString = endDT.format(dtFormat, timeZone);
           
        listCustomer = new List<Customer_Event__c>();
        oCustomerEvent = new Customer_Event__c();
        LoadData();
    }
    else
    {
    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,Label.Calendar_Popup_Info));
    }
   }
      public void LoadData(){
        Set<Id> CustomerEventId = new Set<Id>();
        Set<Id> AccId = new Set<Id>();
        mapCustomers = new Map<Id, Customer_Event__c>();
        for(Customer_Event__c oCustEvent : [select Id, Account__c,
                                                   Account__r.Name,
                                                   Account__r.BillingStreet,
                                                   Account__r.BillingState,
                                                   Account__r.BillingCountry,
                                                   Account__r.BillingCity,Account__r.Billingpostalcode,
                                                   Event_Id__c,Contact_Names__c,Account__r.Enterprise_Party_Number__c,
                                                   Customer_Related_Contact__c,
                                                   Contact__c from Customer_Event__c where Event_Id__c =:eventId ]){
                                                               
           mapCustomers.put(oCustEvent.Account__c, oCustEvent);
           CustomerEventId.add(oCustEvent.Id);
           AccId.add(oCustEvent.Account__c);
           }
     Con = [select id, Name,Accountid,Phone,MobilePhone,Account.Name from contact where Customer_Event__c in:CustomerEventId and Accountid in:AccId];
     
        listCustomer = mapCustomers.values();
     
        listCustomer.sort();
       
    }
    
   }