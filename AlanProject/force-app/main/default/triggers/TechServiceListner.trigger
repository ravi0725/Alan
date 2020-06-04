trigger TechServiceListner on Tech_Service__c (after insert,before update) {
	if(trigger.isInsert && trigger.isAfter){
        TechServiceHandler.attachTechServicesToCase(trigger.new);
    }
    if(trigger.isUpdate && trigger.isBefore){
        TechServiceHandler.clearFields(trigger.new);
    }
}