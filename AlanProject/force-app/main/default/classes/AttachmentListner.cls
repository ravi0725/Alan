public class AttachmentListner{
    public static Map<String, Integer> launchControl;
    // Static initialize
    static {
        resetLaunchControl();
    }
    
    // Reset Trigger control (e.g. for testing)
    public static void resetLaunchControl() {
        launchControl = new Map<String, Integer>();
        launchControl.put('callTFS', 0);
        launchControl.put('AddAttachmentToCase',0);
        launchControl.put('AddCaseAttachmentToIssue',0);
    }
    
    // Reset Trigger control (e.g. for testing)
    public static void setLaunchControl() {
        launchControl = new Map<String, Integer>();
        launchControl.put('callTFS', 1);
        launchControl.put('AddAttachmentToCase',1);
        launchControl.put('AddCaseAttachmentToIssue',1);
    }
    
    @Future(callout=true)
    public static void callTFS(List<Id> attachmentList){
        System.debug('====================attachmentList.size()================='+attachmentList.size()+'=========launchControl.getcallTFS==========='+launchControl.get('callTFS'));
        if(attachmentList.size() == 1){
            Attachment att = [select Id,ParentId,Body,Name,ContentType,Description from Attachment where Id =: attachmentList.get(0)];
            Case cs = [select Id,Product__c,TFS_Id__c,Record_Type_Name__c from Case where Id =: att.ParentId];
            if(cs.Record_Type_Name__c == Label.GCCM_Support_Issue_Record_Type){
                   
                   TFS_Project_Config__c TFSConfig = TFS_Project_Config__c.getAll().get(cs.Product__c);
                   if(TFSConfig != null){
                       
                       if(TFSConfig.Run_Integration__c){
                           TFSConfig = TFS_Project_Config__c.getAll().get(cs.Product__c);
                           
                           String ProjectName = TFSConfig.Project_Name__c;
                           String Division = '';
                           if(cs.Record_Type_Name__c == Label.GCCM_Support_Issue_Record_Type){
                               /*if(cs.Product__c == 'Proliance')Division = 'Proliance';
                               else Division = 'GCCM';*/
                               Division = TFSConfig.Division__c;
                           }
                           
                           system.debug('--------ProjectName ------------' + ProjectName );
                           system.debug('--------Division ------------' + Division );
                           xmlnsOracleComTfsTnvtfsfileattachmen attachmentCall = new xmlnsOracleComTfsTnvtfsfileattachmen();
                           xmlnsOracleComTfsTnvtfsfileattachmen.tnvtfsfileattachmentService_pt processCall = new xmlnsOracleComTfsTnvtfsfileattachmen.tnvtfsfileattachmentService_pt();
                           processCall.timeout_x = 120000;
                           if(!Test.isRunningTest()){
                               xmlnsOracleComTfsTnvtfsfileattachmen.processResponse_element response = processCall.process(((cs.TFS_Id__c != null && cs.TFS_Id__c.isNumeric()) ? Integer.valueOf(cs.TFS_Id__c) : null),att.Name.subString(0,att.Name.lastIndexOf('.')),att.Name.subString(att.Name.lastIndexOf('.') , att.Name.length()),EncodingUtil.base64Encode(att.Body),att.Description , ProjectName , Division);
                           }
                       }
                   }
                   system.debug('--------responseParam.response------------' + ((cs.TFS_Id__c != null && cs.TFS_Id__c.isNumeric()) ? Integer.valueOf(cs.TFS_Id__c) : null));
                   system.debug('--------responseParam.response------------' + att.Name);
                   system.debug('--------responseParam.response------------' + att.Name.subString(0,att.Name.lastIndexOf('.')));
                   system.debug('--------responseParam.response------------' + att.Name.subString(att.Name.lastIndexOf('.') , att.Name.length()));
                   system.debug('--------responseParam.response------------' + att.Description);
               }
        }
    }
    
    //Add Attachment to Case 
    public static void AddCaseAttachmentToIssue(List<Attachment> attList){
        system.debug('------------AddCaseAttachmentToIssue-----------' + launchControl.get('AddCaseAttachmentToIssue'));
        if(launchControl.get('AddCaseAttachmentToIssue') < 1){
            launchControl.put('AddCaseAttachmentToIssue',launchControl.get('AddCaseAttachmentToIssue') + 1);
            Map<Id,List<Attachment>> attIssueMap = new Map<Id,List<Attachment>>();
            for(Attachment att : attList){
                system.debug(att+ '------------att.ParentId-----------' + att.ParentId);
                string objPrefix = (String)att.ParentId;
                if(objPrefix.left(3) == Schema.getGlobalDescribe().get('Case').getDescribe().getKeyPrefix()){
                    if(!attIssueMap.containsKey(att.ParentId))attIssueMap.put(att.ParentId,new List<Attachment>());
                    attIssueMap.get(att.ParentId).add(att);
                }
            }
            system.debug('------------attIssueMap -----------' + attIssueMap );
            if(attIssueMap.size() > 0){
                List<Attachment> insertList = new List<Attachment>();
                for(Case cs : [select Id,Defect__c from Case
                               where RecordType.Name =: Label.GCCM_Support_Case_Record_Type and 
                               Id in : attIssueMap.keySet() and Defect__c != null]){
                                   system.debug(cs+ '------------attIssueMap-----------' + attIssueMap);
                                   if(attIssueMap.containsKey(cs.Id)){ 
                                       for(Attachment att : attIssueMap.get(cs.Id)){
                                           Attachment attObj = new Attachment();
                                           attObj = att.clone(false,false,false,false);
                                           attObj.ParentId = cs.Defect__c;
                                           insertList.add(attObj);
                                       }
                                   }
                               }
                system.debug( '------------insertList-----------' + insertList);
                if(insertList.size() > 0){
                    launchControl.put('callTFS', 0);
                    insert insertList; 
                }
            }
        }
    }
    
    
    //Add Attachment to Case 
    public static void AddAttachmentToCase(List<Attachment> attList){
       /* system.debug('------------AddAttachmentToCase-----------' + launchControl.get('AddAttachmentToCase'));
        if(launchControl.get('AddAttachmentToCase') < 1){
            launchControl.put('AddAttachmentToCase',launchControl.get('AddAttachmentToCase') + 1);
            Map<Id,List<Attachment>> attMsgMap = new Map<Id,List<Attachment>>();
            for(Attachment att : attList){
                system.debug(att+ '------------att.ParentId-----------' + att.ParentId);
                string objPrefix = (String)att.ParentId;
                if(objPrefix.left(3) == Schema.getGlobalDescribe().get('EmailMessage').getDescribe().getKeyPrefix()){
                    if(!attMsgMap.containsKey(att.ParentId))attMsgMap.put(att.ParentId,new List<Attachment>());
                    attMsgMap.get(att.ParentId).add(att);
                }
            }
            system.debug('------------attMsgMap -----------' + attMsgMap );
            if(attMsgMap.size() > 0){
                List<Attachment> insertList = new List<Attachment>();
                for(EmailMessage msg : [select HasAttachment,ParentId,Parent.Record_Type_Name__c,inComing,ToAddress from EmailMessage
                                        where Id in : attMsgMap.keySet()]){
                                            system.debug(msg+ '------------attMsgMap-----------' + attMsgMap);
                                            string objPrefix = (String)msg.ParentId;
                                            if(attMsgMap.containsKey(msg.Id) && objPrefix.left(3) == Schema.getGlobalDescribe().get('Case').getDescribe().getKeyPrefix() && 
                                               msg.Parent.Record_Type_Name__c == Label.RE_WS_Proliance_Support_Case_Record_Type && msg.inComing && 
                                               msg.HasAttachment){
                                                   for(Attachment att : attMsgMap.get(msg.Id)){
                                                       Attachment attObj = new Attachment();
                                                       attObj = att.clone(false,false,false,false);
                                                       attObj.ParentId = msg.ParentId;
                                                       insertList.add(attObj);
                                                   }
                                               }
                                        }
                system.debug( '------------insertList-----------' + insertList);
                if(insertList.size() > 0){
                    AttachmentListner.resetLaunchControl();
                    insert insertList;
                }
            }
        }*/
    }
}