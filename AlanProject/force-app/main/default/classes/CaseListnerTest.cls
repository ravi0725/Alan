/*****************************************************************************************
  Name    : CaseListnerTest 
  Modification Log : 
  ---------------------------------------------------------------------------
  Developer              Date            Description
  ---------------------------------------------------------------------------
  P M Mamata       03/08/2015          Created
  ******************************************************************************************/
@isTest(seealldata = true)

private class CaseListnerTest {
	static testmethod void caseListner1() {
		test.startTest();
		GenerateTestData.createAccount();
		GenerateTestData.createContact();
		GenerateTestData.createParentCase();

		CaseHandler.resetLaunchControl();
		Case oCase1 = new Case();
		oCase1.AccountId = GenerateTestData.acct.Id;
		oCase1.ContactId = GenerateTestData.ct.Id;
		oCase1.Status = 'New';
		oCase1.TFS_Id__c = '12345';
		oCase1.Product__c = 'Prolog';
		oCase1.Origin = 'Chat';
		oCase1.Serial_Number__c = '12345';
		oCase1.TFS_Id__c = '123456';
		oCase1.Defect__c = oCase1.Id;
		oCase1.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('GCCM - Support Issue Record Type').getRecordTypeId();
		oCase1.Temp_Case_Id__c = GenerateTestData.pcs.Id;
		oCase1.Fixed_in_Build_PLM__c = true;
		insert oCase1;

		Case oCase = new Case();
		oCase.AccountId = GenerateTestData.acct.Id;
		oCase.ContactId = GenerateTestData.ct.Id;
		oCase.Status = 'New';
		oCase.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('GCCM - Support Case Record Type').getRecordTypeId();
		oCase.ParentId = GenerateTestData.pcs.Id;
		oCase.Product__c = 'Prolog Manager';
		oCase.Origin = 'Chat';
		oCase.Serial_Number__c = '12345';
		oCase.TFS_Id__c = '123456';
		oCase.Defect__c = oCase1.Id;
		insert oCase;

		CaseHandler.resetLaunchControl();
		update oCase;
        
        CaseHandler.resetLaunchControl();
        oCase1.Planning_Priority__c = 'ERPP1 - Next Release';
        update oCase1;

		test.stopTest();
	}

	static testmethod void caseListner2() {
		test.startTest();
		List<Case> lstCases = new List<Case> ();
		List<Id> lstCaseIds = new List<Id> ();
		GenerateTestData.createAccount();
		GenerateTestData.createProduct2();
		GenerateTestData.createContact();

		Asset oAsset = new Asset();
		oAsset.Name = 'Test Asset';
		oAsset.AccountId = GenerateTestdata.acct.Id;
		oAsset.Product2Id = GenerateTestData.prd.Id;
		oAsset.SerialNumber = '12345';
		insert oAsset;

		Case oCase = new Case();
		oCase.AccountId = GeneratetestData.acct.Id;
		oCase.ContactId = GeneratetestData.ct.Id;
		oCase.Status = 'New';
		oCase.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('GCCM - Support Case Record Type').getRecordTypeId();
		oCase.Product__c = 'Prolog Manager';
		oCase.Origin = 'Chat';
		oCase.Serial_Number__c = '12345';
		oCase.TFS_Id__c = '123456';
		oCase.Sales_Ops_Comments__c = 'test gccm case';
		insert oCase;

		lstCases.add(oCase);
		lstCaseIds.add(oCase.Id);
		CaseHandler ch = new CaseHandler();
		CaseHandler.makeCallout(lstCaseIds, true, true);
		CaseHandler.callTFS(lstCaseIds, true, true);
		CaseHandler.configCase(lstCases);
		test.stopTest();
	}

	static testmethod void caseListner3() {
		test.startTest();
		List<Case> lstCases = new List<Case> ();
		List<Id> lstCaseIds = new List<Id> ();
		GenerateTestData.createAccount();
		GenerateTestData.createProduct2();
		GenerateTestData.createContact();

		Asset oAsset = new Asset();
		oAsset.Name = 'Test Asset';
		oAsset.AccountId = GenerateTestdata.acct.Id;
		oAsset.Product2Id = GenerateTestData.prd.Id;
		oAsset.SerialNumber = '12345';
		insert oAsset;

		Case oCase = new Case();
		oCase.AccountId = GeneratetestData.acct.Id;
		oCase.ContactId = GeneratetestData.ct.Id;
		oCase.Status = 'New';
		oCase.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('GCCM - Support Case Record Type').getRecordTypeId();
		oCase.Product__c = 'Prolog Manager';
		oCase.Origin = 'Chat';
		oCase.Serial_Number__c = '12345';
		oCase.TFS_Id__c = '123456';
		oCase.Sales_Ops_Comments__c = 'test gccm case';
		insert oCase;

		delete oCase;
		test.stopTest();
	}

	static testmethod void caseListner4() {
		test.startTest();
		List<Case> lstCases = new List<Case> ();
		List<Id> lstCaseIds = new List<Id> ();
		GenerateTestData.createAccount();
		GenerateTestData.createProduct2();
		GenerateTestData.createContact();
		GenerateTestData.createAsset();
		GenerateTestData.createEntitlement();

		Case oCase = new Case();
		oCase.AccountId = GeneratetestData.acct.Id;
		oCase.ContactId = GeneratetestData.ct.Id;
		oCase.Status = 'New';
		oCase.AssetId = GenerateTestData.asst.Id;
		oCase.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('TAP - Customer Support').getRecordTypeId();
		insert oCase;
	}

	static testmethod void caseListner5() {
		test.startTest();
		List<Case> lstCases = new List<Case> ();
		List<Id> lstCaseIds = new List<Id> ();
		GenerateTestData.createAccount();
		GenerateTestData.createProduct2();
		GenerateTestData.createContact();
		GenerateTestData.createAsset();
		GenerateTestData.createEntitlement();

		Case oCase = new Case();
		oCase.AccountId = GeneratetestData.acct.Id;
		oCase.ContactId = GeneratetestData.ct.Id;
		oCase.Status = 'New';
		oCase.AssetId = GenerateTestData.asst.Id;
		oCase.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(Label.MEP_NA_Case_Record_Type).getRecordTypeId();
		insert oCase;

		oCase.Status = 'Closed';
		update oCase;
	}

	static testmethod void caseListner6() {
		test.startTest();
		List<Case> lstCases = new List<Case> ();
		List<Id> lstCaseIds = new List<Id> ();
		GenerateTestData.createAccount();
		GenerateTestData.createProduct2();
		GenerateTestData.createContact();
		GenerateTestData.createAsset();
		GenerateTestData.createEntitlement();

		Case oCase = new Case();
		oCase.AccountId = GeneratetestData.acct.Id;
		oCase.ContactId = GeneratetestData.ct.Id;
		oCase.Status = 'New';
		oCase.AssetId = GenerateTestData.asst.Id;
		oCase.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('GCCM - Support Case Record Type').getRecordTypeId();
		insert oCase;

		oCase.Status = 'Closed';
		update oCase;
	}

	static testmethod void caseListner7() {
		test.startTest();
		List<Case> lstCases = new List<Case> ();
		List<Id> lstCaseIds = new List<Id> ();
		GenerateTestData.createAccount();
		GenerateTestData.createProduct2();
		GenerateTestData.createContact();
		GeneratetestData.createParentCase();
		GenerateTestdata.createdefectCase();
		GenerateTestData.createCase();


		Asset oAsset = new Asset();
		oAsset.Name = 'Test Asset';
		oAsset.AccountId = GenerateTestdata.acct.Id;
		oAsset.Product2Id = GenerateTestData.prd.Id;
		oAsset.SerialNumber = '12345';
		insert oAsset;

		lstCases.add(GenerateTestData.cs);
		lstCaseIds.add(GenerateTestData.cs.Id);
		CaseHandler ch = new CaseHandler();
		CaseHandler.makeCallout(lstCaseIds, true, true);
		CaseHandler.callTFS(lstCaseIds, true, true);
		CaseHandler.configCase(lstCases);
		test.stopTest();
	}

	static testmethod void caseListner8() {
		GenerateTestData.createAccount();
		GenerateTestData.createContact();
		List<Case> lstCases = new List<Case> ();
		List<Id> lstCaseIds = new List<Id> ();

		Case doCase = new Case();
		doCase.AccountId = GenerateTestdata.acct.Id;
		doCase.ContactId = GenerateTestdata.ct.Id;
		doCase.Status = 'New';
		doCase.TFS_Id__c = '12345';
		doCase.Product__c = 'Prolog';
		doCase.TFS_Status__c = 'New';
		doCase.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('GCCM - Support Issue Record Type').getRecordTypeId();
		insert doCase;

		CaseHandler.launchControl.put('createTFSTrackingHistory', 0);
		doCase.TFS_Status__c = 'Open';
		//insert doCase;
		update doCase;
	}
	static testmethod void caseListner9() {
		GenerateTestData.createAccount();
		GenerateTestData.createContact();
		Case doCase = new Case();
		List<Case> lstCases = new List<Case> ();

		lstCases.add(doCase);

		Case oCase = new Case();
		oCase.AccountId = GenerateTestData.acct.Id;
		oCase.ContactId = GenerateTestData.ct.Id;
		oCase.Status = 'New';
		oCase.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('GCCM - Support Case Record Type').getRecordTypeId();
		oCase.Product__c = 'Prolog Connect';
		oCase.Origin = 'Chat';
		oCase.Serial_Number__c = 'test';
		oCase.TFS_Id__c = '123456';
		oCase.Defect__c = doCase.Id;
		oCase.Clone_Case_Number__c = '12345';
		CaseHandler.launchControl.put('copyChatTranscriptsToCloneCase', 0);
		CaseHandler.launchControl.put('CaseCountOnIssue', 0);
		insert oCase;
	}

	static testmethod void caseListner10() {
		GenerateTestData.createAccount();
		GenerateTestData.createContact();

		Case oCase = new Case();
		Case oIssue = new Case();

		oCase.AccountId = GenerateTestData.acct.Id;
		oCase.ContactId = GenerateTestData.ct.Id;
		oCase.Status = 'New';
		oCase.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('GCCM - Support Case Record Type').getRecordTypeId();
		oCase.Product__c = 'Prolog Connect';
		oCase.Origin = 'Chat';
		oCase.Serial_Number__c = 'test';
		oCase.TFS_Id__c = '123456';
		oCase.Defect__c = oIssue.Id;
		oCase.Clone_Case_Number__c = '12345';

		oIssue.AccountId = GenerateTestdata.acct.Id;
		oIssue.ContactId = GenerateTestdata.ct.Id;
		oIssue.Status = 'New';
		oIssue.TFS_Id__c = '12345';
		oIssue.Product__c = 'Prolog';
		oIssue.TFS_Status__c = 'New';
		oIssue.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('GCCM - Support Issue Record Type').getRecordTypeId();

		CaseHandler.launchControl.put('CaseCountOnIssue', 0);
		oCase.Defect__c = oIssue.Id;
		insert oCase;
		update oCase;

		insert oIssue;
		CaseHandler.launchControl.put('notifyCaseOwnersForPlanningPriority', 0);
		oIssue.Planning_Priority__c = 'ERPP1 - Next Release';
		oIssue.TFS_Close_Date__c = system.today() + 3;
		update oIssue;
		CaseHandler.setLaunchControl();
	}

	static testmethod void caseListner11() {
		GenerateTestData.createAccount();
		GenerateTestData.createContact();
		List<Case> lstCases = new List<Case> ();
		List<Id> lstCaseIds = new List<Id> ();

		Case oCase = new Case();
		Case oIssue = new Case();

		oCase.AccountId = GenerateTestData.acct.Id;
		oCase.ContactId = GenerateTestData.ct.Id;
		oCase.Status = 'New';
		oCase.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('GCCM - Support Issue Record Type').getRecordTypeId();
		oCase.Product__c = 'Prolog Connect';
		oCase.Origin = 'Chat';
		oCase.Serial_Number__c = 'test';
		oCase.TFS_Id__c = '123456';
		oCase.Defect__c = oIssue.Id;
		oCase.Clone_Case_Number__c = '12345';


		oIssue.AccountId = GenerateTestdata.acct.Id;
		oIssue.ContactId = GenerateTestdata.ct.Id;
		oIssue.Status = 'New';
		oIssue.TFS_Id__c = '12345';
		oIssue.Product__c = 'Prolog';
		oIssue.TFS_Status__c = 'New';
		oIssue.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('GCCM - Support Issue Record Type').getRecordTypeId();

		CaseHandler.launchControl.put('CaseCountOnIssue', 0);
		oCase.Defect__c = oIssue.Id;
		oCase.Fixed_in_Build_PLM__c = True;
		oCase.Planning_Priority__c = 'PP - Fixed in Build';

		insert oCase;
		lstCases.add(oCase);
		lstCaseIds.add(oCase.Id);
		CaseHandler.launchControl.put('notifyCaseOwnersForPlanningPriority', 0);
		oCase.Fixed_in_Build_PLM__c = True;
		oCase.Planning_Priority__c = 'PP - Fixed in Build';
		update oCase;
		update lstCases;

		CaseHandler.launchControl.put('notifyCaseOwnersForPlanningPriority', 0);
		Messaging.Singleemailmessage testEmail;
		List<Messaging.Sendemailresult> testEmailResults;

		insert oIssue;
		CaseHandler.launchControl.put('notifyCaseOwnersForPlanningPriority', 0);
		oIssue.Planning_Priority__c = 'ERPP1 - Next Release';
		oIssue.TFS_Close_Date__c = system.today() + 3;
		update oIssue;
		CaseHandler.setLaunchControl();


	}

	static testmethod void caseListner12() {
		system.test.startTest();
		Profile profile = [select Id from Profile where Name = :'System Administrator'];

		User user1 = new User();
		user1.Username = 'sagaaaaaaaa23@deloitte.com.a123';
		user1.Email = 'sagamehta@deloitte.com';
		user1.LastName = 'Administrator';
		user1.FirstName = 'Data';
		user1.Alias = 'Test123';
		user1.ProfileID = profile.Id;
		user1.LocaleSidKey = 'en_US';
		user1.LanguageLocaleKey = 'en_US';
		user1.Country = 'India';
		user1.Division__c = 'InfroAssetructure';
		user1.TimeZoneSidKey = 'America/Los_Angeles';
		user1.EmailEncodingKey = 'UTF-8';
		insert user1;
		system.runAs(user1) {
			GenerateTestData.createAccount();
			GenerateTestData.createProduct2();
			GenerateTestdata.createAsset();
			GenerateTestData.createContact();
			List<Case> lstCases = new List<Case> ();
			List<Id> lstCaseIds = new List<Id> ();

			Case doCase = new Case();
			doCase.AccountId = GenerateTestdata.acct.Id;
			doCase.ContactId = GenerateTestdata.ct.Id;
			doCase.Status = 'New';
			doCase.TFS_Id__c = '12345';
			doCase.Product__c = 'Prolog';
			doCase.Private_Notes__c = 'test notes';
			doCase.Resolution__c = 'testing';
			doCase.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('GCCM - Support Issue Record Type').getRecordTypeId();
			insert doCase;
			lstCases.add(doCase);
			case oCase = new Case();
			oCase.AccountId = GenerateTestData.acct.Id;
			oCase.ContactId = GenerateTestData.ct.Id;
			oCase.AssetId = GenerateTestData.asst.Id;
			oCase.Status = 'New';
			oCase.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('GCCM - Support Case Record Type').getRecordTypeId();
			oCase.Product__c = 'Prolog Connect';
			oCase.ProductId = GenerateTestData.prd.Id;
			oCase.Origin = 'Chat';
			oCase.Serial_Number__c = 'test';
			oCase.TFS_Id__c = '123456';
			oCase.Defect__c = doCase.Id;
			insert oCase;
			lstCases.add(oCase);
			CaseHandler.launchControl.put('notifyCaseOwnersForPlanningPriority', 0);
			doCase.Planning_Priority__c = 'ERPP1 - Next Release';
			update doCase;
			CaseHandler.setLaunchControl();
		}
		system.test.stopTest();
	}

	static testmethod void caseListner13() {
		GenerateTestData.createAccount();
		GenerateTestData.createContact();
		List<Case> lstCases = new List<Case> ();
		List<Id> lstCaseIds = new List<Id> ();
		case oCase = new Case();
		oCase.AccountId = GenerateTestData.acct.Id;
		oCase.ContactId = GenerateTestData.ct.Id;
		oCase.Status = 'New';
		oCase.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('GCCM - Support Case Record Type').getRecordTypeId();
		oCase.Product__c = 'Prolog Mobile';
		oCase.Origin = 'Chat';
		oCase.Serial_Number__c = 'test';
		oCase.TFS_Id__c = '123456';
		insert oCase;
		lstCases.add(oCase);
		lstCaseIds.add(oCase.Id);
		CaseHandler ch = new CaseHandler();
		CaseHandler.makeCallout(lstCaseIds, true, true);
		CaseHandler.callTFS(lstCaseIds, true, true);
		CaseHandler.configCase(lstCases);
		CaseHandler.launchControl.put('Case24HoursNotification', 0);
		update lstCases;
	}

	static testmethod void caseListner14() {
		GenerateTestData.createAccount();
		GenerateTestData.createContact();
		List<Case> lstCases = new List<Case> ();
		List<Id> lstCaseIds = new List<Id> ();
		case oCase = new Case();
		oCase.AccountId = GenerateTestData.acct.Id;
		oCase.ContactId = GenerateTestData.ct.Id;
		oCase.Status = 'New';
		oCase.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('GCCM - Support Case Record Type').getRecordTypeId();
		oCase.Product__c = 'Prolog AI-SDK';
		oCase.Origin = 'Chat';
		oCase.Serial_Number__c = 'test';
		oCase.TFS_Id__c = '123456';
		insert oCase;
		lstCases.add(oCase);
		lstCaseIds.add(oCase.Id);
		CaseHandler ch = new CaseHandler();
		CaseHandler.makeCallout(lstCaseIds, true, true);
		CaseHandler.callTFS(lstCaseIds, true, true);
		CaseHandler.configCase(lstCases);
	}

	static testmethod void caseListner15() {
		GenerateTestData.createAccount();
		GenerateTestData.createContact();
		List<Case> lstCases = new List<Case> ();
		List<Id> lstCaseIds = new List<Id> ();
		case oCase = new Case();
		oCase.AccountId = GenerateTestData.acct.Id;
		oCase.ContactId = GenerateTestData.ct.Id;
		oCase.Status = 'New';
		oCase.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('GCCM - Support Case Record Type').getRecordTypeId();
		oCase.Product__c = 'Prolog Sky';
		oCase.Origin = 'Chat';
		oCase.Serial_Number__c = 'test';
		oCase.TFS_Id__c = '123456';
		insert oCase;
		lstCases.add(oCase);
		lstCaseIds.add(oCase.Id);
		CaseHandler ch = new CaseHandler();
		CaseHandler.makeCallout(lstCaseIds, true, true);
		CaseHandler.callTFS(lstCaseIds, true, true);
		CaseHandler.configCase(lstCases);
	}

	static testmethod void caseListner16() {
		GenerateTestData.createAccount();
		GenerateTestData.createContact();
		List<Case> lstCases = new List<Case> ();
		List<Id> lstCaseIds = new List<Id> ();
		case oCase = new Case();
		oCase.AccountId = GenerateTestData.acct.Id;
		oCase.ContactId = GenerateTestData.ct.Id;
		oCase.Status = 'New';
		oCase.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('GCCM - Support Case Record Type').getRecordTypeId();
		oCase.Product__c = 'Crystal Reports XI for Prolog';
		oCase.Origin = 'Chat';
		oCase.Serial_Number__c = 'test';
		oCase.TFS_Id__c = '123456';
		insert oCase;
		lstCases.add(oCase);
		lstCaseIds.add(oCase.Id);
		CaseHandler ch = new CaseHandler();
		CaseHandler.makeCallout(lstCaseIds, true, true);
		CaseHandler.callTFS(lstCaseIds, true, true);
		CaseHandler.configCase(lstCases);
	}

	static testmethod void caseListner17() {
		GenerateTestData.createAccount();
		GenerateTestData.createContact();
		List<Case> lstCases = new List<Case> ();
		List<Id> lstCaseIds = new List<Id> ();
		case oCase = new Case();
		oCase.AccountId = GenerateTestData.acct.Id;
		oCase.ContactId = GenerateTestData.ct.Id;
		oCase.Status = 'New';
		oCase.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('GCCM - Support Case Record Type').getRecordTypeId();
		oCase.Product__c = 'Prolog Converge';
		oCase.Origin = 'Chat';
		oCase.Serial_Number__c = 'test';
		oCase.TFS_Id__c = '123456';
		insert oCase;
		lstCases.add(oCase);
		lstCaseIds.add(oCase.Id);
		CaseHandler ch = new CaseHandler();
		CaseHandler.makeCallout(lstCaseIds, true, true);
		CaseHandler.callTFS(lstCaseIds, true, true);
		CaseHandler.configCase(lstCases);
	}

	static testmethod void caseListner18() {
		GenerateTestData.createAccount();
		GenerateTestData.createContact();
		List<Case> lstCases = new List<Case> ();
		List<Id> lstCaseIds = new List<Id> ();
		case oCase = new Case();
		oCase.AccountId = GenerateTestData.acct.Id;
		oCase.ContactId = GenerateTestData.ct.Id;
		oCase.Status = 'New';
		oCase.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('GCCM - Support Case Record Type').getRecordTypeId();
		oCase.Product__c = 'Vico';
		oCase.Origin = 'Chat';
		oCase.Serial_Number__c = 'test';
		oCase.TFS_Id__c = '123456';
		insert oCase;
		lstCases.add(oCase);
		lstCaseIds.add(oCase.Id);
		CaseHandler ch = new CaseHandler();
		CaseHandler.bl = false;
		CaseHandler.makeCallout(lstCaseIds, true, true);
		CaseHandler.callTFS(lstCaseIds, true, true);
		CaseHandler.configCase(lstCases);
	}

	static testmethod void caseListner19() {
		GenerateTestData.createAccount();
		GenerateTestData.createContact();
		List<Case> lstCases = new List<Case> ();
		List<Id> lstCaseIds = new List<Id> ();
		case oCase = new Case();
		oCase.AccountId = GenerateTestData.acct.Id;
		oCase.ContactId = GenerateTestData.ct.Id;
		oCase.Status = 'New';
		oCase.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('GCCM - Support Issue Record Type').getRecordTypeId();
		oCase.Fixed_in_Build_PLM__c = True;
		oCase.Planning_Priority__c = 'PP1 - Next Release';
		oCase.Product__c = 'Solution Accelerators - Prolog';
		oCase.Origin = 'Chat';
		oCase.Serial_Number__c = 'test';
		oCase.TFS_Id__c = '123456';
		insert oCase;
		lstCases.add(oCase);
		lstCaseIds.add(oCase.Id);
		CaseHandler ch = new CaseHandler();
		CaseHandler.bl = false;
		CaseHandler.makeCallout(lstCaseIds, true, true);
		CaseHandler.callTFS(lstCaseIds, true, true);
		CaseHandler.configCase(lstCases);

		oCase.Features__c = 'Admin Tool';
		update oCase;
	}

	static testmethod void caseListner20() {
		GenerateTestData.createAccount();
		GenerateTestData.createContact();
		List<Case> lstCases = new List<Case> ();
		List<Id> lstCaseIds = new List<Id> ();
		case oCase = new Case();
		oCase.AccountId = GenerateTestData.acct.Id;
		oCase.ContactId = GenerateTestData.ct.Id;
		oCase.Status = 'New';
		oCase.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('GCCM - Support Issue Record Type').getRecordTypeId();
		oCase.Fixed_in_Build_PLM__c = True;
		oCase.Planning_Priority__c = 'PP1 - Next Release';
		oCase.Product__c = 'Proliance';
		oCase.Origin = 'Chat';
		oCase.Serial_Number__c = 'test';
		oCase.TFS_Id__c = '123456';
		insert oCase;
		lstCases.add(oCase);
		lstCaseIds.add(oCase.Id);
		CaseHandler ch = new CaseHandler();
		CaseHandler.bl = false;
		CaseHandler.makeCallout(lstCaseIds, true, true);
		CaseHandler.callTFS(lstCaseIds, true, true);
		CaseHandler.configCase(lstCases);

		oCase.Features__c = 'Org Creation';
		oCase.TFS_Status__c = 'Closed';
		oCase.Assigned_To__c = '5be08e5d92e2727e0939df7a';
		update oCase;
	}
}