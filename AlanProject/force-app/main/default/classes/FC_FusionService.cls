public virtual class FC_FusionService {
    public static final String SOAP_NS = 'http://schemas.xmlsoap.org/soap/envelope/';
    public static final String ADF_TYPES_NS = 'http://xmlns.oracle.com/adf/svc/types/';
    public static final String ADF_ERROR_NS = 'http://xmlns.oracle.com/adf/svc/errors/';

    protected String username;
    protected String password;
    protected String endpoint;
    protected Integer TimeOut;
    protected Http h;
    protected HttpRequest req;
    protected Fusion_Configuration__c fusionConfig;
    protected FusionServicesConfig__c serviceConfig;
    
    public FC_FusionService(String serviceName) {
        fusionConfig = Fusion_Configuration__c.getInstance();
        serviceConfig = FusionServicesConfig__c.getInstance(serviceName);
        username = fusionConfig.Username__c;
        password = fusionConfig.Password__c;
        endpoint = fusionConfig.Endpoint__c.replace('<subdomain>', serviceConfig.Sub_Domain__c);
        Timeout = Integer.valueof(fusionConfig.Timed_Out__c);
        h = new Http();
        req = new HttpRequest();
        req.setEndpoint(endpoint + '/' + serviceConfig.Service_Path__c);
        req.setMethod('POST');
        req.setTimeout(TimeOut);
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'BASIC ' +
        EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type', 'text/xml;charset=UTF-8');

    }
    
    protected HttpResponse send(Dom.Document soapDoc) {
        String xmlString = soapDoc.toXmlString();
        System.debug(LoggingLevel.ERROR, '**** HTTP Request: ' + req);
        System.debug(LoggingLevel.ERROR, '**** HTTP Request: ' + xmlString);
        req.setBody(xmlString);
        HttpResponse resp = h.send(req);
        FC_HttpLogger.log(req, resp);
        System.debug(LoggingLevel.ERROR, '**** HTTP Response: ' + resp.getBody());
        system.debug(loggingLevel.ERROR, 'HTTP status Code: ' + resp.getStatusCode());
        if (resp.getStatusCode() != 200 && resp.getStatusCode() != 500) { 
            throw new FC_FusionException(resp);
        }
        return resp;
    }
    
    protected Dom.Document getSoapEnvelope(String[] namespaces) {
        Dom.Document doc = new Dom.Document();
        Dom.XmlNode envelope = doc.createRootElement('Envelope', SOAP_NS, 'soapenv');
        for (Integer i = 0; i < namespaces.size(); i++) {
            envelope.setNamespace('ns' + i, namespaces[i]);
        }
        envelope.addChildElement('Body', SOAP_NS, null);
        return doc;
    }
}