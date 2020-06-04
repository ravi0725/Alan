public class FC_SetAgreementStatusController {
    Apttus__APTS_Agreement__c agreement;
    public FC_SetAgreementStatusController(ApexPages.StandardController controller) {
        agreement = (Apttus__APTS_Agreement__c) controller.getRecord();
    }
    
    public PageReference setStatus() {
        System.debug(logginglevel.error, ApexPages.currentPage().getParameters());
        String status = ApexPages.currentPage().getParameters().get('status');
        String statusCategory = ApexPages.currentPage().getParameters().get('statusCategory');
        agreement.Apttus__Status__c = status;
        agreement.Apttus__Status_Category__c = statusCategory;
        agreement.Apttus__Other_Party_Signed_Date__c = Date.today();
        agreement.Apttus__Company_Signed_Date__c = Date.today();
        update agreement;
        
        return new PageReference('/' + agreement.Id);
    }
}