@isTest
private class GenerateServiceAttachmentContTest{

    public static Country_Region_Mapping__c cust;
    public static Geospatial_Country_Region_Mapping__c custRegMap ;
    public static UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
    public static Profile profile = [Select Id from Profile where name = 'System Administrator'];
    public static User portalAccountOwner ;
    public static Id recordType = Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get('Lead (Customer) Record Type').getRecordTypeId();
    public static Event evt;
    public static Event_Template_Language__c langMap;
    public static Case cs;
    public static Account acct;
    public static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    public static Contact contact ;
    public static Apttus_Config2__PriceList__c appConf;
    public static Apttus_Proposal__Proposal__c appProp ;
    
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
        
        appProp = new Apttus_Proposal__Proposal__c(Apttus_Proposal__Account__c=acct.id,Apttus_QPConfig__PriceListId__c=appConf.Id ,Ship_To_Account__c=acct.Id);
        insert appProp;
        
        contact = new Contact();
        contact.FirstName = 'Partner';
        contact.LastName = 'Contact';
        contact.AccountId = acct.Id;
        contact.MailingCountry ='Switzerland';
        insert contact;
          
       
        cs = new Case();
        cs.Origin='Phone';
        cs.Status = 'Open';
        cs.status_reason__c='New Unassigned';
        cs.Subject ='XYZ';
        cs.Description='Xyz Description';
        insert cs;
        
        evt = new Event(Description='Test',WhoId=contact.Id,StartDateTime=System.now(),Language__c='English',OwnerId=thisUser.Id,DurationInMinutes=200,whatId=acct.Id);
        insert evt;
        
        langMap = new Event_Template_Language__c(name='English');
        insert langMap;
        
    }
    
    private static testmethod void testnext(){
        
        setUpData();
        Test.startTest();   
            
            Pagereference pgRef = Page.GenerateServiceAttachment;
            pgRef.getParameters().put('id',evt.id);
            pgRef.getParameters().put('qId',cs.id);
            Test.setCurrentPage(pgRef);
            
            GenerateServiceAttachmentController cont = new GenerateServiceAttachmentController();
            System.assertNotEquals(cont.generateAttachment(),null);    
            
        Test.stopTest();
    }   
    
    private static testmethod void testAttachment(){
        
        setUpData();
        Test.startTest();   
            
            Pagereference pgRef = Page.GenerateServiceAttachment;
            pgRef.getParameters().put('id',evt.id);
            pgRef.getParameters().put('qId',appProp.id);
            Test.setCurrentPage(pgRef);
            
            GenerateServiceAttachmentController cont = new GenerateServiceAttachmentController();
            System.assertNotEquals(cont.generateAttachment(),null);    
            
        Test.stopTest();
    }   
}