global class BatchUpdateAccountActivityOwnerToBlank implements Database.Batchable<sobject>{
    global string query = '';
    global List<Account> accList;
    
    global BatchUpdateAccountActivityOwnerToBlank(){
        accList = new List<Account>();
    }
    
    global Database.Querylocator start (Database.BatchableContext BC) {
        query = 'select Id, Name, Last_Activity_Owner__c from Account where Account_Division__c Includes (\'MEP\') AND (Last_Activity_Owner__c <> null OR Last_Activity_Owner__c <> \'\')';
        return Database.getQueryLocator(query);
    }
    
    global void execute (Database.BatchableContext BC, List<Account> accnts) {
        for(Account acc: accnts){
            acc.Last_Activity_Owner__c = '';
            accList.add(acc);
        }
        
        if(accList.size() > 0){
            Database.SaveResult[] accsUpdateResults = Database.update(accList, false);
            for(Integer i=0;i<accsUpdateResults.size();i++){
                if (accsUpdateResults.get(i).isSuccess()){
                    accsUpdateResults.get(i).getId();
                }else if (!accsUpdateResults.get(i).isSuccess()){
                    // DML operation failed
                    String errMsg = '';
                    for(Database.Error err : accsUpdateResults.get(i).getErrors()) {
                        errMsg = errMsg+err.getMessage() + '\nError Fields:' + err.getFields()+'\n';
                        system.debug('--Errors--'+'Account Id:' + accList.get(i).Id + ' => ' +errMsg);
                    }
                }
            }
        }
        
    }
    
    
    global void finish(Database.BatchableContext BC){
        
    }
}