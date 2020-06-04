/*
*****************************************************************************************
Name        : TestMEPNACase 
Description : Test class for GenerateAgreementPDFController, CaseHandler, AgreementPDF classes
---------------------------------------------------------------------------
Developer              Date            Description
Ankur Patel           9/2/2017          Created
*****************************************************************************************
*/
@isTest(SeeAllData=true)
public class TestMEPNACase {
    static void TestData(){
        GenerateTestData.CreateParentAccount();
        GenerateTestData.createProduct2();
        
        Entitlement ent = new Entitlement();
        ent.Name = Label.MEPNA_Default_Entitlement;
        ent.Entitlement_Product__c = GenerateTestData.prd.Id;
        ent.AccountId = GenerateTestData.acc.Id;
        insert ent;
    }
    
    static testmethod void TestGenerateAgreementPDFController1(){
        TestData();
        Case cs = new Case();
        cs.Subject = 'New Case';
        cs.Description = 'New Case';
        cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.MEP_NA_Case_Record_Type).getRecordTypeId();
        cs.Product_Group__c = 'QuickPen';
        insert cs;
        
        GenerateAgreementPDFController.generateAgreementPDF(cs.Id);
    }
    
    static testmethod void TestGenerateAgreementPDFController2(){
        TestData();
        Case cs = new Case();
        cs.Subject = 'New Case';
        cs.Description = 'New Case';
        cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.MEP_NA_Case_Record_Type).getRecordTypeId();
        cs.Product_Group__c = 'Fabshop';
        insert cs;
        
        GenerateAgreementPDFController.generateAgreementPDF(cs.Id);
    }
    
    static testmethod void TestGenerateAgreementPDFController3(){
        TestData();
        Case cs = new Case();
        cs.Subject = 'New Case';
        cs.Description = 'New Case';
        cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.MEP_NA_Case_Record_Type).getRecordTypeId();
        cs.Product_Group__c = 'Accubid';
        insert cs;
        
        GenerateAgreementPDFController.generateAgreementPDF(cs.Id);
    }
    
    static testmethod void TestGenerateAgreementPDFController4(){
        TestData();
        Case cs = new Case();
        cs.Subject = 'New Case';
        cs.Description = 'New Case';
        cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.MEP_NA_Case_Record_Type).getRecordTypeId();
        cs.Product_Group__c = 'Test';
        insert cs;
        
        GenerateAgreementPDFController.generateAgreementPDF(cs.Id);
    }
    
    static testmethod void TestGenerateAgreementPDFController5(){
        GenerateAgreementPDFController.generateAgreementPDF(null);
    }
    
    static testmethod void TestAgreementPDFController1(){
        TestData();
        Case cs = new Case();
        cs.Subject = 'New Case';
        cs.Description = 'New Case';
        cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.MEP_NA_Case_Record_Type).getRecordTypeId();
        cs.Product_Group__c = 'Test';
        insert cs;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(cs);
        AgreementPDFController pdf = new AgreementPDFController(sc);
    }
}