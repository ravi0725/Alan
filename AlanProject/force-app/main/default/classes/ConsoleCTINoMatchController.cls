public class ConsoleCTINoMatchController {
    public callData inputCallInfo {get;set;}
    public boolean openDashboardPageFlag {get;set;}
    public ConsoleCTINoMatchController(){
        openDashboardPageFlag = false;
        openDashboardPageFlag = ([select ID,Division__c from User where Id =: UserInfo.getUserId()].Division__c == 'TAP');
    }
    
    @RemoteAction
    public static String CreateTAPCase(string jsonCallData){
        jsonCallData = jsonCallData.replace('id', 'ANI');
        jsonCallData = jsonCallData.replace('number', 'PHNumber');
        CallData inputCallInfo = (callData)JSON.deserialize(jsonCallData, callData.class);
        
        CaseHandler.setLaunchControl();
        CaseHandler.launchControl.put('TAPCaseConfig',0);
        
        String InInSessionId = inputCallInfo.ANI;
        
        List<Case> csList = [select Id, InteractionId__c from case where InteractionId__c =: InInSessionId and RecordType.Name = 'TAP - Customer Support'];
        
        Case cs = new Case();
        if(csList.size() > 0){
            //Case cs = new Case();
            cs.Id = csList[0].Id;
            cs.OwnerId = userinfo.getuserid();
            update cs;
            system.debug('--------cs--------' + cs);
        }else{        
            //Case cs = new Case();
            cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('TAP - Customer Support').getRecordTypeId();
            cs.Origin = 'Phone';
            cs.Priority = 'Level 3: Medium';
            cs.Severity_c__c = 'Severity 4: Low';
            cs.InteractionId__c = inputCallInfo.ANI;
            System.debug(' Incoming Phone Number '+inputCallInfo.PHNumber );
            cs.Incoming_Phone__c=inputCallInfo.PHNumber;
           
            insert cs;
            system.debug('--------cs--------' + cs);
        }
        return cs.Id;
    }
    
    public class callData{
        public String ANI {get;set;}
        public String isConnected {get;set;}
        public String state {get;set;}
        public String direction {get;set;}
        public String name {get;set;}
        public String interactionType {get;set;}
        public String PHNumber {get;set;}
    }
}