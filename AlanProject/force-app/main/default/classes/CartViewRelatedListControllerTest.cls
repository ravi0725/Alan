@isTest
Private class CartViewRelatedListControllerTest {

	public static Country_Region_Mapping__c cust;
	public static Geospatial_Country_Region_Mapping__c custRegMap;
	public static Apttus_Proposal__Proposal__c appProp;
	public static UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
	public static Profile profile = [Select Id from Profile where name = 'System Administrator'];
	public static User portalAccountOwner;
	public static Account acct;
	public static Opportunity opp;
	public static Apttus_Config2__PriceList__c pricelist;
	public static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
	public static Apttus_Config2__ProductConfiguration__c prodConfig;
	public static List<Apttus_Approval__Approval_Request__c> appovalLst = new List<Apttus_Approval__Approval_Request__c> ();

	static void setUpData() {
		cust = new Country_Region_Mapping__c(name = 'India', Region__c = 'India');
		insert cust;

		custRegMap = new Geospatial_Country_Region_Mapping__c(name = 'India', Region__c = 'India');
		insert custRegMap;

		MEP_NA_Payment_Method__c paymentMeth = new MEP_NA_Payment_Method__c(Name = 'CASH IN ADVANCE', Payment_Method__c = 'Check');
		insert paymentMeth;

		/*
		  Group testGroup = new Group(Name = 'CartView Test group', Type = 'Queue');
		  insert testGroup;
		 
		  GroupMember tstGroupMem = new GroupMember(GroupId = testGroup.Id, UserOrGroupId = UserInfo.getUserId());
		  insert tstGroupMem;
		 */
		User thisUser = [select Id from User where Id = :UserInfo.getUserId()];
		System.runAs(thisUser) {
			portalAccountOwner = new User(UserRoleId = portalRole.Id, ProfileId = profile.Id, Username = System.now().millisecond() + 'test2@test.com',
			                              Alias = 'Test', Email = 'test@test.com', EmailEncodingKey = 'UTF-8', Firstname = 'Test', Lastname = 'Suite', LanguageLocaleKey = 'en_US',
			                              LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Chicago', Country = 'India');
			//insert portalAccountOwner;
		}

		pricelist = new Apttus_Config2__PriceList__c();
		pricelist.Apttus_Config2__Active__c = true;
		pricelist.Name = 'TIBV CH Test';
		pricelist.Legal_Entity__c = 'TIBV US BRANCH';
		insert pricelist;

		acct = new Account(Name = 'Test Assign Case Account', RecordTypeId = acctRecTypeId, Account_Status__c = 'Pending', Requested_Account_Record_Type__c = 'Customer',
		                   BillingCountry = 'India', BillingCity = 'Pune', BillingStreet = 'A-202');
		insert acct;

		opp = new Opportunity();
		opp.AccountId = acct.Id;
		opp.StageName = 'Inquery';
		opp.Closedate = date.today() + 7;
		opp.Name = 'Opp1';
		opp.CurrencyISOCode = 'USD';
		opp.Selling_Division__c = 'MEP NA';
		opp.Ship_To_Account__c = acct.ID;
		opp.Payment_Term__c = 'CASH IN ADVANCE';
		opp.Type = 'New Business';
		opp.Account_Sub_Type__c = 'Additional Licenses';
		opp.OwnerId = UserInfo.getUserId();
		insert opp;

		appProp = new Apttus_Proposal__Proposal__c();
		appProp.Apttus_Proposal__Proposal_Name__c = 'TestGenerateQuote' + String.valueOf(Integer.valueof((Math.random() * 100))); //--added by Chandrakanth to overcome error of Null pointer exception related to Proposal Attachments
		appProp.Apttus_Proposal__Account__c = acct.Id;
		appProp.Apttus_QPConfig__BillToAccountId__c = acct.id;
		appProp.Apttus_Proposal__Opportunity__c = opp.Id;
		appProp.Apttus_QPConfig__PriceListId__c = pricelist.Id;
		appProp.Ship_To_Account__c = acct.Id;
		appProp.OwnerId = UserInfo.getUserId();
		appProp.Apttus_Proposal__Primary__c = true;
		appProp.Industry__c = 'Electrical';
		appProp.Freight_Method__c = 'N/A';
		appProp.Freight_Terms__c = 'N/A';
		appProp.Payment_Method__c = 'INVOICE';
		//appProp.Clone_ID__c='Q-00012683';
		insert appProp;

		prodConfig = new Apttus_Config2__ProductConfiguration__c(name = 'Test Product Config', Apttus_QPConfig__Proposald__c = appProp.id);
		insert prodConfig;

		List<Group> lstGrp = [SELECT Name, Id FROM Group WHERE DeveloperName = 'MEPNA_Final_Approver'];

		appovalLst.add(new Apttus_Approval__Approval_Request__c(Apttus_Approval__Approval_Status__c = 'Assigned', Apttus_Approval__Assigned_To_Type__c = 'Queue',
		                                                        Apttus_Approval__Assigned_To_Id__c = lstGrp.get(0).Id, Apttus_CQApprov__CartId__c = prodConfig.id));

		insert appovalLst;

	}

	private static testmethod void testvalidateChecks() {

		setUpData();
		Test.startTest();
		CartViewRelatedListController cont = new CartViewRelatedListController(new ApexPages.StandardController(appProp));
		cont.validateChecks();
		cont.loadMoreApprovalRequest();
		cont.retrieveApprovaHistoryList();
		Test.stopTest();

	}

	private static testmethod void testApprovaHistoryList() {

		setUpData();
		Test.startTest();

		Pagereference pgRef = Page.CartViewApprovalList;
		pgRef.getParameters().put('id', appProp.id);
		Test.setCurrentPage(pgRef);

		CartViewRelatedListController cont = new CartViewRelatedListController(new ApexPages.StandardController(appProp));
		cont.retrieveApprovaHistoryList();
		cont.viewattach();

		Test.stopTest();
	}

	private static testmethod void ApprovalRequestListenerTEST() {

		setUpData();
		Test.startTest();

		update appovalLst;

		Test.stopTest();
	}
}