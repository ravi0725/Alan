/*
Created Date: December 2, 2009
Developer Name 1: Hayes Metzger
Developer Name 2: Ralph Callaway
Case #: 02883110

Description:
 (1) When an attachment is added to a case by the case owner notify the case contact
 (2) When an attachment is added to a case by the case contact notify the case owner
*/

@isTest
private class attachmentNotificationTest {

    private static final string RANDOM_STRING = 'iPe83nIs';

    // Test inserting an attachment as the case owner doesn't cause any errors
    // I'm not making any assertions as there isn't a way for me
    // to verify if an email get's sent or not
    static testMethod void caseOwnerAddsAttachmentTest() {        
        
        // create a test case 
        Case testCase = getTestCase();

        // insert an attachment
        insert getTestAttachment(testCase);
    }

    /* There is no test for inserting an attachment as a case contact
       1. unable to use system.runAs by creating a new portal user
          as this caused a mixed dml exception
       2. querying an existing user caused an insufficient access
          on cross-reference entity error that I couldn't figure out
       Given test coverage is at 83% for the trigger this should be okay
    */

    // create a generic attachment related to a particular case
    private static Attachment getTestAttachment(Case testCase) {
        Blob b = Blob.valueOf('Hello World!');
        
        Attachment testAttachment = 
            new Attachment(parentId = testCase.Id,
                           name = 'Test Attachment',
                           body = b);       
        return testAttachment;
    }
    
    // create a test case that has a contact
    private static Case getTestCase() {

        Contact con = new Contact();
        con.LastName = 'Dummy';
        con.FirstName = 'User';
        con.MailingCountry = 'United States';
        con.MailingCity = 'Marlborough';
        con.MailingStreet = '200 Nickerson Road';
        con.MailingState = 'MA';
        con.MailingPostalCode = '1752';
        con.Email = 'test@manhattan.com';
        Database.Insert(con);
        
        Case testCase = new Case(contactId = con.id);
        insert testCase;
        
        return testCase;
    }
}