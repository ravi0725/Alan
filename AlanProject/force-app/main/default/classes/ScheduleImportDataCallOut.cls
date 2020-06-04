global class ScheduleImportDataCallOut implements Schedulable {
   public Map<String, String> callOutStatusMap = new Map<String, String>();
   public set<String> callOutIdSet = new set<String>();
   public Import_Data__c importData;
   public Id scheduleJobId;
   private Integer successRecordCount;
    private Integer failRecordCount;
    private String successAttachmentId;
   global ScheduleImportDataCallOut(Map<String, String> calloutMap, set<String> callSet, Import_Data__c impData,integer successCnt,Integer failedCnt,String attachmentId){
       callOutIdSet = callSet;
       importData = impData;
       successRecordCount = successCnt;
        failRecordCount = failedCnt;
        callOutStatusMap = calloutMap;
        successAttachmentId = attachmentId;
   }
   
   global void execute(SchedulableContext sc) {
        scheduleJobId = sc.getTriggerId();
        BatchImportDataMakeCallout bid = new BatchImportDataMakeCallout(callOutStatusMap,callOutIdSet ,importData , successRecordCount,failRecordCount,successAttachmentId);
        Database.executeBatch(bid, importData.Batch_Size_Callout__c.intValue());
        System.abortJob(scheduleJobId);
   }
}