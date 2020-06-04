/*****************************************************************************************
  Name    : CaseCommentTrigger_Test 
  Modification Log : 
  ---------------------------------------------------------------------------
  Developer              Date            Description
  ---------------------------------------------------------------------------
  Suresh Babu Murugan   03/08/2015       Created
  ******************************************************************************************/
@isTest(SeeAllData = true)
private class CaseCommentTrigger_Test {
	private static Account acct;
	private static Contact ct;
	private static Case pcs, dcs, cs;
	private static CaseComment ccmt;

	static void setUpData() {
		acct = new Account(Name = 'Test Assign Case Account', RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId(), CurrencyIsoCode = 'USD', Payment_Term__c = 'CASH IN ADVANCE', Account_Status__c = 'Pending', Requested_Account_Record_Type__c = 'Customer',
		                           BillingCountry = 'United States', Restricted_Entity__c = Label.Not_Restricted, Annual_Support_Date__c = date.today(), BillingCity = 'Pune', BillingState = 'California', BillingPostalCode = 'postal code', BillingStreet = 'A-202', Collector_Email__c = 'test@gmail.com');
		insert acct;

		ct = new Contact();
		ct.LastName = 'Test last name';
		ct.AccountId = acct.Id;
		ct.Preferred_Language__c = 'American English';
		ct.Email = 'test@gmail.com';
		ct.MailingCountry = 'United States';
		ct.MailingState = 'California';
		insert ct;

		pcs = new Case();
		pcs.AccountId = acct.Id;
		pcs.ContactId = ct.Id;
		pcs.Status = 'New';
		pcs.TFS_Id__c = '12345';
		pcs.Product__c = 'Prolog Manager';
		pcs.Origin = 'Chat';
		pcs.Serial_Number__c = '12345';
		pcs.TFS_Id__c = '123456';
		pcs.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('GCCM - Support Case Record Type').getRecordTypeId();
		insert pcs;

		dcs = new Case();
		dcs.AccountId = acct.Id;
		dcs.ContactId = ct.Id;
		dcs.Status = 'New';
		dcs.TFS_Id__c = '12345';
		dcs.Product__c = 'Prolog Manager';
		dcs.Origin = 'Chat';
		dcs.Serial_Number__c = '12345';
		dcs.TFS_Id__c = 'PL-123';
		dcs.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('GCCM - Support Issue Record Type').getRecordTypeId();
		insert dcs;

		cs = new Case();
		cs.AccountId = acct.Id;
		cs.ContactId = ct.Id;
		cs.Status = 'New';
		cs.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('GCCM - Support Case Record Type').getRecordTypeId();
		cs.ParentId = pcs.Id;
		cs.Product__c = 'Prolog Manager';
		cs.Origin = 'Chat';
		cs.Serial_Number__c = '12345';
		cs.TFS_Id__c = '123456';
		cs.Defect__c = dcs.Id;
		insert cs;
	}

	static testmethod void caseCommentTriggerMeth1() {
		System.Test.startTest();
		setUpData();
		ccmt = new CaseComment();
		ccmt.ParentId = dcs.Id;
		ccmt.CommentBody = 'Test Comment';
		insert ccmt;

		dcs.CaseComment_JIRA_Mapping__c = ccmt.Id + '=>' + '1233456' + ';';
		update dcs;

		Map<Id, String> mapExistingComments = CaseCommentHandler.returnCaseCommentJIRAIDMapping(dcs.Id);
		System.assertEquals(mapExistingComments != null, true);

		CaseCommentHandler.blnJIRACalloutRestrict = false;
		delete ccmt;

		CaseCommentHandler.setLaunchControl();
		System.Test.stopTest();
	}

	static testmethod void caseCommentTriggerMeth2() {
		System.Test.startTest();
		setUpData();
		ccmt = new CaseComment();
		ccmt.ParentId = dcs.Id;
		ccmt.CommentBody = 'Test Comment';
		insert ccmt;

		dcs.CaseComment_JIRA_Mapping__c = ccmt.Id + '=>' + '1233456' + ';';
		update dcs;

		CaseCommentHandler.resetLaunchControl();
		CaseCommentHandler.blnJIRACalloutRestrict = false;
		ccmt.CommentBody = 'Test 2';
		update ccmt;

		Map<Id, String> mapExistingComments = CaseCommentHandler.returnCaseCommentJIRAIDMapping(dcs.Id);
		System.assertEquals(mapExistingComments != null, true);
		System.Test.stopTest();
	}
}