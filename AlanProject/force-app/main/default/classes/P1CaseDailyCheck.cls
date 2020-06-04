/***
TT# 126222
Daily Check for for P1: Cases to send Followups to Product Lead

***/


global class P1CaseDailyCheck implements Schedulable {

    global void execute(SchedulableContext ctx) {
        List<Case> CaseList = [Select Id, Priority1_Follow_up__c, P1_Email_Continuation_Formula__c, 
                                      P1_Case_Escalated_to_Management__c, Priority , P1_Email_Number__c, 
                                      Priority_Email_1_Date__c, P1_5_Business_Days_waiting__c,
                                      Day_of_the_Priory_Closed_Date__c, Priority_P1_Followup_Deadline_Date__c,
                                      P1_Case_Close_Followup_Status__c , Daily_Trigger_for_Priority_P1_Emails__c
                               from Case 
                               where 
                               //Priority = 'Level 1: Top'
                               //AND
                               Priority1_Follow_up__c= TRUE 
                               //AND
                               //Priority_P1_Followup_Deadline_Date__c >= :System.Today()
                               //AND
                               //Day_of_the_Priory_Closed_Date__c <= :System.Today()  
                               //AND
                               //P1_Case_Escalated_to_Management__c = FALSE
                               //AND 
                               //P1_Email_Continuation_Formula__c = TRUE 
                               LIMIT 4999];
        
        if(!CaseList.isEmpty()) {
        
            for(Case C: CaseList) {
            
                If(c.Priority1_Follow_up__c == TRUE 
                   &&
                   c.P1_Case_Escalated_to_Management__c == FALSE 
                   && 
                   c.P1_Email_Continuation_Formula__c == TRUE 
                   //&& 
                   //c.Priority_P1_Followup_Deadline_Date__c >= System.Today() 
                   //&&
                   //c.Day_of_the_Priory_Closed_Date__c < System.Today()
                     ){
                    //c.Priority_Email_1_Date__c= System.Today();
                    //c.P1_Email_Number__c = 9;
                    c.P1_Case_Close_Followup_Status__c = 'Status 3: Daily Email Triggered on' + System.Now();
                    c.Daily_Trigger_for_Priority_P1_Emails__c = TRUE ;
                    
                    }
                
                //Else if (c.P1_Case_Escalated_to_Management__c == FALSE &&  c.Priority1_Follow_up__c == TRUE && c.P1_Email_Continuation_Formula__c == TRUE  )
                //    {
                    //c.P1_Email_Number__c = 10;
                //    c.P1_Case_Escalated_to_Management__c = TRUE ;
                //    c.Daily_Trigger_for_Priority_P1_Emails__c = FALSE ;
                    //c.P1_Case_Close_Followup_Status__c = 'Status 4: Escalated to Management - Through TRIGGER';
                                       
                //    }
                Else if ( c.P1_Case_Escalated_to_Management__c == FALSE &&  c.Priority1_Follow_up__c == TRUE && c.P1_Email_Continuation_Formula__c == FALSE && c.P1_5_Business_Days_waiting__c == FALSE)
                
                
                {
                    //c.P1_Case_Close_Followup_Status__c = 'Daily check not fired';
                    //c.P1_Email_Number__c = 11;
                    c.P1_Case_Escalated_to_Management__c = TRUE ;
                    c.Daily_Trigger_for_Priority_P1_Emails__c = FALSE ;
                    c.P1_Case_Close_Followup_Status__c = 'Status 4: Escalated to Management (Triggered)';
                    //c.Priority1_Follow_up__c= FALSE ;
                
                }    
                
                Else
                
                {
                    c.P1_Case_Close_Followup_Status__c = 'Status: Daily check no action fired';
                    
                }
              }
              
            update CaseList;
        }
    }
}