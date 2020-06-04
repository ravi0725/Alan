@isTest
Private class SelectInstalledProductsControllerTest{
    
    private static Country_Region_Mapping__c cust;
    private static Geospatial_Country_Region_Mapping__c custRegMap ;
    private static Apttus_Proposal__Proposal__c appProp ;
    private static Account acct;
    private static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    private static Apttus_Config2__ProductConfiguration__c prodConfig ;
    private static Apttus_Config2__AssetLineItem__c assetLineItem ; 
    static void setUpData(){
        
        cust = new Country_Region_Mapping__c(name='India',Region__c='India');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='India',Region__c='India');
        insert custRegMap;
        
        acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
            BillingCountry = 'India',BillingCity = 'Pune',BillingStreet = 'A-202');
        insert acct;
        
        appProp = new Apttus_Proposal__Proposal__c(Apttus_Proposal__Account__c=acct.id);
        insert appProp;
        
        prodConfig = new Apttus_Config2__ProductConfiguration__c(name='Test Product Config',Apttus_QPConfig__Proposald__c=appProp.id);
        insert prodConfig;
        
        assetLineItem = new Apttus_Config2__AssetLineItem__c(Apttus_Config2__AccountId__c=acct.Id , name='Test Line Item');
        insert assetLineItem ;
        
    }
    
    private static testmethod void testAssetOption(){
        setUpData();
        Test.startTest(); 
            PageReference pgRef = Page.SelectInstalledProducts ;
            pgRef.getParameters().put('id' , prodConfig.Id);
            Test.setCurrentPage(pgRef);
            
            SelectInstalledProductsController cont = new SelectInstalledProductsController();
            List<SelectOption> selOptions = cont.getAssetOption() ;
            System.assertEquals(selOptions.size()>0 , true);
        Test.stopTest();
    }

}