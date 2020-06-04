public class EventHandler implements ITriggerEntry{
    public static boolean IsRecursiveCall = false;
    public void MainEntry(Boolean IsBefore, Boolean IsAfter, Boolean IsInsert, Boolean IsUpdate, Boolean IsDelete, Boolean IsExecuting, List<SObject> newlist, Map<ID, SObject> newmap, List<SObject> oldlist, Map<ID,SObject> oldmap){
        system.debug(IsBefore + '----------EventMainEntry-------------' + IsUpdate);
        if(IsAfter){
            if(IsInsert || IsUpdate){
                EventHelper.updateLastActivityOwnerOnAccount(newlist);
            }
        }
    }
    
    public void InProgressEntry(Boolean IsBefore, Boolean IsAfter, Boolean IsInsert, Boolean IsUpdate, Boolean IsDelete, Boolean IsExecuting, List<SObject> newlist, Map<ID, SObject> newmap, List<SObject> oldlist, Map<ID,SObject> oldmap){
        system.debug('----------EventInProgressEntry-------------');
        IsRecursiveCall = true;
        if(IsBefore){
            String Event = '';
            if(IsInsert){
                event = 'insert';
                EventHelper.EventBeforeInsertHandler(newlist);
                EventHelper.updateDescription(newlist,oldmap, event);
            }
            
            if(IsUpdate){
                event = 'update';
                EventHelper.EventBeforeUpdateHandler(newlist);
                EventHelper.updateDescription(newlist,oldmap, event);
            }
        }
    }
}