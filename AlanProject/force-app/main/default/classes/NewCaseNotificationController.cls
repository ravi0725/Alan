public class NewCaseNotificationController{
    public String CaseIds {get; set;}
    public List<Case> caselist {get; set;}
    public boolean displayCaseFlag{get;set;}
    public boolean notifyUserFlag{get;set;}
    public string pushTopicName{get;set;}
    public Integer counter{get;set;}
    public NewCaseNotificationController(){
        CaseIds = '';
        caselist = new List<Case>();
        displayCaseFlag = false;
        notifyUserFlag = false;
        String profileName = [select Profile.Name from User where Id =: userinfo.getUserId()].Profile.Name;
        List<Id> gpIds = new List<Id>();
        for(Group gp : [select id, Group.Name, Type from group where RelatedId =: userinfo.getUserRoleId()]){
            gpIds.add(gp.Id);
        }
        gpIds.add(userinfo.getUserId());
        if(profileName.contains('GCCM')){
            for(GroupMember gpm : [select ID,GroupId,Group.Name from GroupMember where UserOrGroupId in : gpIds and
                   Group.Name in : Label.GCCM_Case_Creation_Notify_Group.split(',')]){
                
                system.debug('----------' + gpm.Group.Name);
                notifyUserFlag = true;  
                pushTopicName = 'GCCMNewCaseNotification';                     
            }
        }else if(profileName.contains('RE&WS')){
            for(GroupMember gpm : [select ID,GroupId,Group.Name from GroupMember where UserOrGroupId in : gpIds and
                   Group.Name in : Label.RE_WS_Case_Creation_Notify_Group.split(',')]){
                
                system.debug('----------' + gpm.Group.Name);
                notifyUserFlag = true;  
                pushTopicName = 'REWSNewCaseNotification';                     
            }
        }else if(profileName.contains('TAP')){
            for(GroupMember gpm : [select ID,GroupId,Group.Name from GroupMember where UserOrGroupId in : gpIds and
                   Group.Name in : Label.TAP_Case_Creation_Notify_Group.split(',')]){
                
                system.debug('----------' + gpm.Group.Name);
                notifyUserFlag = true;  
                pushTopicName = 'TAPNewCaseNotification';                     
            }
        }
        system.debug(notifyUserFlag + '----------' + userinfo.getUserName());
    }
    
    public void caseDetails(){
        system.debug('-------------------' + CaseIds);
        if(String.isNotBlank(CaseIds) && notifyUserFlag){
            counter = 0;
            CaseIds = CaseIds.removeEnd(',');
            CaseIds = CaseIds.replaceAll('"','');
            caseList = [Select Id,CaseNumber,Subject from Case where Id in : caseIds.split(',')];
            if(caseList.size() > 0){
                counter = caseList.size();
                displayCaseFlag = true;
            }
        }    
        
    }
}