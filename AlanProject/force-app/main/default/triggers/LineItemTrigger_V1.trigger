/*****************************************************************************************
  Name    : LineItemTrigger_V1 
  Desc    : LineItem Global Trigger
  Modification Log : 
  ---------------------------------------------------------------------------
  Developer                 Date            Description
  ---------------------------------------------------------------------------
  Suresh Babu Murugan       25/Mar/2019     Created
 ******************************************************************************************/
trigger LineItemTrigger_V1 on Apttus_Config2__LineItem__c(before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerDispatcher.run(new LineItemTriggerHandler());
}