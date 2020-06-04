/*****************************************************************************************
    Name    : DealRegProductLineController 
    Desc    : 
                            
Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Sagar Mehta       4/27/2013          Created
******************************************************************************************/
@isTest
public class DealRegLineItemsTestClass {
	static testMethod void testForecast() { 
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
        	Product2 product = new Product2();
	        product.IsActive = true;
	        product.Name = 'ABC';
	        product.ProductCode = 'T1';
	        product.Certificate__c = 'C1';
	        insert product;
	        
	        PriceBook2 pbe2 = new PriceBook2();
            pbe2.Name = 'GCCM Price Book';
            //pbe2.IsStandard = true;
            insert pbe2;
            
	        Deal_Registration__c dealRegistration = new Deal_Registration__c();
			Id recordId = Schema.SObjectType.Deal_Registration__c.getRecordTypeInfosByName().get('Deal Registration Partner').getRecordTypeId();        
	        dealRegistration.RecordTypeId = recordId;
	        dealRegistration.Approval_Status__c = 'Pending Review';
	        dealRegistration.Approximate_Deal_Amount__c = 10;
	        dealRegistration.City__c = 'Mumbai';
	        dealRegistration.Company__c = 'ABC Corporation';
	        dealRegistration.Competitive_Deal__c = true;
	        dealRegistration.Competitive_Offering__c = '100000';
	        dealRegistration.Country__c = 'India';
	        dealRegistration.Deal_Type__c = 'New Business';
	        dealRegistration.Email__c = 'sagamehta@deloitte.com';
	        dealRegistration.First_Name__c = 'Test';
	        dealRegistration.I_confirm_i_have_read_understood_T_C_s__c = true;
	        dealRegistration.Industry__c = 'Agriculture';
	        dealRegistration.Last_Name__c = 'Test';
	        dealRegistration.Sales_Stage__c = '1- Qualification';
	        dealRegistration.Website__c = 'https://login.salesforce.com';
	        dealRegistration.Title__c = 'Test';
	        dealRegistration.Street__c = 'Test Street';
	        dealRegistration.State_Province__c = 'MH';
	        dealRegistration.Role__c = 'Influencer';
	        dealRegistration.Project_Name__c = 'test';
	        dealRegistration.Project_Description__c = 'desc';
	        dealRegistration.Project_Budgeted_Amount__c = 1000000;
	        dealRegistration.Project_Budgeted__c = true;
	        dealRegistration.Primary_Competitor__c = 'competitor';
	        dealRegistration.Phone__c = '9900000';
	        dealRegistration.OwnerId = user.Id;
	        insert dealRegistration;
	        
	        Deal_Registration_Line__c line = new Deal_Registration_Line__c();
	        line.Deal_Registration__c = dealRegistration.Id;
	        line.Product__c = product.Id;
	        line.Quantity__c = 10;
	        //line.Total_Price__c = 100;
	        line.Unit_Price__c  = 10;
	        insert line;
	        
            /*PricebookEntry pe = new PricebookEntry();
            pe.Pricebook2Id = pbe2.Id;
            pe.UseStandardPrice = false;
            pe.IsActive = true;
            //pe.Pricebook2Id = pbe2.Id;
            pe.Product2Id = product.Id;
            pe.unitprice = 200;
			insert pe;*/
			            
	        PageReference pageRef = Page.DealRegLineItems_PartnerUser;
	        Test.setCurrentPage(pageRef);
	        Apexpages.currentpage().getparameters().put('id', dealRegistration.Id);
	        Apexpages.currentpage().getparameters().put('lineid', line.Id);
	        DealRegLineItems_PartnerUserController puc = new DealRegLineItems_PartnerUserController();
	        puc.cancel();    	
	        puc.Save();
	        Apexpages.currentpage().getparameters().put('lineid', '');
	        puc.deleteRegLineItem();
	        
	        Apexpages.currentpage().getparameters().put('lineid', line.Id);
	        DealRegLineItems_PartnerUserController puc1 = new DealRegLineItems_PartnerUserController();
	        puc1.dealRegLine.Product__c = null;
	        puc1.dealRegLine.Product_Authorization__c = false;
	        puc1.quantity = 0;
	        puc1.dealregline.discount__c = 0.00;
	        puc1.dealregline.unit_price__c = 0.00;
	        puc1.save();
	        
	        Apexpages.currentpage().getparameters().put('lineid', line.Id);
	        puc.deleteRegLineItem();
	        puc.cancel();
        }
        Test.stopTest();    
    }
}