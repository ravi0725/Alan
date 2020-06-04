trigger SendEmailOnTFSValueChange on Case(after insert, after Update, before update)
{
	if (userinfo.getName() != 'Data Administrator') {
		List<Case> Ltcase = new List<Case> ();
		List<Messaging.SingleEmailMessage> Listemail = new List<Messaging.SingleEmailMessage> ();

		List<Case> toBePushedToJIRA = new List<Case> ();
		List<Case> toBeCreatedToJIRA = new List<Case> ();

		if (Trigger.isUpdate && Trigger.isAfter)
		{
			for (Case cs : Trigger.new)
			{
				Case oldcsq = Trigger.oldMap.get(cs.id);

				if (cs.record_type_name__c == 'GCCM - Support Issue Record Type' && (cs.product__c.contains('Prolog') || cs.product__c.contains('ProjectSight'))
				    && (cs.status != oldcsq.status || cs.Confirmed_in_Build__c != oldcsq.Confirmed_in_Build__c || cs.Notes__c != oldcsq.Notes__c ||
				        cs.TFS_Close_Date__c != oldcsq.TFS_Close_Date__c || cs.Reason__c != oldcsq.Reason__c || cs.Resolution__c != oldcsq.Resolution__c
				        || cs.Private_Notes__c != oldcsq.Private_Notes__c || cs.Fixed_in_Build__c != oldcsq.Fixed_in_Build__c))
				{
					System.debug('Line 12 ---- ' + cs.product__c);
					Ltcase.add(cs);
				}

				// - Suresh Babu Murugan: initiate sync if Issue linked with JIRA
				if (cs.Record_Type_Name__c == 'GCCM - Support Issue Record Type' && (cs.Product__c.contains('ProjectSight') || cs.Product__c.contains('Prolog') || cs.Product__c.contains('Proliance') || cs.Product__c.contains('Message Bus') || cs.Product__c.contains('Field Mgmt')) &&
				    cs.TFS_Id__c != null && !cs.TFS_Id__c.isNumeric() &&
				(cs.Status != oldcsq.Status || cs.Description != oldcsq.Description || cs.Severity_c__c != oldcsq.Severity_c__c ||
				 cs.Found_In_Build__c != oldcsq.Found_In_Build__c || cs.Steps_to_Reproduce__c != oldcsq.Steps_to_Reproduce__c ||
				 cs.Workaround__c != oldcsq.Workaround__c || cs.Type != oldcsq.Type || cs.Work_Product__c != oldcsq.Work_Product__c ||
				 cs.Subject != oldcsq.Subject || cs.Product__c != oldcsq.Product__c || cs.No_of_Linked_SI_s__c != oldcsq.No_of_Linked_SI_s__c || cs.Support_Issue_Customer_Names__c != oldcsq.Support_Issue_Customer_Names__c)) {

					system.debug('::::::::::::::::::READY TO PUSH TO JIRA::::::::::::::::::');
					toBePushedToJIRA.add(cs);
				}
				/*
				  // This section is not needed as we are not updating the JIRA status direclty. Can be usable in future requirements.
				  if(cs.Record_Type_Name__c =='GCCM - Support Issue Record Type' && (cs.Product__c.contains('ProjectSight') || cs.Product__c.contains('Prolog') || cs.Product__c.contains('Proliance') || cs.Product__c.contains('Message Bus')) &&
				  cs.Status != oldcsq.Status && (cs.Status == 'Closed' || cs.Status == 'Closed (Fixed)' || cs.Status == 'Closed (Other)') && cs.TFS_Id__c != null && !cs.TFS_Id__c.isNumeric()){
				  if(!RecursiveTriggerUtility.PPMJIRA_UpdateStatus){
				  RecursiveTriggerUtility.PPMJIRA_UpdateStatus = true;
				  PPMConnectorSyncJIRAStatus.updateJIRAStatus(cs.TFS_Id__c, cs.Product__c);
				  }
				  }
				 */
				if (cs.Record_Type_Name__c == 'GCCM - Support Issue Record Type' && (cs.product__c.contains('Prolog') || cs.product__c.contains('ProjectSight') || cs.Product__c.contains('Proliance') || cs.Product__c.contains('Message Bus') || cs.Product__c.contains('Field Mgmt')) &&
				(cs.TFS_Id__c != null && cs.TFS_Id__c != oldcsq.TFS_Id__c && !cs.TFS_Id__c.isNumeric()) || (cs.Features__c != null && cs.Features__c != oldcsq.Features__c)) {
					if (!RecursiveTriggerUtility.PPMJIRA_UpdateComponent) {
						RecursiveTriggerUtility.PPMJIRA_UpdateComponent = true;
						String addnlText = 'PL_';
						if (cs.product__c.contains('Prolog')) {
							addnlText = 'PX_';
						}
						else if (cs.product__c.contains('ProjectSight') || cs.Product__c.contains('Field Mgmt')) {
							addnlText = 'PS_';
						}
						else if (cs.product__c.contains('Proliance')) {
							addnlText = 'PO_';
						}
						if (cs.Features__c != null) {
							String featureTrimmed = (cs.Features__c.length() > 34 ? addnlText + cs.Features__c.substring(0, 32).trim() : addnlText + cs.Features__c);
							System.debug(' featureTrimmed ==>' + featureTrimmed);
							PPMConnectorSyncJIRAStatus.updateJIRAComponent(cs.TFS_Id__c, cs.Product__c, featureTrimmed);
						}

						if (cs.TFS_Id__c != oldcsq.TFS_Id__c) {
							List<User> lstCaseOwner = [SELECT Username FROM User WHERE Id = :cs.OwnerId LIMIT 1];
							if (lstCaseOwner != null && lstCaseOwner.size() == 1) {
								PPMConnectorSyncJIRAStatus.postJIRAWatcher(cs.TFS_Id__c, cs.Product__c, String.valueOf(lstCaseOwner[0].Username));
							}
						}
					}
				}
			}

			if (toBePushedToJIRA.size() > 0) {
				if (!RecursiveTriggerUtility.PPMJIRA_Push && !Test.isRunningTest()) {
					RecursiveTriggerUtility.PPMJIRA_Push = true;
					system.debug('::::::::::::::::::PUSHED TO JIRA::::::::::::::::::');
					JCFS.API.pushUpdatesToJira(toBePushedToJIRA, Trigger.old);
					system.debug('::::::::::::::::::PUSHED TO JIRA::::::::::::::::::');
				}
			}
		}

		if (Trigger.isUpdate && Trigger.isBefore) {
			Map<String, PPM_JIRA_Issue_Type__c> PPMConfig = new Map<String, PPM_JIRA_Issue_Type__c> ();
			String instanceType = 'PROD';
			if ([SELECT isSandbox FROM Organization WHERE Id = :userinfo.getOrganizationId()].isSandbox) {
				instanceType = 'SandBox';
			}
			PPMConfig = PPM_JIRA_Issue_Type__c.getAll();
			String jiraProjectId = '';
			String jiraStatusId = '';
			for (Case cs : Trigger.new) {
				Case oldcsq = Trigger.oldMap.get(cs.id);
				if (cs.TFS_Id__c != null && cs.TFS_Status__c == 'Closed' && cs.Record_Type_Name__c == 'GCCM - Support Issue Record Type') {
					cs.TFS_Close_Date__c = System.today();
				}

				if (cs.Assigned_To__c != null && cs.Assigned_To__c != oldcsq.Assigned_To__c && cs.Record_Type_Name__c == 'GCCM - Support Issue Record Type') {
					System.debug(' ASSIGNED TO STARTED ::::::::::::::::::::::');
					Map<String, String> mapJIRAUserMapping = new Map<String, String> ();
					for (String jMap : PPM_JIRA_User_Mapping__c.getAll().keySet()) {
						if (jMap.startsWithIgnoreCase('PPM_JIRA')) {
							mapJIRAUserMapping.put(PPM_JIRA_User_Mapping__c.getValues(jMap).JIRA_AccountId__c, PPM_JIRA_User_Mapping__c.getValues(jMap).JIRA_DisplayName__c);
						}
					}
					if (mapJIRAUserMapping.containsKey(cs.Assigned_To__c)) {
						cs.Assigned_To__c = mapJIRAUserMapping.get(cs.Assigned_To__c);
					}
					System.debug(' ASSIGNED TO END ::::::::::::::::::::::');
				}

				if (cs.TFS_Id__c == null && cs.TFS_Id__c != oldcsq.TFS_Id__c && cs.Is_JIRA_Linked__c) {
					/*
					  if (cs.Record_Type_Name__c == 'GCCM - Support Issue Record Type' && cs.Product__c.contains('ProjectSight')) {
					  String PPMRecord = instanceType + '_ProjectSight_';
					 
					  for (String PPMType : PPMConfig.keySet()) {
					  if (PPMType.contains(instanceType + '_ProjectSight_') && PPMConfig.get(PPMType).SFDC_IssueType__c == cs.Type) {
					  jiraProjectId = PPMConfig.get(PPMType).JIRA_Project_Id__c;
					  jiraStatusId = PPMConfig.get(PPMType).JIRA_IssueKey__c;
					  }
					  }
					  toBeCreatedToJIRA.add(cs);
					  cs.Is_JIRA_Linked__c = false;
					  break;
					  }
					 */
					if (cs.Record_Type_Name__c == 'GCCM - Support Issue Record Type' && cs.Product__c.contains('Prolog')) {
						String PPMRecord = instanceType + '_Prolog_';

						for (String PPMType : PPMConfig.keySet()) {
							if (PPMType.contains(instanceType + '_Prolog_') && PPMConfig.get(PPMType).SFDC_IssueType__c == cs.Type) {
								jiraProjectId = PPMConfig.get(PPMType).JIRA_Project_Id__c;
								jiraStatusId = PPMConfig.get(PPMType).JIRA_IssueKey__c;
							}
						}
						toBeCreatedToJIRA.add(cs);
						cs.Is_JIRA_Linked__c = false;
						break;
					}
					if (cs.Record_Type_Name__c == 'GCCM - Support Issue Record Type' && (cs.Product__c.contains('Proliance') || cs.Product__c.contains('Message Bus'))) {
						String PPMRecord = instanceType + '_Proliance_';

						for (String PPMType : PPMConfig.keySet()) {
							if (PPMType.contains(instanceType + '_Proliance_') && PPMConfig.get(PPMType).SFDC_IssueType__c == cs.Type) {
								jiraProjectId = PPMConfig.get(PPMType).JIRA_Project_Id__c;
								jiraStatusId = PPMConfig.get(PPMType).JIRA_IssueKey__c;
							}
						}
						toBeCreatedToJIRA.add(cs);
						cs.Is_JIRA_Linked__c = false;
						break;
					}
				}
			}
			system.debug(' toBeCreatedToJIRA ===>' + toBeCreatedToJIRA);
			system.debug(' jiraProjectId ===>' + jiraProjectId);
			system.debug(' jiraStatusId ===>' + jiraStatusId);
			system.debug(' OLD  ===>' + Trigger.Old);
			if (toBeCreatedToJIRA.size() > 0) {
				if (!RecursiveTriggerUtility.PPMJIRA_Create && !Test.isRunningTest()) {
					RecursiveTriggerUtility.PPMJIRA_Create = true;
					// Create JIRA ticket
					JCFS.API.createJiraIssue(jiraProjectId, jiraStatusId, toBeCreatedToJIRA, null);
				}
			}
		}

		if (Trigger.isInsert && Trigger.isAfter) {
			Map<String, PPM_JIRA_Issue_Type__c> PPMConfig = new Map<String, PPM_JIRA_Issue_Type__c> ();
			String instanceType = 'PROD';
			if ([SELECT isSandbox FROM Organization WHERE Id = :userinfo.getOrganizationId()].isSandbox) {
				instanceType = 'SandBox';
			}
			PPMConfig = PPM_JIRA_Issue_Type__c.getAll();
			String jiraProjectId = '';
			String jiraStatusId = '';
			for (Case cs : Trigger.new) {
				if (cs.Record_Type_Name__c == 'GCCM - Support Issue Record Type' && (cs.Product__c.contains('ProjectSight') || cs.Product__c.contains('Field Mgmt'))) {
					String PPMRecord = instanceType + '_ProjectSight_';

					for (String PPMType : PPMConfig.keySet()) {
						if (PPMType.contains(instanceType + '_ProjectSight_') && PPMConfig.get(PPMType).SFDC_IssueType__c == cs.Type) {
							jiraProjectId = PPMConfig.get(PPMType).JIRA_Project_Id__c;
							jiraStatusId = PPMConfig.get(PPMType).JIRA_IssueKey__c;
						}
					}

					toBeCreatedToJIRA.add(cs);
					break;
				}
				if (cs.Record_Type_Name__c == 'GCCM - Support Issue Record Type' && cs.Product__c.contains('Prolog')) {
					String PPMRecord = instanceType + '_Prolog_';

					for (String PPMType : PPMConfig.keySet()) {
						if (PPMType.contains(instanceType + '_Prolog_') && PPMConfig.get(PPMType).SFDC_IssueType__c == cs.Type) {
							jiraProjectId = PPMConfig.get(PPMType).JIRA_Project_Id__c;
							jiraStatusId = PPMConfig.get(PPMType).JIRA_IssueKey__c;
						}
					}

					toBeCreatedToJIRA.add(cs);
					break;
				}
				if (cs.Record_Type_Name__c == 'GCCM - Support Issue Record Type' && (cs.Product__c.contains('Proliance') || cs.Product__c.contains('Message Bus'))) {
					String PPMRecord = instanceType + '_Proliance_';

					for (String PPMType : PPMConfig.keySet()) {
						if (PPMType.contains(instanceType + '_Proliance_') && PPMConfig.get(PPMType).SFDC_IssueType__c == cs.Type) {
							jiraProjectId = PPMConfig.get(PPMType).JIRA_Project_Id__c;
							jiraStatusId = PPMConfig.get(PPMType).JIRA_IssueKey__c;
						}
					}

					toBeCreatedToJIRA.add(cs);
					break;
				}
			}
			if (toBeCreatedToJIRA.size() > 0) {
				if (!RecursiveTriggerUtility.PPMJIRA_Create && !Test.isRunningTest()) {
					RecursiveTriggerUtility.PPMJIRA_Create = true;
					// Create JIRA ticket
					JCFS.API.createJiraIssue(jiraProjectId, jiraStatusId, toBeCreatedToJIRA, null);
				}
			}
		}

		for (Case cscheck : Ltcase)
		{
			Case oldcs = Trigger.oldMap.get(cscheck.id);
			Id ORGEmailAddrID = null;
			List<OrgWideEmailAddress> orgmail = [Select Id, DisplayName From OrgWideEmailAddress WHERE DisplayName = 'Trimble Support Services' limit 1];
			if (orgmail.size() > 0) {
				ORGEmailAddrID = orgmail[0].Id;
			}

			messaging.singleEmailMessage mail = new messaging.singleEmailMessage();
			List<String> lstEmailAddress = Label.TFS_JIRA_On_Update_Notification.split(',');
			mail.setToAddresses(lstEmailAddress);
			mail.setSubject(' Case TFS Fields Updated: ' + cscheck.CaseNumber);
			if (ORGEmailAddrID != null) {
				mail.setOrgWideEmailAddressId(ORGEmailAddrID);
			}
			//mail.setTemplateId('00X3C000000UK3p');
			string htmlBody = 'Product: ' + cscheck.Product__c + '<br/>' + 'Subject: ' + cscheck.Subject + '<br/>' + '<br/>' + 'Hello,' + '<br/>' + '<br/>' + 'The following field values have been updated for issue number:  ' + cscheck.CaseNumber + '<br/>' + '<br/>' + '<br/>';
			if (cscheck.status != oldcs.status)
			{
				htmlBody += ' Case Status changed from: [' + oldcs.status + '] to: [' + cscheck.status + ']' + '<br/>' + '<br/>';
			}
			if (cscheck.Confirmed_in_Build__c != oldcs.Confirmed_in_Build__c)
			{
				htmlBody += ' Case Confirmed Build changed from: [' + oldcs.Confirmed_in_Build__c + '] to: [' + cscheck.Confirmed_in_Build__c + ']' + '<br/>' + '<br/>';
			}
			if (cscheck.Notes__c != oldcs.Notes__c)
			{
				htmlBody += ' Case Notes changed from: [' + oldcs.Notes__c + '] to: [' + cscheck.Notes__c + ']' + '<br/>' + '<br/>';
			}
			if (cscheck.TFS_Close_Date__c != oldcs.TFS_Close_Date__c)
			{
				htmlBody += ' Case TFS Close Date changed from: [' + oldcs.TFS_Close_Date__c + '] to: [' + cscheck.TFS_Close_Date__c + ']' + '<br/>' + '<br/>';
			}
			if (cscheck.Reason__c != oldcs.Reason__c)
			{
				htmlBody += ' Case Reason changed from: [' + oldcs.Reason__c + '] to: [' + cscheck.Reason__c + ']' + '<br/>' + '<br/>';
			}
			if (cscheck.Resolution__c != oldcs.Resolution__c)
			{
				htmlBody += ' Case Resolution changed from: [' + oldcs.Resolution__c + '] to: [' + cscheck.Resolution__c + ']' + '<br/>' + '<br/>';
			}
			if (cscheck.Private_Notes__c != oldcs.Private_Notes__c)
			{
				htmlBody += ' Case Private Notes changed from: [' + oldcs.Private_Notes__c + '] to: [' + cscheck.Private_Notes__c + ']' + '<br/>' + '<br/>';
			}
			if (cscheck.Fixed_in_Build__c != oldcs.Fixed_in_Build__c)
			{
				htmlBody += ' Case Fixed in Build changed from: [' + oldcs.Fixed_in_Build__c + '] to: [' + cscheck.Fixed_in_Build__c + ']' + '<br/>' + '<br/>';
			}
			Listemail.add(mail);
			mail.setHtmlBody(htmlBody);
			//Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
		}
		if (Listemail.size() > 0) Messaging.sendEmail(Listemail);
	}
}