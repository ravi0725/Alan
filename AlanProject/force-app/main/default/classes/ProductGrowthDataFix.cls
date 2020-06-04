Global class ProductGrowthDataFix Implements Database.batchable<sobject>{

  global final string query;
     global ProductGrowthDataFix(){
         
         if(test.isrunningTest())
          query='Select id,Record_ID__c from Batch_Data_Fix_Object__c LIMIT 1'; else query='Select id,Record_ID__c from Batch_Data_Fix_Object__c LIMIT 50000';
          
     }
   
      global Database.QueryLocator start(Database.BatchableContext BC){
      system.debug('********'+Database.getQueryLocator(query));
      return Database.getQueryLocator(query);
      
     }
     
       global  void execute(Database.BatchableContext BC,List<SObject> scope){
    
    
    list<Batch_Data_Fix_Object__c> batchList = new list<Batch_Data_Fix_Object__c>();
    batchList = scope;
    ID OppID = batchList.get(0).Record_ID__c;
    
    if(String.valueof(OppID).startswith('006')){
    Opportunity OppRec = new Opportunity(id=OppId);
    if(OppRec != Null)
    update OppRec;
    }
    }
       global void finish(Database.BatchableContext BC){
    }
    
}