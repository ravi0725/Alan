//Divya-24/3/2015: Changed the custom field Forecast_Category_MEP__c to ForecastCategoryName line 36

@isTest
Private class EditCompetitorClassTest{
    
    public static Country_Region_Mapping__c cust;
    public static Geospatial_Country_Region_Mapping__c custRegMap ;
    public static User thisUser ;
    public static Account acct;
    public static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    public static Product_competitor__c  prodComp;
   // public static Id opptyRecTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Opportunity (Plancal Customer) Record Type').getRecordTypeId();
    public static Apttus_Config2__PriceList__c appConf;
    public static Opportunity oppty;
    
    static void setUpData(){
    
        cust = new Country_Region_Mapping__c(name='Switzerland',Region__c='Switzerland');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='Switzerland',Region__c='Switzerland');
        insert custRegMap;
        Payment_Term_Order__c PaymentTerm = new Payment_Term_Order__c(name='CASH IN ADVANCE',Number_of_Days__c = 20);
        insert PaymentTerm;
        appConf = new Apttus_Config2__PriceList__c(name='TIBV CH Price List' ,Apttus_Config2__Active__c=true);
        insert appConf;
        
        thisUser = [ select Id from User where Id = :UserInfo.getUserId()];
  
        acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
            BillingCountry = 'Switzerland',BillingCity = 'Pune',BillingStreet = 'A-202');
        insert acct;
        
        oppty= new Opportunity (name='Test Oppty' , StageName='1 - Qualification' , ForecastCategoryName='Pipeline' , 
                AccountId=acct.Id, Type='New Business', Price_List__c=appConf.Id , Amount=100, CurrencyIsoCode='USD',Payment_Term__c ='CASH IN ADVANCE',
                CloseDate=System.today(),Ship_To_Account__c=acct.Id);
        insert oppty; 
        
        prodComp = new Product_competitor__c (name='Test Prod Comp',Competitor_Account__c=acct.Id);
        insert prodComp;
    }   
    
    
    private static testmethod void testNewAssets(){
        
        setUpData();
        Test.startTest();  
            EditCompetitorClass cont = new EditCompetitorClass(new ApexPages.StandardSetController([Select id from Product_competitor__c where id =:prodComp.id]));
            cont.productIds  = 'Test';
            //cont.optyId = oppty.id;
            System.AssertNotEquals(cont.newCompetitor(),null);
            System.AssertNotEquals(cont.cancel(),null);     
        Test.stopTest();
    }
    
    private static testmethod void testPopulateproduct(){
        
        setUpData();
        Test.startTest();  
            EditCompetitorClass cont = new EditCompetitorClass(new ApexPages.StandardSetController([Select id from Product_competitor__c where id =:prodComp.id]));
            cont.companyid = acct.Id;
            cont.Populateproduct();
        Test.stopTest();    
    
    }
    
    private static testmethod void testPopulateProductFamily(){
        
        setUpData();
        Test.startTest();  
            EditCompetitorClass cont = new EditCompetitorClass(new ApexPages.StandardSetController([Select id from Product_competitor__c where id =:prodComp.id]));
            cont.productId = prodComp.Id;
            cont.PopulateProductFamily();
        Test.stopTest();
    }
    
    private static testmethod void testupdateCompetitor(){
        
        setUpData();
        Test.startTest();  

            EditCompetitorClass cont = new EditCompetitorClass(new ApexPages.StandardSetController([Select id from Product_competitor__c where id =:prodComp.id]));
            cont.productId = prodComp.Id;           
            System.AssertEquals(cont.updateCompetitor(),null);
        Test.stopTest();
    }
}