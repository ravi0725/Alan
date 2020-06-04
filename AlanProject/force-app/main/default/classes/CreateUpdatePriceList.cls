/*****************************************************************************************
    Name    : CreateUpdatePriceList 
    Desc    : Used implementing the inbound to SFDC from Oracle EBS for PriceList, Pricelist Line Objects 
            This class also derive data for apttus objects like, category, category hierarchy and Product Classfication.
            
                            
Modification Log : 
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
Ashfaq Mohammed       12/23/2013          Created
******************************************************************************************/
global  class CreateUpdatePriceList {
    
    public class soapexception extends exception{}
    
    /*
    * Method name  : CreatePriceListService
    * Description  : Webserice method to load Pricelist data and Pricelist Line data from Oracle EBS to SFDC 
    * Return Type  : list
    * Parameter    : resPriceListData
    */ 
    webService static list<ResponseWraperClass> CreatePriceListService (List<requestPriceListData> resPriceListData) {
        //Variable declarations
        list<Apttus_Config2__PriceList__c> priceListList = new list<Apttus_Config2__PriceList__c>();
        list<Apttus_Config2__ProductClassification__c> prodClassification = new list<Apttus_Config2__ProductClassification__c>();
        
        list<Apttus_Config2__PriceListCategory__c> PriceListCatList = new list<Apttus_Config2__PriceListCategory__c>();
        list<Apttus_Config2__ClassificationName__c> categoryList = new list<Apttus_Config2__ClassificationName__c>();
        list<Apttus_Config2__ClassificationHierarchy__c> categoryHierList = new list<Apttus_Config2__ClassificationHierarchy__c>();
        
        
        list<Apttus_Config2__PriceListItem__c> priceListItemList = new list<Apttus_Config2__PriceListItem__c>();
        
        
        integer priceListCount,priceListItemCount;
        boolean updatePriceList = false;
        boolean updatePriceListItem = false;
        
        boolean createDerivedData = false;
        boolean blnFinalResult = false;
        boolean blnSystemException = false;
        
        
        
        Apttus_Config2__PriceList__c plVar;
        Apttus_Config2__ProductClassification__c prodClasVar;
        Apttus_Config2__PriceListCategory__c plCatVar;
        Apttus_Config2__ClassificationName__c catVar;
        Apttus_Config2__ClassificationHierarchy__c catHierVar;
        
        Apttus_Config2__PriceListItem__c plItemVar;
        
        List<list<Database.UpsertResult>> PriceListMastersrList = new List<list<Database.UpsertResult>>();
        List<list<Database.UpsertResult>> PriceListItemMastersrList = new List<list<Database.UpsertResult>>();
        
        
        Database.UpsertResult[] srListpl;
        
        ResponseWraperClass respvar;
        list<ResponseWraperClass> respvarlist = new list<ResponseWraperClass>();
        list<Apttus_Config2__PriceList__c> plist= new list<Apttus_Config2__PriceList__c>();
        list<Product2> productList = new list<product2>();
        
        //Maps
        
        //PriceList Maps
        Map<id,Apttus_Config2__PriceList__c> priceListMap = new Map<id,Apttus_Config2__PriceList__c>();
        Map<string,Apttus_Config2__PriceList__c> insertPriceListMap = new Map<string,Apttus_Config2__PriceList__c>();        
        set<id> priceListSet = new set<id>(); 
        
        
        
        try{
            plist.clear();
            productList.clear();
            Set<integer> PLOracleIDSet = new Set<integer>();
            //loop to fill the PLOracleIDSet set with LIST_HEADER_ID
            for(requestPriceListData reqPriceListVar :resPriceListData ){
                if(reqPriceListVar.RECORD_TYPE_IDENTIFIER!=null && reqPriceListVar.RECORD_TYPE_IDENTIFIER=='H') {
                    PLOracleIDSet.add(reqPriceListVar.LIST_HEADER_ID);
                    
                }
            }
            
            map<integer,Apttus_Config2__PriceList__c> pLMap = new map<integer,Apttus_Config2__PriceList__c>();
            //loop to fill the pLMap with oracle id from pricelist  
            for(Apttus_Config2__PriceList__c plm : [Select Id, Name,CurrencyIsoCode,Apttus_Config2__Active__c,Apttus_Config2__BasedOnAdjustmentAmount__c,Apttus_Config2__BasedOnAdjustmentType__c,Apttus_Config2__BasedOnPriceListId__c,Apttus_Config2__ContractNumber__c,Apttus_Config2__Description__c,Division__c,Apttus_Config2__EffectiveDate__c,Apttus_Config2__ExpirationDate__c,Apttus_Config2__GuidePage__c,Oracle_ID__c,Region__c  FROM Apttus_Config2__PriceList__c WHERE Oracle_ID__c IN :PLOracleIDSet] ){
                pLMap.put(integer.valueof(plm.Oracle_ID__c),plm);
            }
            map<integer,Apttus_Config2__ClassificationName__c> pLcMap = new map<integer,Apttus_Config2__ClassificationName__c>();
            
            for(Apttus_Config2__ClassificationName__c accn : [Select ID, Name,Apttus_Config2__HierarchyLabel__c,Oracle_ID__c from Apttus_Config2__ClassificationName__c where Oracle_ID__c IN:PLOracleIDSet ] ){
                pLcMap.put(integer.valueof(accn.Oracle_ID__c), accn );
            } 
            //For loop to loop through all the data recieved from Oracle in resPriceListData
            for(requestPriceListData reqPriceListVar :resPriceListData ){
                
                //If condition to get only header values for priceList processing 
                if(reqPriceListVar.RECORD_TYPE_IDENTIFIER!=null && reqPriceListVar.RECORD_TYPE_IDENTIFIER=='H'){
                    
                    //Checks the values in PLMap if exist then update in the if statement else creates new pricelist in else statement
                    if(reqPriceListVar.LIST_HEADER_ID!=null && pLMap.get(reqPriceListVar.LIST_HEADER_ID)!=null){
                        plVar = pLMap.get(reqPriceListVar.LIST_HEADER_ID);
                        plvar.Name = reqPriceListVar.NAME;
                        plvar.Apttus_Config2__Description__c = reqPriceListVar.DESCRIPTION;
                        plvar.CurrencyIsoCode = reqPriceListVar.CURRENCY_CODE;
                        plvar.Business_Area__c = reqPriceListVar.HEADER_ATTRIBUTE1;
                        plvar.Organization__c = reqPriceListVar.HEADER_ATTRIBUTE2;
                        plvar.Apttus_Config2__Active__c = (reqPriceListVar.ACTIVE_FLAG!=null && reqPriceListVar.ACTIVE_FLAG!='')?(reqPriceListVar.ACTIVE_FLAG.equalsIgnoreCase('Y')?true:false):false;
                        plvar.Apttus_Config2__EffectiveDate__c = DateTime.newinstance(reqPriceListVar.START_DATE_ACTIVE.year(),reqPriceListVar.START_DATE_ACTIVE.month(),reqPriceListVar.START_DATE_ACTIVE.day(),00,00,00);
                        if(reqPriceListVar.END_DATE_ACTIVE!= Null) plvar.Apttus_Config2__ExpirationDate__c = DateTime.newinstance(reqPriceListVar.END_DATE_ACTIVE.year(),reqPriceListVar.END_DATE_ACTIVE.month(),reqPriceListVar.END_DATE_ACTIVE.day(),23,59,00);
                        priceListList.add(plvar);
                        
                        if(reqPriceListVar.LIST_HEADER_ID != null && pLcMap.get(reqPriceListVar.LIST_HEADER_ID)!=null){
                            catVar = pLcMap.get(reqPriceListVar.LIST_HEADER_ID);
                            catVar.Name = reqPriceListVar.NAME;
                            catVar.Apttus_Config2__HierarchyLabel__c = reqPriceListVar.NAME;
                            categoryList.add(catVar); 
                        }
                        createDerivedData = true;
                    }
                    else{
                        
                        plVar = new Apttus_Config2__PriceList__c(); 
                        
                        plvar.Oracle_ID__c = reqPriceListVar.LIST_HEADER_ID;
                        plvar.Name = reqPriceListVar.NAME;
                        plvar.Apttus_Config2__Description__c = reqPriceListVar.DESCRIPTION;
                        plvar.CurrencyIsoCode = reqPriceListVar.CURRENCY_CODE;
                        plvar.Business_Area__c = reqPriceListVar.HEADER_ATTRIBUTE1;
                        plvar.Organization__c = reqPriceListVar.HEADER_ATTRIBUTE2;
                        plvar.Apttus_Config2__Active__c = (reqPriceListVar.ACTIVE_FLAG!=null && reqPriceListVar.ACTIVE_FLAG!='')?(reqPriceListVar.ACTIVE_FLAG.equalsIgnoreCase('Y')?true:false):false;
                        plvar.Apttus_Config2__EffectiveDate__c = DateTime.newinstance(reqPriceListVar.START_DATE_ACTIVE.year(),reqPriceListVar.START_DATE_ACTIVE.month(),reqPriceListVar.START_DATE_ACTIVE.day(),00,00,00);
                        if(reqPriceListVar.END_DATE_ACTIVE!= Null) plvar.Apttus_Config2__ExpirationDate__c = DateTime.newinstance(reqPriceListVar.END_DATE_ACTIVE.year(),reqPriceListVar.END_DATE_ACTIVE.month(),reqPriceListVar.END_DATE_ACTIVE.day(),23,59,00);
                        priceListList.add(plvar);
                        
                        //Category
                        //Create a new cateagory entry used for Apttus along with Pricelist 
                        catVar = new Apttus_Config2__ClassificationName__c();
                        catVar.Oracle_ID__c = reqPriceListVar.LIST_HEADER_ID;
                        catVar.Name = reqPriceListVar.NAME;
                        catVar.Apttus_Config2__HierarchyLabel__c = reqPriceListVar.NAME;
                        catVar.Apttus_Config2__Active__c = true;
                        catVar.Apttus_Config2__Type__c = 'Offering';
                        
                        categoryList.add(catVar);   
                        createDerivedData = true;
                        
                        
                    }

                    
                    
                }
                
                
                
            }
            
            //To upsert data in Apttus_Config2__PriceList__c object for Price List
            if(priceListList!=null && priceListList.size()>0){
                Database.UpsertResult[] srListPriceList;
                srListPriceList = Database.Upsert(priceListList,Apttus_Config2__PriceList__c.Fields.Id,false);
                
                PriceListMastersrList.add(srListPriceList);
            }
            
            //To upsert data in Apttus_Config2__ClassificationName__c object for category
            //Upserting Derived tables starts -   Category 
            
            if(categoryList!=null && categoryList.size()>0 ){
                Database.UpsertResult[] srListCategoryList;
                srListCategoryList = Database.Upsert(categoryList,Apttus_Config2__ClassificationName__c.Fields.Id,false);
                
                //MastersrList.add(srListCategoryList);
                
            }
            //Upserting Derived tables Ends -   Category 
            
            set<string> priceListNameSet = new set<string>();
            for(requestPriceListData reqPriceListVar :resPriceListData ){
                priceListNameSet.add(reqPriceListVar.NAME);
                
            }
            if(createDerivedData)  {
                
                plist.clear();
                productList.clear();
                
                //Pricelist Map
                map<string,ID> PriceListNameIDMap = new map<string,ID>();
                for(Apttus_Config2__PriceList__c PLNIM : [Select ID, Name from Apttus_Config2__PriceList__c where Name IN :priceListNameSet]){
                    PriceListNameIDMap.put(PLNIM.Name,PLNIM.ID);
                }
                
                //Category Map
                map<string,ID> CatNameIDMap = new map<string,ID>();
                
                for(Apttus_Config2__ClassificationName__c CNIM : [Select ID, Name,Oracle_ID__c from Apttus_Config2__ClassificationName__c where Name IN:priceListNameSet]){
                    CatNameIDMap.put(CNIM.Name,CNIM.ID);
                    
                }
                //Category Hierarchy exist map
                map<string,Apttus_Config2__ClassificationHierarchy__c> CateHExistMap = new map<string,Apttus_Config2__ClassificationHierarchy__c>();
                for (Apttus_Config2__ClassificationHierarchy__c cheM : [Select ID, Name,Apttus_Config2__IncludeInTotalsView__c,Apttus_Config2__HideAllSearchFilters__c,Apttus_Config2__DefaultSearchCategory__c,Apttus_Config2__ExpandedByDefault__c,Apttus_Config2__Label__c,Apttus_Config2__HierarchyId__c,Apttus_Config2__Level__c,Apttus_Config2__Left__c,Apttus_Config2__Right__c FROM Apttus_Config2__ClassificationHierarchy__c WHERE Name IN :priceListNameSet and Apttus_Config2__Level__c = 0]){
                    CateHExistMap.put(cheM.Name,cheM);
                }
                
                //Pricelist Category Map
                map<ID,Apttus_Config2__PriceListCategory__c> PriceListCategoryMap = new map<ID,Apttus_Config2__PriceListCategory__c>();
                for(Apttus_Config2__PriceListCategory__c PLCM : [Select ID, Name, Apttus_Config2__PriceListId__c, Apttus_Config2__HierarchyId__c from Apttus_Config2__PriceListCategory__c Where Apttus_Config2__PriceListId__c IN : PriceListNameIDMap.values()]){
                    PriceListCategoryMap.put(PLCM.Apttus_Config2__PriceListId__c ,PLCM);
                }
                
                for(requestPriceListData reqPriceListVar :resPriceListData ){
                    
                    
                    if(reqPriceListVar.RECORD_TYPE_IDENTIFIER!=null && reqPriceListVar.RECORD_TYPE_IDENTIFIER=='H'){
                        
                        if(reqPriceListVar.NAME!=null && PriceListNameIDMap.get(reqPriceListVar.NAME)!=null){
                            ID priceListID = PriceListNameIDMap.get(reqPriceListVar.NAME);
                            ID categoryID = CatNameIDMap.get(reqPriceListVar.NAME);
                            
                            //PriceList Category
                            //Create a new PriceList category entry  
                            if(PriceListCategoryMap.get(priceListID)==null){
                                plCatVar = new Apttus_Config2__PriceListCategory__c();
                                
                                plCatVar.Apttus_Config2__PriceListId__c  = priceListID;
                                plCatVar.Apttus_Config2__HierarchyId__c = categoryID; 
                                PriceListCatList.add(plCatVar);
                            }
                            
                            
                            //Category Hierarchy
                            //Check the existing category hierarchy if exists then category hierarchy will be updated else new category will be created
                            if(CateHExistMap.get(reqPriceListVar.NAME)!=null){
                                catHierVar = CateHExistMap.get(reqPriceListVar.NAME);
                                catHierVar.Name = reqPriceListVar.NAME;
                                catHierVar.Apttus_Config2__Label__c = reqPriceListVar.NAME;
                                catHierVar.Apttus_Config2__Level__c = 0;
                                catHiervar.Apttus_Config2__Left__c = 1;
                                catHierVar.Apttus_Config2__Right__c = 2;
                                cathierVar.Apttus_Config2__IncludeInTotalsView__c = false;
                                cathierVar.Apttus_Config2__HideAllSearchFilters__c = true;
                                cathierVar.Apttus_Config2__DefaultSearchCategory__c = true;
                                cathierVar.Apttus_Config2__ExpandedByDefault__c = true;
                                categoryHierList.add(catHierVar);
                            }else{
                                
                                catHierVar = new Apttus_Config2__ClassificationHierarchy__c();
                                catHierVar.Name = reqPriceListVar.NAME;
                                catHierVar.Apttus_Config2__Label__c = reqPriceListVar.NAME;
                                catHierVar.Apttus_Config2__HierarchyId__c  = categoryID;
                                catHierVar.Apttus_Config2__Level__c = 0;
                                catHiervar.Apttus_Config2__Left__c = 1;
                                catHierVar.Apttus_Config2__Right__c = 2;
                                cathierVar.Apttus_Config2__IncludeInTotalsView__c = false;
                                cathierVar.Apttus_Config2__HideAllSearchFilters__c = true;
                                cathierVar.Apttus_Config2__DefaultSearchCategory__c = true;
                                cathierVar.Apttus_Config2__ExpandedByDefault__c = true;
                                categoryHierList.add(catHierVar);
                                
                            }
                            
                            
                        }
                        
                    }
                    
                }
            }
            
            //Upserting Derived tables starts -  PriceList Category  , category Hierarchy 
            //To upsert data in Apttus_Config2__PriceListCategory__c object 
            if(PriceListCatList!=null && PriceListCatList.size()>0 ){
                Database.UpsertResult[] srListPriceListCatList;
                srListPriceListCatList = Database.Upsert(PriceListCatList,Apttus_Config2__PriceListCategory__c.Fields.Id,false);
                
                //MastersrList.add(srListPriceListCatList);
                
            }
            //To upsert data in Apttus_Config2__ClassificationHierarchy__c object 
            if(categoryHierList!=null && categoryHierList.size()>0 ){
                Database.UpsertResult[] srListcategoryHierList;
                srListcategoryHierList = Database.Upsert(categoryHierList,Apttus_Config2__ClassificationHierarchy__c.Fields.Id,false);
                
                //MastersrList.add(srListcategoryHierList);
                
            }
            
            
            //Upserting Derived tables Ends - PriceList Category , category Hierarchy 
            plist.clear();
            productList.clear();
            priceListItemList.clear();
            
            //Declaring maps and sets for pricelist item 
            map<integer,Apttus_Config2__PriceListItem__c> pListItemMap = new Map<integer,Apttus_Config2__PriceListItem__c>();
            Set<integer> OracleIDSet = new Set<integer>();
            Set<string> OracleIDSet_str = new Set<string>();
            Set<integer> OracleListLineIDSet = new Set<integer>();
            //filling the data in sets for Line item which are identified by L
            for(requestPriceListData reqPriceListVar :resPriceListData ){
                if(reqPriceListVar.RECORD_TYPE_IDENTIFIER!=null && reqPriceListVar.RECORD_TYPE_IDENTIFIER=='L') {
                    OracleIDSet.add(reqPriceListVar.LIST_HEADER_ID);
                    OracleIDSet_str.add(reqPriceListVar.PRODUCT_ATTR_VALUE);
                    OracleListLineIDSet.add(reqPriceListVar.LIST_LINE_ID);
                }
                
                
            }
            Set<ID> ProdIDSet = new Set<ID>();
            map<string,ID> pID_oID_Map = new map<string,ID>();
            map<string,string> Contract_Item_Type_Code_Map = new  map<string,string>();
            
            //filling data in product set and product map
            for(product2 p : [select ID,Oracle_ID__c,Type__c,sub_type__c,Contract_Item_Type_Code__c from product2 where Oracle_ID__c IN :OracleIDSet_str]){
                ProdIDSet.add(p.id);
                pID_oID_Map.put(p.Oracle_ID__c,p.ID);
                Contract_Item_Type_Code_Map.put(p.Oracle_ID__c,p.Contract_Item_Type_Code__c);
                
            }
            
            //to get pricelistID in ePriceListIDSet
            set<ID> ePriceListIDSet = new set<ID>();
            for(Apttus_Config2__PriceList__c plm : [Select Id, Name,CurrencyIsoCode,Apttus_Config2__Active__c,Apttus_Config2__BasedOnAdjustmentAmount__c,Apttus_Config2__BasedOnAdjustmentType__c,Apttus_Config2__BasedOnPriceListId__c,Apttus_Config2__ContractNumber__c,Apttus_Config2__Description__c,Division__c,Apttus_Config2__EffectiveDate__c,Apttus_Config2__ExpirationDate__c,Apttus_Config2__GuidePage__c,Oracle_ID__c,Region__c  FROM Apttus_Config2__PriceList__c WHERE Oracle_ID__c IN :PLOracleIDSet] ){
                
                ePriceListIDSet.add(plm.id);
            }
            map<id,id> pListItemProdMap = new map<id,id>();
            
            for(Apttus_Config2__PriceListItem__c pli_var:[Select Id, Name,Oracle_List_Line_ID__c,CurrencyIsoCode, Apttus_Config2__EffectiveDate__c, Apttus_Config2__ExpirationDate__c,Apttus_Config2__ProductId__c, Apttus_Config2__PriceUom__c,Apttus_Config2__ListPrice__c,Apttus_Config2__ChargeType__c,Apttus_Config2__ProductId__r.Oracle_ID__c,Apttus_Config2__PriceListId__c  FROM Apttus_Config2__PriceListItem__c WHERE Oracle_List_Line_ID__c IN : OracleListLineIDSet ]){
                pListItemMap.put(integer.valueof(pli_var.Oracle_List_Line_ID__c), pli_var);
                pListItemProdMap.put(pli_var.Apttus_Config2__ProductId__c,pli_var.Apttus_Config2__PriceListId__c );
            }
            
            
            
            Map<integer,ID> pListID = new  Map<integer,ID>();
            for(Apttus_Config2__PriceList__c pl :[Select ID,Oracle_ID__c from  Apttus_Config2__PriceList__c where Oracle_ID__c IN :OracleIDSet ] ){
                pListID.put(integer.valueof(pl.Oracle_ID__c),pl.ID);
            }
            
            for(requestPriceListData reqPriceListVar :resPriceListData ){
                
                updatePriceListItem = false;
                if(reqPriceListVar.RECORD_TYPE_IDENTIFIER!=null && reqPriceListVar.RECORD_TYPE_IDENTIFIER=='L') {
                    //Check if the pricelist line exists, if exist update the pricelist line else create a new pricelist line item
                    if(reqPriceListVar.LIST_LINE_ID!=null && pListItemMap.get(reqPriceListVar.LIST_LINE_ID)!=null ){
                        plItemVar = pListItemMap.get(reqPriceListVar.LIST_LINE_ID);
                        
                        plItemVar.Apttus_Config2__EffectiveDate__c = DateTime.newinstance(reqPriceListVar.START_DATE_ACTIVE.year(),reqPriceListVar.START_DATE_ACTIVE.month(),reqPriceListVar.START_DATE_ACTIVE.day(),00,00,00);
                        if(reqPriceListVar.END_DATE_ACTIVE!= Null) plItemVar.Apttus_Config2__ExpirationDate__c = DateTime.newinstance(reqPriceListVar.END_DATE_ACTIVE.year(),reqPriceListVar.END_DATE_ACTIVE.month(),reqPriceListVar.END_DATE_ACTIVE.day(),23,59,00);
                        plItemVar.Apttus_Config2__PriceUom__c = reqPriceListVar.PRODUCT_UOM_CODE;
                        plItemVar.Apttus_Config2__ListPrice__c = reqPriceListVar.OPERAND;
                        plItemVar.Apttus_Config2__Active__c = true;
                        if(reqPriceListVar.PRODUCT_ATTR_VALUE!=null  ){
                            if(Contract_Item_Type_Code_Map.get(reqPriceListVar.PRODUCT_ATTR_VALUE)!=null && Contract_Item_Type_Code_Map.get(reqPriceListVar.PRODUCT_ATTR_VALUE)== 'WARRANTY' || Contract_Item_Type_Code_Map.get(reqPriceListVar.PRODUCT_ATTR_VALUE)=='SERVICE' ){
                                plItemVar.Apttus_Config2__ChargeType__c = 'Maintenance Fee';
                                plItemVar.Apttus_Config2__PriceIncludedInBundle__c = false;
                            }else{
                                plItemVar.Apttus_Config2__ChargeType__c = 'Standard Price';
                                plItemVar.Apttus_Config2__PriceIncludedInBundle__c = true;
                            }
                            
                        }
                        
                        if(reqPriceListVar.PRODUCT_ATTR_VALUE!=null && pID_oID_Map.get(reqPriceListVar.PRODUCT_ATTR_VALUE)!=null){
                            plItemVar.Apttus_Config2__ProductId__c =pID_oID_Map.get(reqPriceListVar.PRODUCT_ATTR_VALUE);
                        }
                        if(plItemVar.Apttus_Config2__ProductId__c ==null){
                            blnFinalResult = true;
                            respvar = new ResponseWraperClass();
                            //respvar.result ='Failure .'+ err.getStatusCode() + ': ' + err.getMessage()+': '+sr.getid(); 
                            
                            respvar.result ='Failure';   
                            respvar.Errorcode = 'PLITEM-ERROR-4021';
                            respvar.ErrorMessage = 'Product is missing for this pricelist Item to process ';   
                            respvar.TransactionNameAndValue = 'PriceList:' + string.valueof(reqPriceListVar.LIST_HEADER_ID) + ' '+ string.valueof(reqPriceListVar.LIST_LINE_ID);
                            respvar.RECORD_TYPE_IDENTIFIER = 'L';
                            respvar.LIST_HEADER_ID=string.valueof(reqPriceListVar.LIST_HEADER_ID);  
                            respvar.LIST_LINE_ID = string.valueof(reqPriceListVar.LIST_LINE_ID);            
                            //respvar.SFDC_NUMBER = sr.getid();  
                            respvarlist.add(respvar);
                            
                            
                            
                        }else{
                            priceListItemList.add(plItemVar);
                            system.debug('priceListItemList -Update'+priceListItemList);
                            
                            
                        }
                        
                        
                    }
                    else{
                        
                        plItemVar = new Apttus_Config2__PriceListItem__c();
                        if(reqPriceListVar.LIST_HEADER_ID!=null && pListID.get(reqPriceListVar.LIST_HEADER_ID)!=null){
                            plItemVar.Apttus_Config2__PriceListId__c  = pListID.get(reqPriceListVar.LIST_HEADER_ID);
                            if(reqPriceListVar.PRODUCT_ATTR_VALUE!=null && pID_oID_Map.get(reqPriceListVar.PRODUCT_ATTR_VALUE)!=null){
                                plItemVar.Apttus_Config2__ProductId__c =pID_oID_Map.get(reqPriceListVar.PRODUCT_ATTR_VALUE);
                                
                            }
                            
                            if(reqPriceListVar.PRODUCT_ATTR_VALUE!=null && pID_oID_Map.get(reqPriceListVar.PRODUCT_ATTR_VALUE)!=null){
                                plItemVar.Apttus_Config2__ProductId__c =pID_oID_Map.get(reqPriceListVar.PRODUCT_ATTR_VALUE);
                            }
                            
                            if(reqPriceListVar.PRODUCT_ATTR_VALUE!=null  ){
                                if(Contract_Item_Type_Code_Map.get(reqPriceListVar.PRODUCT_ATTR_VALUE)!=null && Contract_Item_Type_Code_Map.get(reqPriceListVar.PRODUCT_ATTR_VALUE)== 'WARRANTY' || Contract_Item_Type_Code_Map.get(reqPriceListVar.PRODUCT_ATTR_VALUE)=='SERVICE' ){
                                    plItemVar.Apttus_Config2__ChargeType__c = 'Maintenance Fee';
                                    plItemVar.Apttus_Config2__PriceIncludedInBundle__c = false;
                                }else{
                                    plItemVar.Apttus_Config2__ChargeType__c = 'Standard Price';
                                    plItemVar.Apttus_Config2__PriceIncludedInBundle__c = true;
                                }
                                
                            }
                            
                            
                            plItemVar.Oracle_List_Line_ID__c = reqPriceListVar.LIST_LINE_ID;
                            plItemVar.Apttus_Config2__EffectiveDate__c = DateTime.newinstance(reqPriceListVar.START_DATE_ACTIVE.year(),reqPriceListVar.START_DATE_ACTIVE.month(),reqPriceListVar.START_DATE_ACTIVE.day(),00,00,00);
                            if(reqPriceListVar.END_DATE_ACTIVE!= Null) plItemVar.Apttus_Config2__ExpirationDate__c = DateTime.newinstance(reqPriceListVar.END_DATE_ACTIVE.year(),reqPriceListVar.END_DATE_ACTIVE.month(),reqPriceListVar.END_DATE_ACTIVE.day(),23,59,00);
                            plItemVar.Apttus_Config2__PriceUom__c = reqPriceListVar.PRODUCT_UOM_CODE;
                            plItemVar.Apttus_Config2__ListPrice__c = reqPriceListVar.OPERAND;
                            plItemVar.Apttus_Config2__Active__c = true;
                            
                            
                            system.debug('Product Id==>' + plItemVar.Apttus_Config2__ProductId__c);
                            if(plItemVar.Apttus_Config2__ProductId__c ==null){
                                blnFinalResult = true;
                                respvar = new ResponseWraperClass();
                                //respvar.result ='Failure .'+ err.getStatusCode() + ': ' + err.getMessage()+': '+sr.getid(); 
                                
                                respvar.result ='Failure';   
                                respvar.Errorcode = 'PLITEM-ERROR-4021';
                                respvar.ErrorMessage = 'Product is missing for this pricelist Item to process ';   
                                respvar.TransactionNameAndValue = 'PriceList:' + string.valueof(reqPriceListVar.LIST_HEADER_ID) + ' '+ string.valueof(reqPriceListVar.LIST_LINE_ID);
                                respvar.RECORD_TYPE_IDENTIFIER = 'L';
                                respvar.LIST_HEADER_ID=string.valueof(reqPriceListVar.LIST_HEADER_ID);  
                                respvar.LIST_LINE_ID = string.valueof(reqPriceListVar.LIST_LINE_ID);            
                                //respvar.SFDC_NUMBER = sr.getid();  
                                respvarlist.add(respvar);
                                
                                
                                
                            }else{
                                priceListItemList.add(plItemVar);
                                system.debug('priceListItemList -Create'+priceListItemList);
                                
                                
                            }
                            
                            
                        }else
                        {
                            blnFinalResult = true;
                            respvar = new ResponseWraperClass();
                            //respvar.result ='Failure .'+ err.getStatusCode() + ': ' + err.getMessage()+': '+sr.getid(); 
                            
                            respvar.result ='Failure';   
                            respvar.Errorcode = 'PLITEM-ERROR-4021';
                            respvar.ErrorMessage = 'Pricelist data is missing for this pricelist Item to process ';   
                            respvar.TransactionNameAndValue = 'PriceList:' + string.valueof(reqPriceListVar.LIST_HEADER_ID) + ' '+ string.valueof(reqPriceListVar.LIST_LINE_ID);
                            respvar.RECORD_TYPE_IDENTIFIER = 'L';
                            respvar.LIST_HEADER_ID=string.valueof(reqPriceListVar.LIST_HEADER_ID);  
                            respvar.LIST_LINE_ID = string.valueof(reqPriceListVar.LIST_LINE_ID);            
                            //respvar.SFDC_NUMBER = sr.getid();  
                            respvarlist.add(respvar);
                            
                            
                            
                            
                        }
                        
                    }
                    
                }
            }
            
            
            //To upsert data in Apttus_Config2__PriceListItem__c object 
            if(priceListItemList!=null && priceListItemList.size()>0){
                Database.UpsertResult[] srPriceListItem;
                srPriceListItem = Database.Upsert(priceListItemList,Apttus_Config2__PriceListItem__c.Fields.Id,false);
                
                PriceListItemMastersrList.add(srPriceListItem);
            }
            
            
            
            //Category Hierarchy for type
            plist.clear();
            productList.clear();
            categoryHierList.clear();
            integer leftL2 = 2;
            
            //Declaring sets and assigning data to sets    
            set<integer> lstHdrID = new set<integer>();
            for(requestPriceListData reqPriceListVar :resPriceListData ){
                if(reqPriceListVar.RECORD_TYPE_IDENTIFIER!=null && reqPriceListVar.RECORD_TYPE_IDENTIFIER=='L') {
                    lstHdrID.add(reqPriceListVar.LIST_HEADER_ID);
                    
                }
            }
            for(integer LHID :lstHdrID ){
                set<string> prodAttrValSet = new set<string>();
                for(requestPriceListData reqPriceListVar :resPriceListData ){
                    if(reqPriceListVar.PRODUCT_ATTR_VALUE !=null && reqPriceListVar.LIST_HEADER_ID ==LHID ){
                        prodAttrValSet.add(reqPriceListVar.PRODUCT_ATTR_VALUE);
                    }
                    
                }
                set<string> prodTypeSet = new set<string>();
                set<string> prodSubTypeSet = new set<string>();
                for(product2 pt : [Select ID,Type__c,Oracle_ID__c,sub_type__c from product2 where Oracle_ID__c IN :prodAttrValSet] ){
                    prodTypeSet.add(pt.Type__c);
                    
                    prodSubTypeSet.add(pt.sub_type__c);
                    
                }
                
                
                //Declaring maps and assigning data to maps                 
                map<string,String> prodID_Type_Map = new map<string,string>();
                map<string,String> prodID_Type_Map1 = new map<string,string>();
                set<string> tSet = new set<string>();
                
                for(product2 pType : [Select ID, Type__c ,sub_type__c,Oracle_ID__c from product2 where Type__c IN :prodTypeSet and Oracle_ID__c IN :prodAttrValSet]){
                    
                    if(tSet.add(pType.Type__c)){
                        prodID_Type_Map.put(pType.Oracle_ID__c,pType.Type__c);
                    }
                    prodID_Type_Map1.put(pType.Oracle_ID__c,pType.Type__c);
                    
                }
                
                set<string> stSet = new set<string>();
                map<string,String> prodID_Sub_Type_Map = new map<string,string>();
                for(product2 pType : [Select ID, Type__c ,sub_type__c,Oracle_ID__c from product2 where sub_type__c IN :prodSubTypeSet and Oracle_ID__c IN :prodAttrValSet]){
                    
                    if(stSet.add(pType.sub_type__c)){
                        prodID_Sub_Type_Map.put(pType.Oracle_ID__c,pType.sub_type__c);
                    }
                    
                }
                system.debug('prodID_Sub_Type_Map==>'+prodID_Sub_Type_Map);
                
                
                set<string> catHierNameSet = new set<string>();
                
                map<integer,string> catHierNameMap = new map<integer,string>();
                map<string,ID> PrimodalIDMap = new map<string,ID>();
                for(Apttus_Config2__PriceList__c acpl : [Select ID,Oracle_ID__c,Name from Apttus_Config2__PriceList__c where Oracle_ID__c =: LHID]) {
                    catHierNameMap.put(integer.valueof(acpl.Oracle_ID__c),acpl.Name);
                    catHierNameSet.add(acpl.Name);
                    PrimodalIDMap.put(acpl.Name,acpl.ID);
                    
                }
                Map<string,Apttus_Config2__ClassificationHierarchy__c> apCHMap= new Map<string,Apttus_Config2__ClassificationHierarchy__c>();
                Map<ID,String> catHexistMap = new Map<ID,String>();
                
                for(Apttus_Config2__ClassificationHierarchy__c apch : [Select ID, Name,Apttus_Config2__Label__c,Apttus_Config2__PrimordialId__c,Apttus_Config2__HierarchyId__c,Apttus_Config2__AncestorId__c,Apttus_Config2__Level__c from  Apttus_Config2__ClassificationHierarchy__c where Name IN :catHierNameSet] ){
                    apCHMap.put(apch.Name,apch );
                    catHexistMap.put(apch.Apttus_Config2__HierarchyId__c,apch.Name);
                }
                
                set<ID> pimIDSet = new set<ID>();
                map<string,ID> PrimordialIDMap = new map<string,ID>();
                for(Apttus_Config2__ClassificationHierarchy__c PIM : [Select ID, Name,Apttus_Config2__Level__c from Apttus_Config2__ClassificationHierarchy__c WHERE Name IN :catHierNameSet and Apttus_Config2__Level__c = 0]){
                    PrimordialIDMap.put(PIM.Name,PIM.ID);
                    pimIDSet.add(PIM.ID);
                }
                system.debug('PrimordialIDMap'+PrimordialIDMap);
                system.debug('pimIDSet'+pimIDSet);
                map<string,ID> categoryIDMap = new map<string,ID>();
                for(Apttus_Config2__ClassificationName__c CIM : [Select ID, Name,Oracle_ID__c from Apttus_Config2__ClassificationName__c Where Name IN :catHierNameSet]){
                    categoryIDMap.put(CIM.Name,CIM.ID);             
                }
                
                
                
                
                map<string,ID> catHierTypeExistMap = new map<string,ID>();
                for(Apttus_Config2__ClassificationHierarchy__c chte : [Select ID,Apttus_Config2__PrimordialId__c, Name,Apttus_Config2__Level__c From Apttus_Config2__ClassificationHierarchy__c where Name IN:tSet and Apttus_Config2__PrimordialId__c IN:pimIDSet and Apttus_Config2__Level__c = 1])   {
                    catHierTypeExistMap.put(chte.Name,chte.id);
                }
                
                
                for(requestPriceListData reqPriceListVar :resPriceListData ){
                    if(reqPriceListVar.RECORD_TYPE_IDENTIFIER!=null && reqPriceListVar.RECORD_TYPE_IDENTIFIER=='L') {
                        
                        //Category Hierarchy
                        
                        
                        string product_type =null;
                        integer catHexistCount;
                        
                        string catHierName;
                        if(reqPriceListVar.LIST_HEADER_ID!=null && catHierNameMap.get(reqPriceListVar.LIST_HEADER_ID)!=null){
                            catHierName = catHierNameMap.get(reqPriceListVar.LIST_HEADER_ID);
                            
                            
                        }
                        
                        //assigning Primordialid 
                        ID PrimordialID=null;
                        if(PrimordialIDMap.get(catHierName)!=null ){
                            PrimordialID = PrimordialIDMap.get(catHierName);
                        }
                        
                        //assigning CategoryID
                        ID category_ID=null;
                        if(categoryIDMap.get(catHierName)!=null){
                            category_ID = categoryIDMap.get(catHierName);
                        }
                        
                        
                        //assigning Product Type
                        if(prodID_Type_Map.get(reqPriceListVar.PRODUCT_ATTR_VALUE)!=null){
                            product_type = prodID_Type_Map.get(reqPriceListVar.PRODUCT_ATTR_VALUE);
                        }
                        if(catHierTypeExistMap.get(product_type)==null ){
                            //create new category Hierarchy for product types 
                            if(product_type!=null && PrimordialID!=null && category_ID!=null  ){
                                
                                //Category Hierarchy
                                catHierVar = new Apttus_Config2__ClassificationHierarchy__c();
                                catHierVar.Name = product_type;
                                catHierVar.Apttus_Config2__Label__c = product_type;
                                catHierVar.Apttus_Config2__PrimordialId__c = PrimordialID;
                                catHierVar.Apttus_Config2__HierarchyId__c  = category_ID;
                                catHierVar.Apttus_Config2__AncestorId__c = PrimordialID;
                                catHierVar.Apttus_Config2__Level__c = 1;
                                catHierVar.Apttus_Config2__IncludeInTotalsView__c = false;
                                catHierVar.Apttus_Config2__HideAllSearchFilters__c = true;
                                catHierVar.Apttus_Config2__DefaultSearchCategory__c = true;
                                catHierVar.Apttus_Config2__ExpandedByDefault__c = false;
                                
                                categoryHierList.add(catHierVar);
                                
                                
                            }
                            
                            
                        }
                    }
                    
                    
                    
                }
                
                //To upsert data in Apttus_Config2__ClassificationHierarchy__c object
                if(categoryHierList!=null && categoryHierList.size()>0 ){
                    Database.UpsertResult[] srListcategoryHierList;
                    srListcategoryHierList = Database.Upsert(categoryHierList,Apttus_Config2__ClassificationHierarchy__c.Fields.Id,false);
                    
                    //MastersrList.add(srListcategoryHierList);
                    
                }
                
                //Category Hierarchy for sub type
                //Creating Category Hierarchy for sub types which is used for Apttus object Apttus_Config2__ClassificationHierarchy__c
                plist.clear();
                productList.clear();
                categoryHierList.clear();
                
                //Declaring sets for primodal id and category hierarchy name
                set<ID> PriIDSet = new set<ID>();
                set<string> catHierNameSet1 = new set<string>();
                
                //Map for category hierarchy name   
                map<integer,string> catHierNameMap1 = new map<integer,string>();
                for(Apttus_Config2__PriceList__c acpl : [Select ID,Oracle_ID__c,Name from Apttus_Config2__PriceList__c where Oracle_ID__c =:LHID]) {
                    catHierNameMap1.put(integer.valueof(acpl.Oracle_ID__c),acpl.Name);
                    catHierNameSet1.add(acpl.Name);
                    
                }
                system.debug('catHierNameSet1'+catHierNameSet1);
                
                //map for primodalid 
                map<string,ID> PrimordialIDMap1 = new map<string,ID>();
                
                for(Apttus_Config2__ClassificationHierarchy__c PIM : [Select ID, Name,Apttus_Config2__Level__c from Apttus_Config2__ClassificationHierarchy__c WHERE Name IN :catHierNameSet1 and Apttus_Config2__Level__c = 0]){
                    PrimordialIDMap1.put(PIM.Name,PIM.ID);
                    PriIDSet.add(PIM.ID);
                }
                
                
                //map for category hierarchy   
                map<string,ID> categoryIDMap1 = new map<string,ID>();
                for(Apttus_Config2__ClassificationName__c CIM : [Select ID, Name,Oracle_ID__c from Apttus_Config2__ClassificationName__c Where Name IN :catHierNameSet1]){
                    categoryIDMap1.put(CIM.Name,CIM.ID);                
                }
                
                //map for existing category hierarchy for subtypes
                map<string,ID> catHierSubTypeExistMap = new map<string,ID>();
                for(Apttus_Config2__ClassificationHierarchy__c chte : [Select ID,Apttus_Config2__PrimordialId__c, Name,Apttus_Config2__Level__c From Apttus_Config2__ClassificationHierarchy__c where Name IN:stSet and Apttus_Config2__PrimordialId__c IN:pimIDSet and Apttus_Config2__Level__c = 2])   {
                    catHierSubTypeExistMap.put(chte.Name,chte.id);
                }
                
                //map for ancestor id
                map<string,id> ancestorIDMap = new map<string,id>();
                for (Apttus_Config2__ClassificationHierarchy__c aimp : [Select ID,Name,Apttus_Config2__HierarchyId__c from Apttus_Config2__ClassificationHierarchy__c where Apttus_Config2__HierarchyId__c IN : categoryIDMap1.values() ]){
                    ancestorIDMap.put(aimp.Name,aimp.ID);
                }
                
                //for loop for processing the resPriceListData and creating category hierarchy for sub type
                for(requestPriceListData reqPriceListVar :resPriceListData ){
                    if(reqPriceListVar.RECORD_TYPE_IDENTIFIER!=null && reqPriceListVar.RECORD_TYPE_IDENTIFIER=='L') {
                        
                        //Category Hierarchy
                        
                        string product_type=null;
                        string product_sub_type=null;
                        integer catHexistCount;
                        ID Ancestor_ID = null;
                        
                        string catHierName;
                        if(reqPriceListVar.LIST_HEADER_ID!=null && catHierNameMap1.get(reqPriceListVar.LIST_HEADER_ID)!=null){
                            catHierName = catHierNameMap1.get(reqPriceListVar.LIST_HEADER_ID);
                            
                            
                            
                            //assign primodalid value
                            ID PrimordialID = null;
                            if(PrimordialIDMap1.get(catHierName)!=null ){
                                PrimordialID = PrimordialIDMap1.get(catHierName);
                            }
                            
                            //assign category id value
                            ID category_ID=null;
                            
                            if(categoryIDMap1.get(catHierName)!=null){
                                category_ID = categoryIDMap1.get(catHierName);
                            }
                            
                            
                            // assign product type value from prodID_Sub_Type_Map
                            if(prodID_Type_Map1.get(reqPriceListVar.PRODUCT_ATTR_VALUE)!=null){
                                product_type = prodID_Type_Map1.get(reqPriceListVar.PRODUCT_ATTR_VALUE);
                                product_sub_type = prodID_Sub_Type_Map.get(reqPriceListVar.PRODUCT_ATTR_VALUE);
                            }
                            
                            //assign ancestor id based on product type 
                            if(ancestorIDMap.get(product_type)!=null){
                                Ancestor_ID = ancestorIDMap.get(product_type);
                            }
                            
                            //check if category hierarchye exists, if not then create a new category hierarchy for apttus
                            if(catHierSubTypeExistMap.get(product_sub_type)==null ){
                                
                                if(product_type!=null && PrimordialID!=null && category_ID!=null && Ancestor_ID!=null && product_sub_type!=null ){
                                    //Category Hierarchy
                                    catHierVar = new Apttus_Config2__ClassificationHierarchy__c();
                                    catHierVar.Name = product_sub_type;
                                    catHierVar.Apttus_Config2__Label__c = product_sub_type;
                                    system.debug('product_sub_type'+product_sub_type);
                                    catHierVar.Apttus_Config2__PrimordialId__c = PrimordialID;
                                    catHierVar.Apttus_Config2__HierarchyId__c  = category_ID;
                                    catHierVar.Apttus_Config2__AncestorId__c = Ancestor_ID;
                                    catHierVar.Apttus_Config2__Level__c = 2;
                                    catHierVar.Apttus_Config2__IncludeInTotalsView__c = true;
                                    catHierVar.Apttus_Config2__HideAllSearchFilters__c = true;
                                    catHierVar.Apttus_Config2__DefaultSearchCategory__c = true;
                                    catHierVar.Apttus_Config2__ExpandedByDefault__c = false;
                                    
                                    
                                    categoryHierList.add(catHierVar);
                                    
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
                
                //To upsert data in Apttus_Config2__ClassificationHierarchy__c object
                if(categoryHierList!=null && categoryHierList.size()>0 ){
                    Database.UpsertResult[] srListcategoryHierList;
                    srListcategoryHierList = Database.Upsert(categoryHierList,Apttus_Config2__ClassificationHierarchy__c.Fields.Id,false);
                    
                    //MastersrList.add(srListcategoryHierList);
                    
                }
                
                //Code for category hierarchy numbering begins
                //Declare maps for category hierarchy left right numbering 
                map<string,integer> nameLeftMap = new map<string,integer>();
                map<ID, integer> L2LeftFirstMap = new map<ID, integer>();
                map<ID, integer> L1LeftMap = new map<ID,integer>();
                map<ID, integer> L2LeftWithId = new map<ID, integer>();
                map<ID,integer> IDHeader = new map<ID,integer>();           
                map<id,Apttus_Config2__ClassificationHierarchy__c> leftRightUpdateL2Map = new map<id,Apttus_Config2__ClassificationHierarchy__c>();
                map<id,Apttus_Config2__ClassificationHierarchy__c> leftRightUpdateL1Map = new map<id,Apttus_Config2__ClassificationHierarchy__c>();

                //set the starting value for Header right value 
                for(Apttus_Config2__ClassificationHierarchy__c IDLM1:[Select ID,Name,Apttus_Config2__Left__c,Apttus_Config2__AncestorId__c,Apttus_Config2__PrimordialId__c,Apttus_Config2__Level__c from Apttus_Config2__ClassificationHierarchy__c WHERE Apttus_Config2__Level__c = 0 and ID IN: PriIDSet ]){
                    IDHeader.put(IDLM1.ID,2);
                }

                //set the numbering for left right for level 2 
                for(ID pid :PriIDSet){
                    integer i = 3;
                    for(Apttus_Config2__ClassificationHierarchy__c LRUL2 : [Select ID,Name,Apttus_Config2__AncestorId__c, Apttus_Config2__Left__c,Apttus_Config2__Right__c,Apttus_Config2__PrimordialId__c,Apttus_Config2__Level__c from Apttus_Config2__ClassificationHierarchy__c Where Apttus_Config2__Level__c =2 AND Apttus_Config2__PrimordialId__c = :pid ORDER BY Name ASC ]  ){ /*** SURESH ***/
                        leftRightUpdateL2Map.put(LRUL2.ID,LRUL2);
                        
                        if(L2LeftFirstMap.get(LRUL2.Apttus_Config2__AncestorId__c)!=null){
                            i = i-2;
                            L2LeftWithId.put(LRUL2.ID,i);
                            
                        }else if(L2LeftFirstMap.get(LRUL2.Apttus_Config2__AncestorId__c)==null){
                            L2LeftWithId.put(LRUL2.ID,i);
                        } 
                        nameLeftMap.put(LRUL2.Name,i);
                        
                        if(L2LeftFirstMap.get(LRUL2.Apttus_Config2__AncestorId__c)==null){
                            L2LeftFirstMap.put(LRUL2.Apttus_Config2__AncestorId__c,i);
                            
                        }
                        
                        i = i+4;
                        if(L2LeftFirstMap.get(LRUL2.Apttus_Config2__AncestorId__c)!=null){
                            L1LeftMap.put(LRUL2.Apttus_Config2__AncestorId__c,L2LeftFirstMap.get(LRUL2.Apttus_Config2__AncestorId__c)-1);
                        }
                    }
                }

                //set numbering for left right for level 1 
                map<id,Apttus_Config2__ClassificationHierarchy__c> leftRightUpdateMap = new map<id,Apttus_Config2__ClassificationHierarchy__c>();
                List<Integer> L1LeftMapSORT = L1LeftMap.values();
                L1LeftMapSORT.sort();
                List<Id> missedAlignment = new List<Id>();

                Integer j = 0;
                for(Apttus_Config2__ClassificationHierarchy__c LRU : [Select ID, Name, Apttus_Config2__Left__c,Apttus_Config2__Right__c,Apttus_Config2__PrimordialId__c,Apttus_Config2__Level__c from Apttus_Config2__ClassificationHierarchy__c Where Apttus_Config2__Level__c =1 AND Apttus_Config2__PrimordialId__c IN:PriIDSet ORDER BY Name ASC ]  ){ /*** SURESH ***/
                    leftRightUpdateMap.put(LRU.ID,LRU);
                    //leftRightUpdateL2Map.put(LRU.ID,LRU);
                    leftRightUpdateL1Map.put(LRU.ID,LRU);
                    
                    if(j <= L1LeftMapSORT.size() - 1){
                        if(L1LeftMap.containsKey(LRU.ID)){
                            L1LeftMap.put(LRU.ID, L1LeftMapSORT[j]);
                        }
                        else{
                            missedAlignment.add(LRU.ID);
                            j = j - 1;
                        }
                    }
                    else{
                        missedAlignment.add(LRU.ID);
                    }
                    j = j + 1;
                }

                list<Apttus_Config2__ClassificationHierarchy__c> leftRightUpdateListL1L2 = new list<Apttus_Config2__ClassificationHierarchy__c>();
                Apttus_Config2__ClassificationHierarchy__c leftRightListL1L2 ;
                for(ID pid :PriIDSet){
                    for(ID idMapL2 :leftRightUpdateL2Map.keyset() ){
                        if (leftRightUpdateL2Map.get(idMapL2)!=null && L2LeftWithId.get(idMapL2)!=null){
                            leftRightListL1L2 = leftRightUpdateL2Map.get(idMapL2);
                            leftRightListL1L2.Apttus_Config2__Left__c = L2LeftWithId.get(idMapL2);
                            leftRightListL1L2.Apttus_Config2__Right__c = L2LeftWithId.get(idMapL2)+1;
                            IDHeader.put(pid,IDHeader.get(pid)+2);
                            leftRightUpdateListL1L2.add(leftRightListL1L2);
                        }
                    }
                    
                    for(ID idMapL1 :leftRightUpdateL1Map.keyset() ){
                        if (leftRightUpdateL1Map.get(idMapL1)!=null && L1LeftMap.get(idMapL1)!=null){
                            leftRightListL1L2 = leftRightUpdateL1Map.get(idMapL1);
                            leftRightListL1L2.Apttus_Config2__Left__c = L1LeftMap.get(idMapL1);
                            IDHeader.put(pid,IDHeader.get(pid)+2);
                            leftRightUpdateListL1L2.add(leftRightListL1L2);
                        }
                    }
                }

                update leftRightUpdateListL1L2;
                system.debug('leftRightUpdateListL1L2'+leftRightUpdateListL1L2);
                map<id,Apttus_Config2__ClassificationHierarchy__c> leftRightUpdateMap1 = new map<id,Apttus_Config2__ClassificationHierarchy__c>();
                for(Apttus_Config2__ClassificationHierarchy__c LRU : [Select ID, Apttus_Config2__Left__c,Apttus_Config2__Right__c,Apttus_Config2__PrimordialId__c,Apttus_Config2__Level__c from Apttus_Config2__ClassificationHierarchy__c Where Apttus_Config2__Level__c =0 AND ID IN:PriIDSet]  ){
                    leftRightUpdateMap1.put(LRU.ID,LRU);
                }


                set<ID> an4LeftIDSet = new set<ID>();
                for(Apttus_Config2__ClassificationHierarchy__c IDLM:[Select ID,Apttus_Config2__Left__c,Apttus_Config2__AncestorId__c,Apttus_Config2__PrimordialId__c,Apttus_Config2__Level__c from Apttus_Config2__ClassificationHierarchy__c WHERE Apttus_Config2__Level__c = 1 and Apttus_Config2__AncestorId__c IN: PriIDSet ]){
                    an4LeftIDSet.add(IDLM.ID);
                }

                set<ID> anUniqMin = new set<ID>();
                map<id,integer> leftL3Min = new map<id,integer>();
                for(Apttus_Config2__ClassificationHierarchy__c LRU : [Select ID, Apttus_Config2__Left__c,Apttus_Config2__Right__c,Apttus_Config2__PrimordialId__c,Apttus_Config2__Level__c,Apttus_Config2__AncestorId__c from Apttus_Config2__ClassificationHierarchy__c Where Apttus_Config2__Level__c =2 AND Apttus_Config2__PrimordialId__c IN:PriIDSet and Apttus_Config2__AncestorId__c IN:an4LeftIDSet ORDER BY Apttus_Config2__Left__c ASC]  ){
                    if(anUniqMin.add(LRU.Apttus_Config2__AncestorId__c)){
                        leftL3Min.put(LRU.Apttus_Config2__AncestorId__c,integer.valueof(LRU.Apttus_Config2__Left__c));
                    }
                }
                system.debug('leftL3Min'+leftL3Min);
                set<ID> anUniqMax = new set<ID>();
                map<id,integer> leftL3Max = new map<id,integer>();
                for(Apttus_Config2__ClassificationHierarchy__c LRU : [Select ID, Apttus_Config2__Left__c,Apttus_Config2__Right__c,Apttus_Config2__PrimordialId__c,Apttus_Config2__Level__c,Apttus_Config2__AncestorId__c from Apttus_Config2__ClassificationHierarchy__c Where Apttus_Config2__Level__c =2 AND Apttus_Config2__PrimordialId__c IN:PriIDSet and Apttus_Config2__AncestorId__c IN:an4LeftIDSet ORDER BY Apttus_Config2__Left__c DESC]  ){
                    if(anUniqMax.add(LRU.Apttus_Config2__AncestorId__c)){
                        leftL3Max.put(LRU.Apttus_Config2__AncestorId__c,integer.valueof(LRU.Apttus_Config2__Left__c));
                    }
                }
                system.debug('leftL3Max'+leftL3Max);

                list<Apttus_Config2__ClassificationHierarchy__c> leftRightUpdateList = new list<Apttus_Config2__ClassificationHierarchy__c>();
                Apttus_Config2__ClassificationHierarchy__c leftRightList ;
                //set the value for right 
                for(ID pid :PriIDSet){
                    for(ID idMap :leftRightUpdateMap.keyset() ){
                        
                        if (leftRightUpdateMap.get(idMap)!=null && leftL3Max.get(idMap)!=null){
                            
                            leftRightList = leftRightUpdateMap.get(idMap);
                            
                            leftRightList.Apttus_Config2__Right__c = leftL3Max.get(idMap)+2;
                            system.debug('leftL3Max.get(idMap)'+leftL3Max.get(idMap));
                            leftRightUpdateList.add(leftRightList);
                        }
                    }
                }

                //set the number for header right value 
                for(ID pid :PriIDSet){
                    for(ID idMap1 :leftRightUpdateMap1.keyset() ){
                        if(leftRightUpdateMap1.get(idMap1)!=null && IDHeader.get(pid)!=null){
                            leftRightList = leftRightUpdateMap1.get(idMap1);
                            leftRightList.Apttus_Config2__Right__c = IDHeader.get(pid);
                            leftRightUpdateList.add(leftRightList);
                        }
                    }
                }
                Decimal lastGlobalCount = 0;
                for(Apttus_Config2__ClassificationHierarchy__c LRUPDATE: leftRightUpdateList){
                    if(LRUPDATE.Apttus_Config2__Level__c == 0){
                        lastGlobalCount = LRUPDATE.Apttus_Config2__Right__c - 1;
                    }
                }
                
                if(missedAlignment.size() > 0){
                    for(Apttus_Config2__ClassificationHierarchy__c missedAncestor : [SELECT ID, Apttus_Config2__Left__c, Apttus_Config2__Right__c FROM Apttus_Config2__ClassificationHierarchy__c WHERE Apttus_Config2__Level__c = 1 and ID IN: missedAlignment ORDER BY Name ASC]){
                        lastGlobalCount = lastGlobalCount + 1;
                        missedAncestor.Apttus_Config2__Left__c = lastGlobalCount;
                        lastGlobalCount = lastGlobalCount + 1;
                        missedAncestor.Apttus_Config2__Right__c = lastGlobalCount;
                        leftRightUpdateList.add(missedAncestor);
                    }
                }
                
                system.debug('lastGlobalCount =>'+lastGlobalCount);
                for(Apttus_Config2__ClassificationHierarchy__c LRUPDATE: leftRightUpdateList){
                    if(LRUPDATE.Apttus_Config2__Level__c == 0){
                        LRUPDATE.Apttus_Config2__Right__c = lastGlobalCount + 1;
                    }
                }
                update leftRightUpdateList;
                
                categoryHierList.clear();
                plist.clear();
                productList.clear();
                
                //declare and assign set and maps for product classification 
                set<ID> PrimordialIDSet = new set<ID>();
                set<ID> CHIDSet = new set<ID>();
                
                for(Apttus_Config2__ClassificationHierarchy__c pid : [Select ID, Apttus_Config2__PrimordialId__c, Name FROM Apttus_Config2__ClassificationHierarchy__c where Name IN:catHierNameSet] ){
                    //PrimordialIDSet.add(pid.Apttus_Config2__PrimordialId__c);
                    PrimordialIDSet.add(pid.ID);
                    CHIDSet.add(pid.ID);
                    
                }
                
                set<ID> clasHierIDSet = new set<ID>();
                map<string,ID> catHierNameIDMap = new map<string,ID>();
                Map<string,Apttus_Config2__ClassificationHierarchy__c> apcH_PC = new Map<string,Apttus_Config2__ClassificationHierarchy__c>();
                Map<string,ID> CatHierIDMap = new Map<string,ID>();
                
                for(Apttus_Config2__ClassificationHierarchy__c pc : [Select ID, Name,Apttus_Config2__PrimordialId__c,Apttus_Config2__Level__c from Apttus_Config2__ClassificationHierarchy__c Where Name IN : stSet AND Apttus_Config2__PrimordialId__c IN: PrimordialIDSet AND Apttus_Config2__Level__c = 2]){
                    
                    apcH_PC.put(pc.Name,pc);
                    clasHierIDSet.add(pc.ID);
                    CatHierIDMap.put(pc.Name,pc.ID);
                    
                    
                }
                system.debug('stSet'+stSet);
                system.debug('apcH_PC'+apcH_PC);
                for(Apttus_Config2__ClassificationHierarchy__c pc : [Select ID, Name,Apttus_Config2__PrimordialId__c,Apttus_Config2__Level__c from Apttus_Config2__ClassificationHierarchy__c Where ID IN: PrimordialIDSet AND Apttus_Config2__Level__c = 0]){
                    catHierNameIDMap.put(pc.name,pc.id);
                }
                map<ID,ID> ProdClassExitMap = new map<ID,ID>();
                for(Apttus_Config2__ProductClassification__c pst : [Select ID, Apttus_Config2__ClassificationId__c, Apttus_Config2__ProductId__c from  Apttus_Config2__ProductClassification__c where Apttus_Config2__ClassificationId__c IN:clasHierIDSet  and Apttus_Config2__ProductId__c IN: ProdIDSet  ]){
                    ProdClassExitMap.put(pst.Apttus_Config2__ProductId__c,pst.id);
                }
                
                map<string,String> prodID_Sub_Type_ProdClass_Map = new map<string,string>();
                for(product2 pType : [Select ID, Type__c ,sub_type__c,Oracle_ID__c from product2 where sub_type__c IN :prodSubTypeSet and Oracle_ID__c IN :prodAttrValSet]){
                    //for(product2 pType : [Select ID, Type__c ,sub_type__c,Oracle_ID__c from product2 where  Oracle_ID__c IN :prodAttrValSet]){
                    
                    prodID_Sub_Type_ProdClass_Map.put(pType.Oracle_ID__c,pType.sub_type__c);
                    
                    
                }
                
                
                
                for(requestPriceListData reqPriceListVar :resPriceListData ){   
                    
                    
                    if(reqPriceListVar.RECORD_TYPE_IDENTIFIER!=null && reqPriceListVar.RECORD_TYPE_IDENTIFIER=='L') {
                        
                        //Product Classification
                        //Set category hierarchy name 
                        if(reqPriceListVar.PRODUCT_ATTR_VALUE !=null && pID_oID_Map.get(reqPriceListVar.PRODUCT_ATTR_VALUE)!=null){
                            //string catHierName = [Select Name from Apttus_Config2__PriceList__c where Oracle_ID__c =: reqPriceListVar.LIST_HEADER_ID limit 1 ].Name;
                            string catHierName;
                            if(reqPriceListVar.LIST_HEADER_ID!=null && catHierNameMap.get(reqPriceListVar.LIST_HEADER_ID)!=null){
                                catHierName = catHierNameMap.get(reqPriceListVar.LIST_HEADER_ID);
                                
                                
                            }
                            
                            //set primodal id 
                            ID Primordial;
                            if( catHierName !='' && PrimodalIDMap.get(catHierName)!=null){
                                Primordial = PrimodalIDMap.get(catHierName);
                                
                            }
                            string product_sub_type = prodID_Sub_Type_ProdClass_Map.get(reqPriceListVar.PRODUCT_ATTR_VALUE);
                            ID CatHierID=null;
                            //check if product classification exist if dosnt exist create a new product classificatoin
                            if(pID_oID_Map.get(reqPriceListVar.PRODUCT_ATTR_VALUE)!=null && ProdClassExitMap.get(pID_oID_Map.get(reqPriceListVar.PRODUCT_ATTR_VALUE))==null && product_sub_type!=null)  {
                                
                                prodClasVar = new Apttus_Config2__ProductClassification__c();
                                
                                if(apcH_PC.get(product_sub_type)!=null){
                                    
                                    CatHierID =  CatHierIDMap.get(product_sub_type);
                                }
                                if(CatHierID!=null){
                                    prodClasVar.Apttus_Config2__ClassificationId__c = CatHierID;
                                }
                                
                                
                                prodClasVar.Apttus_Config2__ProductId__c  = pID_oID_Map.get(reqPriceListVar.PRODUCT_ATTR_VALUE);
                                prodClasVar.Apttus_Config2__MinQuantity__c = 0.0;
                                prodClasVar.Apttus_Config2__MaxQuantity__c = 1.0;
                                prodClasVar.Apttus_Config2__DefaultQuantity__c = 1.0;
                                prodClasVar.Apttus_Config2__Modifiable__c = true;
                                
                                
                                
                                prodClassification.add(prodClasVar);
                                
                            }
                            
                            
                        }
                        
                    }
                    
                }
                
                //Using the JSON.serializePretty we will serialize the list of account.
                string jsonString = JSON.serializePretty(prodClassification);
                
                //Pass the serialized list to the future method.
                prodClassificationDML(jsonString);
                
                
                
                //Upserting Derived tables starts product Classification 
                //To upsert data in Apttus_Config2__ProductClassification__c object
                /* if(prodClassification!=null && prodClassification.size()>0 ){
                Database.UpsertResult[] srListprodClassification;
                srListprodClassification = Database.Upsert(prodClassification,Apttus_Config2__ProductClassification__c.Fields.Id,false);
    
                //MastersrList.add(srListprodClassification);
                
            }*/
                //Upserting Derived tables Ends product Classification 
                
            }
            
            set<id> succPrLiIdSet = new set<id>();
            if(PriceListMastersrList.size()>0){
                for(list<Database.UpsertResult> srval : PriceListMastersrList) {
                    for (Database.UpsertResult sr : srval){
                        succPrLiIdSet.add(sr.getid());
                    }
                    
                }
            }
            
            
            map<id,string> OracleID_ID_Map = new map<id,string>();
            for(Apttus_Config2__PriceList__c pl : [Select ID,Oracle_ID__c from Apttus_Config2__PriceList__c where id IN:succPrLiIdSet ]){
                OracleID_ID_Map.put(pl.id, string.valueof(pl.Oracle_ID__c));
            }
            
            //Generate response variable with success and failure for pricelist 
            if(PriceListMastersrList.size()>0){
                for(list<Database.UpsertResult> srval : PriceListMastersrList) {
                    for (Database.UpsertResult sr : srval){
                        if (sr.isSuccess()){
                            respvar = new ResponseWraperClass();
                            respvar.result ='Success';
                            respvar.Errorcode = 'PL-SUCCESS-4010:';
                            respvar.ErrorMessage = 'Transaction Succesfull';   
                            respvar.TransactionNameAndValue = 'PriceList:' + sr.getid();
                            respvar.RECORD_TYPE_IDENTIFIER = 'H';
                            if(OracleID_ID_Map.get(sr.getid())!=null){
                                respvar.LIST_HEADER_ID=OracleID_ID_Map.get(sr.getid()); 
                            }
                            //LIST_LINE_ID            
                            respvar.SFDC_NUMBER = sr.getid();
                            system.debug('respvar.result Success===>' + respvar.result);   
                            respvarlist.add(respvar);
                            
                        }else{
                            // Operation failed, so get all errors                
                            for(Database.Error err : sr.getErrors()) {
                                respvar = new ResponseWraperClass();
                                //respvar.result ='Failure .'+ err.getStatusCode() + ': ' + err.getMessage()+': '+sr.getid(); 
                                blnFinalResult = true;
                                respvar.result ='Failure';   
                                respvar.Errorcode = 'PL-ERROR-4010:';
                                respvar.ErrorMessage = 'Failure'+ err.getStatusCode() + ': ' + err.getMessage()+': '+sr.getid();   
                                respvar.TransactionNameAndValue = 'PriceList:' + sr.getid();
                                respvar.RECORD_TYPE_IDENTIFIER = 'H';
                                if(OracleID_ID_Map.get(sr.getid())!=null){
                                    respvar.LIST_HEADER_ID=OracleID_ID_Map.get(sr.getid()); 
                                }           
                                //LIST_LINE_ID            
                                respvar.SFDC_NUMBER = sr.getid();  
                                respvarlist.add(respvar);
                                system.debug('respvar.result Faulure===>' + respvar.result);
                                
                            }
                            
                        }

                    }
                    
                }
                
            }
            
            
            //Generate response variable with success and failure for pricelist 
            if(PriceListItemMastersrList.size()>0){
                for(list<Database.UpsertResult> srval : PriceListItemMastersrList) {
                    for (Database.UpsertResult sr : srval){
                        if (sr.isSuccess()){
                            respvar = new ResponseWraperClass();
                            respvar.result ='Success';
                            respvar.Errorcode = 'PLITEM-SUCCESS-4020:';
                            respvar.ErrorMessage = 'Transaction Succesfull';   
                            respvar.TransactionNameAndValue = 'PriceListItem:' + sr.getid();
                            respvar.RECORD_TYPE_IDENTIFIER = 'L';
                            
                            //LIST_LINE_ID            
                            respvar.SFDC_NUMBER = sr.getid();
                            system.debug('respvar.result Success===>' + respvar.result);   
                            respvarlist.add(respvar);
                            
                        }else{
                            // Operation failed, so get all errors                
                            for(Database.Error err : sr.getErrors()) {
                                respvar = new ResponseWraperClass();
                                //respvar.result ='Failure .'+ err.getStatusCode() + ': ' + err.getMessage()+': '+sr.getid(); 
                                blnFinalResult = true;
                                respvar.result ='Failure';   
                                respvar.Errorcode = 'PLITEM-ERROR-4020:';
                                respvar.ErrorMessage = 'Failure'+ err.getStatusCode() + ': ' + err.getMessage()+': '+sr.getid();   
                                respvar.TransactionNameAndValue = 'PriceListItem:' + sr.getid();
                                respvar.RECORD_TYPE_IDENTIFIER = 'L';
                                
                                //LIST_LINE_ID            
                                respvar.SFDC_NUMBER = sr.getid();  
                                respvarlist.add(respvar);
                                system.debug('respvar.result Faulure===>' + respvar.result);
                                
                            }
                            
                        }

                    }
                    
                }
            }
            
            
            
            
        }catch(Exception ex){
            
            respvar = new ResponseWraperClass();  
            blnSystemException = true;
            blnFinalResult = true; 
            respvar.result ='Failure';
            respvar.Errorcode = 'PL-ERROR-4010';
            respvar.ErrorMessage = 'Failure:'+ string.valueof(ex);
            respvar.TransactionNameAndValue = 'PriceList:'+ string.valueof(ex);
            //+string.valueof(ex);
            respvarlist.add(respvar);
            system.debug('exception ====='+ex); 
            system.debug('exception ====='+ex.getStackTraceString()); 
            
            
            
        }
        
        //Passing final result for the entire load, if there in on failure then Final Result will be Filaure 
        //and all are success the final result will be passed as Success 
        if (blnFinalResult==true) {
            respvar = new ResponseWraperClass();
            respvar.FinalResult = 'Failure';
            respvarlist.add(respvar);
            
        }else{
            respvar = new ResponseWraperClass();
            respvar.FinalResult = 'Success';
            respvarlist.add(respvar);
        }
        return respvarlist;

    }
    @future
    public static void prodClassificationDML(string prodClassificationListString){
        //Deserialize the list and cast it to account list.
        list<Apttus_Config2__ProductClassification__c> prodClassification1 =  (list<Apttus_Config2__ProductClassification__c>)JSON.deserializeStrict(prodClassificationListString, list<Apttus_Config2__ProductClassification__c>.class);
        //Insert the Apttus_Config2__ProductClassification__c
        
        
        //Upserting Derived tables starts product Classification 
        //To upsert data in Apttus_Config2__ProductClassification__c object
        if(prodClassification1!=null && prodClassification1.size()>0 ){
            Database.UpsertResult[] srListprodClassification;
            srListprodClassification = Database.Upsert(prodClassification1,Apttus_Config2__ProductClassification__c.Fields.Id,false);
            
            //MastersrList.add(srListprodClassification);
            
        }
    }

    

    global class requestPriceListData
    {         
        //PriceList Data data
        webservice string RECORD_TYPE_IDENTIFIER ;// 'H' for Header, 'L' for Line
        webservice integer LIST_HEADER_ID;  //-- Header and Line //Oracle_ID
        webservice string NAME;  //-- Header
        webservice string DESCRIPTION; // -- Header
        webservice string  CURRENCY_CODE; // -- Header
        webservice string HEADER_ATTRIBUTE1; // -- Header
        webservice String HEADER_ATTRIBUTE2 ; // -- Header
        webservice String ACTIVE_FLAG;  // -- Header
        webservice Date START_DATE_ACTIVE; // -- Header and Line
        webservice Date END_DATE_ACTIVE; //  -- Header and Line
        webservice string PRODUCT_ATTR_VALUE; // -- Line 
        webservice string PRODUCT_UOM_CODE; // Line
        webservice decimal OPERAND; //Line    
        webservice integer LIST_LINE_ID; //Line               
        
    } 
    

    global class ResponseWraperClass
    {     
        webservice String Result{get;set;}
        webservice String FinalResult{get;set;}
        webservice String Errorcode{get;set;}    
        webservice String ErrorMessage{get;set;} 
        webservice String TransactionNameAndValue{get;set;}  
        webservice String RECORD_TYPE_IDENTIFIER{get;set;}   
        webservice String LIST_HEADER_ID{get;set;}            
        webservice String LIST_LINE_ID{get;set;}            
        webservice String SFDC_NUMBER{get;set;}           
    }

}