//27/3/2015- Divya: Changed Product_Family__c to Opportunity_Product__c at line 46

@isTest
Private class OpportunityPlancalControllerTest{
    
    private static Apttus_Config2__PriceList__c  appPriceList ;
    private static Profile profile = [Select Id from Profile where name = 'System Administrator - MEP - Europe'];
    private static User apiUser ;
    private static Opportunity  opp01 ;
    private static Country_Region_Mapping__c cust;
    private static Geospatial_Country_Region_Mapping__c custRegMap ;
    private static Account acct;
    private static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
   // private static Id opptyRecTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Opportunity (Plancal Customer) Record Type').getRecordTypeId();
    
    static void setUpData(){
        
        cust = new Country_Region_Mapping__c(name='Switzerland',Region__c='Switzerland');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='Switzerland',Region__c='Switzerland');
        insert custRegMap;
        
        Payment_Term_Order__c PaymentTerm = new Payment_Term_Order__c(name='Monthly',Number_of_Days__c = 20);
        insert PaymentTerm;
        
        String restrictedEntry = Label.Not_Restricted ;
        acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
            BillingCountry = 'Switzerland',BillingCity = 'Pune',BillingStreet = 'A-202',BillingPostalCode='100100' ,BillingState='Goa' , Restricted_Entity__c=restrictedEntry);
        insert acct;
        
        appPriceList = new Apttus_Config2__PriceList__c(Name='TIBV CH Price List', Region__c='EMEA' ,Apttus_Config2__Active__c=true);
        insert appPriceList ;
        
        apiUser = new User(ProfileId = profile.Id,Username = System.now().second()+'-'+System.now().millisecond() + 'test2@test.com',
                Alias = 'Test', Email='test@test.com',EmailEncodingKey='UTF-8', Firstname='Test',Lastname='Suite',LanguageLocaleKey='en_US',
                LocaleSidKey='en_US',TimeZoneSidKey='America/Chicago',Country='India');
        
        Payment_Term_Order__c PaymentTerm1 = new Payment_Term_Order__c(name='CASH IN ADVANCE',Number_of_Days__c = 20);
        insert PaymentTerm1;
        
        opp01 = new Opportunity();
        opp01.Name = 'oppty-00';
        opp01.StageName = '1';
        opp01.ForecastCategoryName = 'Pipeline';
        opp01.CloseDate = Date.newInstance(2013, 12, 1);
        opp01.Type = 'New Business';
        opp01.Accountid = acct.Id ;
        opp01.Ship_To_Account__c = acct.id ;
        opp01.Price_List__c = appPriceList.Id ;
        opp01.Payment_Term__c = 'Monthly';
        opp01.Opportunity_Product__c = 'Hardware';

        insert opp01 ;
        
    }

    private static testmethod void testConfigureProductsMEP(){
        setUpData();
        Test.startTest(); 
            System.runAs(apiUser){          
                
                PageReference pgRef = Page.OpportunityPlancalEditPage ;
                pgRef.getParameters().put('RecordType' , 'Plancal');
                Test.setCurrentPage(pgRef);
            
                OpportunityPlancalController cont = new OpportunityPlancalController(new ApexPages.StandardController(opp01));
                cont.redirectToOpportunity() ;
            }
        Test.stopTest();
    }
    
    private static testmethod void testConfigureProducts(){
        setUpData();
        Test.startTest(); 
                
            PageReference pgRef = Page.OpportunityPlancalEditPage ;
            pgRef.getParameters().put('RecordType' , 'Plancal');
            Test.setCurrentPage(pgRef);
            
            OpportunityPlancalController cont = new OpportunityPlancalController(new ApexPages.StandardController(opp01));
            cont.redirectToOpportunity() ;
            
        Test.stopTest();
    }

}