public class CaseUtility
{
    public static Boolean isFirstTime = true;
    
    public static void newCaseSLA(List<Case> caseList)
    {
        List<Id> acntIdLst = new List<Id>();
        Map<Id, Client_Info__c> clientInfoMap = new Map<Id, Client_Info__c>();
        Map<String, Entitlement>  entitlementMap = new Map<String, Entitlement>();
        for(Case c: caseList)
        {
            acntIdLst.add(c.AccountId);
        }
        System.debug('---acntIdLst---'+acntIdLst);
        for(Entitlement e : [Select Id, Name from Entitlement where SlaProcessId != null and SlaProcessId in : [select ID from SLAPRocess where Name != 'TAP Entitlement Process']])
        {
            entitlementMap.put(e.Name, e);
        }
        System.debug('---entitlementMap---'+entitlementMap);
        for(Client_Info__c ci : [Select Time_Zone__c, Account__c, EMERGENCY_Permanent_Fix_SLA__c, HIGH_Permanent_Fix_SLA__c, MEDIUM_Permanent_Fix_SLA__c, LOW_Permanent_Fix_SLA__c from Client_Info__c where  Account__c in: acntIdLst and EMERGENCY_Permanent_Fix_SLA__c != null and HIGH_Permanent_Fix_SLA__c != null and MEDIUM_Permanent_Fix_SLA__c != null and LOW_Permanent_Fix_SLA__c != null ])
        {
            clientInfoMap.put(ci.Account__c, ci);        
         }
        System.debug('---clientInfoMap---'+clientInfoMap);
        
        if(!clientInfoMap.isEmpty())
        {
            for(Case c: caseList)
            {
                String TZ;
                c.Colour__c = 'Green';
                if(clientInfoMap.containsKey(c.AccountId))
                    TZ = clientInfoMap.get(c.AccountId).Time_Zone__c;
                System.debug('---c.Priority---'+c.Priority);
                
                if(c.Priority == 'EMERGENCY')
                {
                    TZ= '24X7';
                    if(entitlementMap.containsKey(TZ))
                        c.EntitlementId = entitlementMap.get(TZ).Id;
                     
                }
                else
                {
                    c.EntitlementId = entitlementMap.get(TZ).Id;                       
                }
                   System.debug('---TZ---'+TZ);         
                if(c.Priority == 'EMERGENCY')
                    c.Time_Remaining__c = clientInfoMap.get(c.AccountId).EMERGENCY_Permanent_Fix_SLA__c;
                
                if(c.Priority == 'MEDIUM')
                    c.Time_Remaining__c = clientInfoMap.get(c.AccountId).MEDIUM_Permanent_Fix_SLA__c;
                    
                if(c.Priority == 'HIGH')
                    c.Time_Remaining__c = clientInfoMap.get(c.AccountId).HIGH_Permanent_Fix_SLA__c;
                
                if(c.Priority == 'LOW')
                    c.Time_Remaining__c = clientInfoMap.get(c.AccountId).LOW_Permanent_Fix_SLA__c;     
                    
                if(c.Time_Remaining__c == null)
                    c.Time_Remaining__c = 600;                    
            
            }
        }

    }
    
    public static void updateCaseSLA(List<Case> caseList)
    {
        List<Id> caseIdLst = new List<Id>();
        Map<Id,CaseMilestone> cmMap= new Map<Id,CaseMilestone>();
        
        for(CaseMilestone cm: [Select CaseId,TimeRemainingInMins from CaseMilestone where CaseId in: caseList and CompletionDate=null])
        {
            cmMap.put(cm.CaseId, cm);    
        }
        System.debug('---cmMap---'+cmMap);
        If(!cmMap.isEmpty())
        {
            for(Case c : caseList)
            {             
                integer timeRemaining = 0;            
                if(c.IsStopped && (c.Status == 'New' || c.Status == 'SA Research in Progress' || c.Status == 'With Hosting Services' || 
                c.Status == 'With Tech Services' || c.Status == 'With Engineering' || c.Status == 'With Product Management' || c.Status == 'With Professional Services' ))
                    c.IsStopped = False;
                
                if(!c.IsStopped && (c.Status == 'Awaiting Client Response' || c.Status == 'Patch Delivered to Client' || c.Status == 'Fixed Pending Client Confirmation' || c.Status == 'On Hold' || 
                c.Status == 'Client Monitoring' || c.Status == 'Watch' || c.Status == 'Pending Future Release' || c.Status == 'Enhancement Request Logged' ))
                    c.IsStopped= True;
               // System.debug('---integer.valueOf(cmMap.get(c.Id).TimeRemainingInMins)---'+integer.valueOf(cmMap.get(c.Id).TimeRemainingInMins)); 
                    
                if(integer.valueOf(cmMap.get(c.Id).TimeRemainingInMins.substringBefore(':')) != null)   
                    timeRemaining = integer.valueOf(cmMap.get(c.Id).TimeRemainingInMins.substringBefore(':'));       
                if(!c.IsStopped)
                    c.Time_Remaining__c  =  timeRemaining ;                           
            }
            List<CaseMilestone> updateCasemilestoneLst = new List<CaseMilestone>();
            for(CaseMilestone cm: [Select TimeSinceTargetInMins, TimeRemainingInMins, TargetResponseInMins, TargetDate, StartDate, MilestoneTypeId, MilestoneType.Name, Case.Status, IsViolated, IsCompleted, Id, ElapsedTimeInMins, CompletionDate, CaseId, BusinessHoursId From CaseMilestone where CaseId in: caseList and CompletionDate= null order by createddate desc])
            {
                if(cm.Case.Status != cm.MilestoneType.Name)
                {            
                    cm.CompletionDate = datetime.now( );
                    updateCasemilestoneLst.add(cm);            
                }
            
            }
            if(updateCasemilestoneLst.size() > 0)
                update updateCasemilestoneLst;
                
                System.debug('---updateCasemilestoneLst---'+updateCasemilestoneLst);
                
                Map<Id,CaseMilestone> caseMap = new Map<Id,CaseMilestone>();
                
             List<CaseMilestone> reportLst = [Select CaseId, MilestoneTypeId, MilestoneType.Name, ElapsedTimeInMins from CaseMilestone where Id in:updateCasemilestoneLst];    
             
             for(Case c : caseList)
             {
                 for(CaseMilestone rep: reportLst)
                {
                    if(rep.CaseId == c.Id)
                    {
                        
                        if(rep.MilestoneType.Name == 'Awaiting Client Response')
                            c.Awaiting_Client_Response__c = rep.ElapsedTimeInMins;
                        if(rep.MilestoneType.Name == 'Client Monitoring')
                            c.Client_Monitoring__c= rep.ElapsedTimeInMins;                        
                        if(rep.MilestoneType.Name == 'Fixed Pending Client Confirmation')
                            c.Fixed_Pending_Client_Confirmation__c = rep.ElapsedTimeInMins;                        
                        if(rep.MilestoneType.Name == 'On Hold')
                            c.On_Hold__c = rep.ElapsedTimeInMins;                        
                        if(rep.MilestoneType.Name == 'Patch Delivered to Client')
                            c.Patch_Delivered_to_Client__c = rep.ElapsedTimeInMins;                        
                        if(rep.MilestoneType.Name == 'SA Research In Progress')
                            c.SA_Research_In_Progress__c = rep.ElapsedTimeInMins;                        
                        if(rep.MilestoneType.Name == 'With Engineering')
                            c.With_Engineering__c = rep.ElapsedTimeInMins;                        
                        if(rep.MilestoneType.Name == 'With Hosting Services')
                            c.With_Hosting_Services__c = rep.ElapsedTimeInMins;    
                    }                   
                }             
            }
        }                        
    } 
    
  /*  public static void updatePartnerContact(List<Case> caseList)
    {
        system.debug('$$$$$$caseList$$$$$$$'+caseList);
        system.debug('$$$$$$UserInfo.getUserId()$$$$$$$'+UserInfo.getUserId());
        system.debug('$$$$$$UserInfo.getProfileId()$$$$$$$'+UserInfo.getProfileId());
        
        
        List<User> lstUser = [Select Id,ContactId from User where Id =: UserInfo.getUserId() limit 1];
        Id cId = lstUser[0].ContactId ;
        
        for(Case c: caseList)
        {
            c.Partner_Contact_Name__c = cId  ;
        }
    
    }   */                
}