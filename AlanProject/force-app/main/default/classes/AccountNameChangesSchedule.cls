/*****************************************************************************************
    Name         : AccountNameChangesSchedule 
    Desc         : Schedulable class to generate Report contains recently name changed Accounts and send email to Team. 

---------------------------------------------------------------------------
 Developer              	Date            Description
---------------------------------------------------------------------------
Suresh Babu Murugan		11/27/2015          Created
******************************************************************************************/
global class AccountNameChangesSchedule implements Schedulable{
	global List<AccountHistory> lstAccountHistories {get;set;}
	global List<User> lstManagers {get;set;}
    global OrgWideEmailAddress orgEmailAddress {get;set;}
	
    global void execute(SchedulableContext SC){
        //Start Execute Process
		initialize();
    }
    
	global void initialize(){
		lstAccountHistories = allAccountHistories();
		lstManagers = returnUsers();
		orgEmailAddress = returnEmailAddress();
		
		//Send email to MEP
		sendEmailtoMEP();
		
		//Send email to GCCM
		sendEmailtoGCCM();
		
		//Send email to RE&WS
		sendEmailtoREWS();
	}
	
	global OrgWideEmailAddress returnEmailAddress(){
		return [Select Id, DisplayName From OrgWideEmailAddress WHERE DisplayName = 'Trimble Support Services' limit 1];
	}
	
	global List<User> returnUsers(){
        List<Account_Name_Change_Notification__c> ManagerUsers = Account_Name_Change_Notification__c.getall().values();
        List<String> lstUserNames = new List<String>();
        for(Account_Name_Change_Notification__c uNames : ManagerUsers){
            lstUserNames.add(uNames.Name);
        }
        return [SELECT Id, Email, Name, FirstName, LastName, Username, Division__c FROM User WHERE Name IN : lstUserNames AND IsActive = true];
	}
	
	global List<AccountHistory> allAccountHistories(){
		return [SELECT Id, AccountId, CreatedBy.Name, CreatedDate, Field, OldValue, NewValue, Account.Account_Division__c, Account.Creator_s_Division__c FROM AccountHistory WHERE Field = 'TextName' AND CreatedDate = THIS_WEEK ORDER BY CreatedDate ASC limit 1000];
	}
	
	global void sendEmailtoMEP(){
		try{
            string excelHeader ='AccountHistory_Id, Account_Id, Old_Account_Name, New_Account_Name, Modified_Date, Modified_By, Account_Division, Account_Creator_Division \n';
            String finalExcelData = excelHeader;
            
			// ONLY Getting values of MEP
			for(AccountHistory aH : lstAccountHistories){
                if(aH.Account.Account_Division__c == 'MEP'){
					String historyData = aH.id+ ',' + aH.AccountId + ',' + '"' + aH.OldValue+ '"' + ',' + '"' + aH.NewValue + '"' + ',' + aH.CreatedDate + ',' + aH.CreatedBy.Name + ',' + aH.Account.Account_Division__c + ',' + aH.Account.Creator_s_Division__c + '\n';
					finalExcelData += historyData;
				}
            }
            
            Messaging.EmailFileAttachment attachExcel = new Messaging.EmailFileAttachment();
            Blob excelData = Blob.valueOf(finalExcelData);
            
            attachExcel.setBody(excelData);
            attachExcel.setFileName('Account Name Changed - Current Week.csv');
            attachExcel.setContentType('application/vnd.ms-excel');
            
            String emailBody = 'Hi, \n\n'+ 'FYI, Attached Report contains Account records Name got changed within this WEEK. \n\n'+ 'Regards, \n' + 'SFDC - Team';
			String emptyEmailBody = 'Hi, \n\n'+ 'FYI, None of the Account Names are changed in Current week. \n\n'+ 'Regards, \n' + 'SFDC - Team';
            
			List<String> ToEmailAddress = new List<String>();
			List<String> CcEmailAddress = new List<String>();
			for(User u : lstManagers){
				if(u.Division__c == 'MEP')
					ToEmailAddress.add(u.Email);
				else if(u.Division__c == 'Architecture')
					CcEmailAddress.add(u.Email);
			}
			
            Messaging.singleEmailMessage EmailwithAttachment = new Messaging.singleEmailMessage();
            EmailwithAttachment.setSubject('Reports of Account Name Changes - Current Week - MEP');
			EmailwithAttachment.setToaddresses(ToEmailAddress);
			EmailwithAttachment.setCcAddresses(CcEmailAddress);
			EmailwithAttachment.setOrgWideEmailAddressId(orgEmailAddress.Id);
            
			if(finalExcelData.length() > 139){ // Header length is 139 chars NOW.
				EmailwithAttachment.setPlainTextBody(emailBody);
				EmailwithAttachment.setFileAttachments(new Messaging.EmailFileAttachment[]{attachExcel});
			}
			else{
				EmailwithAttachment.setPlainTextBody(emptyEmailBody);
			}
            
            // Sends the email
            Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {EmailwithAttachment});
        }
        catch(Exception exp){
            system.debug(' AccountNameChangesSchedule Exception ======>>'+exp.getMessage());
        }
	}
	
	global void sendEmailtoGCCM(){
		try{
            string excelHeader ='AccountHistory_Id, Account_Id, Old_Account_Name, New_Account_Name, Modified_Date, Modified_By, Account_Division, Account_Creator_Division \n';
            String finalExcelData = excelHeader;
            
			// ONLY Getting values of GCCM
			for(AccountHistory aH : lstAccountHistories){
                if(aH.Account.Account_Division__c == 'GCCM'){
					String historyData = aH.id+ ',' + aH.AccountId + ',' + '"' + aH.OldValue+ '"' + ',' + '"' + aH.NewValue + '"' + ',' + aH.CreatedDate + ',' + aH.CreatedBy.Name + ',' + aH.Account.Account_Division__c + ',' + aH.Account.Creator_s_Division__c + '\n';
					finalExcelData += historyData;
				}
            }
            
            Messaging.EmailFileAttachment attachExcel = new Messaging.EmailFileAttachment();
            Blob excelData = Blob.valueOf(finalExcelData);
            
            attachExcel.setBody(excelData);
            attachExcel.setFileName('Account Name Changed - Current Week.csv');
            attachExcel.setContentType('application/vnd.ms-excel');
            
            String emailBody = 'Hi, \n\n'+ 'FYI, Attached Report contains Account records Name got changed within this WEEK. \n\n'+ 'Regards, \n' + 'SFDC - Team';
			String emptyEmailBody = 'Hi, \n\n'+ 'FYI, None of the Account Names are changed in Current week. \n\n'+ 'Regards, \n' + 'SFDC - Team';
            
			List<String> ToEmailAddress = new List<String>();
			List<String> CcEmailAddress = new List<String>();
			for(User u : lstManagers){
				if(u.Division__c == 'GCCM')
					ToEmailAddress.add(u.Email);
				else if(u.Division__c == 'Architecture')
					CcEmailAddress.add(u.Email);
			}
			
			Messaging.singleEmailMessage EmailwithAttachment = new Messaging.singleEmailMessage();
            EmailwithAttachment.setSubject('Reports of Account Name Changes - Current Week - GCCM');
			EmailwithAttachment.setToaddresses(ToEmailAddress);
			EmailwithAttachment.setCcAddresses(CcEmailAddress);
			EmailwithAttachment.setOrgWideEmailAddressId(orgEmailAddress.Id);
            
			if(finalExcelData.length() > 139){ // Header length is 139 chars NOW.
				EmailwithAttachment.setPlainTextBody(emailBody);
				EmailwithAttachment.setFileAttachments(new Messaging.EmailFileAttachment[]{attachExcel});
			}
			else{
				EmailwithAttachment.setPlainTextBody(emptyEmailBody);
			}
            
            // Sends the email
            Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {EmailwithAttachment});
        }
        catch(Exception exp){
            system.debug(' AccountNameChangesSchedule Exception ======>>'+exp.getMessage());
        }
	}
	
	global void sendEmailtoREWS(){
		try{
            string excelHeader ='AccountHistory_Id, Account_Id, Old_Account_Name, New_Account_Name, Modified_Date, Modified_By, Account_Division, Account_Creator_Division \n';
            String finalExcelData = excelHeader;
            
			// ONLY Getting values of RE&WS
			for(AccountHistory aH : lstAccountHistories){
                if(aH.Account.Account_Division__c == 'RE&WS'){
					String historyData = aH.id+ ',' + aH.AccountId + ',' + '"' + aH.OldValue+ '"' + ',' + '"' + aH.NewValue + '"' + ',' + aH.CreatedDate + ',' + aH.CreatedBy.Name + ',' + aH.Account.Account_Division__c + ',' + aH.Account.Creator_s_Division__c + '\n';
					finalExcelData += historyData;
				}
            }
            
            Messaging.EmailFileAttachment attachExcel = new Messaging.EmailFileAttachment();
            Blob excelData = Blob.valueOf(finalExcelData);
            
            attachExcel.setBody(excelData);
            attachExcel.setFileName('Account Name Changed - Current Week.csv');
            attachExcel.setContentType('application/vnd.ms-excel');
            
            String emailBody = 'Hi, \n\n'+ 'FYI, Attached Report contains Account records Name got changed within this WEEK. \n\n'+ 'Regards, \n' + 'SFDC - Team';
			String emptyEmailBody = 'Hi, \n\n'+ 'FYI, None of the Account Names are changed in Current week. \n\n'+ 'Regards, \n' + 'SFDC - Team';
            
			List<String> ToEmailAddress = new List<String>();
			List<String> CcEmailAddress = new List<String>();
			for(User u : lstManagers){
				if(u.Division__c == 'RE&WS')
					ToEmailAddress.add(u.Email);
				else if(u.Division__c == 'Architecture')
					CcEmailAddress.add(u.Email);
			}
			
			Messaging.singleEmailMessage EmailwithAttachment = new Messaging.singleEmailMessage();
            EmailwithAttachment.setSubject('Reports of Account Name Changes - Current Week - RE&WS');
			EmailwithAttachment.setToaddresses(ToEmailAddress);
			EmailwithAttachment.setCcAddresses(CcEmailAddress);
			EmailwithAttachment.setOrgWideEmailAddressId(orgEmailAddress.Id);
            
			if(finalExcelData.length() > 139){ // Header length is 139 chars NOW.
				EmailwithAttachment.setPlainTextBody(emailBody);
				EmailwithAttachment.setFileAttachments(new Messaging.EmailFileAttachment[]{attachExcel});
			}
			else{
				EmailwithAttachment.setPlainTextBody(emptyEmailBody);
			}
            
            // Sends the email
            Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {EmailwithAttachment});
        }
        catch(Exception exp){
            system.debug(' AccountNameChangesSchedule Exception ======>>'+exp.getMessage());
        }
	}
}