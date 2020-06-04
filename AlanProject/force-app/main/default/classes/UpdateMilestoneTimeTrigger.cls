global with sharing class UpdateMilestoneTimeTrigger implements Support.MilestoneTriggerTimeCalculator
{
    global Integer CalculateMilestoneTriggerTime(String CaseId, String MilestoneTypeId)
    {
        Case c = [SELECT Time_Remaining__c FROM Case WHERE Id=:caseId];
        MilestoneType mt = [SELECT Name FROM MilestoneType WHERE Id=:milestoneTypeId];
        
        if(integer.valueOf(c.Time_Remaining__c) != 0)
            return integer.valueOf(c.Time_Remaining__c);
        else
            return 1;        

    }

}