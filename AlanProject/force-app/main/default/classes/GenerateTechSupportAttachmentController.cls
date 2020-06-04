/*****************************************************************************************
    Name        : GenerateTechSupportAttachmentController 
    Desc        : Used for generating Tech Support agreement related to an event of a Case record.
                  The event record type should be Hotline Support.                                   
    Project ITEM: ITEM-00783                          
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Sagar Mehta           11/12/2013          Created
******************************************************************************************/
public class GenerateTechSupportAttachmentController {
    
    public String taskId;
    public String quoteId;
    public Event event{get;set;} 
    public String quoteName{get;set;}
    public String accountName{get;set;}
    public String accountNumber{get;set;}
    public String caseNumber{get;set;}
    public String leadName{get;set;}   
    public string pdf1{get;set;} 
    public String userName{get;set;}
    public string AdddName {get;set;}
    public string AccName {get;set;}
    Public String AccNum {get;set;}
    Public String AccAddress {get;set;}
    Public String AccSite {get;set;}
    public Double sumHours{get;set;}
    public Double totalActivityCost{get;set;}
    public Double totalToCost{get;set;}
    public Double totalFromCost{get;set;}
    public Double totalCost{get;set;}
    public Boolean ischarging {get;set;}
    public Apttus_Proposal__Proposal__c quote{get;set;}
    public List<Contact> contactList{get;set;}
    List<Event> eventList = new List<Event>();
    List<Case> caseList = new List<Case>();
    Public Support_Event__c se {get;set;}
    public Event_Template_Language__c languageMap{get;set;}
    public Boolean isSwissEvent {get;set;} // This Boolean defines to display the new sections in documemnt

    /**
     * Method name  : GenerateTechSupportAttachmentController
     * Description  : Constructor of the Controller class - Initializes all the variables.
     *                Populates appropriate data like accountName, caseNumber, event data.
     * Return Type  : 
     * Parameter    : 
     **/
    public GenerateTechSupportAttachmentController(){
        taskId = ApexPages.currentPage().getParameters().get('id');
        quoteId = ApexPages.currentPage().getParameters().get('qId');
        contactList = new List<Contact>();
        eventList = [Select	
        					Id, WhatId, Subject, Type, Status__c, Event_Owner_Name__c, AccountId, Account__c, Account__r.Name, Account_Owner__c, Account__r.Owner.Email, 
        					Description, Language__c, WhoId,Charging__c,External_Description__c, Related_To_Proposal__r.Name, Contract_Number__c, Completion_Time__c, 
        					StartDateTime, OwnerId, Estimated_Hours__c, Activity_Hours__c, Hourly_Cost__c, Activity_Description__c, Activity_Estimate__c, Total_Estimated_Cost2__c, 
        					RecordTypeName__c, Travel_Time_From__c, Travel_Time_To__c, Service_Location__c, Total_OnTech_Cost__c, Total_Time_From_Cost__c, Total_Time_To_Cost__c, 
        					Total_Activity_Cost__c,Total_On_Tech_Hours__c, Total_Actual_Cost__c,
        					According_to_Order__c, Extra_Effort__c, Extra_Effort_Reason__c, Extra_Effort_Needed__c, Reduced_Effort__c, Reduced_Effort_Reason__c,
        					Arrival_Time__c, Lunch_Break_Hours__c, Completed_Time__c, OnSite_Effort_Pending__c, OnSite_Effort_Completed__c,
                     		Additional_Item_Needed__c, Additional_Item_Number__c, Additional_No_of_Items__c
        				FROM
        					Event
        				WHERE 
        					Id =: taskId];
        List<Support_Event__c> SuppEvent = new List<Support_Event__c>();
        
        SuppEvent = [Select id, External_Description__c,Event_ID_Sub__c from Support_Event__c where Event_ID__c =:taskId or Event_ID_Sub__c =:taskId];
     
        if(SuppEvent.size()==1){
            se = SuppEvent[0];
        }
        
        caseList = [Select Id, CaseNumber, Account.Oracle_ID__c, Account.Name from Case where Id =: quoteId];
        if(caseList.size() > 0){
            Case case1 = caseList.get(0);
            accountName = case1.Account.Name;
            accountNumber = case1.Account.Oracle_ID__c;
            caseNumber = case1.CaseNumber;            
        }
                
        pdf1 = '';  
        ID ProposalAccId; 
        if(eventList.size() > 0){
            event = eventList.get(0);
            if(event.Language__c != null){
                languageMap = Event_Template_Language__c.getInstance(event.Language__c);    
            }else{
                languageMap = Event_Template_Language__c.getInstance('English');
            }
            if(event.WhatId != null && string.valueof(event.WhatId).startswith('a3B')){
                ProposalAccId = [Select Apttus_Proposal__Account__c from Apttus_Proposal__Proposal__c where id=:event.whatID].Apttus_Proposal__Account__c;
            }
            sumHours = 0.0; totalActivityCost = 0.0; totalToCost = 0.0; totalFromCost = 0.0;
            if(event.Activity_Hours__c != null){
                sumHours = Double.valueOf(event.Activity_Hours__c); 
            }
            if(event.Travel_Time_To__c != null){
                sumHours = sumHours + Double.valueOf(event.Travel_Time_To__c);
            }
            if(event.Travel_Time_From__c != null){
                sumHours = sumHours + Double.valueOf(event.Travel_Time_From__c);
            }
            if(event.Activity_Hours__c != null && event.Hourly_Cost__c != null){
                totalActivityCost = Double.valueOf(event.Activity_Hours__c) * Double.valueOf(event.Hourly_Cost__c); 
            }
            if(event.Travel_Time_To__c != null && event.Hourly_Cost__c != null){
                totalToCost = Double.valueOf(event.Travel_Time_To__c) * Double.valueOf(event.Hourly_Cost__c);   
            }
            if(event.Travel_Time_From__c != null && event.Hourly_Cost__c != null){
                totalFromCost = Double.valueOf(event.Travel_Time_From__c) * Double.valueOf(event.Hourly_Cost__c);   
            }
            if(event.Charging__c==False)
            {
                ischarging = False;
            }
            if(event.WhatId != null && string.valueof(event.WhatId).startswith('001')){
                String accBillingCountry = [Select Name, BillingCountry FROM Account WHERE id =: event.WhatId].BillingCountry;
                if(accBillingCountry != NULL && accBillingCountry == 'Switzerland'){
                    isSwissEvent = TRUE;
                }
                else{
                    isSwissEvent = FALSE;
                }
            }

            totalCost = totalActivityCost + totalToCost + totalFromCost;
            User user = [Select Id, Name from User where Id =: event.OwnerId];
            userName = user.Name;
        }
        
        List<Lead> leadList = new List<Lead>();
        leadList = [Select Id, Name from Lead where Id =: event.WhoId];
        
        List<Account> AccList = new List<Account>();
        system.debug('******ProposalAccId*******'+ProposalAccId);
        AccList =[Select id,Name,AccountNumber, Billingcity,Address1__c, Billingcountry,Enterprise_Master_ID_del__c,  EBS_Account_Number__c, Billingpostalcode, Billingstreet, Site_Name__c from account where id=:event.WhatId or id =:ProposalAccId];
        
        if(AccList.size()>0)
        {
        AccName = AccList.get(0).Name;
        //AccNum = AccList.get(0).Enterprise_Master_ID_del__c;
        AccNum = (String.isNotBlank(AccList.get(0).EBS_Account_Number__c)?AccList.get(0).EBS_Account_Number__c:'');//----TT #109002
        if(AccList.get(0).Address1__c !=null)
        AccAddress = AccList.get(0).Address1__c + ', '+AccList.get(0).Billingpostalcode+ ' '+AccList.get(0).Billingcity;
        else
        AccAddress = AccList.get(0).BillingStreet+ ', '+AccList.get(0).Billingpostalcode+ ' '+AccList.get(0).Billingcity;
        AccSite = AccList.get(0).Site_Name__c;
        
        }
        
        List<Contact> contactList = new List<Contact>();
        contactList = [Select Id, Name from Contact where Id =: event.WhoId];
        
        if(leadList.size() > 0){
            leadName = leadList.get(0).Name;
        }
        
        if(contactList.size() > 0){
            leadName = contactList.get(0).Name;
        }
    }
    
    /**
     * Method name  : generateAttachment
     * Description  : This method is used to generate the pdf and attach the Tech support pdf to the newly created event.
                      This method is called after the vf page renders as pdf.    
     * Return Type  : PageReference
     * Parameter    : 
     **/
    public PageReference generateAttachment(){
        PageReference pdf = Page.GenerateTechSupportAttachment;
        pdf.getParameters().put('id', taskId); 
        pdf.getParameters().put('qId', quoteId);
        pdf1 = 'pdf';
        // create the new attachment
        Attachment attach = new Attachment();
        // the contents of the attachment from the pdf
        Blob body;
        try {
            // returns the output of the page as a PDF
            body = pdf.getContentAsPDF();
        } catch (VisualforceException e) {
            body = Blob.valueOf('Some Text');
        }
        String myDateEvent = string.valueof(eventList.get(0).StartDateTime);
        attach.Body = body;

        // add the user entered name
        String fileName = eventList.get(0).RecordTypeName__c;
        fileName = 'OTS';
        if(myDateEvent  != ''){
            fileName = fileName + '-(' + myDateEvent+')'; 
        }  
        attach.Name =  fileName + '.pdf';
        attach.IsPrivate = false;
        // attach the pdf to the account
        attach.ParentId = taskId;
        attach.OwnerId = event.OwnerId;
        insert attach;
        
        //---TT#110094--Send Email to Account Owner when Attachment is generated-----------
        if(event.WhatId != null){
            try{
                string subject = 'Onsite Tech Support Event \"'+event.Subject+'\" has been completed [Account: '+ event.Account__r.Name+']';
                EmailTemplate et=[Select id, HTMLValue, Name from EmailTemplate where DeveloperName=:'Event_Notification'];
                string htbody =  et.HTMLValue;
                htbody = htbody.replace('{!Event.Account_Owner__c}', string.isnotblank(event.Account_Owner__c)?event.Account_Owner__c:'');
                htbody = htbody.replace('{!Event.Account__c}',string.isnotblank(event.Account__r.Name)?event.Account__r.Name:'');
                htbody = htbody.replace('{!Event.Subject}',string.isnotblank(event.Subject)?event.Subject:'');
                htbody = htbody.replace('{!Event.Type}',string.isnotblank(event.Type)?event.Type:'');
                htbody = htbody.replace('{!Event.Account__c}',string.isnotblank(event.Account__r.Name)?event.Account__r.Name:'');
                htbody = htbody.replace('{!Event.Event_Owner_Name__c}',string.isnotblank(event.Event_Owner_Name__c)?event.Event_Owner_Name__c:'');
                htbody = htbody.replace('{!Event.Contract_Number__c}',string.isnotblank(event.Related_To_Proposal__r.Name)?event.Related_To_Proposal__r.Name:'');
                htbody = htbody.replace('{!Event.Contract_Status__c}',string.isnotblank(event.Contract_Number__c)?event.Contract_Number__c:'');
                htbody = htbody.replace('{!Event.Service_Location__c}',string.isnotblank(event.Service_Location__c)?event.Service_Location__c:'');
                htbody = htbody.replace('{!Event.Total_Actual_Cost__c}',String.valueOf(event.Total_Actual_Cost__c));
                htbody = htbody.replace('{!Event.Status__c}',string.isnotblank(event.Status__c)?event.Status__c:'');
                htbody = htbody.replace('{!Event.Link}',URL.getSalesforceBaseUrl().toExternalForm() + '/' + event.Id);
                htbody = htbody.replace(']]>','');
                
                String[] toAddresses = new String[] {event.Account__r.Owner.Email};
                system.debug('--toAddresses--'+toAddresses);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setHtmlBody(htbody);
                mail.setPlainTextBody(htbody);
                mail.setSubject(subject);
                mail.setToAddresses(toAddresses);  
                mail.setSenderDisplayName('Salesforce Support');
                mail.setUseSignature(false);
                mail.setBccSender(false);
                mail.setSaveAsActivity(false);  
                  
                Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            }catch(Exception ex){
                system.debug('---exception---'+ex.getMessage()+'--LineNumber:'+ex.getLineNumber()+'--Cause:'+ex.getCause()+'---ErrorType:'+ex.getTypeName());
            }
        }
        // send the user to the account to view results
        return new PageReference('/'+taskId+'?retURL=%2F'+quoteId);
    }
}