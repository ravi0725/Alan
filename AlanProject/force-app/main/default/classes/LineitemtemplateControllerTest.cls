@isTest
private class LineitemtemplateControllerTest{
    
    private static Country_Region_Mapping__c cust;
    private static Geospatial_Country_Region_Mapping__c custRegMap ;
    private static Apttus_Proposal__Proposal__c appProp ;
    private static UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
    private static Profile profile = [Select Id from Profile where name = 'System Administrator'];
    private static User portalAccountOwner ;
    private static Account acct;
    private static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    private static Apttus_Config2__ProductConfiguration__c prodConfig ;
    private static Apttus_Config2__LineItem__c appLineItem ;
    
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
        
        appProp = new Apttus_Proposal__Proposal__c(Apttus_Proposal__Account__c=acct.id);
        insert appProp;
        
        prodConfig = new Apttus_Config2__ProductConfiguration__c(name='Test Product Config',Apttus_QPConfig__Proposald__c=appProp.id);
        insert prodConfig;

        appLineItem = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c=prodConfig.Id ,Apttus_Config2__Quantity__c=2, Apttus_Config2__ItemSequence__c=1 , Apttus_Config2__LineNumber__c =2,Apttus_Config2__PrimaryLineNumber__c=2,
                        CurrencyIsoCode='USD');
        insert appLineItem;
    }   
    
    static testMethod void testLineitemlst(){
    
            setUpData();
            Test.startTest();

                LineitemtemplateController cont = new LineitemtemplateController();
                cont.configurationId = prodConfig.Id;
                cont.getLineitemlst();
                System.assertEquals(cont.Lineitemlist.size(),1);
                
            Test.stopTest();
    }   
}