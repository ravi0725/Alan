@isTest
Private class MultipleAssetsRelatedListControllerTest{
    
    public static Case cs;
    public static Multiple_Assets_Case_Junction__c csAssetJunc ;
    private static Country_Region_Mapping__c cust;
    private static Geospatial_Country_Region_Mapping__c custRegMap ;
    private static Account acct;
    private static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    private static Asset asst ;
    
    static void setUpData(){
        
        cust = new Country_Region_Mapping__c(name='India',Region__c='India');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='India',Region__c='India');
        insert custRegMap;
        
        User thisUser = [select Id from User where Id = :UserInfo.getUserId()];
        
        acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
            BillingCountry = 'India',BillingCity = 'Pune',BillingStreet = 'A-202');
        insert acct;
        
        asst = new Asset(name='Test Asset' , AccountId=acct.Id);
        insert asst;
        
        cs = new Case();
        cs.Origin='Phone';
        cs.Status = 'Open';
        cs.status_reason__c='New Unassigned';
        cs.Subject ='XYZ';
        cs.Description='Xyz Description';
        insert cs;
        
        csAssetJunc = new Multiple_Assets_Case_Junction__c(Asset__c=asst.id,Case__c=cs.id);
        insert csAssetJunc;
        
    }
    
     private static testmethod void testMultipleAssets(){
        
        setUpData();
        Test.startTest();        

            MultipleAssetsRelatedListController cont = new MultipleAssetsRelatedListController(new ApexPages.StandardController(cs));
            cont.getRelatedCompetitorAsset();

        Test.stopTest();
        
    }  
    
    
}