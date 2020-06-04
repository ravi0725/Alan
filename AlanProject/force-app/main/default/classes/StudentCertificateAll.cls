/*
 @Author : RS
 @Description : Fetch the student details to display in Certificate.
 @Visualforce : Student_Certificate
 @Test Class : CertificateAttachmentTest
 */
public class StudentCertificateAll {
    private final TTraining_Events__c trainingEvt;
    public List<TTraining_Students__c> studentCertList{ get;set; }

    public StudentCertificateAll(ApexPages.StandardController stdController) {
        this.trainingEvt = (TTraining_Events__c)stdController.getRecord();
    }
    public void getStudentCertificate(){
        studentCertList = [Select Id,Name,Events__r.Course__r.Name,
                           Contact__r.Name,Certificate_No__c,Awarded_Date__c
                           from TTraining_Students__c 
                           where Events__c =: trainingEvt.Id];
    }
}