//Divya-24/3/2015:Changed custom field Forecast_Category_MEP__c to standard field ForecastCategoryName at line 40

@isTest(SeeAllData=True)
private class ProductCPQSupportTest{
	public static Apttus_Config2__ProductConfiguration__c prodConfig;
    
    static void setUpData(){
    	GenerateTestData.createAccount();
        GenerateTestData.createAddress();
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();
        GenerateTestData.createProduct2();
        GenerateTestData.createPricebook2();
        GenerateTestData.createPriceBookEntry();
        GenerateTestData.createProposal();
        
        Apttus_Proposal__Proposal__c tmp = [select id, Name from Apttus_Proposal__Proposal__c where Id =: GenerateTestData.proposal.Id];
        RecursiveTriggerUtility.isBeforeInsertQuoteProposalTrigger = false;
        QuoteProposalHandler.resetLaunchControl();
        
        GenerateTestData.proposal.Id = null;
        GenerateTestData.proposal.Clone_Id__c = tmp.Name;
        
        insert GenerateTestData.proposal;
        
        prodConfig = new Apttus_Config2__ProductConfiguration__c(name='Test Product Config',Apttus_QPConfig__Proposald__c=GenerateTestData.proposal.id);
        insert prodConfig;
    }
    
    private static testmethod void testCreateQuoteOrProposal(){
    
       setUpData();           
       Test.startTest();  
           Id recdId =  ProductCPQSupport.getRecordTypeIdForName('' + Apttus_Proposal__Proposal__c.getSObjectType(), ProductCPQSupport.RECORDTYPE_PROPOSAL);
           ProductCPQSupport.getOpportunitySO(GenerateTestData.opp.Id);
           ProductCPQSupport.createProposalFromOpportunity(GenerateTestData.opp, recdId);
           ProductCPQSupport.getCartSO(prodConfig.Id);
            /*
            Id proposalSO = ProductCPQSupport.createQuoteOrProposal(oppty);
            ProductCPQSupport.getOpportunitySO(oppty.id);
            System.assertNotEquals(proposalSO,null);
            */
        Test.stopTest();
    }
    
    private static testmethod void testInstanceUrl(){
       setUpData();           
       Test.startTest();  
            String urlStr = ProductCPQSupport.getInstanceUrl();           
       Test.stopTest();
              
    }
    
    private static testmethod void testNullValue(){
    
       setUpData();           
       Test.startTest();  
            String str = 'test';    
            String outstr= ProductCPQSupport.nullValue(str,'default');
       Test.stopTest();
    }
}