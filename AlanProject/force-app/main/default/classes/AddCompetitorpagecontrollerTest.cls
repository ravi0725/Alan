//Divya-23/3/2015: Changed the custom field Forecast_Category_MEP__c to standard field ForecastCategoryName at line 36

@isTest
Private class AddCompetitorpagecontrollerTest{
    
    public static Opportunity oppty;
    public static Product_competitor__c   prod;
    //public static Id opptyRecTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Opportunity (Plancal Customer) Record Type').getRecordTypeId();
    public static Apttus_Config2__PriceList__c appConf;
    public static UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
    public static Profile profile = [Select Id from Profile where name = 'System Administrator'];
    public static User portalAccountOwner ;
    public static Account acct;
    public static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    public static Country_Region_Mapping__c cust;
    public static Geospatial_Country_Region_Mapping__c custRegMap ;
    public static Competitor_Owned_Assets__c  compAsset;
    static void setUpData(){
    
        cust = new Country_Region_Mapping__c(name='Switzerland',Region__c='Switzerland');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='Switzerland',Region__c='Switzerland');
        insert custRegMap;
        
        //User thisUser = [ select Id from User where Id = :UserInfo.getUserId()];
        
        acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
            BillingCountry = 'Switzerland',BillingCity = 'Pune',BillingStreet = 'A-202');
        insert acct;
        
        appConf = new Apttus_Config2__PriceList__c(name='TIBV CH Price List' ,Apttus_Config2__Active__c=true);
        insert appConf;
        Payment_Term_Order__c PaymentTerm = new Payment_Term_Order__c(name='CASH IN ADVANCE',Number_of_Days__c = 20);
        insert PaymentTerm;
        oppty= new Opportunity (name='Test Oppty' , StageName='1 - Qualification' , ForecastCategoryName='Pipeline' , 
                AccountId=acct.Id, Type='New Business', Price_List__c=appConf.Id , Amount=100, CurrencyIsoCode='USD',Payment_Term__c ='CASH IN ADVANCE',
                CloseDate=System.today(),Ship_To_Account__c=acct.Id);
        insert oppty;
        
        prod = new Product_competitor__c (name='Test Product Competitor');
        insert prod;
        
        compAsset = new Competitor_Owned_Assets__c(name='Test Competitor',Account__c=acct.Id , CurrencyIsoCode='USD',Expiration_Date__c=System.today()+1 , Product__c=prod.Id);
        insert compAsset;
        
    }
    
    private static testmethod  void testUpdatecompetitor(){
        
        setUpData();           
        Test.startTest();                
            PageReference pgRef = Page.CompAssetfromAccount;
            pgRef.getParameters().put('id',oppty.id);
            Test.setCurrentPage(pgRef); 
            
            AddCompetitorpagecontroller cont = new AddCompetitorpagecontroller();
            cont.updatecompetitor();
            System.assertEquals(cont.statusFlag,false);
            
        Test.stopTest();    
                
    }
    
    private static testmethod  void testpageredirectNCancel(){
        
        setUpData();           
        Test.startTest();                
            PageReference pgRef = Page.CompAssetfromAccount;
            pgRef.getParameters().put('id',oppty.id);
            Test.setCurrentPage(pgRef); 
            
            AddCompetitorpagecontroller cont = new AddCompetitorpagecontroller();
            cont.pageredirect();
            //System.assertEquals(pgRef.getUrl(),'/apex/CompAssetsOptyPage?id='+oppty.id+'&ret=1');
            cont.Cancel();
            
        Test.stopTest();    
                
    }



}