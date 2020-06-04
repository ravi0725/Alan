/*****************************************************************************************
Name    : CaseOverrideControllerTest 
Modification Log : 
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
Suresh Babu       	03/28/2017          Created
******************************************************************************************/
@isTest
private class CaseOverrideControllerTest {
    static testmethod void test1(){
        test.startTest();
        Country_Region_Mapping__c cust1 = new Country_Region_Mapping__c(name='United States',Region__c='Europe');
        Country_Region_Mapping__c cust2 = new Country_Region_Mapping__c(name='India',Region__c='India');
        List<Country_Region_Mapping__c> lstCustRegion = new List<Country_Region_Mapping__c>();
        lstCustRegion.add(cust1);
        lstCustRegion.add(cust2);
        insert lstCustRegion;
        
        Geospatial_Country_Region_Mapping__c custRegMap1 = new Geospatial_Country_Region_Mapping__c(name='United States',Region__c='Europe');
        Geospatial_Country_Region_Mapping__c custRegMap2 = new Geospatial_Country_Region_Mapping__c(name='India',Region__c='MEAI');
        List<Geospatial_Country_Region_Mapping__c> lstGeoRegion = new List<Geospatial_Country_Region_Mapping__c>();
        lstGeoRegion.add(custRegMap1);
        lstGeoRegion.add(custRegMap2);
        insert lstGeoRegion;
        
        GenerateTestData.createAccount();
        GenerateTestData.createProduct2();
        GenerateTestData.createContact();  
        GenerateTestData.createAsset();
        GenerateTestData.createEntitlement();
        
        Asset ast = new Asset();
        ast.Name = 'Test Asset';
        ast.AccountId = GenerateTestdata.acct.Id;
        ast.Product2Id = GenerateTestData.prd.Id;
        ast.SerialNumber = '12345';
        insert ast;
        
        Case cs = new Case();
        cs.AccountId = GeneratetestData.acct.Id;
        cs.ContactId = GeneratetestData.ct.Id;
        cs.Status = 'New';
        cs.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('GCCM - Support Case Record Type').getRecordTypeId();
        cs.Product__c = 'Prolog Manager';
        cs.Origin = 'Chat';
        cs.Serial_Number__c = '12345';
        cs.TFS_Id__c = '123456';
        cs.Product_Group__c = 'Prolog';
        insert cs;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(cs);
        PageReference pageRef = Page.CaseOverride;
        pageRef.getparameters().put('retURL', '/apex/AccountOverride?id='+GenerateTestdata.acct.Id);
        pageRef.getparameters().put('sfdc.override', '1');
        pageRef.getparameters().put('def_entitlement_id', GenerateTestdata.ent.Id);
        pageRef.getparameters().put('def_account_id', GenerateTestdata.acct.Id);
        pageRef.getparameters().put('def_asset_id', ast.Id);
        pageRef.getparameters().put('def_product_id', GenerateTestdata.prd.Id);
        pageRef.getparameters().put('RecordType', Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('GCCM - Support Case Record Type').getRecordTypeId());
        pageRef.getparameters().put('ent', 'Case');
        pageRef.getparameters().put('save_new', '1');
        Test.setCurrentPage(pageRef);
        CaseOverrideController fsc1 = new CaseOverrideController(sc);
        fsc1.Initialize();

        GenerateTestData.acct.Sales_Ops_Comments__c = 'TEST Sales Ops Comment';
        update GenerateTestData.acct;
        // Test 2
        PageReference pageRef2 = Page.CaseOverride;
        pageRef2.getparameters().put('retURL', '/apex/AccountOverride?id='+GenerateTestdata.acct.Id);
        pageRef2.getparameters().put('sfdc.override', '1');
        pageRef2.getparameters().put('def_account_id', GenerateTestdata.acct.Id);
        pageRef2.getparameters().put('RecordType', Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('GCCM - Support Case Record Type').getRecordTypeId());
        pageRef2.getparameters().put('ent', 'Case');
        pageRef2.getparameters().put('save_new', '1');
        Test.setCurrentPage(pageRef2);
        CaseOverrideController fsc2 = new CaseOverrideController(sc);
        fsc2.Initialize();

        // Test 3
        PageReference pageRef3 = Page.CaseOverride;
        pageRef3.getparameters().put('retURL', '/apex/AccountOverride?id='+GenerateTestdata.acct.Id);
        pageRef3.getparameters().put('sfdc.override', '1');
        pageRef3.getparameters().put('RecordType', Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('GCCM - Support Case Record Type').getRecordTypeId());
        pageRef3.getparameters().put('ent', 'Case');
        pageRef3.getparameters().put('save_new', '1');
        Test.setCurrentPage(pageRef3);
        CaseOverrideController fsc3 = new CaseOverrideController(sc);
        fsc3.Initialize();

        // Test 4
        PageReference pageRef4 = Page.CaseOverride;
        pageRef4.getparameters().put('retURL', '/apex/AccountOverride?id='+GenerateTestdata.acct.Id);
        pageRef4.getparameters().put('sfdc.override', '1');
        //pageRef4.getparameters().put('RecordType', Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('GCCM - Support Case Record Type').getRecordTypeId());
        pageRef4.getparameters().put('ent', 'Case');
        pageRef4.getparameters().put('save_new', '1');
        Test.setCurrentPage(pageRef4);
        CaseOverrideController fsc4 = new CaseOverrideController(sc);
        fsc4.Initialize();
        fsc1.continueCaseCreation();
        test.stopTest();
    }
    
    static testmethod void test2(){
        test.startTest();
        Country_Region_Mapping__c cust1 = new Country_Region_Mapping__c(name='United States',Region__c='Europe');
        Country_Region_Mapping__c cust2 = new Country_Region_Mapping__c(name='India',Region__c='India');
        List<Country_Region_Mapping__c> lstCustRegion = new List<Country_Region_Mapping__c>();
        lstCustRegion.add(cust1);
        lstCustRegion.add(cust2);
        insert lstCustRegion;
        
        Geospatial_Country_Region_Mapping__c custRegMap1 = new Geospatial_Country_Region_Mapping__c(name='United States',Region__c='Europe');
        Geospatial_Country_Region_Mapping__c custRegMap2 = new Geospatial_Country_Region_Mapping__c(name='India',Region__c='MEAI');
        List<Geospatial_Country_Region_Mapping__c> lstGeoRegion = new List<Geospatial_Country_Region_Mapping__c>();
        lstGeoRegion.add(custRegMap1);
        lstGeoRegion.add(custRegMap2);
        insert lstGeoRegion;
        
        GenerateTestData.createAccount();
        GenerateTestData.createProduct2();
        GenerateTestData.createContact(); 
        GenerateTestData.createAsset();
        GenerateTestData.createEntitlement();
        
        Asset ast = new Asset();
        ast.Name = 'Test Asset';
        ast.AccountId = GenerateTestdata.acct.Id;
        ast.Product2Id = GenerateTestData.prd.Id;
        ast.SerialNumber = '12345';
        insert ast;
        
        Case cs = new Case();
        cs.AccountId = GeneratetestData.acct.Id;
        cs.ContactId = GeneratetestData.ct.Id;
        cs.Status = 'New';
        cs.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Case (Plancal Internal) Record Type').getRecordTypeId();
        cs.Product__c = 'Prolog Manager';
        cs.Origin = 'Chat';
        cs.Serial_Number__c = '12345';
        cs.TFS_Id__c = '123456';
        cs.Product_Group__c = 'Prolog';
        insert cs;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(cs);
        PageReference pageRef = Page.CaseOverride;
        pageRef.getparameters().put('retURL', '/apex/AccountOverride?id='+GenerateTestdata.acct.Id);
        pageRef.getparameters().put('sfdc.override', '1');
        pageRef.getparameters().put('def_entitlement_id', GenerateTestdata.ent.Id);
        pageRef.getparameters().put('def_account_id', GenerateTestdata.acct.Id);
        pageRef.getparameters().put('def_asset_id', ast.Id);
        pageRef.getparameters().put('def_product_id', GenerateTestdata.prd.Id);
        pageRef.getparameters().put('RecordType', Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Case (Plancal Internal) Record Type').getRecordTypeId());
        pageRef.getparameters().put('ent', 'Case');
        pageRef.getparameters().put('save_new', '1');
        Test.setCurrentPage(pageRef);
        CaseOverrideController fsc1 = new CaseOverrideController(sc);
        fsc1.Initialize();

        GenerateTestData.acct.Sales_Ops_Comments__c = 'TEST Sales Ops Comment';
        update GenerateTestData.acct;
        // Test 2
        PageReference pageRef2 = Page.CaseOverride;
        pageRef2.getparameters().put('retURL', '/apex/AccountOverride?id='+GenerateTestdata.acct.Id);
        pageRef2.getparameters().put('sfdc.override', '1');
        pageRef2.getparameters().put('def_account_id', GenerateTestdata.acct.Id);
        pageRef2.getparameters().put('RecordType', Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Case (Plancal Internal) Record Type').getRecordTypeId());
        pageRef2.getparameters().put('ent', 'Case');
        pageRef2.getparameters().put('save_new', '1');
        Test.setCurrentPage(pageRef2);
        CaseOverrideController fsc2 = new CaseOverrideController(sc);
        fsc2.Initialize();

        // Test 3
        PageReference pageRef3 = Page.CaseOverride;
        pageRef3.getparameters().put('retURL', '/apex/AccountOverride?id='+GenerateTestdata.acct.Id);
        pageRef3.getparameters().put('sfdc.override', '1');
        pageRef3.getparameters().put('RecordType', Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Case (Plancal Internal) Record Type').getRecordTypeId());
        pageRef3.getparameters().put('ent', 'Case');
        pageRef3.getparameters().put('save_new', '1');
        Test.setCurrentPage(pageRef3);
        CaseOverrideController fsc3 = new CaseOverrideController(sc);
        fsc3.Initialize();

        // Test 4
        PageReference pageRef4 = Page.CaseOverride;
        pageRef4.getparameters().put('retURL', '/apex/AccountOverride?id='+GenerateTestdata.acct.Id);
        pageRef4.getparameters().put('sfdc.override', '1');
        //pageRef4.getparameters().put('RecordType', Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Case (Plancal Internal) Record Type').getRecordTypeId());
        pageRef4.getparameters().put('ent', 'Case');
        pageRef4.getparameters().put('save_new', '1');
        Test.setCurrentPage(pageRef4);
        CaseOverrideController fsc4 = new CaseOverrideController(sc);
        fsc4.Initialize();
        fsc1.continueCaseCreation();
        test.stopTest();
    }
}