global class UtilitySchedulableClass Implements Schedulable{
     
    /* private static final List<Boolean> isWorkingDay;
     //count of the number of working days in the array
     private static final Integer workingDaysInWeek;
     static {
       //my real implementation uses the Salesforce BusinessHours Object to populate this array
       isWorkingDay = new List<Boolean> { true, true, true, true, true, false, false };
       //You will have real problems if this number does not match the number of true flags in the array
       workingDaysInWeek = 5;
     }*/
     
     global void execute(SchedulableContext SC){
          scheduleLeads();
     }
        
     public void scheduleLeads(){
        try{
           List<Lead> leadList = new List<Lead>();
           List<Lead> leadListToQueue = new List<Lead>();
           RecordType recordType = [SELECT Id FROM RecordType WHERE DeveloperName =: Label.Lead_Accept_Reject_Record_Type];
           Profile profile = [Select Id from Profile where Name =: Label.Partner_Portal_Profile_Name];
           leadList = [Select Id, 
                              Name, 
                              CreatedDate, 
                              LastModifiedDate, 
                              OwnerId, 
                              Lead_Assign_TimeStamp__c,  
                              Lead_Accept_TimeStamp__c  
                              from Lead where 
                              RecordTypeId =: recordType.Id and  
                              Owner.ProfileID =: profile.Id and isPartnerReject__c = false];
                               
           //leadList = [Select Id, Lead_Assign_TimeStamp__c, Lead_Accept_TimeStamp__c from Lead where Id ='00Qc00000036y70EAA'];
           Map<String, Id> recordTypeMap = RecursiveTriggerUtility.loadRecordTypeMap(Lead.SObjectType);
           List<Group> groupList = new List<Group>();
           groupList = [Select Id, DeveloperName from Group where DeveloperName =: Label.Lead_Partner_Reassign_Queue];
           DateTime dt = DateTime.newInstance(System.now().year(), System.now().month(), System.now().day(), System.now().hour(), 0, 0);                       
           for(Lead lead : leadList){                             
              if(dt == lead.Lead_Accept_TimeStamp__c){
                  lead.RecordTypeId =  recordTypeMap.get(Label.Lead_Customer_Record_Type);
                  if(groupList.size() > 0){
                     lead.OwnerId = groupList.get(0).Id;
                  }
                  leadListToQueue.add(lead);
              }               
           }               
           if(leadListToQueue.size() > 0){
               RecursiveTriggerUtility.isBatchExecute = false;
               update leadListToQueue;
           }
        }catch(Exception e){
            System.debug(e.getMessage());        
        }  
     }
}