/*
*****************************************************************************************
    Name        : trimblecorpComTnvcussfdcoutbound_v4Test 
                            
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
 P M Mamata           19/07/2015          Created
*****************************************************************************************
*/

@isTest(seealldata=true)
private class AddressHandlerTest{
	static testmethod void testaddressHandler1(){
        AddressHandler ah = new AddressHandler();
        List<Address__c> acLst = new List<Address__c>(); 
        Map<Id,Address__c> adrMap = new Map<Id,Address__c>();
        GenerateTestData.createAccount();
        GenerateTestData.createAddress();          
        acLst.add(GenerateTestData.adrs);    
        adrMap.put(GenerateTestData.adrs.Id,GenerateTestData.adrs);
        AddressHandler.configOutboundMessage(acLst,adrMap,adrMap,true,false,false);
    }
    
    static testmethod void testaddressHandler2(){
        AddressHandler ah = new AddressHandler();
        List<Address__c> acLst = new List<Address__c>(); 
        Map<Id,Address__c> adrMap = new Map<Id,Address__c>();
        GenerateTestData.createAccount();
        AccountCreationCalloutEX.recursiveCallFlag = false;
        GenerateTestData.createAddress();          
        acLst.add(GenerateTestData.adrs);    
        adrMap.put(GenerateTestData.adrs.Id,GenerateTestData.adrs);
        AddressHandler.configOutboundMessage(acLst,adrMap,adrMap,true,false,false);
    }
    static testmethod void testaddressHandler3(){
        AddressHandler ah = new AddressHandler();
        //GenerateTestData.createAccount();
        Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
        Account acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,Account_Status__c = 'Active',Requested_Account_Record_Type__c = 'Customer',
            BillingCountry = 'United States',BillingCity = 'Pune',BillingStreet = 'A-202',Collector_Email__c = 'test@gmail.com',Lifecycle_Stage__c = 'Customer');
        insert acct;
        AccountCreationCalloutEX.recursiveCallFlag = false;
        Address__c adrs = new Address__c(Name = 'Test Address',Account__c = acct.Id, Country__c = 'UNITED STATES',Bill_To__c = true,Ship_To__c=true);
        insert adrs;       
        List<Address__c> acLst = new List<Address__c>(); 
        Map<Id,Address__c> adrMap = new Map<Id,Address__c>();
        adrMap.put(adrs.Id,adrs);
        acLst.add(adrs);              
        AddressHandler.configOutboundMessage(acLst,adrMap,adrMap,true,false,false);
        AddressHandler.setAddressName(acLst);
    }
    
    static testmethod void testaddressHandler4(){
        AddressHandler ah = new AddressHandler();
        //GenerateTestData.createAccount();
        Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
        Account acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,Account_Status__c = 'Active',Requested_Account_Record_Type__c = 'Customer',
            BillingCountry = 'United States',BillingCity = 'Pune',BillingStreet = 'A-202',Collector_Email__c = 'test@gmail.com',Lifecycle_Stage__c = 'Customer');
        insert acct;
        Address__c adrs = new Address__c(Name = 'Test Address',Account__c = acct.Id, Country__c = 'UNITED STATES',Bill_To__c = true,Ship_To__c=true);
        insert adrs;       
        List<Address__c> acLst = new List<Address__c>(); 
        Map<Id,Address__c> adrMap = new Map<Id,Address__c>();
        adrMap.put(adrs.Id,adrs);
        adrs.FCH_Party_Site_ID__c = '12345676567';
        acLst.add(adrs);              
        AddressHandler.configOutboundMessage(acLst,adrMap,adrMap,true,false,false);
        AddressHandler.resetStatusFlag(adrMap,adrMap);
        AddressHandler.setAddressName(acLst);
        AddressHandler.setLaunchControl();
        AddressHandler.validateAddressExternalKeyValue(acLst,adrMap);
    }
    

}