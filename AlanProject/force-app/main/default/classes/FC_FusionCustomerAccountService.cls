public with sharing class FC_FusionCustomerAccountService extends FC_FusionService {
    public static final String TYPES_NS = 'http://xmlns.oracle.com/apps/cdm/foundation/parties/customerAccountService/applicationModule/types/';
    public static final String ROOT_NS = 'http://xmlns.oracle.com/apps/cdm/foundation/parties/customerAccountService/';
    public static final String SERVICE_NAME = 'CustomerAccountService';
    
    public FC_FusionCustomerAccountService() {
        super(SERVICE_NAME);
    }
    
    // public FC_FusionResponse findCustomer(FC_FusionObject findCriteria) {
    //     Dom.Document soapDoc = getSoapEnvelope(new String[]{ TYPES_NS, ADF_TYPES_NS });
    //     Dom.XmlNode body = soapDoc.getRootElement().getChildElement('Body', SOAP_NS);
    //     Dom.XmlNode findCustomerAccount = body.addChildElement('findCustomerAccount', TYPES_NS, null);
    //     findCriteria.addAsChildTo(findCustomerAccount);
    //     return new FC_FusionResponse(send(soapDoc));
    // }
    
    public FC_FusionResponse getCustomerAccountByOriginalSystemReference(FC_FusionObject findCriteria, String bindOrigSystemReference, String bindOrigSystem) {
        Dom.Document soapDoc = getSoapEnvelope(new String[]{ TYPES_NS, ADF_TYPES_NS });
        Dom.XmlNode body = soapDoc.getRootElement().getChildElement('Body', SOAP_NS);
        Dom.XmlNode getCustomerAccount = body.addChildElement('getCustomerAccountByOriginalSystemReference', TYPES_NS, null);
        findCriteria.addAsChildTo(getCustomerAccount);
        getCustomerAccount.addChildElement('bindOrigSystemReference', TYPES_NS, null).addTextNode(bindOrigSystemReference);
        getCustomerAccount.addChildElement('bindOrigSystem', TYPES_NS, null).addTextNode(bindOrigSystem);
        return new FC_FusionResponse(send(soapDoc));
    }
}