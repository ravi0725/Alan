/*****************************************************************************************
Name    : TestAccount360ViewController 
Modification Log : 
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
Ankur       11/19/2018          Created
******************************************************************************************/
@isTest(seealldata=true)
public class TestAccount360ViewController {
    static testmethod void Account360ViewControllerTest1(){
        test.startTest();
        GenerateTestData.createAccount();
        GenerateTestData.createContact();
        GenerateTestData.createProduct2();
        GenerateTestData.createAsset();
        GenerateTestData.createEntitlement();
        GenerateTestData.createTAPCase();
        /*GenerateTestData.createiStoreNote();
        GeneratetestData.createOrder();
        GeneratetestData.createOrderLineItem();*/
        
        ApexPages.currentPage().getParameters().put('Id',GenerateTestData.acct.Id);
        Account360ViewController ctrl = new Account360ViewController();
        ctrl.resetLoadPanel1();
        ctrl.resetLoadPanel2();
        ctrl.resetLoadPanel3();
        ctrl.showAllRecord();
        ctrl.getHeaderdetail();
        ctrl.getEntitlementListFilter();
        ctrl.getOrderList();
        ctrl.getAssets();
        ctrl.getEntitlementList();
        ctrl.getiStoreNotes();
        ctrl.getCaseList();
        ctrl.getActivityList();
        ctrl.returnToAccount();
        ctrl.newOrder();
        
        ctrl.EntitlementIdSet = GenerateTestData.ent.Id;
        ctrl.customvalidations();
        
        ApexPages.currentPage().getParameters().put('showAllRecord','All');
        ctrl = new Account360ViewController();
        ctrl.resetLoadPanel1();
        ctrl.resetLoadPanel2();
        ctrl.resetLoadPanel3();
        ctrl.showAllRecord();
        ctrl.getHeaderdetail();
        ctrl.getEntitlementListFilter();
        ctrl.getOrderList();
        ctrl.getAssets();
        ctrl.getEntitlementList();
        ctrl.getiStoreNotes();
        ctrl.getCaseList();
        ctrl.getActivityList();
        ctrl.returnToAccount();
        ctrl.newOrder();
        
        ctrl.EntitlementIdSet = GenerateTestData.ent.Id;
        ctrl.customvalidations();
        test.stopTest();
    }
    
    static testmethod void Account360ViewControllerTest2(){
        test.startTest();
        GenerateTestData.createAccount();
        Profile prf = [Select ID from Profile where Name like 'TAP%' limit 1];
        GenerateTestData.createUser(prf.Id);
        
        ApexPages.currentPage().getParameters().put('Id',GenerateTestData.acct.Id);
        system.runAs(GenerateTestData.ur){
            Event eventObj = new Event();
            eventObj.Subject= 'TAP Test Event';
            eventObj.WhatId = GenerateTestData.acct.Id;
            eventObj.Type = 'Other';
            eventObj.ActivityDate = date.today();
            eventObj.DurationInMinutes = 30;
            eventObj.ActivityDateTime = datetime.now();
            insert eventObj;
            
            Task t = new Task();
            t.Subject= 'TAP Test Task';
            t.WhatId = GenerateTestData.acct.Id;
            t.Type = 'Other';
            t.ActivityDate = date.today();
            insert t;
            
            Account360ViewController ctrl = new Account360ViewController();
            ctrl.getActivityList();
        }
        test.stopTest();
    }
}