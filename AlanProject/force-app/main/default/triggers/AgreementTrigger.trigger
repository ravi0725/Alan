trigger AgreementTrigger on Apttus__APTS_Agreement__c (before update, after update) {
    Apttus_Proposal__Proposal__c[] quotesToUpdate = new List<Apttus_Proposal__Proposal__c>();
    Map<Id, Apttus__APTS_Agreement__c> enhancedAgreements;
    Map<Id, Attachment> agreementToLatestAttachment;
    Map<String, FusionProjectAdminMap__c> adminMappings = FusionProjectAdminMap__c.getAll();
   
    if (Trigger.isBefore) {
        bulkBefore();
    }
    
    for (Apttus__APTS_Agreement__c agreement : Trigger.new) {
        if (Trigger.isBefore) {
            collectQuotesToUpdate(agreement);
            setInternalReviewStatus(agreement);
            setFusionOwnerEmail(agreement);
            setInitialAgreement(agreement);
        }
    }
    
    if (Trigger.isAfter) {
  
        andFinally();
    }
    
    if(Trigger.isBefore){
    // To Uncheck the Primary Flage for Second Agreement Created
    Set<ID> ProposalID = new Set<ID>();
    for (Apttus__APTS_Agreement__c agreement : Trigger.new) {
    ProposalID.add(agreement.Apttus_QPComply__RelatedProposalId__c);
    }
     integer count= [select count() from Apttus__APTS_Agreement__c where Apttus_QPComply__RelatedProposalId__c in:ProposalID];
      for (Apttus__APTS_Agreement__c agreement : Trigger.new) {
      if(count>1 && Trigger.new.get(0).Apttus__Status_Category__c!='In Effect' && Trigger.new.get(0).Apttus__Status__c!='Activated')
      agreement.Primary_Agreement__c = False;
      }
    }
    private void bulkBefore() {
        enhancedAgreements = new Map<Id, Apttus__APTS_Agreement__c>(
            [select Apttus_QPComply__RelatedProposalId__r.Initial_Agreement__c,
                Apttus_CMConfig__PriceListId__r.CurrencyIsoCode
            from Apttus__APTS_Agreement__c where Id in :Trigger.new]);
    }
    
    private void andFinally() {
        update quotesToUpdate;
    }
    
    private void collectQuotesToUpdate(Apttus__APTS_Agreement__c agreement) {
        if (isStatusChangedTo(agreement, 'In Effect') && 
                agreement.Apttus_QPComply__RelatedProposalId__c != null) {
            quotesToUpdate.add(new Apttus_Proposal__Proposal__c(
                Id = agreement.Apttus_QPComply__RelatedProposalId__c,
                Apttus_Proposal__Approval_Stage__c = 'Accepted'));
        }
    }
    
    private void setInternalReviewStatus(Apttus__APTS_Agreement__c agreement) {
        if (agreement.Sent_for_Internal_Review__c && agreement.Apttus__Status__c == 'Other Party Review' ) {
            agreement.Apttus__Status__c = agreement.Internal_Party__c + ' Review';
            agreement.Sent_for_Internal_Review__c = false;
            agreement.Internal_Party__c = '';
        }

    }
    
    private void setFusionOwnerEmail(Apttus__APTS_Agreement__c agreement) {
        Apttus__APTS_Agreement__c enhanced = enhancedAgreements.get(agreement.Id);
        for (FusionProjectAdminMap__c adminMap : adminMappings.values()) {
            if (adminMap.Object_Type__c == 'PROJECT') {
                if (adminMap.Organization__c == agreement.Organization__c &&
                        adminMap.Currency__c == enhanced.Apttus_CMConfig__PriceListId__r.CurrencyIsoCode) {
                    agreement.Fusion_Project_Owner_Email__c = adminMap.Project_Administrator_Email__c;
                }
            } else if (adminMap.Object_Type__c == 'CONTRACT') {
                if (adminMap.Organization__c == agreement.Organization__c &&
                        adminMap.Currency__c == enhanced.Apttus_CMConfig__PriceListId__r.CurrencyIsoCode) {
                    agreement.Contract_Owner_Email__c = adminMap.Project_Administrator_Email__c;
                }
            }
        }
    }
    
    private void setInitialAgreement(Apttus__APTS_Agreement__c agreement) {
        if (agreement.Apttus_QPComply__RelatedProposalId__c == null) {
            agreement.Apttus__Parent_Agreement__c = null;
        } else {
            agreement.Apttus__Parent_Agreement__c = enhancedAgreements.get(agreement.Id).Apttus_QPComply__RelatedProposalId__r.Initial_Agreement__c;
        }
    }

    private Boolean isStatusChangedTo(Apttus__APTS_Agreement__c agreement, String statusCategory) {
        Apttus__APTS_Agreement__c oldAgreement = Trigger.oldMap.get(agreement.Id);
        return agreement.Apttus__Status_Category__c == statusCategory && oldAgreement.Apttus__Status_Category__c != statusCategory;
    }
}