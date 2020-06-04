@istest
public with sharing class P1CaseDailyCheckTest {
    static testmethod void testSample() {
        Test.startTest();
        Case c = new Case(Priority1_Follow_up__c = TRUE,
                          //P1_Email_Continuation_Formula__c = TRUE,
                          P1_Case_Escalated_to_Management__c = FALSE, 
                          Priority = 'Level 1: Top', 
                          P1_Email_Number__c = 0, 
                          Priority_Email_1_Date__c = null, 
                          //P1_5_Business_Days_waiting__c = FALSE, 
                          //Day_of_the_Priory_Closed_Date__c = 0,
                          //Priority_P1_Followup_Deadline_Date__c = null,
                          P1_Case_Close_Followup_Status__c = null, 
                          Daily_Trigger_for_Priority_P1_Emails__c = FALSE
                        );
        List<Case> cases = new List<Case>();
        //first 1st if condition & 2nd if condition - Technically both condition are same
        //cases.add(c);
        Case c1 = c;
        c1.P1_Case_Close_Followup_Status__c = null;
        c1.P1_Email_Number__c = 9;
        c1.P1_Case_Close_Followup_Status__c = 'Status 3: Daily Email Triggered on' ;
        //c1.Daily_Trigger_for_Priority_P1_Emails__c = TRUE ;
        //c1.P1_Case_Escalated_to_Management__c = TRUE;
        //c1.Priority = 'Level 1: Top';
        //1st if condition & 2nd if condition - Technically both condition are same
        cases.add(c1);
        
        insert cases;
        
        //------------------------------------------------
        
        List<Case> cases2 = new List<Case>();
        //first 1st if condition & 2nd if condition - Technically both condition are same
        //cases.add(c);
        Case c2 = c;
        c2.P1_Case_Close_Followup_Status__c = null;
        c2.P1_Email_Number__c = 9;
        c2.P1_Case_Close_Followup_Status__c = 'Status 4: Daily Email Triggered on' ;
        //c2.Daily_Trigger_for_Priority_P1_Emails__c = TRUE ;
        //c2.P1_Case_Escalated_to_Management__c = TRUE;
        //c2.Priority = 'Level 1: Top';
        //1st if condition & 2nd if condition - Technically both condition are same
        cases.add(c2);
        
        insert Cases2;
        
        //-------------------------------------------------
        
        P1CaseDailyCheck  cdc = new P1CaseDailyCheck  ();
        cdc.execute(null);
        Test.stopTest();
    }

}