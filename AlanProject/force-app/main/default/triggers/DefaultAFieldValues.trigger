trigger DefaultAFieldValues on Account (before insert, before Update) {
    if(Trigger.Isinsert){
        for(Account Ac : Trigger.new)
        {
          if(Ac.COLLECTOR_Email__c ==Null){
            if(Ac.Region__c=='North America')
            Ac.COLLECTOR_Email__c =Label.Collector_Email_ARFC;
            else 
            Ac.COLLECTOR_Email__c =Label.Collector_Email_ERFC;
           }
        }
    }
  if(trigger.IsUpdate)
  {
   for(Account Ac : Trigger.new)
    {
        system.debug('-------Ac.Account_Division__c------' + Ac.Account_Division__c);
    if(Ac.Account_Division__c == Null && Ac.From_Lead_Conversion__c== True) {
   
    Ac.Account_Division__c= Ac.Creator_s_Division__c;
    Ac.From_Lead_Conversion__c= False;
    }
    }
  } 
  
   
  if(trigger.Isupdate && Trigger.Isbefore)
  {
    AccountHelper.resetStatusFlag(trigger.newMap,trigger.oldMap);
  }
}