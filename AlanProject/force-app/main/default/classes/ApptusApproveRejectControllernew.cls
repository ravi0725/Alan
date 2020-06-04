public class ApptusApproveRejectControllernew{
    public Id approvalId{get;set;}
    public Apttus_Config2__ProductConfiguration__c productConfig{get;set;} 
    public List<Apttus_Approval__Approval_Request__c> approvalRequestList{get;set;}
    public List<Apttus_Config2__ProductConfiguration__c> productConfigList{get;set;}
    public Apttus_Approval__Approval_Request__c Approval{get;set;} 
    public String queryparameters  {get;set;}
    public List<Attachment> attachlist{get;set;}
   
    /**public String relatedcart{get;set;}
    public String accountname{get;set;}
    public String owner{get;set;}
    public String proposalname{get;set;}
    public String opportunity{get;set;}
    public Datetime requestdate{get;set;}
    public String paymentterm{get;set;}
    public String primarycontact{get;set;}**/
    
    public ApptusApproveRejectControllernew(ApexPages.StandardController stdController){
       approvalRequestList = new List<Apttus_Approval__Approval_Request__c>();
       //productConfigList = new List<Apttus_Config2__ProductConfiguration__c>();
       
       //productConfigList = [Select Id, Name, Apttus_QPConfig__Proposald__c, Apttus_CQApprov__Approval_Status__c From 
       //                     Apttus_Config2__ProductConfiguration__c where Apttus_QPConfig__Proposald__c =: proposalId order by Apttus_Config2__VersionNumber__c desc]; 
       
       //if(productConfigList.size() > 0){
          //productConfig = new Apttus_Config2__ProductConfiguration__c();
          //productConfig = productConfigList.get(0);
          approvalId = ApexPages.currentPage().getParameters().get('id');
          queryparameters = apexpages.currentpage().getUrl();
          approvalRequestList = [Select Id, Apttus_Approval__Step_Name__c, Apttus_Approval__Action__c, Apttus_Approval__StepSequence__c,  
                                 Apttus_Approval__Assigned_To_Name__c, Apttus_Approval__Approval_Status__c, Apttus_Approval__Action_Approve_Id__c,  
                                 Apttus_CQApprov__CartId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.Name,Apttus_CQApprov__CartId__r.Apttus_QPConfig__Proposald__r.Name,
                                 Apttus_CQApprov__CartId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.Name,Apttus_CQApprov__CartId__r.Apttus_QPConfig__Proposald__r.Customer_Request_Date__c,
                                 Apttus_CQApprov__CartId__r.Apttus_QPConfig__Proposald__r.Payment_Terms_Oppty__c,Apttus_CQApprov__CartId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Primary_Contact__r.Name,
                                 Apttus_CQApprov__CartId__r.Name,Apttus_CQApprov__CartId__r.Initial_Price1__c,Apttus_CQApprov__CartId__r.Effective_Discount__c,Apttus_CQApprov__CartId__r.Discounted_Price1__c,Apttus_CQApprov__CartId__r.ownerid,Apttus_Approval__Request_Comments__c,Apttus_Approval__Approver_Comments__c,
                                 Apttus_Approval__DateAssigned__c,Apttus_Approval__DependsOn__c,Apttus_Approval__Actual_Approver__r.Name,Apttus_CQApprov__CartId__r.Apttus_Config2__Comments__c from Apttus_Approval__Approval_Request__c where Id =: approvalId]; 
       //}
       if(approvalRequestList.size()>0){
            Approval = approvalRequestList.get(0);
            System.debug('***Approval: '+Approval);
            /**Apttus_Approval__Approval_Request__c  approval = approvalRequestList.get(0);
            relatedcart = Approval.Apttus_CQApprov__CartId__r.Name;
            accountname = approval.Apttus_CQApprov__CartId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.Name ;
            owner         =approval.Apttus_CQApprov__CartId__r.ownerid;
            proposalname =approval.Apttus_CQApprov__CartId__r.Apttus_QPConfig__Proposald__r.Name;
            opportunity = approval.Apttus_CQApprov__CartId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.Name;
            requestdate = approval.Apttus_CQApprov__CartId__r.Apttus_QPConfig__Proposald__r.Customer_Request_Date__c;
            paymentterm = approval.Apttus_CQApprov__CartId__r.Apttus_QPConfig__Proposald__r.Payment_Terms_Oppty__c;
            primarycontact = approval.Apttus_CQApprov__CartId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Primary_Contact__r.Name;**/
            
            
       }
    }
    
    /*public List<Apttus_Config2__ProductConfiguration__c> getproductConfigList(){
        system.debug('proposalId '+proposalId );
        productConfigList = new List<Apttus_Config2__ProductConfiguration__c>();
        productConfigList = [Select Id, Name, Apttus_QPConfig__Proposald__c, Apttus_CQApprov__Approval_Status__c From 
        Apttus_Config2__ProductConfiguration__c where Apttus_QPConfig__Proposald__c =: proposalId  ];
        return productConfigList ;
        
    }*/
    
    /*public List<Apttus_Approval__Approval_Request__c> getapprovalRequestList(){
         approvalRequestList = new List<Apttus_Approval__Approval_Request__c>();
        
        if(productConfigList.size() > 0){
            productConfig = new Apttus_Config2__ProductConfiguration__c();
            productConfig = productConfigList.get(0);
            
            approvalRequestList = [Select Id, Apttus_Approval__Step_Name__c, Apttus_Approval__Action__c, Apttus_Approval__StepSequence__c,  
                                   Apttus_Approval__Assigned_To_Name__c, Apttus_Approval__Approval_Status__c, Apttus_Approval__Action_Approve_Id__c  
                                   From Apttus_Approval__Approval_Request__c where Apttus_CQApprov__CartId__c =: productConfig.Id]; 
    }
         return approvalRequestList ;
    
   }*/
   public pagereference apprvedstatus(){
         approval.Apttus_Approval__Approval_Status__c ='Approved';
         update approval;
         return new PageReference('/'+approvalid);
   
   }
   
    public pagereference rejectstatus(){
         approval.Apttus_Approval__Approval_Status__c ='Rejected';
         update approval;
         return new PageReference('/'+approvalid);
   
   }
   
   public pagereference cancel(){
         if(approval != null){
           approval.Apttus_Approval__Approval_Status__c ='Cancelled';
           update approval;
         }  
         return new PageReference('/'+approvalid);   
   }
   
   public pagereference addcomment(){
         //approval.Apttus_Approval__Approver_Comments__c ='';
         update approval;
         return new PageReference('/'+approvalid);
   
   }
   
   public pagereference attachfile(){
         //approval.Apttus_Approval__Approver_Comments__c ='';
         //?pid=a1Oc0000000KjD0&parentname=0000282&retURL=%2Fa1Oc0000000KjD0
         //return new PageReference('apex/UploadFile?pid='+approvalRequestList.get(0).Id);
         PageReference pageRef = new PageReference('/apex/AttachmentUpload?pid='+approvalRequestList.get(0).Id);
         return pageRef;
         
   }
   
   public List<Attachment> getAttach(){
    
     attachlist  =new List<Attachment>();
     attachlist =[select id,Name,ownerid,BodyLength,Description,CreatedDate from attachment where parentid=:approvalid]; 
     return attachlist;
   }
   
}