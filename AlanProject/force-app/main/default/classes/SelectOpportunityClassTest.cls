//27/3/2015 -Divya: Changed the Product_Family__c to Opportunity_Product__c at line 54 and 68
/*
****************************************************************************************
Name Controller        : SelectOpportunityClassTest 
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
P M Mamata           23/08/2015          Modified
*****************************************************************************************
*/

@isTest(seealldata=true)
Private class SelectOpportunityClassTest{
    
    
    static testmethod void meth1(){
        GenerateTestData.createAccount();
        GenerateTestData.createAddress();
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();
        GenerateTestData.createContact();
        system.currentPageReference().getParameters().put('annualSupportMonth', '03'); 
        system.currentPageReference().getParameters().put('id', GenerateTestData.acct.Id);  
        SelectOpportunityClass soc = new SelectOpportunityClass(new ApexPages.StandardController(GenerateTestData.acct));
        soc.billToContactId = GenerateTestData.ct.Id;
        soc.shipToContactId = GenerateTestData.ct.Id;
        soc.getShipToAddress();
        soc.getBillToContact();
        soc.getShipToContact();
        soc.invalidEntry = false;
        soc.initializeOptyRecords();
        soc.getBillToAddress();
    }
    
    static testmethod void meth2(){
        GenerateTestData.createAccount();
        GenerateTestData.createAddress();
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();
        GenerateTestData.createContact();
        GenerateTestData.createProposal();
        system.currentPageReference().getParameters().put('annualSupportMonth', '03'); 
        system.currentPageReference().getParameters().put('annualSupportDay', '28'); 
        system.currentPageReference().getParameters().put('id', GenerateTestData.acct.Id);  
        SelectOpportunityClass soc = new SelectOpportunityClass(new ApexPages.StandardController(GenerateTestData.acct));
        soc.formatAddress(GenerateTestData.adrs);
        soc.createOpportunity();
        soc.opportunityId = GenerateTestData.opp.Id;
        soc.loadOptyDetail();
        soc.shipToAccount = 'Test Assign Case Account';
        soc.proposal.Bill_To_Address__c = GenerateTestData.adrs.Id;
        soc.loadAddress();
    }
    
    static testmethod void meth3(){
        GenerateTestData.createAccount();
        GenerateTestData.createAddress();
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();
        GenerateTestData.createContact();
        GenerateTestData.createProposal();
        system.currentPageReference().getParameters().put('annualSupportMonth', '03');
        system.currentPageReference().getParameters().put('annualSupportDay', '28'); 
        system.currentPageReference().getParameters().put('id', GenerateTestData.acct.Id);  
        SelectOpportunityClass soc = new SelectOpportunityClass(new ApexPages.StandardController(GenerateTestData.acct));
        soc.next();
        soc.cancel();
        soc.billtoid = GenerateTestData.acct.Id;
        soc.validateBillShipToAddress();
        soc.createQuote();
        soc.initializeOpportunity();
        soc.processQuote(GenerateTestData.opp.Id);
        soc.changeStageName();
        soc.changenewStageName();
        soc.closePopup();
        soc.showPopup();
        soc.opportunityId = GenerateTestData.opp.Id;
        soc.loadOptyDetail();
    }
    
    static testmethod void meth4(){
        GenerateTestData.createAccount();
        GenerateTestData.createAddress();
        GenerateTestData.createPriceList();        
        GenerateTestData.createContact();        
        system.currentPageReference().getParameters().put('annualSupportMonth', '03');
        system.currentPageReference().getParameters().put('annualSupportDay', '28'); 
        system.currentPageReference().getParameters().put('id', GenerateTestData.acct.Id);  
        SelectOpportunityClass soc = new SelectOpportunityClass(new ApexPages.StandardController(GenerateTestData.acct));
        
        Opportunity opp = new Opportunity();
        opp.AccountId = GenerateTestData.acct.Id;
        opp.StageName = 'Inquery';
        opp.Closedate = date.today() + 7;
        opp.Name = 'Opp1';
        opp.CurrencyISOCode = 'USD';
        opp.Price_List__c = GenerateTestData.pricelist.Id;
        //opp.Ship_To_Account__c = acct.ID;
        opp.Payment_Term__c = 'CASH IN ADVANCE';
        opp.OwnerId = UserInfo.getUserId();
        insert opp;
        soc.opportunityId = opp.Id;
        soc.loadOptyDetail();
    }
    
    static testmethod void meth5(){
        GenerateTestData.createAccount();
        GenerateTestData.createAddress();
        GenerateTestData.createPriceList();        
        GenerateTestData.createContact();        
        system.currentPageReference().getParameters().put('annualSupportMonth', '03');
        system.currentPageReference().getParameters().put('annualSupportDay', '28'); 
        system.currentPageReference().getParameters().put('id', GenerateTestData.acct.Id);  
        SelectOpportunityClass soc = new SelectOpportunityClass(new ApexPages.StandardController(GenerateTestData.acct));
        soc.billToAddressId = GenerateTestData.adrs.Id;
        soc.shipToAddressId = GenerateTestData.adrs.Id;
        
        soc.getBillToAddress();
        soc.getShipToAddress();
        
        Opportunity opp = new Opportunity();
        opp.AccountId = GenerateTestData.acct.Id;
        opp.StageName = 'Closed Won';
        opp.Probability= 100;
        opp.Closedate = date.today() + 7;
        opp.Name = 'Opp1';
        opp.CurrencyISOCode = 'USD';
        opp.Price_List__c = GenerateTestData.pricelist.Id;
        //opp.Ship_To_Account__c = acct.ID;
        opp.Payment_Term__c = 'CASH IN ADVANCE';
        opp.OwnerId = UserInfo.getUserId();
        insert opp;
        
        opp.StageName ='';
        //update opp;
        
        soc.changeStageName(); 
        soc.opportunityId = opp.Id;
        soc.next();
        soc.loadOptyDetail();
    }

    static testmethod void meth6(){
        Profile prof = [select Id from Profile where Name =: 'System Administrator'];
        User tUser = new User();
        tUser.Username = 'testuser@stestted.com';
        tUser.Email = 'testuser@stestted.com';
        tUser.LastName = 'Test';
        tUser.Alias = 'Test123d';
        tUser.ProfileID = prof.Id;
        tUser.LocaleSidKey = 'en_US';
        tUser.LanguageLocaleKey = 'en_US';
        tUser.Country = 'United States';
        tUser.TimeZoneSidKey = 'America/Los_Angeles';
        tUser.EmailEncodingKey='UTF-8';
        tUser.Division__c = 'MEP';
        Database.insert(tUser);
        
        GenerateTestData.createAccount();
        GenerateTestData.createAddress();
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();
        GenerateTestData.createContact();
        GenerateTestData.createProposal();
        
        RecursiveTriggerUtility.isAccountRecursive = FALSE;
        ImportDataController.importDataFlag = TRUE;
        GenerateTestData.acct.BillingCountry = 'Liechtenstein';
        update GenerateTestData.acct;

        GenerateTestData.adrs.Primary__c = TRUE;
        update GenerateTestData.adrs;

        System.runAs (tUser){
            system.currentPageReference().getParameters().put('annualSupportMonth', '03');
            system.currentPageReference().getParameters().put('annualSupportDay', '28'); 
            system.currentPageReference().getParameters().put('id', GenerateTestData.acct.Id);
            SelectOpportunityClass soc = new SelectOpportunityClass(new ApexPages.StandardController(GenerateTestData.acct));
            soc.initializeOpportunity();
        }
    }

    static testmethod void meth7(){
        Profile prof = [select Id from Profile where Name =: 'System Administrator'];
        User tUser = new User();
        tUser.Username = 'testuser@stestted.com';
        tUser.Email = 'testuser@stestted.com';
        tUser.LastName = 'Test';
        tUser.Alias = 'Test123d';
        tUser.ProfileID = prof.Id;
        tUser.LocaleSidKey = 'en_US';
        tUser.LanguageLocaleKey = 'en_US';
        tUser.Country = 'United States';
        tUser.TimeZoneSidKey = 'America/Los_Angeles';
        tUser.EmailEncodingKey='UTF-8';
        tUser.Division__c = 'MEP';
        Database.insert(tUser);
        
        GenerateTestData.createAccount();
        GenerateTestData.createAddress();
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();
        GenerateTestData.createContact();
        GenerateTestData.createProposal();
        
        RecursiveTriggerUtility.isAccountRecursive = FALSE;
        ImportDataController.importDataFlag = TRUE;
        GenerateTestData.acct.BillingCountry = 'Germany';
        update GenerateTestData.acct;

        GenerateTestData.adrs.Primary__c = TRUE;
        update GenerateTestData.adrs;

        System.runAs (tUser){
            system.currentPageReference().getParameters().put('annualSupportMonth', '03');
            system.currentPageReference().getParameters().put('annualSupportDay', '28'); 
            system.currentPageReference().getParameters().put('id', GenerateTestData.acct.Id);
            SelectOpportunityClass soc = new SelectOpportunityClass(new ApexPages.StandardController(GenerateTestData.acct));
            soc.initializeOpportunity();
        }
    }

    static testmethod void meth8(){
        Profile prof = [select Id from Profile where Name =: 'System Administrator'];
        User tUser = new User();
        tUser.Username = 'testuser@stestted.com';
        tUser.Email = 'testuser@stestted.com';
        tUser.LastName = 'Test';
        tUser.Alias = 'Test123d';
        tUser.ProfileID = prof.Id;
        tUser.LocaleSidKey = 'en_US';
        tUser.LanguageLocaleKey = 'en_US';
        tUser.Country = 'United States';
        tUser.TimeZoneSidKey = 'America/Los_Angeles';
        tUser.EmailEncodingKey='UTF-8';
        tUser.Division__c = 'MEP';
        Database.insert(tUser);
        
        GenerateTestData.createAccount();
        GenerateTestData.createAddress();
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();
        GenerateTestData.createContact();
        GenerateTestData.createProposal();
        
        RecursiveTriggerUtility.isAccountRecursive = FALSE;
        ImportDataController.importDataFlag = TRUE;
        GenerateTestData.acct.BillingCountry = 'France';
        update GenerateTestData.acct;

        GenerateTestData.adrs.Primary__c = TRUE;
        update GenerateTestData.adrs;

        System.runAs (tUser){
            system.currentPageReference().getParameters().put('annualSupportMonth', '03');
            system.currentPageReference().getParameters().put('annualSupportDay', '28'); 
            system.currentPageReference().getParameters().put('id', GenerateTestData.acct.Id);
            SelectOpportunityClass soc = new SelectOpportunityClass(new ApexPages.StandardController(GenerateTestData.acct));
            soc.initializeOpportunity();
        }
    }

    static testmethod void meth9(){
        Profile prof = [select Id from Profile where Name =: 'System Administrator'];
        User tUser = new User();
        tUser.Username = 'testuser@stestted.com';
        tUser.Email = 'testuser@stestted.com';
        tUser.LastName = 'Test';
        tUser.Alias = 'Test123d';
        tUser.ProfileID = prof.Id;
        tUser.LocaleSidKey = 'en_US';
        tUser.LanguageLocaleKey = 'en_US';
        tUser.Country = 'United States';
        tUser.TimeZoneSidKey = 'America/Los_Angeles';
        tUser.EmailEncodingKey='UTF-8';
        tUser.Division__c = 'MEP';
        Database.insert(tUser);
        
        GenerateTestData.createAccount();
        GenerateTestData.createAddress();
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();
        GenerateTestData.createContact();
        GenerateTestData.createProposal();
        
        RecursiveTriggerUtility.isAccountRecursive = FALSE;
        ImportDataController.importDataFlag = TRUE;
        GenerateTestData.acct.BillingCountry = 'Austria';
        update GenerateTestData.acct;

        GenerateTestData.adrs.Primary__c = TRUE;
        update GenerateTestData.adrs;

        System.runAs (tUser){
            system.currentPageReference().getParameters().put('annualSupportMonth', '03');
            system.currentPageReference().getParameters().put('annualSupportDay', '28'); 
            system.currentPageReference().getParameters().put('id', GenerateTestData.acct.Id);
            SelectOpportunityClass soc = new SelectOpportunityClass(new ApexPages.StandardController(GenerateTestData.acct));
            soc.initializeOpportunity();
        }
    }

    static testmethod void meth10(){
        Profile prof = [select Id from Profile where Name =: 'System Administrator'];
        User tUser = new User();
        tUser.Username = 'testuser@stestted.com';
        tUser.Email = 'testuser@stestted.com';
        tUser.LastName = 'Test';
        tUser.Alias = 'Test123d';
        tUser.ProfileID = prof.Id;
        tUser.LocaleSidKey = 'en_US';
        tUser.LanguageLocaleKey = 'en_US';
        tUser.Country = 'United States';
        tUser.TimeZoneSidKey = 'America/Los_Angeles';
        tUser.EmailEncodingKey='UTF-8';
        tUser.Division__c = 'MEP';
        Database.insert(tUser);
        
        GenerateTestData.createAccount();
        GenerateTestData.createAddress();
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();
        GenerateTestData.createContact();
        GenerateTestData.createProposal();
        
        RecursiveTriggerUtility.isAccountRecursive = FALSE;
        ImportDataController.importDataFlag = TRUE;
        GenerateTestData.acct.BillingCountry = 'United Kingdom';
        update GenerateTestData.acct;

        GenerateTestData.adrs.Primary__c = TRUE;
        update GenerateTestData.adrs;

        System.runAs (tUser){
            system.currentPageReference().getParameters().put('annualSupportMonth', '03');
            system.currentPageReference().getParameters().put('annualSupportDay', '28'); 
            system.currentPageReference().getParameters().put('id', GenerateTestData.acct.Id);
            SelectOpportunityClass soc = new SelectOpportunityClass(new ApexPages.StandardController(GenerateTestData.acct));
            soc.initializeOpportunity();
        }
    }

    static testmethod void meth11(){
        Profile prof = [select Id from Profile where Name =: 'System Administrator'];
        User tUser = new User();
        tUser.Username = 'testuser@stestted.com';
        tUser.Email = 'testuser@stestted.com';
        tUser.LastName = 'Test';
        tUser.Alias = 'Test123d';
        tUser.ProfileID = prof.Id;
        tUser.LocaleSidKey = 'en_US';
        tUser.LanguageLocaleKey = 'en_US';
        tUser.Country = 'United States';
        tUser.TimeZoneSidKey = 'America/Los_Angeles';
        tUser.EmailEncodingKey='UTF-8';
        tUser.Division__c = 'MEP';
        Database.insert(tUser);
        
        GenerateTestData.createAccount();
        GenerateTestData.createAddress();
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();
        GenerateTestData.createContact();
        GenerateTestData.createProposal();
        
        RecursiveTriggerUtility.isAccountRecursive = FALSE;
        ImportDataController.importDataFlag = TRUE;
        GenerateTestData.acct.BillingCountry = 'Greece';
        update GenerateTestData.acct;

        GenerateTestData.adrs.Primary__c = TRUE;
        update GenerateTestData.adrs;

        System.runAs (tUser){
            system.currentPageReference().getParameters().put('annualSupportMonth', '03');
            system.currentPageReference().getParameters().put('annualSupportDay', '28'); 
            system.currentPageReference().getParameters().put('id', GenerateTestData.acct.Id);
            SelectOpportunityClass soc = new SelectOpportunityClass(new ApexPages.StandardController(GenerateTestData.acct));
            soc.initializeOpportunity();
        }
    }
}