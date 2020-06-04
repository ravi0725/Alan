/**
Class Name : JIRAMonitorClass
Desciption : This class is used to Monitor the connection between SFDC and JIRA and notify Admins and Mangers.
Date       : 13-Mar-2017
Author     : Suresh Babu Murugan
**/
public class JIRAMonitorClass implements Schedulable {
    public static String orgType;
    public static String baseUrl = JIRAIntegrationConfig.getEndPointURL('JIRA'); // Base URL of your JIRA instance
    public static String systemId = JIRAIntegrationConfig.getSystemId('JIRA'); // Salesforce Connector System ID in JIRA
    public static String username = JIRAIntegrationConfig.getUserName('JIRA');  // JIRA username
    public static String password = JIRAIntegrationConfig.getPassword('JIRA'); // JIRA password
    public static Integer callbackCount {get;set;}
    public static String CredentialRequestLabel {get;set;}
    public static String IssueRequestLabel {get;set;}
    public static List<String> recipientAddress {get;set;}
    @testVisible public static Integer expectedCode {get;set;}
    
    public void execute(SchedulableContext SC){
        //Start Execute Process
        initialize();
    }
    
    @future(callout=true)
    public static void initialize(){
        orgType = 'Production';
        String qString = '%Prod%';
        if([Select isSandbox from Organization where Id =: userinfo.getOrganizationId()].isSandbox){
            orgType = 'Sandbox';
            qString = '%Sandbox%';
        }
        
        // Query Custom setting record to test connection.
        recipientAddress = new List<String>();
        List<JIRA_Integration_Monitor__c> lstJiraMonitor = [SELECT Id, Name, JIRA_Issue_Number__c, Object_API__c, SFDC_Record_Id__c, Notification_Email1__c, Notification_Email2__c, Notification_Email3__c, Notification_Email4__c, Notification_Email5__c FROM JIRA_Integration_Monitor__c WHERE IsActive__c = true AND Name LIKE :qString limit 1];
        if(lstJiraMonitor.size() > 0 && 
           lstJiraMonitor[0].JIRA_Issue_Number__c != null && 
           lstJiraMonitor[0].SFDC_Record_Id__c != null && 
           lstJiraMonitor[0].Object_API__c != null){
               
                if(lstJiraMonitor[0].Notification_Email1__c != null)
                    recipientAddress.add(lstJiraMonitor[0].Notification_Email1__c);
                if(lstJiraMonitor[0].Notification_Email2__c != null)
                    recipientAddress.add(lstJiraMonitor[0].Notification_Email2__c);
                if(lstJiraMonitor[0].Notification_Email3__c != null)
                    recipientAddress.add(lstJiraMonitor[0].Notification_Email3__c);
                if(lstJiraMonitor[0].Notification_Email4__c != null)
                    recipientAddress.add(lstJiraMonitor[0].Notification_Email4__c);
                if(lstJiraMonitor[0].Notification_Email5__c != null)
                    recipientAddress.add(lstJiraMonitor[0].Notification_Email5__c);

                if(recipientAddress.size() > 0)
                    JIRACredentialValidation(lstJiraMonitor[0].JIRA_Issue_Number__c, lstJiraMonitor[0].SFDC_Record_Id__c, lstJiraMonitor[0].Object_API__c);
           }
    }
    
    // This method is used to check Credentials
    public static void JIRACredentialValidation(String JIRAKey, String DevId, String ObjectType){
        String endPointCredential = baseUrl + '/rest/auth/1/session';
        String basicAuthHeader = JIRAConnectorClass.authHeader(username, password);
        String EmailMessageFormatted = '';
        String exceptionMessage = '';
        Boolean isSendEmail = false;

        HttpRequest reqCredential = new HttpRequest();
        reqCredential.setHeader('Authorization', basicAuthHeader);
        reqCredential.setHeader('Content-Type', 'application/json');
        reqCredential.setEndpoint(endPointCredential);
        reqCredential.setMethod('GET');
        reqCredential.setTimeout(60000);
        
        //HttpResponse CRresponse = JIRAConnectorClass.sendRequest(reqCredential);
        HttpResponse CRresponse = new HttpResponse();
        if(!Test.isRunningTest()){
            try{
                CRresponse = JIRAConnectorClass.sendRequest(reqCredential);
            }
            catch(Exception exp){
                exceptionMessage = exp.getMessage();
            }
        }
        else{
            MockJIRAMonitorClass mockCallout = new MockJIRAMonitorClass(expectedCode);
            CRresponse = mockCallout.respond(reqCredential);
        }
        
        Integer CRstatusCode = CRresponse.getStatusCode();
        system.debug('CRresponse =========>'+CRresponse);

        if(CRstatusCode == 200){ // Credential and Access was good
            // Do another callout to validate
            JIRAIssueValidation(JIRAKey, DevId, ObjectType, basicAuthHeader);
        }
        else if(CRstatusCode == 401){ // Unauthorized
            // Send email to Group about this exception
            isSendEmail = true;
            EmailMessageFormatted = 'Hi Team, <br/><br/>'+
                'Exception: <b>'+CRresponse+'</b><br/><br/>'+
                'Exception Occured while connection JIRA from SFDC: Please check below solutions <br/>'+
                '1. JIRA Generic User credential may wrong <br/>'+
                '2. JIRA Generic User does not have access to view JIRA Issue: '+JIRAKey +' <br/><br/>'+
                'Please DONT Reply this email, <br/>'+
                '-Automated Process';
        }
        else if(CRstatusCode == 404){ // Service Not Found
            // Send email to Group about this exception
            isSendEmail = true;
            EmailMessageFormatted = 'Hi Team, <br/><br/>'+
                'Exception: <b>'+CRresponse+'</b><br/><br/>'+
                'Exception Occured while connection JIRA from SFDC: Please check below solutions <br/>'+
                '1. Mentioned Service was not Found <br/>'+
                '2. Check your JIRA URL and Service Rocket service is Active ? <br/><br/>'+
                'Please DONT Reply this email, <br/>'+
                '-Automated Process';
        }
        else{
            // Send email to Group about this exception
            isSendEmail = true;
            EmailMessageFormatted = 'Hi Team, <br/><br/>'+
                'Exception: <b>'+CRresponse+'</b><br/><br/>'+
                'Exception Occured while connection JIRA from SFDC: Please check below <br/>'+
                '1. Status Code : '+CRresponse.getStatusCode()+' <br/>'+
                '2. Response : '+CRresponse+' <br/>'+
                '3. Response Body : '+CRresponse.getBody()+' <br/>'+
                '4. Response Message: '+exceptionMessage+' <br/><br/>'+
                'Please DONT Reply this email, <br/>'+
                '-Automated Process';
        }
        
        if(EmailMessageFormatted != '' && recipientAddress.size() > 0 && isSendEmail){ // Exception occured: send email to Group about this Exception
            sendEmailtoGroup(recipientAddress, EmailMessageFormatted);
        }
    }

    // This method is used to check mentioned Issue is available in JIRA and SFDC
    public static void JIRAIssueValidation(String JIRAKey, String DevId, String ObjectType, String basicAuthHeader){
        String endPointIssue = baseUrl + '/rest/api/2/issue/'+JIRAKey;
        String EmailMessageFormatted = '';
        Boolean isSendEmail = false;

        HttpRequest reqIssue = new HttpRequest();
        reqIssue.setHeader('Authorization', basicAuthHeader);
        reqIssue.setHeader('Content-Type', 'application/json');
        reqIssue.setEndpoint(endPointIssue);
        reqIssue.setMethod('GET');
        reqIssue.setTimeout(60000);

        HttpResponse ISresponse = new HttpResponse();
        if(!Test.isRunningTest()){
            ISresponse = JIRAConnectorClass.sendRequest(reqIssue);
        }
        else{
            MockJIRAMonitorClass mockCallout = new MockJIRAMonitorClass(expectedCode);
            ISresponse = mockCallout.respond(reqIssue);
        }

        Integer ISstatusCode = ISresponse.getStatusCode();

        if(ISstatusCode == 200){ // Connection looks good
            // Do another callout to validate : 
            JIRASyncValidation(JIRAKey, DevId, ObjectType, basicAuthHeader);
        }
        else if(ISstatusCode == 404){ // Mentioned Issue Not Found
            // Send email to Group about this exception
            isSendEmail = true;
            EmailMessageFormatted = 'Hi Team, <br/><br/>'+
                'Exception: <b>'+ISresponse+'</b><br/><br/>'+
                'Exception Occured while connection JIRA from SFDC: Please check below solutions <br/>'+
                '1. Mentioned JIRA Issue may be deleted. Please check : '+JIRAKey+' <br/>'+
                '2. Check the Service Rocket service URL <br/><br/>'+
                'Please DONT Reply this email, <br/>'+
                '-Automated Process';
            
        }
        else{
            // Send email to Group about this exception
            isSendEmail = true;
            EmailMessageFormatted = 'Hi Team, <br/><br/>'+
                'Exception Occured while connection JIRA from SFDC: Please check below <br/>'+
                '1. Status Code : '+ISresponse.getStatusCode()+' <br/>'+
                '2. Response : '+ISresponse+' <br/>'+
                '3. Response Body : '+ISresponse.getBody()+' <br/><br/>'+
                'Please DONT Reply this email, <br/>'+
                '-Automated Process';
        }
        
        if(EmailMessageFormatted != '' && recipientAddress.size() > 0 && isSendEmail){ // Exception occured: send email to Group about this Exception
            sendEmailtoGroup(recipientAddress, EmailMessageFormatted);
        }
    }

    // This method is used to test sync with JIRA
    public static void JIRASyncValidation(String JIRAKey, String DevId, String ObjectType, String basicAuthHeader){
        String endPointSync = baseUrl + '/rest/customware/connector/1.0/' + systemId + '/' + ObjectType +  '/' + DevId + '/issue/synchronize.json';
        String EmailMessageFormatted = '';
        Boolean isSendEmail = false;

        HttpRequest reqSync = new HttpRequest();
        reqSync.setHeader('Authorization', basicAuthHeader);
        reqSync.setHeader('Content-Type', 'application/json');
        reqSync.setEndpoint(endPointSync);
        reqSync.setMethod('PUT');
        reqSync.setTimeout(60000);
        
        HttpResponse SyncResponse = new HttpResponse();
        if(!Test.isRunningTest()){
            SyncResponse = JIRAConnectorClass.sendRequest(reqSync);
        }
        else{
            MockJIRAMonitorClass mockCallout = new MockJIRAMonitorClass(expectedCode);
            SyncResponse = mockCallout.respond(reqSync);
        }
        Integer SyncStatusCode = SyncResponse.getStatusCode();
        
        if(SyncStatusCode == 200){ // Connection looks good
            // check related workflow status code was updated properly in SFDC, if not send email to Group
            JIRATransitionValidation(JIRAKey, DevId, ObjectType);
        }
        else if(SyncStatusCode == 500){ // Internal Server Error
            // Send email to Group about this exception
            isSendEmail = true;
            EmailMessageFormatted = 'Hi Team, <br/><br/>'+
                'Exception: <b>'+SyncResponse+'</b><br/><br/>'+
                'Exception Occured while connection JIRA from SFDC: Please check below solutions <br/>'+
                '1. Internal Server Error : Please check Endpoint URL : '+endPointSync+' <br/>'+
                '2. Check the Service Rocket service URL <br/><br/>'+
                'Please DONT Reply this email, <br/>'+
                '-Automated Process';
            
        }
        else{
            // Send email to Group about this exception
            isSendEmail = true;
            EmailMessageFormatted = 'Hi Team, <br/><br/>'+
                'Exception Occured while connection JIRA from SFDC: Please check below <br/>'+
                '1. Status Code : '+SyncResponse.getStatusCode()+' <br/>'+
                '2. Response : '+SyncResponse+' <br/>'+
                '3. Response Body : '+SyncResponse.getBody()+' <br/><br/>'+
                'Please DONT Reply this email, <br/>'+
                '-Automated Process';
        }

        if(EmailMessageFormatted != '' && recipientAddress.size() > 0 && isSendEmail){ // Exception occured: send email to Group about this Exception
            sendEmailtoGroup(recipientAddress, EmailMessageFormatted);
        }
    }

    // This method is used to check status transitions
    public static void JIRATransitionValidation(String JIRAKey, String DevId, String ObjectType){
        String endPointTransition = baseUrl + '/rest/api/2/issue/' + JIRAKey + '/transitions';
        String EmailMessageFormatted = '';
        Boolean isSendEmail = false;
        try{
            String JIRAStatus_JSON = '';
            if(!Test.isRunningTest()){
                JIRAStatus_JSON = JIRAUpdateStatusCustomSettingRecords.updateJIRAStatusinSFDC(JIRAKey);
            }
            else{
                HttpRequest reqTrans = new HttpRequest();
                reqTrans.setHeader('Authorization', JIRAConnectorClass.authHeader(username, password));
                reqTrans.setHeader('Content-Type', 'application/json');
                reqTrans.setEndpoint(endPointTransition);
                reqTrans.setMethod('PUT');
                reqTrans.setTimeout(60000);
                MockJIRAMonitorClass mockCallout = new MockJIRAMonitorClass(expectedCode);
                JIRAStatus_JSON = mockCallout.respond(reqTrans).getBody();
            }
            //String JIRAStatus_JSON = JIRAUpdateStatusCustomSettingRecords.updateJIRAStatusinSFDC(JIRAKey);
            
            if(JIRAStatus_JSON != ''){
                JIRAStatusWrapper statusInformation = new JIRAStatusWrapper();
                statusInformation = (JIRAStatusWrapper) System.JSON.deserialize(JIRAStatus_JSON, JIRAStatusWrapper.class);

                String SOQLJKeyParam = JIRAKey.substringBefore('-') +'-%';
                Map<String, String> mapSFDCAvailableStatus = new Map<String, String>();
                Map<String, String> mapJIRAStatuses = new Map<String, String>();

                for(JIRA_Status_Mapping__c jMap: [SELECT Name, Id, Status_Code__c FROM JIRA_Status_Mapping__c WHERE Name LIKE : SOQLJKeyParam]){
                    mapSFDCAvailableStatus.put(jMap.Name, jMap.Status_Code__c);
                }
                
                if(statusInformation.transitions.size() > 0){
                    for(cls_transitions tran: statusInformation.transitions){
                        String formattedString = JIRAKey.substringBefore('-') + '-' + tran.name;
                        mapJIRAStatuses.put(formattedString, tran.id);
                    }
                }

                for(String SFDCStatus: mapSFDCAvailableStatus.keySet()){
                    if(mapJIRAStatuses.containsKey(SFDCStatus)){
                        if(mapJIRAStatuses.get(SFDCStatus) != mapSFDCAvailableStatus.get(SFDCStatus)){
                            // It seems JIRA Status code was updated we need to sync it with SFDC
                            isSendEmail = true;
                            EmailMessageFormatted = 'Hi Team, <br/><br/>'+
                                'Exception: <b> JIRA Transition Staus code was changed </b><br/><br/>'+
                                'Exception Occured while connection JIRA from SFDC: Please check below solutions <br/>'+
                                '1. Run in Execute Anonymous : JIRAUpdateStatusCustomSettingRecords.retrieveJIRAStatus(\''+ JIRAKey + '\');  <br/><br/>'+
                                'Please DONT Reply this email, <br/>'+
                                '-Automated Process';
                            break;
                        }
                    }
                    else{
                        // It seems, JIRA status was removed
                        isSendEmail = true;
                        EmailMessageFormatted = 'Hi Team, <br/><br/>'+
                            'Exception: <b> JIRA Transition Status was removed : '+SFDCStatus+': '+mapSFDCAvailableStatus.get(SFDCStatus)+' </b><br/><br/>'+
                            'Exception Occured while connection JIRA from SFDC: Please check below solutions <br/>'+
                            '1. Run in Execute Anonymous : JIRAUpdateStatusCustomSettingRecords.retrieveJIRAStatus(\''+ JIRAKey + '\');  <br/><br/>'+
                            'Please DONT Reply this email, <br/>'+
                            '-Automated Process';
                        break;
                    }
                }

                for(String JIRAStatus: mapJIRAStatuses.keySet()){
                    if(mapSFDCAvailableStatus.containsKey(JIRAStatus)){
                        if(mapSFDCAvailableStatus.get(JIRAStatus) != mapJIRAStatuses.get(JIRAStatus)){
                            // It seems JIRA Status code was updated we need to sync it with SFDC
                            isSendEmail = true;
                            EmailMessageFormatted = 'Hi Team, <br/><br/>'+
                                'Exception: <b> JIRA Transition Staus code was changed </b><br/><br/>'+
                                'Exception Occured while connection JIRA from SFDC: Please check below solutions <br/>'+
                                '1. Run in Execute Anonymous : JIRAUpdateStatusCustomSettingRecords.retrieveJIRAStatus(\''+ JIRAKey + '\');  <br/><br/>'+
                                'Please DONT Reply this email, <br/>'+
                                '-Automated Process';
                            break;
                        }
                    }
                    else{
                        // It seems, new JIRA status was added
                        isSendEmail = true;
                        EmailMessageFormatted = 'Hi Team, <br/><br/>'+
                            'Exception: <b> New JIRA Transition Status was added : '+JIRAStatus+': '+mapJIRAStatuses.get(JIRAStatus)+' </b><br/><br/>'+
                            'Exception Occured while connection JIRA from SFDC: Please check below solutions <br/>'+
                            '1. Run in Execute Anonymous : JIRAUpdateStatusCustomSettingRecords.retrieveJIRAStatus(\''+ JIRAKey + '\');  <br/><br/>'+
                            'Please DONT Reply this email, <br/>'+
                            '-Automated Process';
                        break;
                    }
                }
            }
        }
        catch(Exception exp){
            isSendEmail = true;
            EmailMessageFormatted = 'Hi Team, <br/><br/>'+
                'Exception: <b> JIRA Transition Validation </b><br/><br/>'+
                'Exception Occured while connection JIRA from SFDC: Please check below solutions <br/>'+
                '1. Exception : '+ exp.getMessage() +' <br/><br/>'+
                'Please DONT Reply this email, <br/>'+
                '-Automated Process';
        }
        
        if(EmailMessageFormatted != '' && recipientAddress.size() > 0 && isSendEmail){ // Exception occured: send email to Group about this Exception
            sendEmailtoGroup(recipientAddress, EmailMessageFormatted);
        }
    }

    // This Method is used to send email to Group when any exception occures
    public static void sendEmailtoGroup(List<String> lstToAddresses, String ExceptionMessage){
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();  
        
        Messaging.SingleEmailMessage sEmail = new Messaging.SingleEmailMessage();
        sEmail.setToAddresses(lstToAddresses);
        sEmail.setSubject('Exception: SFDC-JIRA Connector having Issue');
        sEmail.setBccSender(false);
        sEmail.setHtmlBody(ExceptionMessage);
        emailList.add(sEmail);
        
        Messaging.sendEmail(emailList);
    }

    // JIRA Status Information for the Requested Project
    @testVisible public class JIRAStatusWrapper {
        public String expand;  //transitions
        public List<cls_transitions> transitions;
    }
    class cls_transitions {
        String id;  //11
        String name;  //To Do
        cls_to to;
    }
    class cls_to {
        String self;  //https://ejira.trimble.com/rest/api/2/status/10001
        String description;  //
        String iconUrl;  //https://ejira.trimble.com/images/icons/subtask.gif
        String name;  //To Do
        String id;  //10001
        cls_statusCategory statusCategory;
    }
    class cls_statusCategory {
        String self;  //https://ejira.trimble.com/rest/api/2/statuscategory/2
        Integer id;  //2
        String key;  //new
        String colorName;  //blue-gray
        String name;  //To Do
    }
    /////
}