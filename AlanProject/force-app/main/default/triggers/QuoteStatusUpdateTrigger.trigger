trigger QuoteStatusUpdateTrigger on Apttus_Config2__ProductConfiguration__c (after update) {
    
    Set<Id> quoteIdSet = new Set<Id>();
    List<Apttus_Proposal__Proposal__c> quoteList = new List<Apttus_Proposal__Proposal__c>();
    Map<Id, Apttus_Proposal__Proposal__c> quoteMap = new Map<Id, Apttus_Proposal__Proposal__c>();
    boolean flag = false;
   
    for(Apttus_Config2__ProductConfiguration__c config : trigger.new){
        quoteIdSet.add(config.Apttus_QPConfig__Proposald__c);   
        
    }
    
    

    set<Id> uniqueIds = new set<Id>();
    quoteMap = new Map<Id, Apttus_Proposal__Proposal__c>([Select Id, Apttus_Proposal__Approval_Stage__c,Product_Conf_Status__c from Apttus_Proposal__Proposal__c where Id IN: quoteIdSet]);
    if(quoteMap.size() > 0){
        for(Apttus_Config2__ProductConfiguration__c config : trigger.new){
          if(quoteMap.containsKey(config.Apttus_QPConfig__Proposald__c) && !uniqueIds.contains(config.Apttus_QPConfig__Proposald__c)){
                
                quoteMap.get(config.Apttus_QPConfig__Proposald__c).Product_Conf_Status__c =config.Apttus_Config2__Status__c ;
                uniqueIds.add(config.Apttus_QPConfig__Proposald__c);
                quoteList.add(quoteMap.get(config.Apttus_QPConfig__Proposald__c));                
            }  
        }
                        
        if(quoteList.size() > 0){
            update quoteList;
        }
    }     
}