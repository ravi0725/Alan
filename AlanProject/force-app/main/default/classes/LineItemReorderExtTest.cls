/**
 * Company     : Trimble Software Technology Pvt Ltd.,
 * Description : Test class for LineItemReorder class
 * History     :  

 * [24.08.2014] Ankur Patel  Created
 */
@isTest
Private class LineItemReorderExtTest{
    public static Apttus_Proposal__Proposal_Line_Item__c proposalLiTm;
    public static Apttus_Proposal__Proposal_Line_Item__c proposalLiTm2;
    public static Apttus_Proposal__Proposal__c proposal;
    public static Account acct;
    public static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    public static Country_Region_Mapping__c cust;
    public static Geospatial_Country_Region_Mapping__c custRegMap ;
    static void setUpData(){
        cust = new Country_Region_Mapping__c(name='India',Region__c='India');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='India',Region__c='India');
        insert custRegMap;
        
        acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
            BillingCountry = 'India',BillingCity = 'Pune',BillingStreet = 'A-202');
        insert acct;
        
        proposal = new Apttus_Proposal__Proposal__c();
        proposal.Apttus_Proposal__Account__c = acct.Id;
        insert proposal;
        
        proposalLiTm = new Apttus_Proposal__Proposal_Line_Item__c();
        proposalLiTm.Apttus_Proposal__Proposal__c = proposal.Id;
        proposalLiTm.Apttus_QPConfig__LineType__c='Product/Service';
        proposalLiTm.Apttus_QPConfig__ChargeType__c='Standard Price';
        proposalLiTm.Sort_Order__c = 0;
        insert proposalLiTm;
        
        proposalLiTm2 = new Apttus_Proposal__Proposal_Line_Item__c();
        proposalLiTm2.Apttus_Proposal__Proposal__c = proposal.Id;
        proposalLiTm2.Apttus_QPConfig__LineType__c='Product/Service';
        proposalLiTm2.Apttus_QPConfig__ChargeType__c='Standard Price';
        proposalLiTm2.Sort_Order__c = 1;
        insert proposalLiTm2;
    }   


    private static testmethod void TestAcceptProposalCustomController(){
    
        setUpData();
        Test.startTest();
        
            PageReference pgRef = Page.LineItemReorder;
            pgRef.getParameters().put('id',proposalLiTm.id);
            Test.setCurrentPage(pgRef);
            ApexPages.StandardController sc = new ApexPages.standardController(proposalLiTm);
            LineItemReorderExt temp = new LineItemReorderExt(sc);
            temp.getProposalLineItemList();
            temp.proposalLineItemIds = proposalLiTm.Id+','+proposalLiTm2.Id;
            temp.updateSortOrder();
            temp.validateSortOrderForDuplicate();
            temp.BackToQuote();
        Test.stopTest();
        
    }

}