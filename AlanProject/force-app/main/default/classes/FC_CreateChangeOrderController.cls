public class FC_CreateChangeOrderController {
    Apttus__APTS_Agreement__c agreement;
    public FC_CreateChangeOrderController(ApexPages.StandardController controller) {
        agreement = (Apttus__APTS_Agreement__c) controller.getRecord();
    }
    
    public PageReference beginChangeOrderProcess() {
        // Opportunity opportunity = createOpportunity();
        // insert opportunity;
        // Apttus_Proposal__Proposal__c proposal = createProposal();
        // insert proposal;
        // return new PageReference('/' + proposal.Id + '/e?' + 
        //     'cancelURL=%2Fapex%2Fapttus__cancelactioninterceptor%3F' +
        //     'objectId%3D' + agreement.Id + 
        //     '&retURL=%2F' + proposal.Id);
            
        PageReference pageRef;

        pageRef = Page.CreateQuoteOpportunity;
        pageRef.getParameters().put('id', agreement.Apttus__Account__c);
        pageRef.getParameters().put('initialAgreementId', agreement.Id);
        pageRef.setRedirect(true);

        return pageRef;
    }
    
    // private Opportunity createOpportunity() {
    //     return new Opportunity(Name = 'Change Order for ' + agreement.Name,
    //         AccountId = agreement.Apttus__Account__c
    //         );
    // }
    
    // private Apttus_Proposal__Proposal__c createProposal() {
    //     return new Apttus_Proposal__Proposal__c(
    //         Apttus_Proposal__Proposal_Name__c = 'Change Order for ' + agreement.Name,
    //         CurrencyIsoCode = agreement.Apttus__Related_Opportunity__r.CurrencyIsoCode,
    //         Apttus_Proposal__Account__c = agreement.Apttus__Account__c,
    //         Apttus_Proposal__Opportunity__c = agreement.Apttus__Related_Opportunity__c,
    //         Apttus_QPConfig__PriceListId__c = agreement.Apttus_QPComply__RelatedProposalId__r.Apttus_QPConfig__PriceListId__c,
    //         Apttus_Proposal__Valid_Until_Date__c = Date.today().addDays(30),
    //         Apttus_Proposal__Primary_Contact__c = agreement.Apttus_QPComply__RelatedProposalId__r.Apttus_Proposal__Primary_Contact__c,
    //         Initial_Quote_Proposal__c = agreement.Apttus_QPComply__RelatedProposalId__c);
    // }
}