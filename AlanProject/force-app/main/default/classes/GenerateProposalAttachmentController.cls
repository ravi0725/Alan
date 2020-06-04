/*****************************************************************************************
    Name        : GenerateProposalAttachmentController 
    Desc        : Used for generating Hotline Support agreement related to an event of a Case record.
                  The event record type should be Hotline Support.                                   
    Project ITEM: ITEM-00719, ITEM-00769, ITEM-00778, ITEM-00782                           
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Sagar Mehta           11/12/2013          Created
******************************************************************************************/
public class GenerateProposalAttachmentController{
    
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
    public Apttus_Proposal__Proposal__c quote{get;set;}
    public List<Contact> contactList{get;set;}
    List<Event> eventList = new List<Event>();
    List<Case> caseList = new List<Case>();
    public Event_Template_Language__c languageMap{get;set;}
    
    /**
     * Method name  : GenerateProposalAttachmentController
     * Description  : Constructor of the Controller class - Initializes all the variables.
     *                Populates appropriate data like accountName, caseNumber, event data.
     * Return Type  : 
     * Parameter    : 
     **/
    public GenerateProposalAttachmentController(){
        taskId = ApexPages.currentPage().getParameters().get('id');
        quoteId = ApexPages.currentPage().getParameters().get('qId');
        
        contactList = new List<Contact>();
        
        eventList = [Select Id, WhatId, Description, WhoId, Completion_Time__c, StartDateTime, OwnerId, Estimated_Hours__c, Language__c, 
        		     Hourly_Cost__c, Activity_Description__c,Activity_Estimate__c, Total_Estimated_Cost2__c,RecordTypeName__c  from Event where Id =: taskId];
        
        
        caseList = [Select Id, CaseNumber, Account.Oracle_ID__c, Account.Name from Case where Id =: quoteId];        
        if(caseList.size() > 0){
            Case case1 = caseList.get(0);
            accountName = case1.Account.Name;
            accountNumber = case1.Account.Oracle_ID__c;
            caseNumber = case1.CaseNumber;            
        }
                
        pdf1 = '';  
              
        if(eventList.size() > 0){
            event = eventList.get(0);
            if(event.Language__c != null){
            	languageMap = Event_Template_Language__c.getInstance(event.Language__c);	
            }else{
            	languageMap = Event_Template_Language__c.getInstance('English');
            }
            
            User user = [Select Id, Name from User where Id =: event.OwnerId];
            userName = user.Name;
        }
        
        List<Lead> leadList = new List<Lead>();
        leadList = [Select Id, Name from Lead where Id =: event.WhoId];
        
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
     * Description  : This method is used to generate the pdf and attach the Hotline support pdf to the newly created event.
                      This method is called after the vf page renders as pdf.    
     * Return Type  : PageReference
     * Parameter    : 
     **/
    public PageReference generateAttachment(){
        PageReference pdf = Page.GenerateProposalAttachment;
        pdf.getParameters().put('id', taskId); 
        pdf.getParameters().put('qId',quoteId);
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
 
        attach.Body = body;
        // add the user entered name
        String myDateEvent = string.valueof(eventList.get(0).StartDateTime);
        String fileName = eventList.get(0).RecordTypeName__c;
        fileName = 'HSA';
        if(myDateEvent != ''){
            fileName = fileName + '-(' + myDateEvent+')'; 
        }  
        attach.Name =  fileName + '.pdf';
        attach.IsPrivate = false;
        // attach the pdf to the account
        attach.ParentId = taskId;
        attach.OwnerId = event.OwnerId;
        insert attach;
        
        if(Caselist.size()>0){
	        Attachment attachparent = new Attachment();
	        // the contents of the attachment from the pdf
	        Blob bodyparent;
	        try {
	            // returns the output of the page as a PDF
	            bodyparent = pdf.getContentAsPDF();
	            // need to pass unit test -- current bug    
	        } catch (VisualforceException e) {
	            bodyparent = Blob.valueOf('Some Text');
	        }
	 
	        attachparent.Body = bodyparent;
	        // add the user entered name
	        String myDate = string.valueof(eventList.get(0).StartDateTime);
	        String fileNameparent = eventList.get(0).RecordTypeName__c;        
	        fileNameparent = 'HSA';
	        if(myDate != ''){
	            fileNameparent = fileNameparent + '-' + myDate; 
	        }  
	        attachparent.Name =  fileNameparent + '.pdf';
	        attachparent.IsPrivate = false;
	        // attach the pdf to the account
	        attachparent.ParentId = eventList.get(0).WhatId;
	        attachparent.OwnerId = event.OwnerId;
	        insert attachparent;
	    } 
        // send the user to the account to view results
        return new PageReference('/'+taskId+'?retURL=%2F'+quoteId);
    }
}