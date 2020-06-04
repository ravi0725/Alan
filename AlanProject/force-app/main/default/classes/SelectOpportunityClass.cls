public with sharing class SelectOpportunityClass {
    public string accType{get;set;}
    public boolean flag;
    public String accountId{get;set;}
    public String accountId1{get;set;}
    public boolean invalidEntry{get;set;}
    public boolean showDetail{get;set;}
    public String opportunityId{get;set;}
    public String address{get;set;}  
    public String Billaddress{get;set;}
    public Opportunity opportunity{get;set;} 
    public Opportunity newOpportunity{get;set;} 
    public Apttus_Proposal__Proposal__c proposal{get;set;}
    public List<SelectOption> opportunityList{get;set;}
    public transient Map<String, Decimal> probabilityStageNameMap;
    public transient Map<String, Decimal> probabilityStageNameMapnew;
    Public String usrProfileName {get;set;}
    Public Boolean MEP {Get;set;}
    Public Boolean OtherDivision {get;set;}
    Public Integer NOM {get;Set;}
    Public Date ServiceStartDate {get;set;}
    Public Date ServiceEndDate {get;set;}
    Public Integer Duration {get;set;}
    Public String UOM {get;set;}
    public String addressObjPrefix{get;set;}
    public String shipAddress{get;set;}
    public String billToAddressId{get;set;}
    public String shipToAddressId{get;set;}
    public String billToContactId{get;set;}
    public String shipToContactId{get;set;}
    public String shipToAddName{get;set;}
    public String ShipToContactName{get;set;}
    public String billToContactName{get;set;}
    public String billToAddName{get;set;}
    Public string billtoid{get;set;}
    public string ShipToAccountId{get;set;}
    Public string curr{get;set;}
    public string Payterm {get;set;}

    List<Credit_Details_Tab_Customer_Account__c> credit = new List<Credit_Details_Tab_Customer_Account__c>();
    public void getBillToAddress(){
    system.debug('----------add.account__c--------'+billToAddressId);
        for(Address__c add : [Select Name,account__c,account__r.EBS_Payment_Term__c,account__r.CurrencyISOCode,Address_Line1__c,Address_Line2__c,Address_Line3__c,Address_Line4__c,City__c,State__c,ZIP__c,Country__c from Address__c where Id =: billToAddressId and Bill_to__c= True limit 1]){
            system.debug('----------add.account__c--------'+add.Id);
            Billaddress = formatAddress(add);
            newopportunity.Bill_to_Address__c = add.Id;
            opportunity.Bill_to_Address__c = add.Id;
            system.debug('----------add.account__c--------'+add.Account__c);
            //newopportunity.Bill_to_account__c = add.Account__c;
           // opportunity.Bill_to_account__c = add.Account__c;
            billToAddName= add.Name;
            system.debug('----------add.account__c--------'+add.account__c);
            billtoid=add.account__c;
            curr = add.account__r.CurrencyISOCode;
            Payterm = add.account__r.EBS_Payment_Term__c;
            system.debug('----------Payterm--------'+Payterm);
            newopportunity.Payment_Term__c = Payterm;
            opportunity.Payment_Term__c = Payterm;
            system.debug('----------EBS Payment Term--------'+Payterm);
        }
    }
   
    public boolean displayPopup {get; set;}     
    
    public PageReference closePopup() {        
        displayPopup = false;  
       return  new PageReference('/apex/QuoteDeleteCustomPage');   
    }     
    public void showPopup() {        
        displayPopup = true;    
    }
    
    
    public void getShipToAddress(){
        for(Address__c add : [Select Name,Account__c,Address_Line1__c,Address_Line2__c,Address_Line3__c,Address_Line4__c,City__c,State__c,ZIP__c,Country__c from Address__c where Id =: shipToAddressId and Ship_To__c = True limit 1]){
            shipAddress = formatAddress(add);
            newopportunity.Ship_to_Address1__c = add.Id;
            opportunity.Ship_to_Address1__c = add.Id;
            //opportunity.Ship_to_account__c = add.Account__c;
            //newopportunity.Ship_to_account__c = add.Account__c;
            shipToAddName= add.Name;
            ShipToAccountId = add.Account__c; 
        }
    }
    
    
    public void getBillToContact(){
        for(Contact add : [Select Id,NAme,LastName from Contact where Id =: billToContactId limit 1]){
            newopportunity.Bill_To_Contact__c = add.Id;
            opportunity.Bill_To_Contact__c = add.Id;
            billToContactName = add.NAme;
        }
    }
   
    
    public void getShipToContact(){
        for(Contact add : [Select Id,Name from Contact where Id =: shipToContactId limit 1]){
            newopportunity.Primary_Contact__c = shipToContactId;
            opportunity.Primary_Contact__c = shipToContactId;
            ShipToContactName= add.Name;
        }
    }
    
    /*public void updateServiceEndDate(){
        if(newOpportunity.Duration_UOM__c == 'Year'){
            newOpportunity.Service_End_Date__c = newOpportunity.Service_Start_Date__c.addYears(newOpportunity.Duration__c.intValue()) - 1;
            ServiceEndDate = newOpportunity.Service_Start_Date__c.addYears(newOpportunity.Duration__c.intValue()) - 1;
            Duration = newOpportunity.Duration__c.intValue();
            UOM = 'Year';
        }else if(newOpportunity.Duration_UOM__c == 'Month'){
            newOpportunity.Service_End_Date__c = newOpportunity.Service_Start_Date__c.addMonths(newOpportunity.Duration__c.intValue()) - 1;
            ServiceEndDate = newOpportunity.Service_Start_Date__c.addYears(newOpportunity.Duration__c.intValue()) - 1;
            Duration = newOpportunity.Duration__c.intValue();
            UOM = 'Month';
        }
        system.debug('--------Proposal-----------' + Proposal);
    }*/
    
    private Id fromAgreementId; /** WSL **/
    
    public SelectOpportunityClass(ApexPages.StandardController standardController){
    Account account1 = (Account)standardController.getRecord();
       
      opportunity = new Opportunity();
        newOpportunity = new Opportunity();
        shipAddress = '';
        billAddress = '';
        addressObjPrefix = Address__c.sObjectType.getDescribe().getKEyPrefix();
        usrProfileName = [select u.Profile.Name from User u where u.id = :Userinfo.getUserId()].Profile.Name; 
        if(usrProfileName.contains('MEP'))
        {
        MEP = True;
        }
        else
        {
        OtherDivision = True;
        }
        flag = false;
        invalidEntry = false;
        proposal = new Apttus_Proposal__Proposal__c();
        if(ApexPages.currentPage().getParameters().get('annualSupportMonth') != null && ApexPages.currentPage().getParameters().get('annualSupportDay') != null){
            proposal.Service_Start_Date__c = date.newInstance(date.today().year(),Integer.valueOf(ApexPages.currentPage().getParameters().get('annualSupportMonth')),Integer.valueOf(ApexPages.currentPage().getParameters().get('annualSupportDay')));
            ServiceStartdate = date.newInstance(date.today().year(),Integer.valueOf(ApexPages.currentPage().getParameters().get('annualSupportMonth')),Integer.valueOf(ApexPages.currentPage().getParameters().get('annualSupportDay')));
            Duration = 3;
            UOM = 'Year';
            proposal.Duration__c = 3;
            Proposal.Duration_UOM__c = 'Year';
            //updateServiceEndDate();
            system.debug('--------------------' + proposal);
        }
        Account account = (Account)standardController.getRecord();
        if(account != null){
                    
           accountId = account.Id; 
           showDetail = false;  
                    
           List<Opportunity> opptyList = new List<Opportunity>();
           opptyList = [Select Id, Name from Opportunity where AccountId =: accountId and StageName NOT IN ('6 - Closed Won', 'Closed Lost')];
           if(opptyList.size() > 0){
              invalidEntry = true;
              opportunityList = new List<SelectOption>();
              opportunityList.add(new SelectOption('None', '--None--'));
              for(Opportunity oppty : opptyList){
                opportunityList.add(new SelectOption(oppty.Id, oppty.Name));
              } 
           }
           else
           {
           
           }                            
        }else{
           invalidEntry = false;
           ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, Label.No_Records_Found);
           ApexPages.addMessage(msg); 
        }        
        
        fromAgreementId = (Id) ApexPages.currentPage().getParameters().get('initialAgreementId');
    }
    
    public PageReference initializeOptyRecords(){
        
        PageReference pageRef = null;
        if(!invalidEntry){
            Account acc = [select currencyISOCode,EBS_Payment_Term__c from Account where Id =: ApexPages.currentPage().getParameters().get('Id')];
            curr = acc.CurrencyISOCode;
            Payterm  = acc.EBS_Payment_Term__c;
            pageRef = Page.CreateQuoteOpportunity;
            pageRef.getParameters().put('id', accountId);
            date dt = [select Annual_Support_Date__c from Account where Id =: accountId].Annual_Support_Date__c;
            if(dt != null){
                pageRef.getParameters().put('annualSupportMonth', String.valueOf(dt.month()));
                pageRef.getParameters().put('annualSupportDay', String.valueOf(dt.day()));
            }
            pageRef.getParameters().put('CurrencyId',(Curr != null ? Curr : userinfo.getDefaultCurrency()));
            pageRef.setRedirect(true);            
        }
        return pageRef;
    }
    
    
    
    public String formatAddress(Address__c add){
        String ads = '';
        if(add.Address_Line1__c != null)
           ads = add.Address_Line1__c;
                    
        if(add.Address_Line2__c != null){
          if(ads != '')
            ads += ', ' + add.Address_Line2__c;   
          else
            ads = add.Address_Line2__c;      
        }
        if(add.Address_Line3__c != null){
          if(ads != '')   
            ads += ', ' + add.Address_Line3__c;   
          else
            ads = add.Address_Line3__c;
        }   
        if(add.Address_Line4__c != null){
          if(ads != '')   
            ads += ', ' + add.Address_Line4__c;   
          else
            ads = add.Address_Line4__c;   
        }    
        if(add.City__c!= null){
          if(ads != '')   
            ads += ', ' + add.City__c;   
          else
            ads = add.City__c;
        } 
        if(add.State__c!= null){
          if(ads != '')   
            ads += ', ' + add.State__c;   
          else
            ads = add.State__c;
        }
        if(add.Zip__c!= null){
          if(ads != '')   
            ads += ' - ' + add.Zip__c;   
          else
            ads = add.Zip__c;
        }
        
        if(add.Country__c!= null){
          if(ads != '')   
            ads += ', ' + add.Country__c;   
          else
            ads = add.Country__c;
        }  
        return ads;
    }
    
    public void validateBillShipToAddress(){
        if(accType == 'ShipTo' && ShipToAccountId != opportunity.Ship_To_Account__c){
            opportunity.Ship_to_Address1__c = null;
            shipAddress = '';
        }else if(accType == 'BillTo' && billtoid != opportunity.Bill_To_Account__c){
            opportunity.Bill_to_Address__c = null;
            Billaddress = '';
        }
    }
    
    public void loadOptyDetail(){
        flag = false;
        List<Opportunity> opptyList = new List<Opportunity>();
        opptyList = [Select Id,Bill_To_Contact__c,Bill_to_account__c,Bill_To_Contact__r.Name,Primary_Contact__r.Name, Name,Bill_to_Address_Disp__c,Ship_to_Address_Disp__c, CloseDate, Timeframe_to_Buy__c,Selling_Division__c,Opportunity_Product__c,Account.Number_of_Months__c, Demo_Date__c, EG_First_Meeting_Date__c, Price_List__c, Payment_Term__c, 
                    StageName,Number_of_Months__c,Partner_2__c,Bill_To_Address__c,Ship_To_Address1__c,Customer_Type__c,Reseller__c,Register_To__c, Product_Family__c,Product_Type__c, Primary_Contact__c, Probability, OwnerId, AccountId, Ship_To_Account__c, Ship_To_Address__c, LeadSource 
                    from Opportunity where Id =: opportunityId];
        
        if(opptyList.size() <= 0){
           ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, Label.No_Records_Found);
           ApexPages.addMessage(msg); 
           showDetail = false;
        }else{
           showDetail = true;
           opportunity = opptyList.get(0);
           billToAddressId = opportunity.Bill_To_Address__c;
           getBillToAddress();
           shipToAddressId = opportunity.Ship_To_Address1__c;
           getShipToAddress();
           opportunity.payment_Term__c = Payterm;
           system.debug('>>>>>>>OpptyPRD'+opportunity.Opportunity_Product__c);
           system.debug('>>>>>>>SellingDivision'+opportunity.Selling_Division__c);
           Billaddress = opportunity.Bill_to_Address_Disp__c;
           shipAddress = opportunity.Ship_to_Address_Disp__c;
           system.debug(shipAddress + '-------------Billaddress '+Billaddress );
           billToContactName = opportunity.Bill_To_Contact__r.Name; 
            billToContactId = opportunity.Bill_To_Contact__c;
            shipToContactId = Opportunity.Primary_Contact__c;
           ShipToContactName = opportunity.Primary_Contact__r.Name;
           proposal.Ship_To_Account__c = ShipToAccountId;           
           address = opportunity.Ship_To_Address__c;
           System.debug('-------------' + opportunity.Ship_To_Account__c);
           List<Account> accList = new List<Account>();
           accList = [Select Id, BillingStreet, BillingCity,Number_of_Months__c, BillingState, BillingCountry, BillingPostalCode, Restricted_Entity__c 
              from Account where Id =: opptyList.get(0).AccountId];
           if(opportunity.Ship_To_Account__c == null){
              if(accList.size() > 0 && accList.get(0).Restricted_Entity__c == Label.Not_Restricted){
                 NOM = Integer.valueof(accList.get(0).Number_of_Months__c == null ? 0 : accList.get(0).Number_of_Months__c);
                 opportunity.Number_of_Months__c = NOM;
                 opportunity.Ship_To_Account__c = ShipToAccountId;
                 proposal.Ship_To_Account__c = ShipToAccountId; 
                 address = '';              
                 Account acc = accList.get(0);
                 if(acc.BillingStreet != null)
                    address = acc.BillingStreet;
                            
                 if(acc.BillingCity != null){
                   if(address != '')
                     address += ', ' + acc.BillingCity;   
                   else
                     address = acc.BillingCity;      
                 }
                 if(acc.BillingState != null){
                   if(address != '')   
                     address += ', ' + acc.BillingState;   
                   else
                     address = acc.BillingState;
                 }     
                 if(acc.BillingCountry != null){
                   if(address != '')   
                     address += ', ' + acc.BillingCountry;   
                   else
                     address = acc.BillingCountry;   
                 }    
                 if(acc.BillingPostalCode != null){
                   if(address != '')   
                     address += ', ' + acc.BillingPostalCode;   
                   else
                     address = acc.BillingPostalCode;
                 }                                    
              }
           }else if(accList.size() > 0){
               NOM = Integer.valueof(accList.get(0).Number_of_Months__c == null ? 0 : accList.get(0).Number_of_Months__c);
               opportunity.Number_of_Months__c = NOM;
           }                        
        }            
    }
    
    public String shipToAccount{get;set;}
    public void loadAddress(){
        address = '';
        System.debug('proposal.Ship_To_Account__c: '+shipToAccount);
        if(shipToAccount != null && shipToAccount != ''){
          List<Account> accList = new List<Account>();
          List<Address__c> AddList = new List<Address__c>();
          accList = [Select BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode from Account where Name =: shipToAccount];
          AddList = [Select Address_Line1__c,Address_Line2__c,Address_Line3__c,Address_Line4__c,City__c,State__c,ZIP__c,Country__c from Address__c where id=:proposal.Bill_To_Address__c];
          if(accList.size() > 0){
            Account acc = accList.get(0);
            if(acc.BillingStreet != null)
               address = acc.BillingStreet;
                        
            if(acc.BillingCity != null){
              if(address != '')
                address += ', ' + acc.BillingCity;   
              else
                address = acc.BillingCity;      
            }
            if(acc.BillingState != null){
              if(address != '')   
                address += ', ' + acc.BillingState;   
              else
                address = acc.BillingState;
            }   
            if(acc.BillingCountry != null){
              if(address != '')   
                address += ', ' + acc.BillingCountry;   
              else
                address = acc.BillingCountry;   
            }    
            if(acc.BillingPostalCode != null){
              if(address != '')   
                address += ', ' + acc.BillingPostalCode;   
              else
                address = acc.BillingPostalCode;
            }      
            //address = acc.BillingStreet + ', ' + acc.BillingCity + ', ' + acc.BillingState + ', ' + acc.BillingCountry + ', ' + acc.BillingPostalCode;
            System.debug('address: '+address);
          }
          if(AddList.size()>0)
       {
       String Billaddress = '';              
          Address__c acc = AddList.get(0);
          if(acc.Address_Line1__c!= null)
             Billaddress = acc.Address_Line1__c;
                        
          if(acc.Address_Line2__c != null){
            if(Billaddress != '')
              Billaddress += ', ' + acc.Address_Line2__c;   
            else
              Billaddress = acc.Address_Line2__c;      
          }
          if(acc.City__c != null){
            if(Billaddress != '')   
              Billaddress += ', ' + acc.City__c;   
            else
              Billaddress = acc.City__c;
          }   
          if(acc.State__c != null){
            if(Billaddress != '')   
              Billaddress += ', ' + acc.State__c;   
            else
              Billaddress = acc.State__c;   
          }    
          if(acc.Country__c != null){
            if(Billaddress != '')   
              Billaddress += ', ' + acc.Country__c;   
            else
              Billaddress = acc.Country__c;
          }   
         if(acc.ZIP__c != null){
            if(Billaddress != '')   
              Billaddress += ', ' + acc.ZIP__c;   
            else
              Billaddress = acc.ZIP__c;
          }    
      }           
        }        
    }
    
    public PageReference next(){
    usrProfileName = [select u.Profile.Name from User u where u.id = :Userinfo.getUserId()].Profile.Name; 
       PageReference pageRef;
       Savepoint sp = null;
       String proposalId;
       boolean flag = false;
       if(opportunity.Price_List__c == null){
           ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Price_List_Required);
           ApexPages.addMessage(msg); 
           flag = true;
       }
       if(opportunity.Payment_Term__c == null){
           ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Payment_Term_Required);
           ApexPages.addMessage(msg); 
           flag = true;
       }       
      /* if(opportunity.Product_Family__c == null && usrProfileName.contains('MEP')){
           ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Product_Family_Required);
           ApexPages.addMessage(msg); 
           flag = true;
       }
       if(opportunity.Product_Type__c== null && !usrProfileName.contains('MEP')){
           ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Product_Type);
           ApexPages.addMessage(msg); 
           flag = true;
       } */
       if(opportunity.Primary_Contact__c == null){
           ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Primary_Contact_Required);
           ApexPages.addMessage(msg); 
           flag = true;
       }
        if(opportunity.Probability== 100){
           ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Cannot Create Quote for Closed / Won Opportunity.');
           ApexPages.addMessage(msg); 
           flag = true;
       }
       if(flag){
          return null;
       }        
       try {
          // get the database savepoint
          sp = Database.setSavepoint();         
          List<User> userList = new List<User>();
          userList = [Select Id, IsActive from User where Id =: opportunity.OwnerId];
          if(userList.size() > 0 && userList.get(0).IsActive){
             //opportunity.Ship_To_Account__c = proposal.Ship_To_Account__c;   
             opportunity.Payment_Term__c = Payterm;          
             update opportunity;
             proposalId = processQuote(opportunity.Id);          
             // Call the standard detail page navigate to the quote/proposal detail page        
             pageRef= new PageReference('/apex/Apttus_QPConfig__ProposalConfiguration?id='+proposalId+'&useAdvancedApproval=true&flow=Angular');                
          }else{
             ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Active_Owner_Message);
             ApexPages.addMessage(msg);    
             return null;
          }
          
       }catch (Exception ex){
          // report error
          ApexPages.addmessages(ex);            
          // if a savepoint was set, rollback updates
          if (sp != null) {
            Database.rollback(sp);          
          }        
          return null;        
      }
      pageRef.setRedirect(true);
      return pageRef;
    }
    
    public PageReference cancel(){
        if (fromAgreementId == null) {
            return new PageReference('/'+accountId); 
        } else {
            return new PageReference('/' + fromAgreementId);
        }
    }
    
    public PageReference createOpportunity(){
        List<Account> accList = [select Id,CurrencyISOCode from Account where Id =: accountId];    
       PageReference pageRef = Page.CreateQuoteOpportunity;
       pageRef.getParameters().put('id',accountId);
       date dt = [select Annual_Support_Date__c from Account where Id =: accountId].Annual_Support_Date__c;
        if(dt != null){
            pageRef.getParameters().put('annualSupportMonth', String.valueOf(dt.month()));
            pageRef.getParameters().put('annualSupportDay', String.valueOf(dt.day()));
        }
        
        system.debug('---------Pageref----------'+pageRef.getParameters().get('id'));
        
       pageRef.getParameters().put('CurrencyId',(accList != null ? accList.get(0).CurrencyISOCode : userinfo.getDefaultCurrency()));
       system.debug('---------Pageref----------'+pageRef.getParameters().get('CurrencyId'));
       pageRef.setRedirect(true);
       return pageRef;
    }
    
    public PageReference createQuote(){
        if(newOpportunity.Bill_To_Contact__c == null || newOpportunity.Primary_Contact__c == null){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Required information is missing.');
            ApexPages.addMessage(msg);    
            return null;
        }
        getBillToAddress();
        system.debug('^^^^^^^^^^^^^^^^^^^^^^^^'+billtoid );
        system.debug('^^^^^^^^^^^^^^^^^^^^^^^^'+curr);
        credit = [select Name,Available_Credit_Line_ACL__c from Credit_Details_Tab_Customer_Account__c where Account__c =:billtoid limit  1];
        system.debug('^^^^^^^^^^^^^^^^^^^^^^^^'+credit);   
        PageReference pageRef = null;
        Savepoint sp = null;
        String proposalId;
        
        try {
            // get the database savepoint
            sp = Database.setSavepoint();         
            List<User> userList = new List<User>();
            userList = [Select Id, IsActive from User where Id =: newOpportunity.OwnerId];
            system.debug('---------newOpportunity-----------' + userList.get(0).IsActive);
            if(userList.size() > 0 && userList.get(0).IsActive){
                system.debug('---------newOpportunity-----------' + newOpportunity);
                //newOpportunity.AccountId = accountId;
                system.debug('---------newOpportunity-----------' + newOpportunity.AccountId);
                //newOpportunity.Ship_To_Account__c = proposal.Ship_To_Account__c;
                
                newOpportunity.Payment_Term__c = Payterm;
                system.debug('---------newOpportunityCurrency----------'+newOpportunity.CurrencyISOCode);
                insert newOpportunity;                          
                system.debug('---------newOpportunity-----------' + [select Id,Number_of_Months__c from opportunity where Id =: newOpportunity.Id]);
                proposalId = processQuote(newOpportunity.Id);                                               
                // Call the standard detail page navigate to the quote/proposal detail page        
                pageRef= new PageReference('/apex/Apttus_QPConfig__ProposalConfiguration?id='+proposalId+'&useAdvancedApproval=true&flow=Angular');
            }else{
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Active_Owner_Message);
                ApexPages.addMessage(msg);    
                return null;
            }   
        } catch (Exception ex) {
            // report error
            ApexPages.addmessages(ex);            
            // if a savepoint was set, rollback updates
            if (sp != null) {
                Database.rollback(sp);          
            }        
            return null;        
        }
      
        if((credit.size()>0 && credit.get(0).Available_Credit_Line_ACL__c <=100 && newOpportunity.Probability >=75)||credit.size()==0){
        
            pageRef= new PageReference('/apex/CreditCheckEmailNotificationOppty?id='+proposalId+'&AcctId='+billtoid);
        }
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public void initializeOpportunity(){
       flag = true;
        PageReference pageRef = ApexPages.currentPage();

        Map<String, String> pageParameters = pageRef.getParameters();

        String Curstr = pageParameters.get('CurrencyId');
        
        newOpportunity = new Opportunity();
        //List<RecordType> recordTypes = new List<RecordType>();
        //recordTypes = [SELECT Id FROM RecordType WHERE DeveloperName =: Label.Opportunity_Plancal_Customer_Record_Type LIMIT 1];
        //if(recordTypes.size() > 0){
            //newOpportunity.RecordTypeId = recordTypes.get(0).Id;
       // }             
        List<Account> accList = new List<Account>();
        //List<Address__c> AddList = new List<Address__c>();
        accList = [Select Id, Name, BillingStreet,EBS_Payment_Term__c, Number_of_Months__c, BillingCity, BillingState, BillingCountry, BillingPostalCode, Restricted_Entity__c from Account where Id =: accountId];
        //AddList = [Select Address_Line1__c,Address_Line2__c,Address_Line3__c,Address_Line4__c,City__c,State__c,ZIP__c,Country__c from Address__c where Account__c =:accountId];
         
        if(accList.size() > 0){
            newOpportunity.Name = accList.get(0).Name + ' - ';
            Payterm = accList.get(0).EBS_Payment_Term__c;
        }  
        newOpportunity.StageName = '4 - Proposal/Price Quote';
        newOpportunity.Probability = 75;
        newOpportunity.OwnerId = UserInfo.getUserId();
        newOpportunity.CurrencyISOCode =  Curstr;
        newOpportunity.Payment_Term__c = Payterm;
        newOpportunity.accountId = (accList.size()>0 ? accList.get(0).id : '');
        newOpportunity.Ship_To_Account__c = (accList.size()>0 ? accList.get(0).id : '');
        newOpportunity.Bill_To_Account__c = (accList.size()>0 ? accList.get(0).id : '');
        newOpportunity.LeadSource = '';
        /*if(AddList.size()>0){
            newOpportunity.Bill_to_Address__c = AddList.get(0).id;
            newOpportunity.Ship_to_Address1__c = AddList.get(0).id ;
            billToAddressId = newOpportunity.Bill_to_Address__c;
            shipToAddressId = newOpportunity.Ship_to_Address1__c;
            getBillToAddress();
            getShipToAddress();
        }*/
        proposal = new Apttus_Proposal__Proposal__c();
        if(pageParameters.get('annualSupportMonth') != null && pageParameters.get('annualSupportDay') != null){
            newOpportunity.Service_Start_Date__c = date.newInstance(date.today().year(),Integer.valueOf(pageParameters.get('annualSupportMonth')),Integer.valueOf(pageParameters.get('annualSupportDay')));
            ServiceStartDate = date.newInstance(date.today().year(),Integer.valueOf(pageParameters.get('annualSupportMonth')),Integer.valueOf(pageParameters.get('annualSupportDay')));
            Duration = 3;
            UOM = 'Year';
            //newOpportunity.Duration__c = 3;
            //newOpportunity.Duration_UOM__c = 'Year';
            //updateServiceEndDate();
            system.debug('--------------------' + proposal);
        }
        /**
         * WSL - Frontera Consulting
         * Referencing an additional parameter to populate opportunity details.  Wrapped trimble code within the below
         * if statement
         */
        if (fromAgreementId != null) {
            FC_AgreementUtil.addInfoToOpportunity(fromAgreementId, newOpportunity);

            billToContactName = newOpportunity.Bill_To_Contact__r.Name; 
            billToContactId = newOpportunity.Bill_To_Contact__c;
            shipToContactId = newOpportunity.Primary_Contact__c;
            ShipToContactName = newOpportunity.Primary_Contact__r.Name;
        }

       if(accList.size() > 0){
          NOM = Integer.valueof((accList.get(0).Number_of_Months__c == null ? 0 : accList.get(0).Number_of_Months__c));
          newOpportunity.Number_of_Months__c = NOM;
         // proposal.Ship_To_Account__c = accList.get(0).Id; 
          //newOpportunity.Ship_To_Account__c = accList.get(0).Id; 
          /*address = '';              
          Account acc = accList.get(0);
          if(acc.BillingStreet != null)
             address = acc.BillingStreet;
                        
          if(acc.BillingCity != null){
            if(address != '')
              address += ', ' + acc.BillingCity;   
            else
              address = acc.BillingCity;      
          }
          if(acc.BillingState != null){
            if(address != '')   
              address += ', ' + acc.BillingState;   
            else
              address = acc.BillingState;
          }   
          if(acc.BillingCountry != null){
            if(address != '')   
              address += ', ' + acc.BillingCountry;   
            else
              address = acc.BillingCountry;   
          }    
          if(acc.BillingPostalCode != null){
            if(address != '')   
              address += ', ' + acc.BillingPostalCode;   
            else
              address = acc.BillingPostalCode;
          }                      
          System.debug('address: '+address); */               
       }
       
        /*if(AddList.size()>0)
       {
       String Billaddress = '';              
          Address__c acc = AddList.get(0);
          if(acc.Address_Line1__c!= null)
             Billaddress = acc.Address_Line1__c;
                        
          if(acc.Address_Line2__c != null){
            if(Billaddress != '')
              Billaddress += ', ' + acc.Address_Line2__c;   
            else
              Billaddress = acc.Address_Line2__c;      
          }
          if(acc.City__c != null){
            if(Billaddress != '')   
              Billaddress += ', ' + acc.City__c;   
            else
              Billaddress = acc.City__c;
          }   
          if(acc.State__c != null){
            if(Billaddress != '')   
              Billaddress += ', ' + acc.State__c;   
            else
              Billaddress = acc.State__c;   
          }    
          if(acc.Country__c != null){
            if(Billaddress != '')   
              Billaddress += ', ' + acc.Country__c;   
            else
              Billaddress = acc.Country__c;
          }   
         if(acc.ZIP__c != null){
            if(Billaddress != '')   
              Billaddress += ', ' + acc.ZIP__c;   
            else
              Billaddress = acc.ZIP__c;
          }    
      }*/
        // SURESH BABU MURUGAN : TT 129321 - SFDC: opportunity close date & proposal valid until date
        User cUser = [SELECT Id, Name, Division__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
        List<Apttus_Config2__PriceList__c> lstPricelists = [SELECT Id, Name FROM Apttus_Config2__PriceList__c WHERE Name LIKE 'TIBV%' AND (NOT Name LIKE '%OLD')AND Apttus_Config2__Active__c = TRUE];
        Map<String, Id> mapPricelistIds = new Map<String, Id>();
        for(Apttus_Config2__PriceList__c plist: lstPricelists){
            mapPricelistIds.put(plist.Name, plist.Id);
        }
        if(cUser.Division__c == 'MEP'){
            newOpportunity.Selling_Division__c = cUser.Division__c;
            
            String accountBillingCountry = (accList.size()>0 ? accList.get(0).BillingCountry : '');
            if(accountBillingCountry == 'Liechtenstein' || accountBillingCountry == 'Switzerland'){
                newOpportunity.Price_List__c = (mapPricelistIds.containsKey('TIBV CH Price List') ? mapPricelistIds.get('TIBV CH Price List') : null);
                newOpportunity.CloseDate = system.today().addDays(30);
            }
            else if(accountBillingCountry == 'Germany'){
                newOpportunity.Price_List__c = (mapPricelistIds.containsKey('TIBV DE Price List') ? mapPricelistIds.get('TIBV DE Price List') : null);
                newOpportunity.CloseDate = system.today().addDays(14);
            }
            else if(accountBillingCountry == 'France'){
                newOpportunity.Price_List__c = (mapPricelistIds.containsKey('TIBV FR Price List') ? mapPricelistIds.get('TIBV FR Price List') : null);
                newOpportunity.CloseDate = [SELECT StartDate, EndDate FROM Period WHERE Type = 'Quarter' and StartDate = THIS_FISCAL_QUARTER].EndDate;
            }
            else if(accountBillingCountry == 'Austria'){
                newOpportunity.Price_List__c = (mapPricelistIds.containsKey('TIBV AT Price List') ? mapPricelistIds.get('TIBV AT Price List') : null);
                newOpportunity.CloseDate = system.today().addDays(14);
            }
            else if(accountBillingCountry == 'United Kingdom'){
                newOpportunity.Price_List__c = (mapPricelistIds.containsKey('TIBV UK Price List') ? mapPricelistIds.get('TIBV UK Price List') : null);
                newOpportunity.CloseDate = system.today().addDays(14);
            }
            else if(accountBillingCountry == 'Italy' || accountBillingCountry == 'Hungary' ||
                    accountBillingCountry == 'Poland' || accountBillingCountry == 'Netherlands' ||
                    accountBillingCountry == 'Belgium' || accountBillingCountry == 'Denmark' ||
                    accountBillingCountry == 'Czech Republik' || accountBillingCountry == 'Romania' ||
                    accountBillingCountry == 'Slovakia' || accountBillingCountry == 'Croatia' ||
                    accountBillingCountry == 'Greece' || accountBillingCountry == 'Serbia'){
                        newOpportunity.Price_List__c = (mapPricelistIds.containsKey('TIBV NL Price List') ? mapPricelistIds.get('TIBV NL Price List') : null);
                        newOpportunity.CloseDate = system.today().addDays(14);
            }
            
            List<Address__c> lstAllAddresses = new List<Address__c>();
            lstAllAddresses = [SELECT Id, Address_Line1__c, Bill_To__c, Ship_To__c, Primary__c FROM Address__c WHERE Account__c =: accountId AND Primary__c = TRUE LIMIT 1];
            if(lstAllAddresses.size() == 1){
                if(lstAllAddresses.get(0).Bill_To__c){
                    newOpportunity.Bill_to_Address__c = lstAllAddresses.get(0).Id;
                    billToAddressId = newOpportunity.Bill_to_Address__c;
                    getBillToAddress();
                }
                if(lstAllAddresses.get(0).Ship_To__c){
                    newOpportunity.Ship_to_Address1__c = lstAllAddresses.get(0).Id ;
                    shipToAddressId = newOpportunity.Ship_to_Address1__c;
                    getShipToAddress();
                }
            }
        }
        // TT 129321 - SFDC: opportunity close date & proposal valid until date //
    }
    @TestVisible
    private String processQuote(Id optyId){
        String proposalId;
        // get the opportunity sobject          
        Opportunity opptySO = expressQuote.getOpportunitySO(optyId);          
        // create the quote/proposal
        /** WSL-Frontera **/
        system.debug(' opptySO ===>'+opptySO);
        if (fromAgreementId == null) {
            proposalId = expressQuote.createQuoteOrProposal(opptySO, ShipToAccountId);
        } else {
            proposalId = expressQuote.createQuoteOrProposalFromAgreement(opptySO, ShipToAccountId, fromAgreementId);
        }
        //proposalId = 'a1Sc0000000oQCU';
        return proposalId;
    }
    
    public PageReference changeStageName() {
          if (probabilityStageNameMap == null) {
                 probabilityStageNameMap = new Map<String, Decimal>();
                 for (OpportunityStage oppStage : [Select MasterLabel, DefaultProbability
                                      From OpportunityStage]) {
                         probabilityStageNameMap.put(oppStage.MasterLabel, oppStage.DefaultProbability);
                  }
           }
  
          if (probabilityStageNameMap.containsKey(opportunity.StageName)) {
                opportunity.Probability = probabilityStageNameMap.get(opportunity.StageName);
           }
          return null;
    }
    
    public PageReference changenewStageName() {
          if (probabilityStageNameMapnew == null) {
                 system.debug('test');
                 probabilityStageNameMapnew = new Map<String, Decimal>();
                 for (OpportunityStage oppStage : [Select MasterLabel, DefaultProbability
                                      From OpportunityStage]) {
                         probabilityStageNameMapnew.put(oppStage.MasterLabel, oppStage.DefaultProbability);
                  }
           }
              //system.debug('test1'+newopportunity.StageName);
          if (probabilityStageNameMapnew.containsKey(newopportunity.StageName)) {
                newopportunity.Probability = probabilityStageNameMapnew.get(newopportunity.StageName);
           }
           system.debug('test2'+newopportunity.Probability);
          return null;
    }
}