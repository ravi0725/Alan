@isTest (seealldata=true)
private class OppOrderHelperTest {
    private static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Customer) Record Type').getRecordTypeId();
    
    static testMethod void testData() {
        /* OppOrderHelper.testCase = 'TestCase1';  */
        User adminUser = [select Id from User where CommunityNickname = 'Srinivasan_Babu' limit 1];
        
        System.runAs(adminUser){
            Apttus_Config2__PriceList__c pricelist = new Apttus_Config2__PriceList__c();
            pricelist.Apttus_Config2__Active__c = true;
            pricelist.Name = 'TIBV DE Test';
            pricelist.Legal_Entity__c = 'TIBV SWISS BRANCH';
            pricelist.Business_Area__c = 'MANHATTAN SOFTWARE';
            pricelist.Division__c='GCCM';
			insert pricelist;
            
            Account acct = new Account(
                Name = 'Test Account',
                RecordTypeId = acctRecTypeId,
                BillingCountry = 'United States',
                BillingCity = 'New York',
                BillingStreet = 'A-202',
                Lifecycle_Stage__c='Customer',
                Account_Status__c = 'Active',
                currencyisocode ='USD',
            	Restricted_Entity__c = 'Not Restricted',
                Account_Division__c = 'MEP NA'
             	);
           insert acct;
            
            Contact cont = new Contact(
                lastname = 'test contact',
                accountId = acct.Id,
                Preferred_Name__c = 'American English',
                MailingCountry = 'United States'
                );
            insert cont;
            /*
            Address__c addr = new Address__c(
            	Name =   'Grupo Serex',
                Country__c = 'United States',
                CurrencyIsoCode = 'USD',
                Activation_Email__c = TRUE,
            	Active__c = TRUE,
                Bill_To__c = TRUE,
            	Primary__c = TRUE,
                Sell_To__c = TRUE,
                Ship_To__c = TRUE
            	);
            insert addr;  
            */
            
            Product2 prod = new  Product2(
                Name = 'Prod 1',
                ProductCode = 'SUB-ANY-EST-PRO-D',
                CurrencyIsoCode = 'USD'
            	);
            insert prod;
            
            Id pricebookId = Test.getStandardPricebookId();    
                
            PricebookEntry pbe = new  PricebookEntry(
                Pricebook2Id = pricebookId,
                Product2Id = prod.Id,
                UnitPrice = 0.0,
                CurrencyIsoCode = 'USD',
                isActive = TRUE
            	);
            insert pbe;
            
            Opportunity opp = new Opportunity(
                Accubid_Email_Alert__c = false,
                MEPNA_Submit_for_Order_Audit__c = true,
                Name = 'TestOpp',
                CloseDate = date.parse('12/27/2019'),
                Pricebook2Id = pricebookId,
                StageName = '6 - Closed Won'
            	);
            insert opp;
            
            
        }    
    }
}