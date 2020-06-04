/**
* Company     : Trimble Inc.,
* Description : Batch Class for updating and creating CustomerEvents with Event Contact
* History     :  

* [12.01.2018] Chandrakanth Malayathi  Created
*/
global class BatchCreateCustomerEventWithContact implements Database.Batchable<sobject> {
    global string query;
    
    global BatchCreateCustomerEventWithContact(){
        query = '';
    }
    
    global Database.Querylocator start (Database.BatchableContext BC) {
        query = 'select Id, Event_Id__c, Account__c, Account__r.Id, Contact_Names__c, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, Contact__c, Contact_Confirmation__c, Contact_Ids__c, Customer_Related_Contact__c, Event_Contact__c from Customer_Event__c where Event_Contact__c = null';
        return Database.getQueryLocator(query);
    }
    
    global void execute (Database.BatchableContext BC, List<Customer_Event__c> ceList) {
        Map<Id, set<String>> accCntsMap = new Map<Id, set<String>>();
        Map<Id, Map<String, Id>> contIdMap = new Map<Id, Map<String, Id>>();
    	Map<Id, Customer_Event__c> accCEMap = new Map<Id, Customer_Event__c>();
        
        for(Customer_Event__c ce: ceList){
            accCEMap.put(ce.Account__r.Id, ce);
            if(!accCntsMap.containsKey(ce.Account__r.Id)){
              accCntsMap.put(ce.Account__r.Id, new set<String>());
            }
            if(string.isNotBlank(ce.Contact_Names__c)){
              accCntsMap.get(ce.Account__r.Id).addAll(ce.Contact_Names__c.split('/'));
            }
        }
        
        List<Contact> contactsList = [select Id, Name, AccountId from Contact where AccountId IN: accCEMap.keySet()];
        
        for(Contact cnt: contactsList){
            if(!contIdMap.containsKey(cnt.AccountId)){
              contIdMap.put(cnt.AccountId, new Map<String,Id>());
            }
            if(!contIdMap.get(cnt.AccountId).containsKey(cnt.Name)){
              contIdMap.get(cnt.AccountId).put(cnt.Name, cnt.Id); 
            }
        }
    
        List<Customer_Event__c> insertCEList = new List<Customer_Event__c>();
    	List<Customer_Event__c> updateCEList = new List<Customer_Event__c>();
                
        for(Customer_Event__c ce: ceList){
            if(string.isNotBlank(ce.Contact_Names__c)){
                Integer count = 0;
                for(String cont: accCntsMap.get(ce.Account__r.Id)){      
                	string cntct = cont.trim();
                    if(contIdMap.get(ce.Account__r.Id).containsKey(cntct)){
                        if(count > 0){
                            Customer_Event__c cEvnt = new Customer_Event__c();
                            cEvnt.Account__c = ce.Account__r.Id;
                            cEvnt.Event_Id__c = ce.Event_Id__c;
                            cEvnt.Event_Contact__c = contIdMap.get(ce.Account__r.Id).get(cntct);
                            cEvnt.Contact_Names__c = ce.Contact_Names__c;
                            cEvnt.Contact_Confirmation__c = true;
                            insertCEList.add(cEvnt);
                        }else{
                            ce.Event_Contact__c = contIdMap.get(ce.Account__r.Id).get(cntct);
                            ce.Contact_Confirmation__c = true;
                            updateCEList.add(ce);
                        }
                        count++;
                    }
                }
            }
        }
        
        if(updateCEList.size() > 0)update updateCEList;
        if(insertCEList.size() > 0)insert insertCEList;
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}