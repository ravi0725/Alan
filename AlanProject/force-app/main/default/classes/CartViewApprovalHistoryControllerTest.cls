@isTest
Private class CartViewApprovalHistoryControllerTest{

    public static Country_Region_Mapping__c cust;
    public static Geospatial_Country_Region_Mapping__c custRegMap ;
    public static Apttus_Proposal__Proposal__c app ;
    public static Apttus_Approval__Approval_Request_History__c appHist;
    
    static void setUpData(){
    
        cust = new Country_Region_Mapping__c(name='India',Region__c='India');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='India',Region__c='India');
        insert custRegMap;
        
        app = new Apttus_Proposal__Proposal__c(Apttus_Proposal__Payment_Term__c='1 Year',Apttus_Proposal__Description__c='Test');
        insert app;
        
        appHist= new Apttus_Approval__Approval_Request_History__c(Apttus_QPApprov__ProposalId__c=app.id);
        insert appHist;
    }   

    private static testmethod  void testHistoryList(){
        
        setUpData();           
        Test.startTest();  

            PageReference pgRef = Page.CartViewApprovalHistory;
            Test.setCurrentPage(pgRef); 
            
            CartViewApprovalHistoryController cont = new CartViewApprovalHistoryController(new ApexPages.StandardController(app));
            cont.loadMoreHistory();
            
        Test.stopTest();    
                
    }   
    
    private static testmethod  void testApprovalHistoryList(){
        
        setUpData();           
        Test.startTest();  

            PageReference pgRef = Page.CartViewApprovalHistory;
            pgRef.getParameters().put('id',app.id);
            Test.setCurrentPage(pgRef); 
            
            CartViewApprovalHistoryController cont = new CartViewApprovalHistoryController(new ApexPages.StandardController(app));
            cont.getApprovalHistoryList();
            
        Test.stopTest();    
                
    } 
}