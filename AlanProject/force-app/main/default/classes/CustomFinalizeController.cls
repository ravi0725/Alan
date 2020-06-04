/*****************************************************************************************
Name    : CustomFinalizeController
Desc    : Used to Check if Advanced Pricing is Completed and navigate the user to Standard Finalize Page.


Modification Log : 
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
Prince Leo           10/04/2016          Created
******************************************************************************************/
Public class CustomFinalizeController{
    public string config{get;set;}
    public string tempcpqid {get;set;}
    public boolean errorPopup {get;set;}
    public boolean AdvancedPricingflag{get;set;}
    public boolean BilltoChangedflag{get;set;}
    public boolean ConstraintRuleError{get;set;}
    Public String quoteId {get;set;}
    Public String ApproalStage{get;set;}
    public Apttus_Config2__ProductConfiguration__c con;
    public boolean FinalizeError{get;set;}
    public string flowUI;
    public List<Apttus_Config2__AppliedRuleActionInfo__c> AppliedRuleList = new List<Apttus_Config2__AppliedRuleActionInfo__c>();
    public customfinalizecontroller(){
        
        Config = System.currentPageReference().getParameters().get('id'); 
        flowUI = System.currentPageReference().getParameters().get('flow'); 
        tempcpqid = System.currentPageReference().getParameters().get('configRequestId'); 
        system.debug('-------config--------' + config);
        con = [select id,Apttus_QPConfig__Proposald__r.Bill_to_Address_Changed__c,Apttus_QPConfig__Proposald__r.CreatedDate,Apttus_QPConfig__Proposald__r.Advanced_Pricing_Completed__c,Apttus_Config2__PriceListId__r.Name,Apttus_QPConfig__Proposald__c from Apttus_Config2__ProductConfiguration__c where id=:Config];
        quoteId = con.Apttus_QPConfig__Proposald__c;
        AdvancedPricingflag = con.Apttus_QPConfig__Proposald__r.Advanced_Pricing_Completed__c;
        BilltoChangedflag = con.Apttus_QPConfig__Proposald__r.Bill_to_Address_Changed__c;
        Apttus_Proposal__Proposal__c Qt = [select id,Apttus_Proposal__Approval_Stage__c from Apttus_Proposal__Proposal__c where id=:quoteId];
        AppliedRuleList =[select id from Apttus_Config2__AppliedRuleActionInfo__c where Apttus_Config2__ConfigurationId__c =: Config and Apttus_Config2__Pending__c =True];
        ApproalStage = Qt.Apttus_Proposal__Approval_Stage__c ;
    }
    
    Public Pagereference callFinalize(){
        if(AdvancedPricingflag == False)
        {
            errorPopup = True;
            return Null;
        }
        
        else if (ApproalStage == 'Approval Required' || ApproalStage =='In Review')
        {
            FinalizeError = true;
            return Null;
        }
        else if(AppliedRuleList.size()>0)
        {
            ConstraintRuleError = true;
            return Null;
        }
        else
        {
            if(ApproalStage  != 'Approval Required' && ApproalStage !='In Review'){
                // Update Prent Line Number with Sub splitted lines
                multiYearSplit_ParentLineNumberUpdate(Config);
                ///////////////////////////////

                Apttus_Proposal__Proposal__c  UpQt = new Apttus_Proposal__Proposal__c(id=quoteId);
                UpQt.Apttus_Proposal__Approval_Stage__c ='Approved';
                update UpQt;
                RecursiveTriggerUtility.isAfterInsertQuoteProposalTrigger = False;
                
                List<Apttus_Config2__ProductConfiguration__c> configList = new List<Apttus_Config2__ProductConfiguration__c>();
                
                con.Apttus_Config2__Status__c = 'Finalized';
                con.Apttus_Config2__FinalizedDate__c = system.now();
                con.Apttus_Config2__EffectiveDate__c = con.Apttus_QPConfig__Proposald__r.CreatedDate;
                configList.add(con);
                for(Apttus_Config2__ProductConfiguration__c config : [select Id from Apttus_Config2__ProductConfiguration__c where Apttus_QPConfig__Proposald__c =: quoteId and 
                                                                      Apttus_Config2__Status__c != 'Superseded' and id !=: con.Id ]){
                                                                          config.Apttus_Config2__Status__c = 'Superseded';
                                                                          config.Apttus_Config2__FinalizedDate__c = null;
                                                                          configList.add(config);
                                                                      }
                
                update configList;
                RecursiveTriggerUtility.isAfterInsertQuoteProposalTrigger = False;
            }
            return new Pagereference('/apex/Apttus_Config2__cartfinalize?autoFinalize=true&id='+config+'&configRequestId='+tempcpqid);    
        }
    }
    
    Public Pagereference validateAdvancePriceFlag(){
        if(!AdvancedPricingflag){
            
            return new Pagereference('/apex/Custom_Reprice?retHref=CartDetailView&configRequestId=' + tempcpqid + '&businessObjectId=' + quoteId + '&retId=' + quoteId + '&id='+config+'&flow='+flowUI);
        }
        return null;
    }
    
    public Pagereference backtocart(){
        if(flowUI=='Angular')
            return new Pagereference('/apex/Apttus_Config2__Cart?id='+config+'&configRequestId='+tempcpqid+'&flow='+flowUI);
        else
            return new Pagereference('/apex/Apttus_Config2__CartDetailView?id='+config+'&configRequestId='+tempcpqid+'&flow='+flowUI);    
    }

    /*
    * Method name  : multiYearSplit_ParentLineNumberUpdate
    * Description  : Method used to update LineItem's Parent Line Number on Splitted lines
    * Return Type  : NA
    * Parameter    : NA
    */
    public void multiYearSplit_ParentLineNumberUpdate(Id configId){
        try {
            if(configId != null){
                List<Apttus_Config2__LineItem__c> lstLineItems = [SELECT Name, Product_Code__c, Parent_Line_Number__c, Apttus_Config2__LineNumber__c, Duration_Sequence__c FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__ConfigurationId__c =: configId AND Duration_Sequence__c != NULL ORDER BY Apttus_Config2__LineNumber__c ASC NULLS LAST];
                List<Apttus_Config2__LineItem__c> lstLineItemsUPDATE = new List<Apttus_Config2__LineItem__c>();
                if(lstLineItems != NULL){
                    /*
                    Key => Product_Code__c
                    Value => Name (Parent Line Name)
                    Description => This Map collection will contains the Parent Line records to update Parent Line Number on sub Multi-year lines
                    */
                    Map<String, String> mapSplitParentLineNumber = new Map<String, String>();

                    for(Apttus_Config2__LineItem__c pItem : lstLineItems){
                        if(pItem.Duration_Sequence__c == 1){ //Parent Line will always have the Duration Sequence as "1"
                            mapSplitParentLineNumber.put(pItem.Product_Code__c, pItem.Name);
                        }
                    }
                    System.debug('mapSplitParentLineNumber =>'+mapSplitParentLineNumber);

                    for(Apttus_Config2__LineItem__c sItem : lstLineItems){
                        if(sItem.Duration_Sequence__c > 1){ // Sub multi-year lines always have Deuration Sequence grater than "1"
                            if(mapSplitParentLineNumber.containsKey(sItem.Product_Code__c)){
                                sItem.Parent_Line_Number__c = mapSplitParentLineNumber.get(sItem.Product_Code__c);
                                System.debug('Parent Line ==>'+sItem.Parent_Line_Number__c);
                                System.debug('Child Line ==>'+sItem.Name);
                                lstLineItemsUPDATE.add(sItem);
                            }
                        }
                    }
                }
                if(lstLineItemsUPDATE.size() > 0)
                    update lstLineItemsUPDATE;
            }
        } catch (Exception exp) {
            errorPopup = True;
        }
    }
}