/*****************************************************************************************
Name    : AccountTrigger 
Desc    : Auto Trigger the approval process when the user creates new Account and the record Type = 'Account (Pending) Record Type'
AND
When the user selects/Enter the Country populate the Region

Modification Log : 
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
Ashfaq Mohammed       5/21/2013          Created
Pardeep Rao            April/2014        Modified. Added Line 385 and commented Line 384
Pardeep Rao           05/15/2014         Modified. added label Enable_update_to_EBS_and_FCH check
Suresh Babu           Oct/26/2015        Modified. added line 333 to 337 to set Primary Address
Sowmya Chamakura      10/26/2015         Modified. Added line 582 to 588 to validate FCH Party ID during account merge.
******************************************************************************************/
trigger AccountTrigger on Account (before insert, before update, after insert, after update,before delete,after delete){
    system.debug('-------newAccount---------' + (trigger.isInsert || trigger.isupdate ? trigger.new : trigger.old));
    if(!LinkAccountController.LinkAccountCall && !ImportDataController.importDataFlag){
    Profile prof = [Select id,Name from Profile where Id = :UserInfo.getProfileId()];
    Map<String, Id> recordTypeMap = RecursiveTriggerUtility.loadRecordTypeMap(Account.SObjectType);
    List<MEPEuropeSalesRegion_del_del__c> listCodes = new List<MEPEuropeSalesRegion_del_del__c>();
    listCodes = MEPEuropeSalesRegion_del_del__c.getAll().values();
    List<Paris_Region_Mapping__c> franceCodes = new List<Paris_Region_Mapping__c>();
    franceCodes = Paris_Region_Mapping__c.getAll().values();
    
    List<User>  userList = new List<User>();
    userList = [select Id, MEP_Europe_Sales_Region__c from User where Id =: UserInfo.getUserID()];
    if(Trigger.isBefore && RecursiveTriggerUtility.isAccountRecursive && !Trigger.isDelete){               
        //validation for account records, if Country is not properly matched with Country Region Mapping custom setting, then it will throw error.    
        for (Account acc : trigger.new){
            try{                  
                if(acc.BillingCountry != null){    
                    String Country = acc.BillingCountry;
                    if(country == Label.Democratic_Republic_Lao_People){
                        acc.Region__c = Label.ASEAN;  
                        acc.Geospatial_Region__c = Label.APAC;
                    }else{
                    
                     List<Country_Region_Mapping__c> Lrm = new List<Country_Region_Mapping__c>();  
            Map<String,Country_Region_Mapping__c>CountryMap1 = new Map<String,Country_Region_Mapping__c>();               
                Lrm = Country_Region_Mapping__c.getall().values();
                for(Country_Region_Mapping__c crm : Lrm)
                {
                 CountryMap1.put(crm.Name.touppercase(),crm);
                }
              
              List<Geospatial_Country_Region_Mapping__c> grm = new List<Geospatial_Country_Region_Mapping__c>();  
            Map<String,String>GeoCountryMap1 = new Map<String,String>();               
                grm = Geospatial_Country_Region_Mapping__c.getall().values();
                for(Geospatial_Country_Region_Mapping__c crm : grm)
                {
                 GeoCountryMap1.put(crm.Name.touppercase(),crm.Region__c);
                }
                      /*  Country_Region_Mapping__c countryMap = Country_Region_Mapping__c.getInstance(Country);
                        Geospatial_Country_Region_Mapping__c geoCountryMap = Geospatial_Country_Region_Mapping__c.getInstance(Country);*/
                        
                      if(CountryMap1.get(Country.touppercase())!=Null)
                      {
                       
                       acc.Region__c = CountryMap1.get(Country.touppercase()).Region__c;
                       //if(prof.Name.contains('TAP'))
                       acc.Tap_Region__c = CountryMap1.get(Country.touppercase()).TAP_Region__c;
                       if(geoCountryMap1.get(Country.touppercase())!=Null)
                       {
                       acc.Geospatial_Region__c = geoCountryMap1.get(Country.touppercase()); 
                       }
                       else
                       {
                        acc.addError(Label.Validate_Country_Name);
                       }
                      }
                      else
                      {
                      acc.addError(Label.Validate_Country_Name);
                      }
                        
                       /* if(countryMap != null){
                            acc.Region__c = countryMap.Region__c;
                            if(geoCountryMap != null){
                                acc.Geospatial_Region__c = geoCountryMap.Region__c; 
                            }else{
                                acc.addError(Label.Validate_Country_Name);
                            }                  
                        }else{
                            acc.addError(Label.Validate_Country_Name);
                        }*/
                    }   
                }
                
                /*
* REQ-00202
* Account Pending record type to be updated to Account Association Record Type.          
*/
                if(Trigger.isUpdate){         
                    //get the old account image to compare values with new record instance                
                    Account oldAccount = System.Trigger.oldMap.get(acc.Id);                                  
                    if(acc.Requested_Account_Record_Type__c == Label.Association && oldAccount.Requested_Account_Record_Type__c == Label.Association && 
                       oldAccount.Account_Status__c != Label.Active && acc.Account_Status__c == Label.Active){
                           acc.RecordTypeId = recordTypeMap.get(Label.Account_Association_Record_Type);
                       }               
                }
                
                /*
* ITEM-00810
* Populate MEP Europe Sales Region from Custom setting based on the country specified by user.          
*/                         
                if(acc.BillingCountry != null){
                    String MEDregion;
                    boolean franceZipFlag = true;
                    if(acc.BillingCountry == 'France' && acc.BillingPostalCode != null && acc.BillingPostalCode.length() >= 2 && acc.BillingPostalCode.substring(0, 2) == '75'){
                        franceZipFlag = false;
                    }
                    if(franceZipFlag){
                        for(MEPEuropeSalesRegion_del_del__c mep : listCodes){                   
                            if(mep.Country__c == acc.BillingCountry){
                                acc.MED_Europe_Sales_Region__c = mep.MEP_Europe_Sales_Region__c;
                                if(mep.Zip__c != null && acc.BillingPostalCode != null){
                                    if((acc.BillingCountry == 'France' || acc.BillingCountry == 'Germany') && acc.BillingPostalCode != null && acc.BillingPostalCode.length() >= 2){
                                        String code = acc.BillingPostalCode.substring(0, 2);
                                        if(mep.Zip__c.contains(code)){
                                            acc.MED_Europe_Sales_Region__c = mep.MEP_Europe_Sales_Region__c;                                
                                            break;
                                        }else{
                                            acc.MED_Europe_Sales_Region__c = '';
                                        }
                                    }else{
                                        if(mep.Zip__c.contains(acc.BillingPostalCode)){
                                            acc.MED_Europe_Sales_Region__c = mep.MEP_Europe_Sales_Region__c;                                
                                            break;
                                        }else{
                                            acc.MED_Europe_Sales_Region__c = '';
                                        }
                                    }    
                                }else{
                                    break;  
                                }
                            }else{
                                acc.MED_Europe_Sales_Region__c = '';
                                acc.User_Account_Region_Match__c = false;
                            }
                        }
                    }else{
                        for(Paris_Region_Mapping__c code : franceCodes){
                            if(code.Country__c == acc.BillingCountry){                             
                                if(code.Zip_Postal_Code__c != null && acc.BillingPostalCode != null){
                                    if(code.Zip_Postal_Code__c.contains(acc.BillingPostalCode)){
                                        acc.MED_Europe_Sales_Region__c = code.MEP_Europe_Sales_Region__c;                                
                                        break;
                                    }
                                }else{
                                    break;  
                                }
                            }else{
                                acc.MED_Europe_Sales_Region__c = '';
                                acc.User_Account_Region_Match__c = false;
                            }
                        } 
                        
                    } 
                }
                
                /*
                * ITEM-00823
                * Account Region Report - Set Is_Account_User_Region_Match__c to TRUE when the 
                * Account's MED_Europe_Sales_Region__c field and the User's MEP_Europe_Sales_Region__c field is matching.          
                */
                
                if(userList.size() > 0 && acc.MED_Europe_Sales_Region__c != '' && acc.MED_Europe_Sales_Region__c != null  
                   && userList.get(0).MEP_Europe_Sales_Region__c!=null && userList.get(0).MEP_Europe_Sales_Region__c!=''){             
                       if( userList.get(0).MEP_Europe_Sales_Region__c.contains(acc.MED_Europe_Sales_Region__c)){
                           acc.User_Account_Region_Match__c = true;
                       }  
                   }else{
                       if(acc.User_Account_Region_Match__c){
                           acc.User_Account_Region_Match__c = false;
                       }
                   }                  
            }catch(Exception e){
                acc.addError(e.getMessage());
                system.debug('exception e==='+e);
                system.debug('exception e==='+e.getStackTraceString());
            } 
        }      
    }
    system.debug('-------newAccount---------' + (trigger.isInsert || trigger.isupdate ? trigger.new : trigger.old));
    if(Trigger.isAfter && Trigger.isInsert && RecursiveTriggerUtility.isAccountRecursive){
        //Added by Sowmya for Account Sales Territory logic.
        
        AccountCreationCalloutEX.recursiveCallFlag = true;
        User usrProfileName = [select u.Profile.Name from User u where u.id = :Userinfo.getUserId()];
        if(usrProfileName.Profile.Name != Label.API_Only) AccountHelper.CreateAddressRdFromBillToAddress(trigger.new);
        
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest> ();
        List<ProcessInstance> processInstances = new List<ProcessInstance>();
        Set<Id> accountIdSet = new Set<Id>();
        //variables for cmdm
        set<string> accountnamesset = new set<string>();
        map<string,string> FCRmap = new map<string,string>();
        //end of variables for cmdm
        Set<Id> ownerIdSet = new Set<Id>();
        try{
            processInstances = [select Id, Status, TargetObjectId from ProcessInstance where  Status =: Label.Pending and TargetObjectId IN : Trigger.newMap.keySet()];
            Set<String> targetObjectSet = new Set<String>();
            for(ProcessInstance instance : processInstances){
                targetObjectSet.add(instance.TargetObjectId);
            }
            List<Id> accntLst = new List<Id>();
            for(Account a :trigger.new)
            {
                accntLst.add(a.Id);
            }     
            
            Map<Id,Lead> leadMap= new Map<Id,Lead>();
            for(Lead le : [Select Id, isConverted,ConvertedAccountId from Lead where ConvertedAccountId In: accntLst ])
            {
                if(le.isConverted == true)
                    leadMap.put(le.ConvertedAccountId, le);
                
            }
            //&& !leadMap.containskey(acc.Id)
            
            for (Account acc : trigger.new){
                   if (trigger.isAfter && Trigger.isInsert && acc.RecordTypeId == recordTypeMap.get(Label.Account_Pending_Record_Type) && acc.Account_Status__c == Label.Pending && acc.Record_Lock__c == TRUE && !targetObjectSet.contains(acc.Id)){
               
            //if (trigger.isAfter && Trigger.isInsert  && (acc.RecordTypeId == recordTypeMap.get(Label.Account_Pending_Record_Type) || acc.RecordTypeId == recordTypeMap.get(Label.Account_Pending_Association_Record_Type) || acc.RecordTypeId == recordTypeMap.get(Label.Account_Pending_Competitor_Record_Type) || acc.RecordTypeId == recordTypeMap.get(Label.Account_Pending_Partner_Record_Type)) && acc.Account_Status__c == Label.Pending && acc.Record_Lock__c == TRUE && !targetObjectSet.contains(acc.Id)){
                    // create the new approval request to submit
                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                    req.setComments(Label.Submitted_Approval_Message);
                    req.setObjectId(acc.ID);
                    requests.add(req);
                }
                accountIdSet.add(acc.Id);
                ownerIdSet.add(acc.LastModifiedById);
            }
            
            
            // submit the approval request for processing
            if(requests.size() > 0)Approval.ProcessResult[] result = Approval.process(requests);
            
            /*
* ITEM-00804
* Street Address Split to 4 Fields.          
*/                
            
            List<Profile> prfList = new List<Profile>();
            prfList = [Select Id from Profile where Name =: Label.API_Only];
            List<Account> updatedAccountList = new List<Account>();
            Map<Id, User> uMap = new Map<Id, User>();
            uMap = new Map<Id, User>([Select Id, ProfileId from User where Id IN: ownerIdSet]);
            
            List<Account> accList = new List<Account>();
            accList = [Select Id, RecordTypeId, Address1__c, Address2__c, Address3__c, Address4__c, BillingStreet, LastModifiedById from Account where Id IN: accountIdSet];                
            
            for(Account acc : accList){ 
                
                if(acc.RecordTypeId != recordTypeMap.get(Label.Account_Pending_Record_Type)){
                    
                    if(prfList != null && prfList.size() > 0 && uMap.get(acc.LastModifiedById).ProfileId == prfList.get(0).Id){ 
                        if(acc.Address1__c != null || acc.Address2__c != null || acc.Address3__c != null || acc.Address4__c != null){           
                            /*
* ITEM-00845
* Copy street address values from custom address 1-4 fields to Billing street field.          
*/
                            String additionaldesc ='';
                            
                            if(acc.Address1__c != null){                 
                                additionaldesc = acc.Address1__c+'\r\n';
                            }
                            if(acc.Address2__c != null ){
                                if(additionaldesc != ''){
                                    additionaldesc += acc.Address2__c+'\r\n';
                                }else{
                                    additionaldesc = acc.Address2__c+'\r\n';
                                }   
                            }
                            if(acc.Address3__c !=null ){
                                if(additionaldesc != ''){ 
                                    additionaldesc += acc.Address3__c+'\r\n';
                                }else{
                                    additionaldesc = acc.Address3__c+'\r\n';
                                }  
                            }
                            if(acc.Address4__c !=null ){
                                if(additionaldesc != ''){ 
                                    additionaldesc += acc.Address4__c;
                                }else{
                                    additionaldesc = acc.Address4__c;
                                }  
                            }
                            if(additionaldesc != '')
                                acc.BillingStreet = additionaldesc;                                  
                        }             
                    }else{
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
                            
                            acc.Address1__c = Line1; 
                            acc.Address2__c = Line2;
                            acc.Address3__c = Line3;
                            acc.Address4__c = Line4;
                        }else{
                            acc.Address1__c = ''; 
                            acc.Address2__c = '';
                            acc.Address3__c = '';
                            acc.Address4__c = '';
                        }
                    }
                    updatedAccountList.add(acc);
                }
            }

            if(updatedAccountList.size() > 0){  
                RecursiveTriggerUtility.isAccountRecursive = false;        
                update updatedAccountList;
            } 
            
            
            if(!prof.Name.contains(Label.Restrict_Callout_Profile)){
                List<Id> tempList = new List<Id>();
                tempList.addAll(trigger.newmap.keySet());
                system.debug('-------------AccountInsert--------------');
                if(Trigger.IsInsert && tempList.size()==1 && trigger.new.get(0).Lifecycle_Stage__c!=null && 
                   (trigger.new.get(0).Lifecycle_Stage__c=='Customer' || trigger.new.get(0).Lifecycle_Stage__c=='Qualified Prospect') &&
                   trigger.new.get(0).Account_Status__c == 'Active'&& !(trigger.new.get(0).Disable_Callout__c && Label.Disable_FCH_Callout.contains(UserInfo.getName()))){
                       system.debug('-------------AccountInsert--------------');
                       List<Address__c> addList = [select Id from Address__c where Account__c =: tempList.get(0)];
                       if(addList.size() == 1){
                            set<String> addIds = new set<String>();
                          addIds.add(addList.get(0).Id);
                           AccountCreationCalloutEX.CallEBS(tempList,'Create','NoOp','Create',new Set<String>(),addIds,new Set<String>());
                       }else
                           AccountCreationCalloutEX.CallEBS(tempList,'Create','NoOp','Create',new Set<String>(),new Set<String>(),new Set<String>());
                   }
            }      
            
            
        }catch(Exception e){
            System.debug(e.getMessage());
        }   
        RecursiveTriggerUtility.isAccountRecursive = false;
    }       
    System.debug('RecursiveTriggerUtility.isAccountRecursive: '+RecursiveTriggerUtility.isAccountRecursive);    
    //to update the currency code for forecast year , forecaset quarter and forecast week based on Account
        system.debug('-------newAccount---------' + (trigger.isInsert || trigger.isupdate ? trigger.new : trigger.old));
    if(Trigger.isAfter && Trigger.isUpdate && RecursiveTriggerUtility.isAccountRecursive){
        try{
            if(!prof.Name.contains(Label.Restrict_Callout_Profile)){
                List<Id> tempList = new List<Id>();
                set<Id> validIds = new set<ID>();
                validIds = Utils.verifyFieldUpdate(Trigger.newMap,Trigger.oldMap,'Account','FCH Integration','FCHAccount');
                tempList.addAll(validIds );
                if((Trigger.IsUpdate && tempList.size()==1 && trigger.new.get(0).Lifecycle_Stage__c!=null && 
                    (trigger.new.get(0).Lifecycle_Stage__c=='Customer' || trigger.new.get(0).Lifecycle_Stage__c=='Qualified Prospect') && 
                        trigger.new.get(0).Account_Status__c == 'Active' && trigger.new.get(0).MasterRecordID==Null) && !AccountCreationCalloutEX.dLinkAccountFlag && 
                        (trigger.isUpdate ? AccountHelper.validateAccountExternalKeyValue(trigger.new, trigger.oldMap) : true) &&
                         !(trigger.new.get(0).Disable_Callout__c && Label.Disable_FCH_Callout.contains(UserInfo.getName()))){
                                
                   AccountCreationCalloutEX.CallEBS(tempList,'Update','NoOp','NoOp',new Set<String>(),new Set<String>(),new Set<String>());
               }
            }
            System.debug('----------'+Trigger.oldMap);
            
            
            /**
            * Update Primary Address of Account based on updated Account's Billing Address
            **/
            system.debug(' RecursiveTriggerUtility.isAddressRecursive --------------->>>>>'+RecursiveTriggerUtility.isAddressRecursive);
            if(RecursiveTriggerUtility.isAddressRecursive)
                AccountHelper.updateAddressFromBillToAddress(trigger.newMap, trigger.oldMap);
            /***********/
            
            
            Set<Id> accountIdSet = new Set<Id>();
            Set<Id> forecastAccountIdSet = new Set<Id>();
            List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest> ();
            List<ProcessInstance> processInstances = new List<ProcessInstance>();     
            //TO submit for Approval Process - Added by Sunay R K, 06.02.2014 03:06PM
            processInstances = [select Id, Status, TargetObjectId from ProcessInstance where  Status =: Label.Pending and TargetObjectId IN : Trigger.newMap.keySet()];
            Set<String> targetObjectSet = new Set<String>();
            for(ProcessInstance instance : processInstances){
                targetObjectSet.add(instance.TargetObjectId);
            }
            Set<Id> ownerIdSet = new Set<Id>();
            for(Account acc : trigger.new){  
                Account oldAccount = Trigger.oldMap.get(acc.Id);
                System.debug(acc.Account_Status__c + '-----------------' + Label.Pending + '------acc.Account_Status__c----'+ (acc.Account_Status__c == Label.Pending));
                System.debug(targetObjectSet + '------recordLock----'+acc.Record_Lock__c);
                System.debug(Label.Account_Pending_Record_Type + '------recordLock----' + recordTypeMap.get(Label.Account_Pending_Record_Type));
                if(trigger.isAfter && Trigger.isUpdate && acc.RecordTypeId == recordTypeMap.get(Label.Account_Pending_Record_Type) 
                   && acc.Account_Status__c == Label.Pending && acc.Record_Lock__c == TRUE && !targetObjectSet.contains(acc.Id)){
                       // create the new approval request to submit
                       Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                       req.setComments(Label.Submitted_Approval_Message);
                       req.setObjectId(acc.ID);
                       requests.add(req);
                   }                  
                accountIdSet.add(acc.Id);
                ownerIdSet.add(acc.LastModifiedById);
                if(oldAccount.CurrencyIsoCode != acc.CurrencyIsoCode)
                    forecastAccountIdSet.add(acc.Id);
            }
            
            // submit the approval request for processing
            if(requests.size() > 0)Approval.ProcessResult[] result = Approval.process(requests);
            
            /*
            * ITEM-00845
            * Copy street address values from custom address 1-4 fields to Billing street field.          
            */
            
            List<Profile> prfList = new List<Profile>();
            prfList = [Select Id from Profile where Name =: Label.API_Only];
            List<Account> updatedAccountList = new List<Account>();
            Map<Id, User> uMap = new Map<Id, User>();
            uMap = new Map<Id, User>([Select Id, ProfileId from User where Id IN: ownerIdSet]);
            
            List<Account> accList = new List<Account>();
            accList = [Select Id, RecordTypeId, Address1__c, Address2__c, Address3__c, Address4__c, BillingStreet, LastModifiedById from Account where Id IN: accountIdSet];                
            
            for(Account acc : accList){ 
                if(prfList != null && prfList.size() > 0 && uMap.get(acc.LastModifiedById).ProfileId == prfList.get(0).Id){ 
                    if(acc.Address1__c != null || acc.Address2__c != null || acc.Address3__c != null || acc.Address4__c != null){           
                        
                        String additionaldesc ='';
                        
                        if(acc.Address1__c != null){                 
                            additionaldesc = acc.Address1__c+'\r\n';
                        }
                        if(acc.Address2__c != null ){
                            if(additionaldesc != ''){
                                additionaldesc += acc.Address2__c+'\r\n';
                            }else{
                                additionaldesc = acc.Address2__c+'\r\n';
                            }   
                        }
                        if(acc.Address3__c !=null ){
                            if(additionaldesc != ''){ 
                                additionaldesc += acc.Address3__c+'\r\n';
                            }else{
                                additionaldesc = acc.Address3__c+'\r\n';
                            }  
                        }
                        if(acc.Address4__c !=null ){
                            if(additionaldesc != ''){ 
                                additionaldesc += acc.Address4__c;
                            }else{
                                additionaldesc = acc.Address4__c;
                            }  
                        }
                        if(additionaldesc != '')
                            acc.BillingStreet = additionaldesc;    
                        System.debug('acc.BillingStreet'+acc.BillingStreet);                              
                    }             
                }else{
                    if(acc.BillingStreet != null){ 
                        String Line1, Line2, Line3, Line4;
                        //String[] lines = acc.BillingStreet.split('\r\n');                             
                        String[] lines = acc.BillingStreet.split('\n');
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
                        
                        acc.Address1__c = Line1; 
                        acc.Address2__c = Line2;
                        acc.Address3__c = Line3;
                        acc.Address4__c = Line4;
                    }else{
                        acc.Address1__c = ''; 
                        acc.Address2__c = '';
                        acc.Address3__c = '';
                        acc.Address4__c = '';
                    }
                }
                updatedAccountList.add(acc);
            }  
            
            List<Forecast_Year__c> fyearListUpdate = new List<Forecast_Year__c>();
            List<Forecast_Year__c> fyearList = new List<Forecast_Year__c>();
            fyearList = [Select id, Account__c, CurrencyIsoCode from Forecast_Year__c where Account__c IN: forecastAccountIdSet];
            if(fyearList.size() > 0){
                Set<ID> fyID = new Set<ID>();                    
                //query account records pertaining to the related account Ids
                Map<Id, Account> accMap = new Map<Id, Account>();
                accMap = new Map<Id, Account>([Select Id, CurrencyIsoCode from Account where Id IN: forecastAccountIdSet]);                   
                for (Forecast_Year__c fy : fyearList){
                    fyID.add(fy.id);
                }
                
                //iterate over the new records to update the CurrencyIsocode of the record with that of related account record
                if(fyearList.size()>0){
                    for(Forecast_Year__c fyUpdate : fyearList){
                        if(accMap.containsKey(fyUpdate.Account__c)){
                            fyUpdate.CurrencyIsoCode = accMap.get(fyUpdate.Account__c).CurrencyIsoCode;
                            fyearListUpdate.add(fyUpdate);
                        }                 
                    }
                    update fyearListUpdate;
                }
                
                List<Forecast_Qua__c> fquarterListUpdate = new List<Forecast_Qua__c>(); 
                List<Forecast_Qua__c> fquarterList = new List<Forecast_Qua__c>();
                
                //query forecast quarter record related to the forecast year
                fquarterList = [Select id, Forecast_Year__c, Forecast_Year__r.Account__c, CurrencyIsoCode from Forecast_Qua__c where Forecast_Year__c IN:fyID];
                Set<ID> fqID = new set<ID>();
                for(Forecast_Qua__c fq : fquarterList){
                    fqID.add(fq.id);
                }
                
                //iterate over the new records to update the CurrencyIsocode of the record with that of related account record
                if(fquarterList.size()>0){
                    for(Forecast_Qua__c fqUpdate : fquarterList){
                        if(accMap.containsKey(fqUpdate.Forecast_Year__r.Account__c)){
                            fqUpdate.CurrencyIsoCode = accMap.get(fqUpdate.Forecast_Year__r.Account__c).CurrencyIsoCode;
                            fquarterListUpdate.add(fqUpdate);                               
                        }
                    }
                    if(fquarterListUpdate.size() > 0)
                        update fquarterListUpdate;
                }
                
                List<Forecast_Week__c> fWeekListUpdate = new List<Forecast_Week__c>();
                List<Forecast_Week__c> fWeekList = new List<Forecast_Week__c>();
                
                fWeekList = [Select id, Forecast_Quarter__c, Forecast_Quarter__r.Forecast_Year__r.Account__c, CurrencyIsoCode from Forecast_Week__c where Forecast_Quarter__c IN :fqID];
                Set<ID> fwID = new set<ID>();
                for(Forecast_Week__c fw : fWeekList){
                    fwID.add(fw.id);
                }
                //iterate over the new records to update the CurrencyIsocode of the record with that of related account record
                if(fWeekList.size() > 0){
                    for(Forecast_Week__c fwUpdate : fWeekList){
                        if(accMap.containsKey(fwUpdate.Forecast_Quarter__r.Forecast_Year__r.Account__c)){
                            fwUpdate.CurrencyIsoCode = accMap.get(fwUpdate.Forecast_Quarter__r.Forecast_Year__r.Account__c).CurrencyIsoCode;
                            fWeekListUpdate.add(fwUpdate);
                        }
                    }
                    if(fWeekListUpdate.size() > 0)
                        update fWeekListUpdate;
                }
            }
            if(updatedAccountList.size() > 0){  
                RecursiveTriggerUtility.isAccountRecursive = false;        
                update updatedAccountList;
            }                                              
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    } 
    System.debug('----------Before Delete-----');
    if(Trigger.IsDelete && RecursiveTriggerUtility.isAccountRecursive && trigger.isBefore && trigger.old.size()==1 && trigger.old.get(0).Lifecycle_Stage__c!=null && 
       (trigger.old.get(0).Lifecycle_Stage__c=='Customer' || trigger.old.get(0).Lifecycle_Stage__c=='Qualified Prospect') &&
       trigger.old.get(0).Account_Status__c == 'Active'){
           System.debug('----------Trigger.old.get(0).MasterRecordID-----'+Trigger.old.get(0).MasterRecordID);
           AccountHelper.getRelatedRecords(trigger.old.get(0));
           delete [select id from Credit_Details_Tab_Customer_Account__c where Account__c in: trigger.oldMap.keySet()];
           
       }  
    system.debug('-------newAccount---------' + (trigger.isInsert || trigger.isupdate ? trigger.new : trigger.old));
    if(Trigger.IsDelete){
        delete [select id from Credit_Details_Tab_Customer_Account__c where Account__c in: trigger.oldMap.keySet()];
    }
    System.debug('----------After Delete-----');
    
    if(Trigger.IsDelete && RecursiveTriggerUtility.isAccountRecursive && trigger.isAfter && 
       Trigger.old.get(0).MasterRecordID !=  null){   
           System.debug('----------Trigger.old.get(0).MasterRecordID-----'+Trigger.old.get(0).MasterRecordID);
           Account a = [Select FCH_Party_ID__c,Enterprise_Party_Number__c,COLLECTOR_Name__c,COLLECTOR_Email__c,EBS_Payment_Term__c from Account where id =: Trigger.old.get(0).MasterRecordID];          
            if((a.FCH_Party_ID__c == '' || a.FCH_Party_ID__c == null) && Trigger.old.get(0).FCH_Party_ID__c != '' && Trigger.old.get(0).FCH_Party_ID__c != null){
               Trigger.old.get(0).addError('Please select the record with FCH Party ID as the Master Record.');
                AccountHelper.mergeCalloutFlag = false;
           }
           if((a.Enterprise_Party_Number__c == '' || a.Enterprise_Party_Number__c == null) && Trigger.old.get(0).Enterprise_Party_Number__c != '' && Trigger.old.get(0).Enterprise_Party_Number__c != null){
               Trigger.old.get(0).addError('Please select the record with Enterprise Master ID as the Master Record.');
                AccountHelper.mergeCalloutFlag = false;
           }
    }
    System.debug('----------mergeCalloutFlag-----' + AccountHelper.mergeCalloutFlag);
    system.debug('-------newAccount---------' + (trigger.isInsert || trigger.isupdate ? trigger.new : trigger.old));
    if(Trigger.IsDelete && RecursiveTriggerUtility.isAccountRecursive && trigger.isAfter && trigger.old.size()==1 && ((trigger.old.get(0).Lifecycle_Stage__c!=null && 
       (trigger.old.get(0).Lifecycle_Stage__c=='Customer' || trigger.old.get(0).Lifecycle_Stage__c=='Qualified Prospect') &&
       trigger.old.get(0).Account_Status__c == 'Active') || trigger.old.get(0).MasterRecordID != null)){
            RecursiveTriggerUtility.isAccountRecursive = false;
           AccountCreationCalloutEX.recursiveCallFlag = true;
           if(trigger.old.get(0).MasterRecordID != null)RecursiveTriggerUtility.isAccountMergeRecursive = true;
           AccountHelper.getmergeData(trigger.old);
           system.debug('------------deletedAcc--------' + AccountHelper.deletedAcc);
           system.debug('------------deletedAdd--------' + AccountHelper.deletedAdd);
           system.debug('------------deletedCon--------' + AccountHelper.deletedCon);
           AddressHandler.launchControl.put('configOutboundMessage',1);
           ContactHandler.launchControl.put('configOutboundMessage',1);
           if(trigger.old.get(0).FCH_Party_ID__c!=Null  && !(trigger.old.get(0).Disable_Callout__c && Label.Disable_FCH_Callout.contains(UserInfo.getName())))
                AccountCreationCalloutEX.CallEBS(AccountHelper.deletedAcc,'Delete','Delete','Delete',AccountHelper.deletedCon,AccountHelper.deletedAdd,new set<String>());
            
           if(trigger.old.get(0).MasterRecordID != null && AccountHelper.mergeCalloutFlag){
               Account acc = [select Id,Disable_Callout__c,FCH_Party_ID__c,Lifecycle_Stage__c,Account_Status__c from Account where Id =: trigger.old.get(0).MasterRecordID];
               if((!acc.Disable_Callout__c && Label.Disable_FCH_Callout.contains(UserInfo.getName())) && acc.FCH_Party_ID__c != null && acc.FCH_Party_ID__c != '' && acc.Account_Status__c == 'Active' && (acc.Lifecycle_Stage__c == 'Qualified Prospect' || acc.Lifecycle_Stage__c == 'Customer')){
                   system.debug('-Integration Test-----' + AccountHelper.deletedAcc);
                   system.debug('------------deletedAdd--------' + AccountHelper.relatedAdd);
                   system.debug('------------deletedCon--------' + AccountHelper.relatedCon);
                   system.debug('------------masterRecordIds--------' + AccountHelper.masterRecordIds);
                   scheduleBatchSync temp = new scheduleBatchSync();
                   temp.deletedAdd = AccountHelper.relatedAdd;
                   temp.deletedCon = AccountHelper.relatedCon;
                   temp.masterRecordIds.addAll(AccountHelper.masterRecordIds);
                   Datetime dttime = system.now();
                   dttime = dttime.addMinutes(1);
                   String cronString = '0 ' + dttime.minute() + ' ' + dttime.hour() + ' ' + dttime.day() + ' ' + dttime.month() + ' ? ' + dttime.year();
                   system.schedule('Acc Merge Call' + String.valueOf(dttime), cronString, temp);
               }
           }
       } 
    }
}  //original