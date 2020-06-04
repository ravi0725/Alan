/**
 * Company     : Trimble Software Technology Pvt Ltd.,
 * Description : Master Test Class
 * History     :
 
 * [16.10.2014] Ankur Patel  Created
 */
@isTest
public class GenerateTestData {
    public static Lead LeadObj;
    public static Event eventObj;
    public static Country_Region_Mapping__c cust;
    public static Payment_Term_Order__c PaymentTerm;
    public static Geospatial_Country_Region_Mapping__c custRegMap;
    public static User ur;
    public static Account acct;
    public static Account acct1;
    public static Account acc;
    public static Contact ct;
    public static Opportunity opp;
    public static Product2 prd;
    public static Product2 prd1;
    public static Product2 prd2;
    public static PriceBook2 pb;
    public static PriceBookEntry pbe;
    public static account acctcon;
    public static Apttus_Proposal__Proposal__c proposal;
    public static Apttus_Config2__PriceList__c pricelist;
    public static Apttus_Config2__PriceList__c pricelist1;
    public static Apttus_Config2__PriceListItem__c priceListItem;
    public static Apttus_QPConfig__ProposalSummary__c proposalSum;
    public static Apttus_QPConfig__ProposalSummaryGroup__c proposalSumGrp;
    public static Apttus_Proposal__Proposal_Line_Item__c proposalLiTm;
    public static Apttus_Proposal__Proposal_Line_Item__c proposalLiTm1;
    public static Apttus_Config2__LineItem__c standardliTm;
    public static Apttus_Config2__LineItem__c maintenceliTm, stdliTm;
    public static Apttus_Config2__AssetLineItem__c assLiTm;
    public static Apttus_Config2__TempObject__c tempObj;
    public static Price_Book_Config__c priceBookConfig;
    public static Group gp;
    public static GroupMember gpMem;
    public static Case cs;
    public static Case pcs;
    public static Case dcs;
    public static Proposal_Template_Config__c proposalTemplateConfig;
    public static Attachment attachment;
    public static Address__c adrs;
    public static Apttus__APTS_Agreement__c apg;
    public static Apttus_CMConfig__AgreementSummaryGroup__c acg;
    public static Apttus__AgreementLineItem__c aglt;
    public static Apttus_Config2__ProductConfiguration__c acpcfg;
    public static Entitlement ent;
    public static VF_Page_Paggination_Config__c pageNo;
    public static System_Integration_Config__c sysIntegrationURL;
    public static Asset asst;
    public static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    public static Import_Data__c idcAcc;
    public static Import_Data__c idcAdrs;
    public static Import_Data__c idcnt;
    public static Attachment impDtAccAttach;
    public static Attachment impDtAdrsAttach;
    public static Attachment impDtCntAttach;

    public static void createAttachment() {
        attachment = new Attachment();
        attachment.Body = Blob.valueOf('Test');
        attachment.Name = String.valueOf('test.txt');
        attachment.ParentId = proposal.Id;
        insert attachment;
        System.debug('==========attachment===============' + attachment);
    }

    public static void createSystemIntegrationURL() {
        List<System_Integration_Config__c> systemURLList = new List<System_Integration_Config__c> ();
        sysIntegrationURL = new System_Integration_Config__c();
        sysIntegrationURL.Name = 'FCH_Integration_Production';
        sysIntegrationURL.End_Point_URL__c = '';
        systemURLList.add(sysIntegrationURL);

        sysIntegrationURL = new System_Integration_Config__c();
        sysIntegrationURL.Name = 'FCH_Search_Production';
        sysIntegrationURL.End_Point_URL__c = '';
        systemURLList.add(sysIntegrationURL);

        sysIntegrationURL = new System_Integration_Config__c();
        sysIntegrationURL.Name = 'QuoteToOrder_Production';
        sysIntegrationURL.End_Point_URL__c = '';
        systemURLList.add(sysIntegrationURL);


        sysIntegrationURL = new System_Integration_Config__c();
        sysIntegrationURL.Name = 'TFS_Attachment_Production';
        sysIntegrationURL.End_Point_URL__c = '';
        systemURLList.add(sysIntegrationURL);


        sysIntegrationURL = new System_Integration_Config__c();
        sysIntegrationURL.Name = 'TFS_Integration_Production';
        sysIntegrationURL.End_Point_URL__c = '';
        systemURLList.add(sysIntegrationURL);



        sysIntegrationURL = new System_Integration_Config__c();
        sysIntegrationURL.Name = 'TFS_Search_Production';
        sysIntegrationURL.End_Point_URL__c = '';
        systemURLList.add(sysIntegrationURL);

        sysIntegrationURL = new System_Integration_Config__c();
        sysIntegrationURL.Name = 'FCH_Integration_Sandbox';
        sysIntegrationURL.End_Point_URL__c = '';
        systemURLList.add(sysIntegrationURL);

        sysIntegrationURL = new System_Integration_Config__c();
        sysIntegrationURL.Name = 'FCH_Search_Sandbox';
        sysIntegrationURL.End_Point_URL__c = '';
        systemURLList.add(sysIntegrationURL);

        sysIntegrationURL = new System_Integration_Config__c();
        sysIntegrationURL.Name = 'QuoteToOrder_Sandbox';
        sysIntegrationURL.End_Point_URL__c = '';
        systemURLList.add(sysIntegrationURL);


        sysIntegrationURL = new System_Integration_Config__c();
        sysIntegrationURL.Name = 'TFS_Attachment_Sandbox';
        sysIntegrationURL.End_Point_URL__c = '';
        systemURLList.add(sysIntegrationURL);


        sysIntegrationURL = new System_Integration_Config__c();
        sysIntegrationURL.Name = 'TFS_Integration_Sandbox';
        sysIntegrationURL.End_Point_URL__c = '';
        systemURLList.add(sysIntegrationURL);



        sysIntegrationURL = new System_Integration_Config__c();
        sysIntegrationURL.Name = 'TFS_Search_Sandbox';
        sysIntegrationURL.End_Point_URL__c = '';

        insert systemURLList;
        System.debug('==========attachment===============' + attachment);
    }
    public static void createcaseAttachment() {
        attachment = new Attachment();
        attachment.Body = Blob.valueOf('Test');
        attachment.Name = String.valueOf('test.txt');
        attachment.ParentId = dcs.Id;
        insert attachment;
        System.debug('==========attachment===============' + attachment);
    }

    public static void createEvent() {
        eventObj = new Event();
        eventObj.Subject = '';
        eventObj.WhatId = proposal.Id;
        eventObj.Type = 'Other';
        eventObj.ActivityDate = date.today();
        eventObj.DurationInMinutes = 30;
        eventObj.ActivityDateTime = datetime.now();
        insert eventObj;
    }

    public static void createGroup() {
        gp = new Group();
        gp.Name = 'CAD_FR_Nova_Technic_Team';
        insert gp;
    }

    public static void createGroupMember() {
        gpMem = new GroupMember();
        gpMem.groupId = gp.Id;
        gpMem.UserOrGroupId = userinfo.getUserId();
        insert gpMem;
    }

    public static void createTAPCase() {
        pcs = new Case();
        pcs.AccountId = acct.Id;
        pcs.ContactId = ct.Id;
        pcs.Status = 'New';
        pcs.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('TAP - Customer Support').getRecordTypeId();
        insert pcs;
    }

    public static void createParentCase() {
        pcs = new Case();
        pcs.AccountId = acct.Id;
        pcs.ContactId = ct.Id;
        pcs.Status = 'New';
        pcs.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('GCCM - Support Case Record Type').getRecordTypeId();
        insert pcs;
    }

    public static void createdefectCase() {
        dcs = new Case();
        dcs.AccountId = acct.Id;
        dcs.ContactId = ct.Id;
        dcs.Status = 'New';
        dcs.TFS_Id__c = '12345';
        dcs.Product__c = 'Prolog';
        dcs.Origin = 'Chat';
        dcs.Serial_Number__c = '12345';
        dcs.TFS_Id__c = '123456';
        dcs.Defect__c = dcs.Id;
        dcs.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('GCCM - Support Issue Record Type').getRecordTypeId();
        insert dcs;
    }

    public static void createCase() {
        cs = new Case();
        cs.AccountId = acct.Id;
        cs.ContactId = ct.Id;
        cs.Status = 'New';
        cs.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('GCCM - Support Case Record Type').getRecordTypeId();
        cs.ParentId = pcs.Id;
        cs.Product__c = 'Prolog Manager';
        cs.Origin = 'Chat';
        cs.Serial_Number__c = '12345';
        cs.TFS_Id__c = '123456';
        cs.Defect__c = dcs.Id;
        insert cs;
    }

    public static void createUser(Id ProfileId) {
        ur = new User(
                      ProfileId = ProfileId,
                      LastName = 'last',
                      Email = 'trimbletestuser@trimble.com',
                      Username = 'trimbletestuser@trimble.com' + System.currentTimeMillis(),
                      Alias = 'alias',
                      TimeZoneSidKey = 'America/Los_Angeles',
                      EmailEncodingKey = 'UTF-8',
                      LanguageLocaleKey = 'en_US',
                      LocaleSidKey = 'en_US'
        );
    }

    public static void customSettingRds() {
        List<Country_Region_Mapping__c> custList = new List<Country_Region_Mapping__c> ();
        cust = new Country_Region_Mapping__c(name = 'United States', Region__c = 'Europe');
        custList.add(cust);

        cust = new Country_Region_Mapping__c(name = 'India', Region__c = 'Europe');
        custList.add(cust);

        insert custList;

        custRegMap = new Geospatial_Country_Region_Mapping__c(name = 'United States', Region__c = 'Europe');
        insert custRegMap;

        PaymentTerm = new Payment_Term_Order__c(name = 'CASH IN ADVANCE', Number_of_Days__c = 20);
        insert PaymentTerm;
    }

    public static void CreateParentAccount() {
        acc = new Account(Name = 'Test Assign Case Account parent' + system.now(), RecordTypeId = acctRecTypeId, Account_Status__c = 'Pending', Requested_Account_Record_Type__c = 'Customer', Account_Division__c = 'TAP',
                          BillingCountry = 'United States', BillingPostalCode = '600006', BillingCity = 'Pune', BillingStreet = 'A-202', Collector_Email__c = 'test@gmail.com');
        insert acc;

    }


    public static void createAccount() {
        GenerateTestData.CreateParentAccount();
        acct = new Account(Name = 'Test Assign Case Account' + generateRandomString(5), RecordTypeId = acctRecTypeId, CurrencyIsoCode = 'USD', EBS_Payment_Term__c = 'CASH IN ADVANCE', Payment_Term__c = 'CASH IN ADVANCE', Parent_Account_ID__c = acc.Id, Account_Status__c = 'Pending', Requested_Account_Record_Type__c = 'Customer',
                           FCH_Party_ID__c = '111111', Enterprise_Party_Number__c = '12345', Shipping_Method__c = 'N/A', Payment_Method__c = 'Credit Card', Freight_Term__c = 'UPS2-Air-Air Express Plus', BillingCountry = 'India', Restricted_Entity__c = Label.Not_Restricted, Annual_Support_Date__c = date.today(), BillingCity = 'Pune', BillingState = 'Maharashtra', BillingPostalCode = 'postal code', BillingStreet = 'A-202', Collector_Email__c = 'test@gmail.com', ParentId = acc.Id);
        insert acct;
    }

    public static void createAccountContact() {
        GenerateTestData.CreateParentAccount();
        acctcon = new Account(LifeCycle_Stage__c = 'Customer', Account_Status__c = 'Active', Name = 'Test Assign Case Account' + generateRandomString(5), RecordTypeId = acctRecTypeId, CurrencyIsoCode = 'USD', EBS_Payment_Term__c = 'CASH IN ADVANCE', Payment_Term__c = 'CASH IN ADVANCE', Parent_Account_ID__c = acc.Id, Requested_Account_Record_Type__c = 'Customer',
                              FCH_Party_ID__c = '111111', Enterprise_Party_Number__c = '12345', Shipping_Method__c = 'N/A', Payment_Method__c = 'Credit Card', Freight_Term__c = 'UPS2-Air-Air Express Plus', BillingCountry = 'India', Restricted_Entity__c = Label.Not_Restricted, Annual_Support_Date__c = date.today(), BillingCity = 'Pune', BillingState = 'Maharashtra', BillingPostalCode = 'postal code', BillingStreet = 'A-202', Collector_Email__c = 'test@gmail.com', ParentId = acc.Id);
        insert acctcon;
    }

    public static void createlead() {
        LeadObj = new Lead(lastname = 'TestLead' + generateRandomString(5),Tracking_Division__c='MEP NA',Selling_division__c='MEP NA', company = 'TestCompany', Street = 'Sample Street', City = 'Milpitas', State = 'California', Country = 'United States', County__c = 'Santa Clara', Postalcode = '09876');
        insert LeadObj;
    }
    public static void createAsset() {
        asst = new Asset();
        asst.AccountId = acct.Id;
        asst.Asset_Oracle_ID__c = '391G';
        asst.Name = 'WinEst';
        asst.Available_Quantity__c = 2;
        asst.Quantity_To_be_Upgraded__c = 2;
        asst.Reason_Code__c = 'Upgrade';
        

        insert asst;
    }

    public static void createContact() {
        ct = new Contact();
        ct.LastName = 'Test last name' + generateRandomString(5);
        ct.AccountId = acct.Id;
        ct.Preferred_Language__c = 'American English';
        ct.Email = 'test@gmail.com';
        ct.MarketingListTAP__c = true;
        ct.Unique_Contact_Relationship__c = true;
        ct.MailingStreet = 'test1';
        ct.Mailingcity = 'testcity';
        ct.MailingState = 'California';
        ct.MailingPostalCode = '12345';
        ct.MailingCountry = 'United States';
        ct.Salutation = 'Mr.';
        ct.Phone = '0802345566';
        ct.Role_on_Account__c = 'Accounting';
        insert ct;

    }

    public static void createAddress() {
        adrs = new Address__c(Name = 'Test Address', validation_Status__c = 'Corrected', FCH_Party_Site_Id__c = '222222', Account__c = acct.Id, Country__c = 'United States', Bill_To__c = true, Ship_To__c = true, Address_Line1__c = 'addrs4', Address_Line2__c = 'addrs4', Address_Line3__c = 'addrs4', Address_Line4__c = 'addrs4', City__c = 'city', State__c = 'California', Zip__c = 'zip');
        insert adrs;
    }

    public static void createEntitlement() {
        ent = new Entitlement();
        ent.Name = 'Test Entitlement';
        ent.Entitlement_Product__c = prd.Id;
        if (asst != null) ent.AssetId = asst.Id;
        ent.AccountId = acct.Id;
        insert ent;
    }

    public static void createOpportunity() {
        opp = new Opportunity();
        opp.AccountId = acct.Id;
        opp.StageName = 'Inquery';
        opp.Closedate = date.today() + 7;
        opp.Name = 'Opp1';
        opp.CurrencyISOCode = 'USD';
        opp.Price_List__c = pricelist.Id;
        opp.Selling_Division__c = 'MEP NA';
        opp.Ship_To_Account__c = acct.ID;
        opp.Payment_Term__c = 'CASH IN ADVANCE';
        opp.Type = 'New Business';
        opp.Account_Sub_Type__c = 'Additional Licenses';
        opp.OwnerId = UserInfo.getUserId();
        insert opp;
    }

    public static void createProduct2() {
        List<Product2> prdList = new List<Product2> ();
        prd = new Product2();
        prd.Name = 'test';
        prd.isActive = true;
        prd.Product_Category_Type__c = 'Subscription';
        prd.Contract_Item_Type_Code__c = 'WARRANTY';
        prd.Product_Line_Description__c = 'SAAShdskjhdsfkjtest  ';
        prd.ProductCode = 'Test123';
        prd.Business_Area__c = 'MANHATTAN SOFTWARE';
        prd.Family = 'Services';

        prdList.add(prd);

        prd1 = new Product2();
        prd1.Name = 'test';
        prd1.isActive = true;
        prd1.Product_Category_Type__c = 'SaaS';
        prd1.Contract_Item_Type_Code__c = 'WARRANTY';
        prd1.Product_Line_Description__c = 'hdskjhdsfkjtest SAAS';
        prd1.ProductCode = 'Test456';
        prdList.add(prd1);

        prd2 = new Product2();
        prd2.Name = 'test';
        prd2.isActive = true;
        prd2.Product_Category_Type__c = 'SaaS';
        prd2.Contract_Item_Type_Code__c = 'WARRANTY';
        prd2.Product_Line_Description__c = 'hdskjhdsfkjtest SAAS';
        prd2.ProductCode = 'Test456';
        prd2.Business_Area__c = 'MEP ESTIMATING';
        prdList.add(prd2);

        insert prdList;

        System.debug('--------------prdId----------------' + prd.Id + '-------------prd1Id-----------' + prd1.Id);
    }

    public static void createPricebook2() {
        pb = new PriceBook2();
        pb.Name = 'GCCM Price Book';
        pb.IsActive = true;
        insert pb;
    }

    public static void createApttusConfig2PriceListItem() {
        PriceListItem = new Apttus_Config2__PriceListItem__c();
        PriceListItem.CurrencyISOCode = 'USD';
        PriceListItem.Apttus_Config2__ProductId__c = prd.Id;
        PriceListItem.Apttus_Config2__PriceListId__c = pricelist.Id;
        PriceListItem.Apttus_Config2__ChargeType__c = 'Standard Price';
        PriceListItem.Apttus_Config2__ListPrice__c = 123;
        insert PriceListItem;
    }

    public static void createApttusAgreementLineItem() {
        aglt = new Apttus__AgreementLineItem__c();
        aglt.Apttus__AgreementId__c = apg.Id;
        aglt.Apttus__NetPrice__c = 10;

        insert aglt;

    }
    public static void createAPTSAgreement() {
        apg = new Apttus__APTS_Agreement__c();
        apg.Fusion_Project_Number__c = 'test';
        apg.Apttus__Contract_Start_Date__c = date.today();
        apg.Apttus__Contract_End_Date__c = date.today() + 5;
        apg.ProServ_Type__c = 'Fixed Fee';
        apg.Credit_Status__c = 'test';
        apg.Credit_Approved__c = 'test Credit_Approved__c';
        apg.CREDIT_LIMIT_AVAILABLE__C = 10;
        apg.CREDIT_EXISTING_EXPOSURE__C = 10;
        apg.CREDIT_CALCULATED_EXPOSURE__c = 10;
        apg.CREDIT_TOTAL_EXPOSURE__c = 10;
        apg.Fusion_Project_Number__c = 'test Fusion_Project_Number__c';
        apg.Apttus_QPComply__RelatedProposalId__c = GenerateTestData.proposal.Id;
        apg.Apttus__Related_Opportunity__c = GenerateTestData.opp.Id;
        apg.Apttus__Status_Category__c = 'In Effect : Submitted';
        apg.Apttus__Status__c = 'Activated';
        apg.Apttus_CMConfig__PriceListId__c = pricelist.Id;
        apg.Apttus__Status_Category__c = 'In Effect : Submitted';
        apg.Apttus__Status__c = 'Activated';
        insert apg;

        apg = new Apttus__APTS_Agreement__c();
        apg.Fusion_Project_Number__c = 'test';
        apg.Apttus__Contract_Start_Date__c = date.today();
        apg.Apttus__Contract_End_Date__c = date.today() + 5;
        apg.ProServ_Type__c = 'Fixed Fee';
        apg.Credit_Status__c = 'test';
        apg.Credit_Approved__c = 'test Credit_Approved__c';
        apg.CREDIT_LIMIT_AVAILABLE__C = 10;
        apg.CREDIT_EXISTING_EXPOSURE__C = 10;
        apg.CREDIT_CALCULATED_EXPOSURE__c = 10;
        apg.CREDIT_TOTAL_EXPOSURE__c = 10;
        apg.Fusion_Project_Number__c = 'test Fusion_Project_Number__c';
        apg.Apttus_QPComply__RelatedProposalId__c = proposal.Id;
        apg.Apttus__Related_Opportunity__c = GenerateTestData.opp.Id;
        apg.Apttus__Status_Category__c = 'In Effect';
        apg.Apttus__Status__c = 'Activated';
        apg.Apttus_CMConfig__PriceListId__c = pricelist.Id;
        insert apg;


    }

    public static void createCMConfigAgreementSummaryGroup() {
        acg = new Apttus_CMConfig__AgreementSummaryGroup__c();
        acg.Name = 'Test Aptus CMCongig';
        acg.Apttus_CMConfig__NetPrice__c = 100;
        acg.Apttus_CMConfig__ChargeType__c = 'Implementation Fee';
        acg.Apttus_CMConfig__AgreementId__c = apg.id;
        acg.Apttus_CMConfig__LineType__c = 'Category Total';
        acg.Apttus_CMConfig__ItemSequence__c = 109;
        acg.Apttus_CMConfig__LineNumber__c = 123;
        insert acg;
    }

    public static void createPriceBookEntry() {
        pbe = new PriceBookEntry();
        pbe.CurrencyISOCode = 'USD';
        pbe.PriceBook2ID = test.getStandardPricebookId();
        pbe.Product2Id = prd.Id;
        pbe.IsActive = true;
        pbe.UnitPrice = 1;
        pbe.UseStandardPrice = false;
        insert pbe;
    }

    public static void createPriceList() {
        pricelist = new Apttus_Config2__PriceList__c();
        List<Apttus_Config2__PriceList__c> pllst = new List<Apttus_Config2__PriceList__c> ();

        pricelist.Apttus_Config2__Active__c = true;
        pricelist.Name = 'TIBV DE Test';
        pricelist.Legal_Entity__c = 'TIBV SWISS BRANCH';
        pricelist.Business_Area__c = 'MANHATTAN SOFTWARE';
        pricelist.Division__c = 'GCCM';
        pllst.add(pricelist);


        pricelist1 = new Apttus_Config2__PriceList__c();
        pricelist1.Apttus_Config2__Active__c = true;
        pricelist1.Name = 'INT DATA-GBP';
        pricelist1.Legal_Entity__c = 'TIBV SWISS BRANCH';
        pricelist1.Business_Area__c = 'MANHATTAN SOFTWARE';
        pricelist1.Division__c = 'GCCM';
        pllst.add(pricelist1);
        insert pllst;
    }

    public static void createOtherPriceList() {
        pricelist = new Apttus_Config2__PriceList__c();
        pricelist.Apttus_Config2__Active__c = true;
        pricelist.Name = 'TIBV CH Test';
        pricelist.Legal_Entity__c = 'TIBV US BRANCH';
        insert pricelist;
    }

    public static void createProposal() {
        proposal = new Apttus_Proposal__Proposal__c();
        proposal.Apttus_Proposal__Proposal_Name__c = 'TestGenerateQuote'; //--added by Chandrakanth to overcome error of Null pointer exception related to Proposal Attachments
        proposal.Apttus_Proposal__Account__c = acct.Id;
        proposal.Apttus_QPConfig__BillToAccountId__c = acct.id;
        proposal.Apttus_Proposal__Opportunity__c = opp.Id;
        proposal.Apttus_QPConfig__PriceListId__c = pricelist.Id;
        proposal.Ship_To_Account__c = acct.Id;
        proposal.Bill_to_Address__c = adrs.Id;
        proposal.OwnerId = UserInfo.getUserId();
        proposal.Apttus_Proposal__Primary__c = true;
        proposal.Industry__c = 'Electrical';
        proposal.Freight_Method__c = 'N/A';
        proposal.Freight_Terms__c = 'N/A';
        proposal.Payment_Method__c = 'INVOICE';
        proposal.Clone_ID__c = 'Q-00012683';
        insert proposal;
    }

    public static void createProposalSummary() {
        proposalSum = new Apttus_QPConfig__ProposalSummary__c();
        proposalSum.Apttus_QPConfig__BaseExtendedCost__c = 100.12;
        proposalSum.Apttus_QPConfig__ItemSequence__c = 1;
        proposalSum.Apttus_QPConfig__LineNumber__c = 1;
        proposalSum.Apttus_QPConfig__ProposalId__c = proposal.Id;
        insert proposalSum;
    }

    public static void createProposalSummaryGroup() {
        proposalSumGrp = new Apttus_QPConfig__ProposalSummaryGroup__c();
        proposalSumGrp.Apttus_QPConfig__ProposalId__c = proposal.Id;
        proposalSumGrp.Apttus_QPConfig__NetPrice__c = 1.45;
        proposalSumGrp.Apttus_QPConfig__ItemSequence__c = 10;
        proposalSumGrp.Apttus_QPConfig__LineNumber__c = 23;
        insert proposalSumGrp;
    }

    public static void CreateProposalLineItem() {
        proposalLiTm = new Apttus_Proposal__Proposal_Line_Item__c();
        proposalLiTm.Apttus_QPConfig__BasePrice__c = 140.48;
        proposalLiTm.Apttus_Proposal__Proposal__c = proposal.Id;
        proposalLiTm.CurrencyISOCode = 'USD';
        proposalLiTm.Apttus_QPConfig__PriceListId__c = pricelist.Id;
        proposalLiTm.Apttus_QPConfig__OptionId__c = prd.Id;
        proposalLiTm.Apttus_Proposal__Product__c = prd.Id;
        proposalLiTm.Apttus_Proposal__Quantity__c = 92;
        proposalLiTm.Apttus_QPConfig__Quantity2__c = 95;
        proposalLiTm.Apttus_QPConfig__PriceUom__c = 'Each';
        proposalLiTm.Apttus_QPConfig__ListPrice__c = 45;
        proposalLiTm.Apttus_QPConfig__NetPrice__c = 65;
        proposalLiTm.Apttus_QPConfig__SellingTerm__c = 98;
        proposalLiTm.Apttus_QPConfig__SellingFrequency__c = 'Work Unit';
        proposalLiTm.Apttus_QPConfig__LineType__c = 'Product/Service';

        proposalLiTm.Apttus_QPConfig__OptionId__c = prd.Id;
        proposalLiTm.Apttus_QPConfig__ChargeType__c = 'Maintenance Fese';
        proposalLiTm.Apttus_QPConfig__LineNumber__c = 67;
        insert proposalLiTm;
    }
    public static void CreateProposalLineItem1() {
        proposalLiTm1 = new Apttus_Proposal__Proposal_Line_Item__c();
        proposalLiTm1.Apttus_QPConfig__BasePrice__c = 140.48;
        proposalLiTm1.Apttus_Proposal__Proposal__c = proposal.Id;
        proposalLiTm1.Apttus_QPConfig__PriceListId__c = pricelist.Id;
        proposalLiTm1.Apttus_QPConfig__OptionId__c = prd1.Id;
        proposalLiTm1.Apttus_Proposal__Product__c = prd1.Id;
        proposalLiTm1.Apttus_Proposal__Quantity__c = 92;
        proposalLiTm1.Apttus_QPConfig__Quantity2__c = - 2;
        proposalLiTm1.Apttus_QPConfig__PriceUom__c = 'Each';
        proposalLiTm1.Apttus_QPConfig__ListPrice__c = 45;
        proposalLiTm1.Apttus_QPConfig__NetPrice__c = 65;
        proposalLiTm1.Apttus_QPConfig__SellingTerm__c = 98;
        proposalLiTm1.Apttus_QPConfig__SellingFrequency__c = 'Work Unit';
        proposalLiTm1.Apttus_QPConfig__LineType__c = 'Product/Service';
        proposalLiTm1.Apttus_QPConfig__OptionId__c = prd1.Id;
        proposalLiTm1.Apttus_QPConfig__ChargeType__c = 'Maintenance Fese';
        proposalLiTm1.Apttus_QPConfig__LineNumber__c = 67;

        insert proposalLiTm1;
    }
    public static void CreateApttusConfig2ProductConfigurationMeth() {
        acpcfg = new Apttus_Config2__ProductConfiguration__c();
        acpcfg.Name = 'test acpcfg';
        acpcfg.Apttus_QPConfig__Proposald__c = proposal.Id;
        acpcfg.Apttus_Config2__PriceListId__c = pricelist.Id;
        insert acpcfg;
        CreateLineItem(acpcfg.Id);
    }

    //Standard ChargeType LintItem
    public static void CreateLineItem(Id configurationId) {
        List<Apttus_Config2__LineItem__c> liTmList = new List<Apttus_Config2__LineItem__c> ();
        standardliTm = new Apttus_Config2__LineItem__c();
        standardliTm.Apttus_Config2__ChargeType__c = 'Standard Price';
        standardliTm.Apttus_Config2__IsPrimaryLine__c = true;
        standardliTm.Apttus_Config2__ItemSequence__c = 1;
        standardliTm.Apttus_Config2__LineNumber__c = 1;
        standardliTm.Apttus_Config2__ConfigurationId__c = configurationId;
        standardliTm.Apttus_Config2__Quantity__c = 2;
        standardliTm.Apttus_Config2__ProductId__c = prd.Id;
        standardliTm.Asset_Oracle_ID__c = 'test';
        standardliTm.Apttus_Config2__PrimaryLineNumber__c = 2;
        standardliTm.Apttus_Config2__LineType__c = 'Product/Service';
        standardliTm.Service_Start_Date__c = system.today().addDays(20);
        standardliTm.Service_End_Date__c = system.today().addYears(1);
        liTmList.add(standardliTm);

        stdliTm = new Apttus_Config2__LineItem__c();
        stdliTm.Apttus_Config2__ChargeType__c = 'Standard Price';
        stdliTm.Apttus_Config2__IsPrimaryLine__c = true;
        stdliTm.Apttus_Config2__ItemSequence__c = 1;
        stdliTm.Apttus_Config2__LineNumber__c = 1;
        stdliTm.Apttus_Config2__IsOptionRollupLine__c = false;
        stdliTm.Apttus_Config2__ConfigurationId__c = configurationId;
        stdliTm.Apttus_Config2__Quantity__c = 1;
        stdliTm.Apttus_Config2__ProductId__c = prd.Id;
        stdliTm.Asset_Oracle_ID__c = 'test';
        stdliTm.Apttus_Config2__PrimaryLineNumber__c = 2;
        stdliTm.Apttus_Config2__PriceUom__c = 'Year';
        stdliTm.Apttus_Config2__LineType__c = 'Option';
        stdliTm.Service_Start_Date__c = system.today();
        stdliTm.Service_End_Date__c = system.today().addYears(1);
        liTmList.add(stdliTm);

        maintenceliTm = new Apttus_Config2__LineItem__c();
        maintenceliTm.Apttus_Config2__ChargeType__c = 'Maintenance Fee';
        maintenceliTm.Apttus_Config2__IsPrimaryLine__c = false;
        maintenceliTm.Apttus_Config2__ItemSequence__c = 1;
        maintenceliTm.Apttus_Config2__LineNumber__c = 1;
        maintenceliTm.Apttus_Config2__IsOptionRollupLine__c = false;
        maintenceliTm.Apttus_Config2__ConfigurationId__c = configurationId;
        maintenceliTm.Apttus_Config2__Quantity__c = 1;
        maintenceliTm.Apttus_Config2__ProductId__c = prd.Id;
        maintenceliTm.Asset_Oracle_ID__c = 'test';
        maintenceliTm.Apttus_Config2__PrimaryLineNumber__c = 2;
        maintenceliTm.Apttus_Config2__LineType__c = 'Option';
        liTmList.add(maintenceliTm);

        insert liTmList;
    }

    public static void createAssetLineItem() {
        assLiTm = new Apttus_Config2__AssetLineItem__c();
        assLiTm.Apttus_Config2__AccountId__c = acct.Id;
        assLiTm.Apttus_Config2__Quantity__c = 1;
        assLiTm.Selling_Price__c = 100;
        assLiTm.Apttus_Config2__NetPrice__c = 200;
        insert assLiTm;
    }

    public static void createTempObject(Id configurationId) {
        tempObj = new Apttus_Config2__TempObject__c();
        tempObj.Apttus_Config2__ConfigurationId__c = configurationId;
        insert tempObj;
    }

    public static void createVFPagePagginationConfig() {
        List<VF_Page_Paggination_Config__c> pageNos = new List<VF_Page_Paggination_Config__c> ();
        pageNo = new VF_Page_Paggination_Config__c();
        pageNo.Name = 'Search_Account';
        pageNo.Records_Per_Page__c = 5;
        pageNos.add(pageNo);
        pageNo = new VF_Page_Paggination_Config__c();
        pageNo.Name = 'Search_Defect';
        pageNo.Records_Per_Page__c = 5;
        pageNos.add(pageNo);
        insert pageNos;
    }

    public static void createAccountImportData() {
        idcAcc = new Import_Data__c();
        idcAcc.Operation__c = 'Create';
        idcAcc.Interval__c = 5;
        idcAcc.Batch_Size__c = 10;
        idcAcc.Object__c = 'Import_Data__c';
        idcAcc.Batch_Size_Callout__c = 1;
        idcAcc.Run_Integration__c = false;
        insert idcAcc;
    }

    public static void importDataAccAttachment() {
        //String testCsvData = 'Batch_Size__c,Interval__c,Operation__c,Run_Integration__c\r\n1,1,Insert,FALSE\r\n\r\n2,1,Insert,FALSE\r\n3,1,Insert,FALSE\r\n4,1,Insert,FALSE\r\n5,1,Insert,FALSE\r\n6,1,Insert,FALSE\r\n7,1,Insert,FALSE\r\n8,1,Insert,FALSE\r\n9,1,Insert,FALSE\r\n10,1,Insert,FALSE\r\n11,1,Insert,FALSE\r\n12,1,Insert,FALSE\r\n13,1,Insert,FALSE\r\n14,1,Insert,FALSE\r\n15,1,Insert,FALSE';
        String testCsvData = 'Batch_Size__c,Interval__c,Operation__c,Run_Integration__c\r\n1,1,Insert,FALSE\r\n\r\n2,1,Insert,FALSE\r\n3,1,Insert,FALSE\r\n4,1,Insert,FALSE\r\n5,1,Insert,FALSE\r\n6,1,Insert,FALSE\r\n7,1,Insert,FALSE';
        impDtAccAttach = new Attachment();
        impDtAccAttach.Body = Blob.valueOf(testCsvData);
        impDtAccAttach.Name = String.valueOf('test.csv');
        impDtAccAttach.ParentId = idcAcc.Id; //GenerateTestData.createImportData.
        insert impDtAccAttach;
        System.debug('==========impDtAccAttach===============' + impDtAccAttach);
    }

    public static void createAddressImportData() {
        idcAdrs = new Import_Data__c();
        idcAdrs.Operation__c = 'Create';
        idcAdrs.Interval__c = 5;
        idcAdrs.Batch_Size__c = 10;
        idcAdrs.Object__c = 'Address__c';
        idcAdrs.Batch_Size_Callout__c = 1;
        idcAdrs.Run_Integration__c = true;
        insert idcAdrs;
    }

    public static void importDataAdrsAttachment() {
        //system.debug('---importDataattachment2---'+GenerateTestData.acct.Id);
        //String testCsvData = 'NAME,ACCOUNT__C,ADDRESS_LINE1__C,ADDRESS_LINE2__C,ADDRESS_LINE3__C,ADDRESS_LINE4__C,ADDRESS_REGION__C,ADDRESS_VALIDATED_FLAG__C,BILL_TO__C,CITY__C,COUNTRY__C,COUNTY__C,STATE__C,VALIDATION_STATUS__C,ZIP__C\r\nAddress Doctor Test 1,'+acct.Id+',PO BOX 272318,,,,,TRUE,TRUE,Tampa,United States,Hillsborough,Florida,Corrected,33688\r\nAddress Doctor Test 2,'+acct.Id+',111015 N DALE MABRY HIGHWAY,,,,,TRUE,TRUE,TAMPA,United States,HILLSBOROUGH,Florida,Corrected,33614';
        String testCsvData = 'NAME,ACCOUNT__C,ADDRESS_LINE1__C,ADDRESS_LINE2__C,ADDRESS_LINE3__C,ADDRESS_LINE4__C,ADDRESS_REGION__C,ADDRESS_VALIDATED_FLAG__C,BILL_TO__C,CITY__C,COUNTRY__C,COUNTY__C,STATE__C,VALIDATION_STATUS__C,ZIP__C\r\nAddress Doctor Test 1,001f000000nhsm9,PO BOX 272318,,,,,TRUE,TRUE,Tampa,United States,Hillsborough,Florida,Corrected,33688\r\nAddress Doctor Test 2,001f000000nhsm9,111015 N DALE MABRY HIGHWAY,,,,,TRUE,TRUE,TAMPA,United States,HILLSBOROUGH,Florida,Corrected,33614';
        impDtAdrsAttach = new Attachment();
        impDtAdrsAttach.Body = Blob.valueOf(testCsvData);
        impDtAdrsAttach.Name = String.valueOf('test2.csv');
        impDtAdrsAttach.ParentId = idcAdrs.Id;
        insert impDtAdrsAttach;
        System.debug('==========impDtAdrsAttach===============' + impDtAdrsAttach);
    }

    public static void createContactImportData() {
        idcnt = new Import_Data__c();
        idcnt.Operation__c = 'Create';
        idcnt.Interval__c = 5;
        idcnt.Batch_Size__c = 10;
        idcnt.Object__c = 'Contact';
        idcnt.Batch_Size_Callout__c = 1;
        idcnt.Run_Integration__c = true;
        insert idcnt;
    }

    public static void createPriceListItemData() {
        priceListItem = new Apttus_Config2__PriceListItem__c();
        priceListItem.Apttus_Config2__Active__c = true;
        priceListItem.Apttus_Config2__ProductId__c = prd.Id;
        priceListItem.Apttus_Config2__PriceListId__c = pricelist1.Id;
        insert priceListItem;
    }

    public static void createPriceBookConfigData() {
        priceBookConfig = new Price_Book_Config__c();
        priceBookConfig.Name = 'INT DATA-GBP';
        priceBookConfig.Price_Books__c = 'GCCM Price Book';
        insert priceBookConfig;
    }

    public static void importDataCntAttachment() {
        String testCsvData = 'LastName,AccountId,Preferred_Language__c,Email,MailingCountry\r\nTestLastName1,' + acct.Id + ',American English,test1@gmail.com,United States\r\nTestLastName2,' + acct.Id + ',American English,test2@gmail.com,United States\r\nTestLastName3,' + acct.Id + ',American English,test3@gmail.com,United States\r\nTestLastName4,' + acct.Id + ',American English,test4@gmail.com,United States\r\nTestLastName5,' + acct.Id + ',American English,test5@gmail.com,United States\r\n';
        impDtCntAttach = new Attachment();
        impDtCntAttach.Body = Blob.valueOf(testCsvData);
        impDtCntAttach.Name = String.valueOf('test2.csv');
        impDtCntAttach.ParentId = idcnt.Id;
        insert impDtCntAttach;
        System.debug('==========impDtCntAttach===============' + impDtCntAttach);
    }
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx + 1);
        }
        return randStr;
    }
}