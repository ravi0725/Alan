@isTest
private class FC_TestFusionObject {
    static testMethod void testFusionObject() {
        FC_FusionObject inProject = new FC_FusionObject('inProject', 'ns1');
        inProject.setValue('textfield', 'namespace', 'test text');
        inProject.setvalue('datefield', 'namespace', Date.today());
        
        System.assertEquals('test text', (String) inProject.getValue('textfield'));
        System.assertEquals(Date.today(), (Date) inProject.getValue('datefield'));
        Boolean caughtException = false;
        try {
            Object obj = inProject.getValue('nonexistentfield');
        } catch (FC_Exception ex) {
            caughtException = true;
        }
        System.assert(caughtException);
        
        
        Dom.Document doc = new Dom.Document();
        Dom.XmlNode envelope = doc.createRootElement('Envelope', 'soapNS', 'soapenv');
        Dom.XmlNode body = envelope.addChildElement('Body', 'soapNS', null);
        inProject.addAsChildTo(body);
        System.assertEquals('inProject', body.getChildElement('inProject', 'ns1').getName());
    }
}