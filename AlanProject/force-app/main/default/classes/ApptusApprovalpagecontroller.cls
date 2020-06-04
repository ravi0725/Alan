/*****************************************************************************************
    Name         : CartViewRelatedListController 
    Desc         : Used for displaying approval request related to a Quote/Proposal record in its related list of Approval Requests.
    Project Item : ITEM-00816
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Sagar Mehta          01/15/2014          Created
******************************************************************************************/
public class ApptusApprovalpagecontroller{
   
    public List<Apttus_Approval__Approval_Request__c> approvalRequestList{get;set;}
    public List<Apttus_Approval__Approval_Request__c> approvalRequestListnew{get;set;}
    public List<Apttus_Approval__Approval_Request__c> approverlist{get;set;}
     public List<Apttus_Approval__Approval_Request__c> approverlistall{get;set;}
    public Integer totalSize{get;set;}
    public Integer remainder{get;set;}
    public boolean loadMore{get;set;}
    List<Group> grouplist=new List<Group>();
    List<Groupmember> groupmemberlist=new List<GroupMember>();
    String User;
    set<Id> userset=new set<Id>();
    /**
     * Class Constructor 
     * @param stdController the standard controller
     */
    public ApptusApprovalpagecontroller() {
        remainder = 0;      
        loadMore = false;
        approvalRequestList = new List<Apttus_Approval__Approval_Request__c>();
        approverlist = new List<Apttus_Approval__Approval_Request__c>();          
          
        grouplist =[select Id from Group where DeveloperName =: Label.Apttus_Approval_Group];
        User=Userinfo.getuserid();
        groupmemberlist =[select UserOrGroupId,GroupId from Groupmember where GroupId =: grouplist.get(0).id];
        for(Groupmember  grp:groupmemberlist){
          userset.add(grp.UserOrGroupId);
        }          
        String Userid= Userinfo.getuserid();
        approverlist  = [Select Id,Apttus_Approval__Assigned_To_Type__c,Apttus_Approval__Assigned_To_Id__c,Apttus_Approval__Step_Name__c, Apttus_Approval__Action__c, Apttus_Approval__StepSequence__c,Apttus_Approval__Actual_Approver__c,Apttus_Approval__DateAssigned__c,Apttus_Approval__Object_Type__c,  
                         Apttus_Approval__Assigned_To_Name__c,Apttus_Approval__Initial_Submitter__c, Apttus_Approval__Approval_Status__c, Apttus_Approval__Action_Approve_Id__c,Apttus_Approval__Approver_Comments__c,Apttus_CQApprov__CartId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Proposal_Name__c
                         From Apttus_Approval__Approval_Request__c where  Apttus_Approval__Approval_Status__c =:'Assigned']; 
        for(Apttus_Approval__Approval_Request__c  ap:approverlist){
          if(approvalRequestList.size()<3){
            if(ap.Apttus_Approval__Assigned_To_Type__c =='User' && ap.Apttus_Approval__Assigned_To_Id__c==User){
              approvalRequestList.add(ap);
            }  
            if(ap.Apttus_Approval__Assigned_To_Type__c =='Queue' && userset.contains(ap.Apttus_Approval__Assigned_To_Id__c)){
              approvalRequestList.add(ap);
            }
          }
        }                     
           
        if(approvalRequestList.size() <= 0){
           ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, Label.No_Item_Approve);
           ApexPages.addMessage(msg); 
        }  
        getapprovalRequestListnew();                                   
    }
    
    public List<Apttus_Approval__Approval_Request__c> getapprovalRequestListnew(){
        approvalRequestListnew = new List<Apttus_Approval__Approval_Request__c>();
        approverlistall = new List<Apttus_Approval__Approval_Request__c>();
            
        approverlistall = [Select Id,Apttus_Approval__Assigned_To_Type__c,Apttus_Approval__Assigned_To_Id__c,Apttus_Approval__Step_Name__c, Apttus_Approval__Action__c, Apttus_Approval__StepSequence__c,Apttus_Approval__Actual_Approver__c,Apttus_Approval__DateAssigned__c,Apttus_Approval__Object_Type__c,  
                           Apttus_Approval__Assigned_To_Name__c, Apttus_Approval__Approval_Status__c, Apttus_Approval__Action_Approve_Id__c,Apttus_Approval__Approver_Comments__c,Apttus_CQApprov__CartId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Proposal_Name__c
                           From Apttus_Approval__Approval_Request__c where  Apttus_Approval__Approval_Status__c =:'Assigned']; 
        for(Apttus_Approval__Approval_Request__c  ap:approverlistall){            
           if(ap.Apttus_Approval__Assigned_To_Type__c =='User' && ap.Apttus_Approval__Assigned_To_Id__c==User){
              approvalRequestListnew.add(ap);
           }  
           if(ap.Apttus_Approval__Assigned_To_Type__c =='Queue' && userset.contains(ap.Apttus_Approval__Assigned_To_Id__c)){
              approvalRequestListnew.add(ap);
           }            
        }                     
           
        if(approvalRequestListnew.size() <= 0){
           ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, Label.No_Item_Approve);
           ApexPages.addMessage(msg); 
        }    
        return approvalRequestListnew;
    }        
}