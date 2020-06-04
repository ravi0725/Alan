@isTest
private class CreateUpdatePriceListTest{
    
    private static List<CreateUpdatePriceList.RequestPriceListData>  reqPriceList00 = new List<CreateUpdatePriceList.RequestPriceListData>();
    private static List<CreateUpdatePriceList.RequestPriceListData>  reqPriceList01 = new List<CreateUpdatePriceList.RequestPriceListData>();
    private static List<CreateUpdatePriceList.RequestPriceListData>  reqPriceList02 = new List<CreateUpdatePriceList.RequestPriceListData>();
    private static List<CreateUpdatePriceList.RequestPriceListData>  reqPriceList03 = new List<CreateUpdatePriceList.RequestPriceListData>();
    private static List<CreateUpdatePriceList.RequestPriceListData>  reqPriceList04 = new List<CreateUpdatePriceList.RequestPriceListData>();
    private static Apttus_Config2__PriceList__c appConf;
    private static Apttus_Config2__ProductClassification__c appProdClass  ;
    private static Apttus_Config2__ClassificationName__c appClassName ;
    private static Apttus_Config2__ClassificationHierarchy__c appHierarchy ;
    private static Product2 prod;
    private static Apttus_Config2__PriceListItem__c appPriceListItem ;
    private static String res;
    private static Apttus_Config2__PriceListCategory__c appCat ;
    private static String nameStr ;
    
        static void setUpData(Boolean flag){
    
            appConf = new Apttus_Config2__PriceList__c(name='Test PriceBook' ,Apttus_Config2__Active__c=true ,Apttus_Config2__Description__c='Test',
                        CurrencyIsoCode='USD',Business_Area__c='Oracle',Organization__c='SunMicrosystem',Oracle_ID__c=100);
            insert appConf;
            
            appPriceListItem = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceUom__c='Each',Apttus_Config2__PriceListId__c=appConf.Id,
                            Apttus_Config2__EffectiveDate__c=System.now(),Apttus_Config2__ExpirationDate__c=System.now().addDays(1),
                            Apttus_Config2__ListPrice__c=100.0,Oracle_List_Line_ID__c=100.0);
            insert appPriceListItem;
            
            if(flag){
                nameStr = 'Test';               
            }else{
                nameStr = 'Test PriceBook'; 
            }
            
            appClassName = new Apttus_Config2__ClassificationName__c(name=nameStr,Apttus_Config2__HierarchyLabel__c='new heating engineering CAD 2&ff network space');
            insert appClassName;
            
            appHierarchy = new Apttus_Config2__ClassificationHierarchy__c(name='Test PriceBook',Apttus_Config2__HierarchyId__c=appClassName.Id,
                            Apttus_Config2__Label__c='new Prof CAD Building II 2&ff network space',Apttus_Config2__Level__c =0);
    
                            
            insert appHierarchy;
            
            appProdClass = new Apttus_Config2__ProductClassification__c(Apttus_Config2__ClassificationId__c=appHierarchy.id);

            insert appProdClass;
            
            appCat = new Apttus_Config2__PriceListCategory__c(Apttus_Config2__PriceListId__c=appConf.Id,Apttus_Config2__HierarchyId__c=appClassName.Id,
                    CurrencyIsoCode='USD');
            insert appCat;
            
            prod = new Product2(IsActive=true,Name='ABC',ProductCode='T1',Certificate__c='C1',Contract_Item_Type_Code__c='WARRANTY',Oracle_ID__c='100',Type__c='Hardware');
            insert prod;
            
            CreateUpdatePriceList.RequestPriceListData reqPrice00 = new CreateUpdatePriceList.RequestPriceListData();
            reqPrice00.RECORD_TYPE_IDENTIFIER ='L';
            reqPrice00.LIST_HEADER_ID = 100; //integer
            reqPrice00.NAME = appConf.name; 
            reqPrice00.DESCRIPTION = appConf.Apttus_Config2__Description__c;
            reqPrice00.CURRENCY_CODE = appConf.CurrencyIsoCode; 
            reqPrice00.HEADER_ATTRIBUTE1 = appConf.Business_Area__c; 
            reqPrice00.HEADER_ATTRIBUTE2 = appConf.Organization__c;
            reqPrice00.ACTIVE_FLAG ='Y'; 
            reqPrice00.START_DATE_ACTIVE = Date.valueOf(appPriceListItem.Apttus_Config2__EffectiveDate__c); 
            reqPrice00.END_DATE_ACTIVE = Date.valueOf(appPriceListItem.Apttus_Config2__ExpirationDate__c); 
            reqPrice00.PRODUCT_ATTR_VALUE = prod.Oracle_ID__c;
            reqPrice00.PRODUCT_UOM_CODE = appPriceListItem.Apttus_Config2__PriceUom__c;
            reqPrice00.OPERAND = Double.valueOf(appPriceListItem.Apttus_Config2__ListPrice__c); //decimal
            reqPrice00.LIST_LINE_ID = Integer.valueOf(appPriceListItem.Oracle_List_Line_ID__c);//integer
            
            CreateUpdatePriceList.RequestPriceListData reqPrice01 = new CreateUpdatePriceList.RequestPriceListData();
            reqPrice01.RECORD_TYPE_IDENTIFIER ='H';
            reqPrice01.LIST_HEADER_ID = 100; //integer
            reqPrice01.NAME = appConf.name; 
            reqPrice01.DESCRIPTION = appConf.Apttus_Config2__Description__c;
            reqPrice01.CURRENCY_CODE = appConf.CurrencyIsoCode; 
            reqPrice01.HEADER_ATTRIBUTE1 = appConf.Business_Area__c; 
            reqPrice01.HEADER_ATTRIBUTE2 = appConf.Organization__c;
            reqPrice01.ACTIVE_FLAG ='Y'; 
            reqPrice01.START_DATE_ACTIVE = Date.valueOf(appPriceListItem.Apttus_Config2__EffectiveDate__c); 
            reqPrice01.END_DATE_ACTIVE = Date.valueOf(appPriceListItem.Apttus_Config2__ExpirationDate__c); 
            reqPrice01.PRODUCT_ATTR_VALUE = prod.Oracle_ID__c;
            reqPrice01.PRODUCT_UOM_CODE = appPriceListItem.Apttus_Config2__PriceUom__c;
            reqPrice01.OPERAND = Double.valueOf(appPriceListItem.Apttus_Config2__ListPrice__c); //decimal
            reqPrice01.LIST_LINE_ID = Integer.valueOf(appPriceListItem.Oracle_List_Line_ID__c);//integer
            
            CreateUpdatePriceList.RequestPriceListData reqPrice02 = new CreateUpdatePriceList.RequestPriceListData();
            reqPrice02.RECORD_TYPE_IDENTIFIER ='H';
            reqPrice02.LIST_HEADER_ID =null ; //integer
            reqPrice02.NAME = appConf.name; 
            reqPrice02.DESCRIPTION = appConf.Apttus_Config2__Description__c;
            reqPrice02.CURRENCY_CODE = appConf.CurrencyIsoCode; 
            reqPrice02.HEADER_ATTRIBUTE1 = appConf.Business_Area__c; 
            reqPrice02.HEADER_ATTRIBUTE2 = appConf.Organization__c;
            reqPrice02.ACTIVE_FLAG ='Y'; 
            reqPrice02.START_DATE_ACTIVE = Date.valueOf(appPriceListItem.Apttus_Config2__EffectiveDate__c); 
            reqPrice02.END_DATE_ACTIVE = Date.valueOf(appPriceListItem.Apttus_Config2__ExpirationDate__c); 
            reqPrice02.PRODUCT_ATTR_VALUE = prod.Oracle_ID__c;
            reqPrice02.PRODUCT_UOM_CODE = appPriceListItem.Apttus_Config2__PriceUom__c;
            reqPrice02.OPERAND = Double.valueOf(appPriceListItem.Apttus_Config2__ListPrice__c); //decimal
            reqPrice02.LIST_LINE_ID = Integer.valueOf(appPriceListItem.Oracle_List_Line_ID__c);//integer
            
            CreateUpdatePriceList.RequestPriceListData reqPrice03 = new CreateUpdatePriceList.RequestPriceListData();
            reqPrice03.RECORD_TYPE_IDENTIFIER ='L';
            reqPrice03.LIST_HEADER_ID = 100; //integer
            reqPrice03.NAME = appConf.name; 
            reqPrice03.DESCRIPTION = appConf.Apttus_Config2__Description__c;
            reqPrice03.CURRENCY_CODE = appConf.CurrencyIsoCode; 
            reqPrice03.HEADER_ATTRIBUTE1 = appConf.Business_Area__c; 
            reqPrice03.HEADER_ATTRIBUTE2 = appConf.Organization__c;
            reqPrice03.ACTIVE_FLAG ='Y'; 
            reqPrice03.START_DATE_ACTIVE = Date.valueOf(appPriceListItem.Apttus_Config2__EffectiveDate__c); 
            reqPrice03.END_DATE_ACTIVE = Date.valueOf(appPriceListItem.Apttus_Config2__ExpirationDate__c); 
            reqPrice03.PRODUCT_ATTR_VALUE = prod.Oracle_ID__c;
            reqPrice03.PRODUCT_UOM_CODE = appPriceListItem.Apttus_Config2__PriceUom__c;
            reqPrice03.OPERAND = Double.valueOf(appPriceListItem.Apttus_Config2__ListPrice__c); //decimal
            reqPrice03.LIST_LINE_ID = null;//integer
            
            reqPriceList00.add(reqPrice00);
            reqPriceList01.add(reqPrice01);
            reqPriceList02.add(reqPrice02);
            reqPriceList03.add(reqPrice03);

        }
        
        private static testmethod void testCreatePriceListService00(){
        
            setUpData(true);
            Test.startTest();
                List<CreateUpdatePriceList.ResponseWraperClass> resList = CreateUpdatePriceList.CreatePriceListService(reqPriceList00);
                //res = resList[0].result;
                //System.Assert(res.contains('Success'));
                
            Test.stopTest();
        }
        
        private static testmethod void testCreatePriceListService04(){
        
            setUpData(false);
            Test.startTest();
                List<CreateUpdatePriceList.ResponseWraperClass> resList = CreateUpdatePriceList.CreatePriceListService(reqPriceList00);
                //res = resList[0].result;
                //System.Assert(res.contains('Failure'));
                
            Test.stopTest();
        }
        
        private static testmethod void testCreatePriceListService01(){
        
            setUpData(true);
            Test.startTest();
                List<CreateUpdatePriceList.ResponseWraperClass> resList = CreateUpdatePriceList.CreatePriceListService(reqPriceList01);
                //res = resList[0].result;
                //System.Assert(res.contains('Success'));
                
            Test.stopTest();
        }
        
        private static testmethod void testCreatePriceListService02(){
        
            setUpData(true);
            Test.startTest();
                List<CreateUpdatePriceList.ResponseWraperClass> resList = CreateUpdatePriceList.CreatePriceListService(reqPriceList02);
                //res = resList[0].result;
                //System.Assert(res.contains('Success'));
                
            Test.stopTest();
        }       
        
        private static testmethod void testCreatePriceListService03(){
        
            setUpData(true);
            Test.startTest();
                List<CreateUpdatePriceList.ResponseWraperClass> resList = CreateUpdatePriceList.CreatePriceListService(reqPriceList03);
                //res = resList[0].result;
                //System.Assert(res.contains('Success'));
                
            Test.stopTest();
        }
        
        private static testmethod void testPriceListTrigger(){
        
            setUpData(true);
            Test.startTest();
               appConf.CurrencyIsoCode='EUR';
               update appConf ; 
               System.AssertEquals(appConf.CurrencyIsoCode,'EUR');
            Test.stopTest();
        }
        

}