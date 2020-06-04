@isTest
private class CalculateTaxCheckInAmtControllerTest{

    private static Country_Region_Mapping__c cust;
    private static Geospatial_Country_Region_Mapping__c custRegMap ;
    private static Account acct;
    private static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    private static User thisUser ;
    private static Apttus_Proposal__Proposal__c appProp;
    private static Apttus_Config2__PriceList__c appConf;
    
    static void setUpData(){
        
        cust = new Country_Region_Mapping__c(name='Switzerland',Region__c='Switzerland');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='Switzerland',Region__c='Switzerland');
        insert custRegMap;
        
        thisUser = [select Id from User where Id = :UserInfo.getUserId()];
        
        acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
            BillingCountry = 'Switzerland',BillingCity = 'Pune',BillingStreet = 'A-202');
        insert acct;
        
        appConf = new Apttus_Config2__PriceList__c(name='TIBV CH Price List' ,Apttus_Config2__Active__c=true);
        insert appConf;
        
        appProp = new Apttus_Proposal__Proposal__c(Apttus_Proposal__Account__c=acct.id,Apttus_QPConfig__PriceListId__c=appConf.Id ,Ship_To_Account__c=acct.Id);
        insert appProp;
    }
    
    private static testmethod void testGenerateprop(){
        
        setUpData();
        Test.startTest();   
            
            Pagereference pgRef = Page.CalculateTaxCheckInAmt;
            pgRef.getParameters().put('id',appProp.id);
            Test.setCurrentPage(pgRef);
            
            CalculateTaxCheckInAmtController cont = new CalculateTaxCheckInAmtController();
            cont.generateprop();    
            
        Test.stopTest();
    }   
    
    private static testmethod void testCalculateTax(){
        
        setUpData();
        Test.startTest();   
            
            Pagereference pgRef = Page.CalculateTaxCheckInAmt;
            pgRef.getParameters().put('id',appProp.id);
            Test.setCurrentPage(pgRef);
            
            appProp.Tax__c =100;
            
            CalculateTaxCheckInAmtController cont = new CalculateTaxCheckInAmtController();
            cont.calculateTax();    
            cont.cancelquote();  
            
        Test.stopTest();
    }   
    
    private static testmethod void testCalculateTaxNew(){
        
        setUpData();
        Test.startTest();   
            
            Pagereference pgRef = Page.CalculateTaxCheckInAmt;
            pgRef.getParameters().put('id',appProp.id);
            Test.setCurrentPage(pgRef);
            
            CalculateTaxCheckInAmtController cont = new CalculateTaxCheckInAmtController();
            cont.calculateTax();    
            cont.cancelquote();  
            
        Test.stopTest();
    }   
}