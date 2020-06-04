public class FC_QuoteProposalHandler {
    @TestVisible static FC_FusionProjectDefinitionPublicService prjClient;
    @future(callout=true)
    public static void updatePPM(Id newProposalId) {
        Apttus__APTS_Agreement__c[] agreements = [select Fusion_Project_Id__c, Quote_Number__c, Apttus_QPComply__RelatedProposalId__r.Revenue_Arrangement_Number__c from Apttus__APTS_Agreement__c where Apttus_QPComply__RelatedProposalId__c = :newProposalId];
        if (agreements == null || agreements.size() == 0) {
            return;
        }
        prjClient = new FC_FusionProjectDefinitionPublicService();
        for (Apttus__APTS_Agreement__c agreement : agreements) {
            if (String.isNotBlank(agreement.Fusion_Project_Id__c)) {
                FC_FusionResponse response = prjClient.getProject(agreement.Fusion_Project_Id__c);
                if (!response.isSuccess) {
                    return;
                }
                String description = response.responseRoot.getChildElement('result', FC_FusionProjectDefinitionPublicService.TYPES_NS).
                    getChildElement('ProjectDescription', FC_FusionProjectDefinitionPublicService.MAINTAIN_PROJ_NS).getText();
                
                FC_FusionObject inProject = new FC_FusionObject('inProject', FC_FusionProjectDefinitionPublicService.TYPES_NS);
                inProject.setValue('ProjectDescription', FC_FusionProjectDefinitionPublicService.MAINTAIN_PROJ_NS, getDescription(description, agreement));
                inProject.setValue('ProjectId', FC_FusionProjectDefinitionPublicService.MAINTAIN_PROJ_NS, agreement.Fusion_Project_Id__c);
                response = prjClient.updateProject(inProject);
                if (!response.isSuccess) {
                    return;
                }
            }
        }
    }
    
    private static String getDescription(String prevDescription, Apttus__APTS_Agreement__c agreement) {
        String returnedDescription = '';
        String quoteText = 'Quote Number: ' + agreement.Quote_Number__c + 
            ';Revenue ArrangementNumber: ' + agreement.Apttus_QPComply__RelatedProposalId__r.Revenue_Arrangement_Number__c;
        Integer quoteIndex = prevDescription.toUpperCase().indexOf('QUOTE NUMBER:');
        if (quoteIndex == -1) {
            returnedDescription = prevDescription + '\n' + quoteText;
        } else {
            returnedDescription = prevDescription.left(quoteIndex) + quoteText;
        }
        return returnedDescription;
    }
}