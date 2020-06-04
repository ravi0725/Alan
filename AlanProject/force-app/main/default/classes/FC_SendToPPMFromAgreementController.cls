public class FC_SendToPPMFromAgreementController extends FC_SendToPPMController {
    
    private Apttus__APTS_Agreement__c agreement;
    private Apttus__APTS_Agreement__c enhancedAgreement;
    
    public FC_SendToPPMFromAgreementController(ApexPages.StandardController controller) {
        super(controller);
        agreement = (Apttus__APTS_Agreement__c) record;
        enhancedAgreement = [select Apttus__Related_Opportunity__r.Mavenlink_Project_Number__c,Apttus_QPComply__RelatedProposalId__r.Bill_To_Contact__r.AccountId,Apttus_QPComply__RelatedProposalId__r.Bill_To_Contact__c,
                             Apttus_QPComply__RelatedProposalId__r.Apttus_Proposal__Primary_Contact__r.AccountId, Apttus_QPComply__RelatedProposalId__r.Apttus_Proposal__Primary_Contact__c,
                             Apttus_QPComply__RelatedProposalId__r.Revenue_Arrangement_Number__c from Apttus__APTS_Agreement__c where Id = :agreement.Id];
    }
    
    public override PageReference sendToPPM() {
       /* try {
            validate();
        } catch (FC_Exception ex) {
            System.debug(LoggingLevel.ERROR, 'Exception: ' + ex.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;   
        }
        
        String ppmCustomerId;
        try {
            ppmCustomerId = findCustomer(agreement.Apttus__Account__c);
        } catch (FC_FusionException ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        } catch (FC_Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }
        
        Object_Map__c objectMap;
        try {
            objectMap = [select Id from Object_Map__c 
                where Source_Object__c = 'Apttus__APTS_Agreement__c' and Target_Object__c = 'FC_FusionObject'];
        } catch (QueryException ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }
        
        FC_FusionObject inProject = new FC_FusionObject('inProject', FC_FusionProjectDefinitionPublicService.TYPES_NS);
            
        mapValues(objectMap, inProject);
        inProject.setValue('ProjectDescription', FC_FusionProjectDefinitionPublicService.MAINTAIN_PROJ_NS, getDescription('', agreement));
        inProject.setValue('TemplateKey', FC_FusionProjectDefinitionPublicService.MAINTAIN_PROJ_NS, agreement.Template_Key__c.split(':')[0]);

        FC_FusionObject projectCustomer = new FC_FusionObject('ProjectCustomer', FC_FusionProjectDefinitionPublicService.MAINTAIN_PROJ_NS);
        projectCustomer.setValue('PartyId', FC_FusionProjectDefinitionPublicService.MAINTAIN_PROJ_NS, ppmCustomerId);
        inProject.setGroup(projectCustomer);
        
        FC_FusionResponse response = prjClient.createProject(inProject);
        if (!response.isSuccess) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                'Error on creation of project. Fault code: ' + response.fault.faultCode + ', Fault string: ' + response.fault.faultString));
            return null;
        }else if(enhancedAgreement != null){
            Map<Id,Id> contactIdMap = new Map<Id,Id>();
            if(enhancedAgreement.Apttus_QPComply__RelatedProposalId__r.Apttus_Proposal__Primary_Contact__c != null)
                contactIdMap.put(enhancedAgreement.Apttus_QPComply__RelatedProposalId__r.Apttus_Proposal__Primary_Contact__c,enhancedAgreement.Apttus_QPComply__RelatedProposalId__r.Apttus_Proposal__Primary_Contact__r.AccountId);
            if(enhancedAgreement.Apttus_QPComply__RelatedProposalId__r.Bill_To_Contact__c != null)
                contactIdMap.put(enhancedAgreement.Apttus_QPComply__RelatedProposalId__r.Bill_To_Contact__c,enhancedAgreement.Apttus_QPComply__RelatedProposalId__r.Apttus_Proposal__Primary_Contact__r.AccountId);
            try {
                for(Id conId : contactIdMap.keySet()){
                    List<String> accIdList = new List<String>();
                    set<String> conIdSet = new set<String>();
                    accIdList.add(contactIdMap.get(conId));
                    conIdSet.add(conId);
                    AccountCreationCalloutEX.makeCallOut(accIdList,'NoOp','Update','NoOp',conIdSet,new set<String>(),new set<String>());
                }
            }catch (Exception ex) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
                return null;
            }
        }
        Dom.XmlNode value = response.responseRoot.getChildElement('result', FC_FusionProjectDefinitionPublicService.TYPES_NS).
            getChildElement('Value', FC_FusionProjectDefinitionPublicService.MAINTAIN_PROJ_NS);*/
        
        //agreement.Fusion_Project_Id__c = value.getChildElement('ProjectId', FC_FusionProjectDefinitionPublicService.MAINTAIN_PROJ_NS).getText();
        if(enhancedAgreement != null && enhancedAgreement.Apttus__Related_Opportunity__r.Mavenlink_Project_Number__c != null) agreement.Fusion_Project_Number__c = enhancedAgreement.Apttus__Related_Opportunity__r.Mavenlink_Project_Number__c;
        update agreement;
        
       /* ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Project \'' + 
            value.getChildElement('ProjectName', FC_FusionProjectDefinitionPublicService.MAINTAIN_PROJ_NS).getText() + '\' has been created successfully.'));*/
        
        return null;
    }
    
    public override void validate() {
        super.validate();
        if ([select Id from Apttus__AgreementLineItem__c where Apttus__AgreementId__c = :agreement.Id and Product_Family_Text__c like '%Professional Services'].size() == 0) {
            throw new FC_Exception('This agreement has no proserv line items.  It cannot be sent to PPM.');
        }
    }
    
    // private PageReference updatePPM() {

    //     FC_FusionResponse response = prjClient.getProject(agreement.Fusion_Project_Id__c);
    //     if (!response.isSuccess) {
    //         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
    //             'Error on getProject. Fault code: ' + response.fault.faultCode + ', Fault string: ' + response.fault.faultString));
    //         return null;
    //     }
    //     String description = response.responseRoot.getChildElement('result', FC_FusionProjectDefinitionPublicService.TYPES_NS).
    //         getChildElement('ProjectDescription', FC_FusionProjectDefinitionPublicService.MAINTAIN_PROJ_NS).getText();
        
    //     FC_FusionObject inProject = new FC_FusionObject('inProject', FC_FusionProjectDefinitionPublicService.TYPES_NS);
    //     inProject.setValue('ProjectDescription', FC_FusionProjectDefinitionPublicService.MAINTAIN_PROJ_NS, getDescription(description, agreement));
    //     inProject.setValue('ProjectId', FC_FusionProjectDefinitionPublicService.MAINTAIN_PROJ_NS, agreement.Fusion_Project_Id__c);
    //     response = prjClient.updateProject(inProject);
    //     if (!response.isSuccess) {
    //         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
    //             'Error on creation of project. Fault code: ' + response.fault.faultCode + ', Fault string: ' + response.fault.faultString));
    //         return null;
    //     }
    //     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Project has been updated successfully.'));
    //     return null;
    // }
    
    /*private String getDescription(String prevDescription, Apttus__APTS_Agreement__c agreement) {
        String returnedDescription = '';
        String quoteText = 'Quote Number: ' + agreement.Quote_Number__c + 
            ';Revenue Arrangement Number: ' + enhancedAgreement.Apttus_QPComply__RelatedProposalId__r.Revenue_Arrangement_Number__c;
        Integer quoteIndex = prevDescription.toUpperCase().indexOf('QUOTE NUMBER:');
        if (quoteIndex == -1) {
            returnedDescription = prevDescription + quoteText;
        } else {
            returnedDescription = prevDescription.left(quoteIndex) + quoteText;
        }
        return returnedDescription;
    }*/
}