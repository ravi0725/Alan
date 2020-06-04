global class BatchAddLineItemToRenewalProposal implements Database.Batchable<sObject> , Database.Stateful,Database.AllowsCallouts{
    global Map<Id,Id> OppCartMap;
    String query = '';
    public string XMLResponse;
    public string InterfaceName;
    public set<Id> oppIds;
    public List<WS_Interface_Log__c> logList;
    public BatchAddLineItemToRenewalProposal(Map<Id,Id> proposalMap, String InterfaceNM){
        system.debug('-----------------------' + proposalMap);
        if(InterfaceNM != null && InterfaceNM != '')
        InterfaceName = InterfaceNM;
        else
        InterfaceName = 'TNV_SFDC_OPPORTUNITY_EXT_PKG';
        XMLResponse = '<ROWSET>';
        OppCartMap = proposalMap;
        oppIds = new set<Id>();
        logList = new List<WS_Interface_Log__c>();
        system.debug('-----------proposalMap------------' + proposalMap);
        if(OppCartMap != null){
            for(Apttus_Config2__ProductConfiguration__c configuration : [select Id,Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__c from Apttus_Config2__ProductConfiguration__c where Id in : OppCartMap.values()]){
                oppIds.add(configuration.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__c);
            }
        }else{
            OppCartMap = new Map<Id,Id>();
            for(Apttus_Config2__ProductConfiguration__c configuration : [select Id,Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__c from Apttus_Config2__ProductConfiguration__c where 
                Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.Renewal_Status__c = 'Ready To Create Proposal']){
                oppIds.add(configuration.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__c);
                OppCartMap.put(configuration.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__c,configuration.Id);
            }
        }
        system.debug('-----------oppIds------------' + oppIds);
        query = 'select Id,Type__c,Service_Start_Date__c,Service_End_Date__c,Asset__c,OpportunityId,Discount,Asset_Oracle_Id__c, PricebookEntry.Product2Id, Service_Line__c, Contract__c, Staging__c, UnitPrice, Quantity, ListPrice from OpportunityLineItem where OpportunityId IN: oppIds';
        if(test.isRunningTest())query = query + ' limit 1';
    }
    
    global List<Apttus_Proposal__Proposal__c> start(Database.BatchableContext BC) {
        return database.query(query);
    }
   
    global void execute(Database.BatchableContext BC, List<OpportunityLineItem> scope) {
        set<Id> cardIds = new set<Id>();
        String finalResponse = '';
        Apttus_CPQApi.CPQ.AddMultiProductRequestDO request = new Apttus_CPQApi.CPQ.AddMultiProductRequestDO (); 
        Id cartId;
        try{
            
             for(OpportunityLineItem opli: scope){
                finalResponse = finalResponse + '<ROW>';
                finalResponse = finalResponse + '<STAGING_ID>' + opli.Staging__c + '</STAGING_ID>';
                finalResponse = finalResponse + '<DATA_TYPE>QL</DATA_TYPE>';
                finalResponse = finalResponse + '<CONTRACT_ID>' + opli.Contract__c + '</CONTRACT_ID>';
                system.debug(opli.OpportunityId + '--OppCartMap--'+OppCartMap);
                cartId = OppCartMap.get(opli.OpportunityId);
                system.debug('--cartId--'+cartId);
                request.CartId = cartId;//prodConfigObj.Id; 
                request.SelectedProducts = new List<Apttus_CPQApi.CPQ.SelectedProductDO>();
                LineItemHelper_v1.LineItemList = new List<OpportunityLineItem>();
                LineItemHelper_v1.LineItemList.add(opli);
                system.debug(opli.Quantity + '-----------------------' + opli.PricebookEntry.Product2Id);
                Apttus_CPQApi.CPQ.SelectedProductDO prod = new Apttus_CPQApi.CPQ.SelectedProductDO();
                prod.ProductId = opli.PricebookEntry.Product2Id;
                prod.Quantity = opli.Quantity;
                request.SelectedProducts.add(prod);
            }
            
            system.debug('-----------------------' + request.SelectedProducts);
            if(request.SelectedProducts.size() > 0){
                BatchCreateProposal.runProposalTrigger = false;
                Apttus_CPQApi.CPQ.AddMultiProductResponseDO response = Apttus_CPQApi.CPQWebService.addMultiProducts(request);
                system.debug('------------response-----------' + response); 
                if(response != null){
                    for(Decimal lineNumber : response.LineNumbers){
                        Apttus_CPQApi.CPQ.ComputeNetPriceRequestDO priceRequest = new Apttus_CPQApi.CPQ.ComputeNetPriceRequestDO(); 
                        priceRequest.CartId = cartId; 
                        priceRequest.LineNumber = lineNumber; 
                        Apttus_CPQApi.CPQ.ComputeNetPriceResponseDO priceResponse = Apttus_CPQApi.CPQWebService.computeNetPriceForBundle(priceRequest);
                        system.debug('------------priceResponse-----------' + priceResponse);
                    }
                    List<Apttus_Config2__LineItem__c> LiTmList = new List<Apttus_Config2__LineItem__c>();
                    LineItemHelper_v1.LineItemList = new List<OpportunityLineItem>();
                    LineItemHelper_v1.LineItemList.addAll(scope);
                    system.debug('------------LineItemHelper_v1.LineItemList-----------' + LineItemHelper_v1.LineItemList);
                    for(Apttus_Config2__LineItem__c Li : [select Id,Service_Line__c from Apttus_Config2__LineItem__c where 
                        Apttus_Config2__ConfigurationId__c =: cartId and Apttus_Config2__LineNumber__c in : response.LineNumbers]){
                        for(Integer i = 0; i < LineItemHelper_v1.LineItemList.size() ; i++){
                            if(Li.Service_Line__c == LineItemHelper_v1.LineItemList.get(i).Service_Line__c){
                                Li.Apttus_Config2__ListPrice__c = LineItemHelper_v1.LineItemList.get(i).UnitPrice;
                                Li.Apttus_Config2__BasePrice__c = LineItemHelper_v1.LineItemList.get(i).UnitPrice;
                                system.debug('-----quantity----------'+LineItemHelper_v1.LineItemList.get(i).Quantity+'\n------------unitPrice-------'+LineItemHelper_v1.LineItemList.get(i).UnitPrice);
                                Li.Apttus_Config2__BaseExtendedPrice__c = LineItemHelper_v1.LineItemList.get(i).UnitPrice * LineItemHelper_v1.LineItemList.get(i).Quantity;
                                system.debug('---baseExprice---'+Li.Apttus_Config2__BaseExtendedPrice__c);
                                Li.Apttus_Config2__ExtendedPrice__c = LineItemHelper_v1.LineItemList.get(i).UnitPrice * LineItemHelper_v1.LineItemList.get(i).Quantity;    
                                Li.Apttus_Config2__IsCustomPricing__c = true;
                                Li.Apttus_Config2__PricingStatus__c = 'Pending';  
                                Li.Apttus_Config2__AdjustmentAmount__c = LineItemHelper_v1.LineItemList.get(i).Discount;
                                if(LineItemHelper_v1.LineItemList.get(i).Discount != null)Li.Apttus_Config2__NetAdjustmentPercent__c = -LineItemHelper_v1.LineItemList.get(i).Discount;
                                Li.Apttus_Config2__AdjustmentType__c = '% Discount';
                                LineItemHelper_v1.LineItemList.remove(i);
                            }
                        }
                        LiTmList.add(Li);
                    }
                    
                    system.debug('----------LiTmList--------------' + LiTmList);
                    if(LiTmList.size() > 0)
                        update LiTmList;
                    
                    Apttus_CpqApi.CPQ.UpdatePriceRequestDO req = new Apttus_CpqApi.CPQ.UpdatePriceRequestDO();   
                    req.CartId = cartId;//prodConfigObj.Id;        
                    Apttus_CpqApi.CPQ.UpdatePriceResponseDO result = Apttus_CpqApi.CPQWebService.updatePriceForCart(req);
                }
                
                finalResponse = finalResponse + '<STATUS>SUCCESS</STATUS><ERRORMESSAGE/></ROW>';
                XMLResponse = XMLResponse + finalResponse;
                Apttus_Config2__ProductConfiguration__c prodConfig = new Apttus_Config2__ProductConfiguration__c();
                prodConfig.Id = cartId;
                prodConfig.Apttus_Config2__Status__c = 'Saved';
                update prodConfig;
                system.debug('------------prodConfig-----------' + prodConfig); 
            }
        }catch(Exception ex){
            if(cartId != null){
                Apttus_Config2__ProductConfiguration__c prodConfig = new Apttus_Config2__ProductConfiguration__c();
                prodConfig.Id = cartId;
                delete prodConfig;
            }
            finalResponse = finalResponse + '<STATUS>FAIL</STATUS><ERRORMESSAGE>'+ex.getMessage()+'</ERRORMESSAGE></ROW>';
            XMLResponse = XMLResponse + finalResponse;
            
            if(ex.getMessage() != ''){
                logList.add(WS_Interface_Log.createLog('Renewal','BatchAddLineItemToRenewalProposal',ex.getMessage(),
                                        ex.getStackTraceString(),  'Staging# : ' + scope.get(0).Staging__c + '\n' + 'Contract# : ' + scope.get(0).Contract__c + '\n' 
                                           + 'Service Line# : ' + scope.get(0).Service_Line__c));
            }
        }
        
    }
    
    global void finish(Database.BatchableContext BC) { 
         try{
             if(logList.size() > 0){
                 insert logList;
             }else{
                system.debug('--XMLResponse---'+XMLResponse);
                XMLResponse = XMLResponse + '</ROWSET>';
                xmlnsOracleComPlancalNewTnvplnebsre_v1.tnvPlnEBSResponseBPELProcess_pt  p1 = new xmlnsOracleComPlancalNewTnvplnebsre_v1.tnvPlnEBSResponseBPELProcess_pt();
                p1.timeout_x = 60000;
                if(!test.isRunningTest())xmlnsOracleComPlancalNewTnvplnebsre_v1.processResponse_element ret = p1.process(InterfaceName,XMLResponse,'','','','','');
                Map<Id,Integer> cartLineCountMap = new Map<Id,Integer>();
                if(OppCartMap.size() > 0){
                    for(Apttus_Config2__ProductConfiguration__c configuration : [select Id,(select Id from Apttus_Config2__LineItems__r),
                            Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__c from Apttus_Config2__ProductConfiguration__c 
                                where Id in : OppCartMap.values()]){
                        cartLineCountMap.put(configuration.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__c,configuration.Apttus_Config2__LineItems__r.size());
                    }
                    List<Opportunity> updateOpList = new List<Opportunity>();
                    for(Opportunity op: [select Id, Renewal_Lines_Count__c, Renewal_Status__c from Opportunity where Id IN: OppCartMap.keySet()]){
                        if(cartLineCountMap.containsKey(op.Id)){
                            if(cartLineCountMap.get(op.Id) == op.Renewal_Lines_Count__c){
                                op.Renewal_Status__c = 'Complete';
                                updateOpList.add(op);
                            }
                        }
                    }
                    
                    // Added By Suresh Babu Murugan : TT 128234 - RE&WS Enhancement to Renewals 2.0
                    // Default Finalize on Renewal Quotes
                    Map<Id, Id> mapTempObjectId = new Map<Id, Id>(); // Key: OppId; Value: TempObjId
                    Map<Id, Id> mapQuoteId = new Map<Id, Id>(); // Key: OppId; Value: QuoteId
                    Map<Id, Id> mapConfigId = new Map<Id, Id>(); // Key: OppId; Value: ConfigId
                    for(Apttus_Config2__ProductConfiguration__c pConfig : [SELECT Name, Apttus_QPConfig__Proposald__c, Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__c, (SELECT Id FROM Apttus_Config2__TempObjects__r LIMIT 1) FROM Apttus_Config2__ProductConfiguration__c WHERE Id IN : OppCartMap.values()]){
                        mapConfigId.put(pConfig.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__c, pConfig.Id);
                        mapQuoteId.put(pConfig.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__c, pConfig.Apttus_QPConfig__Proposald__c);
                        for(Apttus_Config2__TempObject__c tempObj : pConfig.Apttus_Config2__TempObjects__r){
                            mapTempObjectId.put(pConfig.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__c, tempObj.Id);
                        }
                    }
                    
                    for(Opportunity opps: [SELECT Id, Name, Bill_To_Account__c, Ship_To_Account__c, Bill_to_Address__c, Ship_to_Address1__c, Bill_To_Contact__c, Primary_Contact__c FROM Opportunity WHERE Id IN: OppCartMap.keySet()]){
                        If(opps != null && 
                           opps.Bill_To_Account__c != null && 
                           opps.Ship_To_Account__c != null && 
                           opps.Bill_to_Address__c != null && 
                           opps.Ship_to_Address1__c != null){ // Advanced Pricing and Finalize the cart
                               Map<String, String> mapPageParams = new Map<String, String>();
                               mapPageParams.put('retHref','CartDetailView');
                               mapPageParams.put('id', String.valueOf(mapConfigId.get(opps.Id))); // ConfigID
                               mapPageParams.put('configRequestId', String.valueOf(mapTempObjectId.get(opps.Id))); // TempObjID
                               mapPageParams.put('businessObjectId', String.valueOf(mapQuoteId.get(opps.Id))); // QuoteID
                               mapPageParams.put('flow', 'Angular');
                               AdvancePricingclass advPricing = new AdvancePricingclass(mapPageParams);
                               advPricing.Temp();
                        }
                    }
                    
                    if(updateOpList.size() > 0)
                        update updateOpList;
                }
            }                
        }catch(Exception ex){
            insert WS_Interface_Log.createLog('BatchAddLineItemToRenewalProposal','Execute',ex.getMessage(),
                                        ex.getStackTraceString(),  '');
        }
    }
}