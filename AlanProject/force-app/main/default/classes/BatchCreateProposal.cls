global class BatchCreateProposal implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
    public string query;
    public string InterfaceName;
    public Map<Id, Id> proposalMap;
    public string XMLResponse;
    public Map<String,String> defaultValueMap;
    public Map<String,String> salesforceInternalObjectMap;
    public static boolean runProductConfigurationTrigger = true;
    public static boolean runProposalTrigger = true;
    global set<Id> oppIds;
    global BatchCreateProposal(String interfaceUsed){
        XMLResponse = '<ROWSET>';
        InterfaceName = interfaceUsed;
        proposalMap = new Map<Id, Id>();
        defaultValueMap = new Map<String,String>();
        salesforceInternalObjectMap = new Map<String,String>();
        for(Field_Map__c fieldMap : [select Id,Default_Value__c,Reference_Query__c,Object_Map__r.Source_Object__c,
                                     Object_Map__r.Target_Object__c,Target_Field__c,Source_Field__c from Field_Map__c 
                                     where Object_Map__r.Name =: interfaceName + ' Proposal']){
            if(fieldMap.Default_Value__c != null)
                defaultValueMap.put(fieldMap.Target_Field__c,fieldMap.Default_Value__c);
            else if(fieldMap.Source_Field__c != null && fieldMap.Source_Field__c != '')
                salesforceInternalObjectMap.put(fieldMap.Source_Field__c, fieldMap.Target_Field__c);
        }
        query ='select ';
        for(String field : salesforceInternalObjectMap.keySet()){
            query = query + ',' + field;
        }
        query = query.replaceFirst(',', '') ;
        String strQuery = query;
        strQuery = strQuery + ' from Opportunity where Renewal_Status__c = \'Ready To Create Proposal\'';
        if(test.isRunningTest())strQuery = strQuery + ' limit 5';
        oppIds = new set<Id>();
        List<Opportunity> oppList = new List<Opportunity>();
        for(Opportunity opp : database.query(strQuery)){
            if(Test.isRunningTest())opp.OwnerId = userInfo.getUserId();
            opp.Renewal_Status__c = 'Processing'; 
            oppList.add(opp);
            oppIds.add(opp.Id);
        }
        
        if(oppList.size() > 0){
            CreateRenewalOpportunityFromEBS.runOpportunityTrigger = false;
            update oppList;
        }
        query = query + ', Selling_Division__c from Opportunity where Id in : oppIds';
        system.debug('--------query--------' + query);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug(oppIds + '--------query--------' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Apttus_Proposal__Proposal__c> proposalList = new List<Apttus_Proposal__Proposal__c>();
        List<WS_Interface_Log__c> logList = new List<WS_Interface_Log__c>();
        for(sObject obj : scope){
            Schema.SObjectType convertType = Schema.getGlobalDescribe().get('Apttus_Proposal__Proposal__c');
            sObject genericObject = convertType.newSObject();
            for(String sourceField : salesforceInternalObjectMap.keySet()){
                system.debug('------sourceField-----' + obj.get(sourceField));
                if(obj.get(sourceField) != null){
                    try{
                        String dataType = XMLUtility.getDataType('Apttus_Proposal__Proposal__c',salesforceInternalObjectMap.get(sourceField)); 
                        if(dataType == 'TEXT'){
                            String fieldValue = (String)obj.get(sourceField);
                            genericObject.put(salesforceInternalObjectMap.get(sourceField),fieldValue);
                        }else if(dataType == 'DATETIME'){
                            genericObject.put(salesforceInternalObjectMap.get(sourceField),(DateTime)obj.get(sourceField));
                        }else if(dataType == 'DATE'){
                            genericObject.put(salesforceInternalObjectMap.get(sourceField),(Date)obj.get(sourceField));
                        }else if(dataType == 'DECIMAL'){
                            genericObject.put(salesforceInternalObjectMap.get(sourceField),(Decimal)obj.get(sourceField));
                        }else if(dataType == 'BOOLEAN'){
                            String fieldValue = (String)obj.get(sourceField);
                            if(fieldValue.equals('Yes') || fieldValue.equals('YES') || 
                               fieldValue.equals('1') || fieldValue.equals('true') ||
                               fieldValue.equals('True') || fieldValue.equals('TRUE'))
                                genericObject.put(salesforceInternalObjectMap.get(sourceField),true);
                            else
                                genericObject.put(salesforceInternalObjectMap.get(sourceField),false);
                        }else if(dataType == 'REFERENCE'){
                            String fieldValue = (String)obj.get(sourceField);
                            genericObject.put(salesforceInternalObjectMap.get(sourceField),(Id)fieldValue);
                        }
                    }catch(exception ex){
                        if(ex.getMessage() != ''){
                            logList.add(WS_Interface_Log.createLog('BatchCreateProposal','XMLUtility.getDataType',ex.getMessage(),
                                        'SourceField: '+sourceField+'\n Error Message: '+ex.getMessage() , 
                                                       'Staging# :'+(String)obj.get('Staging__c') +'\n'+ 'Contract# :'+(String)obj.get('Contract__c')+'\n'));
                        }
                    }
                }
            }
            Apttus_Proposal__Proposal__c proposalObj = (Apttus_Proposal__Proposal__c)genericObject;
            // Suresh Babu: TT:121271 - On quotes, Valid Until Date - change this to be the same dates as the Service Start Date
            if(obj.get('Selling_Division__c') == 'GCCM')
                proposalObj.Apttus_Proposal__Valid_Until_Date__c = proposalObj.Service_Start_Date__c;
            else
                proposalObj.Apttus_Proposal__Valid_Until_Date__c = proposalObj.Apttus_Proposal__Valid_Until_Date__c.addMonths(3);
            proposalList.add(proposalObj);
        }
        system.debug('----------proposalList---------' + proposalList);
        if(proposalList.size() > 0){
            String finalResponse = '';
            Integer cnt = 0;
            runProposalTrigger = false;
            for(Database.saveResult ins: Database.insert(proposalList,false)){
                finalResponse = finalResponse + '<ROW>';
                finalResponse = finalResponse + '<STAGING_ID>' + proposalList[cnt].Staging__c + '</STAGING_ID>';
                finalResponse = finalResponse + '<DATA_TYPE>QH</DATA_TYPE>';
                finalResponse = finalResponse + '<CONTRACT_ID>' + proposalList[cnt].Contract__c + '</CONTRACT_ID>';
                if(ins.isSuccess()){
                    //Create Cart
                    runProductConfigurationTrigger = false;
                    Apttus_CPQApi.CPQ.CreateCartRequestDO request = new Apttus_CPQApi.CPQ.CreateCartRequestDO(); 
                    request.QuoteId = ins.getId(); 
                    Apttus_CPQApi.CPQ.CreateCartResponseDO response = Apttus_CPQApi.CPQWebService.createCart(request);
                    proposalMap.put(proposalList[cnt].Apttus_Proposal__Opportunity__c, response.CartId);
                    finalResponse = finalResponse + '<STATUS>SUCCESS; ' + [select Name from Apttus_Proposal__Proposal__c where Id =: ins.getId()].Name + '</STATUS><ERRORMESSAGE/></ROW>';
                }else{
                    String msg = '';
                    String erMsg = '';
                    for (Database.Error er : ins.getErrors()){
                        erMsg = er.getMessage();
                        msg += 'Error (' +  er.getStatusCode() + '):' + er.getMessage();
                        msg += '\r\n';
                    }
                    
                    logList.add(WS_Interface_Log.createLog('BatchCreateProposal','Database.SaveResult',erMsg,
                                        msg,'Staging# : ' + proposalList[cnt].Staging__c + '\n' + 'Contract# : ' + proposalList[cnt].Contract__c));
                    finalResponse = finalResponse + '<STATUS>FAILED</STATUS><ERRORMESSAGE>' + msg + '</ERRORMESSAGE></ROW>';
                    system.debug('------finalResponse------' + finalResponse);
                }
                XMLResponse = XMLResponse + finalResponse;
                cnt++;
            }
            try{
                insert logList;
            }catch(exception ex){
                
            }
            logList.clear();
        }
    }
    
    global void finish(Database.BatchableContext BC){
        try{
            system.debug('--XMLResponse---'+XMLResponse);
            XMLResponse = XMLResponse + '</ROWSET>';
            xmlnsOracleComPlancalNewTnvplnebsre_v1.tnvPlnEBSResponseBPELProcess_pt  p1 = new xmlnsOracleComPlancalNewTnvplnebsre_v1.tnvPlnEBSResponseBPELProcess_pt();
            p1.timeout_x = 60000;
            if(!test.isRunningTest())xmlnsOracleComPlancalNewTnvplnebsre_v1.processResponse_element ret = p1.process(InterfaceName,XMLResponse,'','','','','');
            system.debug('--proposalMap---'+proposalMap);
            BatchAddLineItemToRenewalProposal temp = new BatchAddLineItemToRenewalProposal(proposalMap,InterfaceName);
            Database.executeBatch(temp, 1);
        }catch(Exception ex){
            WS_Interface_Log.createLog('BatchCreateProposal','Finish',ex.getMessage(),
                                        ex.getStackTraceString(), '\nCause : ' + ex.getCause() + '\nLine Number : ' + ex.getLineNumber() + '\nType : ' + ex.getTypeName());
        }
    }
    
}