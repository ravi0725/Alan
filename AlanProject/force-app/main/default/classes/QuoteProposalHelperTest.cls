@isTest(seeAllData = true)
Private class QuoteProposalHelperTest{
    
    private static Country_Region_Mapping__c cust;
    private static Geospatial_Country_Region_Mapping__c custRegMap ;
    private static Country_To_BU_Map__c custBUMap;
    private static Apttus_Proposal__Proposal__c appProp, appProp1 ;
    private static Account acct;
    private static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    private static Apttus_Config2__ProductConfiguration__c prodConfig ;
    private static Apttus_Config2__TempObject__c appTempObj ;
    private static Opportunity opp;
    private static Contact ct;
    private static Address__c adrs, adrs1;
    
    static void setUpData(){
        GenerateTestData.createAccount();
        GenerateTestData.createAddress();
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();
        GenerateTestData.createProduct2();
        GenerateTestData.createPricebook2();
        GenerateTestData.createPriceBookEntry();
        GenerateTestData.createProposal();
        
        Apttus_Proposal__Proposal__c tmp = [select id, Name from Apttus_Proposal__Proposal__c where Id =: GenerateTestData.proposal.Id];
        RecursiveTriggerUtility.isBeforeInsertQuoteProposalTrigger = false;
        QuoteProposalHandler.resetLaunchControl();
        
        GenerateTestData.proposal.Id = null;
        GenerateTestData.proposal.Clone_Id__c = tmp.Name;
        
        insert GenerateTestData.proposal;
        
        prodConfig = new Apttus_Config2__ProductConfiguration__c(name='Test Product Config',Apttus_QPConfig__Proposald__c=GenerateTestData.proposal.id);
        insert prodConfig;
        
        appTempObj = new Apttus_Config2__TempObject__c(Apttus_Config2__ConfigurationId__c=prodConfig.Id );
        insert appTempObj;
    }
    
    private static testmethod void testConfigureProducts(){
        setUpData();
        Test.startTest();
        
        String res = QuoteProposalHelper.configureProducts(GenerateTestData.proposal.Id) ;
        Test.stopTest();
    }
    
    private static testmethod void testConfigureProducts1(){
        setUpData();
        Test.startTest();
        
        String res = QuoteProposalHelper.configureProducts(GenerateTestData.proposal.Id) ;
        
        QuoteProposalHandler.resetLaunchControl();
        GenerateTestData.proposal.Apttus_Proposal__Approval_Stage__c = 'Approved';
        GenerateTestData.proposal.Apttus_Proposal__Primary__c = true;
        update GenerateTestData.proposal;
        
        QuoteProposalHandler.resetLaunchControl();
        GenerateTestData.proposal.Apttus_Proposal__Approval_Stage__c = 'Cancelled';
        update GenerateTestData.proposal;
        delete GenerateTestData.proposal;
        Test.stopTest();
    }
    
    //Added By Suresh Babu Murugan (11-Oct-2018), TT 139229: 4. Terms default
    private static testmethod void testCHTermDefault(){
        GenerateTestData.createAccount();
        GenerateTestData.createAddress();
        
        Apttus_Config2__PriceList__c pricelistCH = new Apttus_Config2__PriceList__c();
        pricelistCH.Apttus_Config2__Active__c = true;
        pricelistCH.Name = 'TIBV CH Test';
        pricelistCH.Legal_Entity__c = 'TIBV SWISS BRANCH';
        pricelistCH.Business_Area__c = 'MANHATTAN SOFTWARE';
        pricelistCH.Division__c='MEP';
        insert pricelistCH;
        
        Product2 prdCH = new Product2();
        prdCH.Name = 'testCH PRODUCT';
        prdCH.isActive = true;
        prdCH.Product_Category_Type__c ='Maintenance';
        prdCH.Contract_Item_Type_Code__c = 'SERVICE';
        prdCH.Product_Line_Description__c = 'SAAShdskjhdsfkjtest  ';
        prdCH.ProductCode = 'Test123CP-H';
        prdCH.Business_Area__c ='Plancal';
        prdCH.Family = 'Services';
        insert prdCH;

        PriceBookEntry pbeCH = new PriceBookEntry();
        pbeCH.CurrencyISOCode = 'USD';
        pbeCH.PriceBook2ID = test.getStandardPricebookId();
        pbeCH.Product2Id = prdCH.Id;
        pbeCH.IsActive = true;
        pbeCH.UnitPrice = 1;
        pbeCH.UseStandardPrice = false;
        insert pbeCH;

        Term__c trmCH = new Term__c();
        trmCH.Description__c = 'Trimble Care Pack';
        trmCH.Term_Name__c = 'CHQ-6';
        trmCH.Related_Product_Category__c = '';
        trmCH.Editable__c = TRUE;
        trmCH.Title__c = 'Care Pack';
        insert trmCH;

        Opportunity oppCH = new Opportunity();
        oppCH.AccountId = GenerateTestData.acct.Id;
        oppCH.StageName = 'Inquery';
        oppCH.Closedate = date.today() + 7;
        oppCH.Name = 'Opp1';
        oppCH.CurrencyISOCode = 'USD';
        oppCH.Price_List__c = pricelistCH.Id;
        oppCH.Selling_Division__c ='MEP NA';
        oppCH.Ship_To_Account__c = GenerateTestData.acct.ID;
        oppCH.Payment_Term__c = 'CASH IN ADVANCE';
        oppCH.Type = 'New Business';
        oppCH.Account_Sub_Type__c ='Additional Licenses';
        oppCH.OwnerId = UserInfo.getUserId();
        oppCH.Legacy_Payment_Term_Opty__c = 'CASH IN ADVANCE';
        insert oppCH;

        Apttus_Proposal__Proposal__c proposalCH = new Apttus_Proposal__Proposal__c();
        proposalCH.Apttus_Proposal__Proposal_Name__c='TestGenerateQuote';//--added by Chandrakanth to overcome error of Null pointer exception related to Proposal Attachments
        proposalCH.Apttus_Proposal__Account__c = GenerateTestData.acct.Id;
        proposalCH.Apttus_QPConfig__BillToAccountId__c = GenerateTestData.acct.id;
        proposalCH.Apttus_Proposal__Opportunity__c = oppCH.Id;
        proposalCH.Apttus_QPConfig__PriceListId__c = pricelistCH.Id; 
        proposalCH.Ship_To_Account__c = GenerateTestData.acct.Id;
        proposalCH.Bill_to_Address__c  = GenerateTestData.adrs.Id;
        proposalCH.OwnerId = UserInfo.getUserId();
        proposalCH.Apttus_Proposal__Primary__c = true;
        proposalCH.Industry__c ='Electrical';
        proposalCH.Freight_Method__c ='N/A';
        proposalCH.Freight_Terms__c ='N/A';
        proposalCH.Payment_Method__c ='INVOICE';
        proposalCH.Clone_ID__c='Q-00012683';
        insert proposalCH;

        Apttus_Proposal__Proposal_Line_Item__c proposalLiTmCH = new Apttus_Proposal__Proposal_Line_Item__c();
        proposalLiTmCH.Apttus_QPConfig__BasePrice__c = 140.48;
        proposalLiTmCH.Apttus_Proposal__Proposal__c = proposalCH.Id;
        proposalLiTmCH.CurrencyISOCode = 'USD';
        proposalLiTmCH.Apttus_QPConfig__PriceListId__c = pricelistCH.Id;
        proposalLiTmCH.Apttus_QPConfig__OptionId__c = prdCH.Id;        
        proposalLiTmCH.Apttus_Proposal__Product__c = prdCH.Id;        
        proposalLiTmCH.Apttus_Proposal__Quantity__c = 92;
        proposalLiTmCH.Apttus_QPConfig__Quantity2__c = 95;
        proposalLiTmCH.Apttus_QPConfig__PriceUom__c = 'Each';
        proposalLiTmCH.Apttus_QPConfig__ListPrice__c = 45;
        proposalLiTmCH.Apttus_QPConfig__NetPrice__c = 65;
        proposalLiTmCH.Apttus_QPConfig__SellingTerm__c = 98;
        proposalLiTmCH.Apttus_QPConfig__SellingFrequency__c = 'Work Unit';
        proposalLiTmCH.Apttus_QPConfig__LineType__c = 'Product/Service';
        
        proposalLiTmCH.Apttus_QPConfig__OptionId__c = prdCH.Id;
        proposalLiTmCH.Apttus_QPConfig__ChargeType__c = 'Maintenance Fese';
        proposalLiTmCH.Apttus_QPConfig__LineNumber__c = 67;
        insert proposalLiTmCH;

        Test.startTest();
        
        QuoteProposalHandler.resetLaunchControl();
        proposalCH.Apttus_Proposal__Approval_Stage__c = 'Approved';
        proposalCH.Apttus_Proposal__Primary__c = true;
        update proposalCH;

        Test.stopTest();
    }

	private static testmethod void testCHTermDefaultV2(){
        Account acct = new Account(Name = 'Test Assign Case Account'+GenerateTestData.generateRandomString(5), RecordTypeId = acctRecTypeId,CurrencyIsoCode = 'USD',EBS_Payment_Term__c= 'CASH IN ADVANCE',Payment_Term__c = 'CASH IN ADVANCE', Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
            FCH_Party_ID__c = null, Leasing_Customer__c = true, Enterprise_Party_Number__c ='12345',Shipping_Method__c='N/A',Payment_Method__c='Credit Card',Freight_Term__c='UPS2-Air-Air Express Plus',BillingCountry = 'India',Restricted_Entity__c = Label.Not_Restricted,Annual_Support_Date__c = date.today(), BillingCity = 'Pune',BillingState = 'Maharashtra', BillingPostalCode = 'postal code',BillingStreet = 'A-202',Collector_Email__c = 'test@gmail.com');
        insert acct;

		List<Address__c> lstAddresses = new List<Address__c>();
        Address__c adrs = new Address__c(Name = 'Test Address1',validation_Status__c='Corrected',FCH_Party_Site_Id__c = null, Account__c = acct.Id, Country__c = 'India',Bill_To__c = true,Ship_To__c=true,Address_Line1__c = 'addrs4',Address_Line2__c = 'addrs4',Address_Line3__c = 'addrs4',Address_Line4__c = 'addrs4',City__c = 'Pune',State__c = 'Maharashtra',Zip__c = 'zip');
		Address__c adrs1 = new Address__c(Name = 'Test Address2',validation_Status__c='Corrected',FCH_Party_Site_Id__c = null, Account__c = acct.Id, Country__c = 'India',Bill_To__c = true,Ship_To__c=true,Address_Line1__c = 'addrs4',Address_Line2__c = 'addrs4',Address_Line3__c = 'addrs4',Address_Line4__c = 'addrs4',City__c = 'Pune',State__c = 'Maharashtra',Zip__c = 'zip');
        lstAddresses.add(adrs);
		lstAddresses.add(adrs1);
		insert lstAddresses;
        
        Apttus_Config2__PriceList__c pricelistCH = new Apttus_Config2__PriceList__c();
        pricelistCH.Apttus_Config2__Active__c = true;
        pricelistCH.Name = 'TIBV CH Test';
        pricelistCH.Legal_Entity__c = 'TIBV SWISS BRANCH';
        pricelistCH.Business_Area__c = 'MANHATTAN SOFTWARE';
        pricelistCH.Division__c='MEP NA';
        insert pricelistCH;
        
        Product2 prdCH = new Product2();
        prdCH.Name = 'testCH PRODUCT';
        prdCH.isActive = true;
        prdCH.Product_Category_Type__c ='Maintenance';
        prdCH.Contract_Item_Type_Code__c = 'SERVICE';
        prdCH.Product_Line_Description__c = 'SAAShdskjhdsfkjtest  ';
        prdCH.ProductCode = 'Test123CP-H';
        prdCH.Business_Area__c ='Plancal';
        prdCH.Family = 'Services';
        insert prdCH;

        PriceBookEntry pbeCH = new PriceBookEntry();
        pbeCH.CurrencyISOCode = 'USD';
        pbeCH.PriceBook2ID = test.getStandardPricebookId();
        pbeCH.Product2Id = prdCH.Id;
        pbeCH.IsActive = true;
        pbeCH.UnitPrice = 1;
        pbeCH.UseStandardPrice = false;
        insert pbeCH;

        Term__c trmCH = new Term__c();
        trmCH.Description__c = 'Trimble Care Pack';
        trmCH.Term_Name__c = 'CHQ-6';
        trmCH.Related_Product_Category__c = '';
        trmCH.Editable__c = TRUE;
        trmCH.Title__c = 'Care Pack';
        insert trmCH;

        Opportunity oppCH = new Opportunity();
        oppCH.AccountId = acct.Id;
        oppCH.StageName = 'Inquery';
        oppCH.Closedate = date.today() + 7;
        oppCH.Name = 'Opp1';
        oppCH.CurrencyISOCode = 'USD';
        oppCH.Price_List__c = pricelistCH.Id;
        oppCH.Selling_Division__c ='MEP NA';
        oppCH.Ship_To_Account__c = acct.ID;
        oppCH.Payment_Term__c = 'CASH IN ADVANCE';
        oppCH.Type = 'New Business';
        oppCH.Account_Sub_Type__c ='Rental';
        oppCH.OwnerId = UserInfo.getUserId();
        oppCH.Legacy_Payment_Term_Opty__c = 'CASH IN ADVANCE';
        insert oppCH;

        Apttus_Proposal__Proposal__c proposalCH = new Apttus_Proposal__Proposal__c();
        proposalCH.Apttus_Proposal__Proposal_Name__c='TestGenerateQuote';//--added by Chandrakanth to overcome error of Null pointer exception related to Proposal Attachments
        proposalCH.Apttus_Proposal__Account__c = acct.Id;
        proposalCH.Apttus_QPConfig__BillToAccountId__c = acct.id;
        proposalCH.Apttus_Proposal__Opportunity__c = oppCH.Id;
        proposalCH.Apttus_QPConfig__PriceListId__c = pricelistCH.Id; 
        proposalCH.Ship_To_Account__c = acct.Id;
        proposalCH.Bill_to_Address__c  = adrs.Id;
		proposalCH.Ship_to_Address1__c = adrs1.Id;
        proposalCH.OwnerId = UserInfo.getUserId();
        proposalCH.Apttus_Proposal__Primary__c = true;
        proposalCH.Industry__c ='Electrical';
        proposalCH.Freight_Method__c ='N/A';
        proposalCH.Freight_Terms__c ='N/A';
        proposalCH.Payment_Method__c ='INVOICE';
        proposalCH.Clone_ID__c='Q-00012683';
        insert proposalCH;

        Apttus_Proposal__Proposal_Line_Item__c proposalLiTmCH = new Apttus_Proposal__Proposal_Line_Item__c();
        proposalLiTmCH.Apttus_QPConfig__BasePrice__c = 140.48;
        proposalLiTmCH.Apttus_Proposal__Proposal__c = proposalCH.Id;
        proposalLiTmCH.CurrencyISOCode = 'USD';
        proposalLiTmCH.Apttus_QPConfig__PriceListId__c = pricelistCH.Id;
        proposalLiTmCH.Apttus_QPConfig__OptionId__c = prdCH.Id;        
        proposalLiTmCH.Apttus_Proposal__Product__c = prdCH.Id;        
        proposalLiTmCH.Apttus_Proposal__Quantity__c = 92;
        proposalLiTmCH.Apttus_QPConfig__Quantity2__c = 95;
        proposalLiTmCH.Apttus_QPConfig__PriceUom__c = 'Each';
        proposalLiTmCH.Apttus_QPConfig__ListPrice__c = 45;
        proposalLiTmCH.Apttus_QPConfig__NetPrice__c = 65;
        proposalLiTmCH.Apttus_QPConfig__SellingTerm__c = 98;
        proposalLiTmCH.Apttus_QPConfig__SellingFrequency__c = 'Work Unit';
        proposalLiTmCH.Apttus_QPConfig__LineType__c = 'Product/Service';
        
        proposalLiTmCH.Apttus_QPConfig__OptionId__c = prdCH.Id;
        proposalLiTmCH.Apttus_QPConfig__ChargeType__c = 'Maintenance Fee';
        proposalLiTmCH.Apttus_QPConfig__LineNumber__c = 67;
        proposalLiTmCH.Service_Start_Date__c = system.today();
        proposalLiTmCH.Service_End_Date__c = system.today().addYears(1);
        insert proposalLiTmCH;

        Test.startTest();
        
        QuoteProposalHandler.resetLaunchControl();
        proposalCH.Apttus_Proposal__Approval_Stage__c = 'Approved';
        proposalCH.Apttus_Proposal__Primary__c = true;
        proposalCH.Billing_Frequency_Updated__c = false;
		proposalCH.Bill_to_Address__c  = adrs1.Id;
		proposalCH.Apttus_QPConfig__ConfigurationFinalizedDate__c = System.today() - 1;
        update proposalCH;

        Test.stopTest();
    }
}