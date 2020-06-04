/*****************************************************************************************
    Name    : PriceListTrigger 
    Desc    : Trigger on pricelist to match the currency for pricelist and pricelist item whenever currency is updated
              on pricelist
                            
    Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Ashfaq Mohammed       4/22/2014          Created

******************************************************************************************/

trigger PriceListTrigger on Apttus_Config2__PriceList__c (after update) {
    if(Trigger.isAfter==true && Trigger.isUpdate ==true ){
        map<id,Apttus_Config2__PriceList__c> plMap = new map<id,Apttus_Config2__PriceList__c>();
        list<Apttus_Config2__PriceListItem__c> PriceListItemList = new list<Apttus_Config2__PriceListItem__c>();
        for(Apttus_Config2__PriceList__c pl : trigger.new) {
            if(pl.CurrencyIsoCode != system.trigger.oldMap.get(pl.id).CurrencyIsoCode){
                plMap.put(pl.id,pl);
            }
        }
        
        for(Apttus_Config2__PriceListItem__c pli : [Select ID,Apttus_Config2__PriceListId__c,CurrencyIsoCode from Apttus_Config2__PriceListItem__c Where Apttus_Config2__PriceListId__c IN:plMap.keySet()]){
            pli.CurrencyIsoCode = plMap.get(pli.Apttus_Config2__PriceListId__c).CurrencyIsoCode;
            PriceListItemList.add(pli);
        }
        if(PriceListItemList.size()>0){
            update PriceListItemList;
        }
        
    }

}