public class TaskHandler {
    public static Map<Id, Contact> mapContacts {get;set;}
    public static void updateTaskMobileNumber(List<Task> newTasks){
        Set<Id> setCIDs = new Set<ID>();
        for(Task t : newTasks){
            if(t.WhoId != null && String.valueOf(t.WhoId).startsWith('003')){
                setCIDs.add(t.WhoId);
            }
        }
        if(setCIDs.size() > 0){
            mapContacts = new Map<Id, Contact>();
            mapContacts = new Map<Id, Contact>([SELECT Id, Name, MobilePhone FROM Contact WHERE Id IN: setCIDs]);
            
            for(Task t: newTasks){
                if(t.WhoId != null && String.valueOf(t.WhoId).startsWith('003')){
                    if(t.Mobile_Phone__c == null){
                        t.Mobile_Phone__c = mapContacts.get(t.WhoId).MobilePhone;
                    }
                }
            }
        }
    }
    
    //-----TT#88349---
    public static void updateRelatedToFields(List<Task> newTasks, Map<Id,Task> oldMap){        
        Map<String, set<Id>> objSetMap = new Map<String, set<Id>>();
        Map<Id, User> usrMap = new Map<Id, User>();
        for(Task t: newTasks){
            usrMap.put(t.OwnerId, new User());
        }
        
        usrMap = new Map<Id, User>([select Id, Name, Division__c from User where Id IN: usrMap.keySet()]);
        
        for(Task t: newTasks){
            if(usrMap.get(t.OwnerId).Division__c == 'MEP'){
                if(t.Status == 'Completed'){
                    if(t.WhatId != null){
                        String objName = t.WhatId.getSObjectType().getDescribe().getName();
                        if(!objSetMap.keySet().contains(objName)){
                            objSetMap.put(objName, new set<Id>());
                        }
                        objSetMap.get(objName).add(t.WhatId);
                    }
                }
            }
        }      
        
        if(objSetMap.size() > 0){
            Map<String, String> relatedTosMap = new Map<String, String>();
            for(String obj: objSetMap.keySet()){
                set<Id> tempObjIdSet = new set<Id>();
                tempObjIdSet.addAll(objSetMap.get(obj));
                String tempQuery = '';
                if(obj.toLowerCase() != 'case'){
                    tempQuery = 'select Id, Name from '+obj+' where Id IN: tempObjIdSet';
                }else{
                    tempQuery = 'select Id, CaseNumber from '+obj+' where Id IN: tempObjIdSet';
                }
                List<sObject> objList = Database.query(tempQuery);
                Schema.SObjectType sObjectType = objList.getSObjectType();
                
                if(!objList.isEmpty()){
                    for(SObject s:objList){
                        system.debug('---sobject----'+s);
                        relatedTosMap.put(String.valueOf(s.get('Id')), (obj.toLowerCase() == 'case'?String.valueOf(s.get('CaseNumber')):String.valueOf(s.get('Name'))));
                        system.debug('---values---'+relatedTosMap);
                    }
                }
            }
            
            for(Task t: newTasks){
                if(!Test.isRunningTest()){
                    t.Related_To_Object__c =(!String.isNotBlank(t.Related_To_Object__c)?t.WhatId.getSObjectType().getDescribe().getName():t.Related_To_Object__c);
                    t.Related_To_Name__c = relatedTosMap.get(t.WhatId);
                }
            }
        }
    }
    
    public static void updateLastActivityOwnerOnAccount(List<Task> newTasks, Map<Id,Task> oldMap){
        
        Map<Id, Id> ownerAccMap = new Map<Id, Id>();
        Map<Id, List<Task>> accTasksMap = new Map<Id, List<Task>>();
        set<Id> taskIdSet = new set<Id>();
        
        for(Task t: newTasks){
            if(t.WhatId != null){
                if(t.Status == 'Completed' && string.valueOf(t.WhatId).substring(0,3) == '001'){
                    taskIdSet.add(t.Id);
                }
            }
        }
        
        if(taskIdSet.size() > 0){
            List<Task> taskList = [select Id, ActivityDate, WhatId, OwnerId from Task where Id IN: taskIdSet Order by ActivityDate DESC];
            for(Task tsk: taskList){
                if(!accTasksMap.containsKey(tsk.WhatId)){
                    accTasksMap.put(tsk.WhatId, new List<Task>());
                }
                accTasksMap.get(tsk.WhatId).add(tsk);
            }
            
            if(accTasksMap.keySet().size() > 0){
                set<Id> usrIdSet = new set<Id>();
                for(Id accId: accTasksMap.keySet()){
                    ownerAccMap.put(accId, accTasksMap.get(accId).get(0).OwnerId);
                    //usrIdSet.add(accTasksMap.get(accId).get(0).OwnerId);
                }
            
                Map<Id, User> usrMap = new Map<Id, User>([select Id, Name, Division__c from User where Id IN: ownerAccMap.values()]);
                
                List<Account> accUpdateList = new List<Account>();
                for(Account acc: [select Id, Last_Activity_Owner__c from Account where Id IN: ownerAccMap.keySet() AND Account_Division__c Includes ('MEP')]){
                    acc.Last_Activity_Owner__c = usrMap.get(ownerAccMap.get(acc.Id)).Name;
                    accUpdateList.add(acc);
                }
                
                if(!accUpdateList.isEmpty()){
                    update accUpdateList;
                }
            }
        }
    }
}