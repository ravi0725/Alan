trigger failedCallOutaCCOUNTS on Failed_Callout_Accounts__c (after insert) {

    set<id> count = trigger.newmap.keyset();
    
    integer Reccount = [select count() from Failed_Callout_Accounts__c];
    system.debug('Reccount====='+Reccount);
    if(count.size()>0 && Reccount==1)
    scheduleBatchSync sc = new scheduleBatchSync();
    
    }