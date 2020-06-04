/*****************************************************************************************
    Name         : CartViewRelatedListController
    Desc         : Used for displaying approval request related to a Quote/Proposal record in its related list of Approval Requests.
    Project Item : ITEM-00816
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Sagar Mehta          01/15/2014          Created
******************************************************************************************/
public class CartViewRelatedListController{

    public String selectedId{get;set;}
    public String configStatus{get;set;}
    public Integer totalSize{get;set;}
    public Integer remainder{get;set;}
    public boolean loadMore{get;set;}
    public String quoteId{get;set;}
    public String productConfigId{get;set;}
    public clsConfigWrapper configWrapper{get;set;}
    public Apttus_Proposal__Proposal__c proposal{get;set;}
    public Apttus_Config2__ProductConfiguration__c productConfig{get;set;}
    public List<Apttus_Approval__Approval_Request__c> approvalRequestList{get;set;}
    public List<Apttus_Config2__ProductConfiguration__c> productConfigList{get;set;}
    public List<Apttus_Approval__Approval_Request__c> approvalRequestRelatedList{get;set;}
    public String uploadType{get; set;}
    /**
     * Class Constructor
     * @param stdController the standard controller
     */
    public CartViewRelatedListController (ApexPages.StandardController stdController) {

        loadMore = false;

        proposal = (Apttus_Proposal__Proposal__c)stdController.getRecord();
        quoteId = proposal.Id;
        productConfigList = new List<Apttus_Config2__ProductConfiguration__c>();

        productConfigList = [SELECT Id, Name, Apttus_QPConfig__Proposald__c, Apttus_CQApprov__Approval_Status__c, (SELECT Name FROM Apttus_CQApprov__Approval_Requests__r) FROM Apttus_Config2__ProductConfiguration__c WHERE Apttus_QPConfig__Proposald__c =: proposal.Id ORDER BY Apttus_Config2__VersionNumber__c DESC];

        approvalRequestList = new List<Apttus_Approval__Approval_Request__c>();

        if(productConfigList.size() > 0){
            productConfig = new Apttus_Config2__ProductConfiguration__c();
            productConfig = productConfigList.get(0);
            for(Apttus_Config2__ProductConfiguration__c pconfig: productConfigList){
                if(pconfig.Apttus_CQApprov__Approval_Requests__r.size() > 0){
                    productConfig = pconfig;
                    break;
                }
            }
            productConfigId = productConfig.Id;
            configStatus = productConfig.Apttus_CQApprov__Approval_Status__c;
            clsConfigWrapper wrapper = new clsConfigWrapper();
            wrapper.checked = false;
            wrapper.configId = productConfig.Id;
            wrapper.config = productConfig;
            configWrapper = wrapper;

            fetchApprovalRequest();
            if(approvalRequestList.size() <= 0){
               //ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, Label.Quote);
               //ApexPages.addMessage(msg);
            }
        }else{
            //ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, Label.Quote);
            //ApexPages.addMessage(msg);
        }
    }

    public PageReference validateChecks(){
        if(selectedId == ''){
           ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Quote_Select_Items);
           ApexPages.addMessage(msg);
           return null;
        }else{
           return new PageReference('https://apttus-cqapprov.'+Label.Host_URL+'/apex/cartapprovals?quoteId='+proposal.Id+'&returnButtonLabel=Return+to+Quote&action=cancel&approvalType=cart&lineItemIds=&includeHeaderApprovals=true');
        }
        return null;
    }

    public void loadMoreApprovalRequest(){
       loadMore = true;
       fetchApprovalRequest();
    }

    private void fetchApprovalRequest(){
       approvalRequestList = new List<Apttus_Approval__Approval_Request__c>();
       List<Apttus_Approval__Approval_Request__c> reqList = new List<Apttus_Approval__Approval_Request__c>();
       reqList = [Select Id, Apttus_Approval__Step_Name__c, Apttus_Approval__Action__c, Apttus_Approval__StepSequence__c,
                  Apttus_Approval__Assigned_To_Name__c, Apttus_Approval__Approval_Status__c, Apttus_Approval__Action_Approve_Id__c,
                  Apttus_Approval__SubmissionComment1__c,Apttus_Approval__Approver_Comments__c, Assigned_To_Queue_Members__c from Apttus_Approval__Approval_Request__c where Apttus_CQApprov__CartId__c =: productConfigId order by Apttus_Approval__StepSequence__c];
       //if load more link is clicked then additional opportunity records will be displayed
       if(!loadMore){
          if(reqList.size() > 0){
             totalSize = reqList.size();
             Integer counter = 0;
             //initially only 3 records will be displayed
             if(totalSize >= 3){
                counter = 3;
             }else{
                counter = totalSize;
             }
             //if there are more than records to be displayed, initally only 10 records would be displayed.
             for(Integer i = 0; i < counter; i++){
               approvalRequestList.add(reqList.get(i));
             }
             if(totalSize > 3){
               remainder = totalSize - 3;
             }
          }
       }else{
          remainder = 0;
          approvalRequestList = reqList;
       }
    }

    /**
     *Return Type: getApprovaHistoryList
     *Return Type: List<Apttus_Approval__Approval_Request__c>
     *Purpose: This method used to get all the approval request related to an quote record.
     **/
    public void retrieveApprovaHistoryList(){
        approvalRequestRelatedList = new List<Apttus_Approval__Approval_Request__c>();
        try{
            if(Apexpages.currentpage().getparameters().get('id') != null){
               String qId = Apexpages.currentpage().getparameters().get('id');
               productConfigList = new List<Apttus_Config2__ProductConfiguration__c>();

               productConfigList = [Select Id, Name, Apttus_QPConfig__Proposald__c, Apttus_CQApprov__Approval_Status__c From
               Apttus_Config2__ProductConfiguration__c where Apttus_QPConfig__Proposald__c =: proposal.Id order by Apttus_Config2__VersionNumber__c desc];

               if(productConfigList.size() > 0){
                  productConfig = new Apttus_Config2__ProductConfiguration__c();
                  productConfig = productConfigList.get(0);
                  productConfigId = productConfig.Id;
                  approvalRequestRelatedList = [Select Id, Apttus_Approval__Step_Name__c, Apttus_Approval__Action__c, Apttus_Approval__StepSequence__c,
                     Apttus_Approval__Assigned_To_Name__c, Apttus_Approval__Approval_Status__c, Apttus_Approval__Action_Approve_Id__c,
                     Apttus_Approval__Approver_Comments__c, Assigned_To_Queue_Members__c from Apttus_Approval__Approval_Request__c where Apttus_CQApprov__CartId__c =: productConfigId
                     order by Apttus_Approval__StepSequence__c];
               }
            }
        }catch(Exception e){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING, e.getMessage());
            ApexPages.addMessage(msg);
        }
    }

    public class clsConfigWrapper{
        public boolean checked{get;set;}
        public Id configId{get;set;}
        public Apttus_Config2__ProductConfiguration__c config{get;set;}
    }

    public PageReference  viewattach(){
      PageReference ref =  new PageReference('/apex/ApptusApprovalPage?id='+uploadType);
      return ref;
    }
}