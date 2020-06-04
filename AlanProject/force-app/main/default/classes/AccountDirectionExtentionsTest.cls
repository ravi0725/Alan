@istest
private class AccountDirectionExtentionsTest
{
    public static Country_Region_Mapping__c cust;
    public static Geospatial_Country_Region_Mapping__c custRegMap ;
    public static Account objAccount;
    public static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    public static Account getAccountRecord()
    {
        if(objAccount == null)
        {
            cust = new Country_Region_Mapping__c(name='India',Region__c='India');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='India',Region__c='India');
        insert custRegMap;
        
            objAccount = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer', BillingCountry = 'India',BillingCity = 'Pune',BillingStreet = 'A-202' ,FCH_Party_ID__c='100',Phone='111-111-1111',BillingState='Goa',
            BillingPostalCode ='343220');
                        
            insert objAccount;
        }
        
        return objAccount;
    }
    
    
    
    public static testmethod void testAccountDirectionNonCommunityUsers()
    {
        objAccount = getAccountRecord();
        Test.startTest();
        
        User objUser = [select id, name, profileid, profile.name from user where profile.name != 'RE&WS - Customer Portal' and isActive = true limit 1];
        system.runas(objUser)
        {
            ApexPages.StandardController controller = new ApexPages.StandardController(objAccount);
            
            AccountDirectionExtentions objAccountDirectionExtentions = new AccountDirectionExtentions(controller);
            
            PageReference objPageReference = objAccountDirectionExtentions.AccountDirectionSet();
            String strURL = objPageReference.getURL();
            
            String strExpectedURL = 'apex/AccountOverride?id='+objAccount.id+'&sfdc.override=1';
            system.assert(true,strURL.contains(strExpectedURL));
        }
        Test.stopTest();
    }
    
    static testmethod void testAccountDirectionCommunityUsers()
    {
        objAccount = getAccountRecord();
        Test.startTest();
        
        User objUser = [select id, name, profileid, profile.name from user where profile.name = 'RE&WS - Customer Portal' and isActive = true limit 1];
        system.runas(objUser)
        {
            ApexPages.StandardController controller = new ApexPages.StandardController(objAccount);
            
            AccountDirectionExtentions objAccountDirectionExtentions = new AccountDirectionExtentions(controller);
            
            PageReference objPageReference = objAccountDirectionExtentions.AccountDirectionSet();
            String strURL = objPageReference.getURL();
            
            String strExpectedURL = '/apex/AccountOverride?id='+objAccount.id+'&sfdc.override=1';
            system.assert(true,strURL.contains(strExpectedURL));
        }
        Test.stopTest();
    }
    
}