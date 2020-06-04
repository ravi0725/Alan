/*****************************************************************************************
Name        : LeadHelper
Desc        : Used to handel Lead trigger code
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
Ankur Patel          30/10/2017       LeadConversionDefaultOpportunityFields - Default Opportunity fields value while converting Lead
******************************************************************************************/
public class LeadHelper {
	public static Map<String, Integer> launchControl;
    // Static initialize
    static {
        resetLaunchControl();
    }
    
    // Reset Trigger control (e.g. for testing)
    public static void resetLaunchControl() {
        launchControl = new Map<String, Integer>();
        launchControl.put('LeadConversionDefaultOpportunityFields',0);
    }
    
    // Reset Trigger control (e.g. for testing)
    public static void setLaunchControl() {
        launchControl = new Map<String, Integer>();
        launchControl.put('LeadConversionDefaultOpportunityFields',1);
    }
    
    //Default Opportunity fields value while converting Lead
    public static void LeadConversionDefaultOpportunityFields(List<Lead> leadList , Map<Id,Lead> oldLeadMap){
        if(launchControl.get('LeadConversionDefaultOpportunityFields') < 1){
            launchControl.put('LeadConversionDefaultOpportunityFields',launchControl.get('LeadConversionDefaultOpportunityFields') + 1);
            List<Opportunity> oppList = new List<Opportunity>();
            Map<Id,Id> addMap = new Map<Id,Id>();
            //Collect Account Ids from ConvertedAccountId field of Lead
            for(Lead ld : leadList){
                if(ld.ConvertedOpportunityId != null){
                    addMap.put(ld.ConvertedAccountId, null);
                }
            }
            
            //Retrive account related address and prepare map of Key = AccountId, value = AddressId
            for(Account acc : [select Id,(Select Id from Addresses__r) from Account where Id in : addMap.keySet()]){
                if(acc.Addresses__r.size() == 1){
                    addMap.put(acc.Id, acc.Addresses__r.get(0).Id);
                }
            }
            
            //Prepare Converted opportunity instance and set default value of Opportunities fields
            for(Lead ld : leadList){
                if(ld.ConvertedOpportunityId != null){
                    Opportunity opp = new Opportunity();
                    opp.Id = ld.ConvertedOpportunityId;
                    opp.Bill_To_Account__c = ld.ConvertedAccountId;
                    opp.Ship_To_Account__c = ld.ConvertedAccountId;
                    opp.Bill_To_Contact__c = ld.ConvertedContactId;
                    opp.Primary_Contact__c = ld.ConvertedContactId;
                    if(addMap.containsKey(ld.ConvertedAccountId)){
                        opp.Bill_to_Address__c = addMap.get(ld.ConvertedAccountId);
                        opp.Ship_to_Address1__c = addMap.get(ld.ConvertedAccountId);
                    }
                    oppList.add(opp);
                }
            }
            
            //Update opportunities
            if(oppList.size() > 0) update oppList;
        }
    }
}