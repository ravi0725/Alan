/*
 * Description: ValidateEndDateTest
 * Date: 01-09-2015
 * Created By: P M MAMATA
 */
@isTest(seealldata=true)
private class ValidateEndDateTest {
    static testmethod void meth1(){
        Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
        GenerateTestData.createAccount();        
        Product2 prd = new Product2();
        prd.Name = 'test';
        prd.isActive = true;
        prd.Contract_Item_Type_Code__c = 'WARRANTY';
        prd.Product_Line_Description__c = 'SAAShdskjhdsfkjtest  ';
        prd.ProductCode = 'Test123';
        prd.Family = 'test family';
        prd.Product_Line__c = 'test';
        prd.Business_Area__c = 'Plancal';
        insert prd;
        Asset st = new Asset();
        st.Name = 'Test Asset';
        st.AccountId = GenerateTestData.acct.Id;
        st.Product2Id = prd.Id;
        insert st;
        Entitlement ent = new Entitlement();
        ent.Name = 'Test Entitlement';
        ent.Entitlement_Product__c = prd.Id;
        ent.AccountId = GenerateTestData.acct.Id;
        ent.AssetId = st.Id;
        ent.StartDate = System.today() + 1; 
        ent.EndDate = System.today() + 20;
        insert ent;
        ValidateEndDate ved = new ValidateEndDate();
        ved.Check(1.0, GenerateTestData.acct.Id, 'test',prd.Id);
        ved.CheckSAAS(1.0,GenerateTestData.acct.Id,'test','Plancal');
    }
}