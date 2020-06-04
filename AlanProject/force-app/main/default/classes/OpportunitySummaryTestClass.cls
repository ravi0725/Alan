/************************************************************************************
* Name          :    OpportunitySummaryTestClass
* Description   :    
* Author        :    Sagar

Modification Log
----------------
Date             Developer                Comments
------------------------------------------------------------------------------------------
                   Sagar                  Created
******************************************************************************************/
@isTest
public class OpportunitySummaryTestClass {
  
  
    private static Country_Region_Mapping__c cust;
    private static Geospatial_Country_Region_Mapping__c custRegMap ;
    
    
    static void setUpData(){
        
        cust = new Country_Region_Mapping__c(name='India',Region__c='India');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='India',Region__c='India');
        insert custRegMap;
    }   
  /**
     * Method name  : testLoadMoreOpportunities
     * Description  : This method covers the positive and negative scenarios of loadMoreOpportunities method
     * Return Type  : void
     * Parameter    : None
     **/
    static testMethod void testLoadMoreOpportunities() {  
        setUpData();     
        Account testAccount = new Account(Name='Test123',BillingCountry = 'India',BillingCity = 'Pune',BillingStreet = 'A-202');
        insert testAccount;                     
        Opportunity opp;
        List<Opportunity> oppList = new List<Opportunity>();
        for(Integer i = 0; i < 3; i++){
           opp = new Opportunity();
           opp.Name = 'test+i';
           opp.StageName = '1';
           opp.ForecastCategoryName = 'Pipeline';
           opp.CloseDate = Date.newInstance(2013, 12, 1);
           opp.AccountId = testAccount.Id;
           opp.Type = 'New Business';
           oppList.add(opp);
        }
        insert oppList;
        System.assert(oppList.size() == 3);
        ApexPages.StandardController sc = new ApexPages.StandardController(testAccount);
        PageReference pageRef = Page.opportunityRelatedCustomPage;
        Test.setCurrentPage(pageRef);
        OpportunitySummaryClass osc = new OpportunitySummaryClass(sc);        
        osc.loadMoreOpportunities();
        Apexpages.currentpage().getparameters().put('id', testAccount.Id); 
        osc.loadOpportunitiesList();
    }
    
    /**
     * Method name  : testNegativeScenarios
     * Description  : This method covers the negative scenarios
     * Return Type  : void
     * Parameter    : None
     **/
    static testMethod void testNegativeScenarios() {  
        setUpData();     
        Account testAccount = new Account(Name='Test123',BillingCountry = 'India',BillingCity = 'Pune',BillingStreet = 'A-202');
        insert testAccount;                     
        Opportunity opp;
        List<Opportunity> oppList = new List<Opportunity>();
        for(Integer i = 0; i < 3; i++){
           opp = new Opportunity();
           opp.Name = 'test+i';
           opp.StageName = '1';
           opp.ForecastCategoryName = 'Pipeline';
           opp.CloseDate = Date.newInstance(2013, 12, 1);
           opp.AccountId = testAccount.Id;
           opp.Type = 'New Business';
           oppList.add(opp);
        }
        insert oppList;
        System.assert(oppList.size() == 3);
        ApexPages.StandardController sc = new ApexPages.StandardController(testAccount);
        PageReference pageRef = Page.opportunityRelatedCustomPage;
        Test.setCurrentPage(pageRef);
        OpportunitySummaryClass osc = new OpportunitySummaryClass(sc);
        osc.loadMore = null;        
        osc.loadMoreOpportunities();
        Apexpages.currentpage().getparameters().put('id', null); 
        osc.loadOpportunitiesList();
    }
}