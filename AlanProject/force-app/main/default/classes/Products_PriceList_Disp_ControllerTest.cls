/*
*****************************************************************************************
    Name        : Products_PriceList_Disp_ControllerTest 
                            
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
 P M Mamata           19/07/2015          Created
*****************************************************************************************
*/
@isTest(seealldata = true)
private class Products_PriceList_Disp_ControllerTest {
    
    static testmethod void testMeth1(){
        
        Test.setCurrentPageReference(new PageReference('Page.Products_PriceList_Disp'));
        System.currentPageReference().getParameters().put('displayType', 'pdf');
        System.currentPageReference().getParameters().put('prdFamilyList', 'TIBV DE Price List_Old');
        GenerateTestData.createPriceList();
        GenerateTestData.createProduct2();
        GenerateTestData.createApttusConfig2PriceListItem(); 
        Products_PriceList_Disp_Controller ppdc = new Products_PriceList_Disp_Controller();
        ppdc.getWrList();
        
        
    }
    
   
    static testmethod void testMeth2(){
        Test.setCurrentPageReference(new PageReference('Page.Products_PriceList_Disp'));
        System.currentPageReference().getParameters().put('displayType', 'Excel');
        System.currentPageReference().getParameters().put('prdFamilyList', 'TIBV DE Price List_Old');
        Products_PriceList_Disp_Controller ppdc = new Products_PriceList_Disp_Controller(); 
        GenerateTestData.createPriceList();
        GenerateTestData.createProduct2();
        GenerateTestData.createApttusConfig2PriceListItem(); 
        ppdc.getSelectViewList();
        ppdc.getWrList();
    }
    
    
    static testmethod void testMeth3(){
        Test.setCurrentPageReference(new PageReference('Page.Products_PriceList_Disp'));
        System.currentPageReference().getParameters().put('displayType', '');
        System.currentPageReference().getParameters().put('prdFamilyList', 'TIBV DE Price List_Old');
        GenerateTestData.createPriceList();
        GenerateTestData.createProduct2();
        GenerateTestData.createApttusConfig2PriceListItem(); 
        Products_PriceList_Disp_Controller ppdc = new Products_PriceList_Disp_Controller(); 
        ppdc.getWrList();
    }
    
    static testmethod void testmeth4(){
        Test.setCurrentPageReference(new PageReference('Page.Products_PriceList_Disp'));
        System.currentPageReference().getParameters().put('displayType', 'Excel');
        System.currentPageReference().getParameters().put('prdFamilyList', 'TIBV DE Price List_Old');        
        GenerateTestData.createPriceList();
        GenerateTestData.createProduct2();
        GenerateTestData.createApttusConfig2PriceListItem();            
        Products_PriceList_Disp_Controller ppdc = new Products_PriceList_Disp_Controller(); 
        ppdc.filterProductFamily();
        ppdc.getWrList();
        
    }
    
}