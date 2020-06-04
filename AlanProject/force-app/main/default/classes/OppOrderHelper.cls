public class OppOrderHelper {

	static {
		OpportunityHelper.setLaunchControl();
		CreateRenewalOpportunityFromEBS.runOpportunityTrigger = false;
		CreateRenewalOpportunityFromEBS.setLaunchControl();
		RecursiveTriggerUtility.isSetPriceBookDefaultTriggerRecursive = true;
	}

	public static void OppOrder(List<Order__c> lstNewOrders) {
		Map<ID, Opportunity> ParentOpps = new Map<ID, Opportunity> ();
		List<Id> listIds = new List<Id> ();
		List<Opportunity> OpptoUpdate = new List<Opportunity> ();

		for (Order__c ord1 : lstNewOrders) {
			if (ord1.Opportunity_ID__c != null && ord1.Oracle_Order_Number__c != null) {
				Opportunity ParentOpp = new Opportunity(Id = ord1.Opportunity_Id__c);
				ParentOpp.Oracle_Order_Id__c = ord1.Oracle_Order_Number__c;
				System.debug(' ParentOpp =====>'+ParentOpp);
				OpptoUpdate.add(ParentOpp);
			}
		}
		if (OpptoUpdate.size() > 0) {
			try {
				update OpptoUpdate;
			}
			catch(DMLException ex) {
			}
		}
	}
}