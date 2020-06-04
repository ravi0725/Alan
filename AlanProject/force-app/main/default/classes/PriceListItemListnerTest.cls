/*****************************************************************************************
Name    : PriceListItemListnerTest 
Modification Log : 
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
Ankur Patel       25/04/2016          Created
******************************************************************************************/
@isTest(seeAllData=true)
public class PriceListItemListnerTest {
	static testmethod void testMethod1(){
        
        GenerateTestData.createProduct2();
        GenerateTestData.createPriceList();
        GenerateTestData.createPriceBookConfigData();
        
        PriceBookEntry pbe = new PriceBookEntry();
        pbe.CurrencyISOCode = 'USD';
        pbe.PriceBook2ID = test.getStandardPricebookId();
        pbe.Product2Id = GenerateTestData.prd.Id;
        pbe.IsActive = true;
        pbe.UnitPrice = 1;
        pbe.UseStandardPrice = false;
        insert pbe;
        
        GenerateTestData.pbe = pbe;
        
        test.startTest();
        GenerateTestData.createPriceListItemData();
        PriceListItemHelper.setLaunchControl();
        test.stopTest();
    }
    
    static testmethod void testMethod2(){
        GenerateTestData.createProduct2();
        GenerateTestData.createPriceList();
        GenerateTestData.createPriceBookConfigData();
        test.startTest();
        GenerateTestData.createPriceListItemData();
        test.stopTest();
    }
    
    static testmethod void testMethod3(){
        GenerateTestData.createProduct2();
        GenerateTestData.createPricebook2();
        GenerateTestData.createPriceList();
        GenerateTestData.createPriceBookConfigData();
        GenerateTestData.createPriceBookEntry();
        
        PriceBookEntry pbe = new PriceBookEntry();
        pbe.CurrencyISOCode = 'USD';
        pbe.PriceBook2ID = GenerateTestData.pb.Id;
        pbe.Product2Id = GenerateTestData.prd.Id;
        pbe.IsActive = false;
        pbe.UnitPrice = 1;
        pbe.UseStandardPrice = false;
        insert pbe;

        
        test.startTest();
        GenerateTestData.createPriceListItemData();
        PriceListItemHelper.setLaunchControl();
        test.stopTest();
    }
    
}