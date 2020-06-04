global class BatchUpdateConRoleforInactiveEntitlePrd implements Database.Batchable<sObject>,Schedulable {
    public String query;
    global void execute(SchedulableContext SC) {
        String str = 'select Id,Active_Product_List__c from Account where Account_Division__c includes (\'GCCM\',\'Owners\')';
        BatchUpdateConRoleforInactiveEntitlePrd temp = new BatchUpdateConRoleforInactiveEntitlePrd();
        temp.query = str;
        Database.executeBatch(temp,200);
    }
    
    global BatchUpdateConRoleforInactiveEntitlePrd(){
        //Get all GCCM and Owners Accounts and related Contacts and Active Entitlements
    }
    
    // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('----------query------' + query);
        return Database.getQueryLocator(query);
    }
    
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<Account>scope){  
        //Account and Contact list which needs to be updated
        List<Account> updateAccList = new List<Account>();
        //List<Contact> updateConList = new List<Contact>();
        //Map<Id,List<Contact>> conMap = new Map<Id,List<Contact>>();
        Map<Id,List<Entitlement>> etlMap = new Map<Id,List<Entitlement>>();
        set<Id> contactIds = new set<Id>();
        /*for(Contact con : [select Id,AccountId,Role_on_Account__c,Active_Contact_Flag__c from Contact where AccountId in : scope and Role_on_Account__c != null]){
            if(!conMap.containsKey(con.AccountId))conMap.put(con.AccountId, new List<Contact>());
            conMap.get(con.AccountId).add(con);
        }*/
        
        for(Entitlement etl : [select ID,Name,AccountId,Enddate,Entitlement_Product__r.Family,Product_Product_Type__c from Entitlement where AccountId in : scope and (enddate >= today OR Contract_End_Date__c >= today)]){
            if(!etlMap.containsKey(etl.AccountId))
            etlMap.put(etl.AccountId, new List<Entitlement>());
            
            etlMap.get(etl.AccountId).add(etl);
        }
        
        
        //Active Product list for Accounts
        Map<Id,set<String>> accIdPrdMap = new Map<Id,set<String>>();
        set<String> tempSet;
        for(Account acc : scope){
            system.debug('----------acc------' + acc);
            if(etlMap.containsKey(acc.Id)){
                for(Entitlement ent : etlMap.get(acc.Id)){
                    if(ent.Product_Product_Type__c != '' && ent.Product_Product_Type__c != null){
                        if(accIdPrdMap.get(ent.AccountId) == null){
                            accIdPrdMap.put(ent.AccountId,new set<String>());
                        }
                        tempSet = accIdPrdMap.get(ent.AccountId);
 
                        if((ent.Entitlement_Product__r.Family != null ? ent.Entitlement_Product__r.Family.contains('PROLOG SKY') : false) || (ent.Name.contains('GCManager SKY Suite - SaaS')))
                        tempSet.add('Prolog Sky');
                      
                        else tempSet.add(ent.Product_Product_Type__c);
                        accIdPrdMap.put(ent.AccountId,tempSet); 
                    }
                }
            }
            if(accIdPrdMap.containsKey(acc.Id) /*&& conMap.containsKey(acc.Id)*/){
                acc.Active_Product_List__c = '';
                for(String str : accIdPrdMap.get(acc.Id)){
                    /*for(Contact con : conMap.get(acc.Id)){
                        boolean flag = false;
                        for(String role : con.Role_on_Account__c.split(';')){
                            if((role.contains(str) && str != 'Prolog') || (str == 'Prolog' && role.equals('Prolog - Technical Notification'))){
                                flag = true;
                                break;
                            }
                        }
                        
                        if(flag && !con.Active_Contact_Flag__c){
                            con.Active_Contact_Flag__c = true;
                            updateConList.add(con);
                            contactIds.add(con.Id);
                        }
                    }*/
                    if(acc.Active_Product_List__c == '' || acc.Active_Product_List__c == null){
                        acc.Active_Product_List__c = str;
                    }else{
                        acc.Active_Product_List__c = acc.Active_Product_List__c + ';' + str;
                    }
                }
                
                /*for(Contact con : conMap.get(acc.Id) ){
                    if(!contactIds.contains(con.Id)){
                        con.Active_Contact_Flag__c = false;
                        updateConList.add(con);
                    }
                }*/
                
                if(acc.Active_Product_List__c != ''){
                    updateAccList.add(acc);
                }
            }else{
                /*if(conMap.containsKey(acc.Id)){
                    for(Contact con : conMap.get(acc.Id) ){
                        if(con.Active_Contact_Flag__c){
                            con.Active_Contact_Flag__c = false;
                            updateConList.add(con);
                        }
                    }  
                }*/
                if(acc.Active_Product_List__c != '' && acc.Active_Product_List__c != null){
                    acc.Active_Product_List__c = '';
                    updateAccList.add(acc);
                }
            }
            

        }
        //system.debug('----------updateConList-----------' + updateConList);
        List<WS_Interface_Log__c> logList = new List<WS_Interface_Log__c>();
        /*if(updateConList.size() > 0){
            ContactHandler.setLaunchControl();
            Integer cnt = 0;
            for(Database.upsertResult result : Database.upsert(updateConList,false)){
                if(!result.isSuccess()){
                    String msg = '';
                    for (Database.Error er : result.getErrors()){
                        msg += 'Error (' +  er.getStatusCode() + '):' + er.getMessage();
                        msg += '\r\n';
                    }
                    logList.add(WS_Interface_Log.createLog('BatchUpdateConRoleforInactiveEntitlePrd','Contact Update','',
                                        msg, updateConList[cnt].Id));
                }
                cnt++;
            }
        }*/
        
        system.debug('---------updateAccList-----------' + updateAccList);
        if(updateAccList.size() > 0){
            AccountHelper.setLaunchControl();
            Integer cnt = 0;
            for(Database.upsertResult result : Database.upsert(updateAccList,false)){
                if(!result.isSuccess()){
                    String msg = '';
                    for (Database.Error er : result.getErrors()){
                        msg += 'Error (' +  er.getStatusCode() + '):' + er.getMessage();
                        msg += '\r\n';
                    }
                    logList.add(WS_Interface_Log.createLog('BatchUpdateConRoleforInactiveEntitlePrd','Account Update','',
                                        msg, updateAccList[cnt].Id));
                }
                cnt++;
            }
        }
        
        if(logList.size() > 0){
            insert logList;
        }
    }
    
    global void finish(Database.BatchableContext BC){
        // Logic to be Executed at finish
    }
}