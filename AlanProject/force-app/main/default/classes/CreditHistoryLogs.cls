/*****************************************************************************************
Name    : CreditHistoryLogs
Desc    : Creates Log Records on the Custob Object Credit History Tracking when a Order is Submited and Response is Obtained from EBS.


Modification Log : 
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
Prince Leo          30/06/2015          Created
******************************************************************************************/
Public class CreditHistoryLogs{
     Public Void CreateLog(String LogText,String QtID, String AggId)
     {
     User u = [select Id, username from User where Id = :UserInfo.getUserId()];
     Credit_History_Tracking__c cht = new Credit_History_Tracking__c();
     cht.User__c = u.UserName;
     cht.Date_Time__c = system.Now();
     cht.Logs__c = LogText;
     cht.Quote_Proposal__c = QtId;
     cht.Agreement__c = AggId;
     insert cht;
     }
    
}