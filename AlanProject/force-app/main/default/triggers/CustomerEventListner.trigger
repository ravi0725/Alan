/**
 * Company     : Trimble Inc.,
 * Description : This Trigger is used to update records for Formstack integraion.
 * History     :  
 * [20.SEP.2017] Suresh Babu Murugan  Created
 */
trigger CustomerEventListner on Customer_Event__c (before insert, before update) {
    if(!UserInfo.getName().contains('API User')){
        if(Trigger.isBefore && Trigger.isInsert){
            CustomerEventHandler.cEvents_insert(Trigger.new);
        }
        else if(Trigger.isBefore && Trigger.isUpdate){
            CustomerEventHandler.cEvents_update(Trigger.new);
        }
    }
    else {
        // Trim response from Formstack
        if(Trigger.isBefore && Trigger.isUpdate){
            CustomerEventHandler.cTrimFormstackResp(Trigger.new);
        }
    }
}