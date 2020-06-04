/************************************************************************************
* Name          :    CompetitiorAssetClass
* Description   :    to display custom CompetitiorAsset related list
* Author        :    Chandrakant

Modification Log
----------------
Date             Developer                Comments
------------------------------------------------------------------------------------------
                   Chandrakant      Created  07/1/2014
******************************************************************************************/
public class competitorReleatedlistController{
    public String oppId{get;set;}
    public Integer totalSize{get;set;}
    public Integer remainder{get;set;}
    public boolean loadMore{get;set;}
    public String compassetid{get; set;}
    public String compassetdelid{get; set;}
    public competitorReleatedlistController(ApexPages.StandardController controller){
        remainder = 0;      
        loadMore = false;
        //gets the record Id of the account record.
        oppId = (String)controller.getRecord().Id;
    }
    
   /**
     *Return Type: getRelatedCompetitor
     *Return Type: List<Opportunity>
     *Purpose: This method used to get the first 10 opportunities related to an account record.
     *It is also used to rerender the list when the user clicks on link Show (n) more >> in UI.
     **/ 
    public List<Competitor__c> getRelatedCompetitor(){
        List<Competitor__c> CompList = new List<Competitor__c>();
        List<Competitor__c> CompetitorList = new List<Competitor__c>();
        try{
          //query all the opportunity records matching for the account record.
          CompList = [SELECT Id, Comments__c,CompetitorName__c,CompetitorName__r.Name,Competitor_Product__c,Competitor_Product__r.Name,Competitor_Type__c,Opportunity__c,Strengths__c,Weaknesses__c  FROM Competitor__c
                           where Opportunity__c =: oppId order by CompetitorName__r.Name];                                                                                          
        }catch(Exception e){
          ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING, e.getMessage());
            ApexPages.addMessage(msg);
        }                    
        return CompList;        
    }        
    
    /**
     *Return Type: getCompetitorList
     *Return Type: List<Opportunity>
     *Purpose: This method used to get all the opportunities related to an account record.     
     **/ 
    public List<Competitor__c> getCompetitorList(){       
        List<Competitor__c> CompList = new List<Competitor__c>();
        try{
          //null check for account Id
          if(Apexpages.currentpage().getparameters().get('id') != null){
             oppId = Apexpages.currentpage().getparameters().get('id');
             CompList = [SELECT Id, Comments__c,CompetitorName__c,CompetitorName__r.Name,Competitor_Product__c,Competitor_Product__r.Name,Competitor_Type__c,Opportunity__c,Strengths__c,Weaknesses__c  FROM Competitor__c
                           where Opportunity__c =: oppId order by CompetitorName__r.Name];                                                                                
          }
          if(CompList.size() <= 0){
              ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING, 'No records found.');
              ApexPages.addMessage(msg);
          }
        }catch(Exception e){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING, e.getMessage());
            ApexPages.addMessage(msg);
        }                 
        return CompList ;        
    }
    
    public PageReference EditCompetitorAsset(){
       return new PageReference('/apex/EditCompetitorPage?id='+compassetid);
    }
        
    /**public PageReference redirectToAccount(){
       return new PageReference('/'+accId);
    }
   
    public PageReference redirectToNew(){
       PageReference pr = Page.competitorPage;
       pr.getParameters().put('id', oppId);
       return pr;
    }**/
}