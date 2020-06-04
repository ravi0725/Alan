public class CustomerDuplicateCheckWithSavepointCtrl {
    public transient List<Customer_Dup_Check__c> customerDupeCheckList{get;set;}
    public transient List<DedupeAccountWrapper> dedupeAccountWrapList{get;set;}
    public transient List<DedupeAddressWrapper> dedupeAddressWrapList{get;set;}
    public Map<Id,string> customerDupeCheckAccountMap;
    public Map<Id,string> customerDupeCheckAddressMap;
    public Id currentCustomerDupeCheckId{get;set;}
    Public Set<String> RecID;
    public String dedupeAccountId{get;set;}
    public String dedupeAddressId{get;set;}
    public string dedupeMasterId{get;set;}
    //Pagination
    public Integer currentPage{get;set;}
    public Integer totalPage{get;set;}
    public Integer pageSize{get;set;}
    public boolean nextPageFlag{get;set;}
    public boolean previousFlag{get;set;}
    public Integer totalRecords{get;set;}
    public String RecordID {get;set;}
    public Customer_Dup_Check__c customerDupeCheck{get;set;}
    
    public CustomerDuplicateCheckWithSavepointCtrl(){
        
        totalPage = 0;
        totalRecords = 0;
        nextPageFlag = false;
        previousFlag = false;
        pageSize = 1;
        currentPage = 0;
        
        
        currentCustomerDupeCheckId = null;
        dedupeAccountId = '';
        dedupeAddressId = '';
        customerDupeCheckList = new List<Customer_Dup_Check__c>();
        dedupeAccountWrapList = new List<DedupeAccountWrapper>();
        dedupeAddressWrapList = new List<DedupeAddressWrapper>();
        customerDupeCheckAccountMap = new Map<Id,string>();
        customerDupeCheckAddressMap = new Map<Id,string>();
        dedupeMasterId = ApexPages.currentPage().getParameters().get('masterRecordId');
        system.debug('------------------' + dedupeMasterId);
        if(dedupeMasterId != null && dedupeMasterId != ''){
            getCustomerdupCheck(true);
            currentPage = Integer.valueof(ApexPages.currentPage().getParameters().get('SavePoint'));
            totalPage = customerDupeCheckList.size();
            totalRecords = customerDupeCheckList.size();
            nextPageFlag = (currentPage > (totalPage - 1));
            previousFlag = true;
            if(customerDupeCheckList.size() > 0){
                currentCustomerDupeCheckId = customerDupeCheckList.get(currentPage).Id;
                customerDupeCheck = customerDupeCheckList.get(currentPage);
                
                if(dedupeAccountWrapList.size() > 0)dedupeAccountId = dedupeAccountWrapList.get(0).dedupeAccount.Id;
                if(dedupeAddressWrapList.size() > 0)dedupeAddressId = dedupeAddressWrapList.get(0).dedupeAddress.Id;
                
                getDedupeAccounts();
                showaddress();
                getDedupeAddresses();
            }
            
            system.debug('--------customerDupeCheckList.size()----------' + customerDupeCheckList);
        }
    }
    
    public Pagereference SetSavePoint(){
        Dedupe_Master__c DeMasRec = new Dedupe_Master__c(id=dedupeMasterId);
        DeMasRec.Save_Point__c = currentPage;
        
        update DeMasRec;
        Pagereference Pg = new Pagereference('/'+dedupeMasterId);
        return Pg;
    }
    public void getCustomerdupCheck(boolean flag){
        
        RecID = new Set<String>();
        
         customerDupeCheckList = new List<Customer_Dup_Check__c>();
        for(Customer_Dup_Check__c customerCheck : [select Id,Name,Project_Name__c,Derived_Org_ID__c,Address_1__c,Address_2__c,Address_3__c,Address_4__c,City__c,Country__c,County__c,Customer_Name__c,Dedupe_Master__c,Dedup_Program_Request_ID__c,File_Name__c,Gen_Cust_Address_ID__c,Gen_Cust_Customer_ID__c,Legacy_Address_ID__c,Legacy_Customer_ID__c,Load_Request_ID__c,Postal_Code__c,Record_ID__c,State__c,Cust_Account_ID__c,Cust_Acct_Site_ID__c,Process_Flag__c from Customer_Dup_Check__c where Dedupe_Master__c =: dedupeMasterId]){ /*in:RecId and Process_Flag__c != 'Y' order by Record_ID__c]){*/
            customerDupeCheckList.add(customerCheck);
            if(flag){
                customerDupeCheckAccountMap.put(customerCheck.Id, customerCheck.Cust_Account_ID__c);
                customerDupeCheckAddressMap.put(customerCheck.Id, customerCheck.Cust_Acct_Site_ID__c);
            }
        }
        
        for(Dedupe_Account__c dedupeAccount : [select Id,Name,Bill_To_Cust_Invoice_Count__c,Payment_Term__c,Cust_Account_ID__c ,Customer_Name__c,Customer_Name_Match_Percentage__c,Dedupe_Master__c,Gen_Cust_Customer_ID__c,Legacy_Customer_ID__c,Oracle_Account_Number__c,Oracle_Customer_Name__c,Party_ID__c,Process_Flag__c,Profile_Amount__c,Record_ID__c,Request_ID__c,
                                               Addl_Column_1__c,Addl_Column_2__c,Addl_Column_3__c,Addl_Column_4__c,Addl_Column_5__c,Addl_Column_6__c,Addl_Column_7__c,Addl_Column_8__c,Addl_Column_9__c,Addl_Column_10__c,Addl_Column_11__c,Addl_Column_12__c,
                                               Addl_Column_13__c,Addl_Column_14__c,Addl_Column_15__c,Addl_Column_16__c,Addl_Column_17__c,Addl_Column_18__c,Addl_Column_19__c,Addl_Column_20__c from Dedupe_Account__c where Dedupe_Master__c =: dedupeMasterId]){
                                                   RecID.add(dedupeAccount.Record_ID__c);
                                               }
        
       
        
    }
    
    public void getDedupeAccounts(){
        dedupeAccountWrapList = new List<DedupeAccountWrapper>();
        system.debug('---------dedupeMasterId-------' + dedupeMasterId);
        system.debug('---------customerDupeCheckList.get(currentPage).Record_ID__c-------' + customerDupeCheckList.get(currentPage).Record_ID__c);
        for(Dedupe_Account__c dedupeAccount : [select Id,Name,Bill_To_Cust_Invoice_Count__c,Payment_Term__c,Cust_Account_ID__c ,Customer_Name__c,Customer_Name_Match_Percentage__c,Dedupe_Master__c,Gen_Cust_Customer_ID__c,Legacy_Customer_ID__c,Oracle_Account_Number__c,Oracle_Customer_Name__c,Party_ID__c,Process_Flag__c,Profile_Amount__c,Record_ID__c,Request_ID__c,
                                               Addl_Column_1__c,Addl_Column_2__c,Addl_Column_3__c,Addl_Column_4__c,Addl_Column_5__c,Addl_Column_6__c,Addl_Column_7__c,Addl_Column_8__c,Addl_Column_9__c,Addl_Column_10__c,Addl_Column_11__c,Addl_Column_12__c,
                                               Addl_Column_13__c,Addl_Column_14__c,Addl_Column_15__c,Addl_Column_16__c,Addl_Column_17__c,Addl_Column_18__c,Addl_Column_19__c,Addl_Column_20__c from Dedupe_Account__c where Dedupe_Master__c =: dedupeMasterId and Record_ID__c =: customerDupeCheckList.get(currentPage).Record_ID__c Order by Customer_Name_Match_Percentage__c DESC limit 250]){
            system.debug(customerDupeCheckAccountMap.get(currentCustomerDupeCheckId) + '-------check------' + dedupeAccount.Cust_Account_ID__c);
            dedupeAccountWrapList.add(new DedupeAccountWrapper(dedupeAccount,customerDupeCheckAccountMap.get(currentCustomerDupeCheckId) == dedupeAccount.Cust_Account_ID__c));
            if(customerDupeCheckAccountMap.get(currentCustomerDupeCheckId) == dedupeAccount.Cust_Account_ID__c) dedupeAccountId = dedupeAccount.Cust_Account_ID__c;
        }
    }
    
    public void getDedupeAddresses(){
        dedupeAddressWrapList = new List<DedupeAddressWrapper>();
        for(Dedupe_Address__c dedupeAddress : [select Id,Name,Org_Id__c,Bill_To_Addr_Invoice_Count__c,Cust_Account_ID__c,Cust_Acct_Site_ID__c ,Customer_Addr_Match_Percentage__c,Dedupe_Master__c,Gen_Cust_Address_ID__c,Gen_Cust_Customer_ID__c,Legacy_Address_ID__c,Legacy_Customer_ID__c,Location_ID__c,Oracle_address1__c,Oracle_Address2__c,Oracle_Address3__c,Oracle_Address4__c,Oracle_City__c,Oracle_Country__c,Oracle_County__c,Oracle_Postal_Code__c,Oracle_State__c,Party_Site_ID__c,Party_Site_Number__c,Process_Flag__c,Record_ID__c,Request_ID__c,
                                               Addl_Column_1__c,Addl_Column_2__c,Addl_Column_3__c,Addl_Column_4__c,Addl_Column_5__c,Addl_Column_6__c,Addl_Column_7__c,Addl_Column_8__c,Addl_Column_9__c,Addl_Column_10__c,Addl_Column_11__c,Addl_Column_12__c,
                                               Addl_Column_13__c,Addl_Column_14__c,Addl_Column_15__c,Addl_Column_16__c,Addl_Column_17__c,Addl_Column_18__c,Addl_Column_19__c,Addl_Column_20__c from Dedupe_Address__c where Dedupe_Master__c =: dedupeMasterId and Record_ID__c =: customerDupeCheckList.get(currentPage).Record_ID__c order by Customer_Addr_Match_Percentage__c DESC limit 250]){
            dedupeAddressWrapList.add(new DedupeAddressWrapper(dedupeAddress,customerDupeCheckAddressMap.get(currentCustomerDupeCheckId) == dedupeAddress.Cust_Acct_Site_ID__c));
        }
        system.debug('--------dedupeAddressWrapList----------' + dedupeAddressWrapList.size());
    }
    
    public void showaddress(){
        system.debug('------------------' + dedupeAccountId);
        system.debug('------------------' + dedupeMasterId);
        system.debug(currentPage + '------------------' + customerDupeCheckList);
        getCustomerdupCheck(false);
        dedupeAddressWrapList = new List<DedupeAddressWrapper>();
        for(Dedupe_Address__c dedupeAddress : [select Id,Name,Org_Id__c,Bill_To_Addr_Invoice_Count__c,Cust_Account_ID__c,Cust_Acct_Site_ID__c ,Customer_Addr_Match_Percentage__c,Dedupe_Master__c,Gen_Cust_Address_ID__c,Gen_Cust_Customer_ID__c,Legacy_Address_ID__c,Legacy_Customer_ID__c,Location_ID__c,Oracle_address1__c,Oracle_Address2__c,Oracle_Address3__c,Oracle_Address4__c,Oracle_City__c,Oracle_Country__c,Oracle_County__c,Oracle_Postal_Code__c,Oracle_State__c,Party_Site_ID__c,Party_Site_Number__c,Process_Flag__c,Record_ID__c,Request_ID__c,
                                               Addl_Column_1__c,Addl_Column_2__c,Addl_Column_3__c,Addl_Column_4__c,Addl_Column_5__c,Addl_Column_6__c,Addl_Column_7__c,Addl_Column_8__c,Addl_Column_9__c,Addl_Column_10__c,Addl_Column_11__c,Addl_Column_12__c,
                                               Addl_Column_13__c,Addl_Column_14__c,Addl_Column_15__c,Addl_Column_16__c,Addl_Column_17__c,Addl_Column_18__c,Addl_Column_19__c,Addl_Column_20__c from Dedupe_Address__c where Dedupe_Master__c =: dedupeMasterId and Record_ID__c =: customerDupeCheckList.get(currentPage).Record_ID__c and Cust_Account_ID__c=:dedupeAccountId order by Customer_Addr_Match_Percentage__c DESC limit 250]){
            system.debug('-------------' + dedupeAddress);
            dedupeAddressWrapList.add(new DedupeAddressWrapper(dedupeAddress,customerDupeCheckAddressMap.get(currentCustomerDupeCheckId) == dedupeAddress.Cust_Acct_Site_ID__c));
        }
        system.debug('-------------' + dedupeAddressWrapList);
    }
    
    public void previous(){
        if(currentPage > 0)currentPage--;
        getCustomerdupCheck(false);
        currentCustomerDupeCheckId = customerDupeCheckList.get(currentPage).Id;
        customerDupeCheck = customerDupeCheckList.get(currentPage);
        getDedupeAccounts();
        //getDedupeAddresses();
        showaddress();
        nextPageFlag = (currentPage == (totalPage - 1));
        previousFlag = (currentPage == 0);
    } 
    
    public void next(){
        system.debug('-------dedupeAddressId--------' + dedupeAddressId);
        system.debug('--------dedupeAccountId-------' + dedupeAccountId);
        setSelectedValue();
        save();
        
        currentPage++;
        if(currentPage < totalPage){
            getCustomerdupCheck(false);
            currentCustomerDupeCheckId = customerDupeCheckList.get(currentPage).Id;
            customerDupeCheck = customerDupeCheckList.get(currentPage);
            getDedupeAccounts();
            //getDedupeAddresses();
            showaddress();
        }
        nextPageFlag = (currentPage == totalPage);
        previousFlag = (currentPage == 0);
        /*dedupeAddressId = customerDupeCheckAddressMap.put(currentCustomerDupeCheckId , dedupeAddressId);
        dedupeAccountId = customerDupeCheckAccountMap.put(currentCustomerDupeCheckId , dedupeAccountId);*/
        
            
         system.debug('-------dedupeAddressId--------' + dedupeAddressId);
        system.debug('--------dedupeAccountId-------' + dedupeAccountId);
    }
    
    public void setSelectedValue(){
        customerDupeCheckAddressMap.put(currentCustomerDupeCheckId , dedupeAddressId);
        customerDupeCheckAccountMap.put(currentCustomerDupeCheckId , dedupeAccountId);
    }
    
    public void save(){
        system.debug(customerDupeCheck + '-----------' + dedupeAddressId);
        system.debug('-----------' + currentCustomerDupeCheckId);
        system.debug('-----------' + dedupeAddressId);
       
            Customer_Dup_Check__c customerDupCheck = new Customer_Dup_Check__c();
            customerDupCheck.id= currentCustomerDupeCheckId;
            customerDupCheck.Cust_Account_ID__c = dedupeAccountId;
            customerDupCheck.Cust_Acct_Site_ID__c = dedupeAddressId;
            customerDupCheck.Process_Flag__c = 'Y';
            update customerDupCheck;
            dedupeAccountId= Null;
            dedupeAddressId = Null;
    }
    
    public class DedupeAccountWrapper{
        public Dedupe_Account__c dedupeAccount{get;set;}
        public boolean selected{get;set;}
        public DedupeAccountWrapper(Dedupe_Account__c dedupeAccount1,boolean selected1){
            dedupeAccount = new Dedupe_Account__c();
            dedupeAccount = dedupeAccount1; 
            selected = selected1;
        }
    }
    
    public class DedupeAddressWrapper{
        public Dedupe_Address__c dedupeAddress{get;set;}
        public boolean selected{get;set;}
        public DedupeAddressWrapper(Dedupe_Address__c dedupeAddress1,boolean selected1){
            dedupeAddress = new Dedupe_Address__c();
            dedupeAddress = dedupeAddress1;
            selected = selected1;
        }
    }
}