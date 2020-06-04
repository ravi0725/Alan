/*****************************************************************************************
    Name    : CaseAcceptOverrideController
    Desc    : Used to have a solution to solve the issue of multiple Support Reps assigning the same Case to 
    themselves from the Case Queues.
                            
    Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Sagar Mehta           5/13/2014          Created
******************************************************************************************/
public class CaseAcceptOverrideController{
    public String caseId{get;set;}
    public List<Case> errorCaseList{get;set;}
    List<Id> caseIdList = new List<Id>();
    public boolean mandatoryFlag{get;set;}
    /**
     * Method name  : CaseAcceptOverrideController
     * Description  : Constructor of the Controller class - Initializes all the variables.
     *                Populates forecast quarter data into forecast list
     * Return Type  : Void
     * Parameter    : StandardSetController
     **/
    public CaseAcceptOverrideController(ApexPages.StandardSetController controller){                
        List<Case> cList = (List<Case>)controller.getSelected();
        for(Case case1 : cList){
           caseIdList.add(case1.Id);
        }          
        mandatoryFlag = false;     
    }
    
    /**
     * Method name  : checkOwner
     * Description  : Method to check the owner of the selected cases.
     * Return Type  : Void
     * Parameter    : None
     **/
    public void checkOwner(){  
        try{      
            User ur = [select Id,LanguageLocaleKey, Division__c from User where Id =: userinfo.getUserId()];
            
            List<Case> caseList = new List<Case>();
            caseList = [Select Id, CaseNumber, OwnerId from Case where Id IN: caseIdList];            
            if(caseList.size() > 0){
               Set<Id> ownerIdSet = new Set<Id>();
               for(Case case1 : caseList){
                  ownerIdSet.add(case1.OwnerId);
               }
               errorCaseList = new List<Case>();
               Map<Id, Group> groupMap = new Map<Id, Group>();
               groupMap = new Map<Id, Group>([Select Id from Group where Id IN: ownerIdSet]);
               List<Case> updatedCaseList = new List<Case>();
               for(Case case1 : caseList){
                  if(groupMap.containsKey(case1.OwnerId)){
                     case1.OwnerId = UserInfo.getUserId();
                     if(ur.Division__c == 'TAP'){
                         case1.Status = 'Working';
                     }
                     updatedCaseList.add(case1);
                  }else{
                     errorCaseList.add(case1);
                  }
               }
               if(updatedCaseList.size() > 0)
                   update updatedCaseList;
    
               if(errorCaseList.size() > 0){
                  ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Case_Accept_Error_Msg);
                  ApexPages.addMessage(msg);
                  ApexPages.Message msg1;
                  for(Case case1 : errorCaseList){
                     msg1 = new ApexPages.Message(ApexPages.Severity.ERROR, case1.CaseNumber);
                     ApexPages.addMessage(msg1);
                  }                  
               } 
            }else{
               ApexPages.Message msg2 = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Case_Accept_Mandatory_Msg);
               ApexPages.addMessage(msg2);
               mandatoryFlag = true;
            }
        }catch(Exception e){
            ApexPages.Message msg2 = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            ApexPages.addMessage(msg2);
            mandatoryFlag = true;
        }                    
    }
    
     /**
     * Method name  : redirect
     * Description  : Method to redirect to cases tab.
     * Return Type  : PageReference
     * Parameter    : None
     **/
    public PageReference redirect(){
        PageReference pageRef;   
        pageRef = new PageReference('/500');
        return pageRef;
    }
}