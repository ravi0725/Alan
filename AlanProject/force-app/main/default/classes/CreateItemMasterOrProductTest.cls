@isTest
private class CreateItemMasterOrProductTest{

    private static Apttus_Config2__ClassificationName__c appClassName ;
    private static Apttus_Config2__ClassificationHierarchy__c appHierarchy ;
    private static List<CreateItemMasterOrProduct.requestdata>  reqItemMaster00= new List<CreateItemMasterOrProduct.requestdata>();
    private static List<CreateItemMasterOrProduct.requestdata>  reqItemMaster01= new List<CreateItemMasterOrProduct.requestdata>();
    private static List<CreateItemMasterOrProduct.requestdata>  reqItemMaster02= new List<CreateItemMasterOrProduct.requestdata>();
    private static List<CreateItemMasterOrProduct.requestdata>  reqItemMaster03= new List<CreateItemMasterOrProduct.requestdata>();
    private static List<CreateItemMasterOrProduct.requestdata>  reqItemMaster04= new List<CreateItemMasterOrProduct.requestdata>();
    private static List<CreateItemMasterOrProduct.requestdata>  reqItemMaster05= new List<CreateItemMasterOrProduct.requestdata>();
    private static List<CreateItemMasterOrProduct.requestdata>  reqItemMaster06= new List<CreateItemMasterOrProduct.requestdata>();
    private static List<CreateItemMasterOrProduct.requestdata>  reqItemMaster07= new List<CreateItemMasterOrProduct.requestdata>();
    private static List<CreateItemMasterOrProduct.requestdata>  reqItemMaster08= new List<CreateItemMasterOrProduct.requestdata>();
    private static List<CreateItemMasterOrProduct.requestdata>  reqItemMaster09= new List<CreateItemMasterOrProduct.requestdata>();
    private static Apttus_Config2__ProductOptionGroup__c prodOption ;
    private static Apttus_Config2__ProductOptionComponent__c prodOptionCom ;
    private static Apttus_Config2__ProductClassification__c prodClassification ;
    private static Product2 prod;
    private static Country_Region_Mapping__c cust;
    private static Geospatial_Country_Region_Mapping__c custRegMap ;
    private static Account acct;
    private static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    
     static void setUpData(){
     
        cust = new Country_Region_Mapping__c(name='India',Region__c='India');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='India',Region__c='India');
        insert custRegMap;
       
        acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
            BillingCountry = 'India',BillingCity = 'Pune',BillingStreet = 'A-202' );
        insert acct;
        
        appClassName = new Apttus_Config2__ClassificationName__c(name='Test',Apttus_Config2__HierarchyLabel__c='new heating engineering CAD 2&ff network space');
        insert appClassName;
            
        appHierarchy = new Apttus_Config2__ClassificationHierarchy__c(name='Test PriceBook',Apttus_Config2__HierarchyId__c=appClassName.Id,
                            Apttus_Config2__Label__c='new Prof CAD Building II 2&ff network space',Apttus_Config2__Level__c =0);
    
        insert appHierarchy;
        
        prodOption = new Apttus_Config2__ProductOptionGroup__c(Apttus_Config2__OptionGroupId__c=appHierarchy.Id, Apttus_Config2__Sequence__c=100);
        insert prodOption;
        
        prodOptionCom = new Apttus_Config2__ProductOptionComponent__c(Apttus_Config2__Sequence__c=100);
        insert prodOptionCom;
        
        prodClassification = new Apttus_Config2__ProductClassification__c(Apttus_Config2__ClassificationId__c=appHierarchy.Id);
        insert prodClassification;
        
        prod = new Product2(IsActive=true,Name='ABC',ProductCode='T1',Certificate__c='C1',Contract_Item_Type_Code__c='WARRANTY',Oracle_ID__c='100',Type__c='Hardware');
        insert prod;
        
        Entitlement ent = new Entitlement(name='Test', AccountId=acct.Id,supported_Product_Family_Roll_up__c='CAD Software',Entitlement_Product__c=prod.id);
        insert ent;     
            
        CreateItemMasterOrProduct.requestdata req00 = new CreateItemMasterOrProduct.requestdata();
        req00.Record_type ='bom';           
        req00.ProductName = 'T1';
        req00.Oracle_ID =prod.Oracle_ID__c;
        req00.ProductDescription = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'+
        'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'+
        'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
        req00.ProductBusinessArea ='Plancal';
        req00.ProductType ='Hardware';
        req00.ProductSubType ='Hardware';
        req00.ProductStatus ='Active';
        req00.ProductActive='Test';
        req00.ComponentQuantity='2';
        req00.BomProductname =prod.name; 
        req00.ComponentEndDate ='2013-04-17T19:09:27.000Z';
        req00.ComponentSequenceNumber ='1.1';
        req00.Contract_Item_Type_Code='Test'; 
        req00.ProductLongDescription='API Test';
        req00.ProductGroup='Test';
        req00.ProductLine='Test'; 
        req00.productNameDE ='Test Name';
        req00.productNameEN ='Test Name'; 
        req00.productNameFR ='Test Name';
        req00.longDescriptionDE ='Test Long Desc';
        req00.longDescriptionEN ='Test Long Desc'; 
        req00.longDescriptionFR ='Test Long Desc';  
        
        CreateItemMasterOrProduct.requestdata req01 = new CreateItemMasterOrProduct.requestdata();
        req01.Record_type ='item';           
        req01.ProductName  = 'T1';
        req01.Oracle_ID =prod.Oracle_ID__c;
        req01.ProductDescription ='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'+
        'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'+
        'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
        req01.ProductBusinessArea ='Plancal';
        req01.ProductType ='Hardware';
        req01.ProductSubType ='Hardware';
        req01.ProductStatus ='Active';
        req01.ProductActive='Test';
        req01.ComponentQuantity='2';
        req01.BomProductname =prod.name; 
        req01.ComponentEndDate ='2013-04-17T19:09:27.000Z';
        req01.ComponentSequenceNumber ='1.1';
        req01.Contract_Item_Type_Code='Test'; 
        req01.ProductLongDescription='API Test';
        req01.ProductGroup='Test';
        req01.ProductLine='Test'; 
        req01.productNameDE ='Test Name';
        req01.productNameEN ='Test Name'; 
        req01.productNameFR ='Test Name';
        req01.longDescriptionDE ='Test Long Desc';
        req01.longDescriptionEN ='Test Long Desc'; 
        req01.longDescriptionFR ='Test Long Desc';  
        
        CreateItemMasterOrProduct.requestdata req02 = new CreateItemMasterOrProduct.requestdata();
        req02.Record_type ='component';           
        req02.ProductName = 'T1';
        req02.Oracle_ID =prod.Oracle_ID__c;
        req02.ProductDescription = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'+
        'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'+
        'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
        req02.ProductBusinessArea ='Plancal';
        req02.ProductType ='Hardware';
        req02.ProductSubType ='Hardware';
        req02.ProductStatus ='Active';
        req02.ProductActive='Test';
        req02.ComponentQuantity='2';
        req02.BomProductname =prod.name; 
        req02.ComponentEndDate ='2013-04-17T19:09:27.000Z';
        req02.ComponentSequenceNumber ='1.1';
        req02.Contract_Item_Type_Code='Test'; 
        req02.ProductLongDescription='API Test';
        req02.ProductGroup='Test';
        req02.ProductLine='Test'; 
        req02.productNameDE ='Test Name';
        req02.productNameEN ='Test Name'; 
        req02.productNameFR ='Test Name';
        req02.longDescriptionDE ='Test Long Desc';
        req02.longDescriptionEN ='Test Long Desc'; 
        req02.longDescriptionFR ='Test Long Desc';  
        
        CreateItemMasterOrProduct.requestdata req03 = new CreateItemMasterOrProduct.requestdata();
        req03.Record_type = null;           
        req03.ProductName = null;
        req03.Oracle_ID = null;
        req03.ProductDescription =  'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'+
        'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'+
        'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
        req03.ProductBusinessArea = null;
        req03.ProductType =null;
        req03.ProductSubType =null;
        req03.ProductStatus =null;
        req03.ProductActive=null;
        req03.ComponentQuantity=null;
        req03.BomProductname =null; 
        req03.ComponentEndDate =null;
        req03.ComponentSequenceNumber =null;
        req03.Contract_Item_Type_Code=null; 
        req03.ProductLongDescription=null;
        req03.ProductGroup=null;
        req03.ProductLine=null; 
        req03.productNameDE ='Test Name';
        req03.productNameEN ='Test Name'; 
        req03.productNameFR ='Test Name';
        req03.longDescriptionDE ='Test Long Desc';
        req03.longDescriptionEN ='Test Long Desc'; 
        req03.longDescriptionFR ='Test Long Desc';  
        
        CreateItemMasterOrProduct.requestdata req04 = new CreateItemMasterOrProduct.requestdata();
        req04.Record_type ='item';            
        req04.ProductName = null;
        req04.Oracle_ID = null;
        req04.ProductDescription = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'+
        'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'+
        'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
        req04.ProductBusinessArea = null;
        req04.ProductType =null;
        req04.ProductSubType =null;
        req04.ProductStatus =null;
        req04.ProductActive=null;
        req04.ComponentQuantity=null;
        req04.BomProductname =null; 
        req04.ComponentEndDate =null;
        req04.ComponentSequenceNumber =null;
        req04.Contract_Item_Type_Code=null; 
        req04.ProductLongDescription=null;
        req04.ProductGroup=null;
        req04.ProductLine=null;
        req04.productNameDE ='Test Name';
        req04.productNameEN ='Test Name'; 
        req04.productNameFR ='Test Name';
        req04.longDescriptionDE ='Test Long Desc';
        req04.longDescriptionEN ='Test Long Desc'; 
        req04.longDescriptionFR ='Test Long Desc';    
        
        CreateItemMasterOrProduct.requestdata req05 = new CreateItemMasterOrProduct.requestdata();
        req05.Record_type ='bom';            
        req05.ProductName = null;
        req05.Oracle_ID = null;
        req05.ProductDescription = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'+
        'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'+
        'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
        req05.ProductBusinessArea = null;
        req05.ProductType =null;
        req05.ProductSubType =null;
        req05.ProductStatus =null;
        req05.ProductActive=null;
        req05.ComponentQuantity=null;
        req05.BomProductname =null; 
        req05.ComponentEndDate ='2013-04-17T19:09:27.000Z';
        req05.ComponentSequenceNumber =null;
        req05.Contract_Item_Type_Code=null; 
        req05.ProductLongDescription=null;
        req05.ProductGroup=null;
        req05.ProductLine=null;
        req05.productNameDE ='Test Name';
        req05.productNameEN ='Test Name'; 
        req05.productNameFR ='Test Name';
        req05.longDescriptionDE ='Test Long Desc';
        req05.longDescriptionEN ='Test Long Desc'; 
        req05.longDescriptionFR ='Test Long Desc';  
        
        CreateItemMasterOrProduct.requestdata req06 = new CreateItemMasterOrProduct.requestdata();
        req06.Record_type ='component';           
        req06.ProductName = null;
        req06.Oracle_ID = null;
        req06.ProductDescription =  'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'+
        'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'+
        'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
        req06.ProductBusinessArea = null;
        req06.ProductType =null;
        req06.ProductSubType =null;
        req06.ProductStatus =null;
        req06.ProductActive=null;
        req06.ComponentQuantity=null;
        req06.BomProductname =null; 
        req06.ComponentEndDate =null;
        req06.ComponentSequenceNumber =null;
        req06.Contract_Item_Type_Code=null; 
        req06.ProductLongDescription=null;
        req06.ProductGroup=null;
        req06.ProductLine=null; 
        req06.productNameDE ='Test Name';
        req06.productNameEN ='Test Name'; 
        req06.productNameFR ='Test Name';
        req06.longDescriptionDE ='Test Long Desc';
        req06.longDescriptionEN ='Test Long Desc'; 
        req06.longDescriptionFR ='Test Long Desc';    

        CreateItemMasterOrProduct.requestdata req07 = new CreateItemMasterOrProduct.requestdata();
        req07.Record_type ='item';            
        req07.ProductName = 'T2';
        req07.Oracle_ID = prod.Oracle_ID__c;
        req07.ProductDescription = null;
        req07.ProductBusinessArea = null;
        req07.ProductType =null;
        req07.ProductSubType =null;
        req07.ProductStatus = 'Obsolete';
        req07.ProductFamily = 'Others';
        req07.productLineDescription = 'Line DESC';
        req07.ProductActive='No';
        req07.ComponentQuantity=null;
        req07.BomProductname = prod.Name; 
        req07.ComponentEndDate ='2013-04-17T19:09:27.000Z';
        req07.ComponentSequenceNumber =null;
        req07.Contract_Item_Type_Code=null; 
        req07.ProductLongDescription=null;
        req07.ProductGroup=null;
        req07.ProductLine=null;
        req07.productNameDE ='Test Name';
        req07.productNameEN ='Test Name'; 
        req07.productNameFR ='Test Name';
        req07.longDescriptionDE ='Test Long Desc';
        req07.longDescriptionEN ='Test Long Desc'; 
        req07.longDescriptionFR ='Test Long Desc';

        CreateItemMasterOrProduct.requestdata req08 = new CreateItemMasterOrProduct.requestdata();
        req08.Record_type ='bom';           
        req08.ProductName = 'T2';
        req08.Oracle_ID =prod.Oracle_ID__c;
        req08.ProductDescription = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'+
        'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'+
        'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
        req08.ProductBusinessArea ='Plancal';
        req08.ProductType ='Hardware';
        req08.ProductSubType ='Hardware';
        req08.ProductStatus ='Active';
        req08.ProductActive='Test';
        req08.ComponentQuantity='2';
        req08.BomProductname =prod.name; 
        req08.ComponentEndDate ='2013-04-17T19:09:27.000Z';
        req08.ComponentSequenceNumber ='1.1';
        req08.Contract_Item_Type_Code='Test'; 
        req08.ProductLongDescription='API Test';
        req08.ProductGroup='Test';
        req08.ProductLine='Test'; 
        req08.productNameDE ='Test Name';
        req08.productNameEN ='Test Name'; 
        req08.productNameFR ='Test Name';
        req08.longDescriptionDE ='Test Long Desc';
        req08.longDescriptionEN ='Test Long Desc'; 
        req08.longDescriptionFR ='Test Long Desc';  
        
        CreateItemMasterOrProduct.requestdata req09 = new CreateItemMasterOrProduct.requestdata();
        req09.Record_type ='item';           
        req09.ProductName  = 'T1';
        req09.Oracle_ID =prod.Oracle_ID__c;
        req09.ProductDescription ='aaaaaaaa';
        req09.ProductBusinessArea ='Plancal';
        req09.ProductType ='Hardware';
        req09.ProductSubType ='Hardware';
        req09.ProductStatus ='Active';
        req09.ProductActive='Test';
        req09.ComponentQuantity='2';
        req09.BomProductname =prod.name; 
        req09.ComponentEndDate ='2013-04-17T19:09:27.000Z';
        req09.ComponentSequenceNumber ='1.1';
        req09.Contract_Item_Type_Code='Test'; 
        req09.ProductLongDescription='API Test';
        req09.ProductGroup='Test';
        req09.ProductLine='Test'; 
        req09.productNameDE ='Test Name';
        req09.productNameEN ='Test Name'; 
        req09.productNameFR ='Test Name';
        req09.longDescriptionDE ='Test Long Desc';
        req09.longDescriptionEN ='Test Long Desc'; 
        req09.longDescriptionFR ='Test Long Desc';

        reqItemMaster00.add(req00);
        reqItemMaster01.add(req01);
        reqItemMaster02.add(req02);
        reqItemMaster03.add(req03);
        reqItemMaster04.add(req04);
        reqItemMaster05.add(req05);
        reqItemMaster06.add(req06);
        reqItemMaster07.add(req07);
        reqItemMaster08.add(req08);
        reqItemMaster09.add(req09);
     }
    
    private static testmethod void testCreateItemMasterOrProduct00(){
        
            setUpData();
            Test.startTest();
                List<CreateItemMasterOrProduct.ResponseWraperClass> resList = CreateItemMasterOrProduct.CreateItemMasterorProduct(reqItemMaster00);
                
            Test.stopTest();
    } 
    
    private static testmethod void testCreateItemMasterOrProduct01(){
        
            setUpData();
            Test.startTest();
                List<CreateItemMasterOrProduct.ResponseWraperClass> resList = CreateItemMasterOrProduct.CreateItemMasterorProduct(reqItemMaster01);
                
            Test.stopTest();
    }   

    private static testmethod void testCreateItemMasterOrProduct02(){
        
            setUpData();
            Test.startTest();
                List<CreateItemMasterOrProduct.ResponseWraperClass> resList = CreateItemMasterOrProduct.CreateItemMasterorProduct(reqItemMaster02);
                List<Apttus_Config2__ProductOptionComponent__c> lstComp = [select id,Name,oracle_id__c,productcode__c,Apttus_Config2__ProductOptionGroupId__c,Apttus_Config2__Sequence__c,Apttus_Config2__ParentProductId__c,Apttus_Config2__ComponentProductId__c from Apttus_Config2__ProductOptionComponent__c where productcode__c = 'T1'];
            Test.stopTest();
    }   
    
    private static testmethod void testCreateItemMasterOrProductExp00(){
        
            setUpData();
            Test.startTest();
                List<CreateItemMasterOrProduct.ResponseWraperClass> resList = CreateItemMasterOrProduct.CreateItemMasterorProduct(reqItemMaster03);
               
            Test.stopTest();
    } 

    private static testmethod void testCreateItemMasterOrProductExp01(){
        
            setUpData();
            Test.startTest();
                List<CreateItemMasterOrProduct.ResponseWraperClass> resList = CreateItemMasterOrProduct.CreateItemMasterorProduct(reqItemMaster04);
               
            Test.stopTest();
    }   
    
    private static testmethod void testCreateItemMasterOrProduct05(){
        
            setUpData();
            Test.startTest();
                List<CreateItemMasterOrProduct.ResponseWraperClass> resList = CreateItemMasterOrProduct.CreateItemMasterorProduct(reqItemMaster05);
                
            Test.stopTest();
    }  

    private static testmethod void testCreateItemMasterOrProduct06(){
        
            setUpData();
            Test.startTest();
                List<CreateItemMasterOrProduct.ResponseWraperClass> resList = CreateItemMasterOrProduct.CreateItemMasterorProduct(reqItemMaster06);
                
            Test.stopTest();
    }

    private static testmethod void testCreateItemMasterOrProduct07(){
        
            setUpData();
            Test.startTest();
                List<CreateItemMasterOrProduct.ResponseWraperClass> resList = CreateItemMasterOrProduct.CreateItemMasterorProduct(reqItemMaster07);
                
            Test.stopTest();
    }

    private static testmethod void testCreateItemMasterOrProduct08(){
        
            setUpData();
            Test.startTest();
                List<CreateItemMasterOrProduct.ResponseWraperClass> resList = CreateItemMasterOrProduct.CreateItemMasterorProduct(reqItemMaster08);
                
            Test.stopTest();
    } 

    private static testmethod void testCreateItemMasterOrProduct09(){
        
            setUpData();
            Test.startTest();
                List<CreateItemMasterOrProduct.ResponseWraperClass> resList = CreateItemMasterOrProduct.CreateItemMasterorProduct(reqItemMaster09);
                
            Test.stopTest();
    } 
}