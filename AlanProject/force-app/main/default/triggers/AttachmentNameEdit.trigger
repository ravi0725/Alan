trigger AttachmentNameEdit on Attachment (before insert) {
  /*Id ProfID = UserInfo.getProfileId();
  String formatStr='';
  Map<ID,Attachment>RecordID = new Map<ID,Attachment>();
  List<Apttus__APTS_Agreement__c> AgreementList = new List<Apttus__APTS_Agreement__c>();
  List<Apttus_Proposal__Proposal__c>ProposalList = new List<Apttus_Proposal__Proposal__c>();
String profileName = [Select Name from Profile where Id =:ProfID].Name;
    for(Attachment att : trigger.New){
    RecordID.Put(att.Id,att);
    }
  AgreementList = [Select id,Apttus_QPComply__RelatedProposalId__r.Name,Apttus_QPComply__RelatedProposalId__r.Apttus_QPConfig__BillToAccountId__r.Name from Apttus__APTS_Agreement__c where id in:RecordID.keyset()];
  ProposalList = [Select id,Name,Apttus_QPConfig__BillToAccountId__r.Name from Apttus_Proposal__Proposal__c where id in:RecordID.keyset()];
  
  if(AgreementList.size()>0)
  formatStr = 'Agreement - '+AgreementList.get(0).Apttus_QPComply__RelatedProposalId__r.Name+ ' - '+AgreementList.get(0).Apttus_QPComply__RelatedProposalId__r.Apttus_QPConfig__BillToAccountId__r.Name+' - '+system.today();
  else if(ProposalList.size()>0)
  formatStr = 'Proposal - '+ProposalList.get(0).Name+ ' - '+ProposalList.get(0).Apttus_QPConfig__BillToAccountId__r.Name+' - '+system.today();
  
 for(Attachment att : trigger.New){
 
  System.debug('^^^^^^^^^^'+att.ParentId.getSobjectType());
  System.debug('^^^^^^^^^^'+att.ParentId);
  System.debug('^^^^^^^^^^'+Apttus__APTS_Agreement__c.SobjectType);
  System.debug('^^^^^^^^^^'+Apttus_Proposal__Proposal__c.SobjectType);
    
         //Check if added attachment is related to Proposal or Agreement
         if(att.ParentId.getSobjectType() == Apttus__APTS_Agreement__c.SobjectType || att.ParentId.getSobjectType() == Apttus_Proposal__Proposal__c.SobjectType){
             if(profileName.contains('MEP') ||profileName.contains('GCCM'))
                {
                     System.debug('^^^^^InsideMEP^^^^^'+att.ParentId.getSobjectType());
                     Att.Name = formatStr + ' ' + Att.Name;
                }
                              
              System.debug('^^^^^^^^^^'+att.ParentId.getSobjectType());
         }
    }
    */
    
    // Update Attachment name
    if(trigger.IsBefore && trigger.isInsert)
        new AttachmentNameEditHandler(trigger.new,trigger.old).execute();
     
     
}