public virtual class FC_SendToPPMController {
    protected SObject record;
    protected FC_FusionProjectDefinitionPublicService prjClient;
    protected FC_FusionCustomerAccountService custClient;
    
    public FC_SendToPPMController(ApexPages.StandardController controller) {
        record = controller.getRecord();
        prjClient = new FC_FusionProjectDefinitionPublicService();
        custClient = new FC_FusionCustomerAccountService();
    }
    
    protected void mapValues(Object_Map__c objectMap, FC_FusionObject fusionObj) {
        Field_Map__c[] mappings = [select Date_Format__c, Default_Value__c, Field_Type__c, Object_Map__c, Prefix__c, Source_Field__c, Target_Field__c
            from Field_Map__c where Object_Map__c = :objectMap.Id];
        
        for (Field_Map__c m : mappings) {
            String textNodeValue;
            if (m.Source_Field__c != null) {
                
                Object sourceValue = record.get(m.Source_Field__c);
                if (sourceValue != null) {
                    if (sourceValue instanceOf Date) {
                        textNodeValue = FC_FusionUtil.getFusionDate((Date) sourceValue);
                    } else {
                        m.Prefix__c = m.Prefix__c == null ? '' : m.Prefix__c;
                        textNodeValue = String.valueOf(m.Prefix__c + sourceValue);
                    }
                }
            }
            if (String.isBlank(textNodeValue)) {
                textNodeValue = FC_FieldMapUtil.getDefaultValue(m.Default_Value__c);
            }
            
            fusionObj.setValue(m.Target_Field__c, FC_FusionProjectDefinitionPublicService.MAINTAIN_PROJ_NS, textNodeValue);
        }
        
    }
    
    protected String findCustomer(Id accountId) {
        Account acc = [select Name, FCH_Party_ID__c from Account where Id = :accountId];
        
        if (acc.FCH_Party_ID__c == null) {
            throw new FC_Exception('FCH Party Id not found for ' + acc.Name);
        }
        
        FC_FusionObject findCriteria = new FC_FusionObject('findCriteria', FC_FusionCustomerAccountService.TYPES_NS);
        findCriteria.setValue('fetchStart', FC_FusionService.ADF_TYPES_NS, 0);
        findCriteria.setValue('fetchSize', FC_FusionService.ADF_TYPES_NS, -1);
        findCriteria.setValue('findAttribute', FC_FusionService.ADF_TYPES_NS, 'PartyId');
        findCriteria.setValue('findAttribute', FC_FusionService.ADF_TYPES_NS, 'OriginalSystemReference');
        
        FC_FusionObject childFindCriteria = new FC_FusionObject('childFindCriteria', FC_FusionService.ADF_TYPES_NS);
        childFindCriteria.setValue('findAttribute', FC_FusionService.ADF_TYPES_NS, 'Status');
        childFindCriteria.setValue('findAttribute', FC_FusionService.ADF_TYPES_NS, 'OrigSystemReference');
        childFindCriteria.setValue('findAttribute', FC_FusionService.ADF_TYPES_NS, 'OrigSystem');
        childFindCriteria.setValue('childAttrName', FC_FusionService.ADF_TYPES_NS, 'OriginalSystemReference');
        findCriteria.setGroup(childFindCriteria);
        
        FC_FusionObject filter = new FC_FusionObject('filter', FC_FusionService.ADF_TYPES_NS);
        filter.setValue('conjunction', FC_FusionService.ADF_TYPES_NS, 'And');
        childFindCriteria.setGroup(filter);
        
        FC_FusionObject fusionGroup = new FC_FusionObject('group', FC_FusionService.ADF_TYPES_NS);
        fusionGroup.setValue('conjunction', FC_FusionService.ADF_TYPES_NS, 'And');
        filter.setGroup(fusionGroup);
        
        FC_FusionObject item = new FC_FusionObject('item', FC_FusionService.ADF_TYPES_NS);
        item.setValue('conjunction', FC_FusionService.ADF_TYPES_NS, 'And');
        item.setVAlue('attribute', FC_FusionService.ADF_TYPES_NS, 'Status');
        item.setVAlue('operator', FC_FusionService.ADF_TYPES_NS, '=');
        item.setVAlue('value', FC_FusionService.ADF_TYPES_NS, 'A');
        fusionGroup.setGroup(item);
        
        String bindOrigSystemReference = acc.FCH_Party_ID__c;
        String bindOrigSystem = 'FCH';
        
        FC_FusionResponse response = custClient.getCustomerAccountByOriginalSystemReference(findCriteria, bindOrigSystemReference, bindOrigSystem);
        Dom.XmlNode[] values = response.responseRoot.getChildElements()[0].getChildElements();
        Dom.XmlNode customerNode = getActiveOSRNode(values);
        if (customerNode == null) {
            throw new FC_Exception('Customer ' + acc.Name + ' (' + acc.FCH_Party_ID__c + ') not found in PPM');
        }
        
        return customerNode.getChildElement('PartyId', FC_FusionCustomerAccountService.ROOT_NS).getText();
    }
    
    private Dom.XmlNode getActiveOSRNode(Dom.XmlNode[] values) {
        for (Dom.XmlNode customer : values) {
            Dom.XmlNode[] childElements = customer.getChildElements();
            for (Dom.XmlNode childElement : childElements) {
                // If OriginalSystemReference node exists, it is active, since we set filter to only look for active OSR's
                if (childElement.getName() == 'OriginalSystemReference') {
                    return customer;
                }
            }
        }
        return null;
    }
    
    public virtual PageReference sendToPPM() { return null; }
    
    protected virtual void validate() { 
        if (String.isBlank((String) record.get('Template_Key__c'))) {
            throw new FC_Exception('Template Key is required to send to PPM!  Please update the template key under the Additional Details section to continue.');
        }
        if (String.isBlank((String) record.get('ProServ_Type__c'))) {
            throw new FC_Exception('If Professional Services = TRUE, the ProServ Type field cannot be blank.');
        }
        if (record.get('Apttus__Contract_End_Date__c')==Null) {
            throw new FC_Exception('Agreement End Date is required to send to PPM!  Please update the Agreement End Date to continue.');
        }
    }
}