public class Products_PriceList_Disp_Controller{
    public String sSelectView {get;set;}
    public String PriceListName{get;set;}
    set<ID> ProdId = new Set<ID>();
    public String displayType{get;set;}
    public String pageLoadType{get;set;}
    public boolean isVFPage{get;set;}
    public String LoadType{get;set;}
    public SelectOption[] selectedFamily{ get; set; }
    public SelectOption[] availableFamily{ get; set; }
    set<String> productFamily = new Set<String>();
    public Integer totalAvailRecord{get;set;}
    public Integer totalSelectedRecord{get;set;}
    public String prdFamilyList{get;set;} 
    public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null){
            
                if(productFamily.size() > 0) {
                    setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                      [select CurrencyISOCode,Apttus_Config2__ProductId__r.Family,name,Apttus_Config2__ProductId__c,
                      Apttus_Config2__PriceListId__r.Name,Apttus_Config2__ProductId__r.Name,Apttus_Config2__ChargeType__c,
                      Apttus_Config2__ListPrice__c,Apttus_Config2__ProductFamily__c,Apttus_Config2__ProductCode__c 
                      from Apttus_Config2__PriceListItem__c where Apttus_Config2__PriceListId__r.Name='INT DATA-GBP' 
                      and Apttus_Config2__ChargeType__c='Standard Price' and Apttus_Config2__ProductFamily__c in : productFamily order by Apttus_Config2__PriceListId__r.Name]));
                }else{
                    setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                      [select CurrencyISOCode,Apttus_Config2__ProductId__r.Family,name,Apttus_Config2__ProductId__c,
                      Apttus_Config2__PriceListId__r.Name,Apttus_Config2__ProductId__r.Name,Apttus_Config2__ChargeType__c,
                      Apttus_Config2__ListPrice__c,Apttus_Config2__ProductFamily__c,Apttus_Config2__ProductCode__c
                     from Apttus_Config2__PriceListItem__c where Apttus_Config2__PriceListId__r.Name='INT DATA-GBP' 
                      and Apttus_Config2__ChargeType__c='Standard Price' order by Apttus_Config2__PriceListId__r.Name]));
                }
            }
            return setCon;
        }
        set;
    }
    
    public Products_PriceList_Disp_Controller(){
        if(Apexpages.currentpage().getparameters().get('displayType') != null){
            pageLoadType = Apexpages.currentpage().getparameters().get('displayType');
        }
        
        sSelectView = [select Default_Pricelist__c from User where Id =: userinfo.getUserId()].Default_Pricelist__c;
        if(Apexpages.currentpage().getparameters().get('PriceListName') != null){
            sSelectView = Apexpages.currentpage().getparameters().get('PriceListName');
        }
        
        if(Apexpages.currentpage().getparameters().get('prdFamilyList') != null){
            prdFamilyList = Apexpages.currentpage().getparameters().get('prdFamilyList');
        }else{
            prdFamilyList = '';
        }
        system.debug('-------prdFamilyList-------'+prdFamilyList );
        if(pageLoadType == 'Excel'){
            loadType = 'application/vnd.ms-excel#PriceListItems.xls';
            isVFPage = false;
            displayType = '';
        }else if(pageLoadType == 'PDF'){
            displayType = 'PDF';
            isVFPage = false;
        }else{
            isVFPage = true;
        }
        
        selectedFamily = new List<selectoption>();
        availableFamily = new List<selectoption>();
        totalAvailRecord = 0;
        totalSelectedRecord = 0;
        if(sSelectView != null && sSelectView != '' && !test.isRunningTest())
            filterProductFamily();
        else{
            sSelectView = 'TIBV CH Test';
            filterProductFamily();
        }
    }
    
    public void filterProductFamily(){
        PriceListName = this.sSelectView;
        system.debug('--------------'+PriceListName);
        if(PriceListName != null && PriceListName != ''){
            selectedFamily = new List<selectoption>();
            availableFamily = new List<selectoption>();
            for(AggregateResult agr : [select Apttus_Config2__ProductId__r.Family prdFamily from Apttus_Config2__PriceListItem__c where 
                          Apttus_Config2__PriceListId__r.Name=:PriceListName group by Apttus_Config2__ProductId__r.Family order by Apttus_Config2__ProductId__r.Family]){
                if(agr.get('prdFamily') != null)
                    availableFamily.add(new selectOption(String.valueof(agr.get('prdFamily')),string.valueof(agr.get('prdFamily'))));
            }
            toggleEvents();
        }else{
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select Product Family.'));
        }
    }

    
     public void toggleEvents() {
        
         system.debug(Apexpages.currentpage().getparameters().get('prdFamilyList') + '-------prdFamilyList-------'+prdFamilyList );
         prdFamilyList = '--';
         productFamily = new set<String>();
        for ( SelectOption so : selectedFamily){
            productFamily.add(so.getValue());
            prdFamilyList = prdFamilyList + '; ' + so.getValue();
        }
        prdFamilyList = prdFamilyList.replaceAll('--; ' , '').replaceAll('--','');
     
        PageReference ReadPage;
        if(productFamily.size() > 0) {
            setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                  [select CurrencyISOCode,Apttus_Config2__ProductId__r.Family,name,Apttus_Config2__ProductId__r.Apttus_Config2__ConfigurationType__c,Apttus_Config2__PriceListId__r.Name,Apttus_Config2__ProductId__c,Apttus_Config2__ProductId__r.Name,
                      Apttus_Config2__ChargeType__c,Apttus_Config2__ListPrice__c,Apttus_Config2__ProductFamily__c,
                      Apttus_Config2__ProductCode__c from Apttus_Config2__PriceListItem__c where 
                      Apttus_Config2__PriceListId__r.Name=:PriceListName and Apttus_Config2__ChargeType__c='Standard Price' 
                      and Apttus_Config2__ProductFamily__c in : productFamily order by Apttus_Config2__PriceListId__r.Name]));
        }else{
            setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                  [select CurrencyISOCode,Apttus_Config2__ProductId__r.Family,name,Apttus_Config2__ProductId__r.Apttus_Config2__ConfigurationType__c,Apttus_Config2__PriceListId__r.Name,Apttus_Config2__ProductId__c,Apttus_Config2__ProductId__r.Name,
                      Apttus_Config2__ChargeType__c,Apttus_Config2__ListPrice__c,Apttus_Config2__ProductFamily__c,
                      Apttus_Config2__ProductCode__c from Apttus_Config2__PriceListItem__c where 
                      Apttus_Config2__PriceListId__r.Name=:PriceListName and Apttus_Config2__ChargeType__c='Standard Price' 
                      order by Apttus_Config2__PriceListId__r.Name]));
        }
    }
    
    public List<WrapperList> getWrList(){
        if(Apexpages.currentpage().getparameters().get('prdFamilyList') != null){
            prdFamilyList = Apexpages.currentpage().getparameters().get('prdFamilyList');
        }
        system.debug('-------prdFamilyList-------'+prdFamilyList );
        system.debug(Apexpages.currentpage().getparameters().get('prdFamilyList') + '-------prdFamilyList-------'+prdFamilyList );
        List<Apttus_Config2__PriceListItem__c > priceList = new List<Apttus_Config2__PriceListItem__c >();
        if(isVFPage){
             setCon.setpagesize(50);
             priceList = setCon.getRecords();
         }else{
             if(prdFamilyList != null && prdFamilyList != ''){
                 for(String str : prdFamilyList.split('; '))
                     productFamily.add(str);
             }
             if(productFamily.size() > 0) {
                 priceList = [select CurrencyISOCode,Apttus_Config2__ProductId__r.Family,name,Apttus_Config2__ProductId__r.Apttus_Config2__ConfigurationType__c,Apttus_Config2__PriceListId__r.Name,Apttus_Config2__ProductId__c,Apttus_Config2__ProductId__r.Name,
                      Apttus_Config2__ChargeType__c,Apttus_Config2__ListPrice__c,Apttus_Config2__ProductFamily__c,
                      Apttus_Config2__ProductCode__c from Apttus_Config2__PriceListItem__c where 
                      Apttus_Config2__PriceListId__r.Name=:PriceListName and Apttus_Config2__ChargeType__c='Standard Price'
                      and Apttus_Config2__ProductFamily__c in : productFamily order by Apttus_Config2__PriceListId__r.Name];
              }else{
                 priceList = [select CurrencyISOCode,Apttus_Config2__ProductId__r.Family,name,Apttus_Config2__ProductId__r.Apttus_Config2__ConfigurationType__c,Apttus_Config2__PriceListId__r.Name,Apttus_Config2__ProductId__c,Apttus_Config2__ProductId__r.Name,
                      Apttus_Config2__ChargeType__c,Apttus_Config2__ListPrice__c,Apttus_Config2__ProductFamily__c,
                      Apttus_Config2__ProductCode__c from Apttus_Config2__PriceListItem__c where 
                      Apttus_Config2__PriceListId__r.Name=:PriceListName and Apttus_Config2__ChargeType__c='Standard Price'
                       order by Apttus_Config2__PriceListId__r.Name]; 
              }
         }
        set<Id> parentPrdIdSet = new Set<Id>();
        set<Id> maintenancePrdIdSet = new Set<Id>();
        Map<Id,List<Apttus_Config2__PriceListItem__c>> idPriceListMap = new Map<Id,List<Apttus_Config2__PriceListItem__c>>();
        Map<Id,Id> maintenanceParentPrdIdMap = new Map<Id,Id>();
        for(Apttus_Config2__PriceListItem__c tempObj : priceList){
            parentPrdIdSet.add(tempObj.Apttus_Config2__ProductId__c);
        }
        system.debug('--------------parentPrdIdSet--------------' + parentPrdIdSet);
        for(Apttus_Config2__ProductOptionComponent__c tempObj : [select Id,Apttus_Config2__ComponentProductId__c,Apttus_Config2__ParentProductId__c from Apttus_Config2__ProductOptionComponent__c where 
                Apttus_Config2__ParentProductId__c in : parentPrdIdSet]){
            maintenanceParentPrdIdMap.put(tempObj.Apttus_Config2__ComponentProductId__c,tempObj.Apttus_Config2__ParentProductId__c );
        }
        system.debug('--------------maintenanceParentPrdIdMap--------------' + maintenanceParentPrdIdMap);
        for(Apttus_Config2__PriceListItem__c tempObj : (productFamily.size() > 0 ? 
          [select CurrencyISOCode,Apttus_Config2__ProductId__r.Family,name,Apttus_Config2__ProductId__r.Apttus_Config2__ConfigurationType__c,Apttus_Config2__PriceListId__r.Name,Apttus_Config2__ProductId__c,Apttus_Config2__ProductId__r.Name,
          Apttus_Config2__ChargeType__c,Apttus_Config2__ListPrice__c,Apttus_Config2__ProductFamily__c,
          Apttus_Config2__ProductCode__c from Apttus_Config2__PriceListItem__c where 
          Apttus_Config2__ProductFamily__c in : productFamily and  Apttus_Config2__PriceListId__r.Name=:PriceListName and Apttus_Config2__ProductId__c in : maintenanceParentPrdIdMap.keySet()]
          :
          [select CurrencyISOCode,Apttus_Config2__ProductId__r.Family,name,Apttus_Config2__ProductId__r.Apttus_Config2__ConfigurationType__c,Apttus_Config2__PriceListId__r.Name,Apttus_Config2__ProductId__c,Apttus_Config2__ProductId__r.Name,
          Apttus_Config2__ChargeType__c,Apttus_Config2__ListPrice__c,Apttus_Config2__ProductFamily__c,
          Apttus_Config2__ProductCode__c from Apttus_Config2__PriceListItem__c where 
          Apttus_Config2__PriceListId__r.Name=:PriceListName and Apttus_Config2__ProductId__c in : maintenanceParentPrdIdMap.keySet()]
          )){
            system.debug('--------------maintenanceParentPrdIdMap--------------' + maintenanceParentPrdIdMap.get(tempObj.Apttus_Config2__ProductId__c));
            if(maintenanceParentPrdIdMap.get(tempObj.Apttus_Config2__ProductId__c) != null){
                system.debug('--------------idPriceListMap--------------' + idPriceListMap.get(maintenanceParentPrdIdMap.get(tempObj.Apttus_Config2__ProductId__c)));
                if(idPriceListMap.get(maintenanceParentPrdIdMap.get(tempObj.Apttus_Config2__ProductId__c)) == null){
                   idPriceListMap.put(maintenanceParentPrdIdMap.get(tempObj.Apttus_Config2__ProductId__c), new List<Apttus_Config2__PriceListItem__c>()); 
                }
                idPriceListMap.get(maintenanceParentPrdIdMap.get(tempObj.Apttus_Config2__ProductId__c)).add(tempObj); 
            }
        }
        List<WrapperList> tempWrList = new List<WrapperList>();
        system.debug('--------------------' + setCon.getRecords());
        for(Apttus_Config2__PriceListItem__c tempObj : priceList){
            tempWrList.add(new WrapperList(tempObj,idPriceListMap.get(tempObj.Apttus_Config2__ProductId__c)));
        }
        system.debug('-------tempWrList-------------' + tempWrList);
        return tempWrList;
    }
    
    
    public List<SelectOption> getSelectViewList() {
        List<SelectOption> options = new List<SelectOption>();
        // Create the Select Options.
        options.add(new SelectOption('','--None--'));
        for (Apttus_Config2__PriceList__c ViewName : [select id,Name from Apttus_Config2__PriceList__c]) {
            options.add(new SelectOption(ViewName.Name, ViewName.Name));
        }
        
        return options;
        
    }
    // Initialize setCon and return a list of records
   
   Public Class WrapperList{
       Public Apttus_Config2__PriceListItem__c priceListItemObj {get;set;}
       Public List<Apttus_Config2__PriceListItem__c> maintenancePriceListItem {get;set;}
       public WrapperList(Apttus_Config2__PriceListItem__c tempObject,List<Apttus_Config2__PriceListItem__c> tempObjectList){
            priceListItemObj = new Apttus_Config2__PriceListItem__c();
            maintenancePriceListItem = new List<Apttus_Config2__PriceListItem__c>();
            priceListItemObj = tempObject;
            maintenancePriceListItem = tempObjectList;
       }
   }
}