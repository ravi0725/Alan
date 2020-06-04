global class scheduleBatchSync implements Schedulable{
    public List<Id> masterRecordIds;
    public Set<String> deletedAdd;
    public Set<String> deletedCon;
    public scheduleBatchSync(){
        masterRecordIds = new List<Id>();
        deletedAdd = new Set<String>();
        deletedCon = new Set<String>();
    }
    
    
    global void execute(SchedulableContext SC) {
        AccountCreationCalloutEX.callEBS(masterRecordIds,'Merge','Create','Create',deletedCon,deletedAdd,new Set<String>());
    } 
}