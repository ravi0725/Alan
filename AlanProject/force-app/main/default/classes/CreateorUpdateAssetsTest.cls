@isTest
private class CreateorUpdateAssetsTest{

    private static Country_Region_Mapping__c cust;
    private static Geospatial_Country_Region_Mapping__c custRegMap ;
    private static Account acct;
    private static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    private static User thisUser ;
    private static Product2 prod ;
    private static Asset asst;
    private static List<CreateorUpdateAssets.requestdata>  reqInstall00 = new List<CreateorUpdateAssets.requestdata>();
    private static List<CreateorUpdateAssets.requestdata>  reqInstall01 = new List<CreateorUpdateAssets.requestdata>();   
    private static List<CreateorUpdateAssets.requestdata>  reqInstall02 = new List<CreateorUpdateAssets.requestdata>();
    private static List<CreateorUpdateAssets.requestdata>  reqInstall03 = new List<CreateorUpdateAssets.requestdata>();
    private static List<CreateorUpdateAssets.requestdata>  reqInstall04 = new List<CreateorUpdateAssets.requestdata>();
    static void setUpData(){
    
        cust = new Country_Region_Mapping__c(name='India',Region__c='India');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='India',Region__c='India');
        insert custRegMap;
        
        thisUser = [select Id from User where Id = :UserInfo.getUserId()];
  
        acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
            BillingCountry = 'India',BillingCity = 'Pune',FCH_Party_ID__c='12345678',BillingStreet = 'A-202' ,Phone='111-111-1111',BillingState='Goa',
            BillingPostalCode ='343220');
        insert acct;
        
        Address__c Adr = new Address__c(Name ='Test Address',Account__c= acct.id,bill_To__c = true, Ship_To__c = true,FCH_Party_Site_ID__c='12345678');
        insert Adr;
        
        asst = new Asset(name='Test Asset' ,AccountId=acct.Id,Asset_Oracle_ID__c='Test');
        insert asst;
        
        prod = new Product2();
        prod.IsActive = true;
        prod.Name = 'ABC';
        prod.ProductCode = 'T1';
        prod.Certificate__c = 'C1';
        prod.Contract_Item_Type_Code__c ='WARRANTY';
        prod.productcode ='Code';
        prod.Product_Family_Description__c ='PRODFAMILYDES';
        insert prod;
        
        CreateorUpdateAssets.requestdata req00 = new CreateorUpdateAssets.requestdata();
        req00.CustomerMasterID = acct.FCH_Party_ID__c;
        req00.OwnerAccountName = acct.name;
        req00.AssetName = asst.Asset_Oracle_ID__c;
        req00.AssetProductFamily ='Test';
        req00.AssetSerialNumber='TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest';
        req00.AssetInstallDate='2013-04-17T19:09:27.000Z';
        req00.AssetQuantity='10';
        req00.AssetStatus='Test';
        req00.AssetLicenseKey='Test';
        req00.AssetProduct = prod.productcode;
        req00.AssetVersion='Test';
        req00.AssetPrice='100';
        req00.AssetEndDate='2014-04-17T19:09:27.000Z';  
        req00.CurrencyCode='USD'; 
        req00.BillToFCHPartyID ='12345678';
        req00.ShipToFCHPartyID ='12345678';
        req00.BillToFCHPartySiteID ='12345678';
        req00.ShipToFCHPartySiteID ='12345678';
        req00.attribute1 ='test_1';
        req00.attribute2 ='2'; 
        
        CreateorUpdateAssets.requestdata req01 = new CreateorUpdateAssets.requestdata();
        req01.CustomerMasterID = '';
        req01.OwnerAccountName = acct.name;
        req01.AssetName = asst.Asset_Oracle_ID__c;
        req01.AssetProductFamily ='Test';
        req01.AssetSerialNumber='TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest';
        req01.AssetInstallDate='2013-04-17T19:09:27.000Z';
        req01.AssetQuantity='10';
        req01.AssetStatus='Test';
        req01.AssetLicenseKey='Test';
        req01.AssetProduct = prod.productcode;
        req01.AssetVersion='TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest';
        req01.AssetPrice='100';
        req01.AssetEndDate='2014-04-17T19:09:27.000Z';  
        req01.CurrencyCode='USD'; 
        req01.BillToFCHPartyID ='12345678';
        req01.ShipToFCHPartyID ='12345678';
        req01.BillToFCHPartySiteID ='12345678';
        req01.ShipToFCHPartySiteID ='12345678';
        req01.attribute1 ='test_1';
        req01.attribute2 ='2'; 
               
        
        CreateorUpdateAssets.requestdata req02 = new CreateorUpdateAssets.requestdata();
        req02.CustomerMasterID = acct.FCH_Party_ID__c;
        req02.OwnerAccountName = '';
        req02.AssetName = asst.Asset_Oracle_ID__c;
        req02.AssetProductFamily ='Test';
        req02.AssetSerialNumber='TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest';
        req02.AssetInstallDate='2013-04-17T19:09:27.000Z';
        req02.AssetQuantity='10';
        req02.AssetStatus='Test';
        req02.AssetLicenseKey='TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest';
        req02.AssetProduct = prod.productcode;
        req02.AssetVersion='TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest';
        req02.AssetPrice='100';
        req02.AssetEndDate='2014-04-17T19:09:27.000Z';  
        req02.BillToFCHPartyID ='12345678';
        req02.ShipToFCHPartyID ='12345678';
        req02.BillToFCHPartySiteID ='12345678';
        req02.ShipToFCHPartySiteID ='12345678';
        req02.attribute1 ='test_1';
        req02.attribute2 ='2'; 
        
        
        CreateorUpdateAssets.requestdata req03 = new CreateorUpdateAssets.requestdata();
        req03.CustomerMasterID = acct.FCH_Party_ID__c;
        req03.OwnerAccountName = acct.name;
        req03.AssetName = '';
        req03.AssetProductFamily ='Test';
        req03.AssetSerialNumber='TestTestTest';
        req03.AssetInstallDate='2013-04-17T19:09:27.000Z';
        req03.AssetQuantity='10';
        req03.AssetStatus='Test';
        req03.AssetLicenseKey='Test';
        req03.AssetProduct = prod.productcode;
        req03.AssetVersion='V1';
        req03.AssetPrice='100';
        req03.AssetName = '12345';
        req03.AssetEndDate='2014-04-17T19:09:27.000Z';  
        req03.CurrencyCode='USD';
        req03.BillToFCHPartyID ='12345678';
        req03.ShipToFCHPartyID ='12345678';
        req03.BillToFCHPartySiteID ='12345678';
        req03.ShipToFCHPartySiteID ='12345678';
        req03.attribute1 ='test_1';
        req03.attribute2 ='2'; 
        
        
        CreateorUpdateAssets.requestdata req04 = new CreateorUpdateAssets.requestdata();
        req04.CustomerMasterID = acct.FCH_Party_ID__c;
        req04.OwnerAccountName = acct.name;
        req04.AssetName = asst.Asset_Oracle_ID__c;
        req04.AssetProductFamily ='Test';
        req04.AssetSerialNumber='TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest';
        req04.AssetInstallDate='2013-04-17T19:09:27.000Z';
        req04.AssetQuantity='10';
        req04.AssetStatus='Test';
        req04.AssetLicenseKey='Test';
        req04.AssetProduct = '';
        req04.AssetVersion='TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest';
        req04.AssetPrice='100';
        req04.AssetEndDate='2014-04-17T19:09:27.000Z';  
        req04.CurrencyCode='USD';
        req04.BillToFCHPartyID ='12345678';
        req04.ShipToFCHPartyID ='12345678';
        req04.BillToFCHPartySiteID ='12345678';
        req04.ShipToFCHPartySiteID ='12345678';
        req04.attribute1 ='test_1';
        req04.attribute2 ='2'; 
        
        
        
        reqInstall00.add(req00);
        reqInstall01.add(req01);
        reqInstall02.add(req02);
        reqInstall03.add(req03);
        reqInstall04.add(req04);
    }
    
    private static testmethod void testCreatePriceListService00(){
        
        setUpData();
        Test.startTest();
            List<CreateorUpdateAssets.ResponseWraperClass> resList = CreateorUpdateAssets.CreateInstallBase(reqInstall00);
                
        Test.stopTest();
    }
    
    private static testmethod void testCreatePriceListService01(){
        
        setUpData();
        Test.startTest();
            List<CreateorUpdateAssets.ResponseWraperClass> resList = CreateorUpdateAssets.CreateInstallBase(reqInstall01);
                
        Test.stopTest();
    }
    
    private static testmethod void testCreatePriceListService02(){
        
        setUpData();
        Test.startTest();
            List<CreateorUpdateAssets.ResponseWraperClass> resList = CreateorUpdateAssets.CreateInstallBase(reqInstall02);
                
        Test.stopTest();
    }
    
    private static testmethod void testCreatePriceListService03(){
        
        setUpData();
        Test.startTest();
            List<CreateorUpdateAssets.ResponseWraperClass> resList = CreateorUpdateAssets.CreateInstallBase(reqInstall03);
                
        Test.stopTest();
    }
    
    private static testmethod void testCreatePriceListService04(){
        
        setUpData();
        Test.startTest();
            List<CreateorUpdateAssets.ResponseWraperClass> resList = CreateorUpdateAssets.CreateInstallBase(reqInstall04);
                
        Test.stopTest();
    }
    
}