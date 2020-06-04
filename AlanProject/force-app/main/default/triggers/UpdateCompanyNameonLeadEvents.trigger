trigger UpdateCompanyNameonLeadEvents on Lead (before update) {
    Map<Id, Lead> ldMap = new Map<Id, Lead>();
    for(Lead ld: trigger.new){
        if(ld.Company != trigger.oldMap.get(ld.Id).Company){
            ldMap.put(ld.Id,ld);
        }
    }
    
    List<Event> eventList = [Select Id, Company_Name__c, WhoId from Event where WhoId IN: ldMap.KeySet()]; 
    
    if(!eventList.isEmpty()){
        List<Event> updateEtList = new List<Event>();
        for(event et: eventList){
            et.Company_Name__c = ldMap.get(et.WhoId).Company;
            updateEtList.add(et);
        }
        update updateEtList;
    }
}