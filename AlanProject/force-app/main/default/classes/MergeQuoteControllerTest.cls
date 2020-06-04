@isTest
Private class MergeQuoteControllerTest{
    
    private static Country_Region_Mapping__c cust;
    private static Geospatial_Country_Region_Mapping__c custRegMap ;
    private static Account acct;
    private static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    private static Apttus_Proposal__Proposal__c appProp ;
    private static Contact contact ;
    private static Event evt;
    private static Event_Template_Language__c langMap;
    private static Apttus_Config2__PriceList__c  appConf ;
    private static attachment attach;
    
    static void setUpData(){        
        
        cust = new Country_Region_Mapping__c(name='Switzerland',Region__c='Switzerland');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='Switzerland',Region__c='Switzerland');
        insert custRegMap;
        
        User thisUser = [select Id from User where Id = :UserInfo.getUserId()];
        
        acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
            BillingCountry = 'Switzerland',BillingCity = 'Pune',BillingStreet = 'A-202');
        insert acct;
        
        contact = new Contact();
        contact.FirstName = 'Partner';
        contact.LastName = 'Contact';
        contact.AccountId = acct.Id;
        contact.MailingCountry ='Switzerland';
        insert contact;
          
        appConf = new Apttus_Config2__PriceList__c(name='TIBV CH Price List' ,Apttus_Config2__Active__c=true);
        insert appConf;
        
        appProp = new Apttus_Proposal__Proposal__c(Apttus_Proposal__Account__c=acct.id,Apttus_Proposal__Proposal_Name__c='TestMergeQuote',Apttus_QPConfig__PriceListId__c=appConf.Id,Standard_T_Cs__c=true ,Ship_To_Account__c=acct.Id);
        insert appProp;
        
        evt = new Event(Description='Test',WhoId=contact.Id,StartDateTime=System.now(),Language__c='English',OwnerId=thisUser.Id,DurationInMinutes=200,whatId=acct.Id);
        insert evt;
        
        langMap = new Event_Template_Language__c(name='English');
        insert langMap;
        
        attach = new Attachment(name='Test Attach',ParentId=appProp.Id,body=blob.valueOf('my attachment text'));
        insert attach;
        
        MergeQuoteController.clsWrapper clsObj = new MergeQuoteController.clsWrapper();
    }   
    
    private static testmethod void testcancelApproval(){
        
        setUpData();
        Test.startTest();
        
            Pagereference pgRef = Page.ApprovalAction;
            pgRef.getParameters().put('quoteId',appProp.id);
                         
            Test.setCurrentPage(pgRef);
            MergeQuoteController cont = new MergeQuoteController();
            cont.quoteId = appProp.id ;
            cont.cancel();
            cont.generateAttachment();

        Test.stopTest();
        
    }  
    
    private static testmethod void testNext(){
        
        setUpData();
        Test.startTest();
        
            Pagereference pgRef = Page.ApprovalAction;
            pgRef.getParameters().put('quoteId',appProp.id);
                         
            Test.setCurrentPage(pgRef);
            MergeQuoteController cont = new MergeQuoteController();
            List<MergeQuoteController.clsWrapper> wrapperLst = new List<MergeQuoteController.clsWrapper>();
            
            MergeQuoteController.clsWrapper cls00 = new MergeQuoteController.clsWrapper();
            cls00.isSelected = true ;
            cls00.attachment = attach;
            
            MergeQuoteController.clsWrapper cls01 = new MergeQuoteController.clsWrapper();
            cls01.isSelected = true ;
            cls01.attachment = attach;
            
            wrapperLst.add(cls00);
            wrapperLst.add(cls01);
            
            cont.quoteId = appProp.id ;
            cont.wrapperList = wrapperLst;
            cont.next();
        Test.stopTest();
        
    }  
    
    
    
}