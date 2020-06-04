//Divya-24/3/2015: Changed custom field Forecast_Category_MEP__c to standard field  ForecastCategoryName at line 34

@isTest
Private class OpptyProposalCopyControllerTest{
    
    public static Country_Region_Mapping__c cust;
    public static Geospatial_Country_Region_Mapping__c custRegMap ;
   // public static Id opptyRecTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Opportunity (Plancal Customer) Record Type').getRecordTypeId();
    public static Apttus_Config2__PriceList__c appConf;
    public static User portalAccountOwner ;
    public static Account acct;
    public static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    public static Competitor_Owned_Assets__c compAsset ;
    public static Opportunity oppty;
    public static Product_competitor__c  prodComp;
    
    static void setUpData(){
    
        cust = new Country_Region_Mapping__c(name='Switzerland',Region__c='Switzerland');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='Switzerland',Region__c='Switzerland');
        insert custRegMap;
        
        appConf = new Apttus_Config2__PriceList__c(name='TIBV CH Price List' ,Apttus_Config2__Active__c=true);
        insert appConf;
        
        Payment_Term_Order__c PaymentTerm = new Payment_Term_Order__c(name='CASH IN ADVANCE',Number_of_Days__c = 20);
        insert PaymentTerm;
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId()];
           
        acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
            BillingCountry = 'Switzerland',BillingCity = 'Pune',BillingStreet = 'A-202');
        insert acct;
        
        oppty= new Opportunity (name='Test Oppty' , StageName='1 - Qualification' , ForecastCategoryName='Pipeline' , 
                AccountId=acct.Id, Type='New Business', Price_List__c=appConf.Id , Amount=100, CurrencyIsoCode='USD',Payment_Term__c ='CASH IN ADVANCE',
                CloseDate=System.today(),Ship_To_Account__c=acct.Id );
        insert oppty;       

    }
    
     private static testmethod void testoLoad(){
        
        setUpData();
        Test.startTest();               
            OpptyProposalCopyController cont = new OpptyProposalCopyController(new ApexPages.StandardController(oppty));
            cont.getHasErrors();
        Test.stopTest();
    }   
    
}