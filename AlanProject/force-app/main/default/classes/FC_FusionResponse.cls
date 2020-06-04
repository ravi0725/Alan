public virtual class FC_FusionResponse {
    
    protected HttpResponse resp;
    protected Dom.Document soapDoc;
    public Dom.XmlNode responseRoot;
    public Boolean isSuccess { get; private set; }
    public String status { get; private set; }
    public FC_FusionFault fault { get; private set; }
    
    public FC_FusionResponse(HttpResponse response) {
        resp = response;
        status = resp.getStatus();
        Dom.Document soapDoc = resp.getBodyDocument();
        responseRoot = soapDoc.getRootElement().getChildElement('Body', FC_FusionService.SOAP_NS).getChildElements()[0];
        System.debug(LoggingLevel.ERROR, '+++++ FC_FusionResponse Reponse: '+response.getBody());
        System.debug(LoggingLevel.ERROR, 'Response code: ' + resp.getStatusCode());
        if (resp.getStatusCode() == 200) {
            isSuccess = true;
        } else if (resp.getStatusCode() == 500) {
            fault = new FC_FusionFault(soapDoc);
            isSuccess = false;
        } else {
            isSuccess = false;
        }
    }
}