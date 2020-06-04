@IsTest
public class CertificateAttachmentTest {
	@testSetup static void setup() {
        
        TTraining_Instructors__c inst = new TTraining_Instructors__c();
        inst.Name = 'Test Instructor';
        insert inst;
        
        TTraining_Events__c events = new TTraining_Events__c();
        events.Type__c = 'Public';
        insert events;
        
        Contact con = new Contact();
        con.LastName = 'Test Name';
        insert con;
        
        TTraining_Course_Templates__c course = new TTraining_Course_Templates__c();
        course.Name = 'Test Course';
        insert course;
        
        TTraining_Students__c stud = new TTraining_Students__c();
        stud.Awarded_Date__c = System.today() + 5;
        stud.Contact__c = con.id;
        stud.Events__c = events.Id;
        insert stud;
        
    }
    
    @isTest static void EmailAttachmentAndPdf() {
        
        List<TTraining_Students__c> studentCertList = [Select Id,Contact__r.Name,Certificate_No__c,Awarded_Date__c,Events__r.Course__r.Name
                                                       from TTraining_Students__c];
        
        List<TTraining_Events__c> events = [Select Id,Type__c from TTraining_Events__c];
        
        CertificateDataAttachment cert = new CertificateDataAttachment();
        cert.getStudentCertificate();
        
        ApexPages.StandardController standardController = new ApexPages.standardController(events.get(0));
        StudentCertificateAll certAll = new StudentCertificateAll(standardController);
        certAll.getStudentCertificate();
        
        Test.startTest();
            PageReference pageRef = Page.CertificatePDFAttachment; //create a page reference to attachPDFToAccount.page
            Test.setCurrentPage(pageRef); //set page context
            EmailCertificateAttachment.sendEmailWithAttachment(new List<Id>{studentCertList.get(0).Id});
        	Integer invocations = Limits.getEmailInvocations();
        	System.debug('invocations ======'+invocations);
        Test.stopTest();
 
        System.assertEquals(0, invocations, 'An email has not been sent');
    }
    
    @isTest static void EventCalendar() {
        List<TTraining_Instructors__c> instList = [Select Id,Name from TTraining_Instructors__c];
        List<TTraining_Events__c> events = [Select Id,Type__c from TTraining_Events__c];
        EventCalendarCls.getEvents();
        EventCalendarCls.getEventData(events.get(0).Id);
    }
    
    
}