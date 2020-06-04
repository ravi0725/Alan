trigger AutopopulatePartnerAccount on Case (before update, before insert) {
    if(userinfo.getName() != 'Data Administrator'){    
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
            
            //Creating a Map contining all Account IDs from Case where Account ID is not NULL, Partner Account and Partner Contact is Not NULL (this is considered due to Look filter on Partner Contact Name related to Partner Account)
            // and Record Type is GCCM - Support Case Record Type OR GCCM - Support Issue Record Type - this is for GCCM Cases
            {
            
            //TriggerControl__c profileCustomSetting = TriggerControl__c.getInstance(UserInfo.getUserId());
            //if(!(profileCustomSetting.Disable_Trigger__c))
                {
            
                Map<Id, Partner__c> csAccPrtnrMap = new Map<Id, Partner__c>();    
                for(Case c : Trigger.new){
            
                    if(c.AccountId != NULL
                       &&
                       c.Referring_Partner_Account__c == NULL 
                       &&
                       c.Partner_Contact_Name__c == NULL 
                       && 
                       ( c.Record_Type_Name__c == 'GCCM - Support Case Record Type' || c.Record_Type_Name__c == 'GCCM - Support Issue Record Type')){
                       csAccPrtnrMap.put(c.AccountId, new Partner__c());
                    }
                        
             }   
             
             //Creating List of Partner Accounts corresponding to Accounts contained in Map.KeySet 
        
                   if(csAccPrtnrMap.keySet().size() > 0){
                    List<Partner__c> prtnrList = [Select Id,partner__c,  Account__c from partner__c 
                        where 
                            Account__c IN: csAccPrtnrMap.keySet()];
                   
        
             //Appending the Account and Partner Combination to the Map 
                  
                    if(prtnrList.size() > 0){
                        csAccPrtnrMap = new Map<Id, Partner__c>();
                        for(Partner__c prtnr: prtnrList){
                            csAccPrtnrMap.put(prtnr.Account__c, prtnr);
                        
                        
                            }
                        }
                        
                        
             //If no Accounts are fetched re-initialize the Map
                    
                    else{
                        csAccPrtnrMap = new Map<Id, Partner__c>();
                    }
            //Fetching the values from Map and populating Referring/ Partner Account    
                    
                    for(case cs: trigger.new){
                        if(csAccPrtnrMap.containsKey(cs.AccountId) && cs.AccountId != NULL){
                            cs.Referring_Partner_Account__c = csAccPrtnrMap.get(cs.AccountId).partner__c;
                        }
                        
                        Else{
                            cs.Referring_Partner_Account__c = NULL;
                        }
                    }
                }
              } 
           }
   }
}