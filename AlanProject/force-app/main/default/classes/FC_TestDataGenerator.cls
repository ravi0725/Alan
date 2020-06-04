@isTest
public class FC_TestDataGenerator {

    public static Integer NUM_ACCOUNTS = 20;
    private static Profile[] profiles = [select Id, Name from Profile];
    
    public static void insertSetupData() {
        Country_Region_Mapping__c cust = new Country_Region_Mapping__c(name='United States',Region__c='United States');
        insert cust;
        
        Geospatial_Country_Region_Mapping__c custRegMap = new Geospatial_Country_Region_Mapping__c(name='United States',Region__c='United States');
        insert custRegMap;
        
    }
    
    public static Account[] generateAccounts() {
        Account[] accounts = new List<Account>();
        for (Integer i = 0; i < NUM_ACCOUNTS; i++) {
            System.debug(LoggingLevel.ERROR, 'i = ' + i);
            accounts.add(new Account(Name = 'Test Account ' + i, 
                BillingStreet = '123 Main St',
                BillingCity = 'New York',
                BillingCountry = 'United States',
                BillingState = 'NY',
				BillingPostalCode = '94089',
                Industry = 'Biotechnology'));
        }
        return accounts;
    } 
    
    public static Apttus__APTS_Agreement__c[] generateAgreements(RecordType rt, Account[] accounts) {
        Apttus__APTS_Agreement__c[] agreements = new List<Apttus__APTS_Agreement__c>();
        for (Account acc : accounts) {
        	agreements.add(
	            new Apttus__APTS_Agreement__c(Name = 'test',
	                Apttus__Account__c = acc.Id,
	                RecordTypeId = rt.Id,
	                Apttus__Contract_Start_Date__c = Date.today(),
	                Apttus__Status_Category__c = 'Request',
	                Apttus__Status__c = 'Request'));
        }
        return agreements;
    }
    
    public static Apttus__APTS_Agreement__c[] generateAgreements(RecordType rt, Apttus_Proposal__Proposal__c[] proposals) {
        Apttus__APTS_Agreement__c[] agreements = new List<Apttus__APTS_Agreement__c>();
        for (Apttus_Proposal__Proposal__c proposal : proposals) {
        	agreements.add(
	            new Apttus__APTS_Agreement__c(Name = 'test',
	                Apttus__Account__c = proposal.Apttus_Proposal__Account__c,
	                RecordTypeId = rt.Id,
	                Apttus_QPComply__RelatedProposalId__c = proposal.Id,
	                Apttus__Contract_Start_Date__c = Date.today(),
	                Apttus__Status_Category__c = 'Request',
	                Apttus__Status__c = 'Request'));
        }
        return agreements;
    }
    
    public static Apttus__AgreementLineItem__c[] generateAgreementLineItems(Apttus__APTS_Agreement__c agreement, Integer numLineItems) {
        Apttus__AgreementLineItem__c[] lineItems = new List<Apttus__AgreementLineItem__c>();
        for (Integer i = 0; i < numLineItems; i++) {
            lineItems.add(new Apttus__AgreementLineItem__c(Apttus__AgreementId__c = agreement.Id,
                Apttus__Description__c = 'line item ' + i,
                Apttus__Quantity__c = 1,
                Apttus__ListPrice__c = 100, 
                Apttus__ExtendedPrice__c = 100,
                Apttus__NetPrice__c = 100, 
                Apttus_CMConfig__ItemSequence__c = i, 
                Apttus_CMConfig__LineNumber__c = i));
        }
        return lineItems;
    }
    
    public static Contact[] generateContacts(Account[] accounts) {
        Contact[] contacts = new List<Contact>();
        Integer i = 1;
        for (Account acc : accounts) {
            contacts.add(new Contact(
                AccountId = acc.Id,
				LastName = 'Test last ' + i, 
				FirstName = 'Test first ' + i, 
				MailingStreet = '1 Main St',
				MailingCountry = 'United States', 
				Preferred_Language__c = 'American English',
				Salutation = 'Mr.'));
			i += 1;
        }
        return contacts;
    }
    
    public static CurrencyType[] generateCurrencyTypes() {
        CurrencyType[] types = new List<CurrencyType>();
        types.add(new CurrencyType(ConversionRate = 0.89, DecimalPlaces = 2, IsoCode = 'EUR', IsActive = true, IsCorporate = false));
        types.add(new CurrencyType(ConversionRate = 1.063502, DecimalPlaces = 2, IsoCode = 'CAD', IsActive = true, IsCorporate = false));
        types.add(new CurrencyType(ConversionRate = 1, DecimalPlaces = 2, IsoCode = 'USD', IsActive = true, IsCorporate = true));
        return types;
    }
    
    public static Opportunity[] generateOpportunities(Account[] accounts) {
        Opportunity[] opps = new List<Opportunity>();
        for (Account acc : accounts) {
            opps.add(new Opportunity(Name = 'test Opportunity',
            	AccountId = acc.Id,
            	StageName = '4 - Proposal/Price Quote',
            	CurrencyIsoCode = 'USD',
            	CloseDate = Date.today()));
        }
        return opps;
    }
    
    public static Apttus_Config2__PriceList__c generatePriceList() {
        return new Apttus_Config2__PriceList__c(
			Apttus_Config2__EffectiveDate__c = Datetime.now(), 
			CurrencyIsoCode = 'USD', 
			Organization__c = 'Trimble Navigation Limited',
			Apttus_Config2__Active__c = true, 
			Apttus_Config2__Type__c = 'Standard', 
			Name = 'ARFC MANHATTAN PL16052015', 
			Oracle_ID__c = 765703.0, 
			Business_Area__c = 'MANHATTAN SOFTWARE', 						//this must match PPM_Template_Map__c
			Apttus_Config2__Description__c = 'ARFC MANHATTAN PL16052015'
        );
    }
    
    public static Apttus_Proposal__Proposal__c[] generateProposals(Opportunity[] opportunities, Apttus_Config2__PriceList__c newCMConfigPriceList) {
        Apttus_Proposal__Proposal__c[] proposals = new List<Apttus_Proposal__Proposal__c>();
        for (Opportunity opp : opportunities) {
            proposals.add(new Apttus_Proposal__Proposal__c(
                Apttus_Proposal__Approval_Stage__c =  'Draft' , 
				Recalculate_tax__c =  false , 
				Software_Total_Disp_Rounded__c =  0.0 , 
				Third_Party_Disc_Disp_Rounded__c =  0.0 , 
				Hardware_Discount_Disp_Rounded__c =  0.0 , 
				Apttus_Proposal__ReadyToPresent__c =  true , 
				Hardware_Total_Disp_Rounded__c =  0.0 , 
				Apttus_Proposal__ReadyToGenerate__c =  true , 
				Apttus_Proposal__Account__c =  opp.AccountId , 
				Apttus_QPConfig__AutoActivateOrder__c =  false , 
				Service_Total_Disp_Rounded__c =  0.0 , 
				Apttus_Proposal__Primary__c =  true , 
				Apttus_QPConfig__PriceListId__c =  newCMConfigPriceList.Id , 
				Obsolete_Quote__c =  false , 
				is_Order__c =  false , 
				Final_Config__c =  false , 
				Apttus_QPConfig__PricingDate__c =  Datetime.now() , 
				Maintenance_Total_Disp_Rounded__c =  0.0 , 
				Software_Disc_Disp_Rounded__c =  0.0 , 
				Apttus_QPConfig__AutoCreateRevenue__c =  false , 
				Schulung_Basis_Gewerke__c =  true , 
				Schulung_Basis_CAD__c =  true , 
				Standard_T_Cs__c =  true , 
				Ship_To_Account__c =  opp.AccountId , 
				Software_Only_Total_Disp_Rounded__c =  0.0 , 
				Payment_Terms_In_Opportunity__c =  'IMMEDIATE' , 
				CurrencyIsoCode =  'USD' , 
				Include_Pricing_Details__c =  false , 
				Schulung_Raumlufttechnik_K_hllast__c =  true , 
				Third_Party_Total_Disp_Rounded__c =  0.0 , 
				Clone_ID__c =  'Q-00017567' , 
				Custom_T_C__c =  false , 
				Apttus_Proposal__Valid_Until_Date__c =  Date.today() , 
				Apttus_Proposal__Proposal_Name__c =  'Customer#1 -' , 
				Service_Discount_Disp_Rounded__c =  0.0 , 
				Apttus_Proposal__Opportunity__c =  opp.Id ,		//required to match currency code 
				Accept_Auto_Renew__c =  true , 
				Schulung_Sanit_rtechnik__c =  true , 
				Schulung_Elektro__c =  true , 
				Software_Disc_2dec_Rounded__c =  0.0 , 
				Apttus_QPConfig__AutoCreateBill__c =  false));
        }
        return proposals;
    }
    
    public static User generateUser(String userName, String profileName) {
        String lastName = userName.split('@')[0];
        return new User(LastName = lastName,
            Alias = lastName.right(8), 
            Email = userName,  
            EmailEncodingKey = 'UTF-8', 
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', 
            // ProfileId = fcf.ProfileUtil.findByName(profileName).Id,
            TimeZoneSidKey = 'America/New_York', 
            UserName = userName);
    }
}