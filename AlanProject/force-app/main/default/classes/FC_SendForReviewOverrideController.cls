public class FC_SendForReviewOverrideController {
    Apttus__APTS_Agreement__c agreement;
    public FC_SendForReviewOverrideController(ApexPages.StandardController controller) {
        agreement = (Apttus__APTS_Agreement__c) controller.getRecord();
    }
    
    public PageReference setField() {
        /** The status is updated on the trigger. We just need to set a flag to true so we know status to update to.
        Needs to be done in the after phase due to Apttus workflows interfering in the before **/
        // String fieldToSet = ApexPages.currentPage().getParameters().get('fieldToSet');
        // agreement.put(fieldToSet, true);
        agreement.Sent_for_Internal_Review__c = true;
        update agreement;
        return new PageReference('/apex/Apttus__SendEmail?id=' + agreement.Id + '&action=Send_To_Other_Party_For_Review');
    }
}