@isTest
private class GenerateProposalAttachmentContTest{
    
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
    
    static void setUpData(){
        
        cust = new Country_Region_Mapping__c(name='India',Region__c='India');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='India',Region__c='India');
        insert custRegMap;
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            portalAccountOwner = new User(UserRoleId = portalRole.Id,ProfileId = profile.Id,Username = System.now().millisecond() + 'test2@test.com',
                Alias = 'Test', Email='test@test.com',EmailEncodingKey='UTF-8', Firstname='Test',Lastname='Suite',LanguageLocaleKey='en_US',
                LocaleSidKey='en_US',TimeZoneSidKey='America/Chicago',Country='India');
            //insert portalAccountOwner;
        }  
        
        acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
            BillingCountry = 'India',BillingCity = 'Pune',BillingStreet = 'A-202');
        insert acct;
        
        contact = new Contact();
        contact.FirstName = 'Partner';
        contact.LastName = 'Contact';
        contact.AccountId = acct.Id;
        contact.MailingCountry ='India';
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
            
            Pagereference pgRef = Page.GenerateProposalAttachment;
            pgRef.getParameters().put('id',evt.id);
            pgRef.getParameters().put('qId',cs.id);
            Test.setCurrentPage(pgRef);
            
            GenerateProposalAttachmentController cont = new GenerateProposalAttachmentController();
            cont.taskId = evt.id;
            System.assertNotEquals(cont.generateAttachment(),null);    
            
        Test.stopTest();
    }   
}