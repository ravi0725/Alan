/*****************************************************************************************
    Name        : InboundEmailHandler 
    Desc        : InboundEmailHandler class is a global class.
                  It is invoked by Email Service InboundEmailService.
                  This class attaches the attachment from the newly generated mail from Quote record.                                                       
    Project ITEM: ITEM-00733                         
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Sagar Mehta          11/29/2013          Created
******************************************************************************************/
global class InboundEmailHandler implements Messaging.InboundEmailHandler {
   
   /**
     * Method name  : handleInboundEmail
     * Description  : This method is overridden.
     *                This method is used to retireve the attachment associated with the new email send through Quote record.
     *                Send an email functionality do not save attachment with the task for the mail which is being sent.
     *                This method is used to save attachment to associate it with the newly created task.                 
     * Return Type  : Messaging.InboundEmailResult 
     * Parameter    : Messaging.InboundEmail, Messaging.InboundEnvelope
     **/    
   global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope){
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        String subject = email.subject;
        Integer index;
        String taskidnew;
        if(subject.contains('Sandbox')){
           index = subject.lastIndexof('Sandbox: ');    
           taskidnew = subject.substring(index+9, 19);
        }else{ 
           index = subject.lastIndexof('Q-');       
           taskidnew = subject.substring(index, 10);
        }        
        
        List<Apttus_Proposal__Proposal__c> quotelist=new List<Apttus_Proposal__Proposal__c>();
        quotelist =[select id from Apttus_Proposal__Proposal__c where Name =: taskidnew];
        
        List<Task> tasklist=new List<Task>();
        tasklist =[select id, ownerid, CreatedDate from task where whatid =: quotelist.get(0).id ORDER BY CreatedDate DESC];
        
        if(email.binaryAttachments != null && email.binaryAttachments.size() > 0) {
           for(integer i = 0 ; i < email.binaryAttachments.size() ; i++) {
               Attachment attachment = new Attachment();
               // attach to the newly created analysis certificate record
               attachment.ownerid = tasklist.get(0).ownerid;
               attachment.ParentId = tasklist.get(0).Id;
               attachment.Name = email.binaryAttachments[i].filename;
               attachment.Body = email.binaryAttachments[i].body;
               insert attachment;
           }
        }
        return result;
   }
}