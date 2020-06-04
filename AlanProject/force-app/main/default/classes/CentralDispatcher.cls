public class CentralDispatcher {
    public static ITriggerEntry triggerEntry = null;
    public static void Dispatch(Boolean IsBefore, Boolean IsAfter, Boolean IsInsert, Boolean IsUpdate, Boolean IsDelete, Boolean IsExecuting, List<SObject> newlist, Map<ID, SObject> newmap, List<SObject> oldlist, Map<ID,SObject> oldmap){
        if((newList != null ? newlist.get(0) : oldList.get(0)) instanceof Event){
            system.debug(IsBefore + '------Event-------' + IsUpdate);
            triggerEntry = new EventHandler();
            if(EventHandler.IsRecursiveCall){
                triggerEntry.MainEntry(IsBefore, IsAfter, IsInsert, IsUpdate, IsDelete, IsExecuting,  newlist, newmap, oldlist, oldmap);
            }else{
                triggerEntry.InProgressEntry(IsBefore, IsAfter, IsInsert, IsUpdate, IsDelete, IsExecuting,  newlist, newmap, oldlist, oldmap);
            }
        }else if((newList != null ? newlist.get(0) : oldList.get(0)) instanceof Opportunity){
            system.debug('------Opportunity-------');
            triggerEntry = new OpportunityHandler();
            if(OpportunityHandler.IsRecursiveCall){
                triggerEntry.MainEntry(IsBefore, IsAfter, IsInsert, IsUpdate, IsDelete, IsExecuting,  newlist, newmap, oldlist, oldmap);
            }else{
                triggerEntry.InProgressEntry(IsBefore, IsAfter, IsInsert, IsUpdate, IsDelete, IsExecuting,  newlist, newmap, oldlist, oldmap);
            }
        }
        
        system.debug('------end-------' );
    }    
}