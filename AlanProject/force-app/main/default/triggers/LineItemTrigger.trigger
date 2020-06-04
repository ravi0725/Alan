/*****************************************************************************************
Name    : PopulateshippingacctOnChild
Desc    : Trigger for adding account on Quote/Proposal Record to default in Line Item
Project ITEM-00756

Modification Log : 
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
Chandrakant       11/17/2013          Created
******************************************************************************************/
trigger LineItemTrigger on Apttus_Config2__LineItem__c (before insert,before update, before delete) {
    
    if(trigger.isUpdate && trigger.isBefore){
        LineItemHelper.validateAssetQuantity(trigger.newMap, trigger.oldMap);
    }
    if(trigger.isUpdate && trigger.isbefore){
        LineItemHelper.RenewalValidation(trigger.new,trigger.oldMap);
    }
    if(trigger.isInsert && trigger.isbefore && LineItemHelper.LineItemList != null){
        LineItemHelper.processRenewalLineItem(trigger.new);
    }
    /* Added for TT# 101380
Summary : to vlaidate the Qty data is non-integer for Product Category Type = Sofwtare/ Hardware
Added by : Srini Babu 
Dated on : 03/29/2016
*/
    if(trigger.isUpdate && trigger.isbefore){
        LineItemHelper.validateQtydata(trigger.new,trigger.oldMap);
        Set<Id> setProductConfigIdsLineSeq = new Set<Id>(); 
        for(Apttus_Config2__LineItem__c co : Trigger.new){
            
            if(trigger.oldmap.get(co.id).Apttus_Config2__LineSequence__c != trigger.newmap.get(co.id).Apttus_Config2__LineSequence__c)
            {
                setProductConfigIdsLineSeq.add(co.Apttus_Config2__ConfigurationId__c);
            }
        }
        
        //added for Line Sequence Logic - Kit EBS Line Order  
        if(setProductConfigIdsLineSeq.size() > 0){
            // Query Proposal IDs
            Set<Id> setProposalIDs = new Set<Id>();
            List<Apttus_Config2__ProductConfiguration__c> lstpConfigs = [SELECT Id, Apttus_QPConfig__Proposald__c FROM Apttus_Config2__ProductConfiguration__c WHERE Id IN: setProductConfigIdsLineSeq];
            for(Apttus_Config2__ProductConfiguration__c pConf: lstpConfigs){
                setProposalIDs.add(pConf.Apttus_QPConfig__Proposald__c);
            }
            List<Apttus_Proposal__Proposal__c> lstProposals = [SELECT Id, Bill_to_Address_Changed__c FROM Apttus_Proposal__Proposal__c WHERE Id IN: setProposalIDs];
            
            for(Apttus_Proposal__Proposal__c psals : lstProposals){
                psals.Cart_Line_Sequence_Changed__c = true;
            }
            
            try{
                // Update Quote/Proposals with Bill to Address Changed
                update lstProposals;
            }
            catch(System.DmlException dmlexp){
                system.debug('dmlexp ==>'+dmlexp);
            }
        }
        
    }
    //Checking the operation
    if ((Trigger.isInsert || Trigger.isUpdate) && !RecursiveTriggerUtility.stopLineItemTrigger_ApprovalRequestListener){
        RecursiveTriggerUtility.recursiveCallLineItemTrigger = true;
        system.debug('I am Called now ----------- tgrigger');
        Set<Id> setProductConfigIds = new Set<Id>();
        for(Apttus_Config2__LineItem__c Lin: Trigger.new){
            system.debug(Lin.Id + '---------------------' + Lin);
        }
        
        If(Trigger.Isupdate){
            LineItemHelper.configLineItem(Trigger.newmap,Trigger.oldmap);   
            
            //Custom Pricing for Option Lines. 
            for(Apttus_Config2__LineItem__c Lin: Trigger.new){
                if(lin.Apttus_Config2__LineType__c=='Option' && lin.Apttus_Config2__IsCustomPricing__c==True)
                {
                    lin.Apttus_Config2__ExtendedPrice__c = lin.Apttus_Config2__ListPrice__c* lin.Apttus_Config2__Quantity__c;
                    if(lin.Apttus_Config2__NetAdjustmentPercent__c != Null)
                        lin.Apttus_Config2__NetPrice__c = (lin.Apttus_Config2__ListPrice__c* lin.Apttus_Config2__Quantity__c) + ((lin.Apttus_Config2__NetAdjustmentPercent__c /100 ) *lin.Apttus_Config2__ListPrice__c);
                    else
                        lin.Apttus_Config2__NetPrice__c = (lin.Apttus_Config2__ListPrice__c* lin.Apttus_Config2__Quantity__c);
                    lin.Apttus_Config2__BaseExtendedPrice__c = lin.Apttus_Config2__ListPrice__c* lin.Apttus_Config2__Quantity__c;
                    lin.Apttus_Config2__BasePrice__c =  lin.Apttus_Config2__ListPrice__c* lin.Apttus_Config2__Quantity__c;
                    lin.Apttus_Config2__BasePriceOverride__c = lin.Apttus_Config2__ListPrice__c* lin.Apttus_Config2__Quantity__c;
                }
            }  
            // Boolean to Invoke AdvancePricing if bill To Address or Quantity at Line Level is changed.
            Boolean checkTrue;    
            for(Apttus_Config2__LineItem__c co : Trigger.new){
                if((trigger.oldmap.get(co.id).Bill_To_Address__c!= trigger.newmap.get(co.id).Bill_To_Address__c) || (trigger.oldmap.get(co.id).Apttus_Config2__Quantity__c!= trigger.newmap.get(co.id).Apttus_Config2__Quantity__c)){
                    checkTrue = True;
                    setProductConfigIds.add(co.Apttus_Config2__ConfigurationId__c);
                    break;
                }
            }
        }
        
        // Query related Product Configurations
        if(setProductConfigIds.size() > 0){
            // Query Proposal IDs
            Set<Id> setProposalIDs = new Set<Id>();
            List<Apttus_Config2__ProductConfiguration__c> lstpConfigs = [SELECT Id, Apttus_QPConfig__Proposald__c FROM Apttus_Config2__ProductConfiguration__c WHERE Id IN: setProductConfigIds];
            for(Apttus_Config2__ProductConfiguration__c pConf: lstpConfigs){
                setProposalIDs.add(pConf.Apttus_QPConfig__Proposald__c);
            }
            List<Apttus_Proposal__Proposal__c> lstProposals = [SELECT Id, Bill_to_Address_Changed__c FROM Apttus_Proposal__Proposal__c WHERE Id IN: setProposalIDs];
            
            for(Apttus_Proposal__Proposal__c psals : lstProposals){
                psals.Bill_to_Address_Changed__c = true;
            }
            
            try{
                // Update Quote/Proposals with Bill to Address Changed
                update lstProposals;
            }
            catch(System.DmlException dmlexp){
                system.debug('dmlexp ==>'+dmlexp);
            }
        }
        
        Set<Id> configIdSet = new Set<Id>(); 
        Set<ID>LineID = new Set<ID>();
        List<Apttus_Config2__LineItem__c>DelList = new List<Apttus_Config2__LineItem__c>();
        List<String>ParentLineID = new List<String>();
        Map<Id, Id> configOwnerMap = new Map<Id, Id>();
        Map<Id,Id> ConfigManagerMap = new Map<Id,Id>();
        Map<Id,String> ConfigsalesRepMap = new Map<Id,String>();
        Map<Id,String>OppSubType = new Map<Id,String>();
        Map<Id,Id>OppIdMap = new Map<Id,Id>();
        Map<Id, Apttus_Config2__ProductConfiguration__c> configAddressMap = new Map<Id, Apttus_Config2__ProductConfiguration__c>();
        for(Apttus_Config2__LineItem__c co : Trigger.new){
            configIdSet.add(co.Apttus_Config2__ConfigurationId__c);
        }
        
        Map<Id, Apttus_Config2__ProductConfiguration__c> configMap = new Map<Id, Apttus_Config2__ProductConfiguration__c>([Select 
                                                                                                                           Id, Apttus_QPConfig__Proposald__r.OwnerId,Apttus_QPConfig__Proposald__r.Bill_to_Address__c,Apttus_QPConfig__Proposald__r.Service_Start_Date__c,Apttus_QPConfig__Proposald__r.Service_End_Date__c,Apttus_QPConfig__Proposald__r.Bill_To_Contact__c
                                                                                                                           ,Apttus_QPConfig__Proposald__r.Ship_to_Address1__c,Apttus_QPConfig__Proposald__r.Industry__c,Apttus_QPConfig__Proposald__r.Apttus_Proposal__Primary_Contact__c from Apttus_Config2__ProductConfiguration__c where Id IN: configIdSet]);
        for(Apttus_Config2__ProductConfiguration__c config : configMap.values()){
            configOwnerMap.put(config.Id, config.Apttus_QPConfig__Proposald__r.OwnerId);
            configAddressMap.put(config.Id, config);
        }    
        for(Apttus_Config2__LineItem__c Line : [SELECT Id, Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__c, Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.Account_Sub_Type__c, createdby.Managerid, Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Ownerid, Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Owner.userName, Apttus_Config2__ConfigurationId__r.Sales_Rep_Manager__c FROM Apttus_Config2__LineItem__c WHERE Id IN:Trigger.New])
        {
            system.debug('***************I am In'+Line);
            
            if(Trigger.IsBefore && Line.Apttus_Config2__ConfigurationId__r.Sales_Rep_Manager__c != NULL)
                ConfigManagerMap.put(Line.id,Line.Apttus_Config2__ConfigurationId__r.Sales_Rep_Manager__c);
            if(Trigger.IsBefore && Line.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Ownerid != Null)
                ConfigsalesRepMap.put(Line.id,Line.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Owner.username);
            
            if(Line.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.Account_Sub_Type__c !=Null)
                OppSubType.put(Line.id,Line.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.Account_Sub_Type__c);
            if(Line.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__c !=Null)
                OppIdMap.put(Line.id,Line.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__c);
            
            
        }
        
        
        Set<ID>OppId = new Set<ID>();
        List<Opportunity>OppList = new List<Opportunity>();
        for(Apttus_Config2__LineItem__c Li : Trigger.New)
        {
            // This code is to check if the Cart is Already Approved and no change done to initiate the current approval process 
            if(trigger.Isinsert && (Li.Apttus_Config2__NetAdjustmentPercent__c <0 || Li.Apttus_Config2__NetAdjustmentPercent__c >0) && Li.Apttus_CQApprov__Approval_Status__c==Null)
                Li.WF_Skip_Approvals__c = True;
            
            if(trigger.Isupdate && trigger.oldmap.get(Li.id).Apttus_Config2__NetPrice__c != trigger.newmap.get(Li.id).Apttus_Config2__NetPrice__c)
                Li.WF_Skip_Approvals__c = False;
            
            
            Li.Sales_Rep_Manager__c = ConfigManagerMap.get(Li.id);
            if(ConfigsalesRepMap.get(Li.id)!= Null && ConfigsalesRepMap.get(Li.id).touppercase().contains(Label.Trade_Service_Approval_Exclusion.touppercase())){
                Li.Skip_Trade_Service_Approval__c = True;
                
            }
            else
            {
                Li.Skip_Trade_Service_Approval__c = False;
            }
            if((OppSubType.get(Li.id) != Null && (OppSubType.get(Li.id)=='Education/Donation' || OppSubType.get(Li.id)=='Reconfigure/Damaged/Lost Device/License Transfers' || OppSubType.get(Li.id)=='Trial' || OppSubType.get(Li.id)=='Crossgrade')) || Li.WF_Skip_Approvals__c == True)
            {
                Li.WF_Skip_Approvals__c = True;
                OppId.add(OppIdMap.get(Li.id));
            }
            else 
            {
                Li.WF_Skip_Approvals__c = False;
            }
            
            // This block is to replace the Workflow Rule with Trigger to overcome the execution sequence issue 
            List<Skip_Apttus_Approval_Process__c> mcs1 = Skip_Apttus_Approval_Process__c.getall().values();
            boolean MakeTrue = False;
            Skip_Apttus_Approval_Process__c mcsPro = Skip_Apttus_Approval_Process__c.getinstance(Li.Apttus_Config2__ProductId__c);
            Skip_Apttus_Approval_Process__c mcsOpt = Skip_Apttus_Approval_Process__c.getinstance(Li.Apttus_Config2__OptionId__c);
            Skip_Apttus_Approval_Process__c cs;
            
            if(mcsPro != Null)
                cs = mcsPro;
            else if(mcsOpt != Null)
                cs = McsOpt;
            
            system.debug('>>>>>Inside Condition>>>>>1'+Li.Apttus_Config2__ProductId__c);
            system.debug('>>>>>Inside Condition>>>>>1'+Li.Apttus_Config2__OptionId__c);
            
            if(cs!=Null){
                
                system.debug('>>>>>Inside Condition>>>>>1'+Li.Apttus_Config2__ProductId__c);
                system.debug('>>>>>Inside Condition>>>>>2'+cs.Product_ID__c);
                system.debug('>>>>>Inside Condition>>>>>3'+Li.Apttus_Config2__NetAdjustmentPercent__c);
                if(cs.Net_Price__c != Null) system.debug('>>>>>Inside Condition>>>>>4'+cs.Net_Price__c.split(';'));
                system.debug('>>>>>Inside Condition>>>>>5'+cs.Net_Price__c);
                system.debug('>>>>>Inside Condition>>>>>6'+Li.Apttus_Config2__NetPrice__c);
                system.debug('>>>>>Inside Condition>>>>>7'+String.valueof(Li.Apttus_Config2__NetPrice__c));
                
                if(Li.Apttus_Config2__ProductId__c == cs.Product_ID__c &&  ((cs.Net_Price__c != Null && cs.Net_Price__c.split(';').contains(String.valueof(Li.Apttus_Config2__NetPrice__c))) ||  
                                                                            (cs.Discount__c != Null && Li.Apttus_Config2__NetAdjustmentPercent__c != Null && Li.Apttus_Config2__NetAdjustmentPercent__c == cs.Discount__c) ))
                {
                    Li.WF_Skip_Approvals__c = True;
                    OppId.add(OppIdMap.get(Li.id));
                    MakeTrue = True;
                }
                
                if(Li.Apttus_Config2__OptionId__c == cs.Product_ID__c &&  ((cs.Net_Price__c != Null && cs.Net_Price__c.split(';').contains(String.valueof(Li.Apttus_Config2__NetPrice__c))) ||  
                                                                           (cs.Discount__c != Null && Li.Apttus_Config2__NetAdjustmentPercent__c != Null && Li.Apttus_Config2__NetAdjustmentPercent__c == cs.Discount__c) ))
                {
                    
                    Li.WF_Skip_Approvals__c = True;
                    OppId.add(OppIdMap.get(Li.id));
                    MakeTrue = True;
                    system.debug('>>>>>Passes this Condtion>>>>>');
                }
                
                if(Li.Apttus_Config2__ProductId__c == cs.Product_ID__c &&  ((cs.Net_Price__c != Null && !cs.Net_Price__c.split(';').contains(String.valueof(Li.Apttus_Config2__NetPrice__c))) ||  
                                                                            (cs.Discount__c != Null && Li.Apttus_Config2__NetAdjustmentPercent__c != Null && Li.Apttus_Config2__NetAdjustmentPercent__c != cs.Discount__c) ))
                    
                {
                    
                    Li.WF_Skip_Approvals__c = False;
                    
                }
                
                if(Li.Apttus_Config2__OptionId__c == cs.Product_ID__c &&  ((cs.Net_Price__c != Null && !cs.Net_Price__c.split(';').contains(String.valueof(Li.Apttus_Config2__NetPrice__c))) ||  
                                                                           (cs.Discount__c != Null && Li.Apttus_Config2__NetAdjustmentPercent__c != Null && Li.Apttus_Config2__NetAdjustmentPercent__c != cs.Discount__c) ))
                {
                    Li.WF_Skip_Approvals__c = False;
                    
                }
                
            }
            
        }
        system.debug('>>>>>>>>>Inside the Opp Loop'+OppId);
        
        
        for(Id OppIdVal : OppId)
        {
            Opportunity Opp = new Opportunity(id=OppIdVal);
            Opp.Approval_Skipped__c = True;
            //Opp.Approval_Skip_Reason__c='None';
            if(Opp.id != Null) OppList.add(Opp);
        }
        
        
        if(trigger.isupdate && OppList.size()>0)
        {
            CreateRenewalOpportunityFromEBS.runOpportunityTrigger = False;
            Update OppList;
        }
        
        Map<Id, User> userMap = new Map<Id, User>([Select Id, Legal_Entity__c from User where Id IN: configOwnerMap.values()]);
        for(Apttus_Config2__LineItem__c co : Trigger.new){
            LineID.add(co.id);
            //checking if account lookup is null or not null
            if(co.Account_lookup__c ==null){
                //Assigning id to shipping Account field
                co.Account_lookup__c = co.AccountIdfortrigger__c;
            }
            /*  List<Apttus_Config2__LineItem__c > ValidationList = new List<Apttus_Config2__LineItem__c>();
validationList = [Select id,Bill_To_Address__r.Country__c,Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Bill_to_Address__r.Country__c, Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Ship_to_Address1__r.Country__c, Ship_To_Address1__r.Country__c from Apttus_Config2__LineItem__c where id in:LineId];

for(Apttus_Config2__LineItem__c Error : validationList)
{
if(Error.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Ship_to_Address1__r.Country__c != Error.Ship_To_Address1__r.Country__c || Error.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Bill_to_Address__r.Country__c != Error.Bill_To_Address__r.Country__c)
Error.adderror('Please Select Correct Billt to & Ship To Address');
}*/
            if(userMap != null && userMap.size() > 0 && configOwnerMap.size() > 0 && configOwnerMap.containsKey(co.Apttus_Config2__ConfigurationId__c) && userMap.containsKey(configOwnerMap.get(co.Apttus_Config2__ConfigurationId__c))){
                co.Users_Legal_Entity__c = userMap.get(configOwnerMap.get(co.Apttus_Config2__ConfigurationId__c)).Legal_Entity__c;
            }
            
            if(configAddressMap.get(co.Apttus_Config2__ConfigurationId__c) != null && Trigger.isInsert){
                co.Industry__c = configAddressMap.get(co.Apttus_Config2__ConfigurationId__c).Apttus_QPConfig__Proposald__r.Industry__c;
                if(co.Bill_To_Address__c ==Null) co.Bill_To_Address__c = configAddressMap.get(co.Apttus_Config2__ConfigurationId__c).Apttus_QPConfig__Proposald__r.Bill_to_Address__c;
                if(co.Ship_To_Address1__c==Null) co.Ship_To_Address1__c = configAddressMap.get(co.Apttus_Config2__ConfigurationId__c).Apttus_QPConfig__Proposald__r.Ship_to_Address1__c;
                if(co.Apttus_Config2__ChargeType__c=='Maintenance Fee'){
                    // co.Service_Start_Date__c = configAddressMap.get(co.Apttus_Config2__ConfigurationId__c).Apttus_QPConfig__Proposald__r.Service_Start_Date__c;
                    // co.Service_End_Date__c = configAddressMap.get(co.Apttus_Config2__ConfigurationId__c).Apttus_QPConfig__Proposald__r.Service_End_Date__c;
                }
            } 
            else 
            {
                if(co.Industry__c== Null) co.Industry__c = configAddressMap.get(co.Apttus_Config2__ConfigurationId__c).Apttus_QPConfig__Proposald__r.Industry__c;
                if(co.Bill_To_Address__c ==Null) co.Bill_To_Address__c = configAddressMap.get(co.Apttus_Config2__ConfigurationId__c).Apttus_QPConfig__Proposald__r.Bill_to_Address__c;
                if(co.Ship_To_Address1__c==Null) co.Ship_To_Address1__c = configAddressMap.get(co.Apttus_Config2__ConfigurationId__c).Apttus_QPConfig__Proposald__r.Ship_to_Address1__c;
                
            }
        }
    }
    
    if(trigger.isDelete){
        set<String> parentLineNumber = new set<String>();
        List<Apttus_Config2__LineItem__c> liTmList = new List<Apttus_Config2__LineItem__c>();
        system.debug('-------Trigger.oldMap.keySet()-----'+Trigger.oldMap.keySet());
        for (Apttus_Config2__LineItem__c li : Trigger.old) {
            if(li.Parent_Line_Number__c != Null && li.Parent_Line_Number__c != '') parentLineNumber.add(li.Parent_Line_Number__c);
        }
        system.debug('-------parentLineNumber-----'+parentLineNumber); 
        for (Apttus_Config2__LineItem__c li : Trigger.old) {
            if(li.Type__c == 'Renewal' && !parentLineNumber.contains(li.Name) && (li.Parent_Line_Number__c == Null || li.Parent_Line_Number__c == '')){
                system.debug('-------Line No-----'+li.Name);
                system.debug('-------Line No-----'+li.Parent_Line_Number__c );
                system.debug('-------Line No-----'+li.Type__c );
                li.addError('Renewal Lines cannot be deleted!');
            }else if(li.Type__c == 'Renewal' && parentLineNumber.contains(li.Name)){
                Apttus_Config2__LineItem__c nLin = new Apttus_Config2__LineItem__c();
                nLin = li.clone(false, true, false, false);
                liTmList.add(nLin);
            }
        }
        if(liTmList.size() > 0 )insert litmList;
    }
}