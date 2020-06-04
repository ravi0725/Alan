trigger PopulateProductOptions on Apttus_Config2__ProductOptionComponent__c (after insert, after update) {
    List<Apttus_Config2__ProductOptionComponent__c> MapList = new List<Apttus_Config2__ProductOptionComponent__c>();
    Set<Id> productIdSet = new Set<Id>();
    Map<Id,Decimal> Quantity = new Map<ID,Decimal>();
      
    for(Apttus_Config2__ProductOptionComponent__c option : Trigger.new){
        productIdSet.add(option.Apttus_Config2__ParentProductId__c);
        
    }
     Maplist=[Select id,Apttus_Config2__DefaultQuantity__c,Apttus_Config2__ComponentProductId__c from Apttus_Config2__ProductOptionComponent__c where Apttus_Config2__ParentProductId__c in:productIdSet];
     for(Apttus_Config2__ProductOptionComponent__c option : Maplist){
     Quantity.put(option.Apttus_Config2__ComponentProductId__c,option.Apttus_Config2__DefaultQuantity__c);
     }
    try{    
       ProcessProductOptionComponent.processProductOptionComponent(productIdSet, true,Quantity);
    }catch(Exception e){
        
    }   
          
}