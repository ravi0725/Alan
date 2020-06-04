public class ConsoleCTIMultipleMatchCtrl {
    public List<aInternalWrapper> lstAllDetails { get; set; }
    public String pNonce { get; set; }
    public String pUrl { get; set; }

    public callData inputCallInfo { get; set; }
    public Id relAccountId { get; set; }

    public List<contactWrapper> lstFilteredContacts { get; set; }
    public static List<Contact> conList { get; set; }
    public static List<Account> accList { get; set; }
    public boolean displayPopup { get; set; }

    public String AllDataJSON { get; set; }
    public String jsonCallData { get; set; }

    public Id entId { get; set; }
    public Id entAccId { get; set; }
    public Id entAstId { get; set; }
    public String entPGroup { get; set; }
    public boolean openDashboardPageFlag { get; set; }

    public ConsoleCTIMultipleMatchCtrl() {
        conList = new List<Contact> ();
        accList = new List<Account> ();
        if (ApexPages.currentPage().getParameters().containsKey('nonce')) {
            pNonce = ApexPages.currentPage().getParameters().get('nonce');
        }
        pUrl = system.Url.getSalesforceBaseUrl().toExternalForm();
        openDashboardPageFlag = false;
        openDashboardPageFlag = ([select ID, Division__c from User where Id = :UserInfo.getUserId()].Division__c == 'TAP');

        system.debug(UserInfo.getUserId() + '---------openDashboardPageFlag---------' + openDashboardPageFlag);
    }

    public void closePopup() {
        displayPopup = false;
    }
    public PageReference showPopup() {
        system.Debug(' entId  =>' + entId);

        lstFilteredContacts = new List<contactWrapper> ();
        for (Contact cc : conList) {
            if (cc.AccountId == entAccId) {
                contactWrapper cWrp = new contactWrapper();
                cWrp.cCont = cc;
                cWrp.entId = entId;
                cWrp.entAccId = entAccId;
                cWrp.entAstId = entAstId;
                cWrp.entPGroup = entPGroup;

                lstFilteredContacts.add(cWrp);
            }
        }
        system.Debug(' lstFilteredContacts ==>' + lstFilteredContacts);
        displayPopup = true;
        return null;
    }

    public void returnAccountId() {
        system.debug(' jsonCallData  ==>>>>' + jsonCallData);
        jsonCallData = jsonCallData.replace('id', 'ANI');
        jsonCallData = jsonCallData.replace('number', 'PHNumber');
        inputCallInfo = (callData) JSON.deserialize(jsonCallData, callData.class);
        system.debug(' ' + inputCallInfo);

        String ConditionedPhone = '( ' + inputCallInfo.PHNumber + ' OR ';
        // Query - Account, Lead or Contact
        inputCallInfo.PHNumber = inputCallInfo.PHNumber.replaceAll('[^\\d]', ''); // Remove all spl Chars and White spaces
        // Sub string ONLY Phone numbers
        inputCallInfo.PHNumber = inputCallInfo.PHNumber.length() > 10 ? inputCallInfo.PHNumber.substring(inputCallInfo.PHNumber.length() - 10) : inputCallInfo.PHNumber;
        ConditionedPhone += inputCallInfo.PHNumber + ' )';

        String searchQuery = 'FIND \'' + ConditionedPhone + '\' IN PHONE Fields RETURNING Account(Id, Name), Contact(Id, Name, AccountId, Account.Name, Title, Email, Phone) LIMIT 100';
        List<List<sObject>> searchList = search.query(searchQuery);
        accList = ((List<Account>) searchList[0]);
        conList = ((List<Contact>) searchList[1]);


        lstAllDetails = new List<aInternalWrapper> ();
        Set<id> setAccIds = new Set<Id> ();
        Set<id> setConIds = new Set<Id> ();
        for (Account acc : accList) {
            setAccIds.add(acc.id);
        }
        for (Contact con : conList) {
            setAccIds.add(con.AccountId);
            setConIds.add(con.Id);
        }

        system.debug(' setConId ==>' + setConIds);
        openDashboardPageFlag = ([select ID, Division__c from User where Id = :UserInfo.getUserId()].Division__c == 'TAP');

        // Query Account Related Data
        List<Account> lstMatchedAccounts;
        if (!openDashboardPageFlag) {
            lstMatchedAccounts = [SELECT Id, Name, Account_Status__c, Type, BillingCity, BillingCountry, BillingState, BillingStreet, BillingPostalCode, Phone, OwnerId, Owner.Alias, Enterprise_Master_ID_del__c,
            (SELECT AccountId, Account.Name, Id, Name, Serial_Number__c, Asset_s_Serial_Number__c, Asset_Effectivity__c, Entitlement_Status__c, Status, Contract_Start_Date__c, Contract_End_Date__c, Quantity__c, List_Price__c, Product_Code__c, Entitlement_Product_Group__c, Entitlement_Product_Sub_Group__c, AssetId, Asset.Name FROM Entitlements ORDER BY Entitlement_Status__c ASC NULLS LAST),
            (SELECT AccountId, Id, Name, Title, Account.Name, Email, Phone, MobilePhone, Division_Department__c, OwnerId, Owner.Alias, FCH_Contact_Id__c, Contact_Status__c FROM Contacts WHERE Id IN :setConIds)
                                  FROM Account WHERE id IN :setAccIds];
        } else {
            lstMatchedAccounts = [SELECT Id, Name, Account_Status__c, Type, BillingCity, BillingCountry, BillingState, BillingStreet, BillingPostalCode, Phone, OwnerId, Owner.Alias, Enterprise_Master_ID_del__c,
            (SELECT AccountId, Id, Name, Title, Account.Name, Email, Phone, MobilePhone, Division_Department__c, OwnerId, Owner.Alias, FCH_Contact_Id__c, Contact_Status__c FROM Contacts WHERE Id IN :setConIds)
                                  FROM Account WHERE id IN :setAccIds];
        }
        for (Account ac : lstMatchedAccounts) {
            aInternalWrapper wrp = new aInternalWrapper();
            wrp.wAccount = ac;
            wrp.wlstContacts = ac.Contacts;
            if (!openDashboardPageFlag) wrp.wlstEntitlements = ac.Entitlements;
            if (ac.Contacts.size() == 1) {
                wrp.relContactId = ac.Contacts[0].Id;
            }
            lstAllDetails.add(wrp);
        }

        if (accList.size() == 0 && conList.size() == 0) {
            // No information found in SFDC
            // Redirect to Create New Case.

        }
        else if (accList.size() > 0) {
            // ONE Account found with Inbound Number
            relAccountId = accList[0].Id;

            DataToJavascript aData = new DataToJavascript();
            aData.isOnlyAccount = true;
            aData.AccountId = accList[0].Id;
            aData.AccountName = accList[0].Name;
            //return JSON.serialize(aData);
        }
        else if (conList.size() > 0) {
            // ONE Contact found with Inbound Number
            relAccountId = conList[0].AccountId;

            DataToJavascript cData = new DataToJavascript();
            cData.isOnlyAccount = false;
            cData.AccountId = conList[0].AccountId;
            cData.AccountName = conList[0].Account.Name;
            cData.ContactId = conList[0].Id;
            cData.ContactName = conList[0].Name;
            //return JSON.serialize(cData);
        }
        else {
            // Some issue happening
            system.debug(' NO Account & Contact found with this Inbound Number');
        }
    }

    @RemoteAction
    public static String returnTAPCaseId(string jsonCallData) {
        jsonCallData = jsonCallData.replace('id', 'ANI');
        jsonCallData = jsonCallData.replace('number', 'PHNumber');
        CallData inputCallInfo = (callData) JSON.deserialize(jsonCallData, callData.class);
        system.debug(' inputCallInfo ==>' + inputCallInfo);

        String ConditionedPhone = '( ' + inputCallInfo.PHNumber + ' OR ';
        // Query - Account, Lead or Contact
        inputCallInfo.PHNumber = inputCallInfo.PHNumber.replaceAll('[^\\d]', ''); // Remove all spl Chars and White spaces
        // Sub string ONLY Phone numbers
        inputCallInfo.PHNumber = inputCallInfo.PHNumber.length() > 10 ? inputCallInfo.PHNumber.substring(inputCallInfo.PHNumber.length() - 10) : inputCallInfo.PHNumber;
        ConditionedPhone += inputCallInfo.PHNumber + ' )';

        String searchQuery = 'FIND \'' + ConditionedPhone + '\' IN PHONE Fields RETURNING Account(Id, Name), Contact(Id, Name, AccountId, Account.Name, Title, Email, Phone) LIMIT 100';
        List<List<sObject>> searchList = search.query(searchQuery);
        accList = ((List<Account>) searchList[0]);
        conList = ((List<Contact>) searchList[1]);

        system.debug('---------inputCallInfo.ANI----------' + inputCallInfo.ANI);
        system.debug('---------accList----------' + accList);
        system.debug('---------conList----------' + conList);
        DataToJavascript data = new DataToJavascript();

        String InInSessionId = inputCallInfo.ANI;

        List<Case> csList = [select Id, InteractionId__c from case where InteractionId__c = :InInSessionId and RecordType.Name = 'TAP - Customer Support'];

        Case cs = new Case();
        if (csList.size() > 0) {
            //Case cs = new Case();
            cs.Id = csList[0].Id;
            cs.OwnerId = userinfo.getuserid();
            update cs;
            system.debug('--------cs--------' + cs);
        } else {
            //Case cs = new Case();
            cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('TAP - Customer Support').getRecordTypeId();
            cs.Origin = 'Phone';
            cs.Priority = 'Level 3: Medium';
            cs.Severity_c__c = 'Severity 4: Low';
            cs.InteractionId__c = inputCallInfo.ANI;
            data.oneAccountFound = false;
            if (conList.size() == 1) {
                data.ContactId = conList.get(0).Id;

                cs.ContactId = conList.get(0).Id;

                data.ContactName = conList.get(0).Name;
                data.AccountId = conList.get(0).AccountId;

                cs.AccountId = conList.get(0).AccountId;

                data.AccountName = conList.get(0).Account.Name;
                data.isOnlyAccount = false;
                data.oneAccountFound = true;
            } else if (accList.size() == 1) {
                data.AccountId = accList.get(0).Id;

                cs.AccountId = accList.get(0).Id;

                data.AccountName = accList.get(0).Name;
                data.isOnlyAccount = true;
                data.oneAccountFound = true;
            }
            CaseHandler.setLaunchControl();
            CaseHandler.launchControl.put('TAPCaseConfig', 0);

            insert cs;
        }
        data.caseId = cs.Id;
        system.debug('------JSON.serialize(data)-------' + JSON.serialize(data));
        return JSON.serialize(data);
    }
    //JIRA-APP-2280-- Start
    @RemoteAction
    public static String updateTAPCase(String jsonCallData, String accId, String conId) {
        jsonCallData = jsonCallData.replace('id', 'ANI');
        jsonCallData = jsonCallData.replace('number', 'PHNumber');
        CallData inputCallInfo = (callData) JSON.deserialize(jsonCallData, callData.class);
        system.debug(' inputCallInfo ==>' + inputCallInfo);
        String InInSessionId = inputCallInfo.ANI;
        DataToJavascript data = new DataToJavascript();
        List<Case> lstCurrentCase = [SELECT Id, CaseNumber, ContactId, AccountId, InteractionId__c FROM Case WHERE InteractionId__c = :InInSessionId AND RecordType.Name = 'TAP - Customer Support' LIMIT 1];
        if (lstCurrentCase.size() == 1) {
            lstCurrentCase[0].ContactId = (conId != null ? conId : null);
            lstCurrentCase[0].AccountId = (accId != null ? accId : null);

            data.ContactId = (conId != null ? conId : null);
            //data.ContactName = conList.get(0).Name;
            data.AccountId = (accId != null ? accId : null);
            //data.AccountName = conList.get(0).Account.Name;
            data.isOnlyAccount = false;
            data.oneAccountFound = true;
            update lstCurrentCase[0];
            data.caseId = lstCurrentCase[0].Id;
            data.CaseNumber = lstCurrentCase[0].CaseNumber;
        }
        else{
            Case cs = new Case();
            cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('TAP - Customer Support').getRecordTypeId();
            cs.Origin = 'Phone';
            cs.Priority = 'Level 3: Medium';
            cs.Severity_c__c = 'Severity 4: Low';
            cs.InteractionId__c = inputCallInfo.ANI;
            cs.ContactId = (conId != null ? conId : null);
            cs.AccountId = (accId != null ? accId : null);
            
            data.oneAccountFound = false;
            data.ContactId = (conId != null ? conId : null);
            data.AccountId = (accId != null ? accId : null);
            data.isOnlyAccount = false;
            //data.ContactName = conList.get(0).Name;
            //data.AccountName = conList.get(0).Account.Name;
            insert cs;
            data.caseId = cs.Id;
            data.CaseNumber = cs.CaseNumber;
        }
        return JSON.serialize(data);
    }
    //JIRA-APP-2280-- End

    public class contactWrapper {
        public Contact cCont { get; set; }
        public Id entId { get; set; }
        public Id entAccId { get; set; }
        public Id entAstId { get; set; }
        public String entPGroup { get; set; }
    }

    public class aInternalWrapper {
        public Account wAccount { get; set; }
        public List<Contact> wlstContacts { get; set; }
        public List<Entitlement> wlstEntitlements { get; set; }
        public Id relContactId { get; set; }

        public aInternalWrapper() {
            wAccount = new Account();
            wlstContacts = new List<Contact> ();
            wlstEntitlements = new List<Entitlement> ();
        }
    }

    public class callData {
        public String ANI { get; set; }
        public String isConnected { get; set; }
        public String state { get; set; }
        public String direction { get; set; }
        public String name { get; set; }
        public String interactionType { get; set; }
        public String PHNumber { get; set; }
    }

    public class DataToJavascript {
        public Boolean isOnlyAccount { get; set; }
        public Boolean oneAccountFound { get; set; }
        public Id AccountId { get; set; }
        public String AccountName { get; set; }
        public Id ContactId { get; set; }
        public String ContactName { get; set; }
        public String CaseId { get; set; }
        public String CaseNumber { get; set; }
    }
}