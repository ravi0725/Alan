@isTest
private class  ListCaseController_Test
{
    private static testMethod void testAutoRun() {
        test.startTest();
        case defectCase = new Case();
        Case c = new Case(defect__c =defectCase.Id);
        insert c;
        //test try block
        ListCaseController lc1 = new ListCaseController();
        lc1.cId = c.defect__c;
        lc1.recType = 'recType';//hard code correct recType
        lc1.getCases();
 
        //test catch block
        ListCaseController lc2 = new ListCaseController ();
        lc2.cId = c.defect__c;
        lc2.recType = 'recType';
        System.assert(lc2.getCases().isEmpty());
        test.stopTest();
       
    }
}