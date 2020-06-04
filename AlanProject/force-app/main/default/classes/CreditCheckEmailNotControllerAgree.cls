/*****************************************************************************************
    Name        : CreditCheckEmailNotControllerAgree
    Desc        :Used to send Email Notification to the credit check team.     
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Prince Leo           11/06/2015          Created
******************************************************************************************/
public class CreditCheckEmailNotControllerAgree{

public String AggId{get;set;}
Public String AccId{get;set;}
public string ACL{get;set;}
Public String Curr{get;set;}
public Boolean errorPopup {get;set;}
public Boolean EntpriseID {get;set;}
Public String EnterPriseErr {get;set;}
public String errorMsg{get;set;}
Public String Comments {get;set;}
List<Credit_Details_Tab_Customer_Account__c> credit = new List<Credit_Details_Tab_Customer_Account__c>();
List<Account> BillToAcc = new List<Account>();
public CreditCheckEmailNotControllerAgree(){
       AggId = System.currentPageReference().getParameters().get('id');
       AccId = System.currentPageReference().getParameters().get('AcctId');
       Curr = System.currentPageReference().getParameters().get('Currency');
       
       credit = [select id,Available_Credit_Line_ACL__c from Credit_Details_Tab_Customer_Account__c where Account__c =:Accid];
       BillToAcc = [select id,Phone,Collector_Name__c,COLLECTOR_Email__c,EBS_Account_Number__c,Credit_Manager_Notified__c,Credit_Request_Comment__c,Name,Enterprise_Party_Number__c,BillingStreet,BillingCity,BillingCountry,BillingPostalCode,BillingState from account where id =:AccId];
       if(credit.size()>0)
       ACL ='USD '+ String.valueof(credit.get(0).Available_Credit_Line_ACL__c);
       else
       ACL = 'USD 0';
    }
   
    public boolean displayPopup {get; set;}     
    
    public PageReference closePopup() {  
     Account Acct = new Account(id=BillToAcc.get(0).id);
    Acct.Credit_Request_Comment__c =Comments;
    Acct.Credit_Manager_Notified__c ='Email Sent'; 
    update Acct;      
        displayPopup = false;  
    return new PageReference('/apex/Apttus__SendEmail?id='+AggId+'&action=Send_To_Other_Party_For_Signatures');
     }     
     
    Public Pagereference ContOver(){
    
    return new PageReference('/apex/Apttus__SendEmail?id='+AggId+'&action=Send_To_Other_Party_For_Signatures');
    }
    public PageReference showPopup() {    
    if(credit.size()>0 && credit.get(0).Available_Credit_Line_ACL__c <=100 && BillToAcc.get(0).Enterprise_Party_Number__c != Null){    
        displayPopup = true;    
        return null;
      }
      else if(BillToAcc.get(0).Enterprise_Party_Number__c == Null)
      {
       EntpriseID = True;
       displayPopup = False;
       EnterPriseErr ='Credit Check Bypassed as the Customer Do not have Enterprise Master Id.';
       return null;
      }
      else
     return new PageReference('/apex/Apttus__SendEmail?id='+AggId+'&action=Send_To_Other_Party_For_Signatures');
    }
   Public Pagereference Cont(){
    return new PageReference('/apex/Apttus__SendEmail?id='+AggId+'&action=Send_To_Other_Party_For_Signatures');  
      
  }  
  
    
public PageReference SendEmail(){
       try{
        Account Acct = new Account(id=BillToAcc.get(0).id);
    Acct.Credit_Request_Comment__c =Comments;
    Acct.Credit_Manager_Notified__c ='Email Sent'; 
    update Acct;
    
        List<String> toAdd = new List <String>();
         displayPopup = false; 
       if(BillToAcc.size()>0 && credit.size()>0){
     /*  List<Credit_Check_Email__c> cce= Credit_Check_Email__c.getall().values();
       
       for(Credit_Check_Email__c ce : cce)
       {
       if(ce.country__c == BillToAcc.get(0).billingcountry)
       {
       toAdd = ce.Email__c.split('\\;');
       }
       else if(ce.Country__c=='Generic')
       toAdd = ce.Email__c.split('\\;');
       }
    */
    
    toadd.add(BillToAcc.get(0).Collector_Email__c);
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
         mail.setSubject('Credit Evaluation - '+BillToAcc.get(0).Name);
      String body = 'Hi Credit & Collection Team,<Br/><BR />';
      body += 'This customer has been identified as needing a credit evaluation:<BR /><BR />';
      body += '<u>Customer Name:</u> '+BillToAcc.get(0).Name+'<BR />';
      body += '<u>Customer Address:</u> '+street+', '+city+', '+state+', '+zipcode+', '+country+'<BR />';
      body += '<u>Customer Phone Number:</u> '+BillToAcc.get(0).Phone+'<BR />';
      body += '<u>Enterprise Account Number:</u> '+BillToAcc.get(0).Enterprise_Party_Number__c+'<BR />';
      body += '<u>Oracle Account Number:</u> '+BillToAcc.get(0).EBS_Account_Number__c+'<BR />';
      body += '<u>Credit Request Comment:</u> '+Comments.replaceall('','')+'<BR /><BR/>';
      body += '<u>Collector Name:</u> '+collectorName+'<BR />';
      body += '<BR/><BR/>Thanks,<BR/><BR/>';
      body += SalesrepName+'<BR/>';
      body += Division+'<BR/>';
     // body += BusinessArea;
         mail.setHtmlBody(body);
         mails.add(mail);
        if(BillToAcc.get(0).Enterprise_Party_Number__c != Null)
         Messaging.sendEmail(mails);
         
    errorPopup = False;
     }
     
       }
      catch(Exception e){
          errorPopup = true;
          errorMsg = e.getMessage();
          
       }  
        if(errorPopup == false)
      return new PageReference('/apex/Apttus__SendEmail?id='+AggId+'&action=Send_To_Other_Party_For_Signatures');
      else
       return null;
     
      
      // return  new PageReference('/'+OppID); 
       }
       
  
}