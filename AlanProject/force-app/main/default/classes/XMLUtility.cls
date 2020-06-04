/*****************************************************************************************
Name    : XMLUtility
Desc    : Used to parse renewal Opportunity data came as XML format from Oracle

Modification Log : 
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
Ankur Patel       12/11/2013          Created
******************************************************************************************/
public class XMLUtility {
    public static XmlStreamReader readerObj;
    public static Map<String,String> targetObjMap;
    public static Map<String,Map<String,Field_Map__c>> paramMap;
    public static Map<String,String> responseMap;
    public static Map<String,String> resultMap;
    public static String responseXMLString;
    public static String uniqueIdentifier;
    public static String uniqueIdentifierValue;
    public static Map<String, Map<String,String>> referenceFieldMap;
    public static Map<String,String> salesforceInternalObjectMap;
    public static Set<String> mepnaContractGroups;
    public static boolean mepnaCancelledStatusFlag;
    public static boolean mepnaDeleteLineFlag;
    public static Map<String, Integer> months = new Map <String, Integer> {'JAN'=>1, 'FEB'=>2,
        'MAR'=>3, 'APR'=>4, 'MAY'=>5, 'JUN'=>6, 'JUL'=>7, 'AUG'=>8, 'SEP'=>9,
        'OCT'=>10, 'NOV'=>11, 'DEC'=>12};
            
    //Method to get Object Map and Field Map for Renewal opportunity
    public static Map<String,List<sObject>> getSObjectMap(String XMLData,String integrationType){
        resultMap = new Map<String,String>();
        responseMap = new Map<String,String>();
        getIntegrationParams(integrationType);
        return parseXMLData(XMLData);
    }
    
    //Method to retrieve MEPNA contract groups
    public static Set<String> getMEPNAContractGroups(){
        Set<String> contractGroups = new Set<String>();
        for(MEPNA_Renewal_Contract_Group__mdt contractGroup : [select MasterLabel from MEPNA_Renewal_Contract_Group__mdt]){
            contractGroups.add(contractGroup.MasterLabel);
        }
        return contractGroups;
    }
    
    //Prepare parameter map for Opportunity and Opportunity line item
    public static void getIntegrationParams(String integrationType){
        targetObjMap = new Map<String,String>();
        paramMap = new Map<String,Map<String,Field_Map__c>>();
        salesforceInternalObjectMap = new Map<String,String>();
        mepnaContractGroups = getMEPNAContractGroups();
        for(Field_Map__c fieldMap : [select Id,Reference_Field__c,Unique_Identifier__c,Default_Value__c,Reference_Query__c,Object_Map__r.Source_Object__c,
                                        Object_Map__r.Target_Object__c,Target_Field__c,Source_Field__c, Object_Map__r.Source_Type__c from Field_Map__c 
                                            where Object_Map__r.Name like : (integrationType + '%')]){
            if(fieldMap.Object_Map__r.Source_Type__c == 'Salesforce')salesforceInternalObjectMap.put(fieldMap.Object_Map__r.Target_Object__c,fieldMap.Object_Map__r.Source_Object__c);
            if(!paramMap.containsKey(fieldMap.Object_Map__r.Target_Object__c))paramMap.put(fieldMap.Object_Map__r.Target_Object__c,new Map<String,Field_Map__c>());
            paramMap.get(fieldMap.Object_Map__r.Target_Object__c).put((fieldMap.Source_Field__c == null || fieldMap.Source_Field__c == '' ? fieldMap.Target_Field__c : fieldMap.Source_Field__c),fieldMap);
            targetObjMap.put(fieldMap.Object_Map__r.Source_Object__c,fieldMap.Object_Map__r.Target_Object__c);
        }
        system.debug('------paramMap------' + paramMap);
        system.debug('------targetObjMap------' + targetObjMap);
    }
    
    //Parse XML payload
    public static Map<String,List<sObject>> parseXMLData(String XMLData) {
        Map<String,List<sObject>> sObjectMap = new Map<String,List<sObject>>();
        readerObj = new XmlStreamReader(XMLData);
        readerObj.setCoalescing(true);
        boolean isSafeToGetNextXmlElement = true;
        responseXMLString = '';
        uniqueIdentifier = '';
        uniqueIdentifierValue = '';
        referenceFieldMap = new Map<String,Map<String,String>>();
        mepnaCancelledStatusFlag = false;
        mepnaDeleteLineFlag = false;
        CreateRenewalOpportunityFromEBS.setCoveredLineIds = new set<String>();
        while(isSafeToGetNextXmlElement) {
            system.debug('------getEventType------' + readerObj.getEventType());
            if (readerObj.getEventType() == XmlTag.START_ELEMENT) {
                String localName = readerObj.getLocalName();
                system.debug('------localName------' + localName);
                system.debug(targetObjMap + '------getLocalName---1---' + readerObj.getLocalName());
                if (readerObj.hasNext() && 'ROW' != readerObj.getLocalName()){
                    readerObj.next();
                }else if(!readerObj.hasNext()){
                    isSafeToGetNextXmlElement = false;
                    break;
                }
                system.debug('--chandra2--'+readerObj.getEventType());
                if(readerObj.getEventType() == XMLTag.CHARACTERS ){
                    system.debug('------getLocalName---2---' + localName);
                    generateResponse(localName);
                    system.debug('------responseMap------' + responseMap);
                    if(targetObjMap.containsKey(readerObj.getText())){
                        String dataType = readerObj.getText();
                        sObject obj = parseData(targetObjMap.get(dataType));
                        if(obj != null){
                            system.debug('------obj------' + obj);
                            system.debug(mepnaCancelledStatusFlag + '------mepnaContractGroups------' + mepnaContractGroups);
                            if(mepnaDeleteLineFlag){
                                if(obj.get('CoveredLineId__c') != null)CreateRenewalOpportunityFromEBS.setCoveredLineIds.add(String.valueOf(obj.get('CoveredLineId__c')));
                                mepnaDeleteLineFlag = false;
                            }else if(targetObjMap.get(dataType) == 'Opportunity' ? (mepnaContractGroups.contains(String.valueOf(obj.get('ContractGroup__c')))  && mepnaCancelledStatusFlag) : false){
                                if(targetObjMap.get(dataType) == 'Opportunity')obj.put('Renewal_Status__c','New');
                                if(!sObjectMap.containsKey(targetObjMap.get(dataType) + 'Update'))
                                    sObjectMap.put(targetObjMap.get(dataType) + 'Update',New List<sObject>());
                                sObjectMap.get(targetObjMap.get(dataType) + 'Update').add(obj);
                                mepnaCancelledStatusFlag = false;
                            }else{
                                if(targetObjMap.get(dataType) == 'Opportunity')obj.put('Renewal_Status__c','New');
                                if(!sObjectMap.containsKey(targetObjMap.get(dataType)))
                                    sObjectMap.put(targetObjMap.get(dataType),New List<sObject>());
                                sObjectMap.get(targetObjMap.get(dataType)).add(obj);
                                mepnaCancelledStatusFlag = false;
                            }
                        }
                    }
                }
            }
            if (readerObj.hasNext()) {
                readerObj.next();
            } else {
                isSafeToGetNextXmlElement = false;
                break;
            }
        }
        system.debug('-------referenceFieldMap---------' + referenceFieldMap);
        Map<String,String> referenceFieldSFDCIdMap = new Map<String,String>();
        for(String objectAPIName : targetObjMap.values()){
            if(paramMap.containsKey(objectAPIName)){
                for(String referenceField : referenceFieldMap.keySet()){
                    if(paramMap.get(objectAPIName).containsKey(referenceField) && sObjectMap.containskey(objectAPIName)){
                        List<String> tagValue = new List<String>();
                        tagValue = referenceFieldMap.get(referenceField).values();
                        system.debug(objectAPIName+ '-------tagValue---------' + tagValue);
                        for(sObject obj : database.query(paramMap.get(objectAPIName).get(referenceField).Reference_Query__c)){
                            referenceFieldSFDCIdMap.put((String)obj.get(paramMap.get(objectAPIName).get(referenceField).Reference_Field__c),(Id)obj.get('Id'));
                        }
                        system.debug(objectAPIName + '-------referenceFieldSFDCIdMap---------' + referenceFieldSFDCIdMap);
                        for(SObject obj : sObjectMap.get(objectAPIName)){
                            if(referenceFieldMap.get(referenceField).containsKey((String)obj.get(uniqueIdentifier)) ?
                              referenceFieldSFDCIdMap.containsKey(referenceFieldMap.get(referenceField).get((String)obj.get(uniqueIdentifier))) : false){
                                Id accId = referenceFieldSFDCIdMap.get(referenceFieldMap.get(referenceField).get((String)obj.get(uniqueIdentifier)));
                                obj.put(paramMap.get(objectAPIName).get(referenceField).Target_Field__c,accId);
                            }
                        }
                    }
                }
            }
        }
        system.debug('-------sObjectMap---------' + sObjectMap);
        return sObjectMap;
    }
    

    // Parse through the XML, determine the author and the characters
    public static sObject parseData(String SfdcObjectAPIName){
        Sobject genericObject;
        Schema.SObjectType convertType = Schema.getGlobalDescribe().get(SfdcObjectAPIName);
        genericObject = convertType.newSObject();
        boolean isSafeToGetNextXmlElement = true;
        while(isSafeToGetNextXmlElement) {
            if(readerObj.getEventType() == XmlTag.START_ELEMENT){
                String localName = readerObj.getLocalName();
                system.debug('------getLocalName---3---' + localName);
                if(localName == 'RECORD_TYPE'){
                    readerObj.next();
                    if(readerObj.getEventType() == XMLTag.CHARACTERS ){
                        mepnaCancelledStatusFlag = (readerObj.getText() == 'CANCELLED');
                        mepnaDeleteLineFlag = (readerObj.getText() == 'DEL');
                    }
                }
                
                if(paramMap.get(SfdcObjectAPIName).containsKey(localName)){
                    String fieldName = localName;
                    readerObj.next();
                    if(readerObj.getEventType() == XMLTag.CHARACTERS ){
                        generateResponse(localName);
                        system.debug(SfdcObjectAPIName + '-------fieldName----------' + fieldName);
                        String SfdcFieldAPIName = paramMap.get(SfdcObjectAPIName).get(fieldName).Target_Field__c;
                        
                        String dataType = getDataType(SfdcObjectAPIName,SfdcFieldAPIName);
                        system.debug(fieldName + '------fieldName------' + readerObj.getText());
                        if(readerObj.getText() != null && readerObj.getText() != ''){
                            convertValue(genericObject,localName,SfdcObjectAPIName,SfdcFieldAPIName,fieldName,dataType,readerObj.getText());
                        } 
                    }
                }
            }
            if (readerObj.hasNext()) {
                readerObj.next();
                if('ROW' == readerObj.getLocalName() &&  readerObj.getEventType() == XmlTag.END_ELEMENT){
                    isSafeToGetNextXmlElement = false;
                }
            }
        }
        system.debug(uniqueIdentifierValue + '------responseXMLString------' + responseXMLString);
        responseMap.put(uniqueIdentifierValue,responseXMLString);
        responseXMLString = ''; 
        system.debug('------responseMap------' + responseMap);
        for(Field_Map__c fieldMap : paramMap.get(SfdcObjectAPIName).values()){
            if(fieldMap.Default_Value__c != null && fieldMap.Default_Value__c != ''){
                genericObject.put(fieldMap.Target_Field__c,fieldMap.Default_Value__c);
            }
        }
        system.debug(uniqueIdentifier + '------uniqueIdentifier------' + uniqueIdentifierValue);
        genericObject.put(uniqueIdentifier,uniqueIdentifierValue);
        if (readerObj.hasNext()) {
            readerObj.next();
        }
        system.debug('------genericObject------' + genericObject);
        return genericObject;
    }
    
    //Generate response in XML format to send back to Oracle
    public static void generateResponse(String localName){
        if(paramMap.containsKey('Response') ? paramMap.get('Response').containsKey(localName) : false){
            responseXMLString = responseXMLString + '<' + localName + '>' + readerObj.getText() + '</' + localName + '>';
            system.debug(readerObj.getText() + '------responseXMLString------' + responseXMLString);
            system.debug(localName + '------localName------' + paramMap.get('Response').get(localName).Unique_Identifier__c);
            if(paramMap.get('Response').get(localName).Unique_Identifier__c){
                responseMap.put(readerObj.getText(),'');
                uniqueIdentifier = paramMap.get('Response').get(localName).Target_Field__c;
                uniqueIdentifierValue = readerObj.getText();
            }
        }
    }

   
    //Validate mandatory fields to Create Renewal Opportunity and Opportunity Line Item
    public static List<sObject> validateRequiredField(String interfaceName,String sObjectType,List<sObject> sObjectList){
        String finalResponse = '';
        set<string> fieldSet = new set<String>();
        List<sObject> newsObjectList = new List<sObject>();
        List<WS_Interface_Log__c> logList = new List<WS_Interface_Log__c>();
        for(Object_Map__c objMap : [select Required_Fields__c from Object_Map__c where  
                                    Name like : interfaceName + '%' and Target_Object__c =: sObjectType limit 1]){
            if(objMap.Required_Fields__c != null){
                for(sObject obj : sObjectList){
                    if(obj.get(uniqueIdentifier) != null){
                        boolean flag = true;
                        if(XMLUtility.responseMap.containskey((String)obj.get(uniqueIdentifier))){
                            String msg = '';
                            for(String field : objMap.Required_Fields__c.split(',')){
                                field = field.trim();
                                if(obj.get(field) == null){
                                    msg = 'Error :';
                                    msg = msg + '\n' + field + ' is required field value missing.';
                                    flag = false;
                                }
                            }
                            finalResponse = finalResponse + '<ROW>' + XMLUtility.responseMap.get((String)obj.get(uniqueIdentifier));
                            finalResponse = finalResponse + '<STATUS>FAILED</STATUS><ERRORMESSAGE>' + msg + '</ERRORMESSAGE></ROW>';
                            if(!flag)setResultMap((String)obj.get(uniqueIdentifier),finalResponse);
                            if(msg != ''){
                                WS_Interface_Log__c il = new WS_Interface_Log__c();
                                il.Interface__c = 'Renewal';
                                il.ComponentName__c = 'CreateRenewalOpportunityFromEBS';
                                il.MethodName__c = 'upsertRecord Method';
                                il.ExceptionDetails__c = msg;
                                il.Exception__c = 'Required Field\'s values missing.  Please see the Exception details.';
                                il.Timestamp__c = string.valueOf(system.Now());
                                il.Description__c = XMLUtility.responseMap.get((String)obj.get(uniqueIdentifier));
                                logList.add(il);
                            }
                        }
                        system.debug((String)obj.get(uniqueIdentifier) + '------finalResponse------' + finalResponse);
                        finalResponse = '';
                        if(flag)newsObjectList.add(obj);
                    }
                }
            }else{
                newsObjectList.addAll(sObjectList);
            }
        }
        if(logList.size() > 0){
            insert logList;
        }
        logList.clear();
        
        return newsObjectList;
    }
    
    //Prepare result map
    public static void setResultMap(String key,String result){
        resultMap.put(key, (resultMap.containsKey(key) ? resultMap.get(key) + '\n' + result : result));
    }
    
    //Convert string to specific data type based on the target field of Opportunity and Opportunity line Item
    public static void convertValue(sObject obj,String localName,String SfdcObjectAPIName,String SfdcFieldAPIName, String paramFieldName, String dataType, String fieldValue){
        system.debug('--Field--     ObjApi---'+SfdcObjectAPIName+'  fieldApi--'+SfdcFieldAPIName+'  param--'+paramFieldName+'  dataType--'+dataType+'  fieldValue--'+fieldValue);
        if(dataType == 'TEXT'){
            obj.put(SfdcFieldAPIName,fieldValue);
        }else if(dataType == 'DATETIME'){
            List<string> dt = fieldValue.split('-');
            Datetime servcDatetime = Datetime.parse(months.get(dt[1])+'/'+dt[0]+'/'+dt[2]+' 00:00 AM');
            system.debug('--servcDatetime--'+servcDatetime);
            obj.put(SfdcFieldAPIName,servcDatetime);
            //obj.put(SfdcFieldAPIName,DateTime.parse(fieldValue));
        }else if(dataType == 'DATE'){
            system.debug('---------fieldValue---------'+ fieldValue);
            List<string> dt = fieldValue.split('-');
            Date servcDate = Date.parse(months.get(dt[1])+'/'+dt[0]+'/'+dt[2]);
            system.debug('--servcDate--'+servcDate);
            obj.put(SfdcFieldAPIName,servcDate);
            //obj.put(SfdcFieldAPIName,date.parse(fieldValue));
        }else if(dataType == 'DECIMAL'){
            obj.put(SfdcFieldAPIName,Decimal.valueOf(fieldValue));
        }else if(dataType == 'BOOLEAN'){
            if(fieldValue.equals('Yes') || fieldValue.equals('YES') || 
               fieldValue.equals('1') || fieldValue.equals('true') ||
               fieldValue.equals('True') || fieldValue.equals('TRUE'))
                obj.put(SfdcFieldAPIName,true);
            else
                obj.put(SfdcFieldAPIName,false);
        }else if(dataType == 'REFERENCE' && fieldValue != null && fieldValue != ''){
            if(!referenceFieldMap.containsKey(localName))referenceFieldMap.put(localName,new Map<String,String>());
            referenceFieldMap.get(localName).put(uniqueIdentifierValue,(String)fieldValue);
        }
    }
    
    // Parse through the XML, determine the author and the characters
    public static string getDataType(String ObjectName,String fieldName) {
        Schema.SObjectType t = Schema.getGlobalDescribe().get(ObjectName);
        Schema.DescribeSObjectResult r = t.getDescribe();
        Schema.DescribeFieldResult f = r.fields.getMap().get(fieldName).getDescribe();
         
        if (f.getType() == Schema.DisplayType.String || f.getType() == Schema.DisplayType.PICKLIST || f.getType() == Schema.DisplayType.EMAIL || 
            f.getType() == Schema.DisplayType.ID || f.getType() == Schema.DisplayType.MULTIPICKLIST || f.getType() == Schema.DisplayType.PHONE || f.getType() == Schema.DisplayType.TEXTAREA
           || f.getType() == Schema.DisplayType.URL)return 'TEXT';
        if (f.getType() == Schema.DisplayType.DATETIME)return 'DATETIME';
        if (f.getType() == Schema.DisplayType.DATE)return 'DATE';
        if (f.getType() == Schema.DisplayType.CURRENCY || f.getType() == Schema.DisplayType.PERCENT || 
            f.getType() == Schema.DisplayType.DOUBLE || f.getType() == Schema.DisplayType.INTEGER)return 'DECIMAL';
        if (f.getType() == Schema.DisplayType.BOOLEAN || f.getType() == Schema.DisplayType.COMBOBOX)return 'BOOLEAN';
        if (f.getType() == Schema.DisplayType.REFERENCE)return 'REFERENCE';
        return null;
    }
}