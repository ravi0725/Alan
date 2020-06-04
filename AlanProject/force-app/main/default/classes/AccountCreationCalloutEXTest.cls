@isTest
private class AccountCreationCalloutEXTest{
    
    private static list<id> accountlst = new list<id>();
    private static Country_Region_Mapping__c cust;
    private static Geospatial_Country_Region_Mapping__c custRegMap ;
    private static Account acct;
    private static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    private static User thisUser;
    static void setUpData(){
    	
        GenerateTestData.customSettingRds();
        GenerateTestData.createAccount();
        GenerateTestData.createAddress();
        GenerateTestData.createContact();
        
        accountlst.add(GenerateTestData.acct.Id);
    }
    
    private static testmethod void testDeleteOSR(){
        setUpData();
        Test.startTest(); 
        AccountCreationCalloutEX.CallEBS(accountlst,'Update','Update','Update',new set<String>{GenerateTestData.ct.Id},new set<String>{GenerateTestData.adrs.Id},new set<String>()); 
        	AccountCreationCalloutEX.CallEBS(accountlst,'DLink','','',new set<String>(),new set<String>(),new set<String>()); 
        	AccountCreationCalloutEX.dLinkAccount(accountlst.get(0));
        Test.stopTest();
    } 
}