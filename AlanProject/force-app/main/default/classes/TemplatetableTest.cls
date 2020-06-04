@isTest
private class TemplatetableTest{
    
    private static Country_Region_Mapping__c cust;
    private static Geospatial_Country_Region_Mapping__c custRegMap ;
    private static Account acct;
    private static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    private static User thisUser ;
    private static Apttus_Proposal__Proposal__c appProp;
    public static Apttus_Config2__ProductConfiguration__c prodConfig ;
    private static Apttus_Config2__PriceList__c appConf;
    public static List<Apttus_Approval__Approval_Request__c> appovalLst = new List<Apttus_Approval__Approval_Request__c>() ;
    
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
        
        prodConfig = new Apttus_Config2__ProductConfiguration__c(name='Test Product Config',Apttus_QPConfig__Proposald__c=appProp.id);
        insert prodConfig;
        
        appovalLst.add(new Apttus_Approval__Approval_Request__c(Apttus_Approval__Approval_Status__c='Assigned',Apttus_Approval__Assigned_To_Type__c='User' ,
                        Apttus_Approval__Assigned_To_Id__c=UserInfo.getUserId() ,Apttus_CQApprov__CartId__c=prodConfig.Id ,Apttus_Approval__StepSequence__c=2222));
        appovalLst.add(new Apttus_Approval__Approval_Request__c(Apttus_Approval__Approval_Status__c='Assigned',Apttus_Approval__Assigned_To_Type__c='Queue'));
        insert appovalLst;
    }
    
    private static testmethod void testgetapprovalReqList(){
        
        setUpData();
        Test.startTest();   
           
            Templatetable cont = new Templatetable();
            cont.proposalId = appovalLst[0].id;
            cont.getapprovalReqList();    
            
        Test.stopTest();
    }  
    
}