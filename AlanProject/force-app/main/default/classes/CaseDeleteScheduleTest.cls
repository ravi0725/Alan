/* Class Name  : CaseDeleteScheduleTest
 * Created By  : Prajakta S
 * Description : This is test class for CaseDeleteSchedule class.
 */


@isTest
private class CaseDeleteScheduleTest
{

static testmethod void test() {
String myDateTime = string.valueof( Datetime.now()) ;

       // Create some test case items to be deleted by the batch job.
     List<Case> caseLst = new List<Case>();
     Group grp = [select Id from Group where Name = 'SPAM' and Type = 'Queue'];
       for (Integer i=0;i<10;i++) {
           Case cseObj = new Case ();
           cseObj.Description = 'Test SPAM Case'+ i;
           cseObj.Subject = 'Test SPAM Case'+ i;
           cseObj.OwnerId = grp.Id;
           caseLst.add(cseObj);
       }
       insert caseLst;
       Test.StartTest();
       CaseDeleteSchedule shcObj = new CaseDeleteSchedule();      
       String sch = '0 0 23 * * ?';
       String jobId = system.schedule('Test check', sch, shcObj);
                
       CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
            NextFireTime
            FROM CronTrigger WHERE id = :jobId];            
         
      Test.stopTest();
       
    }

}