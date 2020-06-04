trigger createCaseHistoryForResolution on Case (after insert, after update) {
    if(userinfo.getName() != 'Data Administrator'){
        List<CaseHistory> chList = new List<CaseHistory>();
        if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
            
            for(Case cs: trigger.new){
                if(cs.Record_Type_Name__c == 'Case (Plancal Customer) Record Type'){
                    if(trigger.isInsert){
                        CaseHistory ch = new CaseHistory();
                        ch.CaseId = cs.Id;
                        ch.Field = 'Resolution__c';
                        chList.add(ch);
                    }
                    
                    if(trigger.isUpdate){
                        if(trigger.oldMap.get(cs.Id).Resolution__c != cs.Resolution__c){
                            CaseHistory ch = new CaseHistory();
                            ch.CaseId = cs.Id;
                            ch.Field = 'Resolution__c';
                            //ch.OldValue = trigger.oldMap.get(cs.Id).Reason__c;
                            //ch.NewValue = cs.Reason__c;
                            chList.add(ch);
                        }
                    }
                }
            }
            
        }
        if(chList.size() > 0) insert chList;
    }
}