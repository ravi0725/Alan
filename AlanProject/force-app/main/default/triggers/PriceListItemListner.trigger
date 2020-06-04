trigger PriceListItemListner on Apttus_Config2__PriceListItem__c (after insert,after update) {
    if((trigger.isInsert || trigger.isUpdate) && trigger.isAfter){
        system.debug('-----------------' + trigger.new.get(0).Apttus_Config2__ProductId__c);
        PriceListItemHelper.createPriceBookEntries(trigger.new);
    }
}