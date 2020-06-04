trigger EventListner on Event(after insert, after update, after delete, after undelete, before insert, before update, before delete){
    CentralDispatcher.Dispatch(trigger.IsBefore, trigger.isAfter, trigger.IsInsert, trigger.IsUpdate, trigger.IsDelete , trigger.IsExecuting, trigger.new, trigger.newmap, trigger.old, trigger.oldmap);

    // Added by: Suresh Babu Murugan
    // Desc: This method is used to update related Customer Event records for Non-CH Schedule Events
    if(Trigger.isAfter && Trigger.isUpdate){
        EventTriggerHandler.UpdateCustomerEvents(Trigger.new);
    }
    //////////
}