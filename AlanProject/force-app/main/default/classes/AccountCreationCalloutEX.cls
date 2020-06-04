/*****************************************************************************************
Name    : AccountCreationCalloutEX 
Desc    : Used to do a call out to FCH server or EBS and pass the data from Account
to insert a record

Modification Log : 
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
Vikram Mandla         01/01/2013          Created
Sunay Prasad R K      19/02/2014          Modified
******************************************************************************************/
public class AccountCreationCalloutEX{
    /*
    * Method name  : CallEBS
    * Description  : Future method to pass the list of accounts with the operation name to 
    create or update an account in FCH or EBS server
    * Return Type  : void
    * Parameter    : list<id>,string
    */
    public static boolean recursiveCallFlag = false;
    public static boolean dLinkAccountFlag = false;
    public static String calloutResult = '';
    public static void makeCallOut(List<String> accIdList,String AccountOpr,String ContactOpr,String AddressOpr,set<String> conIdSet,set<String> addIdSet,set<String> deleteData){
        system.debug('------------MakeCallOut----------');
        system.debug('------------accIdList--------' + accIdList);
        system.debug('------------conIdSet--------' + conIdSet);
        system.debug('------------addIdSet--------' + addIdSet);
        system.debug('------------deleteData--------' + deleteData);
        system.debug('------------AccountOpr--------' + AccountOpr);
        system.debug('------------ContactOpr--------' + ContactOpr);
        system.debug('------------AddressOpr--------' + AddressOpr);
        if(conIdSet == null)conIdSet = new set<String>();
        if(addIdSet == null)addIdSet = new set<String>();
        
        recursiveCallFlag = true;
        if(accIdList.size() == 1){
            List<Reseller__c>ResellerAcc = new List<Reseller__c>();
            String resellerStr ='';
            trimblecorpComTnvcussfdcoutbound_v5.HeaderType headerType = new  trimblecorpComTnvcussfdcoutbound_v5.HeaderType();
            headerType.sourceSystem = 'SFDC';
            trimblecorpComTnvcussfdcoutbound_v5.AccountType accountType = new  trimblecorpComTnvcussfdcoutbound_v5.AccountType();
            if(AccountOpr != 'Delete' && AccountOpr != 'DLink'){
                Account acc = [select Id,Customer_Short_Name__c,TAP_Customer_Sub_Type__c,TAP_Customer_Type__c,Type,Discount__c,Auto_Renewal__c,ConvertedLeadId__c,FchReportingEntityPartyID__c,EBS_Account_Number__c,FchReportingEntityNumber__c,Email__c,CPI_RPI_Reqd__c,Customer_Reference__c,Phone,Account_Division__c,CurrencyISOCode,Total_Unpaid_Amount__c,Total_Amount_Past_Due__c,Name,Owner.Email,Sales_Rep_Sales_Region__c,Sales_Rep_Legal_Entity__c,Creator_s_Division__c,Sales_Rep_Business_Area__c,Customer_Type__c,sub_type__c,Customer_Name__c ,Site_Name__c,DUNS__c,Global_Opt_Out__c,Lifecycle_Stage__c,Region__c  ,
                               Restricted_Entity__c,Do_Not_Merge__c,Vertical_Classification__c ,Credit_Check_Status__c,Enterprise_Party_Number__c,FCH_Party_Id__c,
                               (select Id,CurrencyISOCode,Industry__c,Active__c,Customer_Type_1__c,Customer_Type_2__c,Customer_Type_3__c,Customer_Type_4__c,Customer_Value_1__c,Customer_Value_2__c,Customer_Value_3__c,Customer_Value_4__c,
                             Sales_Person__c,Tax_Number__c,Price_List__c,POS_Flag__c,TapInv_Grp_Option__c,Tax_Reg_Number__c,Restricted_Party_Indicator__c,Site_Name__c,Anniversary_Date__c,Location_ID__c,Bill_To_Location__c,Ship_To_Location__c,Party_Site_ID__c,Party_Site_Number__c,Address_line1__c,Address_line2__c,Address_line3__c,
                                Address_line4__c,Brazilian_Neighborhood__c,Brazilian_State__c,Brazilian_City__c,City__c,County__c,Country__c,State__c,Zip__c,Bill_to__c,Ship_to__c,Installed_at__c,End_User__c,
                                Sell_to__c,Address_Region__c,Activation_Email__c,Preferred_Language__c,Account__c,Enterprise_Address_Number__c,Address_Validated_Flag__c,
                                FCH_Party_Site_ID__c
                                from Addresses__r order by FCH_Party_Site_ID__c ASC NULLS LAST),
                               (select Id,CurrencyISOCode,Address__c,Address__r.FCH_Party_Site_ID__c,FirstName,LastName,Email_Renewal__c,Address_ID_Type__c,Ship_to__c,FCH_Fax_Id__c,Fch_Home_Phone_Id__c,Fch_Phone_Id__c,FCH_Email_Id__c,Email,FCH_Cell_Phone_Id__c,Contact.FCH_Contact_Id__c,MobilePhone,Fax,HomePhone,Phone,Preferred_Language__c,Primary_Contact__c,Bill_to__c,
                                Sell_to__c,Acknowledgement__c,Invoice__c,Legal__c,AccountID,Enterprise_Contact_Number__c,Invoice_Delivery_Method__c from Contacts)
                               from Account where Id =: accIdList.get(0)];
                //Division__c removed from line 32
                ResellerAcc = [select id,Reseller_Account__r.FCH_Party_Id__c,Reseller_Account__r.EBS_Account_Number__c,Reseller_Account__r.Enterprise_Party_Number__c from Reseller__c where Parent_Account__c =:accIdList.get(0)];
                
                if(ResellerAcc.size()==1)
                {
                  resellerStr = (ResellerAcc.get(0).Reseller_Account__r.Enterprise_Party_Number__c != Null ? ResellerAcc.get(0).Reseller_Account__r.Enterprise_Party_Number__c :'');
                }
                else
                {
                for(Reseller__c Acct: ResellerAcc)
                {
                 if(Acct.Reseller_Account__r.Enterprise_Party_Number__c != Null)
                 resellerStr = resellerStr + Acct.Reseller_Account__r.Enterprise_Party_Number__c+'|';
                }
                system.debug('>>>>>>>resellerStr>>>>>>>>>>'+resellerStr);
                }
                accountType.Operation = (AccountOpr == 'Merge' ? 'Update' : AccountOpr);
                accountType.AccountID = acc.Id;
                accountType.AccountName = acc.Name;
                System.debug('---------------Account Lifecycle Stage----------'+acc.Lifecycle_stage__c);
                
                if(acc.Account_Division__c != null){
                    String temp = acc.Account_Division__c.replaceAll('; ',';');
                    accountType.division = new trimblecorpComTnvcussfdcoutbound_v5.DivisionType();
                    accountType.division.Div = new List<String>();
                    accountType.division.Div = temp.split(';');
                }
                
                
                accountType.AccountOwnerEmail = acc.Owner.Email;
                accountType.CustomerLevel = acc.sub_type__c;
                accountType.CustomerName = acc.Customer_Name__c; 
                accountType.SiteName = acc.Site_Name__c;
                if(acc.Phone != null)
                    accountType.AccountPhone = acc.Phone;
                
                if(acc.Email__c != null)
                    accountType.Email= acc.Email__c;
                accountType.DUNS = acc.DUNS__c;
                accountType.GlobalOptput = (acc.Global_Opt_Out__c == true)?'Yes':'No';
                accountType.LifeCycelstage = acc.Lifecycle_Stage__c;
                accountType.PrimaryRegion = acc.Region__c ; 
                // accountType.RestrictedPartyIndicator = (acc.Restricted_Entity__c!=null)?((acc.Restricted_Entity__c==Label.Restricted)?'Yes':'No'):'No';
                accountType.DoNotMerge = (acc.Do_Not_Merge__c == true)?'Yes':'No';
                accountType.VerticalClassification = acc.Vertical_Classification__c; 
                accountType.CreditStatus= acc.Credit_Check_Status__c;
                accountType.EnterpriseAccountNumber = acc.Enterprise_Party_Number__c;
                accountType.FchPartyID = acc.FCH_Party_Id__c; 
                accountType.CustomerReference = acc.Customer_Reference__c;
                accountType.CpiRpiRequired = (acc.CPI_RPI_Reqd__c=='Yes'? 'Y' : (acc.CPI_RPI_Reqd__c=='No' ? 'N' : ''));
                accountType.FchReportingEntityNumber = acc.FchReportingEntityNumber__c;
                accountType.FchReportingEntityPartyID = acc.FchReportingEntityPartyID__c;
                accountType.CustomerType = acc.Customer_Type__c;
                accountType.SalesRepBusinessArea = acc.Sales_Rep_Business_Area__c;
                accountType.SalesRepUserDivision = acc.Creator_s_Division__c;
                accountType.SalesRepLegalEntity = acc.Sales_Rep_Legal_Entity__c;
                accountType.SalesRepSalesRegion = acc.Sales_Rep_Sales_Region__c;
                //accountType.EBSPaymentTerm = acc.EBS_Payment_Term__c;
                accountType.IsDeleted = 'No';
                
                accountType.TotalUnpaidAmount = acc.Total_Unpaid_Amount__c;
                accountType.TotalAmountPastDue = acc.Total_Amount_Past_Due__c;
                accountType.AccountCurrency = acc.currencyISOCode;
                
                //TAP attributes mapping
                accountType.Tapcustomershortname = (acc.Customer_Short_Name__c!=Null || acc.Customer_Short_Name__c!= '' ? acc.Customer_Short_Name__c : acc.Name);
                accountType.Tapdiscount = acc.Discount__c;
                accountType.Tapautorenewal  = (acc.Auto_Renewal__c==True ? 'Y' : 'N');
                accountType.TapResellers = resellerStr;
                accountType.TapCustomerType = (acc.TAP_Customer_Type__c != Null ? acc.TAP_Customer_Type__c.touppercase() : '');
                accountType.TapCustomerSubType = (acc.TAP_Customer_Sub_Type__c!= Null ? acc.TAP_Customer_Sub_Type__c.touppercase() : '');
 
                
                accountType.Address = new List< trimblecorpComTnvcussfdcoutbound_v5.AddressType>();
                system.debug('-----------accountType-----------' + accountType);
                trimblecorpComTnvcussfdcoutbound_v5.AddressType add = new  trimblecorpComTnvcussfdcoutbound_v5.AddressType();
                Integer cnt = 0; //If AddressOpr is NoOp then send only one Address record
                for(Address__c address : acc.Addresses__r){
                    if((AddressOpr == 'NoOp' && cnt == 0) || (AddressOpr != 'NoOp' && AddressOpr != 'Delete' && addIdSet.contains(address.Id))){
                        cnt++;
                        add = new trimblecorpComTnvcussfdcoutbound_v5.AddressType();
                        
                        if(AddressOpr == 'Delete')
                            add.Operation = 'NoOp';
                        else if(addIdSet != null ? !addIdSet.contains(address.Id) : true)
                            add.Operation = 'NoOp';
                        else
                            add.Operation = AddressOpr;
                        add.AddressID = Address.Id;
                        add.BillToLocation = address.Bill_To_Location__c;
                        add.ShipToLocation = address.Ship_To_Location__c;
                        add.SiteName= address.Party_Site_ID__c;
                        add.AddressLine1 = address.Address_line1__c;
                        
                        if(address.Country__c != Null && address.Country__c != '' && address.Country__c.equalsIgnoreCase('Brazil')){
                            
                            add.AddressLine2 = address.Brazilian_Neighborhood__c;
                            add.City = address.Brazilian_City__c;
                            add.County = 'BR';
                            add.Country = 'Brazil';
                            add.State = address.Brazilian_State__c;
                        }
                        else
                        {
                            add.AddressLine2 = address.Address_line2__c;
                            add.City = address.City__c;
                            add.County = address.County__c;
                            add.Country = address.Country__c;
                            add.State = address.State__c;
                        }
                        add.AddressLine3 = address.Address_line3__c;
                        add.AddressLine4 = address.Address_line4__c;
                        add.Language = address.Preferred_Language__c;
                        add.Zip = address.Zip__c;
                        add.BillTo = (address.Bill_to__c ? 'Yes' : 'No');
                        add.ShipTo = (address.Ship_to__c ? 'Yes' : 'No');
                        add.InstalledAt = (address.Installed_at__c ? 'Yes' : 'No');
                        add.EndUser = (address.End_User__c ? 'Yes' : 'No');
                        add.SellTo = (address.Sell_to__c ? 'Yes' : 'No');
                        add.AddressRegion = address.Address_Region__c;
                        add.AccountID = address.Account__c;
                        add.EnterpriseAddressNumber = address.Enterprise_Address_Number__c;
                        add.AddressValidatorFlag = (address.Address_Validated_Flag__c ? 'Yes' : 'No');
                        add.FchPartySiteID = address.FCH_Party_Site_ID__c;
                        add.RestrictedPartyIndicator = address.Restricted_Party_Indicator__c;
                        if(address.Anniversary_Date__c != null)
                            add.AnniversaryDate= address.Anniversary_Date__c.year() + '-' + 
                            (address.Anniversary_Date__c.month() < 10 ? '0' + address.Anniversary_Date__c.month() : '' + address.Anniversary_Date__c.month()) + '-' +
                            (address.Anniversary_Date__c.day() < 10 ? '0' + address.Anniversary_Date__c.day() : '' + address.Anniversary_Date__c.day());
                        add.TaxRegNumber = address.Tax_Reg_Number__c;    
                        add.SiteName = address.Site_Name__c;
                        
                        //TAP attribute mapping
                        add.TapIndustry = address.Industry__c;
                        add.TapActivationEmail = (address.Activation_Email__c == True ? 'Y' : 'N');
                        add.TapCustPayableContType1 = address.Customer_Type_1__c;
                        add.TapCustPayableContType2 = address.Customer_Type_2__c;
                        add.TapCustPayableContType3 = address.Customer_Type_3__c;
                        add.TapCustPayableContType4 = address.Customer_Type_4__c;
                        add.TapCustPayableContValue1 = address.Customer_value_1__c;
                        add.TapCustPayableContValue2 = address.Customer_value_2__c;
                        add.TapCustPayableContValue3 = address.Customer_value_3__c;
                        add.TapCustPayableContValue4 = address.Customer_value_4__c;
                        add.TapSalesPerson = address.Sales_Person__c;
                        add.TapTaxNumber = address.Tax_Number__c;
                        add.TapPriceListId = address.Price_List__c;
                        add.TapPosFlag = (address.POS_Flag__c == True ? 'Y' : 'N');
                        add.AddressStatus = (address.Active__c== True ? 'Y' : 'N');
                        add.TapInvGroupingOption = (address.TapInv_Grp_Option__c!= Null ? address.TapInv_Grp_Option__c:'');
                        accountType.Address.add(add);
                        system.debug('-----------add.EnterpriseAddressNumber-----------' + add.EnterpriseAddressNumber);
                        system.debug('-----------add.AddressID-----------' + add.AddressID);
                        system.debug('-----------add.FchPartySiteID-----------' + add.FchPartySiteID);
                        system.debug('-----------add.Operation-----------' + add.Operation);
                    }
                }
                if(AddressOpr == 'Delete'){
                    for(String str : deleteData){
                        add = new trimblecorpComTnvcussfdcoutbound_v5.AddressType();
                        add.Operation = AddressOpr;
                        
                        add.AddressID = (str.split('~~').size() > 0 ? str.split('~~')[0].trim() : '');
                        add.EnterpriseAddressNumber = (str.split('~~').size() > 1 ? str.split('~~')[1].trim() : '');
                        add.FchPartySiteID = (str.split('~~').size() > 2 ? str.split('~~')[2].trim() : '');
                        system.debug('-----------add-----------' + add);
                        accountType.Address.add(add);
                    }
                }
                system.debug('-----------accountType.Address-----------' + accountType.Address);
                accountType.Contacts = new List< trimblecorpComTnvcussfdcoutbound_v5.ContactType>();
                trimblecorpComTnvcussfdcoutbound_v5.ContactType conType = new trimblecorpComTnvcussfdcoutbound_v5.ContactType();
                system.debug('-----------acc.ConvertedLeadId__c-----------' + acc.ConvertedLeadId__c);
                system.debug('-----------acc.FCH_Party_Id__c-----------' + acc.FCH_Party_Id__c);
                system.debug('-----------acc.Contacts.size()-----------' + acc.Contacts.size());
                system.debug('-----------acc.Contacts-----------' + acc.Contacts);
                system.debug('-----------conIdSet-----------' + conIdSet);
                /*if(String.isNotBlank(acc.ConvertedLeadId__c) && string.isBlank(acc.FCH_Party_Id__c) && acc.Contacts.size() == 1){
                    ContactOpr = 'Create';
                    conIdSet.add(acc.Contacts.get(0).Id);
                }*/
                if(ContactOpr != 'NoOp' && ContactOpr != 'Delete'){
                    
                    for(Contact con : acc.Contacts){
                        if(conIdSet.contains(con.Id)){
                            conType = new trimblecorpComTnvcussfdcoutbound_v5.ContactType();
                            
                            if(ContactOpr == 'Delete')
                                conType.Operation = 'NoOp';
                            else if(conIdSet != null ? !conIdSet.contains(con.Id) : true)
                                conType.Operation = 'NoOp';
                            else
                                conType.Operation = ContactOpr;
                            
                            conType.ContactID = con.Id;
                            conType.FirstName = con.FirstName;
                            conType.LastName = con.LastName;
                            conType.Email = con.Email;
                            conType.CellPhone = con.MobilePhone;
                            conType.Fax = con.Fax;
                            conType.HomePhone = con.HomePhone;
                            conType.Phone = con.Phone;
                            conType.PreferedLanguage = con.Preferred_Language__c;
                            conType.Primary = con.Primary_Contact__c;
                            conType.BillTo = con.Bill_to__c;
                            conType.ShipTo = con.Ship_to__c;
                            //conType.sellTo = con.Sell_To__c;
                            conType.Acknowledgement = con.Acknowledgement__c;
                            conType.Invoice = con.Invoice__c;
                            conType.Legal = con.Legal__c;
                            conType.AccountID = con.AccountID;
                            conType.FchContactID = con.FCH_Contact_Id__c;
                            conType.FchCellPhoneID = con.FCH_Cell_Phone_Id__c;
                            conType.FchFaxID = con.FCH_Fax_Id__c;
                            conType.FchHomePhoneID = con.Fch_Home_Phone_Id__c;
                            conType.FchPhoneID = con.Fch_Phone_Id__c;
                            conType.FchEmailID = con.FCH_Email_Id__c;
                            conType.attribute2 = con.Invoice_Delivery_Method__c;
                            conType.EnterpriseContactNumber = con.Enterprise_Contact_Number__c;
                            
                            //TAP attribute Mapping
                            conType.TapEmailInvoice = (Con.Invoice_Delivery_Method__c!= Null && Con.Invoice_Delivery_Method__c =='Email' ? 'true' : 'false'); 
                            conType.TapEmailRenewal = (Con.Email_Renewal__c == True ? 'true' : 'false');
                            conType.TapPrintInvoice = (Con.Invoice_Delivery_Method__c!= Null && Con.Invoice_Delivery_Method__c =='Print' ? 'true' : 'false');
                            if(Con.Invoice_Delivery_Method__c!= Null && Con.Invoice_Delivery_Method__c =='Both')
                            {
                             conType.TapEmailInvoice = 'true';
                             conType.TapPrintInvoice = 'true';
                            }
                            conType.TapAddressId = (con.Address__r.FCH_Party_Site_ID__c!= Null ? con.Address__r.FCH_Party_Site_ID__c : con.Address__c);
                            conType.TapAddressIdType = (Con.Address__r.FCH_Party_Site_ID__c != Null ? 'FCH' : 'SFDC');
                            
                             system.debug('-------------conType.TapAddressId ----------'+conType.TapAddressId );
                             system.debug('-------------conType.TapAddressIdType----------'+conType.TapAddressIdType); 
                            system.debug('-----------conType.EnterpriseContactNumber-----------' + conType.EnterpriseContactNumber);
                            system.debug('-----------conType.ContactID-----------' + conType.ContactID);
                            system.debug('-----------conType.FchContactID-----------' + conType.FchContactID);
                            system.debug('-----------conType.Operation-----------' + conType.Operation);
                            accountType.Contacts.add(conType);
                        }
                    }
                }
                system.debug('-----------accountType.Contacts-----------' + accountType.Contacts.size());
                if(ContactOpr == 'Delete'){
                    for(String str : deleteData){
                        conType = new trimblecorpComTnvcussfdcoutbound_v5.ContactType();
                        conType.Operation = ContactOpr;
                        conType.ContactID = (str.split('~~').size() > 0 ? str.split('~~')[0].trim() : '');
                        conType.EnterpriseContactNumber = (str.split('~~').size() > 1 ? str.split('~~')[1].trim() : '');
                        conType.FchContactID = (str.split('~~').size() > 2 ? str.split('~~')[2].trim() : '');
                        system.debug('-----------conType-----------' + conType);
                        accountType.Contacts.add(conType);
                    }
                }
            }else if(AccountOpr == 'DLink'){
                Account acc = [select Id,FchReportingEntityPartyID__c,TAP_Customer_Sub_Type__c,Type,Customer_Short_Name__c,TAP_Customer_Type__c,Discount__c,Auto_Renewal__c,FchReportingEntityNumber__c,Email__c,CPI_RPI_Reqd__c,Customer_Reference__c,Phone,Account_Division__c,CurrencyISOCode,Total_Unpaid_Amount__c,Total_Amount_Past_Due__c,Name,Owner.Email,Sales_Rep_Sales_Region__c,Sales_Rep_Legal_Entity__c,Creator_s_Division__c,Sales_Rep_Business_Area__c,Customer_Type__c,sub_type__c,Customer_Name__c ,Site_Name__c,DUNS__c,Global_Opt_Out__c,Lifecycle_Stage__c,Region__c  ,
                               Restricted_Entity__c,Do_Not_Merge__c,Vertical_Classification__c ,Credit_Check_Status__c,Enterprise_Party_Number__c,FCH_Party_Id__c,
                               (select Id,Tax_Reg_Number__c,Restricted_Party_Indicator__c,Site_Name__c,Anniversary_Date__c,Location_ID__c,Bill_To_Location__c,Ship_To_Location__c,Party_Site_ID__c,Party_Site_Number__c,Address_line1__c,Address_line2__c,Address_line3__c,
                                Address_line4__c,Brazilian_Neighborhood__c,TapInv_Grp_Option__c,City__c,County__c,Country__c,State__c,Zip__c,Bill_to__c,Ship_to__c,Installed_at__c,End_User__c,Sell_to__c,Industry__c,Activation_Email__c,Active__c,Customer_Type_1__c,Customer_Type_2__c,Customer_Type_3__c,Customer_Type_4__c,Customer_Value_1__c,Customer_Value_2__c,Customer_Value_3__c,Customer_Value_4__c,Sales_Person__c,Tax_Number__c,Price_List__c,POS_Flag__c,Address_Region__c,Preferred_Language__c,Account__c,Enterprise_Address_Number__c,Address_Validated_Flag__c,
                                FCH_Party_Site_ID__c
                                from Addresses__r),
                               (select Id,FirstName,LastName,Address__c,Address__r.FCH_Party_Site_ID__c,Email_Renewal__c,Address_ID_Type__c,Ship_to__c,FCH_Fax_Id__c,Fch_Home_Phone_Id__c,Fch_Phone_Id__c,FCH_Email_Id__c,Email,FCH_Cell_Phone_Id__c,Contact.FCH_Contact_Id__c,MobilePhone,Fax,HomePhone,Phone,Preferred_Language__c,Primary_Contact__c,Bill_to__c,
                                Sell_to__c,Acknowledgement__c,Invoice__c,Legal__c,AccountID,Enterprise_Contact_Number__c,Invoice_Delivery_Method__c from Contacts)
                               from Account where Id =: accIdList.get(0)];
                //Division__c removed from line 32
                
                accountType.Operation = 'Delete';
                accountType.AccountID = acc.Id;
                accountType.AccountName = acc.Name;
                
                
                if(acc.Account_Division__c != null){
                    String temp = acc.Account_Division__c.replaceAll('; ',';');
                    accountType.division = new trimblecorpComTnvcussfdcoutbound_v5.DivisionType();
                    accountType.division.Div = new List<String>();
                    accountType.division.Div = temp.split(';');
                }
                
                
                accountType.AccountOwnerEmail = acc.Owner.Email;
                accountType.CustomerLevel = acc.sub_type__c;
                accountType.CustomerName = acc.Customer_Name__c; 
                accountType.SiteName = acc.Site_Name__c;
                if(acc.Phone != null)
                    accountType.AccountPhone = acc.Phone;
                
                if(acc.Email__c != null)
                    accountType.Email= acc.Email__c;
                accountType.DUNS = acc.DUNS__c;
                accountType.GlobalOptput = (acc.Global_Opt_Out__c == true)?'Yes':'No';
                accountType.LifeCycelstage = acc.Lifecycle_Stage__c;
                accountType.PrimaryRegion = acc.Region__c ; 
                // accountType.RestrictedPartyIndicator = (acc.Restricted_Entity__c!=null)?((acc.Restricted_Entity__c==Label.Restricted)?'Yes':'No'):'No';
                accountType.DoNotMerge = (acc.Do_Not_Merge__c == true)?'Yes':'No';
                accountType.VerticalClassification = acc.Vertical_Classification__c; 
                accountType.CreditStatus= acc.Credit_Check_Status__c;
                accountType.EnterpriseAccountNumber = acc.Enterprise_Party_Number__c;
                accountType.FchPartyID = acc.FCH_Party_Id__c; 
                accountType.CustomerReference = acc.Customer_Reference__c;
                accountType.CpiRpiRequired = (acc.CPI_RPI_Reqd__c=='Yes'? 'Y' : (acc.CPI_RPI_Reqd__c=='No' ? 'N' : ''));
                accountType.FchReportingEntityNumber = acc.FchReportingEntityNumber__c;
                accountType.FchReportingEntityPartyID = acc.FchReportingEntityPartyID__c;
                accountType.CustomerType = acc.Customer_Type__c;
                accountType.SalesRepBusinessArea = acc.Sales_Rep_Business_Area__c;
                accountType.SalesRepUserDivision = acc.Creator_s_Division__c;
                accountType.SalesRepLegalEntity = acc.Sales_Rep_Legal_Entity__c;
                accountType.SalesRepSalesRegion = acc.Sales_Rep_Sales_Region__c;
                //accountType.EBSPaymentTerm = acc.EBS_Payment_Term__c;
                accountType.IsDeleted = 'No';
                
                //TAP attributes mapping
                 accountType.Tapcustomershortname = (acc.Customer_Short_Name__c!=Null || acc.Customer_Short_Name__c!= '' ? acc.Customer_Short_Name__c : acc.Name);
                accountType.Tapdiscount = acc.Discount__c;
                accountType.Tapautorenewal  = (acc.Auto_Renewal__c==True ? 'Y' : 'N');
                accountType.TapResellers = resellerStr;
                accountType.TapCustomerType = (acc.TAP_Customer_Type__c != Null ?acc.TAP_Customer_Type__c.touppercase() : '');
                accountType.TapCustomerSubType = (acc.TAP_Customer_Sub_Type__c!= Null ? acc.TAP_Customer_Sub_Type__c.touppercase() : '');
                
                accountType.TotalUnpaidAmount = acc.Total_Unpaid_Amount__c;
                accountType.TotalAmountPastDue = acc.Total_Amount_Past_Due__c;
                accountType.AccountCurrency = acc.currencyISOCode;
                accountType.Address = new List< trimblecorpComTnvcussfdcoutbound_v5.AddressType>();
                system.debug('-----------accountType-----------' + accountType);
                trimblecorpComTnvcussfdcoutbound_v5.AddressType add = new  trimblecorpComTnvcussfdcoutbound_v5.AddressType();
                for(Address__c address : acc.Addresses__r){
                    add = new trimblecorpComTnvcussfdcoutbound_v5.AddressType();
                    
                    add.Operation = 'NoOp';
                    add.AddressID = Address.Id;
                    add.BillToLocation = address.Bill_To_Location__c;
                    add.ShipToLocation = address.Ship_To_Location__c;
                    add.SiteName= address.Party_Site_ID__c;
                    add.AddressLine1 = address.Address_line1__c;
                    if(address.Country__c != Null && address.Country__c != '' && address.Country__c.equalsIgnoreCase('Brazil')){
                        
                        add.AddressLine2 = address.Brazilian_Neighborhood__c;
                        add.City = address.Brazilian_City__c;
                        add.County = 'BR';
                        add.Country = 'Brazil';
                        add.State = address.Brazilian_State__c;
                    }
                    else
                    {
                        add.AddressLine2 = address.Address_line2__c;
                        add.City = address.City__c;
                        add.County = address.County__c;
                        add.Country = address.Country__c;
                        add.State = address.State__c;
                    }
                    add.AddressLine3 = address.Address_line3__c;
                    add.AddressLine4 = address.Address_line4__c;
                    add.Language = address.Preferred_Language__c;
                    add.Zip = address.Zip__c;
                    add.BillTo = (address.Bill_to__c ? 'Yes' : 'No');
                    add.ShipTo = (address.Ship_to__c ? 'Yes' : 'No');
                    add.InstalledAt = (address.Installed_at__c ? 'Yes' : 'No');
                    add.EndUser = (address.End_User__c ? 'Yes' : 'No');
                    add.SellTo = (address.Sell_to__c ? 'Yes' : 'No');
                    add.AddressRegion = address.Address_Region__c;
                    add.AccountID = address.Account__c;
                    add.EnterpriseAddressNumber = address.Enterprise_Address_Number__c;
                    add.AddressValidatorFlag = (address.Address_Validated_Flag__c ? 'Yes' : 'No');
                    add.FchPartySiteID = address.FCH_Party_Site_ID__c;
                    add.RestrictedPartyIndicator = address.Restricted_Party_Indicator__c;
                    if(address.Anniversary_Date__c != null)
                        add.AnniversaryDate= address.Anniversary_Date__c.year() + '-' + 
                        (address.Anniversary_Date__c.month() < 10 ? '0' + address.Anniversary_Date__c.month() : '' + address.Anniversary_Date__c.month()) + '-' +
                        (address.Anniversary_Date__c.day() < 10 ? '0' + address.Anniversary_Date__c.day() : '' + address.Anniversary_Date__c.day());
                    add.TaxRegNumber = address.Tax_Reg_Number__c;    
                    add.SiteName = address.Site_Name__c;
                    
                 //TAP attribute mapping
                        add.TapIndustry = address.Industry__c;
                        add.TapActivationEmail = (address.Activation_Email__c == True ? 'Y' : 'N');
                        add.TapCustPayableContType1 = address.Customer_Type_1__c;
                        add.TapCustPayableContType2 = address.Customer_Type_2__c;
                        add.TapCustPayableContType3 = address.Customer_Type_3__c;
                        add.TapCustPayableContType4 = address.Customer_Type_4__c;
                        add.TapCustPayableContValue1 = address.Customer_value_1__c;
                        add.TapCustPayableContValue2 = address.Customer_value_2__c;
                        add.TapCustPayableContValue3 = address.Customer_value_3__c;
                        add.TapCustPayableContValue4 = address.Customer_value_4__c;
                        add.TapSalesPerson = address.Sales_Person__c;
                        add.TapTaxNumber = address.Tax_Number__c;
                        add.TapPriceListId = address.Price_List__c;
                        add.TapPosFlag = (address.POS_Flag__c == True ? 'Y' : 'N');
                        add.AddressStatus = (address.Active__c== True ? 'Y' : 'N');
                        add.TapInvGroupingOption = (address.TapInv_Grp_Option__c!= Null ? address.TapInv_Grp_Option__c:'');
                        
                    accountType.Address.add(add);
                    system.debug('-----------add.EnterpriseAddressNumber-----------' + add.EnterpriseAddressNumber);
                    system.debug('-----------add.AddressID-----------' + add.AddressID);
                    system.debug('-----------add.FchPartySiteID-----------' + add.FchPartySiteID);
                    
                }
                
                system.debug('-----------accountType.Address-----------' + accountType.Address);
                accountType.Contacts = new List< trimblecorpComTnvcussfdcoutbound_v5.ContactType>();
                trimblecorpComTnvcussfdcoutbound_v5.ContactType conType = new trimblecorpComTnvcussfdcoutbound_v5.ContactType();
                
                for(Contact con : acc.Contacts){
                    conType = new trimblecorpComTnvcussfdcoutbound_v5.ContactType();
                    
                    
                    conType.Operation = 'NoOp';
                    
                    conType.ContactID = con.Id;
                    conType.FirstName = con.FirstName;
                    conType.LastName = con.LastName;
                    conType.Email = con.Email;
                    conType.CellPhone = con.MobilePhone;
                    conType.Fax = con.Fax;
                    conType.HomePhone = con.HomePhone;
                    conType.Phone = con.Phone;
                    conType.PreferedLanguage = con.Preferred_Language__c;
                    conType.Primary = con.Primary_Contact__c;
                    conType.BillTo = con.Bill_to__c;
                    conType.ShipTo = con.Ship_to__c;
                    //conType.sellTo = con.Sell_To__c;
                    conType.Acknowledgement = con.Acknowledgement__c;
                    conType.Invoice = con.Invoice__c;
                    conType.Legal = con.Legal__c;
                    conType.AccountID = con.AccountID;
                    conType.FchContactID = con.FCH_Contact_Id__c;
                    conType.FchCellPhoneID = con.FCH_Cell_Phone_Id__c;
                    conType.FchFaxID = con.FCH_Fax_Id__c;
                    conType.FchHomePhoneID = con.Fch_Home_Phone_Id__c;
                    conType.FchPhoneID = con.Fch_Phone_Id__c;
                    conType.FchEmailID = con.FCH_Email_Id__c;
                    conType.attribute2 = con.Invoice_Delivery_Method__c;
                    conType.EnterpriseContactNumber = con.Enterprise_Contact_Number__c;
                    
                    //TAP attribute Mapping
                    conType.TapEmailInvoice = (Con.Invoice_Delivery_Method__c!= Null && Con.Invoice_Delivery_Method__c =='Email' ? 'true' : 'false'); 
                            conType.TapEmailRenewal = (Con.Email_Renewal__c == True ? 'true' : 'false');
                            conType.TapPrintInvoice = (Con.Invoice_Delivery_Method__c!= Null && Con.Invoice_Delivery_Method__c =='Print' ? 'true' : 'false');
                            if(Con.Invoice_Delivery_Method__c!= Null && Con.Invoice_Delivery_Method__c =='Both')
                            {
                             conType.TapEmailInvoice = 'true';
                             conType.TapPrintInvoice = 'true';
                            }
                    conType.TapAddressId = (con.Address__r.FCH_Party_Site_ID__c!= Null ? con.Address__r.FCH_Party_Site_ID__c : con.Address__c);
                    conType.TapAddressIdType = (Con.Address__r.FCH_Party_Site_ID__c != Null ? 'FCH' : 'SFDC');
                            
                    system.debug('-------------conType.TapAddressId ----------'+conType.TapAddressId );
                    system.debug('-------------conType.TapAddressIdType----------'+conType.TapAddressIdType);      
                    system.debug('-----------conType.EnterpriseContactNumber-----------' + conType.EnterpriseContactNumber);
                    system.debug('-----------conType.ContactID-----------' + conType.ContactID);
                    system.debug('-----------conType.FchContactID-----------' + conType.FchContactID);
                    system.debug('-----------conType.FchContactID-----------' + conType.FchContactID);
                    accountType.Contacts.add(conType);
                }
            }else{
                
                accountType.Operation = AccountOpr;
                accountType.AccountID = (accIdList.get(0).split('~~').size() > 0 ? accIdList.get(0).split('~~')[0].trim() : '');
                accountType.EnterpriseAccountNumber = (accIdList.get(0).split('~~').size() > 1 ? accIdList.get(0).split('~~')[1].trim() : '');
                accountType.FchPartyID = (accIdList.get(0).split('~~').size() > 2 ? accIdList.get(0).split('~~')[2].trim() : '');
                accountType.AccountName = (accIdList.get(0).split('~~').size() > 3 ? accIdList.get(0).split('~~')[3].trim() : '');
                accountType.Address = new List< trimblecorpComTnvcussfdcoutbound_v5.AddressType>();
                system.debug('-----------accountType-----------' + accountType);
                trimblecorpComTnvcussfdcoutbound_v5.AddressType add = new  trimblecorpComTnvcussfdcoutbound_v5.AddressType();
                for(String str : addIdSet){
                    add = new trimblecorpComTnvcussfdcoutbound_v5.AddressType();
                    add.Operation = AddressOpr;
                    add.AddressID = (str.split('~~').size() > 0 ? str.split('~~')[0].trim() : '');
                    add.EnterpriseAddressNumber = (str.split('~~').size() > 1 ? str.split('~~')[1].trim() : '');
                    add.FchPartySiteID = (str.split('~~').size() > 2 ? str.split('~~')[2].trim() : '');
                    system.debug('-----------add-----------' + add);
                    accountType.Address.add(add);
                }
                
                accountType.Contacts = new List< trimblecorpComTnvcussfdcoutbound_v5.ContactType>();
                trimblecorpComTnvcussfdcoutbound_v5.ContactType conType = new trimblecorpComTnvcussfdcoutbound_v5.ContactType();
                
                for(String str : conIdSet){
                    conType = new trimblecorpComTnvcussfdcoutbound_v5.ContactType();
                    conType.Operation = ContactOpr;
                    conType.ContactID = (str.split('~~').size() > 0 ? str.split('~~')[0].trim() : '');
                    conType.EnterpriseContactNumber = (str.split('~~').size() > 1 ? str.split('~~')[1].trim() : '');
                    conType.FchContactID = (str.split('~~').size() > 2 ? str.split('~~')[2].trim(): '');
                    system.debug('-----------conType-----------' + conType);
                    accountType.Contacts.add(conType);
                }
                
                
            }
            
            trimblecorpComTnvcussfdcoutbound_v5.RelationshipAttributeType relationObj = new trimblecorpComTnvcussfdcoutbound_v5.RelationshipAttributeType();
            accountType.RelationshipObject = relationObj;
            
            system.debug('-----------account--------' + accountType.Operation);
            for(trimblecorpComTnvcussfdcoutbound_v5.AddressType add1 : accountType.Address){
                system.debug(add1.Operation + '----------address----------' + add1);
            }
            for(trimblecorpComTnvcussfdcoutbound_v5.ContactType con : accountType.Contacts){
                system.debug(con.Operation + '----------contact----------' + con);
            }
            
            trimblecorpComTnvcussfdcoutbound_v5.tnvcusSFDCOutboundOutput_element responseVar = new  trimblecorpComTnvcussfdcoutbound_v5.tnvcusSFDCOutboundOutput_element();
            system.debug('-----------accountType-----------' + accountType);
            system.debug('-----------headerType-----------' + headerType);
            try{
                system.debug('-----------responseVar -----------' + responseVar );
                xmlnsOracleComCmdmTnvcusbpelsfdcoutb_v5.BpelTnvCusSfdcOutboundQueue_pt obj = new xmlnsOracleComCmdmTnvcusbpelsfdcoutb_v5.BpelTnvCusSfdcOutboundQueue_pt();
                responseVar = obj.process(headerType,AccountType);
                system.debug('-----------responseVar-----------' + responseVar);
                calloutResult = responseVar.Status;
                system.debug('-----------responseVar.Status-----------' + responseVar.Status);
                if(dLinkAccountFlag){
                    dLinkAccount(accountType.AccountID);
                } 
            }catch(Exception ex){
                Inbound_Outbound_Callouts__c errorLog = new Inbound_Outbound_Callouts__c();
                errorLog.Callout_Type__c = 'Outbound';
                errorLog.Destination_System__c = 'FCH';
                errorLog.Source_System__c ='SFDC';
                errorLog.Integration_Module__c =  'Customer Interface';
                errorLog.Error_Message__c = '';
                insert errorLog;
                system.debug('------------ex----------' + ex);
                calloutResult = ex.getMessage();
            }
            
        }
    }
    
    public static void dLinkAccount(Id AccId){
        List<Address__c>ChildAddress = new List<Address__c>();
        List<Contact>ChildContact = new List<Contact>();
        Account AccRecord  =[ Select id,FCH_Party_ID__c,EBS_Account_Number__c,Enterprise_Party_Number__c,FchReportingEntityNumber__c,FchReportingEntityPartyID__c, (Select id,FCH_Party_Site_ID__c,Enterprise_Address_Number__c from Addresses__r ad) , (Select id,Enterprise_Contact_Number__c,FCH_Cell_Phone_Id__c,FCH_Contact_Id__c,FCH_Email_Id__c,FCH_Fax_Id__c,FCH_Home_Phone_Id__c,FCH_Phone_Id__c,Invoice_Delivery_Method__c from Contacts ct) from Account where id =:AccId];
        for(Address__c Adds : AccRecord.Addresses__r){
            Adds.FCH_Party_Site_ID__c ='';
            Adds.Enterprise_Address_Number__c ='';
            ChildAddress.add(Adds);
        }
        for(Contact Con : AccRecord.Contacts){
            Con.FCH_Cell_Phone_Id__c='';
            Con.FCH_Contact_Id__c='';
            Con.FCH_Email_Id__c='';
            Con.FCH_Fax_Id__c='';
            Con.FCH_Home_Phone_Id__c='';
            Con.FCH_Phone_Id__c ='';
            Con.Enterprise_Contact_Number__c='';
            ChildContact.add(Con);  
        }
        Account Ac = new Account (id=AccRecord.id);
        Ac.FCH_Party_ID__c ='';
        Ac.FchReportingEntityNumber__c='';
        Ac.FchReportingEntityPartyID__c='';
        Ac.Enterprise_Party_Number__c='';
        Ac.COLLECTOR_Email__c = '';
        Ac.COLLECTOR_Name__c = '';
        Ac.EBS_Payment_Term__c = '';
        Ac.EBS_Account_Number__c ='';
        //Ac.Credit_Line_Currency__c = '';
        Ac.Credit_Check_Status__c = '';
        // Ac.Available_Credit_Line_ACL__c = '';
        Update Ac;
        if(ChildAddress.size()>0)
            Update ChildAddress;
        If(ChildContact.size()>0)
            Update ChildContact;
        
        delete [select id from Credit_Details_Tab_Customer_Account__c where Account__c =: AccRecord.id];
    }
    
    @future(callout=true)
    public static void CallEBS(List<String> accIdList,String AccountOpr,String ContactOpr,String AddressOpr,set<String> conIdSet,set<String> addIdSet,set<String> deleteData){
        system.debug('------------accIdList--------' + accIdList);
        system.debug('------------conIdSet--------' + conIdSet);
        system.debug('------------addIdSet--------' + addIdSet);
        system.debug('------------deleteData--------' + deleteData);
        system.debug('------------AccountOpr--------' + AccountOpr);
        system.debug('------------ContactOpr--------' + ContactOpr);
        system.debug('------------AddressOpr--------' + AddressOpr);
        
        AccountCreationCalloutEX.makeCallOut(accIdList,AccountOpr,ContactOpr,AddressOpr,conIdSet,addIdSet,deleteData);
    }
    
}