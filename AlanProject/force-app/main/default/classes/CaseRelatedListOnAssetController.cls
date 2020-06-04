/*****************************************************************************************
    Name    :     CaseRelatedListOnAssetController
    Desc    :     Used for implementing cusotm visualforce page logic for case related list on Asset.  
                  
    Project ITEM: ITEM-008129                            
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Sagar Mehta           01/24/2014          Created
******************************************************************************************/
public class CaseRelatedListOnAssetController{
    public String assetId{get;set;}
    public String accountId{get;set;}
    
    public CaseRelatedListOnAssetController(ApexPages.StandardController controller){
        //gets the record Id of the account record.
        assetId = (String)controller.getRecord().Id;
    }
    
    /**
     *Return Type: getRelatedCases
     *Return Type: List<Opportunity>
     *Purpose: This method used to get the related Cases to an Asset record.     
     **/ 
    public List<Case> getRelatedCases(){
        List<Case> caseList = new List<Case>();
        try{
            List<Multiple_Assets_Case_Junction__c> assetList = new List<Multiple_Assets_Case_Junction__c>();
            assetList = [Select Id, Case__c, Asset__r.AccountId from Multiple_Assets_Case_Junction__c where Asset__c =: assetId];
            //query all the case records matching for the asset record.
            if(assetList.size() > 0){
                accountId = assetList.get(0).Asset__r.AccountId;
                caseList = [SELECT Id, CaseNumber, ContactId, Contact.Name, Subject, Priority, Status, CreatedDate, 
                OwnerId, Owner.Name FROM Case where Id =: assetList.get(0).Case__c];                                                                                                         
            }            
        }catch(Exception e){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING, e.getMessage());
            ApexPages.addMessage(msg);
        }                    
        return caseList;        
    }
}