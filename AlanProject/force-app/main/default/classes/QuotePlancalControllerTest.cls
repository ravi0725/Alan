@isTest
Private class QuotePlancalControllerTest{
    
    private static Apttus_Config2__PriceList__c appConf;
    private static User apiUser;
    private static Apttus_Proposal__Proposal__c appProp ;
    private static Country_Region_Mapping__c cust;
    private static Geospatial_Country_Region_Mapping__c custRegMap ;
    private static Account acct;
    private static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    private static Profile prf = [Select Id from Profile where Name =: Label.API_Only];
    
    static void setUpData(){
        
        cust = new Country_Region_Mapping__c(name='Switzerland',Region__c='Switzerland');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='Switzerland',Region__c='Switzerland');
        insert custRegMap;
        
        User thisUser = [select Id from User where Id = :UserInfo.getUserId()];
        
        acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
            BillingCountry = 'Switzerland',BillingCity = 'Pune',BillingStreet = 'A-202');
        insert acct;
        
        appConf = new Apttus_Config2__PriceList__c(name='TIBV CH Price List' ,Apttus_Config2__Active__c=true);
        insert appConf;
        
        apiUser = new User(ProfileId = prf.Id,Username = System.now().millisecond() + 'trimbleuattest2@test.com',
                Alias = 'Test', Email='test@test.com',EmailEncodingKey='UTF-8', Firstname='Test',Lastname='Suite',LanguageLocaleKey='en_US',
                LocaleSidKey='en_US',TimeZoneSidKey='America/Chicago',Country='India',Division__c='MEP');
                
        appProp = new Apttus_Proposal__Proposal__c(Apttus_Proposal__Account__c=acct.id,Apttus_QPConfig__PriceListId__c=appConf.Id,Standard_T_Cs__c=true
                ,Ship_To_Account__c=acct.Id);
        insert appProp;     
    }
    
    private static testmethod void testRedirectToquote(){
        
        setUpData();
        Test.startTest();
        
            Pagereference pgRef = Page.QuoteplancalRedirect;
            pgRef.getParameters().put('RecordType','Test');
                        
            Test.setCurrentPage(pgRef);
            QuotePlancalController cont = new QuotePlancalController(new ApexPages.StandardController(appProp));
            cont.redirectToquote();

        Test.stopTest();
        
    }  
    
    private static testmethod void testRedirectToquoteMEP(){
        
        setUpData();
        Test.startTest();           
            System.RunAs(apiUser){
                Pagereference pgRef = Page.QuoteplancalRedirect;
                pgRef.getParameters().put('RecordType','Test');
                            
                Test.setCurrentPage(pgRef);
                QuotePlancalController cont = new QuotePlancalController(new ApexPages.StandardController(appProp));
                cont.redirectToquote();
            }
        Test.stopTest();
        
    }  
    
        
}