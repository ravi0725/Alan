/* Class Name  : SPAMCaseDeleteBatchTest
 * Created By  : Prajakta S
 * Description : This is test class for SPAMCaseDeleteBatch class
 */

@isTest(seeAllData = true)
private class SPAMCaseDeleteBatchTest
{


static testmethod void test() {
    Group grp = [select Id from Group where Name = 'SPAM' and Type = 'Queue'];
    
       // Create some test case items to be deleted by the batch job.
     List<Case> caseLst = new List<Case>();
       for (Integer i=0;i<10;i++) {
           Case cseObj = new Case ();
           cseObj.Description = 'Test SPAM Case'+ i;
           cseObj.Subject = 'Test SPAM Case'+ i;
           cseObj.OwnerId = grp.Id;
           caseLst.add(cseObj);
       }
       insert caseLst;
       // The query used by the batch job.
       String query = 'select id from Case where OwnerId = \'' + grp.Id + '\' and Subject like \'Test*\' ';
       Test.startTest();
       SPAMCaseDeleteBatch caseDelBat = new SPAMCaseDeleteBatch (query);
       Database.executeBatch(caseDelBat);
       

       
       Test.stopTest();
    }
}