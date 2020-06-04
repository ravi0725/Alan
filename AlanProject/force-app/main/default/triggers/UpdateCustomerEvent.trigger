/**
 * Company     : Trimble Software Technology Pvt Ltd.,
 * Description : To Upate a Field "Contact Names" on Customer Event Object. 
 * History     :  

 * [12.MAR.2014] Prince Leo Created*/
 
trigger UpdateCustomerEvent on Contact (after Insert,after Update) {
try{
    List<Contact> ConList = new List<Contact>();
    List<Customer_Event__c> Ce = new List<Customer_Event__c>();
    List<Customer_Event__c> Upce= new List<Customer_Event__c>();
    List<Account> Acc = new List<Account>();
    List<Opportunity> Opp = new List<Opportunity>();
    Set<ID>CustEvId = new Set<ID>();
    Set<ID>AccId = new Set<ID>();
    Set<ID>OppID = new Set<ID>();
    String ConNames=' ';
        for(contact c : Trigger.new)
        {
         if(c.Customer_Event__c!=null)
         CustEvId.add(c.Customer_Event__c);
         AccId.add(c.Accountid);
        }
  ConList = [select id,Name from contact where Customer_Event__c in:CustEvId];
  
  
 /* // Lead Conversion Description__c mapping to Account.Description
      if(Trigger.Isinsert)
      {
      Acc = [Select id,Description from Account where id in:AccId];
      opp = [Select id,Description from Opportunity where id in:OppId];
      if(Acc.size()>0 && Trigger.New.size()==1){
      Account AccUp = Acc.get(0);
      AccUp.Description = Trigger.new[0].Description;
      Update Accup;
      }
      if(Opp.size()>0 && Trigger.New.size()==1){
      Opportunity Oppup = Opp.get(0);
      Oppup.Description = Trigger.new[0].Description;
      Update Oppup;
      }
      } */
      
  for(Contact c : ConList)
  {
  ConNames = ConNames + c.Name + ' / ';
 
  } 
 ce = [select id,Contact_Names__c from Customer_Event__c where id =:CustEvId];
      if(ce.size()>0){
      for(Customer_Event__c c : ce){
      c.Contact_Names__c = ConNames;
      system.debug('&*&*&*&*&'+c.Contact_Names__c);
      Upce.add(c);
       }
      if(Upce.size()>0)
      update Upce;
    }
    }
    
   catch(Exception e){
                    system.debug('exception e==='+e);
                   }
    
  }