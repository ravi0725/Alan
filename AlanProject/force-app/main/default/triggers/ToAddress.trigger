Trigger ToAddress on EmailMessage (before insert, before update){
    system.debug('-----------------ToAddress-------------' );
    if(userinfo.getName() != 'Data Administrator'){
        if(trigger.isInsert && trigger.isBefore){
            system.debug('-----------------ToAddress-------------' );
            EmailMessageHandler.ResetCase24HoursNotification(trigger.new);
            EmailMessageHandler.setToAddress(trigger.new);
        }
    }else{
        if(trigger.isUpdate && trigger.isBefore){
            EmailMessageHandler.removeCreditCardNumber(trigger.new);
        }
    }
}