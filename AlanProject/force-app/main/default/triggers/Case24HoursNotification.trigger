/*****************************************************************************************
Name    : Case24HoursNotification
Desc    : Before insert trigger to calculate the 24 hours from the date of creation of case excluding Weekends and holidays and insert the field Case24HoursTimeStamp__c

Modification Log : 
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
Ashfaq Mohammed       10/01/2013          Created
Jitendra Behera       28/04/2015          Modified  
Jitendra Behera       28/05/2015          Modified
******************************************************************************************/

trigger Case24HoursNotification on Case (before insert, before update, after insert, after update) {

    /* New Changes */
    if(userinfo.getName() != 'Data Administrator'){
        if(trigger.isAfter) {
            
            if(staticRecursiveHandler.runOnetime == true){
                staticRecursiveHandler.runOnetime = false;
                
                user user = [select id, Division__c from user where id=:userinfo.getUserid()];
                system.debug('Current User User Division>>>>>>'+user.Division__c);
                
                if(user.Division__c == 'RE&WS') {
                    
                    set<Id> CaseIdset = new set<Id>();
                    
                    for(Case objCase : trigger.new) {
                        system.debug('77772 after DML option set');
                        //Case objCaseOld;
                        //if(trigger.isUpdate) 
                        //  objCaseOld = trigger.oldMap.get(objCase.Id);
                        
                        if(trigger.isInsert 
                           //|| (trigger.isUpdate && objCaseOld.ownerID == objCase.OwnerId) 
                          ) 
                        {
                            CaseIdSet.add(objCase.Id);
                        }
                    }
                    
                    List<case> allCase = new List<case>(); 
                    //List<case> allCaseToUpdate = new List<case>();
                    
                    if(CaseIdSet!=null && CaseIdSet.size()>0) {                 
                        allCase = [select id, OwnerId from case where id in:CaseIdSet];
                    }
                    
                    system.debug('77771 after DML option set');
                    
                    for(Case objCase : allCase) {
                        Database.DMLOptions dmo = new Database.DMLOptions();
                        
                        dmo.assignmentRuleHeader.useDefaultRule = true;
                        system.debug('77773 after DML option set');
                        objCase.setOptions(dmo);
                        
                        //allCaseToUpdate.add(objCase);
                    }
                    
                    if(allCase != null && allCase.size() > 0) 
                        update allCase;
                }
            }
        }
    }
}