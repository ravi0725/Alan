/*****************************************************************************************
    Name    : ProductLookupControllerTestClass
    Desc    : Used for test coverage of the code implemented in ProductLookupControllerTestClass. 
                            
    Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Sagar Mehta       5/27/2013          Created
******************************************************************************************/
@isTest
public class ProductLookupControllerTestClass{

     /**
     * Method name  : testForecast
     * Description  : This method covers the positive scenarios of ForecastController
     * Return Type  : void
     * Parameter    : None
     **/
  static testMethod void testProductControllerMethods() { 
    Test.startTest();
    Profile profile = [select Id from Profile where Name =: 'System Administrator'];
    
    User user = new User();
        user.Username = 'sagamehta123@deloitte.com';
        user.Email = 'sagamehta@deloitte.com';
        user.LastName = 'Test';
        user.Alias = 'Test123';
        user.ProfileID = profile.Id;
        user.LocaleSidKey = 'en_US';
        user.LanguageLocaleKey = 'en_US';
        user.Country = 'India';
        user.Division__c = 'Infrastructure';
        user.TimeZoneSidKey = 'America/Los_Angeles';
        user.EmailEncodingKey='UTF-8';
        insert user;
        System.runAs(user) {
        
          PriceBook2 pbe2 = new PriceBook2();
          pbe2.name='GCCM Price Book';
          insert pbe2;
          
          Product2 product = new Product2();
          product.Name = 'Vico Software';
          product.Family = 'Software';
          insert product;
          
          PricebookEntry pbe = new PricebookEntry();
          pbe.Pricebook2Id = pbe2.Id;
          pbe.Product2Id = product.Id;                          
          
          System.assert(pbe.Pricebook2Id == pbe2.Id);                    
                
          PageReference pageRef = Page.productlookup;
          Test.setCurrentPage(pageRef);
          Apexpages.currentpage().getparameters().put('lksrch', 'Vico Software');
          productlookupController fsc = new productlookupController();  
          Apexpages.currentpage().getparameters().put('frm', 'Vico Software');      
          fsc.getFormTag();
          Apexpages.currentpage().getparameters().put('txt', 'Vico Software');
          fsc.getTextBox();
          fsc.search();
        }
        Test.stopTest();    
    }



}