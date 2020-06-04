//Divya-23/3/2015:Changed the Forecast_Category_MEP__c field to   ForecastCategoryName

/*
 * Description:AcceptProposalCustomControllerTest  
 * Modified By: P M MAMATA
 * Date: 01-09-2015
 * 
*/



@isTest(seeAllData=true)
Private class AcceptRedirectControllerTest{
    /*
    public static Quote qt ;
    public static Apttus_Proposal__Proposal__c app ;
    public static Opportunity oppty;
    public static Account acct;
    public static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
   // public static Id opptyRecTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Opportunity (Plancal Customer) Record Type').getRecordTypeId();
    public static Apttus_Config2__PriceList__c appConf;
    public static UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
    public static Profile profile = [Select Id from Profile where name = 'System Administrator'];
    public static User portalAccountOwner ;

    
    static void setUp(){
    
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            portalAccountOwner = new User(
                UserRoleId = portalRole.Id,
                ProfileId = profile.Id,
                Username = System.now().millisecond() + 'test2@test.com',
                Alias = 'Test',
                Email='test@test.com',
                EmailEncodingKey='UTF-8',
                Firstname='Test',
                Lastname='Suite',
                LanguageLocaleKey='en_US',
                LocaleSidKey='en_US',
                TimeZoneSidKey='America/Chicago',
                Country='India'
            );
            //insert portalAccountOwner;
          }
        
        acct = new Account(
            Name = 'Test Assign Case Account',
            RecordTypeId = acctRecTypeId,
            Account_Status__c = 'Pending',
            Requested_Account_Record_Type__c = 'Customer',
            BillingCountry = 'Switzerland',
            BillingCity = 'Pune',
            BillingStreet = 'A-202'
            );
        insert acct;
        
        
        
        appConf = new Apttus_Config2__PriceList__c(name='TIBV CH Price List' ,Apttus_Config2__Active__c=true);
        insert appConf;
        
        oppty= new Opportunity (name='Test Oppty' , StageName='1 - Qualification' ,  ForecastCategoryName='Pipeline' , 
                AccountId=acct.Id, Type='New Business', Price_List__c=appConf.Id , Amount=100, CurrencyIsoCode='USD',Payment_Term__c ='CASH IN ADVANCE',
                CloseDate=System.today(),Ship_To_Account__c=acct.Id);
        insert oppty;
        
        qt = new Quote(name='Test Quote',OpportunityId=oppty.Id);
        insert qt;
        
        app = new Apttus_Proposal__Proposal__c(Apttus_Proposal__Payment_Term__c='1 Year',Apttus_Proposal__Description__c='Test');
        insert app;
        
         
    }
    
    private static testmethod void TestAcceptRedirectController(){
        setUp();
        Test.startTest();
            AcceptRedirectController cont = new AcceptRedirectController();
            cont.quoteId = app.Id;
            cont.generateprop();            
            cont.calculateTax();
            cont.cancelquote();
            System.assertEquals(cont.taxFlag,false);
        Test.stopTest();
        
    }
	*/
    
    static testmethod void meth1(){
        GenerateTestData.createAccount();
        GenerateTestData.createAddress();
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();
		Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c();
        proposal.Apttus_Proposal__Account__c = GenerateTestData.acct.Id;
        proposal.Apttus_Proposal__Opportunity__c = GenerateTestData.opp.Id;
        proposal.Apttus_QPConfig__PriceListId__c = GenerateTestData.pricelist.Id;
        proposal.Ship_To_Account__c = GenerateTestData.acct.Id;
        proposal.Bill_to_Address__c  = GenerateTestData.adrs.Id;
        proposal.OwnerId = UserInfo.getUserId();
        proposal.Apttus_Proposal__Primary__c = true;
        proposal.Tax__c = 10;
        proposal.Recalculate_tax__c = true;
        insert proposal;        
        
        System.currentPageReference().getParameters().put('id', proposal.Id);
        AcceptRedirectController arc = new AcceptRedirectController();
        arc.cancelquote();
        arc.generateprop();
        arc.calculateTax();
        
    }
    
}