Global class BatchSpecialScenarioAutoFill Implements Database.batchable<sobject>{
     global final string query;
     global BatchSpecialScenarioAutoFill(string q){
         
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
Map<String,Customer_Dup_Check__c> DupCheckMap = new Map<String,Customer_Dup_Check__c>();
Map<String,Dedupe_Account__c> DedupeAccountMap = new Map<String,Dedupe_Account__c>();
Map<String,Dedupe_Address__c> DedupeAddressMap = new Map<String,Dedupe_Address__c>();
Set<String>RecID = new Set<String>();
Set<String>RecID1 = new Set<String>();
Set<String>AddRecID = new Set<String>();
Set<String>TempAccID = new Set<String>();
List<Customer_Dup_Check__c>UpdateDupCheckList = new List<Customer_Dup_Check__c>();
List<String>CustID = new List<String>();
Set<String>ProcessID = new Set<String>();

DupCheckList = Scope;

system.debug('>>>>>Scope>>>>>>>'+DupCheckList.size());
/*[select id,Cust_Account_ID__c,Oracle_Site_Reference__C,Process_Flag__c,Cust_Acct_Site_ID__c,Record_ID__c,New_Oracle_Address_1__c,New_Oracle_Address_2__c,New_Oracle_City__c,New_Oracle_Country__c,New_Oracle_County__c,New_Oracle_Customer_Name__c,New_Oracle_Postal_Code__c,New_Oracle_State__c,New_Oracle_Account_Number__c
                    from Customer_Dup_Check__c where Dedupe_Master__c =:query and Process_Flag__c ='X'];*/
                    
    for(Customer_Dup_Check__c Dup : DupCheckList)
    {
      ProcessID.add(Dup.Record_ID__c);
    }
    
    String DedupeMasterID = DupCheckList.get(0).Dedupe_Master__c;
                   
    DedupeAccountList = [select id,Record_ID__c,Cust_Account_ID__c,Customer_Name_Match_Percentage__c,Oracle_Customer_Name__c,Oracle_Account_Number__c
                         from Dedupe_Account__c where Dedupe_Master__c =:DedupeMasterID and Record_ID__c in: ProcessID and Customer_Name_Match_Percentage__c  > 70
                         order by Record_ID__c,Customer_Name_Match_Percentage__c DESC];
    DedupeAddressList = [select id,Cust_Acct_Site_ID__c,Oracle_Site_Reference__c,Cust_Account_ID__c,Record_ID__c,Oracle_address1__c,Oracle_address2__c,Oracle_City__c,Oracle_Country__c,Oracle_County__c,Oracle_Postal_Code__c,Oracle_State__c
                         from Dedupe_Address__c where Dedupe_Master__c =:DedupeMasterID and Record_ID__c in: ProcessID and Customer_Addr_Match_Percentage__c > 75
                         order by Record_ID__c,Customer_Addr_Match_Percentage__c DESC];
   
system.debug('>>>>>Scope>>>>>>>'+DedupeAccountList.size());
system.debug('>>>>>Scope>>>>>>>'+DedupeAddressList.size());

for(Customer_Dup_Check__c Dup : DupCheckList)
{
  DupCheckMap.put(Dup.Record_ID__c,Dup);
}

for(Dedupe_Account__c Acc : DedupeAccountList)
{
 DedupeAccountMap.put(Acc.Record_ID__c,Acc);
}

for(Dedupe_Address__c Add : DedupeAddressList)
{
 DedupeAddressMap.put(Add.Record_ID__c,Add);
}


Map<String,List<Dedupe_Account__c>>DupAccountListMap = new Map<String,List<Dedupe_Account__c>>();
Map<String,List<Dedupe_Address__c>>DupAddressListMap = new Map<String,List<Dedupe_Address__c>>();


for(Customer_Dup_Check__c Dup : DupCheckList)
 {
 List<Dedupe_Account__c> TempAcclist = new List<Dedupe_Account__c>();
   for(Dedupe_Account__c Acc : DedupeAccountList)
   {
    if(Dup.Record_Id__c == Acc.Record_Id__c)
    {
     Dedupe_Account__c tempAc = new Dedupe_Account__c();
     TempAcclist.add(Acc);
    }
    DupAccountListMap.put(Dup.Record_Id__c,TempAcclist);
   }
  }

system.debug('>>>>>>>DupAccountListMap>>>>>>>>>>>'+DupAccountListMap);
 for(Customer_Dup_Check__c Dup : DupCheckList)
 {
 List<Dedupe_Address__c> TempAdrlist = new List<Dedupe_Address__c>();
   for(Dedupe_Address__c Adr : DedupeAddressList)
   {
    if(Dup.Record_Id__c == Adr.Record_Id__c)
    {
     Dedupe_Address__c tempAdr = new Dedupe_Address__c();
     TempAdrlist.add(Adr);
    }
    DupAddressListMap.put(Dup.Record_Id__c,TempAdrlist);
   }
  }
system.debug('>>>>>>>DupAddressListMap>>>>>>>>>>>'+DupAddressListMap);
Map<String,Dedupe_Account__c>BestMatchAccount = new Map<String,Dedupe_Account__c>();
Map<String,Dedupe_Address__c>BestMatchAddress = new Map<String,Dedupe_Address__c>();

for(Customer_Dup_Check__c Dup : DupCheckList)
{
//system.debug('>>>>>>DupAccountListMap.get(Dup.Record_ID__c)>>>>>>>'+DupAccountListMap.get(Dup.Record_ID__c));
  if(DupAccountListMap.get(Dup.Record_ID__c) != Null){
  for(Dedupe_Account__c Acct : DupAccountListMap.get(Dup.Record_ID__c))
  {
  //system.debug('>>>>>>DupAddressListMap.get(Dup.Record_ID__c)>>>>>>>'+DupAddressListMap.get(Dup.Record_ID__c));
  if(DupAddressListMap.get(Dup.Record_ID__c) != Null){
   for(Dedupe_Address__c Adrr : DupAddressListMap.get(Dup.Record_ID__c))
   {
    system.debug('>>>>>Matched>>>>>>>'+Acct.Cust_Account_ID__c);
    system.debug('>>>>>Matched>>>>>>>'+Adrr.Cust_Account_ID__c);
    if(Acct.Cust_Account_ID__c == Adrr.Cust_Account_ID__c)
    {
    system.debug('>>>>>Matched>>>>>>>'+Acct.Cust_Account_ID__c);
    system.debug('>>>>>Matched>>>>>>>'+Adrr.Cust_Account_ID__c);
     BestMatchAccount.put(Dup.Record_ID__c,Acct);
     BestMatchAddress.put(Dup.Record_ID__c,Adrr);
    }
    
   }
  }
  else
    {
     BestMatchAccount.put(Dup.Record_ID__c,Acct);
    }
  }
  }
}

system.debug('>>>>>>>>BestMatchAccount>>>>>>>>>>'+BestMatchAccount);
system.debug('>>>>>>>>BestMatchAddress>>>>>>>>>>'+BestMatchAddress);

 for(Customer_Dup_Check__c Dup : DupCheckList)
            {
            
                  if(BestMatchAccount.get(Dup.Record_Id__c)!= Null) 
                  {
                  Dup.Cust_Account_ID__c = BestMatchAccount.get(Dup.Record_Id__c).Cust_Account_ID__c;
                  Dup.New_Oracle_Account_Number__c = BestMatchAccount.get(Dup.Record_Id__c).Oracle_Account_Number__c;
                  Dup.New_Oracle_Customer_Name__c =  BestMatchAccount.get(Dup.Record_Id__c).Oracle_Customer_Name__c;
                  Dup.Process_Flag__c = 'Y';
                  }
                  
                 
                  if(BestMatchAddress.get(Dup.Record_Id__c)!= Null) 
                  {
                 
                  Dup.Cust_Acct_Site_ID__c = BestMatchAddress.get(Dup.Record_Id__c).Cust_Acct_Site_ID__c;
                  Dup.New_Oracle_Address_1__c = BestMatchAddress.get(Dup.Record_Id__c).Oracle_Address1__c;
                  Dup.New_Oracle_Address_2__c = BestMatchAddress.get(Dup.Record_Id__c).Oracle_Address2__c;
                  Dup.New_Oracle_City__c = BestMatchAddress.get(Dup.Record_Id__c).Oracle_City__c;
                  Dup.New_Oracle_Country__c = BestMatchAddress.get(Dup.Record_Id__c).Oracle_Country__c;
                  Dup.New_Oracle_County__c  = BestMatchAddress.get(Dup.Record_Id__c).Oracle_County__c;
                  Dup.New_Oracle_Postal_Code__c = BestMatchAddress.get(Dup.Record_Id__c).Oracle_Postal_Code__c;
                  Dup.New_Oracle_State__c = BestMatchAddress.get(Dup.Record_Id__c).Oracle_State__c;
                  Dup.Oracle_Site_Reference__c = BestMatchAddress.get(Dup.Record_Id__c).Oracle_Site_Reference__c;
                  Dup.Process_Flag__c = 'Y';  
                    
                                           
                  }
                  Dup.Process_Flag__c = 'Y';
                 
                  
                  UpdateDupCheckList.add(Dup);
                
            }
         system.debug('>>>>>>UpdateDupCheckList>>>>>>>>>>>'+ UpdateDupCheckList);  
            
       if(UpdateDupCheckList.size()>0) Update UpdateDupCheckList;    
          
    
    
    }
    global void finish(Database.BatchableContext BC){
    }

 }