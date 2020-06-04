/************************************************************************************
* Name          :    CartViewApprovalHistoryController
* Description   :    Displays all the approval request history related a quote record.
* Author        :    Sagar Mehta

Modification Log
-----------------------------------------------------------------------------------------
Date             Developer                Comments
------------------------------------------------------------------------------------------
02/14/2014       Sagar                     Created    
******************************************************************************************/
public class CartViewApprovalHistoryController{
    
    public String quoteId{get;set;}
    public Integer totalSize{get;set;}
    public Integer remainder{get;set;}
    public boolean loadMore{get;set;}
    //public List<Apttus_Approval__Approval_Request_History__c> historyList{get;set;}
    
    /**
     * Method name  : CartViewApprovalHistoryController
     * Description  : Constructor of the Controller class - Initializes all the variables.
     *                Populates forecast quarter data into forecast list
     * Return Type  : Void
     * Parameter    : StandardController
     **/    
    public CartViewApprovalHistoryController(ApexPages.StandardController controller){
        remainder = 0;      
        loadMore = false;    
        quoteId = controller.getRecord().Id;            
    }
    
    public List<Apttus_Approval__Approval_Request_History__c> getHistoryList(){
        List<Apttus_Approval__Approval_Request_History__c> hList = new List<Apttus_Approval__Approval_Request_History__c>();
        List<Apttus_Approval__Approval_Request_History__c> histList = new List<Apttus_Approval__Approval_Request_History__c>();
        try{
            //query all the opportunity records matching for the account record.
            hList = [Select Name, Id, Apttus_QPApprov__ProposalId__c, Apttus_Approval__Step_Name__c, Apttus_Approval__StepSequence__c, 
            Apttus_Approval__Assigned_To_Name__c, Apttus_Approval__Approver_Comments__c, Apttus_Approval__Approval_Status__c From 
            Apttus_Approval__Approval_Request_History__c where Apttus_QPApprov__ProposalId__c =: quoteId];                                                        
            //if load more link is clicked then additional opportunity records will be displayed
            if(!loadMore){
                if(hList.size() > 0){
                  totalSize = hList.size();
                  Integer counter = 0;
                  //initially only 10 records will be displayed
                  if(totalSize >= 3){
                     counter = 3;
                  }else{
                     counter = totalSize;
                  }
                  //if there are more than records to be displayed, initally only 10 records would be displayed.
                  for(Integer i = 0; i < counter; i++){
                    histList.add(hList.get(i));
                  }
                  if(totalSize > 3){
                    remainder = totalSize - 3;       
                  }
                }                 
            }else{
                remainder = 0;
                histList = hList;
            }
        }catch(Exception e){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING, e.getMessage());
            ApexPages.addMessage(msg);
        }                    
        return histList;
    }
    
    /**
     *Return Type: loadMoreHistory
     *Return Type: void
     *Purpose: This method is called from the visual force page to load more opportunities related to an account record.     
     **/
    public void loadMoreHistory(){
       getHistoryList();
    }
    
    public List<Apttus_Approval__Approval_Request_History__c> getApprovalHistoryList(){
        List<Apttus_Approval__Approval_Request_History__c> histList = new List<Apttus_Approval__Approval_Request_History__c>();
        try{
            //null check for account Id
            if(Apexpages.currentpage().getparameters().get('id') != null){
               String qId = Apexpages.currentpage().getparameters().get('id');
               //query all the opportunity records matching for the account record.
               histList = [Select Name, Id, Apttus_QPApprov__ProposalId__c, Apttus_Approval__Step_Name__c, Apttus_Approval__StepSequence__c, 
               Apttus_Approval__Assigned_To_Name__c, Apttus_Approval__Approver_Comments__c, Apttus_Approval__Approval_Status__c From 
               Apttus_Approval__Approval_Request_History__c where Apttus_QPApprov__ProposalId__c =: qId];
            }   
        }catch(Exception e){
            System.debug(e.getMessage());
        }    
        return histList;
    }
    
}