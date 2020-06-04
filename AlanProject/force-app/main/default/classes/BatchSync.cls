global class BatchSync implements Database.Batchable<sObject>,   Database.AllowsCallouts {

 public String query = 'Select ID,Name,Account_id__c from Failed_Callout_Accounts__c';
 public list<Failed_Callout_Accounts__c> strAccountNames = new list<Failed_Callout_Accounts__c>();
 public set<id> setAccids = new set<id>();
 public map<string,string> failedlist = new map<string,string>();
 public string strAccName,strAccId;
 global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(query);
 }

     global void execute(Database.BatchableContext BC, List<Failed_Callout_Accounts__c> records) {         
        
         try {  
         	    list<trimblecorpComTnvcussfdcoutbound_v1.RequestUpdateWrpaerClass> respvarList = new list<trimblecorpComTnvcussfdcoutbound_v1.RequestUpdateWrpaerClass>();
                trimblecorpComTnvcussfdcoutbound_v1.RequestUpdateWrpaerClass respvar;
                trimblecorpComTnvcussfdcoutbound_v1.HeaderType reqvar = new trimblecorpComTnvcussfdcoutbound_v1.HeaderType();
                reqvar.sourceSystem = 'SFDC';
                reqvar.destinationSytem = 'FCH';
                reqvar.operation = 'Create';
             
         system.debug('records======='+records);            
     
               
                for(Failed_Callout_Accounts__c objvar:records){
                   
                     setAccids.add(objvar.Account_id__c);        
                 }
                 
                 for(Account ACC:[Select Id,Preferred_Language__c,Enterprise_Party_Number__c,Attention__c,Address_Check_Results__c,VAT_Number__c,Do_Not_Merge__c,Owner.Email,Customer_Name__c,Site_Name__c, IsDeleted,email__c,Parent.FCH_Party_Id__c,Ship_to_Flag__c,Lifecycle_Stage__c,Vertical_Classification__c,End_User_Flag__c,Bill_to_Flag__c,Credit_Check_Status__c,Address4__c,Parent_Account_ID__c,Global_Opt_Out__c,Installed_at_Flag__c,parent.id,Restricted_Entity__c, AccountSource,SicDesc,Ownership,Sic,Rating,Jigsaw,MasterRecordId, Name, Type, RecordTypeId, ParentId, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, ShippingLatitude, ShippingLongitude, Phone, Fax, Website, Industry, AnnualRevenue, NumberOfEmployees, Description, Site, CurrencyIsoCode, OwnerId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, IsPartner, JigsawCompanyId, pw_cc__BillingAddressStatus__c, pw_cc__ShippingAddressStatus__c, Account_Status__c, DUNS__c, Division__c, Forecast_Account__c, NAICS_Code__c, Oracle_ID__c, Region__c, Requested_Account_Record_Type__c, SIC_Code_del__c, Sub_Type__c, Submitted_for_Approval__c, sub_industry__c, Marketing_Segment__c, Sell_Through__c, Account_Forecast_Owner__c, Sell_ToFlag__c, Email_domain__c,  AddressValidated__c, Address1__c, Address2__c, Address3__c, Party_Original_System__c, FCH_Party_ID__c FROM Account  where id in : setaccids limit 10 ])
                 {
                    respvar = new trimblecorpComTnvcussfdcoutbound_v1.RequestUpdateWrpaerClass();                  
                
                                          respvar.CustomerName = acc.name;
                      respvar.LifecycleStage = acc.type;
                      respvar.CustomerLevel = acc.sub_type__c;
                      
                     respvar.PrimaryRegion = acc.Region__c ;
                      respvar.SelltoFlag = (acc.Sell_ToFlag__c == true)?'Yes':'No';
                      respvar.PrimaryEmailAddress = acc.Email_domain__c;
                      respvar.enterprisemasterid = acc.FCH_Party_Id__c; 
                    
                     respvar.AddressValidated = (acc.AddressValidated__c == true)?'Yes':'No';
                      respvar.Address1 = acc.Address1__c;
                      respvar.Address2 = acc.Address2__c;
                      respvar.Address3 = acc.Address3__c;
                      respvar.Address4 = acc.Address4__c;
                      respvar.City = acc.BillingCity;
                      respvar.State = acc.BillingState;
                      respvar.Country = acc.BillingCountry;
                      respvar.PostalCode = acc.Billingpostalcode;
                      respvar.party_OriginalSystem = 'SFDC';
                      respvar.Party_OriginalSystemReference = acc.id;               
                      respvar.BillingStreet = acc.billingstreet;          
                      respvar.AccountForecastOwner = acc.Account_Forecast_Owner__c;
                     respvar.AccountStatus = acc.Account_Status__c ;
                      respvar.AnnualRevenue = acc.AnnualRevenue;
                    
                      respvar.AccountSource = acc.AccountSource;
                      respvar.BillingLatitude = acc.BillingLatitude;
                      respvar.BillingLongitude = acc.BillingLongitude;
                      respvar.CurrencyIsoCode = acc.CurrencyIsoCode;
                      respvar.DUNS = acc.DUNS__c;
                      respvar.Description = acc.Description;
                      respvar.Division = acc.Division__c;
                      respvar.Fax = acc.Fax;
                    
                     respvar.Industry = acc.Industry;
                      respvar.JigsawCompanyId = acc.Jigsaw;
                    
                      respvar.MarketingSegment = acc.Marketing_Segment__c;
                    respvar.NAICSCode =  acc.NAICS_Code__c ;
                      respvar.NumberOfEmployees = acc.NumberOfEmployees;
                      respvar.phone = acc.Phone;
                      respvar.OracleID = acc.Oracle_ID__c;
                      respvar.Ownership = acc.Ownership;
                      respvar.pwccBillingAddressStatus = acc.pw_cc__BillingAddressStatus__c;
                      respvar.pwccShippingAddressStatus = acc.pw_cc__ShippingAddressStatus__c;
                     respvar.Rating = acc.Rating ;
                     respvar.SICCodedel = acc.Sic ;
                      respvar.SicDesc = acc.SicDesc;
                      respvar.SellThrough = acc.Sell_Through__c;
                     respvar.ShippingCity = acc.ShippingCity ;
                      respvar.ShippingCountry = acc.ShippingCountry;
                       respvar.ShippingState = acc.ShippingState;      
                      respvar.ShippingStreet = acc.ShippingStreet;
                     respvar.ShippingLatitude = acc.ShippingLatitude ;
                      respvar.ShippingLongitude = acc.ShippingLongitude;
                      respvar.ShippingPostalCode = acc.ShippingPostalCode;
                      respvar.Site = acc.site;   
                      
                      respvar.VerticalClassification = acc.Vertical_Classification__c; 
            respvar.subindustry = acc.sub_industry__c;                                           
                      respvar.webSite = acc.Website;                      
                      respvar.Division = acc.Division__c ;  
                      
                      respvar.AccountOwnerEmail = acc.email__c;
                      respvar.BilltoFlag = (acc.Bill_to_Flag__c == true)?'Yes':'No';
                      respvar.CreditStatus = acc.Credit_Check_Status__c;
                      respvar.EnterpriseParentID = acc.Parent_Account_ID__c;
                      respvar.GlobalOptOut = (acc.Global_Opt_Out__c == true)?'Yes':'No';
                      respvar.InstalledatFlag = (acc.Installed_at_Flag__c == true)?'Yes':'No';
                      respvar.Party_originalsystemParent = acc.parent.id;
                      //respvar.RestrictedPartyIndicator = (acc.Restricted_Entity__c!=null)?((acc.Restricted_Entity__c == true)?'Yes': 'No' ):'No'; 
                      respvar.RestrictedPartyIndicator = (acc.Restricted_Entity__c!=null)?((acc.Restricted_Entity__c == Label.Restricted)?'Yes': 'No' ):'No';                       
                      
                      respvar.Division = acc.Division__c ;  
                      
                      trimblecorpComTnvcussfdcoutbound_v1.tnvcusSFDCOutboundOutput_element respvar1 = new trimblecorpComTnvcussfdcoutbound_v1.tnvcusSFDCOutboundOutput_element();

                    trimblecorpComTnvcussfdcoutboundWsdl_v1.tnvcusSFDCOutboundPort_pt objvar1= new trimblecorpComTnvcussfdcoutboundWsdl_v1.tnvcusSFDCOutboundPort_pt();
                    respvar1 = objvar1.tnvcusSFDCOutbound(reqvar,respvar);     
                             
                 }
                  
                    
              
          }        
          catch (Exception e) {         
            //System.debug('Error:' + e.getMessage() + 'LN:' + e.getLineNumber() ); 
                      
          }
          set<id> delAccID = new set<id>();
          for(account acc: [Select id from Account where id in : setaccids AND Enterprise_Party_Number__c !=null ]){
          	delAccID.add(acc.id);
          } 
          
          for(Failed_Callout_Accounts__c objvar1:[Select id from Failed_Callout_Accounts__c where Account_id__c IN : delAccID]){
          	strAccountNames.add(objvar1);
          }
          if(strAccountNames!=null && strAccountNames.size()>0)
          delete strAccountNames;
       }
     

    global void finish(Database.BatchableContext BC){    
    }
    
     }