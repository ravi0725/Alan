public class AccountHelper{
    public static Map<String, Integer> launchControl;
    public static List<String> deletedAcc;
    public static Set<String> deletedAdd;
    public static Set<String> deletedCon;
    public static set<Id> masterRecordIds;
    public static Set<String> relatedAdd;
    public static Set<String> relatedCon;
    public static boolean mergeCalloutFlag;
    // Static initialize
    static {
        resetLaunchControl();
    }
    
    // Reset Trigger control (e.g. for testing)
    public static void resetLaunchControl() {
        launchControl = new Map<String, Integer>();
        launchControl.put('CreateAddressRdFromBillToAddress', 0);
        launchControl.put('getRelatedRecords', 0);
        launchControl.put('updateAddressFromBillToAddress', 0);
        launchControl.put('resetStatusFlag', 0);
        launchControl.put('SendEmailOnCreditCheck', 0);
        mergeCalloutFlag = true;
    }
    
    // Reset Trigger control (e.g. for testing)
    public static void setLaunchControl() {
        launchControl = new Map<String, Integer>();
        launchControl.put('CreateAddressRdFromBillToAddress', 1);
        launchControl.put('getRelatedRecords', 1);
        launchControl.put('updateAddressFromBillToAddress', 1);
        launchControl.put('resetStatusFlag', 1);
        launchControl.put('SendEmailOnCreditCheck', 1);
    }
    
    public static void SendEmailOnCreditCheck(ID AccountID){
    if(launchControl.get('SendEmailOnCreditCheck') < 1){
            launchControl.put('SendEmailOnCreditCheck',launchControl.get('SendEmailOnCreditCheck') + 1);
            try{
            String AccName = '';
            String AccCountry ='';
            String AccEPN='';
            String AccEBSAccNum ='';
            String AccCollector ='';
             List<String> toAdd = new List <String>();
            List<Account>AccountList = [Select id,BillingCountry,Name,Enterprise_Party_Number__c,EBS_Account_Number__c,COLLECTOR_Name__c from Account where id=:AccountID];
            List<opportunity>OpptyList = [select id,owner.email from opportunity where (StageName != '6 - Closed Won' AND StageName !='Closed Lost') and Bill_To_Account__c=:AccountID];
            if(AccountList.size()>0)
            {
             AccName = AccountList.get(0).Name;
             AccCountry = AccountList.get(0).BillingCountry;
             AccEPN = AccountList.get(0).Enterprise_Party_Number__c;
             AccEBSAccNum = AccountList.get(0).EBS_Account_Number__c;
             AccCollector = AccountList.get(0).COLLECTOR_Name__c;
            }
           
            if(OpptyList.size()>0)
            {
             for(Opportunity Op : OpptyList)
             {
              if(Op.Owner.Email!=Null)
              toAdd.add(Op.Owner.Email);
             }
            }
            
             
         List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
         Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
         mail.setSenderDisplayName('Trimble SFDC');
       //mail.setOrgWideEmailAddressId(OrgID);
          mail.setToAddresses(toAdd);
         mail.setSubject('Credit Information Updated - '+AccName+', '+AccCountry);
      String body = 'Hi, <Br/><BR />';
      body += 'This customer’s credit info has been updated by Credit & Collection team.<BR /><BR />';
      body += '<u>Customer Name:</u> '+AccName+'<BR />';
      body += '<u>Enterprise Account Number:</u> '+AccEPN+'<BR />';
      body += '<u>Oracle Account Number:</u> '+AccEBSAccNum+'<BR />';
      body += '<u>Collector Name:</u> '+AccCollector+'<BR />';
      body += '<BR/><BR/>Thanks,<BR/><BR/>';
      body += 'Salesforce Support';
       mail.setHtmlBody(body);
         mails.add(mail);
        // Messaging.sendEmail(mails);
       } 
        catch(Exception e){
                    
       }  
      } 
    }
    
    public static void resetStatusFlag(Map<Id,Account> newMap, Map<Id,Account> oldMap){
     String usrProfileName;
    usrProfileName = [select u.Profile.Name from User u where u.id = :Userinfo.getUserId()].Profile.Name; 
     system.debug('*****UserProfile*****'+usrProfileName);
        if(launchControl.get('resetStatusFlag') < 1){
            launchControl.put('resetStatusFlag',launchControl.get('resetStatusFlag') + 1);
            for(Account Ad : newMap.values())
            {
                if(!usrProfileName.contains(Label.Restrict_Callout_Profile) && ((oldMap.get(Ad.id).BillingStreet != Null && oldMap.get(Ad.id).BillingStreet != newMap.get(Ad.id).BillingStreet )||
                   
                   (oldMap.get(Ad.id).BillingState != Null && oldMap.get(Ad.id).BillingState != newMap.get(Ad.id).BillingState )||
                   (oldMap.get(Ad.id).BillingCity != Null && oldMap.get(Ad.id).BillingCity != newMap.get(Ad.id).BillingCity )||
                   (oldMap.get(Ad.id).BillingCountry != Null && oldMap.get(Ad.id).BillingCountry != newMap.get(Ad.id).BillingCountry )||
                   (oldMap.get(Ad.id).County__c!= Null && oldMap.get(Ad.id).County__c!= newMap.get(Ad.id).County__c)||
                   (oldMap.get(Ad.id).BillingPostalCode!= Null && oldMap.get(Ad.id).BillingPostalCode!= newMap.get(Ad.id).BillingPostalCode))){
                    system.debug('*****UserProfile*****'+usrProfileName);
                       Ad.Validation_Status_Code__c ='';
                       Ad.Validation_Status__c ='';
                   }
            }
        }
    }
    
    public static boolean validateAccountExternalKeyValue(List<Account> newList,Map<Id,Account> oldMap){
        boolean flag = true;
        for(Account acc : newList){
            System.debug('----------'+(acc.FCH_Party_ID__c != oldMap.get(acc.Id).FCH_Party_ID__c));
            System.debug('----------'+(acc.Enterprise_Party_Number__c != oldMap.get(acc.Id).Enterprise_Party_Number__c));
            if(acc.FCH_Party_ID__c != oldMap.get(acc.Id).FCH_Party_ID__c || 
              acc.Enterprise_Party_Number__c != oldMap.get(acc.Id).Enterprise_Party_Number__c){
                flag = false;
                break;
            }
        }
        return flag;
    }
    
    public static void getmergeData(List<Account> oldList){
        masterRecordIds = new set<Id>();
        Map<Id,Account> accMap = new Map<Id,Account>();
        for(Account accObj : oldList){
            if(accObj.MasterRecordId != null){
                masterRecordIds.add(accObj.MasterRecordId);
                RecursiveTriggerUtility.isAccountMergeRecursive = true;
                accMap.put(accObj.Id,accObj);
            }
       }
        
        if(accMap.size() > 0){
            accountMerge(accMap);
        }
       system.debug('------------masterRecordIds--------' + masterRecordIds);
    }
    
    public static void accountMerge(Map<Id,Account> oldAccMap){
        List<Address__c> updateAddressList = new List<Address__c>();
        for(Address__c add : [select ID,Primary__c,FCH_Party_Site_ID__c,Enterprise_Address_Number__c from Address__c where Id in : AccountHelper.relatedAdd]){
            if(add.FCH_Party_Site_ID__c != null || add.Enterprise_Address_Number__c != null || add.Primary__c){
                add.FCH_Party_Site_ID__c ='';
                add.Enterprise_Address_Number__c ='';
                add.Primary__c = false;
                updateAddressList.add(add);
            }
        }
        if(updateAddressList.size() > 0){
            RecursiveTriggerUtility.isAccountMergeRecursive = true;
            update updateAddressList;
        }
        List<Contact> updateContactList = new List<Contact>();
        for(Contact con : [select ID,FCH_Cell_Phone_Id__c,FCH_Contact_Id__c,FCH_Email_Id__c,FCH_Phone_Id__c
                           ,FCH_Fax_Id__c,FCH_Home_Phone_Id__c
                           from Contact where Id in : AccountHelper.relatedCon]){
            if(Con.FCH_Cell_Phone_Id__c != null || Con.FCH_Contact_Id__c != null || Con.FCH_Email_Id__c != null || 
                Con.FCH_Fax_Id__c != null || Con.FCH_Home_Phone_Id__c != null || Con.FCH_Phone_Id__c != null){
                Con.FCH_Cell_Phone_Id__c='';
                Con.FCH_Contact_Id__c='';
                Con.FCH_Email_Id__c='';
                Con.FCH_Fax_Id__c='';
                Con.FCH_Home_Phone_Id__c='';
                Con.FCH_Phone_Id__c ='';
                Con.Enterprise_Contact_Number__c='';
                updateContactList.add(con);
            }
        }
        if(updateContactList.size() > 0){
            RecursiveTriggerUtility.isAccountMergeRecursive = true;
            update updateContactList;
        }
    }
    
    public static void getRelatedRecords(Account acc){
        deletedAcc = new List<String>();
        deletedAdd = new Set<String>();
        deletedCon = new Set<String>();
        relatedAdd = new Set<String>();
        relatedCon = new Set<String>();
        if(launchControl.get('getRelatedRecords') < 1){
            launchControl.put('getRelatedRecords',launchControl.get('getRelatedRecords') + 1);
            for(Account accObj : [select Name,Enterprise_Party_Number__c,FCH_Party_ID__c From 
                     Account where Id =: acc.Id]){
                deletedAcc.add(accObj.Id + ' ~~ ' + accObj.Enterprise_Party_Number__c + ' ~~ ' + accObj.FCH_Party_ID__c + ' ~~ ' + accObj.Name);
            }
            
            for(Contact con : [Select Id,Enterprise_Contact_Number__c,FCH_Contact_Id__c
                 from Contact where AccountId =: acc.Id]){
                system.debug('-----------temp--------' + con.Id + '~' + con.Enterprise_Contact_Number__c+ '~' + con.FCH_Contact_Id__c);
                relatedCon.add(con.Id);
                deletedCon.add(con.Id + ' ~~ ' + con.Enterprise_Contact_Number__c+ ' ~~ ' + con.FCH_Contact_Id__c);
            }
            
            for(Address__c add : [Select Id,FCH_Party_Site_ID__c,Enterprise_Address_Number__c from Address__c
                 where Account__c =: acc.Id]){
                 relatedAdd.add(add.Id);
                deletedAdd.add(add.Id + ' ~~ ' + add.Enterprise_Address_Number__c + ' ~~ ' + add.FCH_Party_Site_ID__c);
            }
            system.debug('------------deletedAcc--------' + deletedAcc);
            system.debug('------------deletedAdd--------' + deletedAdd);
            system.debug('------------deletedCon--------' + deletedCon);
        }
        
    }
    
    
    public static void CreateAddressRdFromBillToAddress(List<Account> accList){
        if(launchControl.get('CreateAddressRdFromBillToAddress') < 1){
            launchControl.put('CreateAddressRdFromBillToAddress',launchControl.get('CreateAddressRdFromBillToAddress') + 1);
            system.debug('------------accList--------' + accList);
            List<Address__c> addressList = new List<Address__c>();
            for(Account acc : accList){
                if(acc.Bill_To_Flag__c || acc.Ship_To_Flag__c){
                    Address__c address = createAddress(acc);
                    addressList.add(address);
                }
            }
            system.debug('------------addressList--------' + addressList);
            RecursiveTriggerUtility.isAddressRecursive = false; // STOP return Account Address Updation from AddressListner.Trigger
            if(addressList.size() > 0){
                insert addressList;
            }
        }
    }
    
    public static Address__c createAddress(Account acc){
            Address__c address = new Address__c();
            address.Account__c = acc.Id;
            if(acc.BillingStreet != null){ 
                String Line1, Line2, Line3, Line4; 
                
                String[] lines = acc.BillingStreet.split('\r\n');
                    Line1 = lines[0];                             
                if (lines.size() > 1){
                    Line2 = lines[1];
                }
                if (lines.size() > 2){
                    Line3 = lines[2];
                }
                if (lines.size() > 3){
                    Line4 = lines[3];
                }
            
                address.Address_line1__c = Line1; 
                if(acc.BillingCountry == 'Brazil')
                address.Brazilian_Neighborhood__c = Line2;
                else
                address.Address_line2__c = Line2;
                address.Address_line3__c = Line3;
                address.Address_line4__c = Line4;
            }else{
                address.Address_line1__c = '';
                address.Address_line2__c = '';
                address.Address_line3__c = '';
                address.Address_line4__c = '';
            }    
            
            address.City__c = acc.BillingCity;
            address.Country__c = acc.BillingCountry;
            address.County__c = acc.County__c;
            address.State__c = acc.BillingState;
            address.Zip__c = acc.BillingPostalCode;
            address.Address_Region__c = acc.Account_Country_Region__c;
            address.Bill_To__c = acc.Bill_To_Flag__c;
            address.Ship_To__c = acc.Ship_To_Flag__c;
            address.Sell_To__c = acc.Sell_ToFlag__c;
            address.End_User__c = acc.End_User_Flag__c;
            address.Installed_at__c =acc.Installed_At_Flag__c;
            address.End_User__c = acc.End_User_Flag__c;
            address.Sell_To__c = True;
            address.Anniversary_Date__c= acc.Annual_Support_Date__c ;
            address.Tax_Reg_Number__c = acc.Tax_Reg_Number__c;
            address.Preferred_Language__c = acc.Preferred_Language__c;
            address.Primary__c = true;
            if(acc.Account_Division__c != NULL && acc.Account_Division__c.contains('TAP'))
            address.POS_Flag__c = True;
            return address;
    }
    
    /*
    *   Method Name :   updateAddressFromBillToAddress
    *   Description :   This is static method. This method used to update Primary Address based on updated Billing Address on Account
    *   Parameter   :   NewMap Accounts, OLDMap Accounts
    *   Return Type :   N/A
    */
    public static void updateAddressFromBillToAddress(Map<Id, Account> newAccounts, Map<Id, Account> OldAccounts){
    String usrProfileName;
    usrProfileName = [select u.Profile.Name from User u where u.id = :Userinfo.getUserId()].Profile.Name; 
        if(launchControl.get('updateAddressFromBillToAddress') < 1){
            launchControl.put('updateAddressFromBillToAddress',launchControl.get('updateAddressFromBillToAddress') + 1);
            // Query Address for update
            Map<Id, Address__c> mapAddress = new Map<Id, Address__c>(); // Here ID -> Account's ID is KEY, because ONE Account should have ONLY ONE Primary Address
            for(Address__c adr : [SELECT
                                                    Id, Name,Brazilian_Neighborhood__c , Address_line1__c, Address_line2__c, Address_line3__c, Address_line4__c, City__c,
                                                    Country__c,Preferred_Language__c,Validation_Status__c,Validation_Status_Code__c,Job_Token__c, County__c, State__c, Zip__c, Account__c
                                                FROM 
                                                    Address__c 
                                                WHERE 
                                                    Primary__c = true AND 
                                                    Account__c IN : newAccounts.keySet()]){
                mapAddress.put(adr.Account__c, adr);
            }
            List<Address__c> lstAddress = new List<Address__c>();
            
            system.Debug('newAccounts.values ----------------->'+newAccounts.values());
            system.Debug('OldAccounts.values ----------------->'+OldAccounts.values());
            for(Account newAcc : newAccounts.values()){
                system.Debug('+++++++'+newAcc.BillingStreet);
                system.Debug('+++++++++++++++++++'+OldAccounts.get(newAcc.Id).BillingStreet);
                if(!usrProfileName.contains(Label.Restrict_Callout_Profile) && newAcc.Name != OldAccounts.get(newAcc.Id).Name ||
                    newAcc.BillingStreet != OldAccounts.get(newAcc.Id).BillingStreet ||
                    newAcc.BillingState != OldAccounts.get(newAcc.Id).BillingState ||
                    newAcc.Preferred_Language__c != OldAccounts.get(newAcc.Id).Preferred_Language__c ||
                    newAcc.BillingPostalCode != OldAccounts.get(newAcc.Id).BillingPostalCode ||
                    newAcc.BillingCountry != OldAccounts.get(newAcc.Id).BillingCountry ||
                    newAcc.BillingCity != OldAccounts.get(newAcc.Id).BillingCity ||
                    newAcc.County__c!= OldAccounts.get(newAcc.Id).County__c || 
                    newAcc.Validation_Status_Code__c != OldAccounts.get(newAcc.Id).Validation_Status_Code__c || 
                    newAcc.Validation_Status__c != OldAccounts.get(newAcc.Id).Validation_Status__c ||
                    newAcc.Job_Token__c != OldAccounts.get(newAcc.Id).Job_Token__c){
                        system.Debug(' ENTRY ------------------------------');
                    // Update updated Address to Primary Address record.
                    if(mapAddress.containsKey(newAcc.Id)){
                        Address__c updateAddress = mapAddress.get(newAcc.Id);
                        
                        if(newAcc.BillingStreet != null){ 
                            String Line1, Line2, Line3, Line4; 
                            
                            String[] lines = newAcc.BillingStreet.split('\r\n');
                                Line1 = lines[0];                             
                            if (lines.size() > 1){
                                Line2 = lines[1];
                            }
                            if (lines.size() > 2){
                                Line3 = lines[2];
                            }
                            if (lines.size() > 3){
                                Line4 = lines[3];
                            }
                        
                            updateAddress.Address_line1__c = Line1; 
                            if(newAcc.BillingCountry == 'Brazil')
                            updateAddress.Brazilian_Neighborhood__c = Line2;
                            else
                            updateAddress.Address_line2__c = Line2;
                            updateAddress.Address_line3__c = Line3;
                            updateAddress.Address_line4__c = Line4;
                        }else{
                            updateAddress.Address_line1__c = '';
                            updateAddress.Address_line2__c = '';
                            updateAddress.Address_line3__c = '';
                            updateAddress.Address_line4__c = '';
                        }    
                        
                        updateAddress.City__c = newAcc.BillingCity;
                        updateAddress.Country__c = newAcc.BillingCountry;
                        updateAddress.County__c = newAcc.County__c;
                        updateAddress.State__c = newAcc.BillingState;
                        updateAddress.Zip__c = newAcc.BillingPostalCode;
                        updateAddress.Name = newAcc.Name;
                        updateAddress.Primary__c = true;
                        updateAddress.Preferred_Language__c = newAcc.Preferred_Language__c;
                        updateAddress.Validation_Status__c = newAcc.Validation_Status__c;
                        system.Debug(updateAddress.Validation_Status_Code__c + 'lstAddress ----------------->'+newAcc.Validation_Status_Code__c);
                        updateAddress.Validation_Status_Code__c = newAcc.Validation_Status_Code__c;
                        system.Debug(updateAddress.Validation_Status_Code__c + 'lstAddress ----------------->'+newAcc.Validation_Status_Code__c);
                        updateAddress.Job_Token__c = newAcc.Job_Token__c;
                        lstAddress.add(updateAddress);
                    }
                    else{
                        // INSERT New Address Record
                        Address__c address = createAddress(newAcc);
                        lstAddress.add(address);
                    }
                } 
            }
            system.Debug('lstAddress ----------------->'+lstAddress);
            if(lstAddress.size() > 0){
                // Update all Addresses
                RecursiveTriggerUtility.isAddressRecursive = false; // STOP return Account Address Updation from AddressListner.Trigger
                 AddressHandler.launchControl.put('resetStatusFlag', 1);
                upsert lstAddress;
            }
        }
    }
}