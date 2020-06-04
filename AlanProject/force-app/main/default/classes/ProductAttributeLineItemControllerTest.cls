@isTest
Private class ProductAttributeLineItemControllerTest{
    
    private static Country_Region_Mapping__c cust;
    private static Geospatial_Country_Region_Mapping__c custRegMap ;
    private static UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
    private static Profile profile = [Select Id from Profile where name = 'System Administrator'];
    private static User portalAccountOwner ;
    private static Account acct;
    private static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    private static Apttus_Proposal__Proposal__c appProp ;
    private static Apttus_Config2__ProductConfiguration__c prodConfig ;
    private static Apttus_Config2__LineItem__c appLineItem ;
    private static Asset assetLineItem ;
    private static Apttus_Config2__TempObject__c tmpObj;

    static void setUpData(){
        
        cust = new Country_Region_Mapping__c(name='India',Region__c='India');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='India',Region__c='India');
        insert custRegMap;
        Payment_Term_Order__c PaymentTerm = new Payment_Term_Order__c(name='Monthly',Number_of_Days__c = 20);
        insert PaymentTerm;
        User thisUser = [select Id from User where Id = :UserInfo.getUserId()];
        
        acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
            BillingCountry = 'India',BillingCity = 'Pune',BillingStreet = 'A-202');
        insert acct;
        
        appProp = new Apttus_Proposal__Proposal__c(Apttus_Proposal__Account__c=acct.id);
        insert appProp;
        
        prodConfig = new Apttus_Config2__ProductConfiguration__c(name='Test Product Config',Apttus_QPConfig__Proposald__c=appProp.id);
        insert prodConfig;

        appLineItem = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c=prodConfig.Id ,Apttus_Config2__Quantity__c=2, Apttus_Config2__ItemSequence__c=1, Apttus_Config2__LineNumber__c =2,Apttus_Config2__PrimaryLineNumber__c=2,
                        CurrencyIsoCode='USD', Asset_Oracle_ID__c = '1234G', Entitlement_Oracle_Id__c='5678G', Type__c = 'New Buy');
        insert appLineItem;
        
        tmpObj = new Apttus_Config2__TempObject__c(Apttus_Config2__ConfigurationId__c = prodConfig.Id);
        insert tmpObj;

        assetLineItem = new Asset(Accountid=acct.Id , name='Test Line Item');
        insert assetLineItem ;
        
        VF_Page_Paggination_Config__c pageConfig = new VF_Page_Paggination_Config__c();
        pageConfig.Name = 'ProductAttributeDetailCustom';
        pageConfig.Records_Per_Page__c = 1;
        insert pageConfig;
        
    }   
    
    private static testmethod void testQuoteDelete(){
        
        setUpData();
        Test.startTest();
        
            Pagereference pgRef = Page.ProductAttributeDetailCustom;
            pgRef.getParameters().put('id',appLineItem.id);
            pgRef.getParameters().put('configRequestId', tmpObj.Id);

            Test.setCurrentPage(pgRef);
            ProductAttributeLineItemController cont = new ProductAttributeLineItemController(new Apexpages.StandardController(appLineItem));
            cont.selectedAsset = assetLineItem.Id ;
            cont.loadAssetData();
            cont.saveLineItem();

            cont.selectedAsset = '';
            cont.saveLineItem();

            cont.AddProd();
        Test.stopTest();
        
    }     
    
}