public class QuoteProductApprovalController{
    
    public String quoteId;
    public String cancel;
    public boolean cancelFlag{get;set;}
    public String configStatus{get;set;}
    public Apttus_Config2__ProductConfiguration__c productConfig{get;set;} 
    public List<Apttus_Approval__Approval_Request__c> approvalRequestList{get;set;}
    public List<Apttus_Config2__ProductConfiguration__c> productConfigList{get;set;}
    
    public QuoteProductApprovalController(){
        quoteId = ApexPages.currentPage().getParameters().get('quoteId');
        cancelFlag = false;
        if(ApexPages.currentPage().getParameters().get('action') != null){
           cancel = ApexPages.currentPage().getParameters().get('action');    
        }
        if(cancel == 'cancel'){
            cancelFlag = true;    
        }      
        productConfigList = new List<Apttus_Config2__ProductConfiguration__c>();
        
        productConfigList = [Select Id, Name, Apttus_QPConfig__Proposald__c, Apttus_CQApprov__Approval_Status__c, Apttus_Config2__Comments__c From 
        Apttus_Config2__ProductConfiguration__c where Apttus_QPConfig__Proposald__c =: quoteId order by Apttus_Config2__VersionNumber__c desc];
        
        approvalRequestList = new List<Apttus_Approval__Approval_Request__c>();
        
        if(productConfigList.size() > 0){
            productConfig = new Apttus_Config2__ProductConfiguration__c();
            productConfig = productConfigList.get(0);                                    
            configStatus = productConfig.Apttus_CQApprov__Approval_Status__c;
            approvalRequestList = [Select Id, Apttus_Approval__Step_Name__c, Apttus_Approval__Action__c, Apttus_Approval__StepSequence__c,  
                                   Apttus_Approval__Assigned_To_Name__c, Apttus_Approval__Approval_Status__c, Apttus_Approval__Action_Approve_Id__c  
                                   From Apttus_Approval__Approval_Request__c where Apttus_CQApprov__CartId__c =: productConfig.Id];
        }
    }
    
    public PageReference cancelApproval(){
        productConfig.Apttus_CQApprov__Approval_Status__c = 'Cancelled';
        
        for(Apttus_Approval__Approval_Request__c request : approvalRequestList){
            request.Apttus_Approval__Approval_Status__c = 'Cancelled';
        }
        
        update approvalRequestList;
        
        update productConfig;
              
        return new PageReference('/'+quoteId); 
    }     
       
}