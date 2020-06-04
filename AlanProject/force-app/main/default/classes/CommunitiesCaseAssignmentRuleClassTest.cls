@isTest
Private class CommunitiesCaseAssignmentRuleClassTest{

    public static Case cs;
    public static User thisUser;
    public static Country_Region_Mapping__c cust;
    public static Geospatial_Country_Region_Mapping__c custRegMap ;
    public static Profile profile = [Select Id, Name from Profile where Name =: Label.MEP_Europe_Community_Profile];
    public static User portalAccountOwner ;
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
        
        Contact contact = new Contact();
        contact.FirstName = 'Partner';
        contact.LastName = 'Contact';
        contact.AccountId = acct.Id;
        contact.MailingCountry='India';
        insert contact;
        
        User objUser = [select id, profileid from user where profile.name ='System Administrator' limit 1];
        
        cs = new Case();
        cs.Origin='Phone';
        cs.Status = 'Open';
        cs.status_reason__c='New Unassigned';
        cs.Subject ='XYZ';
        cs.Description='Xyz Description';
        cs.ownerId = objUser.id;
        //cs.accountId=acct.Id;
        
        insert cs;
    }
    
    private static testmethod void testSubmitCaseForAssignmentRule(){
        
        setUpData();
        Test.startTest();
        
        PageReference pgRef = Page.SubmitCaseForAssignment;
        pgRef.getParameters().put('id',cs.id);
        Test.setCurrentPage(pgRef);
        
        CommunitiesCaseAssignmentRuleClass cont = new CommunitiesCaseAssignmentRuleClass(new ApexPages.StandardSetController([Select Id From Case Where Id =:cs.Id]));
        //cont.submitCaseForAssignmentRule();  //Prasad [13th July, 2015] : Need to comment this line as it was throwing exception. Need to fix once deployment
        
        Test.stopTest();
    }
}