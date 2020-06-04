/**
 * Company     : Trimble Software Technology Pvt Ltd.,
 * Description : Test class for QuickQuoteFromAccountController class
 * History     :  

 * [29.09.2014] Ankur Patel  Created
 */
@isTest
public class QuickQuoteFromAccountControllerTest{
    public static Country_Region_Mapping__c cust;
    public static Geospatial_Country_Region_Mapping__c custRegMap ;
    public static User thisUser ;
    public static Account acct;
    public static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    static void setUpData(){
        cust = new Country_Region_Mapping__c(name='India',Region__c='India');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='India',Region__c='India');
        insert custRegMap;
        
        acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
            BillingCountry = 'India',BillingCity = 'Pune',BillingStreet = 'A-202');
        insert acct;
        
        Pricebook2 pb = new PriceBook2();
        pb.Name = 'GCCM Price Book';
        pb.IsActive = true;
        insert pb;
    }
    
    private static testmethod void TestAcceptProposalCustomController(){
        setUpData();
        Test.startTest();
            QuickQuoteFromAccountController temp = new QuickQuoteFromAccountController(new ApexPages.StandardController(acct));
            temp.createQuickQuote();
        Test.stopTest();
    }   
}