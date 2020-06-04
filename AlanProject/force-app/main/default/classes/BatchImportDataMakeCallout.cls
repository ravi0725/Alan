global with sharing class BatchImportDataMakeCallout implements Database.batchable<String>, Database.Stateful, Database.allowscallouts
{
    public Map<String, String> callOutStatusMap = new Map<String, String>();
   public set<String> callOutIdSet = new set<String>();
   public Import_Data__c importData;
   public Id scheduleJobId;
    public boolean exceptionFlag = false;
    private Integer successRecordCount;
    private Integer failRecordCount;
    private String successAttachmentId;
   global BatchImportDataMakeCallout(Map<String, String> calloutMap,set<String> callSet, Import_Data__c impData,integer successCnt,Integer failedCnt, String attachmentId){
       callOutIdSet = callSet;
       importData = impData;
       successRecordCount = successCnt;
        failRecordCount = failedCnt;
        callOutStatusMap = calloutMap;
        system.debug('---attachemnt-constructor---'+attachmentId);
        successAttachmentId = attachmentId;
   }
   
   global Iterable<String> start(Database.batchableContext batchableContext){ 
       List<String> idList = new List<String>();
       if(successRecordCount == 0 && failRecordCount == 0 && importData.Batch_Size_Callout__c != 0){
           importData.Total_Items__c = (callOutIdSet.size() / importData.Batch_Size_Callout__c.intValue()) + 1;
           importData.Items_Processed__c = 0;
           importData.Status__c = 'Web Service Callout started';
           update importData;
       }
       for(String ids: callOutIdSet){
           idList.add(ids);
           callOutIdSet.remove(ids);
           system.debug('---callOutIdSet-remove---'+callOutIdSet);
           if(idList.size() == importData.Batch_Size_Callout__c.intValue()){
               break;
           }
       }
       return new AttachmentExtractor(idList);
    }
    
    global void execute(Database.BatchableContext batchableContext, List<String> scope){
        Map<String,String> objAccIdMap = new Map<String,String>();
        if(importData.Object__c == 'Address__c'){
            for(Address__c add : [Select Account__c from Address__c where Id in : scope and Account__c != null]){
                objAccIdMap.put(add.Id,add.Account__c);
            }
        }else if(importData.Object__c == 'Contact'){
            for(Contact con : [Select AccountId,Id from Contact where Id in : scope and AccountId != null]){
                objAccIdMap.put(con.Id,con.AccountId);
            }
        }
        for(String objId : scope){
            try{
                if(importData.Object__c == 'Account'){
                    List<String> accIdList = new List<String>();
                    accIdList.add(objId);
                    AccountCreationCalloutEX.makeCallOut(accIdList,importData.Operation__c,'NoOp','NoOp',new set<String>(),new set<String>(),new set<String>());
                    accIdList.clear();
                }else if(importData.Object__c == 'Address__c'){
                    List<String> accIdList = new List<String>();
                    set<String> addIdList = new set<String>();
                    accIdList.add(objAccIdMap.get(objId));
                    addIdList.add(objId);
                    AccountCreationCalloutEX.makeCallOut(accIdList,'NoOp','NoOp',importData.Operation__c,new set<String>(),addIdList,new set<String>());
                    addIdList.clear();
                    accIdList.clear();
                }else if(importData.Object__c == 'Contact'){
                    List<String> accIdList = new List<String>();
                    set<String> conIdList = new set<String>();
                    conIdList.add(objId);
                    accIdList.add(objAccIdMap.get(objId));
                    AccountCreationCalloutEX.makeCallOut(accIdList,'NoOp',importData.Operation__c,'NoOp',conIdList,new set<String>(),new set<String>());
                    conIdList.clear();
                    accIdList.clear();
                } 
                callOutIdSet.remove(objId);
                callOutStatusMap.put(objId,AccountCreationCalloutEX.calloutResult);
                successRecordCount++;
             }catch(Exception ex){
                 callOutStatusMap.put(objId,ex.getMessage());
                 failRecordCount++;
                 WS_Interface_Log__c log = WS_Interface_Log.createLog('BatchImportDataMakeCallout','Execute',ex.getMessage(),ex.getTypeName() + '\n' + ex.getCause() + '\n' + ex.getStackTraceString()+'\n Exception Line Number: '+ex.getLineNumber(),'');
                 insert log;
                 exceptionFlag = true;
            }
        }
    }
    
    global void finish(Database.BatchableContext batchableContext){
        system.debug('---callOutIdSet-finish---'+this.callOutIdSet+'---'+callOutIdSet);
        try{
            if(callOutIdSet.size() > 0){
                importData.Items_Processed__c = importData.Total_Items__c - callOutIdSet.size();
                importData.Status__c = 'Processing';
            }else{
                importData.Items_Processed__c = importData.Total_Items__c;
                importData.Callout_Result__c = 'Total Records = ' + (successRecordCount + failRecordCount) + '<br/>';
                importData.Callout_Result__c = importData.Callout_Result__c + 'Success Records : ' + successRecordCount + '<br/>';
                importData.Callout_Result__c = importData.Callout_Result__c + 'Failed Records : ' + failRecordCount + '<br/>';
                importData.Status__c = 'Completed';
                
                system.debug('---attachemnt-finish-1--'+successAttachmentId);
                
                if(successAttachmentId != '' && successAttachmentId != null){
                    Attachment att = [select Body,Id from Attachment where Id =: successAttachmentId];
                    String csvRdData = att.Body.toString();
                    String newCsvData = '';
                    Integer idColIndex = 0;
                    Boolean flag = false;
                    while(csvRdData.length() != 0){
                        String row = '';
                        system.debug('-------st---------22' + csvRdData.indexOf('\n'));
                        if(csvRdData.indexOf('\n') == -1){
                            row = csvRdData;
                            csvRdData = '';
                        }else{
                            row = csvRdData.subString(0, csvRdData.indexOf('\n'));
                            csvRdData = csvRdData.subString(csvRdData.indexOf('\n') + '\n'.length(),csvRdData.length());
                        }
                        //return row;
                        if(!flag){
                            for(String st: row.split(',')){
                                st = st.replaceAll('"','').toLowerCase();
                                st = st.replaceAll('\'','').toLowerCase();
                                system.debug('-------st---------' + st);
                                if(st.toLowerCase() == 'id'){
                                    flag = true;
                                }
                                if(!flag)idColIndex++;
                            }
                            row = row.subString(0,row.length() - '\n'.length());
                            row = row + ',"Callout Status"';
                            newCsvData = newCsvData + row + '\n';
                        }else{
                            system.debug('-------idColIndex---------' + idColIndex);
                            if(row.split(',').size() > idColIndex){
                                if(callOutStatusMap.containskey(row.split(',')[idColIndex]))row = row.subString(0,row.length() - '\n'.length()) + ',' + callOutStatusMap.get(row.split(',')[idColIndex]);
                                else row = row.subString(0,row.length() - '\n'.length()) + ',' + '""';
                                newCsvData = newCsvData + row + '\n';
                            }
                            system.debug('-------newCsvData---------' + newCsvData);
                        } 
                        system.debug(csvRdData+'-------newCsvData---------' + newCsvData);
                    }
                    att.Body = Blob.valueOf(newCsvData);
                    system.debug('---attachemnt-finish-2--'+att.Body.toString());
                    update att;
                    system.debug('--attachment-Updated---'+att.Body.toString());
                }
            }
            update importData;
            if(callOutIdSet.size() > 0){
                system.debug('---attachemnt-finish-3--'+successAttachmentId);
                scheduleImportDataCallOut sbcp = new scheduleImportDataCallOut(callOutStatusMap,callOutIdSet, importData , successRecordCount,failRecordCount,successAttachmentId);
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
}