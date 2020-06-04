/*****************************************************************************************
Name    : OrderHelper
Modification Log : 
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
Ankur Patel       07/13/2019          Created
******************************************************************************************/
public class OrderHelper {
    //Create MEPNA Customer Support case in when Order is booked and having atlease on Order line item with business area Estimation
    public static void validateMEPNAEstimatingBusinessArea(Boolean bIsInsert, Boolean bIsUpdate, List<Order__c> lstNewOrders, Map<Id, Order__c> mapOldOrders, Map<Id, Order__c> mapNewOrders){
        system.debug(' ==== IN ORDER TRIGGER ===== ');
        
        Map<Id, Id> mapOrderProposalIds = new Map<Id, Id>();
        for(Order__c oOrder: lstNewOrders) {
            system.debug('===Trigger.isInsert' + Trigger.isInsert + '===Trigger.isUpdate====' + Trigger.isUpdate);
            system.debug('=====oOrder.Order_Status__c=====' + oOrder.Order_Status__c);
            if((bIsInsert && oOrder.Order_Status__c == 'BOOKED') || 
               (bIsUpdate ? (mapOldOrders.get(oOrder.Id).Order_Status__c != oOrder.Order_Status__c && oOrder.Order_Status__c == 'BOOKED') : false )) {
                mapOrderProposalIds.put(oOrder.Related_Quote_Proposal__c, oOrder.Id);
            }
        }

        if(mapOrderProposalIds.size() > 0){       
            system.debug('=====mapOrderProposalIds====' + mapOrderProposalIds);
            List<Group> lstOwnerIdFromQueue = new List<Group>();
            lstOwnerIdFromQueue = [SELECT ID FROM Group WHERE Type = 'Queue' AND Name = 'MEPNA - Order Ops Queue'];
            
            system.debug('=====lstOwnerIdFromQueue====' + lstOwnerIdFromQueue); 
            List<Case> lstOrderPropInsertCases = new List<Case>();
            for(Apttus_Proposal__Proposal__c oProposal: [SELECT Id, Name,Apttus_Proposal__Account__c,Apttus_Proposal__Primary_Contact__c, (SELECT Id,Apttus_Proposal__Product__r.Business_Area__c FROM R00N70000001yUfBEAU WHERE Apttus_Proposal__Product__r.Business_Area__c = 'MEP ESTIMATING' AND Apttus_Proposal__Product__r.Type__c != 'ESTIMATING TRAINING') FROM Apttus_Proposal__Proposal__c WHERE ID IN: mapOrderProposalIds.keyset()]) {
                system.debug('=====oProposal.Apttus_Proposal__R00N70000001yUfBEAU__r.size()====' + oProposal.Apttus_Proposal__R00N70000001yUfBEAU__r.size());
                if(oProposal.Apttus_Proposal__R00N70000001yUfBEAU__r.size() > 0)
                    lstOrderPropInsertCases.add(caseHandler.createCaseAfterOpportunityOrderProcess(oProposal.Apttus_Proposal__Account__c, oProposal.Apttus_Proposal__Primary_Contact__c, 'License Fulfillment', lstOwnerIdFromQueue, mapNewOrders.get(mapOrderProposalIds.get(oProposal.ID)).Oracle_Order_Number__c, oProposal.Name ));
            }
            
            system.debug('=====lstOrderPropInsertCases====' + lstOrderPropInsertCases);
            insert lstOrderPropInsertCases;
        }
    }
}