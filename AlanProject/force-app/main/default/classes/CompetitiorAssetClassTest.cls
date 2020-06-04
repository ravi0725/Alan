@isTest
Private class CompetitiorAssetClassTest{
    
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
    
    static void setUpData(){
    
        cust = new Country_Region_Mapping__c(name='India',Region__c='India');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='India',Region__c='India');
        insert custRegMap;
        
        //User thisUser = [ select Id from User where Id = :UserInfo.getUserId()];
        
        acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
            BillingCountry = 'India',BillingCity = 'Pune',BillingStreet = 'A-202');
        insert acct;
            
        prodComp = new Product_competitor__c(name='Test Prod Competitor');
        insert prodComp;        
         
        compAsset = new Competitor_Owned_Assets__c(name='Test Competitor Asset',Account__c=acct.Id,Product__c=prodComp.Id);
        insert compAsset;
        
        compAssetJunc = new Competitor_Assets_Junction__c(Account__c=acct.Id,Competitor_Assets__c=compAsset.Id);
        insert compAssetJunc;
        
        CompetitiorAssetClass classObj = new CompetitiorAssetClass();
        CompetitiorAssetClass.clsCompeAsset cls = new CompetitiorAssetClass.clsCompeAsset();
    }   

    private static testmethod void testRelatedCompetitorAsset(){
        
        setUpData();
        Test.startTest();
        
            Pagereference pgRef = Page.CompetitorAssetRelatedCustomPage;
            pgRef.getParameters().put('id',acct.id);
            Test.setCurrentPage(pgRef);
            
            CompetitiorAssetClass cont = new CompetitiorAssetClass(new ApexPages.standardController(acct));
            cont.assetJunction = compAssetJunc ;
            cont.getRelatedCompetitorAsset();
            cont.loadCompetitorAsset();            
            
        Test.stopTest();
        
    }       
    
    private static testmethod void testCompetitorAssetList(){
        
        setUpData();
        Test.startTest();
        
            Pagereference pgRef = Page.CompetitorAssetRelatedCustomPage;
            pgRef.getParameters().put('id',compAsset.id);
            pgRef.getParameters().put('aId',acct.id);
            
            Test.setCurrentPage(pgRef);
            
            CompetitiorAssetClass cont = new CompetitiorAssetClass(new ApexPages.standardController(acct));
            List<Competitor_Assets_Junction__c> compJuncLst = new List<Competitor_Assets_Junction__c>();
            compJuncLst.add(compAssetJunc);
            cont.opportunityList = compJuncLst;
            cont.assetJunction = compAssetJunc ;
            
            cont.editCompAsset(); 
            cont.companyid = acct.Id;
            cont.populateproduct();
            
        Test.stopTest();
        
    }     
    
    private static testmethod void testProdFamily(){
        
        setUpData();
        Test.startTest();
        
            Pagereference pgRef = Page.CompetitorAssetRelatedCustomPage;
            pgRef.getParameters().put('id',acct.id);
            Test.setCurrentPage(pgRef);
            
            CompetitiorAssetClass cont = new CompetitiorAssetClass(new ApexPages.standardController(acct));
            cont.productId =compAsset.Id;
            cont.assets = compAsset;
            cont.populateProductFamily();

        Test.stopTest();
        
    }
    
    private static testmethod void testPageReference(){
        
        setUpData();
        Test.startTest();
        
            Pagereference pgRef = Page.CompetitorAssetRelatedCustomPage;
            pgRef.getParameters().put('id',compAsset.id);
            pgRef.getParameters().put('aId',acct.id);
            
            Test.setCurrentPage(pgRef);
            
            CompetitiorAssetClass cont = new CompetitiorAssetClass(new ApexPages.standardController(acct));
            cont.cancel(); 
            cont.newAssets();
            cont.productIds ='Test';
                        
        Test.stopTest();
        
    }
    
    private static testmethod void testUpdAsset(){
        
        setUpData();
        Test.startTest();
        
            Pagereference pgRef = Page.CompetitorAssetRelatedCustomPage;
            pgRef.getParameters().put('id',compAsset.id);
            pgRef.getParameters().put('aId',acct.id);
            
            Test.setCurrentPage(pgRef);
            
            CompetitiorAssetClass cont = new CompetitiorAssetClass(new ApexPages.standardController(acct));
            cont.productIds ='Test';
            cont.updateAssets();            
                        
        Test.stopTest();
        
    }
    
    private static testmethod void testDeleteAsset(){
        
        setUpData();
        Test.startTest();
        
            Pagereference pgRef = Page.CompetitorAssetRelatedCustomPage;
            pgRef.getParameters().put('id',compAsset.id);
            pgRef.getParameters().put('aId',acct.id);
            
            Test.setCurrentPage(pgRef);
            
            CompetitiorAssetClass cont = new CompetitiorAssetClass(new ApexPages.standardController(acct));
            cont.assetId = compAsset.Id;
            cont.accountId = acct.Id;
            cont.deleteCompetitorAsset();            
                        
        Test.stopTest();        
    }    
}