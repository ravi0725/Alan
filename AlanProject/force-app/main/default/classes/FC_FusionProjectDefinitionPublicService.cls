public with sharing class FC_FusionProjectDefinitionPublicService extends FC_FusionService {
    
    public static final String MAINTAIN_PROJ_NS = 'http://xmlns.oracle.com/apps/projects/foundation/projectDefinition/publicService/maintainProjectV2/';
    public static final String DFF_NS = 'http://xmlns.oracle.com/apps/projects/foundation/projectDefinition/flex/ProjectDff/';
    public static final String TYPES_NS = 'http://xmlns.oracle.com/apps/projects/foundation/projectDefinition/publicService/maintainProjectV2/types/';
    public static final String SERVICE_NAME = 'ProjectDefinitionPublicServiceV2';
    
    public FC_FusionProjectDefinitionPublicService() {
        super(SERVICE_NAME);
    }
    
    public FC_FusionResponse createProject(FC_FusionObject inProject) {
        Dom.Document soapDoc = getSoapEnvelope(new String[]{ TYPES_NS, MAINTAIN_PROJ_NS });
        Dom.XmlNode body = soapDoc.getRootElement().getChildElement('Body', SOAP_NS);
        Dom.XmlNode createProject = body.addChildElement('createProject', TYPES_NS, null);
        inProject.addAsChildTo(createProject);

        HttpResponse resp = send(soapDoc);
        System.debug(LoggingLevel.ERROR, '**** HTTP Response: ' + resp.getBody());
        return new FC_FusionResponse(resp);
    }
    
    public FC_FusionResponse updateProject(FC_FusionObject inProject) {
        Dom.Document soapDoc = getSoapEnvelope(new String[]{ TYPES_NS, MAINTAIN_PROJ_NS });
        Dom.XmlNode body = soapDoc.getRootElement().getChildElement('Body', SOAP_NS);
        Dom.XmlNode updateProject = body.addChildElement('updateProject', TYPES_NS, null);
        inProject.addAsChildTo(updateProject);

        HttpResponse resp = send(soapDoc);
        System.debug(LoggingLevel.ERROR, '**** HTTP Response: ' + resp.getBody());
        return new FC_FusionResponse(resp);
    }
    
    public FC_FusionResponse getProject(String projectId) {
        Dom.Document soapDoc = getSoapEnvelope(new String[]{ TYPES_NS, MAINTAIN_PROJ_NS });
        Dom.XmlNode body = soapDoc.getRootElement().getChildElement('Body', SOAP_NS);
        Dom.XmlNode getProject = body.addChildElement('getProject', TYPES_NS, null);
        getProject.addChildElement('projectId', TYPES_NS, null).addTextNode(projectId);

        HTTPResponse resp = send(soapDoc);
        System.debug(LoggingLevel.ERROR, '**** HTTP Response: ' + resp.getBody());
        return new FC_FusionResponse(resp);
    }

}