public class ReadCsvBulkModeController{
    public static boolean importDataFlag = false;
    String attName;
    String attContentType;
    public List<selectOption> FileList{get; set;}
    public Id attachmentId{get; set;}
    public boolean runBatchEnable{get;set;}
    private string COMMA = ',';
    private string NL = '\n';
    private string QUOTE = '"';
    private string DOUBLE_QUOTE = '""';
    String csvData = '';
    List<String> fields;
    string header;
    Dedupe_Master__c data;
    string attachTimeStamp;
    public ReadCsvBulkModeController(Apexpages.StandardController controller){
        
        runBatchEnable = false;
        attachTimeStamp = system.now().format();
        data = [select Id from Dedupe_Master__c where Id =: controller.getId()];

        FileList = new List<selectOption>();
        for(Attachment att : [select Id,Name from Attachment where ParentId =: data.Id]){
            FileList.add(new SelectOption(att.Id,att.Name));
        }
    }
      public Void validateHeader(){
               
        Attachment att = [select ID,body,ContentType,Name from Attachment where Id =: attachmentId];
        Blob csvDataBlob = att.body;
        attName = att.Name;
        attContentType = att.ContentType;
        csvData = csvDataBlob.toString();
         BatchReadCSVDedupFile processBatch = new BatchReadCSVDedupFile(csvData,data,attName);
         csvData = '';
        Id batchId = database.executeBatch(processBatch,200);
        
         // return (new Pagereference('/'+data.Id));
        }
        
      Public void DeleteAll(){
       /*List<Customer_Dup_Check__c> DelCustDupCheckList = new List<Customer_Dup_Check__c>([select id from Customer_Dup_Check__c where Dedupe_Master__c =:data.Id Limit 3000]);
        /*List<Dedupe_Account__c> DelDedupeAccountList = new List<Dedupe_Account__c>([select id from Dedupe_Account__c where Dedupe_Master__c =:data.Id Limit 3000]);
        List<Dedupe_Address__c> DelDedupeAddressList = new List<Dedupe_Address__c>([select id from Dedupe_Address__c where Dedupe_Master__c =:data.Id Limit 3000]);
        
        if(DelCustDupCheckList.size()>0) delete DelCustDupCheckList;
        if(DelDedupeAccountList.size()>0) delete DelDedupeAccountList;
        if(DelDedupeAddressList.size()>0) delete DelDedupeAddressList;*/
       // Dedupe_Master__c Dup = [select id,name,(select id,name from Dedupe_Account__r), (select id, name from Dedupe_Address__r) ,(Select id,Name from Customer_Dup_Check__r) from Dedupe_Master__c limit 1];
        
        string str2='select id,name from Customer_Dup_Check__c where Dedupe_Master__c= \'' + data.id + '\'';
        BatchMassDeleteRecs bdt2=new BatchMassDeleteRecs(str2);
        Database.executeBatch(bdt2,2000);
        
        string str='select id,name from Dedupe_Account__c where Dedupe_Master__c= \'' + data.id + '\'';
        BatchMassDeleteRecs bdt=new BatchMassDeleteRecs(str);
        Database.executeBatch(bdt,2000);
        
        string str1='select id,name from Dedupe_Address__c where Dedupe_Master__c= \'' + data.id + '\'';
        BatchMassDeleteRecs bdt1=new BatchMassDeleteRecs(str1);
        Database.executeBatch(bdt1,2000);
        
                
      }
      
      Public PageReference Done()
      {
      return (new Pagereference('/'+data.Id));
      }
    }