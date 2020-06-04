/*****************************************************************************************
    Name        : Cross_Division_Quote_ApprovalCntrl
    Desc        :Used to send Email Notification to the credit check team.     
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Prince Leo           11/06/2015          Created
******************************************************************************************/
public class Cross_Division_Quote_ApprovalCntrl{

public String OppID{get;set;}
Public String AccId{get;set;}
Public string errorMsg{get;set;}
public boolean errorPopup{get;set;}
List<Account> BillToAcc = new List<Account>();
public Cross_Division_Quote_ApprovalCntrl(){
       OppID = System.currentPageReference().getParameters().get('id');
       AccId = System.currentPageReference().getParameters().get('AcctId');
       BillToAcc = [select id,owner.Email,owner.Manager.Email,collector_Name__c,Account_Division__c,Collector_Email__c,Enterprise_Party_Number__c,Name,BillingStreet,Country_Code__c,BillingCity,BillingCountry,BillingPostalCode,BillingState from account where id =:OppID];
    
    }
    
    public boolean displayPopup {get; set;}     
    
    public PageReference closePopup() {        
        displayPopup = false;  
       return  new PageReference('/'+OppId);    
    }     
    public void showPopup() {        
        displayPopup = true;    
    }
    
  Public Pagereference exit(){
   return  new PageReference('/'+OppID);
  }
    
  public void SendEmail(){
       try{
       List<String> toAdd = new List <String>();
        
     
      // toadd.add(BillToAcc.get(0).Collector_Email__c);
         toadd.add(Label.Admin_Email);
         User u = [select Id,FirstName,LastName,manager.Email,Division__c,Business_Area__c, username from User where Id = :UserInfo.getUserId()];
         if(BillToAcc.get(0).owner.Email!=Null)
         toadd.add(BillToAcc.get(0).owner.Email);
         if(BillToAcc.get(0).owner.Manager.Email!=Null)
         toadd.add(BillToAcc.get(0).owner.Manager.Email);
         List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
         Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
         mail.setSenderDisplayName('Trimble SFDC');
         mail.setToAddresses(toAdd);
         mail.setSubject('Action Item Initiated for Cross Division Quote Creation');
      String body = 'Dear Manager,<Br/><BR />';
      body += 'Please add the Account Division Value: '+u.Division__c+' to the Account '+BillToAcc.get(0).Name+'<BR /><BR />';
      body +='Quick Link: '+Label.Internal_UAT_url+'/'+BillToAcc.get(0).Id;
      body += '<BR/><BR/>Thanks,<BR/><BR/>';
      body += ' SFDC Admin Team <BR/>';
         mail.setHtmlBody(body);
         mails.add(mail);
      Messaging.sendEmail(mails);
     displayPopup = true;
            
     //  return null;  
       
    }
       catch(Exception e){
          errorPopup = true;
          errorMsg = e.getMessage();
       }  
      // return  new PageReference('/'+OppID); 
       }
}