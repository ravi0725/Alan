public class ConsoleCTIInboundController {
    public static callData inputCallInfo {get;set;}
    public static List<Account> accList {get;set;}
    public static List<Contact> conList {get;set;}
    public static Id relAccountId {get;set;}
    public Id rAccId {get;set;}
    public Id rConId {get;set;}
    public List<Entitlement> lstEntitlements {get;set;}
    public static String pNonce {get;set;}
    public static String pUrl {get;set;}
    public static boolean openDashboardPageFlag {get;set;}
    
    public ConsoleCTIInboundController(){
        if(ApexPages.currentPage().getParameters().containsKey('nonce')){
            pNonce = ApexPages.currentPage().getParameters().get('nonce');
        } 
        pUrl = system.Url.getSalesforceBaseUrl().toExternalForm();
        openDashboardPageFlag = false;
        openDashboardPageFlag = ([select ID,Division__c from User where Id =: UserInfo.getUserId()].Division__c == 'TAP');
        
        system.debug(UserInfo.getUserId() + '---------openDashboardPageFlag---------' + openDashboardPageFlag);
    }
    
    // This method is used to retreive related Entitlements.
    public void retrieveEntitlements(){
        if(rAccId != null){
            lstEntitlements = new List<Entitlement>();
            lstEntitlements = [SELECT Id, Name, Serial_Number__c, Asset_s_Serial_Number__c, Asset_Effectivity__c, Entitlement_Status__c, Status, Contract_Start_Date__c, Contract_End_Date__c, Quantity__c, List_Price__c, Product_Code__c, Entitlement_Product_Group__c, Entitlement_Product_Sub_Group__c, AssetId, Asset.Name, AccountId FROM Entitlement WHERE AccountId =: rAccId ORDER BY Entitlement_Status__c ASC NULLS LAST];
            system.debug(' lstEntitlements ===>'+lstEntitlements);
        }
        else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: No Account Found');
            ApexPages.addMessage(myMsg);
        }
    }
    
    /*
* This Page only will be initiate, ONLY One record (Contact or Account) matched.
* 
*/
    @RemoteAction
    public static String returnAccountId(String jsonCallData){
        system.debug('---------jsonCallData-----------' + jsonCallData);
        jsonCallData = jsonCallData.replace('id', 'ANI');
        jsonCallData = jsonCallData.replace('number', 'PHNumber');
        inputCallInfo = (callData)JSON.deserialize(jsonCallData, callData.class);
        system.debug(' inputCallInfo ==>'+inputCallInfo);
        
        // Query - Account, Lead or Contact
        inputCallInfo.PHNumber = inputCallInfo.PHNumber.replaceAll('[^\\d]', ''); // Remove all spl Chars and White spaces
        // Sub string ONLY Phone numbers
        inputCallInfo.PHNumber = inputCallInfo.PHNumber.length() > 10 ? inputCallInfo.PHNumber.substring(inputCallInfo.PHNumber.length() - 10) : inputCallInfo.PHNumber;
        
        String searchQuery = 'FIND \'' + inputCallInfo.PHNumber + '\' IN PHONE Fields RETURNING Account(Id, Name), Contact(Id, Name, AccountId, Account.Name) LIMIT 1';
        List<List <sObject>> searchList = search.query(searchQuery);
        accList = ((List<Account>)searchList[0]);
        conList  = ((List<Contact>)searchList[1]);
        openDashboardPageFlag = ([select ID,Division__c from User where Id =: UserInfo.getUserId()].Division__c == 'TAP');
        if(accList.size() == 0 && conList.size() == 0){
            // No information found in SFDC
            // Redirect to Create New Case.
            DataToJavascript aData = new DataToJavascript();
            if(openDashboardPageFlag)
                aData.CaseId = CreateTAPCase(null,null,inputCallInfo.ANI);
        }
        else if(accList.size() > 0){
            // ONE Account found with Inbound Number
            relAccountId = accList[0].Id;
            
            DataToJavascript aData = new DataToJavascript();
            aData.isOnlyAccount = true;
            aData.AccountId = accList[0].Id;
            aData.AccountName = accList[0].Name;
            if(openDashboardPageFlag)
                aData.CaseId = CreateTAPCase(accList[0].Id,null,inputCallInfo.ANI);
            return JSON.serialize(aData);
        }
        else if(conList.size() > 0){
            // ONE Contact found with Inbound Number
            relAccountId = conList[0].AccountId;
            
            DataToJavascript cData = new DataToJavascript();
            cData.isOnlyAccount = false;
            cData.AccountId = conList[0].AccountId;
            cData.AccountName = conList[0].Account.Name;
            cData.ContactId = conList[0].Id;
            cData.ContactName = conList[0].Name;
            if(openDashboardPageFlag)
                cData.CaseId = CreateTAPCase(conList[0].AccountId,conList[0].Id,inputCallInfo.ANI);
            return JSON.serialize(cData);
        }
        else{
            // Some issue happening
            system.debug(' NO Account & Contact found with this Inbound Number');
        }
        return null;
    }
    
    public static Id CreateTAPCase(Id accountId, Id contactId,string interActionId){
        CaseHandler.setLaunchControl();
        CaseHandler.launchControl.put('TAPCaseConfig',0);
        
        List<Case> csList = [select Id, InteractionId__c from case where InteractionId__c =: interActionId and RecordType.Name = 'TAP - Customer Support'];
        
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
            cs.AccountId = accountId;
            cs.ContactId = contactId;
            cs.Origin = 'Phone';
            cs.Priority = 'Level 3: Medium';
            cs.Severity_c__c = 'Severity 4: Low';
            cs.InteractionId__c = interActionId;
            insert cs;
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
    
    public class DataToJavascript{
        public Boolean isOnlyAccount {get;set;}
        public Id AccountId {get;set;}
        public String AccountName {get;set;}
        public Id ContactId {get;set;}
        public Id CaseId {get;set;}
        public String ContactName {get;set;}
    }
}