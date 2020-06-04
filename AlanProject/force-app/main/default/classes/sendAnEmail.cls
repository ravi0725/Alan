public class sendAnEmail
{
    @InvocableMethod(label='Send an email from apex class' description='sends an email')
    public static void sendEmailWithAttachment(List<id> listofQuoteHeader)
    {
           for(Id QuoteHeaderid :listofQuoteHeader)
           {
               PageReference pref= page.Quote_PDF;
               pref.getParameters().put('id',(Id)QuoteHeaderid);
               pref.setRedirect(true);
               
               Attachment attachment = new Attachment();      
               Blob b=pref.getContentAsPDF();
               attachment.Body = b;
               attachment.Name = Datetime.now().format('yyyy-MM-dd HH:mm') + ' ' + 'Quote' + '.pdf';
               attachment.IsPrivate = false;
               attachment.ParentId = QuoteHeaderid;
               insert attachment;
               
               Messaging.SingleEmailMessage semail= new Messaging.SingleEmailMessage();
               Messaging.EmailFileAttachment attach= new Messaging.EmailFileAttachment();
               attach.setBody(pref.getContentAsPDF());
               semail.setSubject('Quote Issued');
               String[] emailIds= new String[]{'**********@gmail.com'};
               semail.setToAddresses(emailIds);
               semail.setPlainTextBody('Please find the attached quote details');
               semail.setFileAttachments(new Messaging.EmailFileAttachment[]{attach});
               Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail});
           }
    }

}