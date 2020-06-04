public class ReadDedupeCsvController{
    public static boolean importDataFlag = false;
    String attName;
    String attContentType;
    public List<selectOption> FileList{get; set;}
    public boolean runBatchEnable{get;set;}
    private string COMMA = ',';
    private string NL = '\n';
    private string QUOTE = '"';
    private string DOUBLE_QUOTE = '""';
    String csvData = '';
    List<String> fields;
    string header;
    Dedupe_Master__c MasterRecord;
    string attachTimeStamp;
    public ReadDedupeCsvController(Apexpages.StandardController controller){
        runBatchEnable = false;
        attachTimeStamp = system.now().format();
        MasterRecord = [select Id from Dedupe_Master__c where Id =: controller.getId()];

        FileList = new List<selectOption>();
        for(Attachment att : [select Id,Name from Attachment where ParentId =: MasterRecord.Id]){
            FileList.add(new SelectOption(att.Id,att.Name));
        }
    }
    
      public static String blobToString(Blob input, String inCharset){
        String hex = EncodingUtil.convertToHex(input);
        System.assertEquals(0, hex.length() & 1);
        final Integer bytesCount = hex.length() >> 1;
        String[] bytes = new String[bytesCount];
        for(Integer i = 0; i < bytesCount; ++i)
            bytes[i] =  hex.mid(i << 1, 2);
        return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), inCharset);
    }  
    
    public Pagereference validateHeader(){
        List<Customer_Dup_Check__c> DelCustDupCheckList = new List<Customer_Dup_Check__c>([select id from Customer_Dup_Check__c where Dedupe_Master__c =:MasterRecord.Id]);
        List<Dedupe_Account__c> DelDedupeAccountList = new List<Dedupe_Account__c>([select id from Dedupe_Account__c where Dedupe_Master__c =:MasterRecord.Id]);
        List<Dedupe_Address__c> DelDedupeAddressList = new List<Dedupe_Address__c>([select id from Dedupe_Address__c where Dedupe_Master__c =:MasterRecord.Id]);
        
        if(DelCustDupCheckList.size()>0) delete DelCustDupCheckList;
        if(DelDedupeAccountList.size()>0) delete DelDedupeAccountList;
        if(DelDedupeAddressList.size()>0) delete DelDedupeAddressList;
        
        List<Attachment> attList = new List<Attachment>([select ID,body,ContentType,Name from Attachment where ParentId =: MasterRecord.Id]);
        Map<string,Dedup_Object_Setup__c> mapCodes = Dedup_Object_Setup__c.getAll(); 
        
        for(Attachment Att : attList){
        attName = att.Name;
        Blob csvDataBlob = att.body;
        attContentType = att.ContentType;
        csvData=blobToString( csvDataBlob,'ISO-8859-1');
        system.debug('>>>>>>>>BeforeBatchcall>>>>>>');
        BatchReadCSVDedupFile processBatch = new BatchReadCSVDedupFile(csvData,MasterRecord,attName);
                csvData = '';
        Id batchId = database.executeBatch(processBatch,200);
        system.debug('>>>>>>>>AfterBatchcall>>>>>>');
     }
   
   return (new Pagereference('/'+MasterRecord.Id));
   }
   }