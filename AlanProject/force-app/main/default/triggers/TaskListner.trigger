trigger TaskListner on Task (before insert, before update, after insert, after update) {
    if(userinfo.getName() != 'Data Administrator'){
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
            TaskHandler.updateTaskMobileNumber(Trigger.new);
            
            if(Trigger.isUpdate){
                TaskHandler.updateRelatedToFields(Trigger.new, Trigger.oldMap);
            }
        }
        
        if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
            TaskHandler.updateLastActivityOwnerOnAccount(Trigger.new, Trigger.oldMap);
        }
    }
}