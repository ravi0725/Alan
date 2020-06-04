public with sharing class ApttusProposalFlows {

	@InvocableMethod(label='Update Proposal Service Dates' description='This method used in Process builder to update Proposal Service Dates')
	public static void updateProposalServiceDates (List<Id> lstPropIDs) {
		Map<String, Date> mapServiceStart = new Map<String, Date>();
		Map<String, Date> mapServiceEnd = new Map<String, Date>();
		List<Apttus_Proposal__Proposal__c> lstProposals = [SELECT Id, Name, Service_Start_Date__c, Service_End_Date__c FROM Apttus_Proposal__Proposal__c WHERE Id IN : lstPropIDs];
		List<AggregateResult> lstPropLines = [SELECT MIN(Service_Start_Date__c) minStartDate, MAX(Service_End_Date__c) maxEndDate, Apttus_Proposal__Proposal__c pID FROM Apttus_Proposal__Proposal_Line_Item__c WHERE Apttus_Proposal__Proposal__c IN : lstPropIDs AND Service_Start_Date__c != NULL AND Service_End_Date__c != NULL GROUP BY Apttus_Proposal__Proposal__c];
		for(AggregateResult pItem : lstPropLines){
			mapServiceStart.put(String.valueOf(pItem.get('pID')), Date.valueOf(pItem.get('minStartDate')));
			mapServiceEnd.put(String.valueOf(pItem.get('pID')), Date.valueOf(pItem.get('maxEndDate')));
		}

		for(Apttus_Proposal__Proposal__c prop : lstProposals){
			if(mapServiceStart.containsKey(prop.Id)){
				prop.Service_Start_Date__c = mapServiceStart.get(prop.Id);
			}
			if(mapServiceEnd.containsKey(prop.Id)){
				prop.Service_End_Date__c = mapServiceEnd.get(prop.Id);
			}
		}
		if(lstProposals.size() > 0){
			update lstProposals;
		}
	}
}