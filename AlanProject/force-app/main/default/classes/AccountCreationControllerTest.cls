@isTest
Private class AccountCreationControllerTest{
    
    public static Country_Region_Mapping__c cust;
    public static Geospatial_Country_Region_Mapping__c custRegMap ;
    public static User thisUser ;
    public static Account acct, acct1;
    public static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    /**
    * Dummy Metadata API web service mock class (see MetadataCreateJobTest.cls for a better example)
    **/
    private class WebServiceMockImpl implements WebServiceMock {
        public void doInvoke(Object stub, Object request, Map<String, Object> response,
                                String endpoint, String soapAction, String requestName,
                                String responseNS, String responseName, String responseType){
                                    
                                    trimblecorpComCmdm_v4.PartySite_element[] partySite = new List<trimblecorpComCmdm_v4.PartySite_element>();
                                    trimblecorpComCmdm_v4.LocationType dLocation = new trimblecorpComCmdm_v4.LocationType();
                                    dLocation.Address1 = 'A-202';
                                    dLocation.Address2 = null;
                                    dLocation.Address3 = null;
                                    dLocation.Address4 = null;
                                    dLocation.City = 'Pune';
                                    dLocation.State = 'Goa';
                                    dLocation.Province = null;
                                    dLocation.County = null;
                                    dLocation.Country = 'India';
                                    dLocation.PostalCode = '343220';
                                    trimblecorpComCmdm_v4.PartySite_element dPartySite = new trimblecorpComCmdm_v4.PartySite_element();
                                    dPartySite.Location = dLocation;
                                    dPartySite.PartySiteName = null;
                                    dPartySite.EnterprisePartySiteNumber = '98765409';
                                    dPartySite.PartySiteId = '3456789012';
                                    dPartySite.DoNotMerge = 'No';
                                    dPartySite.TaxID = null;
                                    dPartySite.AddressCheckResults = null;
                                    dPartySite.PrimaryContact = null;
                                    partySite.add(dPartySite);
                                    trimblecorpComCmdm_v4.OriginalSystemReferenceType[] originalSystemReference = new List<trimblecorpComCmdm_v4.OriginalSystemReferenceType>();
                                    
                                    trimblecorpComCmdm_v4.OrganizationPartyResultType finalResponse = new trimblecorpComCmdm_v4.OrganizationPartyResultType();
                                    trimblecorpComCmdm_v4.OrganizationPartyType[] dummyResp = new trimblecorpComCmdm_v4.OrganizationPartyType[]{};
                                    trimblecorpComCmdm_v4.OrganizationPartyType sResp = new trimblecorpComCmdm_v4.OrganizationPartyType();
                                    sResp.PartyId = '3456789012';
                                    sResp.Parent_PartyId = '2454466';
                                    sResp.EnterprisePartyNumber = '56786436';
                                    sResp.AccountName = 'Test Assign Case Account1';
                                    sResp.OrganizationName = '';
                                    sResp.LifecycleStage_c = null;
                                    sResp.CustomerLevel_c = null;
                                    sResp.Channel_c = null;
                                    sResp.PrimaryRegion_c = null;
                                    sResp.GlobalOptOut_c = 'No';
                                    sResp.RestrictedPartyIndicator_c = null;
                                    sResp.DUNSNumberC = null;
                                    sResp.Language = null;
                                    sResp.VerticalClassification_c = null;
                                    sResp.CreditStatus_c = null;
                                    sResp.BilltoUsage_c = 'No';
                                    sResp.ShiptoUsage_c = 'No';
                                    sResp.EndUser_c = 'No';
                                    sResp.Installedat_c = 'No';
                                    sResp.SelltoFlag = 'No';
                                    sResp.PrimaryPhoneNumber = null;
                                    sResp.PrimaryEMail_c = null;
                                    sResp.AccountOwnerEmail_c = 'genericuser@TESTTRMB.com';
                                    sResp.ValidatedFlag = 'No';
                                    sResp.PartySite = partySite;
                                    sResp.OriginalSystemReference = originalSystemReference;
                                    dummyResp.add(sResp);
                                    finalResponse.OrganizationParty = dummyResp;
                                    response.put('response_x', finalResponse);
                                    return;
                                }
    }
    
    static void setUpData(){
        
        cust = new Country_Region_Mapping__c(name='India',Region__c='India');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='India',Region__c='India');
        insert custRegMap;
        
        thisUser = [ select Id from User where Id = :UserInfo.getUserId()];
        
        acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
                           BillingCountry = 'India',BillingCity = 'Pune',BillingStreet = 'A-202', Phone='+91 (970) 845-0466',BillingState='Goa',
                           BillingPostalCode ='343220', FCH_Party_ID__c = '2454467', Enterprise_Party_Number__c = '56786433');
        List<Account> lstAccs = new List<Account>();
        lstAccs.add(acct);
        acct1 = new Account(Name = 'Test Assign Case Account1',RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
                            BillingCountry = 'India',BillingCity = 'Pune',BillingStreet = 'A-202', Phone='+91 (970) 845-0466',BillingState='Goa',
                            BillingPostalCode ='343220', FCH_Party_ID__c = '2454466', Enterprise_Party_Number__c = '56786436');
        lstAccs.add(acct1);
        insert lstAccs;
    }
    
    private static testmethod void testAccountCreationController(){
        
        setUpData();
        GenerateTestData.createVFPagePagginationConfig();
        GenerateTestData.createSystemIntegrationURL();
        Test.startTest();  
        ApexPages.CurrentPage().getParameters().put('AccName', 'Test Assign Case Account');
        ApexPages.CurrentPage().getParameters().put('Country','India');
        ApexPages.CurrentPage().getParameters().put('Phone', '+91 (970) 845-0466');
        ApexPages.CurrentPage().getParameters().put('Address', '');
        ApexPages.CurrentPage().getParameters().put('City', '');
        ApexPages.CurrentPage().getParameters().put('State', '');
        ApexPages.CurrentPage().getParameters().put('County', '');
        ApexPages.CurrentPage().getParameters().put('PostalCode', '');
        ApexPages.CurrentPage().getParameters().put('CurrentAccountId', acct.Id);
        AccountCreationController cont = new AccountCreationController(new ApexPages.StandardController(acct));
        
        Address__c cAddr = [SELECT Name, Account__c, Address_Line1__c, Address_Line2__c, Address_Line3__c, Address_Line4__c, Address_Region__c, Address_Validated_Flag__c, Anniversary_Date__c, Bill_To__c, City__c, Country__c, County__c, End_User__c, Enterprise_Address_Number__c, FCH_Party_Site_ID__c, Installed_at__c, Location_ID__c, Party_Site_ID__c, Party_Site_Number__c, Preferred_Language__c, Restricted_Entity__c, Restricted_Party_Indicator__c, Sell_To__c, Ship_To__c, Site_Name__c, State__c, Tax_Reg_Number__c, Validation_Status__c, Zip__c, Primary__c, Job_Token__c, Validation_Status_Code__c, Brazilian_Neighborhood__c, Brazilian_City__c, Brazilian_State__c, Legacy_CMS_Number__c, Legacy_Quisp_Number__c FROM Address__c WHERE Account__c =: acct1.Id LIMIT 1];
        cAddr.Enterprise_Address_Number__c = '98765409';
        cAddr.FCH_Party_Site_ID__c = '3456789012';
        
        cont.SelAccFCHId = '2454466';
        cont.SelAccEnterPriseMasterId = '56786436';
        cont.SelAddFCHId = '3456789012';
        cont.SelAddEnterPriseMasterId = '98765409';
        cont.AccName = acct.name;
        cont.straddress = 'A-202';
        cont.city = acct.BillingCity;
        cont.State =acct.BillingState;
        cont.postalcode = acct.BillingPostalCode;
        cont.Country = acct.BillingCountry;
        cont.AccPhone = acct.Phone;
        //cont.SelAccId = '300000000000000';
        
        cont.SearchSFDCData();
        system.debug('wrapperlist =>'+cont.wrapperlist);
        cont.GoToRecord();
        
        system.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());       
        
        cont.SearchMDMData();
        cont.createAccountWithUserSelected();     	
        cont.createNewaccount();
        cont.County = 'test1';
        cont.createNewaccount();
        cont.searchinMDMdata();
        cont.cancel();
        
        Test.stopTest();
    }
    
    private static testmethod void testAccountCreationController1(){
        
        setUpData();
        GenerateTestData.createVFPagePagginationConfig();
        GenerateTestData.createSystemIntegrationURL();
        Test.startTest();  
        AccountCreationController cont = new AccountCreationController(new ApexPages.StandardController(acct));
        
        cont.AccName = acct.name;
        cont.straddress = 'stradd1[\n\r]stradd2[\n\r]stradd3[\n\r]stradd4';
        cont.city = acct.BillingCity;
        cont.State =acct.BillingState;
        cont.postalcode = acct.BillingPostalCode;
        cont.Country = acct.BillingCountry;
        cont.AccPhone = acct.Phone;
        //cont.SelAccId = '300000000000000';
        
        cont.SearchSFDCData();
        cont.GoToRecord();
        cont.SearchMDMData();
        cont.AccName = 'test';
        cont.AccPhone = '3456';
        cont.country = 'test country';
        cont.straddress = 'test straddress';
        cont.city = 'city';
        cont.Postalcode = '567';
        cont.State = 'test state';
        cont.County = 'test county';
        cont.createNewaccount();
        cont.County = 'test1';
        
        cont.createNewaccount();
        cont.createAccountWithUserSelected();
        cont.searchinMDMdata();
        cont.cancel();
        
        Test.stopTest();
    }
    
    private static testmethod void testAccountCreationController2(){
        
        setUpData();
        GenerateTestData.createVFPagePagginationConfig();
        GenerateTestData.createSystemIntegrationURL();
        Test.startTest();  
        ApexPages.CurrentPage().getParameters().put('AccName', 'Test Assign\'s Case Account');
        ApexPages.CurrentPage().getParameters().put('Country','India');
        ApexPages.CurrentPage().getParameters().put('Phone', '+91 (970) 845-0466');
        ApexPages.CurrentPage().getParameters().put('Address', 'TestAddress1');
        ApexPages.CurrentPage().getParameters().put('City', 'Bangalore');
        ApexPages.CurrentPage().getParameters().put('State', 'Karnataka');
        ApexPages.CurrentPage().getParameters().put('County', '');
        ApexPages.CurrentPage().getParameters().put('PostalCode', '560076');
        ApexPages.CurrentPage().getParameters().put('CurrentAccountId', acct.Id);
        
        List<Address__c> addrsList = new List<Address__c>();
        
        Address__c adrs = new Address__c(Name = 'Test Address',validation_Status__c='Corrected',FCH_Party_Site_Id__c = '222222',Account__c = acct.Id, Country__c = 'United States',Bill_To__c = true,Ship_To__c=true,Address_Line1__c = 'addrs4',Address_Line2__c = 'addrs4',Address_Line3__c = 'addrs4',Address_Line4__c = 'addrs4',City__c = 'city',State__c = 'state',Zip__c = 'zip');
        addrsList.add(adrs);
        
        Address__c adrs2 = new Address__c(Name = 'Test Address2',validation_Status__c='Corrected',FCH_Party_Site_Id__c = '2222222',Account__c = acct.Id, Country__c = 'United States',Bill_To__c = true,Ship_To__c=true,Address_Line1__c = 'addrs4',Address_Line2__c = 'addrs4',Address_Line3__c = 'addrs4',Address_Line4__c = 'addrs4',City__c = 'city2',State__c = 'state',Zip__c = 'zip');
        addrsList.add(adrs2);
        
        insert addrsList;
        
        Address__c cAddr = new Address__c();
        cAddr = [SELECT Name, Account__c, Address_Line1__c, Address_Line2__c, Address_Line3__c, Address_Line4__c, Address_Region__c, Address_Validated_Flag__c, Anniversary_Date__c, Bill_To__c, City__c, Country__c, County__c, End_User__c, Enterprise_Address_Number__c, FCH_Party_Site_ID__c, Installed_at__c, Location_ID__c, Party_Site_ID__c, Party_Site_Number__c, Preferred_Language__c, Restricted_Entity__c, Restricted_Party_Indicator__c, Sell_To__c, Ship_To__c, Site_Name__c, State__c, Tax_Reg_Number__c, Validation_Status__c, Zip__c, Primary__c, Job_Token__c, Validation_Status_Code__c, Brazilian_Neighborhood__c, Brazilian_City__c, Brazilian_State__c, Legacy_CMS_Number__c, Legacy_Quisp_Number__c FROM Address__c WHERE Account__c =: acct.Id LIMIT 1];
        
        AccountCreationController cont = new AccountCreationController(new ApexPages.StandardController(acct));
        cont.Street = 'Bangalore';
        cont.SearchSFDCData();
        cont.SearchMDMData();
        cont.createNewaccount();
        cont.County = 'test1';
        cont.createNewaccount();
        cont.SelAccFCHId = '2454466';
        cont.createAccountWithUserSelected();
        cont.searchinMDMdata();
        cont.cancel();
        cont.previous();
        cont.first();
        cont.next();
        cont.last();  
        cont.selSFDCAccId = acct.Id;
        cont.selSFDCAddId = cAddr.Id;
        cont.createSellToAccount();
        //cont.callLinkAccWebService();
        Test.stopTest();
    }
    
    private static testmethod void testAccountCreationController3(){
        
        setUpData();
        GenerateTestData.createVFPagePagginationConfig();
        GenerateTestData.createSystemIntegrationURL();
        Test.startTest();  
        ApexPages.CurrentPage().getParameters().put('AccName', '');
        ApexPages.CurrentPage().getParameters().put('Country','India');
        ApexPages.CurrentPage().getParameters().put('Phone', '+91 (970) 845-0466');
        ApexPages.CurrentPage().getParameters().put('Address', 'TestAddress1');
        ApexPages.CurrentPage().getParameters().put('City', 'Bangalore');
        ApexPages.CurrentPage().getParameters().put('State', 'Karnataka');
        ApexPages.CurrentPage().getParameters().put('County', '');
        ApexPages.CurrentPage().getParameters().put('PostalCode', '560076');
        ApexPages.CurrentPage().getParameters().put('CurrentAccountId', acct.Id);
        
        List<Address__c> addrsList = new List<Address__c>();
        
        Address__c adrs = new Address__c(Name = 'Test Address',validation_Status__c='Corrected',FCH_Party_Site_Id__c = '222222',Account__c = acct.Id, Country__c = 'United States',Bill_To__c = true,Ship_To__c=true,Address_Line1__c = 'addrs4',Address_Line2__c = 'addrs4',Address_Line3__c = 'addrs4',Address_Line4__c = 'addrs4',City__c = 'city',State__c = 'state',Zip__c = 'zip');
        addrsList.add(adrs);
        
        Address__c adrs2 = new Address__c(Name = 'Test Address2',validation_Status__c='Corrected',FCH_Party_Site_Id__c = '2222222',Account__c = acct.Id, Country__c = 'United States',Bill_To__c = true,Ship_To__c=true,Address_Line1__c = 'addrs4',Address_Line2__c = 'addrs4',Address_Line3__c = 'addrs4',Address_Line4__c = 'addrs4',City__c = 'city2',State__c = 'state',Zip__c = 'zip');
        addrsList.add(adrs2);
        
        insert addrsList;
        
        Address__c cAddr = new Address__c();
        cAddr = [SELECT Name, Account__c, Address_Line1__c, Address_Line2__c, Address_Line3__c, Address_Line4__c, Address_Region__c, Address_Validated_Flag__c, Anniversary_Date__c, Bill_To__c, City__c, Country__c, County__c, End_User__c, Enterprise_Address_Number__c, FCH_Party_Site_ID__c, Installed_at__c, Location_ID__c, Party_Site_ID__c, Party_Site_Number__c, Preferred_Language__c, Restricted_Entity__c, Restricted_Party_Indicator__c, Sell_To__c, Ship_To__c, Site_Name__c, State__c, Tax_Reg_Number__c, Validation_Status__c, Zip__c, Primary__c, Job_Token__c, Validation_Status_Code__c, Brazilian_Neighborhood__c, Brazilian_City__c, Brazilian_State__c, Legacy_CMS_Number__c, Legacy_Quisp_Number__c FROM Address__c WHERE Account__c =: acct.Id LIMIT 1];
        
        AccountCreationController cont = new AccountCreationController(new ApexPages.StandardController(acct));
        cont.Street = 'Bangalore';
        cont.SearchSFDCData();
        cont.SearchMDMData();
        cont.createNewaccount();
        cont.County = 'test1';
        cont.createNewaccount();
        cont.SelAccFCHId = '2454466';
        cont.createAccountWithUserSelected();
        cont.searchinMDMdata();
        cont.cancel();
        cont.previous();
        cont.first();
        cont.next();
        cont.last();  
        cont.selSFDCAccId = acct.Id;
        cont.selSFDCAddId = cAddr.Id;
        cont.createSellToAccount();
        //cont.callLinkAccWebService();
        Test.stopTest();
    }
    /*static testmethod void meth1(){
GenerateTestData.createAccount();
AccountCreationController acc = new AccountCreationController(new ApexPages.StandardController(GenerateTestData.acct));
acc.SearchSFDCData();
//acc.GoToRecord();
acc.SearchMDMData();
acc.createNewaccount();
acc.createSellToAccount();
acc.createAccountWithUserSelected();
//acc.searchinMDMdata();
acc.currentPage = 2;
acc.previous();
acc.first();
acc.next();
acc.last();

acc.cancel();

acc.GoToRecord();
}*/
    
}