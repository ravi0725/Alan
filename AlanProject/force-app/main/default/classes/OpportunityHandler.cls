public class OpportunityHandler implements ITriggerEntry{
    public static boolean IsRecursiveCall = false;
    public void MainEntry(Boolean IsBefore, Boolean IsAfter, Boolean IsInsert, Boolean IsUpdate, Boolean IsDelete, Boolean IsExecuting, List<SObject> newlist, Map<ID, SObject> newmap, List<SObject> oldlist, Map<ID,SObject> oldmap){
        system.debug('----------OpportunityMainEntry-------------');
    }
    
    public void InProgressEntry(Boolean IsBefore, Boolean IsAfter, Boolean IsInsert, Boolean IsUpdate, Boolean IsDelete, Boolean IsExecuting, List<SObject> newlist, Map<ID, SObject> newmap, List<SObject> oldlist, Map<ID,SObject> oldmap){
        system.debug('----------OpportunityInProgressEntry-------------');
        if(IsDelete){
            OpportunityHelper.OpportunityBeforeDeleteHandler(oldlist);
        }
        
        IsRecursiveCall = true;
    }
}