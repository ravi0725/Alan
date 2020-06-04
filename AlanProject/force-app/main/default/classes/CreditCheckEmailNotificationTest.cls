/*
****************************************************************************************
    Name Controller        : CreditCheckEmailNotificationTest 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
 P M Mamata           24/07/2015          created
*****************************************************************************************
*/
@isTest
private class CreditCheckEmailNotificationTest {
    /*
    * Test method to cover CreditCheckEmailNotificationController class
    */
    static testmethod void creditCheckEmailNotificationControllerTest1(){
        GenerateTestData.createSystemIntegrationURL();
        GenerateTestData.customSettingRds();
        GenerateTestData.createAccount();   
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();
        PageReference oPageReference = Page.CreditCheckEmailNotification; 
        
        oPageReference.getParameters().put('AcctId', GenerateTestData.acct.Id); 
        oPageReference.getParameters().put('id', GenerateTestData.opp.Id);    
        oPageReference.getParameters().put('ACL', '');    
        oPageReference.getParameters().put('source', '');    
        Test.setCurrentPage(oPageReference);
        CreditCheckEmailNotificationController oCreditCheckCtrl = new CreditCheckEmailNotificationController();
        oCreditCheckCtrl.Comments = 'Test';
        oCreditCheckCtrl.closePopup();
        oCreditCheckCtrl.showPopup();
        oCreditCheckCtrl.close();
        oCreditCheckCtrl.SendEmail(); 
        oCreditCheckCtrl.backtoAccount();
        oCreditCheckCtrl.cont();
    }
    
    /*
    * Test method to cover CreditCheckEmailNotificationController class
    */
    static testmethod void creditCheckEmailNotificationControllerTest2(){
        GenerateTestData.createSystemIntegrationURL();
        GenerateTestData.customSettingRds();
        GenerateTestData.createAccount();   
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();
        PageReference oPageReference = Page.CreditCheckEmailNotification; 
        
        oPageReference.getParameters().put('AcctId', GenerateTestData.acct.Id); 
        oPageReference.getParameters().put('id', GenerateTestData.opp.Id);    
        oPageReference.getParameters().put('ACL', '');    
        oPageReference.getParameters().put('source', 'mavenlinkproject');    
        Test.setCurrentPage(oPageReference);
        CreditCheckEmailNotificationController oCreditCheckCtrl = new CreditCheckEmailNotificationController();
        oCreditCheckCtrl.Comments = 'Test';
        oCreditCheckCtrl.closePopup();
        oCreditCheckCtrl.showPopup();
        oCreditCheckCtrl.close();
        oCreditCheckCtrl.SendEmail(); 
        oCreditCheckCtrl.backtoAccount();
        oCreditCheckCtrl.cont();
    }
    
    /*
    * Test method to cover CreditCheckEmailNotificationController class
    */
    static testmethod void creditCheckEmailNotificationControllerTest3(){
        GenerateTestData.createSystemIntegrationURL();
        GenerateTestData.customSettingRds();
		GenerateTestData.createAccount(); 
        GenerateTestData.acct.Enterprise_Party_Number__c = '';
        GenerateTestData.acct.Collector_Email__c = '';
        update GenerateTestData.acct;
        
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();
        PageReference oPageReference = Page.CreditCheckEmailNotification; 
        
        oPageReference.getParameters().put('AcctId', GenerateTestData.acct.Id); 
        oPageReference.getParameters().put('id', GenerateTestData.opp.Id);    
        oPageReference.getParameters().put('ACL', '');    
        oPageReference.getParameters().put('source', '');    
        Test.setCurrentPage(oPageReference);
        CreditCheckEmailNotificationController oCreditCheckCtrl = new CreditCheckEmailNotificationController();
        oCreditCheckCtrl.Comments = 'Test';
        oCreditCheckCtrl.closePopup();
        oCreditCheckCtrl.showPopup();
        oCreditCheckCtrl.close();
        oCreditCheckCtrl.SendEmail(); 
        oCreditCheckCtrl.backtoAccount();
        oCreditCheckCtrl.cont();
    }
    
    /*
    * Test method to cover CreditCheckEmailNotificationController class
    */
    static testmethod void creditCheckEmailNotificationControllerTest4(){
        GenerateTestData.createSystemIntegrationURL();
        GenerateTestData.customSettingRds();
		GenerateTestData.createAccount(); 
        GenerateTestData.acct.Enterprise_Party_Number__c = '';
        GenerateTestData.acct.Collector_Email__c = '';
        GenerateTestData.acct.Region__c = 'North America';
        update GenerateTestData.acct;
        
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();
        PageReference oPageReference = Page.CreditCheckEmailNotification; 
        
        oPageReference.getParameters().put('AcctId', GenerateTestData.acct.Id); 
        oPageReference.getParameters().put('id', GenerateTestData.opp.Id);    
        oPageReference.getParameters().put('ACL', '');    
        oPageReference.getParameters().put('source', 'mavenlinkproject');    
        Test.setCurrentPage(oPageReference);
        CreditCheckEmailNotificationController oCreditCheckCtrl = new CreditCheckEmailNotificationController();
        oCreditCheckCtrl.Comments = 'Test';
        oCreditCheckCtrl.closePopup();
        oCreditCheckCtrl.showPopup();
        oCreditCheckCtrl.close();
        oCreditCheckCtrl.SendEmail(); 
        oCreditCheckCtrl.backtoAccount();
        oCreditCheckCtrl.cont();
    }
    
    /*
    * Test method to cover CreditCheckEmailNotificationController class
    */
    static testmethod void creditCheckEmailNotificationControllerTest5(){
        GenerateTestData.createSystemIntegrationURL();
        GenerateTestData.customSettingRds();
		GenerateTestData.createAccount(); 
        GenerateTestData.acct.Enterprise_Party_Number__c = '';
        GenerateTestData.acct.Collector_Email__c = '';
        GenerateTestData.acct.Region__c = 'North America';
        update GenerateTestData.acct;
        
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();
        PageReference oPageReference = Page.CreditCheckEmailNotification; 
        
        oPageReference.getParameters().put('AcctId', GenerateTestData.acct.Id); 
        oPageReference.getParameters().put('id', GenerateTestData.opp.Id);    
        oPageReference.getParameters().put('ACL', '');      
        Test.setCurrentPage(oPageReference);
        CreditCheckEmailNotificationController oCreditCheckCtrl = new CreditCheckEmailNotificationController();
        oCreditCheckCtrl.Comments = 'Test';
        oCreditCheckCtrl.closePopup();
        oCreditCheckCtrl.showPopup();
        oCreditCheckCtrl.close();
        oCreditCheckCtrl.SendEmail(); 
        oCreditCheckCtrl.backtoAccount();
        oCreditCheckCtrl.cont();
        oCreditCheckCtrl.errorMsg = '';
    }
}