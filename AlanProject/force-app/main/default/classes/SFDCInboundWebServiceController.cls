/*****************************************************************************************
Name    : SFDCInboundWebServiceController
Desc    : Used for all SFDC Inbound Integration

Modification Log : 
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
Ankur Patel       12/11/2013          Created
******************************************************************************************/
global class SFDCInboundWebServiceController{
    //Web service method invoke by Oracle to create Renewal Opportunity and Line Item in Salesforce
    webService static ResponseWrapperClass SFDCInboundWebServiceMethod(PayLoad payLoadObj){
        try{
            Map<String,List<sObject>> sObjectMap = new Map<String,List<sObject>>();
            if(payLoadObj.InterfaceName == 'TNV_SFDC_OPPORTUNITY_EXT_PKG'){
                system.debug('-----------payLoadObj---------' + payLoadObj.XMLContent);
                sObjectMap = XMLUtility.getSObjectMap(payLoadObj.XMLContent,payLoadObj.InterfaceName);
                system.debug('-----------sObjectMap.get()---------' + sObjectMap.get('Opportunity'));
                system.debug('-----------sObjectMap.get()---------' + sObjectMap.get('OpportunityLineItem'));

                if(sObjectMap.get('Opportunity') != null)
                    CreateRenewalOpportunityFromEBS.createOpportuntiy(payLoadObj.InterfaceName,sObjectMap.get('Opportunity'));
                System.debug('------XMLUtility.resultMap-------' + XMLUtility.resultMap);
                
                //Renewal 3.5 - Update MEPNA renewal opportunity stage to Closed Lost
                if(sObjectMap.get('OpportunityUpdate') != null)
                    CreateRenewalOpportunityFromEBS.updateMEPNAOpportuntiy(payLoadObj.InterfaceName,sObjectMap.get('OpportunityUpdate'));
                System.debug('------XMLUtility.resultMap-------' + XMLUtility.resultMap);
                
                if(sObjectMap.get('OpportunityLineItem') != null)
                    CreateRenewalOpportunityFromEBS.createOpportuntiyLineItem(payLoadObj.InterfaceName,sObjectMap.get('OpportunityLineItem'));
                System.debug('------XMLUtility.resultMap-------' + XMLUtility.resultMap);
                
                if(CreateRenewalOpportunityFromEBS.setCoveredLineIds.size() > 0)
                    CreateRenewalOpportunityFromEBS.deleteMEPNAOpportuntiy();
                
                if(test.isRunningTest()){
                    BatchCreateProposal b = new BatchCreateProposal('TNV_SFDC_OPPORTUNITY_EXT_PKG'); 
                    database.executebatch(b, 10);
                    ScheduleBatchCreateProposal sbcp = new ScheduleBatchCreateProposal();
                    String chronExpression = '' + system.now().second() + ' ' + system.now().minute() + ' ' + system.now().hour() + ' ' + system.now().day() + ' ' + system.now().month() + ' ? ' + system.now().year();
                    System.schedule( 'ScheduleBatchCreateProposal' + chronExpression, chronExpression, sbcp);
                }
            }
            WS_Interface_Log__c log = WS_Interface_Log.createLog('SFDCInboundWebServiceController','SFDCInboundWebServiceMethod', '', '', payLoadObj.InterfaceName );
            insert log;
            
            createAttachment(log.Id, payLoadObj);
        }catch(Exception ex){
             System.debug('------ex-------' + ex);
             if(ex.getMessage() != ''){
                WS_Interface_Log__c log = WS_Interface_Log.createLog('SFDCInboundWebServiceController','SFDCInboundWebServiceMethod',ex.getMessage(),
                                        ex.getTypeName() + '\n' + ex.getCause() + '\n' + ex.getStackTraceString(),'');
                insert log;
                
                createAttachment(log.Id, payLoadObj);
            }
            
            system.debug('------ex-------' + XMLUtility.resultMap);
            return new ResponseWrapperClass(payLoadObj.InterfaceName,XMLUtility.resultMap);
        }  
        system.debug('------ex-------' + XMLUtility.resultMap);
        return new ResponseWrapperClass(payLoadObj.InterfaceName,XMLUtility.resultMap);
    } 
    
    //Attach payload to WS Interface log record as Attachment
    public static void createAttachment(Id logId, PayLoad payLoadObj){
        Attachment oAttachment = new Attachment();
        oAttachment.Body = Blob.valueOf(payLoadObj.XMLContent);
        oAttachment.ParentId = logId;
        oAttachment.ContentType = 'text/plain';
        oAttachment.Name = payLoadObj.InterfaceName;
        oAttachment.Description = payLoadObj.InterfaceName;
        insert oAttachment;
    }
    
    
    //Wrapper Class to define attributes of Response
    global class PayLoad{
        webservice String InterfaceName{get;set;}        
        webservice String XMLContent{get;set;}
        webservice String Attribute1{get;set;}
        webservice String Attribute2{get;set;}
        webservice String Attribute3{get;set;}
        webservice String Attribute4{get;set;}
        webservice String Attribute5{get;set;}
    }
    
    
    
    //Wrapper Class to define attributes of Response
    global class ResponseWrapperClass{
        webservice String InterfaceName{get;set;}        
        webservice String StatusResponse{get;set;}
        public ResponseWrapperClass(String interface_Name, Map<String,String> resultMap){
            InterfaceName = interface_Name;
            StatusResponse = '<ROWSET>';
            system.debug('-----------resultMap------------' + resultMap);
            for(String str : resultMap.values()){
                StatusResponse = StatusResponse + str;
            }
            StatusResponse = StatusResponse + '</ROWSET>';
        }
    }
    
}