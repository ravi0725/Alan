@isTest
private class FC_TestFusionFault {
    static testMethod void testFusionFault() {
        // create fault envelope
        Dom.Document doc = new Dom.Document();
        Dom.XmlNode envelope = doc.createRootElement('Envelope', FC_FusionService.SOAP_NS, 'soapenv');
        Dom.XmlNode fault = envelope.addChildElement('Body', FC_FusionService.SOAP_NS, null).addChildElement('Fault', FC_FusionService.SOAP_NS, null);
        fault.addChildElement('faultcode', null, null).addTextNode('fault code');
        fault.addChildElement('faultstring', null, null).addTextNode('sample fault string');
        
        FC_FusionFault f = new FC_FusionFault(doc);
        System.assertEquals('fault code', f.faultCode);
        System.assertEquals('sample fault string', f.faultString);
        
    }
}