trigger ProductConfigurationListner on Apttus_Config2__ProductConfiguration__c (before insert, before update, after update) {
    // Update on Before Insert and Update
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        ProductConfigurationHandler.pConfigBefore(Trigger.new);
    }

    if(Trigger.isAfter && Trigger.isUpdate){
        ProductConfigurationHandler.pConfigAfterUpdate(Trigger.new);
    }
    
  /*   if(Trigger.IsAfter && Trigger.IsInsert)
    {
        ProductConfigurationHandler.pConfigAfterInsert(Trigger.new);
    }*/
}