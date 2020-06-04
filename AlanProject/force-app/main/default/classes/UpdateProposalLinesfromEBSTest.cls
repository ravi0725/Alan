@isTest(seealldata=true)
private class UpdateProposalLinesfromEBSTest{
        
    static testmethod void meth1(){

         GenerateTestData.createAccount();
         GenerateTestData.createAddress();
         GenerateTestData.createPriceList();
         GenerateTestData.createProduct2();
         GenerateTestData.createOpportunity(); 
         system.debug('>>>>createOpportunity>>>>'+GenerateTestData.opp.id);
         RecursiveTriggerUtility.isAfterInsertQuoteProposalTrigger = True; 
         GenerateTestData.createProposal();
         system.debug('>>>>createProposal>>>>'+GenerateTestData.Proposal.id);
         GenerateTestData.CreateProposalLineItem();
         system.debug('>>>>CreateProposalLineItem>>>>'+GenerateTestData.proposalLiTm.id);
         Test.startTest();
             GenerateTestData.createAPTSAgreement();
             
             system.debug('****************'+GenerateTestData.Proposal.Name);
             system.debug('****************'+GenerateTestData.proposalLiTm.Name);
             
             UpdateProposalLinesfromEBS.HeaderData HeaderVar = new UpdateProposalLinesfromEBS.HeaderData();
             List<UpdateProposalLinesfromEBS.InputLineData> LineListVar = new List<UpdateProposalLinesfromEBS.InputLineData>();
             Apttus_Proposal__Proposal_Line_Item__c prslLineItem = [select id, Name, Apttus_Proposal__Proposal__r.Name from Apttus_Proposal__Proposal_Line_Item__c where id=:GenerateTestData.proposalLiTm.id];
             HeaderVar.X_PROPOSAL_ID = prslLineItem.Apttus_Proposal__Proposal__r.Name;
             HeaderVar.X_EBS_ACCOUNT_NUMBER ='12345';
             HeaderVar.X_STATUS = 'SUCCESS';
             HeaderVar.X_ISORDER = '1';
             
             UpdateProposalLinesfromEBS.InputLineData LineVar = new UpdateProposalLinesfromEBS.InputLineData();
             LineVar.PROPOSAL_ID =  prslLineItem.Apttus_Proposal__Proposal__r.Name;
             LineVar.PROPOSAL_LINE_ID = prslLineItem.Name;
             LineVar.SERV_START_DATE = system.now();
             LineVar.SERV_END_DATE = system.now();
             LineVar.SELLING_PRICE_EBS_CALCULATED ='200';
             LineVar.DISCOUNT_EBS_CALCULATED ='20';
             LineListVar.add(LineVar);
             
             UpdateProposalLinesfromEBS.UpdateLines(HeaderVar,LineListVar);
       		Test.stopTest();
         
        }
        static testmethod void meth2(){
        
         GenerateTestData.createAccount();
         GenerateTestData.createAddress();
         GenerateTestData.createPriceList();
         GenerateTestData.createProduct2();
         GenerateTestData.createOpportunity(); 
         system.debug('>>>>createOpportunity>>>>'+GenerateTestData.opp.id);
         RecursiveTriggerUtility.isAfterInsertQuoteProposalTrigger = True; 
         GenerateTestData.createProposal();
         system.debug('>>>>createProposal>>>>'+GenerateTestData.Proposal.id);
         GenerateTestData.CreateProposalLineItem();
         system.debug('>>>>CreateProposalLineItem>>>>'+GenerateTestData.proposalLiTm.id);
         Test.startTest();    
         	GenerateTestData.createAPTSAgreement();
             
             system.debug('****************'+GenerateTestData.Proposal.Name);
             system.debug('****************'+GenerateTestData.proposalLiTm.Name);
             
             UpdateProposalLinesfromEBS.HeaderData HeaderVar = new UpdateProposalLinesfromEBS.HeaderData();
             List<UpdateProposalLinesfromEBS.InputLineData> LineListVar = new List<UpdateProposalLinesfromEBS.InputLineData>();
             
             HeaderVar.X_PROPOSAL_ID = [select id, Name from Apttus_Proposal__Proposal__c where id=:GenerateTestData.Proposal.id].Name;
             HeaderVar.X_EBS_ACCOUNT_NUMBER ='12345';
             HeaderVar.X_STATUS = 'ERROR';
             HeaderVar.X_ISORDER = '0';
             //HeaderVar.X_CREDIT_STATUS='N';
             
             UpdateProposalLinesfromEBS.InputLineData LineVar = new UpdateProposalLinesfromEBS.InputLineData();
             LineVar.PROPOSAL_ID =  [select id, Name from Apttus_Proposal__Proposal__c where id=:GenerateTestData.Proposal.id].Name;
             LineVar.PROPOSAL_LINE_ID = [select id, Name from Apttus_Proposal__Proposal_Line_Item__c where id=:GenerateTestData.proposalLiTm.id].Name;
             LineVar.SERV_START_DATE = system.now();
             LineVar.SERV_END_DATE = system.now();
             LineVar.SELLING_PRICE_EBS_CALCULATED ='200';
             LineVar.DISCOUNT_EBS_CALCULATED ='20';
             LineListVar.add(LineVar);
             
             UpdateProposalLinesfromEBS.UpdateLines(HeaderVar,LineListVar);
       	Test.stopTest();
         }
         static testmethod void meth3(){
      Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
      User u = new User(Alias = 'standt', Email='standarduser@testorg.com',Division__c='MEP NA',
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
         GenerateTestData.createProposal();
         system.debug('>>>>createProposal>>>>'+GenerateTestData.Proposal.id);
         GenerateTestData.CreateApttusConfig2ProductConfigurationMeth();
                  
         UpdateProposalLinesfromEBS.HeaderData HeaderVar = new UpdateProposalLinesfromEBS.HeaderData();
         List<UpdateProposalLinesfromEBS.InputLineData> LineListVar = new List<UpdateProposalLinesfromEBS.InputLineData>();
         
         HeaderVar.X_PROPOSAL_ID = [select id, Name from Apttus_Proposal__Proposal__c where id=:GenerateTestData.Proposal.id].Name;
         HeaderVar.X_EBS_ACCOUNT_NUMBER ='12345';
         HeaderVar.X_STATUS = 'SUCCESS';
         HeaderVar.X_ISORDER = '1';
         
         UpdateProposalLinesfromEBS.InputLineData LineVar = new UpdateProposalLinesfromEBS.InputLineData();
         LineVar.PROPOSAL_ID =  [select id, Name from Apttus_Proposal__Proposal__c where id=:GenerateTestData.Proposal.id].Name;
         LineVar.PROPOSAL_LINE_ID = [select id, Name from Apttus_Config2__LineItem__c where id=:GenerateTestData.standardliTm.id].Name;
         LineVar.SERV_START_DATE = system.now();
         LineVar.SERV_END_DATE = system.now();
         LineVar.SELLING_PRICE_EBS_CALCULATED ='200';
         LineVar.DISCOUNT_EBS_CALCULATED ='20';
         LineListVar.add(LineVar);
         
         UpdateProposalLinesfromEBS.UpdateLines(HeaderVar,LineListVar);
       
         }
         }
       }