global class ScheduleBatchCreateProposal implements Schedulable {
   global void execute(SchedulableContext sc) {
      BatchCreateProposal b = new BatchCreateProposal('TNV_SFDC_OPPORTUNITY_EXT_PKG'); 
      database.executebatch(b, 10);
      // System.abortJob(sc.getTriggerId());
   }
    
}