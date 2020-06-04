trigger SalesRepManagerInsUpdate on Apttus_Config2__ProductConfiguration__c (before insert,before update) {

// create a set of all the quote ids
    /*Set<id> quoteIds= new Set<id>();
    for (Apttus_Config2__ProductConfiguration__c a : Trigger.new)
        quoteIds.add(a.Apttus_QPConfig__Proposald__c);   
    
     system.debug('quoteIds'+quoteIds);    
     Map<id, Apttus_Proposal__Proposal__c> owners = new Map<id, Apttus_Proposal__Proposal__c>([Select a.Sales_Manager_ID__c From Apttus_Proposal__Proposal__c a where Id in :quoteIds]);  
     
    // iterate over the list of records being processed in the trigger and
    if(owners.size()>0 ){      */
       for (Apttus_Config2__ProductConfiguration__c a : Trigger.new){  
         try{
           a.Sales_Rep_Manager__c = a.Sales_Manager_Id_Formula__c;
         }catch(Exception e){
           a.addError(e.getMessage());
         }  
       }                   
    //}
}