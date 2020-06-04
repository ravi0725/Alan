@isTest
public class EntitlementHelperTest{
    
    private static Customer_Event__c custEvt;
    private static Country_Region_Mapping__c cust;
    private static Geospatial_Country_Region_Mapping__c custRegMap ;
    private static Account acct;
    private static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    private static Entitlement ent;
    private static Set<Id> entSet = new Set<Id>();
    private static User apiUser;
    private static Profile prf = [Select Id from Profile where Name =: Label.API_Only];
      
    static void setUpData(){
        
        cust = new Country_Region_Mapping__c(name='India',Region__c='India');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='India',Region__c='India');
        insert custRegMap;
        
        //thisUser = [select Id from User where Id = :UserInfo.getUserId()];
        
        acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
            BillingCountry = 'India',BillingCity = 'Pune',BillingStreet = 'A-202' );
        insert acct;
        
        apiUser = new User(ProfileId = prf.Id,Username = System.now().millisecond() + 'trimbleuattest2@test.com',
                Alias = 'Test', Email='test@test.com',EmailEncodingKey='UTF-8', Firstname='Test',Lastname='Suite',LanguageLocaleKey='en_US',
                LocaleSidKey='en_US',TimeZoneSidKey='America/Chicago',Country='India');
        
        System.runAs(apiUser){
            ent = new Entitlement(name='Test', AccountId=acct.Id,supported_Product_Family_Roll_up__c='CAD Software');
            insert ent;
        }        
        
        
        entSet.add(ent.Id);
        
    }

    private static testmethod void testprocessEntitlements(){
            setUpData();
            Test.startTest();                    
                
                EntitlementHelper.processEntitlements(entSet);
                update ent;
            Test.stopTest();        
    }   
}