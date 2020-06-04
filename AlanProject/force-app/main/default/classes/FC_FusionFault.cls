public class FC_FusionFault {
    public String faultCode { get; private set; }
    public String faultString { get; private set; }
    
    public FC_FusionFault(Dom.Document soapDoc) {
        Dom.XmlNode fault = soapDoc.getRootElement().getChildElement('Body', FC_FusionService.SOAP_NS).getChildElements()[0];
        System.debug(LoggingLevel.ERROR, 'Fault: ' + fault);
        if (fault != null) {
            faultCode = fault.getChildElement('faultcode', null).getText();
            faultString = fault.getChildElement('faultstring', null).getText();
        }
    }
}