public with sharing class Utils{ 
     public static boolean SkipFieldTracking = false;
    // Returns a dynamic SOQL statement for the whole object, includes only creatable fields since we will be inserting a cloned result of this query
    public static string getCreatableFieldsSOQL(String objectName, String whereClause){
         
        String selects = '';
         
        if (whereClause == null || whereClause == ''){ return null; }
         
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
         
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
         
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
             
        }
         
        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;
         
    }
    
    
    public static set<Id> verifyFieldUpdate(Map<Id,sObject> newMap, Map<Id,sObject> oldMap,String sObjectName,String IntegrationName,String NamePrefix){
        boolean fieldUpdateFlag = false; 
        set<Id> ids = new set<Id>();
        List<String> fieldList = new List<String>();
        system.debug('----------IntegrationName------' + IntegrationName);
        system.debug('----------sObjectName------' + sObjectName);
        system.debug('----------NamePrefix------' + NamePrefix);
        for(Track_Field_Update__c temp : Track_Field_Update__c.getAll().values()){
            if(temp.Integration_Name__c == IntegrationName && temp.Object__c == sObjectName){
                fieldList.add(temp.Name.replaceAll(NamePrefix + '/',''));
            }
        }
        //try{
        for(sObject obj : newMap.values()){
            for(String field : fieldList){
                system.debug('----------field------' + field);
                system.debug(obj.get(field) + '----------field------' + oldMap.get((Id)obj.get('Id')).get(field));
                if(obj.get(field) != oldMap.get((Id)obj.get('Id')).get(field) || SkipFieldTracking){
                    ids.add((Id)obj.get('Id'));
                    break;
                }
            }
        }
        system.debug('----------ids------' + ids);
        return ids;
    } 
}