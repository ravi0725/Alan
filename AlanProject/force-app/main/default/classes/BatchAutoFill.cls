/*****************************************************************************************
  Name    : BatchAutoFill 
  Desc    : Used to Autofill values on customer dedupe with higher number of Dedupe Account and Dedupe Address (More than 50000 records) 
 
  Modification Log :
  ---------------------------------------------------------------------------
  Developer              Date            Description
  ---------------------------------------------------------------------------
  Prince Leo           03/04/2018          Created
 ******************************************************************************************/
Global class BatchAutoFill Implements Database.batchable<sobject>{
     global final string query;
     global BatchAutoFill(string q){
         
          query=q;
     }
   
      global Database.QueryLocator start(Database.BatchableContext BC){
      system.debug('********'+Database.getQueryLocator(query));
      return Database.getQueryLocator(query);
      
     }
     global  void execute(Database.BatchableContext BC,List<SObject> scope){
     
     List<Dedupe_Address__c> DedupeAddressList = new List<Dedupe_Address__c>();
    List<Dedupe_Account__c> DedupeAccountList = new List<Dedupe_Account__c>();
    List<Customer_Dup_Check__c> DupCheckList = new List<Customer_Dup_Check__c>();
    Map<String,String> DupCheckMap = new Map<String,String>();
    Map<String,Dedupe_Account__c> DedupeAccountMap = new Map<String,Dedupe_Account__c>();
    Map<String,Dedupe_Address__c> DedupeAddressMap = new Map<String,Dedupe_Address__c>();
    Set<String>RecID = new Set<String>();
    Set<String>AddRecID = new Set<String>();
    Set<String>TempAccID = new Set<String>();
    List<Customer_Dup_Check__c>UpdateDupCheckList = new List<Customer_Dup_Check__c>();
    List<String>CustID = new List<String>();
    
    DupCheckList = Scope;
    String DedupeMasterID = DupCheckList.get(0).Dedupe_Master__c;

   for(Customer_Dup_Check__c Dup : DupCheckList)
{
  DupCheckMap.put(Dup.Record_ID__c,Dup.id);
}
   
   DedupeAccountList = [select id,Record_ID__c,Bill_To_Cust_Invoice_Count__c,Cust_Account_ID__c,Customer_Name_Match_Percentage__c,Oracle_Customer_Name__c,Oracle_Account_Number__c
                         from Dedupe_Account__c where Dedupe_Master__c =:DedupeMasterID and Record_Id__c=:DupCheckMap.keyset() and Customer_Name_Match_Percentage__c  > 70
                         order by Record_ID__c,Bill_To_Cust_Invoice_Count__c DESC, Customer_Name_Match_Percentage__c DESC];
                         
     
  for(Dedupe_Account__c DupAc :DedupeAccountList)
  {
    if(!RecID.contains(DupAc.Record_ID__c)){
    DedupeAccountMap.put(DupAc.Record_ID__c,DupAc);
    RecID.add(DupAc.Record_ID__c);
    CustID.add(DupAc.Cust_Account_ID__c);
    }
    
  }
  
    System.debug('>>>>>>>RecID>>>>>>>>>>'+RecID.size());
   System.debug('>>>>>>>Dedupe Account Map>>>>>>>>>>'+DedupeAccountMap);
 /* for(Customer_Dup_Check__c Dup : DupCheckList)
            {
             if(Dup.Cust_Account_ID__c == Null && DedupeAccountMap.get(Dup.Record_ID__c)!= Null){
            // Dup.Cust_Account_ID__c = DedupeAccountMap.get(Dup.Record_ID__c).Cust_Account_ID__c;
            // Dup.Process_Flag__c = 'Y';
             AccID.add(Dup.Cust_Account_ID__c);
            // UpdateDupCheckList.add(Dup);
             }
            }*/
     
  DedupeAddressList = [select id,Cust_Acct_Site_ID__c,Oracle_Site_Reference__c,Cust_Account_ID__c,Record_ID__c,Oracle_address1__c,Oracle_address2__c,Oracle_City__c,Oracle_Country__c,Oracle_County__c,Oracle_Postal_Code__c,Oracle_State__c
                         from Dedupe_Address__c where Dedupe_Master__c =:DedupeMasterID and Record_Id__c=:DupCheckMap.keyset() and Customer_Addr_Match_Percentage__c > 75 and Cust_Account_ID__c in: CustID 
                         order by Record_ID__c,Bill_To_Addr_Invoice_Count__c DESC,Customer_Addr_Match_Percentage__c DESC];
                                   
        for(Dedupe_Address__c DupAdd :DedupeAddressList)
  {
 
      if(!AddRecID.contains(DupAdd.Record_ID__c+'-'+DupAdd.Cust_Account_ID__c))
     {
      DedupeAddressMap.put(DupAdd.Record_ID__c+DupAdd.Cust_Account_ID__c,DupAdd);
      AddRecID.add(DupAdd.Record_ID__c+'-'+DupAdd.Cust_Account_ID__c);
     }
  }
     System.debug('>>>>>>>Dedupe Address Map>>>>>>>>>>'+DedupeAddressMap);
   
       
        for(Customer_Dup_Check__c Dup : DupCheckList)
            {
            if((Dup.Cust_Account_ID__c == Null || Dup.Cust_Acct_Site_ID__c == Null ))
                {
                  if(DedupeAccountMap.get(Dup.Record_ID__c)!= Null) 
                  {
                  Dup.Cust_Account_ID__c = DedupeAccountMap.get(Dup.Record_ID__c).Cust_Account_ID__c;
                  Dup.New_Oracle_Account_Number__c = DedupeAccountMap.get(Dup.Record_ID__c).Oracle_Account_Number__c;
                  Dup.New_Oracle_Customer_Name__c =  DedupeAccountMap.get(Dup.Record_ID__c).Oracle_Customer_Name__c;
                  Dup.Process_Flag__c = 'Y';
                  }
                  
                  system.debug('>>>>>>CheckPoint>>>>>>'+Dup.Record_ID__c);
                  if(DedupeAccountMap.get(Dup.Record_ID__c)!= Null && DedupeAddressMap.get(Dup.Record_ID__c+DedupeAccountMap.get(Dup.Record_ID__c).Cust_Account_ID__c)!=Null)
                  { system.debug('>>>>>>CheckPoint1>>>>>>'+DedupeAddressMap.get(Dup.Record_ID__c+DedupeAccountMap.get(Dup.Record_ID__c).Cust_Account_ID__c).Cust_Account_ID__c);}
                  if(DedupeAccountMap.get(Dup.Record_ID__c)!=Null)
                  { system.debug('>>>>>>CheckPoint2>>>>>>'+DedupeAccountMap.get(Dup.Record_ID__c).Cust_Account_ID__c);}
                   
                  if(DedupeAccountMap.get(Dup.Record_ID__c)!= Null && DedupeAddressMap.get(Dup.Record_ID__c+DedupeAccountMap.get(Dup.Record_ID__c).Cust_Account_ID__c)!= Null) 
                  {
                  if(DedupeAddressMap.get(Dup.Record_ID__c+DedupeAccountMap.get(Dup.Record_ID__c).Cust_Account_ID__c).Cust_Account_ID__c == DedupeAccountMap.get(Dup.Record_ID__c).Cust_Account_ID__c){
                  Dup.Cust_Acct_Site_ID__c = DedupeAddressMap.get(Dup.Record_ID__c+DedupeAccountMap.get(Dup.Record_ID__c).Cust_Account_ID__c).Cust_Acct_Site_ID__c;
                  Dup.New_Oracle_Address_1__c = DedupeAddressMap.get(Dup.Record_ID__c+DedupeAccountMap.get(Dup.Record_ID__c).Cust_Account_ID__c).Oracle_Address1__c;
                  Dup.New_Oracle_Address_2__c = DedupeAddressMap.get(Dup.Record_ID__c+DedupeAccountMap.get(Dup.Record_ID__c).Cust_Account_ID__c).Oracle_Address2__c;
                  Dup.New_Oracle_City__c = DedupeAddressMap.get(Dup.Record_ID__c+DedupeAccountMap.get(Dup.Record_ID__c).Cust_Account_ID__c).Oracle_City__c;
                  Dup.New_Oracle_Country__c = DedupeAddressMap.get(Dup.Record_ID__c+DedupeAccountMap.get(Dup.Record_ID__c).Cust_Account_ID__c).Oracle_Country__c;
                  Dup.New_Oracle_County__c  = DedupeAddressMap.get(Dup.Record_ID__c+DedupeAccountMap.get(Dup.Record_ID__c).Cust_Account_ID__c).Oracle_County__c;
                  Dup.New_Oracle_Postal_Code__c = DedupeAddressMap.get(Dup.Record_ID__c+DedupeAccountMap.get(Dup.Record_ID__c).Cust_Account_ID__c).Oracle_Postal_Code__c;
                  Dup.New_Oracle_State__c = DedupeAddressMap.get(Dup.Record_ID__c+DedupeAccountMap.get(Dup.Record_ID__c).Cust_Account_ID__c).Oracle_State__c;
                  Dup.New_Oracle_Account_Number__c = DedupeAccountMap.get(Dup.Record_ID__c).Oracle_Account_Number__c;
                  Dup.New_Oracle_Customer_Name__c = DedupeAccountMap.get(Dup.Record_ID__c).Oracle_Customer_Name__c;
                  Dup.Oracle_Site_Reference__c = DedupeAddressMap.get(Dup.Record_ID__c+DedupeAccountMap.get(Dup.Record_ID__c).Cust_Account_ID__c).Oracle_Site_Reference__c;
                  Dup.Process_Flag__c = 'Y';  
                  }  
                 /* else
                  {
                  Dup.Cust_Acct_Site_ID__c = '';
                  Dup.New_Oracle_Address_1__c = '';
                  Dup.New_Oracle_Address_2__c = '';
                  Dup.New_Oracle_City__c = '';
                  Dup.New_Oracle_Country__c = '';
                  Dup.New_Oracle_County__c  = '';
                  Dup.New_Oracle_Postal_Code__c = '';
                  Dup.New_Oracle_State__c = '';
                  Dup.New_Oracle_Account_Number__c = '';
                  Dup.New_Oracle_Customer_Name__c = '';
                  Dup.Process_Flag__c = '';  
                  }   */                                   
                  }
                 
                  UpdateDupCheckList.add(Dup);
                }
            }
            
            
       if(UpdateDupCheckList.size()>0) Update UpdateDupCheckList;    
     }
     
   global void finish(Database.BatchableContext BC){
    }

 }