/*****************************************************************************************
    Name    : CreateAccountOrParty 
    Desc    : Used to create accounts in Salesforce from the data returend from the customer data hub
                            
Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Vikram Mandla       12/11/2013          Created
Vikram Mandla       28/01/2014          Modified
******************************************************************************************/
global class CreateAccountOrParty {
   
     /*
     * Method name  : CreateParty
     * Description  : Webserice method to load Account data from Oracle EBS to SFDC standard object Account and create Account data
     * Return Type  : list<ResponseWraperClass>
     * Parameter    : requesrwrapervar
     */
    
    webService static list<ResponseWrpaerClass> CreateParty(list<RequestWrpaerClass> requesrwrapervar) 
    {
        list<account> accountlist = new list<account>();
        ResponseWrpaerClass respvar ;
        Database.UpsertResult[] srList;
        list<ResponseWrpaerClass> responselist = new list<ResponseWrpaerClass>();
        
        map<string,account> accountmap = new map<string,account>();
        map<string,account> newaccountmap = new map<string,account>();
        map<string,user> usermap = new map<string,user>();
        set<string> accountset = new set<string>();
        set<string> owneremailset = new set<string>();
        set<string> enterprisemasteridset = new set<string>();
        List<Account> multipleAccountList = new List<Account>();
        //Iterate over the request data and validate the values sent and also add them into sets
        for(RequestWrpaerClass  reqvar : requesrwrapervar)
        {
            //accountset.add(reqvar.Party_originalsystemParent);
            accountset.add(reqvar.EnterpriseParentID);
            if(reqvar.AccountOwnerEmail != NULL && reqvar.AccountOwnerEmail !='')
                owneremailset.add(reqvar.AccountOwnerEmail);
            if(reqvar.EnterpriseMasterID != NULL && reqvar.EnterpriseMasterID != '')
                enterprisemasteridset.add(reqvar.EnterpriseMasterID);
        }
        
        for(Account acc : [select id,Name,Enterprise_Party_Number__c from account where Enterprise_Party_Number__c in :accountset ])
        {
            accountmap.put(acc.Enterprise_Party_Number__c,acc);
        }
        
        for(Account acc : [select id,Name,Enterprise_Party_Number__c from account where Enterprise_Party_Number__c in :enterprisemasteridset ])
        {
            newaccountmap.put(acc.Enterprise_Party_Number__c,acc);
            //multipleAccountList.add(acc);
        }
        
        for(RequestWrpaerClass  reqvar : requesrwrapervar)
        {
            if(reqvar.AccountOwnerEmail != NULL && reqvar.AccountOwnerEmail !='')
                owneremailset.add(reqvar.AccountOwnerEmail);
        }
        
        
        for(User u:[Select id,Name,Email,IsActive from User where IsActive = TRUE AND Email IN:owneremailset]){
            usermap.put(u.Email,u);
        }
        
        try{
            //Iterate over the data received from Oracle for creating the Account records
           for(RequestWrpaerClass  reqvar : requesrwrapervar)
            {      
                    respvar = new ResponseWrpaerClass(); 
                    
                    if((reqvar.CustomerName == '' || reqvar.CustomerName == null) || (reqvar.Country == '' || reqvar.Country == null) || (reqvar.Address1 == '' || reqvar.Address1 == null))
                    {                          
                           respvar.result  =  'Failure';
                           respvar.ErrorCode = 'CMDM-ERR-01';
                           respvar.ErrorMessage = 'One of the required fields is null. Please check the data';
                           responselist.add(respvar);     
                    }
                    //else if(reqvar.EnterpriseMasterID != NULL && reqvar.EnterpriseMasterID != '' && !multipleAccountList.isEmpty() && multipleAccountList.size()>0){
                    else if(reqvar.EnterpriseMasterID != NULL && reqvar.EnterpriseMasterID != '' && newaccountmap != null && newaccountmap.get(reqvar.EnterpriseMasterID) != null){
                        Account acc = new Account();
                        acc = newaccountmap.get(reqvar.EnterpriseMasterID);
                        accountlist.add(acc); 
                        //accountlist = multipleAccountList;
                    }
                    else{                                    
                    Account accvar = new Account();
                    //accvar.name =  reqvar.CustomerName;
                    //accvar.Customer_Name__c =  reqvar.CustomerName;
                    /*if(reqvar.CustomerName != NULL && reqvar.CustomerName !=''){
                        String[] cName = reqvar.CustomerName.split('-');
                        accvar.Name = cName[0];
                    }    */
                    accvar.name =  reqvar.CustomerName;
                    //accvar.type = reqvar.LifecycleStage;
                    if(reqvar.LifecycleStage != NULL && reqvar.LifecycleStage !='')
                        accvar.Lifecycle_Stage__c = reqvar.LifecycleStage;
                    if(reqvar.CustomerLevel != NULL && reqvar.CustomerLevel !='')
                        accvar.sub_type__c = reqvar.CustomerLevel;
                    if(reqvar.PrimaryRegion != NULL && reqvar.PrimaryRegion !='')
                        accvar.Region__c = reqvar.PrimaryRegion;
                    if(reqvar.SelltoFlag!=null && reqvar.SelltoFlag!='' && (reqvar.SelltoFlag == 'Yes' || reqvar.SelltoFlag == 'yes'))                    
                        accvar.Sell_ToFlag__c = true;
                    else
                    if(reqvar.SelltoFlag!=null && reqvar.SelltoFlag!='' && (reqvar.SelltoFlag == 'No' || reqvar.SelltoFlag == 'no')&&
                       reqvar.BilltoFlag!=null && reqvar.BilltoFlag!='' && (reqvar.BilltoFlag == 'No' || reqvar.BilltoFlag == 'no')&&
                       reqvar.ShiptoFlag!=null && reqvar.ShiptoFlag!='' && (reqvar.ShiptoFlag == 'No' || reqvar.ShiptoFlag == 'no'))
                        accvar.Sell_ToFlag__c = true;         
                    else
                        accvar.Sell_ToFlag__c = false;         
                   
                    //accvar.Email_Domain__c = reqvar.PrimaryEmailAddress;
                    if(reqvar.PrimaryEmailAddress != NULL && reqvar.PrimaryEmailAddress !='')
                        accvar.Email__c = reqvar.PrimaryEmailAddress;
                    if(reqvar.EnterpriseMasterID != NULL && reqvar.EnterpriseMasterID !='')
                        accvar.FCH_Party_Id__c = reqvar.EnterpriseMasterID; 
                                     
                    
                    if(reqvar.AddressValidated!=null && reqvar.AddressValidated!='' && (reqvar.AddressValidated== 'Yes' || reqvar.AddressValidated== 'yes'))                    
                    accvar.AddressValidated__c = true;
                    else
                    accvar.AddressValidated__c = false;  
                    if(accvar.AddressValidated__c == true)
                        accvar.Account_Status__c = 'Active'; 
                    if(reqvar.Address1 != NULL && reqvar.Address1 !='') 
                        accvar.Address1__c = reqvar.Address1;
                    if(reqvar.Address2 != NULL && reqvar.Address2 !='')
                        accvar.Address2__c = reqvar.Address2;
                    if(reqvar.Address3 != NULL && reqvar.Address3 !='')
                        accvar.Address3__c = reqvar.Address3;
                    if(reqvar.Address4 != NULL && reqvar.Address4 !='')
                        accvar.Address4__c = reqvar.Address4;
                    if(reqvar.City != NULL && reqvar.City !='')
                        accvar.BillingCity = reqvar.City;
                    if(reqvar.State != NULL && reqvar.State !='')
                        accvar.BillingState = reqvar.State;
                    if(reqvar.Country!=null && reqvar.Country!='')
                        accvar.BillingCountry = reqvar.Country;
                   
                    if(reqvar.PostalCode != NULL && reqvar.PostalCode !='')
                        accvar.Billingpostalcode = reqvar.PostalCode;
                    
                    if(reqvar.EnterprisePartyNumber!= NULL && reqvar.EnterprisePartyNumber != '')
                        accvar.Enterprise_Party_Number__c   = reqvar.EnterprisePartyNumber;           
                    
                    //if(reqvar.Address1!= NULL && reqvar.Address1 != '') 
                    //  accvar.billingstreet = reqvar.Address1+'\r\n'+reqvar.Address2+'\r\n'+reqvar.Address3+'\r\n'+reqvar.Address4;   
                        
                     String additionaldesc ='';
                
                     if(reqvar.Address1 != null){                 
                        additionaldesc = reqvar.Address1+'\r\n';
                     }
                     if(reqvar.Address2 != null ){
                       if(additionaldesc != ''){
                          additionaldesc += reqvar.Address2+'\r\n';
                       }else{
                          additionaldesc = reqvar.Address2+'\r\n';
                       }   
                     }
                     if(reqvar.Address3 !=null ){
                       if(additionaldesc != ''){ 
                         additionaldesc += reqvar.Address3+'\r\n';
                       }else{
                         additionaldesc = reqvar.Address3+'\r\n';
                       }  
                     }
                     if(reqvar.Address4 !=null ){
                       if(additionaldesc != ''){ 
                         additionaldesc += reqvar.Address4;
                       }else{
                         additionaldesc = reqvar.Address4;
                       }  
                     }
                     if(additionaldesc != '')
                        accvar.billingstreet = additionaldesc;
                                   
                    if(reqvar.AccountForecastOwner != NULL && reqvar.AccountForecastOwner !='')    
                        accvar.Account_Forecast_Owner__c = reqvar.AccountForecastOwner;
                    if(reqvar.AccountStatus != NULL && reqvar.AccountStatus !='')
                        accvar.Account_Status__c = reqvar.AccountStatus;
                    if(reqvar.AnnualRevenue != NULL)
                        accvar.AnnualRevenue = reqvar.AnnualRevenue;                    
                    
                    if(accountmap!=null && reqvar.EnterpriseParentID!=null && reqvar.EnterpriseParentID!='' && accountmap.get(reqvar.EnterpriseParentID)!=null)
                    accvar.ParentId = accountmap.get(reqvar.EnterpriseParentID).Id; 
                   
                    /*if(reqvar.EnterpriseParentID != NULL && reqvar.EnterpriseParentID !='')
                        accvar.Parent.Enterprise_Party_Number__c =accountmap.get(reqvar.EnterpriseParentID).Enterprise_Party_Number__c; 
                    */
                        
                    if(reqvar.AccountSource != NULL && reqvar.AccountSource !='')
                        accvar.AccountSource = reqvar.AccountSource;                 
                    if(reqvar.CurrencyIsoCode != NULL && reqvar.CurrencyIsoCode !='')  
                        accvar.CurrencyIsoCode = reqvar.CurrencyIsoCode;
                    if(reqvar.DUNS != NULL && reqvar.DUNS !='')
                        accvar.DUNS__c = reqvar.DUNS;
                    if(reqvar.Description != NULL && reqvar.Description !='')
                        accvar.Description = reqvar.Description;
                    if(reqvar.Division != NULL && reqvar.Division !='')
                        accvar.Division__c = reqvar.Division;
                    if(reqvar.Fax != NULL && reqvar.Fax !='')
                        accvar.Fax = reqvar.Fax;                  
                    if(reqvar.Industry != NULL && reqvar.Industry !='')
                        accvar.Industry = reqvar.Industry;
                    if(reqvar.JigsawCompanyId != NULL && reqvar.JigsawCompanyId !='')
                        accvar.Jigsaw = reqvar.JigsawCompanyId;
                    if(reqvar.MarketingSegment != NULL && reqvar.MarketingSegment !='')
                        accvar.Marketing_Segment__c = reqvar.MarketingSegment;
                    if(reqvar.NAICSCode != NULL && reqvar.NAICSCode !='')
                        accvar.NAICS_Code__c = reqvar.NAICSCode;
                    if(reqvar.NumberOfEmployees != NULL)
                        accvar.NumberOfEmployees = reqvar.NumberOfEmployees;
                    if(reqvar.phone != NULL && reqvar.phone !='')
                        accvar.Phone = reqvar.phone;
                    if(reqvar.OracleID != NULL && reqvar.OracleID !='')
                        accvar.Oracle_ID__c = reqvar.OracleID;
                    if(reqvar.Ownership != NULL && reqvar.Ownership !='')
                        accvar.Ownership = reqvar.Ownership;
                    if(reqvar.pwccBillingAddressStatus != NULL && reqvar.pwccBillingAddressStatus !='')
                        accvar.pw_cc__BillingAddressStatus__c = reqvar.pwccBillingAddressStatus;
                    if(reqvar.pwccShippingAddressStatus != NULL && reqvar.pwccShippingAddressStatus !='')
                        accvar.pw_cc__ShippingAddressStatus__c = reqvar.pwccShippingAddressStatus;
                    if(reqvar.Rating != NULL && reqvar.Rating !='')
                        accvar.Rating = reqvar.Rating;
                    if(reqvar.SICCodedel != NULL && reqvar.SICCodedel !='')
                        accvar.Sic = reqvar.SICCodedel;
                    if(reqvar.SicDesc != NULL && reqvar.SicDesc !='')
                        accvar.SicDesc = reqvar.SicDesc;
                    if(reqvar.SellThrough != NULL && reqvar.SellThrough !='')
                        accvar.Sell_Through__c = reqvar.SellThrough;
                    if(reqvar.ShippingCity != NULL && reqvar.ShippingCity !='')
                        accvar.ShippingCity = reqvar.ShippingCity;
                    if(reqvar.ShippingCountry != NULL && reqvar.ShippingCountry !='')
                        accvar.ShippingCountry = reqvar.ShippingCountry;
                    if(reqvar.ShippingState != NULL && reqvar.ShippingState !='')
                        accvar.ShippingState  = reqvar.ShippingState;      
                    if(reqvar.ShippingStreet != NULL && reqvar.ShippingStreet !='')
                        accvar.ShippingStreet = reqvar.ShippingStreet;
                    if(reqvar.ShippingLatitude != NULL)
                        accvar.ShippingLatitude = reqvar.ShippingLatitude;
                    if(reqvar.ShippingLongitude != NULL)
                        accvar.ShippingLongitude = reqvar.ShippingLongitude;
                    if(reqvar.ShippingPostalCode != NULL && reqvar.ShippingPostalCode !='')
                        accvar.ShippingPostalCode = reqvar.ShippingPostalCode;
                    //accvar.site = reqvar.Site;   
                    //accvar.Site_Name__c = reqvar.Site;
                    
                    if(reqvar.PartySiteName != NULL && reqvar.PartySiteName !='')
                    accvar.Site_Name__c = reqvar.PartySiteName;   
                    
                    if(reqvar.DoNotMerge != NULL && reqvar.DoNotMerge !='')
                    accvar.Do_Not_Merge__c = boolean.valueOf(reqvar.DoNotMerge);
                    
                    if(reqvar.PrimaryContact != NULL && reqvar.PrimaryContact !='')
                    accvar.Attention__c = reqvar.PrimaryContact;
                    
                    if(reqvar.TaxID != NULL && reqvar.TaxID !='')
                    accvar.VAT_Number__c = reqvar.TaxID;
                    
                    if(reqvar.AddressCheckResults != NULL && reqvar.AddressCheckResults !='')
                    accvar.Address_Check_Results__c = reqvar.AddressCheckResults;
                    
                    if(reqvar.Language != NULL && reqvar.Language !='')
                    accvar.Preferred_Language__c = reqvar.Language;   
                    
                    if(reqvar.subindustry != NULL && reqvar.subindustry !='')
                    accvar.sub_industry__c = reqvar.subindustry;
                    if(reqvar.VerticalClassification != NULL && reqvar.VerticalClassification !='')
                    accvar.vertical_classification__c = reqvar.VerticalClassification;   
                    
                    if(usermap!=NULL && reqvar.AccountOwnerEmail != NULL && reqvar.AccountOwnerEmail !='' && usermap.get(reqvar.AccountOwnerEmail) != NULL)
                        //accvar.Owner.Email = reqvar.AccountOwnerEmail;
                        accvar.OwnerId = usermap.get(reqvar.AccountOwnerEmail).id;   
                    if(reqvar.webSite != NULL && reqvar.webSite !='')
                        accvar.Website = reqvar.webSite;
                    //accvar.Parent_Account_ID__c =reqvar.EnterpriseParentID;
                    
                    
                    if(reqvar.GlobalOptOut!=null && reqvar.GlobalOptOut!='' && (reqvar.GlobalOptOut== 'Yes' || reqvar.GlobalOptOut== 'yes'))                    
                        accvar.Global_Opt_Out__c = true;
                    else
                        accvar.Global_Opt_Out__c = false;
                        accvar.Restricted_Entity__c     = (reqvar.RestrictedPartyIndicator!=null && reqvar.RestrictedPartyIndicator!='')?((reqvar.RestrictedPartyIndicator.equalsIgnoreCase('yes'))?Label.Restricted:Label.Not_Restricted):Label.Not_Restricted;
                    
                    //accvar.Credit_Check_Status__c =reqvar.CreditStatus;                   
                    
                    if(reqvar.BilltoFlag!=null && reqvar.BilltoFlag!='' && (reqvar.BilltoFlag== 'Yes' || reqvar.BilltoFlag== 'yes'))                    
                        accvar.Bill_to_Flag__c = true;
                    else
                        accvar.Bill_to_Flag__c = false;
                    
                    if(reqvar.ShiptoFlag!=null && reqvar.ShiptoFlag!='' && (reqvar.ShiptoFlag== 'Yes' || reqvar.ShiptoFlag== 'yes'))                    
                        accvar.Ship_to_Flag__c = true;
                    else
                        accvar.Ship_to_Flag__c = false;
                    
                    if(reqvar.EndUserFlag!=null && reqvar.EndUserFlag!='' && (reqvar.EndUserFlag== 'Yes' || reqvar.EndUserFlag== 'yes'))                    
                        accvar.End_User_Flag__c = true;
                    else
                        accvar.End_User_Flag__c = false;
                    
                    if(reqvar.InstalledatFlag!=null && reqvar.InstalledatFlag!='' && (reqvar.InstalledatFlag== 'Yes' || reqvar.InstalledatFlag== 'yes'))                    
                        accvar.Installed_at_Flag__c = true;
                    else
                        accvar.Installed_at_Flag__c = false;                    
                    accountlist.add(accvar); 
                    }
                    
                             
            }            
             if(accountlist !=null && accountlist.size()>0)
                srList = Database.upsert(accountlist,Account.Fields.Id,false);
             /*if(multipleAccountList != null && multipleAccountList.size()>0)
                srList = Database.upsert(multipleAccountList,Account.Fields.Id,false);*/
             for (Database.UpsertResult sr : srList) { 
             if (sr.isSuccess()) {
                respvar = new ResponseWrpaerClass();
                    respvar.result ='Success'; 
                    respvar.recordid =   sr.getId();
                    responselist.add(respvar);
            }
            else {            
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    respvar = new ResponseWrpaerClass();
                    respvar.result ='Failure';
                    respvar.ErrorCode = 'CMDM-ERR-04';
                    respvar.ErrorMessage = err.getStatusCode() + ': ' + err.getMessage();
                    respvar.recordid =   sr.getId();
                    responselist.add(respvar);
                }
            } 
            }
            
        }
        catch(exception ex)
        {
            respvar = new ResponseWrpaerClass();  
            respvar.result ='Failure';
            respvar.ErrorCode = 'CMDM-ERR-05';
            respvar.ErrorMessage = string.valueof(ex);
            responselist.add(respvar);
            system.debug('error ==== '+ex);
            system.debug('error at ==== '+ex.getStackTraceString());
        }         
        return responselist ;
    }
     
     /*
     * Method name  : UpdateParty
     * Description  : Webserice method to load Account data from Oracle EBS to SFDC standard object Account and update Account data
     * Return Type  : list<ResponseWraperClass>
     * Parameter    : requesrwrapervar
     */
     webService static list<ResponseWrpaerClass> UpdateParty(list<RequestUpdateWrpaerClass> updatevar) 
    {
    
        list<account> accountlist = new list<account>();
        ResponseWrpaerClass respvar ;
        integer count;
        list<ResponseWrpaerClass> responselist = new list<ResponseWrpaerClass>();
        Database.UpsertResult[] srList;
        map<string,account> accountmap = new map<string,account>();
        set<string> accountset = new set<string>();
        
        account acc;
        try{
            
       
        for(RequestUpdateWrpaerClass objvar: updatevar)
        {
            if(objvar.party_OriginalSystem == 'SFDC')
                accountset.add(objvar.Party_OriginalSystemReference);
            else
                accountset.add(objvar.EnterpriseMasterID);
        }
        
        for(Account accvar : [Select Id,Site_Name__c,Owner.Email,Parent.FCH_Party_Id__c,Parent.Enterprise_Party_Number__c, IsDeleted,email__c,Ship_to_Flag__c,End_User_Flag__c,Bill_to_Flag__c,Credit_Check_Status__c,Address4__c,Parent_Account_ID__c,Global_Opt_Out__c,Installed_at_Flag__c,parent.id,Restricted_Entity__c, AccountSource,SicDesc,Ownership,Sic,Rating,Jigsaw,MasterRecordId, Name, Type, RecordTypeId, ParentId, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, ShippingLatitude, ShippingLongitude, Phone, Fax, Website, Industry, AnnualRevenue, NumberOfEmployees, Description, Site, CurrencyIsoCode, OwnerId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, IsPartner, JigsawCompanyId, pw_cc__BillingAddressStatus__c, pw_cc__ShippingAddressStatus__c, Account_Status__c, DUNS__c, Division__c, Forecast_Account__c, NAICS_Code__c, Oracle_ID__c, Region__c, Requested_Account_Record_Type__c, SIC_Code_del__c, Sub_Type__c, Submitted_for_Approval__c, sub_industry__c, Marketing_Segment__c, Sell_Through__c, Account_Forecast_Owner__c,Sell_ToFlag__c, Email_domain__c,  AddressValidated__c, Address1__c, Address2__c, Address3__c, Party_Original_System__c, FCH_Party_ID__c FROM Account where id in :accountset ])
        {
            accountmap.put(accvar.id,accvar);
        }   
        
        if(accountmap.size()==0){
            for(Account accvar : [Select Id,Site_Name__c,Owner.Email,Parent.FCH_Party_Id__c,Parent.Enterprise_Party_Number__c, IsDeleted,email__c,Ship_to_Flag__c,End_User_Flag__c,Bill_to_Flag__c,Credit_Check_Status__c,Address4__c,Parent_Account_ID__c,Global_Opt_Out__c,Installed_at_Flag__c,parent.id,Restricted_Entity__c, AccountSource,SicDesc,Ownership,Sic,Rating,Jigsaw,MasterRecordId, Name, Type, RecordTypeId, ParentId, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, ShippingLatitude, ShippingLongitude, Phone, Fax, Website, Industry, AnnualRevenue, NumberOfEmployees, Description, Site, CurrencyIsoCode, OwnerId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, IsPartner, JigsawCompanyId, pw_cc__BillingAddressStatus__c, pw_cc__ShippingAddressStatus__c, Account_Status__c, DUNS__c, Division__c, Forecast_Account__c, NAICS_Code__c, Oracle_ID__c, Region__c, Requested_Account_Record_Type__c, SIC_Code_del__c, Sub_Type__c, Submitted_for_Approval__c, sub_industry__c, Marketing_Segment__c, Sell_Through__c, Account_Forecast_Owner__c,Sell_ToFlag__c, Email_domain__c,  AddressValidated__c, Address1__c, Address2__c, Address3__c, Party_Original_System__c, FCH_Party_ID__c,Enterprise_Party_Number__c FROM Account where Enterprise_Party_Number__c in :accountset ])
            {
                accountmap.put(accvar.id,accvar);
            }
        }
        
       //Iterate over the data received from Oracle for creating the Account records    
       for(RequestUpdateWrpaerClass objvar: updatevar)
        {
            respvar = new ResponseWrpaerClass();
            system.debug('respvar.customername='+objvar.customername);
            /*if(objvar.customerName == null || objvar.customername == '')
            {    
                     respvar.result  =  'Failure';
                     respvar.ErrorCode = 'CMDM-ERR-02';
                     respvar.ErrorMessage = 'Customer name is null. Please check the data';
                     responselist.add(respvar);
            }
            else
            {*/   
                if(objvar.party_OriginalSystem == 'SFDC'){            
                    if(accountmap!=null && objvar.Party_OriginalSystemReference!=null && objvar.Party_OriginalSystemReference!='' && accountmap.get(objvar.Party_OriginalSystemReference)!=null)                
                    acc = accountmap.get(objvar.Party_OriginalSystemReference);
                
                else{
                     respvar.result  =  'Failure';
                     respvar.ErrorCode = 'CMDM-ERR-03';
                     respvar.ErrorMessage = 'Party with name '+ objvar.customername +' doesnot exist in the system . please recheck the data';
                     responselist.add(respvar);
                }
                }
                else
                    acc = accountmap.get(objvar.EnterpriseMasterID);           
                
                if(acc!=null){
                acc.Name = (objvar.customerName!=null && objvar.customerName!='') ? objvar.customerName : acc.Name;
                acc.FCH_Party_Id__c = objvar.EnterpriseMasterID;                    
                acc.Lifecycle_Stage__c = (objvar.LifecycleStage!=null && objvar.LifecycleStage!='') ? objvar.LifecycleStage : acc.Lifecycle_Stage__c;
                acc.sub_type__c = (objvar.CustomerLevel!=null && objvar.CustomerLevel!='') ? objvar.CustomerLevel : acc.sub_type__c;
                
                 
                acc.Region__c = (objvar.PrimaryRegion!=null && objvar.PrimaryRegion!='') ? objvar.PrimaryRegion : acc.Region__c;
                //acc.Sell_ToFlag__c = (objvar.SelltoFlag!=null && objvar.SelltoFlag!='') ? ((objvar.SelltoFlag == 'yes')?true:false) : acc.Sell_ToFlag__c;
                if(objvar.SelltoFlag!=null && objvar.SelltoFlag!='' && (objvar.SelltoFlag == 'Yes' || objvar.SelltoFlag == 'yes'))                    
                        acc.Sell_ToFlag__c = true;
                    else
                    if(objvar.SelltoFlag!=null && objvar.SelltoFlag!='' && (objvar.SelltoFlag == 'No' || objvar.SelltoFlag == 'no')&&
                       objvar.BilltoFlag!=null && objvar.BilltoFlag!='' && (objvar.BilltoFlag == 'No' || objvar.BilltoFlag == 'no')&&
                       objvar.ShiptoFlag!=null && objvar.ShiptoFlag!='' && (objvar.ShiptoFlag == 'No' || objvar.ShiptoFlag == 'no'))
                        acc.Sell_ToFlag__c = true;         
                    else
                        acc.Sell_ToFlag__c = false;
                //acc.Email_Domain__c = (objvar.PrimaryEmailAddress!=null && objvar.PrimaryEmailAddress!='') ? objvar.PrimaryEmailAddress : acc.Email_Domain__c;
                acc.Email__c = (objvar.PrimaryEmailAddress!=null && objvar.PrimaryEmailAddress!='') ? objvar.PrimaryEmailAddress : acc.Email__c;
                
                acc.AddressValidated__c = (objvar.AddressValidated!=null && objvar.AddressValidated!='') ? ((objvar.AddressValidated == 'yes')?true:false) : acc.AddressValidated__c;
                acc.Address1__c = (objvar.Address1!=null && objvar.Address1!='') ? objvar.Address1 : acc.Address1__c;
                acc.Address2__c = (objvar.Address2!=null && objvar.Address2!='') ? objvar.Address2 : acc.Address2__c;
                acc.Address3__c = (objvar.Address3!=null && objvar.Address3!='') ? objvar.Address3 : acc.Address3__c;
                acc.Address4__c = (objvar.Address4!=null && objvar.Address4!='') ? objvar.Address4 : acc.Address4__c;
                acc.BillingCity = (objvar.City!=null && objvar.City!='') ? objvar.City : acc.BillingCity;
                acc.BillingState = (objvar.State!=null && objvar.State!='') ? objvar.State : acc.BillingState;
                
                if(objvar.Country!=null && objvar.Country!='')
                acc.BillingCountry = objvar.Country;
                //acc.Billingstreet = objvar.Address1+'\r\n'+objvar.Address2+'\r\n'+objvar.Address3+'\r\n'+objvar.Address4; 
                String additionaldesc ='';
                
                 if(objvar.Address1 != null && objvar.Address1 != ''){                 
                    additionaldesc = objvar.Address1+'\r\n';
                 }
                 if(objvar.Address2 != null && objvar.Address2 != ''){
                   if(additionaldesc != ''){
                      additionaldesc += objvar.Address2+'\r\n';
                   }else{
                      additionaldesc = objvar.Address2+'\r\n';
                   }   
                 }
                 if(objvar.Address3 !=null && objvar.Address3 != ''){
                   if(additionaldesc != ''){ 
                     additionaldesc += objvar.Address3+'\r\n';
                   }else{
                     additionaldesc = objvar.Address3+'\r\n';
                   }  
                 }
                 if(objvar.Address4 !=null && objvar.Address4 != ''){
                   if(additionaldesc != ''){ 
                     additionaldesc += objvar.Address4;
                   }else{
                     additionaldesc = objvar.Address4;
                   }  
                 }
                 if(additionaldesc != '')
                    acc.billingstreet = additionaldesc;
                    
                acc.Billingpostalcode = (objvar.PostalCode!=null && objvar.PostalCode!='') ? objvar.PostalCode : acc.Billingpostalcode;
              
                //acc.billingstreet =   (objvar.Address1!=null && objvar.Address1!='') ? objvar.Address1 : acc.billingstreet;        
                acc.Account_Forecast_Owner__c = (objvar.AccountForecastOwner!=null && objvar.AccountForecastOwner!='') ? objvar.AccountForecastOwner : acc.Account_Forecast_Owner__c;
                acc.Account_Status__c = (objvar.AccountStatus!=null && objvar.AccountStatus!='') ? objvar.AccountStatus : acc.Account_Status__c;
                acc.AnnualRevenue =   (objvar.AnnualRevenue!=null ) ? objvar.AnnualRevenue : acc.AnnualRevenue;                  
                
              
                acc.CurrencyIsoCode = (objvar.CurrencyIsoCode!=null && objvar.CurrencyIsoCode!='') ? objvar.CurrencyIsoCode : acc.CurrencyIsoCode;
                acc.DUNS__c = (objvar.DUNS!=null && objvar.DUNS!='') ? objvar.DUNS : acc.DUNS__c;
                acc.Description = (objvar.Description!=null && objvar.Description!='') ? objvar.Description : acc.Description;
                acc.Division__c = (objvar.Division!=null && objvar.Division!='') ? objvar.Division : acc.Division__c;
                acc.Fax = (objvar.Fax!=null && objvar.Fax!='') ? objvar.Fax : acc.Fax;                
                
                acc.Jigsaw = (objvar.JigsawCompanyId!=null && objvar.JigsawCompanyId!='') ? objvar.JigsawCompanyId : acc.Jigsaw;
                acc.Enterprise_Party_Number__c   = (objvar.EnterprisePartyNumber!=null && objvar.EnterprisePartyNumber!='') ? objvar.EnterprisePartyNumber : acc.Enterprise_Party_Number__c;  
                acc.Marketing_Segment__c = (objvar.MarketingSegment!=null && objvar.MarketingSegment!='') ? objvar.MarketingSegment : acc.Marketing_Segment__c;
                acc.NAICS_Code__c = (objvar.NAICSCode!=null && objvar.NAICSCode!='') ? objvar.NAICSCode : acc.NAICS_Code__c;
                acc.NumberOfEmployees = (objvar.NumberOfEmployees!=null && integer.valueof(objvar.NumberOfEmployees)>0) ? objvar.NumberOfEmployees : acc.NumberOfEmployees;
                //system.debug('objvar.Phone====='+objvar.Phone+'=====acc.Phone====='+acc.Phone);
                acc.Phone = (objvar.Phone!=null && objvar.Phone!='') ? objvar.Phone : acc.Phone;
                acc.Oracle_ID__c = (objvar.OracleID!=null && objvar.OracleID!='') ? objvar.OracleID : acc.Oracle_ID__c;
                acc.Ownership = (objvar.Ownership!=null && objvar.Ownership!='') ? objvar.Ownership : acc.Ownership;
                acc.pw_cc__BillingAddressStatus__c = (objvar.pwccBillingAddressStatus!=null && objvar.pwccBillingAddressStatus!='') ? objvar.pwccBillingAddressStatus : acc.pw_cc__BillingAddressStatus__c;
                acc.pw_cc__ShippingAddressStatus__c = (objvar.pwccShippingAddressStatus!=null && objvar.pwccShippingAddressStatus!='') ? objvar.pwccShippingAddressStatus : acc.pw_cc__ShippingAddressStatus__c;
                acc.Rating = (objvar.Rating!=null && objvar.Rating!='') ? objvar.Rating : acc.Rating;
                acc.Sic = (objvar.SICCodedel!=null && objvar.SICCodedel!='') ? objvar.SICCodedel : acc.Sic;
                acc.SicDesc = (objvar.SicDesc!=null && objvar.SicDesc!='') ? objvar.SicDesc : acc.SicDesc;
                acc.Sell_Through__c = (objvar.SellThrough!=null && objvar.SellThrough!='') ? objvar.SellThrough : acc.Sell_Through__c;
                acc.ShippingCity = (objvar.ShippingCity!=null && objvar.ShippingCity!='') ? objvar.ShippingCity : acc.ShippingCity;
                acc.ShippingCountry = (objvar.ShippingCountry!=null && objvar.ShippingCountry!='') ? objvar.ShippingCountry : acc.ShippingCountry;
                acc.ShippingState  = (objvar.ShippingState!=null && objvar.ShippingState!='') ? objvar.ShippingState : acc.ShippingState; 
                acc.ShippingStreet = (objvar.ShippingStreet!=null && objvar.ShippingStreet!='') ? objvar.ShippingStreet : acc.ShippingStreet;
                
                acc.Site_Name__c = (objvar.PartySiteName!=null && objvar.PartySiteName!='') ? objvar.PartySiteName : acc.Site_Name__c;
                
                acc.Do_Not_Merge__c = (objvar.DoNotMerge!=null && objvar.DoNotMerge!='') ? boolean.valueOf(objvar.DoNotMerge) : acc.Do_Not_Merge__c;
                
                acc.Attention__c = (objvar.PrimaryContact!=null && objvar.PrimaryContact!='') ? objvar.PrimaryContact : acc.Attention__c;   
                
                acc.VAT_Number__c = (objvar.TaxID!=null && objvar.TaxID!='') ? objvar.TaxID : acc.VAT_Number__c;   
                
                acc.Address_Check_Results__c = (objvar.AddressCheckResults!=null && objvar.AddressCheckResults!='') ? objvar.AddressCheckResults : acc.Address_Check_Results__c;   
                
                acc.Preferred_Language__c = (objvar.Language!=null && objvar.Language!='') ? objvar.Language : acc.Preferred_Language__c;   
                    
                acc.ShippingPostalCode = (objvar.ShippingPostalCode!=null && objvar.ShippingPostalCode!='') ? objvar.ShippingPostalCode : acc.ShippingPostalCode;
                //acc.site = (objvar.site!=null && objvar.site!='') ? objvar.site : acc.site;     
                acc.Site_Name__c = (objvar.site!=null && objvar.site!='') ? objvar.site : acc.Site_Name__c;            
                acc.sub_industry__c = (objvar.subindustry!=null && objvar.subindustry!='') ? objvar.subindustry : acc.sub_industry__c;
                acc.vertical_classification__c = (objvar.VerticalClassification!=null && objvar.VerticalClassification!='') ? objvar.VerticalClassification : acc.vertical_classification__c;                
                
                //acc.Parent_Account_ID__c =(objvar.EnterpriseParentID!=null && objvar.EnterpriseParentID!='')?objvar.EnterpriseParentID:acc.Parent_Account_ID__c;
                if(acc.ParentId !=null)
                acc.Parent.Enterprise_Party_Number__c =(objvar.EnterpriseParentID!=null && objvar.EnterpriseParentID!='')?objvar.EnterpriseParentID:acc.Parent.Enterprise_Party_Number__c;
                acc.Global_Opt_Out__c =(objvar.GlobalOptOut!=null && objvar.GlobalOptOut!='')?((objvar.GlobalOptOut== 'yes')?true:false):acc.Global_Opt_Out__c;
                acc.Restricted_Entity__c    =(objvar.RestrictedPartyIndicator!=null && objvar.RestrictedPartyIndicator!='')?(objvar.RestrictedPartyIndicator.equalsIgnoreCase('yes')?Label.Restricted:Label.Not_Restricted):acc.Restricted_Entity__c;
                 
                //acc.Credit_Check_Status__c =(objvar.CreditStatus!=null && objvar.CreditStatus!='')?objvar.CreditStatus:acc.Credit_Check_Status__c;
                acc.Bill_to_Flag__c =(objvar.BilltoFlag!=null && objvar.BilltoFlag!='')?((objvar.BilltoFlag== 'yes')?true:false):acc.Bill_to_Flag__c;
                acc.Ship_to_Flag__c =(objvar.ShiptoFlag!=null && objvar.ShiptoFlag!='')?((objvar.ShiptoFlag== 'yes')?true:false):acc.Ship_to_Flag__c;
                acc.End_User_Flag__c =(objvar.EndUserFlag!=null && objvar.EndUserFlag!='')?((objvar.EndUserFlag== 'yes')?true:false):acc.End_User_Flag__c;
                acc.Installed_at_Flag__c =(objvar.InstalledatFlag!=null && objvar.InstalledatFlag!='')?((objvar.InstalledatFlag== 'yes')?true:false):acc.Installed_at_Flag__c ;
                //acc.Email__c = (objvar.AccountOwnerEmail!=null && objvar.AccountOwnerEmail!='')?objvar.AccountOwnerEmail:acc.Email__c ;
                acc.Owner.Email = (objvar.AccountOwnerEmail!=null && objvar.AccountOwnerEmail!='')?objvar.AccountOwnerEmail:acc.Owner.Email ;
                //acc.Party_original_system_Parent__c = (objvar.Party_originalsystemParent!=null && objvar.Party_originalsystemParent!='')?objvar.Party_originalsystemParent:acc.Account_Owner_Email__c ;    
                acc.Website = (objvar.Website!=null && objvar.Website!='') ? objvar.Website : acc.Website;
                //acc.Parent.id = (objvar.Party_originalsystemParent!=null && objvar.Party_originalsystemParent!='') ? objvar.Party_originalsystemParent : acc.Parent.id ;
                accountlist.add(acc);
            }
            
        //}        
        
        }
       
       
        if(accountlist !=null && accountlist.size()>0)
             srList = Database.upsert(accountlist,Account.Fields.Id,false);
             if(srList!=null && srList.size()>0)
             for (Database.UpsertResult sr : srList) { 
             if (sr.isSuccess()) {
                respvar = new ResponseWrpaerClass();
                    respvar.result ='Success'; 
                    respvar.recordid =   sr.getId();  
                    responselist.add(respvar);
            }
            else {            
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    respvar = new ResponseWrpaerClass();
                    respvar.result ='Failure';   
                    respvar.ErrorCode = 'CMDM-DB-ERR';
                    respvar.ErrorMessage = err.getStatusCode() + ': ' + err.getMessage();
                    respvar.recordid =   sr.getId();
                    responselist.add(respvar);
                }
            } 
            }        
     }
    catch(Exception ex)
    {
            respvar = new ResponseWrpaerClass();
            
            respvar.result  =  'Failure';
            respvar.ErrorCode = 'CMDM-FIN-ERR';
            respvar.ErrorMessage = string.valueof(ex);
            responselist.add(respvar);    
            system.debug('error ==== '+ex);
            system.debug('error at ==== '+ex.getStackTraceString()); 
        
    }    
    
    return responselist;
    
   } 
   
   //Wrapper Class to define attributes used to set the data from Oracle EBS for Creation 
   global class RequestWrpaerClass 
    {        
        webservice String CustomerName;
        webservice String LifecycleStage;
        webservice String CustomerLevel;
        webservice String Channel;
        webservice String PrimaryRegion;
        webservice String SelltoFlag;
        webservice String PrimaryEmailAddress;
        
        webservice String AddressValidated;
        webservice String Address1;
        webservice String Address2;
        webservice String Address3;
        webservice String Address4;
        webservice String City;
        webservice String State;
        webservice String Country;
        webservice String PostalCode;
        webservice String party_OriginalSystem;
        webservice String Party_OriginalSystemReference;
        webservice String Party_originalsystemParent;
                       
        webservice String BillingStreet;
        webservice String Email;
        webservice String EnterpriseMasterID;
        
        webservice string AccountForecastOwner;
        webservice string AccountStatus;
        webservice double AnnualRevenue;
        webservice string AccountSource;
        webservice double BillingLatitude;
        webservice double BillingLongitude;
        webservice string CurrencyIsoCode;
        webservice string DUNS;
        webservice string Description;
        webservice string Division;
        webservice string Fax;
        webservice boolean ForecastAccount;
        webservice string Industry;
        webservice string JigsawCompanyId;
        webservice string LegacySystem;
        webservice string MarketingSegment;
        webservice string NAICSCode;
        webservice integer NumberOfEmployees;
        webservice string OracleID;
        webservice string Ownership;
        webservice string Phone;
        webservice string Rating;
        webservice string SicDesc; 
        webservice string SICCodedel;
        webservice string SellThrough;
        webservice string ShippingCity;
        webservice string ShippingCountry;
        webservice string ShippingState;        
        webservice string ShippingStreet;
        webservice double ShippingLatitude;
        webservice double ShippingLongitude;
        webservice string ShippingPostalCode;
        webservice string Site; 
        webservice string webSite;  
        webservice string SubType;
        webservice boolean SubmittedforApproval;     
        webservice string Type;
        
        webservice string pwccBillingAddressStatus;
        webservice string pwccShippingAddressStatus;
        webservice string subindustry; 
            
        webservice string EnterpriseParentID;
        webservice string GlobalOptOut;
        webservice string RestrictedPartyIndicator;
        webservice string VerticalClassification; 
        webservice string CreditStatus;
        webservice string BilltoFlag;
        webservice string ShiptoFlag;
        webservice string EndUserFlag;
        webservice string InstalledatFlag;
        webservice string AccountOwnerEmail;
        webservice string DoNotMerge;
        webservice string TaxId;
        webservice string Language;
        webservice string AddressCheckResults;
        webservice string EnterprisePartyNumber;
        webservice string PartySiteName;
        webservice string PrimaryContact;
    }
   
   //Wrapper Class to define attributes used to set the data from Oracle EBS for Updation
   global class RequestUpdateWrpaerClass 
    {        
        webservice String CustomerName;
        webservice String EnterpriseMasterID;
        
        webservice String LifecycleStage;
        webservice String CustomerLevel;
        webservice String Channel;
        webservice String PrimaryRegion;
        webservice String SelltoFlag;
        webservice String PrimaryEmailAddress;
        
        webservice String AddressValidated;
        webservice String Address1;
        webservice String Address2;
        webservice String Address3;
        webservice String Address4;
        webservice String City;
        webservice String State;
        webservice String Country;
        webservice String PostalCode;
        webservice String party_OriginalSystem;
        webservice String Party_OriginalSystemReference;
        webservice String Party_originalsystemParent;               
        webservice String BillingStreet;
        webservice String Email;
        
        webservice string AccountForecastOwner;
        webservice string AccountStatus;
        webservice double AnnualRevenue;
        webservice string AccountSource;
        webservice double BillingLatitude;
        webservice double BillingLongitude;
        webservice string CurrencyIsoCode;
        webservice string DUNS;
        webservice string Description;
        webservice string Division;
        webservice string Fax;
        webservice boolean ForecastAccount;
        webservice string Industry;
        webservice string JigsawCompanyId;
        webservice string LegacySystem;
        webservice string MarketingSegment;
        webservice string NAICSCode;
        webservice integer NumberOfEmployees;
        webservice string OracleID;
        webservice string Ownership;
        webservice string Phone;
        webservice string Rating;
        webservice string SicDesc; 
        webservice string SICCodedel;
        webservice string SellThrough;
        webservice string ShippingCity;
        webservice string ShippingCountry;
        webservice string ShippingState;        
        webservice string ShippingStreet;
        webservice double ShippingLatitude;
        webservice double ShippingLongitude;
        webservice string ShippingPostalCode;
        webservice string Site; 
        webservice string webSite;  
        webservice string SubType;
        webservice boolean SubmittedforApproval;     
        webservice string Type;
        
        webservice string pwccBillingAddressStatus;
        webservice string pwccShippingAddressStatus;
        webservice string subindustry;
        
        webservice string EnterpriseParentID;
        webservice string GlobalOptOut;
        webservice string RestrictedPartyIndicator;
        webservice string VerticalClassification; 
        webservice string CreditStatus;
        webservice string BilltoFlag;
        webservice string ShiptoFlag;
        webservice string EndUserFlag;
        webservice string InstalledatFlag;
        webservice string AccountOwnerEmail;
        webservice string DoNotMerge;
        webservice string TaxId;
        webservice string Language;
        webservice string AddressCheckResults;
        webservice string EnterprisePartyNumber;
        webservice string PartySiteName;
        webservice string PrimaryContact;
    } 
    
    
    global class ResponseWrpaerClass 
    {
        webservice String recordid {get;set;}        
        webservice String result{get;set;}
        webservice String ErrorCode{get;set;}
        webservice String ErrorMessage{get;set;}
    }
        
}