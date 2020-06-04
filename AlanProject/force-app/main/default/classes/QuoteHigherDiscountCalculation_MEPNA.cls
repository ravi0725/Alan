/**
 * Company     : Trimble Software Technology Pvt Ltd.,
 * Description : Quote - Higher Discount calculation class 
 * History     :  
 
 * [01.05.2019] Prince Leo  Created
 * [30.10.2019] Suresh Babu Murugan Big fix on Maintanance lines calculation issue
 * */
public class QuoteHigherDiscountCalculation_MEPNA {
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

			Boolean isMEPNAQuote = false;
			Set<Id> setProposalIDs = new Set<Id> ();
			Set<String> setQuotePriceListNames = new Set<String> ();
			for (Apttus_Proposal__Proposal__c proposal : newProposalList) {
				System.debug('Selected Quote Pricelist :::::: ' + proposal.Pricelist_Name__c);
				if (proposal.Pricelist_Name__c != Null && proposal.Pricelist_Name__c.startsWith('MEP NA')) {
					setProposalIDs.add(proposal.Id);
					setQuotePriceListNames.add(proposal.Pricelist_Name__c);
					isMEPNAQuote = true;
				}
			}

			if (isMEPNAQuote) { // These calculation only works for TIBV Quotes
				Map<String, String> mapCategories = new Map<String, String> ();
				//mapCategories = retrieveAllCatagoryHierarchies(setQuotePriceListNames);

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
				                                                                     Apttus_QPConfig__PriceListId__r.Name LIKE 'MEP NA%' AND
				                                                                     Apttus_QPConfig__ChargeType__c != null AND
				                                                                     Apttus_QPConfig__LineType__c != null AND
				((Apttus_QPConfig__ChargeType__c = 'Maintenance Fee' AND Apttus_QPConfig__IsPrimaryLine__c = true) OR
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
					Decimal MaintenanceTotal_MonthAmount = 0.0;
					Decimal MaintenanceActualDiscount_MonthAmount = 0.0;
					Decimal MaintenanceDiscount_MonthAmount = 0.0;

					Decimal SaaSTotalAmount = 0.0;
					Decimal SaaSHigher_DiscountAmount = 0.0;
					Decimal SaaS_ActualDiscountAmount = 0.0;
					Decimal SaaS_DiscountAmount = 0.0;
					Decimal SaaSTotal_MonthAmount = 0.0;
					Decimal SaaSActualDiscount_MonthAmount = 0.0;
					Decimal SaaSDiscount_MonthAmount = 0.0;

					Decimal RentalTotalAmount = 0.0;
					Decimal RentalHigher_DiscountAmount = 0.0;
					Decimal Rental_ActualDiscountAmount = 0.0;
					Decimal Rental_DiscountAmount = 0.0;

					Decimal SubscriptionTotalAmount = 0.0;
					Decimal SubscriptionHigher_DiscountAmount = 0.0;
					Decimal Subscription_ActualDiscountAmount = 0.0;
					Decimal Subscription_DiscountAmount = 0.0;
					Decimal SubscriptionTotal_MonthAmount = 0.0;
					Decimal SubscriptionActualDiscount_MonthAmount = 0.0;
					Decimal SubscriptionDiscount_MonthAmount = 0.0;

					Decimal OthersTotalAmount = 0.0;
					Decimal OthersHigher_DiscountAmount = 0.0;
					Decimal Others_ActualDiscountAmount = 0.0;
					Decimal Others_DiscountAmount = 0.0;

					Decimal ServicesTotalAmount = 0.0;
					Decimal ServicesHigher_DiscountAmount = 0.0;
					Decimal Services_ActualDiscountAmount = 0.0;
					Decimal Services_DiscountAmount = 0.0;

					Decimal TrainingTotalAmount = 0.0;
					Decimal TrainingHigher_DiscountAmount = 0.0;
					Decimal Training_ActualDiscountAmount = 0.0;
					Decimal Training_DiscountAmount = 0.0;


					for (Apttus_Proposal__Proposal_Line_Item__c pLineItem : lstProposalLineItems) {
						Decimal Discount_Amount = pLineItem.Apttus_QPConfig__ExtendedPrice__c - pLineItem.Apttus_QPConfig__NetPrice__c;
						Decimal Discount_MonthAmount = (pLineItem.Number_of_Months__c != null && pLineItem.Number_of_Months__c > 0 && Discount_Amount != null ? Discount_Amount / pLineItem.Number_of_Months__c : 0.0);

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
						String ancestorName = ''; //(minimizedCategoryHierarchy != null && mapCategories.containsKey(pLineItem.Apttus_QPConfig__PriceListId__r.Name+'~'+minimizedCategoryHierarchy) ? mapCategories.get(pLineItem.Apttus_QPConfig__PriceListId__r.Name+'~'+minimizedCategoryHierarchy) : null);
						System.debug(LoggingLevel.DEBUG, ' ancestorName : ' + ancestorName);
						String strProductCategoryType = (pLineItem.Apttus_Proposal__Product__r.Product_Category_Type__c != null ? pLineItem.Apttus_Proposal__Product__r.Product_Category_Type__c : (pLineItem.Apttus_QPConfig__OptionId__r.Product_Category_Type__c != null ? pLineItem.Apttus_QPConfig__OptionId__r.Product_Category_Type__c : null));

						Decimal multiYearProratedAmount = null;
						Boolean isOracleDiscountApplied = false;
						if (pLineItem.Service_Start_Date__c != null && pLineItem.Service_End_Date__c != null && pLineItem.Actual_List_Price__c != null) {
							multiYearProratedAmount = calculateMultiYearActualPrice(pLineItem.Service_Start_Date__c, pLineItem.Service_End_Date__c, pLineItem.EBS_Discount_Percentage__c, pLineItem.Apttus_QPConfig__PriceUom__c, pLineItem.Actual_List_Price__c);
						}
						if (multiYearProratedAmount != null && pLineItem.Actual_List_Price__c != pLineItem.Apttus_QPConfig__ListPrice__c && pLineItem.Apttus_QPConfig__ListPrice__c != multiYearProratedAmount) {
							isOracleDiscountApplied = true;
						}
						System.debug(' multiYearProratedAmount ::::::::::::::::::::::::::::::::::::: ' + multiYearProratedAmount);

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
							MaintenanceTotal_MonthAmount = 0.0;
							MaintenanceActualDiscount_MonthAmount = 0.0;
							MaintenanceDiscount_MonthAmount = 0.0;
							SaaSTotalAmount = 0.0;
							SaaSHigher_DiscountAmount = 0.0;
							SaaS_ActualDiscountAmount = 0.0;
							SaaS_DiscountAmount = 0.0;
							SaaSTotal_MonthAmount = 0.0;
							SaaSActualDiscount_MonthAmount = 0.0;
							SaaSDiscount_MonthAmount = 0.0;
							RentalTotalAmount = 0.0;
							RentalHigher_DiscountAmount = 0.0;
							Rental_ActualDiscountAmount = 0.0;
							Rental_DiscountAmount = 0.0;
							SubscriptionTotalAmount = 0.0;
							SubscriptionHigher_DiscountAmount = 0.0;
							Subscription_ActualDiscountAmount = 0.0;
							Subscription_DiscountAmount = 0.0;
							SubscriptionTotal_MonthAmount = 0.0;
							SubscriptionActualDiscount_MonthAmount = 0.0;
							SubscriptionDiscount_MonthAmount = 0.0;
							OthersTotalAmount = 0.0;
							OthersHigher_DiscountAmount = 0.0;
							Others_ActualDiscountAmount = 0.0;
							Others_DiscountAmount = 0.0;
							ServicesTotalAmount = 0.0;
							ServicesHigher_DiscountAmount = 0.0;
							Services_ActualDiscountAmount = 0.0;
							Services_DiscountAmount = 0.0;
							TrainingTotalAmount = 0.0;
							TrainingHigher_DiscountAmount = 0.0;
							Training_ActualDiscountAmount = 0.0;
							Training_DiscountAmount = 0.0;
						}

						// Software Product Total Calculation
						if (pLineItem.Actual_List_Price__c != null &&
						    pLineItem.Actual_List_Price__c == pLineItem.Apttus_QPConfig__ListPrice__c) { // Both SFDC and EBS List prices are same

							if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c > 0 &&
							    pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							    strProductCategoryType != null &&
							    strProductCategoryType.containsIgnoreCase('Software')) { // if this Percentage is Greater than 0, User giving Higher Discount

								SoftwareTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								SoftwareHigher_DiscountAmount += (Discount_Amount * - 1); // To get positive amount
							}
							else if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c <= 0 &&
							         pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							         strProductCategoryType != null &&
							         strProductCategoryType.containsIgnoreCase('Software')) {

								//SoftwareTotalAmount += pLineItem.Apttus_QPConfig__ExtendedPrice__c;
								//SoftwareTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								Software_DiscountAmount += Discount_Amount;
								SoftwareTotalAmount += pLineItem.Apttus_QPConfig__ExtendedPrice__c;
								/*
								  if(pLineItem.Apttus_QPConfig__AdjustmentType__c != 'Price Override' ){
								  Software_DiscountAmount += Discount_Amount;
								  SoftwareTotalAmount += pLineItem.Apttus_QPConfig__ExtendedPrice__c;
								  }
								  else{
								  SoftwareTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								  }
								 */
							}
						}
						else if (pLineItem.Actual_List_Price__c != null &&
						         pLineItem.Actual_List_Price__c != pLineItem.Apttus_QPConfig__ListPrice__c) {

							if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c > 0 &&
							    pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							    strProductCategoryType != null &&
							    strProductCategoryType.containsIgnoreCase('Software')) { // if this Percentage is Greater than 0, User giving Higher Discount

								SoftwareTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c + (isOracleDiscountApplied ? pLineItem.Actual_Discount_Amount__c : 0);
								Software_ActualDiscountAmount += (isOracleDiscountApplied ? pLineItem.Actual_Discount_Amount__c : 0);
								SoftwareHigher_DiscountAmount += (Discount_Amount * - 1); // To get positive amount
							}
							else if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c <= 0 &&
							         pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							         strProductCategoryType != null &&
							         strProductCategoryType.containsIgnoreCase('Software')) {

								Software_DiscountAmount += Discount_Amount;
								SoftwareTotalAmount += pLineItem.Actual_Extended_Price__c;
								Software_ActualDiscountAmount += (isOracleDiscountApplied ? pLineItem.Actual_Discount_Amount__c : 0);
								/*
								  if(pLineItem.Apttus_QPConfig__AdjustmentType__c != 'Price Override' ){
								  Software_DiscountAmount += Discount_Amount;
								  SoftwareTotalAmount += pLineItem.Actual_Extended_Price__c;
								  Software_ActualDiscountAmount += pLineItem.Actual_Discount_Amount__c;
								  }
								  else{
								  SoftwareTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								  }
								 */
							}
						}
						system.debug('SoftwareTotalAmount ::::::::::::::::::::::::::::::::::::>>' + SoftwareTotalAmount);

						// Rental total Calculation
						if (pLineItem.Actual_List_Price__c != null &&
						    pLineItem.Actual_List_Price__c == pLineItem.Apttus_QPConfig__ListPrice__c) { // Both SFDC and EBS List prices are same

							if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c > 0 &&
							    pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							    strProductCategoryType != null &&
							    strProductCategoryType == 'Rental') { // if this Percentage is Greater than 0, User giving Higher Discount
								RentalTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								RentalHigher_DiscountAmount += (Discount_Amount * - 1); // To get positive amount
							}
							else if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c <= 0 &&
							         pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							         strProductCategoryType != null &&
							         strProductCategoryType == 'Rental') {

								Rental_DiscountAmount += Discount_Amount;
								RentalTotalAmount += pLineItem.Apttus_QPConfig__ExtendedPrice__c;
								/*
								  if(pLineItem.Apttus_QPConfig__AdjustmentType__c != 'Price Override' ){
								  Rental_DiscountAmount += Discount_Amount;
								  RentalTotalAmount += pLineItem.Apttus_QPConfig__ExtendedPrice__c;
								  }
								  else{
								  RentalTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								  }
								 */
							}
						}
						else if (pLineItem.Actual_List_Price__c != null &&
						         pLineItem.Actual_List_Price__c != pLineItem.Apttus_QPConfig__ListPrice__c) {

							if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c > 0 &&
							    pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							    strProductCategoryType != null &&
							    strProductCategoryType == 'Rental') { // if this Percentage is Greater than 0, User giving Higher Discount

								RentalTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c + (isOracleDiscountApplied ? pLineItem.Actual_Discount_Amount__c : 0);
								Rental_ActualDiscountAmount += (isOracleDiscountApplied ? pLineItem.Actual_Discount_Amount__c : 0);
								Rental_DiscountAmount += (Discount_Amount * - 1); // To get positive amount
							}
							else if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c <= 0 &&
							         pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							         strProductCategoryType != null &&
							         strProductCategoryType == 'Rental') {

								Rental_DiscountAmount += Discount_Amount;
								RentalTotalAmount += pLineItem.Actual_Extended_Price__c;
								Rental_ActualDiscountAmount += (isOracleDiscountApplied ? pLineItem.Actual_Discount_Amount__c : 0);
								/*
								  if(pLineItem.Apttus_QPConfig__AdjustmentType__c != 'Price Override' ){
								  Rental_DiscountAmount += Discount_Amount;
								  RentalTotalAmount += pLineItem.Actual_Extended_Price__c;
								  Rental_ActualDiscountAmount += pLineItem.Actual_Discount_Amount__c;
								  }
								  else{
								  RentalTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								  }
								 */
							}
						}

						// Other Products total Calculation
						if (pLineItem.Actual_List_Price__c != null && pLineItem.Actual_List_Price__c == pLineItem.Apttus_QPConfig__ListPrice__c) {

							if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c > 0 &&
							    pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							    strProductCategoryType != null &&
							    strProductCategoryType.containsIgnoreCase('Others') && pLineItem.Product_ICC_Type__c != 'Training - Hardware' && pLineItem.Product_ICC_Type__c != 'Training - Software') { // if this Percentage is Greater than 0, User giving Higher Discount

								OthersTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								OthersHigher_DiscountAmount += (Discount_Amount * - 1); // To get positive amount
							}
							else if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c <= 0 &&
							         pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							         strProductCategoryType != null &&
							         strProductCategoryType.containsIgnoreCase('Others') && pLineItem.Product_ICC_Type__c != 'Training - Hardware' && pLineItem.Product_ICC_Type__c != 'Training - Software') {

								Others_DiscountAmount += Discount_Amount;
								OthersTotalAmount += pLineItem.Apttus_QPConfig__ExtendedPrice__c;
								/*
								  if(pLineItem.Apttus_QPConfig__AdjustmentType__c != 'Price Override' ){
								  Others_DiscountAmount += Discount_Amount;
								  OthersTotalAmount += pLineItem.Apttus_QPConfig__ExtendedPrice__c;
								  }
								  else{
								  OthersTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								  }
								 */
							}
						}
						else if (pLineItem.Actual_List_Price__c != null && pLineItem.Actual_List_Price__c != pLineItem.Apttus_QPConfig__ListPrice__c) {

							if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c > 0 &&
							    pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							    strProductCategoryType != null &&
							    strProductCategoryType.containsIgnoreCase('Others') && pLineItem.Product_ICC_Type__c != 'Training - Hardware' && pLineItem.Product_ICC_Type__c != 'Training - Software') { // if this Percentage is Greater than 0, User giving Higher Discount

								OthersTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c + (isOracleDiscountApplied ? pLineItem.Actual_Discount_Amount__c : 0);
								Others_ActualDiscountAmount += (isOracleDiscountApplied ? pLineItem.Actual_Discount_Amount__c : 0);
								OthersHigher_DiscountAmount += (Discount_Amount * - 1); // To get positive amount
							}
							else if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c <= 0 &&
							         pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							         strProductCategoryType != null &&
							         strProductCategoryType.containsIgnoreCase('Others') && pLineItem.Product_ICC_Type__c != 'Training - Hardware' && pLineItem.Product_ICC_Type__c == 'Training - Software') {

								Others_DiscountAmount += Discount_Amount;
								OthersTotalAmount += pLineItem.Actual_Extended_Price__c;
								Others_ActualDiscountAmount += (isOracleDiscountApplied ? pLineItem.Actual_Discount_Amount__c : 0);
								/*
								  if(pLineItem.Apttus_QPConfig__AdjustmentType__c != 'Price Override' ){
								  Others_DiscountAmount += Discount_Amount;
								  OthersTotalAmount += pLineItem.Actual_Extended_Price__c;
								  Others_ActualDiscountAmount += pLineItem.Actual_Discount_Amount__c;
								  }
								  else{
								  OthersTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								  }
								 */
							}
						}

						// Prof Service Products total Calculation
						if (pLineItem.Actual_List_Price__c != null && pLineItem.Actual_List_Price__c == pLineItem.Apttus_QPConfig__ListPrice__c) {
							if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c > 0 &&
							    pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							    strProductCategoryType != null &&
							    strProductCategoryType.containsIgnoreCase('Prof. Services')) { // if this Percentage is Greater than 0, User giving Higher Discount

								ServicesTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								ServicesHigher_DiscountAmount += (Discount_Amount * - 1); // To get positive amount
							}
							else if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c <= 0 &&
							         pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							         strProductCategoryType != null &&
							         strProductCategoryType.containsIgnoreCase('Prof. Services')) {

								Services_DiscountAmount += Discount_Amount;
								ServicesTotalAmount += pLineItem.Apttus_QPConfig__ExtendedPrice__c;
								/*
								  if(pLineItem.Apttus_QPConfig__AdjustmentType__c != 'Price Override' ){
								  Services_DiscountAmount += Discount_Amount;
								  ServicesTotalAmount += pLineItem.Apttus_QPConfig__ExtendedPrice__c;
								  }
								  else{
								  ServicesTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								  }
								 */
							}
						}
						else if (pLineItem.Actual_List_Price__c != null && pLineItem.Actual_List_Price__c != pLineItem.Apttus_QPConfig__ListPrice__c) {
							if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c > 0 &&
							    pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							    strProductCategoryType != null &&
							    strProductCategoryType.containsIgnoreCase('Prof. Services')) { // if this Percentage is Greater than 0, User giving Higher Discount

								ServicesTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c + (isOracleDiscountApplied ? pLineItem.Actual_Discount_Amount__c : 0);
								Services_ActualDiscountAmount += (isOracleDiscountApplied ? pLineItem.Actual_Discount_Amount__c : 0);
								ServicesHigher_DiscountAmount += (Discount_Amount * - 1); // To get positive amount
							}
							else if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c <= 0 &&
							         pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							         strProductCategoryType != null &&
							         strProductCategoryType.containsIgnoreCase('Prof. Services')) {

								Services_DiscountAmount += Discount_Amount;
								ServicesTotalAmount += pLineItem.Actual_Extended_Price__c;
								Services_ActualDiscountAmount += (isOracleDiscountApplied ? pLineItem.Actual_Discount_Amount__c : 0);
								/*
								  if(pLineItem.Apttus_QPConfig__AdjustmentType__c != 'Price Override' ){
								  Services_DiscountAmount += Discount_Amount;
								  ServicesTotalAmount += pLineItem.Actual_Extended_Price__c;
								  Services_ActualDiscountAmount += pLineItem.Actual_Discount_Amount__c;
								  }
								  else{
								  ServicesTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								  }
								 */
							}
						}

						// Subscription total Calculation
						if (pLineItem.Actual_List_Price__c != null && pLineItem.Actual_List_Price__c == pLineItem.Apttus_QPConfig__ListPrice__c) {
							if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c > 0 &&
							    pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							    strProductCategoryType != null &&
							    strProductCategoryType.containsIgnoreCase('Subscription')) { // if this Percentage is Greater than 0, User giving Higher Discount

								SubscriptionTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								SubscriptionHigher_DiscountAmount += (Discount_Amount * - 1); // To get positive amount

								SubscriptionTotal_MonthAmount += pLineItem.Net_Price_Month__c;
							}
							else if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c <= 0 &&
							         pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							         strProductCategoryType != null &&
							         strProductCategoryType.containsIgnoreCase('Subscription')) {

								Subscription_DiscountAmount += Discount_Amount;
								SubscriptionTotalAmount += pLineItem.Apttus_QPConfig__ExtendedPrice__c;
								
								SubscriptionDiscount_MonthAmount += Discount_MonthAmount;
								SubscriptionTotal_MonthAmount += (pLineItem.Number_of_Months__c != null  && pLineItem.Number_of_Months__c > 0 ? pLineItem.Apttus_QPConfig__ExtendedPrice__c / pLineItem.Number_of_Months__c : 0.0);
								/*
								  if(pLineItem.Apttus_QPConfig__AdjustmentType__c != 'Price Override' ){
								  Subscription_DiscountAmount += Discount_Amount;
								  SubscriptionTotalAmount += pLineItem.Apttus_QPConfig__ExtendedPrice__c;
								  }
								  else{
								  SubscriptionTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								  }
								 */
							}
						}
						else if (pLineItem.Actual_List_Price__c != null && pLineItem.Actual_List_Price__c != pLineItem.Apttus_QPConfig__ListPrice__c) {
							if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c > 0 &&
							    pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							    strProductCategoryType != null &&
							    strProductCategoryType.containsIgnoreCase('Subscription')) { // if this Percentage is Greater than 0, User giving Higher Discount

								SubscriptionTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c + (isOracleDiscountApplied ? pLineItem.Actual_Discount_Amount__c : 0);
								Subscription_ActualDiscountAmount += (isOracleDiscountApplied ? pLineItem.Actual_Discount_Amount__c : 0);
								SubscriptionHigher_DiscountAmount += (Discount_Amount * - 1); // To get positive amount

								SubscriptionTotal_MonthAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								SubscriptionActualDiscount_MonthAmount += (isOracleDiscountApplied && pLineItem.Number_of_Months__c != null && pLineItem.Number_of_Months__c > 0 ? pLineItem.Actual_Discount_Amount__c / pLineItem.Number_of_Months__c : 0);
							}
							else if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c <= 0 &&
							         pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							         strProductCategoryType != null &&
							         strProductCategoryType.containsIgnoreCase('Subscription')) {

								Subscription_DiscountAmount += Discount_Amount;
								SubscriptionTotalAmount += pLineItem.Actual_Extended_Price__c;
								Subscription_ActualDiscountAmount += (isOracleDiscountApplied ? pLineItem.Actual_Discount_Amount__c : 0);
								
								SubscriptionDiscount_MonthAmount += Discount_MonthAmount;
								SubscriptionTotal_MonthAmount += (pLineItem.Number_of_Months__c != null ? pLineItem.Apttus_QPConfig__ExtendedPrice__c / pLineItem.Number_of_Months__c : 0.0);
								SubscriptionActualDiscount_MonthAmount += (isOracleDiscountApplied && pLineItem.Number_of_Months__c != null && pLineItem.Number_of_Months__c > 0 ? pLineItem.Actual_Discount_Amount__c / pLineItem.Number_of_Months__c : 0);
								/*
								  if(pLineItem.Apttus_QPConfig__AdjustmentType__c != 'Price Override' ){
								 
								  Subscription_DiscountAmount += Discount_Amount;
								  SubscriptionTotalAmount += pLineItem.Actual_Extended_Price__c;
								  Subscription_ActualDiscountAmount += pLineItem.Actual_Discount_Amount__c;
								  }
								  else{
								  SubscriptionTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								  }
								 */
							}
						}

						// SaaS total Calculation
						if (pLineItem.Actual_List_Price__c != null && pLineItem.Actual_List_Price__c == pLineItem.Apttus_QPConfig__ListPrice__c) {
							if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c > 0 &&
							    pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							    strProductCategoryType != null &&
							    strProductCategoryType.containsIgnoreCase('SaaS')) { // if this Percentage is Greater than 0, User giving Higher Discount

								SaaSTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								SaaSHigher_DiscountAmount += (Discount_Amount * - 1); // To get positive amount

								SaaSTotal_MonthAmount += pLineItem.Net_Price_Month__c;
							}
							else if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c <= 0 &&
							         pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							         strProductCategoryType != null &&
							         strProductCategoryType.containsIgnoreCase('SaaS')) {
								SaaS_DiscountAmount += Discount_Amount;
								SaaSTotalAmount += pLineItem.Apttus_QPConfig__ExtendedPrice__c;

								SaaSDiscount_MonthAmount += Discount_MonthAmount;
								SaaSTotal_MonthAmount += (pLineItem.Number_of_Months__c != null && pLineItem.Number_of_Months__c > 0 ? pLineItem.Apttus_QPConfig__ExtendedPrice__c / pLineItem.Number_of_Months__c : 0.0);
								/*
								  if(pLineItem.Apttus_QPConfig__AdjustmentType__c != 'Price Override' ){
								  SaaS_DiscountAmount += Discount_Amount;
								  SaaSTotalAmount += pLineItem.Apttus_QPConfig__ExtendedPrice__c;
								  }
								  else{
								  SaaSTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								  }
								 */
							}
						}
						else if (pLineItem.Actual_List_Price__c != null && pLineItem.Actual_List_Price__c != pLineItem.Apttus_QPConfig__ListPrice__c) {
							if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c > 0 &&
							    pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							    strProductCategoryType != null &&
							    strProductCategoryType.containsIgnoreCase('SaaS')) { // if this Percentage is Greater than 0, User giving Higher Discount

								SaaSTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c + (isOracleDiscountApplied ? pLineItem.Actual_Discount_Amount__c : 0);
								SaaS_ActualDiscountAmount += (isOracleDiscountApplied ? pLineItem.Actual_Discount_Amount__c : 0);
								SaaSHigher_DiscountAmount += (Discount_Amount * - 1); // To get positive amount

								SaaSTotal_MonthAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								SaaSActualDiscount_MonthAmount += (isOracleDiscountApplied && pLineItem.Number_of_Months__c != null && pLineItem.Number_of_Months__c > 0 ? pLineItem.Actual_Discount_Amount__c / pLineItem.Number_of_Months__c : 0);
							}
							else if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c <= 0 &&
							         pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							         strProductCategoryType != null &&
							         strProductCategoryType.containsIgnoreCase('SaaS')) {

								SaaS_DiscountAmount += Discount_Amount;
								SaaSTotalAmount += pLineItem.Actual_Extended_Price__c;
								SaaS_ActualDiscountAmount += (isOracleDiscountApplied ? pLineItem.Actual_Discount_Amount__c : 0);

								SaaSDiscount_MonthAmount += Discount_MonthAmount;
								SaaSTotal_MonthAmount += (pLineItem.Number_of_Months__c != null && pLineItem.Number_of_Months__c > 0 ? pLineItem.Apttus_QPConfig__ExtendedPrice__c / pLineItem.Number_of_Months__c : 0.0);
								SaaSActualDiscount_MonthAmount += (isOracleDiscountApplied && pLineItem.Number_of_Months__c != null && pLineItem.Number_of_Months__c > 0 ? pLineItem.Actual_Discount_Amount__c / pLineItem.Number_of_Months__c : 0);
								/*
								  if(pLineItem.Apttus_QPConfig__AdjustmentType__c != 'Price Override' ){
								 
								  SaaS_DiscountAmount += Discount_Amount;
								  SaaSTotalAmount += pLineItem.Actual_Extended_Price__c;
								  SaaS_ActualDiscountAmount += pLineItem.Actual_Discount_Amount__c;
								  }
								  else{
								  SaaSTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								  }
								 */
							}
						}

						// Hardware total Calculation
						if (pLineItem.Actual_List_Price__c != null && pLineItem.Actual_List_Price__c == pLineItem.Apttus_QPConfig__ListPrice__c) {
							if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c > 0 &&
							    pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							    pLineItem.Apttus_QPConfig__LineType__c != 'Option' &&
							    strProductCategoryType != null &&
							    strProductCategoryType.containsIgnoreCase('Hardware')) { // if this Percentage is Greater than 0, User giving Higher Discount

								HardwareTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								HardwareHigher_DiscountAmount += (Discount_Amount * - 1); // To get positive amount
							}
							else if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c <= 0 &&
							         pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							         pLineItem.Apttus_QPConfig__LineType__c != 'Option' &&
							         strProductCategoryType != null &&
							         strProductCategoryType.containsIgnoreCase('Hardware')) {

								Hardware_DiscountAmount += Discount_Amount;
								HardwareTotalAmount += pLineItem.Apttus_QPConfig__ExtendedPrice__c;
								/*
								  if(pLineItem.Apttus_QPConfig__AdjustmentType__c != 'Price Override' ){
								  Hardware_DiscountAmount += Discount_Amount;
								  HardwareTotalAmount += pLineItem.Apttus_QPConfig__ExtendedPrice__c;
								  }
								  else{
								  HardwareTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								  }
								 */
							}
						}
						else if (pLineItem.Actual_List_Price__c != null && pLineItem.Actual_List_Price__c != pLineItem.Apttus_QPConfig__ListPrice__c) {
							if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c > 0 &&
							    pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							    pLineItem.Apttus_QPConfig__LineType__c != 'Option' &&
							    strProductCategoryType != null &&
							    strProductCategoryType.containsIgnoreCase('Hardware')) { // if this Percentage is Greater than 0, User giving Higher Discount

								HardwareTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c + (isOracleDiscountApplied ? pLineItem.Actual_Discount_Amount__c : 0);
								Hardware_ActualDiscountAmount += (isOracleDiscountApplied ? pLineItem.Actual_Discount_Amount__c : 0);
								HardwareHigher_DiscountAmount += (Discount_Amount * - 1); // To get positive amount
							}
							else if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c <= 0 &&
							         pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							         pLineItem.Apttus_QPConfig__LineType__c != 'Option' &&
							         strProductCategoryType != null &&
							         strProductCategoryType.containsIgnoreCase('Hardware')) {

								Hardware_DiscountAmount += Discount_Amount;
								HardwareTotalAmount += pLineItem.Actual_Extended_Price__c;
								Hardware_ActualDiscountAmount += (isOracleDiscountApplied ? pLineItem.Actual_Discount_Amount__c : 0);
								/*
								  if(pLineItem.Apttus_QPConfig__AdjustmentType__c != 'Price Override' ){
								  Hardware_DiscountAmount += Discount_Amount;
								  HardwareTotalAmount += pLineItem.Actual_Extended_Price__c;
								  Hardware_ActualDiscountAmount += pLineItem.Actual_Discount_Amount__c;
								  }
								  else{
								  HardwareTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								  }
								 */
							}
						}

						// Maintenance total Calculation
						if (pLineItem.Actual_List_Price__c != null && pLineItem.Actual_List_Price__c == pLineItem.Apttus_QPConfig__ListPrice__c) {
							if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c > 0 &&
							    pLineItem.Apttus_QPConfig__ChargeType__c == 'Maintenance Fee' &&
							    pLineItem.Apttus_QPConfig__IsPrimaryLine__c) { // if this Percentage is Greater than 0, User giving Higher Discount

								MaintenanceTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								MaintenanceHigher_DiscountAmount += (Discount_Amount * - 1); // To get positive amount

								MaintenanceTotal_MonthAmount += pLineItem.Net_Price_Month__c;
							}
							else if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c <= 0 &&
							         pLineItem.Apttus_QPConfig__ChargeType__c == 'Maintenance Fee' &&
							         pLineItem.Apttus_QPConfig__IsPrimaryLine__c) {

								Maintenance_DiscountAmount += Discount_Amount;
								MaintenanceTotalAmount += pLineItem.Apttus_QPConfig__ExtendedPrice__c;

								MaintenanceDiscount_MonthAmount += Discount_MonthAmount;
								MaintenanceTotal_MonthAmount += (pLineItem.Number_of_Months__c != null && pLineItem.Number_of_Months__c > 0 ? pLineItem.Apttus_QPConfig__ExtendedPrice__c / pLineItem.Number_of_Months__c : 0.0);
								/*
								  if(pLineItem.Apttus_QPConfig__AdjustmentType__c != 'Price Override' ){
								  Maintenance_DiscountAmount += Discount_Amount;
								  MaintenanceTotalAmount += pLineItem.Apttus_QPConfig__ExtendedPrice__c;
								  }
								  else{
								  MaintenanceTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								  }
								 */
							}
						}
						else if (pLineItem.Actual_List_Price__c != null && pLineItem.Actual_List_Price__c != pLineItem.Apttus_QPConfig__ListPrice__c) {
							if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c > 0 &&
							    pLineItem.Apttus_QPConfig__ChargeType__c == 'Maintenance Fee' &&
							    pLineItem.Apttus_QPConfig__IsPrimaryLine__c) { // if this Percentage is Greater than 0, User giving Higher Discount

								MaintenanceTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c + (isOracleDiscountApplied ? pLineItem.Actual_Discount_Amount__c : 0);
								Maintenance_ActualDiscountAmount += (isOracleDiscountApplied ? pLineItem.Actual_Discount_Amount__c : 0);
								MaintenanceHigher_DiscountAmount += (Discount_Amount * - 1); // To get positive amount

								MaintenanceTotal_MonthAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								MaintenanceActualDiscount_MonthAmount += (isOracleDiscountApplied && pLineItem.Number_of_Months__c != null && pLineItem.Number_of_Months__c > 0 ? pLineItem.Actual_Discount_Amount__c / pLineItem.Number_of_Months__c : 0);
							}
							else if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c <= 0 &&
							         pLineItem.Apttus_QPConfig__ChargeType__c == 'Maintenance Fee' &&
							         pLineItem.Apttus_QPConfig__IsPrimaryLine__c) {

								Maintenance_DiscountAmount += Discount_Amount;
								MaintenanceDiscount_MonthAmount += Discount_MonthAmount;

								if (pLineItem.Apttus_QPConfig__ListPrice__c != 0){
									MaintenanceTotalAmount += pLineItem.Actual_Extended_Price__c;
									Maintenance_ActualDiscountAmount += (isOracleDiscountApplied ? pLineItem.Actual_Discount_Amount__c : 0);

									MaintenanceTotal_MonthAmount += (pLineItem.Number_of_Months__c != null && pLineItem.Number_of_Months__c > 0 ? pLineItem.Apttus_QPConfig__ExtendedPrice__c / pLineItem.Number_of_Months__c : 0.0);
									MaintenanceActualDiscount_MonthAmount += Subscription_ActualDiscountAmount += (isOracleDiscountApplied && pLineItem.Number_of_Months__c != null && pLineItem.Number_of_Months__c > 0 ? pLineItem.Actual_Discount_Amount__c / pLineItem.Number_of_Months__c : 0);
								}
								/*
								  if(pLineItem.Apttus_QPConfig__AdjustmentType__c != 'Price Override' ){
								  Maintenance_DiscountAmount += Discount_Amount;
								  MaintenanceTotalAmount += pLineItem.Actual_Extended_Price__c;
								  Maintenance_ActualDiscountAmount += pLineItem.Actual_Discount_Amount__c;
								  }
								  else{
								  MaintenanceTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								  }
								 */
							}
						}

						// Training total Calculation
						if (pLineItem.Actual_List_Price__c != null && pLineItem.Actual_List_Price__c == pLineItem.Apttus_QPConfig__ListPrice__c) {
							if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c > 0 &&
							    pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							    strProductCategoryType != null &&
							    strProductCategoryType.containsIgnoreCase('Others') && (pLineItem.Product_ICC_Type__c == 'Training - Hardware' || pLineItem.Product_ICC_Type__c == 'Training - Software')) { // if this Percentage is Greater than 0, User giving Higher Discount


								TrainingTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								TrainingHigher_DiscountAmount += (Discount_Amount * - 1); // To get positive amount
							}
							else if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c <= 0 &&
							         pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							         strProductCategoryType != null &&
							         strProductCategoryType.containsIgnoreCase('Others') && (pLineItem.Product_ICC_Type__c == 'Training - Hardware' || pLineItem.Product_ICC_Type__c == 'Training - Software')) {
								Training_DiscountAmount += Discount_Amount;
								TrainingTotalAmount += pLineItem.Apttus_QPConfig__ExtendedPrice__c;
								/*
								  if(pLineItem.Apttus_QPConfig__AdjustmentType__c != 'Price Override' ){
								  Training_DiscountAmount += Discount_Amount;
								  TrainingTotalAmount += pLineItem.Apttus_QPConfig__ExtendedPrice__c;
								  }
								  else{
								  TrainingTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								  }
								 */
							}
						}
						else if (pLineItem.Actual_List_Price__c != null && pLineItem.Actual_List_Price__c != pLineItem.Apttus_QPConfig__ListPrice__c) {
							if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c > 0 &&
							    pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							    strProductCategoryType != null &&
							    strProductCategoryType.containsIgnoreCase('Others') && (pLineItem.Product_ICC_Type__c == 'Training - Hardware' || pLineItem.Product_ICC_Type__c == 'Training - Software')) { // if this Percentage is Greater than 0, User giving Higher Discount

								TrainingTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c + (isOracleDiscountApplied ? pLineItem.Actual_Discount_Amount__c : 0);
								Training_ActualDiscountAmount += (isOracleDiscountApplied ? pLineItem.Actual_Discount_Amount__c : 0);
								TrainingHigher_DiscountAmount += (Discount_Amount * - 1); // To get positive amount
							}
							else if (pLineItem.Apttus_QPConfig__NetAdjustmentPercent__c <= 0 &&
							         pLineItem.Apttus_QPConfig__ChargeType__c == 'Standard Price' &&
							         strProductCategoryType != null &&
							         strProductCategoryType.containsIgnoreCase('Others') && (pLineItem.Product_ICC_Type__c == 'Training - Hardware' || pLineItem.Product_ICC_Type__c == 'Training - Software')) {

								Training_DiscountAmount += Discount_Amount;
								TrainingTotalAmount += pLineItem.Actual_Extended_Price__c;
								Training_ActualDiscountAmount += (isOracleDiscountApplied ? pLineItem.Actual_Discount_Amount__c : 0);
								/*
								  if(pLineItem.Apttus_QPConfig__AdjustmentType__c != 'Price Override' ){
								 
								  Training_DiscountAmount += Discount_Amount;
								  TrainingTotalAmount += pLineItem.Actual_Extended_Price__c;
								  Training_ActualDiscountAmount += pLineItem.Actual_Discount_Amount__c;
								  }
								  else{
								  TrainingTotalAmount += pLineItem.Apttus_QPConfig__NetPrice__c;
								  }
								 */
							}
						}

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
							swTotal.MaintenanceTotal_Month = MaintenanceTotal_MonthAmount;
							swTotal.MaintenanceDiscount_Month = MaintenanceDiscount_MonthAmount;
							swTotal.MaintenanceActualDiscount_Month = Maintenance_ActualDiscountAmount;

							swTotal.SaaSTotal = SaaSTotalAmount;
							swTotal.SaaSHigherDiscount = SaaSHigher_DiscountAmount;
							swTotal.SaaSActualDiscount = SaaS_ActualDiscountAmount;
							swTotal.SaaSDiscount = SaaS_DiscountAmount;
							swTotal.SaaSTotal_Month = SaaSTotal_MonthAmount;
							swTotal.SaaSDiscount_Month = SaaSDiscount_MonthAmount;
							swTotal.SaaSActualDiscount_Month = SaaSActualDiscount_MonthAmount;

							swTotal.SubscriptionTotal = SubscriptionTotalAmount;
							swTotal.SubscriptionHigherDiscount = SubscriptionHigher_DiscountAmount;
							swTotal.SubscriptionActualDiscount = Subscription_ActualDiscountAmount;
							swTotal.SubscriptionDiscount = Subscription_DiscountAmount;
							swTotal.SubscriptionTotal_Month = SubscriptionTotal_MonthAmount;
							swTotal.SubscriptionActualDiscount_Month = SubscriptionActualDiscount_MonthAmount;
							swTotal.SubscriptionDiscount_Month = SubscriptionDiscount_MonthAmount;

							swTotal.RentalTotal = RentalTotalAmount;
							swTotal.RentalHigherDiscount = RentalHigher_DiscountAmount;
							swTotal.RentalActualDiscount = Rental_ActualDiscountAmount;
							swTotal.RentalDiscount = Rental_DiscountAmount;

							swTotal.OthersTotal = OthersTotalAmount;
							swTotal.OthersHigherDiscount = OthersHigher_DiscountAmount;
							swTotal.OthersActualDiscount = Others_ActualDiscountAmount;
							swTotal.OthersDiscount = Others_DiscountAmount;

							swTotal.ServicesTotal = ServicesTotalAmount;
							swTotal.ServicesHigherDiscount = ServicesHigher_DiscountAmount;
							swTotal.ServicesActualDiscount = Services_ActualDiscountAmount;
							swTotal.ServicesDiscount = Services_DiscountAmount;

							swTotal.TrainingTotal = TrainingTotalAmount;
							swTotal.TrainingHigherDiscount = TrainingHigher_DiscountAmount;
							swTotal.TrainingActualDiscount = Training_ActualDiscountAmount;
							swTotal.TrainingDiscount = Training_DiscountAmount;


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
							swTotal.MaintenanceTotal_Month = MaintenanceTotal_MonthAmount;
							swTotal.MaintenanceDiscount_Month = MaintenanceDiscount_MonthAmount;
							swTotal.MaintenanceActualDiscount_Month = Maintenance_ActualDiscountAmount;

							swTotal.SaaSTotal = SaaSTotalAmount;
							swTotal.SaaSHigherDiscount = SaaSHigher_DiscountAmount;
							swTotal.SaaSActualDiscount = SaaS_ActualDiscountAmount;
							swTotal.SaaSDiscount = SaaS_DiscountAmount;
							swTotal.SaaSTotal_Month = SaaSTotal_MonthAmount;
							swTotal.SaaSDiscount_Month = SaaSDiscount_MonthAmount;
							swTotal.SaaSActualDiscount_Month = SaaSActualDiscount_MonthAmount;

							swTotal.SubscriptionTotal = SubscriptionTotalAmount;
							swTotal.SubscriptionHigherDiscount = SubscriptionHigher_DiscountAmount;
							swTotal.SubscriptionActualDiscount = Subscription_ActualDiscountAmount;
							swTotal.SubscriptionDiscount = Subscription_DiscountAmount;
							swTotal.SubscriptionTotal_Month = SubscriptionTotal_MonthAmount;
							swTotal.SubscriptionActualDiscount_Month = SubscriptionActualDiscount_MonthAmount;
							swTotal.SubscriptionDiscount_Month = SubscriptionDiscount_MonthAmount;

							swTotal.RentalTotal = RentalTotalAmount;
							swTotal.RentalHigherDiscount = RentalHigher_DiscountAmount;
							swTotal.RentalActualDiscount = Rental_ActualDiscountAmount;
							swTotal.RentalDiscount = Rental_DiscountAmount;

							swTotal.OthersTotal = OthersTotalAmount;
							swTotal.OthersHigherDiscount = OthersHigher_DiscountAmount;
							swTotal.OthersActualDiscount = Others_ActualDiscountAmount;
							swTotal.OthersDiscount = Others_DiscountAmount;

							swTotal.ServicesTotal = ServicesTotalAmount;
							swTotal.ServicesHigherDiscount = ServicesHigher_DiscountAmount;
							swTotal.ServicesActualDiscount = Services_ActualDiscountAmount;
							swTotal.ServicesDiscount = Services_DiscountAmount;

							swTotal.TrainingTotal = TrainingTotalAmount;
							swTotal.TrainingHigherDiscount = TrainingHigher_DiscountAmount;
							swTotal.TrainingActualDiscount = Training_ActualDiscountAmount;
							swTotal.TrainingDiscount = Training_DiscountAmount;

							TotalMap.put(pLineItem.Apttus_Proposal__Proposal__c, swTotal);
						}

					}
					system.debug('SoftwareTotalAmount ===>' + SoftwareTotalAmount);
					system.debug('SoftwareActualDiscountAmount ==>' + Software_ActualDiscountAmount);
					system.debug('SoftwareHigher_DiscountAmount ===>' + SoftwareHigher_DiscountAmount);
					system.debug('Software_DiscountAmount ===>' + Software_DiscountAmount);
					system.debug('HardwareTotal ===>' + HardwareTotalAmount);
					system.debug('HardwareDiscount ===>' + Hardware_DiscountAmount);
					system.debug('SaaSTotal ===>' + SaaSTotalAmount);
					system.debug('SaaSDiscount ===>' + SaaS_DiscountAmount);
					system.debug('SubscriptionTotal ===>' + SubscriptionTotalAmount);
					system.debug('SubscriptionDiscount ===>' + Subscription_DiscountAmount);
					system.debug('RentalTotal ===>' + RentalTotalAmount);
					system.debug('RentalDiscount ===>' + Rental_DiscountAmount);
					system.debug('MaintenanceTotal ===>' + MaintenanceTotalAmount);
					system.debug('MaintenanceHigher_DiscountAmount ===>' + MaintenanceHigher_DiscountAmount);
					system.debug('MaintenanceDiscount ===>' + Maintenance_DiscountAmount);
					system.debug('TotalMap ==>' + TotalMap);

					for (Apttus_Proposal__Proposal__c proposal : newProposalList) {
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

							proposal.SaaS_Total_PriceOverride__c = TotalMap.get(proposal.Id).SaaSTotal;
							proposal.SaaS_Discount_PriceOverride__c = TotalMap.get(proposal.Id).SaaSDiscount;
							proposal.SaaS_Higher_DiscPriceOverride__c = TotalMap.get(proposal.Id).SaaSHigherDiscount;
							proposal.SaaS_Actual_Discount_PriceOverride__c = TotalMap.get(proposal.Id).SaaSActualDiscount;
							proposal.SaaS_Total_Month_CFD__c = TotalMap.get(proposal.Id).SaaSTotal_Month;
							proposal.SaaS_Discount_Month_CFD__c = TotalMap.get(proposal.Id).SaaSDiscount_Month;
							proposal.SaaS_Actual_Discount_Month_CFD__c = TotalMap.get(proposal.Id).SaaSActualDiscount_Month;

							proposal.Subscription_Total_PriceOverride__c = TotalMap.get(proposal.Id).SubscriptionTotal;
							proposal.Subscription_Discount_PriceOverride__c = TotalMap.get(proposal.Id).SubscriptionDiscount;
							proposal.Subscription_Higher_Discount_PO__c = TotalMap.get(proposal.Id).SubscriptionHigherDiscount;
							proposal.Subscription_Actual_Discount_PriceOverri__c = TotalMap.get(proposal.Id).SubscriptionActualDiscount;
							proposal.Subscription_Total_Month_CFD__c = TotalMap.get(proposal.Id).SubscriptionTotal_Month;
							proposal.Subscription_Discount_Month_CFD__c = TotalMap.get(proposal.Id).SubscriptionDiscount_Month;
							proposal.Subscription_Actual_Discount_Month_CFD__c = TotalMap.get(proposal.Id).SubscriptionActualDiscount_Month;

							proposal.Rental_Total_PriceOverride__c = TotalMap.get(proposal.Id).RentalTotal;
							proposal.Rental_Discount_PriceOverride__c = TotalMap.get(proposal.Id).RentalDiscount;
							proposal.Rental_Higher_DiscountPriceOverride__c = TotalMap.get(proposal.Id).RentalHigherDiscount;
							proposal.Rental_Actual_Discount_PriceOverride__c = TotalMap.get(proposal.Id).RentalActualDiscount;

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
							proposal.Maintenance_Total_Month_CFD__c = TotalMap.get(proposal.Id).MaintenanceTotal_Month;
							proposal.Maintenance_Discount_Month_CFD__c = TotalMap.get(proposal.Id).MaintenanceDiscount_Month;
							proposal.Maintenance_Actual_Discount_Month_CFD__c = TotalMap.get(proposal.Id).MaintenanceActualDiscount_Month;

							proposal.Training_Total_PriceOverride__c = TotalMap.get(proposal.Id).TrainingTotal;
							proposal.Training_Discount_PriceOverride__c = TotalMap.get(proposal.Id).TrainingDiscount;
							proposal.Training_Higher_Discount_PriceOverride__c = TotalMap.get(proposal.Id).TrainingHigherDiscount;
							proposal.Training_Actual_Discount_PriceOverride__c = TotalMap.get(proposal.Id).TrainingActualDiscount;
						}
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
		public Decimal SaaSTotal { get; set; }
		public Decimal SaaSHigherDiscount { get; set; }
		public Decimal SaaSActualDiscount { get; set; }
		public Decimal SaaSDiscount { get; set; }
		public Decimal RentalTotal { get; set; }
		public Decimal RentalHigherDiscount { get; set; }
		public Decimal RentalActualDiscount { get; set; }
		public Decimal RentalDiscount { get; set; }
		public Decimal SubscriptionTotal { get; set; }
		public Decimal SubscriptionHigherDiscount { get; set; }
		public Decimal SubscriptionActualDiscount { get; set; }
		public Decimal SubscriptionDiscount { get; set; }
		public Decimal OthersTotal { get; set; }
		public Decimal OthersHigherDiscount { get; set; }
		public Decimal OthersActualDiscount { get; set; }
		public Decimal OthersDiscount { get; set; }
		public Decimal ServicesTotal { get; set; }
		public Decimal ServicesHigherDiscount { get; set; }
		public Decimal ServicesActualDiscount { get; set; }
		public Decimal ServicesDiscount { get; set; }
		public Decimal TrainingTotal { get; set; }
		public Decimal TrainingHigherDiscount { get; set; }
		public Decimal TrainingActualDiscount { get; set; }
		public Decimal TrainingDiscount { get; set; }
		public Decimal MaintenanceTotal_Month { get; set; }
		public Decimal MaintenanceActualDiscount_Month { get; set; }
		public Decimal MaintenanceDiscount_Month { get; set; }
		public Decimal SaaSTotal_Month { get; set; }
		public Decimal SaaSActualDiscount_Month { get; set; }
		public Decimal SaaSDiscount_Month { get; set; }
		public Decimal SubscriptionTotal_Month { get; set; }
		public Decimal SubscriptionActualDiscount_Month { get; set; }
		public Decimal SubscriptionDiscount_Month { get; set; }

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
			MaintenanceTotal_Month = 0.0;
			MaintenanceActualDiscount_Month = 0.0;
			MaintenanceDiscount_Month = 0.0;
			SaaSTotal = 0.0;
			SaaSHigherDiscount = 0.0;
			SaaSActualDiscount = 0.0;
			SaaSDiscount = 0.0;
			SaaSTotal_Month = 0.0;
			SaaSActualDiscount_Month = 0.0;
			SaaSDiscount_Month = 0.0;
			RentalTotal = 0.0;
			RentalHigherDiscount = 0.0;
			RentalActualDiscount = 0.0;
			RentalDiscount = 0.0;
			SubscriptionTotal = 0.0;
			SubscriptionHigherDiscount = 0.0;
			SubscriptionActualDiscount = 0.0;
			SubscriptionDiscount = 0.0;
			SubscriptionTotal_Month = 0.0;
			SubscriptionActualDiscount_Month = 0.0;
			SubscriptionDiscount_Month = 0.0;
			TrainingTotal = 0.0;
			TrainingHigherDiscount = 0.0;
			TrainingActualDiscount = 0.0;
			TrainingDiscount = 0.0;
		}
	}

	public static Decimal calculateMultiYearActualPrice(Date dStartDate, Date dEndDate, Decimal ebsDiscountPercentage, String priceUOM, Decimal actualListPrice) {
		if (dStartDate != null && dEndDate != null) {
			Integer iMonths = 0;
			Integer iDays = 0;
			String sOutput = CalculateDuration.MonthsandDays(dStartDate, dEndDate);
			List<String> lstOutputs = sOutput.split(':');
			iMonths = Integer.valueof(lstOutputs.get(0));
			iDays = Integer.valueof(lstOutputs.get(1));

			Decimal dcMonthlyPrice = 0;
			if (ebsDiscountPercentage != Null && priceUOM == 'Year') {
				dcMonthlyPrice = actualListPrice + (actualListPrice * (ebsDiscountPercentage / 100));
				dcMonthlyPrice = dcMonthlyPrice / 12;
			}
			else if (priceUOM == 'Year')
			dcMonthlyPrice = actualListPrice / 12;
			else if (priceUOM == 'Month')
			dcMonthlyPrice = actualListPrice;
			else
			dcMonthlyPrice = actualListPrice / 12;
			Decimal dcDailyPrice = dcMonthlyPrice / 30;
			Decimal dcListPriceMonthly = iMonths * dcMonthlyPrice;
			Decimal dcListPriceDaily = iDays * dcDailyPrice;
			Decimal dcListPr = dcListPriceMonthly + dcListPriceDaily;
			return dcListPr;
		}
		else {
			return null;
		}
	}
}