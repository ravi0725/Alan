public class FC_CopyAtttachmentHandler{
    public static string AGREEMENT = 'Agreement';
    public static string PROPOSAL = 'Proposal';
    
    public FC_CopyAtttachmentHandler(){
    }
    
    // Updated by Suresh Babu Murugan: 
    // Requirement we need to create attachment to Opportunity from Agreement and Proposals
    public void onAfterInsertAttachment(List<Attachment> newAttachments){
        Set<Id> AGMTParentIDs = new Set<Id>();
        Set<Id> PROPParentIDs = new Set<Id>();
        List<Attachment> InsertAttachments = new List<Attachment>();
        Map<Id, Apttus__APTS_Agreement__c> agrmnts = new Map<Id, Apttus__APTS_Agreement__c>();
        Map<Id, Apttus_Proposal__Proposal__c> proposals = new Map<id, Apttus_Proposal__Proposal__c>();
        
        for(Attachment att : newAttachments){
            if(att.ParentId != null && att.ParentId.getSobjectType() != Apttus__APTS_Agreement__c.SobjectType 
               && att.ParentId.getSobjectType() != Apttus_Proposal__Proposal__c.SobjectType) {
                   continue;
               }
            String sObjectType = att.ParentId.getSobjectType() == Apttus__APTS_Agreement__c.SobjectType ? AGREEMENT : PROPOSAL;
            if(sObjectType == 'Agreement'){
                AGMTParentIDs.add(att.ParentId);
            }
            else if(sObjectType == 'Proposal'){
                PROPParentIDs.add(att.ParentId);
            }
        }
        
        if(AGMTParentIDs.size() > 0){
            agrmnts = new Map<Id, Apttus__APTS_Agreement__c>([SELECT Id, Apttus__Related_Opportunity__c FROM Apttus__APTS_Agreement__c WHERE Id IN :AGMTParentIDs AND Apttus__Related_Opportunity__c != null]);
        }
        
        if(PROPParentIDs.size() > 0){
            proposals = new Map<Id, Apttus_Proposal__Proposal__c>([SELECT Id, Apttus_Proposal__Opportunity__c FROM Apttus_Proposal__Proposal__c WHERE Id IN :PROPParentIDs AND Apttus_Proposal__Opportunity__c != null]);
        }
        
        for(Attachment att : newAttachments){
            if(att.ParentId != null && att.ParentId.getSobjectType() != Apttus__APTS_Agreement__c.SobjectType 
               && att.ParentId.getSobjectType() != Apttus_Proposal__Proposal__c.SobjectType) {
                   continue;
               }
            String sObjectType = att.ParentId.getSobjectType() == Apttus__APTS_Agreement__c.SobjectType ? AGREEMENT : PROPOSAL;
            
            if(sObjectType == 'Agreement'){
                if(agrmnts.containsKey(att.ParentId)){
                    InsertAttachments.add(new Attachment(Name = att.Name, body = att.body, ParentId = agrmnts.get(att.ParentId).Apttus__Related_Opportunity__c));
                }
            }
            else if(sObjectType == 'Proposal'){
                if(proposals.containsKey(att.ParentId)){
                    InsertAttachments.add(new Attachment(Name = att.Name, body = att.body, ParentId = proposals.get(att.ParentId).Apttus_Proposal__Opportunity__c));
                }
            }
        }
        
        if(InsertAttachments.size() > 0){
            insert InsertAttachments;
        }
    }
}