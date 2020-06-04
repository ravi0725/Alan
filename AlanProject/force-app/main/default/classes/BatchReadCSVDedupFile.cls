global with sharing class BatchReadCSVDedupFile implements Database.batchable<String>, Database.Stateful
{
    private String m_csvFile;
    private Integer m_startRow;
    private static final Integer SCOPE_SIZE = 100;
    private Attachment attach;
    private String attName;
    private String attContentType;
    Private Dedupe_Master__c DeDupMasterRecord;
    private Id successFileId;
    private String FlName;
    
    public BatchReadCSVDedupFile(String csvData,Dedupe_Master__c  DeDupMaster,String FileName){
        m_csvFile = csvData;
        DeDupMasterRecord = new Dedupe_Master__c();
        DeDupMasterRecord = DeDupMaster;
        FlName = FileName;
    }
    
    global Iterable<String> start(Database.batchableContext batchableContext){ 
        return new CSVIterator(m_csvFile, '\r\n');
    }
    
    global void execute(Database.BatchableContext batchableContext, List<String> scope){
        system.debug('-------------' + Scope.size());
        system.debug('-------------' + FlName);
        String BatchCsvData='';
        String subString;
        try{
            for(String csvData : Scope){
                List<String> strList = new List<String>();
             system.debug('---->>>>>>---------' + csvData);
                while(csvData != ''){
                    system.debug('-------------' + csvData.startswith('"'));
                    if(csvData.startswith('"')){
                        subString = csvData.substringBetween('"', '"');
                        csvData = csvData.substring(subString.length() + 2, csvData.length());
                        
                    }else{
                        if(csvData.indexof(',') == -1){
                            subString = csvData.substring(0, csvData.length());
                            csvData= '';
                        }else{
                            subString = csvData.substring(0, csvData.indexof(','));
                            csvData = csvData.substring(csvData.indexof(',')  , csvData.length());
                        }
                        
                    }
                    strList.add(subString);
                    if(csvData.length() > 0){
                        csvData = csvData.substring(1, csvData.length());
                        if(csvData == '')strList.add(csvData);
                    }
                    
                }
                if(strList.size() > 0){
                    for(string str : strList){
                        BatchCsvData = BatchCsvData + str +'//n';
                    }
                    BatchCsvData = BatchCsvData + '\r\n';
                }
            }
        }catch(Exception ex){
            system.debug('------ex-------' + ex);
        }
        
        system.debug('------BatchCsvData-------' + BatchCsvData);
        
        List<string> rows = BatchCsvData.split('\r\n');
        
        if(FlName.contains('CUSTOMERS_DUP_CHECK')){
            system.debug('-------------' + Scope);
            List<Customer_Dup_Check__c>CustDupCheckList = new List<Customer_Dup_Check__c>();
            
            for(Integer i=0;i<rows.size();i++)
            {
                Customer_Dup_Check__c DupRec = new Customer_Dup_Check__c();
                List<String> Columns = new List<String>();
                system.debug('>>>>>>>>>>>>>'+Columns.size());
                system.debug('>>>>>>>>>>>>>'+rows.size());
                
                if(i<rows.size()-1) {
                    Columns = rows[i+1].split('//n');
                    
                    DupRec.Project_Name__c = Columns.get(0).replace('"','');
                    DupRec.Record_ID__c = Columns.get(1).replace('"','');
                    DupRec.Customer_Name__c = Columns.get(2).replace('"','');
                    DupRec.Address_1__c = Columns.get(3).replace('"','');
                    DupRec.Address_2__c = Columns.get(4).replace('"','');
                    DupRec.Address_3__c = Columns.get(5).replace('"','');
                    DupRec.Address_4__c = Columns.get(6).replace('"','');
                    DupRec.City__c = Columns.get(7).replace('"','');
                    DupRec.State__c = Columns.get(8).replace('"','');
                    DupRec.County__c = Columns.get(9).replace('"','');
                    DupRec.Postal_Code__c = Columns.get(10).replace('"','');
                    DupRec.Country__c = Columns.get(11).replace('"','');
                    DupRec.Load_Request_ID__c = Columns.get(12).replace('"','');
                    DupRec.Dedup_Program_Request_ID__c = Columns.get(13).replace('"','');
                    DupRec.File_Name__c = Columns.get(14).replace('"','');
                    DupRec.Legacy_Customer_ID__c = Columns.get(15).replace('"','');
                    DupRec.Gen_Cust_Customer_ID__c = Columns.get(16).replace('"','');
                    DupRec.Legacy_Address_ID__c = Columns.get(17).replace('"','');
                    DupRec.Gen_Cust_Address_ID__c = Columns.get(18).replace('"','');
                    //DupRec.Cust_Acct_Site_ID__c = Columns.get(19).replace('"','');
                    DupRec.Derived_Org_ID__c = Columns.get(21).replace('"','');
                    DupRec.Dedupe_Master__c = DeDupMasterRecord.Id;
                    CustDupCheckList.add(DupRec);    
                }
            }
            system.debug('>>>>>CustDupCheckList>>>>>>>>'+CustDupCheckList);
            if(CustDupCheckList.size()>0)
                insert CustDupCheckList;    
            
        }
        
        else if(FlName.contains('CUST_DEDUP_IDEN_CUSTOMER')){
            List<Dedupe_Account__c> DedupeAccountList = new List<Dedupe_Account__c>();
            
            for(Integer i=0;i<rows.size();i++)
            {
                Dedupe_Account__c DupRec = new Dedupe_Account__c();
                List<String> Columns = new List<String>();
                
                if(i<rows.size()-1) {
                    Columns = rows[i+1].split('//n');
                    //system.debug('>>>>>>AccountColumns>>>>>>'+Columns.size());
                    //system.debug('>>>>>>Account>>>>>>'+i);
                    DupRec.Record_ID__c = Columns.get(0).replace('"','');
                    DupRec.Gen_Cust_Customer_ID__c = Columns.get(1).replace('"','');
                    DupRec.Legacy_Customer_ID__c = Columns.get(2).replace('"','');
                    DupRec.Customer_Name__c = Columns.get(3).replace('"','');
                    DupRec.Customer_Name_Match_Percentage__c = Decimal.valueof(Columns.get(4).replace('"',''));
                    DupRec.Oracle_Customer_Name__c = Columns.get(5).replace('"','');
                    DupRec.Oracle_Account_Number__c = Columns.get(6).replace('"','');
                    DupRec.Profile_Amount__c = Columns.get(7).replace('"','');
                    DupRec.Payment_Term__c = Columns.get(8).replace('"','');
                    DupRec.Bill_To_Cust_Invoice_Count__c = Decimal.valueof(Columns.get(9).replace('"',''));
                    DupRec.Party_ID__c = Columns.get(10).replace('"','');
                    DupRec.Cust_Account_ID__c = Columns.get(11).replace('"','');
                    DupRec.Request_ID__c = Columns.get(12).replace('"','');
                    DupRec.Process_Flag__c = Columns.get(13).replace('"','');
                    if(Columns.size()>=15) DupRec.Addl_Column_1__c = Columns.get(14).replace('"','');
                    if(Columns.size()>=16) DupRec.Addl_Column_2__c = Columns.get(15).replace('"','');
                    if(Columns.size()>=17) DupRec.Addl_Column_3__c = Columns.get(16).replace('"','');
                    if(Columns.size()>=18) DupRec.Addl_Column_4__c = Columns.get(17).replace('"','');
                    if(Columns.size()>=19) DupRec.Addl_Column_5__c = Columns.get(18).replace('"','');
                    if(Columns.size()>=20) DupRec.Addl_Column_6__c= Columns.get(19).replace('"','');
                    if(Columns.size()>=21) DupRec.Addl_Column_7__c= Columns.get(20).replace('"','');
                    if(Columns.size()>=22) DupRec.Addl_Column_8__c= Columns.get(21).replace('"','');
                    if(Columns.size()>=23) DupRec.Addl_Column_9__c= Columns.get(22).replace('"','');
                    if(Columns.size()>=24) DupRec.Addl_Column_10__c= Columns.get(23).replace('"','');
                    if(Columns.size()>=25) DupRec.Addl_Column_11__c= Columns.get(24).replace('"','');
                    if(Columns.size()>=26) DupRec.Addl_Column_12__c= Columns.get(25).replace('"','');
                    if(Columns.size()>=27) DupRec.Addl_Column_13__c= Columns.get(26).replace('"','');
                    if(Columns.size()>=28) DupRec.Addl_Column_14__c= Columns.get(27).replace('"','');
                    if(Columns.size()>=29) DupRec.Addl_Column_15__c= Columns.get(28).replace('"','');
                    if(Columns.size()>=30) DupRec.Addl_Column_16__c= Columns.get(29).replace('"','');
                    if(Columns.size()>=31) DupRec.Addl_Column_17__c= Columns.get(30).replace('"','');
                    if(Columns.size()>=32) DupRec.Addl_Column_18__c= Columns.get(31).replace('"','');
                    if(Columns.size()>=33) DupRec.Addl_Column_18__c= Columns.get(32).replace('"','');
                    if(Columns.size()>=34) DupRec.Addl_Column_19__c= Columns.get(33).replace('"','');
                    if(Columns.size()>=35) DupRec.Addl_Column_20__c= Columns.get(34).replace('"','');
                    DupRec.Dedupe_Master__c = DeDupMasterRecord.Id;
                    DedupeAccountList.add(DupRec);    
                }
            }
            system.debug('>>>>>DedupeAccountList>>>>>>>>'+DedupeAccountList);
            if(DedupeAccountList.size()>0)
                insert DedupeAccountList;
        }
        else if(FlName.contains('CUST_DEDUP_IDEN_ADDRESS')){
            List<Dedupe_Address__c> DedupeAddressList = new List<Dedupe_Address__c>();
            
            for(Integer i=0;i<rows.size();i++)
            {
                Dedupe_Address__c DupRec = new Dedupe_Address__c();
                List<String> Columns = new List<String>();
                
                if(i<rows.size()-1) {
                    Columns = rows[i+1].split('//n');
                    DupRec.Record_ID__c = Columns.get(0).replace('"','');
                    DupRec.Gen_Cust_Customer_ID__c = Columns.get(1).replace('"','');
                    DupRec.Legacy_Customer_ID__c = Columns.get(2).replace('"','');
                    DupRec.Gen_Cust_Address_ID__c = Columns.get(3).replace('"','');
                    DupRec.Legacy_Address_ID__c = Columns.get(4).replace('"','');
                    DupRec.Cust_Account_ID__c = Columns.get(5).replace('"','');
                    DupRec.Cust_Acct_Site_ID__c = Columns.get(6).replace('"','');
                    DupRec.Org_Id__c = Columns.get(7).replace('"','');
                    DupRec.Party_Site_ID__c = Columns.get(8).replace('"','');
                    DupRec.Party_Site_Number__c = Columns.get(9).replace('"','');
                    DupRec.Location_ID__c = Columns.get(10).replace('"','');
                    DupRec.Customer_Addr_Match_Percentage__c = Decimal.valueof(Columns.get(11).replace('"',''));
                    DupRec.Bill_To_Addr_Invoice_Count__c = Decimal.valueof(Columns.get(12).replace('"',''));
                    DupRec.Oracle_address1__c = Columns.get(13).replace('"','');
                    DupRec.Oracle_address2__c = Columns.get(14).replace('"','');
                    DupRec.Oracle_address3__c = Columns.get(15).replace('"','');
                    DupRec.Oracle_address4__c = Columns.get(16).replace('"','');
                    DupRec.Oracle_City__c = Columns.get(17).replace('"','');
                    DupRec.Oracle_State__c = Columns.get(18).replace('"','');
                    DupRec.Oracle_County__c = Columns.get(19).replace('"','');
                    DupRec.Oracle_Postal_Code__c = Columns.get(20).replace('"','');
                    DupRec.Oracle_Country__c = Columns.get(21).replace('"','');
                    DupRec.Request_ID__c = Columns.get(22).replace('"','');
                    DupRec.Process_Flag__c = Columns.get(23).replace('"','');
                    if(Columns.size()>=25) DupRec.Addl_Column_1__c= Columns.get(24).replace('"','');
                    if(Columns.size()>=26) DupRec.Addl_Column_2__c= Columns.get(25).replace('"','');
                    if(Columns.size()>=27) DupRec.Addl_Column_3__c= Columns.get(26).replace('"','');
                    if(Columns.size()>=28) DupRec.Addl_Column_4__c= Columns.get(27).replace('"','');
                    if(Columns.size()>=29) DupRec.Addl_Column_5__c= Columns.get(28).replace('"','');
                    if(Columns.size()>=30) DupRec.Addl_Column_6__c= Columns.get(29).replace('"','');
                    if(Columns.size()>=31) DupRec.Addl_Column_7__c= Columns.get(30).replace('"','');
                    if(Columns.size()>=32) DupRec.Addl_Column_8__c= Columns.get(31).replace('"','');
                    if(Columns.size()>=33) DupRec.Addl_Column_9__c= Columns.get(32).replace('"','');
                    if(Columns.size()>=34) DupRec.Addl_Column_10__c= Columns.get(33).replace('"','');
                    if(Columns.size()>=35) DupRec.Addl_Column_11__c= Columns.get(34).replace('"','');
                    if(Columns.size()>=36) DupRec.Addl_Column_12__c= Columns.get(35).replace('"','');
                    if(Columns.size()>=37) DupRec.Addl_Column_13__c= Columns.get(36).replace('"','');
                    if(Columns.size()>=38) DupRec.Addl_Column_14__c= Columns.get(37).replace('"','');
                    if(Columns.size()>=39) DupRec.Addl_Column_15__c= Columns.get(38).replace('"','');
                    if(Columns.size()>=40) DupRec.Addl_Column_16__c= Columns.get(39).replace('"','');
                    if(Columns.size()>=41) DupRec.Addl_Column_17__c= Columns.get(40).replace('"','');
                    if(Columns.size()>=42) DupRec.Addl_Column_18__c= Columns.get(41).replace('"','');
                    if(Columns.size()>=43) DupRec.Addl_Column_19__c= Columns.get(42).replace('"','');
                    if(Columns.size()>=44) DupRec.Addl_Column_20__c= Columns.get(43).replace('"','');
                    DupRec.Dedupe_Master__c = DeDupMasterRecord.Id;
                    DedupeAddressList.add(DupRec);    
                }
            }
            
            if(DedupeAddressList.size()>0)
                insert DedupeAddressList;
        }
    } 
    global void finish(Database.BatchableContext batchableContext){
    }
}