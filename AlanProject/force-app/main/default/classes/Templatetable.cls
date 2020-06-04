public class Templatetable{
    
    public Id proposalId{get;set;}
    public Apttus_Config2__ProductConfiguration__c productConfig{get;set;} 
    public List<Apttus_Approval__Approval_Request__c> approvalRequestList{get;set;}
    public List<Apttus_Config2__ProductConfiguration__c> productConfigList{get;set;}
    List<Apttus_Approval__Approval_Request__c> listapprover=new List<Apttus_Approval__Approval_Request__c>();
    List<Apttus_Approval__Approval_Request__c> listreturn{get;set;}
    
    public Templatetable(){
     
    }
    
    public List<Apttus_Approval__Approval_Request__c> getapprovalReqList(){
       Double sequence;
       String ssequence;
       String sq;
       Integer sqi;
       List<Double> sequenceList = new List<Double>();
       List<Double> sequenceListlater = new List<Double>();
       listreturn = new List<Apttus_Approval__Approval_Request__c>();
       List<Apttus_Approval__Approval_Request__c> requestList = new List<Apttus_Approval__Approval_Request__c>();
       Apttus_Approval__Approval_Request__c request = new Apttus_Approval__Approval_Request__c();

       requestList = [Select Apttus_CQApprov__CartId__c, Id, Apttus_Approval__Step_Name__c, Apttus_Approval__Action__c,
                      Apttus_Approval__ActualApproverName__c, Apttus_Approval__StepSequence__c, Apttus_Approval__Assigned_To_Name__c, 
                      Apttus_Approval__Approval_Status__c,Apttus_Approval__Approver_Comments__c, Apttus_Approval__Date__c,
                      Apttus_Approval__Action_Approve_Id__c,Seq_Template__c, Apttus_Approval__DependsOn__c 
                      from Apttus_Approval__Approval_Request__c where Id =: proposalId];

       if(requestList.size() > 0){
           request = requestList.get(0);
       }
       
       if(request.Apttus_Approval__StepSequence__c != null){
           sequence = request.Apttus_Approval__StepSequence__c;
           ssequence = String.valueOf(sequence);
       }
       sq = ssequence.substring(0, 1);
       String sqlate=ssequence.substring(1);
       sqi = Integer.valueOf(sq);
       if(ssequence.substring(0, 1) != '1'){         
         approvalRequestList = new List<Apttus_Approval__Approval_Request__c>();
         approvalRequestList = [Select Id, Apttus_Approval__Step_Name__c, Apttus_Approval__Action__c,Apttus_Approval__ActualApproverName__c, Apttus_Approval__StepSequence__c,  
                                Apttus_Approval__Assigned_To_Name__c, Apttus_Approval__Approval_Status__c,Apttus_Approval__Approver_Comments__c, Apttus_Approval__Date__c,
                                Apttus_Approval__Action_Approve_Id__c,Seq_Template__c, Apttus_Approval__DependsOn__c  
                                From Apttus_Approval__Approval_Request__c where Apttus_CQApprov__CartId__c =: request.Apttus_CQApprov__CartId__c order by Apttus_Approval__StepSequence__c  Desc]; 
         String s;
         s = '1: '+sqi;
         sequenceList.add(sqi);
         Integer i = 1;
         for(Apttus_Approval__Approval_Request__c req : approvalRequestList){          
            if(request.Apttus_Approval__StepSequence__c != req.Apttus_Approval__StepSequence__c){
               s = s+'s: '+(sqi-i);
               sequenceList.add(sqi-i);
               i++;
            }          
          }
          for(i=0;i<sequenceList.size();i++){
              Integer later=Integer.valueof(sequenceList[i]);
              String st=String.valueof(later);
              st=st+sqlate;
              double dbst=double.valueof(st);
              sequenceListlater.add(dbst);
          
          }
         
          listreturn = [Select Id, Apttus_Approval__Step_Name__c, Apttus_Approval__Action__c,Apttus_Approval__ActualApproverName__c, Apttus_Approval__StepSequence__c,  
                    Apttus_Approval__Assigned_To_Name__c, Apttus_Approval__Approval_Status__c,Apttus_Approval__Approver_Comments__c, Apttus_Approval__Date__c,
                    Apttus_Approval__Action_Approve_Id__c,Seq_Template__c,Apttus_Approval__DependsOn__c 
                    From Apttus_Approval__Approval_Request__c where Apttus_CQApprov__CartId__c =: request.Apttus_CQApprov__CartId__c and Apttus_Approval__StepSequence__c IN: sequenceListlater order by Apttus_Approval__StepSequence__c]; 
       }else{
         listreturn = requestList;
       }    
       return listreturn;
    }                      
    
}