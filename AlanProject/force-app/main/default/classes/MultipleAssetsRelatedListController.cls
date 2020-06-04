/*****************************************************************************************
    Name    :     MultipleAssetsRelatedListController
    Desc    :     Used for implementing cusotm visualforce page logic for competitor assets related list on Account and Lead.  
                  The new button in Competitor Assets related list on Account and lead is overridden here and the functionality is implemented in this class                
    Project ITEM: ITEM-00703, ITEM-00779                            
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Sagar Mehta           10/27/2013          Created
******************************************************************************************/
public class MultipleAssetsRelatedListController{
    public String caseId{get;set;}
    
    public MultipleAssetsRelatedListController(ApexPages.StandardController controller){
        //gets the record Id of the account record.
        caseId = (String)controller.getRecord().Id;
    }
    
    /**
     *Return Type: getRelatedOpportunities
     *Return Type: List<Opportunity>
     *Purpose: This method used to get the first 10 opportunities related to an account record.
     *It is also used to rerender the list when the user clicks on link Show (n) more >> in UI.
     **/ 
    public List<Multiple_Assets_Case_Junction__c> getRelatedCompetitorAsset(){
        List<Multiple_Assets_Case_Junction__c> compAssetList = new List<Multiple_Assets_Case_Junction__c>();
        try{
            //query all the opportunity records matching for the account record.
            compAssetList = [SELECT Id, Asset__c, Asset__r.Name, Case__c FROM Multiple_Assets_Case_Junction__c where Case__c =: caseId];                                                                                          
        }catch(Exception e){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING, e.getMessage());
            ApexPages.addMessage(msg);
        }                    
        return compAssetList;        
    }
}