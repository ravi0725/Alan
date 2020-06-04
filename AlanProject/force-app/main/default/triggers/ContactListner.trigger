/*****************************************************************************************
Name    : ContactListner 
Desc    : Used to process Contact data when record is created or updated

Modification Log : 
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
Ankur Patel         20/03/2015          Created
******************************************************************************************/
trigger ContactListner on Contact(before insert,before update,after insert,after update,after delete) {
    if(userinfo.getName() != 'Data Administrator'){
        if(!AccountCreationCalloutEX.recursiveCallFlag && !AccountCreationCalloutEX.dLinkAccountFlag && 
           trigger.isAfter && !RecursiveTriggerUtility.isAccountMergeRecursive && 
           (trigger.isUpdate ? ContactHandler.validateContactExternalKeyValue(trigger.new, trigger.oldMap) : true) && !ImportDataController.importDataFlag){
               List<Contact> conList = new List<Contact>();
               conList = ContactHandler.validateDisableCallout(trigger.isDelete ? trigger.old : trigger.new);
               if(conList.size() > 0)
                   ContactHandler.configOutboundMessage((trigger.isDelete ? trigger.old : trigger.new),trigger.newMap,trigger.oldMap,trigger.isInsert,trigger.isUpdate,trigger.isDelete);
           }
        
        if(Trigger.IsAfter && Trigger.IsUpdate)
        {
            system.debug('INNNNNNN AFTER UPDATE');
            Map<Id,String> conAddressMap = new Map<Id,String>();
            for(Contact con : Trigger.new){
                if(con.Address__c != Trigger.oldMap.get(con.Id).Address__c){
                    conAddressMap.put(con.Id, con.Selected_Address__c);
                }
            }
            system.debug('=====Address MAp =====' + conAddressMap);
            // Contact_Address__c
            
            for(Case cs: [SELECT ID, contactID FROM CASE WHERE isClosed = false AND Record_Type_Name__c = 'TAP - Customer Support' AND contactID IN : conAddressMap.keyset()]){
                system.debug('===== cs.contactID ===== '+ cs.contactID);
                cs.Contact_Address__c = conAddressMap.get(cs.contactID);
                update cs;
            }
        }
        
        
        
        
        if(Trigger.Isbefore && (Trigger.IsInsert || Trigger.IsUpdate)){
            ContactHandler.CheckInvoice(Trigger.New);
            ContactHandler.validateTAPContact(trigger.new,trigger.newMap);
        }
        
    }
}