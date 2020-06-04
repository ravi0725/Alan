@isTest
Private class FinalizeOpportunityCustomControllerTest{

    private static Country_Region_Mapping__c cust;
    private static Geospatial_Country_Region_Mapping__c custRegMap ;
    private static Account acct;
    private static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    private static User thisUser ;
    private static Apttus_Proposal__Proposal__c appProp;
    private static Apttus_Config2__PriceList__c appConf;
    private static attachment attach;
    
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
        
        appProp = new Apttus_Proposal__Proposal__c(Apttus_Proposal__Account__c=acct.id,Apttus_QPConfig__PriceListId__c=appConf.Id,Standard_T_Cs__c=true
                ,Ship_To_Account__c=acct.Id);
        insert appProp;

    }
    
    private static testmethod void testupdateopportunity(){
        
        setUpData();
        Test.startTest();   
            
            Pagereference pgRef = Page.FianalizeOpportunitypage;
            pgRef.getParameters().put('id',appProp.id);
            Test.setCurrentPage(pgRef);
            
            FinalizeOpportunityCustomController cont = new FinalizeOpportunityCustomController();
            cont.updateopportunity();    
            cont.cancelquote();
            
        Test.stopTest();
    }   
}