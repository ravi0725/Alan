/*****************************************************************************************
  Name    : ExceptionUtils 
  Desc    : Exception utility global class to capture exceptions.
  Modification Log : 
  ---------------------------------------------------------------------------
  Developer					Date			Description
  ---------------------------------------------------------------------------
  Suresh Babu Murugan		25/Mar/2019		Created
 ******************************************************************************************/
global class ExceptionUtils {
	/**
	 * @description 
	 * @param expCaught 
	 * @param blnCreateLog 
	 */
	global static void captureException(Exception expCaught, Boolean blnCreateLog) {
		if (expCaught != null) {
			Errors_and_Exception__c exceptionStaged = new Errors_and_Exception__c();

			exceptionStaged.Cause__c = String.valueOf(expCaught.getCause());
			exceptionStaged.Current_User_Id__c = String.valueOf(UserInfo.getUserId());
			exceptionStaged.Error_Message__c = expCaught.getMessage();
			exceptionStaged.Exception_Type__c = expCaught.getTypeName();
			exceptionStaged.Line_Number__c = expCaught.getLineNumber();
			exceptionStaged.Stack_Trace_String__c = expCaught.getStackTraceString();

			if (blnCreateLog) {
				ExceptionUtils.createExceptionLog(exceptionStaged);
			}
		}
	}

	/**
	 * @description 
	 * @param expCaught 
	 * @param blnCreateLog 
	 */
	global static void captureException(DmlException expCaught, Boolean blnCreateLog) {
		if (expCaught != null) {
			Errors_and_Exception__c exceptionStaged = new Errors_and_Exception__c();

			exceptionStaged.Cause__c = String.valueOf(expCaught.getCause());
			exceptionStaged.Current_User_Id__c = String.valueOf(UserInfo.getUserId());
			exceptionStaged.Error_Message__c = expCaught.getMessage();
			exceptionStaged.Exception_Type__c = expCaught.getTypeName();
			exceptionStaged.Line_Number__c = expCaught.getLineNumber();
			exceptionStaged.Stack_Trace_String__c = expCaught.getStackTraceString();

			if (exceptionStaged.Exception_Type__c == 'System.DmlException') {
				exceptionStaged.DML_Exception_Details__c =
				'Record Id : ' + expCaught.getDmlId(0) + '\n' +
				'Type : ' + expCaught.getDmlType(0) + '\n' +
				'Status Code : ' + expCaught.getDmlStatusCode(0) + '\n' +
				'No of Rows affected : ' + expCaught.getNumDml() + '\n' +
				'Message : ' + expCaught.getDmlMessage(0) + '\n' +
				'Index Row : ' + expCaught.getDmlIndex(0) + '\n' +
				'Field Names : ' + expCaught.getDmlFieldNames(0) + '\n' +
				'Fields : ' + expCaught.getDmlFields(0) + '\n';
			}

			if (blnCreateLog) {
				ExceptionUtils.createExceptionLog(exceptionStaged);
			}
		}
	}

	/**
	 * @description 
	 * @param expCaught 
	 * @param blnCreateLog 
	 */
	global static void captureException(EmailException expCaught, Boolean blnCreateLog) {
		if (expCaught != null) {
			Errors_and_Exception__c exceptionStaged = new Errors_and_Exception__c();

			exceptionStaged.Cause__c = String.valueOf(expCaught.getCause());
			exceptionStaged.Current_User_Id__c = String.valueOf(UserInfo.getUserId());
			exceptionStaged.Error_Message__c = expCaught.getMessage();
			exceptionStaged.Exception_Type__c = expCaught.getTypeName();
			exceptionStaged.Line_Number__c = expCaught.getLineNumber();
			exceptionStaged.Stack_Trace_String__c = expCaught.getStackTraceString();

			if (exceptionStaged.Exception_Type__c == 'System.EmailException') {
				exceptionStaged.DML_Exception_Details__c =
				'Record Id : ' + expCaught.getDmlId(0) + '\n' +
				'Type : ' + expCaught.getDmlType(0) + '\n' +
				'Status Code : ' + expCaught.getDmlStatusCode(0) + '\n' +
				'No of Rows affected : ' + expCaught.getNumDml() + '\n' +
				'Message : ' + expCaught.getDmlMessage(0) + '\n' +
				'Index Row : ' + expCaught.getDmlIndex(0) + '\n' +
				'Field Names : ' + expCaught.getDmlFieldNames(0) + '\n' +
				'Fields : ' + expCaught.getDmlFields(0) + '\n';
			}

			if (blnCreateLog) {
				ExceptionUtils.createExceptionLog(exceptionStaged);
			}
		}
	}

	/**
	 * @description 
	 * @param exceptionRecord 
	 */
	private static void createExceptionLog(Errors_and_Exception__c exceptionRecord) {
		try {
			List<Errors_and_Exception__c> lstErrosAndExceptions = new List<Errors_and_Exception__c> ();
			lstErrosAndExceptions.add(exceptionRecord);
			Database.insert(lstErrosAndExceptions);
		}
		catch(Exception exp) {
			System.debug(exp.getMessage());
		}
	}
}