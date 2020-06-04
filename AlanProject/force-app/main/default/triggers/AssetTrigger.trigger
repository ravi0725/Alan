/*****************************************************************************************
    Name    : AssetTrigger 
    Desc    : Match all the fields in Asset to Asset Line Item. Copy existing Asset records to Asset Line Item
              Part of ITEM-00817 - Need trigger to copy Asset to Asset Line Item  
                            
Modification Log : Update Asset Lookup at Order Line level using the Attribute6 (Asset Oracle ID) of Order Line Interface
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Sagar Mehta        01/18/2013          Created
Prince Leo         01-Dec-2018         Modified
******************************************************************************************/
trigger AssetTrigger on Asset (after insert) {
    List<Apttus_Config2__AssetLineItem__c> lineItemList = new List<Apttus_Config2__AssetLineItem__c>();
    List<Order_Line_Item__c>UpdateOrderLineList = new List<Order_Line_Item__c>();
    Map<String,Asset>AssetOracleIDMap = new Map<String,Asset>();
    try{
      for(Asset asset : trigger.new){
         Apttus_Config2__AssetLineItem__c item = new Apttus_Config2__AssetLineItem__c();
         item.Name = asset.Name;
         item.Apttus_Config2__AccountId__c = asset.AccountId;
         item.Serial_Number__c = asset.SerialNumber;
         item.License_Key__c = asset.License_Key__c;
         item.Version__c = asset.Product_Version__c;
         item.Apttus_Config2__NetPrice__c = asset.Price;
         item.Apttus_Config2__Quantity__c = asset.Quantity;
         item.Apttus_Config2__ProductId__c = asset.Product2Id;
         item.Apttus_Config2__PurchaseDate__c = asset.PurchaseDate;
         item.Apttus_Config2__StartDate__c = asset.InstallDate;
         item.Apttus_Config2__EndDate__c = asset.UsageEndDate;
         item.Apttus_Config2__AssetStatus__c = 'New'; 
         item.Asset_Oracle_ID__c = asset.Asset_Oracle_ID__c;       
         lineItemList.add(item);
         if(asset.Asset_Oracle_Id__c!=Null) AssetOracleIDMap.put(asset.Asset_Oracle_Id__c,asset);
      }
      
      for(Order_Line_Item__c ol : [select id,Asset__c,Asset_Oracle_ID__c from Order_Line_Item__c where Asset__c =Null AND Asset_Oracle_ID__c != Null AND Asset_Oracle_ID__c in: AssetOracleIDMap.keyset()])
      {
       if(AssetOracleIDMap.get(ol.Asset_Oracle_ID__c) != Null) {
       ol.Asset__c = AssetOracleIDMap.get(ol.Asset_Oracle_ID__c).id;
       UpdateOrderLineList.add(ol);
       }
       
      }
      
      insert lineItemList;
      if(UpdateOrderLineList.size()>0) update UpdateOrderLineList;
    }catch(Exception e){
        System.debug(e.getMessage());
    }   
}