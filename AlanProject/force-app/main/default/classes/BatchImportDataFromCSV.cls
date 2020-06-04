global with sharing class BatchImportDataFromCSV implements Database.batchable<String>, Database.Stateful
{
    private String m_csvFile;
    private Integer m_startRow;
    private static final Integer SCOPE_SIZE = 100;
    private List<String> objFields;
    private String saveResultSuccess;
    private String saveResultFailed;
    private Import_Data__c importData;
    private Attachment attach;
    private String attName;
    private String attContentType;
    private set<String> objIds;
    private Id successFileId;
    private Integer successRecordCount;
    private Integer failRecordCount;
    private string successAttachmentId;
    String attachTimeStamp;
    public BatchImportDataFromCSV(String csvData,Import_Data__c impData, List<String> fields,String attachmentName, String ContentType, String atchTimeStamp){
        successRecordCount = 0;
        failRecordCount = 0;
        m_csvFile = csvData;
        objFields = new List<String>();
        objFields.addAll(fields);
        importData = new Import_Data__c();
        importData = impData;
        saveResultSuccess = '';
        saveResultFailed = '';
        attName = attachmentName;
        attContentType = ContentType;
        objIds = new set<String>();
        attachTimeStamp = atchTimeStamp;
    }
    
    global Iterable<String> start(Database.batchableContext batchableContext){ 
        return new CSVIterator(m_csvFile, '\r\n');
    }
    
    global void execute(Database.BatchableContext batchableContext, List<String> scope){
        system.debug('---------scope--------' + scope);
        List<sObject> objRecordsList = new List<sObject>();
        
        objRecordsList = CSVReader.ReadLine(scope,objFields,importData);
        Map<String,String> resultMap = new Map<String,String>();

        if(importData.Operation__c == 'Create'){
            resultMap = doInsert(objRecordsList,scope,importData);
        }
        
        if(importData.Operation__c == 'Update'){
            resultMap = doUpdate(objRecordsList,scope,importData);
        }
        
        if(importData.Operation__c == 'Delete'){
            resultMap = doDelete(objRecordsList,scope,importData);
        }
        
        /*if(importData.Operation__c == 'Upsert'){
            resultMap = doUpsert(objRecordsList,scope,importData);
        }*/
        if(resultMap.containsKey('Success'))saveResultSuccess = saveResultSuccess + resultMap.get('Success');
        if(resultMap.containsKey('Fail'))saveResultFailed = saveResultFailed + resultMap.get('Fail');
        system.debug('--saveResult--Success--'+saveResultSuccess+'\n--saveResult--Failed--'+saveResultFailed);
        
        AsyncApexJob statusInfo = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems 
                                  FROM AsyncApexJob WHERE Id =: batchableContext.getJobId()];
        importData.Total_Items__c = statusInfo.TotalJobItems ;
        importData.Items_Processed__c = statusInfo.JobItemsProcessed+1;
        importData.Status__c = statusInfo.Status;
        update importData;
    }
        
    global void finish(Database.BatchableContext batchableContext){
        try{
            createResultCSV(importData, saveResultSuccess, saveResultFailed, attName, attcontentType, objFields);
            if(objIds.size() > 0 && importData.Run_Integration__c){
                AsyncApexJob statusInfo = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems 
                                      FROM AsyncApexJob WHERE Id =: batchableContext.getJobId()];
                importData.Total_Items__c = statusInfo.TotalJobItems ;
                importData.Items_Processed__c = statusInfo.JobItemsProcessed;
                importData.Status__c = 'Web Service Callout initializing';
                importData.DML_Operation_Result__c = 'Total Records = ' + (successRecordCount + failRecordCount) + '<br/>';
                importData.DML_Operation_Result__c = importData.DML_Operation_Result__c + 'Success Records : ' + successRecordCount + '<br/>';
                importData.DML_Operation_Result__c = importData.DML_Operation_Result__c + 'Failed Records : ' + failRecordCount + '<br/>';
                update importData;
            }else{
                AsyncApexJob statusInfo = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems 
                                      FROM AsyncApexJob WHERE Id =: batchableContext.getJobId()];
                importData.Total_Items__c = statusInfo.TotalJobItems ;
                importData.Items_Processed__c = statusInfo.JobItemsProcessed;
                importData.Status__c = 'Completed';
                importData.DML_Operation_Result__c = 'Total Records = ' + (successRecordCount + failRecordCount) + '<br/>';
                importData.DML_Operation_Result__c = importData.DML_Operation_Result__c + 'Success Records : ' + successRecordCount + '<br/>';
                importData.DML_Operation_Result__c = importData.DML_Operation_Result__c + 'Failed Records : ' + failRecordCount + '<br/>';
                update importData;
            }
            
            if(objIds.size() > 0 && importData.Run_Integration__c){
                system.debug('------------importData--------' + importData);
                ScheduleImportDataCallOut sbcp = new ScheduleImportDataCallOut(new Map<String,String>(),objIds, importData , 0 , 0,successAttachmentId);
                DateTime sysTime = System.now().addSeconds(importData.Interval__c.intValue());
                String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
                System.schedule( 'ScheduleImportDataCallOut' + sysTime, chronExpression, sbcp);
            }
        }catch(Exception ex){
            importData.Exception_Detail__c = ex.getMessage() + '\n Exception Line Number: '+ex.getLineNumber();
            importData.Status__c = 'Failed';
            update importData;
        }
    }
    
    global void createResultCSV(Import_Data__c importData,String resultSuccess, String resultFail,String attachmentName,String contentType,List<String> objFields){
        try{
            system.debug('--Import_Data__c :'+importData+'\n  --resultSuccess :'+resultSuccess+'\n  --resultFail :'+resultFail+'\n  --attachmentName :'+attachmentName+'\n  --contentType :'+contentType+'  --objFields :'+objFields);
            String header = '';
            system.debug('--Operation:'+importData.Operation__c);
            if(importData.Operation__c == 'Create')header = '"Id",';
            for(String hf: objFields){
                header = header+'"'+hf+'",';
                system.debug('--header--'+hf);
            }
            header = header + '"Status"\r\n';
            
            system.debug('--header--'+header);
            system.debug('--Finish--saveResult--Success--'+resultSuccess+'\n--saveResult--Failed--'+resultFail);
            List<Attachment> attList = new List<Attachment>();
            boolean flag = false;
            if(resultSuccess != ''){
                Attachment att = new Attachment();
                att.Name = (attachmentName.contains('.csv')?attachmentName.replace('.csv',''):attachmentName) + ' - Success-'+attachTimeStamp+'.csv';
                att.Body = Blob.valueOf(header+resultSuccess);
                att.ParentId = importData.Id;
                att.ContentType = contentType;//'application/vnd.ms-excel';
                attList.add(att);
                flag = true;
            }
            
            if(resultFail != ''){
                Attachment att = new Attachment();
                att.Name = (attachmentName.contains('.csv')?attachmentName.replace('.csv',''):attachmentName) + ' - Error-'+attachTimeStamp + '.csv';
                att.Body = Blob.valueOf(header+resultFail);
                att.ParentId = importData.Id;
                att.ContentType = contentType;//'application/vnd.ms-excel';
                attList.add(att);
            }
            
            if(attList.size() > 0){
                insert attList;
                if(flag)successAttachmentId = attList.get(0).Id;
            }
        }catch(Exception ex){
            /*importData.Exception_Detail__c = ex.getMessage() + '\n Exception Line Number: '+ex.getLineNumber();
            importData.Status__c = 'Failed';
            update importData;*/
        }
    }
    
    public static void processContact(List<sObject> conList){
        Map<Id,string> accCountryMap = new Map<Id,String>();
        for(sObject obj : conList){
            if(obj.get('AccountId') != null && obj.get('MailingCountry') == null){
                accCountryMap.put((Id)obj.get('AccountId'),'');
            }
        }
        
        for(Account acc : [select Id,BillingCountry from Account where Id in: accCountryMap.keySet()]){
            accCountryMap.put(acc.Id, acc.BillingCountry);
        }
        
        for(sObject obj : conList){
            if(obj.get('AccountId') != null){
                if(accCountryMap.get((Id)obj.get('AccountId')) != '')obj.put('MailingCountry' , accCountryMap.get((Id)obj.get('AccountId')));
            }
        }
    }
    
    
    global Map<String,String> doInsert(List<SObject> objRecordsList,List<String> scope,Import_Data__c data){
        Map<String,String> resultMap = new Map<String,String>();
        Integer scopeIndex = 0;
        string saveResultSuccess = '';
        string saveResultFailed = '';
        List<WS_Interface_Log__c> logList = new List<WS_Interface_Log__c>();
        try{
            ImportDataController.importDataFlag = true;
            if(ImportData.Object__c == 'Contact')processContact(objRecordsList);
            for(Database.saveResult ins: Database.insert(objRecordsList, false)){
                system.debug('--ins--'+ins);
                string resultSuccess = '';
                string resultFailed = '';
                if(ins.isSuccess()){
                    successRecordCount++;
                    /*String objId = (data.Object__c == 'Address__c' ? 'Account__c' : (data.Object__c == 'Contact' ? 'AccountId' : 'Id'));
                    if(data.Run_Integration__c && objRecordsList[scopeIndex].get(objId) != null){
                        objIds.add((string)objRecordsList[scopeIndex].get(objId));
                    }*/
                    objIds.add(ins.getId());
                    system.debug('--insert--Success');
                    resultSuccess = ',"Insert Successfully"';
                    saveResultSuccess = saveResultSuccess + '"' + ins.getId() + '",' +scope.get(scopeIndex)+resultSuccess+'\r\n';
                    resultMap.put('Success', saveResultSuccess);
                }else{
                    failRecordCount++;
                    resultFailed = ',"';
                    String erMsg = '';
                    for (Database.Error er : ins.getErrors()){
                        if(resultFailed.length() > 2)resultFailed = resultFailed + '\n';
                        system.debug('--insert--failed'+er.getStatusCode()+'--errmsg--'+er.getMessage());
                        resultFailed = resultFailed+'Error (' +  er.getStatusCode() + '):' + er.getMessage();
                        erMsg = erMsg + er.getMessage()+'.  ';
                    }
                    resultFailed = resultFailed+'"';
                    saveResultFailed = saveResultFailed+scope.get(scopeIndex)+resultFailed+'\r\n';
                    resultMap.put('Fail', saveResultFailed);
                    if(saveResultFailed != ''){
                        WS_Interface_Log__c log = WS_Interface_Log.createLog('BatchImportDataFromCSV','doinsert',erMsg,saveResultFailed,'');
                        logList.add(log);
                    }
                }
                scopeIndex++;
            }
            if(logList.size() > 0){
                insert logList;
            }
            logList.clear();
            ImportDataController.importDataFlag = false;
        }catch(Exception ex){
            /*importData.Exception_Detail__c = ex.getMessage() + '\n Exception Line Number: '+ex.getLineNumber();
            importData.Status__c = 'Failed';
            update importData;*/
        }
        return resultMap;
    }
    
    global Map<String,String> doUpdate(List<SObject> objRecordsList,List<String> scope,Import_Data__c data){
        Map<String,String> resultMap = new Map<String,String>();
        Integer scopeIndex = 0;
        string saveResultSuccess = '';
        string saveResultFailed = '';
        List<WS_Interface_Log__c> logList = new List<WS_Interface_Log__c>();
        try{
            ImportDataController.importDataFlag = true;
            for(Database.saveResult ins: Database.update(objRecordsList,false)){
                system.debug('--ins--'+ins);
                string resultSuccess = '';
                string resultFailed = '';
                system.debug('--ins--'+ins);
                system.debug('----------------' + scope.get(scopeIndex));
                if(ins.isSuccess()){
                    objIds.add(ins.getId());
                    successRecordCount++;
                    system.debug('--update--Success');
                    resultSuccess = ',"Update Successfully"';
                    saveResultSuccess = saveResultSuccess+scope.get(scopeIndex)+resultSuccess+'\r\n';
                    resultMap.put('Success', saveResultSuccess);
                }else{
                    failRecordCount++;
                     resultFailed = ',"';
                     String erMsg = '';
                     for (Database.Error er : ins.getErrors()){
                         if(resultFailed.length() > 2)resultFailed = resultFailed + '\n';
                         system.debug('--update--failed'+er.getStatusCode()+'--errmsg--'+er.getMessage());
                         resultFailed = resultFailed+'Error (' +  er.getStatusCode() + '):' + er.getMessage();
                         erMsg = erMsg +er.getMessage()+'.  ';
                     }
                     resultFailed = resultFailed+'"';
                    saveResultFailed = saveResultFailed+scope.get(scopeIndex)+resultFailed+'\r\n';
                    resultMap.put('Fail', saveResultFailed);
                    if(saveResultFailed != ''){
                        WS_Interface_Log__c log = WS_Interface_Log.createLog('BatchImportDataFromCSV','doUpdate',erMsg,saveResultFailed,'');
                        logList.add(log);
                    }
                }
                scopeIndex++;
            }
            if(logList.size() > 0){
                insert logList;
            }
            logList.clear();
            ImportDataController.importDataFlag = false;
        }catch(Exception ex){
            /*importData.Exception_Detail__c = ex.getMessage() + '\n Exception Line Number: '+ex.getLineNumber();
            importData.Status__c = 'Failed';
            update importData;*/
        }
        return resultMap;
    }
    
    global Map<String,String> doDelete(List<SObject> objRecordsList,List<String> scope,Import_Data__c data){
        Map<String,String> resultMap = new Map<String,String>();
        Integer scopeIndex = 0;
        string saveResultSuccess = '';
        string saveResultFailed = '';
        List<WS_Interface_Log__c> logList = new List<WS_Interface_Log__c>();
        try{
            ImportDataController.importDataFlag = true;
            for(Database.deleteResult ins: Database.Delete(objRecordsList,false)){
                system.debug('--ins--'+ins);
                string resultSuccess = '';
                string resultFailed = '';
                system.debug('--ins--'+ins);
                system.debug('----------------' + scope.get(scopeIndex));
                if(ins.isSuccess()){
                    objIds.add(ins.getId());
                    successRecordCount++;
                    system.debug('--Delete--Success');
                    resultSuccess = ',"Delete Successfully"';
                    saveResultSuccess = saveResultSuccess+scope.get(scopeIndex)+resultSuccess+'\r\n';
                    resultMap.put('Success', saveResultSuccess);
                }else{
                    failRecordCount++;
                     resultFailed = ',"';
                     String erMsg = '';
                     for (Database.Error er : ins.getErrors()){
                         if(resultFailed.length() > 2)resultFailed = resultFailed + '\n';
                         system.debug('--Delete--failed'+er.getStatusCode()+'--errmsg--'+er.getMessage());
                         resultFailed = resultFailed+'Error (' +  er.getStatusCode() + '):' + er.getMessage();
                         erMsg = erMsg +er.getMessage()+'.  ';
                     }
                     resultFailed = resultFailed+'"';
                    saveResultFailed = saveResultFailed+scope.get(scopeIndex)+resultFailed+'\r\n';
                    resultMap.put('Fail', saveResultFailed);
                    if(saveResultFailed != ''){
                        WS_Interface_Log__c log = WS_Interface_Log.createLog('BatchImportDataFromCSV','doUpdate',erMsg,saveResultFailed,'');
                        logList.add(log);
                    }
                }
                scopeIndex++;
            }
            if(logList.size() > 0){
                insert logList;
            }
            logList.clear();
            ImportDataController.importDataFlag = false;
        }catch(Exception ex){
            /*importData.Exception_Detail__c = ex.getMessage() + '\n Exception Line Number: '+ex.getLineNumber();
            importData.Status__c = 'Failed';
            update importData;*/
        }
        return resultMap;
    }
    
}