public class PriceListItemHelper {
    public static Map<String, Integer> launchControl;
    // Static initialize
    static {
        resetLaunchControl();
    }
    
    // Reset Trigger control (e.g. for testing)
    public static void resetLaunchControl() {
        launchControl = new Map<String, Integer>();
        launchControl.put('configCase',0);
    }
    
    // set Trigger control (e.g. for testing)
    public static void setLaunchControl() {
        launchControl = new Map<String, Integer>();
        launchControl.put('configCase',1);
    }
    
    public static void createPriceBookEntries(List<Apttus_Config2__PriceListItem__c> newPriceListItems){
        Map<String,Id> insertPriceBookEntryMap = new Map<String,Id>();
        Map<String,PriceBookEntry> updatePriceBookEntryMap = new Map<String,PriceBookEntry>();
        Map<String,PriceBookEntry> stdPriceBookEntryMap = new Map<String,PriceBookEntry>();
        List<PriceBookEntry> insertpriceBookEntryList = new List<PriceBookEntry>();
        List<PriceBookEntry> updatepriceBookEntryList = new List<PriceBookEntry>();
        Map<String,Id> priceBookNameIdMap = new Map<String,Id>();
        set<Id> prdIds = new set<Id>();
        
        for(PriceBook2 pb : [select Name,Id from PRiceBook2 where isActive = true]){
			priceBookNameIdMap.put(pb.Name, pb.Id);
		}
        system.debug('-----------------' + priceBookNameIdMap);
		for(Apttus_Config2__PriceListItem__c priceListItem : newPriceListItems){
            system.debug('---------priceListItem.Price_List_Name__c--------' + priceListItem.Price_List_Name__c);
            if(priceListItem.Apttus_Config2__Active__c && priceListItem.Apttus_Config2__ProductId__c != null && priceListItem.Apttus_Config2__PriceListId__c != null){
                if(Price_Book_Config__c.getAll().containsKey(priceListItem.Price_List_Name__c) ? Price_Book_Config__c.getAll().get(priceListItem.Price_List_Name__c).Price_Books__c != null : false){
                    for(String pbName : Price_Book_Config__c.getAll().get(priceListItem.Price_List_Name__c).Price_Books__c.split(',')){
                        if(priceBookNameIdMap.containsKey(pbName)){
                        	insertPriceBookEntryMap.put(priceListItem.Apttus_Config2__ProductId__c + '-'+
                            	               				priceListItem.CurrencyISOCode + '-' +
                                	           					priceBookNameIdMap.get(pbName),null);
                        }
                    }
                    prdIds.add(priceListItem.Apttus_Config2__ProductId__c);
                    system.debug('-----------------' + priceListItem.Apttus_Config2__ProductId__c);
                }
            }
		}
        system.debug('-----------------' + insertPriceBookEntryMap);
        system.debug('-----------------' + prdIds);
        for(PriceBookEntry pbe : [select Id,isActive,PriceBook2Id,PriceBook2.isStandard,Product2Id,CurrencyIsoCode from PriceBookEntry where 
                                  Product2Id in : prdIds]){
            system.debug(pbe.Product2Id + '-' + pbe.CurrencyISOCode+ '-'+ pbe.PriceBook2Id + ')-----------------' + pbe);
                                      if(pbe.PriceBook2.isStandard && !pbe.IsActive) stdPriceBookEntryMap.put(pbe.Product2Id + '-' + pbe.CurrencyISOCode+ '-'+ pbe.PriceBook2Id, pbe);
                                      if(pbe.IsActive) insertPriceBookEntryMap.put(pbe.Product2Id + '-' + pbe.CurrencyISOCode+ '-'+ pbe.PriceBook2Id, pbe.Id);
                                      else updatePriceBookEntryMap.put(pbe.Product2Id + '-' + pbe.CurrencyISOCode+ '-'+ pbe.PriceBook2Id, pbe);
        }
        system.debug('---------stdPriceBookEntryMap--------' + stdPriceBookEntryMap);
        for(String key : insertPriceBookEntryMap.keySet()){
            system.debug('---------key--------' + key);
            system.debug(insertPriceBookEntryMap.get(key) + '---------key--------' + updatePriceBookEntryMap.containsKey(key));
            if(insertPriceBookEntryMap.get(key) == null && !updatePriceBookEntryMap.containsKey(key)){
                if(!stdPriceBookEntryMap.containsKey(key.split('-')[0] + '-' + key.split('-')[1] + '-' + priceBookNameIdMap.get('Standard Price Book')) && 
                   !insertPriceBookEntryMap.containsKey(key.split('-')[0] + '-' + key.split('-')[1] + '-' + priceBookNameIdMap.get('Standard Price Book'))){
                    PriceBookEntry pbe = new PriceBookEntry();
                    pbe.Product2Id = key.split('-')[0];
                    pbe.CurrencyIsoCode = key.split('-')[1];
                    pbe.Pricebook2Id = priceBookNameIdMap.get('Standard Price Book');
                    pbe.UnitPrice = 0;
                    pbe.IsActive = true;
                    insertpriceBookEntryList.add(pbe);
                }else if(stdPriceBookEntryMap.containsKey(key.split('-')[0] + '-' + key.split('-')[1] + '-' + priceBookNameIdMap.get('Standard Price Book'))){
                    stdPriceBookEntryMap.get(key.split('-')[0] + '-' + key.split('-')[1] + '-' + priceBookNameIdMap.get('Standard Price Book')).isActive = true;
                    updatepriceBookEntryList.add(stdPriceBookEntryMap.get(key.split('-')[0] + '-' + key.split('-')[1] + '-' + priceBookNameIdMap.get('Standard Price Book')));
                }
                
                PriceBookEntry pbe1 = new PriceBookEntry();
                pbe1.Product2Id = key.split('-')[0];
                pbe1.CurrencyIsoCode = key.split('-')[1];
                pbe1.Pricebook2Id = key.split('-')[2];
                pbe1.UnitPrice = 0;
                pbe1.IsActive = true;
                insertpriceBookEntryList.add(pbe1);
            }else if(updatePriceBookEntryMap.containsKey(key)){
                system.debug('---------updatePriceBookEntryMap-------' + updatePriceBookEntryMap);
                updatePriceBookEntryMap.get(key).isActive = true;
                updatepriceBookEntryList.add(updatePriceBookEntryMap.get(key));
            }
            if(updatePriceBookEntryMap.containsKey(key.split('-')[0] + '-' + key.split('-')[1] + '-' + priceBookNameIdMap.get('Standard Price Book')))
                 updatePriceBookEntryMap.get(key.split('-')[0] + '-' + key.split('-')[1] + '-' + priceBookNameIdMap.get('Standard Price Book')).isActive = true;
        }
        system.debug('-------updatepriceBookEntryList----------' + updatepriceBookEntryList);
        system.debug('-----------------' + insertpriceBookEntryList); 
        if(insertpriceBookEntryList.size() > 0)insert insertpriceBookEntryList;
        if(updatepriceBookEntryList.size() > 0)update updatepriceBookEntryList;
        
    }
}