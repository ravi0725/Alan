@isTest
Private class EditMultipleAssetsAndCasesClassTest{

    private static Country_Region_Mapping__c cust;
    private static Geospatial_Country_Region_Mapping__c custRegMap ;
    private static User thisUser ;
    private static Account acct;
    private static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    private static Product_competitor__c  prodComp;
    private static Competitor_Owned_Assets__c compAsset;
    private static Id recordType = Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get('Lead (Customer) Record Type').getRecordTypeId();
    public static Case cs;
    public static Multiple_Assets_Case_Junction__c csAssetJunc ;
    public static Asset asst;
    static void setUpData(){
    
        cust = new Country_Region_Mapping__c(name='India',Region__c='India');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='India',Region__c='India');
        insert custRegMap;
        
        thisUser = [ select Id from User where Id = :UserInfo.getUserId()];
             
        acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
            BillingCountry = 'India',BillingCity = 'Pune',BillingStreet = 'A-202',OwnerId = thisUser.Id);
        insert acct;
        
        prodComp = new Product_competitor__c (name='Test Prod Comp',Competitor_Account__c=acct.Id,Product_Family__c='Test');
        insert prodComp;
        
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
    
    
    private static testmethod void testNewAssets(){
        
        setUpData();
        Test.startTest();  
        
            Pagereference pgRef = Page.competitorAssetsAccountPage;
            pgRef.getParameters().put('id',csAssetJunc.id);
            Test.setCurrentPage(pgRef);
                
            EditMultipleAssetsAndCasesClass cont = new EditMultipleAssetsAndCasesClass();
            System.AssertNotEquals(cont.cancel(),null);     
        Test.stopTest();
    }
    
    private static testmethod void testupdateAssets(){
        
        setUpData();
        Test.startTest();  
        
            Pagereference pgRef = Page.competitorAssetsAccountPage;
            pgRef.getParameters().put('id',csAssetJunc.id);
            Test.setCurrentPage(pgRef);
                
            EditMultipleAssetsAndCasesClass cont = new EditMultipleAssetsAndCasesClass();
            
            System.AssertNotEquals(cont.updateAssets(),null);
 
        Test.stopTest();
    }
    
    
}