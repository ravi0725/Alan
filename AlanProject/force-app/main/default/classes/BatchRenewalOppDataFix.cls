/*****************************************************************************************
  Name    : BatchRenewalOppDataFix 
  Desc    : Used to fix Adding new Product Growth in Opportunity using batch mode 
  Modification Log :
  ---------------------------------------------------------------------------
  Developer              Date            Description
  ---------------------------------------------------------------------------
  Suresh Babu Murugan	12/APR/2020          Created
 ******************************************************************************************/
global class BatchRenewalOppDataFix Implements Database.batchable<sobject> {
	global final string query;

	global BatchRenewalOppDataFix() {
		if (test.isrunningTest())
		query = 'SELECT Id, Name FROM Opportunity WHERE Selling_Division__c = \'MEP NA\' AND Renewal_Lines_Count__c > 0 AND StageName = \'6 - Closed Won\' AND Line_Item_Count__c > 0 ORDER BY CreatedDate LIMIT 1';
		else
		query = 'SELECT Id, Name FROM Opportunity WHERE Selling_Division__c = \'MEP NA\' AND Renewal_Lines_Count__c > 0 AND StageName = \'6 - Closed Won\' AND Line_Item_Count__c > 0 ORDER BY CreatedDate';
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		system.debug('********' + Database.getQueryLocator(query));
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<SObject> scope) {
		try {
			List<Opportunity> batchList = new List<Opportunity> ();
			batchList = scope;
			Id OppId = batchList.get(0).Id;

			Opportunity oppRecord = [SELECT Id FROM Opportunity WHERE Id = :OppId];
			system.debug('---sync---oppRecord---' + oppRecord);

			Boolean isDummyUpdateNeeded = false;
			for (OpportunityLineItem oppLine :[SELECT Id, Product_Growth__c FROM OpportunityLineItem WHERE OpportunityId = :OppId]) {
				if (oppLine.Product_Growth__c != 'Renewal') {
					isDummyUpdateNeeded = true;
					break;
				}
			}

			if (isDummyUpdateNeeded) {
				update oppRecord;
			}
		}
		catch(Exception ex) {
			System.debug(' ERROR EXCEPTION :::' + ex.getTypeName() + ' : ' + ex.getMessage() + ' : ' + ex.getLineNumber() + ' : ' + ex.getCause());
		}
	}

	global void finish(Database.BatchableContext BC) { }
}