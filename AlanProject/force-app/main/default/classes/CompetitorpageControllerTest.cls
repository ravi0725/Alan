@isTest
Private class CompetitorpageControllerTest{

    public static Country_Region_Mapping__c cust;
    public static Geospatial_Country_Region_Mapping__c custRegMap ;
    public static UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
    public static Profile profile = [Select Id from Profile where name = 'System Administrator'];
    public static User portalAccountOwner ;
    public static Account acct;
    public static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    public static Product_competitor__c  prodComp;
    
    static void setUpData(){
    
        cust = new Country_Region_Mapping__c(name='India',Region__c='India');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='India',Region__c='India');
        insert custRegMap;
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            portalAccountOwner = new User(UserRoleId = portalRole.Id,ProfileId = profile.Id,Username = System.now().millisecond() + 'test2@test.com',
                Alias = 'Test', Email='test@test.com',EmailEncodingKey='UTF-8', Firstname='Test',Lastname='Suite',LanguageLocaleKey='en_US',
                LocaleSidKey='en_US',TimeZoneSidKey='America/Chicago',Country='India');
            //insert portalAccountOwner;
        }   
        
        acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
            BillingCountry = 'India',BillingCity = 'Pune',BillingStreet = 'A-202');
        insert acct;
        
        prodComp = new Product_competitor__c (name='Test Prod Comp',Competitor_Account__c=acct.Id);
        insert prodComp;
    }   
    
    
    private static testmethod void testnewCompetitor(){
        
        setUpData();
        Test.startTest();  
            CompetitorpageController cont = new CompetitorpageController(new ApexPages.StandardSetController([Select id from Product_competitor__c where id =:prodComp.id]));
            cont.productIds  = 'Test';
            System.AssertNotEquals(cont.newCompetitor(),null);
            System.AssertNotEquals(cont.cancel(),null);     
        Test.stopTest();
    }
    
    private static testmethod void testPopulateproduct(){
        
        setUpData();
        Test.startTest();  
            CompetitorpageController cont = new CompetitorpageController(new ApexPages.StandardSetController([Select id from Product_competitor__c where id =:prodComp.id]));
            cont.companyid = acct.Id;
            cont.Populateproduct();
        Test.stopTest();    
    
    }
    
    private static testmethod void testPopulateProductFamily(){
        
        setUpData();
        Test.startTest();  
            CompetitorpageController cont = new CompetitorpageController(new ApexPages.StandardSetController([Select id from Product_competitor__c where id =:prodComp.id]));
            cont.productId = prodComp.Id;
            cont.PopulateProductFamily();
        Test.stopTest();
    }
}