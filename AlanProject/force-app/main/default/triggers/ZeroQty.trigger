trigger ZeroQty on OpportunityLineItem (before insert, after insert, before update) {
    if(trigger.isBefore){
        for (OpportunityLineItem oli : trigger.new) {
            if(oli.quantity == 0){
                oli.quantity= 1;
                system.debug('-------oli-------' + oli.Name);
                system.debug(oli.Unitprice + '-------oli-------' + oli.Totalprice);
                if(oli.Unitprice != Null && oli.Unitprice != 0) oli.Unitprice= 0;
            }else if(oli.quantity<0){
            system.debug('-------oli-------' + oli.quantity);
            system.debug('-------oli-------' + oli.UnitPrice);
                oli.quantity = -1*oli.quantity;
                if(oli.UnitPrice!=Null) oli.UnitPrice = -1*oli.UnitPrice;
            }
        }
    }else{
        for (OpportunityLineItem oli : trigger.new) {
            system.debug('-------oli-------' + oli.Name);
        }
    }
}