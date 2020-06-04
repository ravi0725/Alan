/*****************************************************************************************
  Name    : AutofillValues
  Desc    : Used to Autofill values on customer dedupe with higher number of Dedupe Account and Dedupe Address (More than 50000 records) 
            Invokes BatchAutoFill class internally. 
 
  Modification Log :
  ---------------------------------------------------------------------------
  Developer              Date            Description
  ---------------------------------------------------------------------------
  Prince Leo           03/04/2018          Created
 ******************************************************************************************/
Public class AutofillValues{

    public AutofillValues(ApexPages.StandardController controller) {
    DedupeMasterID = apexpages.currentpage().getparameters().get('id');

    DupCheckList = [select id,Cust_Account_ID__c,Oracle_Site_Reference__C,Process_Flag__c,Cust_Acct_Site_ID__c,Record_ID__c,New_Oracle_Address_1__c,New_Oracle_Address_2__c,New_Oracle_City__c,New_Oracle_Country__c,New_Oracle_County__c,New_Oracle_Customer_Name__c,New_Oracle_Postal_Code__c,New_Oracle_State__c,New_Oracle_Account_Number__c
                    from Customer_Dup_Check__c where Dedupe_Master__c =:DedupeMasterID /*and Process_Flag__c<>'Y'*/];
                    
   /* DedupeAccountList = [select id,Record_ID__c,Bill_To_Cust_Invoice_Count__c,Cust_Account_ID__c,Customer_Name_Match_Percentage__c,Oracle_Customer_Name__c,Oracle_Account_Number__c
                         from Dedupe_Account__c where Dedupe_Master__c =:DedupeMasterID and Customer_Name_Match_Percentage__c  > 70
                         order by Record_ID__c,Bill_To_Cust_Invoice_Count__c DESC, Customer_Name_Match_Percentage__c DESC];
    DedupeAddressList = [select id,Cust_Acct_Site_ID__c,Oracle_Site_Reference__c,Cust_Account_ID__c,Record_ID__c,Oracle_address1__c,Oracle_address2__c,Oracle_City__c,Oracle_Country__c,Oracle_County__c,Oracle_Postal_Code__c,Oracle_State__c
                         from Dedupe_Address__c where Dedupe_Master__c =:DedupeMasterID and Customer_Addr_Match_Percentage__c > 75
                         order by Record_ID__c,Bill_To_Addr_Invoice_Count__c DESC,Customer_Addr_Match_Percentage__c DESC];*/
    }
    
    
List<Dedupe_Address__c> DedupeAddressList = new List<Dedupe_Address__c>();
List<Dedupe_Account__c> DedupeAccountList = new List<Dedupe_Account__c>();
List<Customer_Dup_Check__c> DupCheckList = new List<Customer_Dup_Check__c>();
Public ID DedupeMasterID {get;set;}
Public Map<String,String> DupCheckMap = new Map<String,String>();
Public Map<String,Dedupe_Account__c> DedupeAccountMap = new Map<String,Dedupe_Account__c>();
Public Map<String,Dedupe_Address__c> DedupeAddressMap = new Map<String,Dedupe_Address__c>();
Public Set<String>RecID = new Set<String>();
Public Set<String>AddRecID = new Set<String>();
Public Set<String>TempAccID = new Set<String>();
List<Customer_Dup_Check__c>UpdateDupCheckList = new List<Customer_Dup_Check__c>();
List<String>CustID = new List<String>();

Public PageReference UpdateDedupemaster()
{

string str2='select id,Cust_Account_ID__c,Oracle_Site_Reference__C,Process_Flag__c,Dedupe_Master__c,Cust_Acct_Site_ID__c,Record_ID__c,New_Oracle_Address_1__c,New_Oracle_Address_2__c,New_Oracle_City__c,New_Oracle_Country__c,New_Oracle_County__c,New_Oracle_Customer_Name__c,New_Oracle_Postal_Code__c,New_Oracle_State__c,New_Oracle_Account_Number__c from Customer_Dup_Check__c where Dedupe_Master__c = \'' +  DedupeMasterID  + '\'';
        BatchAutoFill bdt2=new BatchAutoFill(str2);
        Database.executeBatch(bdt2);     
       
       PageReference Pg = new PageReference('/'+DedupeMasterID);
       return Pg;
}
}