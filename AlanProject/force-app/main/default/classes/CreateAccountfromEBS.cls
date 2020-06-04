/*****************************************************************************************
    Name    : CreateAccountfromEBS 
    Desc    : Used to do a call out from FCH server or EBS and Insert / Update data to SFDC tabels Account, Address and Contact.
                                          
Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Prince Leo            29/03/2015          Created
Ankur Patel           29/03/2015          Created 
******************************************************************************************/
global class CreateAccountfromEBS {

     /*
     * Method name  : CreateParty
     * Description  : Method to Create an accounts with related List of Contact and List of Address from EBS / FCH
     * Return Type  : list<ResponseWrapper>
     * Parameter    : RequestAccountdata
     */
 Public Static Boolean SpecialScenario = False;
 Public Static RequestAccountdata GlobalrequestParam; 
 Public Static Map<String,String>AddressMap = new Map<String,String>();
    webService static list<ResponseWrapper> CreateParty(RequestAccountdata requestParam){
        GlobalrequestParam = requestParam;
        list<ResponseWrapper> responselist = new list<ResponseWrapper>();
        Account acc = new Account();
        boolean errorFlag = false;
        List<String>AcctIds = new List<String>();
         List<Reseller__c>InsertResellerList= new List<Reseller__c>();
         if(requestParam.Resellers!= Null && requestParam.Resellers!= '')
                {
                 AcctIds = requestParam.Resellers.split('\\|');
                }
            system.debug('>>>>>>>>>AcctIds*****>>>>>>'+AcctIds);
            
        List<Account> AccList = new List<Account>([select id from Account where FCH_Party_ID__c =: requestParam.FchPartyID]);
        List<Account> ResellerAccList = new List<Account>([select id,Reseller_Account__c from Account where Enterprise_Party_Number__c =: AcctIds]);
        if(AccList.size()==0 && (requestParam.AccountID == Null || requestParam.AccountID ==''))
        {
        SpecialScenario = True;
        }
        try{
            if(requestParam.strOperation != 'Merge'){
            
                if(requestParam.AccountName != null && requestParam.AccountName != ''){
                    acc.Name = requestParam.AccountName;
                }
                if(requestParam.DUNS != null && requestParam.DUNS != ''){
                    acc.DUNS__c = requestParam.DUNS;
                }
               
                if(requestParam.TotalAmountPastDue !=null && requestParam.TotalAmountPastDue !=''){
                 acc.Total_Amount_Past_Due__c = requestParam.TotalAmountPastDue;
                }
                
               if(requestParam.TotalUnpaidAmount!=null && requestParam.TotalUnpaidAmount!=''){
                 acc.Total_Unpaid_Amount__c = requestParam.TotalUnpaidAmount;
                }
               /* if(requestParam.AvailableCreditLine!=null && requestParam.AvailableCreditLine!=''){
                 acc.Available_Credit_Line__c= requestParam.AvailableCreditLine;
                } */
                 if(requestParam.Email!=null && requestParam.Email!=''){
                 acc.Email__c= requestParam.Email;
                } 
                  if(requestParam.FchReportingEntityPartyID !=null && requestParam.FchReportingEntityPartyID !=''){
                 acc.FchReportingEntityPartyID__c= requestParam.FchReportingEntityPartyID;
                } 
                
                
                if(requestParam.PrimaryRegion != null && requestParam.PrimaryRegion != ''){
                    acc.Region__c = requestParam.PrimaryRegion;
                }
                
                if(requestParam.RestrictedPartyIndicator != null && requestParam.RestrictedPartyIndicator != ''){
                    acc.Restricted_Entity__c = requestParam.RestrictedPartyIndicator;
                }
                
                if(requestParam.DoNotMerge != null)
                acc.Do_Not_Merge__c = requestParam.DoNotMerge;
                
                if(requestParam.VerticalClassification != null && requestParam.VerticalClassification != ''){
                    acc.Vertical_Classification__c = requestParam.VerticalClassification;
                }
                
                if(requestParam.CreditStatus != null && requestParam.CreditStatus != ''){
                    acc.Credit_Check_Status__c = requestParam.CreditStatus;
                }
                
                // Default values at the time of Account creation from EBS
                acc.Bill_To_Flag__c = True;
                acc.Ship_To_Flag__c = True;
                //acc.Lifecycle_Stage__c = 'Customer';
                if(requestParam.CustomerType != Null && requestParam.CustomerType !='')
                acc.Type = requestParam.CustomerType;
                
                if(requestParam.TapCustomerType != Null && requestParam.TapCustomerType !='')
                acc.TAP_Customer_Type__c = requestParam.TapCustomerType;
                
                if(requestParam.FchPartyID != null && requestParam.FchPartyID != ''){
                    acc.FCH_Party_Id__c = requestParam.FchPartyID;
                }
                
                if(requestParam.CustomerReference !=null && requestParam.CustomerReference !=''){
                 acc.Customer_Reference__c = requestParam.CustomerReference;
                }
                 if(requestParam.CPIRPIReqd !=null && requestParam.CPIRPIReqd !=''){
                 acc.CPI_RPI_Reqd__c = (requestParam.CPIRPIReqd=='Y'? 'Yes' : 'No');
                }
                
                if(requestParam.FchReportingEntityNumber != null && requestParam.FchReportingEntityNumber != ''){
                    acc.FchReportingEntityNumber__c = requestParam.FchReportingEntityNumber;
                }
                
                if(requestParam.EBSPaymentTerm != null && requestParam.EBSPaymentTerm != ''){
                    acc.EBS_Payment_Term__c = requestParam.EBSPaymentTerm;
                }
              
              system.debug('>>>>>>>>>Attribute3>>>>>>>>>>'+requestParam.attribute3);
              system.debug('>>>>>>>>>Attribute4>>>>>>>>>>'+requestParam.attribute4);
              if(requestParam.attribute3!= Null && requestParam.attribute3 != '')
              {
               acc.Freight_Term__c = requestParam.attribute3;
              }
              
              if(requestParam.attribute4!= Null && requestParam.attribute4 != '')
              {
               acc.Shipping_Method__c = requestParam.attribute4;
              }
              
                if(requestParam.EnterpriseAccountNumber != null && requestParam.EnterpriseAccountNumber != ''){
                    acc.Enterprise_Party_Number__c = requestParam.EnterpriseAccountNumber;
                }
                
                //Added for TAP 
                 if(requestParam.customershortname != null && requestParam.customershortname!= ''){
                    acc.Customer_Short_Name__c = requestParam.customershortname;
                }
                
                if(requestParam.discount != null && requestParam.discount!= ''){
                    acc.Discount__c= requestParam.discount;
                }
                
                if(requestParam.autorenewal !=null && requestParam.autorenewal !=''){
                 acc.Auto_Renewal__c = (requestParam.autorenewal =='Y'? True : False);
                }
                
                 system.debug('>>>>>>>>requestParam.TapCustomerSubType>>>>>>>>>>>'+requestParam.TapCustomerSubType!='');
                 system.debug('>>>>>>>>requestParam.TapCustomerSubType>>>>>>>>>>>'+requestParam.TapCustomerSubType);
                 
                 if(requestParam.TapCustomerSubType!=null && requestParam.TapCustomerSubType!=''){
                 acc.TAP_Customer_Sub_Type__c = requestParam.TapCustomerSubType;
                }
                
               /* if(requestParam.Resellers!= Null && requestParam.Resellers!= '')
                {
                 List<String>AcctIds = requestParam.Resellers.split('\\|');
                 
                 for(String St: AcctIds)
                 {
                        acc.Reseller_Account__r = new Account(Enterprise_Party_Number__c = St);
                 }
                 }*/
                
                 if(requestParam.CollectorName != null && requestParam.CollectorName != ''){
                 List<String>fields = requestParam.CollectorName.Split('\\|');
                      if(fields.size()==2)
                      {
                      acc.Collector_Name__c = fields.get(0);
                      acc.Collector_Email__c = fields.get(1);
                      }
                    
                }

               if(requestParam.EBSAccountNumber != null && requestParam.EBSAccountNumber != ''){ 
               acc.EBS_Account_Number__c= requestParam.EBSAccountNumber;
               }
               
               if(requestParam.Division != null && requestParam.Division != ''){
                   Acc.Account_Division__c = requestParam.division;
                } 
                system.debug('------------------'  +requestParam.AccountID + '--------');
                system.debug('------------------'  +requestParam.EnterpriseAccountNumber + '--------' + requestParam.strOperation);
                if(((requestParam.AccountID != null && requestParam.AccountID != '') || (AccList.size() > 0)) && requestParam.strOperation == 'Update'){
                    system.debug(requestParam.AccountID + '---------Update---------' + AccList);
                    if(((requestParam.AccountID != null && requestParam.AccountID != '') ? requestParam.AccountID.length() == 18 : false) 
                       || AccList.size() > 0){
                       
                        acc.Id = (AccList.size() > 0 ? AccList.get(0).Id : requestParam.AccountID);
                      if(requestParam.CustomerCreditInfoString!= null && requestParam.CustomerCreditInfoString!= ''){
                           CreateAccountfromEBS ObjInst = new CreateAccountfromEBS();
                           ObjInst.CreateCreditCheck(requestParam.CustomerCreditInfoString,String.valueof(acc.id));
                           Acc.Credit_Manager_Notified__c ='Credit Info Updated';
                      }
                        List<Reseller__c>Delreseller = new List<Reseller__c>([select id from Reseller__c where Parent_Account__c =:Acc.id]);
                        for(Account Ac : ResellerAccList){
                        Reseller__c Res = new Reseller__c();
                        Res.Reseller_Account__c = Ac.id;
                        Res.Parent_Account__c = Acc.id;
                        InsertResellerList.add(Res);
                         }
                        if(InsertResellerList.size()>0)
                        {
                         Delete Delreseller;
                         Insert InsertResellerList;
                         }
                        update acc;
                    }
                }else if((requestParam.EnterpriseAccountNumber != null && requestParam.EnterpriseAccountNumber != '' && requestParam.strOperation == 'Create') || SpecialScenario == True){
                    system.debug('---------Insert---------' );
                      if(requestParam.Country != null && requestParam.Country != ''){
                   Acc.BillingCountry = requestParam.Country;
                    }
                    acc.Account_Status__c = 'Active';
                    acc.Lifecycle_Stage__c = 'Customer';
                    insert acc;
                    List<Reseller__c>Delreseller = new List<Reseller__c>([select id from Reseller__c where Parent_Account__c =:Acc.id]); 
                   for(Account Ac : ResellerAccList){
                        Reseller__c Res = new Reseller__c();
                        Res.Reseller_Account__c = Ac.id;
                        Res.Parent_Account__c = Acc.id;
                        InsertResellerList.add(Res);
                         }
                        if(InsertResellerList.size()>0)
                        {
                         Delete Delreseller;
                         Insert InsertResellerList;
                         }
                    if(requestParam.CustomerCreditInfoString!= null && requestParam.CustomerCreditInfoString!= ''){
                       CreateAccountfromEBS ObjInst = new CreateAccountfromEBS();
                       ObjInst.CreateCreditCheck(requestParam.CustomerCreditInfoString,String.valueof(acc.id));
                    }
                }else if(requestParam.strOperation != 'NoOp'){
                    system.debug('---------error---------' );
                    errorFlag = true;
                    ResponseWrapper respvar ;
                    respvar = new ResponseWrapper();  
                    respvar.recordID = string.valueof((requestParam.AccountID != null ? requestParam.AccountID : ''));
                    respvar.EnterpriseId = (requestParam.EnterpriseAccountNumber != null ? requestParam.EnterpriseAccountNumber : '');
                    respvar.result ='Fail';
                    respvar.ErrorCode = 'CMDM-ERR-05';
                    respvar.ErrorMessage = 'Required field missing. To Insert/Update Account, SFDC Id or Enterprise Master Id is required.';
                    respvar.RecordType = 'HZ_PARTIES';
                    responselist.add(respvar);
                }
            }else if(requestParam.strOperation == 'Merge'){
                acc.FchReportingEntityNumber__c = requestParam.FchReportingEntityNumber;
                acc.FchReportingEntityPartyID__c = requestParam.FchReportingEntityPartyID;
                if(requestParam.AccountID != null && requestParam.AccountID != ''){
                    acc.Id = requestParam.AccountID;
                    update acc;
                }else if(requestParam.EnterpriseAccountNumber != null && requestParam.EnterpriseAccountNumber != ''){
                    acc.Enterprise_Party_Number__c  = requestParam.EnterpriseAccountNumber;
                    upsert acc Enterprise_Party_Number__c ;
                } 
                errorFlag = false;
            }
            
            system.debug('---------exceptionEntry---------' );
            if(!errorFlag){
                system.debug('---------exception---------' );
                ResponseWrapper respvar ;
                respvar = new ResponseWrapper();
                  system.debug('---------acc.ID---------' + acc.ID);
                if(acc.ID != null){
                    respvar.recordID = String.valueof((acc.ID != null ? acc.ID : ''));
                }else{
                    respvar.recordID =requestParam.AccountID;
                }
                respvar.EnterpriseId = (acc.Enterprise_Party_Number__c != null ? acc.Enterprise_Party_Number__c : '');
                respvar.result ='Success';
                respvar.RecordType = 'HZ_PARTIES';
                responselist.add(respvar);
            }
        }catch(Exception ex){
            errorFlag = true;
            ResponseWrapper respvar ;
            respvar = new ResponseWrapper();  
            respvar.recordID = String.valueof((requestParam.AccountID != null ? requestParam.AccountID : ''));
            respvar.EnterpriseId = (requestParam.EnterpriseAccountNumber != null ? requestParam.EnterpriseAccountNumber : '');
            respvar.result ='Fail';
            respvar.ErrorCode = 'CMDM-ERR-05';
            respvar.RecordType = 'HZ_PARTIES';
            respvar.ErrorMessage = String.valueOf(ex);
            responselist.add(respvar);
            
            Inbound_Outbound_Callouts__c errorLog = new Inbound_Outbound_Callouts__c();
            errorLog.Callout_Type__c = 'Inbound';
            errorLog.Destination_System__c = 'SFDC';
            errorLog.Source_System__c ='FCH';
            errorLog.Integration_Module__c =  'Customer Interface';
            errorLog.Error_Message__c = String.valueOf(ex);
            insert errorLog;
        }
        
        if(!errorFlag){
            system.debug('------------' + requestParam.contacts);
            
            system.debug('----requestParam.addresses--------' + requestParam.addresses);
            if(requestParam.addresses != null ? requestParam.addresses.size() > 0 : false){
                responselist.addAll(CreatePartyAddresses(requestParam.addresses));
            }
            if(requestParam.contacts != null ? requestParam.contacts.size() > 0 : false){
                responselist.addAll(CreatePartyContact(requestParam.contacts));
            }
        }
        return responselist; 
    }
    
    /*
     * Method name  : CreatePartyAddresses
     * Description  : Method to Create or Update List of Address from EBS / FCH
     * Return Type  : list<ResponseWrapper>
     * Parameter    : List<RequestAddressdata>
     */
    
    webService static list<ResponseWrapper> CreatePartyAddresses(List<RequestAddressdata> requestParamList){
    
        list<ResponseWrapper> responselist = new list<ResponseWrapper>();
        List<Address__c>InsertList = new List<Address__c>();
        List<Address__c>UpdateList = new List<Address__c>();
        List<String>FCHSiteID = new List<String>();
        MAp<String,String> AddIDMAp = new MAp<String,String>();
        for(RequestAddressdata requestParam :requestParamList){
        if(requestParam.FchPartySiteID!=Null && requestParam.FchPartySiteID!=''){
        system.debug('&&&&&&&&&&&&&&&&'+requestParam.FchPartySiteID);
        FCHSiteID.add(requestParam.FchPartySiteID);
        }
        }
        system.debug('&&&&&&&&&&&&&&&&'+FCHSiteID);
        system.debug('&&&&&&&&&&&&&&&&'+FCHSiteID.size());
        List<Address__c>AddListSc = new List<Address__c>([Select id,FCH_Party_Site_ID__c from Address__c where FCH_Party_Site_ID__c in:FCHSiteID]);
        for(Address__c Ad : AddListSc)
        {
        AddIDMAp.put(Ad.FCH_Party_Site_ID__c,Ad.id);
        system.debug('*******AddIDMAp.get().values()******'+AddIDMAp);
        }
        
        boolean errorFlag = false;
        try
        {
          Integer VarInt = 0;  
            system.debug('----requestParam.addresses--------' + requestParamList);
            for(RequestAddressdata requestParam :requestParamList){
                    system.debug(SpecialScenario + '----requestParam.addresses--------' + requestParam.AddressID);
                if(((requestParam.AddressID == Null || requestParam.AddressID =='') && requestParam.strOperation == 'Create' && AddIDMAp.get(requestParam.FchPartySiteID) == Null) 
                    || 
                        (SpecialScenario == True 
                            || 
                            ((requestParam.AddressID == Null || requestParam.AddressID == '') && requestParam.FchPartySiteID != Null && requestParam.FchPartySiteID != '' && AddIDMAp.get(requestParam.FchPartySiteID) == Null  && requestParam.strOperation == 'Update')
                        )
                    ){
                    Address__c address = new Address__c();
                    
                    // Added to Mark First Address as Primary and to Sync the Address fields of Account. 
                    VarInt = VarInt +1;
                    if(VarInt ==1 && SpecialScenario){
                    Account Ac;
                     address.Primary__c = True;
                     address.Sell_To__c = True;
                     
                     String BillStr='';
                    if(requestParam.AccountID != Null && requestParam.AccountID != '')
                        Ac = new Account(id= requestParam.AccountID);
                    else if(requestParam.EnterpriseMasterId != Null && requestParam.EnterpriseMasterId != '')
                        Ac = new Account(Enterprise_Party_Number__c = requestParam.EnterpriseMasterId);
              
                      if(requestParam.AddressLine1 != Null && requestParam.AddressLine1 != '')
                       BillStr = requestParam.AddressLine1;
                    if(requestParam.AddressLine2 != Null && requestParam.AddressLine2 != '')
                       BillStr += '\r\n' + requestParam.AddressLine2;
                    if(requestParam.AddressLine3 != Null && requestParam.AddressLine3 != '') 
                       BillStr += '\r\n' + requestParam.AddressLine3;
                    if(requestParam.AddressLine4 != Null && requestParam.AddressLine4 != '') 
                       BillStr += '\r\n' + requestParam.AddressLine4;
                       Ac.BillingStreet = BillStr;
                    if(requestParam.City != Null && requestParam.City != '') 
                        Ac.BillingCity= requestParam.City ;
                    if(requestParam.County != Null && requestParam.County != '') 
                        Ac.County__c = requestParam.County;
                    if(requestParam.Country != Null && requestParam.Country != '') 
                        Ac.BillingCountry= requestParam.Country;
                    if(requestParam.State!= Null && requestParam.State!= '') 
                        Ac.BillingState= requestParam.State;
                    if(requestParam.ZIP!= Null && requestParam.ZIP!= '') 
                        Ac.BillingPostalCode = requestParam.ZIP;
                        
                     Ac.Sell_ToFlag__c = True;
                     if(requestParam.BillTo != Null && requestParam.BillTo != '' && (requestParam.BillTo=='Yes' || requestParam.BillTo=='yes' || requestParam.BillTo=='True' || requestParam.BillTo=='true'))
                        Ac.Bill_To_Flag__c = True;
                    if(requestParam.BillTo == Null || requestParam.BillTo == '' || (requestParam.BillTo != Null && requestParam.BillTo != '' && (requestParam.BillTo=='No' || requestParam.BillTo=='no' || requestParam.BillTo=='False' || requestParam.BillTo=='false')))
                        Ac.Bill_To_Flag__c = False;
                    if(requestParam.ShipTo != Null && requestParam.ShipTo != '' && (requestParam.ShipTo =='Yes' || requestParam.ShipTo =='yes' || requestParam.ShipTo=='True' || requestParam.ShipTo=='true'))
                        Ac.Ship_To_Flag__c = True;
                    if(requestParam.ShipTo == Null || requestParam.ShipTo == '' || (requestParam.ShipTo != Null && requestParam.ShipTo != '' && (requestParam.ShipTo =='No' || requestParam.ShipTo =='no' || requestParam.ShipTo=='False' || requestParam.ShipTo=='false')))
                        Ac.Ship_To_Flag__c = False;
                    if(requestParam.InstalledAt != Null && requestParam.InstalledAt != '' && (requestParam.InstalledAt =='Yes' || requestParam.InstalledAt =='yes' || requestParam.InstalledAt=='True' || requestParam.InstalledAt=='true'))
                        Ac.Installed_At_Flag__c = True;
                    if(requestParam.InstalledAt == Null && requestParam.InstalledAt == '' || (requestParam.InstalledAt =='No' || requestParam.InstalledAt =='no' || requestParam.InstalledAt=='False' || requestParam.InstalledAt=='false'))
                        Ac.Installed_At_Flag__c = False;
                    if(requestParam.EndUser != Null && requestParam.EndUser != '' && (requestParam.EndUser =='Yes' || requestParam.EndUser =='yes' || requestParam.EndUser=='True' || requestParam.EndUser=='true'))
                        Ac.End_User_Flag__c = True;
                    if(requestParam.EndUser == Null && requestParam.EndUser == '' || (requestParam.EndUser =='No' || requestParam.EndUser =='no' || requestParam.EndUser=='False' || requestParam.EndUser=='false'))
                        Ac.End_User_Flag__c = False;
                    
                     upsert Ac Enterprise_Party_Number__c;
                     }
                     if(requestParam.RestrictedPartyIndicator != Null && requestParam.RestrictedPartyIndicator!= '')
                        address.Restricted_Party_Indicator__c = requestParam.RestrictedPartyIndicator;
                        
                         if(requestParam.AnniversaryDate != Null)
                        address.Anniversary_Date__c = requestParam.AnniversaryDate;
                         if(requestParam.TaxRegNumber != Null && requestParam.TaxRegNumber != '')
                        address.Tax_Reg_Number__c = requestParam.TaxRegNumber;
                   if(requestParam.SiteName != Null && requestParam.SiteName!= '')
                        address.Site_Name__c = requestParam.SiteName;
                    
                    if(requestParam.AddressLine1 != Null && requestParam.AddressLine1 != '')
                        address.Address_line1__c = requestParam.AddressLine1;
                        system.debug('>>>>>>country>>>>>>>>>>'+requestParam.Country);
                        system.debug('>>>>>>>addressline2>>>>>>>>>'+requestParam.AddressLine2);
                        system.debug('>>>>>>>requestParam.Country.equalsIgnoreCase>>>>>>>>>'+requestParam.Country.equalsIgnoreCase('Brazil'));
                        system.debug('>>>>>>>requestParam.Country.equalsIgnoreCase>>>>>>>>>'+requestParam.Country.length());
                        system.debug('>>>>>>>requestParam.Country.equalsIgnoreCase>>>>>>>>>'+requestParam.Country != Null);
                        system.debug('>>>>>>>requestParam.Country.equalsIgnoreCase>>>>>>>>>'+requestParam.Country != '');
                        system.debug('>>>>>>>requestParam.Country.equalsIgnoreCase>>>>>>>>>'+requestParam.AddressLine2 != '');
                        
                    if(requestParam.Country != Null && requestParam.Country != '' && requestParam.Country.equalsIgnoreCase('Brazil')){
                    
                    system.debug('>>>>>Inside BR Country>>>>>>'+requestParam.Country);
                    if(requestParam.AddressLine2 != Null && requestParam.AddressLine2 != '')
                    {
                        address.Address_line2__c = requestParam.AddressLine2;
                        address.Brazilian_Neighborhood__c = requestParam.AddressLine2;
                        system.debug('>>>>>Inside BR NEigh>>>>>>'+requestParam.AddressLine2);
                        }
                    if(requestParam.City != Null && requestParam.City != '') {
                        address.Brazilian_City__c = requestParam.City ;
                        address.City__c = requestParam.City ;
                        }
                        address.County__c = 'BR';
                        address.Country__c = 'Brazil';
                    if(requestParam.State!= Null && requestParam.State!= '') {
                        address.Brazilian_State__c = requestParam.State; 
                        address.State__c= requestParam.State;
                        }
                        }
                    else {
                    if(requestParam.AddressLine2 != Null && requestParam.AddressLine2 != '')
                         address.Address_line2__c = requestParam.AddressLine2;
                     if(requestParam.City != Null && requestParam.City != '') 
                        address.City__c = requestParam.City ;
                    if(requestParam.County != Null && requestParam.County != '') 
                        address.County__c = requestParam.County;
                    if(requestParam.Country != Null && requestParam.Country != '') 
                        address.Country__c = requestParam.Country;
                    if(requestParam.State!= Null && requestParam.State!= '') 
                        address.State__c = requestParam.State;    
                         }
                    if(requestParam.AddressLine3 != Null && requestParam.AddressLine3 != '') 
                        address.Address_line3__c = requestParam.AddressLine3;
                    if(requestParam.AddressLine4 != Null && requestParam.AddressLine4 != '') 
                        address.Address_line4__c = requestParam.AddressLine4;
                    if(requestParam.ZIP!= Null && requestParam.ZIP!= '') 
                        address.Zip__c = requestParam.ZIP;
                    if(requestParam.BillTo != Null && requestParam.BillTo != '' && (requestParam.BillTo=='Yes' || requestParam.BillTo=='yes' || requestParam.BillTo=='True' || requestParam.BillTo=='true'))
                        address.Bill_to__c = True;
                    if(requestParam.BillTo == Null || requestParam.BillTo == '' || (requestParam.BillTo != Null && requestParam.BillTo != '' && (requestParam.BillTo=='No' || requestParam.BillTo=='no' || requestParam.BillTo=='False' || requestParam.BillTo=='false')))
                        address.Bill_to__c = False;
                    if(requestParam.ShipTo != Null && requestParam.ShipTo != '' && (requestParam.ShipTo =='Yes' || requestParam.ShipTo =='yes' || requestParam.ShipTo=='True' || requestParam.ShipTo=='true'))
                        address.Ship_to__c = True;
                    if(requestParam.ShipTo == Null || requestParam.ShipTo == '' || (requestParam.ShipTo != Null && requestParam.ShipTo != '' && (requestParam.ShipTo =='No' || requestParam.ShipTo =='no' || requestParam.ShipTo=='False' || requestParam.ShipTo=='false')))
                        address.Ship_to__c = False;
                    if(requestParam.InstalledAt != Null && requestParam.InstalledAt != '' && (requestParam.InstalledAt =='Yes' || requestParam.InstalledAt =='yes' || requestParam.InstalledAt=='True' || requestParam.InstalledAt=='true'))
                        address.Installed_at__c= True;
                    if(requestParam.InstalledAt == Null || requestParam.InstalledAt == '' || (requestParam.InstalledAt =='No' || requestParam.InstalledAt =='no' || requestParam.InstalledAt=='False' || requestParam.InstalledAt=='false'))
                        address.Installed_at__c= False;
                    if(requestParam.EndUser != Null && requestParam.EndUser != '' && (requestParam.EndUser =='Yes' || requestParam.EndUser =='yes' || requestParam.EndUser=='True' || requestParam.EndUser=='true'))
                        address.End_User__c= True;
                    if(requestParam.EndUser == Null && requestParam.EndUser == '' || (requestParam.EndUser =='No' || requestParam.EndUser =='no' || requestParam.EndUser=='False' || requestParam.EndUser=='false'))
                        address.End_User__c= False;
                    if(requestParam.SellTo != Null && requestParam.SellTo != '' && (requestParam.SellTo =='Yes' || requestParam.SellTo =='yes' || requestParam.SellTo=='True' || requestParam.SellTo=='true'))
                        address.Sell_to__c= True;
                    if(requestParam.SellTo == Null && requestParam.SellTo == '' || (requestParam.SellTo =='No' || requestParam.SellTo =='no' || requestParam.SellTo=='False' || requestParam.SellTo=='false'))
                        address.Sell_to__c= False;
                    
                    if(requestParam.AccountID != Null && requestParam.AccountID != '')
                        address.Account__c = requestParam.AccountID;
                    else if(requestParam.EnterpriseMasterId != Null && requestParam.EnterpriseMasterId != '')
                        address.Account__r = new Account(Enterprise_Party_Number__c = requestParam.EnterpriseMasterId);
                    if(requestParam.EnterpriseAddressNumber != Null && requestParam.EnterpriseAddressNumber != '') 
                        address.Enterprise_Address_Number__c = requestParam.EnterpriseAddressNumber;
                    if(requestParam.AddressValidatorFlag != Null && requestParam.AddressValidatorFlag != '' && (requestParam.AddressValidatorFlag =='Y' || requestParam.AddressValidatorFlag =='y')) {
                        address.Address_Validated_Flag__c = True;
                        address.Validation_Status__c = 'Corrected';
                        }
                    else{
                        address.Address_Validated_Flag__c = False;
                        address.Validation_Status__c = 'Not Corrected';
                        }
                    if(requestParam.FchPartySiteID != Null && requestParam.FchPartySiteID != '')
                        address.FCH_Party_Site_ID__c = requestParam.FchPartySiteID;
                   system.debug('>>>>>>>>>>>>>>>>requestParam.RestrictedPartyIndicator>>>>>>>>>>>>>>>>>>'+requestParam.RestrictedPartyIndicator); 
                   
                   //Added for TAP division
                   
                    if(requestParam.industry!= Null && requestParam.industry!= '') 
                        address.Industry__c = requestParam.industry;
                    if(requestParam.Salesperson!= Null && requestParam.Salesperson!= '') 
                        address.Sales_Person__c = requestParam.Salesperson;
                    if(requestParam.pricelistid!= Null && requestParam.pricelistid!= '') 
                        address.Price_List__c = requestParam.pricelistid;
                    if(requestParam.activationemail!= Null && requestParam.activationemail!= '' && (requestParam.activationemail =='Y' || requestParam.activationemail=='y' || requestParam.activationemail=='True' || requestParam.activationemail=='true')) 
                        address.Activation_Email__c = True;
                      if(requestParam.activationemail!= Null && requestParam.activationemail!= '' && (requestParam.activationemail =='N' || requestParam.activationemail=='n' || requestParam.activationemail=='False' || requestParam.activationemail=='false')) 
                     address.Activation_Email__c = False;
                   if(requestParam.Active!= Null && requestParam.Active!= '' && (requestParam.Active=='Y' || requestParam.Active=='y' || requestParam.Active=='True' || requestParam.Active=='true')) 
                        address.Active__c= True;
                     if(requestParam.Active!= Null && requestParam.Active!= '' && (requestParam.Active=='N' || requestParam.Active=='n' || requestParam.Active=='False' || requestParam.Active=='false')) 
                      address.Active__c = False;
                     
                       if(requestParam.TapPOSFlag != Null && requestParam.TapPOSFlag != '' && (requestParam.TapPOSFlag =='Y' || requestParam.TapPOSFlag =='y' || requestParam.TapPOSFlag =='True' || requestParam.TapPOSFlag =='true')) 
                        address.POS_Flag__c = True;
                       if(requestParam.TapPOSFlag != Null && requestParam.TapPOSFlag != '' && (requestParam.TapPOSFlag =='N' || requestParam.TapPOSFlag =='n' || requestParam.TapPOSFlag =='False' || requestParam.TapPOSFlag =='false')) 
                       address.POS_Flag__c = False;
                        
                    if(requestParam.TaxNumber!= Null && requestParam.TaxNumber!= '') 
                        address.Tax_Number__c = requestParam.TaxNumber;
                    if(requestParam.custpayablecontacttype1!= Null && requestParam.custpayablecontacttype1!= '') 
                        address.Customer_Type_1__c = requestParam.custpayablecontacttype1;
                    if(requestParam.custpayablecontacttype2!= Null && requestParam.custpayablecontacttype2!= '') 
                        address.Customer_Type_2__c = requestParam.custpayablecontacttype2;
                    if(requestParam.custpayablecontacttype3!= Null && requestParam.custpayablecontacttype3!= '') 
                        address.Customer_Type_3__c = requestParam.custpayablecontacttype3;
                    if(requestParam.custpayablecontacttype4!= Null && requestParam.custpayablecontacttype4!= '') 
                        address.Customer_Type_4__c = requestParam.custpayablecontacttype4;
                    if(requestParam.custpayablecontactvalue1 != Null && requestParam.custpayablecontactvalue1!= '') 
                        address.Customer_Value_1__c = requestParam.custpayablecontactvalue1;
                    if(requestParam.custpayablecontactvalue2 != Null && requestParam.custpayablecontactvalue2!= '') 
                        address.Customer_Value_2__c = requestParam.custpayablecontactvalue2;
                    if(requestParam.custpayablecontactvalue3 != Null && requestParam.custpayablecontactvalue3 != '') 
                        address.Customer_Value_3__c = requestParam.custpayablecontactvalue3;
                    if(requestParam.custpayablecontactvalue4 != Null && requestParam.custpayablecontactvalue4!= '') 
                        address.Customer_Value_4__c = requestParam.custpayablecontactvalue4;
                    if(requestParam.BillToLocation!= Null && requestParam.BillToLocation!= '') 
                        address.Bill_To_Location__c = requestParam.BillToLocation;
                    if(requestParam.ShipToLocation!= Null && requestParam.ShipToLocation!= '') 
                        address.Ship_To_Location__c = requestParam.ShipToLocation;
                    if(requestParam.TapInvGroupingOption!= Null && requestParam.TapInvGroupingOption!= '') 
                        address.TapInv_Grp_Option__c= requestParam.TapInvGroupingOption;
                     
                    InsertList.add(address);
                     
                }else if((requestParam.AddressID != Null && requestParam.AddressID != Null && requestParam.strOperation == 'Update') || (AddIDMAp.get(requestParam.FchPartySiteID) != Null && requestParam.strOperation == 'Create')){
                    Address__c address = new Address__c(id= AddIDMAp.get(requestParam.FchPartySiteID) != Null ? AddIDMAp.get(requestParam.FchPartySiteID) : requestParam.AddressID);
                    system.debug('>>>>>>>>>>>>>>>>requestParam.RestrictedPartyIndicator>>>>>>>>>>>>>>>>>>'+requestParam.RestrictedPartyIndicator);  
                  if(requestParam.RestrictedPartyIndicator != Null && requestParam.RestrictedPartyIndicator!= '')
                        address.Restricted_Party_Indicator__c = requestParam.RestrictedPartyIndicator;
                         if(requestParam.AnniversaryDate != Null)
                        address.Anniversary_Date__c = requestParam.AnniversaryDate;
                         if(requestParam.TaxRegNumber != Null && requestParam.TaxRegNumber != '')
                        address.Tax_Reg_Number__c = requestParam.TaxRegNumber;
                   if(requestParam.SiteName != Null && requestParam.SiteName!= '')
                        address.Site_Name__c = requestParam.SiteName;
                    if(requestParam.AddressLine1 != Null && requestParam.AddressLine1 != '')
                        address.Address_line1__c = requestParam.AddressLine1;
                     if(requestParam.Country != Null && requestParam.Country != '' && requestParam.Country.equalsIgnoreCase('Brazil')){
                    if(requestParam.AddressLine2 != Null && requestParam.AddressLine2 != '')
                        address.Brazilian_Neighborhood__c = requestParam.AddressLine2;
                    if(requestParam.City != Null && requestParam.City != '') {
                        address.Brazilian_City__c = requestParam.City ;
                        address.City__c = requestParam.City ;
                        }
                        address.County__c = 'BR';
                        address.Country__c = 'Brazil';
                    if(requestParam.State!= Null && requestParam.State!= '') {
                        address.Brazilian_State__c = requestParam.State; 
                        address.State__c = requestParam.State;
                        }
                        }
                    else {
                    if(requestParam.AddressLine2 != Null && requestParam.AddressLine2 != '')
                         address.Address_line2__c = requestParam.AddressLine2;
                     if(requestParam.City != Null && requestParam.City != '') 
                        address.City__c = requestParam.City ;
                    if(requestParam.County != Null && requestParam.County != '') 
                        address.County__c = requestParam.County;
                    if(requestParam.Country != Null && requestParam.Country != '') 
                        address.Country__c = requestParam.Country;
                    if(requestParam.State!= Null && requestParam.State!= '') 
                        address.State__c = requestParam.State;    
                         }
                    if(requestParam.AddressLine3 != Null && requestParam.AddressLine3 != '') 
                        address.Address_line3__c = requestParam.AddressLine3;
                    if(requestParam.AddressLine4 != Null && requestParam.AddressLine4 != '') 
                        address.Address_line4__c = requestParam.AddressLine4;
                    if(requestParam.ZIP!= Null && requestParam.ZIP!= '') 
                        address.Zip__c = requestParam.ZIP;
                    if(requestParam.Language!=Null && requestParam.Language!='')
                    address.Preferred_Language__c = requestParam.Language;
                    if(requestParam.BillTo != Null && requestParam.BillTo != '' && (requestParam.BillTo=='Yes' || requestParam.BillTo=='yes' || requestParam.BillTo=='True' || requestParam.BillTo=='true'))
                        address.Bill_to__c = True;
                    if(requestParam.BillTo == Null || requestParam.BillTo == '' || (requestParam.BillTo != Null && requestParam.BillTo != '' && (requestParam.BillTo=='No' || requestParam.BillTo=='no' || requestParam.BillTo=='False' || requestParam.BillTo=='false')))
                        address.Bill_to__c = False;
                    if(requestParam.ShipTo != Null && requestParam.ShipTo != '' && (requestParam.ShipTo =='Yes' || requestParam.ShipTo =='yes' || requestParam.ShipTo=='True' || requestParam.ShipTo=='true'))
                        address.Ship_to__c = True;
                    if(requestParam.ShipTo == Null || requestParam.ShipTo == '' || (requestParam.ShipTo != Null && requestParam.ShipTo != '' && (requestParam.ShipTo =='No' || requestParam.ShipTo =='no' || requestParam.ShipTo=='False' || requestParam.ShipTo=='false')))
                        address.Ship_to__c = False;
                    if(requestParam.InstalledAt != Null && requestParam.InstalledAt != '' && (requestParam.InstalledAt =='Yes' || requestParam.InstalledAt =='yes' || requestParam.InstalledAt=='True' || requestParam.InstalledAt=='true'))
                        address.Installed_at__c= True;
                    if(requestParam.InstalledAt == Null && requestParam.InstalledAt == '' || (requestParam.InstalledAt =='No' || requestParam.InstalledAt =='no' || requestParam.InstalledAt=='False' || requestParam.InstalledAt=='false'))
                        address.Installed_at__c= False;
                    if(requestParam.EndUser != Null && requestParam.EndUser != '' && (requestParam.EndUser =='Yes' || requestParam.EndUser =='yes' || requestParam.EndUser=='True' || requestParam.EndUser=='true'))
                        address.End_User__c= True;
                    if(requestParam.EndUser == Null && requestParam.EndUser == '' || (requestParam.EndUser =='No' || requestParam.EndUser =='no' || requestParam.EndUser=='False' || requestParam.EndUser=='false'))
                        address.End_User__c= False;
                    if(requestParam.SellTo != Null && requestParam.SellTo != '' && (requestParam.SellTo =='Yes' || requestParam.SellTo =='yes' || requestParam.SellTo=='True' || requestParam.SellTo=='true'))
                        address.Sell_to__c= True;
                    if(requestParam.SellTo == Null && requestParam.SellTo == '' || (requestParam.SellTo =='No' || requestParam.SellTo =='no'|| requestParam.SellTo=='False' || requestParam.SellTo=='false'))
                        address.Sell_to__c= False;
                    
                    if(requestParam.AccountID != Null && requestParam.AccountID != '')
                        address.Account__c = requestParam.AccountID;
                    else if(requestParam.EnterpriseMasterId != Null && requestParam.EnterpriseMasterId != '')
                        address.Account__r = new Account(Enterprise_Party_Number__c = requestParam.EnterpriseMasterId);
                    if(requestParam.EnterpriseAddressNumber != Null && requestParam.EnterpriseAddressNumber != '') 
                        address.Enterprise_Address_Number__c = requestParam.EnterpriseAddressNumber;
                    if(requestParam.AddressValidatorFlag != Null && requestParam.AddressValidatorFlag != '' && (requestParam.AddressValidatorFlag =='Y' || requestParam.AddressValidatorFlag =='y')) {
                        address.Address_Validated_Flag__c = True;
                        address.Validation_Status__c = 'Corrected';
                        }
                    else{
                        address.Address_Validated_Flag__c = False;
                        address.Validation_Status__c = 'Not Corrected';
                        }
                    if(requestParam.FchPartySiteID != Null && requestParam.FchPartySiteID != '')
                        address.FCH_Party_Site_ID__c = requestParam.FchPartySiteID;
                     
                     //Added for TAP division
                   
                    if(requestParam.industry!= Null && requestParam.industry!= '') 
                        address.Industry__c = requestParam.industry;
                    if(requestParam.Salesperson!= Null && requestParam.Salesperson!= '') 
                        address.Sales_Person__c = requestParam.Salesperson;
                    if(requestParam.pricelistid!= Null && requestParam.pricelistid!= '') 
                        address.Price_List__c = requestParam.pricelistid;
                    if(requestParam.activationemail!= Null && requestParam.activationemail!= '' && (requestParam.activationemail =='Y' || requestParam.activationemail=='y' || requestParam.activationemail=='True' || requestParam.activationemail=='true')) 
                        address.Activation_Email__c = True;
                     if(requestParam.activationemail!= Null && requestParam.activationemail!= '' && (requestParam.activationemail =='N' || requestParam.activationemail=='n' || requestParam.activationemail=='False' || requestParam.activationemail=='false')) 
                        address.Activation_Email__c = False;
                   if(requestParam.Active!= Null && requestParam.Active!= '' && (requestParam.Active=='Y' || requestParam.Active=='y' || requestParam.Active=='True' || requestParam.Active=='true')) 
                        address.Active__c= True;
                      if(requestParam.Active!= Null && requestParam.Active!= '' && (requestParam.Active=='N' || requestParam.Active=='n' || requestParam.Active=='False' || requestParam.Active=='false')) 
                       address.Active__c = False;
                      
                    if(requestParam.TapPOSFlag != Null && requestParam.TapPOSFlag != '' && (requestParam.TapPOSFlag =='Y' || requestParam.TapPOSFlag =='y' || requestParam.TapPOSFlag =='True' || requestParam.TapPOSFlag =='true')) 
                        address.POS_Flag__c = True;
                        if(requestParam.TapPOSFlag != Null && requestParam.TapPOSFlag != '' && (requestParam.TapPOSFlag =='N' || requestParam.TapPOSFlag =='n' || requestParam.TapPOSFlag =='False' || requestParam.TapPOSFlag =='false')) 
                        address.POS_Flag__c = False;
                        
                    if(requestParam.TaxNumber!= Null && requestParam.TaxNumber!= '') 
                        address.Tax_Number__c = requestParam.TaxNumber;
                       if(requestParam.custpayablecontacttype1!= Null && requestParam.custpayablecontacttype1!= '') 
                        address.Customer_Type_1__c = requestParam.custpayablecontacttype1;
                    if(requestParam.custpayablecontacttype2!= Null && requestParam.custpayablecontacttype2!= '') 
                        address.Customer_Type_2__c = requestParam.custpayablecontacttype2;
                    if(requestParam.custpayablecontacttype3!= Null && requestParam.custpayablecontacttype3!= '') 
                        address.Customer_Type_3__c = requestParam.custpayablecontacttype3;
                    if(requestParam.custpayablecontacttype4!= Null && requestParam.custpayablecontacttype4!= '') 
                        address.Customer_Type_4__c = requestParam.custpayablecontacttype4;
                    if(requestParam.custpayablecontactvalue1 != Null && requestParam.custpayablecontactvalue1!= '') 
                        address.Customer_Value_1__c = requestParam.custpayablecontactvalue1;
                    if(requestParam.custpayablecontactvalue2 != Null && requestParam.custpayablecontactvalue2!= '') 
                        address.Customer_Value_2__c = requestParam.custpayablecontactvalue2;
                    if(requestParam.custpayablecontactvalue3 != Null && requestParam.custpayablecontactvalue3 != '') 
                        address.Customer_Value_3__c = requestParam.custpayablecontactvalue3;
                    if(requestParam.custpayablecontactvalue4 != Null && requestParam.custpayablecontactvalue4!= '') 
                        address.Customer_Value_4__c = requestParam.custpayablecontactvalue4;
                      if(requestParam.BillToLocation!= Null && requestParam.BillToLocation!= '') 
                        address.Bill_To_Location__c = requestParam.BillToLocation;
                    if(requestParam.ShipToLocation!= Null && requestParam.ShipToLocation!= '') 
                        address.Ship_To_Location__c = requestParam.ShipToLocation;
                    if(requestParam.TapInvGroupingOption!= Null && requestParam.TapInvGroupingOption!= '') 
                        address.TapInv_Grp_Option__c= requestParam.TapInvGroupingOption;  
                        
                    
                    UpdateList.add(address);

                }else if(requestParam.AccountID == Null && requestParam.strOperation != 'NoOp'){
                    ResponseWrapper respvar ;
                    respvar = new ResponseWrapper(); 
                    respvar.recordID = requestParam.AddressID != Null ? requestParam.AddressID : '';
                    respvar.EnterpriseId = requestParam.EnterpriseAddressNumber != Null ? requestParam.EnterpriseAddressNumber : '';
                    respvar.result ='Failure';
                    respvar.ErrorCode = 'SFDC Account ID';
                    respvar.ErrorMessage = 'Mandatory Value SFDC Account ID Missing';
                    respvar.RecordType = 'HZ_PARTY_SITES';
                    responselist.add(respvar);
                }
        
            }
            if(InsertList.size()>0)
                insert InsertList;
            if(UpdateList.size()>0)
                update UpdateList;
            
            for(Address__c add : insertList){
            system.debug('>>>>>>>>Inside Address Success>>>>>>'+add.id);
            system.debug('>>>>>>>>Inside Address Success>>>>>>'+add.FCH_Party_Site_ID__c);
            AddressMap.put(add.FCH_Party_Site_ID__c ,add.ID);
                ResponseWrapper respvar ;
                respvar = new ResponseWrapper();  
                respvar.recordID = String.valueof((add.ID != null ? add.ID : ''));
                respvar.EnterpriseId = (add.Enterprise_Address_Number__c != null ? add.Enterprise_Address_Number__c : '');
                respvar.result ='Success';
                respvar.RecordType = 'HZ_PARTY_SITES';
                responselist.add(respvar);
                
            }
            
            for(Address__c add : UpdateList){
           system.debug('>>>>>>>>Inside Address Success>>>>>>'+add.id);
            system.debug('>>>>>>>>Inside Address Success>>>>>>'+add.FCH_Party_Site_ID__c);
            AddressMap.put(add.FCH_Party_Site_ID__c ,add.ID);
                ResponseWrapper respvar ;
                respvar = new ResponseWrapper();  
                respvar.recordID = String.valueof((add.ID != null ? add.ID : ''));
                respvar.EnterpriseId = (add.Enterprise_Address_Number__c != null ? add.Enterprise_Address_Number__c : '');
                respvar.result ='Success';
                respvar.RecordType = 'HZ_PARTY_SITES';
                responselist.add(respvar);
            }
        }catch(Exception ex){
            errorFlag = true;
            system.debug('------------ex----------' + ex);
            Inbound_Outbound_Callouts__c errorLog = new Inbound_Outbound_Callouts__c();
            errorLog.Callout_Type__c = 'Inbound';
            errorLog.Destination_System__c = 'FCH';
            errorLog.Source_System__c ='SFDC';
            errorLog.Integration_Module__c =  'Customer Interface';
            errorLog.Error_Message__c = String.valueof(ex).left(255);
            insert errorLog;
            system.debug('------------ex----------' + ex);
              
            ResponseWrapper respvar ;
            respvar = new ResponseWrapper();  
            respvar.result ='Failure';
            respvar.ErrorCode = 'SOA - SFDC Inbound - CreatePartyAddresses';
            respvar.RecordType = 'HZ_PARTY_SITES';
            respvar.ErrorMessage = String.valueof(ex);
            responselist.add(respvar);
        }
        
        
        return responselist;
    }
    
    
    
    /*
     * Method name  : CreatePartyContact
     * Description  : Method to Create or Update List of Contact from EBS / FCH
     * Return Type  : list<ResponseWrapper>
     * Parameter    : List<RequestContactData>
     */
    webService static list<ResponseWrapper> CreatePartyContact(List<RequestContactData> requestParamList){
    
    
    List<Account>AccList = new List<Account>();
    AccList = [select id from Account where Enterprise_Party_Number__c=: GlobalrequestParam.EnterpriseAccountNumber];     
        list<ResponseWrapper> responselist = new list<ResponseWrapper>();
        List<Contact>InsertList = new List<Contact>();
        List<Contact>UpdateList = new List<Contact>();
        List<String>AddFCHId = new List<String>();
        try{
        for(RequestContactData requestParam :requestParamList){
        AddFCHId.add(requestParam.addressid);
        }
        system.debug('>>>AddFCHId>>>'+AddFCHId);
        
        for(Address__c Add : [select id,FCH_Party_Site_ID__c from Address__c where FCH_Party_Site_ID__c in:AddFCHId])
        {
         AddressMap.put(Add.FCH_Party_Site_ID__c,Add.id);
        }
        system.debug('>>>AddressMap>>>'+AddressMap);
            for(RequestContactData requestParam :requestParamList){
                if(((GlobalrequestParam.EnterpriseAccountNumber != null && GlobalrequestParam.EnterpriseAccountNumber != '' )
                    || (requestParam.AccountID != Null && requestParam.AccountID != '')) && 
                    ((requestParam.EnterpriseContactNumber != null && requestParam.EnterpriseContactNumber != '' )
                    || (requestParam.ContactID != Null && requestParam.ContactID != ''))){
                    if((GlobalrequestParam.EnterpriseAccountNumber != Null && GlobalrequestParam.EnterpriseAccountNumber != '' && requestParam.strOperation == 'Create' && AccList.size()>0) || (SpecialScenario == True && requestParam.FchContactID != Null && requestParam.FchContactID != '')){
                        Contact con = new Contact();
                        if(requestParam.FirstName != Null && requestParam.FirstName !='')
                            con.FirstName = requestParam.FirstName;
                        if(requestParam.LastName!= Null && requestParam.LastName!= '')
                            con.LastName= requestParam.LastName; 
                        if(requestParam.Email!= Null && requestParam.Email!= '')
                            con.Email= requestParam.Email;
                        if(requestParam.CellPhone!= Null && requestParam.CellPhone!= '')
                            con.MobilePhone= requestParam.CellPhone;
                        if(requestParam.Fax!= Null && requestParam.Fax!= '')
                            con.Fax= requestParam.Fax;
                        if(requestParam.HomePhone!= Null && requestParam.HomePhone!= '')
                            con.HomePhone= requestParam.HomePhone;
                        if(requestParam.Phone!= Null && requestParam.Phone!= '')
                            con.Phone= requestParam.Phone;
                        if(requestParam.PreferredLanguage != Null && requestParam.PreferredLanguage != '')
                            con.Preferred_Language__c= requestParam.PreferredLanguage; 
                        con.Primary_Contact__c = requestParam.IsPrimary;
                        con.Bill_to__c = requestParam.Billto;
                        con.Sell_to__c = requestParam.Shipto;
                        con.Acknowledgement__c = requestParam.Acknowledgement;
                        con.Invoice__c = requestParam.Invoice;
                        con.Legal__c = requestParam.Legal;
                        con.MailingCountry = requestParam.Attribute1;
                       // if(requestParam.AccountID != Null && requestParam.AccountID != '')
                            con.AccountID= AccList.get(0).id;
                       /* else if(requestParam.EnterpriseMasterId != Null && requestParam.EnterpriseMasterId != '')
                            con.Account = new Account(Enterprise_Party_Number__c = requestParam.EnterpriseMasterId);*/
                        if(requestParam.FchContactID != Null && requestParam.FchContactID != '')
                            con.FCH_Contact_Id__c= requestParam.FchContactID;
                        if(requestParam.FchCellPhoneID != Null && requestParam.FchCellPhoneID != '')
                            con.FCH_Cell_Phone_Id__c= requestParam.FchCellPhoneID;
                        if(requestParam.FchFaxID != Null && requestParam.FchFaxID!= '')
                            con.FCH_Fax_Id__c= requestParam.FchFaxID;
                        if(requestParam.FchHomePhoneID != Null && requestParam.FchHomePhoneID != '')
                            con.Fch_Home_Phone_Id__c= requestParam.FchHomePhoneID;
                        if(requestParam.FchPhoneID != Null && requestParam.FchPhoneID != '')
                            con.Fch_Phone_Id__c= requestParam.FchPhoneID;
                        if(requestParam.FchEmailID != Null && requestParam.FchEmailID != '')
                            con.FCH_Email_Id__c = requestParam.FchEmailID;
                        if(requestParam.EnterpriseContactNumber != Null && requestParam.EnterpriseContactNumber != '')
                            con.Enterprise_Contact_Number__c= requestParam.EnterpriseContactNumber;
                       
                        //Added for TAP
                        if(requestParam.addressid!= Null && requestParam.addressid!= '' && AddressMap.get(requestParam.addressid) != Null){
                            con.Address__c = AddressMap.get(requestParam.addressid);
                            con.MarketingListTAP__c = True;
                            }
                        if(requestParam.addressidtype != Null && requestParam.addressidtype != '')
                            con.Address_ID_Type__c = requestParam.addressidtype;
                        /*if(requestParam.emailinvoice!= Null && requestParam.emailinvoice!= '' && (requestParam.emailinvoice=='Y' || requestParam.emailinvoice=='y' || requestParam.emailinvoice=='True' || requestParam.emailinvoice=='true')) 
                        Con.Email_Invoice__c = True;
                        if(requestParam.emailinvoice!= Null && requestParam.emailinvoice!= '' && (requestParam.emailinvoice=='N' || requestParam.emailinvoice=='n' || requestParam.emailinvoice=='False' || requestParam.emailinvoice=='false')) 
                        Con.Email_Invoice__c = False;*/
                        if(requestParam.emailrenewal != Null && requestParam.emailrenewal != '' && (requestParam.emailrenewal =='Y' || requestParam.emailrenewal =='y' || requestParam.emailrenewal =='True' || requestParam.emailrenewal =='true')) 
                        Con.Email_Renewal__c = True;
                        if(requestParam.emailrenewal != Null && requestParam.emailrenewal != '' && (requestParam.emailrenewal =='N' || requestParam.emailrenewal =='n' || requestParam.emailrenewal =='False' || requestParam.emailrenewal =='false')) 
                        Con.Email_Renewal__c = False;
                       /* if(requestParam.printinvoice != Null && requestParam.printinvoice != '' && (requestParam.printinvoice =='Y' || requestParam.printinvoice =='y' || requestParam.printinvoice =='True' || requestParam.printinvoice =='true')) 
                        Con.Print_Invoice__c= True;
                        if(requestParam.printinvoice != Null && requestParam.printinvoice != '' && (requestParam.printinvoice =='N' || requestParam.printinvoice =='n' || requestParam.printinvoice =='False' || requestParam.printinvoice =='false')) 
                        Con.Print_Invoice__c = False;*/
                        if(requestParam.mktlisttap != Null && requestParam.mktlisttap != '' && (requestParam.mktlisttap =='Y' || requestParam.mktlisttap =='y' || requestParam.mktlisttap =='True' || requestParam.mktlisttap=='true')) 
                        Con.MarketingListTAP__c = True;
                        if(requestParam.mktlisttap != Null && requestParam.mktlisttap != '' && (requestParam.mktlisttap =='N' || requestParam.mktlisttap =='n' || requestParam.mktlisttap =='False' || requestParam.mktlisttap=='false')) 
                        Con.MarketingListTAP__c = False;
                        
                        if(requestParam.emailinvoice!= Null && requestParam.emailinvoice!= '' && requestParam.emailinvoice=='true') 
                        Con.Invoice_Delivery_Method__c = 'Email';
                        if(requestParam.printinvoice != Null && requestParam.printinvoice != '' && requestParam.printinvoice =='true') 
                        Con.Invoice_Delivery_Method__c = 'Print';
                        if((requestParam.emailinvoice!= Null && requestParam.emailinvoice!= '' && requestParam.emailinvoice=='true') && (requestParam.printinvoice != Null && requestParam.printinvoice != '' && requestParam.printinvoice =='true'))
                        Con.Invoice_Delivery_Method__c = 'Both';
                        
                        InsertList.add(con);
                    }else if(requestParam.ContactID != Null && requestParam.ContactID != '' && requestParam.strOperation == 'Update'){
                        Contact Con = new Contact(id=requestParam.ContactID);
        
                        if(requestParam.FirstName != Null && requestParam.FirstName != '')
                            con.FirstName= requestParam.FirstName;
                        if(requestParam.LastName!= Null && requestParam.LastName!= '')
                            con.LastName= requestParam.LastName;
                        if(requestParam.Email!= Null && requestParam.Email!= '')
                            con.Email= requestParam.Email;
                        if(requestParam.CellPhone!= Null && requestParam.CellPhone!= '')
                            con.MobilePhone= requestParam.CellPhone;
                        if(requestParam.Fax!= Null && requestParam.Fax!= '')
                            con.Fax= requestParam.Fax;
                        if(requestParam.HomePhone!= Null && requestParam.HomePhone!= '')
                            con.HomePhone= requestParam.HomePhone;
                        if(requestParam.Phone!= Null && requestParam.Phone!= '')
                            con.Phone= requestParam.Phone;
                        if(requestParam.PreferredLanguage != Null && requestParam.PreferredLanguage != '')
                            con.Preferred_Language__c= requestParam.PreferredLanguage;
                        con.Primary_Contact__c = requestParam.isPrimary;
                        con.Bill_to__c = requestParam.Billto;
                        con.Sell_to__c = requestParam.Shipto;
                        con.Acknowledgement__c = requestParam.Acknowledgement;
                        con.Invoice__c = requestParam.Invoice;
                        con.Legal__c = requestParam.Legal;
                        if(requestParam.AccountID != Null && requestParam.AccountID != '')
                            con.AccountID= requestParam.AccountID;
                        else if(requestParam.EnterpriseMasterId != Null && requestParam.EnterpriseMasterId != '')
                            con.Account = new Account(Enterprise_Party_Number__c = requestParam.EnterpriseMasterId);
                        if(requestParam.FchContactID != Null && requestParam.FchContactID != '')
                            con.FCH_Contact_Id__c= requestParam.FchContactID;
                        if(requestParam.FchCellPhoneID != Null && requestParam.FchCellPhoneID != '')
                            con.FCH_Cell_Phone_Id__c= requestParam.FchCellPhoneID;
                        if(requestParam.FchFaxID != Null && requestParam.FchFaxID!= '')
                            con.FCH_Fax_Id__c= requestParam.FchFaxID;
                        if(requestParam.FchHomePhoneID != Null && requestParam.FchHomePhoneID != '')
                            con.Fch_Home_Phone_Id__c= requestParam.FchHomePhoneID;
                        if(requestParam.FchPhoneID != Null && requestParam.FchPhoneID != '')
                            con.Fch_Phone_Id__c= requestParam.FchPhoneID;
                        if(requestParam.FchEmailID != Null && requestParam.FchEmailID != '')
                            con.FCH_Email_Id__c = requestParam.FchEmailID;
                        if(requestParam.EnterpriseContactNumber != Null && requestParam.EnterpriseContactNumber != '')
                            con.Enterprise_Contact_Number__c= requestParam.EnterpriseContactNumber;
                        
                        //Added for TAP
                        if(requestParam.addressid!= Null && requestParam.addressid!= '' && AddressMap.get(requestParam.addressidtype) != Null){
                            con.Address__c = AddressMap.get(requestParam.addressidtype);
                            con.MarketingListTAP__c = True;
                            }
                        if(requestParam.addressidtype != Null && requestParam.addressidtype != '')
                            con.Address_ID_Type__c = requestParam.addressidtype;
                        /*if(requestParam.emailinvoice!= Null && requestParam.emailinvoice!= '' && (requestParam.emailinvoice=='Y' || requestParam.emailinvoice=='y' || requestParam.emailinvoice=='True' || requestParam.emailinvoice=='true')) 
                        Con.Email_Invoice__c = True;
                        if(requestParam.emailinvoice!= Null && requestParam.emailinvoice!= '' && (requestParam.emailinvoice=='N' || requestParam.emailinvoice=='n' || requestParam.emailinvoice=='False' || requestParam.emailinvoice=='false')) 
                        Con.Email_Invoice__c = False;*/
                        if(requestParam.emailrenewal != Null && requestParam.emailrenewal != '' && (requestParam.emailrenewal =='Y' || requestParam.emailrenewal =='y' || requestParam.emailrenewal =='True' || requestParam.emailrenewal =='true')) 
                        Con.Email_Renewal__c = True;
                        if(requestParam.emailrenewal != Null && requestParam.emailrenewal != '' && (requestParam.emailrenewal =='N' || requestParam.emailrenewal =='n' || requestParam.emailrenewal =='False' || requestParam.emailrenewal =='false')) 
                        Con.Email_Renewal__c = False;
                        /*if(requestParam.printinvoice != Null && requestParam.printinvoice != '' && (requestParam.printinvoice =='Y' || requestParam.printinvoice =='y' || requestParam.printinvoice =='True' || requestParam.printinvoice =='true')) 
                        Con.Print_Invoice__c= True;
                        if(requestParam.printinvoice != Null && requestParam.printinvoice != '' && (requestParam.printinvoice =='N' || requestParam.printinvoice =='n' || requestParam.printinvoice =='False' || requestParam.printinvoice =='false')) 
                        Con.Print_Invoice__c = False;*/
                        if(requestParam.mktlisttap != Null && requestParam.mktlisttap != '' && (requestParam.mktlisttap =='Y' || requestParam.mktlisttap =='y' || requestParam.mktlisttap =='True' || requestParam.mktlisttap=='true')) 
                        Con.MarketingListTAP__c = True;
                        if(requestParam.mktlisttap != Null && requestParam.mktlisttap != '' && (requestParam.mktlisttap =='N' || requestParam.mktlisttap =='n' || requestParam.mktlisttap =='False' || requestParam.mktlisttap=='false')) 
                        Con.MarketingListTAP__c = False;
                        
                        if(requestParam.emailinvoice!= Null && requestParam.emailinvoice!= '' && requestParam.emailinvoice=='true') 
                        Con.Invoice_Delivery_Method__c = 'Email';
                        if(requestParam.printinvoice != Null && requestParam.printinvoice != '' && requestParam.printinvoice =='true') 
                        Con.Invoice_Delivery_Method__c = 'Print';
                        if((requestParam.emailinvoice!= Null && requestParam.emailinvoice!= '' && requestParam.emailinvoice=='true') && (requestParam.printinvoice != Null && requestParam.printinvoice != '' && requestParam.printinvoice =='true'))
                        Con.Invoice_Delivery_Method__c = 'Both';
                        
                                                                       
                        UpdateList.add(Con);
                    }
                }else if(requestParam.strOperation != 'NoOp'){
                    ResponseWrapper respvar ;
                    respvar = new ResponseWrapper(); 
                    respvar.recordID = requestParam.ContactID != Null ? requestParam.ContactID : '';
                    respvar.EnterpriseId = requestParam.EnterpriseContactNumber != Null ? requestParam.EnterpriseContactNumber : '';
                    respvar.result ='Failure';
                    respvar.ErrorCode = 'SFDC Account ID';
                    respvar.ErrorMessage = 'Mandatory information is missing.';
                    respvar.RecordType = 'Contact';
                    responselist.add(respvar);
                }
            }
            system.debug(UpdateList + '------InsertList------' + InsertList);
            if(InsertList.size()>0)
                insert InsertList;
            if(UpdateList.size()>0)
                Update UpdateList;
                
            for(Contact con : insertList){
                ResponseWrapper respvar ;
                respvar = new ResponseWrapper();  
                respvar.recordID = String.valueof((con.ID != null ? con.ID : ''));
                respvar.EnterpriseId = (con.Enterprise_Contact_Number__c != null ? con.Enterprise_Contact_Number__c : '');
                respvar.result ='Success';
                respvar.RecordType = 'Contact';
                responselist.add(respvar);
            }
            
            for(Contact con : UpdateList){
                ResponseWrapper respvar ;
                respvar = new ResponseWrapper();  
                respvar.recordID = String.valueof((con.ID != null ? con.ID : ''));
                respvar.EnterpriseId = (con.Enterprise_Contact_Number__c != null ? con.Enterprise_Contact_Number__c : '');
                respvar.result ='Success';
                respvar.RecordType = 'Contact';
                responselist.add(respvar);
            }
            
        }catch(Exception ex){
            Inbound_Outbound_Callouts__c errorLog = new Inbound_Outbound_Callouts__c();
            errorLog.Callout_Type__c = 'Inbound';
            errorLog.Destination_System__c = 'FCH';
            errorLog.Source_System__c ='SFDC';
            errorLog.Integration_Module__c =  'Customer Interface';
            errorLog.Error_Message__c = '';
            insert errorLog;
            system.debug('------------ex----------' + ex);
            
            ResponseWrapper respvar ;
            respvar = new ResponseWrapper();  
            respvar.result ='Failure';
            respvar.ErrorCode = 'SOA - SFDC Inbound - CreatePartyContact';
            respvar.ErrorMessage = String.valueof(ex);
            respvar.RecordType = 'Contact';
            responselist.add(respvar);
        } 
        return responselist;
    }
    
    Public void CreateCreditCheck(String InputStr,String AccID)
    {
    List<Credit_Details_Tab_Customer_Account__c> OldRetCCList = new List<Credit_Details_Tab_Customer_Account__c>();
    List<Credit_Details_Tab_Customer_Account__c> RetCCList = new List<Credit_Details_Tab_Customer_Account__c>();
   // String Sample ='USD:100000:50000:20000|GBP:10000:5000:2000';
   OldRetCCList = [Select id from Credit_Details_Tab_Customer_Account__c where Account__c =: AccId];
    List<String>Records = InputStr.Split('\\|');
    List<String>Fields = new List<String>(); 
    
    for(Integer i=0;i<Records.size();i++)
    {
    system.debug('****************'+Records );
    Credit_Details_Tab_Customer_Account__c cc = new Credit_Details_Tab_Customer_Account__c();
     fields = Records[i].Split('\\:');
     system.debug('****************'+fields);
     system.debug('****************'+AccID);
       cc.Currency__c = fields.get(0);
       cc.CurrencyIsoCode = fields.get(0);
       cc.Available_Credit_Line_ACL__c = Decimal.valueof(fields.get(1));
       cc.Outstanding_Payment_OP__c = Decimal.valueof(fields.get(2));
       cc.Overdue_Payment_OD__c = Decimal.valueof(fields.get(3));
       cc.Account__C = AccID;
     RetCCList.add(cc);
    }
    if(OldRetCCList.size()>0 && RetCCList.size()>0)
    {
    Delete OldRetCCList;
    Insert RetCCList;
    AccountHelper.SendEmailOnCreditCheck(AccID);
    }
    else if(OldRetCCList.size()== 0 && RetCCList.size()>0)
    Insert RetCCList;
    }
    
    global class ResponseWrapper{
        webservice String EnterpriseId {get;set;}        
        webservice String recordid {get;set;}    
        webservice String recordType {get;set;}    
        webservice String result{get;set;}
        webservice String ErrorCode{get;set;}
        webservice String ErrorMessage{get;set;}
    }
    
    global class RequestContactData{
        Webservice String ContactID;
        Webservice String AccountID;
        Webservice String FirstName;
        Webservice String LastName;
        Webservice String Email;
        Webservice String CellPhone;
        Webservice String Fax;
        Webservice String HomePhone;
        Webservice String Phone;
        Webservice String PreferredLanguage;
        Webservice boolean IsPrimary;
        Webservice boolean BillTo;
        Webservice boolean ShipTo;
        Webservice boolean Acknowledgement;
        Webservice boolean Invoice;
        Webservice boolean Legal;
        Webservice String FchContactID;
        Webservice String FchCellPhoneID;
        Webservice String FchFaxID;
        Webservice String FchHomePhoneID;
        Webservice String FchPhoneID;
        Webservice String FchEmailID;
        Webservice String EnterpriseContactNumber;
        Webservice String EnterpriseMasterId;
        webservice string StrOperation;
        Webservice String Attribute1;
        Webservice String Attribute2;
        Webservice String Attribute3;
        Webservice String Attribute4;
        Webservice String Attribute5;
        Webservice String Attribute6;
        Webservice String Attribute7;
        Webservice String Attribute8;
        Webservice String Attribute9;
        Webservice String Attribute10;
        
        //Added for TAP Division
        Webservice String emailinvoice;
        Webservice String emailrenewal;
        Webservice String printinvoice;
        Webservice String mktlisttap;
        Webservice String addressid;
        Webservice String addressidtype; 
        
    }
    
    global class RequestAddressData{
        
        webservice string Language;
        Webservice String AddressID;
        Webservice String SiteName;
        Webservice String CustomerName;
        Webservice String AddressLine1;
        Webservice String AddressLine2;
        Webservice String AddressLine3;
        Webservice String AddressLine4;
        Webservice String City;
        Webservice String County;
        Webservice String Country;
        Webservice String State;
        Webservice String Zip;
        Webservice String RestrictedPartyIndicator;
        Webservice Date AnniversaryDate;
        Webservice String TaxRegNumber;
        Webservice String BillTo;
        Webservice String ShipTo;
        Webservice String InstalledAt;
        Webservice String EndUser;
        Webservice String SellTo;
        Webservice String AccountID;
        Webservice String FCHPartySiteID;
        Webservice String EnterpriseAddressNumber;
        Webservice String EnterpriseMasterId;
        Webservice String AddressValidatorFlag;
        webservice string StrOperation;
        Webservice String Attribute1;
        Webservice String Attribute2;
        Webservice String Attribute3;
        Webservice String Attribute4;
        Webservice String Attribute5;
        Webservice String Attribute6;
        Webservice String Attribute7;
        Webservice String Attribute8;
        Webservice String Attribute9;
        Webservice String Attribute10;  
        
        //Added for TAP Division
        Webservice String industry;
        Webservice String salesperson;
        Webservice String pricelistid;
        Webservice String activationemail;
        Webservice String active;
        Webservice String taxnumber;
        Webservice String custpayablecontacttype1;
        Webservice String custpayablecontacttype2;
        Webservice String custpayablecontacttype3;
        Webservice String custpayablecontacttype4;
        Webservice String custpayablecontactvalue1;
        Webservice String custpayablecontactvalue2;
        Webservice String custpayablecontactvalue3;
        Webservice String custpayablecontactvalue4;
        Webservice String BillTolocation;
        Webservice String ShipTolocation;
        webservice String TapPOSFlag;
        webservice string TapInvGroupingOption;
          
    }
    
    global class RequestAccountdata{
        webservice string EBSAccountNumber;
        Webservice String CustomerReference;
        Webservice String CPIRPIReqd;
        Webservice String AccountID;
        Webservice String AccountName;
        webservice string CollectorName;
        webservice String Email;
        Webservice String DUNS;
        Webservice String PrimaryRegion; 
        Webservice String RestrictedPartyIndicator;
        Webservice boolean DoNotMerge;
        webservice String FchReportingEntityPartyID;
        Webservice String VerticalClassification; 
        Webservice String CreditStatus;
        Webservice String EnterpriseAccountNumber;
        Webservice String FchPartyID; 
        Webservice String FchReportingEntityNumber;
        Webservice String EBSPaymentTerm;
        Webservice List<RequestAddressData> addresses;
        Webservice List<RequestContactData> contacts;
        Webservice String IsDeleted;
        Webservice String Country;
        Webservice String GlobalOptput;
        Webservice String LifeCycelstage;
        Webservice String CustomerType;
        Webservice String SalesRepBusinessArea;
        Webservice String SalesRepUserDivision;
        Webservice String SalesRepLegalEntity;
        Webservice String SalesRepSalesRegion;
        Webservice String AccountOwnerEmail;
        Webservice String CustomerLevel;
        Webservice String CustomerName; 
        Webservice String SiteName;
        Webservice String Division;
        Webservice String AvailableCreditLine;
        Webservice String TotalUnpaidAmount;
        Webservice String TotalAmountPastDue;
        Webservice String CustomerCreditInfoString;
        webservice string StrOperation;
        
        Webservice String Attribute1;
        Webservice String Attribute2;
        Webservice String Attribute3;
        Webservice String Attribute4;
        Webservice String Attribute5;
        Webservice String Attribute6;
        Webservice String Attribute7;
        Webservice String Attribute8;
        Webservice String Attribute9;
        Webservice String Attribute10;
        
        //Added for TAP Division
        webservice string customershortname;
        webservice string discount;
        webservice string resellers;
        webservice string autorenewal;
        webservice string TapCustomerType;
        webservice string TapCustomerSubType;
    }
}