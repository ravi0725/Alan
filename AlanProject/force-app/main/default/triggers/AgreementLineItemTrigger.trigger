trigger AgreementLineItemTrigger on Apttus__AgreementLineItem__c (before insert, before update) {

    for (Apttus__AgreementLineItem__c lineItem : Trigger.new) {
        lineItem.Product_Type_Text__c = lineItem.Product_Type__c;
        lineItem.Product_Family_Text__c = lineItem.Product_Family__c;
    }
    

}