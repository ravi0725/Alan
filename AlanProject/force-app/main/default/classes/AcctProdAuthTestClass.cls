/************************************************************************************
* Name          :    AcctProdAuthTestClass
* Description   :    
* Author        :    Ashfaq

Modification Log
----------------
Date             Developer                Comments
------------------------------------------------------------------------------------------
10/3/2013                   Ashfaq                  Created
*/

@isTest
public  class AcctProdAuthTestClass {

   private static Country_Region_Mapping__c cust;
   private static Geospatial_Country_Region_Mapping__c custRegMap ;
    
static testMethod void testSaveMethod() {
    
    cust = new Country_Region_Mapping__c(name='India',Region__c='India');
    insert cust;
        
    custRegMap = new Geospatial_Country_Region_Mapping__c(name='India',Region__c='India');
    insert custRegMap;
        
    Account acc = new Account(Name = 'test Account',BillingCountry = 'India',BillingCity = 'Pune',BillingStreet = 'A-202');
    insert acc;
    
    Account accvar = new Account(Name = 'Account test',BillingCountry = 'India',BillingCity = 'Pune',BillingStreet = 'A-202');
    insert accvar;
    
    Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
      User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
      LocaleSidKey='en_US', ProfileId = p.Id, 
      TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com',Country='India');
    
    Account_Product_Authorization__c APVar = new Account_Product_Authorization__c(Account__c = acc.id,user__c=userinfo.getuserid(),Product_Authorization__c='Prolog');
    insert APVar;
    Account_Product_Authorization__c NewAPVar = new Account_Product_Authorization__c(Account__c = acc.id,user__c=userinfo.getuserid(),Product_Authorization__c='Prolog');
    insert NewAPVar;
    Account_Product_Authorization__c NewAPVar1 = new Account_Product_Authorization__c(Account__c = accvar.id,user__c=u.id,Product_Authorization__c='Prolog');
    insert NewAPVar1;
    
    list<Account_Product_Authorization__c> li = new list<Account_Product_Authorization__c>();
    li.add(APvar);
    //li.add(NewAPvar);
    //li.add(NewAPvar1);
    test.starttest();
    
    ApexPages.StandardSetController sc = new ApexPages.StandardSetController(li);
    AccountProductAuthorizationController APAuthVar = new AccountProductAuthorizationController(sc);    
    
    APAuthVar.authorizationList.add(APVar);
    APAuthVar.authorizationList.add(NewAPVar);
    ApexPages.CurrentPage().getParameters().put('id',acc.id); 
    APAuthVar.AccountID = acc.id;
    APAuthVar.save();
    APAuthVar.saveMore();
    APAuthVar.cancel();
    
    APAuthVar.authorizationList.clear();
    APAuthVar.authorizationList.add(APVar);
    APAuthVar.authorizationList.add(NewAPVar1);    
    APAuthVar.save();
    APAuthVar.saveMore();
    
    
    APAuthVar.authorizationList.clear();
    APAuthVar.authorizationList.add(NewAPVar1);        
    APAuthVar.save();    
    APAuthVar.saveMore();
    
    test.stoptest();
}
}