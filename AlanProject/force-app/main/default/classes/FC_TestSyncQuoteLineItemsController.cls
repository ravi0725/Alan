@isTest(seeAlldata=true)
private class FC_TestSyncQuoteLineItemsController {
    static testMethod void testMeth1() {
    	GenerateTestData.createAccount();
        GenerateTestData.createAddress();
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();
        GenerateTestData.createProposal();
        
        Apttus__APTS_Agreement__c apg = new Apttus__APTS_Agreement__c();
        apg.Fusion_Project_Number__c = 'test';        
        apg.Apttus__Contract_Start_Date__c = date.today();
        apg.Apttus__Contract_End_Date__c = date.today() + 5;        
        apg.ProServ_Type__c = 'Fixed Fee';
        apg.Credit_Status__c = 'test';
        apg.Credit_Approved__c = 'test Credit_Approved__c';
        apg.CREDIT_LIMIT_AVAILABLE__C = 10;
        apg.CREDIT_EXISTING_EXPOSURE__C = 10;
        apg.CREDIT_CALCULATED_EXPOSURE__c = 10; 
        apg.CREDIT_TOTAL_EXPOSURE__c = 10;        
        apg.Fusion_Project_Number__c = 'test Fusion_Project_Number__c'; 
        apg.Apttus_QPComply__RelatedProposalId__c = GenerateTestData.proposal.Id;
        apg.Apttus__Status_Category__c = 'Request';
        apg.Apttus__Status__c='Activated';
        apg.Apttus_CMConfig__PriceListId__c = GenerateTestData.pricelist.Id;
        apg.RecordTypeId = Schema.getGlobalDescribe().get('Apttus__APTS_Agreement__c').getDescribe().getRecordTypeInfosByName().get('SOW Only').getRecordTypeId();
        insert apg;
        
        FC_SyncQuoteLineItemsController temp = new FC_SyncQuoteLineItemsController(new ApexPages.StandardController(GenerateTestData.proposal));
        ApexPages.currentPage().getParameters().put('agreementId', apg.Id);
        temp.selectAgreement();
        temp.syncLineItems();
    }
    
  /*  static testMethod void testSync() {
        setup();
        Apttus_Proposal__Proposal__c proposal = [select Id from Apttus_Proposal__Proposal__c limit 1];
        Apttus_Proposal__Proposal_Line_Item__c[] proposalLineItems = new List<Apttus_Proposal__Proposal_Line_Item__c>();
        for (Integer i = 0; i < 3; i++) {
            proposalLineItems.add(new Apttus_Proposal__Proposal_Line_Item__c(
                Apttus_Proposal__Description__c = 'line item descr ' + i,
                Apttus_Proposal__Proposal__c = proposal.Id,
                Apttus_QPConfig__BasePriceMethod__c = 'Per Unit',
                Apttus_QPConfig__ExtendedPrice__c = 100,
                Apttus_QPConfig__Frequency__c = 'One Time',
                Apttus_QPConfig__ItemSequence__c = i,
                Apttus_QPConfig__LineNumber__c = i,
                Apttus_QPConfig__LineStatus__c = 'New',
                Apttus_QPConfig__LineType__c = 'Product/Service',
                Apttus_QPConfig__ListPrice__c = 0,
                Apttus_QPConfig__NetPrice__c = 200));
        }
        insert proposalLineItems;
        
        Apttus__APTS_Agreement__c agreement = [select Id from Apttus__APTS_Agreement__c where Apttus_QPComply__RelatedProposalId__c = :proposal.Id limit 1];
        Test.startTest();
        FC_SyncQuoteLineItemsController controller = new FC_SyncQuoteLineItemsController(new ApexPages.StandardController(proposal));
        ApexPages.currentPage().getParameters().put('agreementId', agreement.Id);
        controller.selectAgreement();
        controller.syncLineItems();
        Test.stopTest();
        
        Apttus__AgreementLineItem__c[] agreementLineItems = [select Apttus__ExtendedPrice__c, Apttus__NetPrice__c 
            from Apttus__AgreementLineItem__c where Apttus__AgreementId__c = :agreement.Id];
        
        System.assertEquals(3, agreementLineItems.size());
        for (Apttus__AgreementLineItem__c agreementLineItem : agreementLineItems) {
            System.assertEquals(100, agreementLineItem.Apttus__ExtendedPrice__c);
            System.assertEquals(200, agreementLineItem.Apttus__NetPrice__c);
        }

    }
    
    private static void setup() {
        FC_TestDataGenerator.insertSetupData();
        
        // create accounts
        Account[] accounts = FC_TestDataGenerator.generateAccounts();
        insert accounts;
        Contact[] contacts = FC_TestDataGenerator.generateContacts(accounts);
        insert contacts;
        Apttus_Config2__PriceList__c priceList = FC_TestDataGenerator.generatePriceList();
        insert priceList;
        Opportunity[] opportunities = FC_TestDataGenerator.generateOpportunities(accounts);
        insert opportunities;
        Apttus_Proposal__Proposal__c[] proposals = FC_TestDataGenerator.generateProposals(opportunities, priceList);
        insert proposals;
        insert FC_TestDataGenerator.generateAgreements(rt, proposals);
        
    }*/
}