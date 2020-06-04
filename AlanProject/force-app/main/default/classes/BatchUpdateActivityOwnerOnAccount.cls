global class BatchUpdateActivityOwnerOnAccount implements Database.Batchable<sobject> {
    global string query;
    global Map<Id, Account> accsMap;
    global Map<Id, String> usersMap;
    global Map<Id, List<Event>> eventsMap;
    global Map<id, List<Task>> tasksMap;
    global Map<Id, String> failedAccountsMap;
    
    global BatchUpdateActivityOwnerOnAccount(){
        query = '';
    }
    
    global Database.Querylocator start (Database.BatchableContext BC) {
        query = 'select Id, Name, Last_Activity_Owner__c from Account where Account_Division__c Includes (\'MEP\') AND (Last_Activity_Owner__c = null OR Last_Activity_Owner__c = \'\')';
        return Database.getQueryLocator(query);
    }
    
    global void execute (Database.BatchableContext BC, List<Account> scope) {
        accsMap = new Map<Id, Account>();
        for(Account acc: scope){
            accsMap.put(acc.Id, acc);
        }
        
        if(accsMap.size() > 0){
            usersMap = new Map<Id, String>();
            eventsMap = new Map<Id, List<Event>>();
            tasksMap = new Map<id, List<Task>>();
            
            for(Event ev: [select Id, ActivityDate, WhatId, OwnerId from Event where WhatId IN: accsMap.keySet() AND ActivityDate <> null order by ActivityDate DESC]){
                if(!eventsMap.containsKey(ev.WhatId)){
                    eventsMap.put(ev.WhatId, new List<Event>());
                }
                eventsMap.get(ev.WhatId).add(ev);
                usersMap.put(ev.OwnerId, '');
            }
            
            for(Task tsk: [select Id, ActivityDate, WhatId, Status, OwnerId from Task where WhatId IN: accsMap.keySet() AND ActivityDate <> null AND Status = 'Completed' order by ActivityDate DESC]){
                if(!tasksMap.containsKey(tsk.WhatId)){
                    tasksMap.put(tsk.WhatId, new List<Task>());
                }
                tasksMap.get(tsk.WhatId).add(tsk);
                usersMap.put(tsk.OwnerId, '');
            }
            
            if(usersMap.size() > 0){
                for(User usr: [select Id, Name, FirstName, LastName from User where Id IN: usersMap.keySet()]){
                    usersMap.put(usr.Id, usr.Name);
                }
            }
            
            List<Account> accountsList = new List<Account>();
            for(Id acId: accsMap.keySet()){
                system.debug('----accId----'+acId+'--eventMap--'+eventsMap.containsKey(acId)+'---taskMap---'+tasksMap.containsKey(acId));
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
                    }else if(eventsMap.containsKey(acId) && tasksMap.get(acId) == null){
                        accsMap.get(acId).Last_Activity_Owner__c = usersMap.get(eventsMap.get(acId)[0].OwnerId);
                        accountsList.add(accsMap.get(acId));
                    }else if(eventsMap.get(acId) == null && tasksMap.containsKey(acId)){
                        accsMap.get(acId).Last_Activity_Owner__c = usersMap.get(tasksMap.get(acId)[0].OwnerId);
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