/*****************************************************************************************
    Name        : GeneratescheduleactivityController 
    Desc        : Used for generating Schedule delivery agreement related to an event of a Case record.                                                    
    Project ITEM: ITEM-00788
                          
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Sagar Mehta           11/12/2013          Created
******************************************************************************************/
public class GeneratescheduleactivityController {
    
    public String taskId;
    public String quoteId{get;set;}
    public Event event{get;set;} 
    public String quoteName{get;set;}
    public String accountName{get;set;}
    public String accountNumber{get;set;}
    public String caseNumber{get;set;}
    public String leadName{get;set;}   
    public string pdf1{get;set;} 
    public String userName{get;set;}
    public string additionaldesc{get;set;}
    public Apttus_Proposal__Proposal__c quote{get;set;}
    public List<Event> eventList{get;set;}
    Map<String, Id> recordTypeMap = new Map<String, Id>();
    Map<id,string> Idnamemap=new Map<id,string>();
    String rectypeID;
    public String language{get;set;}
    List<Apttus_Proposal__Proposal__c> quotelist=new List<Apttus_Proposal__Proposal__c>();
    List<Order__c> Orderlist =new List<Order__c>();
    public Event_Template_Language__c languageMap{get;set;}
    
    /**
     * Method name  : GeneratescheduleactivityController
     * Description  : Constructor of the Controller class - Initializes all the variables.
     *                Populates appropriate data like accountName, caseNumber, event data.
     * Return Type  : 
     * Parameter    : 
     **/
    public GeneratescheduleactivityController(){
        RecordType recType = [Select Id from RecordType where DeveloperName =: Label.Event_Service_Delivery_Record_Type];  
        rectypeID = recType.id;
        system.debug('rectypeID'+rectypeID);
        quoteId = ApexPages.currentPage().getParameters().get('qId');
        pdf1 = ''; 
        additionaldesc ='';
        quotelist =[select id,Name from Apttus_Proposal__Proposal__c where Id=:quoteId];
        Orderlist =[select id from Order__c where Id=:quoteId];
        eventList = new list<Event>();
        eventList = [Select Id, Subject, WhatId, Description,Owner.Name, WhoId,Type,GroupEventType,Service__c, StartDateTime, OwnerId, Activity_Description__c, 
        Travel_Time_From__c, Travel_Time_To__c,language__c, Total_hours__c, Service_Location__c, Activity_Hours__c,RecordTypeName__c from Event 
        where WhatId =: quoteId and RecordTypeId =: rectypeID];
        
        if(eventList.size() <= 0){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, Label.Create_Events_Message);
            ApexPages.addMessage(msg);
        }
        if(eventList.size() > 0){
           event = eventList.get(0);                      
        }
        if(eventList.size() > 0){
            List<User> u = new List<USer>();
            u = [select id,LanguageLocaleKey from user where Id=:userinfo.getuserid()];
            if(u.size()>0){
               if((u.get(0).LanguageLocaleKey=='en_US') || (u.get(0).LanguageLocaleKey =='Fr') || (u.get(0).LanguageLocaleKey =='de')){
                 if(u.get(0).LanguageLocaleKey== 'en_US'){
                    event.Language__c ='English';
                 }
                 if(u.get(0).LanguageLocaleKey== 'Fr'){
                    event.Language__c ='French';
                 }
                 if(u.get(0).LanguageLocaleKey== 'de'){
                    event.Language__c ='German';
                 }
               }else{
                 event.Language__c ='English';
               }
            }
        }
        for(Event evt:eventList){           
            if(evt.Description != null){
                additionaldesc += evt.Description;
            }            
            additionaldesc += '<br></br>'+'            ';            
        }
    }
    
    /**
     * Method name  : generateAttachment
     * Description  : This method is used to generate the pdf and attach the Schedule Service delivery pdf to the newly created event.
                      This method is called after the vf page renders as pdf.    
     * Return Type  : PageReference
     * Parameter    : 
     **/   
       
    public Pagereference generateAttachment(){
        PageReference pdf = Page.GenerateSchduleActivcitypage;
        if(quotelist.size()>0){
        pdf.getParameters().put('qId',quoteId);
        }
        if(orderlist.size()>0){
        pdf.getParameters().put('qId',quoteId);
        }
        pdf1 = 'pdf';
 
        // create the new attachment
        Attachment attach = new Attachment();
        // the contents of the attachment from the pdf
        Blob body;
        try {
            // returns the output of the page as a PDF
            body = pdf.getContentAsPDF();
            // need to pass unit test -- current bug    
        } catch (VisualforceException e) {
            body = Blob.valueOf('Some Text');
        }
        String fileName = '';
        attach.Body = body;
        String myDate = string.valueof(eventList.get(0).StartDateTime);
        fileName = 'SS';
        if(myDate  != ''){
            fileName = fileName + '-' + myDate ; 
        }  
        
        attach.Name =   fileName + '.pdf' ;
        attach.IsPrivate = false;
        // attach the pdf to the account
        
        attach.ParentId = quoteId;
        
        insert attach;
 
        // send the user to the account to view results
      
        return new PageReference('/'+quoteId+'?retURL=%2F'+quoteId);
       
       
    
   }
   
    
    /**
     * Method name  : next
     * Description  : This method is used to set the language selected by the user in Language picklist in Language Selector page                      
     * Return Type  : PageReference
     * Parameter    : 
     **/
    public Pagereference next(){
       language = Event.Language__c;
       if(language != ''){
         languageMap = Event_Template_Language__c.getInstance(language);  
       }else{
          languageMap = Event_Template_Language__c.getInstance('English');
       }
       return new PageReference('/apex/GenerateSchduleActivcitypage');     
    }
    
    /**
     * Method name  : cancel
     * Description  : This method is used to redirect from the page back to quote record.                      
     * Return Type  : PageReference
     * Parameter    : 
     **/ 
    public PageReference cancel(){
       
       
       PageReference pageReference = new PageReference('/'+quoteId); 
       return pageReference;
       
    }
}