/*****************************************************************************************
Name        : OpportunityLineItemListner
Desc        : Used to handel Opportunity Line Item trigger code
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
Ankur Patel          21/10/2016          Created
******************************************************************************************/

trigger OpportunityLineItemListner on OpportunityLineItem (before insert,before Update, before delete, after insert,after update,after delete) {
    if(CreateRenewalOpportunityFromEBS.runOpportunityLineItemTrigger){
        //Execute below code when Line Items gets created irrespective of Line item type(Renewal or New Buy)
        if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate || trigger.isDelete)){
            if(OpportunityLineItemHelper.launchControl.get('populateSerialNumbersOnOpportunity') < 1){
                OpportunityLineItemHelper.populateSerialNumbersOnOpportunity((trigger.isDelete ? trigger.old : trigger.new));
                OpportunityLineItemHelper.launchControl.put('populateSerialNumbersOnOpportunity',OpportunityLineItemHelper.launchControl.get('populateSerialNumbersOnOpportunity') + 1);
            }
        }
    }
}