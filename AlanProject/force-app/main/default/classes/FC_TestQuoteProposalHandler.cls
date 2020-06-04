@isTest
private class FC_TestQuoteProposalHandler {
    static testMethod void testQuoteProposalHandler() {
        
        User adminUser = [select Id from User where Username = 'test-sysadmin@trimble.com' limit 1];
        RecordType rt = [select Id from RecordType where Name = 'Master Saas Agreement' limit 1];
        
        List<Country_To_BU_Map__c> custBUList = new List<Country_To_BU_Map__c>();
        Country_To_BU_Map__c custBUMap1 = new Country_To_BU_Map__c(name='Rest of World',Business_Unit__c='European Regional Fulfillment Center', Legal_Entity__c='Trimble Europe B.V.');
        Country_To_BU_Map__c custBUMap2 = new Country_To_BU_Map__c(name='United States',Business_Unit__c='Americas Regional Fulfillment Center', Legal_Entity__c='Trimble Inc.');
        custBUList.add(custBUMap1);
        custBUList.add(custBUMap2);
        insert custBUList;
        
        Account[] accounts = new Account[] {
            new Account(Name = 'Test Account One', 
                BillingCity = 'New York',
                BillingCountry = 'United States',
                BillingState = 'NY',
                BillingStreet ='San Jose',
				BillingPostalCode = '94089',
                FCH_Party_ID__c = '300000001106393',        //match the soap party id
                Industry = 'Biotechnology')
        };
        System.assertEquals(true, accounts.size() > 0);
        System.runAs(adminUser) {
            insert accounts;
        }
        
        Address__c adrs = new Address__c(
            Name = 'Test Account One', 
            Account__c = accounts[0].Id, 
            Country__c = 'United States',
            Bill_To__c = true,
            Ship_To__c=true,
            Address_Line1__c = 'San Jose',
            City__c = 'New York',
            State__c = 'NY',
            Zip__c = '94089');
		insert adrs;
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
        //proposal.Revenue_Arrangement_Number__c = '123456';
        proposal.Bill_to_Address__c = adrs.Id;
        proposal.Ship_to_Address1__c = adrs.Id;
        insert proposal;
        
        Apttus__APTS_Agreement__c[] agreements = new Apttus__APTS_Agreement__c[]{
            //force to match the PPM_Template_Map__c
            new Apttus__APTS_Agreement__c(Name = 'test',
                    Apttus__Account__c = accounts[0].Id,
                    RecordTypeId = rt.Id,
                    Apttus_CMConfig__PriceListId__c = newCMConfigPriceList.Id,
                    Business_Unit__c = 'Americas Regional',
                    Apttus__Contract_Start_Date__c = Date.today(),
                    Apttus_QPComply__RelatedProposalId__c = proposal.Id,
                    Apttus__Status_Category__c = 'Request',
                    Apttus__Status__c = 'Request',
                    Fusion_Project_Id__c = '1234',
                    Template_Key__c = 'T5')
        };
        insert agreements;
        
        FC_TestMockCallout testMock = new FC_TestMockCallout(); 
        
        String testGetProjectDefinitionResponseSOAP = '<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:wsa="http://www.w3.org/2005/08/addressing" xmlns:typ="http://xmlns.oracle.com/apps/projects/foundation/projectDefinition/publicService/maintainProjectV2/types/"> <env:Header> <wsa:Action>http://xmlns.oracle.com/apps/projects/foundation/projectDefinition/publicService/maintainProjectV2//ProjectDefinitionPublicService/getProjectResponse</wsa:Action> <wsa:MessageID>urn:uuid:b437fe91-6ca3-412a-9730-400f069e3931</wsa:MessageID> </env:Header> <env:Body> <ns0:getProjectResponse xmlns:ns0="http://xmlns.oracle.com/apps/projects/foundation/projectDefinition/publicService/maintainProjectV2/types/"> <ns3:result xsi:type="ns1:Project" xmlns:ns2="http://xmlns.oracle.com/apps/projects/foundation/projectDefinition/flex/ProjectDff/" xmlns:ns1="http://xmlns.oracle.com/apps/projects/foundation/projectDefinition/publicService/maintainProjectV2/" xmlns:ns3="http://xmlns.oracle.com/apps/projects/foundation/projectDefinition/publicService/maintainProjectV2/types/" xmlns:ns0="http://xmlns.oracle.com/adf/svc/types/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"> <ns1:ClientKey>SFDC</ns1:ClientKey> <ns1:ClientProjectKey xsi:nil="true"/> <ns1:ProjectId>300000006024495</ns1:ProjectId> <ns1:ProjectNumber>00000911</ns1:ProjectNumber> <ns1:ProjectName>INT Go Wireless -  - 00000911</ns1:ProjectName> <ns1:ProjectDescription>Quote Number: Q-00019100;Revenue Arrangement Number: Q-00019100</ns1:ProjectDescription> <ns1:StartDate>2015-06-17</ns1:StartDate> <ns1:EndDate>2015-12-31</ns1:EndDate> <ns1:TemplateKey>T-102</ns1:TemplateKey> <ns1:ProjectStatus>APPROVED</ns1:ProjectStatus> <ns1:OwningOrganization>MANHATTAN SOFTWARE (US-164)</ns1:OwningOrganization> <ns1:BusinessUnit>Americas Regional Fulfillment Center</ns1:BusinessUnit> <ns1:ProjectUnit>Americas Regional Fulfillment Center Project Operations</ns1:ProjectUnit> <ns1:LegalEntity xsi:nil="true"/> <ns1:ProjectDff> <ns2:ProjectId>300000006024495</ns2:ProjectId> <ns2:projectDetail xsi:nil="true"/> <ns2:__FLEX_Context xsi:nil="true"/> <ns2:_FLEX_NumOfSegments>1</ns2:_FLEX_NumOfSegments> </ns1:ProjectDff> </ns3:result> </ns0:getProjectResponse> </env:Body> </env:Envelope>';
        FC_TestMockCallout.FC_TestEndPointMock projectDefinitionResponseSOAPPResponseMock = new FC_TestMockCallout.FC_TestEndPointMock(testGetProjectDefinitionResponseSOAP, 200);
        projectDefinitionResponseSOAPPResponseMock.setContentTypeXML(); //returns xml
        testMock.addEndpointMock('https://ebko-test.prj.us2.oraclecloud.com//pjfProjectDefinition/ProjectDefinitionPublicServiceV2', projectDefinitionResponseSOAPPResponseMock);

        Test.setMock(HttpCalloutMock.class, testMock);
        
        proposal.Revenue_Arrangement_Number__c = '1234567';
        update proposal;
        
        // Initiate Testing
        system.Test.startTest();
        FC_QuoteProposalHandler.updatePPM(proposal.Id);
        system.Test.stopTest();
    }
    
    @testSetup
    static void setup() {
        
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
    }
}