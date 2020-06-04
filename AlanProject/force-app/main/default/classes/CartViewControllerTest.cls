@isTest
Private class CartViewControllerTest{

    public static Country_Region_Mapping__c cust;
    public static Geospatial_Country_Region_Mapping__c custRegMap ;
    public static Apttus_Proposal__Proposal__c appProp ;
    public static UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
    public static Profile profile = [Select Id from Profile where name = 'System Administrator'];
    public static User portalAccountOwner ;
    public static Account acct;
    public static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    
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
    }   

    private static testmethod void testCartViewController(){
        
        setUpData();
        Test.startTest();
            CartViewController cont = new CartViewController(new ApexPages.StandardController(appProp));
            cont.getCtxObjectId();
            cont.getCtxApprovalType();
        Test.stopTest();
    }
    
}