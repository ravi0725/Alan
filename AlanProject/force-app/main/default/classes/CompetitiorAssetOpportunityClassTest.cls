@isTest
Private class CompetitiorAssetOpportunityClassTest{
    
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
    private static Opportunity opp;
    
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
       
        opp = new Opportunity();
        opp.Name = 'oppty-00';
        opp.StageName = '1';
        opp.ForecastCategoryName = 'Pipeline';
        opp.CloseDate = Date.newInstance(2013, 12, 1);
        opp.Type = 'New Business';
        opp.Accountid = acct.Id ;
        insert opp;
        
        compAsset = new Competitor_Owned_Assets__c(name='Test Competitor Asset',Account__c=acct.Id,Product__c=prodComp.Id );
        insert compAsset;
        
        compAssetJunc = new Competitor_Assets_Junction__c(Account__c = acct.Id,Competitor_Assets__c = compAsset.Id ,Opportunity__c=opp.Id);
        insert compAssetJunc;        
        
        CompetitiorAssetOpportunityClass classObj = new CompetitiorAssetOpportunityClass();
        CompetitiorAssetOpportunityClass.clsLeadWrapper cls = new CompetitiorAssetOpportunityClass.clsLeadWrapper();
    }   

    private static testmethod void testRelatedCompetitorAsset(){
        
        setUpData();
        Test.startTest();
        
            Pagereference pgRef = Page.competitorAssetsLeadPage;
            pgRef.getParameters().put('id',opp.id);
            Test.setCurrentPage(pgRef);
            
            CompetitiorAssetOpportunityClass cont = new CompetitiorAssetOpportunityClass(new ApexPages.standardController(opp));
            cont.assetJunction = compAssetJunc ;
            cont.loadCompetitorAsset();  
            cont.loadAddCompetitorAsset();          
            
        Test.stopTest();
        
    }       
    
    private static testmethod void testCompetitorAssetList(){
        
        setUpData();
        Test.startTest();
        
            Pagereference pgRef = Page.competitorAssetsLeadPage;
            pgRef.getParameters().put('id',opp.id);
                        
            Test.setCurrentPage(pgRef);
            CompetitiorAssetOpportunityClass cont = new CompetitiorAssetOpportunityClass(new ApexPages.standardController(opp));
            cont.getCompetitorAssetList();
            cont.getRelatedCompetitorAsset();
        Test.stopTest();
        
    }     
    
 
    
    private static testmethod void testEditCompAsset(){
        
        setUpData();
        Test.startTest();
        
            Pagereference pgRef = Page.competitorAssetsLeadPage;
            pgRef.getParameters().put('id',compAsset.id);
            pgRef.getParameters().put('aId',opp.id);
                        
            Test.setCurrentPage(pgRef);
            CompetitiorAssetOpportunityClass cont = new CompetitiorAssetOpportunityClass(new ApexPages.standardController(opp));
            cont.assetJunction = compAssetJunc ;
            
            cont.editCompAsset();
        Test.stopTest();
        
    }   
    
    
    
    private static testmethod void testProdFamily(){
        
        setUpData();
        Test.startTest();
        
            Pagereference pgRef = Page.competitorAssetsLeadPage;
            pgRef.getParameters().put('id',opp.id);
            Test.setCurrentPage(pgRef);
            
            CompetitiorAssetOpportunityClass cont = new CompetitiorAssetOpportunityClass(new ApexPages.standardController(opp));
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
            pgRef.getParameters().put('id',opp.id);
            
            Test.setCurrentPage(pgRef);
            
            CompetitiorAssetOpportunityClass cont = new CompetitiorAssetOpportunityClass(new ApexPages.standardController(opp));
            cont.productIds = 'Test';
            cont.cancel(); 
            cont.newAssets();
            cont.redirectToNew();
            cont.pageredirect();
            cont.cancelPage();
                                
        Test.stopTest();
        
    }
    
    private static testmethod void testUpdAsset(){
        
        setUpData();
        Test.startTest();
        
            Pagereference pgRef = Page.competitorAssetsLeadPage;
            pgRef.getParameters().put('id',opp.id);
             
            Test.setCurrentPage(pgRef);
            
            CompetitiorAssetOpportunityClass cont = new CompetitiorAssetOpportunityClass(new ApexPages.standardController(opp));
            List<CompetitiorAssetOpportunityClass.clsLeadWrapper> assetLst = new List<CompetitiorAssetOpportunityClass.clsLeadWrapper>();
            
            CompetitiorAssetOpportunityClass.clsLeadWrapper clsLead00 = new CompetitiorAssetOpportunityClass.clsLeadWrapper();
            clsLead00.isSelected =true;
            clsLead00.asset=compAssetJunc;
            
            CompetitiorAssetOpportunityClass.clsLeadWrapper clsLead01 = new CompetitiorAssetOpportunityClass.clsLeadWrapper();
            clsLead01.isSelected =false;
            clsLead01.asset=compAssetJunc;
            
            assetLst.add(clsLead00);
            assetLst.add(clsLead01);
            
            cont.productIds ='Test';
            cont.competitorAssetsList = assetLst;
            cont.updateAssets();    
            cont.updatecompetitor();
                        
        Test.stopTest();
        
    }
    
    private static testmethod void testDeleteAsset(){
        
        setUpData();
        Test.startTest();
        
            Pagereference pgRef = Page.competitorAssetsLeadPage;
            pgRef.getParameters().put('id',opp.id);
            
            Test.setCurrentPage(pgRef);
            
            CompetitiorAssetOpportunityClass cont = new CompetitiorAssetOpportunityClass(new ApexPages.standardController(opp));
            cont.assetId = compAsset.Id;
            cont.opptyId = opp.id;
            cont.deleteCompetitorAsset();            
                        
        Test.stopTest();
        
    }        
    
}