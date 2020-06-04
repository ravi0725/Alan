/*****************************************************************************************
Name        : CreditCheckEmailNotificationController
Desc        :Used to send Email Notification to the credit check team.     
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
Prince Leo           11/06/2015          Created
******************************************************************************************/
public class CreditCheckEmailNotificationController{
    
    public String OppID{get;set;} // change to : sOppId
    Public String AccId{get;set;} // change to : sAccId
    public string ACL{get;set;} // change to : sACL & string -> String
    Public string errorMsg{get;set;} // change to : sErrorMsg
    public boolean errorPopup{get;set;} // change to : blnErrorPopup
    Public string mavenLinkMessage{get;set;} // change to : sMavenLinkMessage
    public boolean mavenLinkMessagePopup{get;set;} // change to : blnMavenLinkMessagePopup
    public boolean displayPopup {get; set;} // change to : blnDisplayPopup
    public boolean displayMavenlinkPopup {get; set;} // change to : blnDisplayMavenLinkPopup
    public Boolean EntpriseID {get;set;} // change to : blnEnterpriseId
    Public String EnterPriseErr {get;set;} // change to : sEnterpriseError
    Public String Comments {get;set;} // change to : sComments
    public String source {get; set; } // change to : sSource
    Opportunity oOpportunity;
    List<Account> BillToAcc = new List<Account>(); // change to : lstBillToAccounts

    /*
    * Please add description
    */
    public CreditCheckEmailNotificationController(){
        OppID = System.currentPageReference().getParameters().get('id');
        AccId = System.currentPageReference().getParameters().get('AcctId');
        ACL = System.currentPageReference().getParameters().get('ACL');
        source = system.currentPageReference().getParameters().get('source');
        
        BillToAcc = [SELECT id,Phone,Region__c,Credit_Manager_Notified__c,collector_Name__c,Credit_Request_Comment__c,EBS_Account_Number__c,Collector_Email__c,Enterprise_Party_Number__c,Name,BillingStreet,Country_Code__c,BillingCity,BillingCountry,BillingPostalCode,BillingState FROM account WHERE id =:AccId];
        oOpportunity = [SELECT Id,Selling_Division__c FROM Opportunity WHERE Id =: OppID];
    }
    
    /*
    * Please add description
    */
    public PageReference closePopup() {    
        Account oAccount = new Account(id=BillToAcc.get(0).id); 
        oAccount.Credit_Request_Comment__c =Comments;
        update oAccount;
        
        displayPopup = false;  
        return new PageReference('/apex/CreateQuoteFromOpptyPage?id='+oppId+'&AcctId='+AccId); 
    }  
    
    /*
    * Update Credit Request Comment on Account and return to Opportunity page
    */
    public PageReference close() {    
        Account oAccount = new Account(id=BillToAcc.get(0).id); 
        oAccount.Credit_Request_Comment__c =Comments;
        update oAccount;
        
        displayPopup = false;  
        return new PageReference('/'+oppId); 
    } 
    
    /*
    * Return to Account page
    */
    public Pagereference backtoAccount(){
        return new Pagereference('/'+BillToAcc.get(0).id);
    }
    
    /*
    * Show error message on page
    */
    public void showPopup() {   
        if((source != null ? source == 'mavenlinkproject' : false) && BillToAcc.get(0).Enterprise_Party_Number__c != Null)
            displayMavenlinkPopup = true;
        else if((source != null ? source == 'mavenlinkproject' : false) && BillToAcc.get(0).Enterprise_Party_Number__c == Null){
            EntpriseID = True;
            displayPopup = False;
            EnterPriseErr ='Credit Check Bypassed as the Customer Do not have Enterprise Master Id.';
        }else if(BillToAcc.get(0).Enterprise_Party_Number__c != Null)     
            displayPopup = true;    
        else{
            EntpriseID = True;
            displayPopup = False;
            EnterPriseErr ='Credit Check Bypassed as the Customer Do not have Enterprise Master Id.';
        }
        
    }
    
    /*
    * Invoke MavenLinkProjectConvention.createMavenLinkProject to create Mavenlink Project
    */
    public void createMavenlinkProject() {  
        displayPopup = false; 
        EntpriseID = false; 
        displayMavenlinkPopup = false;
        string result = MavenLinkProjectConvention.createMavenLinkProject(oOpportunity.Id, oOpportunity.Selling_Division__c); //change to : sResult
        mavenLinkMessagePopup = true;
        if(!result.contains('Error')){ 
            mavenLinkMessage = 'Success : Mavenlink Project# ' + result + ' is created successfully.'; 
        }else{ 
            mavenLinkMessage = result;
        } 
    }
    
    /*
    * If source is Mavenlink project then call createMavenlinkProject else return CreateQuoteFromOpptyPage page url
    */
    Public Pagereference cont(){
        if((source != null ? source == 'mavenlinkproject' : false)){
            createMavenlinkProject();
            return null;
        }
        return new PageReference('/apex/CreateQuoteFromOpptyPage?id='+oppId+'&AcctId='+AccId);  
    }
    
    /*
    * If source is Mavenlink project then invoke createMavenlinkProject and send mail to Credit & Collection Team
    * else only send mail to Credit & Collection Team
    */
    public PageReference SendEmail(){
        try{
            system.debug('---------------------' + source);
            if((source != null ? source == 'mavenlinkproject' : false)){
                createMavenlinkProject();
                system.debug('---------------------' + mavenLinkMessage);
            }
            
            Account oAccount = new Account(id=BillToAcc.get(0).id); 
            oAccount.Credit_Request_Comment__c =Comments;
            oAccount.Credit_Manager_Notified__c ='Email Sent'; 
            update oAccount;
            
            List<String> lstEmailAddresses = new List <String>(); 
            displayPopup = false; 
            if(BillToAcc.size()>0){
                
                if(BillToAcc.get(0).Collector_Email__c!=Null)
                    lstEmailAddresses.add(BillToAcc.get(0).Collector_Email__c);
                else if(BillToAcc.get(0).Region__c=='North America')
                    lstEmailAddresses.add(Label.Collector_Email_ARFC);
                else
                    lstEmailAddresses.add(Label.Collector_Email_ERFC);
                User u = [select Id,FirstName,LastName,Division__c,Business_Area__c, username from User where Id = :UserInfo.getUserId()];
                String sSalesRepName = (u.FirstName !=Null ? u.FirstName : ' ') + ' '+u.LastName; 
                String sDivision = (u.Division__c !=Null ? u.Division__c : ' '); 
                String sStreet = (BillToAcc.get(0).BillingStreet != Null ? BillToAcc.get(0).BillingStreet : ' '); 
                string sCity = (BillToAcc.get(0).Billingcity != Null ? BillToAcc.get(0).Billingcity : ' '); 
                string sState = (BillToAcc.get(0).BillingState != Null ? BillToAcc.get(0).BillingState : ' '); 
                string sCountry = (BillToAcc.get(0).BillingCountry != Null ? BillToAcc.get(0).BillingCountry : ' '); 
                string sZipcode = (BillToAcc.get(0).BillingPostalCode != Null ? BillToAcc.get(0).BillingPostalCode : ' '); 
                string sCollectorName = (BillToAcc.get(0).Collector_Name__c != Null ? BillToAcc.get(0).Collector_Name__c : ' '); 
                List<Messaging.SingleEmailMessage> lstMails = new List<Messaging.SingleEmailMessage>(); 
                Messaging.SingleEmailMessage oMail = new Messaging.SingleEmailMessage(); 
                oMail.setSenderDisplayName('Trimble SFDC');
                oMail.setToAddresses(lstEmailAddresses);
                oMail.setSubject('Credit Evaluation - '+BillToAcc.get(0).Name+', '+sCountry);
                String sEmailBody = 'Hi Credit & Collection Team,<Br/><BR />';
                sEmailBody += 'This customer has been identified as needing a credit evaluation:<BR /><BR />';
                sEmailBody += '<u>Customer Name:</u> '+BillToAcc.get(0).Name+'<BR />';
                sEmailBody += '<u>Customer Address:</u> '+sStreet+', '+sCity+', '+sState+', '+sZipcode+', '+sCountry+'<BR />';
                sEmailBody += '<u>Customer Phone Number:</u> '+BillToAcc.get(0).Phone+'<BR />';
                sEmailBody += '<u>Enterprise Account Number:</u> '+BillToAcc.get(0).Enterprise_Party_Number__c+'<BR />';
                sEmailBody += '<u>Oracle Account Number:</u> '+BillToAcc.get(0).EBS_Account_Number__c+'<BR />';
                sEmailBody += '<u>Credit Request Comment:</u> '+Comments.replaceall('','')+'<BR /><BR/>';
                sEmailBody += '<u>Collector Name:</u> '+sCollectorName+'<BR />';
                sEmailBody += '<BR/><BR/>Thanks,<BR/><BR/>';
                sEmailBody += sSalesRepName+'<BR/>';
                sEmailBody += sDivision+'<BR/>';
                oMail.setHtmlBody(sEmailBody);
                lstMails.add(oMail);
                
                Messaging.sendEmail(lstMails);
                errorPopup= False;
            }
            
            
        }
        catch(Exception e){
            errorPopup = true; 
            errorMsg = e.getMessage();
        }  
        
        
        if(errorPopup == false && source == null)
            return new PageReference('/apex/CreateQuoteFromOpptyPage?id='+oppId+'&AcctId='+AccId); 
        else
            return null;
    }
}