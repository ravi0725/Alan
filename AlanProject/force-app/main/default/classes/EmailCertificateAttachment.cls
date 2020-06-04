/*
 @Author : RS
 @Description : Send Certificate to student via Email.
 @Visualforce : CertificatePDFAttachment
 @Test Class : CertificateAttachmentTest
 */
public class EmailCertificateAttachment {
	@InvocableMethod(label='Send an email to students' description='sends an email')
    public static void sendEmailWithAttachment(List<id> listofTrainingEvents)
    {
        if(listofTrainingEvents.size() > 0){
            TTraining_Students__c studentCertRec = [Select Id,Contact__r.Name,Certificate_No__c,Email__c,
                                                     Events__r.Course__r.Name,Awarded_Date__c
                                                     from TTraining_Students__c 
                                                     where Id =: listofTrainingEvents.get(0)];
            System.debug('studentCertRec ======== '+studentCertRec);
            try{
                String StudentName = studentCertRec.Contact__r.Name;
                String StudentEmail = studentCertRec.Email__c;
                System.debug('studentCertRec.Email__c ======== '+studentCertRec.Email__c);
                String CourseName = studentCertRec.Events__r.Course__r.Name;
                Date AwardedDate = studentCertRec.Awarded_Date__c;
                String StngDate = AwardedDate.format();
                DateTime dt = DateTime.newInstance(AwardedDate.year(), AwardedDate.month(),AwardedDate.day());
                String newDate = dt.format('MMMM dd, YYYY');
                
                Messaging.SingleEmailMessage semail= new Messaging.SingleEmailMessage();
                Messaging.EmailFileAttachment attach= new Messaging.EmailFileAttachment();
                
                for(Id studentId :listofTrainingEvents)
                {
                    System.debug('Student Id ==== '+studentId);
                    PageReference pref= page.CertificatePDFAttachment;
                    pref.getParameters().put('id',(Id)studentId);
                    pref.setRedirect(true);
                    Blob bc;
                    if(!Test.isRunningTest()){
                        bc = pref.getContent();
                    }
                    attach.setFileName(StudentName+'.pdf');
                    attach.setBody(bc);
                    semail.setSubject('Certificate from your Trimble MEP Course -'+ CourseName);
                    List<String> sendTo = new List<String>();
                    sendTo.add(StudentEmail);
                    String emailBody = 'Dear ' + StudentName + ', <br/><br/>';
                    emailBody += 'Please find attached your Certificate following your attendance at our course '+'\'' + CourseName +'\'' +' '+  newDate + '.'+'<br/><br/>';
                    emailBody += 'We enjoyed looking after you, and hope to see you again at one of our future events.<br/><br/>';
                    emailBody += 'Best regards';
                    semail.setHtmlBody(emailBody);
                    semail.setToAddresses(sendTo);
                    semail.setPlainTextBody('Please find your Course Certificate');
                    semail.setFileAttachments(new Messaging.EmailFileAttachment[]{attach});
                }
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail});
            }catch(Exception e){
                System.debug('Exception type caught: ' + e.getTypeName());    
                System.debug('Message: ' + e.getMessage());    
                System.debug('Cause: ' + e.getCause());    // returns null
                System.debug('Line number: ' + e.getLineNumber());    
                System.debug('Stack trace: ' + e.getStackTraceString());    
            }
        }else{
            
        }
    }
}