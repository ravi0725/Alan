global class BatchUpdateAccountsLastActivityOwnerAH implements Database.Batchable<sobject> {
    global string query;
    global Map<Id, Account> accsMap;
    global Map<Id, String> usersMap;
    global Map<Id, List<ActivityHistory>> eventsMap;
    global Map<id, List<ActivityHistory>> tasksMap;
    global Map<Id, String> failedAccountsMap;
    global Map<Id, List<ActivityHistory>> ahMap;
    
    global BatchUpdateAccountsLastActivityOwnerAH(){
        query = '';
    }
    
    global Database.Querylocator start (Database.BatchableContext BC) {
        query = 'select Id, Name, Last_Activity_Owner__c, (select Id, WhatId, AccountId, ActivityDate, Status, OwnerId, isTask from ActivityHistories where ActivityDate <> null order by ActivityDate DESC) from Account where Account_Division__c Includes (\'MEP\') AND (Last_Activity_Owner__c = null OR Last_Activity_Owner__c = \'\')';
        //query = 'select Id, Name, Last_Activity_Owner__c, (select Id, WhatId, AccountId, ActivityDate, Status, OwnerId, isTask from ActivityHistories where ActivityDate <> null order by ActivityDate DESC) from Account where Id IN (\'001i000000pCJgaAAG\',\'001i000000pEIEpAAO\',\'001i000000pEICKAA4\')';
        return Database.getQueryLocator(query);
    }
    
    global void execute (Database.BatchableContext BC, List<Account> scope) {
        accsMap = new Map<Id, Account>();
        ahMap = new Map<Id, List<ActivityHistory>>();
        for(Account acc: scope){
            accsMap.put(acc.Id, acc);
            ahMap.put(acc.Id, new List<ActivityHistory>());
            if(acc.ActivityHistories.size() > 0){
                system.debug('--accId--'+acc.Id+'--'+acc.ActivityHistories);
                for(ActivityHistory ah: acc.ActivityHistories){
                    ahMap.get(acc.Id).add(ah);
                }
            }
            //ahMap.get(acc.Id).addAll(acc.ActivityHistories);
        }
        system.debug('--ahMap--1-'+ahMap);
        system.debug('--accsMap--'+accsMap);
        if(ahMap.size() > 0){
            usersMap = new Map<Id, String>();
            eventsMap = new Map<Id, List<ActivityHistory>>();
            tasksMap = new Map<id, List<ActivityHistory>>();
            
            if(ahMap.size() > 0){
                for(Id acId: ahMap.keySet()){
                    for(ActivityHistory ah: ahMap.get(acId)){
                        if(ah.isTask != true){
                            system.debug('--Event--'+ah);
                            if(ah.AccountId != null || String.isNotBlank(String.valueOf(ah.AccountId))){
                                if(!eventsMap.containsKey(ah.AccountId)){
                                    eventsMap.put(ah.AccountId, new List<ActivityHistory>());
                                }
                                eventsMap.get(ah.AccountId).add(ah);
                            }
                            usersMap.put(ah.OwnerId, '');
                        }
                        
                        if(ah.isTask == true){
                            system.debug('--Task--'+ah);
                            if(ah.Status == 'Completed'){
                                if(ah.AccountId != null || String.isNotBlank(String.valueOf(ah.AccountId))){
                                    if(!tasksMap.containsKey(ah.AccountId)){
                                        tasksMap.put(ah.AccountId, new List<ActivityHistory>());
                                    }
                                    tasksMap.get(ah.AccountId).add(ah);
                                }
                            }
                            usersMap.put(ah.OwnerId, '');
                        }
                    }
                }
            }
            
            if(usersMap.size() > 0){
                for(User usr: [select Id, Name, FirstName, LastName from User where Id IN: usersMap.keySet()]){
                    usersMap.put(usr.Id, usr.Name);
                }
            }
            
            List<Account> accountsList = new List<Account>();
            for(Id acId: ahMap.keySet()){
                system.debug('----accId----'+acId+'--eventMap--'+eventsMap.containsKey(acId)+'---taskMap---'+tasksMap.containsKey(acId));
                if(accsMap.containsKey(acId)){
                    if(eventsMap.size() > 0 && tasksMap.size() > 0){
                        if(eventsMap.containsKey(acId) && tasksMap.containsKey(acId)){
                            if(eventsMap.get(acId)[0].ActivityDate > tasksMap.get(acId)[0].ActivityDate){
                                accsMap.get(acId).Last_Activity_Owner__c = usersMap.get(eventsMap.get(acId)[0].OwnerId);
                                accountsList.add(accsMap.get(acId));
                            }
                            
                            if((eventsMap.get(acId)[0].ActivityDate == tasksMap.get(acId)[0].ActivityDate) || (eventsMap.get(acId)[0].ActivityDate < tasksMap.get(acId)[0].ActivityDate)){
                                accsMap.get(acId).Last_Activity_Owner__c = usersMap.get(tasksMap.get(acId)[0].OwnerId);
                                accountsList.add(accsMap.get(acId));
                            }
                        }
                    }
                    
                    if(eventsMap.containsKey(acId)){
                        if(eventsMap.get(acId).isEmpty() && tasksMap.containsKey(acId)){
                            accsMap.get(acId).Last_Activity_Owner__c = usersMap.get(tasksMap.get(acId)[0].OwnerId);
                            accountsList.add(accsMap.get(acId));
                        }
                    }
                    
                    if(tasksMap.containsKey(acId)){
                        if(eventsMap.containsKey(acId) && tasksMap.get(acId).isEmpty()){
                            accsMap.get(acId).Last_Activity_Owner__c = usersMap.get(eventsMap.get(acId)[0].OwnerId);
                            accountsList.add(accsMap.get(acId));
                        }
                    }
                        
                    if(eventsMap.size() > 0 && tasksMap.size() == 0){
                        if(eventsMap.containsKey(acId)){
                            accsMap.get(acId).Last_Activity_Owner__c = usersMap.get(eventsMap.get(acId)[0].OwnerId);
                            accountsList.add(accsMap.get(acId));
                        }
                    }
                    
                    if(tasksMap.size() > 0 && eventsMap.size() == 0){
                        if(tasksMap.containsKey(acId)){
                            accsMap.get(acId).Last_Activity_Owner__c = usersMap.get(tasksMap.get(acId)[0].OwnerId);
                            accountsList.add(accsMap.get(acId));
                        }
                    }
                }
            }
            
            if(accountsList.size() > 0){
                //accountsList = accsMap.values();
                Database.SaveResult[] accsUpdateResults = Database.update(accountsList, false);
                //update accsMap.values();
                for(Integer i=0;i<accsUpdateResults.size();i++){
                    if (accsUpdateResults.get(i).isSuccess()){
                        accsUpdateResults.get(i).getId();
                    }else if (!accsUpdateResults.get(i).isSuccess()){
                        // DML operation failed
                        String errMsg = '';
                        for(Database.Error err : accsUpdateResults.get(i).getErrors()) {
                            errMsg = errMsg+err.getMessage() + '\nError Fields:' + err.getFields()+'\n';
                        }
                        failedAccountsMap = new Map<Id, String>();
                        failedAccountsMap.put(accountsList.get(i).Id, 'Account Id:' + accountsList.get(i).Id + ' => ' +errMsg);
                        system.debug('--failedAccountsMap--'+failedAccountsMap);
                    }
                }
            }
            
        }
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}