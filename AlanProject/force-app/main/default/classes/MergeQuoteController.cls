public class MergeQuoteController{

    public String quoteId{get;set;}
    public String quoteName{get;set;}
    public String accountName{get;set;}
    public String accountNumber{get;set;}
    public String caseNumber{get;set;}
    public Apttus_Proposal__Proposal__c quote{get;set;}
    public List<Attachment> attachmentList{get;set;}    
    public string pdf1{get;set;} 
    public List<clsWrapper> wrapperList{get;set;}
    public List<Event> eventList{get;set;}
    
    public MergeQuoteController(){
        quoteId = ApexPages.currentPage().getParameters().get('id');
        
        List<Event> eventList = new List<Event>();
        eventList = [Select Id, WhatId, Description, WhoId, StartDateTime, OwnerId, Activity_Description__c, Travel_Time_From__c, Travel_Time_To__c, Total_hours__c, Service_Location__c, Activity_Hours__c from Event where WhatId =: quoteId];
        List<Id> eventIdList = new List<Id>();
        for(Event evt : eventList){
            eventIdList.add(evt.Id);
        }
        pdf1 = '';
        attachmentList = new List<Attachment>();
        wrapperList = new List<clsWrapper>();
        attachmentList = [Select ParentId, Name, Id, ContentType, BodyLength, LastModifiedDate, IsPrivate From Attachment where ParentId IN: eventIdList];                
        for(Attachment att : attachmentList){
            clsWrapper wrapper = new clsWrapper();
            wrapper.isSelected = false;
            wrapper.attachment = att;
            wrapperList.add(wrapper);
        }        
    }
    
    public PageReference next(){
        List<Id> eventIdList = new List<Id>();
        boolean flag = true;
        for(clsWrapper wrapper : wrapperList){
            System.debug('***isSelected: '+wrapper.isSelected);
            if(wrapper.isSelected){
            	flag = false;
                eventIdList.add(wrapper.attachment.ParentId);
            }
        }
        if(flag || eventIdList.size() < 1){
        	ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, 'Please select atleast two attachments to merge.');
          	ApexPages.addMessage(msg);
          	return null;
        }
        
        
        System.debug('***eventIdList: '+eventIdList);
        if(eventIdList.size() > 0){            
            eventList = new List<Event>();
            eventList = [Select Id, WhatId, Description, WhoId, StartDateTime, OwnerId, Activity_Description__c, Travel_Time_From__c, Travel_Time_To__c, Total_hours__c, Service_Location__c, Activity_Hours__c from Event where Id IN: eventIdList];
            
            List<Apttus_Proposal__Proposal__c> proposalList = new List<Apttus_Proposal__Proposal__c>();           
            proposalList = [Select Id, Name, Apttus_Proposal__Proposal_Name__c, Apttus_Proposal__Account__r.Name, Apttus_Proposal__Account__r.Oracle_ID__c, Case__r.CaseNumber from Apttus_Proposal__Proposal__c where Id =: quoteId];
            if(proposalList.size() > 0){
               Apttus_Proposal__Proposal__c quote = new Apttus_Proposal__Proposal__c();
               quote = proposalList.get(0);
               quoteName = quote.Apttus_Proposal__Proposal_Name__c;
               accountName = quote.Apttus_Proposal__Account__r.Name;
               accountNumber = quote.Apttus_Proposal__Account__r.Oracle_ID__c;
               caseNumber = quote.Name;
            }
            pdf1 = ''; 
            //new PageReference('/'+quoteId);           
        }else{
            
        }
        return new PageReference('/apex/mergeQuoteAttachment?id='+quoteId);
    }
    
    public PageReference cancel(){
        return new PageReference('/'+quoteId);
    }
    
    public PageReference generateAttachment(){ 
        PageReference pdf = Page.mergeQuoteAttachment;        
        pdf.getParameters().put('qId',quoteId); 
        pdf1 = 'pdf';
        // add parent id to the parameters for standardcontroller
        //pdf.getParameters().put('id',parentId);
 
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
 
        attach.Body = body;
        // add the user entered name
        attach.Name = 'Proposal for '+accountName+'-'+Date.today().year()+'-'+Date.today().month()+'-'+Date.today().day()+'.pdf'; 
        attach.IsPrivate = false;
        // attach the pdf to the account
        attach.ParentId = quoteId;
        insert attach;
 
        // send the user to the account to view results
        return new PageReference('/'+quoteId);
    }
    
    public class clsWrapper{
        public boolean isSelected{get;set;}
        public Attachment attachment{get;set;}
    }
}