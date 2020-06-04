@isTest
private class CreateAccountOrPartyTest{

    private static Country_Region_Mapping__c cust;
    private static Geospatial_Country_Region_Mapping__c custRegMap ;
    private static Account acct;
    private static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    private static User thisUser ;
    private static List<CreateAccountOrParty.RequestWrpaerClass>  reqacct00= new List<CreateAccountOrParty.RequestWrpaerClass>();
    private static List<CreateAccountOrParty.RequestWrpaerClass>  reqacct01= new List<CreateAccountOrParty.RequestWrpaerClass>();
    private static List<CreateAccountOrParty.RequestUpdateWrpaerClass>  updacct00= new List<CreateAccountOrParty.RequestUpdateWrpaerClass>();
    
    static void setUpData(){
        
        cust = new Country_Region_Mapping__c(name='India',Region__c='India');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='India',Region__c='India');
        insert custRegMap;
        
        thisUser = [select Id, name , email from User where Id = :UserInfo.getUserId()];
        
        acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
            BillingCountry = 'India',BillingCity = 'Pune',BillingStreet = 'A-202',OwnerId = thisUser.Id ,FCH_Party_ID__c='100',Phone='111-111-1111',BillingState='Goa',
            BillingPostalCode ='343220');
        insert acct;
        
        CreateAccountOrParty.RequestWrpaerClass req00 = new CreateAccountOrParty.RequestWrpaerClass();
        
        req00.CustomerName ='Test';
        req00.LifecycleStage='Test';
        req00.CustomerLevel='Test';
        req00.Channel='Test';
        req00.PrimaryRegion='Test';
        req00.SelltoFlag='Test';
        req00.PrimaryEmailAddress='Test';      
        req00.AddressValidated='yes';
        req00.Address1='Test';
        req00.Address2='Test';
        req00.Address3='Test';
        req00.Address4='Test';
        req00.City=acct.BillingCity;
        req00.State=acct.BillingState;
        req00.Country='IN';
        req00.PostalCode=acct.BillingPostalCode;
        req00.party_OriginalSystem='Test';
        req00.Party_OriginalSystemReference='Test';
        req00.Party_originalsystemParent=acct.Id;                       
        req00.BillingStreet=acct.BillingStreet;
        req00.Email='test@test.com';
        req00.EnterpriseMasterID=null;        
        req00.AccountForecastOwner=String.ValueOf(thisUser.Id);
        req00.AccountStatus='Active';
        req00.AnnualRevenue=100;//double
        req00.AccountSource='Test';
        req00.BillingLatitude=100;//double
        req00.BillingLongitude=100;//double
        req00.CurrencyIsoCode='USD';
        req00.DUNS='Test';
        req00.Description='Test';
        req00.Division='Test';
        req00.Fax='Test';
        req00.ForecastAccount=true;//boolean
        req00.Industry='Test';
        req00.JigsawCompanyId='Test';
        req00.LegacySystem='Test';
        req00.MarketingSegment='Test';
        req00.NAICSCode='Test';
        req00.NumberOfEmployees=100;
        req00.OracleID='Test';
        req00.Ownership='Test';
        req00.Phone='Test';
        req00.Rating='Test';
        req00.SicDesc='Test';
        req00.SICCodedel='Test';
        req00.SellThrough='Test';
        req00.ShippingCity='Test';
        req00.ShippingCountry='Test';
        req00.ShippingState='Test';       
        req00.ShippingStreet='Test';
        req00.ShippingLatitude=100;//double
        req00.ShippingLongitude=100;//double
        req00.ShippingPostalCode='Test';
        req00.Site='Test';
        req00.webSite='Test.com'; 
        req00.SubType='Test';
        req00.SubmittedforApproval=true; //boolean    
        req00.Type='Test';        
        req00.pwccBillingAddressStatus='Test';
        req00.pwccShippingAddressStatus='Test';
        req00.subindustry='Test';            
        req00.EnterpriseParentID=null;
        req00.GlobalOptOut='Yes';
        req00.RestrictedPartyIndicator='Test';
        req00.VerticalClassification='Test'; 
        req00.CreditStatus='Test';
        req00.BilltoFlag='Yes';
        req00.ShiptoFlag='Yes';
        req00.EndUserFlag='Yes';
        req00.InstalledatFlag='Yes';
        req00.AccountOwnerEmail =thisUser.email;
        req00.DoNotMerge='Test';
        req00.TaxId='Test';
        req00.Language='Test';
        req00.AddressCheckResults='Test';
        req00.EnterprisePartyNumber='Test';
        req00.PartySiteName='Test';
        
        CreateAccountOrParty.RequestWrpaerClass req01 = new CreateAccountOrParty.RequestWrpaerClass();
        
        req01.CustomerName ='Test';
        req01.LifecycleStage='Test';
        req01.CustomerLevel='Test';
        req01.Channel='Test';
        req01.PrimaryRegion='Test';
        req01.SelltoFlag='Test';
        req01.PrimaryEmailAddress='Test';      
        req01.AddressValidated='yes';
        req01.Address1='Test';
        req01.Address2='Test';
        req01.Address3='Test';
        req01.Address4='Test';
        req01.City=acct.BillingCity;
        req01.State=acct.BillingState;
        req01.Country=acct.BillingCountry;
        req01.PostalCode=acct.BillingPostalCode;
        req01.party_OriginalSystem='Test';
        req01.Party_OriginalSystemReference='Test';
        req01.Party_originalsystemParent=acct.Id;                       
        req01.BillingStreet=acct.BillingStreet;
        req01.Email='test@test.com';
        req01.EnterpriseMasterID=null;
        req01.AccountForecastOwner=String.ValueOf(thisUser.Id);        
        req01.AccountStatus='Active';
        req01.AnnualRevenue=100;//double
        req01.AccountSource='Test';
        req01.BillingLatitude=100;//double
        req01.BillingLongitude=100;//double
        req01.CurrencyIsoCode='USD';
        req01.DUNS='Test';
        req01.Description='Test';
        req01.Division='Test';
        req01.Fax='Test';
        req01.ForecastAccount=true;//boolean
        req01.Industry='Test';
        req01.JigsawCompanyId='Test';
        req01.LegacySystem='Test';
        req01.MarketingSegment='Test';
        req01.NAICSCode='Test';
        req01.NumberOfEmployees=100;
        req01.OracleID='Test';
        req01.Ownership='Test';
        req01.Phone='Test';
        req01.Rating='Test';
        req01.SicDesc='Test';
        req01.SICCodedel='Test';
        req01.SellThrough='Test';
        req01.ShippingCity='Test';
        req01.ShippingCountry='Test';
        req01.ShippingState='Test';       
        req01.ShippingStreet='Test';
        req01.ShippingLatitude=100;//double
        req01.ShippingLongitude=100;//double
        req01.ShippingPostalCode='Test';
        req01.Site='Test';
        req01.webSite='Test.com'; 
        req01.SubType='Test';
        req01.SubmittedforApproval=true; //boolean    
        req01.Type='Test';        
        req01.pwccBillingAddressStatus='Test';
        req01.pwccShippingAddressStatus='Test';
        req01.subindustry='Test';            
        req01.EnterpriseParentID=null;
        req01.GlobalOptOut='Yes';
        req01.RestrictedPartyIndicator='Test';
        req01.VerticalClassification='Test'; 
        req01.CreditStatus='Test';
        req01.BilltoFlag='Yes';
        req01.ShiptoFlag='Yes';
        req01.EndUserFlag='Yes';
        req01.AccountOwnerEmail =thisUser.email;
        req01.DoNotMerge='Test';
        req01.TaxId='Test';
        req01.Language='Test';
        req01.AddressCheckResults='Test';
        req01.EnterprisePartyNumber='Test';
        req01.PartySiteName='Test';
        
        reqacct00.add(req00);
        reqacct01.add(req01);
        
        CreateAccountOrParty.RequestUpdateWrpaerClass upd00 = new CreateAccountOrParty.RequestUpdateWrpaerClass();
        upd00.CustomerName='Test';
        upd00.EnterpriseMasterID='Test';       
        upd00.LifecycleStage='Test';
        upd00.CustomerLevel='Test';
        upd00.Channel='Test';
        upd00.PrimaryRegion='Test';
        upd00.SelltoFlag='Test';
        upd00.PrimaryEmailAddress='Test';        
        upd00.AddressValidated='Test';
        upd00.Address1='Test';
        upd00.Address2='Test';
        upd00.Address3='Test';
        upd00.Address4='Test';
        upd00.City='Test';
        upd00.State='Test';
        upd00.Country='Test';
        upd00.PostalCode='Test';
        upd00.party_OriginalSystem ='SFDC';
        upd00.Party_OriginalSystemReference=acct.Id;
        upd00.Party_originalsystemParent='Test';              
        upd00.BillingStreet='Test';
        upd00.Email='Test';       
        upd00.AccountForecastOwner=String.ValueOf(thisUser.Id);
        upd00.AccountStatus='Test';
        upd00.AnnualRevenue=100;
        upd00.AccountSource='Test';
        upd00.BillingLatitude=100;
        upd00.BillingLongitude=100;
        upd00.CurrencyIsoCode='Test';
        upd00.DUNS='Test';
        upd00.Description='Test';
        upd00.Division='Test';
        upd00.Fax='Test';
        upd00.ForecastAccount=true;  
        upd00.Industry='Test';
        upd00.JigsawCompanyId='Test';
        upd00.LegacySystem='Test';
        upd00.MarketingSegment='Test';
        upd00.NAICSCode='Test';
        upd00.NumberOfEmployees=100;
        upd00.OracleID='Test';
        upd00.Ownership='Test';
        upd00.Phone='Test';
        upd00.Rating='Test';
        upd00.SicDesc='Test'; 
        upd00.SICCodedel='Test';
        upd00.SellThrough='Test';
        upd00.ShippingCity='Test';
        upd00.ShippingCountry='Test';
        upd00.ShippingState='Test';       
        upd00.ShippingStreet='Test';
        upd00.ShippingLatitude=100;
        upd00.ShippingLongitude=100;
        upd00.ShippingPostalCode='Test';
        upd00.Site='Test';
        upd00.webSite='Test';  
        upd00.SubType='Test';
        upd00.SubmittedforApproval=true;     
        upd00.Type='Test';        
        upd00.pwccBillingAddressStatus='Test';
        upd00.pwccShippingAddressStatus='Test';
        upd00.subindustry='Test';        
        upd00.EnterpriseParentID=null;
        upd00.GlobalOptOut='Yes';
        upd00.RestrictedPartyIndicator='Test';
        upd00.VerticalClassification='Test';
        upd00.CreditStatus='Test';
        upd00.BilltoFlag='Yes';
        upd00.ShiptoFlag='Yes';
        upd00.EndUserFlag='Yes';
        upd00.InstalledatFlag='Yes';
        upd00.AccountOwnerEmail='Test';
        upd00.DoNotMerge='Test';
        upd00.TaxId='Test';
        upd00.Language='Test';
        upd00.AddressCheckResults='Test';
        upd00.EnterprisePartyNumber='Test';
        upd00.PartySiteName='Test';
        
        updacct00.add(upd00);
        
    }   
    
    private static testmethod void testCreateAccountOrParty00(){
        
            setUpData();
            Test.startTest();
                List<CreateAccountOrParty.ResponseWrpaerClass> resList = CreateAccountOrParty.CreateParty(reqacct00);
                
            Test.stopTest();
    } 
    private static testmethod void testCreateAccountOrParty01(){
        
            setUpData();
            Test.startTest();
                List<CreateAccountOrParty.ResponseWrpaerClass> resList = CreateAccountOrParty.CreateParty(reqacct01);
                
            Test.stopTest();
    } 
    
    private static testmethod void testCreateAccountOrParty02(){
        
            setUpData();
            Test.startTest();
                List<CreateAccountOrParty.ResponseWrpaerClass> resList = CreateAccountOrParty.UpdateParty(updacct00);
                
            Test.stopTest();
    } 

}