/**
 * Company     : Trimble Software Technology Pvt Ltd.,
 * Description : Quote - Higher Discount calculation class 
 * History     :  
 
 * [17.04.2016] Suresh Babu Murugan  Created
 * [10.05.2016] Suresh Babu Murugan  Modified    Due to Apttus Proposal Line Item: Catehory Hierarchy format was changed, updated code to fix the amount calculation issue
*/
public class QuoteHigherDiscountCalculation {
	public static Map<String, Integer> launchControl;

	// Static initialize
	static {
		resetLaunchControl();
	}

	// Reset Trigger control (e.g. for testing)
	public static void resetLaunchControl() {
		launchControl = new Map<String, Integer> ();
		launchControl.put('higherDiscountCalculation', 0);
	}

	/*
	 * This method is used to update Proposal with Higer discounts
	 * Parameter : List<Apttus_Proposal__Proposal__c> NewProposalUpdates
	 * Return Type: void
	 */
	public static void higherDiscountCalculation(List<Apttus_Proposal__Proposal__c> newProposalList) {
		if (launchControl.get('higherDiscountCalculation') < 1) {
			launchControl.put('higherDiscountCalculation', launchControl.get('higherDiscountCalculation') + 1);

			Boolean isTIBVQuote = false;
			Set<Id> setProposalIDs = new Set<Id> ();
			Set<String> setQuotePriceListNames = new Set<String> ();
			for (Apttus_Proposal__Proposal__c proposal : newProposalList) {
				System.debug('Selected Quote Pricelist :::::: ' + proposal.Pricelist_Name__c);
				if (proposal.Pricelist_Name__c != Null && proposal.Pricelist_Name__c.startsWith('TIBV')) {
					setProposalIDs.add(proposal.Id);
					setQuotePriceListNames.add(proposal.Pricelist_Name__c);
					isTIBVQuote = true;
				}
			}

			if (isTIBVQuote) { // These calculation only works for TIBV Quotes
				Map<String, String> mapCategories = new Map<String, String> ();
				mapCategories = retrieveAllCatagoryHierarchies(setQuotePriceListNames);

				// Query all Proposal Line Items using Proposal Id
				List<Apttus_Proposal__Proposal_Line_Item__c> lstProposalLineItems = [SELECT
				                                                                     Id, Apttus_QPConfig__NetAdjustmentPercent__c, Apttus_QPConfig__AdjustmentType__c, Apttus_QPConfig__ListPrice__c,
				                                                                     Apttus_QPConfig__ExtendedPrice__c, Apttus_QPConfig__Quantity2__c, Net_Discount__c, Discount_Amount__c, Apttus_QPConfig__NetPrice__c,
				                                                                     Apttus_QPConfig__NetUnitPrice__c, Apttus_QPConfig__BasePriceOverride__c, Apttus_Proposal__Proposal__c, Service_Start_Date__c, Service_End_Date__c, EBS_Discount_Percentage__c, Apttus_QPConfig__PriceUom__c,
				                                                                     Apttus_QPConfig__ChargeType__c, Apttus_QPConfig__ClassificationHierarchy__c, Apttus_QPConfig__LineType__c, Apttus_QPConfig__IsPrimaryLine__c, Net_Price_Month__c, Number_of_Months__c, List_Price_Disp_Month__c,
				                                                                     Actual_List_Price__c, Product_ICC_Type__c, Apttus_QPConfig__OptionId__r.Product_Category_Type__c, Apttus_Proposal__Product__r.Product_Category_Type__c, Actual_Extended_Price__c, Actual_Discount_Amount__c, Extended_List_Price__c, Apttus_QPConfig__PriceListId__r.Name
				                                                                     FROM
				                                                                     Apttus_Proposal__Proposal_Line_Item__c
				                                                                     WHERE
				                                                                     Apttus_Proposal__Proposal__c IN :setProposalIDs AND
				                                                                     Apttus_QPConfig__PriceListId__c != null AND
				                                                                     Apttus_QPConfig__PriceListId__r.Name LIKE '%TIBV%' AND
				                                                                     Apttus_QPConfig__ChargeType__c != null AND
				                                                                     Apttus_QPConfig__LineType__c != null AND
				((Apttus_QPConfig__ChargeType__c = 'Maintenance Fee' AND Apttus_QPConfig__LineType__c = 'Option') OR
				(Apttus_QPConfig__ChargeType__c LIKE 'Standard%'))
				                                                                     ORDER BY Apttus_Proposal__Proposal__r.Name ASC
				                                                                    ];

				if (lstProposalLineItems.size() > 0) {
					Map<Id, amountsWrapper> TotalMap = new Map<Id, amountsWrapper> ();
					Decimal SoftwareTotalAmount = 0.0;
					Decimal SoftwareHigher_DiscountAmount = 0.0;
					Decimal Software_ActualDiscountAmount = 0.0;
					Decimal Software_DiscountAmount = 0.0;

					Decimal HardwareTotalAmount = 0.0;
					Decimal HardwareHigher_DiscountAmount = 0.0;
					Decimal Hardware_ActualDiscountAmount = 0.0;
					Decimal Hardware_DiscountAmount = 0.0;

					Decimal MaintenanceTotalAmount = 0.0;
					Decimal MaintenanceHigher_DiscountAmount = 0.0;
					Decimal Maintenance_ActualDiscountAmount = 0.0;
					Decimal Maintenance_DiscountAmount = 0.0;

					Decimal SpecialServicesTotalAmount = 0.0;
					Decimal SpecialServicesHigher_DiscountAmount = 0.0;
					Decimal SpecialServices_ActualDiscountAmount = 0.0;
					Decimal SpecialServices_DiscountAmount = 0.0;

					Decimal ThirdPartyTotalAmount = 0.0;
					Decimal ThirdPartyHigher_DiscountAmount = 0.0;
					Decimal ThirdParty_ActualDiscountAmount = 0.0;
					Decimal ThirdParty_DiscountAmount = 0.0;

					Decimal TrainingTotalAmount = 0.0;
					Decimal TrainingHigher_DiscountAmount = 0.0;
					Decimal Training_ActualDiscountAmount = 0.0;
					Decimal Training_DiscountAmount = 0.0;

					Decimal OthersTotalAmount = 0.0;
					Decimal OthersHigher_DiscountAmount = 0.0;
					Decimal Others_ActualDiscountAmount = 0.0;
					Decimal Others_DiscountAmount = 0.0;

					Decimal ServicesTotalAmount = 0.0;
					Decimal ServicesHigher_DiscountAmount = 0.0;
					Decimal Services_ActualDiscountAmount = 0.0;
					Decimal Services_DiscountAmount = 0.0;


					for (Apttus_Proposal__Proposal_Line_Item__c pLineItem : lstProposalLineItems) {
						Decimal Discount_Amount = pLineItem.Apttus_QPConfig__ExtendedPrice__c - pLineItem.Apttus_QPConfig__NetPrice__c;

						system.debug(' pLineItem Net Adjustment :::::::::::::::::::' + pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c);
						system.debug(' pLineItem Charge Type:::::::::::::::::::' + pLineItem.Apttus_QPConfig__ChargeType__c);
						system.debug(' pLineItem Classification Higherarchy :::::::::::::::::::' + pLineItem.Apttus_QPConfig__ClassificationHierarchy__c);
						system.debug(' pLineItem Actual List Price :::::::::::::::::::' + pLineItem.Actual_List_Price__c);
						system.debug(' pLineItem List Price :::::::::::::::::::' + pLineItem.Apttus_QPConfig__ListPrice__c);
						system.debug(' pLineItem Extended Price :::::::::::::::::::' + pLineItem.Extended_List_Price__c);
						system.debug(' pLineItem Actual Discount Price :::::::::::::::::::' + pLineItem.Actual_Discount_Amount__c);
						system.debug(' pLineItem Net Price :::::::::::::::::::' + pLineItem.Apttus_QPConfig__NetPrice__c);
						system.debug(' pLineItem Discounted Amount :::::::::::::::::::' + pLineItem.Discount_Amount__c);
						system.debug(' pLineItem Discounted Calculated :::::::::::::::::::' + Discount_Amount);

						System.debug(LoggingLevel.DEBUG, 'PlistNAME: ' + pLineItem.Apttus_QPConfig__PriceListId__r.Name);
						String minimizedCategoryHierarchy = (pLineItem.Apttus_QPConfig__ClassificationHierarchy__c != null && pLineItem.Apttus_QPConfig__ClassificationHierarchy__c.contains('|') ? pLineItem.Apttus_QPConfig__ClassificationHierarchy__c.substringAfterLast('|').trim() : pLineItem.Apttus_QPConfig__ClassificationHierarchy__c);
						System.debug(LoggingLevel.DEBUG, ' MIN : ' + minimizedCategoryHierarchy);
						String ancestorName = (minimizedCategoryHierarchy != null && mapCategories.containsKey(pLineItem.Apttus_QPConfig__PriceListId__r.Name + '~' + minimizedCategoryHierarchy) ? mapCategories.get(pLineItem.Apttus_QPConfig__PriceListId__r.Name + '~' + minimizedCategoryHierarchy) : null);
						System.debug(LoggingLevel.DEBUG, ' ancestorName : ' + ancestorName);
						String strProductCategoryType = (pLineItem.Apttus_Proposal__Product__r.Product_Category_Type__c != null ? pLineItem.Apttus_Proposal__Product__r.Product_Category_Type__c : (pLineItem.Apttus_QPConfig__OptionId__r.Product_Category_Type__c != null ? pLineItem.Apttus_QPConfig__OptionId__r.Product_Category_Type__c : null));
						System.debug(LoggingLevel.DEBUG, ' strProductCategoryType : ' + strProductCategoryType);

						// Reset Amount variables if this class handles multiple Quotes in sametime
						if (!TotalMap.containsKey(pLineItem.Apttus_Proposal__Proposal__c)) {
							SoftwareTotalAmount = 0.0;
							SoftwareHigher_DiscountAmount = 0.0;
							Software_ActualDiscountAmount = 0.0;
							Software_DiscountAmount = 0.0;
							HardwareTotalAmount = 0.0;
							HardwareHigher_DiscountAmount = 0.0;
							Hardware_ActualDiscountAmount = 0.0;
							Hardware_DiscountAmount = 0.0;
							MaintenanceTotalAmount = 0.0;
							MaintenanceHigher_DiscountAmount = 0.0;
							Maintenance_ActualDiscountAmount = 0.0;
							Maintenance_DiscountAmount = 0.0;
							SpecialServicesTotalAmount = 0.0;
							SpecialServicesHigher_DiscountAmount = 0.0;
							SpecialServices_ActualDiscountAmount = 0.0;
							SpecialServices_DiscountAmount = 0.0;
							ThirdPartyTotalAmount = 0.0;
							ThirdPartyHigher_DiscountAmount = 0.0;
							ThirdParty_ActualDiscountAmount = 0.0;
							ThirdParty_DiscountAmount = 0.0;
							TrainingTotalAmount = 0.0;
							TrainingHigher_DiscountAmount = 0.0;
							Training_ActualDiscountAmount = 0.0;
							Training_DiscountAmount = 0.0;
							OthersTotalAmount = 0.0;
							OthersHigher_DiscountAmount = 0.0;
							Others_ActualDiscountAmount = 0.0;
							Others_DiscountAmount = 0.0;
							ServicesTotalAmount = 0.0;
							ServicesHigher_DiscountAmount = 0.0;
							Services_ActualDiscountAmount = 0.0;
							Services_DiscountAmount = 0.0;
						}

						// Software Product Total Calculation
						if (pLineItem.Actual_List_Price__c != null &&
						    pLineItem.Actual_List_Price__c == pLineItem.Apttus_QPConfig__ListPrice__c) { // Both SFDC and EBS List prices are same

							if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c > 0 &&
							    pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							(ancestorName != null && ancestorName.containsOnly('Software')) ||
							(strProductCategoryType != null && (strProductCategoryType.containsOnly('Software') || strProductCategoryType.containsOnly('SaaS')))) {
								// if this Percentage is Greater than 0, User giving Higher Discount

								SoftwareTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								SoftwareHigher_DiscountAmount += (Discount_Amount * - 1); // To get positive amount
							}
							else if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c <= 0 &&
							         pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							(ancestorName != null && ancestorName.containsOnly('Software')) ||
							(strProductCategoryType != null && (strProductCategoryType.containsOnly('Software') || strProductCategoryType.containsOnly('SaaS')))) {

								//SoftwareTotalAmount += pLineItem.Apttus_QPConfig__ExtendedPrice__c;
								//SoftwareTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								if (pLineItem.Apttus_QPConfig__AdjustmentType__c != 'Price Override') {
									Software_DiscountAmount += Discount_Amount;
									SoftwareTotalAmount += pLineItem.Apttus_QPConfig__ExtendedPrice__c;
								}
								else {
									SoftwareTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								}
							}
						}
						else if (pLineItem.Actual_List_Price__c != null &&
						         pLineItem.Actual_List_Price__c != pLineItem.Apttus_QPConfig__ListPrice__c) {

							if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c > 0 &&
							    pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							(ancestorName != null && ancestorName.containsOnly('Software')) ||
							(strProductCategoryType != null && (strProductCategoryType.containsOnly('Software') || strProductCategoryType.containsOnly('SaaS')))) { // if this Percentage is Greater than 0, User giving Higher Discount

								SoftwareTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c + pLineItem.Actual_Discount_Amount__c;
								Software_ActualDiscountAmount += pLineItem.Actual_Discount_Amount__c;
								SoftwareHigher_DiscountAmount += (Discount_Amount * - 1); // To get positive amount
							}
							else if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c <= 0 &&
							         pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							(ancestorName != null && ancestorName.containsOnly('Software')) ||
							(strProductCategoryType != null && (strProductCategoryType.containsOnly('Software') || strProductCategoryType.containsOnly('SaaS')))) {

								if (pLineItem.Apttus_QPConfig__AdjustmentType__c != 'Price Override') {
									Software_DiscountAmount += Discount_Amount;
									SoftwareTotalAmount += pLineItem.Actual_Extended_Price__c;
									Software_ActualDiscountAmount += pLineItem.Actual_Discount_Amount__c;
								}
								else {
									SoftwareTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								}
							}
						}
						system.debug('SoftwareTotalAmount ::::::::::::::::::::::::::::::::::::>>' + SoftwareTotalAmount);

						// Third Party Software total Calculation
						if (pLineItem.Actual_List_Price__c != null &&
						    pLineItem.Actual_List_Price__c == pLineItem.Apttus_QPConfig__ListPrice__c) { // Both SFDC and EBS List prices are same

							if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c > 0 &&
							    pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							    ancestorName != null &&
							    ancestorName == 'Third Party Software') { // if this Percentage is Greater than 0, User giving Higher Discount
								ThirdPartyTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								ThirdPartyHigher_DiscountAmount += (Discount_Amount * - 1); // To get positive amount
							}
							else if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c <= 0 &&
							         pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							         ancestorName != null &&
							         ancestorName == 'Third Party Software') {

								if (pLineItem.Apttus_QPConfig__AdjustmentType__c != 'Price Override') {
									ThirdParty_DiscountAmount += Discount_Amount;
									ThirdPartyTotalAmount += pLineItem.Apttus_QPConfig__ExtendedPrice__c;
								}
								else {
									ThirdPartyTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								}
							}
						}
						else if (pLineItem.Actual_List_Price__c != null &&
						         pLineItem.Actual_List_Price__c != pLineItem.Apttus_QPConfig__ListPrice__c) {

							if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c > 0 &&
							    pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							    ancestorName != null &&
							    ancestorName == 'Third Party Software') { // if this Percentage is Greater than 0, User giving Higher Discount

								ThirdPartyTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c + pLineItem.Actual_Discount_Amount__c;
								ThirdParty_ActualDiscountAmount += pLineItem.Actual_Discount_Amount__c;
								ThirdParty_DiscountAmount += (Discount_Amount * - 1); // To get positive amount
							}
							else if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c <= 0 &&
							         pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							         ancestorName != null &&
							         ancestorName == 'Third Party Software') {

								if (pLineItem.Apttus_QPConfig__AdjustmentType__c != 'Price Override') {
									ThirdParty_DiscountAmount += Discount_Amount;
									ThirdPartyTotalAmount += pLineItem.Actual_Extended_Price__c;
									ThirdParty_ActualDiscountAmount += pLineItem.Actual_Discount_Amount__c;
								}
								else {
									ThirdPartyTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								}
							}
						}

						// Other Products total Calculation
						if (pLineItem.Actual_List_Price__c != null && pLineItem.Actual_List_Price__c == pLineItem.Apttus_QPConfig__ListPrice__c) {

							if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c > 0 &&
							    pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							(ancestorName != null && ancestorName.containsOnly('Other')) ||
							(strProductCategoryType != null && strProductCategoryType.containsOnly('Other'))) {
								// if this Percentage is Greater than 0, User giving Higher Discount

								OthersTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								OthersHigher_DiscountAmount += (Discount_Amount * - 1); // To get positive amount
							}
							else if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c <= 0 &&
							         pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							(ancestorName != null && ancestorName.containsOnly('Other')) ||
							(strProductCategoryType != null && strProductCategoryType.containsOnly('Other'))) {

								if (pLineItem.Apttus_QPConfig__AdjustmentType__c != 'Price Override') {
									Others_DiscountAmount += Discount_Amount;
									OthersTotalAmount += pLineItem.Apttus_QPConfig__ExtendedPrice__c;
								}
								else {
									OthersTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								}
							}
						}
						else if (pLineItem.Actual_List_Price__c != null && pLineItem.Actual_List_Price__c != pLineItem.Apttus_QPConfig__ListPrice__c) {

							if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c > 0 &&
							    pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							(ancestorName != null && ancestorName.containsOnly('Other')) ||
							(strProductCategoryType != null && strProductCategoryType.containsOnly('Other'))) { // if this Percentage is Greater than 0, User giving Higher Discount

								OthersTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c + pLineItem.Actual_Discount_Amount__c;
								Others_ActualDiscountAmount += pLineItem.Actual_Discount_Amount__c;
								OthersHigher_DiscountAmount += (Discount_Amount * - 1); // To get positive amount
							}
							else if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c <= 0 &&
							         pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							(ancestorName != null && ancestorName.containsOnly('Other')) ||
							(strProductCategoryType != null && strProductCategoryType.containsOnly('Other'))) {

								if (pLineItem.Apttus_QPConfig__AdjustmentType__c != 'Price Override') {
									Others_DiscountAmount += Discount_Amount;
									OthersTotalAmount += pLineItem.Actual_Extended_Price__c;
									Others_ActualDiscountAmount += pLineItem.Actual_Discount_Amount__c;
								}
								else {
									OthersTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								}
							}
						}

						// Service Products total Calculation
						if (pLineItem.Actual_List_Price__c != null && pLineItem.Actual_List_Price__c == pLineItem.Apttus_QPConfig__ListPrice__c) {
							if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c > 0 &&
							    pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							(ancestorName != null && ancestorName.containsOnly('Services')) ||
							(strProductCategoryType != null && (strProductCategoryType.containsOnly('Services') || strProductCategoryType.containsOnly('Rental')))) { // if this Percentage is Greater than 0, User giving Higher Discount

								ServicesTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								ServicesHigher_DiscountAmount += (Discount_Amount * - 1); // To get positive amount
							}
							else if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c <= 0 &&
							         pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							(ancestorName != null && ancestorName.containsOnly('Services')) ||
							(strProductCategoryType != null && (strProductCategoryType.containsOnly('Services') || strProductCategoryType.containsOnly('Rental')))) {
								if (pLineItem.Apttus_QPConfig__AdjustmentType__c != 'Price Override') {
									Services_DiscountAmount += Discount_Amount;
									ServicesTotalAmount += pLineItem.Apttus_QPConfig__ExtendedPrice__c;
								}
								else {
									ServicesTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								}
							}
						}
						else if (pLineItem.Actual_List_Price__c != null && pLineItem.Actual_List_Price__c != pLineItem.Apttus_QPConfig__ListPrice__c) {
							if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c > 0 &&
							    pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							(ancestorName != null && ancestorName.containsOnly('Services')) ||
							(strProductCategoryType != null && (strProductCategoryType.containsOnly('Services') || strProductCategoryType.containsOnly('Rental')))) { // if this Percentage is Greater than 0, User giving Higher Discount

								ServicesTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c + pLineItem.Actual_Discount_Amount__c;
								Services_ActualDiscountAmount += pLineItem.Actual_Discount_Amount__c;
								ServicesHigher_DiscountAmount += (Discount_Amount * - 1); // To get positive amount
							}
							else if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c <= 0 &&
							         pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							(ancestorName != null && ancestorName.containsOnly('Services')) ||
							(strProductCategoryType != null && (strProductCategoryType.containsOnly('Services') || strProductCategoryType.containsOnly('Rental')))) {
								if (pLineItem.Apttus_QPConfig__AdjustmentType__c != 'Price Override') {
									Services_DiscountAmount += Discount_Amount;
									ServicesTotalAmount += pLineItem.Actual_Extended_Price__c;
									Services_ActualDiscountAmount += pLineItem.Actual_Discount_Amount__c;
								}
								else {
									ServicesTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								}
							}
						}

						// Training total Calculation
						if (pLineItem.Actual_List_Price__c != null && pLineItem.Actual_List_Price__c == pLineItem.Apttus_QPConfig__ListPrice__c) {
							if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c > 0 &&
							    pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							    minimizedCategoryHierarchy != null &&
							    minimizedCategoryHierarchy.containsOnly('Training')) { // if this Percentage is Greater than 0, User giving Higher Discount

								TrainingTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								TrainingHigher_DiscountAmount += (Discount_Amount * - 1); // To get positive amount
							}
							else if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c <= 0 &&
							         pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							         minimizedCategoryHierarchy != null &&
							         minimizedCategoryHierarchy.containsOnly('Training')) {
								if (pLineItem.Apttus_QPConfig__AdjustmentType__c != 'Price Override') {
									Training_DiscountAmount += Discount_Amount;
									TrainingTotalAmount += pLineItem.Apttus_QPConfig__ExtendedPrice__c;
								}
								else {
									TrainingTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								}
							}
						}
						else if (pLineItem.Actual_List_Price__c != null && pLineItem.Actual_List_Price__c != pLineItem.Apttus_QPConfig__ListPrice__c) {
							if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c > 0 &&
							    pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							    minimizedCategoryHierarchy != null &&
							    minimizedCategoryHierarchy.containsOnly('Training')) { // if this Percentage is Greater than 0, User giving Higher Discount

								TrainingTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c + pLineItem.Actual_Discount_Amount__c;
								Training_ActualDiscountAmount += pLineItem.Actual_Discount_Amount__c;
								TrainingHigher_DiscountAmount += (Discount_Amount * - 1); // To get positive amount
							}
							else if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c <= 0 &&
							         pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							         minimizedCategoryHierarchy != null &&
							         minimizedCategoryHierarchy.containsOnly('Training')) {
								if (pLineItem.Apttus_QPConfig__AdjustmentType__c != 'Price Override') {

									Training_DiscountAmount += Discount_Amount;
									TrainingTotalAmount += pLineItem.Actual_Extended_Price__c;
									Training_ActualDiscountAmount += pLineItem.Actual_Discount_Amount__c;
								}
								else {
									TrainingTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								}
							}
						}

						// Special Services total Calculation
						if (pLineItem.Actual_List_Price__c != null && pLineItem.Actual_List_Price__c == pLineItem.Apttus_QPConfig__ListPrice__c) {
							if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c > 0 &&
							    pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							    minimizedCategoryHierarchy != null &&
							    minimizedCategoryHierarchy.containsOnly('Special Services')) { // if this Percentage is Greater than 0, User giving Higher Discount

								SpecialServicesTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								SpecialServicesHigher_DiscountAmount += (Discount_Amount * - 1); // To get positive amount
							}
							else if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c <= 0 &&
							         pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							         minimizedCategoryHierarchy != null &&
							         minimizedCategoryHierarchy.containsOnly('Special Services')) {
								if (pLineItem.Apttus_QPConfig__AdjustmentType__c != 'Price Override') {
									SpecialServices_DiscountAmount += Discount_Amount;
									SpecialServicesTotalAmount += pLineItem.Apttus_QPConfig__ExtendedPrice__c;
								}
								else {
									SpecialServicesTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								}
							}
						}
						else if (pLineItem.Actual_List_Price__c != null && pLineItem.Actual_List_Price__c != pLineItem.Apttus_QPConfig__ListPrice__c) {
							if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c > 0 &&
							    pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							    minimizedCategoryHierarchy != null &&
							    minimizedCategoryHierarchy.containsOnly('Special Services')) { // if this Percentage is Greater than 0, User giving Higher Discount

								SpecialServicesTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c + pLineItem.Actual_Discount_Amount__c;
								SpecialServices_ActualDiscountAmount += pLineItem.Actual_Discount_Amount__c;
								SpecialServicesHigher_DiscountAmount += (Discount_Amount * - 1); // To get positive amount
							}
							else if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c <= 0 &&
							         pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							         minimizedCategoryHierarchy != null &&
							         minimizedCategoryHierarchy.containsOnly('Special Services')) {
								if (pLineItem.Apttus_QPConfig__AdjustmentType__c != 'Price Override') {

									SpecialServices_DiscountAmount += Discount_Amount;
									SpecialServicesTotalAmount += pLineItem.Actual_Extended_Price__c;
									SpecialServices_ActualDiscountAmount += pLineItem.Actual_Discount_Amount__c;
								}
								else {
									SpecialServicesTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								}
							}
						}

						// Hardware total Calculation
						if (pLineItem.Actual_List_Price__c != null && pLineItem.Actual_List_Price__c == pLineItem.Apttus_QPConfig__ListPrice__c) {
							if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c > 0 &&
							    pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							    pLineItem.Apttus_QPConfig__LineType__c != 'Option' &&
							(ancestorName != null && ancestorName.containsOnly('Hardware')) ||
							(strProductCategoryType != null && strProductCategoryType.containsOnly('Hardware'))) { // if this Percentage is Greater than 0, User giving Higher Discount

								HardwareTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								HardwareHigher_DiscountAmount += (Discount_Amount * - 1); // To get positive amount
							}
							else if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c <= 0 &&
							         pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							         pLineItem.Apttus_QPConfig__LineType__c != 'Option' &&
							(ancestorName != null && ancestorName.containsOnly('Hardware')) ||
							(strProductCategoryType != null && strProductCategoryType.containsOnly('Hardware'))) {
								if (pLineItem.Apttus_QPConfig__AdjustmentType__c != 'Price Override') {
									Hardware_DiscountAmount += Discount_Amount;
									HardwareTotalAmount += pLineItem.Apttus_QPConfig__ExtendedPrice__c;
								}
								else {
									HardwareTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								}
							}
						}
						else if (pLineItem.Actual_List_Price__c != null && pLineItem.Actual_List_Price__c != pLineItem.Apttus_QPConfig__ListPrice__c) {
							if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c > 0 &&
							    pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							    pLineItem.Apttus_QPConfig__LineType__c != 'Option' &&
							(ancestorName != null && ancestorName.containsOnly('Hardware')) ||
							(strProductCategoryType != null && strProductCategoryType.containsOnly('Hardware'))) { // if this Percentage is Greater than 0, User giving Higher Discount

								HardwareTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c + pLineItem.Actual_Discount_Amount__c;
								Hardware_ActualDiscountAmount += pLineItem.Actual_Discount_Amount__c;
								HardwareHigher_DiscountAmount += (Discount_Amount * - 1); // To get positive amount
							}
							else if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c <= 0 &&
							         pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							         pLineItem.Apttus_QPConfig__LineType__c != 'Option' &&
							(ancestorName != null && ancestorName.containsOnly('Hardware')) ||
							(strProductCategoryType != null && strProductCategoryType.containsOnly('Hardware'))) {
								if (pLineItem.Apttus_QPConfig__AdjustmentType__c != 'Price Override') {
									Hardware_DiscountAmount += Discount_Amount;
									HardwareTotalAmount += pLineItem.Actual_Extended_Price__c;
									Hardware_ActualDiscountAmount += pLineItem.Actual_Discount_Amount__c;
								}
								else {
									HardwareTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								}
							}
						}

						// Maintenance total Calculation
						if (pLineItem.Actual_List_Price__c != null && pLineItem.Actual_List_Price__c == pLineItem.Apttus_QPConfig__ListPrice__c) {
							if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c > 0 &&
							    pLineItem.Apttus_QPConfig__ChargeType__c == 'Maintenance Fee' &&
							    pLineItem.Apttus_QPConfig__LineType__c == 'Option') { // if this Percentage is Greater than 0, User giving Higher Discount

								MaintenanceTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								MaintenanceHigher_DiscountAmount += (Discount_Amount * - 1); // To get positive amount
							}
							else if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c <= 0 &&
							         pLineItem.Apttus_QPConfig__ChargeType__c == 'Maintenance Fee' &&
							         pLineItem.Apttus_QPConfig__LineType__c == 'Option') {
								if (pLineItem.Apttus_QPConfig__AdjustmentType__c != 'Price Override') {
									Maintenance_DiscountAmount += Discount_Amount;
									MaintenanceTotalAmount += pLineItem.Apttus_QPConfig__ExtendedPrice__c;
								}
								else {
									MaintenanceTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								}
							}
						}
						else if (pLineItem.Actual_List_Price__c != null && pLineItem.Actual_List_Price__c != pLineItem.Apttus_QPConfig__ListPrice__c) {
							if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c > 0 &&
							    pLineItem.Apttus_QPConfig__ChargeType__c == 'Maintenance Fee' &&
							    pLineItem.Apttus_QPConfig__LineType__c == 'Option') { // if this Percentage is Greater than 0, User giving Higher Discount

								MaintenanceTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c + pLineItem.Actual_Discount_Amount__c;
								Maintenance_ActualDiscountAmount += pLineItem.Actual_Discount_Amount__c;
								MaintenanceHigher_DiscountAmount += (Discount_Amount * - 1); // To get positive amount
							}
							else if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c <= 0 &&
							         pLineItem.Apttus_QPConfig__ChargeType__c == 'Maintenance Fee' &&
							         pLineItem.Apttus_QPConfig__LineType__c == 'Option') {
								if (pLineItem.Apttus_QPConfig__AdjustmentType__c != 'Price Override') {
									Maintenance_DiscountAmount += Discount_Amount;
									MaintenanceTotalAmount += pLineItem.Actual_Extended_Price__c;
									Maintenance_ActualDiscountAmount += pLineItem.Actual_Discount_Amount__c;
								}
								else {
									MaintenanceTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								}
							}
						}
						System.debug('TOTALMAP TEST::: ' + TotalMap);
						//--------------------------------------------//
						if (TotalMap.containsKey(pLineItem.Apttus_Proposal__Proposal__c)) {
							amountsWrapper swTotal = new amountsWrapper();
							swTotal = TotalMap.get(pLineItem.Apttus_Proposal__Proposal__c);
							swTotal.softwareTotal = SoftwareTotalAmount;
							swTotal.softwareHigherDiscount = SoftwareHigher_DiscountAmount;
							swTotal.softwareActualDiscount = Software_ActualDiscountAmount;
							swTotal.softwareDiscount = Software_DiscountAmount;

							swTotal.HardwareTotal = HardwareTotalAmount;
							swTotal.HardwareHigherDiscount = HardwareHigher_DiscountAmount;
							swTotal.HardwareActualDiscount = Hardware_ActualDiscountAmount;
							swTotal.HardwareDiscount = Hardware_DiscountAmount;

							swTotal.MaintenanceTotal = MaintenanceTotalAmount;
							swTotal.MaintenanceHigherDiscount = MaintenanceHigher_DiscountAmount;
							swTotal.MaintenanceActualDiscount = Maintenance_ActualDiscountAmount;
							swTotal.MaintenanceDiscount = Maintenance_DiscountAmount;

							swTotal.SpecialServicesTotal = SpecialServicesTotalAmount;
							swTotal.SpecialServicesHigherDiscount = SpecialServicesHigher_DiscountAmount;
							swTotal.SpecialServicesActualDiscount = SpecialServices_ActualDiscountAmount;
							swTotal.SpecialServicesDiscount = SpecialServices_DiscountAmount;

							swTotal.TrainingTotal = TrainingTotalAmount;
							swTotal.TrainingHigherDiscount = TrainingHigher_DiscountAmount;
							swTotal.TrainingActualDiscount = Training_ActualDiscountAmount;
							swTotal.TrainingDiscount = Training_DiscountAmount;

							swTotal.ThirdPartyTotal = ThirdPartyTotalAmount;
							swTotal.ThirdPartyHigherDiscount = ThirdPartyHigher_DiscountAmount;
							swTotal.ThirdPartyActualDiscount = ThirdParty_ActualDiscountAmount;
							swTotal.ThirdPartyDiscount = ThirdParty_DiscountAmount;

							swTotal.OthersTotal = OthersTotalAmount;
							swTotal.OthersHigherDiscount = OthersHigher_DiscountAmount;
							swTotal.OthersActualDiscount = Others_ActualDiscountAmount;
							swTotal.OthersDiscount = Others_DiscountAmount;

							swTotal.ServicesTotal = ServicesTotalAmount;
							swTotal.ServicesHigherDiscount = ServicesHigher_DiscountAmount;
							swTotal.ServicesActualDiscount = Services_ActualDiscountAmount;
							swTotal.ServicesDiscount = Services_DiscountAmount;

							TotalMap.put(pLineItem.Apttus_Proposal__Proposal__c, swTotal);
						}
						else {
							amountsWrapper swTotal = new amountsWrapper();
							swTotal.softwareTotal = SoftwareTotalAmount;
							swTotal.softwareHigherDiscount = SoftwareHigher_DiscountAmount;
							swTotal.softwareActualDiscount = Software_ActualDiscountAmount;
							swTotal.softwareDiscount = Software_DiscountAmount;

							swTotal.HardwareTotal = HardwareTotalAmount;
							swTotal.HardwareHigherDiscount = HardwareHigher_DiscountAmount;
							swTotal.HardwareActualDiscount = Hardware_ActualDiscountAmount;
							swTotal.HardwareDiscount = Hardware_DiscountAmount;

							swTotal.MaintenanceTotal = MaintenanceTotalAmount;
							swTotal.MaintenanceHigherDiscount = MaintenanceHigher_DiscountAmount;
							swTotal.MaintenanceActualDiscount = Maintenance_ActualDiscountAmount;
							swTotal.MaintenanceDiscount = Maintenance_DiscountAmount;

							swTotal.SpecialServicesTotal = SpecialServicesTotalAmount;
							swTotal.SpecialServicesHigherDiscount = SpecialServicesHigher_DiscountAmount;
							swTotal.SpecialServicesActualDiscount = SpecialServices_ActualDiscountAmount;
							swTotal.SpecialServicesDiscount = SpecialServices_DiscountAmount;

							swTotal.TrainingTotal = TrainingTotalAmount;
							swTotal.TrainingHigherDiscount = TrainingHigher_DiscountAmount;
							swTotal.TrainingActualDiscount = Training_ActualDiscountAmount;
							swTotal.TrainingDiscount = Training_DiscountAmount;

							swTotal.ThirdPartyTotal = ThirdPartyTotalAmount;
							swTotal.ThirdPartyHigherDiscount = ThirdPartyHigher_DiscountAmount;
							swTotal.ThirdPartyActualDiscount = ThirdParty_ActualDiscountAmount;
							swTotal.ThirdPartyDiscount = ThirdParty_DiscountAmount;

							swTotal.OthersTotal = OthersTotalAmount;
							swTotal.OthersHigherDiscount = OthersHigher_DiscountAmount;
							swTotal.OthersActualDiscount = Others_ActualDiscountAmount;
							swTotal.OthersDiscount = Others_DiscountAmount;

							swTotal.ServicesTotal = ServicesTotalAmount;
							swTotal.ServicesHigherDiscount = ServicesHigher_DiscountAmount;
							swTotal.ServicesActualDiscount = Services_ActualDiscountAmount;
							swTotal.ServicesDiscount = Services_DiscountAmount;

							TotalMap.put(pLineItem.Apttus_Proposal__Proposal__c, swTotal);
						}

					}
					system.debug('SoftwareTotalAmount ===>' + SoftwareTotalAmount);
					system.debug('SoftwareActualDiscountAmount ==>' + Software_ActualDiscountAmount);
					system.debug('SoftwareHigher_DiscountAmount ===>' + SoftwareHigher_DiscountAmount);
					system.debug('Software_DiscountAmount ===>' + Software_DiscountAmount);
					system.debug('HardwareTotal ===>' + HardwareTotalAmount);
					system.debug('HardwareDiscount ===>' + Hardware_DiscountAmount);
					system.debug('SpecialServicesTotal ===>' + SpecialServicesTotalAmount);
					system.debug('SpecialServicesDiscount ===>' + SpecialServices_DiscountAmount);
					system.debug('TrainingTotal ===>' + TrainingTotalAmount);
					system.debug('TrainingDiscount ===>' + Training_DiscountAmount);
					system.debug('ThirdPartyTotal ===>' + ThirdPartyTotalAmount);
					system.debug('ThirdPartyDiscount ===>' + ThirdParty_DiscountAmount);
					system.debug('MaintenanceTotal ===>' + MaintenanceTotalAmount);
					system.debug('MaintenanceHigher_DiscountAmount ===>' + MaintenanceHigher_DiscountAmount);
					system.debug('MaintenanceDiscount ===>' + Maintenance_DiscountAmount);
					system.debug('TotalMap ==>' + TotalMap);

					system.debug(' newProposalList size --->' + newProposalList.size());

					for (Apttus_Proposal__Proposal__c proposal : newProposalList) {
						system.debug('proposal ==>' + proposal.Id);
						system.debug('contains key ====>' + TotalMap.containsKey(proposal.Id));
						// Add Proposal Record Id, which are ONLY having Line Items.
						if (TotalMap.containsKey(proposal.Id)) {
							proposal.Software_Total_PriceOverride__c = TotalMap.get(proposal.Id).softwareTotal;
							proposal.Software_Discount_PriceOverride__c = TotalMap.get(proposal.Id).softwareDiscount;
							proposal.Software_Higher_Discount_PriceOverride__c = TotalMap.get(proposal.Id).softwareHigherDiscount;
							proposal.Software_Actual_Discount_PriceOverride__c = TotalMap.get(proposal.Id).softwareActualDiscount;

							proposal.Hardware_Total_PriceOverride__c = TotalMap.get(proposal.Id).HardwareTotal;
							proposal.Hardware_Discount_PriceOverride__c = TotalMap.get(proposal.Id).HardwareDiscount;
							proposal.Hardware_Higher_Discount_PriceOverride__c = TotalMap.get(proposal.Id).HardwareHigherDiscount;
							proposal.Hardware_Actual_Discount_PriceOverride__c = TotalMap.get(proposal.Id).HardwareActualDiscount;

							proposal.Special_Services_Total_PriceOverride__c = TotalMap.get(proposal.Id).SpecialServicesTotal;
							proposal.Special_Services_Discount_PriceOverride__c = TotalMap.get(proposal.Id).SpecialServicesDiscount;
							proposal.SpecialServices_Higher_DiscPriceOverride__c = TotalMap.get(proposal.Id).SpecialServicesHigherDiscount;
							proposal.SPService_Actual_Discount_PriceOverride__c = TotalMap.get(proposal.Id).SpecialServicesActualDiscount;

							proposal.Training_Total_PriceOverride__c = TotalMap.get(proposal.Id).TrainingTotal;
							proposal.Training_Discount_PriceOverride__c = TotalMap.get(proposal.Id).TrainingDiscount;
							proposal.Training_Higher_Discount_PriceOverride__c = TotalMap.get(proposal.Id).TrainingHigherDiscount;
							proposal.Training_Actual_Discount_PriceOverride__c = TotalMap.get(proposal.Id).TrainingActualDiscount;

							proposal.Third_Party_Total_PriceOverride__c = TotalMap.get(proposal.Id).ThirdPartyTotal;
							proposal.Third_Party_Discount_PriceOverride__c = TotalMap.get(proposal.Id).ThirdPartyDiscount;
							proposal.Third_Party_Higher_DiscountPriceOverride__c = TotalMap.get(proposal.Id).ThirdPartyHigherDiscount;
							proposal.ThirParty_Actual_Discount_PriceOverride__c = TotalMap.get(proposal.Id).ThirdPartyActualDiscount;

							proposal.Others_Total_PriceOverride__c = TotalMap.get(proposal.Id).OthersTotal;
							proposal.Others_Discount_PriceOverride__c = TotalMap.get(proposal.Id).OthersDiscount;
							proposal.Others_Higher_Discount_PriceOverride__c = TotalMap.get(proposal.Id).OthersHigherDiscount;
							proposal.Other_Actual_Discount_PriceOverride__c = TotalMap.get(proposal.Id).OthersActualDiscount;

							proposal.Services_Total_PriceOverride__c = TotalMap.get(proposal.Id).ServicesTotal;
							proposal.Services_Discount_PriceOverride__c = TotalMap.get(proposal.Id).ServicesDiscount;
							proposal.Services_Higher_Discount_PriceOverride__c = TotalMap.get(proposal.Id).ServicesHigherDiscount;
							proposal.Services_Actual_Discount_PriceOverride__c = TotalMap.get(proposal.Id).ServicesActualDiscount;

							proposal.Maintenance_Total_PriceOverride__c = TotalMap.get(proposal.Id).MaintenanceTotal;
							proposal.Maintenance_Discount_PriceOverride__c = TotalMap.get(proposal.Id).MaintenanceDiscount;
							proposal.Maintenance_Higher_DiscountPriceOverride__c = TotalMap.get(proposal.Id).MaintenanceHigherDiscount;
							proposal.Maint_Actual_Discount_PriceOverride__c = TotalMap.get(proposal.Id).MaintenanceActualDiscount;
						}
						system.debug('proposal ==>' + proposal);
					}
				}
			}
		}
	}

	public class amountsWrapper {
		public Decimal softwareTotal { get; set; }
		public Decimal softwareHigherDiscount { get; set; }
		public Decimal softwareActualDiscount { get; set; }
		public Decimal softwareDiscount { get; set; }
		public Decimal HardwareTotal { get; set; }
		public Decimal HardwareHigherDiscount { get; set; }
		public Decimal HardwareActualDiscount { get; set; }
		public Decimal HardwareDiscount { get; set; }
		public Decimal MaintenanceTotal { get; set; }
		public Decimal MaintenanceHigherDiscount { get; set; }
		public Decimal MaintenanceActualDiscount { get; set; }
		public Decimal MaintenanceDiscount { get; set; }
		public Decimal SpecialServicesTotal { get; set; }
		public Decimal SpecialServicesHigherDiscount { get; set; }
		public Decimal SpecialServicesActualDiscount { get; set; }
		public Decimal SpecialServicesDiscount { get; set; }
		public Decimal ThirdPartyTotal { get; set; }
		public Decimal ThirdPartyHigherDiscount { get; set; }
		public Decimal ThirdPartyActualDiscount { get; set; }
		public Decimal ThirdPartyDiscount { get; set; }
		public Decimal TrainingTotal { get; set; }
		public Decimal TrainingHigherDiscount { get; set; }
		public Decimal TrainingActualDiscount { get; set; }
		public Decimal TrainingDiscount { get; set; }
		public Decimal OthersTotal { get; set; }
		public Decimal OthersHigherDiscount { get; set; }
		public Decimal OthersActualDiscount { get; set; }
		public Decimal OthersDiscount { get; set; }
		public Decimal ServicesTotal { get; set; }
		public Decimal ServicesHigherDiscount { get; set; }
		public Decimal ServicesActualDiscount { get; set; }
		public Decimal ServicesDiscount { get; set; }

		public amountsWrapper() {
			softwareTotal = 0.0;
			softwareHigherDiscount = 0.0;
			softwareActualDiscount = 0.0;
			softwareDiscount = 0.0;
			HardwareTotal = 0.0;
			HardwareHigherDiscount = 0.0;
			HardwareActualDiscount = 0.0;
			HardwareDiscount = 0.0;
			MaintenanceTotal = 0.0;
			MaintenanceHigherDiscount = 0.0;
			MaintenanceActualDiscount = 0.0;
			MaintenanceDiscount = 0.0;
			SpecialServicesTotal = 0.0;
			SpecialServicesHigherDiscount = 0.0;
			SpecialServicesActualDiscount = 0.0;
			SpecialServicesDiscount = 0.0;
			ThirdPartyTotal = 0.0;
			ThirdPartyHigherDiscount = 0.0;
			ThirdPartyActualDiscount = 0.0;
			ThirdPartyDiscount = 0.0;
			TrainingTotal = 0.0;
			TrainingHigherDiscount = 0.0;
			TrainingActualDiscount = 0.0;
			TrainingDiscount = 0.0;
		}
	}

	/*
	 *   Author  :   SURESH BABU MURUGAN
	 *   Date    :   10-MAY-2018
	 *   Desc    :   As some cases ProposalLineItem's Category Hierarchy format differed, using this method to retrieve all CategoryHierarchy available for selected Quote's Pricelists
	 *   Param   :   Set<String> setQuotePriceLists : This set collection contains all pricelists which is used by selected Quotes
	 */
	private static Map<String, String> retrieveAllCatagoryHierarchies(Set<String> setQuotePriceLists) {
		List<Apttus_Config2__ClassificationHierarchy__c> lstCategoryHierarchies = [SELECT Name, Apttus_Config2__AncestorId__c, Apttus_Config2__AncestorId__r.Name, Apttus_Config2__HierarchyId__c, Apttus_Config2__HierarchyId__r.Name FROM Apttus_Config2__ClassificationHierarchy__c WHERE Apttus_Config2__PrimordialId__r.Name IN :setQuotePriceLists AND Apttus_Config2__Level__c = 2];
		// FORMAT-> key: TIBV CH Price List~CAD Software || value: Software
		// Key included with Priclist Name with Catagory
		Map<String, String> mapCatagoryHierarchy = new Map<String, String> ();
		for (Apttus_Config2__ClassificationHierarchy__c cHier : lstCategoryHierarchies) {
			mapCatagoryHierarchy.put(cHier.Apttus_Config2__HierarchyId__r.Name + '~' + cHier.Name, cHier.Apttus_Config2__AncestorId__r.Name);
			System.debug(LoggingLevel.DEBUG, 'KEY: ' + cHier.Apttus_Config2__HierarchyId__r.Name + '~' + cHier.Name + ' VAL: ' + cHier.Apttus_Config2__AncestorId__r.Name);
		}
		return mapCatagoryHierarchy;
	}
}