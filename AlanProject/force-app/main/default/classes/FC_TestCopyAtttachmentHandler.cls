@isTest(SeeAllData = true)
public class FC_TestCopyAtttachmentHandler{
    static testMethod void TestCopyAtttachmentHandler() {
        system.Test.startTest();
        
        Account acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId(),CurrencyIsoCode = 'USD',Payment_Term__c = 'CASH IN ADVANCE', Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
            BillingCountry = 'United States',Restricted_Entity__c = Label.Not_Restricted,Annual_Support_Date__c = date.today(), BillingCity = 'Pune',BillingState = 'BillingState', BillingPostalCode = 'postal code',BillingStreet = 'A-202',Collector_Email__c = 'test@gmail.com');
        insert acct;
        
        Opportunity o = new Opportunity(Name = 'Test Opp', AccountId = acct.Id, CloseDate = system.today(), StageName = 'Closed Won');
        insert o;
        
        Apttus__APTS_Agreement__c agg = new Apttus__APTS_Agreement__c(Apttus__Related_Opportunity__c = o.id);
        insert agg;
        
        Attachment att = new Attachment(Name = 'test', body = Blob.valueOf('Attachment Body'), ParentId = agg.Id);
        insert att;
        
        system.Test.stopTest();
    }
}