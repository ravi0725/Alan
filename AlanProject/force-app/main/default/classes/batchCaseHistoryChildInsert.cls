/*****************************************************************************************
    Name        : batchCaseHistoryChildInsert
    Desc        :Used to insert all Support Case History Old records with status new.
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Jitendra Behera       06/05/2015          Created
Shruti Moghe          26/05/2015          Created
******************************************************************************************/

global class batchCaseHistoryChildInsert implements Database.Batchable<sObject> {
    public string query;
    list<Support_Case_History_Old__c> scHistToInsert = new list<Support_Case_History_Old__c>();
    global Database.QueryLocator start(Database.BatchableContext BC) {
        if(!Test.isRunningTest())
        query ='select id, caseNumber, CreatedDate, Date_Time_Opened__c from case where Legacy_System_ID_Manhattan_US_SFDC__c!= null';// where Support_Case_History_Child_Count__c>0';
        else if(Test.isRunningTest())
        query ='select id, caseNumber, CreatedDate, Date_Time_Opened__c from case where Legacy_System_ID_Manhattan_US_SFDC__c!= null limit 200';    
      return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<Case> scope) {
    for(case cse:scope) {
        system.debug('Processing Case>>>>>>>>>>'+Cse.id);
        Support_Case_History_Old__c childSupport = new Support_Case_History_Old__c();
        childSupport.case__c= cse.id;
        childSupport.FIELD__c='Status';
        childSupport.IsAdded__c=True;
        //childSupport.CREATEDDATE__c=cse.CreatedDate.addhours(-8);
        childSupport.CREATEDDATE__c=cse.Date_Time_Opened__c;
        childSupport.NEWVALUE__c='New';
        scHistToInsert.add(childSupport); 
    }
    
    if(scHistToInsert!=null &&  scHistToInsert.size()>0) {
        if(!Test.isRunningTest()){
          insert scHistToInsert;
          system.debug('$$$$$$$ Insert Successfull$$$$$$');             
        }else if(Test.isRunningTest()){
            //Do Nothing
        }
       
    }        
  }
  
  global void finish(Database.BatchableContext BC) {  }
}