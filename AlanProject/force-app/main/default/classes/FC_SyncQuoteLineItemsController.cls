public class FC_SyncQuoteLineItemsController {
    
    private final Apttus_Proposal__Proposal__c proposal;
    public Apttus__APTS_Agreement__c[] validAgreements { get; private set; }
    private String selectedAgreementId;
    
    public FC_SyncQuoteLineItemsController(ApexPages.StandardController controller) {
        proposal = (Apttus_Proposal__Proposal__c) controller.getRecord();
        
        validAgreements = [select Name, RecordType.Name, Apttus__FF_Agreement_Number__c, Apttus__Status_Category__c from Apttus__APTS_Agreement__c 
            where Apttus_QPComply__RelatedProposalId__c = :proposal.Id
              and RecordType.Name in ('SOW Only', 'Master Saas Agreement', 'Change Order')
              and Apttus__Status_Category__c in ('Request', 'In Authoring')];

        if (validAgreements.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'There are no valid agreements attached to this proposal.  Cannot sync.'));
        } 
    }
    
    public PageReference syncLineItems() {
        Apttus__APTS_Agreement__c selectedAgreement = getSelectedAgreement();
        try { 
            syncProposalTo(selectedAgreement);
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Lines did not get created successfully: ' + ex.getMessage() + '[' + ex.getLineNumber() + ']'));
            return null;
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Agreement <a href="/' + selectedAgreement.Id + '">' + selectedAgreement.Name + '</a> has been successfully sync\'ed!'));
        return null;
    }
    
    public Apttus__APTS_Agreement__c getSelectedAgreement() {
        // do validations first
        if (selectedAgreementId == null) {
            throw new FC_Exception('Please select an agreement from the list below.');
        }
        Apttus__APTS_Agreement__c selectedAgreement;
        for (Apttus__APTS_Agreement__c agr : validAgreements) {
            if (agr.Id == selectedAgreementId) {
                selectedAgreement = agr;
            }
        }
        if (selectedAgreement == null) {
            throw new FC_Exception('Agreement not found (' + selectedAgreementId + ')');
        }
        return selectedAgreement;
    }
    
    private void syncProposalTo(Apttus__APTS_Agreement__c agreement) {
        // delete agreement line items
        
        Map<String, DescribeFieldResult> proposalLineFields = getLocalNameMap(Schema.SObjectType.Apttus_Proposal__Proposal_Line_Item__c.fields.getMap().values());
        Map<String, DescribeFieldResult> agreementLineFields = getLocalNameMap(Schema.SObjectType.Apttus__AgreementLineItem__c.fields.getMap().values());
        String[] proposalSelectFields = new List<String>();
        String[] commonFields = new List<String>();
        for (String field : agreementLineFields.keySet()) {
            DescribeFieldResult fieldDescribe = agreementLineFields.get(field);
            System.debug(logginglevel.error, 'field: ' + field + ', ' + fieldDescribe.isCreateable() + ', ' + proposalLineFields.containsKey(field));
            if (fieldDescribe.isCreateable() && proposalLineFields.containsKey(field)) {
                proposalSelectFields.add(proposalLineFields.get(field).getName());
                commonFields.add(field);
            }
        }
        String soql = 'select ' + String.join(proposalSelectFields, ',') + ' from Apttus_Proposal__Proposal_Line_Item__c where Apttus_Proposal__Proposal__c = \'' + proposal.Id + '\'';
        Apttus_Proposal__Proposal_Line_Item__c[] proposalLines = (Apttus_Proposal__Proposal_Line_Item__c[]) Database.query(soql);
        
        Apttus__AgreementLineItem__c[] newAgreementLines = new List<Apttus__AgreementLineItem__c>();
        for (Apttus_Proposal__Proposal_Line_Item__c proposalLine : proposalLines) {
            Apttus__AgreementLineItem__c newAgreementLine = new Apttus__AgreementLineItem__c(Apttus__AgreementId__c = agreement.Id);
            for (String field : commonFields) {
                newAgreementLine.put(agreementLineFields.get(field).getName(), proposalLine.get(proposalLineFields.get(field).getName()));
            }
            newAgreementLines.add(newAgreementLine);
        }
        
        Apttus__AgreementLineItem__c[] oldAgreementLines = [select Id from Apttus__AgreementLineItem__c where Apttus__AgreementId__c = :agreement.Id];
        insert newAgreementLines;
        delete oldAgreementLines;
        
    }
    
    private Map<String, DescribeFieldResult> getLocalNameMap(Schema.SObjectField[] sobjFields) {
        Map<String, DescribeFieldResult> localNameMap = new Map<String, DescribeFieldResult>();
        for (Schema.SObjectField sobjField : sobjFields) {
            DescribeFieldResult fieldResult = sobjField.getDescribe();
            String fieldName = fieldResult.getName();
            String[] fieldNameSplit = fieldName.split('__');
            String localName;
            if (fieldNameSplit.size() <= 2) {
                localName = fieldName;
            } else {
                fieldNameSplit.remove(0);
                localName = String.join(fieldNameSplit, '__');
            }
            localNameMap.put(localName, fieldResult);
        }
        return localNameMap;
    }

    public void selectAgreement() {
        selectedAgreementId = ApexPages.currentPage().getParameters().get('agreementId');
        
    }
}