/*****************************************************************************************
    Name        : InvokeOraccle
    Desc        : Used to Invoke the Webservie to call Oracle with Enterprise Oracle Number as input
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Prince Leo            25/05/2016          Created
******************************************************************************************/
global class InvokeOraccle{
public string AccountID{get;set;}
Public boolean ErrorPopup{get;set;}
Public boolean Runtimeerror{get;set;}
Public String ErrorMsg{get;set;}
Public String profileName{get;set;}
Public String retURL{get;set;}
Public String ObjectName{get;set;}
Account Acc;
Address__c Add;
Public InvokeOraccle(){
system.debug('********AccountID*******'+AccountID);
AccountID = System.currentPageReference().getParameters().get('id'); 

    if(AccountID.startswith('001'))
    ObjectName ='Account';
    else if(AccountID.startswith('a5O'))
    ObjectName ='Address';

profileName = [select Id,Name from Profile where Id =: userinfo.getProfileId()].Name;
     if(ObjectName =='Account')
     Acc =[select id,Enterprise_Party_Number__c from Account where id=:AccountID];  
     else if(ObjectName =='Address')
     Add = [Select id,Enterprise_Address_Number__c,Account__r.Enterprise_Party_Number__c from Address__c where id=:AccountID];
     
     retURL = '/'+ AccountID;
}
Public Void ValidateAccount(){
    try{
      if(ObjectName =='Account'){
        /*if(profileName!='Data Administrator' && profileName !='System Administrator' && !profileName.containsIgnoreCase('sales'))
        {
         ErrorPopup = True;
         ErrorMsg = 'You are Not Authorized to Perform this Process';
        }
         else */if(Acc.Enterprise_Party_Number__c == Null || Acc.Enterprise_Party_Number__c == '')
         {
         ErrorPopup = True;
         ErrorMsg = 'Enterprise Account Number cannot be Blank / Null';
         }
         else
         
         {
          ErrorPopup = False;
         processDetails(Acc.Enterprise_Party_Number__c);
         }
        }
        
        else if(ObjectName =='Address')
        {
         /* if(profileName!='Data Administrator' && profileName !='System Administrator' && !profileName.containsIgnoreCase('sales'))
        {
         ErrorPopup = True;
         ErrorMsg = 'You are Not Authorized to Perform this Process';
        }
         else */if(Add.Account__r.Enterprise_Party_Number__c == Null || Add.Account__r.Enterprise_Party_Number__c == '' || Add.Enterprise_Address_Number__c == Null || Add.Enterprise_Address_Number__c=='')
         {
         ErrorPopup = True;
         ErrorMsg = 'Enterprise Account Number or Enterprise Address Number cannot be Blank / Null';
         }
         else
         
         {
          ErrorPopup = False;
         String TempVal = Add.Account__r.Enterprise_Party_Number__c + ':'+Add.Enterprise_Address_Number__c;
         processDetails(TempVal);
         }
        }
         system.debug('******ErrorMsg******'+ErrorPopup);
         system.debug('******ErrorMsg******'+ErrorMsg);
         system.debug('******ErrorMsg******'+profileName);
     }
     catch (Exception e)
     {
     ErrorPopup = True;
     ErrorMsg = e.getmessage();
     
     }
    }
    
Public void processDetails(String EntpriseNum){
     system.debug('******ErrorMsg******'+ErrorPopup);
     system.debug('******ErrorMsg******'+ErrorMsg);
    xmlnsOracleComAppsHzSoaproviderPls.OutputParameters_element OutVal = new xmlnsOracleComAppsHzSoaproviderPls.OutputParameters_element();
    xmlnsTrimbleComCusthubTnvcustebsacco sd = new xmlnsTrimbleComCusthubTnvcustebsacco();
    xmlnsTrimbleComCusthubTnvcustebsacco.tnvCustEBSAccountTrigger_pt sw = new xmlnsTrimbleComCusthubTnvcustebsacco.tnvCustEBSAccountTrigger_pt();
    OutVal = sw.process(EntpriseNum);
    if(OutVal.X_STATUS_CODE=='S'){
    ErrorPopup = True;
    ErrorMsg = 'Your request to get latest data from Oracle is submitted. Please check back in 5 minutes.';
    }
    else if(OutVal.X_STATUS_CODE=='E'){
    ErrorPopup = True;
    ErrorMsg = OutVal.X_STATUS_DESC;
    }
    system.debug('******OutVal ******'+OutVal );
    system.debug('******OutVal ******'+OutVal );
  }
  
 
  
   public Pagereference cancelPage()
    {
       
            return new Pagereference('/'+AccountID);
    }
}