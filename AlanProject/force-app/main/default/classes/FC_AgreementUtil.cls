/**
 * NOT BULK FRIENDLY
 */
public class FC_AgreementUtil {
    public static void addInfoToOpportunity(Id agreementId, Opportunity opp) {
        if (agreementId == null) {
            return;
        }
        Apttus__APTS_Agreement__c agreement = [select Name,
                Apttus_CMConfig__PriceListId__c, 
                Apttus__Related_Opportunity__r.Payment_Term__c, 
                Apttus__Related_Opportunity__r.ForecastCategoryName,
                Apttus__Related_Opportunity__r.Primary_Contact__c,
                Apttus__Related_Opportunity__r.Primary_Contact__r.Name,
                Apttus__Related_Opportunity__r.LeadSource,
                Apttus__Related_Opportunity__r.Selling_Division__c,
                Apttus__Related_Opportunity__r.Ship_To_Account__c,
                Apttus__Related_Opportunity__r.Opportunity_Product__c
                // Apttus__Related_Opportunity__r.Bill_to_Address_Disp__c,
                // Apttus__Related_Opportunity__r.Ship_to_Address_Disp__c,
                // Apttus__Related_Opportunity__r.Bill_To_Contact__r.Name,
                // Apttus__Related_Opportunity__r.Bill_To_Contact__c
            from Apttus__APTS_Agreement__c where Id = :agreementId];
        
        opp.Name = 'Change Order for ' + agreement.Name;
        opp.Payment_Term__c = agreement.Apttus__Related_Opportunity__r.Payment_Term__c;
        opp.Price_List__c = agreement.Apttus_CMConfig__PriceListId__c;
        opp.ForecastCategoryName = agreement.Apttus__Related_Opportunity__r.ForecastCategoryName;
        opp.Primary_Contact__c = agreement.Apttus__Related_Opportunity__r.Primary_Contact__c;
        opp.Primary_Contact__r = agreement.Apttus__Related_Opportunity__r.Primary_Contact__r;
        opp.LeadSource = agreement.Apttus__Related_Opportunity__r.LeadSource;
        opp.Selling_Division__c = agreement.Apttus__Related_Opportunity__r.Selling_Division__c;
        opp.Opportunity_Product__c = agreement.Apttus__Related_Opportunity__r.Opportunity_Product__c;
        // opp.Bill_To_Contact__c = agreement.Apttus__Related_Opportunity__r.Bill_To_Contact__c;
        // opp.Bill_To_Contact__r = agreement.Apttus__Related_Opportunity__r.Bill_To_Contact__r;
    }
    
    // public static void addInfoToProposal(Id agreementId, Apttus_Proposal__Proposal__c proposal) {
    //     Apttus__APTS_Agreement__c agreement = [select Apttus_QPComply__RelatedProposalId__c from Apttus__APTS_Agreement__c where Id = :agreementId];
    //     proposal.Initial_Quote_Proposal__c = agreement.Apttus_QPComply__RelatedProposalId__c;
    //     proposal.Initial_Agreement__c = agreement.Id;
    // }
}