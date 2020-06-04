@isTest
private class CustomAssetAccountlookupPageContTest{

    private static Country_Region_Mapping__c cust;
    private static Geospatial_Country_Region_Mapping__c custRegMap ;
    private static Account acct;
    private static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    private static User thisUser ;
    private static Asset asst ;
    private static Case cs;
    
    static void setUpData(){
        
        cust = new Country_Region_Mapping__c(name='India',Region__c='India');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='India',Region__c='India');
        insert custRegMap;        
       
        acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
            BillingCountry = 'India',BillingCity = 'Pune',BillingStreet = 'A-202');
        insert acct;    
            
        asst = new Asset(name='Test Asset' , AccountId=acct.Id);
        insert asst;
        
        cs = new Case();
        cs.Origin='Phone';
        cs.Status = 'Open';
        cs.status_reason__c='New Unassigned';
        cs.Subject ='XYZ';
        cs.Description='Xyz Description';
        cs.Accountid = acct.id;
        insert cs;  
   
    }
    
    private static testmethod void testsearch(){
        
        setUpData();
        Test.startTest();   
            
            Pagereference pgRef = Page.customprimarycontactlookup;
            pgRef.getParameters().put('lksrch','Test');
            pgRef.getParameters().put('caseid',cs.id);
            Test.setCurrentPage(pgRef);
            
            CustomAssetAccountlookupPageController cont = new CustomAssetAccountlookupPageController();
            cont.search();
            cont.getFormTag();
            cont.getTextBox();  
            
        Test.stopTest();
    }   
    
      
}