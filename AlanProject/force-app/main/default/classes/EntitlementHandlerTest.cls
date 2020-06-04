/*****************************************************************************************
Name    : EntitlementHandlerTest 
Modification Log : 
---------------------------------------------------------------------------
Developer           Date            Description
---------------------------------------------------------------------------
Ankur Patel      03/12/2018          Created
******************************************************************************************/
@isTest(seealldata = true)
public class EntitlementHandlerTest {

    static testmethod void TestEntitlementHandler1(){
        GenerateTestData.createAccount();
        GenerateTestData.createContact();        
        GenerateTestData.createAsset();
        
        Product2 oProduct = new Product2();
        oProduct.Name = 'test';
        oProduct.isActive = true;
        oProduct.Product_Category_Type__c ='Subscription';
        oProduct.Contract_Item_Type_Code__c = 'WARRANTY';
        oProduct.Product_Line_Description__c = 'OMNISTAR';
        oProduct.ProductCode = 'OMNISTAR';
        oProduct.Business_Area__c ='OMNISTAR';
        oProduct.Family = 'Services';
        insert oProduct;
        
        test.startTest();
        Entitlement oEntitlement = new Entitlement();
        oEntitlement.Name = 'Test Entitlement';
        oEntitlement.Entitlement_Product__c = oProduct.Id;
        oEntitlement.AccountId = GenerateTestData.acct.Id;
        oEntitlement.AssetId = GenerateTestData.asst.Id;
        insert oEntitlement;
        
        EntitlementHandler.setLaunchControl();
        test.stopTest();
    }
    
    static testmethod void TestEntitlementHandler2(){
        GenerateTestData.createAccount();
        GenerateTestData.createAsset();
        
        Product2 oProduct = new Product2();
        oProduct.Name = 'test';
        oProduct.isActive = true;
        oProduct.Product_Category_Type__c ='Subscription';
        oProduct.Contract_Item_Type_Code__c = 'WARRANTY';
        oProduct.Product_Line_Description__c = 'OMNISTAR';
        oProduct.ProductCode = 'OMNISTAR';
        oProduct.Business_Area__c ='MEP BUILDING DATA';
        oProduct.Family = 'Services';
        insert oProduct;
        
        test.startTest();
        
        Opportunity oOpportunity = new Opportunity();
        oOpportunity.name = 'Test Opprtunity';
        oOpportunity.AccountId = GenerateTestData.acct.Id;
        oOpportunity.StageName = 'Inquery';
        oOpportunity.Closedate = date.today() + 7;
        oOpportunity.Service_Contract__c = 'abc';
        insert oOpportunity;
        
        Entitlement oEntitlement = new Entitlement();
        oEntitlement.Name = 'Test Entitlement';
        oEntitlement.Entitlement_Product__c = oProduct.Id;
        oEntitlement.AccountId = GenerateTestData.acct.Id;
        oEntitlement.AssetId = GenerateTestData.asst.Id;
        oEntitlement.Contract_Number__c = 'abc';
        oEntitlement.StartDate = date.today() - 1;
        oEntitlement.EndDate = date.today() + 1;
        oEntitlement.AssetId = GenerateTestData.asst.Id;
        insert oEntitlement;
        
        test.stopTest();
    }
}