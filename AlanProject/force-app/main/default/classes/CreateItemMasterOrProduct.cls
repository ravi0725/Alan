/*****************************************************************************************
    Name    : CreateItemMasterOrProduct 
    Desc    : Used implementing the inbound to SFDC from Oracle EBS for Product,Category,Category Hierarchy and Option Group Object
              
                            
Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Vikram Mandla        12/12/2013          Created
Sunay Prasad R K     21/02/2014          Modified
Sunay Prasad R K     16/04/2014          Modified to add the Email Exception handling
******************************************************************************************/
global class CreateItemMasterOrProduct {
    
    public class soapexception extends exception{}
    /*
     * Method name  : CreateItemMasterorProduct
     * Description  : Webserice method to load Product data from Oracle EBS to SFDC standard object Product
     * Return Type  : list<ResponseWraperClass>
     * Parameter    : requesrwrapervar
     */ 
    webService static list<ResponseWraperClass> CreateItemMasterorProduct(list<requestdata> requesrwrapervar) 
    {
        list<product2> productlist = new list<product2>();
        list<Apttus_Config2__ClassificationName__c> configObjlist = new list<Apttus_Config2__ClassificationName__c>();
        list<Apttus_Config2__ClassificationHierarchy__c> configHierObjlist = new list<Apttus_Config2__ClassificationHierarchy__c>();
        list<Apttus_Config2__ProductOptionGroup__c> ProductOptionList = new list<Apttus_Config2__ProductOptionGroup__c>();
        list<Apttus_Config2__ProductOptionComponent__c> ProductOptionCompList = new list<Apttus_Config2__ProductOptionComponent__c>();
        list<Apttus_Config2__ProductClassification__c> ProductclasifyList = new list<Apttus_Config2__ProductClassification__c>();
        List<Apttus_Config2__ProductOptionGroup__c> optGrpList;
        List<Apttus_Config2__ProductOptionComponent__c> prodCompList;
        List<Product2> prodList;
        
        product2 productvar;
        Apttus_Config2__ClassificationName__c configvar;
        Apttus_Config2__ClassificationHierarchy__c configHierVar;
        Apttus_Config2__ProductOptionGroup__c ProOptVar; 
        Apttus_Config2__ProductOptionComponent__c ProdCoponentvar;
        Apttus_Config2__ProductClassification__c ProdClasifyVar;        
        
        string strproductid,categoryHierId;
        string strproductid1,categoryHierId1;
        string strproductid2,categoryHierId2;
        string strproductid3,categoryHierId3;
        string oracleid;
        string MasterProductName;
        string coponentprodId;
        integer listsize = 0;
        integer firstrec = 0;
        boolean forupdate = false;
        boolean blnFinalResult = false;
        boolean blnSystemException = false;
        boolean throwEx = false;
        
        //for sequence
        string strProOptGrpId;
        integer count = 0;
        map<string,integer> ProOptGRPMap = new map<string,integer>();
        integer RecCount = 0;
        set<id> productoptiongroupidset = new set<id>();
        integer sequencevalue;
        
        integer listsize1 = 0,RecCount1 = 0;
        string strProOptGrpId1;
        integer count1 = 0;
        list<Apttus_Config2__ProductOptionGroup__c> objlist = new list<Apttus_Config2__ProductOptionGroup__c>();
        //end of sequence
                
        list<list<Database.UpsertResult>> MastersrList = new list<list<Database.UpsertResult>>();
        map<Database.UpsertResult,Database.UpsertResult> resultsmap = new map<Database.UpsertResult,Database.UpsertResult>(); 
        Database.UpsertResult[] srList;
        boolean addtolist;
        
        ResponseWraperClass respvar;
        list<ResponseWraperClass> respvarlist = new list<ResponseWraperClass>();
        string productid;
        
        map<string,integer> countmap = new map<string,integer>();
        //product map
        map<string,product2> productmap = new map<string,product2>();
        map<string,product2> Insertedproductmap = new map<string,product2>();
        
        set<string> productnamesSet = new set<string>(); 
        set<id> productidSet = new set<id>();     
        map<string,product2> bundleproductmap = new map<string,product2>(); 
        map<string,product2> newproductmap = new map<string,product2>(); 
        map<string,string> productmapForBundle = new map<string,string>(); 
        map<string,string> componentproductcodemap = new map<string,string>();
        map<string,string> bundleproductcodemap = new map<string,string>();
        map<string,string> ProductCompOptUpdatemap = new map<string,string>();
        set<string> bundleproductnamesSet = new set<string>(); 
        
        //for Apttus_Config2__ClassificationName__c
        
        map<string,Apttus_Config2__ClassificationName__c> classificationmap = new map<string,Apttus_Config2__ClassificationName__c>();
        map<string,Apttus_Config2__ClassificationName__c> Insertedclassificationmap = new map<string,Apttus_Config2__ClassificationName__c>();  
        map<string,Apttus_Config2__ClassificationName__c> newclassificationmap = new map<string,Apttus_Config2__ClassificationName__c>();
        list<Apttus_Config2__ClassificationName__c> Updatecategorylist = new list<Apttus_Config2__ClassificationName__c>();  
        set<id> classificationidSet = new set<id>(); 
        
        //for Apttus_Config2__ClassificationHierarchy__c
        
        map<string,Apttus_Config2__ClassificationHierarchy__c> classificationHirmap = new map<string,Apttus_Config2__ClassificationHierarchy__c>();
        map<string,Apttus_Config2__ClassificationHierarchy__c> InsertedclassificationHirmap = new map<string,Apttus_Config2__ClassificationHierarchy__c>();
        map<string,Apttus_Config2__ClassificationHierarchy__c> InsertedclassificationHirmap1 = new map<string,Apttus_Config2__ClassificationHierarchy__c>();         
        set<id> classificationHiridSet = new set<id>(); 
        
        // for Apttus_Config2__ProductOptionGroup__c
        map<string,Apttus_Config2__ProductOptionGroup__c> ProdOptmap = new map<string,Apttus_Config2__ProductOptionGroup__c>();
        map<string,Apttus_Config2__ProductOptionGroup__c> InsertedProdOptmap = new map<string,Apttus_Config2__ProductOptionGroup__c>(); 
        map<string,Apttus_Config2__ProductOptionGroup__c> ProdOptmapTobeUpdated = new map<string,Apttus_Config2__ProductOptionGroup__c>();
        list<Apttus_Config2__ProductOptionGroup__c>   productoptlist = new list<Apttus_Config2__ProductOptionGroup__c>(); 
        map<string,string> PorductUpdatesMap = new map<string,string>();
        map<string,integer> SeqProdOptmap = new map<string,integer>();
        list<product2> bundleproductupdatelist = new list<product2>();
        set<id> ProdOptidSet = new set<id>(); 
        
        //for Apttus_Config2__ProductOptionComponent__c
        map<string,Apttus_Config2__ProductOptionComponent__c> ProdOptCompMap = new map<string,Apttus_Config2__ProductOptionComponent__c>();
        map<string,integer> ProdOptComponentMap = new map<string,integer>();
        list<Apttus_Config2__ProductOptionComponent__c> ProdOptCopList = new list<Apttus_Config2__ProductOptionComponent__c>();
        integer listsize2=0,loopvar=0,ObjRecCount=0;
        string StrOptionGRpID;
        set<id> prodid = new set<id>();
        list<Apttus_Config2__ProductOptionComponent__c> OptComTobeDeleted = new list<Apttus_Config2__ProductOptionComponent__c>();
        
        //for Apttus_Config2__ProductClassification__c
        map<string,Apttus_Config2__ProductClassification__c> ProdClassyfyMap = new map<string,Apttus_Config2__ProductClassification__c>();
        list<Apttus_Config2__ProductClassification__c> ClassifyObjTobeDeleted = new list<Apttus_Config2__ProductClassification__c>();
        set<string> componentProductCodeSet = new set<string>();
        
        //for bundle deletion
            set<string> productstobedeleted = new set<string>();
            list<Apttus_Config2__ClassificationName__c>  categorylisttobedeleted = new list<Apttus_Config2__ClassificationName__c>();
            //list<Apttus_Config2__ClassificationHierarchy__c>   categoryHierlisttobedeleted = new list<Apttus_Config2__ClassificationHierarchy__c>();
            //list<Apttus_Config2__ProductOptionGroup__c> ProOptlisttobedeleted = new list<Apttus_Config2__ProductOptionGroup__c>();
            set<string> OptionGRpIdsSet = new set<string>();            
            list<Apttus_Config2__ProductOptionComponent__c> OptComplisttobedeleted = new list<Apttus_Config2__ProductOptionComponent__c>();         
            //list<Apttus_Config2__ProductClassification__c> Optclassifylisttobedeleted = new list<Apttus_Config2__ProductClassification__c>();
        
        //end of varaiables for bundle deletion
        
        
        
        
        //Iterate over the request data and add in to sets        
        for(requestdata reqvar:requesrwrapervar)
        {
            productnamesSet.add(reqvar.ProductName);
            if(reqvar.bomProductName!=null && reqvar.bomProductName!=''){
                bundleproductnamesSet.add(reqvar.bomProductName);
                componentproductcodemap.put(reqvar.ProductName,reqvar.ProductName);
            }
            
            if(reqvar.Record_type!=null && reqvar.Record_type!='' && reqvar.Record_type.equalsIgnoreCase('bom'))
            {
                bundleproductcodemap.put(reqvar.ProductName,reqvar.ProductName);
            }
                          
            if((reqvar.Record_type != null && reqvar.Record_type != '') && reqvar.Record_type.equalsIgnoreCase('component'))
            {
                listsize1++;
                
            }
            /*if(reqvar.Record_type!=null && reqvar.Record_type!='' && reqvar.Record_type.equalsIgnoreCase('item'))
            {
                if(reqvar.ProductActive!=null && reqvar.ProductActive!='' && reqvar.ProductActive.equalsIgnoreCase('no'))
                productstobedeleted.add(reqvar.ProductName);
            }*/
            
        }
        //for(product2 prodvar:[select id,Name,Oracle_ID__c,ProductCode,Long_Description__c,Business_Area__c,Product_Type__c,sub_type__c,status__c,IsActive from product2 where ProductCode in: productnamesSet and isactive= : true])
        //For loop to add product map
        for(product2 prodvar:[select id,Name,Oracle_ID__c,ProductCode,Long_Description__c,Business_Area__c,Product_Type__c,sub_type__c,status__c,IsActive from product2 where ProductCode in: productnamesSet ])
        {
            productmap.put(prodvar.ProductCode,prodvar);
            prodid.add(prodvar.id);
        }
        //For loop to add product classification(Category)  map
        for(Apttus_Config2__ClassificationName__c objvar:[select id,productcode__c,Name,Apttus_Config2__HierarchyLabel__c,Apttus_Config2__Active__c,Apttus_Config2__Type__c from Apttus_Config2__ClassificationName__c where ProductCode__c in: productnamesSet])
        {
            classificationmap.put(objvar.ProductCode__c,objvar);
        }
        //For loop to add Classification Hierarchy(Category hierarchy)  map
        for(Apttus_Config2__ClassificationHierarchy__c hiervar:[select id,productcode__c,Name,Apttus_Config2__Left__c,Apttus_Config2__HierarchyId__c,Apttus_Config2__Level__c,Apttus_Config2__Right__c,Apttus_Config2__Label__c from Apttus_Config2__ClassificationHierarchy__c where ProductCode__c in: productnamesSet])
        {
            classificationHirmap.put(hiervar.ProductCode__c,hiervar);
        }
        
       
        
        //////system.debug('requesrwrapervar======'+requesrwrapervar.size());
        try{
            //Iterate over the data received from Oracle for creating or updating the Product records
        for(requestdata reqvar:requesrwrapervar)
        {
            System.debug(reqvar.Record_type);
            System.debug(reqvar.ProductName);
            if(reqvar.Record_type == null || reqvar.Record_type == '')
            {
                //throw new soapexception('Record type is missing in the data.Please check the data.');
                blnFinalResult = true;
                respvar = new ResponseWraperClass();  
                respvar.result ='Failure';
                respvar.Errorcode = 'IMP-ERR-101';
                respvar.ErrorMessage = 'Failure: Record type is missing in the data.Please check the data';
                if(reqvar.Record_type != null)
                    respvar.TransactionNameAndValue = 'Product: '+reqvar.Record_type;
                if(reqvar.Record_type != null)
                    respvar.RECORD_TYPE = reqvar.Record_type; 
                if(reqvar.ProductName != null)                    
                    respvar.ITEM_NUMBER = reqvar.ProductName;                 
                if(reqvar.Oracle_ID != null)
                    respvar.INVENTORY_ITEM_ID = reqvar.Oracle_ID;  
                if(reqvar.BomProductname != null)   
                    respvar.ASSEMBLY_ITEM_ID = reqvar.BomProductname; 
                respvarlist.add(respvar);
                
                
                    
                
            }    
            
            //Code to check for the Product which is a standalone product and insert in SFDC
            if((reqvar.Record_type != null && reqvar.Record_type != '') && reqvar.Record_type.equalsIgnoreCase('item'))
            {
                if(reqvar.ProductName == null || reqvar.ProductName == ''){
                    blnFinalResult = true;
                    respvar = new ResponseWraperClass();  
                    respvar.result ='Failure';
                    respvar.Errorcode = 'IMP-ERR-101';
                    respvar.ErrorMessage = 'Failure: Please check the Product Name and resend the Data';
                    if(reqvar.ProductName != null)
                        respvar.TransactionNameAndValue = 'Product: '+reqvar.ProductName;
                    if(reqvar.Record_type != null)
                        respvar.RECORD_TYPE = reqvar.Record_type; 
                    if(reqvar.ProductName != null)                    
                        respvar.ITEM_NUMBER = reqvar.ProductName;                 
                    if(reqvar.Oracle_ID != null)
                        respvar.INVENTORY_ITEM_ID = reqvar.Oracle_ID;   
                    if(reqvar.BomProductname != null) 
                        respvar.ASSEMBLY_ITEM_ID = reqvar.BomProductname;        
                    //respvar.SFDC_ITEM_NUMBER 
                    respvarlist.add(respvar);

                    
                }
                if(reqvar.ProductDescription != null && reqvar.ProductDescription != '' && reqvar.ProductDescription.length()>255){
                    blnFinalResult = true;
                    respvar = new ResponseWraperClass();  
                    respvar.result ='Failure';
                    respvar.Errorcode = 'IMP-ERR-101';
                    respvar.ErrorMessage = 'Failure: Please check the length of the Product Description and resend the data';
                    if(reqvar.ProductDescription != null)
                        respvar.TransactionNameAndValue = 'Product: '+reqvar.ProductDescription;
                    if(reqvar.Record_type != null)
                        respvar.RECORD_TYPE = reqvar.Record_type; 
                    if(reqvar.ProductName != null)                    
                        respvar.ITEM_NUMBER = reqvar.ProductName;                 
                    if(reqvar.Oracle_ID != null)
                        respvar.INVENTORY_ITEM_ID = reqvar.Oracle_ID;   
                    if(reqvar.BomProductname != null)  
                        respvar.ASSEMBLY_ITEM_ID = reqvar.BomProductname;
                    respvarlist.add(respvar);
                    
                    
                }
                if(reqvar.ProductDescription == null || reqvar.ProductDescription ==''){
                    blnFinalResult = true;
                    respvar = new ResponseWraperClass();  
                    respvar.result ='Failure';
                    respvar.Errorcode = 'IMP-ERR-101';
                    respvar.ErrorMessage = 'Failure: Product Description is missing in the data, please check the data';
                    if(reqvar.ProductDescription != null)
                        respvar.TransactionNameAndValue = 'Product: '+reqvar.ProductDescription;
                    if(reqvar.Record_type != null)
                        respvar.RECORD_TYPE = reqvar.Record_type; 
                    if(reqvar.ProductName != null)                    
                        respvar.ITEM_NUMBER = reqvar.ProductName;                 
                    if(reqvar.Oracle_ID != null)
                        respvar.INVENTORY_ITEM_ID = reqvar.Oracle_ID; 
                    if(reqvar.BomProductname != null)    
                        respvar.ASSEMBLY_ITEM_ID = reqvar.BomProductname;
                    respvarlist.add(respvar);
                    
                    
                }
                if(reqvar.ProductBusinessArea == null || reqvar.ProductBusinessArea ==''){
                    blnFinalResult = true;
                    respvar = new ResponseWraperClass();  
                    respvar.result ='Failure';
                    respvar.Errorcode = 'IMP-ERR-101';
                    respvar.ErrorMessage = 'Failure: Product Business Area is missing in the data, please check the data';
                    if(reqvar.ProductBusinessArea != null)
                        respvar.TransactionNameAndValue = 'Product: '+reqvar.ProductBusinessArea;
                    if(reqvar.Record_type != null)
                        respvar.RECORD_TYPE = reqvar.Record_type; 
                    if(reqvar.ProductName != null)                    
                        respvar.ITEM_NUMBER = reqvar.ProductName;                 
                    if(reqvar.Oracle_ID != null)
                        respvar.INVENTORY_ITEM_ID = reqvar.Oracle_ID; 
                    if(reqvar.BomProductname != null)    
                        respvar.ASSEMBLY_ITEM_ID = reqvar.BomProductname;
                    respvarlist.add(respvar);
                    
                   
                }
                if(reqvar.ProductType == null || reqvar.ProductType ==''){
                    blnFinalResult = true;
                    respvar = new ResponseWraperClass();  
                    respvar.result ='Failure';
                    respvar.Errorcode = 'IMP-ERR-101';
                    respvar.ErrorMessage = 'Failure: Product Type is missing in the data, please check the data';
                    if(reqvar.ProductType != null)
                        respvar.TransactionNameAndValue = 'Product: '+reqvar.ProductType;
                    if(reqvar.Record_type != null)
                        respvar.RECORD_TYPE = reqvar.Record_type; 
                    if(reqvar.ProductName != null)                    
                        respvar.ITEM_NUMBER = reqvar.ProductName;                 
                    if(reqvar.Oracle_ID != null)
                        respvar.INVENTORY_ITEM_ID = reqvar.Oracle_ID;  
                    if(reqvar.BomProductname != null)  
                        respvar.ASSEMBLY_ITEM_ID = reqvar.BomProductname;
                    respvarlist.add(respvar);

                    
                }
                if(reqvar.ProductSubType == null || reqvar.ProductSubType ==''){
                    blnFinalResult = true;
                    respvar = new ResponseWraperClass();  
                    respvar.result ='Failure';
                    respvar.Errorcode = 'IMP-ERR-101';
                    respvar.ErrorMessage = 'Failure: Product Sub Type is missing in the data, please check the data';
                    if(reqvar.ProductSubType != null)       
                        respvar.TransactionNameAndValue = 'Product: '+reqvar.ProductSubType;
                    if(reqvar.Record_type != null)
                        respvar.RECORD_TYPE = reqvar.Record_type; 
                    if(reqvar.ProductName != null)                    
                        respvar.ITEM_NUMBER = reqvar.ProductName;                 
                    if(reqvar.Oracle_ID != null)
                        respvar.INVENTORY_ITEM_ID = reqvar.Oracle_ID; 
                    if(reqvar.BomProductname != null)   
                        respvar.ASSEMBLY_ITEM_ID = reqvar.BomProductname;
                    respvarlist.add(respvar);
                    
                    
                }
                if(reqvar.ProductStatus == null || reqvar.ProductStatus ==''){
                    blnFinalResult = true;
                    respvar = new ResponseWraperClass();  
                    respvar.result ='Failure';
                    respvar.Errorcode = 'IMP-ERR-101';
                    respvar.ErrorMessage = 'Failure: Product Status is missing in the data, please check the data';
                    if(reqvar.ProductStatus != null)
                        respvar.TransactionNameAndValue = 'Product: '+reqvar.ProductStatus;
                    if(reqvar.Record_type != null)
                        respvar.RECORD_TYPE = reqvar.Record_type; 
                    if(reqvar.ProductName != null)                    
                        respvar.ITEM_NUMBER = reqvar.ProductName;                 
                    if(reqvar.Oracle_ID != null)
                        respvar.INVENTORY_ITEM_ID = reqvar.Oracle_ID;
                    if(reqvar.BomProductname != null)    
                        respvar.ASSEMBLY_ITEM_ID = reqvar.BomProductname;
                    respvarlist.add(respvar);
                    
                    
                }
                
                if(reqvar.ProductName!=null && reqvar.ProductName!='' && productmap.get(reqvar.ProductName)!=null)
                {
                    productvar =    productmap.get(reqvar.ProductName);
                    forupdate = true;
                }
                else 
                {   
                    //if(reqvar.ProductActive!=null && reqvar.ProductActive!='' && reqvar.ProductActive.equalsIgnoreCase('yes'))
                    productvar = new product2();
                }   
                
                if(forupdate)
                {   
                    if(reqvar.ProductDescription !=null){
                        if(productvar.Name!=reqvar.ProductDescription.trim())
                        {         
                            PorductUpdatesMap.put(reqvar.ProductName,reqvar.ProductDescription.trim());
                        }
                    }       
                    if((reqvar.ProductActive!=null && reqvar.ProductActive!='' && reqvar.ProductActive.equalsIgnoreCase('no') && reqvar.ProductName != null) || ((reqvar.ProductActive == null || reqvar.ProductActive =='')&& reqvar.ProductName != null))
                        productstobedeleted.add(reqvar.ProductName);
                }
                
                if(reqvar.ProductDescription !=null)
                    productvar.Name = reqvar.ProductDescription.trim();
                if(reqvar.Oracle_ID !=null)
                    productvar.Oracle_ID__c = reqvar.Oracle_ID;
                
                //productvar.Long_Description__c = reqvar.ProductDescription;
                if(reqvar.ProductLongDescription !=null)
                    productvar.Long_Description__c = reqvar.ProductLongDescription;
                if(reqvar.ProductGroup !=null)
                    productvar.Product_Group__c = reqvar.ProductGroup;
                if(reqvar.ProductLine !=null)
                    productvar.Product_Line__c = reqvar.ProductLine;
                if(reqvar.ProductBusinessArea !=null)
                    productvar.Business_Area__c = reqvar.ProductBusinessArea;
                if(reqvar.ProductType !=null)
                    productvar.Type__c = reqvar.ProductType;
                if(reqvar.ProductSubType !=null)
                    productvar.sub_type__c = reqvar.ProductSubType; 
                if(reqvar.ProductStatus !=null)
                    productvar.status__c = reqvar.ProductStatus;
                if(reqvar.ProductName !=null)
                    productvar.ProductCode = reqvar.ProductName;
                if(reqvar.Contract_Item_Type_Code !=null)
                    productvar.Contract_Item_Type_Code__c = reqvar.Contract_Item_Type_Code;
                if(reqvar.ProductActive !=null)
                    productvar.IsActive = (reqvar.ProductActive!=null && reqvar.ProductActive!='')?(reqvar.ProductActive.equalsIgnoreCase('yes')?true:false):false;
                if(reqvar.productNameDE !=null)
                    productvar.Product_Name_DE__c = reqvar.productNameDE;  
                if(reqvar.productNameEN !=null)
                    productvar.Product_Name_EN__c = reqvar.productNameEN;   
                if(reqvar.productNameFR !=null)
                    productvar.Product_Name_FR__c = reqvar.productNameFR;    
                if(reqvar.longDescriptionDE !=null)
                    productvar.Long_Desc_DE__c = reqvar.longDescriptionDE;       
                if(reqvar.longDescriptionEN !=null)
                    productvar.Long_Desc_EN__c = reqvar.longDescriptionEN;     
                if(reqvar.longDescriptionFR !=null)
                    productvar.Long_Desc_FR__c = reqvar.longDescriptionFR;
                if(reqvar.ProductFamily !=null)
                    productvar.Family = reqvar.ProductFamily;
                if(reqvar.productLineDescription !=null)
                    productvar.Product_Line_Description__c = reqvar.productLineDescription;
                if(reqvar.ProductSubType !=null)
                    productvar.Product_Family_Description__c = reqvar.ProductSubType;
                if(reqvar.ProductType !=null)
                    productvar.Product_Group_Description__c = reqvar.ProductType; 
                
                productvar.TNV_Acting_Category__c = reqvar.attribute1;
                productvar.ICC_Type__c = reqvar.attribute2;
                productvar.PPM_Item__c = reqvar.attribute3;
                productvar.Apttus_Config2__Uom__c = reqvar.attribute4;
                productvar.Oracle_Sales_Price_Type__c = reqvar.attribute5;
                productvar.Seat_Count__c = reqvar.attribute6;   
                productvar.BA_Number__c = reqvar.attribute7; // added for mapping BANumber value from Oracle to Salesforce
                productlist.add(productvar); 
               
            }           
            
        }
        
        if(productlist!=null && productlist.size()>0)
        {
            srList = Database.Upsert(productlist,product2.Fields.Id,false);      
            MastersrList.add(srList);               
        }
        
        //Bundle Deactivation Code
        if(productstobedeleted!=null && productstobedeleted.size()>0)
        {   
            for(Apttus_Config2__ProductOptionGroup__c ProductOptVar:[select id,ProductCode__c from Apttus_Config2__ProductOptionGroup__c where ProductCode__c in : productstobedeleted])
            {               
                OptionGRpIdsSet.add(ProductOptVar.id);
            }
            for(Apttus_Config2__ClassificationName__c categoryvar:[select id,ProductCode__c from Apttus_Config2__ClassificationName__c where ProductCode__c in : productstobedeleted ])
            {
                categorylisttobedeleted.add(categoryvar);           
            }
            for(Apttus_Config2__ProductOptionComponent__c OptCompVar:[select id,Apttus_Config2__ProductOptionGroupId__c from Apttus_Config2__ProductOptionComponent__c where Apttus_Config2__ProductOptionGroupId__c in : OptionGRpIdsSet])
            {
                OptComplisttobedeleted.add(OptCompVar);
            }
            
        }
        
        /*
        if(categorylisttobedeleted!=null && categorylisttobedeleted.size()>0)
        {
            delete categorylisttobedeleted;
        }   
       
         if(OptComplisttobedeleted!=null && OptComplisttobedeleted.size()>0)
        {
            delete OptComplisttobedeleted;
        }
        */  
        //End -- Bundle Deactivation Code
        
         for(product2 newprodvar:[select id,Name,Oracle_ID__c,ProductCode,Long_Description__c,Business_Area__c,Product_Type__c,sub_type__c,status__c,IsActive from product2 where ProductCode in: productnamesSet and isactive= : true])
        {
            newproductmap.put(newprodvar.ProductCode,newprodvar);
            //productmapForBundle.put(newprodvar.id,newprodvar.Oracle_ID__c);
        }   
        
        if(bundleproductnamesSet!=null && bundleproductnamesSet.size()>0){
            for(product2 newprodvar1:[select id,Name,Oracle_ID__c,ProductCode,Long_Description__c,Business_Area__c,Product_Type__c,sub_type__c,status__c,IsActive from product2 where oracle_id__c in: bundleproductnamesSet and isactive= : true])
            {            
                productmapForBundle.put(newprodvar1.id,newprodvar1.Oracle_ID__c);
                ProductCompOptUpdatemap.put(newprodvar1.Oracle_ID__c,newprodvar1.ProductCode);
            } 
        }
        
        for(requestdata reqvar:requesrwrapervar)
        {
            if(reqvar.Record_type == null || reqvar.Record_type == ''){
                blnFinalResult = true;
                respvar = new ResponseWraperClass();  
                respvar.result ='Failure';
                respvar.Errorcode = 'IMP-ERR-101';
                respvar.ErrorMessage = 'Failure: Record type is missing in the data.Please check the data';
                if(reqvar.Record_type != null)  
                    respvar.TransactionNameAndValue = 'Product: '+reqvar.Record_type;
                if(reqvar.Record_type != null)
                    respvar.RECORD_TYPE = reqvar.Record_type; 
                if(reqvar.ProductName != null)                    
                    respvar.ITEM_NUMBER = reqvar.ProductName;                 
                if(reqvar.Oracle_ID != null)
                    respvar.INVENTORY_ITEM_ID = reqvar.Oracle_ID;    
                if(reqvar.BomProductname != null)
                    respvar.ASSEMBLY_ITEM_ID = reqvar.BomProductname;
                respvarlist.add(respvar);
                
                
                
            }
            if((reqvar.Record_type != null && reqvar.Record_type != '') && reqvar.Record_type.equalsIgnoreCase('bom'))
            {   
                //integer count  = [select count() from product2 where name=:reqvar.ProductName.trim() limit 1];
                if((reqvar.ProductName == null || reqvar.ProductName == '') )
                {
                    blnFinalResult = true;
                    respvar = new ResponseWraperClass();  
                    respvar.result ='Failure';
                    respvar.Errorcode = 'IMP-ERR-101';
                    respvar.ErrorMessage = 'Failure: Please check the BOM Product Name and resend the Data';
                    if(reqvar.ProductName != null)
                        respvar.TransactionNameAndValue = 'Product: '+reqvar.ProductName;
                    if(reqvar.Record_type != null)
                        respvar.RECORD_TYPE = reqvar.Record_type; 
                    if(reqvar.ProductName != null)                    
                        respvar.ITEM_NUMBER = reqvar.ProductName;                 
                    if(reqvar.Oracle_ID != null)
                        respvar.INVENTORY_ITEM_ID = reqvar.Oracle_ID;
                    if(reqvar.BomProductname != null)    
                        respvar.ASSEMBLY_ITEM_ID = reqvar.BomProductname;
                    respvarlist.add(respvar);

                    
                }    
                if((newproductmap!=null && reqvar.ProductName!=null && reqvar.ProductName!='' && newproductmap.get(reqvar.ProductName) == null) ){
                    blnFinalResult = true;
                    respvar = new ResponseWraperClass();  
                    respvar.result ='Failure';
                    respvar.Errorcode = 'IMP-ERR-101';
                    respvar.ErrorMessage = 'Failure: BOM Product Name does not exist in SFDC.please send a existing bundle name.';
                    if(reqvar.ProductName != null) 
                        respvar.TransactionNameAndValue = 'Product: '+reqvar.ProductName;
                    if(reqvar.Record_type != null)
                        respvar.RECORD_TYPE = reqvar.Record_type; 
                    if(reqvar.ProductName != null)                    
                        respvar.ITEM_NUMBER = reqvar.ProductName;                 
                    if(reqvar.Oracle_ID != null)
                        respvar.INVENTORY_ITEM_ID = reqvar.Oracle_ID;
                    if(reqvar.BomProductname != null)    
                        respvar.ASSEMBLY_ITEM_ID = reqvar.BomProductname;
                    respvarlist.add(respvar);
                    
                    
                }
               
                if(classificationmap!=null && reqvar.ProductName!=null && reqvar.ProductName!='' && classificationmap.get(reqvar.ProductName)!=null)
                {
                    configvar = classificationmap.get(reqvar.ProductName);
                }
                else
                configvar = new Apttus_Config2__ClassificationName__c();
                
                configvar.Name = (reqvar.ProductDescription!=null && reqvar.ProductDescription!='')?reqvar.ProductDescription.trim():newproductmap.get(reqvar.ProductName).Name;   
                
                //system.debug('reqvar.ProductDescription============='+reqvar.ProductDescription+'=====newproductmap.get(reqvar.ProductName).Name======'+newproductmap.get(reqvar.ProductName).Name);                              
                if(reqvar.ProductName != null)
                    configvar.productcode__c = reqvar.ProductName;
                configvar.Apttus_Config2__HierarchyLabel__c = (reqvar.ProductDescription!=null && reqvar.ProductDescription!='')?reqvar.ProductDescription.trim():newproductmap.get(reqvar.ProductName).Name;
                configvar.Apttus_Config2__Active__c  = true;
                configvar.Apttus_Config2__Type__c = 'Option Group';
                
                                
                if(bundleproductcodemap!=null && bundleproductcodemap.get(reqvar.ProductName)!=null && bundleproductcodemap.get(reqvar.ProductName)!='')
                {
                    product2 p = newproductmap.get(reqvar.ProductName);
                    p.Apttus_Config2__ConfigurationType__c = 'Bundle';
                    p.Apttus_Config2__HasOptions__c = true;
                    bundleproductupdatelist.add(p);
                }
                
                configObjlist.add(configvar);
              
            }
            
        }
         if(configObjlist!=null && configObjlist.size()>0)
        {          
            Database.UpsertResult[] srList1 = Database.upsert(configObjlist,Apttus_Config2__ClassificationName__c.Fields.Id,false);
            //MastersrList.add(srList1);   
            
        } 
        if(bundleproductupdatelist!=null && bundleproductupdatelist.size()>0)
        update bundleproductupdatelist;
        
        system.debug('PorductUpdatesMap============'+PorductUpdatesMap);
        
        if(PorductUpdatesMap!=null && PorductUpdatesMap.size()>0)
        {
            for(Apttus_Config2__ClassificationName__c objvar2:[select id,Name,productcode__c,Apttus_Config2__HierarchyLabel__c,Apttus_Config2__Active__c,Apttus_Config2__Type__c from Apttus_Config2__ClassificationName__c where ProductCode__c in: PorductUpdatesMap.keyset()])
            {
                objvar2.Name = PorductUpdatesMap.get(objvar2.productcode__c);
                objvar2.Apttus_Config2__HierarchyLabel__c = PorductUpdatesMap.get(objvar2.productcode__c);
                Updatecategorylist.add(objvar2);
            }
        }
        
        system.debug('Updatecategorylist============='+Updatecategorylist);
        
        if(Updatecategorylist!=null && Updatecategorylist.size()>0)
        update Updatecategorylist;
        
        for(Apttus_Config2__ClassificationName__c objvar1:[select id,Name,productcode__c,Apttus_Config2__HierarchyLabel__c,Apttus_Config2__Active__c,Apttus_Config2__Type__c from Apttus_Config2__ClassificationName__c where ProductCode__c in: productnamesSet])
        {
                Insertedclassificationmap.put(objvar1.ProductCode__c,objvar1);
        }
        
         for(requestdata reqvar:requesrwrapervar)
        { 
            //Code to check for the Product which is a Bundle product and insert in SFDC
            if((reqvar.Record_type != null && reqvar.Record_type != '') && reqvar.Record_type.equalsIgnoreCase('bom'))
            {
                    //integer count  = [select count() from product2 where name=:reqvar.ProductName.trim() limit 1];
                    if((reqvar.ProductName == null || reqvar.ProductName == '') )
                    {
                        blnFinalResult = true;
                        respvar = new ResponseWraperClass();  
                        respvar.result ='Failure';
                        respvar.Errorcode = 'IMP-ERR-101';
                        respvar.ErrorMessage = 'Failure: Please check the bundle Name and resend the Data';
                        if(reqvar.ProductName != null)
                            respvar.TransactionNameAndValue = 'Product: '+reqvar.ProductName;
                        if(reqvar.Record_type != null)
                            respvar.RECORD_TYPE = reqvar.Record_type; 
                        if(reqvar.ProductName != null)                    
                            respvar.ITEM_NUMBER = reqvar.ProductName;                 
                        if(reqvar.Oracle_ID != null)
                            respvar.INVENTORY_ITEM_ID = reqvar.Oracle_ID;  
                        if(reqvar.BomProductname != null)   
                            respvar.ASSEMBLY_ITEM_ID = reqvar.BomProductname;
                        respvarlist.add(respvar);
                        
                        
                    }    
                    if((newproductmap!=null && reqvar.ProductName!=null && reqvar.ProductName!='' && newproductmap.get(reqvar.ProductName) == null) ){
                        blnFinalResult = true;
                        respvar = new ResponseWraperClass();  
                        respvar.result ='Failure';
                        respvar.Errorcode = 'IMP-ERR-101';
                        respvar.ErrorMessage = 'Failure: BOM Product Name does not exist in SFDC.please send a existing bundle name.';
                        if(reqvar.ProductName != null)
                            respvar.TransactionNameAndValue = 'Product: '+reqvar.ProductName;
                        if(reqvar.Record_type != null)
                            respvar.RECORD_TYPE = reqvar.Record_type; 
                        if(reqvar.ProductName != null)                    
                            respvar.ITEM_NUMBER = reqvar.ProductName;                 
                        if(reqvar.Oracle_ID != null)
                            respvar.INVENTORY_ITEM_ID = reqvar.Oracle_ID;
                        if(reqvar.BomProductname != null)   
                            respvar.ASSEMBLY_ITEM_ID = reqvar.BomProductname;
                        respvarlist.add(respvar);
                        
                        
                    }
                    
                    if(classificationHirmap!=null && reqvar.ProductName!=null && reqvar.ProductName!='' && classificationHirmap.get(reqvar.ProductName)!=null)
                        configHierVar = classificationHirmap.get(reqvar.ProductName);
                    else                                      
                        configHierVar = new Apttus_Config2__ClassificationHierarchy__c();
                    
                    configHierVar.Name = (reqvar.ProductDescription!=null && reqvar.ProductDescription!='')?reqvar.ProductDescription.trim():newproductmap.get(reqvar.ProductName).Name;
                    //configHierVar.Name = reqvar.ProductName.trim();
                    configHierVar.Apttus_Config2__Left__c = 1;                    
                    configHierVar.Apttus_Config2__Level__c = 0;
                    configHierVar.Apttus_Config2__Right__c = 2;
                    //configHierVar.Apttus_Config2__Label__c = reqvar.ProductName.trim();
                    configHierVar.Apttus_Config2__Label__c = (reqvar.ProductDescription!=null && reqvar.ProductDescription!='')?reqvar.ProductDescription.trim():newproductmap.get(reqvar.ProductName).Name;
                    if(reqvar.ProductName != null)
                        configHierVar.productcode__c = reqvar.ProductName;
                    
                    if(Insertedclassificationmap!=null && reqvar.ProductName!=null && reqvar.ProductName!='' && Insertedclassificationmap.get(reqvar.ProductName)!=null)
                    {
                            addtolist = true;
                            if(configHierVar.Apttus_Config2__HierarchyId__c == null)
                            {            
                                configHierVar.Apttus_Config2__HierarchyId__c = Insertedclassificationmap.get(reqvar.ProductName).id;
                                
                            }
                    }             
                    
                    ////system.debug('configHierVar.Apttus_Config2__HierarchyId__c======'+configHierVar.Apttus_Config2__HierarchyId__c);
                    if(addtolist == true)  
                    configHierObjlist.add(configHierVar);
                    
            }
            
        }
        
        //Upsert the Classification Hierarchy Records    
        if(configHierObjlist!=null && configHierObjlist.size()>0)
        {          
            Database.UpsertResult[] srList1 = Database.upsert(configHierObjlist,Apttus_Config2__ClassificationHierarchy__c.Fields.Id,false);            
            //MastersrList.add(srList1);    
        }
        
        
        list<Apttus_Config2__ClassificationHierarchy__c> updateCatHierList = new list<Apttus_Config2__ClassificationHierarchy__c>();
        if(PorductUpdatesMap!=null && PorductUpdatesMap.size()>0)
        {
            for(Apttus_Config2__ClassificationHierarchy__c hiervar2:[select id,Name,productcode__c,Apttus_Config2__Left__c,Apttus_Config2__HierarchyId__c,Apttus_Config2__Level__c,Apttus_Config2__Right__c,Apttus_Config2__Label__c from Apttus_Config2__ClassificationHierarchy__c where productcode__c in: PorductUpdatesMap.keyset()])
            {
                hiervar2.Name = PorductUpdatesMap.get(hiervar2.productcode__c);
                
                updateCatHierList.add(hiervar2);
            }
        }
        
        //Update the category hierarchy list when the produt is updated
        if(updateCatHierList!=null && updateCatHierList.size()>0)
        update updateCatHierList;
        
        
                       
        for(Apttus_Config2__ClassificationHierarchy__c hiervar1:[select id,Name,productcode__c,Apttus_Config2__Left__c,Apttus_Config2__HierarchyId__c,Apttus_Config2__Level__c,Apttus_Config2__Right__c,Apttus_Config2__Label__c from Apttus_Config2__ClassificationHierarchy__c where productcode__c in: productnamesset])
        {
            InsertedclassificationHirmap.put(hiervar1.productcode__c,hiervar1);
        }       
        for(Apttus_Config2__ClassificationHierarchy__c hiervar1:[select id,Name,productcode__c,Apttus_Config2__Left__c,Apttus_Config2__HierarchyId__c,Apttus_Config2__Level__c,Apttus_Config2__Right__c,Apttus_Config2__Label__c from Apttus_Config2__ClassificationHierarchy__c where productcode__c in: bundleproductnamesSet])
        {
            InsertedclassificationHirmap1.put(hiervar1.productcode__c,hiervar1);
        }
        
        
        
        for(Apttus_Config2__ProductOptionGroup__c prodoptvar : [select id,Name,productcode__c,Apttus_Config2__RootOptionGroupId__c,Apttus_Config2__Left__c,Apttus_Config2__MaxOptions__c,Apttus_Config2__MinOptions__c,Apttus_Config2__Level__c,Apttus_Config2__Right__c,Apttus_Config2__OptionGroupId__c,Apttus_Config2__ProductId__c,Apttus_Config2__Sequence__c from Apttus_Config2__ProductOptionGroup__c where productcode__c in : productnamesSet])
        {
                ProdOptmap.put(prodoptvar.productcode__c,prodoptvar); 
                SeqProdOptmap.put(prodoptvar.id,integer.valueof(prodoptvar.Apttus_Config2__MaxOptions__c));         
        }
        
        
        
        for(requestdata reqvar:requesrwrapervar)
        {
            if(reqvar.Record_type == null || reqvar.Record_type == ''){
                blnFinalResult = true;
                respvar = new ResponseWraperClass();  
                respvar.result ='Failure';
                respvar.Errorcode = 'IMP-ERR-101';
                respvar.ErrorMessage = 'Failure: Record type is missing in the data.Please check the data';
                if(reqvar.Record_type != null)
                    respvar.TransactionNameAndValue = 'Product: '+reqvar.Record_type;
                if(reqvar.Record_type != null)
                    respvar.RECORD_TYPE = reqvar.Record_type; 
                if(reqvar.ProductName != null)                    
                    respvar.ITEM_NUMBER = reqvar.ProductName;                 
                if(reqvar.Oracle_ID != null)
                    respvar.INVENTORY_ITEM_ID = reqvar.Oracle_ID;
                if(reqvar.BomProductname != null)   
                    respvar.ASSEMBLY_ITEM_ID = reqvar.BomProductname;
                respvarlist.add(respvar);
                
                
            }
            
            if((reqvar.Record_type != null && reqvar.Record_type != '') && reqvar.Record_type.equalsIgnoreCase('bom'))
            {   
                //integer count  = [select count() from product2 where name=:reqvar.ProductName.trim() limit 1];
                 if((reqvar.ProductName == null || reqvar.ProductName == '') )
                {
                    blnFinalResult = true;
                    respvar = new ResponseWraperClass();  
                    respvar.result ='Failure';
                    respvar.Errorcode = 'IMP-ERR-101';
                    respvar.ErrorMessage = 'Failure: Please check the Product Name and resend the Data';
                    if(reqvar.ProductName != null)
                        respvar.TransactionNameAndValue = 'Product: '+reqvar.ProductName;
                    if(reqvar.Record_type != null)
                        respvar.RECORD_TYPE = reqvar.Record_type; 
                    if(reqvar.ProductName != null)                    
                        respvar.ITEM_NUMBER = reqvar.ProductName;                 
                    if(reqvar.Oracle_ID != null)
                        respvar.INVENTORY_ITEM_ID = reqvar.Oracle_ID; 
                    if(reqvar.BomProductname != null)   
                        respvar.ASSEMBLY_ITEM_ID = reqvar.BomProductname;
                    respvarlist.add(respvar);

                    
                }    
                if((newproductmap!=null && reqvar.ProductName!=null && reqvar.ProductName!='' && newproductmap.get(reqvar.ProductName) == null) ){
                    blnFinalResult = true;
                    respvar = new ResponseWraperClass();  
                    respvar.result ='Failure';
                    respvar.Errorcode = 'IMP-ERR-101';
                    respvar.ErrorMessage = 'Failure: Product name does not exist in SFDC.please send a existing bundle name.';
                    if(reqvar.ProductName != null)
                        respvar.TransactionNameAndValue = 'Product: '+reqvar.ProductName;
                    if(reqvar.Record_type != null)
                        respvar.RECORD_TYPE = reqvar.Record_type; 
                    if(reqvar.ProductName != null)                    
                        respvar.ITEM_NUMBER = reqvar.ProductName;                 
                    if(reqvar.Oracle_ID != null)
                        respvar.INVENTORY_ITEM_ID = reqvar.Oracle_ID;    
                    if(reqvar.BomProductname != null)
                        respvar.ASSEMBLY_ITEM_ID = reqvar.BomProductname;
                    respvarlist.add(respvar);

                    
                } 
               
                ////system.debug('reqvar.ProductName======'+reqvar.ProductName);
                 if(newproductmap!=null && reqvar.ProductName!=null && reqvar.ProductName!='' && newproductmap.get(reqvar.ProductName)!=null)
                {
                    strproductid1 = newproductmap.get(reqvar.ProductName).id;
                }
                
                
                if(InsertedclassificationHirmap!=null && reqvar.ProductName!=null && reqvar.ProductName!='' && InsertedclassificationHirmap.get(reqvar.ProductName)!=null)
                {
                    categoryHierId1 = InsertedclassificationHirmap.get(reqvar.ProductName).id;
                }

                if((ProdOptmap!=null && reqvar.ProductName!=null && reqvar.ProductName!='' && ProdOptmap.get(reqvar.ProductName) != null)  )
                    ProOptVar =  ProdOptmap.get(reqvar.ProductName);
                else                                      
                    ProOptVar = new Apttus_Config2__ProductOptionGroup__c();
                
                
                
                if(categoryHierId1!=null && categoryHierId1!=''){
                    ProOptVar.Apttus_Config2__RootOptionGroupId__c = categoryHierId1;
                    if(ProOptVar.Apttus_Config2__OptionGroupId__c == null)
                    ProOptVar.Apttus_Config2__OptionGroupId__c = categoryHierId1;
                    ////system.debug('ProOptVar.Apttus_Config2__OptionGroupId__c====='+ProOptVar.Apttus_Config2__OptionGroupId__c);
               }
               
                if((newproductmap!=null && reqvar.ProductName!=null && reqvar.ProductName!='' && newproductmap.get(reqvar.ProductName) != null) )
                ProOptVar.Apttus_Config2__ProductId__c = strproductid1;
                
                
                ProOptVar.Apttus_Config2__Sequence__c = 0;
                ProOptVar.Apttus_Config2__Left__c = 1;
                ProOptVar.Apttus_Config2__Right__c = 2;
                ProOptVar.Apttus_Config2__Level__c = 0;
                if(reqvar.ProductName != null)
                    ProOptVar.productcode__c = reqvar.ProductName;
                ProOptVar.Apttus_Config2__IsLeaf__c = true;
                ProOptVar.Apttus_Config2__MinOptions__c = (reqvar.ComponentQuantity!=null && reqvar.ComponentQuantity!='') ? Decimal.valueOf(reqvar.ComponentQuantity):0;
                ProOptVar.Apttus_Config2__MaxOptions__c = (reqvar.ComponentQuantity!=null && reqvar.ComponentQuantity!='') ? Decimal.valueOf(reqvar.ComponentQuantity):0;
                
                if(categoryHierId1!=null && categoryHierId1!='')
                ProductOptionList.add(ProOptVar);
                
                system.debug('categoryHierId1============'+categoryHierId1);
                system.debug('ProductOptionList============'+ProductOptionList);
            }
            
            
        }   
        
        if(ProductOptionList!=null && ProductOptionList.size()>0)
        {          
            Database.UpsertResult[] srList1 = Database.upsert(ProductOptionList,Apttus_Config2__ProductOptionGroup__c.Fields.Id,false);           
            
            MastersrList.add(srList1);
        }       
        
        
        
        
        system.debug('map size============'+InsertedProdOptmap);
        set<string> componentIdset = new set<string>();
        for(product2 bomprodvar:[select id,Name,Oracle_ID__c,ProductCode,Long_Description__c,Business_Area__c,Product_Type__c,sub_type__c,status__c,IsActive from product2 where Oracle_ID__c in: bundleproductnamesSet and isactive= : true])
        {
            bundleproductmap.put(bomprodvar.Oracle_ID__c,bomprodvar);
            componentIdset.add(bomprodvar.productcode);
            
        }
        
        //for(Apttus_Config2__ProductOptionGroup__c productoptvar1:[select id,Name,productcode__c,Apttus_Config2__RootOptionGroupId__c,Apttus_Config2__Left__c,Apttus_Config2__MaxOptions__c,Apttus_Config2__MinOptions__c,Apttus_Config2__Level__c,Apttus_Config2__Right__c,Apttus_Config2__OptionGroupId__c,Apttus_Config2__ProductId__c,Apttus_Config2__Sequence__c from Apttus_Config2__ProductOptionGroup__c  where productcode__c in: ProductCompOptUpdatemap.values()])
        for(Apttus_Config2__ProductOptionGroup__c productoptvar1:[select id,Name,productcode__c,Apttus_Config2__RootOptionGroupId__c,Apttus_Config2__Left__c,Apttus_Config2__MaxOptions__c,Apttus_Config2__MinOptions__c,Apttus_Config2__Level__c,Apttus_Config2__Right__c,Apttus_Config2__OptionGroupId__c,Apttus_Config2__ProductId__c,Apttus_Config2__Sequence__c from Apttus_Config2__ProductOptionGroup__c  where productcode__c in: componentIdset])
        {
            InsertedProdOptmap.put(productoptvar1.productcode__c,productoptvar1);
            //ProdOptmapTobeUpdated.put(productoptvar1.id,productoptvar1);
        }
       
        system.debug('bundleproductnamesSet========='+bundleproductnamesSet);
        system.debug('bundleproductmap=========='+bundleproductmap);
        ////system.debug('productmapForBundle=============='+productmapForBundle);
        
        
         for(Apttus_Config2__ProductOptionComponent__c ProdCompVar:[select id,Name,oracle_id__c,productcode__c,Apttus_Config2__ProductOptionGroupId__c,Apttus_Config2__Sequence__c,Apttus_Config2__ParentProductId__c,Apttus_Config2__ComponentProductId__c from Apttus_Config2__ProductOptionComponent__c where productcode__c in : productnamesSet])
        {
                ////system.debug('productmapForBundle.get(ProdCompVar.Apttus_Config2__ComponentProductId__c)============'+productmapForBundle.get(ProdCompVar.Apttus_Config2__ComponentProductId__c));
                ////system.debug('ProdCompVar.Apttus_Config2__ComponentProductId__c==========='+ProdCompVar.Apttus_Config2__ComponentProductId__c);
                
                ProdOptCompMap.put(ProdCompVar.ProductCode__c+ProdCompVar.oracle_id__c+productmapForBundle.get(ProdCompVar.Apttus_Config2__ParentProductId__c),ProdCompVar);
                
        }
        
        //system.debug('ProdOptCompMap====='+ProdOptCompMap);
        
        for(Apttus_Config2__ProductClassification__c prodclassifyvar : [select id,Name,BomProductCode__c,oracle_id__c,productcode__c,Apttus_Config2__ClassificationId__c,Apttus_Config2__ProductId__c,Apttus_Config2__DefaultQuantity__c,Apttus_Config2__MaxQuantity__c,Apttus_Config2__MinQuantity__c from Apttus_Config2__ProductClassification__c where productcode__c in: productnamesSet])
        {   
            ////system.debug('prodclassifyvar.oracle_id__c============'+prodclassifyvar.oracle_id__c);          
            ProdClassyfyMap.put(prodclassifyvar.ProductCode__c+prodclassifyvar.oracle_id__c+prodclassifyvar.BomProductCode__c,prodclassifyvar);
        }
        //system.debug('ProdOptCompMap============'+ProdOptCompMap);
        //system.debug('ProdClassyfyMap============'+ProdClassyfyMap);
       
       bundleproductupdatelist = new list<product2>();
        
        for(requestdata reqvar:requesrwrapervar)
        {
            if(reqvar.Record_type == null || reqvar.Record_type == ''){
                blnFinalResult = true;
                respvar = new ResponseWraperClass();  
                respvar.result ='Failure';
                respvar.Errorcode = 'IMP-ERR-101';
                respvar.ErrorMessage = 'Failure: Record type is missing in the data.Please check the data';
                if(reqvar.Record_type != null)  
                    respvar.TransactionNameAndValue = 'Product: '+reqvar.Record_type;
                if(reqvar.Record_type != null)
                    respvar.RECORD_TYPE = reqvar.Record_type; 
                if(reqvar.ProductName != null)                    
                    respvar.ITEM_NUMBER = reqvar.ProductName;                 
                if(reqvar.Oracle_ID != null)
                    respvar.INVENTORY_ITEM_ID = reqvar.Oracle_ID;    
                if(reqvar.BomProductname != null)
                    respvar.ASSEMBLY_ITEM_ID = reqvar.BomProductname;
                respvarlist.add(respvar);
                
                
                
            }
            if((reqvar.Record_type != null && reqvar.Record_type != '') && reqvar.Record_type.equalsIgnoreCase('component'))
            {
                if((reqvar.ProductName == null || reqvar.ProductName == '') )
                {
                    blnFinalResult = true;
                    respvar = new ResponseWraperClass();  
                    respvar.result ='Failure';
                    respvar.Errorcode = 'IMP-ERR-101';
                    respvar.ErrorMessage = 'Failure: Please check the Product Name and resend the Data';
                    if(reqvar.ProductName != null)
                        respvar.TransactionNameAndValue = 'Product: '+reqvar.ProductName;
                    if(reqvar.Record_type != null)
                        respvar.RECORD_TYPE = reqvar.Record_type; 
                    if(reqvar.ProductName != null)                    
                        respvar.ITEM_NUMBER = reqvar.ProductName;                 
                    if(reqvar.Oracle_ID != null)
                        respvar.INVENTORY_ITEM_ID = reqvar.Oracle_ID; 
                    if(reqvar.BomProductname != null)   
                        respvar.ASSEMBLY_ITEM_ID = reqvar.BomProductname;
                    respvarlist.add(respvar);

                    
                }  
                if((reqvar.BomProductname == null || reqvar.BomProductname == '') )
                {
                    blnFinalResult = true;
                    respvar = new ResponseWraperClass();  
                    respvar.result ='Failure';
                    respvar.Errorcode = 'IMP-ERR-101';
                    respvar.ErrorMessage = 'Failure: Please check the BOM Product Name and resend the Data';
                    if(reqvar.BomProductname != null)
                        respvar.TransactionNameAndValue = 'Product: '+reqvar.BomProductname;
                    if(reqvar.Record_type != null)
                        respvar.RECORD_TYPE = reqvar.Record_type; 
                    if(reqvar.ProductName != null)                    
                        respvar.ITEM_NUMBER = reqvar.ProductName;                 
                    if(reqvar.Oracle_ID != null)
                        respvar.INVENTORY_ITEM_ID = reqvar.Oracle_ID; 
                    if(reqvar.BomProductname != null)   
                        respvar.ASSEMBLY_ITEM_ID = reqvar.BomProductname;
                    respvarlist.add(respvar);

                    
                }  
                //integer count2 = [select count() from Product2 where Oracle_ID__c=:reqvar.bomProductname limit 1];
                date datevar;
                if(reqvar.ComponentEndDate!=null && reqvar.ComponentEndDate!='')
                {
                     string str = reqvar.ComponentEndDate;
                    list<string> li = str.split('T');               
                    datevar = date.valueof(li[0]);
                    
                    //datevar = Date.parse(reqvar.ComponentEndDate);
                
                }
                    
                if(datevar!=null && datevar<=system.today())
                {
                
                    if(ProdOptCompMap!=null && ProdOptCompMap.get(reqvar.ProductName+reqvar.Oracle_ID+reqvar.BomProductname)!=null)
                    {
                        Apttus_Config2__ProductOptionComponent__c ProdComponentvar =  ProdOptCompMap.get(reqvar.ProductName+reqvar.Oracle_ID+reqvar.BomProductname);
                        productoptiongroupidset.add(ProdComponentvar.Apttus_Config2__ProductOptionGroupId__c);
                        
                        OptComTobeDeleted.add(ProdComponentvar);
                    }
                    if(ProdClassyfyMap!=null && ProdClassyfyMap.get(reqvar.ProductName+reqvar.Oracle_ID+reqvar.BomProductname)!=null)
                    {
                        Apttus_Config2__ProductClassification__c ProdClasifyVarObj =  ProdClassyfyMap.get(reqvar.ProductName+reqvar.Oracle_ID+reqvar.BomProductname);                                   
                        ClassifyObjTobeDeleted.add(ProdClasifyVarObj);
                    }   
                    
                    if(componentproductcodemap!=null && componentproductcodemap.get(reqvar.ProductName)!=null && componentproductcodemap.get(reqvar.ProductName)!='' && newproductmap.get(reqvar.ProductName) != null)
                        {
                            //if(reqvar.ProductName!= null)
                            product2 p = newproductmap.get(reqvar.ProductName);
                            p.Apttus_Config2__ConfigurationType__c = 'Standalone';
                            p.Apttus_Config2__HasOptions__c = false;
                            bundleproductupdatelist.add(p);
                        }
                }
                
                else
                {
                        //system.debug('bundleproductmap.get(reqvar.bomProductname)==========='+bundleproductmap.get(reqvar.bomProductname));
                        if(bundleproductmap!=null && reqvar.bomProductname!=null && reqvar.bomProductname!='' && bundleproductmap.get(reqvar.bomProductname)!=null)                
                        {
                            strproductid = bundleproductmap.get(reqvar.bomProductname).id;
                            //MasterProductName = bundleproductmap.get(reqvar.bomProductname).Name;
                            MasterProductName = bundleproductmap.get(reqvar.bomProductname).Productcode;
                        }               
                        
                        //system.debug('reqvar.ProductName====='+reqvar.ProductName);
                        
                         if(newproductmap!=null && MasterProductName!=null && MasterProductName!='' && newproductmap.get(MasterProductName)!=null)
                        {
                            strproductid2 = newproductmap.get(MasterProductName).id;
                        }
                        
                        if(InsertedclassificationHirmap!=null && MasterProductName!=null && MasterProductName!='' && InsertedclassificationHirmap.get(MasterProductName)!=null)
                        {
                            categoryHierId2 = InsertedclassificationHirmap.get(MasterProductName).id;
                        }
                        
                        //if(newproductmap!=null && newproductmap.get(reqvar.ProductName)!=null  )
                        //oracleid = ProdOptCompMap.get(reqvar.ProductName).oracle_id__c;
                        
                        ////system.debug('ProdOptCompMap.get(reqvar.ProductName+optiongroupid)====='+ProdOptCompMap.get(reqvar.ProductName+optiongroupid)+'=======optiongroupid====');
                        //system.debug('reqvar.ProductName+strproductid2======='+reqvar.ProductName+strproductid2);
                        
                        //system.debug('product code======'+reqvar.ProductName+'==========oracle id=========='+reqvar.Oracle_ID+'===========bom product name========='+reqvar.BomProductname);
                        //system.debug('component object=========='+ProdOptCompMap.get(reqvar.ProductName+reqvar.Oracle_ID+reqvar.BomProductname));
                        
                        if(reqvar.ProductName!=null && reqvar.ProductName!='' && ProdOptCompMap!=null && ProdOptCompMap.get(reqvar.ProductName+reqvar.Oracle_ID+reqvar.BomProductname)!=null)
                        ProdCoponentvar =  ProdOptCompMap.get(reqvar.ProductName+reqvar.Oracle_ID+reqvar.BomProductname);
                        else                                      
                        ProdCoponentvar = new Apttus_Config2__ProductOptionComponent__c();                
                        
                        if(reqvar.ProductName!=null)
                            ProdCoponentvar.productcode__c = reqvar.ProductName;
                        
                                       
                        
                        //system.debug('reqvar.ProductName=========='+reqvar.ProductName+'========MasterProductName======='+MasterProductName);
                        //system.debug('    =='+InsertedProdOptmap.get(MasterProductName));
                        
                        if(InsertedProdOptmap!=null && InsertedProdOptmap.get(MasterProductName)!=null  ){
                            ProdCoponentvar.Apttus_Config2__ProductOptionGroupId__c = InsertedProdOptmap.get(MasterProductName).id;                                     
                        }                
                        
                        
                        if(reqvar.ProductName!=null && reqvar.ProductName!='' && newproductmap!=null && newproductmap.get(reqvar.ProductName)!=null){
                            ProdCoponentvar.Apttus_Config2__ComponentProductId__c = newproductmap.get(reqvar.ProductName).id;
                            productid = newproductmap.get(reqvar.ProductName).id;
                            
                        }
                        else
                        {
                            if((!productmap.IsEmpty() && reqvar.ProductName!=null && reqvar.ProductName!='' && productmap.get(reqvar.ProductName) != null)){
                                ProdCoponentvar.Apttus_Config2__ComponentProductId__c = productmap.get(reqvar.ProductName).id;
                                productid = productmap.get(reqvar.ProductName).id;
                            } 
                        }
                        
                        ProdCoponentvar.Apttus_Config2__Sequence__c = (reqvar.ComponentSequenceNumber!=null && reqvar.ComponentSequenceNumber!='')?integer.valueof(reqvar.ComponentSequenceNumber):1;
                        //productid = Insertedproductmap.get(reqvar.ProductName).id;
                        
                        productoptiongroupidset.add(ProdCoponentvar.Apttus_Config2__ProductOptionGroupId__c);                
                        
                        
                        if(productid!=null && productid!=''){           
                        if(bundleproductmap!=null && reqvar.BomProductname!=null && reqvar.BomProductname!='' && bundleproductmap.get(reqvar.BomProductname)!=null)
                        ProdCoponentvar.Apttus_Config2__ParentProductId__c = bundleproductmap.get(reqvar.BomProductname).id;                
                        
                       
                        
                        }
                       
                        ProdCoponentvar.Apttus_Config2__Default__c = true;
                        ProdCoponentvar.Apttus_Config2__DefaultQuantity__c = (reqvar.ComponentQuantity!=null && reqvar.ComponentQuantity!='') ? Decimal.valueOf(reqvar.ComponentQuantity):0;
                        ProdCoponentvar.Apttus_Config2__MaxQuantity__c = (reqvar.ComponentQuantity!=null && reqvar.ComponentQuantity!='') ? Decimal.valueOf(reqvar.ComponentQuantity):0;
                        ProdCoponentvar.Apttus_Config2__MinQuantity__c = (reqvar.ComponentQuantity!=null && reqvar.ComponentQuantity!='') ? Decimal.valueOf(reqvar.ComponentQuantity):0;
                        ProdCoponentvar.oracle_id__c = reqvar.Oracle_ID;
                        ProdCoponentvar.Apttus_Config2__Modifiable__c = false;
                        ProdCoponentvar.Apttus_Config2__Required__c = true;
                        ProductOptionCompList.add(ProdCoponentvar);
                        
                        
                        
                        
                        if(InsertedclassificationHirmap!=null && MasterProductName!=null && MasterProductName!='' && InsertedclassificationHirmap.get(MasterProductName)!=null)
                        categoryHierId = InsertedclassificationHirmap.get(MasterProductName).id;
                        //system.debug('categoryHierId======'+categoryHierId+'=====MasterProductName====='+MasterProductName);
                        
                        
                        if(strproductid!=null && strproductid!='' &&  ProdClassyfyMap!=null && ProdClassyfyMap.get(reqvar.ProductName+reqvar.Oracle_ID+reqvar.BomProductname)!=null)
                        ProdClasifyVar =  ProdClassyfyMap.get(reqvar.ProductName+reqvar.Oracle_ID+reqvar.BomProductname);
                        else                                      
                        ProdClasifyVar = new Apttus_Config2__ProductClassification__c();                
                        
                        ////system.debug('reqvar.ProductName========='+reqvar.ProductName);
                        if(reqvar.ProductName!=null)
                            ProdClasifyVar.productcode__c = reqvar.ProductName;
                        
                        if(bundleproductmap!=null && reqvar.BomProductname!=null && reqvar.BomProductname!='' && bundleproductmap.get(reqvar.BomProductname)!=null && ProdClasifyVar.Apttus_Config2__ClassificationId__c == null){
                        //ProdClasifyVar.Apttus_Config2__ClassificationId__c = [select id,Name from Apttus_Config2__ClassificationHierarchy__c where Name=:MasterProductName limit 1].id;
                        ProdClasifyVar.Apttus_Config2__ClassificationId__c = categoryHierId2;
                        }
                       
                        
                        if((newproductmap!=null && reqvar.ProductName!=null && reqvar.ProductName!='' && newproductmap.get(reqvar.ProductName) != null) )
                        ProdClasifyVar.Apttus_Config2__ProductId__c = newproductmap.get(reqvar.ProductName).id;
                        ProdClasifyVar.Apttus_Config2__DefaultQuantity__c = (reqvar.ComponentQuantity!=null && reqvar.ComponentQuantity!='') ? Decimal.valueOf(reqvar.ComponentQuantity):0;
                        ProdClasifyVar.Apttus_Config2__MaxQuantity__c = (reqvar.ComponentQuantity!=null && reqvar.ComponentQuantity!='') ? Decimal.valueOf(reqvar.ComponentQuantity):0;
                        ProdClasifyVar.Apttus_Config2__MinQuantity__c = (reqvar.ComponentQuantity!=null && reqvar.ComponentQuantity!='') ? Decimal.valueOf(reqvar.ComponentQuantity):0;
                        ProdClasifyVar.Apttus_Config2__Default__c = true;
                        ProdClasifyVar.Oracle_ID__c = reqvar.Oracle_ID;
                        /* Adding this line of code to make the modifiable field as false in product classification*/
                        ProdClasifyVar.Apttus_Config2__Modifiable__c = false; 
                        if(reqvar.BomProductname!=null)
                            ProdClasifyVar.BomProductCode__c = reqvar.BomProductname;
                        ////system.debug('bundleproductmap===='+bundleproductmap.size()+'=====reqvar.BomProductname===='+reqvar.BomProductname+'=====bundleproductmap.get(reqvar.BomProductname)===='+bundleproductmap.get(reqvar.BomProductname));
                        if(bundleproductmap!=null && reqvar.BomProductname!=null && reqvar.BomProductname!='' && bundleproductmap.get(reqvar.BomProductname)!=null)
                        ProductclasifyList.add(ProdClasifyVar);
                        
                        //code for component product configuration type update
                        if(componentproductcodemap!=null && componentproductcodemap.get(reqvar.ProductName)!=null && componentproductcodemap.get(reqvar.ProductName)!=''&&newproductmap.get(reqvar.ProductName)!= null)
                        {
                            //if(reqvar.ProductName!=null)
                            product2 p = newproductmap.get(reqvar.ProductName);
                            p.Apttus_Config2__ConfigurationType__c = 'Option';
                            p.Apttus_Config2__HasOptions__c = false;
                            bundleproductupdatelist.add(p);
                        }
                        
                        //end of the code for component product configuration type update
                        
                    }
            
            }
        }   
                
        //DML operations to delete the product components when it is deleted in Oracle
        if(OptComTobeDeleted!=null && OptComTobeDeleted.size()>0)
            delete OptComTobeDeleted;
        if(ClassifyObjTobeDeleted!=null && ClassifyObjTobeDeleted.size()>0)
            delete ClassifyObjTobeDeleted;
        
        if(ProductOptionCompList!=null && ProductOptionCompList.size()>0)
        {          
            Database.UpsertResult[] srList1 = Database.upsert(ProductOptionCompList,Apttus_Config2__ProductOptionComponent__c.Fields.Id,false);             
            MastersrList.add(srList1);
            
        }
        
        if(ProductclasifyList!=null && ProductclasifyList.size()>0)
        {          
            Database.UpsertResult[] srList1 = Database.upsert(ProductclasifyList,Apttus_Config2__ProductClassification__c.Fields.Id,false);             
            //MastersrList.add(srList1);
            
        }
        system.debug('productoptiongroupidset============'+productoptiongroupidset);
        if(productoptiongroupidset!=null && productoptiongroupidset.size()>0)
        {   
            for(Apttus_Config2__ProductOptionComponent__c proOptCompVar:[select id ,Name,Apttus_Config2__ProductOptionGroupId__c from Apttus_Config2__ProductOptionComponent__c where Apttus_Config2__ProductOptionGroupId__c in :productoptiongroupidset ]) 
            {
                listsize2++;
            }
            
            system.debug('listsize2============='+listsize2);           
            for(Apttus_Config2__ProductOptionComponent__c proOptCompVar:[select id ,Name,Apttus_Config2__ProductOptionGroupId__c from Apttus_Config2__ProductOptionComponent__c where Apttus_Config2__ProductOptionGroupId__c in :productoptiongroupidset ]) 
            {
                loopvar++;
                if(StrOptionGRpID != null && StrOptionGRpID != '')
                    {    
                        system.debug('StrOptionGRpID====='+StrOptionGRpID+'=====ObjRecCount===='+ObjRecCount);
                        //system.debug('loopvar========='+ObjRecCount+'========StrOptionGRpID========'+StrOptionGRpID);    
                        if(StrOptionGRpID == proOptCompVar.Apttus_Config2__ProductOptionGroupId__c)
                        {
                            ObjRecCount++;
                            //proOptCompVar.Apttus_Config2__Sequence__c = ObjRecCount; 
                            if(loopvar == listsize2) 
                            {
                                ProdOptComponentMap.put(StrOptionGRpID.trim(),ObjRecCount);
                                ////system.debug('ProdOptComponentMap======'+ProdOptComponentMap+'=========ObjRecCount====='+ObjRecCount+'=========loopvar=========='+loopvar);
                            }      
                        }
                        else if(StrOptionGRpID != proOptCompVar.Apttus_Config2__ProductOptionGroupId__c)
                        {
                            ProdOptComponentMap.put(StrOptionGRpID ,ObjRecCount);
                            //proOptCompVar.Apttus_Config2__Sequence__c = ObjRecCount;
                            ObjRecCount = 1;
                            StrOptionGRpID = proOptCompVar.Apttus_Config2__ProductOptionGroupId__c;
                            if(loopvar == listsize2) 
                            {
                                ProdOptComponentMap.put(StrOptionGRpID.trim(),ObjRecCount);
                                ////system.debug('ProdOptComponentMap======'+ProdOptComponentMap+'=========ObjRecCount====='+ObjRecCount+'=========loopvar=========='+loopvar);
                            }
                               
                        }
                    }
                    else
                    {
                        StrOptionGRpID = proOptCompVar.Apttus_Config2__ProductOptionGroupId__c;
                        ObjRecCount++;
                       // proOptCompVar.Apttus_Config2__Sequence__c = ObjRecCount;
                        if(loopvar == listsize2) 
                        {
                            ProdOptComponentMap.put(StrOptionGRpID.trim(),ObjRecCount);
                        }
                    }
                    ProdOptCopList.add(proOptCompVar);
            }
            
            system.debug('ProdOptCopList====='+ProdOptCopList);
            
            for(Apttus_Config2__ProductOptionGroup__c productoptVar:[select id,Apttus_Config2__MaxOptions__c,Apttus_Config2__MinOptions__c from Apttus_Config2__ProductOptionGroup__c where id in :productoptiongroupidset ])
            {
                    
                    if(ProdOptComponentMap!=null && ProdOptComponentMap.get(productoptVar.id)!=null){
                    //productoptVar.Apttus_Config2__MaxOptions__c =ProOptGRPMap.get(productoptVar.id);
                    //productoptVar.Apttus_Config2__MinOptions__c =ProOptGRPMap.get(productoptVar.id);
                    
                    //system.debug('ProdOptComponentMap.get(productoptVar.id)========='+ProdOptComponentMap.get(productoptVar.id));
                    
                    productoptVar.Apttus_Config2__MaxOptions__c =ProdOptComponentMap.get(productoptVar.id);
                    productoptVar.Apttus_Config2__MinOptions__c =ProdOptComponentMap.get(productoptVar.id);
                     objlist.add(productoptVar);
                    }
                   else
                   {
                    productoptVar.Apttus_Config2__MaxOptions__c =0;
                    productoptVar.Apttus_Config2__MinOptions__c =0;
                    objlist.add(productoptVar);
                   }
            }
            ////system.debug('ProOptGRPMap===='+ProOptGRPMap);
            ////system.debug('objlist====='+objlist);
        }
        //DML operation to update the product components
        if(objlist!=null && objlist.size()>0)
        update objlist;
        if(ProdOptCopList!=null && ProdOptCopList!=null)
        update ProdOptCopList;
        
        //DML operation to update the bundle product
        if(bundleproductupdatelist!=null && bundleproductupdatelist.size()>0)
        update bundleproductupdatelist;
        
        ////system.debug('MastersrList========='+MastersrList.size());
        
        set<id> succProductIdSet = new set<id>(); 
        
        for(list<Database.UpsertResult> srval : MastersrList) {
             for (Database.UpsertResult sr : srval){
                 succProductIdSet.add(sr.getid());
             }
        }
        
        map<id,string> Prod_ID_ConfType_Map = new map<id,string>();
        map<id,string> Prod_ID_Name_Map = new map<id,string>();
        map<id,string> Prod_ID_OracleID_Map = new map<id,string>();
        map<id,string> BOMProd_ID_OracleID_Map = new map<id,string>();
        map<id,Boolean> Prod_Active_Map = new map<id,Boolean>();
        prodList = [Select ID,Name,Apttus_Config2__ConfigurationType__c,Oracle_ID__c,IsActive,ProductCode from Product2 where id IN:succProductIdSet ];
        for(Product2 prod :prodList){
              Prod_ID_ConfType_Map.put(prod.id, prod.Apttus_Config2__ConfigurationType__c);
              Prod_ID_Name_Map.put(prod.id, prod.ProductCode);
              Prod_ID_OracleID_Map.put(prod.id, prod.Oracle_ID__c);
              Prod_Active_Map.put(prod.id, prod.IsActive);
        }
        
        //if(Prod_ID_ConfType_Map!= null && Prod_ID_Name_Map!= null && Prod_ID_OracleID_Map!= null){
            /* 
            for(Apttus_Config2__ProductOptionGroup__c prod : [Select ID,Name,Apttus_Config2__ProductId__r.Name,Apttus_Config2__ProductId__r.Apttus_Config2__ConfigurationType__c,Apttus_Config2__ProductId__r.Oracle_ID__c from Apttus_Config2__ProductOptionGroup__c where id IN:succProductIdSet ]){
                  Prod_ID_ConfType_Map.put(prod.id, prod.Apttus_Config2__ProductId__r.Apttus_Config2__ConfigurationType__c);
                  Prod_ID_Name_Map.put(prod.id, prod.Apttus_Config2__ProductId__r.Name);
                  Prod_ID_OracleID_Map.put(prod.id, prod.Apttus_Config2__ProductId__r.Oracle_ID__c);
            }*/
           optGrpList = [Select ID,Name,Apttus_Config2__ProductId__r.ProductCode,Apttus_Config2__ProductId__r.Apttus_Config2__ConfigurationType__c,Apttus_Config2__ProductId__r.Oracle_ID__c from Apttus_Config2__ProductOptionGroup__c where id IN:succProductIdSet ];  
           for(Apttus_Config2__ProductOptionGroup__c prod : optGrpList){
                  Prod_ID_ConfType_Map.put(prod.id, prod.Apttus_Config2__ProductId__r.Apttus_Config2__ConfigurationType__c);
                  Prod_ID_Name_Map.put(prod.id, prod.Apttus_Config2__ProductId__r.ProductCode);
                  Prod_ID_OracleID_Map.put(prod.id, prod.Apttus_Config2__ProductId__r.Oracle_ID__c);
            }
        //}
        
        //if(optGrpList.size() == 0){
            prodCompList = [Select Id,Name,Apttus_Config2__ComponentProductId__r.Id,Apttus_Config2__ParentProductId__r.Oracle_ID__c,Apttus_Config2__ComponentProductId__r.Apttus_Config2__ConfigurationType__c,Apttus_Config2__ComponentProductId__r.ProductCode,Apttus_Config2__ComponentProductId__r.Oracle_ID__c from Apttus_Config2__ProductOptionComponent__c where Id IN:succProductIdSet];
            for(Apttus_Config2__ProductOptionComponent__c prodComp : prodCompList){
                  Prod_ID_ConfType_Map.put(prodComp.id, prodComp.Apttus_Config2__ComponentProductId__r.Apttus_Config2__ConfigurationType__c);
                  Prod_ID_Name_Map.put(prodComp.id, prodComp.Apttus_Config2__ComponentProductId__r.ProductCode);
                  Prod_ID_OracleID_Map.put(prodComp.id, prodComp.Apttus_Config2__ComponentProductId__r.Oracle_ID__c);
                  BOMProd_ID_OracleID_Map.put(prodComp.id, prodComp.Apttus_Config2__ParentProductId__r.Oracle_ID__c);
            }
        //}
        for(list<Database.UpsertResult> srval : MastersrList) 
        {
             for (Database.UpsertResult sr : srval)
             { 
                 if (sr.isSuccess())
                 {
                    respvar = new ResponseWraperClass();    
                    respvar.result ='Success';
                    respvar.Errorcode = 'IMP-SUCC-114';
                    respvar.ErrorMessage = 'Transaction is Success';
                    
                    respvar.SFDC_ITEM_NUMBER = sr.getId();
                    if(BOMProd_ID_OracleID_Map.get(sr.getId())!=null)
                        respvar.ASSEMBLY_ITEM_ID = BOMProd_ID_OracleID_Map.get(sr.getId());
                      if(Prod_ID_ConfType_Map.get(sr.getId())!=null){
                            
                            if(prodList.size()!= 0 && Prod_Active_Map.get(sr.getId()) != null){
                               respvar.RECORD_TYPE='Item';
                               respvar.TransactionNameAndValue = 'Item: '+ sr.getId();
                            }
                            else if(optGrpList.size() != 0 && Prod_ID_ConfType_Map.get(sr.getId()) == 'Bundle'){   
                                //if(Prod_ID_ConfType_Map.get(sr.getId()) == 'Bundle'){
                                   respvar.RECORD_TYPE='BOM';
                                   respvar.TransactionNameAndValue = 'BOM: '+ sr.getId();
                                //}   
                            }
                            else if(prodCompList.size() != 0 && Prod_ID_ConfType_Map.get(sr.getId()) == 'Option'){
                               respvar.RECORD_TYPE='Component';  
                               respvar.TransactionNameAndValue = 'Component: '+ sr.getId();
                            }   
                    }
                    
                    if(Prod_ID_Name_Map.get(sr.getId())!=null){
                      respvar.ITEM_NUMBER=Prod_ID_Name_Map.get(sr.getId());
                    }
                    if(Prod_ID_OracleID_Map.get(sr.getId())!=null){
                      respvar.INVENTORY_ITEM_ID=Prod_ID_OracleID_Map.get(sr.getId());
                    }
                    
                    respvarlist.add(respvar);
                 }
                else 
                {            
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) 
                    {
                        blnFinalResult = true;
                        respvar = new ResponseWraperClass();
                        respvar.result ='Failure';
                        respvar.Errorcode = 'IMP-ERR-'+string.valueOf(err.getStatusCode());
                        respvar.ErrorMessage = err.getMessage();
                        if(BOMProd_ID_OracleID_Map.get(sr.getId())!=null)
                            respvar.ASSEMBLY_ITEM_ID = BOMProd_ID_OracleID_Map.get(sr.getId());
                        
                        if(Prod_ID_ConfType_Map.get(sr.getId())!=null){
                            if(prodList.size()!= 0 && Prod_Active_Map.get(sr.getId()) != null){
                               respvar.RECORD_TYPE='Item';
                               respvar.TransactionNameAndValue = 'Item: '+ sr.getId();
                            }
                            else if(optGrpList.size() != 0 && Prod_ID_ConfType_Map.get(sr.getId()) == 'Bundle'){   
                                //if(Prod_ID_ConfType_Map.get(sr.getId()) == 'Bundle'){
                                   respvar.RECORD_TYPE='BOM';
                                   respvar.TransactionNameAndValue = 'BOM: '+ sr.getId();
                                //}   
                            }
                            else if(prodCompList.size() != 0 && Prod_ID_ConfType_Map.get(sr.getId()) == 'Option'){
                               respvar.RECORD_TYPE='Component';  
                               respvar.TransactionNameAndValue = 'Component: '+ sr.getId();
                            }   
                        }
                        if(Prod_ID_Name_Map.get(sr.getId())!=null){
                          respvar.ITEM_NUMBER=Prod_ID_Name_Map.get(sr.getId());
                        }
                        if(Prod_ID_OracleID_Map.get(sr.getId())!=null){
                          respvar.INVENTORY_ITEM_ID=Prod_ID_OracleID_Map.get(sr.getId());
                        }
                        respvarlist.add(respvar);
                     
                    }
                }
                }
            }
        
        }
        catch(exception ex)
        {           
            blnFinalResult = true;
            blnSystemException = true;
            respvar = new ResponseWraperClass();  
            respvar.result ='Failure';
            respvar.Errorcode = 'IMP-ERR-102';
            respvar.ErrorMessage = 'Failure: '+ string.valueof(ex);
            respvarlist.add(respvar);
            
              
        }
        
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
    
    //global class to expose parameters to Oracle to accept Product data
    global class requestdata 
    {   
        webservice String Record_type;           
        webservice String ProductName;
        webservice String Oracle_ID;
        webservice String ProductDescription;
        webservice String ProductBusinessArea;
        webservice String ProductType; //productGroupDescription.
        webservice String ProductSubType;
        webservice String ProductStatus;
        webservice String ProductActive;
        webservice String ComponentQuantity;
        webservice String BomProductname; 
        webservice String ComponentEndDate;
        webservice String ComponentSequenceNumber;
        webservice String Contract_Item_Type_Code;  
        webservice String ProductLongDescription;  
        webservice String ProductGroup;
        webservice String ProductLine;   
        webservice String productNameDE;
        webservice String productNameEN;
        webservice String productNameFR;
        webservice String longDescriptionDE;
        webservice String longDescriptionEN;
        webservice String longDescriptionFR;
        webservice string ProductFamily;
        webservice string productLineDescription;
        
        webservice string attribute1;
        webservice string attribute2;
        webservice string attribute3;
        webservice string attribute4;
        webservice string attribute5;
        webservice string attribute6;
        webservice string attribute7;
        webservice string attribute8;
        webservice string attribute9;
        webservice string attribute10;
        webservice string attribute11;
        webservice string attribute12;
        webservice string attribute13;
        webservice string attribute14;
        webservice string attribute15;
        
    } 
    
    //Response class to send the success or failure detail back to oracle EBS
    global class ResponseWraperClass
    {     
        webservice String Result{get;set;}
        webservice String Errorcode{get;set;}    
        webservice String ErrorMessage{get;set;} 
        webservice String TransactionNameAndValue{get;set;}
        webservice String FinalResult{get;set;}
        webservice String RECORD_TYPE{get;set;}                     
        webservice String ITEM_NUMBER{get;set;}                //product name  
        webservice String INVENTORY_ITEM_ID{get;set;}    //oracle id   
        webservice String ASSEMBLY_ITEM_ID{get;set;}        //bomproductname
        webservice String SFDC_ITEM_NUMBER{get;set;}   //sfdc id
    }    
    
}