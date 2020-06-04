/**
 * Company     : Trimble Software Technology Pvt Ltd.,
 * Description : 
 * History     :  

 * [30.4.2015] Suresh Babu  Created
*/
@isTest
public class TestConsoleCTIClasses {
    private static Customer_Event__c custEvt;
    private static Country_Region_Mapping__c cust;
    private static Geospatial_Country_Region_Mapping__c custRegMap ;
    private static Account acct;
    private static Contact ct;
    private static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    private static Entitlement ent;
    private static Case pcs;
    private static User apiUser;
    private static Profile prf = [Select Id from Profile where Name =: Label.API_Only];
    private static Integer count=0;
    private static Asset asst;
    static void setUpData(){
        
        cust = new Country_Region_Mapping__c(name='India',Region__c='India');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='India',Region__c='India');
        insert custRegMap;
        
        //thisUser = [select Id from User where Id = :UserInfo.getUserId()];
        
        acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
            BillingCountry = 'India',BillingCity = 'Pune',BillingStreet = 'A-202', Phone = '(408) 481-6246' );
        insert acct;
        
        ct = new Contact();
        ct.LastName = 'Test last name';
        ct.AccountId = acct.Id;
        ct.Phone = '(408) 481-6246';
        ct.Preferred_Language__c = 'American English';
        ct.Email = 'test@gmail.com';
        ct.MailingStreet='test1';
        ct.Mailingcity='testcity';
        ct.MailingState='teststate';
        ct.MailingPostalCode ='12345';
        ct.MailingCountry = 'India';
        insert ct;
        
        asst = new Asset();
        asst.AccountId = acct.Id;
        asst.Asset_Oracle_ID__c = '391G';
        asst.Name = 'WinEst';
        asst.Available_Quantity__c = 2;
        asst.Quantity_To_be_Upgraded__c=2;
        asst.Reason_Code__c ='Upgrade';
        insert asst;
        
        pcs = new Case();
        pcs.AccountId = acct.Id;
        pcs.ContactId = ct.Id; 
        pcs.Status = 'New';
        pcs.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('GCCM - Support Case Record Type').getRecordTypeId();        
        insert pcs;
        
        apiUser = new User(ProfileId = prf.Id,Username = 'test' + (count++) + System.now().millisecond() + 'test@test.com',
                Alias = 'Test', Email='test@test.com',EmailEncodingKey='UTF-8', Firstname='Test-1',Lastname='Suite-1',LanguageLocaleKey='en_US',
                LocaleSidKey='en_US',TimeZoneSidKey='America/Chicago',Country='India');
        
        
        System.runAs(apiUser){
            
            
            ent = new Entitlement(name='Test',AssetId = asst.Id, AccountId=acct.Id,supported_Product_Family_Roll_up__c='CAD Software');
            insert ent;
        }
    }
    
    private static testmethod void TestConsoleCTINoMatchController(){
        ConsoleCTINoMatchController temp = new ConsoleCTINoMatchController();
        
        String DataJS1 = '{"id":"203410237420160519","isConnected":"false","state":"Alerting","direction":"inbound","name":"Sunnyvale CA","interactionType":"Call","number":"1 (408) 481-6246"}';
        ConsoleCTINoMatchController.CreateTAPCase(DataJS1);
        ConsoleCTINoMatchController.CreateTAPCase(DataJS1);
        ConsoleCTINoMatchController.callData callObj = new ConsoleCTINoMatchController.callData();
        callObj.ANI = '';
        callObj.direction = '';
        callObj.interactionType = '';
        callObj.isConnected = '';
        callObj.name = '';
        callObj.PHNumber = '';
        callObj.state = '';
        
    }
    
    private static testmethod void TestConsoleCTIInboundController(){
        setUpData();
        system.Test.startTest();
        ApexPages.currentPage().getParameters().put('nonce', 'e98bff04408d1239da44334b0d0296da3f9b9bbbb1441b5ffd8c4db3d97950ba');
        ConsoleCTIInboundController ctrl = new ConsoleCTIInboundController();
        
        List<Id> fixedSearchResults = new List<Id>();
        fixedSearchResults.add(ct.Id);
        system.Test.setFixedSearchResults(fixedSearchResults);        
        String DataJS = ConsoleCTIInboundController.returnAccountId('{"id":"203410237420160519","isConnected":"false","state":"Alerting","direction":"inbound","name":"Sunnyvale CA","interactionType":"Call","number":"1 (408) 481-6246"}');
        
        fixedSearchResults.clear();
        fixedSearchResults.add(acct.Id);        
        system.Test.setFixedSearchResults(fixedSearchResults);        
        String DataJS1 = ConsoleCTIInboundController.returnAccountId('{"id":"203410237420160519","isConnected":"false","state":"Alerting","direction":"inbound","name":"Sunnyvale CA","interactionType":"Call","number":"1 (408) 481-6246"}');
        
        ctrl.retrieveEntitlements();
        ctrl.rAccId = acct.Id;
        ctrl.retrieveEntitlements();
        
        ConsoleCTIInboundController.inputCallInfo.ANI = '12345';
        ConsoleCTIInboundController.inputCallInfo.isConnected = ' 1234';
        ConsoleCTIInboundController.inputCallInfo.state = ' 1234';
        ConsoleCTIInboundController.inputCallInfo.direction = ' 1234';
        ConsoleCTIInboundController.inputCallInfo.name = ' 1234';
        ConsoleCTIInboundController.inputCallInfo.interactionType = ' 1234';
        ConsoleCTIInboundController.inputCallInfo.PHNumber = ' 1234';
        ConsoleCTIInboundController.CreateTAPCase(acct.Id,ct.Id,'203410237420160519');
        system.Test.stopTest();
    }
    
    private static testmethod void TestConsoleCTISingleMatchCls(){
        setUpData();
        system.Test.startTest();
        
        ConsoleCTISingleMatchCls sCtrl = new ConsoleCTISingleMatchCls();
        List<Id> fixedSearchResults = new List<Id>();
        fixedSearchResults.add(ct.Id);
        system.Test.setFixedSearchResults(fixedSearchResults);        
        String DataJS = ConsoleCTISingleMatchCls.returnAccountId('{"id":"203410237420160519","isConnected":"false","state":"Alerting","direction":"inbound","name":"Sunnyvale CA","interactionType":"Call","number":"1 (408) 481-6246"}');
        
        ConsoleCTISingleMatchCls.inputCallInfo.ANI = '12345';
        ConsoleCTISingleMatchCls.inputCallInfo.isConnected = ' 1234';
        ConsoleCTISingleMatchCls.inputCallInfo.state = ' 1234';
        ConsoleCTISingleMatchCls.inputCallInfo.direction = ' 1234';
        ConsoleCTISingleMatchCls.inputCallInfo.name = ' 1234';
        ConsoleCTISingleMatchCls.inputCallInfo.interactionType = ' 1234';
        ConsoleCTISingleMatchCls.inputCallInfo.PHNumber = ' 1234';
        
        system.Test.stopTest();
    }
    
    private static testmethod void TestConsoleCTIMultipleMatchCtrl(){
        setUpData();
        system.Test.startTest();
        ApexPages.currentPage().getParameters().put('nonce', 'e98bff04408d1239da44334b0d0296da3f9b9bbbb1441b5ffd8c4db3d97950ba');
        ConsoleCTIMultipleMatchCtrl mCtrl = new ConsoleCTIMultipleMatchCtrl();
        
        mCtrl.jsonCallData = '{"id":"203410237420160519","isConnected":"false","state":"Alerting","direction":"inbound","name":"Sunnyvale CA","interactionType":"Call","number":"1 (408) 481-6246"}';
        
        List<Id> fixedSearchResults = new List<Id>();
        fixedSearchResults.add(ct.Id);
        fixedSearchResults.add(acct.Id);
        system.Test.setFixedSearchResults(fixedSearchResults);
        mCtrl.returnAccountId();
        
        fixedSearchResults.clear();
        fixedSearchResults.add(ct.Id);
        system.Test.setFixedSearchResults(fixedSearchResults);
        mCtrl.returnAccountId();
        
        mCtrl.showPopup();
        mCtrl.closePopup();
        
        mCtrl.inputCallInfo.ANI = '12345';
        mCtrl.inputCallInfo.isConnected = ' 1234';
        mCtrl.inputCallInfo.state = ' 1234';
        mCtrl.inputCallInfo.direction = ' 1234';
        mCtrl.inputCallInfo.name = ' 1234';
        mCtrl.inputCallInfo.interactionType = ' 1234';
        mCtrl.inputCallInfo.PHNumber = ' 1234';
        
        ConsoleCTIMultipleMatchCtrl.contactWrapper temp = new ConsoleCTIMultipleMatchCtrl.contactWrapper();
        temp.cCont = new Contact();
        temp.entId = null;
        temp.entAccId = null;
        temp.entAstId = null;
        temp.entPGroup = '';
        
               
        String DataJS = ConsoleCTIMultipleMatchCtrl.returnTAPCaseId('{"id":"203410237420160519","isConnected":"false","state":"Alerting","direction":"inbound","name":"Sunnyvale CA","interactionType":"Call","number":"1 (408) 481-6246"}');
        DataJS = ConsoleCTIMultipleMatchCtrl.returnTAPCaseId('{"id":"203410237420160519","isConnected":"false","state":"Alerting","direction":"inbound","name":"Sunnyvale CA","interactionType":"Call","number":"1 (408) 481-6246"}');
        
        String ContId =  temp.cCont.Id;
        String AccId =  temp.entAccId;
        ConsoleCTIMultipleMatchCtrl.updateTAPCase(DataJs, AccId, ContId);
               
        system.Test.stopTest();
    }
}