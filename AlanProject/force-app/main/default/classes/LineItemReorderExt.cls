/**
 * Company     : Trimble Software Technology Pvt Ltd.,
 * Description : Controller Class For LineItemReorder Visualforce Page
 * History     :  

 * [24.08.2014] Prince Leo  Created
 */
public with sharing class LineItemReorderExt{
    public boolean successFlag{get;set;}
    public Id QuoteID{get;set;}
    Map<Id,Apttus_Proposal__Proposal_Line_Item__c> proposalMap;
    public List<Apttus_Proposal__Proposal_Line_Item__c> proposalList{get;set;}
    Set<Decimal> ReOrder = new Set<Decimal>();
    public String proposalLineItemIds{get;set;}
    public LineItemReorderExt(ApexPages.StandardController controller) {
        successFlag = true;
        QuoteID = System.currentPageReference().getParameters().get('id');
        proposalLineItemIds = '';
        getProposalLineItemList();
    }
    
    public void getProposalLineItemList(){
        proposalMap = new Map<Id,Apttus_Proposal__Proposal_Line_Item__c>();
        proposalList = [select id,Name,Sort_Order__c,Product_or_Option_name__c,Apttus_QPConfig__ChargeType__c ,Apttus_Proposal__Product__r.Name,Apttus_QPConfig__LineNumber__c,Apttus_QPConfig__ItemSequence__c,Apttus_Proposal__Product__c,
                            Reorder_Number__c,Apttus_QPConfig__DerivedFromId__r.Apttus_Config2__LineNumber__c,Apttus_QPConfig__DerivedFromId__r.Apttus_Config2__PrimaryLineNumber__c,Apttus_QPConfig__PrimaryLineNumber__c from Apttus_Proposal__Proposal_Line_Item__c where 
                                Apttus_Proposal__Proposal__c=:QuoteID order by Sort_Order__c]; /*AND Apttus_QPConfig__LineType__c='Product/Service'AND Apttus_QPConfig__ChargeType__c='Standard Price' and 
                                ((Apttus_QPConfig__ChargeType__c = 'Maintenance Fee' AND Apttus_QPConfig__LineType__c = 'Product/Service' AND 
                                    Asset_Oracle_ID__c!=null) OR (Apttus_QPConfig__LineType__c != 'Option' AND Apttus_QPConfig__ChargeType__c != 'Maintenance Fee') 
                                    OR (Apttus_QPConfig__LineType__c = 'Option' AND (Apttus_QPConfig__OptionId__r.Contract_Item_Type_Code__c = 'WARRANTY' OR 
                                    Apttus_QPConfig__OptionId__r.Contract_Item_Type_Code__c = 'SERVICE'))) order by Sort_Order__c];*/
        
        /*select id,Name,Sort_Order__c,Product_or_Option_name__c,Apttus_QPConfig__LineNumber__c,Apttus_QPConfig__ItemSequence__c,Apttus_Proposal__Product__c,
                            Reorder_Number__c,Apttus_QPConfig__DerivedFromId__r.Apttus_Config2__LineNumber__c,Apttus_QPConfig__DerivedFromId__r.Apttus_Config2__PrimaryLineNumber__c,Apttus_QPConfig__PrimaryLineNumber__c from Apttus_Proposal__Proposal_Line_Item__c where 
                                Apttus_Proposal__Proposal__c=:QuoteID AND Apttus_QPConfig__LineType__c='Product/Service'AND Apttus_QPConfig__ChargeType__c='Standard Price' order by Sort_Order__c*/
        for(Apttus_Proposal__Proposal_Line_Item__c temp : proposalList){
            proposalMap.put(temp.Id,temp);
        }
    }
    
    public void updateSortOrder(){
        system.debug('-------------proposalLineItemIds---------------' + proposalLineItemIds);
        Integer i = 1;
        boolean flag = false;
        try{
            for(String str : proposalLineItemIds.split(',')){
                if(str != '' && str != null){
                    system.debug(str + '-------------proposalMap.get(str)---------------' + proposalMap.get(str));
                    if(proposalMap.get(str) != null){
                        proposalMap.get(str).Sort_Order__c = i;
                        system.debug('-------------proposalMap.get(str).Sort_Order__c---------------' + proposalMap.get(str).Sort_Order__c);
                        i++;
                        flag = true;
                    }
                }
            }
            if(flag){
                system.debug('-------------proposalMap---------------' + proposalMap);
                update proposalMap.values();
            }
            
            successFlag = true;
        }catch(Exception ex){
            apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.error,'Some Exception occurred while Processing. Please contact to your Administrator.' + ex.getMessage());
            apexpages.addmessage(msg);
            successFlag = false;
        }
    }
    
    public boolean validateSortOrderForDuplicate(){
        set<decimal> tempSet = new set<decimal>();
        for(Apttus_Proposal__Proposal_Line_Item__c temp : proposalMap.values()){
            if(tempSet.contains(temp.Apttus_QPConfig__ItemSequence__c) && temp.Apttus_QPConfig__ItemSequence__c!= null){
                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, 'Sort Order number is already assigned to other Line Item.'));
                return false;
            }
            tempSet.add(temp.Apttus_QPConfig__ItemSequence__c);
        }
        return true;
    }
    
    Public PageReference BackToQuote(){
        PageReference PrevPg = new PageReference('/'+QuoteID);
        PrevPg.setRedirect(true);
        return PrevPg;
    }
}