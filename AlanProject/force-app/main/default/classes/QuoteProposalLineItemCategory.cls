/**
* Company     : Trimble Software Technology Pvt Ltd.,
* Description : Quote/Proposal - To update Proposal_Line_Available_Items__c value for avilable Proposal Line Item. Product Item Category
to display the customer facing document section based in grouping.
* History     :  

* [12.06.2017] Srinivasan Babu  Created
* [02.08.2018] Srinivasan Babu Updated - removed SOQL filter condition for Maintenance as it fails for only SSM only items
*/
public class QuoteProposalLineItemCategory {
    public static Map<String, Integer> launchControl;
    
    // Static initialize
    static {
        resetLaunchControl();
    }
    
    // Reset Trigger control (e.g. for testing)
    public static void resetLaunchControl() {
        launchControl = new Map<String, Integer>();
        launchControl.put('proposalLineItemType', 0);
    }
    
    public static void proposalLineItemType(List<Apttus_Proposal__Proposal__c> newProposalList){
        if(launchControl.get('proposalLineItemType') < 1){
            launchControl.put('proposalLineItemType', launchControl.get('proposalLineItemType') + 1);
            
            Set<Id> setProposalIDs = new Set<Id>();
            for(Apttus_Proposal__Proposal__c proposal: newProposalList){
                setProposalIDs.add(proposal.Id);
            }
            
            Map<Id,Set<String>> mapProductItemCategory = new Map<Id,Set<String>>();
            Map<Id,Set<String>> mapProductICCType = new Map<Id,Set<String>>();
            // Query all Proposal Line Items using Proposal Id
            List<Apttus_Proposal__Proposal_Line_Item__c> lstProposalLineItems = [SELECT 
                                                                                 Id, Product_Item_Category__c,Apttus_Proposal__Product__r.Icc_Type__c, Apttus_Proposal__Proposal__c, Apttus_QPConfig__PriceListId__c,
                                                                                 Apttus_QPConfig__ChargeType__c,Product_ICC_Type__c, Apttus_QPConfig__LineType__c, Apttus_QPConfig__ClassificationHierarchy__c
                                                                                 FROM
                                                                                 Apttus_Proposal__Proposal_Line_Item__c
                                                                                 WHERE
                                                                                 Apttus_Proposal__Proposal__c IN : setProposalIDs AND 
                                                                                 Apttus_QPConfig__PriceListId__c != null AND 
                                                                                 Apttus_QPConfig__PriceListId__r.Name LIKE '%MEP NA%' AND 
                                                                                 Apttus_QPConfig__ChargeType__c != null AND 
                                                                                 Apttus_QPConfig__LineType__c != null /*AND
                                                                                 ((Apttus_QPConfig__ChargeType__c = 'Maintenance Fee' AND Apttus_QPConfig__LineType__c = 'Option') OR
                                                                                  (Apttus_QPConfig__ChargeType__c LIKE 'Standard%' AND Apttus_QPConfig__ClassificationHierarchy__c != null))*/
                                                                                ];
            system.debug('lstProposalLineItems>>>'+lstProposalLineItems+'<<set>>'+setProposalIDs);
             map<ID,Set<String>> FinalMap = new Map<ID,Set<String>>();
             Set<String>SetStr = new Set<String>();
            for(Apttus_Proposal__Proposal_Line_Item__c pLineItem: lstProposalLineItems){
            if(pLineItem.Product_Item_Category__c != Null){
            if(pLineItem.Product_ICC_Type__c =='Training - Hardware' || pLineItem.Product_ICC_Type__c=='Training - Software')
            {
             SetStr.add('Training');
            }
            else
            {
            SetStr.add(pLineItem.Product_Item_Category__c);
            }
            FinalMap.put(pLineItem.Apttus_Proposal__Proposal__c,SetStr);
            }
            }
              
              for(Apttus_Proposal__Proposal__c proposal: newProposalList){
              if(proposal.id != Null){
              String availItemCategory ='';
               if(FinalMap.get(proposal.id) != Null){
                for(String Str : FinalMap.get(proposal.id))
                {
                 availItemCategory += Str+ ';';
                }
              availItemCategory = availItemCategory.removeEnd(';');
              proposal.Proposal_Line_Available_Items__c = availItemCategory;
              }
           }
           }
           }
         }   
    
}