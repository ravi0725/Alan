@isTest
private class PopulateProductCaseGCCMTest{
    
    private static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    private static Id caseRecTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('GCCM - Support Case Record Type').getRecordTypeId();
    private static Asset asst;
    private static Account acct;
    private static Product2 prod;    
    public static Country_Region_Mapping__c cust;
    public static Geospatial_Country_Region_Mapping__c custRegMap ;
        
    static void setUpData(){                                    
        cust = new Country_Region_Mapping__c(name='India',Region__c='India');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='India',Region__c='India');
        insert custRegMap;
        
        acct = new Account(Name = 'Test Assign Case Account', RecordTypeId = acctRecTypeId, Account_Status__c = 'Pending',
               Requested_Account_Record_Type__c = 'Customer', BillingCountry = 'India', BillingCity = 'Pune', BillingStreet = 'A-202', FCH_Party_ID__c='100',
               Phone='111-111-1111', BillingState='Goa', BillingPostalCode ='343220');
        test.startTest();
        insert acct;
        
        
        prod = new Product2();
        prod.IsActive = true;
        prod.Name = 'ABC';
        prod.ProductCode = 'T1';
        prod.Certificate__c = 'C1';
        prod.Contract_Item_Type_Code__c ='WARRANTY';
        prod.productcode ='Code';
        insert prod;
        
        asst = new Asset(name = 'Test Asset', AccountId = acct.Id, Asset_Oracle_ID__c = 'Test', Product2Id = prod.Id);
        insert asst;   
               
        Case newCase = new Case();
        newCase.Origin = 'Phone';
        newCase.Type = 'New Problem';
        newCase.Severity_c__c = 'Severity 1: Critical';
        newCase.urgency__c = 'Urgency 1: Critical';
        newCase.Status = 'Open';
        newCase.status_reason__c = 'New Unassigned';
        newCase.Subject = 'XYZ';
        newCase.Description = 'Xyz Description';
        newCase.RecordTypeId = caseRecTypeId;
        newCase.AssetId = asst.Id;
        insert newCase;                                                                
        test.stopTest();
    }
    
    static testMethod void testCaseGCCMTrigger(){
        Profile p = [Select Id from Profile where Name = 'Sales Ops - GCCM'];           
        User user = new User();
        user.Username = 'sagamehta123@deloitte.com';
        user.Email = 'sagamehta@deloitte.com';
        user.LastName = 'Test';
        user.Alias = 'Test123';
        user.ProfileID = p.Id;
        user.LocaleSidKey = 'en_US';
        user.LanguageLocaleKey = 'en_US';
        user.Country = 'India';
        user.Division__c = 'Infrastructure';
        user.TimeZoneSidKey = 'America/Los_Angeles';
        user.EmailEncodingKey='UTF-8';
        insert user;
        System.RunAs(user){
           setUpData();
        }
    }
}