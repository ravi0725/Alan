@isTest(seealldata = true)
public class MepNaHardwareKittest {
    static testmethod void MepNaHardwareKit1() {

        Test.setCurrentPageReference(new PageReference('Page.MepNaHardwareKitPage'));
        GenerateTestData.createAccount();
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();
        GenerateTestData.createAddress();
        GenerateTestData.createProposal();

        List<Product2> lstProducts = new List<Product2>();
        Product2 prd = new Product2();
        //prd = new Product2();
        prd.Name = 'test';
        prd.isActive = true;
        prd.Product_Category_Type__c = 'Subscription';
        prd.Contract_Item_Type_Code__c = 'WARRANTY';
        prd.Product_Line_Description__c = 'SAAShdskjhdsfkjtest  ';
        prd.ProductCode = 'HAR-OTH-USB-GN';
        prd.Family = 'Services';
        lstProducts.add(prd);

        Product2 prd1 = new Product2();
        //prd = new Product2();
        prd1.Name = 'test';
        prd1.isActive = true;
        prd1.Product_Category_Type__c = 'Subscription';
        prd1.Contract_Item_Type_Code__c = 'WARRANTY';
        prd1.Product_Line_Description__c = 'SAAShdskjhdsfkjtest  ';
        prd1.ProductCode = 'SOF-AEE-DB-EL-M';
        prd1.Family = 'Services';
        lstProducts.add(prd1);

        Product2 prd2 = new Product2();
        //prd = new Product2();
        prd2.Name = 'test';
        prd2.isActive = true;
        prd2.Product_Category_Type__c = 'Subscription';
        prd2.Contract_Item_Type_Code__c = 'WARRANTY';
        prd2.Product_Line_Description__c = 'SAAShdskjhdsfkjtest  ';
        prd2.ProductCode = 'SOF-AEE-BWP-M';
        prd2.Family = 'Services';
        lstProducts.add(prd2);

        Product2 prd3 = new Product2();
        //prd = new Product2();
        prd3.Name = 'test';
        prd3.isActive = true;
        prd3.Product_Category_Type__c = 'Subscription';
        prd3.Contract_Item_Type_Code__c = 'WARRANTY';
        prd3.Product_Line_Description__c = 'SAAShdskjhdsfkjtest  ';
        prd3.ProductCode = 'HAR-OTH-USB-GN';
        prd3.Family = 'Services';
        lstProducts.add(prd3);

        Product2 prd4 = new Product2();
        //prd = new Product2();
        prd4.Name = 'test';
        prd4.isActive = true;
        prd4.Product_Category_Type__c = 'Subscription';
        prd4.Contract_Item_Type_Code__c = 'WARRANTY';
        prd4.Product_Line_Description__c = 'SAAShdskjhdsfkjtest  ';
        prd4.ProductCode = 'DVD-ACE';
        prd4.Family = 'Services';
        lstProducts.add(prd4);

        Product2 prd5 = new Product2();
        //prd = new Product2();
        prd5.Name = 'test';
        prd5.isActive = true;
        prd5.Product_Category_Type__c = 'Subscription';
        prd5.Contract_Item_Type_Code__c = 'WARRANTY';
        prd5.Product_Line_Description__c = 'SAAShdskjhdsfkjtest  ';
        prd5.ProductCode = 'DVD-AEE-SQL';
        prd5.Family = 'Services';
        lstProducts.add(prd5);
        insert lstProducts;

        Apttus_Config2__ProductConfiguration__c acpcfg = new Apttus_Config2__ProductConfiguration__c();
        acpcfg.Name = 'test acpcfg';
        acpcfg.Apttus_QPConfig__Proposald__c = GenerateTestData.proposal.Id;
        acpcfg.Apttus_Config2__PriceListId__c = GenerateTestData.pricelist.Id;
        insert acpcfg;

        Apttus_Config2__LineItem__c standardliTm = new Apttus_Config2__LineItem__c();
        //standardliTm.Apttus_Config2__ChargeType__c = 'Standard Price';
        //standardliTm.Apttus_Config2__IsPrimaryLine__c = true;
        standardliTm.Apttus_Config2__ItemSequence__c = 1;
        standardliTm.Apttus_Config2__LineNumber__c = 1;
        standardliTm.Apttus_Config2__ConfigurationId__c = acpcfg.Id;
        standardliTm.Apttus_Config2__Quantity__c = 2;
        standardliTm.Apttus_Config2__ProductId__c = prd.Id;
        standardliTm.Apttus_Config2__PrimaryLineNumber__c = 1;
        standardliTm.Apttus_Config2__IsOptionRollupLine__c = true;
        standardliTm.Duration__c = 1;
        standardliTm.service_Start_Date__c = date.newinstance(2016, 04, 01);
        standardliTm.service_End_date__c = system.today() + 50;
        standardliTm.Duration_UOM__c = 'Year';
        standardliTm.Apttus_Config2__ChargeType__c = 'Maintenance Fee';
        standardliTm.Apttus_Config2__IsOptionRollupLine__c = False;
        standardliTm.Apttus_Config2__AdjustmentAmount__c = 100;
        standardliTm.Apttus_Config2__AdjustmentType__c = '% Discount';
        standardliTm.Apttus_Config2__PriceListId__c = GenerateTestData.pricelist.id;
        //standardliTm.Asset_Oracle_ID__c = 'test';
        //insert standardliTm;

        System.currentPageReference().getParameters().put('id', acpcfg.Id);
        System.currentPageReference().getParameters().put('ProductCode', prd.ProductCode);
        System.currentPageReference().getParameters().put('SelectedProdID', 'SOF-AEE-DB-EL-M');
        MepNaHardwareKit apc = new MepNaHardwareKit();
       // test.startTest();
        apc.SelectedProdID = prd1.ProductCode;
        apc.SelectedProdID1 = prd2.ProductCode;
        apc.SelectedProdID2 = prd5.ProductCode;
        //apc.AddselectedProduct();
        test.startTest();
        //apc.AddselectedProductWizard2();
        apc.AddselectedProductWizard3();
       // apc.GotoCart();
        test.stopTest();
    }

    static testmethod void MepNaHardwareKit2() {

        Test.setCurrentPageReference(new PageReference('Page.MepNaHardwareKitPage'));
        GenerateTestData.createAccount();
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();
        GenerateTestData.createAddress();
        GenerateTestData.createProposal();

        List<Product2> lstProducts = new List<Product2>();
        Product2 prd = new Product2();
        //prd = new Product2();
        prd.Name = 'test';
        prd.isActive = true;
        prd.Product_Category_Type__c = 'Subscription';
        prd.Contract_Item_Type_Code__c = 'WARRANTY';
        prd.Product_Line_Description__c = 'SAAShdskjhdsfkjtest  ';
        prd.ProductCode = 'SOF-ACE-DB-EL-M';
        prd.Family = 'Services';
        lstProducts.add(prd);

        Product2 prd1 = new Product2();
        //prd = new Product2();
        prd1.Name = 'test';
        prd1.isActive = true;
        prd1.Product_Category_Type__c = 'Subscription';
        prd1.Contract_Item_Type_Code__c = 'WARRANTY';
        prd1.Product_Line_Description__c = 'SAAShdskjhdsfkjtest  ';
        prd1.ProductCode = 'SOF-ACE-PB-M';
        prd1.Family = 'Services';
        lstProducts.add(prd1);

        Product2 prd3 = new Product2();
        //prd = new Product2();
        prd3.Name = 'test';
        prd3.isActive = true;
        prd3.Product_Category_Type__c = 'Subscription';
        prd3.Contract_Item_Type_Code__c = 'WARRANTY';
        prd3.Product_Line_Description__c = 'SAAShdskjhdsfkjtest  ';
        prd3.ProductCode = 'HAR-OTH-USB-GN';
        prd3.Family = 'Services';
        lstProducts.add(prd3);

        Product2 prd4 = new Product2();
        //prd = new Product2();
        prd4.Name = 'test';
        prd4.isActive = true;
        prd4.Product_Category_Type__c = 'Subscription';
        prd4.Contract_Item_Type_Code__c = 'WARRANTY';
        prd4.Product_Line_Description__c = 'SAAShdskjhdsfkjtest  ';
        prd4.ProductCode = 'DVD-ACE';
        prd4.Family = 'Services';
        lstProducts.add(prd4);

        Product2 prd5 = new Product2();
        //prd = new Product2();
        prd5.Name = 'test';
        prd5.isActive = true;
        prd5.Product_Category_Type__c = 'Subscription';
        prd5.Contract_Item_Type_Code__c = 'WARRANTY';
        prd5.Product_Line_Description__c = 'SAAShdskjhdsfkjtest  ';
        prd5.ProductCode = 'DVD-AEE-SQL';
        prd5.Family = 'Services';
        lstProducts.add(prd5);
        insert lstProducts;

        Apttus_Config2__ProductConfiguration__c acpcfg = new Apttus_Config2__ProductConfiguration__c();
        acpcfg.Name = 'test acpcfg';
        acpcfg.Apttus_QPConfig__Proposald__c = GenerateTestData.proposal.Id;
        acpcfg.Apttus_Config2__PriceListId__c = GenerateTestData.pricelist.Id;
        insert acpcfg;

        Apttus_Config2__LineItem__c standardliTm = new Apttus_Config2__LineItem__c();
        //standardliTm.Apttus_Config2__ChargeType__c = 'Standard Price';
        //standardliTm.Apttus_Config2__IsPrimaryLine__c = true;
        standardliTm.Apttus_Config2__ItemSequence__c = 1;
        standardliTm.Apttus_Config2__LineNumber__c = 1;
        standardliTm.Apttus_Config2__ConfigurationId__c = acpcfg.Id;
        standardliTm.Apttus_Config2__Quantity__c = 2;
        standardliTm.Apttus_Config2__ProductId__c = prd.Id;
        standardliTm.Apttus_Config2__PrimaryLineNumber__c = 1;
        standardliTm.Apttus_Config2__IsOptionRollupLine__c = true;
        standardliTm.Duration__c = 1;
        standardliTm.service_Start_Date__c = date.newinstance(2016, 04, 01);
        standardliTm.service_End_date__c = system.today() + 50;
        standardliTm.Duration_UOM__c = 'Year';
        standardliTm.Apttus_Config2__ChargeType__c = 'Maintenance Fee';
        standardliTm.Apttus_Config2__IsOptionRollupLine__c = False;
        standardliTm.Apttus_Config2__AdjustmentAmount__c = 100;
        standardliTm.Apttus_Config2__AdjustmentType__c = '% Discount';
        standardliTm.Apttus_Config2__PriceListId__c = GenerateTestData.pricelist.id;
        //standardliTm.Asset_Oracle_ID__c = 'test';
       // insert standardliTm;

        System.currentPageReference().getParameters().put('id', acpcfg.Id);
        System.currentPageReference().getParameters().put('ProductCode', prd.ProductCode);
        System.currentPageReference().getParameters().put('SelectedProdID', 'SOF-ACE-PB-M');
        MepNaHardwareKit apc = new MepNaHardwareKit();
        test.startTest();
        apc.SelectedProdID = prd1.ProductCode;

        apc.AddselectedProduct();
        apc.GotoCart();
        test.stopTest();
    }
    
     static testmethod void MepNaHardwareKit3() {

        Test.setCurrentPageReference(new PageReference('Page.MepNaHardwareKitPage'));
        GenerateTestData.createAccount();
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();
        GenerateTestData.createAddress();
        GenerateTestData.createProposal();

        List<Product2> lstProducts = new List<Product2>();
        Product2 prd = new Product2();
        //prd = new Product2();
        prd.Name = 'test';
        prd.isActive = true;
        prd.Product_Category_Type__c = 'Subscription';
        prd.Contract_Item_Type_Code__c = 'WARRANTY';
        prd.Product_Line_Description__c = 'SAAShdskjhdsfkjtest  ';
        prd.ProductCode = 'HAR-OTH-USB-GN';
        prd.Family = 'Services';
        lstProducts.add(prd);

        Product2 prd1 = new Product2();
        //prd = new Product2();
        prd1.Name = 'test';
        prd1.isActive = true;
        prd1.Product_Category_Type__c = 'Subscription';
        prd1.Contract_Item_Type_Code__c = 'WARRANTY';
        prd1.Product_Line_Description__c = 'SAAShdskjhdsfkjtest  ';
        prd1.ProductCode = 'SOF-AEE-DB-EL-M';
        prd1.Family = 'Services';
        lstProducts.add(prd1);

        Product2 prd2 = new Product2();
        //prd = new Product2();
        prd2.Name = 'test';
        prd2.isActive = true;
        prd2.Product_Category_Type__c = 'Subscription';
        prd2.Contract_Item_Type_Code__c = 'WARRANTY';
        prd2.Product_Line_Description__c = 'SAAShdskjhdsfkjtest  ';
        prd2.ProductCode = 'SOF-AEE-BWP-M';
        prd2.Family = 'Services';
        lstProducts.add(prd2);

        Product2 prd3 = new Product2();
        //prd = new Product2();
        prd3.Name = 'test';
        prd3.isActive = true;
        prd3.Product_Category_Type__c = 'Subscription';
        prd3.Contract_Item_Type_Code__c = 'WARRANTY';
        prd3.Product_Line_Description__c = 'SAAShdskjhdsfkjtest  ';
        prd3.ProductCode = 'HAR-OTH-USB-GN';
        prd3.Family = 'Services';
        lstProducts.add(prd3);

        Product2 prd4 = new Product2();
        //prd = new Product2();
        prd4.Name = 'test';
        prd4.isActive = true;
        prd4.Product_Category_Type__c = 'Subscription';
        prd4.Contract_Item_Type_Code__c = 'WARRANTY';
        prd4.Product_Line_Description__c = 'SAAShdskjhdsfkjtest  ';
        prd4.ProductCode = 'DVD-ACE';
        prd4.Family = 'Services';
        lstProducts.add(prd4);

        Product2 prd5 = new Product2();
        //prd = new Product2();
        prd5.Name = 'test';
        prd5.isActive = true;
        prd5.Product_Category_Type__c = 'Subscription';
        prd5.Contract_Item_Type_Code__c = 'WARRANTY';
        prd5.Product_Line_Description__c = 'SAAShdskjhdsfkjtest  ';
        prd5.ProductCode = 'DVD-AEE-SQL';
        prd5.Family = 'Services';
        lstProducts.add(prd5);
        insert lstProducts;

        Apttus_Config2__ProductConfiguration__c acpcfg = new Apttus_Config2__ProductConfiguration__c();
        acpcfg.Name = 'test acpcfg';
        acpcfg.Apttus_QPConfig__Proposald__c = GenerateTestData.proposal.Id;
        acpcfg.Apttus_Config2__PriceListId__c = GenerateTestData.pricelist.Id;
        insert acpcfg;

        Apttus_Config2__LineItem__c standardliTm = new Apttus_Config2__LineItem__c();
        //standardliTm.Apttus_Config2__ChargeType__c = 'Standard Price';
        //standardliTm.Apttus_Config2__IsPrimaryLine__c = true;
        standardliTm.Apttus_Config2__ItemSequence__c = 1;
        standardliTm.Apttus_Config2__LineNumber__c = 1;
        standardliTm.Apttus_Config2__ConfigurationId__c = acpcfg.Id;
        standardliTm.Apttus_Config2__Quantity__c = 2;
        standardliTm.Apttus_Config2__ProductId__c = prd.Id;
        standardliTm.Apttus_Config2__PrimaryLineNumber__c = 1;
        standardliTm.Apttus_Config2__IsOptionRollupLine__c = true;
        standardliTm.Duration__c = 1;
        standardliTm.service_Start_Date__c = date.newinstance(2016, 04, 01);
        standardliTm.service_End_date__c = system.today() + 50;
        standardliTm.Duration_UOM__c = 'Year';
        standardliTm.Apttus_Config2__ChargeType__c = 'Maintenance Fee';
        standardliTm.Apttus_Config2__IsOptionRollupLine__c = False;
        standardliTm.Apttus_Config2__AdjustmentAmount__c = 100;
        standardliTm.Apttus_Config2__AdjustmentType__c = '% Discount';
        standardliTm.Apttus_Config2__PriceListId__c = GenerateTestData.pricelist.id;
        //standardliTm.Asset_Oracle_ID__c = 'test';
       // insert standardliTm;

        System.currentPageReference().getParameters().put('id', acpcfg.Id);
        System.currentPageReference().getParameters().put('ProductCode', prd.ProductCode);
        System.currentPageReference().getParameters().put('SelectedProdID', 'SOF-AEE-DB-EL-M');
        MepNaHardwareKit apc = new MepNaHardwareKit();
       // test.startTest();
        apc.SelectedProdID = prd1.ProductCode;
        apc.SelectedProdID1 = prd2.ProductCode;
        apc.SelectedProdID2 = prd5.ProductCode;
        //apc.AddselectedProduct();
        test.startTest();
        apc.AddselectedProductWizard2();
       // apc.AddselectedProductWizard3();
       // apc.GotoCart();
        test.stopTest();
    }
    
    static testmethod void MepNaHardwareKit4() {

        Test.setCurrentPageReference(new PageReference('Page.MepNaHardwareKitPage'));
        GenerateTestData.createAccount();
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();
        GenerateTestData.createAddress();
        GenerateTestData.createProposal();

        List<Product2> lstProducts = new List<Product2>();
        Product2 prd = new Product2();
        //prd = new Product2();
        prd.Name = 'test';
        prd.isActive = true;
        prd.Product_Category_Type__c = 'Subscription';
        prd.Contract_Item_Type_Code__c = 'WARRANTY';
        prd.Product_Line_Description__c = 'SAAShdskjhdsfkjtest  ';
        prd.ProductCode = 'SUB-ANY- ESTCM-SUITE-ADDON-D';
        prd.Family = 'Services';
        lstProducts.add(prd);

        Product2 prd1 = new Product2();
        //prd = new Product2();
        prd1.Name = 'test';
        prd1.isActive = true;
        prd1.Product_Category_Type__c = 'Subscription';
        prd1.Contract_Item_Type_Code__c = 'WARRANTY';
        prd1.Product_Line_Description__c = 'SAAShdskjhdsfkjtest  ';
        prd1.ProductCode = 'SUB-TS-SX-SUBMAN-EL';
        prd1.Family = 'Services';
        lstProducts.add(prd1);

        Product2 prd2 = new Product2();
        //prd = new Product2();
        prd2.Name = 'test';
        prd2.isActive = true;
        prd2.Product_Category_Type__c = 'Subscription';
        prd2.Contract_Item_Type_Code__c = 'WARRANTY';
        prd2.Product_Line_Description__c = 'SAAShdskjhdsfkjtest  ';
        prd2.ProductCode = 'SUB-TS-ICT-ADDON-D';
        prd2.Family = 'Services';
        lstProducts.add(prd2);

        Product2 prd3 = new Product2();
        //prd = new Product2();
        prd3.Name = 'test';
        prd3.isActive = true;
        prd3.Product_Category_Type__c = 'Subscription';
        prd3.Contract_Item_Type_Code__c = 'WARRANTY';
        prd3.Product_Line_Description__c = 'SAAShdskjhdsfkjtest  ';
        prd3.ProductCode = 'SUB-TS-SX-SUBMAN-P';
        prd3.Family = 'Services';
        lstProducts.add(prd3);

        Product2 prd4 = new Product2();
        //prd = new Product2();
        prd4.Name = 'test';
        prd4.isActive = true;
        prd4.Product_Category_Type__c = 'Subscription';
        prd4.Contract_Item_Type_Code__c = 'WARRANTY';
        prd4.Product_Line_Description__c = 'SAAShdskjhdsfkjtest  ';
        prd4.ProductCode = 'DVD-ACE';
        prd4.Family = 'Services';
        lstProducts.add(prd4);

        Product2 prd5 = new Product2();
        //prd = new Product2();
        prd5.Name = 'test';
        prd5.isActive = true;
        prd5.Product_Category_Type__c = 'Subscription';
        prd5.Contract_Item_Type_Code__c = 'WARRANTY';
        prd5.Product_Line_Description__c = 'SAAShdskjhdsfkjtest  ';
        prd5.ProductCode = 'DVD-AEE-SQL';
        prd5.Family = 'Services';
        lstProducts.add(prd5);
        insert lstProducts;

        Apttus_Config2__ProductConfiguration__c acpcfg = new Apttus_Config2__ProductConfiguration__c();
        acpcfg.Name = 'test acpcfg';
        acpcfg.Apttus_QPConfig__Proposald__c = GenerateTestData.proposal.Id;
        acpcfg.Apttus_Config2__PriceListId__c = GenerateTestData.pricelist.Id;
        insert acpcfg;

        Apttus_Config2__LineItem__c standardliTm = new Apttus_Config2__LineItem__c();
        //standardliTm.Apttus_Config2__ChargeType__c = 'Standard Price';
        //standardliTm.Apttus_Config2__IsPrimaryLine__c = true;
        standardliTm.Apttus_Config2__ItemSequence__c = 1;
        standardliTm.Apttus_Config2__LineNumber__c = 1;
        standardliTm.Apttus_Config2__ConfigurationId__c = acpcfg.Id;
        standardliTm.Apttus_Config2__Quantity__c = 2;
        standardliTm.Apttus_Config2__ProductId__c = prd.Id;
        standardliTm.Apttus_Config2__PrimaryLineNumber__c = 1;
        standardliTm.Apttus_Config2__IsOptionRollupLine__c = true;
        standardliTm.Duration__c = 1;
        standardliTm.service_Start_Date__c = date.newinstance(2016, 04, 01);
        standardliTm.service_End_date__c = system.today() + 50;
        standardliTm.Duration_UOM__c = 'Year';
        standardliTm.Apttus_Config2__ChargeType__c = 'Maintenance Fee';
        standardliTm.Apttus_Config2__IsOptionRollupLine__c = False;
        standardliTm.Apttus_Config2__AdjustmentAmount__c = 100;
        standardliTm.Apttus_Config2__AdjustmentType__c = '% Discount';
        standardliTm.Apttus_Config2__PriceListId__c = GenerateTestData.pricelist.id;
        //standardliTm.Asset_Oracle_ID__c = 'test';
       // insert standardliTm;

        System.currentPageReference().getParameters().put('id', acpcfg.Id);
        System.currentPageReference().getParameters().put('ProductCode', prd.ProductCode);
        System.currentPageReference().getParameters().put('SelectedProdID', 'SUB-TS-SX-SUBMAN-EL');
        MepNaHardwareKit apc = new MepNaHardwareKit();
       // test.startTest();
        apc.SelectedProdID = prd1.ProductCode;
        apc.SelectedProdID1 = prd2.ProductCode;
        apc.SelectedProdID2 = prd5.ProductCode;
        //apc.AddselectedProduct();
        test.startTest();
        apc.cartid = acpcfg.Id;
        apc.AddselectedProduct();
        test.stopTest();
    }
}