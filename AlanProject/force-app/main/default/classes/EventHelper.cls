public with sharing class EventHelper{
    public static void EventBeforeInsertHandler(List<SObject> newlist){
        updateContractNumber(newlist);
        updateCompanyName(newlist);  //-------------TT #100402------------
    }
    
    public static void EventBeforeUpdateHandler(List<SObject> newlist){
        updateContractNumber(newlist);
    }
   
    public static void updateDescription(List<SObject> newlist,Map<Id,sObject> oldMap, string trigEvent){
        set<Id> accIdSet = new set<Id>();
        set<Id> conIdSet = new set<Id>();
        set<Id> leadIdSet = new set<Id>();
        
        for(SObject temp : newlist){
            Event eventObj = (Event)temp;
            system.debug('--------------eventObj-----------' + eventObj);
            if(eventObj.Description == null) eventObj.Description = '';
            if(eventObj.WhatId != NULL){
                if(String.valueof(eventObj.WhatId).startswith('001')){
                    eventObj.Account__c = eventObj.WhatId; //-------TT #110490-----TT #110094-----------
                    accIdSet.add(eventObj.WhatId);    
                }
                
            }
            if(eventObj.WhoId != NULL){
                if(String.valueof(eventObj.WhoId).startswith('003')) conIdSet.add(eventObj.WhoId);
                if(String.valueof(eventObj.WhoId).startswith('00Q') && eventObj.RecordTypeName__c == 'Sales Event'){
                    leadIdSet.add(eventObj.WhoId);
                }
            }
            
            String descriptionStr = '';
            if(!accIdSet.isEmpty() || !conIdSet.isEmpty()){
                if(eventObj.Description != '' && eventObj.Description != null){
                    boolean flag = true;
                    for(String str : eventObj.Description.split('\n')){
                        if(str.Startswith('````````````Primary Account/Contact Info````````````')) flag = false;
                        if(flag) descriptionStr = descriptionStr + '\n' + str;
                        if(str.Startswith('````````````````````````````````````````````````````')) flag = true;
                    }
                }
            }
            
            if(!leadIdSet.isEmpty()){
                if(eventObj.Description != '' && eventObj.Description != null){
                    boolean flag = true;
                    for(String str : eventObj.Description.split('\n')){
                        if(str.Startswith('````````````Lead Info````````````')) flag = false;
                        if(flag) descriptionStr = descriptionStr + '\n' + str;
                        if(str.Startswith('````````````````````````````````````````````````````')) flag = true;
                    }
                }
            }
            
            if(eventObj.WhatId != NULL || eventObj.WhoId != NULL){
                if(String.isNotBlank(descriptionStr)){
                    eventObj.Description = descriptionStr;
                }
            }

        }
            
        system.debug(conIdSet + '---------------------------' + accIdSet + '-------------'+ leadIdSet);
        Map<Id,Account> accMap = new Map<Id,Account>();
        if(accIdSet.size() > 0){
            accMap = new Map<Id,Account>([select Id, Name, Enterprise_Party_Number__c, Phone, BillingCity,
                                          BillingStreet,BillingState,BillingCountry,BillingPostalCode from Account where Id in : accIdSet]);
        }
        
        Map<Id,Contact> conMap = new Map<Id,Contact>();
        if(conIdSet.size() > 0){
            conMap = new Map<Id,Contact>([select Id, Name, MobilePhone, Phone from Contact where Id in : conIdSet]);
        }
        
        
        Map<Id, Lead> leadMap = new Map<Id, Lead>();
        if(leadIdSet.size() > 0){
            leadMap = new Map<Id,Lead>([select Id, Name, Company, Phone, Email, Street, City, State, PostalCode, Country from Lead where Id in : leadIdSet]);
        }
        system.debug(conMap + '---------------------------' + accMap + '-----------------------' + leadMap);
        
        for(SObject temp : newlist){
            Event eventObj = (Event)temp;
            String descriptionStr = '';

            if(accMap.get(eventObj.WhatId) != null){
                String str = 'Account Name ~ ' + accMap.get(eventObj.WhatId).Name;    
                String address = '';
                system.debug('--------address ----------' + accMap.get(eventObj.WhatId).BillingStreet);
                address = (accMap.get(eventObj.WhatId).BillingStreet == null ? '' : accMap.get(eventObj.WhatId).BillingStreet);
                address = address + ', ' + (accMap.get(eventObj.WhatId).BillingPostalCode == null ? '' : accMap.get(eventObj.WhatId).BillingPostalCode) + 
                            ' '  + (accMap.get(eventObj.WhatId).BillingCity == null ? '' : accMap.get(eventObj.WhatId).BillingCity);
                address = address + ', ' + (accMap.get(eventObj.WhatId).BillingState == null ? '' : accMap.get(eventObj.WhatId).BillingState);
                
                address = address + ', ' + (accMap.get(eventObj.WhatId).BillingCountry == null ? '' : accMap.get(eventObj.WhatId).BillingCountry);
                if(address != ''){
                    if(trigEvent == 'update'){
                        Event Ev = (Event)oldMap.get(eventObj.Id);
                        system.debug('--oldMap--'+Ev.WhatId);
                        if(Ev.WhatId  != eventObj.WhatId){
                            eventObj.Service_Location__c = address;
                        }
                    }
                    
                    if(trigEvent == 'insert'){
                        eventObj.Service_Location__c = address;
                    }
                    //eventObj.Service_Location__c = address; //----TT #110547--removed Service Location != null check before adding address to service location---------
                    address = 'Address ~ ' + address;
                    if(str != ''){
                        str = str + '\n' + address;
                    }
                }
                if(accMap.get(eventObj.WhatId).Phone != '' && accMap.get(eventObj.WhatId).Phone != null){
                    if(str != ''){
                        str = str + '\n' + 'Phone ~ ' + accMap.get(eventObj.WhatId).Phone;
                    }
                }
                if(accMap.get(eventObj.WhatId).Enterprise_Party_Number__c != '' && accMap.get(eventObj.WhatId).Enterprise_Party_Number__c != null){
                    if(str != ''){
                        str = str + '\n' + 'Enterprise Master Id ~ ' + accMap.get(eventObj.WhatId).Enterprise_Party_Number__c;
                    }
                }
                
                descriptionStr = '\n\n````````````Primary Account/Contact Info`````````````\n' + descriptionStr + 'Primary Account Info\n' + str;
            }
            if(conMap.get(eventObj.WhoId) != null){
                String str = 'Contact Name ~ ' + conMap.get(eventObj.WhoId).Name;    
                
                if(conMap.get(eventObj.WhoId).Phone != '' && conMap.get(eventObj.WhoId).Phone != null){
                    str = str + '\nPhone ~ ' + conMap.get(eventObj.WhoId).Phone;
                }
                
                if(conMap.get(eventObj.WhoId).MobilePhone != '' && conMap.get(eventObj.WhoId).MobilePhone != null){
                    eventObj.Mobile_Phone__c = conMap.get(eventObj.WhoId).MobilePhone;
                    str = str + '\nMobile No. ~ ' + conMap.get(eventObj.WhoId).MobilePhone;
                }
                if(descriptionStr != ''){
                    descriptionStr = descriptionStr + '\n\nPrimary Contact Info\n' + str;
                }else{
                    descriptionStr = '\n\n````````````Primary Account/Contact Info`````````````\n' + '\nPrimary Contact Info\n' + str;
                }
            }
            
            //-------------TT #100407------------
            if(leadMap.get(eventObj.WhoId) != null){
                String str = 'Name ~ ' + leadMap.get(eventObj.WhoId).Name; 
                if(leadMap.get(eventObj.WhoId).Company != ''){
                    str = str + '\nCompany ~ ' + leadMap.get(eventObj.WhoId).Company;
                }
                String address = '';
                system.debug('--------address ----------' + leadMap.get(eventObj.WhoId).Street);
                address = (leadMap.get(eventObj.WhoId).Street == null ? '' : leadMap.get(eventObj.WhoId).Street);
                address = address + ', ' + ' '  + (leadMap.get(eventObj.WhoId).City == null ? '' : leadMap.get(eventObj.WhoId).City);
                address = address + ', ' + (leadMap.get(eventObj.WhoId).State == null ? '' : leadMap.get(eventObj.WhoId).State) + ' '+ (leadMap.get(eventObj.WhoId).PostalCode == null ? '' : leadMap.get(eventObj.WhoId).PostalCode);
                address = address + ', ' + (leadMap.get(eventObj.WhoId).Country == null ? '' : leadMap.get(eventObj.WhoId).Country);
                if(address != ''){
                    if((eventObj.Service_Location__c == null || eventObj.Service_Location__c == '') ){
                        if(trigEvent == 'update'){
                            Event Ev = (Event)oldMap.get(eventObj.Id);
                            system.debug('--oldMap--'+Ev.WhatId);
                            if(Ev.WhatId  != eventObj.WhatId){
                                eventObj.Service_Location__c = address;
                            }
                        }
                        
                        if(trigEvent == 'insert'){
                            eventObj.Service_Location__c = address;
                        }
                        //eventObj.Service_Location__c = address;
                    }
                    address = 'Address ~ ' + address;
                    if(str != ''){
                        str = str + '\n' + address;
                    }
                }
                if(leadMap.get(eventObj.WhoId).Phone != '' && leadMap.get(eventObj.WhoId).Phone != null){
                    if(str != ''){
                        str = str + '\n' + 'Phone ~ ' + leadMap.get(eventObj.WhoId).Phone;
                    }
                }
                if(leadMap.get(eventObj.WhoId).Email != '' && leadMap.get(eventObj.WhoId).Email != null){
                    if(str != ''){
                        str = str + '\n' + 'Email ~ ' + leadMap.get(eventObj.WhoId).Email;
                    }
                }
                
                descriptionStr = '\n\n````````````Lead Info`````````````\n' + (String.isNotBlank(descriptionStr) ? descriptionStr + '\n' + str : str); 
            }
            
            if(descriptionStr != ''){
                eventObj.Description = eventObj.Description + descriptionStr.removeStart('\n');
                eventObj.Description = eventObj.Description + '\n````````````````````````````````````````````````````';
            }
        }
    }
    
    public static void updateContractNumber(List<SObject> newlist){
        set<Id> proposalIdSet = new Set<Id>();
        for(SObject temp : newlist){
            Event eventObj = (Event)temp;
            if(eventObj.WhatId != NULL){
                system.debug(Schema.getGlobalDescribe().get('Apttus_Proposal__Proposal__c').getDescribe().getKeyPrefix() + '-------------------------' + String.valueOf(eventObj.WhatId).subString(0,2));
                if(Schema.getGlobalDescribe().get('Apttus_Proposal__Proposal__c').getDescribe().getKeyPrefix() == String.valueOf(eventObj.WhatId).subString(0,3)){
                    proposalIdSet.add(eventObj.whatId);
                }
            }
        }
        
        if(proposalIdSet.size() > 0){
            Map<Id,Apttus_Proposal__Proposal__c> proposalIdMap = new Map<Id,Apttus_Proposal__Proposal__c>([select Id,Name 
                from Apttus_Proposal__Proposal__c where Id in : proposalIdSet]);
            for(SObject temp : newlist){
                Event eventObj = (Event)temp;
                if(proposalIdMap.get(eventObj.whatId) != null){
                    eventObj.Contract_Number__c = proposalIdMap.get(eventObj.whatId).Name;
                }
            }
        }
    }
    
    public static void updateCompanyName(List<SObject> newlist){
        List<Lead> leadList = new List<Lead>();
        Map<String, Event> leadEventMap = new Map<String, Event>();
        List<Event> eventList = new List<Event>();
        
        for(SObject temp : newlist){
            Event et = (Event)temp;
            if(et.whoId != null){
                if(String.valueOf(et.whoId).substring(0,3) == '00Q'){
                    leadEventMap.put(String.valueOf(et.whoId), et);
                }
            }
        }
        
        if(leadEventMap.keySet().size() > 0){
            leadList = [select Id, Company from Lead where Id IN: leadEventMap.keySet()];
        }
        
        if(leadList.size() > 0){
            for(Lead ld: leadList){
                if(String.isNotBlank(ld.Company)){
                    leadEventMap.get(String.valueOf(ld.Id)).Company_Name__c = ld.Company;
                }
            }
        }
    }
    
    public static void updateLastActivityOwnerOnAccount(List<SObject> newlist){
        Map<Id, Id> ownerAccMap = new Map<Id, Id>();
        Map<Id, List<Event>> accEventsMap = new Map<Id, List<Event>>();
        set<Id> eventAccIdSet = new set<Id>();
        
        for(SObject temp : newlist){
            Event et = (Event)temp;
            if(et.WhatId != null){
                if(string.valueOf(et.WhatId).substring(0,3) == '001'){
                    eventAccIdSet.add(et.WhatId);
                }
            }
        }
        
        if(eventAccIdSet.size() > 0){
            List<Event> eventList = [select Id, ActivityDate, WhatId, OwnerId from Event where WhatId IN: eventAccIdSet Order by ActivityDate DESC];
            system.debug('--eventList--'+eventList);
            for(Event Ev: eventList){
                if(!accEventsMap.containsKey(ev.WhatId)){
                    accEventsMap.put(ev.WhatId, new List<Event>());
                }
                accEventsMap.get(ev.WhatId).add(ev);
            }
            system.debug('--eventAccEvents--'+accEventsMap);
            if(accEventsMap.keySet().size() > 0){
                set<Id> usrIdSet = new set<Id>();
                for(Id accId: accEventsMap.keySet()){
                    ownerAccMap.put(accId, accEventsMap.get(accId).get(0).OwnerId);
                    //usrIdSet.add(accEventsMap.get(accId).get(0).OwnerId);
                }
                system.debug('--eventAccUser--'+ownerAccMap);
                Map<Id, User> usrMap = new Map<Id, User>([select Id, Name, Division__c from User where Id IN: ownerAccMap.values()]);
                system.debug('--eventUser--'+usrMap);
                List<Account> accUpdateList = new List<Account>();
                for(Account acc: [select Id, Last_Activity_Owner__c from Account where Id IN: ownerAccMap.keySet() AND Account_Division__c Includes ('MEP')]){
                    acc.Last_Activity_Owner__c = usrMap.get(ownerAccMap.get(acc.Id)).Name;
                    accUpdateList.add(acc);
                }
                system.debug('--eventAcc--'+accUpdateList);
                if(!accUpdateList.isEmpty()){
                    update accUpdateList;
                }
            }
        }
    }
}