@isTest 
public class TestQuickSpamController {
    static testMethod void testMethod1(){

        List <Case> cases = new List<Case>();
        Case c = new Case(
            Subject = 'Case1 - Subject',
            Status = 'In Progress'
        );
        cases.add(c);
        insert  cases;

        
        Test.startTest();
        Test.setCurrentPage(Page.markspam);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(cases);
        stdSetController.setSelected(cases);
        QuickSpamController qsc = new QuickSpamController(stdSetController);
        qsc.markspam();
        Test.stopTest();
    }
}