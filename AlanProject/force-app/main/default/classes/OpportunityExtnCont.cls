public class OpportunityExtnCont {
    
    public Opportunity opportunity{get;set;}
    public String opportunityId{get;set;}
    public String billToAddName{get;set;}
    public String shipToAddName{get;set;}
    public String Billaddress{get;set;}
    public String shipAddress{get;set;}
    public String billToContactName{get;set;}
    public String ShipToContactName{get;set;}
    public String billToAddressId{get;set;}
    public String shipToAddressId{get;set;}
    public String billToContactId{get;set;}
    public String shipToContactId{get;set;}
    public string billtoid{get;set;}
    public string ShipToAccountId{get;set;}
    public boolean showDetail{get;set;}
    
    public OpportunityExtnCont(ApexPages.StandardController controller) {
        opportunityId = ApexPages.currentPage().getParameters().get('id');
    }
    
    public void loadOptyDetail(){
        List<Opportunity> opptyList = new List<Opportunity>();
        opptyList = [Select Id,Bill_To_Contact__c,Bill_to_account__c,Bill_To_Contact__r.Name,Primary_Contact__r.Name, Name,Bill_to_Address_Disp__c,Ship_to_Address_Disp__c, CloseDate, Timeframe_to_Buy__c,Selling_Division__c,Opportunity_Product__c,Account.Number_of_Months__c, Demo_Date__c, EG_First_Meeting_Date__c, Price_List__c, Payment_Term__c, 
                    StageName,Number_of_Months__c,Partner_2__c,Bill_To_Address__c,Ship_To_Address1__c,Customer_Type__c,Reseller__c,Register_To__c, Product_Family__c,Product_Type__c, Primary_Contact__c, Probability, OwnerId, AccountId, Ship_To_Account__c, Ship_To_Address__c 
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
           Billaddress = opportunity.Bill_to_Address_Disp__c;
           shipAddress = opportunity.Ship_to_Address_Disp__c;
           billToContactName = opportunity.Bill_To_Contact__r.Name; 
           billToContactId = opportunity.Bill_To_Contact__c;
           shipToContactId = Opportunity.Primary_Contact__c;
           ShipToContactName = opportunity.Primary_Contact__r.Name;
        }            
    }
    
    public void getBillToAddress(){
        for(Address__c add : [Select Id,Name,account__c,account__r.EBS_Payment_Term__c,account__r.CurrencyISOCode,Address_Line1__c,Address_Line2__c,Address_Line3__c,Address_Line4__c,City__c,State__c,ZIP__c,Country__c from Address__c where Id =: billToAddressId and Bill_to__c= True limit 1]){
            Billaddress = formatAddress(add);
            opportunity.Bill_to_Address__c = add.Id;
            billToAddName= add.Name;
            billtoid=add.account__c;
        }
    }
    public void getShipToAddress(){
        for(Address__c add : [Select Name,Account__c,Address_Line1__c,Address_Line2__c,Address_Line3__c,Address_Line4__c,City__c,State__c,ZIP__c,Country__c from Address__c where Id =: shipToAddressId and Ship_To__c = True limit 1]){
            shipAddress = formatAddress(add);
            opportunity.Ship_to_Address1__c = add.Id;
            shipToAddName= add.Name;
            ShipToAccountId = add.Account__c; 
        }
    }
    public void getBillToContact(){
        for(Contact add : [Select Id,NAme,LastName from Contact where Id =: billToContactId limit 1]){
            opportunity.Bill_To_Contact__c = add.Id;
            billToContactName = add.NAme;
        }
    }
    public void getShipToContact(){
        for(Contact add : [Select Id,Name from Contact where Id =: shipToContactId limit 1]){
            opportunity.Primary_Contact__c = shipToContactId;
            ShipToContactName= add.Name;
        }
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
    public PageReference Save(){
         system.debug('opportunity >>>>'+opportunity);
         update opportunity;
         return null;
    }
}