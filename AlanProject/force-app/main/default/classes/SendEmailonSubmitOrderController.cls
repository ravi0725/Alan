/*****************************************************************************************
    Name        : SendEmailonSubmitOrderController
    Desc        :Used to send Email Notification to the credit check team.     
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Prince Leo           11/06/2015          Created
******************************************************************************************/
public class SendEmailonSubmitOrderController{

String AggID,PaymentTermForCountry;
String CreditStatus;
String QuoteID;
List<Account> BillToAcc = new List<Account>();
List<Apttus_Proposal__Proposal__c> Prop = new List<Apttus_Proposal__Proposal__c>();
List<Apttus__APTS_Agreement__c> Aggree = new List<Apttus__APTS_Agreement__c>();
List<Apttus_CMConfig__AgreementSummaryGroup__c> AggSum = new List<Apttus_CMConfig__AgreementSummaryGroup__c>();
public SendEmailonSubmitOrderController(){
      
     //  Prop = [select id,Name,Bill_to_Address__r.Account__c from Apttus_Proposal__Proposal__c where id=:QuoteID];
      // BillToAcc = [select id,Enterprise_Party_Number__c,Name,BillingStreet,Country_Code__c,BillingCity,BillingCountry,BillingPostalCode,BillingState from account where id =:Prop.get(0).Bill_to_Address__r.Account__c];
     //  Aggree = [Select id,Fusion_Project_Number__c,Agreement_Number_for_Fusion__c,Apttus__FF_Agreement_Number__c,Apttus__Contract_Start_Date__c,Apttus__Contract_End_Date__c,Total_Agreement_Value_Formula__c,Organization__c from Apttus__APTS_Agreement__c where id=:AggId];
      // StartProcess();
       
system.debug('');
}
Public Pagereference StartProcess()
{
Pagereference Temp;


      return Temp;
}

    Public Pagereference SendEmailToAdmin()
    {
        try{
       List<String> toAdd = new List <String>();
        
       if(Aggree.size()>0){
       List<FusionProjectAdminMap__c> cce= FusionProjectAdminMap__c.getall().values();
       
       for(FusionProjectAdminMap__c ce : cce)
       {
       if(ce.Organization__c == Aggree.get(0).Organization__c)
       {
       toAdd.add(ce.Project_Administrator_Email__c);
       }
      }
      
   User u = [select Id,FirstName,LastName,Division__c,Business_Area__c, username from User where Id = :UserInfo.getUserId()];
        String SalesrepName = (u.FirstName !=Null ? u.FirstName : ' ') + ' '+u.LastName;
        String Division = (u.Division__c !=Null ? u.Division__c : ' ');
        String BusinessArea = (u.Business_Area__c !=Null ? u.Business_Area__c : ' ');
        ID templateId = '00Xe0000000Isqf';
         List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
         Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
         mail.setSenderDisplayName('Trimble SFDC');
       //mail.setOrgWideEmailAddressId(OrgID);
         mail.setToAddresses(toAdd);
        mail.setSubject('Contract Activated Notification.');
      String body = 'Dear Contract Admin,<Br/><BR />';
      body += 'Below Agreement and Project has been created and Activated. Please create Contract details in Oracle Fusion PPM.<BR /><BR />';
      body += 'Agreement No# '+Aggree.get(0).Apttus__FF_Agreement_Number__c+'<BR />';
      body += 'Project Number # '+Aggree.get(0).Fusion_Project_Number__c+'<BR />';
      body += '<BR/><BR/>Thanks,<BR/><BR/>';
      body += SalesrepName+'<BR/>';
      body += Division+'<BR/>';
      body += BusinessArea;
         mail.setHtmlBody(body);
       //  mail.setTargetObjectId(Aggree.get(0).id);
       //  Mail.setTemplateId(templateId);
         mails.add(mail);
         Messaging.sendEmail(mails);
         List<Messaging.SendEmailResult> results =

    Messaging.sendEmail(new Messaging.Email[] { mail });

if (!results.get(0).isSuccess()) {

    System.StatusCode statusCode = results.get(0).getErrors()[0].getStatusCode();

    String errorMessage = results.get(0).getErrors()[0].getMessage();
    system.debug('******************'+ errorMessage);
}

else
{
system.debug('********Success**********');
 return  new PageReference('/'+AggID); 
}

    //return  new PageReference('/'+AggID); 
    }
    
    }
       catch(Exception e){
          
       } 
   return  new PageReference('/'+AggID);  
     }
   
    Public void SendEmailToCredit(ID QuoteID, ID AggId)
    {
       Prop = [select id,Name,Payment_Terms_Oppty__c,CurrencyIsoCode,CREDIT_CALCULATED_EXPOSURE__c,CREDIT_EXISTING_EXPOSURE__c,CREDIT_LIMIT_AVAILABLE__c,CREDIT_TOTAL_EXPOSURE__c,Bill_to_Address__r.Account__c from Apttus_Proposal__Proposal__c where id=:QuoteID];
       BillToAcc = [select id,Collector_Email__c,EBS_Account_Number__c,collector_Name__c,Enterprise_Party_Number__c,Name,BillingStreet,Country_Code__c,BillingCity,BillingCountry,BillingPostalCode,BillingState from account where id =:Prop.get(0).Bill_to_Address__r.Account__c];
       Aggree = [Select id,CurrencyIsoCode,Fusion_Project_Number__c,Agreement_Number_for_Fusion__c,Apttus__FF_Agreement_Number__c,Apttus__Contract_Start_Date__c,Apttus__Contract_End_Date__c,Total_Agreement_Value_Formula__c,Organization__c from Apttus__APTS_Agreement__c where id=:AggId];
       AggSum = [select id,Name,Apttus_CMConfig__NetPrice__c,Apttus_CMConfig__ChargeType__c from Apttus_CMConfig__AgreementSummaryGroup__c where Apttus_CMConfig__AgreementId__c =: Aggree.get(0).id and Apttus_CMConfig__LineType__c ='Category Total'];
    try{
       List<String> toAdd = new List <String>();
       System.debug('-------------Prop--------------'+Prop); 
       System.debug('-------------BillToAcc--------------'+BillToAcc); 
       System.debug('-------------Aggree--------------'+Aggree); 
       System.debug('--------------AggSum-------------'+AggSum); 
       if(BillToAcc.size()>0){
      List<Country_Region_Mapping__c> cce= Country_Region_Mapping__c.getall().values();
       
       for(Country_Region_Mapping__c ce : cce)
       {
       if(ce.Name == BillToAcc.get(0).billingcountry)
       {
       PaymentTermForCountry= ce.Standard_Payment_Term__c;
       }
       
       }
       
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
        string collectorname = (BillToAcc.get(0).Collector_Name__c!= Null ? BillToAcc.get(0).Collector_Name__c: ' ');
         List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
         Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
         mail.setSenderDisplayName('Trimble SFDC');
         mail.setReplyTo(Label.Credit_Check_Reply_Email);
        // mail.setReplyTo('credit_check_email_service@j-14nbkm98nf6xpltbnrk3a375m86w2yuzfopv4zo90cvf1v132r.c-3kc8leae.cs14.apex.sandbox.salesforce.com');
       //mail.setOrgWideEmailAddressId(OrgID);
         mail.setToAddresses(toAdd);
      String Tabstr;
      String Temp=' ';
       if(AggSum.size()>0){
        TabStr = '<table border ="1"><tr><td><b>Product Group Name</b></td><td><b>Charge Type</b></td><td><b>Net Price</b></td></tr>';
        for(Integer i = 0; i<AggSum.size();i++)
        {
        Temp = Temp+'<td>'+AggSum[i].Name+'</td>';
        Temp = Temp+'<td>'+AggSum[i].Apttus_CMConfig__ChargeType__c+'</td>';
        Temp = Temp+'<td>'+AggSum[i].Apttus_CMConfig__NetPrice__c.setscale(2)+'</td></tr>';
        }
    }
      String AggLineItem = TabStr+Temp+'</table>';
      
  
      mail.setSubject('Credit Approval Requested for Quote#'+Prop.get(0).Name+' - '+BillToAcc.get(0).Name+', '+country);
      String body = 'Dear Credit & Collection Team,<Br/><BR />';
      body += 'The following quote has been identified as requiring a Credit Team approval. Please review and if you decide to approve the transaction, reply to this email with “Approved” in the <B><u>first line</u></b> of the email body. <BR /><BR />';
      body += '<u>Quote No:</u> '+Prop.get(0).Name+'<BR />';
      body += '<u>Agreement No:</u> '+Aggree.get(0).Apttus__FF_Agreement_Number__c+'<BR />';
      body += '<u>Salesperson Name:</u> '+SalesrepName+'<BR/><BR/>';
      
      body += '<u>Enterprise Account Number:</u> '+(BillToAcc.get(0).Enterprise_Party_Number__c!=Null ? BillToAcc.get(0).Enterprise_Party_Number__c :' ')+'<BR />';
      body += '<u>Oracle Account Number:</u> '+BillToAcc.get(0).EBS_Account_Number__c+'<BR />';
      body += '<u>Customer Name:</u> '+BillToAcc.get(0).Name+'<BR />';
      body += '<u>Customer Address:</u> '+street+', '+city+', '+state+', '+zipcode+', '+country+'<BR />';
     // body += 'Agreement Start Date: '+(Aggree.get(0).Apttus__Contract_Start_Date__c).format()+'<BR />';
      body += '<u>Agreement Start Date:</u> '+DateTime.newInstance(Aggree.get(0).Apttus__Contract_Start_Date__c.Year(),Aggree.get(0).Apttus__Contract_Start_Date__c.month(),Aggree.get(0).Apttus__Contract_Start_Date__c.day()).format('d-MMM-YYYY')+'<BR />';
     // body += 'Agreement End Date: '+(Aggree.get(0).Apttus__Contract_End_Date__c).format()+'<BR />';
      body += '<u>Agreement End Date:</u> '+DateTime.newInstance(Aggree.get(0).Apttus__Contract_End_Date__c.Year(),Aggree.get(0).Apttus__Contract_End_Date__c.month(),Aggree.get(0).Apttus__Contract_End_Date__c.day()).format('d-MMM-YYYY')+'<BR />';
      body += '<u>Total Agreement Value:</u> '+Aggree.get(0).CurrencyIsoCode+' '+(Aggree.get(0).Total_Agreement_Value_Formula__c.setScale(2))+'<BR /><BR/>';
     
      body += '<b>Agreement Lines Summary</b><br/><br/>';
      body += AggLineItem; 
     // body +='<br/><br/>If you decide to release the credit hold, please reply to this email with “Approved” in the first line of the email body.';
      body += '<BR/><BR/><u>Terms of Payment from Quote:</u> '+Prop.get(0).Payment_Terms_Oppty__c+'<BR />';
      body += '<u>Standard Country Terms of Payment:</u> '+PaymentTermForCountry+'<BR /><BR/>'; 
      
      body += '<U>Existing Exposure:</U> '+Prop.get(0).CurrencyIsoCode+' '+ Prop.get(0).CREDIT_EXISTING_EXPOSURE__c+'<BR />';
      body += '<U>Available Credit:</U> '+Prop.get(0).CurrencyIsoCode+' '+ Prop.get(0).CREDIT_LIMIT_AVAILABLE__c+'<BR />';
      body += '<U>Credit Evaluation Amount for this Quote:</U> '+Prop.get(0).CurrencyIsoCode+' '+ Prop.get(0).CREDIT_CALCULATED_EXPOSURE__c+'<BR /><BR/>';
      
      body += '<BR/><u>Collector Name:</u> '+collectorName+'<BR />';
      body += '<BR/><BR/>Thanks,<BR/><BR/>';
      body += SalesrepName+'<BR/>';
      body += Division+'<BR/>';
      //body += BusinessArea; 
         mail.setHtmlBody(body);
         mails.add(mail);
        // Messaging.sendEmail(mails);
       List<Messaging.SendEmailResult> results =

    Messaging.sendEmail(new Messaging.Email[] { mail });

                CreditHistoryLogs ch = new CreditHistoryLogs();
                String LogStr = 'Email notification sent to Collector: '+collectorname+'; Email : '+toAdd;
                ch.CreateLog(LogStr,Prop.get(0).Id,Aggree.get(0).Id); 
                
if (!results.get(0).isSuccess()) {

    System.StatusCode statusCode = results.get(0).getErrors()[0].getStatusCode();

    String errorMessage = results.get(0).getErrors()[0].getMessage();

}
  else
  {
  system.debug('*************'+results.get(0));
   
  }
    //return  new PageReference('/'+AggID); 
    }
    
    }
       catch(Exception e){
           String errMsg = e.getMessage();
           system.debug('exception ====='+e); 
            system.debug('exception ====='+e.getStackTraceString());
       } 
   
     }
}