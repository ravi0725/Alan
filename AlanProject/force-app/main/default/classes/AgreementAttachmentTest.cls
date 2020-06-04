@isTest(seealldata=true)
private class AgreementAttachmentTest{
    
    static testmethod void meth1(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser09878987@testorg.com');
        
        System.runAs(u) {
            
            GenerateTestData.createAccount();
            GenerateTestData.createPriceList();
            GenerateTestData.createOtherPriceList();
            GenerateTestData.createOpportunity();      
            
            Apttus__APTS_Agreement__c apg;
            Attachment attachment;
            
            apg = new Apttus__APTS_Agreement__c();
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
            apg.Apttus__Status_Category__c = 'In Effect';
            apg.Apttus__Status__c='Activated';
            apg.Apttus__Related_Opportunity__c=GenerateTestData.opp.Id;
            insert apg;
            System.debug('==========agreement==============='+apg);
            
            attachment = new Attachment();
            attachment.Body = Blob.valueOf('Test');
            attachment.Name = String.valueOf('test1_test2_test3.txt');
            attachment.ParentId = apg.Id; 
            insert attachment;
            System.debug('==========attachment==============='+attachment);
            
        }
    }
    
    static testmethod void meth2(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser09878987@testorg.com');
        
        System.runAs(u) {
            
            GenerateTestData.createAccount();
            GenerateTestData.createAddress();
            GenerateTestData.createPriceList();
            GenerateTestData.createProduct2();
            GenerateTestData.createOpportunity(); 
            system.debug('>>>>createOpportunity>>>>'+GenerateTestData.opp.id);
            
            Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c();
            proposal.Apttus_Proposal__Account__c = GenerateTestData.acct.Id;
            proposal.Apttus_QPConfig__BillToAccountId__c = GenerateTestData.acct.id;
            proposal.Apttus_Proposal__Opportunity__c = GenerateTestData.opp.Id;
            proposal.Apttus_QPConfig__PriceListId__c = GenerateTestData.pricelist.Id;
            proposal.Ship_To_Account__c = GenerateTestData.acct.Id;
            proposal.Bill_to_Address__c  = GenerateTestData.adrs.Id;
            proposal.OwnerId = UserInfo.getUserId();
            proposal.Apttus_Proposal__Primary__c = true;
            proposal.Apttus_Proposal__Proposal_Name__c = 'TEST Proposal';
            insert proposal;
            
            Attachment attachment;
            
            Date sysDate = Date.newinstance(system.today().year(), system.today().month(), system.today().day());
            attachment = new Attachment();
            attachment.Body = Blob.valueOf('Test');
            attachment.Name = String.valueOf('TEST Proposal_Manhattan Trimble Proposal US_'+String.valueOf(sysDate)+'.doc');
            attachment.ParentId = proposal.Id; 
            insert attachment;
            System.debug('==========attachment==============='+attachment);
        }
    }
    
    static testmethod void meth3(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser09878987@testorg.com');
        
        System.runAs(u) {
            
            GenerateTestData.createAccount();
            GenerateTestData.createAddress();
            GenerateTestData.createPriceList();
            GenerateTestData.createProduct2();
            GenerateTestData.createOpportunity(); 
            system.debug('>>>>createOpportunity>>>>'+GenerateTestData.opp.id);
            RecursiveTriggerUtility.isAfterInsertQuoteProposalTrigger = True; 
            
            Apttus__APTS_Agreement__c apg;
            Attachment attachment;
            
            apg = new Apttus__APTS_Agreement__c();
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
            apg.Apttus__Status_Category__c = 'In Effect';
            apg.Apttus__Status__c='Activated';
            apg.Apttus__Related_Opportunity__c=GenerateTestData.opp.Id;
            apg.Name = 'TEST AGMT';
            insert apg;
            System.debug('==========agreement==============='+apg);
            
            Date sysDate = Date.newinstance(system.today().year(), system.today().month(), system.today().day());
            attachment = new Attachment();
            attachment.Body = Blob.valueOf('Test');
            attachment.Name = String.valueOf('TEST AGMT_Original_GCCM Change Order Non-TEBV Template_'+String.valueOf(sysDate)+'.doc');
            attachment.ParentId = apg.Id; 
            insert attachment;
            System.debug('==========attachment==============='+attachment);
        }
    }
}