//Divya-24/3/2015:custom field Product_Family__c to Opportunity_Product__c at line 41

@isTest
Private class CompetitiorAssetLeadClassTest{
    
    public static Country_Region_Mapping__c cust;
    public static Geospatial_Country_Region_Mapping__c custRegMap ;
    public static UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
    public static Profile profile = [Select Id from Profile where name = 'System Administrator'];
    public static User portalAccountOwner ;
    public static Account acct;
    public static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    public static Competitor_Owned_Assets__c compAsset ;
    public static Product_competitor__c  prodComp;
    public static Competitor_Assets_Junction__c compAssetJunc;
       private static Lead leadvar ;
    
    static void setUpData(){
    
        cust = new Country_Region_Mapping__c(name='India',Region__c='India');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='India',Region__c='India');
        insert custRegMap;
        
        User thisUser = [select Id from User where Id = :UserInfo.getUserId()];
        
        acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
            BillingCountry = 'India',BillingCity = 'Pune',BillingStreet = 'A-202');
        insert acct;
            
        prodComp = new Product_competitor__c(name='Test Prod Competitor' , Competitor_Account__c=acct.Id);
        insert prodComp;               
       
        RecordType recordType = [SELECT Id FROM RecordType WHERE DeveloperName =: Label.Lead_Accept_Reject_Record_Type];
                        
        leadvar = new Lead(LastName = 'Test Lead',company='Test',isPartnerReject__c=false,
                    Lead_Accept_TimeStamp__c = DateTime.newInstance(System.now().year(), System.now().month(), System.now().day(), System.now().hour(), 0, 0) ,
                    RecordTypeId = recordType.Id,Country='India',Industry='Engineering and Construction',city='Pune',
                    street='dalal',postalcode='100100',Opportunity_Product__c='Hardware',Email='test@test.com',Phone='111-111-1111',
                    Address1__c='Test-1',Address2__c='Test-2',Address3__c='Test-3',Address4__c='Test-4');   
        insert leadvar; 
        
        compAsset = new Competitor_Owned_Assets__c(name='Test Competitor Asset',Account__c=acct.Id,Product__c=prodComp.Id , Lead__c=leadvar.Id);
        insert compAsset;
        
        compAssetJunc = new Competitor_Assets_Junction__c(Account__c = acct.Id,Competitor_Assets__c = compAsset.Id , Lead__c = leadvar.Id);
        insert compAssetJunc;
        
        
        CompetitiorAssetLeadClass classObj = new CompetitiorAssetLeadClass();
        
    }   

    private static testmethod void testRelatedCompetitorAsset(){
        
        setUpData();
        Test.startTest();
        
            Pagereference pgRef = Page.competitorAssetsLeadPage;
            pgRef.getParameters().put('id',leadvar.id);
            Test.setCurrentPage(pgRef);
            
            CompetitiorAssetLeadClass cont = new CompetitiorAssetLeadClass(new ApexPages.standardController(leadvar));
            cont.assetJunction = compAssetJunc ;
            cont.loadMoreCompAssets();
            cont.loadCompetitorAsset();            
            
        Test.stopTest();
        
    }       
    
    private static testmethod void testCompetitorAssetList(){
        
        setUpData();
        Test.startTest();
        
            Pagereference pgRef = Page.competitorAssetsLeadPage;
            pgRef.getParameters().put('id',leadvar.id);
                        
            Test.setCurrentPage(pgRef);
            CompetitiorAssetLeadClass cont = new CompetitiorAssetLeadClass(new ApexPages.standardController(leadvar));
            cont.getCompetitorAssetList();
            
        Test.stopTest();
        
    }     
    
    private static testmethod void testEditCompetitorAsset(){
        
        setUpData();
        Test.startTest();
        
            Pagereference pgRef = Page.competitorAssetsLeadPage;
            pgRef.getParameters().put('id',leadvar.id);
                        
            Test.setCurrentPage(pgRef);
            CompetitiorAssetLeadClass cont = new CompetitiorAssetLeadClass(new ApexPages.standardController(leadvar));
            cont.EditCompetitorAsset();

        Test.stopTest();
        
    }   
    
    private static testmethod void testEditCompAsset(){
        
        setUpData();
        Test.startTest();
        
            Pagereference pgRef = Page.competitorAssetsLeadPage;
            pgRef.getParameters().put('id',compAsset.id);
            pgRef.getParameters().put('aId',leadvar.id);
                        
            Test.setCurrentPage(pgRef);
            CompetitiorAssetLeadClass cont = new CompetitiorAssetLeadClass(new ApexPages.standardController(leadvar));
            cont.assetJunction = compAssetJunc ;
            
            cont.editCompAsset();
        Test.stopTest();
        
    }   
    
    
    
    private static testmethod void testProdFamily(){
        
        setUpData();
        Test.startTest();
        
            Pagereference pgRef = Page.competitorAssetsLeadPage;
            pgRef.getParameters().put('id',leadvar.id);
            Test.setCurrentPage(pgRef);
            
            CompetitiorAssetLeadClass cont = new CompetitiorAssetLeadClass(new ApexPages.standardController(leadvar));
            cont.productId =prodComp.Id;
            cont.assets = compAsset;
            cont.companyid = prodComp.Id;
            cont.populateproduct();
            cont.populateProductFamily();

        Test.stopTest();
        
    }
    
    private static testmethod void testPageReference(){
        
        setUpData();
        Test.startTest();
        
            Pagereference pgRef = Page.competitorAssetsLeadPage;
            pgRef.getParameters().put('id',leadvar.id);
            
            Test.setCurrentPage(pgRef);
            
            CompetitiorAssetLeadClass cont = new CompetitiorAssetLeadClass(new ApexPages.standardController(leadvar));
            cont.productIds = 'Test';
            cont.cancel(); 
            cont.newAssets();
            cont.redirectToNew();
                                
        Test.stopTest();
        
    }
    
    private static testmethod void testUpdAsset(){
        
        setUpData();
        Test.startTest();
        
            Pagereference pgRef = Page.competitorAssetsLeadPage;
            pgRef.getParameters().put('id',leadvar.id);
             
            Test.setCurrentPage(pgRef);
            
            CompetitiorAssetLeadClass cont = new CompetitiorAssetLeadClass(new ApexPages.standardController(leadvar));
            cont.productIds ='Test';
            cont.updateAssets();            
                        
        Test.stopTest();
        
    }
    
    private static testmethod void testDeleteAsset(){
        
        setUpData();
        Test.startTest();
        
            Pagereference pgRef = Page.competitorAssetsLeadPage;
            pgRef.getParameters().put('id',leadvar.id);
            
            Test.setCurrentPage(pgRef);
            
            CompetitiorAssetLeadClass cont = new CompetitiorAssetLeadClass(new ApexPages.standardController(leadvar));
            cont.assetId = compAsset.Id;
            cont.leadId = leadvar.id;
            cont.deleteCompetitorAsset();            
                        
        Test.stopTest();
        
    }           
}