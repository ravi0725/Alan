@isTest
private class InboundEmailHandlerTest{

    private static Messaging.InboundEmail email = new Messaging.InboundEmail();
    private static Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
    private static Apttus_Proposal__Proposal__c appProp;
    private static Apttus_Config2__PriceList__c appConf;
    private static Task tsk ;
    private static UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
    private static Profile profile = [Select Id from Profile where name = 'System Administrator'];
    private static User portalAccountOwner ;
    private static Messaging.InboundEmailResult res ;
    private static Account acct ;
    public static Country_Region_Mapping__c cust;
    public static Geospatial_Country_Region_Mapping__c custRegMap ;
    public static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    
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
        
        Apttus_Proposal__Proposal__c appProposal = [Select id, name from Apttus_Proposal__Proposal__c where id=:appProp.id];
        
        tsk = new Task(whatid=appProp.id, ownerid=thisUser.Id );
        insert tsk;
        
        List<String> emailToAddress = new List<String>();
        emailToAddress.add('test@test.com');
      
              
        envelope.fromAddress = 'testsupport@test.com';    
        envelope.ToAddress = 'testenv@test.com';  
        
        email.subject = 'Sandbox: '+appProposal.name;
        System.debug('email.subject ::'+email.subject);

        email.plainTextBody = 'Test Body';
        email.toAddresses = emailToAddress  ;
        email.fromAddress = 'testemail@test.com';
        email.ccAddresses = emailToAddress;
        
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfile.txt';
        attachment.mimeTypeSubType = 'text/plain';

        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };

    }
    
    static testMethod void testHandleInbound(){
    
            setUpData();
            Test.startTest();

                InboundEmailHandler emailObj = new InboundEmailHandler();
                emailObj.handleInboundEmail(email,envelope);
                //System.AssertEquals(res.success,true);
                
            Test.stopTest();
    }   
}