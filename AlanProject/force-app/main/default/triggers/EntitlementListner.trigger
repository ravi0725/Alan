trigger EntitlementListner on Entitlement (before insert, before update, after insert, after update) {
    if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
        EntitlementHandler.PopulateEntitlementProcess(trigger.new);
    }
    
    //Update MEPNA Renewal Opportunity stage to "6 - Closed Won" when Entitlement is renewed
    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
        EntitlementHandler.UpdateOpportunityStage(trigger.new);
    }
}