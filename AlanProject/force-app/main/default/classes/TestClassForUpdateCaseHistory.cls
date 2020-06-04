@isTest(SeeAllData=true)
public class TestClassForUpdateCaseHistory {


      static testmethod void casehistorytest(){
       Test.startTest();
       batchCaseHistoryChildUpdate c = new batchCaseHistoryChildUpdate();
       Database.executeBatch(c);
       Test.stopTest();
    }

}