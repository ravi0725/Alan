@isTest 
private class Test_UtilitySchedulableClass {

    private static Country_Region_Mapping__c cust;
    private static Geospatial_Country_Region_Mapping__c custRegMap ;
    public static UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
    
    static testMethod void testUtilitySchedulableClassmethod() {
    
       cust = new Country_Region_Mapping__c(name='India',Region__c='India');
       insert cust;
        
       custRegMap = new Geospatial_Country_Region_Mapping__c(name='India',Region__c='India');
       insert custRegMap; 
       
       Test.startTest();
       Profile profile = [select Id from Profile where Name =: 'System Administrator'];
    
        User user = new User();
        user.Username = 'sagamehta123@deloitte.com';
        user.UserRoleId = portalRole.Id;
        user.Email = 'sagamehta@deloitte.com';
        user.LastName = 'Test';
        user.Alias = 'Test123';
        user.ProfileID = profile.Id;
        user.LocaleSidKey = 'en_US';
        user.LanguageLocaleKey = 'en_US';
        user.Country = 'India';
        user.Division__c = 'Infrastructure';
        user.TimeZoneSidKey = 'America/Los_Angeles';
        user.EmailEncodingKey='UTF-8';
        //insert user;
        //System.runAs(user){
           User user1 = [Select Id from User where isActive = true and UserRoleId != null and ProfileId =: profile.Id limit 1];
           Profile partnerProfile = [select Id from Profile where Name = 'Trimble Standard Partner Portal User'];
           
           Account account = new Account();
           account.Name = 'Test Account';
           //account.OwnerId = user1.Id;
           account.BillingCountry = 'India';
           account.BillingCity = 'Pune';
           account.BillingStreet = 'A-202';
           
           insert account;
           
           Contact contact = new Contact();
           contact.FirstName = 'Test';
           contact.LastName = 'Test';
           contact.AccountId = account.Id;
           contact.MailingCountry ='India';
           
           insert contact;
           
           User pUser = new User();
           puser.Username = 'portal@deloitte.com';
           puser.Email = 'portal@deloitte.com';
           puser.LastName = 'Partner';
           puser.Alias = 'Test123';
           puser.ProfileID = partnerProfile.Id;
           puser.ContactId = contact.Id;
           puser.LocaleSidKey = 'en_US';
           puser.LanguageLocaleKey = 'en_US';
           puser.Country = 'India';
           puser.Division__c = 'Infrastructure';
           puser.TimeZoneSidKey = 'America/Los_Angeles';
           puser.EmailEncodingKey='UTF-8';
           //insert puser;
           
           RecordType recordType = [SELECT Id FROM RecordType WHERE DeveloperName =: Label.Lead_Accept_Reject_Record_Type];
                        
           Lead leadvar = new Lead(LastName = 'Test Lead',company='test company',isPartnerReject__c=false, Lead_Accept_TimeStamp__c = DateTime.newInstance(System.now().year(), System.now().month(), System.now().day(), System.now().hour(), 0, 0) ,  RecordTypeId = recordType.Id,Country='India');   
           insert leadvar;        
                      
           Lead newleadvar = new Lead(LastName = 'Lead Test',company='test company1',isPartnerReject__c=false, Lead_Accept_TimeStamp__c = DateTime.newInstance(System.now().year(), System.now().month(), System.now().day(), System.now().hour(), 0, 0) , RecordTypeId = recordType.Id,Country='India');                           
           insert newleadvar;
           
           UtilitySchedulableClass UtScVar = new UtilitySchedulableClass();
           String sch = '0 0 1 * * ?';
           system.schedule('Test Utility Schedulable class',sch,UtScVar);                              
        //}
        Test.stopTest();
    }
}