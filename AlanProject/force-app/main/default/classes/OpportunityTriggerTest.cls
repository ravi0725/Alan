/**
 * Company     : Trimble Software Technology Pvt Ltd.,
 * Description : Test class for Opportunity Triggers
 * History     :  

 * [08.09.2014] Ankur Patel  Created
 */
@isTest
Private class OpportunityTriggerTest{
    public static Country_Region_Mapping__c cust;
    public static Geospatial_Country_Region_Mapping__c custRegMap ;
    public static Account acct;
    public static Opportunity opp;
    public static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    static void setUpData(){
        cust = new Country_Region_Mapping__c(name='India',Region__c='India');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='India',Region__c='India');
        insert custRegMap;
        
        acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
            BillingCountry = 'India',BillingCity = 'Pune',BillingStreet = 'A-202');
        
        insert acct;
        
        opp = new Opportunity();
        opp.AccountId = acct.Id;
        opp.StageName = 'Inquery';
        opp.Closedate = date.today() + 7;
        opp.Name = 'Opp1';
        insert opp;
    }
    
    private static testmethod void TestAcceptProposalCustomController(){
        setUpData();
        Test.startTest();
            OpportunityHandler.IsRecursiveCall = false;
            delete opp;
        Test.stopTest();
    }   
    
    private static testmethod void TestTrimble_CustomException(){
        Test.startTest();
            Trimble_CustomException temp = new Trimble_CustomException('test',false);
            temp.getMessage();
        Test.stopTest();
    }   
}