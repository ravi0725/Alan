public class FC_SendToPPMFromProposalController extends FC_SendToPPMController {
    
    private Apttus_Proposal__Proposal__c proposal;
    
    public FC_SendToPPMFromProposalController(ApexPages.StandardController controller) {
        super(controller);
        proposal = (Apttus_Proposal__Proposal__c) record;
        
    }
    
    public override PageReference sendToPPM() {
        
        String ppmCustomerId;
        // try {
        //     ppmCustomerId = findCustomer(proposal.Apttus_Proposal__Account__c);
        // } catch (FC_FusionException ex) {
        //     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        // }
        
        Object_Map__c objectMap;
        try {
            objectMap = [select Id from Object_Map__c 
                where Source_Object__c = 'Apttus_Proposal__Proposal__c' and Target_Object__c = 'FC_FusionObject'];
        } catch (QueryException ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }
        
        FC_FusionObject inProject = new FC_FusionObject('inProject', FC_FusionProjectDefinitionPublicService.TYPES_NS);
            
        mapValues(objectMap, inProject);
        // FC_FusionObject projectCustomer = new FC_FusionObject('ProjectCustomer', FC_FusionProjectDefinitionPublicService.MAINTAIN_PROJ_NS);
        // projectCustomer.setValue('PartyId', FC_FusionProjectDefinitionPublicService.MAINTAIN_PROJ_NS, ppmCustomerId);
        // inProject.setGroup(projectCustomer);
        
        FC_FusionResponse response = prjClient.createProject(inProject);
        if (response.isSuccess) {
            // do something with response.responseRoot
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, response + ''));
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                'Error on creation of project. Fault code: ' + response.fault.faultCode + ', Fault string: ' + response.fault.faultString));
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, response + ''));
        return null;
    }
}