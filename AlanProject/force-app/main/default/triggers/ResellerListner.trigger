/*****************************************************************************************
    Name    : ResellerListner 
    Desc    : Used to do a call out on Creation and Delete of Reseller for TAP division
                                          
Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Prince Leo           21/11/2018          Created 
******************************************************************************************/
trigger ResellerListner on Reseller__c (after insert,before delete) {
Profile prof = [Select id,Name from Profile where Id = :UserInfo.getProfileId()];
    if(!prof.Name.contains(Label.Restrict_Callout_Profile)){
    
    if(trigger.isInsert && trigger.new.size()==1){
    List<Id> tempList = new List<Id>();
    tempList.add(trigger.new.get(0).Parent_Account__c);
    AccountCreationCalloutEX.CallEBS(tempList,'Update','NoOp','NoOp',new Set<String>(),new Set<String>(),new Set<String>());
    }
    
    if(trigger.isDelete){
    List<Id> tempList = new List<Id>();
    tempList.add(trigger.old.get(0).Parent_Account__c);
    AccountCreationCalloutEX.CallEBS(tempList,'Update','NoOp','NoOp',new Set<String>(),new Set<String>(),new Set<String>());
    }
   }
}