/*
 @Author : RS
 @Description : Display Certificate data as pdf and send out to student via Email attachment.
 @Visualforce : CertificatePDFAttachment
 @Test Class : CertificateAttachmentTest
 */
public class CertificateDataAttachment {
    private Id studentId{ get;set; }
    public List<TTraining_Students__c> studentCertList{ get;set; }
    public CertificateDataAttachment(){
        studentId = ApexPages.currentPage().getParameters().get('id');
    }
	public void getStudentCertificate(){
        studentCertList = [Select Id,Contact__r.Name,Certificate_No__c,Awarded_Date__c,Events__r.Course__r.Name
                           from TTraining_Students__c 
                           where Id =: studentId];
        System.debug('studentCertList @@@@@@ '+studentCertList);
    }
}