/**
 * Company     : Trimble Software Technology Pvt Ltd.,
 * Description : Test class for BatchUpdateConRoleInactiveEntitlePrd
 * History     :  

 * [12.1.2015] Ankur Patel  Created
 * [24.7.2015] Divya Renamed Acccount (Pending) Record type to Account (Pending Customer) Record Type at line no: 17
 */
 @isTest
public class BatchUpdateConRoleInactiveEntitlePrdTest{
    public static Country_Region_Mapping__c cust;
    public static Geospatial_Country_Region_Mapping__c custRegMap ;
    public static User thisUser ;
    public static Account acct;
    public static Opportunity opp;
    public static Entitlement entitle;
    public static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    static void setUpData(){
        cust = new Country_Region_Mapping__c(name='India',Region__c='India');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='India',Region__c='India');
        insert custRegMap;
        
        acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
            BillingCountry = 'India',BillingCity = 'Pune',BillingStreet = 'A-202');
        insert acct;
        
        Contact con = new Contact();
        con.AccountId = acct.ID;
        con.LastName = 'Test';
        con.MailingCountry = 'India';
        con.Preferred_Language__c = 'American English';
        con.Role_on_Account__c = 'Prolog - Engineer';
        insert con;
        
        Product2 prd = new Product2();
        prd.Name = 'test';
        prd.isActive = true;
        prd.Product_Type__c = 'Prolog';
        insert prd;
        
        Product2 prd1 = new Product2();
        prd1.Name = 'test';
        prd1.isActive = true;
        prd1.Product_Type__c = 'Prolog Sky';
        insert prd1;
        
        Asset ass = new Asset();
        ass.Product2Id = prd.Id;
        ass.AccountId = acct.Id;
        ass.Name = 'test';
        insert ass;
        
        entitle = new Entitlement();
        entitle.Name = 'test';
        entitle.Entitlement_Product__c = prd.Id;
        entitle.AssetId = ass.ID;
        entitle.AccountId = acct.Id;
        entitle.StartDate = Date.today() - 10;
        entitle.EndDate = Date.today() + 10;
        insert entitle;
        
        entitle = new Entitlement();
        entitle.Name = 'test';
        entitle.Entitlement_Product__c = prd1.Id;
        entitle.AccountId = acct.Id;
        entitle.AssetId = ass.ID;
        entitle.StartDate = Date.today() - 10;
        entitle.EndDate = Date.today() + 10;
        insert entitle;
    }
    
    private static testmethod void TestMethod1(){
        setUpData();
        Test.startTest();
            BatchUpdateConRoleforInactiveEntitlePrd temp = new BatchUpdateConRoleforInactiveEntitlePrd();
            temp.query = 'select Id,Active_Product_List__c,(select Id,Role_on_Account__c,Active_Contact_Flag__c from Contacts where Role_on_Account__c != null),(select ID,Name,AccountId,Enddate,Product_Product_Type__c from Entitlements where enddate >= today) from Account where Id =\'' + acct.Id + '\'';
            Database.executeBatch(temp,200);
        Test.stopTest();
    } 
    
    private static testmethod void TestMethod2(){
        setUpData();
        Test.startTest();
            BatchUpdateConRoleforInactiveEntitlePrd temp = new BatchUpdateConRoleforInactiveEntitlePrd();
            temp.query = 'select Id,Active_Product_List__c,(select Id,Role_on_Account__c,Active_Contact_Flag__c from Contacts where Role_on_Account__c != null),(select ID,Name,AccountId,Enddate,Product_Product_Type__c from Entitlements where enddate >= today) from Account where Id =\'' + acct.Id + '\''; 
            String sch = '0 0 23 * * ?';
            system.schedule('Test check', sch, temp);
        Test.stopTest();
    }
    
    private static testmethod void TestMethod3(){
        setUpData();
        Test.startTest();
            entitle.EndDate = Date.today() - 2;
            update entitle;
            
            BatchUpdateConRoleforInactiveEntitlePrd temp = new BatchUpdateConRoleforInactiveEntitlePrd();
            temp.query = 'select Id,Active_Product_List__c,(select Id,Role_on_Account__c,Active_Contact_Flag__c from Contacts where Role_on_Account__c != null),(select ID,Name,AccountId,Enddate,Product_Product_Type__c from Entitlements where enddate >= today) from Account where Id =\'' + acct.Id + '\''; 
            String sch = '0 0 23 * * ?';
            system.schedule('Test check', sch, temp);
        Test.stopTest();
    }   
}