public class ImportDataController{
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
    Import_Data__c data;
    string attachTimeStamp;
    public ImportDataController(Apexpages.StandardController controller){
        runBatchEnable = false;
        attachTimeStamp = system.now().format();
        data = [select Id,Total_Items__c,Items_Processed__c,Object__c,Run_Integration__c,Operation__c,Batch_Size__c,Batch_Size_Callout__c,Interval__c from Import_Data__c where Id =: controller.getId()];

        FileList = new List<selectOption>();
        for(Attachment att : [select Id,Name from Attachment where ParentId =: data.Id]){
            FileList.add(new SelectOption(att.Id,att.Name));
        }
    }
    
    public void resetStatus(){
        data.Total_Items__c = 0;
        data.Items_Processed__c = 0;
        data.Status__c = 'Initializing';
        data.Exception_Detail__c = '';
        data.DML_Operation_Result__c = '';
        data.Callout_Result__c = '';
        update data;
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
    
    public void validateHeader(){
        resetStatus();
        Attachment att = [select ID,body,ContentType,Name from Attachment where Id =: attachmentId];
        Blob csvDataBlob = att.body;
        attName = att.Name;
        attContentType = att.ContentType;
        
        csvData=blobToString( csvDataBlob,'ISO-8859-1');
        system.debug('----fullCsvData----'+csvData);
        string lineBreak = '';
        if(csvData.indexOf('\r\n') != -1)lineBreak = '\r\n';
        else lineBreak = '\n';
        header = csvData.subString(0, csvData.indexOf(lineBreak));
        csvData = csvData.subString(csvData.indexOf(lineBreak) + lineBreak.length(),csvData.length());
        system.debug('=-------------' + csvData);
        fields = new List<String>();
        fields = header.replace('"','').split(',');
        system.debug('--fields--'+fields);
        
        SObjectType objType = Schema.getGlobalDescribe().get(data.Object__c);
        Map<String,Schema.SObjectField> mfields = objType.getDescribe().fields.getMap();
        system.debug('--mfields--'+mfields.keySet().size());
        
        List<String> unknownFields = new List<String>();
        if(mfields.keySet().size()>0){
            Integer i = 0;
            for(String fileCol: fields){
                
                if(!mfields.keySet().contains(fileCol.toLowerCase())){
                    unknownFields.add(fileCol);
                }
                i++;
            }
            system.debug('--unknownFields--'+unknownFields);
        }
        
        if(unknownFields.size() > 0){
            String errMsg = 'Following are invalid fields on '+data.Object__c+' : \n'+unknownFields;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, errMsg));
            data.Id = Apexpages.CurrentPage().getParameters().get('Id');
            data.Total_Items__c = 0;
            data.Items_Processed__c = 0;
            data.Status__c = 'Failed';
            update data;
        }else{
            try{
                system.debug('--------data-------' + data);
                BatchImportDataFromCSV processBatch = new BatchImportDataFromCSV(csvData,data,fields,attName,attContentType, attachTimeStamp);
                csvData = '';
                Id batchId = database.executeBatch(processBatch, data.Batch_Size__c.intValue());
                AsyncApexJob statusInfo = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems 
                                  FROM AsyncApexJob WHERE Id =: batchId];
                data.Total_Items__c = statusInfo.TotalJobItems ;
                data.Items_Processed__c = statusInfo.JobItemsProcessed;
                update data;
            }catch(Exception ex){
                WS_Interface_Log__c log = WS_Interface_Log.createLog('ImportDataController','importDataWithoutCallout',ex.getMessage(),ex.getTypeName() + '\n' + ex.getCause() + '\n' + ex.getStackTraceString(),'');
                insert log;
                data.Id = Apexpages.CurrentPage().getParameters().get('Id');
                data.Status__c = 'Failed';
                data.Exception_Detail__c = ex.getMessage().subString(255);
                update data;
                Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            }
        }
    }

}