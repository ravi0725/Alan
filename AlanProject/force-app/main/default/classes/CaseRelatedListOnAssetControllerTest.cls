@isTest
Private class CaseRelatedListOnAssetControllerTest{
    
    public static Country_Region_Mapping__c cust;
    public static Geospatial_Country_Region_Mapping__c custRegMap ;
    public static UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
    public static Profile profile = [Select Id from Profile where name = 'System Administrator'];
    public static User portalAccountOwner ;
    public static Account acct;
    public static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    public static Asset asst;
    public static BusinessHours bizhr;
    public static Case cs;
    public static Multiple_Assets_Case_Junction__c csAssetJunc ;
    
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
        
        asst = new Asset(name='Test Asset' , AccountId=acct.Id);
        insert asst;
        
        //bizhr = new BusinessHours(name='Test BizHr', TimeZoneSidKey='America/Chicago',MondayStartTime='06:00:00',MondayEndTime='18:00:00');
        //insert bizhr;
        
        cs = new Case();
        cs.Origin='Phone';
        cs.Status = 'Open';
        cs.status_reason__c='New Unassigned';
        cs.Subject ='XYZ';
        cs.Description='Xyz Description';
        insert cs;
        
        csAssetJunc = new Multiple_Assets_Case_Junction__c(Asset__c=asst.id,Case__c=cs.id);
        insert csAssetJunc;
    }   
    
    private static testmethod void testRelatedCases(){
        
        setUpData();
        Test.startTest();
            CaseRelatedListOnAssetController cont = new CaseRelatedListOnAssetController(new Apexpages.StandardController(asst));
            List<Case> csList = cont.getRelatedCases();
            System.assertEquals(csList.size(),1);
        Test.stopTest();
        
    }   

}