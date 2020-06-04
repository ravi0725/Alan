trigger ProductConfigurationQuoteTrigger on Apttus_Config2__ProductConfiguration__c (after update) {
    
    Set<Id> quoteIdSet = new Set<Id>();
    List<Apttus_Proposal__Proposal__c> quoteList = new List<Apttus_Proposal__Proposal__c>();
      
    Apttus_Proposal__Proposal__c prop = new Apttus_Proposal__Proposal__c();
    set<Id> uniqueIds = new set<Id>();
    for(Apttus_Config2__ProductConfiguration__c config : trigger.new){
        prop = new Apttus_Proposal__Proposal__c();
        prop.Id = config.Apttus_QPConfig__Proposald__c;
        if(config.Apttus_QPConfig__Proposald__c != null && !uniqueIds.contains(prop.Id)){
            if(config.Apttus_CQApprov__Approval_Status__c == 'Pending Approval'){
                prop.Apttus_Proposal__Approval_Stage__c = 'In Review';           
            }
            if(config.Apttus_CQApprov__Approval_Status__c == 'Approved'){
                prop.Apttus_Proposal__Approval_Stage__c = 'Approved';                
            }
            if(config.Apttus_CQApprov__Approval_Status__c == 'Cancelled'){
                prop.Apttus_Proposal__Approval_Stage__c = 'Cancelled';                
            }
            if(config.Apttus_CQApprov__Approval_Status__c == 'Rejected'){
                prop.Apttus_Proposal__Approval_Stage__c = 'Approval Rejected';                
            }
            uniqueIds.add(prop.Id);
            quoteList.add(prop); 
        }  
        
        if(quoteList.size() > 0){
            update quoteList;
        }
    }
}