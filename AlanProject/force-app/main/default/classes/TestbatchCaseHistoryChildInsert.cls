@isTest(SeeAllData=true)
public class TestbatchCaseHistoryChildInsert{


      static testmethod void casehistorychildinserttest(){
       Test.startTest();
       batchCaseHistoryChildInsert c = new batchCaseHistoryChildInsert();
       Database.executeBatch(c);
       Test.stopTest();
    }

}