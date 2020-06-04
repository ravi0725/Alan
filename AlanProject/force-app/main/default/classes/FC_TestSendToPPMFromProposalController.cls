@isTest
private class FC_TestSendToPPMFromProposalController {

    private static testmethod void testSendToPPM() {
        setup();
        User adminUser = [select Id from User where Username = 'test-sysadmin@trimble.com' limit 1];
		RecordType rt = [select Id from RecordType where Name = 'Master Saas Agreement' limit 1];

        Contact[] contacts = new Contact[] {
        	new Contact(
				LastName = 'Test last', 
				FirstName = 'Test first', 
				MailingStreet = '1 Main St',
				MailingCountry = 'United States', 
				Preferred_Language__c = 'American English',
				Salutation = 'Mr.'
            )
        };		
        Account[] accounts = FC_TestDataGenerator.generateAccounts();
        accounts[0].FCH_Party_ID__c = '300000001106393';
        accounts[0].Industry = 'Biotechnology';
        
        System.assertEquals(true, accounts.size() > 0);
        System.runAs(adminUser) {
            insert accounts;
            contacts[0].AccountId = accounts[0].Id;
            insert contacts;
            
            //attempt to fix AccountCreationCalloutEX error
            //Failed_Callout_Accounts__c failedAcct = new Failed_Callout_Accounts__c(Name = 'Test Account One', Account_id__c=accounts[0].Id);
        	//insert failedAcct;
        }
        Apttus_Config2__PriceList__c newCMConfigPriceList = new Apttus_Config2__PriceList__c(
			Apttus_Config2__EffectiveDate__c = Datetime.now(), 
			CurrencyIsoCode = 'USD', 
			Organization__c = 'Trimble Navigation Limited',
			Apttus_Config2__Active__c = true, 
			Apttus_Config2__Type__c = 'Standard', 
			Name = 'ARFC MANHATTAN PL16052015', 
			Oracle_ID__c = 765703.0, 
			Business_Area__c = 'MANHATTAN SOFTWARE', 						//this must match PPM_Template_Map__c
			Apttus_Config2__Description__c = 'ARFC MANHATTAN PL16052015'
        );
        insert newCMConfigPriceList;
        
        //create Quote/Proposal
        //first create opportunity
        Opportunity newTestOpportunity = new Opportunity(
        	Name = 'test Opportunity',
        	AccountId = accounts[0].Id,
        	StageName = '4 - Proposal/Price Quote',
        	CurrencyIsoCode = 'USD',
        	CloseDate = Date.today()
        );
        insert newTestOpportunity;
        Apttus_Proposal__Proposal__c[] proposals = new Apttus_Proposal__Proposal__c []{
        	new Apttus_Proposal__Proposal__c(
				Apttus_Proposal__Approval_Stage__c =  'Draft' , 
				Recalculate_tax__c =  false , 
				Software_Total_Disp_Rounded__c =  0.0 , 
				Third_Party_Disc_Disp_Rounded__c =  0.0 , 
				Hardware_Discount_Disp_Rounded__c =  0.0 , 
				Apttus_Proposal__ReadyToPresent__c =  true , 
				Hardware_Total_Disp_Rounded__c =  0.0 , 
				Apttus_Proposal__ReadyToGenerate__c =  true , 
				Apttus_Proposal__Account__c =  accounts[0].Id , 
				Apttus_QPConfig__AutoActivateOrder__c =  false , 
				Service_Total_Disp_Rounded__c =  0.0 , 
				Apttus_Proposal__Primary__c =  true , 
				Apttus_QPConfig__PriceListId__c =  newCMConfigPriceList.Id , 
				Obsolete_Quote__c =  false , 
				is_Order__c =  false , 
				Final_Config__c =  false , 
				Apttus_QPConfig__PricingDate__c =  Datetime.now() , 
				Maintenance_Total_Disp_Rounded__c =  0.0 , 
				Software_Disc_Disp_Rounded__c =  0.0 , 
				Apttus_QPConfig__AutoCreateRevenue__c =  false , 
				Schulung_Basis_Gewerke__c =  true , 
				Schulung_Basis_CAD__c =  true , 
				Standard_T_Cs__c =  true , 
				Ship_To_Account__c =  accounts[0].Id , 
				Software_Only_Total_Disp_Rounded__c =  0.0 , 
				Payment_Terms_In_Opportunity__c =  'IMMEDIATE' , 
				CurrencyIsoCode =  'USD' , 
				Include_Pricing_Details__c =  false , 
				Schulung_Raumlufttechnik_K_hllast__c =  true , 
				Third_Party_Total_Disp_Rounded__c =  0.0 , 
				Clone_ID__c =  'Q-00017567' , 
				Apttus_Proposal__Primary_Contact__c =  contacts[0].Id , 
				Custom_T_C__c =  false , 
				Apttus_Proposal__Valid_Until_Date__c =  Date.today() , 
				Apttus_Proposal__Proposal_Name__c =  'Customer#1 -' , 
				Service_Discount_Disp_Rounded__c =  0.0 , 
				Apttus_Proposal__Opportunity__c =  newTestOpportunity.Id ,		//required to match currency code 
				Accept_Auto_Renew__c =  true , 
				Schulung_Sanit_rtechnik__c =  true , 
				Schulung_Elektro__c =  true , 
				Software_Disc_2dec_Rounded__c =  0.0 , 
				Apttus_QPConfig__AutoCreateBill__c =  false 
        	)
        };
        insert proposals;

        Test.startTest();
        
        FC_TestMockCallout testMock = new FC_TestMockCallout();
        String testCustomerAccountServiceResponseSOAP = '<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:wsa="http://www.w3.org/2005/08/addressing"> <env:Header> <wsa:Action>http://xmlns.oracle.com/apps/cdm/foundation/parties/customerAccountService/applicationModule//CustomerAccountService/findCustomerAccountResponse</wsa:Action> <wsa:MessageID>urn:uuid:9fcc0c15-666b-4148-ba20-fd3213d72aa4</wsa:MessageID> </env:Header> <env:Body> <ns0:findCustomerAccountResponse xmlns:ns0="http://xmlns.oracle.com/apps/cdm/foundation/parties/customerAccountService/applicationModule/types/"> <ns0:result xsi:type="ns2:CustomerAccountResult" xmlns:ns2="http://xmlns.oracle.com/apps/cdm/foundation/parties/customerAccountService/" xmlns:ns1="http://xmlns.oracle.com/adf/svc/types/" xmlns:ns4="http://xmlns.oracle.com/apps/cdm/foundation/parties/partyService/" xmlns:tns="http://xmlns.oracle.com/adf/svc/errors/" xmlns:ns9="http://xmlns.oracle.com/apps/cdm/foundation/parties/flex/custAccount/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"> <ns2:Value> <ns2:CustomerAccountId>300000001106394</ns2:CustomerAccountId> <ns2:PartyId>300000001106393</ns2:PartyId> <ns2:LastUpdateDate>2015-03-18T18:16:33.0Z</ns2:LastUpdateDate> <ns2:AccountNumber>8003</ns2:AccountNumber> <ns2:LastUpdatedBy>BRAYUDU</ns2:LastUpdatedBy> <ns2:CreationDate>2015-03-18T17:48:05.134Z</ns2:CreationDate> <ns2:CreatedBy>BRAYUDU</ns2:CreatedBy> <ns2:LastUpdateLogin>11927600CBBD8FBCE053B4B7C80AF5CC</ns2:LastUpdateLogin> <ns2:RequestId xsi:nil="true"/> <ns2:OrigSystem xsi:nil="true"/> <ns2:OrigSystemReference>300000001106394</ns2:OrigSystemReference> <ns2:Status>A</ns2:Status> <ns2:CustomerType>R</ns2:CustomerType> <ns2:CustomerClassCode>PUBLIC SECTOR COMPANIES</ns2:CustomerClassCode> <ns2:TaxCode xsi:nil="true"/> <ns2:TaxHeaderLevelFlag xsi:nil="true"/> <ns2:TaxRoundingRule xsi:nil="true"/> <ns2:CoterminateDayMonth xsi:nil="true"/> <ns2:AccountEstablishedDate>2015-03-18</ns2:AccountEstablishedDate> <ns2:AccountTerminationDate>4712-12-31</ns2:AccountTerminationDate> <ns2:HeldBillExpirationDate xsi:nil="true"/> <ns2:HoldBillFlag>false</ns2:HoldBillFlag> <ns2:AccountName>BestBuy Test Customer</ns2:AccountName> <ns2:DepositRefundMethod xsi:nil="true"/> <ns2:NpaNumber xsi:nil="true"/> <ns2:SourceCode xsi:nil="true"/> <ns2:Comments xsi:nil="true"/> <ns2:DateTypePreference xsi:nil="true"/> <ns2:ArrivalsetsIncludeLinesFlag xsi:nil="true"/> <ns2:StatusUpdateDate xsi:nil="true"/> <ns2:AutopayFlag xsi:nil="true"/> <ns2:LastBatchId xsi:nil="true"/> <ns2:CreatedByModule>TCA_FORM_WRAPPER</ns2:CreatedByModule> <ns2:SellingPartyId xsi:nil="true"/> </ns2:Value> </ns0:result> </ns0:findCustomerAccountResponse> </env:Body> </env:Envelope>';
        FC_TestMockCallout.FC_TestEndPointMock customerServiceSOAPResponseMock = new FC_TestMockCallout.FC_TestEndPointMock(testCustomerAccountServiceResponseSOAP, 200);
        customerServiceSOAPResponseMock.setContentTypeXML();	//returns xml
		testMock.addEndpointMock('https://ebko-test.crm.us2.oraclecloud.com//foundationParties/CustomerAccountService', customerServiceSOAPResponseMock);

        String testProjectDefinitionResponseSOAP = '<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:wsa="http://www.w3.org/2005/08/addressing" xmlns:typ="http://xmlns.oracle.com/apps/projects/foundation/projectDefinition/publicService/maintainProjectV2/types/"> <env:Header> <wsa:Action>http://xmlns.oracle.com/apps/projects/foundation/projectDefinition/publicService/maintainProjectV2//ProjectDefinitionPublicService/createProjectResponse</wsa:Action> <wsa:MessageID>urn:uuid:4e5ac224-c181-4180-9447-4ca02b2c3b8c</wsa:MessageID> </env:Header> <env:Body> <ns0:createProjectResponse xmlns:ns0="http://xmlns.oracle.com/apps/projects/foundation/projectDefinition/publicService/maintainProjectV2/types/"> <ns3:result xsi:type="ns1:ProjectResult" xmlns:ns2="http://xmlns.oracle.com/apps/projects/foundation/projectDefinition/flex/ProjectDff/" xmlns:ns1="http://xmlns.oracle.com/apps/projects/foundation/projectDefinition/publicService/maintainProjectV2/" xmlns:ns3="http://xmlns.oracle.com/apps/projects/foundation/projectDefinition/publicService/maintainProjectV2/types/" xmlns:tns="http://xmlns.oracle.com/adf/svc/errors/" xmlns:ns0="http://xmlns.oracle.com/adf/svc/types/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"> <ns1:Value> <ns1:ClientKey>SFDC</ns1:ClientKey> <ns1:ClientProjectKey xsi:nil="true"/> <ns1:ProjectId>300000001380218</ns1:ProjectId> <ns1:ProjectNumber>221</ns1:ProjectNumber> <ns1:ProjectName>CRP2 BINGHAM PLUMBING &amp; PIPING INC. -</ns1:ProjectName> <ns1:ProjectDescription>CRP2 BINGHAM PLUMBING &amp; PIPING INC.</ns1:ProjectDescription> <ns1:StartDate>2015-04-10</ns1:StartDate> <ns1:EndDate>2016-04-08</ns1:EndDate> <ns1:TemplateKey>T30</ns1:TemplateKey> <ns1:ProjectStatus>300000001278209</ns1:ProjectStatus> <ns1:OwningOrganization>Manhattan Software(164)</ns1:OwningOrganization> <ns1:BusinessUnit>Americas Regional Fulfillment Center</ns1:BusinessUnit> <ns1:ProjectUnit>Americas Regional Fulfillment Center</ns1:ProjectUnit> <ns1:LegalEntity xsi:nil="true"/> <ns1:ProjectCcyCode>USD</ns1:ProjectCcyCode> <ns1:CcyConversionRateType>Corporate</ns1:CcyConversionRateType> <ns1:CcyConversionDateTypeCode>T</ns1:CcyConversionDateTypeCode> <ns1:CcyConversionDate xsi:nil="true"/> <ns1:ServiceType xsi:nil="true"/> <ns1:OutlineLevel xsi:nil="true"/> <ns1:IsPlanningProject>Y</ns1:IsPlanningProject> <ns1:ProjectPriorityCode xsi:nil="true"/> <ns1:ProjectTypeName>Client Implementation</ns1:ProjectTypeName> <ns1:WorkTypeName xsi:nil="true"/> <ns1:KPINotificationEnabled>N</ns1:KPINotificationEnabled> <ns1:KPINotificationIncludeNotes>N</ns1:KPINotificationIncludeNotes> <ns1:KPINotificationRecipients xsi:nil="true"/> <ns1:CintEligibleFlag xsi:nil="true"/> <ns1:CintRateSchName xsi:nil="true"/> <ns1:CintStopDate xsi:nil="true"/> <ns1:AssetAllocationMethodCode xsi:nil="true"/> <ns1:CapitalEventProcessingCode xsi:nil="true"/> <ns1:AllowCrossChargeFlag>true</ns1:AllowCrossChargeFlag> <ns1:CcProcessLaborFlag>false</ns1:CcProcessLaborFlag> <ns1:LaborTpScheduleName xsi:nil="true"/> <ns1:LaborTpFixedDate xsi:nil="true"/> <ns1:CcProcessNlFlag>false</ns1:CcProcessNlFlag> <ns1:NlTpScheduleName xsi:nil="true"/> <ns1:NlTpFixedDate xsi:nil="true"/> <ns1:ClosedDate xsi:nil="true"/> <ns1:LimitToTransactionControlsCode>N</ns1:LimitToTransactionControlsCode> <ns1:BurdenScheduleName xsi:nil="true"/> <ns1:BurdenSchFixedDate xsi:nil="true"/> <ns1:CreationDate>2015-04-28T23:33:04.574Z</ns1:CreationDate> <ns1:CreatedBy>WLEE</ns1:CreatedBy> <ns1:LastUpdateDate>2015-04-28T23:33:07.361Z</ns1:LastUpdateDate> <ns1:LastUpdatedBy>WLEE</ns1:LastUpdatedBy> <ns1:LastUpdateLogin>14D248A3FAFBDD70E053B4B7C80A18C6</ns1:LastUpdateLogin> <ns1:ObjectVersionNumber>2</ns1:ObjectVersionNumber> <ns1:ProjectManager xsi:nil="true"/> <ns1:ProjectManagerNumber xsi:nil="true"/> <ns1:ProjectManagerEmail xsi:nil="true"/> <ns1:UseTemplateTasksFlag xsi:nil="true"/> <ns1:OperationSuccessfulFlag>true</ns1:OperationSuccessfulFlag> <ns1:CopyTaskAttachmentsFlag xsi:nil="true"/> <ns1:CopyTaskDffsFlag xsi:nil="true"/> <ns1:CopyTaskAssignmentsFlag xsi:nil="true"/> <ns1:CopyTeamMembersFlag xsi:nil="true"/> <ns1:CopyAssetsFlag xsi:nil="true"/> <ns1:CopyAssetAssignmentsFlag xsi:nil="true"/> <ns1:CopyTransactionControlsFlag xsi:nil="true"/> <ns1:CopyGroupSpaceFlag xsi:nil="true"/> <ns1:CopyDffFlag xsi:nil="true"/> <ns1:CopyAttachmentsFlag xsi:nil="true"/> <ns1:CopyCostOverridesFlag xsi:nil="true"/> <ns1:ProjectDff> <ns2:ProjectId>300000001380218</ns2:ProjectId> <ns2:__FLEX_Context xsi:nil="true"/> <ns2:_FLEX_NumOfSegments>0</ns2:_FLEX_NumOfSegments> </ns1:ProjectDff> </ns1:Value> </ns3:result> </ns0:createProjectResponse> </env:Body></env:Envelope>';
        FC_TestMockCallout.FC_TestEndPointMock projectDefinitionResponseSOAPPResponseMock = new FC_TestMockCallout.FC_TestEndPointMock(testProjectDefinitionResponseSOAP, 200);
        projectDefinitionResponseSOAPPResponseMock.setContentTypeXML();	//returns xml
		testMock.addEndpointMock('https://ebko-test.prj.us2.oraclecloud.com//pjfProjectDefinition/ProjectDefinitionPublicServiceV2', projectDefinitionResponseSOAPPResponseMock);

		Test.setMock(HttpCalloutMock.class, testMock);


        PageReference testPage = Page.FC_SendToPPMFromAgreement;
        testPage.getParameters().put('id', proposals[0].Id);
        Test.setCurrentPage(testPage);
        ApexPages.StandardController standardController = new ApexPages.StandardController(proposals[0]);
        FC_SendToPPMFromProposalController controller = new FC_SendToPPMFromProposalController(standardController);
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
        
        //add template for mapping
//         insert new PPM_Template_Map__c(
// 			Name = 'T5', 
// 			Business_Unit__c = 'Americas Regional', 
// 			CurrencyIsoCode = 'USD', 
// 			Template_Key__c = 'T5', 
// 			Organization__c = 'MANHATTAN SOFTWARE', 
// 			Project_Type__c = 'Client Implementation'
//         );
    }
}