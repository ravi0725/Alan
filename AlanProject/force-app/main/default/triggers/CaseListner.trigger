trigger CaseListner on Case (before insert,before update,before delete,after insert,after update,after delete){
    if(userinfo.getName() != 'Data Administrator'){
        
        if(Trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
            CaseHandler.TAPCaseConfig(Trigger.new);
        }
        
        if(Trigger.isBefore && trigger.isUpdate){
            CaseHandler.validateOpenActivityRelatedToCase(Trigger.new);
        }
        
        //Added by Sowmya for Case SLA RE&WS
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RE&WS - Support').getRecordTypeId();
        List<Case> newCaseLst = new List<Case>();
        if(Trigger.isBefore && Trigger.isInsert)
        {
            for(Case c : Trigger.new){
                if(c.RecordTypeId == caseRecordTypeId)
                    newCaseLst.add(c);       
            }
            CaseUtility.newCaseSLA(newCaseLst);    
        }
        List<Case> updateCaseLst = new List<Case>();
        if(Trigger.isBefore && Trigger.isUpdate){
            for(Case c : Trigger.new){
                if(c.RecordTypeId == caseRecordTypeId && c.Status != Trigger.oldMap.get(c.Id).Status)
                    updateCaseLst.add(c);       
            }
            CaseUtility.updateCaseSLA(updateCaseLst);    
        }
    
        //End -- Added by Sowmya for Case SLA RE&WS
    
        
        // Update RE&WS case to remove Brackets from JIRA
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
            
            for(Case c : Trigger.new){
                
                if(c.Record_Type_Name__c == 'RE&WS - Support' && c.Version_To_Be_Fixed_In__c!= null && c.Version_To_Be_Fixed_In__c != '' && c.Version_To_Be_Fixed_In__c.contains('[')){
                    c.Version_To_Be_Fixed_In__c = c.Version_To_Be_Fixed_In__c.remove('[');
                }
                if(c.Record_Type_Name__c == 'RE&WS - Support' && c.Version_To_Be_Fixed_In__c!= null && c.Version_To_Be_Fixed_In__c != '' && c.Version_To_Be_Fixed_In__c.contains(']')){
                    c.Version_To_Be_Fixed_In__c = c.Version_To_Be_Fixed_In__c.remove(']');
                }
            }
            
            
        }
        
        //MEP NA 
        if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
            CaseHandler.MEPNACaseConfig(trigger.new);
        }
        
        //MEP NA 
        if(trigger.isAfter && trigger.isUpdate){
            CaseHandler.updateContactLastSurveyDate(trigger.new , trigger.oldMap);
        }
        
        // Update JIRA ticket from Salesforce RE&WS Case
        if(Trigger.isAfter && Trigger.isUpdate){
            JIRASycnOnCaseUpdate.updateJIRATicket(Trigger.new, Trigger.oldmap);
        }
        
        boolean gccmFlag = false;
        if(!trigger.isDelete){
            for(Case cs : trigger.new){
                if(cs.Record_Type_Name__c == Label.GCCM_Support_Issue_Record_Type || 
                    cs.Record_Type_Name__c == Label.GCCM_Support_Case_Record_Type){
                        gccmFlag = true;
                    system.debug('---------cs--------' + cs);
                }
            }
        }else if(trigger.isDelete){
            for(Case cs : trigger.old){
                if(cs.Record_Type_Name__c == Label.GCCM_Support_Issue_Record_Type || 
                    cs.Record_Type_Name__c == Label.GCCM_Support_Case_Record_Type)
                        gccmFlag = true;
            }
        }
        
        //Added by Suresh Babu Murugan
        //Update GCCM Case with Account's Sales Ops Comments
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
            for(Case cs: Trigger.new){
                if(cs.AccountId != null && cs.Record_Type_Name__c == Label.GCCM_Support_Case_Record_Type){
                    Account acc = [SELECT Id, Name, Sales_Ops_Comments__c FROM Account WHERE Id =: cs.AccountId Limit 1];
                    if(acc.Sales_Ops_Comments__c != null){
                        cs.Sales_Ops_Comments__c = acc.Sales_Ops_Comments__c;
                    }
                }
            }
        }
        //End
        
        String usrProfileName;
         
        if(trigger.isBefore && trigger.isInsert){
            CaseHandler.configCase(trigger.new);
            CaseHandler.populateProductCaseGCCM(trigger.New,new Map<Id,Case>());
            CaseHandler.TFSIntegrationCheck(trigger.new);
        }
        
        if(trigger.isBefore && trigger.isUpdate){
            CaseHandler.setStatusReason(trigger.New,trigger.OldMap);
            CaseHandler.clearFields(trigger.New);
            CaseHandler.Case24HoursNotification(trigger.New,trigger.OldMap);
            CaseHandler.populateProductCaseGCCM(trigger.New,trigger.OldMap);
            CaseHandler.TFSIntegrationCheck(trigger.new);
        }
        if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
            Map<Id,Case> newCaseMap = new Map<Id,Case>();
            Map<Id,Case> oldCaseMap = new Map<Id,Case>();
            for(Case cs : trigger.new){
                if(trigger.isUpdate)system.debug(cs.To_Address__c + '---------------idList---------'+trigger.oldMap.get(cs.Id).To_Address__c);
                if(cs.Record_Type_Name__c == Label.GCCM_Support_Issue_Record_Type/* || 
                   cs.Record_Type_Name__c == Label.RE_WS_Proliance_Support_Issue_Record_Type*/){
                    newCaseMap.put(cs.Id,cs);
                    if(trigger.isUpdate)oldCaseMap.put(cs.Id,trigger.oldMap.get(cs.Id));    
                }
                    
            }
            system.debug(caseHandler.launchControl.get('validateBeforeTFSCallout') + '---------------newCaseMap---------'+newCaseMap);
            if(newCaseMap.size() > 0){
                system.debug( '---------------newCaseMap---------'+newCaseMap);
                CaseHandler.validateBeforeTFSCallout(newCaseMap.values(),newCaseMap,oldCaseMap,trigger.isInsert,trigger.isUpdate);
            }
        }
        
        if(trigger.isAfter && trigger.isUpdate){
            CaseHandler.notifyCaseOwnersForPlanningPriority(trigger.new,trigger.oldMap);
        }
        
        
        if(trigger.isAfter && trigger.isInsert){
            CaseHandler.notifyCaseOwnersForPlanningPriority(trigger.new,new Map<Id,Case>());
            CaseHandler.attachIssueToCase(trigger.new);
            CaseHandler.copyChatTranscriptsToCloneCase(trigger.new);
        }
        if((trigger.isInsert || trigger.isUpdate) && trigger.isAfter){
            caseHandler.createTFSTrackingHistory(trigger.oldMap, trigger.new,trigger.isInsert);
        }
        if(trigger.isAfter && (trigger.isInsert || trigger.isDelete || trigger.isUpdate)){
            CaseHandler.CaseCountOnIssue(trigger.isDelete ? trigger.old : trigger.new,trigger.isInsert ? new Map<Id,Case>() : trigger.oldMap);
        }
    }else{
        //MEP NA 
        if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
            CaseHandler.removeCreditCardNumber(trigger.new);
            CaseHandler.MEPNACaseConfig(trigger.new);
        }
    }
}