@isTest
private class GeneratescheduleactivityContTest{

    public static Apttus_Config2__PriceList__c appConf;
    public static Apttus_Proposal__Proposal__c appProp ;
    public static Event evt;
    public static RecordType recType = [Select Id from RecordType where DeveloperName =: Label.Event_Service_Delivery_Record_Type]; 
    public static Country_Region_Mapping__c cust;
    public static Geospatial_Country_Region_Mapping__c custRegMap ;
    public static UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
    public static Profile profile = [Select Id from Profile where name = 'System Administrator'];
    public static User portalAccountOwner ;
    public static Account acct;
    public static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    public static Event_Template_Language__c langMap;
    
    static void setUpData(){
        
        cust = new Country_Region_Mapping__c(name='Switzerland',Region__c='Switzerland');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='Switzerland',Region__c='Switzerland');
        insert custRegMap;
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId()];
    
        acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
            BillingCountry = 'Switzerland',BillingCity = 'Pune',BillingStreet = 'A-202');
        insert acct;
        
        appConf = new Apttus_Config2__PriceList__c(name='TIBV CH Price List' ,Apttus_Config2__Active__c=true);
        insert appConf;
        
        appProp = new Apttus_Proposal__Proposal__c(Apttus_Proposal__Account__c=acct.id,Apttus_Proposal__Proposal_Name__c='TestProposal',Apttus_QPConfig__PriceListId__c=appConf.Id ,Ship_To_Account__c=acct.Id);
        insert appProp;
        
        evt = new Event(Description='Test',StartDateTime=System.now(),Language__c='English',DurationInMinutes=200,whatId=appProp.Id ,
              RecordTypeId= recType.Id);
        insert evt;
                        
        langMap = new Event_Template_Language__c(name='English');
        insert langMap;
    }
    
    
    private static testmethod void testAttachment(){
        
        setUpData();
        Test.startTest();   
            
            Pagereference pgRef = Page.GenerateSchduleActivcitypage;
            pgRef.getParameters().put('qId',appProp.id);
            Test.setCurrentPage(pgRef);
            
            GeneratescheduleactivityController cont = new GeneratescheduleactivityController();
            System.assertNotEquals(cont.generateAttachment(),null);    
            
        Test.stopTest();
    }  

    private static testmethod void testNextnCancel(){
        
        setUpData();
        Test.startTest();   
            
            Pagereference pgRef = Page.GenerateSchduleActivcitypage;
            pgRef.getParameters().put('qId',appProp.id);
            Test.setCurrentPage(pgRef);
            
            GeneratescheduleactivityController cont = new GeneratescheduleactivityController();
            System.assertNotEquals(cont.next(),null);   
            System.assertNotEquals(cont.cancel(),null);             
            
        Test.stopTest();
        
    }   
}