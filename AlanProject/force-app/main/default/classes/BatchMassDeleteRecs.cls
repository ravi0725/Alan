Global class BatchMassDeleteRecs Implements Database.batchable<sobject>{
     global final string query;
     global BatchMassDeleteRecs(string q){
         
          query=q;
     }
   
     global Database.QueryLocator start(Database.BatchableContext BC){
      system.debug('********'+Database.getQueryLocator(query));
      return Database.getQueryLocator(query);
      
     }
     global  void execute(Database.BatchableContext BC,List<SObject> scope){
         delete scope;
    
    }
    global void finish(Database.BatchableContext BC){
    }

 }