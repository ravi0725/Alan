trigger PopulateOptionNamesFromProduct on Apttus_Proposal__Proposal_Line_Item__c (after insert, after update) {
    if(RecursiveTriggerUtility.isProposalLineItemRecursive){
        Set<Id> productIdSet = new Set<Id>();
        Set<Id> productIdtoExecSet = new Set<Id>();
        Set<Id> Matches= new Set<Id>();
        List<Apttus_Proposal__Proposal_Line_Item__c> ProposalList = new List<Apttus_Proposal__Proposal_Line_Item__c>();
        List<Product2> ProdList = new List<Product2>();
        
        Map<Id,Decimal> Quantity = new Map<ID,Decimal>(); 
        
        for(Apttus_Proposal__Proposal_Line_Item__c proposal : Trigger.new){
            productIdSet.add(proposal.Apttus_Proposal__Product__c);
            Matches.add(proposal.Apttus_Proposal__Proposal__c);
        }
          ProposalList = [select id,Apttus_Proposal__Proposal__c,Apttus_QPConfig__Quantity2__c,Apttus_Proposal__Quantity__c,Apttus_QPConfig__OptionId__c from Apttus_Proposal__Proposal_Line_Item__c where Apttus_Proposal__Proposal__c in:Matches];
         
        for(Apttus_Proposal__Proposal_Line_Item__c  te : ProposalList)
        {
        if(te.Apttus_QPConfig__OptionId__c!=null) 
        Quantity.Put(te.Apttus_QPConfig__OptionId__c,te.Apttus_QPConfig__Quantity2__c);
        }
        ProdList = [Select id,Type__c,Apttus_Config2__ConfigurationType__c from Product2 where id in:productIdSet AND Type__c='Hardware' AND Apttus_Config2__ConfigurationType__c='Bundle'];
        try{    
               if(!ProdList.isEmpty()){
               for(Product2 oPrdt : ProdList){
                   productIdtoExecSet.add(oPrdt.Id);
               }
               ProcessProductOptionComponent.processProductOptionComponent(productIdtoExecSet, false,Quantity);
           }
        }catch(Exception e){
            system.debug('>>>>>Exception'+e);
        }
    }    
}