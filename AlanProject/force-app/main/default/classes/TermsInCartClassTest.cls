@isTest
private class TermsInCartClassTest{
    
    private static Country_Region_Mapping__c cust;
    private static Geospatial_Country_Region_Mapping__c custRegMap ;
    private static Apttus_Proposal__Proposal__c appProp ;
    private static User thisUser ;
    private static Account acct;
    private static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    private static Apttus_Config2__ProductConfiguration__c prodConfig ;
    private static Apttus_Config2__TempObject__c appTempObj ;
    private static Apttus_Config2__PriceList__c appConf;
    private static Proposal_Term__c  propTerm;
    private static Term__c  trm, trm1 ;
    
    static void setUpData(){
        
        cust = new Country_Region_Mapping__c(name='Switzerland',Region__c='Switzerland');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='Switzerland',Region__c='Switzerland');
        insert custRegMap;
        
        thisUser = [select Id from User where Id = :UserInfo.getUserId()];
        
        acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
            BillingCountry = 'Switzerland',BillingCity = 'Pune',BillingStreet = 'A-202');
        insert acct;
        
        //appConf = new Apttus_Config2__PriceList__c(name='TIBV CH Price List' ,Apttus_Config2__Active__c=true);
        appConf = new Apttus_Config2__PriceList__c(name='GCCM Region 3-USD' ,Apttus_Config2__Active__c=true);
        insert appConf;
        
        appProp = new Apttus_Proposal__Proposal__c(Apttus_Proposal__Account__c=acct.id,Apttus_QPConfig__PriceListId__c=appConf.Id,Standard_T_Cs__c=true
                    ,Ship_To_Account__c=acct.Id);
        insert appProp;
        
        prodConfig = new Apttus_Config2__ProductConfiguration__c(name='Test Product Config',Apttus_QPConfig__Proposald__c=appProp.id ,Apttus_Config2__BusinessObjectId__c='Test');
        insert prodConfig;      
            
        propTerm = new Proposal_Term__c(Quote_Proposal_ID__c=appProp.Id , name='Test-1');
        insert propTerm;
        
        trm = new Term__c(Term_Name__c='1 - Test',Pricelist__c=appConf.name, Proposal_Type__c = 'Quote', Customer_Type__c = 'New', Language__c = 'English');
        insert trm;
        trm1 = new Term__c(Term_Name__c='2 - Test',Pricelist__c=appConf.name, Proposal_Type__c = 'Quote', Customer_Type__c = 'New', Language__c = 'English');
        insert trm1;
        
        appTempObj = new Apttus_Config2__TempObject__c(Apttus_Config2__ConfigurationId__c=prodConfig.Id , Apttus_Config2__Data__c='<BusinessObjectId>'+propTerm.Quote_Proposal_ID__c+'</BusinessObjectId>');
        insert appTempObj;  

    }
    
    private static testmethod void testTermsInCartClass(){
        
        setUpData();
        Test.startTest();
        	Pagereference pgRef = Page.TermsInCart;
            pgRef.getParameters().put('configRequestId',appTempObj.id);
            pgRef.getParameters().put('Id',prodConfig.id);
            Test.setCurrentPage(pgRef);
            
            TermsInCartClass cont = new TermsInCartClass();
            List<SelectOption> testOptions = TermsInCartClass.getProposalTypeValues();
        Test.stopTest();
    } 
    
    private static testmethod void testConds(){
        
        setUpData();
        Test.startTest();
            Pagereference pgRef = Page.TermsInCart;
            pgRef.getParameters().put('configRequestId',appTempObj.id);
            pgRef.getParameters().put('Id',prodConfig.id);
            Test.setCurrentPage(pgRef);
            
            TermsInCartClass cont = new TermsInCartClass();
            cont.getConds();
            
        Test.stopTest();
    } 
    
    private static testmethod void testTerm(){
        
        setUpData();
        Test.startTest();
            Pagereference pgRef = Page.TermsInCart;
            pgRef.getParameters().put('configRequestId',appTempObj.id);
            pgRef.getParameters().put('Id',prodConfig.id);
            Test.setCurrentPage(pgRef);
            
            TermsInCartClass cont = new TermsInCartClass();
            
            List<TermsWrapperCls> ternWrapper = new List<TermsWrapperCls>();
            
            TermsWrapperCls termObj00 = new TermsWrapperCls(trm);
            termObj00.rowIndex=0;
            termObj00.isSelected=true;
            
            TermsWrapperCls termObj01 = new TermsWrapperCls(trm);
            termObj01.rowIndex=1;
            termObj01.isSelected=false;
                
            ternWrapper.add(termObj00);
            ternWrapper.add(termObj01);
            
            cont.pageTerms = ternWrapper;
            
            cont.pageTerms = ternWrapper;
            cont.addTerms();
            cont.Save();
        	
        	cont.selectedTerm.Proposal_Type__c = 'Quote';
        	cont.selectedTerm.Customer_Type__c = 'New';
        	cont.selectedTerm.Language__c = 'English';
        	cont.condition = 'AND';
            cont.filterTerms();
            cont.clearfilterTerms();
            
        Test.stopTest();
    } 
    
    private static testmethod void testremoveRow(){
        
        setUpData();
        Test.startTest();
            Pagereference pgRef = Page.TermsInCart;
            pgRef.getParameters().put('configRequestId',appTempObj.id);
            pgRef.getParameters().put('Id',prodConfig.id);
            Test.setCurrentPage(pgRef);
            
            TermsInCartClass cont = new TermsInCartClass();
            
            List<TermsWrapperCls> ternWrapper = new List<TermsWrapperCls>();
            
            TermsWrapperCls termObj00 = new TermsWrapperCls(trm);
            termObj00.rowIndex=0;
            termObj00.isSelected=true;
            
            TermsWrapperCls termObj01 = new TermsWrapperCls(trm);
            termObj01.rowIndex=1;
            termObj01.isSelected=false;
                
            ternWrapper.add(termObj00);
            ternWrapper.add(termObj01);
            
            cont.pageTerms = ternWrapper;
            
        	cont.addTerms();
            cont.termName = 'Test-1';
        	cont.removeRow();
            
        Test.stopTest();
    }         
}