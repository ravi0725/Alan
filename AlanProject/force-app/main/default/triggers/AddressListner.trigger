/*****************************************************************************************
    Name    : AddressListner 
    Desc    : Used to process Address data when record is created or updated
                            
Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Ankur Patel         20/03/2015          Created
Suresh Babu         26/10/2015          Modified - Added lines from #35 to #43
******************************************************************************************/
trigger AddressListner on Address__c(before insert, before update, after insert,after update,after delete) {
    system.debug(LinkAccountController.LinkAccountCall + '-------------------' + RecursiveTriggerUtility.isAccountMergeRecursive);
    system.debug(ImportDataController.importDataFlag + '-------------------' + AccountCreationCalloutEX.recursiveCallFlag);
    if(userinfo.getName() != 'Data Administrator' && !RecursiveTriggerUtility.isAccountMergeRecursive && !LinkAccountController.LinkAccountCall && !ImportDataController.importDataFlag){
        if(trigger.isAfter && !AccountCreationCalloutEX.recursiveCallFlag && 
            (trigger.isUpdate ? AddressHandler.validateAddressExternalKeyValue(trigger.new, trigger.oldMap) : true)){
            system.debug('----------CallOut------');
            List<Address__c> addList = new List<Address__c>();
            addList = AddressHandler.validateDisableCallout(trigger.isDelete ? trigger.old : trigger.new);
            if(addList.size() > 0)
            AddressHandler.configOutboundMessage((trigger.isDelete ? trigger.old : trigger.new),trigger.newMap,trigger.oldMap,trigger.isInsert,trigger.isUpdate,trigger.isDelete);
        }
        
        if(trigger.isBefore && trigger.isInsert){
            AddressHandler.setAddressName(trigger.new);
        }
        
        
        /*****************************************************************************************
        Name         : AddressTrigger 
        Desc         : Used for Populating Account.Restricted_Entity__c based on ALL Address record's Restricted_Party_Indicator__c field value associated with it. 
            
        If any one of the address has the field Restricted_Party_Indicator__c = ‘Restricted’ then its Account -> Restricted_Entity__c=’ Restricted’;
        If any one of the address has the field Restricted_Party_Indicator__c = ‘Check in Progress’ then its Account -> Restricted_Entity__c=’ Check in Progress’;
        If all the address has Restricted_Party_Indicator__c= ‘Not Restricted’ only then Update the Account -> Restricted_Entity__c= Not Restricted’;
        ****/
        if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
            AddressTriggerHandler.setAccountRestrictedEntity(trigger.new, trigger.old);
        }
        
        
        /******************************************************************************************
        Name        :   AddressTrigger
        Description :   Used to set Primary (Primary__c) check box to denote Primary contact address for Account.
        
        Managed to maintain one Account should have only one Primary Address.
        *******************************************************************************************/
        if(trigger.isAfter && trigger.isUpdate && RecursiveTriggerUtility.isAddressRecursive){
            AddressTriggerHandler.checkPrimaryAddressForAccount(trigger.newMap, trigger.oldMap);
        }
        if(Trigger.Isbefore && Trigger.IsUpdate)
        { 
          AddressHandler.resetStatusFlag(trigger.newMap, trigger.oldMap);
        }
    }
    
    if(trigger.isBefore && ( trigger.isInsert || trigger.isUpdate)){
        AddressHandler.populateRegionValue(trigger.new); 
    }
    
}