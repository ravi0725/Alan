/*****************************************************************************************
    Name        : CreditCheckEmailNotificationOppty
    Desc        :Used to send Email Notification to the credit check team.     
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Prince Leo           11/06/2015          Created
******************************************************************************************/
public class CreditCheckEmailNotificationOppty{

public String OppID{get;set;}
Public String AccId{get;set;}
Public string errorMsg{get;set;}
public boolean errorPopup{get;set;}
public Boolean EntpriseID {get;set;}
Public String EnterPriseErr {get;set;}
Public String Comments {get;set;}
List<Account> BillToAcc = new List<Account>();
public CreditCheckEmailNotificationOppty(){
       OppID = System.currentPageReference().getParameters().get('id');
       AccId = System.currentPageReference().getParameters().get('AcctId');
       BillToAcc = [select id,Phone,Region__c,collector_Name__c,EBS_Account_Number__c,Collector_Email__c,Enterprise_Party_Number__c,Name,BillingStreet,Country_Code__c,BillingCity,BillingCountry,BillingPostalCode,BillingState from account where id =:AccId];
    
    }
    
    public boolean displayPopup {get; set;}     
    
    public PageReference closePopup() {        
        displayPopup = false;  
       return new PageReference('/apex/Apttus_QPConfig__ProposalConfiguration?id='+oppId+'&useAdvancedApproval=true&flow=Angular'); 
    }  
    Public Pagereference BacktoAccount(){
    return new Pagereference('/'+BillToAcc.get(0).id);
    }
    public void showPopup() {   
    if(BillToAcc.get(0).Enterprise_Party_Number__c != Null)     
        displayPopup = true;    
        else{
         EntpriseID = True;
         displayPopup = False;
         EnterPriseErr ='Credit Check Bypassed as the Customer Do not have Enterprise Master Id.';
         }
        
    }
    
  Public Pagereference cont(){
 return new PageReference('/apex/Apttus_QPConfig__ProposalConfiguration?id='+oppId+'&useAdvancedApproval=true&flow=Angular');   
      
  }
    
public PageReference SendEmail(){
       try{
         List<String> toAdd = new List <String>();
         displayPopup = false; 
       if(BillToAcc.size()>0){
      
     /*  List<Credit_Check_Email__c> cce= Credit_Check_Email__c.getall().values();
       
       for(Credit_Check_Email__c ce : cce)
       {
       if(ce.country__c == BillToAcc.get(0).billingcountry)
       {
       toAdd = ce.Email__c.split('\\;');
       }
       else if(ce.Country__c=='Generic')
       toAdd = ce.Email__c.split('\\;');
       } */
        if(BillToAcc.get(0).Collector_Email__c!=Null)
        toadd.add(BillToAcc.get(0).Collector_Email__c);
        else if(BillToAcc.get(0).Region__c=='North America')
        toadd.add(Label.Collector_Email_ARFC);
        else
        toadd.add(Label.Collector_Email_ERFC);
         // ID OrgID = '0D2i0000000TNQM';
        User u = [select Id,FirstName,LastName,Division__c,Business_Area__c, username from User where Id = :UserInfo.getUserId()];
        String SalesrepName = (u.FirstName !=Null ? u.FirstName : ' ') + ' '+u.LastName;
        String Division = (u.Division__c !=Null ? u.Division__c : ' ');
        String BusinessArea = (u.Business_Area__c !=Null ? u.Business_Area__c : ' ');
         String street = (BillToAcc.get(0).BillingStreet != Null ? BillToAcc.get(0).BillingStreet : ' ');
        string city = (BillToAcc.get(0).Billingcity != Null ? BillToAcc.get(0).Billingcity : ' ');
        string state = (BillToAcc.get(0).BillingState != Null ? BillToAcc.get(0).BillingState : ' ');
        string country = (BillToAcc.get(0).BillingCountry != Null ? BillToAcc.get(0).BillingCountry : ' ');
        string zipcode = (BillToAcc.get(0).BillingPostalCode != Null ? BillToAcc.get(0).BillingPostalCode : ' ');
        string collectorName = (BillToAcc.get(0).Collector_Name__c != Null ? BillToAcc.get(0).Collector_Name__c : ' ');
         List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
         Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
         mail.setSenderDisplayName('Trimble SFDC');
       //mail.setOrgWideEmailAddressId(OrgID);
         mail.setToAddresses(toAdd);
         mail.setSubject('Credit Evaluation - '+BillToAcc.get(0).Name+', '+country);
      String body = 'Hi Credit & Collection Team,<Br/><BR />';
      body += 'This customer has been identified as needing a credit evaluation:<BR /><BR />';
      body += '<u>Customer Name:</u> '+BillToAcc.get(0).Name+'<BR />';
      body += '<u>Customer Address:</u> '+street+', '+city+', '+state+', '+zipcode+', '+country+'<BR />';
      body += '<u>Customer Phone Number:</u> '+BillToAcc.get(0).Phone+'<BR />';
      body += '<u>Enterprise Account Number:</u> '+BillToAcc.get(0).Enterprise_Party_Number__c+'<BR />';
      body += '<u>Oracle Account Number:</u> '+BillToAcc.get(0).EBS_Account_Number__c+'<BR /><BR/>';
      body += '<u>Collector Name:</u> '+collectorName+'<BR />';
      body += '<BR/><BR/>Thanks,<BR/><BR/>';
      body += SalesrepName+'<BR/>';
      body += Division+'<BR/>';
      //body += BusinessArea;
         mail.setHtmlBody(body);
         mails.add(mail);
        
         Messaging.sendEmail(mails);
        
    //displayPopup = true;
    errorPopup= False;
     }
      
     
       }
       catch(Exception e){
          errorPopup = true;
          errorMsg = e.getMessage();
          
       }  
      // return  new PageReference('/'+OppID); 
      if(errorPopup == false)
       return new PageReference('/apex/Apttus_QPConfig__ProposalConfiguration?id='+oppId+'&useAdvancedApproval=true&flow=Angular'); 
        
      
      else
     // return new PageReference('/apex/'+Label.Configure_Products_VF_Page+'?id='+oppId+'&useAdvancedApproval=true');  
      return null;
       }
       
  
}