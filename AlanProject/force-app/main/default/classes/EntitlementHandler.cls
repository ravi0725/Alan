/*****************************************************************************************
Name    : CreateRenewalOpportunityFromEBS
Desc    : Used for Renewal Opportunity and Opportunity Line Item creation

Modification Log : 
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
Ankur Patel       12/11/2013          Created
******************************************************************************************/
public class EntitlementHandler{
    public static Map<String, Integer> launchControl;
    // Static initialize
    static {
        resetLaunchControl();
    }
    
    // Reset Trigger control (e.g. for testing)
    public static void resetLaunchControl() {
        launchControl = new Map<String, Integer>();
        launchControl.put('PopulateEntitlementProcess',0);
        launchControl.put('UpdateOpportunityStage',0);
    }
    
    // Reset Trigger control (e.g. for testing)
    public static void setLaunchControl() {
        launchControl = new Map<String, Integer>();
        launchControl.put('PopulateEntitlementProcess',1);
        launchControl.put('UpdateOpportunityStage',1);
    }
    
    //Populate Entitlement Process on entitlement
    public static void PopulateEntitlementProcess(List<Entitlement> lstEntitlements){
        if(launchControl.get('PopulateEntitlementProcess') < 1){
            launchControl.put('PopulateEntitlementProcess',1);
            Id entitltmentProcessId;
            for(slaProcess oSLAProcess : [select ID from slaProcess where name = 'TAP Entitlement Process']){
                entitltmentProcessId = oSLAProcess.Id;
            }
            
            for(Entitlement oEntitlement : lstEntitlements){
                if(TAP_Business_Area__c.getAll().containsKey(oEntitlement.Product_Business_Area__c))
                    oEntitlement.slaProcessId = entitltmentProcessId;
            }
        }
    }
    
    //Update MEPNA Renewal Opportunity stage to "6 - Closed Won" when Entitlement is renewed
    public static void UpdateOpportunityStage(List<Entitlement> lstEntitlements){
        if(launchControl.get('UpdateOpportunityStage') < 1){
            launchControl.put('UpdateOpportunityStage',1);
            List<String> lstContractNumbers = new List<String>();
            List<Opportunity> lstOpportunities = new List<Opportunity>();
            
            Set<String> lstContractGroups = new set<String>();  
            for(MEPNA_Renewal_Contract_Group__mdt oContractGroup : [SELECT MasterLabel FROM MEPNA_Renewal_Contract_Group__mdt]){
                lstContractGroups.add(oContractGroup.MasterLabel.replace('ARFC - ',''));
            }
            
            for(Entitlement oEntitlement: lstEntitlements){
                if((oEntitlement.Status == 'Active' || oEntitlement.StartDate >= date.today()) && lstContractGroups.contains(oEntitlement.Product_Business_Area__c)){
                    lstContractNumbers.add(oEntitlement.Contract_Number__c);
                }
            }
            
            if(lstContractNumbers.size() > 0){
                for(Opportunity oOpportunity: [SELECT ID, StageName, Service_Contract__c, Skip_validation_rule__c FROM 
                                             Opportunity WHERE Service_Contract__c in :lstContractNumbers AND 
                                             StageName != '6 - Closed Won']) {
                    oOpportunity.Skip_validation_rule__c = !oOpportunity.Skip_validation_rule__c;
                    oOpportunity.StageName = '6 - Closed Won';
                    lstOpportunities.add(oOpportunity);
                }
                update lstOpportunities;
            }
        }
    }
}