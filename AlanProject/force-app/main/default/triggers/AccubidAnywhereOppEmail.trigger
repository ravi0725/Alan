trigger AccubidAnywhereOppEmail on Opportunity(before update) {
	if (CreateRenewalOpportunityFromEBS.runOpportunityTrigger) {

		List<OpportunityAccubidAnywhere_EmailSetting__mdt> cmdt = [SELECT IsEnable_EmailSetting__c FROM OpportunityAccubidAnywhere_EmailSetting__mdt];
		if ((cmdt[0].IsEnable_EmailSetting__c)) {
			if (Trigger.isUpdate && Trigger.isBefore) {
				if (AccubidAnywhereOppEMailHelper.isEmailTriggered1) {
					AccubidAnywhereOppEMailHelper.AccuOppEmail(Trigger.new);
				}
			}
		}

		List<Opportunity_Training_Pod_Email_Settings__mdt> trngcmdt = [SELECT IsEnable_EmailSetting__c FROM Opportunity_Training_Pod_Email_Settings__mdt];
		if ((trngcmdt[0].IsEnable_EmailSetting__c)) {
			if (Trigger.isUpdate && Trigger.isBefore) {
				if (AccubidAnywhereOppEMailHelper.isEmailTriggered2) {
					AccubidAnywhereOppEMailHelper.TRNOppEmail(Trigger.new);
				}
			}
		}

		List<AutoBid_Opp_Email__mdt> autobidcmdt = [SELECT IsEnable_EmailSetting__c FROM AutoBid_Opp_Email__mdt];
		system.debug('Autobid Custom Metadata is enabled----------------------------------------->' + autobidcmdt);
		if ((autobidcmdt[0].IsEnable_EmailSetting__c)) {
			if (Trigger.isUpdate && Trigger.isBefore) {
				system.debug('<--------------AccubidAnywhereOppEMailHelper.isEmailTriggered3----------->' + AccubidAnywhereOppEMailHelper.isEmailTriggered3);
				if (AccubidAnywhereOppEMailHelper.isEmailTriggered3) {
					system.debug('<--------------Trigger fires AutoBidEmail from Helper----------->');
					AccubidAnywhereOppEMailHelper.AutoBidEmail(Trigger.new);
				}
			}
		}

		List<OpportunityEstimationProductsEmailAlert__mdt> ESTcmdt = [SELECT IsEnable_EmailSetting__c FROM OpportunityEstimationProductsEmailAlert__mdt];
		system.debug('T-EST Custom Metadata is enabled----------------------------------------->' + ESTcmdt);
		if ((ESTcmdt[0].IsEnable_EmailSetting__c)) {
			if (Trigger.isUpdate && Trigger.isBefore) {
				if (AccubidAnywhereOppEMailHelper.isEmailTriggered4) {
					AccubidAnywhereOppEMailHelper.EstOppProdEmail(Trigger.new);
				}
			}
		}

	}
}