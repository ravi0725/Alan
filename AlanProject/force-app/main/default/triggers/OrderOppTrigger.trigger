trigger OrderOppTrigger on Order__c (before insert, before update, after insert, after update) {
    if(Trigger.isBefore) {
        Trigger_A__mdt[] tm = [select Opp_Order_Trigger_Activation__c from Trigger_A__mdt where Opp_Order_Trigger_Activation__c = TRUE  limit 1];
        for (Trigger_A__mdt tml: tm){
            if(tml.Opp_Order_Trigger_Activation__c){
                if((Trigger.isUpdate && Trigger.isBefore) || (Trigger.isInsert && Trigger.isBefore)){
                    OppOrderHelper.OppOrder(Trigger.New);
                }
            }
        }
    }
    
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        system.debug('====Trigger.New====' + Trigger.New);
        system.debug('====Trigger.oldMap====' + Trigger.oldMap);
    	OrderHelper.validateMEPNAEstimatingBusinessArea(Trigger.isInsert, Trigger.isUpdate, Trigger.New, Trigger.oldMap, Trigger.newMap);
    }
}