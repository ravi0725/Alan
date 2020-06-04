@isTest
private class FC_TestSendToPPMFromAgreementController {

    private static testmethod void testSendToPPM() {
        setup();
        User adminUser = [select Id from User where Username = 'test-sysadmin@trimble.com' limit 1];
        RecordType rt = [select Id from RecordType where Name = 'Master Saas Agreement' limit 1];
        
        Account[] accounts = new Account[] {
            new Account(Name = 'Test Account One', 
                BillingCity = 'New York',
                BillingCountry = 'United States',
                BillingState = 'NY',
                BillingStreet ='San Jose',
                FCH_Party_ID__c = '300000001106393',        //match the soap party id
                Industry = 'Biotechnology')
        };
        System.assertEquals(true, accounts.size() > 0);
        System.runAs(adminUser) {
            insert accounts;
        }
        Apttus_Config2__PriceList__c newCMConfigPriceList = new Apttus_Config2__PriceList__c(
            Apttus_Config2__EffectiveDate__c = Datetime.now(), 
            CurrencyIsoCode = 'USD', 
            Organization__c = 'Trimble Navigation Limited',
            Apttus_Config2__Active__c = true, 
            Apttus_Config2__Type__c = 'Standard', 
            Name = 'ARFC MANHATTAN PL16052015', 
            Oracle_ID__c = 765703.0, 
            Business_Area__c = 'MANHATTAN SOFTWARE',                        //this must match PPM_Template_Map__c
            Apttus_Config2__Description__c = 'ARFC MANHATTAN PL16052015'
        );
        insert newCMConfigPriceList;
        
        Opportunity[] opps = FC_TestDataGenerator.generateOpportunities(accounts);
        insert opps;
        Apttus_Proposal__Proposal__c[] proposals = FC_TestDataGenerator.generateProposals(opps, newCMConfigPriceList);
        
        Apttus_Proposal__Proposal__c proposal = proposals[0];
        proposal.Revenue_Arrangement_Number__c = '123456';
        insert proposal;
        
        Apttus__APTS_Agreement__c[] agreements = new Apttus__APTS_Agreement__c[]{
            //force to match the PPM_Template_Map__c
            new Apttus__APTS_Agreement__c(Name = 'test',
                    Apttus__Account__c = accounts[0].Id,
                    RecordTypeId = rt.Id,
                    Apttus_CMConfig__PriceListId__c = newCMConfigPriceList.Id,
                    Business_Unit__c = 'Americas Regional',
                    Apttus__Contract_Start_Date__c = Date.today(),
                    Apttus__Contract_End_Date__c = Date.today().addYears(1),
                    Apttus_QPComply__RelatedProposalId__c = proposal.Id,
                    Apttus__Status_Category__c = 'Request',
                    Apttus__Status__c = 'Request',
                    Proserv_Type__c = 'T&M',
                    Template_Key__c = 'T5')
        };
        insert agreements;
        Apttus__APTS_Agreement__c testAgreement = [
            select Id, Name, Apttus__Account__c, RecordTypeId, Business_Unit__c, Apttus__Contract_Start_Date__c, Apttus__Contract_End_Date__c,
                Apttus__FF_Agreement_Number__c, Apttus__Account__r.Name, Apttus_QPComply__RelatedProposalId__r.Revenue_Arrangement_Number__c,
                Apttus__Status_Category__c, Apttus__Status__c, Organization__c,ProServ_Type__c, 
                Quote_Number__c, Template_Key__c 
                from Apttus__APTS_Agreement__c where Id =:agreements[0].Id limit 1];
        
        Product2 product = new Product2(Name = 'Pro Serv Product', Family = 'Professional Services');
        insert product;
        
        Apttus__AgreementLineItem__c[] lineItems = FC_TestDataGenerator.generateAgreementLineItems(agreements[0], 1);
        for (Apttus__AgreementLineItem__c lineItem : lineItems) {
            lineItem.Apttus__ProductId__c = product.Id;
        }
        insert lineItems;
        Apttus__AgreementLineItem__c lineItem = [select Product_Family_Text__c from Apttus__AgreementLineItem__c where Apttus__AgreementId__c = :agreements[0].Id];
        Test.startTest();
        
        FC_TestMockCallout testMock = new FC_TestMockCallout();
        // String testCustomerAccountServiceResponseSOAP = '<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:wsa="http://www.w3.org/2005/08/addressing"> <env:Header> <wsa:Action>http://xmlns.oracle.com/apps/cdm/foundation/parties/customerAccountService/applicationModule//CustomerAccountService/findCustomerAccountResponse</wsa:Action> <wsa:MessageID>urn:uuid:9fcc0c15-666b-4148-ba20-fd3213d72aa4</wsa:MessageID> </env:Header> <env:Body> <ns0:findCustomerAccountResponse xmlns:ns0="http://xmlns.oracle.com/apps/cdm/foundation/parties/customerAccountService/applicationModule/types/"> <ns0:result xsi:type="ns2:CustomerAccountResult" xmlns:ns2="http://xmlns.oracle.com/apps/cdm/foundation/parties/customerAccountService/" xmlns:ns1="http://xmlns.oracle.com/adf/svc/types/" xmlns:ns4="http://xmlns.oracle.com/apps/cdm/foundation/parties/partyService/" xmlns:tns="http://xmlns.oracle.com/adf/svc/errors/" xmlns:ns9="http://xmlns.oracle.com/apps/cdm/foundation/parties/flex/custAccount/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"> <ns2:Value> <ns2:CustomerAccountId>300000001106394</ns2:CustomerAccountId> <ns2:PartyId>300000001106393</ns2:PartyId> <ns2:LastUpdateDate>2015-03-18T18:16:33.0Z</ns2:LastUpdateDate> <ns2:AccountNumber>8003</ns2:AccountNumber> <ns2:LastUpdatedBy>BRAYUDU</ns2:LastUpdatedBy> <ns2:CreationDate>2015-03-18T17:48:05.134Z</ns2:CreationDate> <ns2:CreatedBy>BRAYUDU</ns2:CreatedBy> <ns2:LastUpdateLogin>11927600CBBD8FBCE053B4B7C80AF5CC</ns2:LastUpdateLogin> <ns2:RequestId xsi:nil="true"/> <ns2:OrigSystem xsi:nil="true"/> <ns2:OrigSystemReference>300000001106394</ns2:OrigSystemReference> <ns2:Status>A</ns2:Status> <ns2:CustomerType>R</ns2:CustomerType> <ns2:CustomerClassCode>PUBLIC SECTOR COMPANIES</ns2:CustomerClassCode> <ns2:TaxCode xsi:nil="true"/> <ns2:TaxHeaderLevelFlag xsi:nil="true"/> <ns2:TaxRoundingRule xsi:nil="true"/> <ns2:CoterminateDayMonth xsi:nil="true"/> <ns2:AccountEstablishedDate>2015-03-18</ns2:AccountEstablishedDate> <ns2:AccountTerminationDate>4712-12-31</ns2:AccountTerminationDate> <ns2:HeldBillExpirationDate xsi:nil="true"/> <ns2:HoldBillFlag>false</ns2:HoldBillFlag> <ns2:AccountName>BestBuy Test Customer</ns2:AccountName> <ns2:DepositRefundMethod xsi:nil="true"/> <ns2:NpaNumber xsi:nil="true"/> <ns2:SourceCode xsi:nil="true"/> <ns2:Comments xsi:nil="true"/> <ns2:DateTypePreference xsi:nil="true"/> <ns2:ArrivalsetsIncludeLinesFlag xsi:nil="true"/> <ns2:StatusUpdateDate xsi:nil="true"/> <ns2:AutopayFlag xsi:nil="true"/> <ns2:LastBatchId xsi:nil="true"/> <ns2:CreatedByModule>TCA_FORM_WRAPPER</ns2:CreatedByModule> <ns2:SellingPartyId xsi:nil="true"/> </ns2:Value> </ns0:result> </ns0:findCustomerAccountResponse> </env:Body> </env:Envelope>';
        String testCustomerAccountServiceResponseSOAP = '<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:wsa="http://www.w3.org/2005/08/addressing"> <env:Header> <wsa:Action>http://xmlns.oracle.com/apps/cdm/foundation/parties/customerAccountService/applicationModule//CustomerAccountService/getCustomerAccountByOriginalSystemReferenceResponse</wsa:Action><wsa:MessageID>urn:uuid:bbe3325d-0fc1-4f7e-a1fd-e7d34d89bd23</wsa:MessageID> </env:Header> <env:Body> <ns0:getCustomerAccountByOriginalSystemReferenceResponse xmlns:ns0="http://xmlns.oracle.com/apps/cdm/foundation/parties/customerAccountService/applicationModule/types/"> <ns0:result xsi:type="ns2:CustomerAccountResult" xmlns:ns2="http://xmlns.oracle.com/apps/cdm/foundation/parties/customerAccountService/" xmlns:ns1="http://xmlns.oracle.com/adf/svc/types/" xmlns:ns4="http://xmlns.oracle.com/apps/cdm/foundation/parties/partyService/" xmlns:tns="http://xmlns.oracle.com/adf/svc/errors/" xmlns:ns9="http://xmlns.oracle.com/apps/cdm/foundation/parties/flex/custAccount/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"> <ns2:Value> <ns2:PartyId>300000001263934</ns2:PartyId></ns2:Value></ns0:result></ns0:getCustomerAccountByOriginalSystemReferenceResponse></env:Body></env:Envelope>';
        FC_TestMockCallout.FC_TestEndPointMock customerServiceSOAPResponseMock = new FC_TestMockCallout.FC_TestEndPointMock(testCustomerAccountServiceResponseSOAP, 200);
        customerServiceSOAPResponseMock.setContentTypeXML();    //returns xml
        testMock.addEndpointMock('https://ebko-test.crm.us2.oraclecloud.com//foundationParties/CustomerAccountService', customerServiceSOAPResponseMock);

        String testProjectDefinitionResponseSOAP = '<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:wsa="http://www.w3.org/2005/08/addressing" xmlns:typ="http://xmlns.oracle.com/apps/projects/foundation/projectDefinition/publicService/maintainProjectV2/types/"> <env:Header> <wsa:Action>http://xmlns.oracle.com/apps/projects/foundation/projectDefinition/publicService/maintainProjectV2//ProjectDefinitionPublicService/createProjectResponse</wsa:Action> <wsa:MessageID>urn:uuid:4e5ac224-c181-4180-9447-4ca02b2c3b8c</wsa:MessageID> </env:Header> <env:Body> <ns0:createProjectResponse xmlns:ns0="http://xmlns.oracle.com/apps/projects/foundation/projectDefinition/publicService/maintainProjectV2/types/"> <ns3:result xsi:type="ns1:ProjectResult" xmlns:ns2="http://xmlns.oracle.com/apps/projects/foundation/projectDefinition/flex/ProjectDff/" xmlns:ns1="http://xmlns.oracle.com/apps/projects/foundation/projectDefinition/publicService/maintainProjectV2/" xmlns:ns3="http://xmlns.oracle.com/apps/projects/foundation/projectDefinition/publicService/maintainProjectV2/types/" xmlns:tns="http://xmlns.oracle.com/adf/svc/errors/" xmlns:ns0="http://xmlns.oracle.com/adf/svc/types/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"> <ns1:Value> <ns1:ClientKey>SFDC</ns1:ClientKey> <ns1:ClientProjectKey xsi:nil="true"/> <ns1:ProjectId>300000001380218</ns1:ProjectId> <ns1:ProjectNumber>221</ns1:ProjectNumber> <ns1:ProjectName>CRP2 BINGHAM PLUMBING &amp; PIPING INC. -</ns1:ProjectName> <ns1:ProjectDescription>CRP2 BINGHAM PLUMBING &amp; PIPING INC.</ns1:ProjectDescription> <ns1:StartDate>2015-04-10</ns1:StartDate> <ns1:EndDate>2016-04-08</ns1:EndDate> <ns1:TemplateKey>T30</ns1:TemplateKey> <ns1:ProjectStatus>300000001278209</ns1:ProjectStatus> <ns1:OwningOrganization>Manhattan Software(164)</ns1:OwningOrganization> <ns1:BusinessUnit>Americas Regional Fulfillment Center</ns1:BusinessUnit> <ns1:ProjectUnit>Americas Regional Fulfillment Center</ns1:ProjectUnit> <ns1:LegalEntity xsi:nil="true"/> <ns1:ProjectCcyCode>USD</ns1:ProjectCcyCode> <ns1:CcyConversionRateType>Corporate</ns1:CcyConversionRateType> <ns1:CcyConversionDateTypeCode>T</ns1:CcyConversionDateTypeCode> <ns1:CcyConversionDate xsi:nil="true"/> <ns1:ServiceType xsi:nil="true"/> <ns1:OutlineLevel xsi:nil="true"/> <ns1:IsPlanningProject>Y</ns1:IsPlanningProject> <ns1:ProjectPriorityCode xsi:nil="true"/> <ns1:ProjectTypeName>Client Implementation</ns1:ProjectTypeName> <ns1:WorkTypeName xsi:nil="true"/> <ns1:KPINotificationEnabled>N</ns1:KPINotificationEnabled> <ns1:KPINotificationIncludeNotes>N</ns1:KPINotificationIncludeNotes> <ns1:KPINotificationRecipients xsi:nil="true"/> <ns1:CintEligibleFlag xsi:nil="true"/> <ns1:CintRateSchName xsi:nil="true"/> <ns1:CintStopDate xsi:nil="true"/> <ns1:AssetAllocationMethodCode xsi:nil="true"/> <ns1:CapitalEventProcessingCode xsi:nil="true"/> <ns1:AllowCrossChargeFlag>true</ns1:AllowCrossChargeFlag> <ns1:CcProcessLaborFlag>false</ns1:CcProcessLaborFlag> <ns1:LaborTpScheduleName xsi:nil="true"/> <ns1:LaborTpFixedDate xsi:nil="true"/> <ns1:CcProcessNlFlag>false</ns1:CcProcessNlFlag> <ns1:NlTpScheduleName xsi:nil="true"/> <ns1:NlTpFixedDate xsi:nil="true"/> <ns1:ClosedDate xsi:nil="true"/> <ns1:LimitToTransactionControlsCode>N</ns1:LimitToTransactionControlsCode> <ns1:BurdenScheduleName xsi:nil="true"/> <ns1:BurdenSchFixedDate xsi:nil="true"/> <ns1:CreationDate>2015-04-28T23:33:04.574Z</ns1:CreationDate> <ns1:CreatedBy>WLEE</ns1:CreatedBy> <ns1:LastUpdateDate>2015-04-28T23:33:07.361Z</ns1:LastUpdateDate> <ns1:LastUpdatedBy>WLEE</ns1:LastUpdatedBy> <ns1:LastUpdateLogin>14D248A3FAFBDD70E053B4B7C80A18C6</ns1:LastUpdateLogin> <ns1:ObjectVersionNumber>2</ns1:ObjectVersionNumber> <ns1:ProjectManager xsi:nil="true"/> <ns1:ProjectManagerNumber xsi:nil="true"/> <ns1:ProjectManagerEmail xsi:nil="true"/> <ns1:UseTemplateTasksFlag xsi:nil="true"/> <ns1:OperationSuccessfulFlag>true</ns1:OperationSuccessfulFlag> <ns1:CopyTaskAttachmentsFlag xsi:nil="true"/> <ns1:CopyTaskDffsFlag xsi:nil="true"/> <ns1:CopyTaskAssignmentsFlag xsi:nil="true"/> <ns1:CopyTeamMembersFlag xsi:nil="true"/> <ns1:CopyAssetsFlag xsi:nil="true"/> <ns1:CopyAssetAssignmentsFlag xsi:nil="true"/> <ns1:CopyTransactionControlsFlag xsi:nil="true"/> <ns1:CopyGroupSpaceFlag xsi:nil="true"/> <ns1:CopyDffFlag xsi:nil="true"/> <ns1:CopyAttachmentsFlag xsi:nil="true"/> <ns1:CopyCostOverridesFlag xsi:nil="true"/> <ns1:ProjectDff> <ns2:ProjectId>300000001380218</ns2:ProjectId> <ns2:__FLEX_Context xsi:nil="true"/> <ns2:_FLEX_NumOfSegments>0</ns2:_FLEX_NumOfSegments> </ns1:ProjectDff> </ns1:Value> </ns3:result> </ns0:createProjectResponse> </env:Body></env:Envelope>';
        FC_TestMockCallout.FC_TestEndPointMock projectDefinitionResponseSOAPPResponseMock = new FC_TestMockCallout.FC_TestEndPointMock(testProjectDefinitionResponseSOAP, 200);
        projectDefinitionResponseSOAPPResponseMock.setContentTypeXML(); //returns xml
        testMock.addEndpointMock('https://ebko-test.prj.us2.oraclecloud.com//pjfProjectDefinition/ProjectDefinitionPublicServiceV2', projectDefinitionResponseSOAPPResponseMock);

        Test.setMock(HttpCalloutMock.class, testMock);

        PageReference testPage = Page.FC_SendToPPMFromAgreement;
        testPage.getParameters().put('id', testAgreement.Id);
        Test.setCurrentPage(testPage);
        ApexPages.StandardController standardController = new ApexPages.StandardController(testAgreement);
        FC_SendToPPMFromAgreementController controller = new FC_SendToPPMFromAgreementController(standardController);
        controller.sendToPPM();
		controller.validate();
        Test.stopTest();
        
    }
    
    private static testmethod void testValidations() {
        setup();
        User adminUser = [select Id from User where Username = 'test-sysadmin@trimble.com' limit 1];
        RecordType rt = [select Id from RecordType where Name = 'Master Saas Agreement' limit 1];
        
        Account[] accounts = new Account[] {
            new Account(Name = 'Test Account One', 
                BillingCity = 'New York',
                BillingCountry = 'United States',
                BillingState = 'NY',
                BillingStreet ='San Jose',
                // FCH_Party_ID__c = '300000001106393',        // not having this will trigger a validation
                Industry = 'Biotechnology')
        };
        System.assertEquals(true, accounts.size() > 0);
        System.runAs(adminUser) {
            insert accounts;
        }
        Apttus_Config2__PriceList__c newCMConfigPriceList = new Apttus_Config2__PriceList__c(
            Apttus_Config2__EffectiveDate__c = Datetime.now(), 
            CurrencyIsoCode = 'USD', 
            Organization__c = 'Trimble Navigation Limited',
            Apttus_Config2__Active__c = true, 
            Apttus_Config2__Type__c = 'Standard', 
            Name = 'ARFC MANHATTAN PL16052015', 
            Oracle_ID__c = 765703.0, 
            Business_Area__c = 'MANHATTAN SOFTWARE',                        //this must match PPM_Template_Map__c
            Apttus_Config2__Description__c = 'ARFC MANHATTAN PL16052015'
        );
        insert newCMConfigPriceList;
        
        Opportunity[] opps = FC_TestDataGenerator.generateOpportunities(accounts);
        insert opps;
        Apttus_Proposal__Proposal__c[] proposals = FC_TestDataGenerator.generateProposals(opps, newCMConfigPriceList);
        
        Apttus_Proposal__Proposal__c proposal = proposals[0];
        proposal.Revenue_Arrangement_Number__c = '123456';
        insert proposal;
        
        Apttus__APTS_Agreement__c[] agreements = new Apttus__APTS_Agreement__c[]{
            //force to match the PPM_Template_Map__c
            new Apttus__APTS_Agreement__c(Name = 'test',
                    Apttus__Account__c = accounts[0].Id,
                    RecordTypeId = rt.Id,
                    Apttus_CMConfig__PriceListId__c = newCMConfigPriceList.Id,
                    Business_Unit__c = 'Americas Regional',
                    Apttus__Contract_Start_Date__c = Date.today(),
                    Apttus__Contract_End_Date__c = Date.today().addYears(1),
                    Apttus_QPComply__RelatedProposalId__c = proposal.Id,
                    Apttus__Status_Category__c = 'Request',
                    Apttus__Status__c = 'Request',
                    // Proserv_Type__c = 'T&M', // this will trigger a validation
                    Template_Key__c = 'T5')
        };
        insert agreements;
        Apttus__APTS_Agreement__c testAgreement = [
            select Id, Name, Apttus__Account__c, RecordTypeId, Business_Unit__c, Apttus__Contract_Start_Date__c, Apttus__Contract_End_Date__c,
                Apttus__FF_Agreement_Number__c, Apttus__Account__r.Name, Apttus_QPComply__RelatedProposalId__r.Revenue_Arrangement_Number__c,
                Apttus__Status_Category__c, Apttus__Status__c, Organization__c,ProServ_Type__c, 
                Quote_Number__c, Template_Key__c 
                from Apttus__APTS_Agreement__c where Id =:agreements[0].Id limit 1];
        
        Product2 product = new Product2(Name = 'Pro Serv Product', Family = 'Professional Services');
        insert product;
        
        
        Test.startTest();
        
        FC_TestMockCallout testMock = new FC_TestMockCallout();
        // String testCustomerAccountServiceResponseSOAP = '<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:wsa="http://www.w3.org/2005/08/addressing"> <env:Header> <wsa:Action>http://xmlns.oracle.com/apps/cdm/foundation/parties/customerAccountService/applicationModule//CustomerAccountService/findCustomerAccountResponse</wsa:Action> <wsa:MessageID>urn:uuid:9fcc0c15-666b-4148-ba20-fd3213d72aa4</wsa:MessageID> </env:Header> <env:Body> <ns0:findCustomerAccountResponse xmlns:ns0="http://xmlns.oracle.com/apps/cdm/foundation/parties/customerAccountService/applicationModule/types/"> <ns0:result xsi:type="ns2:CustomerAccountResult" xmlns:ns2="http://xmlns.oracle.com/apps/cdm/foundation/parties/customerAccountService/" xmlns:ns1="http://xmlns.oracle.com/adf/svc/types/" xmlns:ns4="http://xmlns.oracle.com/apps/cdm/foundation/parties/partyService/" xmlns:tns="http://xmlns.oracle.com/adf/svc/errors/" xmlns:ns9="http://xmlns.oracle.com/apps/cdm/foundation/parties/flex/custAccount/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"> <ns2:Value> <ns2:CustomerAccountId>300000001106394</ns2:CustomerAccountId> <ns2:PartyId>300000001106393</ns2:PartyId> <ns2:LastUpdateDate>2015-03-18T18:16:33.0Z</ns2:LastUpdateDate> <ns2:AccountNumber>8003</ns2:AccountNumber> <ns2:LastUpdatedBy>BRAYUDU</ns2:LastUpdatedBy> <ns2:CreationDate>2015-03-18T17:48:05.134Z</ns2:CreationDate> <ns2:CreatedBy>BRAYUDU</ns2:CreatedBy> <ns2:LastUpdateLogin>11927600CBBD8FBCE053B4B7C80AF5CC</ns2:LastUpdateLogin> <ns2:RequestId xsi:nil="true"/> <ns2:OrigSystem xsi:nil="true"/> <ns2:OrigSystemReference>300000001106394</ns2:OrigSystemReference> <ns2:Status>A</ns2:Status> <ns2:CustomerType>R</ns2:CustomerType> <ns2:CustomerClassCode>PUBLIC SECTOR COMPANIES</ns2:CustomerClassCode> <ns2:TaxCode xsi:nil="true"/> <ns2:TaxHeaderLevelFlag xsi:nil="true"/> <ns2:TaxRoundingRule xsi:nil="true"/> <ns2:CoterminateDayMonth xsi:nil="true"/> <ns2:AccountEstablishedDate>2015-03-18</ns2:AccountEstablishedDate> <ns2:AccountTerminationDate>4712-12-31</ns2:AccountTerminationDate> <ns2:HeldBillExpirationDate xsi:nil="true"/> <ns2:HoldBillFlag>false</ns2:HoldBillFlag> <ns2:AccountName>BestBuy Test Customer</ns2:AccountName> <ns2:DepositRefundMethod xsi:nil="true"/> <ns2:NpaNumber xsi:nil="true"/> <ns2:SourceCode xsi:nil="true"/> <ns2:Comments xsi:nil="true"/> <ns2:DateTypePreference xsi:nil="true"/> <ns2:ArrivalsetsIncludeLinesFlag xsi:nil="true"/> <ns2:StatusUpdateDate xsi:nil="true"/> <ns2:AutopayFlag xsi:nil="true"/> <ns2:LastBatchId xsi:nil="true"/> <ns2:CreatedByModule>TCA_FORM_WRAPPER</ns2:CreatedByModule> <ns2:SellingPartyId xsi:nil="true"/> </ns2:Value> </ns0:result> </ns0:findCustomerAccountResponse> </env:Body> </env:Envelope>';
        String testCustomerAccountServiceResponseSOAP = '<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:wsa="http://www.w3.org/2005/08/addressing"> <env:Header> <wsa:Action>http://xmlns.oracle.com/apps/cdm/foundation/parties/customerAccountService/applicationModule//CustomerAccountService/getCustomerAccountByOriginalSystemReferenceResponse</wsa:Action><wsa:MessageID>urn:uuid:bbe3325d-0fc1-4f7e-a1fd-e7d34d89bd23</wsa:MessageID> </env:Header> <env:Body> <ns0:getCustomerAccountByOriginalSystemReferenceResponse xmlns:ns0="http://xmlns.oracle.com/apps/cdm/foundation/parties/customerAccountService/applicationModule/types/"> <ns0:result xsi:type="ns2:CustomerAccountResult" xmlns:ns2="http://xmlns.oracle.com/apps/cdm/foundation/parties/customerAccountService/" xmlns:ns1="http://xmlns.oracle.com/adf/svc/types/" xmlns:ns4="http://xmlns.oracle.com/apps/cdm/foundation/parties/partyService/" xmlns:tns="http://xmlns.oracle.com/adf/svc/errors/" xmlns:ns9="http://xmlns.oracle.com/apps/cdm/foundation/parties/flex/custAccount/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"> <ns2:Value> <ns2:PartyId>300000001263934</ns2:PartyId></ns2:Value></ns0:result></ns0:getCustomerAccountByOriginalSystemReferenceResponse></env:Body></env:Envelope>';
        FC_TestMockCallout.FC_TestEndPointMock customerServiceSOAPResponseMock = new FC_TestMockCallout.FC_TestEndPointMock(testCustomerAccountServiceResponseSOAP, 200);
        customerServiceSOAPResponseMock.setContentTypeXML();    //returns xml
        testMock.addEndpointMock('https://ebko-test.crm.us2.oraclecloud.com//foundationParties/CustomerAccountService', customerServiceSOAPResponseMock);

        String testProjectDefinitionResponseSOAP = '<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:wsa="http://www.w3.org/2005/08/addressing" xmlns:typ="http://xmlns.oracle.com/apps/projects/foundation/projectDefinition/publicService/maintainProjectV2/types/"> <env:Header> <wsa:Action>http://xmlns.oracle.com/apps/projects/foundation/projectDefinition/publicService/maintainProjectV2//ProjectDefinitionPublicService/createProjectResponse</wsa:Action> <wsa:MessageID>urn:uuid:4e5ac224-c181-4180-9447-4ca02b2c3b8c</wsa:MessageID> </env:Header> <env:Body> <ns0:createProjectResponse xmlns:ns0="http://xmlns.oracle.com/apps/projects/foundation/projectDefinition/publicService/maintainProjectV2/types/"> <ns3:result xsi:type="ns1:ProjectResult" xmlns:ns2="http://xmlns.oracle.com/apps/projects/foundation/projectDefinition/flex/ProjectDff/" xmlns:ns1="http://xmlns.oracle.com/apps/projects/foundation/projectDefinition/publicService/maintainProjectV2/" xmlns:ns3="http://xmlns.oracle.com/apps/projects/foundation/projectDefinition/publicService/maintainProjectV2/types/" xmlns:tns="http://xmlns.oracle.com/adf/svc/errors/" xmlns:ns0="http://xmlns.oracle.com/adf/svc/types/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"> <ns1:Value> <ns1:ClientKey>SFDC</ns1:ClientKey> <ns1:ClientProjectKey xsi:nil="true"/> <ns1:ProjectId>300000001380218</ns1:ProjectId> <ns1:ProjectNumber>221</ns1:ProjectNumber> <ns1:ProjectName>CRP2 BINGHAM PLUMBING &amp; PIPING INC. -</ns1:ProjectName> <ns1:ProjectDescription>CRP2 BINGHAM PLUMBING &amp; PIPING INC.</ns1:ProjectDescription> <ns1:StartDate>2015-04-10</ns1:StartDate> <ns1:EndDate>2016-04-08</ns1:EndDate> <ns1:TemplateKey>T30</ns1:TemplateKey> <ns1:ProjectStatus>300000001278209</ns1:ProjectStatus> <ns1:OwningOrganization>Manhattan Software(164)</ns1:OwningOrganization> <ns1:BusinessUnit>Americas Regional Fulfillment Center</ns1:BusinessUnit> <ns1:ProjectUnit>Americas Regional Fulfillment Center</ns1:ProjectUnit> <ns1:LegalEntity xsi:nil="true"/> <ns1:ProjectCcyCode>USD</ns1:ProjectCcyCode> <ns1:CcyConversionRateType>Corporate</ns1:CcyConversionRateType> <ns1:CcyConversionDateTypeCode>T</ns1:CcyConversionDateTypeCode> <ns1:CcyConversionDate xsi:nil="true"/> <ns1:ServiceType xsi:nil="true"/> <ns1:OutlineLevel xsi:nil="true"/> <ns1:IsPlanningProject>Y</ns1:IsPlanningProject> <ns1:ProjectPriorityCode xsi:nil="true"/> <ns1:ProjectTypeName>Client Implementation</ns1:ProjectTypeName> <ns1:WorkTypeName xsi:nil="true"/> <ns1:KPINotificationEnabled>N</ns1:KPINotificationEnabled> <ns1:KPINotificationIncludeNotes>N</ns1:KPINotificationIncludeNotes> <ns1:KPINotificationRecipients xsi:nil="true"/> <ns1:CintEligibleFlag xsi:nil="true"/> <ns1:CintRateSchName xsi:nil="true"/> <ns1:CintStopDate xsi:nil="true"/> <ns1:AssetAllocationMethodCode xsi:nil="true"/> <ns1:CapitalEventProcessingCode xsi:nil="true"/> <ns1:AllowCrossChargeFlag>true</ns1:AllowCrossChargeFlag> <ns1:CcProcessLaborFlag>false</ns1:CcProcessLaborFlag> <ns1:LaborTpScheduleName xsi:nil="true"/> <ns1:LaborTpFixedDate xsi:nil="true"/> <ns1:CcProcessNlFlag>false</ns1:CcProcessNlFlag> <ns1:NlTpScheduleName xsi:nil="true"/> <ns1:NlTpFixedDate xsi:nil="true"/> <ns1:ClosedDate xsi:nil="true"/> <ns1:LimitToTransactionControlsCode>N</ns1:LimitToTransactionControlsCode> <ns1:BurdenScheduleName xsi:nil="true"/> <ns1:BurdenSchFixedDate xsi:nil="true"/> <ns1:CreationDate>2015-04-28T23:33:04.574Z</ns1:CreationDate> <ns1:CreatedBy>WLEE</ns1:CreatedBy> <ns1:LastUpdateDate>2015-04-28T23:33:07.361Z</ns1:LastUpdateDate> <ns1:LastUpdatedBy>WLEE</ns1:LastUpdatedBy> <ns1:LastUpdateLogin>14D248A3FAFBDD70E053B4B7C80A18C6</ns1:LastUpdateLogin> <ns1:ObjectVersionNumber>2</ns1:ObjectVersionNumber> <ns1:ProjectManager xsi:nil="true"/> <ns1:ProjectManagerNumber xsi:nil="true"/> <ns1:ProjectManagerEmail xsi:nil="true"/> <ns1:UseTemplateTasksFlag xsi:nil="true"/> <ns1:OperationSuccessfulFlag>true</ns1:OperationSuccessfulFlag> <ns1:CopyTaskAttachmentsFlag xsi:nil="true"/> <ns1:CopyTaskDffsFlag xsi:nil="true"/> <ns1:CopyTaskAssignmentsFlag xsi:nil="true"/> <ns1:CopyTeamMembersFlag xsi:nil="true"/> <ns1:CopyAssetsFlag xsi:nil="true"/> <ns1:CopyAssetAssignmentsFlag xsi:nil="true"/> <ns1:CopyTransactionControlsFlag xsi:nil="true"/> <ns1:CopyGroupSpaceFlag xsi:nil="true"/> <ns1:CopyDffFlag xsi:nil="true"/> <ns1:CopyAttachmentsFlag xsi:nil="true"/> <ns1:CopyCostOverridesFlag xsi:nil="true"/> <ns1:ProjectDff> <ns2:ProjectId>300000001380218</ns2:ProjectId> <ns2:__FLEX_Context xsi:nil="true"/> <ns2:_FLEX_NumOfSegments>0</ns2:_FLEX_NumOfSegments> </ns1:ProjectDff> </ns1:Value> </ns3:result> </ns0:createProjectResponse> </env:Body></env:Envelope>';
        FC_TestMockCallout.FC_TestEndPointMock projectDefinitionResponseSOAPPResponseMock = new FC_TestMockCallout.FC_TestEndPointMock(testProjectDefinitionResponseSOAP, 200);
        projectDefinitionResponseSOAPPResponseMock.setContentTypeXML(); //returns xml
        testMock.addEndpointMock('https://ebko-test.prj.us2.oraclecloud.com//pjfProjectDefinition/ProjectDefinitionPublicServiceV2', projectDefinitionResponseSOAPPResponseMock);

        Test.setMock(HttpCalloutMock.class, testMock);

        PageReference testPage = Page.FC_SendToPPMFromAgreement;
        testPage.getParameters().put('id', testAgreement.Id);
        Test.setCurrentPage(testPage);
        ApexPages.StandardController standardController = new ApexPages.StandardController(testAgreement);
        FC_SendToPPMFromAgreementController controller = new FC_SendToPPMFromAgreementController(standardController);
        controller.sendToPPM();
        
        testAgreement.ProServ_Type__c = 'T&M';
        update testAgreement;
        controller.sendToPPM();

        Apttus__AgreementLineItem__c[] lineItems = FC_TestDataGenerator.generateAgreementLineItems(agreements[0], 1);
        for (Apttus__AgreementLineItem__c lineItem : lineItems) {
            lineItem.Apttus__ProductId__c = product.Id;
        }
        insert lineItems;
        controller.sendToPPM();
        
        Test.stopTest();
        
    }
    
    private static testmethod void testValidationsTwo() {
        setup();
        User adminUser = [select Id from User where Username = 'test-sysadmin@trimble.com' limit 1];
        RecordType rt = [select Id from RecordType where Name = 'Master Saas Agreement' limit 1];
        
        Account[] accounts = new Account[] {
            new Account(Name = 'Test Account One', 
                BillingCity = 'New York',
                BillingCountry = 'United States',
                BillingState = 'NY',
                BillingStreet ='San Jose',
                FCH_Party_ID__c = '3000000011063xx',        //this will trigger a validation
                Industry = 'Biotechnology')
        };
        System.assertEquals(true, accounts.size() > 0);
        System.runAs(adminUser) {
            insert accounts;
        }
        Apttus_Config2__PriceList__c newCMConfigPriceList = new Apttus_Config2__PriceList__c(
            Apttus_Config2__EffectiveDate__c = Datetime.now(), 
            CurrencyIsoCode = 'USD', 
            Organization__c = 'Trimble Navigation Limited',
            Apttus_Config2__Active__c = true, 
            Apttus_Config2__Type__c = 'Standard', 
            Name = 'ARFC MANHATTAN PL16052015', 
            Oracle_ID__c = 765703.0, 
            Business_Area__c = 'MANHATTAN SOFTWARE',                        //this must match PPM_Template_Map__c
            Apttus_Config2__Description__c = 'ARFC MANHATTAN PL16052015'
        );
        insert newCMConfigPriceList;
        
        Opportunity[] opps = FC_TestDataGenerator.generateOpportunities(accounts);
        insert opps;
        Apttus_Proposal__Proposal__c[] proposals = FC_TestDataGenerator.generateProposals(opps, newCMConfigPriceList);
        
        Apttus_Proposal__Proposal__c proposal = proposals[0];
        proposal.Revenue_Arrangement_Number__c = '123456';
        insert proposal;
        
        Apttus__APTS_Agreement__c[] agreements = new Apttus__APTS_Agreement__c[]{
            //force to match the PPM_Template_Map__c
            new Apttus__APTS_Agreement__c(Name = 'test',
                    Apttus__Account__c = accounts[0].Id,
                    RecordTypeId = rt.Id,
                    Apttus_CMConfig__PriceListId__c = newCMConfigPriceList.Id,
                    Business_Unit__c = 'Americas Regional',
                    Apttus__Contract_Start_Date__c = Date.today(),
                    Apttus__Contract_End_Date__c = Date.today().addYears(1),
                    Apttus_QPComply__RelatedProposalId__c = proposal.Id,
                    Apttus__Status_Category__c = 'Request',
                    Apttus__Status__c = 'Request',
                    Proserv_Type__c = 'T&M',
                    Template_Key__c = 'T5')
        };
        insert agreements;
        Apttus__APTS_Agreement__c testAgreement = [
            select Id, Name, Apttus__Account__c, RecordTypeId, Business_Unit__c, Apttus__Contract_Start_Date__c, Apttus__Contract_End_Date__c,
                Apttus__FF_Agreement_Number__c, Apttus__Account__r.Name, Apttus_QPComply__RelatedProposalId__r.Revenue_Arrangement_Number__c,
                Apttus__Status_Category__c, Apttus__Status__c, Organization__c,ProServ_Type__c, 
                Quote_Number__c, Template_Key__c 
                from Apttus__APTS_Agreement__c where Id =:agreements[0].Id limit 1];
        
        Product2 product = new Product2(Name = 'Pro Serv Product', Family = 'Professional Services');
        insert product;
        
        Apttus__AgreementLineItem__c[] lineItems = FC_TestDataGenerator.generateAgreementLineItems(agreements[0], 1);
        for (Apttus__AgreementLineItem__c lineItem : lineItems) {
            lineItem.Apttus__ProductId__c = product.Id;
        }
        insert lineItems;
        Apttus__AgreementLineItem__c lineItem = [select Product_Family_Text__c from Apttus__AgreementLineItem__c where Apttus__AgreementId__c = :agreements[0].Id];
        Test.startTest();
        
        FC_TestMockCallout testMock = new FC_TestMockCallout();
        // String testCustomerAccountServiceResponseSOAP = '<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:wsa="http://www.w3.org/2005/08/addressing"> <env:Header> <wsa:Action>http://xmlns.oracle.com/apps/cdm/foundation/parties/customerAccountService/applicationModule//CustomerAccountService/findCustomerAccountResponse</wsa:Action> <wsa:MessageID>urn:uuid:9fcc0c15-666b-4148-ba20-fd3213d72aa4</wsa:MessageID> </env:Header> <env:Body> <ns0:findCustomerAccountResponse xmlns:ns0="http://xmlns.oracle.com/apps/cdm/foundation/parties/customerAccountService/applicationModule/types/"> <ns0:result xsi:type="ns2:CustomerAccountResult" xmlns:ns2="http://xmlns.oracle.com/apps/cdm/foundation/parties/customerAccountService/" xmlns:ns1="http://xmlns.oracle.com/adf/svc/types/" xmlns:ns4="http://xmlns.oracle.com/apps/cdm/foundation/parties/partyService/" xmlns:tns="http://xmlns.oracle.com/adf/svc/errors/" xmlns:ns9="http://xmlns.oracle.com/apps/cdm/foundation/parties/flex/custAccount/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"> <ns2:Value> <ns2:CustomerAccountId>300000001106394</ns2:CustomerAccountId> <ns2:PartyId>300000001106393</ns2:PartyId> <ns2:LastUpdateDate>2015-03-18T18:16:33.0Z</ns2:LastUpdateDate> <ns2:AccountNumber>8003</ns2:AccountNumber> <ns2:LastUpdatedBy>BRAYUDU</ns2:LastUpdatedBy> <ns2:CreationDate>2015-03-18T17:48:05.134Z</ns2:CreationDate> <ns2:CreatedBy>BRAYUDU</ns2:CreatedBy> <ns2:LastUpdateLogin>11927600CBBD8FBCE053B4B7C80AF5CC</ns2:LastUpdateLogin> <ns2:RequestId xsi:nil="true"/> <ns2:OrigSystem xsi:nil="true"/> <ns2:OrigSystemReference>300000001106394</ns2:OrigSystemReference> <ns2:Status>A</ns2:Status> <ns2:CustomerType>R</ns2:CustomerType> <ns2:CustomerClassCode>PUBLIC SECTOR COMPANIES</ns2:CustomerClassCode> <ns2:TaxCode xsi:nil="true"/> <ns2:TaxHeaderLevelFlag xsi:nil="true"/> <ns2:TaxRoundingRule xsi:nil="true"/> <ns2:CoterminateDayMonth xsi:nil="true"/> <ns2:AccountEstablishedDate>2015-03-18</ns2:AccountEstablishedDate> <ns2:AccountTerminationDate>4712-12-31</ns2:AccountTerminationDate> <ns2:HeldBillExpirationDate xsi:nil="true"/> <ns2:HoldBillFlag>false</ns2:HoldBillFlag> <ns2:AccountName>BestBuy Test Customer</ns2:AccountName> <ns2:DepositRefundMethod xsi:nil="true"/> <ns2:NpaNumber xsi:nil="true"/> <ns2:SourceCode xsi:nil="true"/> <ns2:Comments xsi:nil="true"/> <ns2:DateTypePreference xsi:nil="true"/> <ns2:ArrivalsetsIncludeLinesFlag xsi:nil="true"/> <ns2:StatusUpdateDate xsi:nil="true"/> <ns2:AutopayFlag xsi:nil="true"/> <ns2:LastBatchId xsi:nil="true"/> <ns2:CreatedByModule>TCA_FORM_WRAPPER</ns2:CreatedByModule> <ns2:SellingPartyId xsi:nil="true"/> </ns2:Value> </ns0:result> </ns0:findCustomerAccountResponse> </env:Body> </env:Envelope>';
        String testCustomerAccountServiceResponseSOAP = '<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:wsa="http://www.w3.org/2005/08/addressing"> <env:Header> <wsa:Action>http://xmlns.oracle.com/apps/cdm/foundation/parties/customerAccountService/applicationModule//CustomerAccountService/getCustomerAccountByOriginalSystemReferenceResponse</wsa:Action><wsa:MessageID>urn:uuid:bbe3325d-0fc1-4f7e-a1fd-e7d34d89bd23</wsa:MessageID> </env:Header> <env:Body> <ns0:getCustomerAccountByOriginalSystemReferenceResponse xmlns:ns0="http://xmlns.oracle.com/apps/cdm/foundation/parties/customerAccountService/applicationModule/types/"> <ns0:result xsi:type="ns2:CustomerAccountResult" xmlns:ns2="http://xmlns.oracle.com/apps/cdm/foundation/parties/customerAccountService/" xmlns:ns1="http://xmlns.oracle.com/adf/svc/types/" xmlns:ns4="http://xmlns.oracle.com/apps/cdm/foundation/parties/partyService/" xmlns:tns="http://xmlns.oracle.com/adf/svc/errors/" xmlns:ns9="http://xmlns.oracle.com/apps/cdm/foundation/parties/flex/custAccount/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"> <ns2:Value> <ns2:PartyId>300000001263934</ns2:PartyId></ns2:Value></ns0:result></ns0:getCustomerAccountByOriginalSystemReferenceResponse></env:Body></env:Envelope>';
        FC_TestMockCallout.FC_TestEndPointMock customerServiceSOAPResponseMock = new FC_TestMockCallout.FC_TestEndPointMock(testCustomerAccountServiceResponseSOAP, 200);
        customerServiceSOAPResponseMock.setContentTypeXML();    //returns xml
        testMock.addEndpointMock('https://ebko-test.crm.us2.oraclecloud.com//foundationParties/CustomerAccountService', customerServiceSOAPResponseMock);

        String testProjectDefinitionResponseSOAP = '<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:wsa="http://www.w3.org/2005/08/addressing" xmlns:typ="http://xmlns.oracle.com/apps/projects/foundation/projectDefinition/publicService/maintainProjectV2/types/"> <env:Header> <wsa:Action>http://xmlns.oracle.com/apps/projects/foundation/projectDefinition/publicService/maintainProjectV2//ProjectDefinitionPublicService/createProjectResponse</wsa:Action> <wsa:MessageID>urn:uuid:4e5ac224-c181-4180-9447-4ca02b2c3b8c</wsa:MessageID> </env:Header> <env:Body> <ns0:createProjectResponse xmlns:ns0="http://xmlns.oracle.com/apps/projects/foundation/projectDefinition/publicService/maintainProjectV2/types/"> <ns3:result xsi:type="ns1:ProjectResult" xmlns:ns2="http://xmlns.oracle.com/apps/projects/foundation/projectDefinition/flex/ProjectDff/" xmlns:ns1="http://xmlns.oracle.com/apps/projects/foundation/projectDefinition/publicService/maintainProjectV2/" xmlns:ns3="http://xmlns.oracle.com/apps/projects/foundation/projectDefinition/publicService/maintainProjectV2/types/" xmlns:tns="http://xmlns.oracle.com/adf/svc/errors/" xmlns:ns0="http://xmlns.oracle.com/adf/svc/types/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"> <ns1:Value> <ns1:ClientKey>SFDC</ns1:ClientKey> <ns1:ClientProjectKey xsi:nil="true"/> <ns1:ProjectId>300000001380218</ns1:ProjectId> <ns1:ProjectNumber>221</ns1:ProjectNumber> <ns1:ProjectName>CRP2 BINGHAM PLUMBING &amp; PIPING INC. -</ns1:ProjectName> <ns1:ProjectDescription>CRP2 BINGHAM PLUMBING &amp; PIPING INC.</ns1:ProjectDescription> <ns1:StartDate>2015-04-10</ns1:StartDate> <ns1:EndDate>2016-04-08</ns1:EndDate> <ns1:TemplateKey>T30</ns1:TemplateKey> <ns1:ProjectStatus>300000001278209</ns1:ProjectStatus> <ns1:OwningOrganization>Manhattan Software(164)</ns1:OwningOrganization> <ns1:BusinessUnit>Americas Regional Fulfillment Center</ns1:BusinessUnit> <ns1:ProjectUnit>Americas Regional Fulfillment Center</ns1:ProjectUnit> <ns1:LegalEntity xsi:nil="true"/> <ns1:ProjectCcyCode>USD</ns1:ProjectCcyCode> <ns1:CcyConversionRateType>Corporate</ns1:CcyConversionRateType> <ns1:CcyConversionDateTypeCode>T</ns1:CcyConversionDateTypeCode> <ns1:CcyConversionDate xsi:nil="true"/> <ns1:ServiceType xsi:nil="true"/> <ns1:OutlineLevel xsi:nil="true"/> <ns1:IsPlanningProject>Y</ns1:IsPlanningProject> <ns1:ProjectPriorityCode xsi:nil="true"/> <ns1:ProjectTypeName>Client Implementation</ns1:ProjectTypeName> <ns1:WorkTypeName xsi:nil="true"/> <ns1:KPINotificationEnabled>N</ns1:KPINotificationEnabled> <ns1:KPINotificationIncludeNotes>N</ns1:KPINotificationIncludeNotes> <ns1:KPINotificationRecipients xsi:nil="true"/> <ns1:CintEligibleFlag xsi:nil="true"/> <ns1:CintRateSchName xsi:nil="true"/> <ns1:CintStopDate xsi:nil="true"/> <ns1:AssetAllocationMethodCode xsi:nil="true"/> <ns1:CapitalEventProcessingCode xsi:nil="true"/> <ns1:AllowCrossChargeFlag>true</ns1:AllowCrossChargeFlag> <ns1:CcProcessLaborFlag>false</ns1:CcProcessLaborFlag> <ns1:LaborTpScheduleName xsi:nil="true"/> <ns1:LaborTpFixedDate xsi:nil="true"/> <ns1:CcProcessNlFlag>false</ns1:CcProcessNlFlag> <ns1:NlTpScheduleName xsi:nil="true"/> <ns1:NlTpFixedDate xsi:nil="true"/> <ns1:ClosedDate xsi:nil="true"/> <ns1:LimitToTransactionControlsCode>N</ns1:LimitToTransactionControlsCode> <ns1:BurdenScheduleName xsi:nil="true"/> <ns1:BurdenSchFixedDate xsi:nil="true"/> <ns1:CreationDate>2015-04-28T23:33:04.574Z</ns1:CreationDate> <ns1:CreatedBy>WLEE</ns1:CreatedBy> <ns1:LastUpdateDate>2015-04-28T23:33:07.361Z</ns1:LastUpdateDate> <ns1:LastUpdatedBy>WLEE</ns1:LastUpdatedBy> <ns1:LastUpdateLogin>14D248A3FAFBDD70E053B4B7C80A18C6</ns1:LastUpdateLogin> <ns1:ObjectVersionNumber>2</ns1:ObjectVersionNumber> <ns1:ProjectManager xsi:nil="true"/> <ns1:ProjectManagerNumber xsi:nil="true"/> <ns1:ProjectManagerEmail xsi:nil="true"/> <ns1:UseTemplateTasksFlag xsi:nil="true"/> <ns1:OperationSuccessfulFlag>true</ns1:OperationSuccessfulFlag> <ns1:CopyTaskAttachmentsFlag xsi:nil="true"/> <ns1:CopyTaskDffsFlag xsi:nil="true"/> <ns1:CopyTaskAssignmentsFlag xsi:nil="true"/> <ns1:CopyTeamMembersFlag xsi:nil="true"/> <ns1:CopyAssetsFlag xsi:nil="true"/> <ns1:CopyAssetAssignmentsFlag xsi:nil="true"/> <ns1:CopyTransactionControlsFlag xsi:nil="true"/> <ns1:CopyGroupSpaceFlag xsi:nil="true"/> <ns1:CopyDffFlag xsi:nil="true"/> <ns1:CopyAttachmentsFlag xsi:nil="true"/> <ns1:CopyCostOverridesFlag xsi:nil="true"/> <ns1:ProjectDff> <ns2:ProjectId>300000001380218</ns2:ProjectId> <ns2:__FLEX_Context xsi:nil="true"/> <ns2:_FLEX_NumOfSegments>0</ns2:_FLEX_NumOfSegments> </ns1:ProjectDff> </ns1:Value> </ns3:result> </ns0:createProjectResponse> </env:Body></env:Envelope>';
        FC_TestMockCallout.FC_TestEndPointMock projectDefinitionResponseSOAPPResponseMock = new FC_TestMockCallout.FC_TestEndPointMock(testProjectDefinitionResponseSOAP, 200);
        projectDefinitionResponseSOAPPResponseMock.setContentTypeXML(); //returns xml
        testMock.addEndpointMock('https://ebko-test.prj.us2.oraclecloud.com//pjfProjectDefinition/ProjectDefinitionPublicServiceV2', projectDefinitionResponseSOAPPResponseMock);

        Test.setMock(HttpCalloutMock.class, testMock);

        PageReference testPage = Page.FC_SendToPPMFromAgreement;
        testPage.getParameters().put('id', testAgreement.Id);
        Test.setCurrentPage(testPage);
        ApexPages.StandardController standardController = new ApexPages.StandardController(testAgreement);
        FC_SendToPPMFromAgreementController controller = new FC_SendToPPMFromAgreementController(standardController);
        controller.sendToPPM();

        Test.stopTest();
        
    }
    
    private static void setup() {
        FC_TestDataGenerator.insertSetupData();
        
        Profile profile = [select Id from Profile where Name = 'System Administrator' limit 1];    
        
        User usr = new User();
        usr.Username = 'test-sysadmin@trimble.com';
        usr.Email = 'test@trimble.com';
        usr.LastName = 'Test';
        usr.Alias = 'Test123';
        usr.ProfileID = profile.Id;
        usr.LocaleSidKey = 'en_US';
        usr.LanguageLocaleKey = 'en_US';
        usr.Country = 'United States';
        usr.TimeZoneSidKey = 'America/Los_Angeles';
        usr.EmailEncodingKey='UTF-8';
        insert usr;
        
        //create fusion public service
        //ProjectDefinitionPublicServiceV2  for class FC_FusionProjectDefinitionPublicService
        insert new FusionServicesConfig__c(
            Name = 'ProjectDefinitionPublicServiceV2', 
            CurrencyIsoCode = 'USD', 
            Service_Path__c = '/pjfProjectDefinition/ProjectDefinitionPublicServiceV2', 
            Sub_Domain__c = 'prj'
        );

        //CustomerAccountService  for class FC_FusionCustomerAccountService
        insert new FusionServicesConfig__c(
            Name = 'CustomerAccountService', 
            CurrencyIsoCode = 'USD', 
            Service_Path__c = '/foundationParties/CustomerAccountService', 
            Sub_Domain__c = 'crm'
        );


        insert new Fusion_Configuration__c(
            Name = 'testFusion_Configuration__c', 
            CurrencyIsoCode = 'USD', 
            Endpoint__c = 'https://ebko-test.<subdomain>.us2.oraclecloud.com', 
            Password__c = 'randomFakePassword', 
            Username__c = 'randUsername',
            Timed_Out__c = 60000
        );
        
        //this is need for fusion configuration
        Object_Map__c[] objectMaps = new Object_Map__c[] {
            new Object_Map__c(
                Name = 'Proposal to Fusion Object', 
                Source_Object__c = 'Apttus_Proposal__Proposal__c', 
                CurrencyIsoCode = 'USD', 
                Target_Object__c = 'FC_FusionObject', 
                Source_Type__c = 'Salesforce', 
                Target_Type__c = 'Fusion'),
            new Object_Map__c(
                Name = 'Agreement to inProject', 
                Source_Object__c = 'Apttus__APTS_Agreement__c', 
                CurrencyIsoCode = 'USD', 
                Target_Object__c = 'FC_FusionObject', 
                Source_Type__c = 'Salesforce', 
                Target_Type__c = 'Fusion')
        };
        insert objectMaps;
        
        // insert field maps
        Field_Map__c[] fieldMaps = new Field_Map__c[]{
            new Field_Map__c(Object_Map__c = objectMaps[0].Id,
                Field_Type__c = 'String',
                Source_Field__c = 'Name',
                Target_Field__c = 'ProjectName'),
            new Field_Map__c(Object_Map__c = objectMaps[1].Id,
                Field_Type__c = 'String',
                Source_Field__c = 'Name',
                Target_Field__c = 'ProjectDescription'),
            new Field_Map__c(Object_Map__c = objectMaps[1].Id,
                Field_Type__c = 'String',
                Source_Field__c = 'Template_Key__c',
                Target_Field__c = 'TemplateKey')
        };
        insert fieldMaps;
        
        //add template for mapping
//         insert new PPM_Template_Map__c(
//          Name = 'T5', 
//          Business_Unit__c = 'Americas Regional', 
//          CurrencyIsoCode = 'USD', 
//          Template_Key__c = 'T5', 
//          Organization__c = 'MANHATTAN SOFTWARE', 
//          Project_Type__c = 'Client Implementation'
//         );
    }
}