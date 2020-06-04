/*****************************************************************************************
Name    : CustomprimarycontactlookupPageContTest 
Modification Log : 
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
P M Mamata       1/08/2015          Modified
******************************************************************************************/

@isTest
private class CustomprimarycontactlookupPageContTest{

    private static Country_Region_Mapping__c cust;
    private static Geospatial_Country_Region_Mapping__c custRegMap ;
    private static Account acct;
    private static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    private static User thisUser ;
    private static Asset asst ;
    private static attachment attach;
    private static Case cs;
    private static Contact contact;
    
    static void setUpData(){
        
        cust = new Country_Region_Mapping__c(name='India',Region__c='India');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='India',Region__c='India');
        insert custRegMap;        
       
        acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
            BillingCountry = 'India',BillingCity = 'Pune',BillingStreet = 'A-202');
        insert acct;    
            
        contact = new Contact();
        contact.LastName = 'Test';
        contact.AccountId = acct.Id;
        contact.MailingCountry ='India';
        insert contact;
   
    }
    
    private static testmethod void testGenerateprop(){
        
        setUpData();
        Test.startTest();   
            
            Pagereference pgRef = Page.customprimarycontactlookup;
            pgRef.getParameters().put('lksrch','Test');
            pgRef.getParameters().put('accountid',acct.id);
            Test.setCurrentPage(pgRef);
            
            CustomprimarycontactlookupPageController cont = new CustomprimarycontactlookupPageController();
            GenerateTestData.createAccount();
        	cont.search();
            cont.getFormTag();
            cont.getTextBox();         	

            
        Test.stopTest();
    }   
    
      
}