@isTest
private class CustomLeadConversionControllerTest{

    private static User thisUser ;
    private static Account acct ;
    private static Contact cnt ;
    private static Lead leadvar ;
    private static Lead leadvar2 ;
    private static Country_Region_Mapping__c cust;
    private static Geospatial_Country_Region_Mapping__c custRegMap ;
    private static Opportunity opp;
    //private static Competitor_Assets_Junction__c compAssetJunc ;
    private static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId(); 
    //private static Competitor_Owned_Assets__c compAsset;
    //private static Product_competitor__c  prodComp;
    private static Product2 prod;
    private static String selectId ;
    private static Task tsk ;
    private static Profile prf = [Select Id from Profile where Name =: Label.API_Only];
    private static User apiUser;
    private static User apiUser2;
    
    static void setUpData(){
    
        selectId= '300000000000000';
        
        cust = new Country_Region_Mapping__c(name='India',Region__c='India');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='India',Region__c='India');
        insert custRegMap;  
        
        thisUser = [select Id from User where Id = :UserInfo.getUserId()];
        
        acct = new Account(Name = 'Test',RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
            BillingCountry = 'India',BillingCity = 'Pune',BillingStreet = 'A-202',OwnerId = thisUser.Id ,FCH_Party_ID__c= selectId,Phone='111-111-1111',BillingState='Goa',
            BillingPostalCode ='343220',Lifecycle_Stage__c='Customer',Site_Name__c='test',Address1__c='Test',Address2__c='Test',
            Address3__c='Test',Address4__c='Test',Account_Forecast_Owner__c=thisUser.Id);
        insert acct;
        
        cnt = new Contact();
        cnt.LastName = 'Test';
        cnt.AccountId = acct.Id;
        cnt.MailingCountry ='India';
        insert cnt;

        RecordType recordType = [SELECT Id FROM RecordType WHERE DeveloperName =: Label.Lead_Accept_Reject_Record_Type];
                        
        leadvar = new Lead(LastName = 'Test Lead',company='Test',isPartnerReject__c=false,
                    Lead_Accept_TimeStamp__c = DateTime.newInstance(System.now().year(), System.now().month(), System.now().day(), System.now().hour(), 0, 0) ,
                    ownerid=thisUser.id, RecordTypeId = recordType.Id,Country='India',Industry='Engineering and Construction',city='Pune',
                    street='dalal',postalcode='100100',Opportunity_Product__c='Hardware',Tracking_Division__c='GCCM',Selling_division__c='GCCM',Email='test@test.com',Phone='111-111-1111',
                    Address1__c='Test-1',Address2__c='Test-2',Address3__c='Test-3',Address4__c='Test-4');   
        insert leadvar; 
        
        leadvar2 = new Lead(LastName = 'Test Lead2',company='Test2',isPartnerReject__c=false,
                    Lead_Accept_TimeStamp__c = DateTime.newInstance(System.now().year(), System.now().month(), System.now().day(), System.now().hour(), 0, 0) ,
                    ownerid=thisUser.id, RecordTypeId = recordType.Id,Country='India',Industry='Engineering and Construction',city='Pune',
                    street='dalal',postalcode='100100',Tracking_Division__c='GCCM',Selling_division__c='GCCM',Opportunity_Product__c='Hardware',Email='test@test2.com',Phone='111-111-1111',
                    Address1__c='Test-1',Address2__c='Test-2',Address3__c='Test-3',Address4__c='Test-4');   
        insert leadvar2; 

        opp = new Opportunity();
        opp.Name = 'oppty-00';
        opp.StageName = '1';
        opp.ForecastCategoryName = 'Pipeline';
        opp.CloseDate = Date.newInstance(2013, 12, 1);
        opp.Type = 'New Business';
        opp.ownerId=thisUser.id;
        insert opp;
        
        prod = new Product2();
        prod.IsActive = true;
        prod.Name = 'ABC';
        prod.ProductCode = 'T1';
        prod.Certificate__c = 'C1';
        //prod.Contract_Item_Type_Code__c ='WARRANTY';
        prod.productcode ='Code';
        insert prod;
        
            
        //prodComp = new Product_competitor__c(name='Test Prod Competitor');
        //insert prodComp;        
         
        //compAsset = new Competitor_Owned_Assets__c(name='Test Competitor Asset',Account__c=acct.Id,Product__c=prodComp.Id);
        //insert compAsset;
        
        //compAssetJunc = new Competitor_Assets_Junction__c(Account__c=acct.Id, Lead__c=leadvar.Id , Opportunity__c=opp.Id ,Competitor_Assets__c=compAsset.Id);
        //insert compAssetJunc;
        
        tsk = new Task(whoid=leadvar.id, ownerid=thisUser.Id );
        insert tsk;
        
        CustomLeadConversionController npConstructor = new CustomLeadConversionController();
        Double rnNo = math.random() +2;
        apiUser = new User(ProfileId = prf.Id,Username = System.now().millisecond() + String.valueOf(rnNo)+ 'test2@test.com',
                Alias = 'Test', Email='test@test.com',EmailEncodingKey='UTF-8', Firstname='Test',Lastname='Suite',LanguageLocaleKey='en_US',
                LocaleSidKey='en_US',TimeZoneSidKey='America/Chicago',Country='India',Division__c='MEP');
        
        apiUser2 = new User(ProfileId = prf.Id,Username = System.now().millisecond() + String.valueOf(rnNo+2) + 'trimbleuattest2@test.com',
                Alias = 'Test', Email='test@test.com',EmailEncodingKey='UTF-8', Firstname='Test',Lastname='Suite',LanguageLocaleKey='en_US',
                LocaleSidKey='en_US',TimeZoneSidKey='America/Chicago',Country='Canada',Division__c='GCCM');
    }
    
    private static testmethod void testCustomLeadConversionCont(){
        
        setUpData();
        Test.startTest();  
            System.runAs(apiUser){
                Pagereference pgRef = Page.CustomLeadConversionPage;
                pgRef.getParameters().put('id',leadvar.id);
                Test.setCurrentPage(pgRef);
                
                CustomLeadConversionController cont = new CustomLeadConversionController(new ApexPages.StandardController(leadvar));
                cont.SelAccId= '300000000000001';

                cont.leadobj=leadvar;
                cont.changedConvalue ='Test';
                cont.prepareaccounts();
                cont.preparecontacts();
                cont.DispEnterAddressFields = false;
                cont.DisplayUserErrors();
                cont.Setreminder = true;
                cont.Setcontinueuserselection = true;
                cont.duplicateContact = false;
                cont.AttachtoConExisting = false;
                cont.ConvertLead();
                cont.SelAccountName = 'Attach to Existing:'+acct.Name;
                cont.validateCompetitorAssets();
            }
            
        Test.stopTest();  
    } 

    private static testmethod void testCustomLeadConversionCont2(){
        
        setUpData();
        Test.startTest();  
            System.runAs(apiUser2){
                Pagereference pgRef = Page.CustomLeadConversionPage;
                pgRef.getParameters().put('id',leadvar.id);
                Test.setCurrentPage(pgRef);
                
                CustomLeadConversionController cont = new CustomLeadConversionController(new ApexPages.StandardController(leadvar));
                cont.leadobj=leadvar;
                cont.changedConvalue ='Test';
                cont.prepareaccounts();
                cont.preparecontacts();
                cont.DispEnterAddressFields = false;
                cont.DisplayUserErrors();
            }
            
        Test.stopTest();  
    }
    
    private static testmethod void testCustomLeadConversionCont3(){
        
        setUpData();
        Test.startTest();  
            System.runAs(apiUser2){
                Pagereference pgRef = Page.CustomLeadConversionPage;
                pgRef.getParameters().put('id',leadvar2.id);
                Test.setCurrentPage(pgRef);
                
                CustomLeadConversionController cont = new CustomLeadConversionController(new ApexPages.StandardController(leadvar));
                cont.leadobj=leadvar2;
                cont.changedConvalue ='Test';
                cont.prepareaccounts();
                cont.preparecontacts();
                cont.DispEnterAddressFields = false;
                cont.DisplayUserErrors();
                cont.Setreminder = true;
                cont.Setcontinueuserselection = true;
                cont.duplicateContact = false;
                cont.AttachtoConExisting = false;
                cont.ConvertLead();
                cont.SelAccountName = 'Attach to Existing:'+acct.Name;
                cont.validateCompetitorAssets();
                cont.reorderConPickValues();
                cont.reorderpickValues();
                cont.cancelpopup();
            }
            
        Test.stopTest();  
    }

    private static testmethod void testCustomLeadConversionCont4(){
        
        setUpData();
        Test.startTest();  
            System.runAs(apiUser){
                Pagereference pgRef = Page.CustomLeadConversionPage;
                pgRef.getParameters().put('id',leadvar.id);
                Test.setCurrentPage(pgRef);
                
                acct.FCH_Party_ID__c = '300000000000001';
                update acct;

                CustomLeadConversionController cont = new CustomLeadConversionController(new ApexPages.StandardController(leadvar));
                
                cont.leadobj=leadvar;
                cont.changedConvalue ='Test';
                cont.prepareaccounts();
                cont.preparecontacts();
                cont.DispEnterAddressFields = false;
                cont.DisplayUserErrors();
                cont.Setreminder = true;
                cont.Setcontinueuserselection = true;
                cont.duplicateContact = false;
                cont.AttachtoConExisting = false;
                cont.SetCreatenewAccount = true;
                cont.AttchtoExisting = false;
                cont.selectedtime = '10:00';
                cont.Eventobj.Activitydate = system.today();

                cont.SelAccId= '300000000000000';
                cont.ConvertLead();
                cont.SelAccountName = 'Attach to Existing:'+acct.Name;
                cont.validateCompetitorAssets();
            }
            
        Test.stopTest();  
    }  
    
    private static testmethod void testCustomLeadConversionCont5(){
        
        setUpData();
        Test.startTest();  
            System.runAs(apiUser){
                Pagereference pgRef = Page.CustomLeadConversionPage;
                pgRef.getParameters().put('id',leadvar.id);
                Test.setCurrentPage(pgRef);
                
                CustomLeadConversionController cont = new CustomLeadConversionController(new ApexPages.StandardController(leadvar));
                
                cont.leadobj=leadvar;
                cont.changedConvalue ='Test';
                cont.prepareaccounts();
                cont.preparecontacts();
                cont.DispEnterAddressFields = false;
                cont.DisplayUserErrors();
                cont.Setreminder = true;
                cont.Setcontinueuserselection = true;
                cont.duplicateContact = false;
                cont.AttachtoConExisting = false;
                cont.SetCreatenewAccount = true;
                cont.AttchtoExisting = false;
                cont.selectedtime = '10:00';
                cont.Eventobj.Activitydate = system.today();

                cont.SelAccId = selectId;
                cont.ConvertLead();
                cont.SelAccountName = 'Attach to Existing:'+acct.Name;
                cont.validateCompetitorAssets();
            }
            
        Test.stopTest();  
    }

    private static testmethod void testGettimes(){
        
        setUpData();
        Test.startTest();  
        
            Pagereference pgRef = Page.CustomLeadConversionPage;
            pgRef.getParameters().put('id',leadvar.id);
            Test.setCurrentPage(pgRef);
            
            CustomLeadConversionController cont = new CustomLeadConversionController(new ApexPages.StandardController(leadvar));
            List<SelectOption> lstOption = cont.gettimes();
            System.AssertEquals(lstOption.size()>0,true);
            
        Test.stopTest(); 
    }   

    private static testmethod void testPageRef(){
        
        setUpData();
        Test.startTest();  
        
            Pagereference pgRef = Page.CustomLeadConversionPage;
            pgRef.getParameters().put('id',leadvar.id);
            Test.setCurrentPage(pgRef);
            
            CustomLeadConversionController cont = new CustomLeadConversionController(new ApexPages.StandardController(leadvar));
            System.AssertNotEquals(cont.cancel(),null);
            cont.SelAccountName='Attach to Existing:Test';
            cont.SelAccId= selectId;
            //cont.validateCompetitorAssets();
            cont.SearchCustomerMaster();
            cont.continuetoPage();
            cont.COntinueWithUserSelection();
            cont.cancelAction();
            
        Test.stopTest(); 
    }

    private static testmethod void testvalidateCompetitorAssets(){
    
        setUpData();
        Test.startTest();  
        
            Pagereference pgRef = Page.CustomLeadConversionPage;
            pgRef.getParameters().put('id',leadvar.id);
            Test.setCurrentPage(pgRef);
            
            CustomLeadConversionController cont = new CustomLeadConversionController(new ApexPages.StandardController(leadvar));
            cont.validation=false;
            cont.SelAccountName='Attach to Existing:Test';
            cont.leadid = leadvar.Id;
            //cont.validateCompetitorAssets();
            //System.AssertEquals(cont.AttchtoExisting,false);
            
        Test.stopTest();
    }
    
    private static testmethod void testconvertFromContact(){
        
        setUpData();
        Test.startTest();  
        
            Pagereference pgRef = Page.CustomLeadConversionPage;
            pgRef.getParameters().put('id',leadvar.id);
            Test.setCurrentPage(pgRef);
            
            CustomLeadConversionController cont = new CustomLeadConversionController(new ApexPages.StandardController(leadvar));
            cont.convertFromContact();
            
        Test.stopTest();    
    }
    
    private static testmethod void testConvertLead00(){
        
        setUpData();
        Test.startTest();  
        
            Pagereference pgRef = Page.CustomLeadConversionPage;
            pgRef.getParameters().put('id',leadvar.id);
            Test.setCurrentPage(pgRef);
            
            CustomLeadConversionController cont = new CustomLeadConversionController(new ApexPages.StandardController(leadvar));
            cont.SelAccountName='Attach to Existing:Test';
            cont.SelContactName='Attach to Existing:Test';
            cont.SelAccId = selectId;
            cont.Taskobj = tsk;
            //cont.validateCompetitorAssets();
            cont.ConvertLead();
            //System.AssertEquals(cont.AttchtoExisting,true);
            
        Test.stopTest();    
    }
    
    private static testmethod void testConvertLead01(){
        
        setUpData();
        Test.startTest();  
        
            Pagereference pgRef = Page.CustomLeadConversionPage;
            pgRef.getParameters().put('id',leadvar.id);
            Test.setCurrentPage(pgRef);
            
            acct.FCH_Party_ID__c ='300000000000001';
            update acct;
            
            CustomLeadConversionController cont = new CustomLeadConversionController(new ApexPages.StandardController(leadvar));
            cont.SelAccountName='Attach to Existing:Test';
            cont.SelContactName='Attach to Existing:Test';
            cont.SelAccId = '300000000000001';
            cont.Taskobj = tsk;
            //cont.validateCompetitorAssets();
            cont.ConvertLead();
            //System.AssertEquals(cont.AttchtoExisting,true);
            
        Test.stopTest();    
    }
    
    private static testmethod void testConvertLead02(){
        
        setUpData();
        Test.startTest();  
        
            Pagereference pgRef = Page.CustomLeadConversionPage;
            pgRef.getParameters().put('id',leadvar.id);
            Test.setCurrentPage(pgRef);
                    
            CustomLeadConversionController cont = new CustomLeadConversionController(new ApexPages.StandardController(leadvar));
            cont.SelAccountName='Attach to Existing:Test';
            cont.SelContactName='Attach to Existing:Test';
            cont.SelAccId = 'Test-Test';
            cont.Taskobj = tsk;
            //cont.validateCompetitorAssets();
            cont.ConvertLead();
            //System.AssertEquals(cont.AttchtoExisting,true);
            
        Test.stopTest();    
    }

    private static testmethod void testConvertLeadNegativeCase(){
        setUpData();
        Profile dProf = [Select Id from Profile where Name =: Label.Data_Administrator];
        Double rn1No = math.random() +2;
        User datauser = new User(ProfileId = dProf.Id,Username = System.now().millisecond() + String.valueOf(rn1No+2) + 'trimbleuattest2@test.com',
                Alias = 'Test', Email='test@test.com',EmailEncodingKey='UTF-8', Firstname='Test',Lastname='Suite',LanguageLocaleKey='en_US',
                LocaleSidKey='en_US',TimeZoneSidKey='America/Chicago',Country='Canada',Division__c='GCCM');
        insert datauser;

        Test.startTest();
            System.runAs(datauser){
                leadvar2.Country = '';
                leadvar2.Industry = '';
                leadvar2.city='';
                leadvar2.street='';
                leadvar2.postalcode='';
                leadvar2.Email='';
                leadvar2.Phone='';
                update leadvar2;
                
                Pagereference pgRef = Page.CustomLeadConversionPage;
                pgRef.getParameters().put('id', leadvar2.id);
                Test.setCurrentPage(pgRef);
                
                CustomLeadConversionController cont = new CustomLeadConversionController(new ApexPages.StandardController(leadvar2));
                cont.DisplayUserErrors();
                
                CustomLeadConversionController cont1 = new CustomLeadConversionController(new ApexPages.StandardController(leadvar2));
                cont.DisplayUserErrors();
            }
        Test.stopTest();    
    }
}