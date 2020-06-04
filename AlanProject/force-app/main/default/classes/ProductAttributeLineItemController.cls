public class ProductAttributeLineItemController {
    
    public String lineItemId{get;set;}
    public String selectedAsset{get;set;} 
    public String selectedEntitlement{get;set;} 
    public String allSelectedAssets{get;set;} 
    public String allSelectedEntitlements{get;set;}
    public String validAssets{get;set;}
    public string division{get;set;}
    public boolean enablePricing{get;set;}
    public List<SelectOption> assetOptionValues{get;set;}
    public List<Apttus_Config2__LineItem__c> lineItemList;
    public List<AssetWrapper> assetWrapList{get;set;}
    public List<AssetWrapper> allAssetWrapList;
    Map<String,Decimal> assetOracleIdQtyMap = new Map<String,Decimal>();
    public string configRequestId{get;set;}
    public string proposalId{get;set;}
    public string configurationId{get;set;}
    public string tempid{get;set;}
    public string flowUI{get;set;}
    
    //Pagination
    public Integer currentPageRd{get;set;}
    public Integer totalPageRd{get;set;}
    public Integer pageSizeRd{get;set;}
    public boolean nextPageFlagRd{get;set;}
    public boolean previousFlagRd{get;set;}
    public Integer totalRecordsRd{get;set;}
    
    public ProductAttributeLineItemController(ApexPages.StandardController controller){
    flowUI = System.currentPageReference().getParameters().get('flow'); 
        pageSizeRd = VF_Page_Paggination_Config__c.getAll().get('ProductAttributeDetailCustom').Records_Per_Page__c.intValue();
        
        retriveAssetRecords();
    }
    
    public void retriveAssetRecords(){
        nextPageFlagRd = false;
        previousFlagRd = false;
        currentPageRd = 0;
        totalRecordsRd = 0;
        validAssets = '';
        selectedAsset = '';
        selectedEntitlement = '';
        allSelectedAssets = '';
        allSelectedEntitlements = '';
        enablePricing = false;
        lineItemId = ApexPages.CurrentPage().getParameters().get('id');
        configRequestId = ApexPages.CurrentPage().getParameters().get('configRequestId');
        
        for(Apttus_Config2__TempObject__c tempObj : [select Id,Apttus_Config2__ConfigurationId__c,Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c,Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.Selling_Division__c from Apttus_Config2__TempObject__c where Id =: configRequestId]){
            proposalId = tempObj.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c;
            tempid = tempObj.id;
            configurationId = tempObj.Apttus_Config2__ConfigurationId__c;
            division = tempObj.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.Selling_Division__c;
        } 
        
        assetOptionValues = new List<SelectOption>(); 
        assetOptionValues.add(new SelectOption('None', '---None---'));
        assetWrapList = new List<AssetWrapper>();   
        allAssetWrapList = new List<AssetWrapper>();   
        List<AssetWrapper> tempAssetWrapList = new List<AssetWrapper>();   
        lineItemList = new List<Apttus_Config2__LineItem__c>();
        lineItemList = [Select Id,Entitlement_Oracle_Id__c,Apttus_Config2__ProductId__c,Apttus_Config2__ProductId__r.ProductCode,Apttus_Config2__Quantity__c, Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__c, Asset_Oracle_ID__c
                        from Apttus_Config2__LineItem__c where Id =: lineItemId];
        
        if(lineItemList.size() > 0){
            //Retrive all Product Options Component
            for(Apttus_Config2__ProductOptionComponent__c prdOptComp : [select Id,Apttus_Config2__ParentProductId__c from Apttus_Config2__ProductOptionComponent__c where Apttus_Config2__ComponentProductId__c =: lineItemList.get(0).Apttus_Config2__ProductId__c]){
                validAssets = validAssets + ',' + prdOptComp.Apttus_Config2__ParentProductId__c;
            }
            
            Id accountId = lineItemList.get(0).Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__c;
            selectedAsset = lineItemList.get(0).Asset_Oracle_ID__c;
            selectedEntitlement = lineItemList.get(0).Entitlement_Oracle_Id__c;
            for(Asset ass : [Select Id,Product2Id,Product_Code__c,License_Key__c,PurchaseDate,Product_Version__c,Quantity, Name,SerialNumber,Asset_Oracle_ID__c,
                                (select ID,Quantity__c,Contract_Number__c,Oracle_Unique_Identifier__c,Asset_Effectivity__c,Status,Contract_Start_Date__c,Entitlement_Status__c,Entitlement_Product_Product_Code__c,Contract_End_Date__c,StartDate,EndDate 
                                 from Asset.Entitlements/* where Entitlement_Product_Product_Code__c =: lineItemList.get(0).Apttus_Config2__ProductId__r.ProductCode and Entitlement_Product_Product_Code__c != null
                                and Entitlement_Product_Product_Code__c != '' */) 
                             from Asset where Accountid=: accountId /*and Asset_Oracle_ID__c != null*/ order by Asset_Oracle_ID__c nulls Last]){
                if(ass.Entitlements.size() > 0){
                    for(Entitlement ent : ass.Entitlements){
                        AssetWrapper assWrap = new AssetWrapper(ass,ent);
                        
                        assetOracleIdQtyMap.put(ass.Asset_Oracle_ID__c + ':' + ent.Entitlement_Product_Product_Code__c,ass.Quantity);
                        system.debug('----------assetOracleIdQtyMap---------' + assetOracleIdQtyMap);
                        if(selectedAsset == ass.Asset_Oracle_ID__c + ':' + ent.Entitlement_Product_Product_Code__c && selectedAsset != null && selectedAsset != ''){
                            enablePricing = true;
                        }
                        allAssetWrapList.add(assWrap);
                    }
                }else{
                    AssetWrapper assWrap = new AssetWrapper(ass,new Entitlement());
                    assWrap.entitltmentFlag = false;
                    assetOracleIdQtyMap.put(ass.Asset_Oracle_ID__c,ass.Quantity);
                    system.debug('----------assetOracleIdQtyMap---------' + assetOracleIdQtyMap);
                    if(selectedAsset == ass.Asset_Oracle_ID__c && selectedAsset != null && selectedAsset != ''){
                        enablePricing = true;
                    }
                    tempAssetWrapList.add(assWrap);
                }
            }
            
            if(tempAssetWrapList.size() > 0){
                allAssetWrapList.addAll(tempAssetWrapList);
            }
            
            if(allAssetWrapList.size() > 0){
                currentPageRd = 0;
                totalPageRd = (allAssetWrapList.size() / pageSizeRd);
                totalRecordsRd = (totalPageRd * pageSizeRd) + Math.mod(allAssetWrapList.size() , pageSizeRd);
                if(Math.mod(allAssetWrapList.size() , pageSizeRd) > 0) totalPageRd++;
                nextPageRd();
            }
            retriveSelectedAssets();
        }else{
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, Label.NO_Records_Found);
            ApexPages.addMessage(msg); 
            return;
        }
    }
    
    public void nextPageRd(){
        assetWrapList = new List<AssetWrapper>();
        system.debug('---rdCnt---'+currentPageRd * pageSizeRd);
        for(Integer rdCnt = (currentPageRd * pageSizeRd); rdCnt < ((currentPageRd+1) * pageSizeRd) ; rdCnt++){
            assetWrapList.add(allAssetWrapList[rdCnt]);
            if(rdCnt+1 >= allAssetWrapList.size()) break;
        }
        system.debug(totalPageRd + '--------------' + currentPageRd);
        currentPageRd++;
        system.debug(currentPageRd + '--------------' + assetWrapList);
        nextPageFlagRd = currentPageRd >= totalPageRd;
        previousFlagRd = currentPageRd == 1;
    }
    
    public void previousPageRd(){
        currentPageRd--;
        assetWrapList = new List<AssetWrapper>();
        for(Integer rdCnt = ((currentPageRd-1) * pageSizeRd); rdCnt < (currentPageRd * pageSizeRd) ; rdCnt++){
            assetWrapList.add(allAssetWrapList[rdCnt]);
            if(rdCnt+1 >= allAssetWrapList.size()) break;
        }
        nextPageFlagRd = currentPageRd >= totalPageRd;
        previousFlagRd = (currentPageRd == 1);
    }
    
    public void retriveSelectedAssets(){
        system.debug('-----------------' + configurationId);
        allSelectedAssets = '';
        allSelectedEntitlements = '';
        for(Apttus_Config2__LineItem__c litm : [Select Id, Asset_Oracle_ID__c,Entitlement_Oracle_Id__c
            from Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c =: configurationId AND Type__c = 'New Buy']){ 
            // Change       :   Add condition in above Query "AND Type__c = 'New Buy'"
            // Description  :   GCCM division wants to Configure Asset with New Buy lines in Renewal Quote
            // Request      :   TT 128258 - Adding new buy lines for the same serial number on a renewal quote
            if(string.isNOTBlank(litm.Asset_Oracle_ID__c))allSelectedAssets = allSelectedAssets + ',' + litm.Asset_Oracle_ID__c;
            if(string.isNOTBlank(litm.Entitlement_Oracle_Id__c))allSelectedEntitlements = allSelectedEntitlements + ',' + litm.Entitlement_Oracle_Id__c;
        }
    }
    
    public void loadAssetData(){
        //assetList = [Select Id, Name, SerialNumber, License_Key__c, Product_Version__c, PurchaseDate, Asset_Oracle_ID__c from Asset where Id =: selectedAsset];
    }
    
    Public Pagereference AddProd(){
    if(flowUI == 'Default')
     return new Pagereference('/apex/Apttus_Config2__SelectConfigProductsFilterView?id='+configurationId+'&configRequestId='+tempid +'&launchState=catalog');
    else
    return new Pagereference('/apex/Apttus_Config2__Cart?configRequestId='+tempid +'&id='+configurationId+'&launchState=catalog');
    }
    
    public void saveLineItem(){
        if(selectedAsset == '' || selectedAsset == null){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Asset_Mandatory);
            ApexPages.addMessage(msg); 
            return;
        }
        try{
            if(lineItemList.size() > 0){
                for(Apttus_Config2__LineItem__c lineItem : lineItemList){
                    lineItem.Asset_Oracle_ID__c = selectedAsset;
                    lineItem.Entitlement_Oracle_Id__c = selectedEntitlement;
                    system.debug(assetOracleIdQtyMap.get(selectedAsset) + '----------selectedAsset---------' + selectedAsset);
                    lineItem.Apttus_Config2__Quantity__c = (assetOracleIdQtyMap.get(selectedAsset) != null ? assetOracleIdQtyMap.get(selectedAsset) : lineItem.Apttus_Config2__Quantity__c);
                }
                update lineItemList;
                enablePricing = true; 
                retriveSelectedAssets();
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, Label.Asset_Saved);
                ApexPages.addMessage(msg);
            }
        }catch(Exception e){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Unexpected_Error);
            ApexPages.addMessage(msg);
        }         
    }
    
    class AssetWrapper{
        public Asset assObj{get;set;}
        public Entitlement entObj{get;set;}
        public boolean entitltmentFlag{get;set;}
        public boolean selected{get;set;}
        public AssetWrapper(Asset ass, Entitlement ent){
            entitltmentFlag = true;
            assObj = ass;
            entObj = ent;
            selected = false;
        }
    }
}