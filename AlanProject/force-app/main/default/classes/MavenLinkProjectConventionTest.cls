/*****************************************************************************************
Name        : MavenLinkProjectConventionTest
Desc        : Test class for MavenLinkProjectConvention   
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
Ankur Patel           15/05/2019          Created
******************************************************************************************/
@isTest
public class MavenLinkProjectConventionTest{
    public static opportunity oOpportunity1;
    public static opportunity oOpportunity2;
    /*
    * Test Method for RE$WS Mavenlink project
    */
    static testMethod void TestMavenLinkProjectConvention1() {
        generateTestData();
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new MockMavenLinkProjectConvention());
            MavenLinkProjectConvention.createMavenLinkProject(oOpportunity1.Id, oOpportunity1.Selling_Division__c);
            MavenLinkProjectConvention.updateOpportunity(oOpportunity1.Id, '25153655' , oOpportunity1.Selling_Division__c, '83-2323233', '83-2323233');
            MavenLinkProjectConvention.getLocation('83|1381404' , '83');
        Test.stopTest();
    }
    
    /*
    * Test Method for RE$WS Mavenlink GCCM
    */
    static testMethod void TestMavenLinkProjectConvention2() {
        generateTestData();
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockMavenLinkProjectConvention());
            MavenLinkProjectConvention.createMavenLinkProject(oOpportunity2.Id, oOpportunity2.Selling_Division__c);
            MavenLinkProjectConvention.updateOpportunity(oOpportunity2.Id, '25153655' , oOpportunity2.Selling_Division__c, '83-2323233', '83-2323233');
            MavenLinkProjectConvention.getLocation('83|1381404' , '83');
        Test.stopTest();
    }
    
    static testMethod void TestMavenLinkProjectConvention3() {
        generateTestData();
        Test.startTest();
            MavenLinkProjectConvention.createMavenLinkProject(oOpportunity1.Id, oOpportunity1.Selling_Division__c);
            MavenLinkProjectConvention.updateOpportunity(oOpportunity1.Id, '25153655' , oOpportunity1.Selling_Division__c, '83-2323233', '83-2323233');
            MavenLinkProjectConvention.getLocation('83|1381404' , '83');
        Test.stopTest();
    }
    
    /*
    * Method to generate test data 
    */
    public static void generateTestData() 
    {
        Object_Map__c oObjectMap = new Object_Map__c();
        oObjectMap.Name = 'MavenLinkProject-GCCM';
        oObjectMap.Source_Type__c = 'Salesforce';
        oObjectMap.Source_Object__c = 'H';
        oObjectMap.Target_Type__c = 'MavenLink';
        oObjectMap.Target_Object__c = 'Opportunity';
        oObjectMap.Required_Fields__c = 'title,creator_role,Business Area, ProjectDescription';
        insert oObjectMap;
        
        List<Field_Map__c> lstFieldMaps = new List<Field_Map__c>();
        // condition 8 - Note NULL
        Field_Map__c ofieldMap = new Field_Map__c();
        ofieldMap.Target_Field__c = 'ProjectDescription';
        ofieldMap.Object_Map__c = oObjectMap.id;
        ofieldMap.Source_Field__c = 'ProjectDescription';
        ofieldMap.CustomLogic__c = true;
        ofieldMap.Note__c = '';
        ofieldMap.Reference_Field__c = 'ProjectDescription';
        ofieldMap.Unique_Identifier__c = false;
        ofieldMap.Default_Value__c = '';
        ofieldMap.Reference_Query__c = '';
        lstFieldMaps.add(ofieldMap);
        
        // condition 4 - Note NOT NULL
        ofieldMap = new Field_Map__c();
        ofieldMap.Target_Field__c = 'creator_role';
        ofieldMap.Object_Map__c = oObjectMap.id;
        ofieldMap.Source_Field__c = 'creator_role';
        ofieldMap.CustomLogic__c = true;
        ofieldMap.Note__c = 'Standard Attribute';
        ofieldMap.Reference_Field__c = 'creator_role';
        ofieldMap.Unique_Identifier__c = false;
        ofieldMap.Default_Value__c = '';
        ofieldMap.Reference_Query__c = '';
        lstFieldMaps.add(ofieldMap);
        
        // condition 5 - Note NULL
        ofieldMap = new Field_Map__c();
        ofieldMap.Target_Field__c = 'Competitor_Description__c';
        ofieldMap.Object_Map__c = oObjectMap.id;
        ofieldMap.Source_Field__c = 'Competitor_Description__c';
        ofieldMap.CustomLogic__c = false;
        ofieldMap.Note__c = '';
        ofieldMap.Reference_Field__c = 'Competitor_Description__c';
        ofieldMap.Unique_Identifier__c = false;
        ofieldMap.Default_Value__c = 'default 1';
        ofieldMap.Reference_Query__c = '';
        lstFieldMaps.add(ofieldMap);
        
        // condition 6 - Note NULL
        ofieldMap = new Field_Map__c();
        ofieldMap.Target_Field__c = 'Invoice_Number__c';
        ofieldMap.Object_Map__c = oObjectMap.id;
        ofieldMap.Source_Field__c = 'Invoice_Number__c';
        ofieldMap.CustomLogic__c = false;
        ofieldMap.Note__c = '';
        ofieldMap.Reference_Field__c = 'Invoice_Number__c';
        ofieldMap.Unique_Identifier__c = false;
        ofieldMap.Default_Value__c = '';
        ofieldMap.Reference_Query__c = '';
        lstFieldMaps.add(ofieldMap);
        
        // condition 7 - Note NULL
        ofieldMap = new Field_Map__c();
        ofieldMap.Target_Field__c = 'sCustomer';
        ofieldMap.Object_Map__c = oObjectMap.id;
        ofieldMap.Source_Field__c = 'sCustomer';
        ofieldMap.CustomLogic__c = true;
        ofieldMap.Note__c = '';
        ofieldMap.Reference_Field__c = 'sCustomer';
        ofieldMap.Unique_Identifier__c = false;
        ofieldMap.Default_Value__c = '';
        ofieldMap.Reference_Query__c = '';
		lstFieldMaps.add(ofieldMap);
        
        // condition 1 - Note NOT NULL
        ofieldMap = new Field_Map__c();
        ofieldMap.Target_Field__c = 'Business_Area__c';
        ofieldMap.Object_Map__c = oObjectMap.id;
        ofieldMap.Source_Field__c = 'Business_Area__c';
        ofieldMap.CustomLogic__c = false;
        ofieldMap.Note__c = 'Standard Attribute';
        ofieldMap.Reference_Field__c = 'Business_Area__c';
        ofieldMap.Unique_Identifier__c = false;
        ofieldMap.Default_Value__c = 'Default';
        ofieldMap.Reference_Query__c = '';
        lstFieldMaps.add(ofieldMap);
        
        // condition 2 - Note NOT NULL
        ofieldMap = new Field_Map__c();
        ofieldMap.Target_Field__c = 'Closed_Lost_Reason_Detail__c';
        ofieldMap.Object_Map__c = oObjectMap.id;
        ofieldMap.Source_Field__c = 'Closed_Lost_Reason_Detail__c';
        ofieldMap.CustomLogic__c = false;
        ofieldMap.Note__c = 'Standard Attribute';
        ofieldMap.Reference_Field__c = 'Closed_Lost_Reason_Detail__c';
        ofieldMap.Unique_Identifier__c = false;
        ofieldMap.Default_Value__c = '';
        ofieldMap.Reference_Query__c = '';
        lstFieldMaps.add(ofieldMap);
        
        // condition 3 - Note NOT NULL
        ofieldMap = new Field_Map__c();
        ofieldMap.Target_Field__c = 'sSellingDivision';
        ofieldMap.Object_Map__c = oObjectMap.id;
        ofieldMap.Source_Field__c = 'sSellingDivision';
        ofieldMap.CustomLogic__c = true;
        ofieldMap.Note__c = 'Standard Attribute';
        ofieldMap.Reference_Field__c = 'sSellingDivision';
        ofieldMap.Unique_Identifier__c = false;
        ofieldMap.Default_Value__c = '';
        ofieldMap.Reference_Query__c = '';
        lstFieldMaps.add(ofieldMap);
        insert lstFieldMaps;
        
        List<System_Integration_Config__c> lstSystemIntegrationConfigs = new List<System_Integration_Config__c>();
        System_Integration_Config__c oSystemIntegrationConfig = new System_Integration_Config__c();
        oSystemIntegrationConfig.Name = 'MavenLinkProject-GCCM';
        oSystemIntegrationConfig.End_Point_URL__c   = 'https://api.mavenlink.com/api/v1/workspaces.json';
        oSystemIntegrationConfig.Password__c = '12345';
        oSystemIntegrationConfig.User_Name__c = '';
        lstSystemIntegrationConfigs.add(oSystemIntegrationConfig);
        
        oSystemIntegrationConfig = new System_Integration_Config__c();
        oSystemIntegrationConfig.Name = 'MavenLinkProject-RE&WS';
        oSystemIntegrationConfig.End_Point_URL__c   = 'https://api.mavenlink.com/api/v1/workspaces.json';
        oSystemIntegrationConfig.Password__c = '23456';
        oSystemIntegrationConfig.User_Name__c = '';
        lstSystemIntegrationConfigs.add(oSystemIntegrationConfig);
        insert lstSystemIntegrationConfigs;
        
        Country_Region_Mapping__c oCountryRegionMapping = new Country_Region_Mapping__c();
        oCountryRegionMapping.Name = 'UNITED STATES';
        oCountryRegionMapping.Region__c = 'North America';
        oCountryRegionMapping.TAPLanguage__c = 'E_AM';
        oCountryRegionMapping.TAP_Region__c = 'AMERICA';
        insert oCountryRegionMapping;
        
        Country_To_BU_Map__c oCountryBUMap = new Country_To_BU_Map__c();
        oCountryBUMap.Name = 'United States';
        oCountryBUMap.Business_Unit__c = 'Americas Regional Fulfillment Center';
        oCountryBUMap.Legal_Entity__c = 'Trimble Inc.';
        oCountryBUMap.Operating_Unit__c = '83';
        oCountryBUMap.Owning_Org__c = '100';
        insert oCountryBUMap;
        
        Geospatial_Country_Region_Mapping__c oGeospatialCountryRegionMapping = new Geospatial_Country_Region_Mapping__c();
        oGeospatialCountryRegionMapping.Name = 'UNITED STATES';
        oGeospatialCountryRegionMapping.Region__c = 'North America';
        oGeospatialCountryRegionMapping.TAP_Region__c = '';
        insert oGeospatialCountryRegionMapping;
        
        Account oAccount = new Account();
        oAccount.Name = 'Test Account';
        oAccount.Email__c = 'test@gmail.com';
        oAccount.BillingCountry = 'United States';
        oAccount.EBS_Account_Number__c = 'ebs123456';
        insert oAccount;
        
        Contact oContact = new Contact();
        oContact.LastName = 'Contact last name';
        oContact.Email = 'contact@gmail.com';
        insert oContact;
        
        Address__c oAddress = new Address__c();
        oAddress.Name = 'Test Address';
        oAddress.Account__c = oAccount.id;
        oAddress.Bill_To_Location__c = '83-1381404';
        oAddress.Ship_To_Location__c = '83-1381404';
        insert oAddress;
        
        List<Opportunity> lstOpportunities = new List<Opportunity>();
        oOpportunity1 = new Opportunity();
        oOpportunity1.Name = 'Test Opportunity';
        oOpportunity1.AccountId = oAccount.id;
        oOpportunity1.StageName = 'Qualification';
        oOpportunity1.CloseDate = date.today() + 7;
        oOpportunity1.Amount = 100;
        oOpportunity1.Legal_Entity__c = 'Trimble Inc.';
        oOpportunity1.Selling_Division__c = 'RE&WS';
        oOpportunity1.Closed_Lost_Reason_Detail__c = 'Closed lost';
        oOpportunity1.Invoice_Number__c = '2123dfg234';
        oOpportunity1.Bill_To_Contact__c = oContact.id;
        oOpportunity1.Bill_to_Address__c =  oAddress.id;
        oOpportunity1.Ship_to_Address1__c = oAddress.id;
        lstOpportunities.add(oOpportunity1);

        
       	oOpportunity2 = new Opportunity();
        oOpportunity2.Name = 'Test Opportunity 1';
        oOpportunity2.AccountId = oAccount.id;
        oOpportunity2.StageName = 'Qualification';
        oOpportunity2.CloseDate = date.today() + 7;
        oOpportunity2.Amount = 100;
        oOpportunity2.Legal_Entity__c = 'Trimble Inc.';
        oOpportunity2.Selling_Division__c = 'GCCM';
        oOpportunity2.Closed_Lost_Reason_Detail__c = 'Closed lost';
        oOpportunity2.Invoice_Number__c = '2123dfg234';
        oOpportunity2.Bill_To_Contact__c = oContact.id;
        oOpportunity2.Bill_to_Address__c =  oAddress.id;
        oOpportunity2.Ship_to_Address1__c = oAddress.id;
        lstOpportunities.add(oOpportunity2);
        insert lstOpportunities;
    }
}