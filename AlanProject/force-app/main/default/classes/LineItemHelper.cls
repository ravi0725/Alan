public class LineItemHelper {
	public static Map<String, Integer> launchControl;
	public static List<OpportunityLineItem> LineItemList;
	// Static initialize
	static {
		resetLaunchControl();
	}

	// Reset Trigger control (e.g. for testing)
	public static void resetLaunchControl() {
		launchControl = new Map<String, Integer> ();
		launchControl.put('validateAssetQuantity', 0);
		launchControl.put('configLineItem', 0);
	}

	// Reset Trigger control (e.g. for testing)
	public static void setLaunchControl() {
		launchControl = new Map<String, Integer> ();
		launchControl.put('validateAssetQuantity', 1);
		launchControl.put('configLineItem', 1);
	}



	public static void configLineItem(Map<Id, Apttus_Config2__LineItem__c> newLineItemMap, Map<Id, Apttus_Config2__LineItem__c> oldLineItemMap) {
		if (launchControl.get('configLineItem') < 1) {
			launchControl.put('configLineItem', launchControl.get('configLineItem') + 1);

			Map<String, ProjectSight_Discounting_Matrix__mdt> mapPSDiscMatrix = new Map<String, ProjectSight_Discounting_Matrix__mdt> ();
			List<ProjectSight_Discounting_Matrix__mdt> lstProjectSightDicMatrix = [SELECT MasterLabel, DeveloperName, Item_Code__c, Object_API_Name__c, Matrix_Based_on_Field_API__c FROM ProjectSight_Discounting_Matrix__mdt];
			for (ProjectSight_Discounting_Matrix__mdt pDM : lstProjectSightDicMatrix) {
				mapPSDiscMatrix.put(pDM.Item_Code__c, pDM);
			}

			for (Apttus_Config2__LineItem__c oLineItem : newLineItemMap.values()) {
				system.debug('----------------------' + oLineItem.Name);
				system.debug('----------------------' + oLineItem.Apttus_Config2__Quantity__c);
				system.debug('-----------Apttus_Config2__ListPrice__c-----------' + oLineItem.Apttus_Config2__ListPrice__c);
				system.debug('-----------Actual_List_Price__c-----------' + oLineItem.Actual_List_Price__c);
				system.debug(oldLineItemMap.get(oLineItem.id).Service_Start_date__c + '----------------------' + oLineItem.Service_Start_date__c);
				system.debug(oldLineItemMap.get(oLineItem.id).Service_End_date__c + '----------------------' + oLineItem.Service_End_date__c);
				system.debug('----------------------' + oldLineItemMap.get(oLineItem.id).Service_Start_date__c);
				system.debug('----------------------' + oldLineItemMap.get(oLineItem.id).Service_End_date__c);

				if ((Trigger.Isupdate && oLineItem.Service_Start_date__c != null && oLineItem.Service_End_date__c != null && oLineItem.Price_List_Division__c != 'Plancal' && /*oLineItem.Must_Prorate__c == True && */
				(oldLineItemMap.get(oLineItem.id).Service_Start_date__c != newLineItemMap.get(oLineItem.id).Service_Start_date__c ||
				 oldLineItemMap.get(oLineItem.id).Service_End_date__c != newLineItemMap.get(oLineItem.id).Service_End_date__c)) || (Trigger.Isinsert && oLineItem.Service_Start_date__c != null && oLineItem.Service_End_date__c != null)) {

					Boolean skipPricingConfig = false;
					if (mapPSDiscMatrix.containsKey(oLineItem.Product_Code__c) && mapPSDiscMatrix.get(oLineItem.Product_Code__c) != null && oLineItem.Apttus_Config2__IsCustomPricing__c) {
						skipPricingConfig = true;
					}

					if (!skipPricingConfig) {
						Integer NoMonths = 0;
						Integer NoDays = 0;
						Date startDate = oLineItem.service_Start_date__c;
						Date endDate = oLineItem.Service_End_date__c;
						String Output = CalculateDuration.MonthsandDays(startDate, endDate);
						List<String> OutputList = Output.split(':');
						NoMonths = Integer.valueof(OutputList.get(0));
						NoDays = Integer.valueof(OutputList.get(1));

						/*
						  oLineItem.Apttus_Config2__ListPrice__c = (((lp/12) * NoMonths) + (((lp / 12) / 30) * NoDays));
						  oLineItem.Apttus_Config2__NetPrice__c = oLineItem.Apttus_Config2__ListPrice__c * oLineItem.Apttus_Config2__Quantity__c;
						  oLineItem.Apttus_Config2__BaseExtendedPrice__c = (((lp/12) * NoMonths) + (((lp / 12) / 30) * NoDays)) * oLineItem.Apttus_Config2__Quantity__c;
						  oLineItem.Apttus_Config2__BasePrice__c = (((lp/12) * NoMonths) + (((lp / 12) / 30) * NoDays));
						  oLineItem.Apttus_Config2__BasePriceOverride__c =(((lp/12) * NoMonths) + (((lp / 12) / 30) * NoDays));
						  oLineItem.Apttus_Config2__ExtendedPrice__c = (((lp/12) * NoMonths) + (((lp / 12) / 30) * NoDays))* oLineItem.Apttus_Config2__Quantity__c;*/

						Decimal Monthlyprice = 0;
						if (oLineItem.EBS_Discount_Percentage__c != Null && oLineItem.Apttus_Config2__PriceUom__c == 'Year') {
							Monthlyprice = oLineItem.Actual_List_Price__c + (oLineItem.Actual_List_Price__c * (oLineItem.EBS_Discount_Percentage__c / 100));
							Monthlyprice = Monthlyprice / 12;
						}
						else if (oLineItem.Apttus_Config2__PriceUom__c == 'Year')
						MonthlyPrice = oLineItem.Actual_List_Price__c / 12;
						else if (oLineItem.Apttus_Config2__PriceUom__c == 'Month')
						MonthlyPrice = oLineItem.Actual_List_Price__c;
						// TT-124690 : SaaS item List price was overriden with "0"
						else
						MonthlyPrice = oLineItem.Actual_List_Price__c / 12;
						/////
						Decimal DailyPrice = Monthlyprice / 30;
						Decimal ListPriceMonthly = NoMonths * Monthlyprice;
						Decimal ListPriceDaily = NoDays * DailyPrice;
						Decimal ListPr = ListPriceMonthly + ListPriceDaily;


						system.debug('--------NoMonths -------' + NoMonths);
						system.debug('--------NoDays -------' + NoDays);
						system.debug('--------Monthlyprice -------' + Monthlyprice);
						system.debug('--------DailyPrice -------' + DailyPrice);
						system.debug('--------ListPriceMonthly -------' + ListPriceMonthly);
						system.debug('--------ListPriceDaily -------' + ListPriceDaily);
						system.debug('--------ListPr -------' + ListPr);

						oLineItem.Apttus_Config2__ListPrice__c = ListPr;
						oLineItem.Apttus_Config2__NetPrice__c = ListPr * oLineItem.Apttus_Config2__Quantity__c;
						oLineItem.Apttus_Config2__BaseExtendedPrice__c = ListPr * oLineItem.Apttus_Config2__Quantity__c;
						oLineItem.Apttus_Config2__BasePrice__c = ListPr;
						oLineItem.Apttus_Config2__BasePriceOverride__c = ListPr;
						oLineItem.Apttus_Config2__ExtendedPrice__c = ListPr * oLineItem.Apttus_Config2__Quantity__c;
					}
				}
			}
		}
	}

	public static void validateAssetQuantity(Map<Id, Apttus_Config2__LineItem__c> newLineItemMap, Map<Id, Apttus_Config2__LineItem__c> oldLineItem) {
		if (launchControl.get('validateAssetQuantity') < 1) {
			launchControl.put('validateAssetQuantity', launchControl.get('validateAssetQuantity') + 1);
			Map<Id, Map<String, decimal>> lineItemQtyMap = new Map<Id, Map<String, decimal>> ();
			Map<String, decimal> assetOracleIdQtyMap = new Map<String, decimal> ();
			set<Id> cartIds = new set<Id> ();
			set<Id> accIds = new set<Id> ();
			for (Apttus_Config2__LineItem__c oLineItem : newLineItemMap.values()) {
				if (oLineItem.Asset_Oracle_ID__c != null && (oLineItem.Apttus_Config2__Quantity__c > oldLineItem.get(oLineItem.id).Apttus_Config2__Quantity__c ||
				                                            oLineItem.Asset_Oracle_ID__c != oldLineItem.get(oLineItem.id).Asset_Oracle_ID__c) && !oLineItem.Price_List_Name__c.contains('TIBV')) {
					cartIds.add(oLineItem.Apttus_Config2__ConfigurationId__c);
					assetOracleIdQtyMap.put(oLineItem.Asset_Oracle_ID__c.split(':').get(0), 0);
					accIds.add(oLineItem.Account_Id__c);
					String assetOracleId = oLineItem.Asset_Oracle_ID__c.split(':').get(0);

					if (!lineItemQtyMap.containsKey(oLineItem.Apttus_Config2__ConfigurationId__c)) lineItemQtyMap.put(oLineItem.Apttus_Config2__ConfigurationId__c, new Map<String, decimal> ());
					if (!lineItemQtyMap.get(oLineItem.Apttus_Config2__ConfigurationId__c).containsKey(assetOracleId)) {
						lineItemQtyMap.get(oLineItem.Apttus_Config2__ConfigurationId__c).put(assetOracleId, 0);
					}

					decimal qty = lineItemQtyMap.get(oLineItem.Apttus_Config2__ConfigurationId__c).get(assetOracleId) + oLineItem.Apttus_Config2__Quantity__c;
					lineItemQtyMap.get(oLineItem.Apttus_Config2__ConfigurationId__c).put(assetOracleId, qty);
				}
			}
			system.debug(cartIds + '--------assetOracleIdQtyMap-------' + assetOracleIdQtyMap);
			for (Apttus_Config2__LineItem__c oLineItem :[select ID, Account_Id__c, Apttus_Config2__Quantity__c, Asset_Oracle_ID__c, Apttus_Config2__ConfigurationId__c from Apttus_Config2__LineItem__c where
			     Apttus_Config2__ConfigurationId__c in :cartIds and Asset_Oracle_ID__c in :assetOracleIdQtyMap.keySet() and
			     Id not in :newLineItemMap.keySet()]) {
				if (!lineItemQtyMap.containsKey(oLineItem.Apttus_Config2__ConfigurationId__c)) lineItemQtyMap.put(oLineItem.Apttus_Config2__ConfigurationId__c, new Map<String, decimal> ());
				String assetOracleId = (newLineItemMap.containsKey(oLineItem.Id) ? newLineItemMap.get(oLineItem.Id).Asset_Oracle_ID__c.split(':').get(0) :
				                        oLineItem.Asset_Oracle_ID__c.split(':').get(0));
				if (assetOracleId != null && assetOracleId != '') {
					if (!lineItemQtyMap.get(oLineItem.Apttus_Config2__ConfigurationId__c).containsKey(assetOracleId)) {
						lineItemQtyMap.get(oLineItem.Apttus_Config2__ConfigurationId__c).put(assetOracleId, 0);
					}

					decimal qty = lineItemQtyMap.get(oLineItem.Apttus_Config2__ConfigurationId__c).get(assetOracleId) + oLineItem.Apttus_Config2__Quantity__c;
					lineItemQtyMap.get(oLineItem.Apttus_Config2__ConfigurationId__c).put(assetOracleId, qty);
				}
			}

			for (Asset ass :[select Id, Asset_Oracle_ID__c, Quantity from Asset where Asset_Oracle_ID__c in :assetOracleIdQtyMap.keySet() and AccountId in :accIds]) {
				assetOracleIdQtyMap.put(ass.Asset_Oracle_ID__c, ass.Quantity);
			}

			for (Apttus_Config2__LineItem__c oLineItem : newLineItemMap.values()) {
				if (oLineItem.Asset_Oracle_ID__c != null && oLineItem.Asset_Oracle_ID__c != '' && oLineItem.Apttus_Config2__Quantity__c > oldLineItem.get(oLineItem.id).Apttus_Config2__Quantity__c && !oLineItem.Price_List_Name__c.contains('TIBV')) {
					if (assetOracleIdQtyMap.containsKey(oLineItem.Asset_Oracle_ID__c.split(':').get(0)) && lineItemQtyMap.get(oLineItem.Apttus_Config2__ConfigurationId__c).containsKey(oLineItem.Asset_Oracle_ID__c.split(':').get(0))) {
						if (lineItemQtyMap.get(oLineItem.Apttus_Config2__ConfigurationId__c).get(oLineItem.Asset_Oracle_ID__c.split(':').get(0)) > assetOracleIdQtyMap.get(oLineItem.Asset_Oracle_ID__c.split(':').get(0))) {
							oLineItem.Apttus_Config2__Quantity__c.addError('Line Item Quantity is more than Asset Quantity.');
						}
					}
				}
			}
		}
	}

	public static void RenewalValidation(List<Apttus_Config2__LineItem__c> newLiTmList, Map<Id, Apttus_Config2__LineItem__c> oldLiTmMap) {
		for (Apttus_Config2__LineItem__c LiTm : newLiTmList) {
			if (LiTm.Type__c == 'Renewal') {
				if (LiTm.Service_Start_Date__c != null && oldLiTmMap.get(LiTm.Id).Service_Start_Date__c != null) {
					if (LiTm.Service_Start_Date__c != oldLiTmMap.get(LiTm.Id).Service_Start_Date__c) {
						LiTm.Service_Start_Date__c.addError('You cannot modify Service Start Date for Renewal Item.(Initial Value : ' + oldLiTmMap.get(LiTm.Id).Service_Start_Date__c.month() + '/' + oldLiTmMap.get(LiTm.Id).Service_Start_Date__c.day() + '/' + oldLiTmMap.get(LiTm.Id).Service_Start_Date__c.year() + ' )');
					}
				}
				if (LiTm.Service_Start_Date__c != null && LiTm.Service_End_Date__c != null) {
					if (LiTm.Service_Start_Date__c >= LiTm.Service_End_Date__c) {
						LiTm.Service_End_Date__c.addError('Service End Date should be greater than Service Start Date.(Previous Value : ' + oldLiTmMap.get(LiTm.Id).Service_End_Date__c.month() + '/' + oldLiTmMap.get(LiTm.Id).Service_End_Date__c.day() + '/' + oldLiTmMap.get(LiTm.Id).Service_End_Date__c.year() + ' )');
					}
				}
				if (LiTm.Apttus_Config2__Quantity__c != null && LiTm.Initial_Renewal_Quantity__c != null) {
					if (LiTm.Apttus_Config2__Quantity__c > LiTm.Initial_Renewal_Quantity__c) {
						LiTm.Apttus_Config2__Quantity__c.addError('You cannot assign Quantity beyond Initial Quantity of Renewal Item.(Initial Value : ' + oldLiTmMap.get(LiTm.Id).Initial_Renewal_Quantity__c.intValue() + ' )');
					}
				}
			}
		}
	}

	public static void processRenewalLineItem(List<Apttus_Config2__LineItem__c> newLiTmList) {
		List<WS_Interface_Log__c> logList = new List<WS_Interface_Log__c> ();
		Map<String, String> targetSouurcFieldMap = new Map<String, String> ();
		Map<String, String> defaultValueMap = new Map<String, String> ();
		for (Field_Map__c fieldMap :[select Id, Default_Value__c, Reference_Query__c, Object_Map__r.Source_Object__c,
		     Object_Map__r.Target_Object__c, Target_Field__c, Source_Field__c from Field_Map__c
		     where Object_Map__r.Name = :'TNV_SFDC_OPPORTUNITY_EXT_PKG Line Item']) {
			if (fieldMap.Default_Value__c != null)
			defaultValueMap.put(fieldMap.Target_Field__c, fieldMap.Default_Value__c);
			else if (fieldMap.Source_Field__c != null && fieldMap.Source_Field__c != '')
			targetSouurcFieldMap.put(fieldMap.Target_Field__c, fieldMap.Source_Field__c);
		}


		for (String targetField : targetSouurcFieldMap.keySet()) {
			for (Apttus_Config2__LineItem__c Li : newLiTmList) {
				for (Integer i = 0; i<LineItemHelper.LineItemList.size(); i++) {
					if (LineItemHelper.LineItemList.get(i).PriceBookEntry.Product2Id == Li.Apttus_Config2__ProductId__c &&
					    LineItemHelper.LineItemList.get(i).Quantity == Li.Apttus_Config2__Quantity__c) {
						String sourceField = targetSouurcFieldMap.get(targetField);
						system.debug('------sourceField-----' + LineItemHelper.LineItemList.get(i).get(sourceField));
						Object SourceFieldValue = LineItemHelper.LineItemList.get(i).get(sourceField);
						if (SourceFieldValue != null) {
							try {
								String dataType = XMLUtility.getDataType('Apttus_Config2__LineItem__c', targetField);
								setFieldValue(dataType, SourceFieldValue, targetField, Li);
							} catch(exception ex) {
								if (ex.getMessage() != '') {
									WS_Interface_Log__c log = WS_Interface_Log.createLog('LineItemHelper', 'processRenewalLineItem', ex.getMessage(),
									                                                     ex.getTypeName() + '\n' + ex.getCause() + '\n' + ex.getStackTraceString(), '');
									logList.add(log);
								}
							}
						}
						/*Li.Apttus_Config2__ListPrice__c = LineItemHelper.LineItemList.get(i).UnitPrice;
						  Li.Apttus_Config2__BasePrice__c = LineItemHelper.LineItemList.get(i).UnitPrice;
						  system.debug('-----quantity----------'+LineItemHelper.LineItemList.get(i).Quantity+'\n------------unitPrice-------'+LineItemHelper.LineItemList.get(i).UnitPrice);
						  Li.Apttus_Config2__BaseExtendedPrice__c = LineItemHelper.LineItemList.get(i).UnitPrice * LineItemHelper.LineItemList.get(i).Quantity;
						  system.debug('---baseExprice---'+Li.Apttus_Config2__BaseExtendedPrice__c);
						  Li.Apttus_Config2__ExtendedPrice__c = LineItemHelper.LineItemList.get(i).UnitPrice * LineItemHelper.LineItemList.get(i).Quantity;       
						  Li.Apttus_Config2__AdjustmentAmount__c = LineItemHelper.LineItemList.get(i).Discount;
						  Li.Apttus_Config2__NetAdjustmentPercent__c = -LineItemHelper.LineItemList.get(i).Discount;
						  Li.Apttus_Config2__AdjustmentType__c = '% Discount';
						  Li.Service_Line__c = LineItemHelper.LineItemList.get(i).Service_Line__c;
						  Li.Staging__c = LineItemHelper.LineItemList.get(i).Staging__c;
						  Li.Asset_Oracle_ID__c = LineItemHelper.LineItemList.get(i).Asset_Oracle_Id__c;
						  Li.Apttus_Config2__AssetId__c = LineItemHelper.LineItemList.get(i).Asset__c;
						  Li.Contract__c = LineItemHelper.LineItemList.get(i).Contract__c;
						  Li.Service_Start_Date__c = LineItemHelper.LineItemList.get(i).Service_Start_Date__c;
						  Li.Service_End_Date__c = LineItemHelper.LineItemList.get(i).Service_End_Date__c;
						  Li.Initial_Renewal_Quantity__c = LineItemHelper.LineItemList.get(i).Quantity;
						  Li.Type__c = LineItemHelper.LineItemList.get(i).Type__c;
						  Li.Apttus_Config2__ConfigStatus__c = 'Complete';
						  LineItemHelper.LineItemList.remove(i);*/
					}
				}
			}
		}

		for (String targetField : defaultValueMap.keySet()) {
			for (Apttus_Config2__LineItem__c Li : newLiTmList) {
				String fieldValue = defaultValueMap.get(targetField);
				if (fieldValue != null) {
					try {
						String dataType = XMLUtility.getDataType('Apttus_Config2__LineItem__c', targetField);
						setFieldValue(dataType, fieldValue, targetField, Li);
					} catch(exception ex) {
						if (ex.getMessage() != '') {
							WS_Interface_Log__c log = WS_Interface_Log.createLog('LineItemHelper', 'processRenewalLineItem', ex.getMessage(),
							                                                     ex.getTypeName() + '\n' + ex.getCause() + '\n' + ex.getStackTraceString(), '');
							logList.add(log);
						}
					}
				}
			}
			if (logList.size()> 0) {
				insert logList;
			}
		}
	}

	public static void setFieldValue(String dataType, Object SourceFieldValue, String targetField, Apttus_Config2__LineItem__c Li) {
		if (dataType == 'TEXT') {
			String fieldValue = (String) SourceFieldValue;
			Li.put(targetField, fieldValue);
		} else if (dataType == 'DATETIME') {
			Li.put(targetField, (DateTime) SourceFieldValue);
		} else if (dataType == 'DATE') {
			Li.put(targetField, (Date) SourceFieldValue);
		} else if (dataType == 'DECIMAL') {
			Li.put(targetField, (targetField == 'Apttus_Config2__NetAdjustmentPercent__c' ? - 1 * (Decimal) SourceFieldValue : (Decimal) SourceFieldValue));
		} else if (dataType == 'BOOLEAN') {
			String fieldValue = (String) SourceFieldValue;
			if (fieldValue.equals('Yes') || fieldValue.equals('YES') ||
			    fieldValue.equals('1') || fieldValue.equals('true') ||
			    fieldValue.equals('True') || fieldValue.equals('TRUE'))
			Li.put(targetField, true);
			else
			Li.put(targetField, false);
		} else if (dataType == 'REFERENCE') {
			String fieldValue = (String) SourceFieldValue;
			Li.put(targetField, (Id) fieldValue);
		}
	}

	/* Added for TT# 101380
	  Summary : to vlaidate the Qty data is non-integer for Product Category Type = Sofwtare/ Hardware
	  Added by : Srini Babu 
	  Dated on : 03/29/2016 */

	public static void validateQtydata(List<Apttus_Config2__LineItem__c> newLiTmList, Map<Id, Apttus_Config2__LineItem__c> oldLiTmMap) {
		Decimal decQty;
		for (Apttus_Config2__LineItem__c objLineItem : newLiTmList) {
			if (objLineItem.Apttus_Config2__Quantity__c != 0 && (oldLiTmMap.get(objLineItem.Id).PPM_Item__c == '' || (oldLiTmMap.get(objLineItem.Id).PPM_Item__c != Null && oldLiTmMap.get(objLineItem.Id).PPM_Item__c == 'N'))) {
				decQty = objLineItem.Apttus_Config2__Quantity__c.Divide(objLineItem.Apttus_Config2__Quantity__c.intValue(), 5);
				system.debug('decQty>>>' + decQty);
				if (decQty > 1) {
					objLineItem.Apttus_Config2__Quantity__c.addError('Non-integer value is not allowed for this item');
				}
			}
		}
	}
}