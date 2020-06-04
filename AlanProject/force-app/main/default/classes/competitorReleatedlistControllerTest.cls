//Divya:24/3/2015: Changed custom field Forecast_Category_MEP__c to ForecastCategoryName at line 36


@isTest(seealldata=true)
Private class competitorReleatedlistControllerTest{
    /*
    public static Country_Region_Mapping__c cust;
    public static Geospatial_Country_Region_Mapping__c custRegMap ;
    //public static Id opptyRecTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Opportunity (Plancal Customer) Record Type').getRecordTypeId();
    public static Apttus_Config2__PriceList__c appConf;
    public static UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
    public static Profile profile = [Select Id from Profile where name = 'System Administrator'];
    public static User portalAccountOwner ;
    public static Account acct;
    public static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Competitor) Record Type').getRecordTypeId();
    public static Opportunity oppty;
    public static Competitor__c comp;
    
    static void setUpData(){
    	GenerateTestData.PaymentTerm = new Payment_Term_Order__c(Name='CASH IN ADVANCE',Number_of_Days__c = 20);
        insert GenerateTestData.PaymentTerm;
        
        cust = new Country_Region_Mapping__c(name='Switzerland',Region__c='Switzerland');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='Switzerland',Region__c='Switzerland');
        insert custRegMap;
        
        appConf = new Apttus_Config2__PriceList__c(name='TIBV CH Price List' ,Apttus_Config2__Active__c=true);
        insert appConf;
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId()];
  
        acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
            BillingCountry = 'Switzerland',BillingCity = 'Pune',BillingStreet = 'A-202');
        insert acct;
        
        oppty= new Opportunity (name='Test Oppty' , StageName='1 - Qualification' , ForecastCategoryName='Pipeline' , 
                AccountId=acct.Id, Type='New Business', Price_List__c=appConf.Id , Amount=100, CurrencyIsoCode='USD',Payment_Term__c ='CASH IN ADVANCE',
                CloseDate=System.today(),Ship_To_Account__c=acct.Id);
        insert oppty;    

        comp = new Competitor__c(CompetitorName__c=oppty.accountId,Opportunity__c=oppty.id);
        insert comp;    
    }

    private static testmethod void testRelatedCompetitor(){
        
        setUpData();
        Test.startTest();  
            competitorReleatedlistController cont = new competitorReleatedlistController(new ApexPages.StandardController(oppty));
            cont.oppId = oppty.Id; 
            System.AssertEquals(cont.getRelatedCompetitor().size(),1);  
        Test.stopTest();
    }   
    
    private static testmethod void testCompetitorList(){
        
        setUpData();
        Test.startTest();  
            competitorReleatedlistController cont = new competitorReleatedlistController(new ApexPages.StandardController(oppty));
            cont.oppId = oppty.Id; 
            cont.getCompetitorList();   
        Test.stopTest();
    }
    
    private static testmethod void testPageREF(){
        
        setUpData();
        Test.startTest();  
            competitorReleatedlistController cont = new competitorReleatedlistController(new ApexPages.StandardController(oppty));
            System.AssertNotEquals(cont.EditCompetitorAsset(),null);    
        Test.stopTest();
    }
    */
    static testmethod void meth1(){
        GenerateTestData.CreateParentAccount();
        GenerateTestData.createAccount();
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();
        Competitor__c c = new Competitor__c();
        c.Opportunity__c = GenerateTestData.opp.Id;
        insert c;
        System.currentPageReference().getParameters().put('id', GenerateTestData.opp.Id);
        competitorReleatedlistController crc = new competitorReleatedlistController(new ApexPages.StandardController(GenerateTestData.opp));
        crc.getRelatedCompetitor();
        crc.getCompetitorList();
        crc.EditCompetitorAsset();
        
    }
    
    static testmethod void meth2(){
        GenerateTestData.CreateParentAccount();
        GenerateTestData.createAccount();
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();
        Competitor__c c = new Competitor__c();
        c.Opportunity__c = GenerateTestData.opp.Id;
        insert c;
        //System.currentPageReference().getParameters().put('id', GenerateTestData.opp.Id);
        competitorReleatedlistController crc = new competitorReleatedlistController(new ApexPages.StandardController(GenerateTestData.opp));
        crc.getRelatedCompetitor();
        crc.getCompetitorList();
        crc.EditCompetitorAsset();
        crc.totalSize = 1;
        crc.compassetdelid = 'test';
    }
}