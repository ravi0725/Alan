/**
 *  Apttus Config & Pricing
 *  AptsMetadataCallback
 *   
 *  @2016-2017 Apttus Inc. All rights reserved.
 */
global with sharing class AptsMetadataCallback implements Apttus_Config2.CustomClass.IMetaDataCallback {
    
    private static Map<String, Schema.SObjectType> typeMap;
    
    /**
     * return OBject type for SObject, to avoid global describe
     * @param sObjectName name of the sObject that triggers global describe when this callback is not implemented
     */
    global Schema.SObjectType getSObjectType(String sObjectName) {
        if (sObjectName == 'ClassificationHierarchy__c') {
          return Apttus_Config2__ClassificationHierarchy__c.getSObjectType();
        
        } else if (sObjectName == 'Apttus_Config2__ClassificationHierarchy__c') {
          return Apttus_Config2__ClassificationHierarchy__c.getSObjectType();
        
        }
        
        System.debug(LoggingLevel.INFO, 'getGlobalDescribe for sObjectName = ' + sObjectName);
        // get the sobject type for the given name
        if (typeMap == null) {
            typeMap = new Map<String, Schema.SObjectType>();
            
            Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
            for (Schema.SObjectType value : gd.values()) {
                typeMap.put(('' + value).toUpperCase(), value);
            
            }
            
        }
        
        return typeMap.get(sObjectName.toUpperCase());  
         
    }
    
}