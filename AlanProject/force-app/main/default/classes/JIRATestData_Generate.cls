/**
  * Company     : Trimble Software Technology Pvt Ltd.,
  * Description : JIRA Master Data for Test Classes
  * History     :  
 
  * [15.12.2016] Suresh Babu Murugan  Created
  * [15.12.2018] Suresh Babu Murugan  Modified : PPM JIRA integraion
*/
public class JIRATestData_Generate {
	public static Country_Region_Mapping__c cust;
	public static Geospatial_Country_Region_Mapping__c custRegMap;
	public static Account acct;
	public static Contact ct;
	public static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
	public static Entitlement ent;
	public static Case pcs, pcs1, pcs2, PPMcs1, PPMcs2;
	public static Development__c dev1, dev2;
	public static Attachment att1, att2, att3, att4;
	public static Note Note1, Note2;
	public static TechOps__c TechOps1;
	public static User apiUser;
	public static Profile prf = [Select Id from Profile where Name = :Label.API_Only];

	public static void createCustomSettingRecords() {
		cust = new Country_Region_Mapping__c(name = 'India', Region__c = 'India');
		insert cust;
		custRegMap = new Geospatial_Country_Region_Mapping__c(name = 'India', Region__c = 'India');
		insert custRegMap;

		List<JIRA_System_Config__c> lstJIRASys = new List<JIRA_System_Config__c> ();
		JIRA_System_Config__c jiraSysteminfo = new JIRA_System_Config__c();
		jiraSysteminfo.Name = 'JIRA_Sandbox';
		jiraSysteminfo.End_Point_URL__c = 'http://jira.com';
		jiraSysteminfo.Password__c = 'yourJIRApassword';
		jiraSysteminfo.User_Name__c = 'yourJIRAusername';
		jiraSysteminfo.System_Id__c = '1';
		lstJIRASys.add(jiraSysteminfo);

		JIRA_System_Config__c jiraSysteminfo1 = new JIRA_System_Config__c();
		jiraSysteminfo1.Name = 'JIRA_Production';
		jiraSysteminfo1.End_Point_URL__c = 'http://jira.com';
		jiraSysteminfo1.Password__c = 'yourJIRApassword';
		jiraSysteminfo1.User_Name__c = 'yourJIRAusername';
		jiraSysteminfo1.System_Id__c = '1';
		lstJIRASys.add(jiraSysteminfo1);

		JIRA_System_Config__c jiraSysteminfo2 = new JIRA_System_Config__c();
		jiraSysteminfo2.Name = 'PPM_Sandbox';
		jiraSysteminfo2.End_Point_URL__c = 'http://e-builderjira.com';
		jiraSysteminfo2.Password__c = 'yourJIRApassword';
		jiraSysteminfo2.User_Name__c = 'yourJIRAusername';
		jiraSysteminfo2.System_Id__c = '13';
		lstJIRASys.add(jiraSysteminfo2);

		JIRA_System_Config__c jiraSysteminfo3 = new JIRA_System_Config__c();
		jiraSysteminfo3.Name = 'PPM_Production';
		jiraSysteminfo3.End_Point_URL__c = 'http://e-builderjira.com';
		jiraSysteminfo3.Password__c = 'yourJIRApassword';
		jiraSysteminfo3.User_Name__c = 'yourJIRAusername';
		jiraSysteminfo3.System_Id__c = '13';
		lstJIRASys.add(jiraSysteminfo3);
		insert lstJIRASys;

		List<JIRA_Status_Mapping__c> lstJIRAStatus = new List<JIRA_Status_Mapping__c> ();
		JIRA_Status_Mapping__c status1 = new JIRA_Status_Mapping__c(Name = 'SFUST-Backlog', Status_Code__c = '191', Status_Name__c = 'Backlog', Key_Type__c = 'new', Color_Name__c = 'blue-gray', Is_Status_Mapping__c = false, Description__c = 'This status is managed internally by JIRA Agile');
		JIRA_Status_Mapping__c status2 = new JIRA_Status_Mapping__c(Name = 'SPSUST-Backlog', Status_Code__c = '191', Status_Name__c = 'Backlog', Key_Type__c = 'new', Color_Name__c = 'blue-gray', Is_Status_Mapping__c = false, Description__c = 'This status is managed internally by JIRA Agile');
		JIRA_Status_Mapping__c status3 = new JIRA_Status_Mapping__c(Name = 'JIRA-Backlog', Status_Name__c = 'Backlog', Is_Status_Mapping__c = TRUE, Description__c = 'JIRA to SFDC Status update');
		JIRA_Status_Mapping__c status4 = new JIRA_Status_Mapping__c(Name = 'JIRA-Fix Failed', Status_Name__c = 'Fix Failed', Is_Status_Mapping__c = TRUE, Description__c = 'JIRA to SFDC Status update');
		JIRA_Status_Mapping__c status5 = new JIRA_Status_Mapping__c(Name = 'SFDC-Backlog', Status_Name__c = 'Backlog', Is_Status_Mapping__c = TRUE, Description__c = 'SFDC to JIRA Status');
		JIRA_Status_Mapping__c status6 = new JIRA_Status_Mapping__c(Name = 'SFDC-Closed No Fix', Status_Name__c = 'Closed No Fix', Is_Status_Mapping__c = TRUE, Description__c = 'SFDC to JIRA Status');
		lstJIRAStatus.add(status1);
		lstJIRAStatus.add(status2);
		lstJIRAStatus.add(status3);
		lstJIRAStatus.add(status4);
		lstJIRAStatus.add(status5);
		lstJIRAStatus.add(status6);
		insert lstJIRAStatus;

		List<JIRA_Development_User_Mapping__c> lstUserMapping = new List<JIRA_Development_User_Mapping__c> ();
		JIRA_Development_User_Mapping__c mapping1 = new JIRA_Development_User_Mapping__c(Name = 'pcolgan', SFDC_Name__c = 'Patrick Colgan', SFDC_User_ID__c = System.UserInfo.getUserId(), SFDC_User_Name__c = 'patrick_colgan@trimble.com', Role_Department__c = '');
		JIRA_Development_User_Mapping__c mapping2 = new JIRA_Development_User_Mapping__c(Name = 'agelber', SFDC_Name__c = 'Andy Gelbert', SFDC_User_ID__c = '00531000006fXUa', SFDC_User_Name__c = 'andy_gelbert@trimble.com', Role_Department__c = 'Engineering');
		lstUserMapping.add(mapping1);
		lstUserMapping.add(mapping2);
		insert lstUserMapping;

		List<JIRA_Integration_Monitor__c> lstIntegrationMonitor = new List<JIRA_Integration_Monitor__c> ();
		JIRA_Integration_Monitor__c mon1 = new JIRA_Integration_Monitor__c(
		                                                                   Name = 'SandBox',
		                                                                   IsActive__c = true,
		                                                                   JIRA_Issue_Number__c = 'SFUST-145',
		                                                                   Notification_Email1__c = 'test@tst.csa',
		                                                                   Object_API__c = 'Development__c',
		                                                                   SFDC_Record_Id__c = 'a583C000000GqTc'
		);
		JIRA_Integration_Monitor__c mon2 = new JIRA_Integration_Monitor__c(
		                                                                   Name = 'PROD',
		                                                                   IsActive__c = true,
		                                                                   JIRA_Issue_Number__c = 'SFUST-145',
		                                                                   Notification_Email1__c = 'test@tst.csa',
		                                                                   Object_API__c = 'Development__c',
		                                                                   SFDC_Record_Id__c = 'a583C000000GqTc'
		);
		lstIntegrationMonitor.add(mon1);
		lstIntegrationMonitor.add(mon2);
		insert lstIntegrationMonitor;

		List<TFS_Project_Config__c> lstTFSConfigMapping = new List<TFS_Project_Config__c> ();
		TFS_Project_Config__c TFSConfig1 = new TFS_Project_Config__c(Name = 'ProjectSight', Area__c = 'WeMi', Iteration__c = 'WeMi\Backlog\New', Project_Name__c = 'GCCMCollection|Wemi',
		                                                             Run_Integration__c = false, Division__c = 'GCCM', Run_JIRA_Integration__c = true, JIRA_Closed_Transision__c = 199);
		lstTFSConfigMapping.add(TFSConfig1);
		TFS_Project_Config__c TFSConfig2 = new TFS_Project_Config__c(Name = 'ProjectSight API', Area__c = 'WeMi', Iteration__c = 'WeMi\Backlog\New', Project_Name__c = 'GCCMCollection|Wemi',
		                                                             Run_Integration__c = false, Division__c = 'GCCM', Run_JIRA_Integration__c = true, JIRA_Closed_Transision__c = 199);
		lstTFSConfigMapping.add(TFSConfig2);
		TFS_Project_Config__c TFSConfig3 = new TFS_Project_Config__c(Name = 'ProjectSight Mobile', Area__c = 'WeMi', Iteration__c = 'WeMi\Backlog\New', Project_Name__c = 'GCCMCollection|Wemi',
		                                                             Run_Integration__c = false, Division__c = 'GCCM', Run_JIRA_Integration__c = true, JIRA_Closed_Transision__c = 199);
		lstTFSConfigMapping.add(TFSConfig3);
		TFS_Project_Config__c TFSConfig4 = new TFS_Project_Config__c(Name = 'ProjectSight Web', Area__c = 'WeMi', Iteration__c = 'WeMi\Backlog\New', Project_Name__c = 'GCCMCollection|Wemi',
		                                                             Run_Integration__c = false, Division__c = 'GCCM', Run_JIRA_Integration__c = true, JIRA_Closed_Transision__c = 199);
		lstTFSConfigMapping.add(TFSConfig4);
		TFS_Project_Config__c TFSConfig5 = new TFS_Project_Config__c(Name = 'Proliance', Area__c = 'AgileProliance Proliance Maintenance', Iteration__c = 'AgileProliance Active Proliance Maintenance', Project_Name__c = 'DefaultCollection|AgileProliance',
		                                                             Run_Integration__c = true, Division__c = 'PROLIANCE', Run_JIRA_Integration__c = false);
		lstTFSConfigMapping.add(TFSConfig5);
		insert lstTFSConfigMapping;

		List<PPM_JIRA_Issue_Type__c> lstPPMIssueTypes = new List<PPM_JIRA_Issue_Type__c> ();
		PPM_JIRA_Issue_Type__c PPMIssueType1 = new PPM_JIRA_Issue_Type__c(Name = 'SandBox_ProjectSight_CFD', SFDC_IssueType__c = 'Software Defect', JIRA_IssueKey__c = '10006',
		                                                                  JIRA_IssueType__c = 'CFD', JIRA_Project_Id__c = '11022', JIRA_Project_Key__c = 'PL');
		lstPPMIssueTypes.add(PPMIssueType1);
		PPM_JIRA_Issue_Type__c PPMIssueType2 = new PPM_JIRA_Issue_Type__c(Name = 'PROD_ProjectSight_CFD', SFDC_IssueType__c = 'Software Defect', JIRA_IssueKey__c = '10006',
		                                                                  JIRA_IssueType__c = 'CFD', JIRA_Project_Id__c = '11022', JIRA_Project_Key__c = 'PL');
		lstPPMIssueTypes.add(PPMIssueType2);
		insert lstPPMIssueTypes;

		List<PPM_JIRA_Components__c> PPMComponents = new List<PPM_JIRA_Components__c> ();
		PPM_JIRA_Components__c PPMComp1 = new PPM_JIRA_Components__c(Name = 'Action Items', JIRA_Id__c = '11891');
		PPMComponents.add(PPMComp1);
		PPM_JIRA_Components__c PPMComp2 = new PPM_JIRA_Components__c(Name = 'Authentication', JIRA_Id__c = '11884');
		PPMComponents.add(PPMComp2);
		PPM_JIRA_Components__c PPMComp3 = new PPM_JIRA_Components__c(Name = 'Drawings', JIRA_Id__c = '11885');
		PPMComponents.add(PPMComp3);
		insert PPMComponents;

		List<System_Integration_Config__c> lstSysIntegrationConfig = new List<System_Integration_Config__c> ();
		System_Integration_Config__c conf1 = new System_Integration_Config__c(Name = 'TFS_Attachment_Production', End_Point_URL__c = 'https://ihub2.trimble.com:1025/soa-infra/services/sfdctfs/TNVTFSFileAttachmentComposite/tnvtfsfileattachmentservice_client_ep');
		System_Integration_Config__c conf2 = new System_Integration_Config__c(Name = 'TFS_Attachment_Sandbox', End_Point_URL__c = 'https://ihub2.trimble.com:1025/soa-infra/services/sfdctfs/TNVTFSFileAttachmentComposite/tnvtfsfileattachmentservice_client_ep');
		lstSysIntegrationConfig.add(conf1);
		lstSysIntegrationConfig.add(conf2);
		insert lstSysIntegrationConfig;
	}

	public static void createAccount() {
		acct = new Account(Name = 'Test Assign Case Account', RecordTypeId = acctRecTypeId, Account_Status__c = 'Pending', Requested_Account_Record_Type__c = 'Customer',
		                   BillingCountry = 'India', BillingStreet = 'A-202', BillingCity = 'Pune', BillingState = 'Maharashtra', BillingPostalCode = 'postal code', Phone = '(408) 481-6246');
		insert acct;
	}

	public static void createContact() {
		ct = new Contact();
		ct.LastName = 'Test last name';
		ct.AccountId = acct.Id;
		ct.Phone = '(408) 481-6246';
		ct.Preferred_Language__c = 'American English';
		ct.Email = 'test@gmail.com';
		ct.MailingStreet = 'A-202';
		ct.MailingCity = 'Pune';
		ct.MailingState = 'Maharashtra';
		ct.MailingPostalCode = '12345';
		ct.MailingCountry = 'India';
		insert ct;
	}

	public static void createCases() {
		List<Case> lstCases = new List<Case> ();
		pcs = new Case();
		pcs.AccountId = acct.Id;
		pcs.ContactId = ct.Id;
		pcs.Status = 'New';
		pcs.Application__c = 'Space Scheduling';
		pcs.SPR__c = 'SFC-1';
		pcs.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('RE&WS - Support').getRecordTypeId();
		lstCases.add(pcs);

		pcs1 = new Case();
		pcs1.AccountId = acct.Id;
		pcs1.ContactId = ct.Id;
		pcs1.Status = 'New';
		pcs1.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('RE&WS - Support').getRecordTypeId();
		lstCases.add(pcs1);

		pcs2 = new Case();
		pcs2.AccountId = acct.Id;
		pcs2.ContactId = ct.Id;
		pcs2.Status = 'New';
		pcs2.Application__c = 'Manhattan';
		pcs2.SPR__c = 'SFC-2';
		pcs2.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('RE&WS - Support').getRecordTypeId();
		lstCases.add(pcs2);

		PPMcs1 = new Case();
		PPMcs1.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('GCCM - Support Issue Record Type').getRecordTypeId();
		PPMcs1.Type = 'Software Defect';
		PPMcs1.Status = 'New';
		PPMcs1.Severity_c__c = '3';
		PPMcs1.Priority = 'Level 3: Medium';
		PPMcs1.Product__c = 'ProjectSight Web';
		PPMcs1.Features__c = 'Drawings';
		PPMcs1.Work_Product__c = 'Help File';
		PPMcs1.Found_In_Build__c = '12345';
		PPMcs1.Subject = 'TEST JIRA integration #1 (MSB)';
		PPMcs1.Description = 'Test Desc';
		PPMcs1.Steps_to_Reproduce__c = 'Test #1';
		PPMcs1.TFS_Id__c = 'PL-12';
		lstCases.add(PPMcs1);

		PPMcs2 = new Case();
		PPMcs2.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('GCCM - Support Issue Record Type').getRecordTypeId();
		PPMcs2.Type = 'Software Defect';
		PPMcs2.Status = 'New';
		PPMcs2.Severity_c__c = '3';
		PPMcs2.Priority = 'Level 3: Medium';
		PPMcs2.Product__c = 'Proliance';
		PPMcs2.Features__c = 'Drawings';
		PPMcs2.Work_Product__c = 'Help File';
		PPMcs2.Found_In_Build__c = '12345';
		PPMcs2.Subject = 'TEST JIRA integration #1 (MSB)';
		PPMcs2.Description = 'Test Desc';
		PPMcs2.Steps_to_Reproduce__c = 'Test #1';
		PPMcs2.TFS_Id__c = 'PL-12';
		lstCases.add(PPMcs2);

		insert lstCases;
	}

	public static void createNotes() {
		Note1 = new Note();
		Note1.Title = 'TEST NOTE 2';
		Note1.Body = 'TEST Note2 Body';
		Note1.ParentId = dev1.Id;

		List<Note> lstNotes = new List<Note> ();
		lstNotes.add(Note1);
		insert lstNotes;
	}

	public static void createAttachments() {
		att1 = new Attachment();
		att1.Body = Blob.valueOf('Test');
		att1.Name = String.valueOf('test.txt');
		att1.ParentId = pcs.Id;

		att2 = new Attachment();
		att2.Body = Blob.valueOf('Test');
		att2.Name = String.valueOf('test.txt');
		att2.ParentId = dev1.Id;

		att3 = new Attachment();
		att3.Body = Blob.valueOf('Test');
		att3.Name = String.valueOf('test.txt');
		att3.ParentId = PPMcs1.Id;

		att4 = new Attachment();
		att4.Body = Blob.valueOf('Test');
		att4.Name = String.valueOf('test.txt');
		att4.ParentId = PPMcs2.Id;

		List<Attachment> lstAtts = new List<Attachment> ();
		lstAtts.add(att1);
		lstAtts.add(att2);
		lstAtts.add(att3);
		lstAtts.add(att4);
		insert lstAtts;
	}

	public static void createTechOps() {
		TechOps1 = new TechOps__c();
		TechOps1.Priority__c = 'Medium';
		TechOps1.Status__c = 'Submitted';
		TechOps1.Impact_Area__c = 'Other';
		TechOps1.Category__c = 'Other';
		TechOps1.Requested_Due_Date__c = system.today() + 20;
		TechOps1.Summary__c = 'Testing TechOp PC 2';
		TechOps1.Task_Details__c = 'This is another test.';
		insert TechOps1;
	}

	public static void createDevelopments() {
		dev1 = new Development__c();
		dev1.Internal_Priority__c = 'P2';
		dev1.Subject__c = 'TEST Dev ticket';
		dev1.Description__c = 'TEST Desc';
		dev1.Status__c = 'Backlog';
		dev1.OwnerId = system.UserInfo.getUserId();
		dev1.Rank__c = '2';
		dev1.Est_Delivery_Date__c = system.today() + 100;
		dev1.Release_Found_In__c = 'CS_34';
		dev1.Target_Release__c = 'CS_34';
		dev1.Category__c = 'CAD';
		dev1.Client__c = acct.Id;
		dev1.Business_Use_Case__c = 'test case';
		dev1.Platform__c = 'Centerstone';
		dev1.Module__c = 'CAD';
		dev1.AppServer__c = 'TC - Tomcat';
		dev1.DBServer__c = 'SQL';
		dev1.Internal_URL_Reproduced_In__c = 'google.com';
		dev1.TEST_Deploy_URL__c = 'google.com';
		dev1.PROD_Deploy_URL__c = 'google.com';
		dev1.Support_Case_1__c = pcs.Id;
		if (TechOps1 != null)
		dev1.QA_Tech_Ops__c = TechOps1.Id;
		dev1.Code_Fix_Information__c = 'test code fix';

		dev2 = new Development__c();
		dev2.Internal_Priority__c = 'P2';
		dev2.Subject__c = 'TEST Dev ticket';
		dev2.JIRA_Description__c = 'TEST Desc';
		dev2.Status__c = 'Backlog';
		dev2.OwnerId = system.UserInfo.getUserId();
		dev2.Rank__c = '2';
		dev2.Est_Delivery_Date__c = system.today() + 100;
		dev2.Release_Found_In__c = 'CS_34';
		dev2.Target_Release__c = 'CS_34';
		dev2.Category__c = 'CAD';
		dev2.Client__c = acct.Id;
		dev2.Business_Use_Case__c = 'test case';
		dev2.Platform__c = 'Centerstone';
		dev2.Module__c = 'CAD';
		dev2.AppServer__c = 'TC - Tomcat';
		dev2.DBServer__c = 'SQL';
		dev2.Internal_URL_Reproduced_In__c = 'google.com';
		dev2.TEST_Deploy_URL__c = 'google.com';
		dev2.PROD_Deploy_URL__c = 'google.com';
		dev2.Support_Case_1__c = pcs.Id;
		dev2.JIRA_Issue_Assigned_User__c = 'pcolgan';
		dev2.JIRA_Status__c = 'Backlog';
		if (TechOps1 != null)
		dev2.QA_Tech_Ops__c = TechOps1.Id;
		dev2.JIRA_Code_Fix_Information__c = 'test code fix';

		List<Development__c> lstDevs = new List<Development__c> ();
		lstDevs.add(dev1);
		lstDevs.add(dev2);
		insert lstDevs;
	}
}