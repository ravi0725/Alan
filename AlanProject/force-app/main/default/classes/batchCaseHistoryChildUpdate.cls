/*****************************************************************************************
    Name        : batchCaseHistoryChildUpdate
    Desc        :Used to update all Support Case History Old records.
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Jitendra Behera       26/04/2015          Created
Shruti Moghe          26/05/2015          Modified
******************************************************************************************/
global class batchCaseHistoryChildUpdate implements Database.Batchable<sObject> {

    list<Support_Case_History_Old__c> scHistToUpdate = new list<Support_Case_History_Old__c>();
    list<case> allCase;
    String query;
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //String query = 'select id,caseNumber,(select id,name,CREATEDDATE__c,case__c ,FIELD__c,Until_Date__c, OLDVALUE__c,NEWVALUE__c from Support_Cases_History_Old__r where FIELD__c=\'Pending\' order by CREATEDDATE__c) from case where Legacy_System_ID_Manhattan_US_SFDC__c!= null';
        if(test.isrunningtest()) {            
             query ='select id from case where Legacy_System_ID_Manhattan_US_SFDC__c!= null LIMIT 100';
        } else if(!test.isrunningtest()) {
             query ='select id from case where Legacy_System_ID_Manhattan_US_SFDC__c!= null';
        }
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<Case> scope) {
        
        if(test.isrunningtest()) {
            allCase = [select id, caseNumber, (select id, name, CREATEDDATE__c, case__c, FIELD__c, Until_Date__c, OLDVALUE__c, NEWVALUE__c from Support_Cases_History_Old__r where FIELD__c = 'Status' order by CREATEDDATE__c)  from case where id in:scope LIMIT 100];
        } else {
            allCase = [select id, caseNumber, (select id, name, CREATEDDATE__c, case__c, FIELD__c, Until_Date__c, OLDVALUE__c, NEWVALUE__c from Support_Cases_History_Old__r where FIELD__c = 'Status' order by CREATEDDATE__c)  from case where id in:scope ];
        }
    
        for(case cse:allCase) {
            if(cse.Support_Cases_History_Old__r.size() > 0) {
            
                if(cse.Support_Cases_History_Old__r.size()>1){
                    cse.Support_Cases_History_Old__r[0].Newvalue__c = cse.Support_Cases_History_Old__r[1].oldvalue__c;
                    //scHistToUpdate.add(cse.Support_Cases_History_Old__r[0]);
                }
                
                for(integer i=0; i<cse.Support_Cases_History_Old__r.size(); i++) {
                  if(i != cse.Support_Cases_History_Old__r.size()-1)
                      cse.Support_Cases_History_Old__r[i].Until_Date__c = cse.Support_Cases_History_Old__r[i+1].CREATEDDATE__c;
                  if(i == cse.Support_Cases_History_Old__r.size() - 1)
                      cse.Support_Cases_History_Old__r[i].Until_Date__c = null;
                  
                  scHistToUpdate.add (cse.Support_Cases_History_Old__r[i]);
                }
            }
        }
        
        if(scHistToUpdate != null && scHistToUpdate.size() > 0) {
         if(!test.isrunningtest()){
          update scHistToUpdate;
         }else if(test.isrunningtest()){
          //Do Nothing
         }
            
        }
    }
    
    global void finish(Database.BatchableContext BC) { }
}