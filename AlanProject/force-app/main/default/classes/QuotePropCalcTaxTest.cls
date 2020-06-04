/*****************************************************************************************
Name    : QuotePropCalcTaxTest 
Modification Log : 
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
P M Mamata       1/08/2015          Modified
******************************************************************************************/

@isTest(seealldata=true)
private class QuotePropCalcTaxTest{
    
    static testmethod void meth1(){
        GenerateTestData.createAccount();        
        GenerateTestData.createPriceList();
        OpportunityHelper.setLaunchControl();
        AddressHandler.setLaunchControl();     
        LineItemHelper.setLaunchControl();
        RecursiveTriggerUtility.isBeforeInsertQuoteProposalTrigger = true;
        RecursiveTriggerUtility.isBeforeUpdateQuoteProposalTrigger = true;
        GenerateTestData.createOpportunity();
        GenerateTestData.createAddress();
        GenerateTestData.createProposal();
        GenerateTestData.createProduct2();
        GenerateTestData.CreateProposalLineItem1();  
        GenerateTestData.createAPTSAgreement();
        system.currentPageReference().getParameters().put('id', GenerateTestData.proposal.Id);
        test.startTest();
        QuotePropCalcTax ap = new QuotePropCalcTax();
        ap.callActionMethod();
        ap.cancelquote();
        ap.closePopup();
        ap.showPopup();
        ap.doSendMail('');
        ap.SendEmail('');
        test.stopTest();
        //ap.UpdateTax('1');
    }
    
    static testmethod void meth2(){
        OpportunityHelper.setLaunchControl();
        AddressHandler.setLaunchControl();     
        LineItemHelper.setLaunchControl();
        RecursiveTriggerUtility.isBeforeInsertQuoteProposalTrigger = true;
        RecursiveTriggerUtility.isBeforeUpdateQuoteProposalTrigger = true;
        GenerateTestData.createAccount();        
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();         
        GenerateTestData.createAddress();
        GenerateTestData.createProposal();
        GenerateTestData.createProduct2();
        GenerateTestData.CreateProposalLineItem1();  
        GenerateTestData.createAPTSAgreement();
        system.currentPageReference().getParameters().put('id', GenerateTestData.proposal.Id);
        
        xmlnsOracleComAppsOntSoaproviderPl_v10.OutputParameters_element o = new xmlnsOracleComAppsOntSoaproviderPl_v10.OutputParameters_element();
        o.X_SFDC_LINEOUT_TBL = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINEOUT_TBL_TYPE();
        xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINEOUT_TBL_TYPE o1 = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINEOUT_TBL_TYPE();
        o1.X_SFDC_LINEOUT_TBL_ITEM = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINEOUT_REC_TYPE[]{};
        xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINEOUT_REC_TYPE testxml = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINEOUT_REC_TYPE();
        testxml.PROPOSAL_ID = GenerateTestData.proposal.Id;
        testxml.PROPOSAL_LINE_ID = GenerateTestData.proposalLiTm1.Name;
        testxml.PROPOSAL_SERV_REF_LINE = 'test serv';
        testxml.SERV_START_DATE = System.now();
        testxml.SERV_END_DATE = System.now() + 50;
        testxml.DISCOUNT_EBS_CALCULATED = '18';
        testxml.SELLING_PRICE_EBS_CALCULATED = '20';
        o1.X_SFDC_LINEOUT_TBL_ITEM.add(testxml);        
        o.X_SFDC_LINEOUT_TBL = o1;
        system.debug('--------testxml.PROPOSAL_LINE_ID-------' + testxml.PROPOSAL_LINE_ID);        
        test.startTest();
        o.X_STATUS = 'SUCCESS';
        o.X_CREDIT_STATUS = 'Y';
        o.X_TAX_AMOUNT = 10;                      
        
        QuotePropCalcTax ap = new QuotePropCalcTax();
        ap.o = o;
        ap.callActionMethod();
        ap.cancelquote();
        ap.closePopup();
        ap.showPopup();
        ap.doSendMail('');
        ap.SendEmail('');
        ap.UpdateTax('1');
        
        test.stopTest();
        
    }    
    
    static testmethod void meth3(){
        OpportunityHelper.setLaunchControl();
        AddressHandler.setLaunchControl();     
        LineItemHelper.setLaunchControl();
        RecursiveTriggerUtility.isBeforeInsertQuoteProposalTrigger = true;
        RecursiveTriggerUtility.isBeforeUpdateQuoteProposalTrigger = true;
        GenerateTestData.createAccount();        
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();         
        GenerateTestData.createAddress();
        GenerateTestData.createProposal();
        GenerateTestData.createProduct2();
        GenerateTestData.CreateProposalLineItem1();  
        GenerateTestData.createAPTSAgreement();
        system.currentPageReference().getParameters().put('id', GenerateTestData.proposal.Id);
        
        xmlnsOracleComAppsOntSoaproviderPl_v10.OutputParameters_element o = new xmlnsOracleComAppsOntSoaproviderPl_v10.OutputParameters_element();
        o.X_SFDC_LINEOUT_TBL = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINEOUT_TBL_TYPE();
        xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINEOUT_TBL_TYPE o1 = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINEOUT_TBL_TYPE();
        o1.X_SFDC_LINEOUT_TBL_ITEM = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINEOUT_REC_TYPE[]{};
        xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINEOUT_REC_TYPE testxml = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINEOUT_REC_TYPE();
        testxml.PROPOSAL_ID = GenerateTestData.proposal.Id;
        testxml.PROPOSAL_LINE_ID = GenerateTestData.proposalLiTm1.Name;
        testxml.PROPOSAL_SERV_REF_LINE = 'test serv';
        testxml.SERV_START_DATE = System.now();
        testxml.SERV_END_DATE = System.now() + 50;
        testxml.DISCOUNT_EBS_CALCULATED = '18';
        testxml.SELLING_PRICE_EBS_CALCULATED = '20';
        o1.X_SFDC_LINEOUT_TBL_ITEM.add(testxml);        
        o.X_SFDC_LINEOUT_TBL = o1;
        system.debug('--------testxml.PROPOSAL_LINE_ID-------' + testxml.PROPOSAL_LINE_ID);        
        test.startTest();
        o.X_STATUS = 'SUCCESS';
        o.X_CREDIT_STATUS = 'Y';
        o.X_TAX_AMOUNT = 10;                      
        
        QuotePropCalcTax ap = new QuotePropCalcTax();
        ap.o = o;
        ap.callActionMethod();
        ap.cancelquote();
        ap.closePopup();
        ap.showPopup();
        ap.doSendMail('');
        ap.SendEmail('');
        ap.UpdateTax('0');
        
        QuotePropCalcTax.ebsExceptionCall(GenerateTestData.proposal.Id, 'failed','failed message','SYSTEM_ERROR','');
        test.stopTest();
        
        
        
    } 
}