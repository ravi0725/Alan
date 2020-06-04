/*****************************************************************************************
  Name    : ExceptionUtilsTest 
  Desc    : Test class for ExceptionUtils
  Modification Log : 
  ---------------------------------------------------------------------------
  Developer                 Date            Description
  ---------------------------------------------------------------------------
  Suresh Babu Murugan       25/Mar/2019     Created
 ******************************************************************************************/
@isTest
public class ExceptionUtilsTest {
    public static Account accountFail;
    public static Account accountSuccess;

    public static Integer eListSize;
    public static String eCause;
    public static Decimal eLineNumber;
    public static String eMessage;
    public static String eStackTraceString;
    public static String eTypeName;

    static {
        accountFail = new Account();
        accountSuccess = new Account(Name = 'Account 2');
    }

    static testmethod void testAccFailure() {
        try {
            insert accountFail;
        }
        catch(Exception e) {
            ExceptionUtils.captureException(e, true);

            eCause = String.valueOf(e.getCause());
            eLineNumber = e.getLineNumber();
            eMessage = e.getMessage();
            eStackTraceString = e.getStackTraceString();
            eTypeName = e.getTypeName();
        }
        List<Errors_and_Exception__c> exceptionCreated = [SELECT Id, Name, Cause__c, Line_Number__c, Error_Message__c, Stack_Trace_String__c, Exception_Type__c FROM Errors_and_Exception__c];

        eListSize = exceptionCreated.size();
        system.assertEquals(eListSize, 1);

        system.assertEquals(eCause, exceptionCreated[0].Cause__c);
        system.assertEquals(eLineNumber, exceptionCreated[0].Line_Number__c);
        system.assertEquals(eMessage, exceptionCreated[0].Error_Message__c);
        system.assertEquals(eStackTraceString, exceptionCreated[0].Stack_Trace_String__c);
        system.assertEquals(eTypeName, exceptionCreated[0].Exception_Type__c);
    }

    static testmethod void testAccountInsertSuccess() {
        try {
            insert accountSuccess;
        } catch(Exception e) {
            ExceptionUtils.captureException(e, true);

            eCause = String.valueOf(e.getCause());
            eLineNumber = e.getLineNumber();
            eMessage = e.getMessage();
            eStackTraceString = e.getStackTraceString();
            eTypeName = e.getTypeName();
        }
    }
    
     static testmethod void testAccountInsertSuccess1() {
        try {
            insert accountSuccess;
        } catch(DmlException e) {
            ExceptionUtils.captureException(e, true);

            eCause = String.valueOf(e.getCause());
            eLineNumber = e.getLineNumber();
            eMessage = e.getMessage();
            eStackTraceString = e.getStackTraceString();
            eTypeName = e.getTypeName();
        }
    }
    
    static testmethod void testAccountInsertSuccess2() {
        try {
         List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
         Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
         mail.setSenderDisplayName('Trimble SFDC');
       //mail.setOrgWideEmailAddressId(OrgID);
         //mail.setToAddresses();
         mail.setSubject('Credit Evaluation - ');
         String sbody = 'Hi Credit & Collection Team,<Br/><BR />';
         mail.setHtmlBody(sbody);
         mails.add(mail);
         Messaging.sendEmail(mails);
        } catch(EmailException e) {
            ExceptionUtils.captureException(e, true);

            eCause = String.valueOf(e.getCause());
            eLineNumber = e.getLineNumber();
            eMessage = e.getMessage();
            eStackTraceString = e.getStackTraceString();
            eTypeName = e.getTypeName();
        }
    }
}