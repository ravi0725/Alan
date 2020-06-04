public class AccubidAnywhereOppEMailHelper {

    //---JIRA-APP-1613-Accubid Prod. Opp Close Won Email Alert
    public static boolean isEmailTriggered1 = true;
    public static void AccuOppEmail(List<Opportunity> lstNewOpps) {
    system.debug(' isEmailTriggered ==============>'+AccubidAnywhereOppEMailHelper.isEmailTriggered1);
    isEmailTriggered1 = false;
    Set<Id> setOppIDs = new Set<Id>();
           
        for(Opportunity opp : lstNewOpps){
            if(opp.MEPNA_Submit_for_Order_Audit__c == true && opp.Accubid_Email_Alert__c == false){
                setOppIDs.add(opp.Id);
            }
        }
        
        if(setOppIDs.size() > 0){
            Set<Id> uOppIds = new Set<Id>();
            List<OpportunityAccubidAnywhere_EmailSetting__mdt> lstAccubidEmailConfig = [Select MasterLabel, DeveloperName, IsEnable_EmailSetting__c, ProductCodes__c, TestCase__c FROM OpportunityAccubidAnywhere_EmailSetting__mdt WHERE IsEnable_EmailSetting__c = TRUE ];
            List<String> lstProductCodes = new List<String>();
            for(OpportunityAccubidAnywhere_EmailSetting__mdt eConfig: lstAccubidEmailConfig){
                lstProductCodes.add(eConfig.ProductCodes__c);
            }
            
            if(lstProductCodes.size() > 0){
                List<OpportunityLineItem> lstOppLines = new List<OpportunityLineItem>();
                lstOppLines = [SELECT Id, Name, OpportunityId, Productcode FROM OpportunityLineItem WHERE Productcode IN: lstProductCodes AND OpportunityId IN: setOppIDs];
                for(OpportunityLineItem opLine : lstOppLines){
                    if(setOppIDs.contains(opLine.OpportunityId)){
                        uOppIds.add(opLine.OpportunityId);
                    }
                }
             }
            for(Opportunity opp : lstNewOpps){
                if(uOppIds.contains(opp.Id)){
                    opp.Accubid_Email_Alert__c = TRUE;
                }
             }
          }
    }
    
    //---JIRA-APP-10438-Training Prod. Opps
    public static boolean isEmailTriggered2 = true;
    public static void TRNOppEmail(List<Opportunity> lstNewOpps){
        isEmailTriggered2 = false;
        Set<Id> OppIdsforTRNProds = new Set<Id>();
        
        for(Opportunity opp : lstNewOpps){
        if(opp.StageName == '6 - Closed Won' && opp.Training_Products_Email_Alert__c == false){
                OppIdsforTRNProds.add(opp.Id);
            }
        }
        
        if(OppIdsforTRNProds.size() > 0){
        Set<Id> TrnProdOppIds = new Set <Id>();
        List<OpportunityLineItem> ProdOppLines = new List<OpportunityLineItem>();
        ProdOppLines = [SELECT Id, Name, OpportunityId, Productcode FROM OpportunityLineItem WHERE Productcode like '%TRN%' AND OpportunityId IN: OppIdsforTRNProds];
            for(OpportunityLineItem trnopLine : ProdOppLines){
                if(OppIdsforTRNProds.contains(trnopLine.OpportunityId)){
                    TrnProdOppIds.add(trnopLine.OpportunityId);
                }
            }
            
            for(Opportunity opp : lstNewOpps){
               if(TrnProdOppIds.contains(Opp.Id)){
                    opp.Training_Products_Email_Alert__c = TRUE;
                    
                }                  
            }
        }
    }
    
    
    //---JIRA-APP-12191-Autobid Prod. Opps
    public static boolean isEmailTriggered3 = true;
    public static void AutoBidEmail(List<Opportunity> lstNewOpps3) {
    system.debug(' isEmailTriggered ==============>'+AccubidAnywhereOppEMailHelper.isEmailTriggered3);
    isEmailTriggered3 = false;
    Set<Id> setAutoBidOppIds = new Set<Id>();
        
        for(Opportunity opp1 : lstNewOpps3){
            if(opp1.StageName == '6 - Closed Won' && opp1.Autobid_Email_Alert__c == false){
                setAutoBidOppIds.add(opp1.Id);
            }
        }
        
        if(setAutoBidOppIds.size() > 0){
            Set<Id> AutoBidOppIds = new Set<Id>();
            List<AutoBid_Opp_Email__mdt> lstAutoBidEmailConfig = [Select MasterLabel, DeveloperName, IsEnable_EmailSetting__c, ProductCodes__c FROM AutoBid_Opp_Email__mdt WHERE IsEnable_EmailSetting__c = TRUE ];
            List<String> lstProductCodes1 = new List<String>();
            for(AutoBid_Opp_Email__mdt eConfig1: lstAutoBidEmailConfig){
                lstProductCodes1.add(eConfig1.ProductCodes__c);
                system.debug('<--------------Block2----------->');
            }
            
            if(lstProductCodes1.size() > 0){
                List<OpportunityLineItem> lstOppLines1 = new List<OpportunityLineItem>();
                lstOppLines1 = [SELECT Id, Name, OpportunityId, Productcode FROM OpportunityLineItem WHERE Productcode IN: lstProductCodes1 AND OpportunityId IN: setAutoBidOppIds];
                for(OpportunityLineItem opLine1 : lstOppLines1){
                    if(setAutoBidOppIds.contains(opLine1.OpportunityId)){
                        AutoBidOppIds.add(opLine1.OpportunityId);
                    }
                }
             }
            for(Opportunity opp2 : lstNewOpps3){
                if(AutoBidOppIds.contains(opp2.Id)){
                    opp2.AutoBid_Email_Alert__c = TRUE;
                }
          }
       }
    }
    
    //---JIRA-APP-13113-T-EST Prod. Opps Alert
    public static boolean isEmailTriggered4 = true;
    public static void EstOppProdEmail(List<Opportunity> lstNewOpps4) {
    
    isEmailTriggered4 = false;
    Set<Id> setEstOppIds = new Set<Id>();
        
        for(Opportunity opp4 : lstNewOpps4){
            if(opp4.StageName == '6 - Closed Won' && opp4.T_EST_Opp_Prod_Email_Alert__c == false){
                setEstOppIds.add(opp4.Id);
            }
        }
        
        if(setEstOppIds.size() > 0){
            Set<Id> EstOppIds = new Set<Id>();
            List<OpportunityEstimationProductsEmailAlert__mdt> lstAutoBidEmailConfig = [Select MasterLabel, DeveloperName, IsEnable_EmailSetting__c, ProductCodes__c FROM OpportunityEstimationProductsEmailAlert__mdt WHERE IsEnable_EmailSetting__c = TRUE ];
            List<String> lstProductCodes4 = new List<String>();
            for(OpportunityEstimationProductsEmailAlert__mdt eConfig4: lstAutoBidEmailConfig){
                lstProductCodes4.add(eConfig4.ProductCodes__c);
                system.debug('<--------------Block2----------->');
            }
            
            if(lstProductCodes4.size() > 0){
                List<OpportunityLineItem> lstOppLines4 = new List<OpportunityLineItem>();
                lstOppLines4 = [SELECT Id, Name, OpportunityId, Productcode FROM OpportunityLineItem WHERE Productcode IN: lstProductCodes4 AND OpportunityId IN: setEstOppIds];
                for(OpportunityLineItem opLine4 : lstOppLines4){
                    if(setEstOppIds.contains(opLine4.OpportunityId)){
                        EstOppIds.add(opLine4.OpportunityId);
                    }
                }
             }
            for(Opportunity opp4 : lstNewOpps4){
                if(EstOppIds.contains(opp4.Id)){
                    opp4.T_EST_Opp_Prod_Email_Alert__c = TRUE;
                }
          }
       }
    }
}