/*****************************************************************************************
  Name    : LineItemHelper_v1 
  Desc    : LineItem helper class
  Modification Log : 
  ---------------------------------------------------------------------------
  Developer                 Date            Description
  ---------------------------------------------------------------------------
  Prince Leo                13/FEB/2016     Created
 ******************************************************************************************/
public class LineItemHelper_v1 {
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
        launchControl.put('RestrictDiscounts_PriceOverride', 0);
    }

    // Reset Trigger control (e.g. for testing)
    public static void setLaunchControl() {
        launchControl = new Map<String, Integer> ();
        launchControl.put('validateAssetQuantity', 1);
        launchControl.put('configLineItem', 1);
        launchControl.put('RestrictDiscounts_PriceOverride', 1);
    }

    public static void configLineItem(Map<Id, Apttus_Config2__LineItem__c> newMapLineItems, Map<Id, Apttus_Config2__LineItem__c> oldMapLineItems) {
        if (launchControl.get('configLineItem') < 1) {
            launchControl.put('configLineItem', launchControl.get('configLineItem') + 1);

            Map<String, ProjectSight_Discounting_Matrix__mdt> mapPSDiscMatrix = new Map<String, ProjectSight_Discounting_Matrix__mdt> ();
            List<ProjectSight_Discounting_Matrix__mdt> lstProjectSightDicMatrix = [SELECT MasterLabel, DeveloperName, Item_Code__c, Object_API_Name__c, Matrix_Based_on_Field_API__c FROM ProjectSight_Discounting_Matrix__mdt];
            for (ProjectSight_Discounting_Matrix__mdt pDM : lstProjectSightDicMatrix) {
                mapPSDiscMatrix.put(pDM.Item_Code__c, pDM);
            }

            for (Apttus_Config2__LineItem__c oLineItem : newMapLineItems.values()) {

                if ((Trigger.Isupdate && oLineItem.Service_Start_date__c != null && oLineItem.Service_End_date__c != null && oLineItem.Price_List_Division__c != 'Plancal' && /*oLineItem.Must_Prorate__c == True && */
                (oldMapLineItems.get(oLineItem.id).Service_Start_date__c != newMapLineItems.get(oLineItem.id).Service_Start_date__c ||
                 oldMapLineItems.get(oLineItem.id).Service_End_date__c != newMapLineItems.get(oLineItem.id).Service_End_date__c)) || (Trigger.Isinsert && oLineItem.Service_Start_date__c != null && oLineItem.Service_End_date__c != null)) {

                    Boolean skipPricingConfig = false;
                    if (mapPSDiscMatrix.containsKey(oLineItem.Product_Code__c) && mapPSDiscMatrix.get(oLineItem.Product_Code__c) != null && oLineItem.Apttus_Config2__IsCustomPricing__c) {
                        skipPricingConfig = true;
                    }

                    if (!skipPricingConfig) {
                        Integer iMonths = 0;
                        Integer iDays = 0;
                        Date dStartDate = oLineItem.service_Start_date__c;
                        Date dEndDate = oLineItem.Service_End_date__c;
                        String sOutput = CalculateDuration.MonthsandDays(dStartDate, dEndDate);
                        List<String> lstOutputs = sOutput.split(':');
                        iMonths = Integer.valueof(lstOutputs.get(0));
                        iDays = Integer.valueof(lstOutputs.get(1));


                        Decimal dcMonthlyPrice = 0;
                        if (oLineItem.EBS_Discount_Percentage__c != Null && oLineItem.Apttus_Config2__PriceUom__c == 'Year') {
                            dcMonthlyPrice = oLineItem.Actual_List_Price__c + (oLineItem.Actual_List_Price__c * (oLineItem.EBS_Discount_Percentage__c / 100));
                            dcMonthlyPrice = dcMonthlyPrice / 12;
                        }
                        else if (oLineItem.Apttus_Config2__PriceUom__c == 'Year')
                        dcMonthlyPrice = oLineItem.Actual_List_Price__c / 12;
                        else if (oLineItem.Apttus_Config2__PriceUom__c == 'Month')
                        dcMonthlyPrice = oLineItem.Actual_List_Price__c;
                        // TT-124690 : SaaS item List price was overriden with "0"
                        else
                        dcMonthlyPrice = oLineItem.Actual_List_Price__c / 12;
                        /////
                        Decimal dcDailyPrice = dcMonthlyPrice / 30;
                        Decimal dcListPriceMonthly = iMonths * dcMonthlyPrice;
                        Decimal dcListPriceDaily = iDays * dcDailyPrice;
                        Decimal dcListPr = dcListPriceMonthly + dcListPriceDaily;

                        System.debug('dcMonthlyPrice :::::::::::: ' + dcMonthlyPrice);
                        System.debug('dcListPr :::::::::::: ' + dcListPr);

                        oLineItem.Apttus_Config2__ListPrice__c = dcListPr;
                        oLineItem.Apttus_Config2__NetPrice__c = dcListPr * oLineItem.Apttus_Config2__Quantity__c;
                        oLineItem.Apttus_Config2__BaseExtendedPrice__c = dcListPr * oLineItem.Apttus_Config2__Quantity__c;
                        oLineItem.Apttus_Config2__BasePrice__c = dcListPr;
                        oLineItem.Apttus_Config2__BasePriceOverride__c = dcListPr;
                        oLineItem.Apttus_Config2__ExtendedPrice__c = dcListPr * oLineItem.Apttus_Config2__Quantity__c;
                    }
                }
            }
        }
    }

    public static void validateAssetQuantity(Map<Id, Apttus_Config2__LineItem__c> newMapLineItems, Map<Id, Apttus_Config2__LineItem__c> oldMapLineItems) {
        if (launchControl.get('validateAssetQuantity') < 1) {
            launchControl.put('validateAssetQuantity', launchControl.get('validateAssetQuantity') + 1);
            Map<Id, Map<String, decimal>> mapLineItemQty = new Map<Id, Map<String, decimal>> ();
            Map<String, decimal> mapAssetOracleIdQty = new Map<String, decimal> ();
            set<Id> setCartIds = new set<Id> ();
            set<Id> setAccountIds = new set<Id> ();
            for (Apttus_Config2__LineItem__c oLineItem : newMapLineItems.values()) {
                if (oLineItem.Asset_Oracle_ID__c != null && (oLineItem.Apttus_Config2__Quantity__c > oldMapLineItems.get(oLineItem.id).Apttus_Config2__Quantity__c ||
                                                             oLineItem.Asset_Oracle_ID__c != oldMapLineItems.get(oLineItem.id).Asset_Oracle_ID__c) && !oLineItem.Price_List_Name__c.contains('TIBV')) {
                    setCartIds.add(oLineItem.Apttus_Config2__ConfigurationId__c);
                    mapAssetOracleIdQty.put(oLineItem.Asset_Oracle_ID__c.split(':').get(0), 0);
                    setAccountIds.add(oLineItem.Account_Id__c);
                    String assetOracleId = oLineItem.Asset_Oracle_ID__c.split(':').get(0);

                    if (!mapLineItemQty.containsKey(oLineItem.Apttus_Config2__ConfigurationId__c)) mapLineItemQty.put(oLineItem.Apttus_Config2__ConfigurationId__c, new Map<String, decimal> ());
                    if (!mapLineItemQty.get(oLineItem.Apttus_Config2__ConfigurationId__c).containsKey(assetOracleId)) {
                        mapLineItemQty.get(oLineItem.Apttus_Config2__ConfigurationId__c).put(assetOracleId, 0);
                    }

                    decimal qty = mapLineItemQty.get(oLineItem.Apttus_Config2__ConfigurationId__c).get(assetOracleId) + oLineItem.Apttus_Config2__Quantity__c;
                    mapLineItemQty.get(oLineItem.Apttus_Config2__ConfigurationId__c).put(assetOracleId, qty);
                }
            }
            system.debug(setCartIds + '--------mapAssetOracleIdQty-------' + mapAssetOracleIdQty);
            for (Apttus_Config2__LineItem__c oLineItem :[select ID, Account_Id__c, Apttus_Config2__Quantity__c, Asset_Oracle_ID__c, Apttus_Config2__ConfigurationId__c from Apttus_Config2__LineItem__c where
                 Apttus_Config2__ConfigurationId__c in :setCartIds and Asset_Oracle_ID__c in :mapAssetOracleIdQty.keySet() and
                 Id not in :newMapLineItems.keySet()]) {
                if (!mapLineItemQty.containsKey(oLineItem.Apttus_Config2__ConfigurationId__c)) mapLineItemQty.put(oLineItem.Apttus_Config2__ConfigurationId__c, new Map<String, decimal> ());
                String assetOracleId = (newMapLineItems.containsKey(oLineItem.Id) ? newMapLineItems.get(oLineItem.Id).Asset_Oracle_ID__c.split(':').get(0) :
                                        oLineItem.Asset_Oracle_ID__c.split(':').get(0));
                if (assetOracleId != null && assetOracleId != '') {
                    if (!mapLineItemQty.get(oLineItem.Apttus_Config2__ConfigurationId__c).containsKey(assetOracleId)) {
                        mapLineItemQty.get(oLineItem.Apttus_Config2__ConfigurationId__c).put(assetOracleId, 0);
                    }

                    decimal qty = mapLineItemQty.get(oLineItem.Apttus_Config2__ConfigurationId__c).get(assetOracleId) + oLineItem.Apttus_Config2__Quantity__c;
                    mapLineItemQty.get(oLineItem.Apttus_Config2__ConfigurationId__c).put(assetOracleId, qty);
                }
            }

            for (Asset ass :[select Id, Asset_Oracle_ID__c, Quantity from Asset where Asset_Oracle_ID__c in :mapAssetOracleIdQty.keySet() and AccountId in :setAccountIds]) {
                mapAssetOracleIdQty.put(ass.Asset_Oracle_ID__c, ass.Quantity);
            }

            for (Apttus_Config2__LineItem__c oLineItem : newMapLineItems.values()) {
                if (oLineItem.Asset_Oracle_ID__c != null && oLineItem.Asset_Oracle_ID__c != '' && oLineItem.Apttus_Config2__Quantity__c > oldMapLineItems.get(oLineItem.id).Apttus_Config2__Quantity__c && !oLineItem.Price_List_Name__c.contains('TIBV')) {
                    if (mapAssetOracleIdQty.containsKey(oLineItem.Asset_Oracle_ID__c.split(':').get(0)) && mapLineItemQty.get(oLineItem.Apttus_Config2__ConfigurationId__c).containsKey(oLineItem.Asset_Oracle_ID__c.split(':').get(0))) {
                        if (mapLineItemQty.get(oLineItem.Apttus_Config2__ConfigurationId__c).get(oLineItem.Asset_Oracle_ID__c.split(':').get(0)) > mapAssetOracleIdQty.get(oLineItem.Asset_Oracle_ID__c.split(':').get(0))) {
                            oLineItem.Apttus_Config2__Quantity__c.addError('Line Item Quantity is more than Asset Quantity.');
                        }
                    }
                }
            }
        }
    }


    public static void RenewalValidation(List<Apttus_Config2__LineItem__c> newListLineItems, Map<Id, Apttus_Config2__LineItem__c> oldMapLineItems) {
        for (Apttus_Config2__LineItem__c oLineItem : newListLineItems) {
            if (oLineItem.Type__c == 'Renewal') {
                if (oLineItem.Service_Start_Date__c != null && oldMapLineItems.get(oLineItem.Id).Service_Start_Date__c != null) {
                    if (oLineItem.Service_Start_Date__c != oldMapLineItems.get(oLineItem.Id).Service_Start_Date__c) {
                        oLineItem.Service_Start_Date__c.addError('You cannot modify Service Start Date for Renewal Item.(Initial Value : ' + oldMapLineItems.get(oLineItem.Id).Service_Start_Date__c.month() + '/' + oldMapLineItems.get(oLineItem.Id).Service_Start_Date__c.day() + '/' + oldMapLineItems.get(oLineItem.Id).Service_Start_Date__c.year() + ' )');
                    }
                }
                if (oLineItem.Service_Start_Date__c != null && oLineItem.Service_End_Date__c != null) {
                    if (oLineItem.Service_Start_Date__c >= oLineItem.Service_End_Date__c) {
                        oLineItem.Service_End_Date__c.addError('Service End Date should be greater than Service Start Date.(Previous Value : ' + oldMapLineItems.get(oLineItem.Id).Service_End_Date__c.month() + '/' + oldMapLineItems.get(oLineItem.Id).Service_End_Date__c.day() + '/' + oldMapLineItems.get(oLineItem.Id).Service_End_Date__c.year() + ' )');
                    }
                }
                if (oLineItem.Apttus_Config2__Quantity__c != null && oLineItem.Initial_Renewal_Quantity__c != null) {
                    if (oLineItem.Apttus_Config2__Quantity__c > oLineItem.Initial_Renewal_Quantity__c) {
                        oLineItem.Apttus_Config2__Quantity__c.addError('You cannot assign Quantity beyond Initial Quantity of Renewal Item.(Initial Value : ' + oldMapLineItems.get(oLineItem.Id).Initial_Renewal_Quantity__c.intValue() + ' )');
                    }
                }
            }
        }
    }

    public static void processRenewalLineItem(List<Apttus_Config2__LineItem__c> newListLineItems) {
        List<WS_Interface_Log__c> lstLogs = new List<WS_Interface_Log__c> ();
        Map<String, String> mapTargetSourceField = new Map<String, String> ();
        Map<String, String> mapDefaultValue = new Map<String, String> ();
        for (Field_Map__c oFieldMap :[select Id, Default_Value__c, Reference_Query__c, Object_Map__r.Source_Object__c,
             Object_Map__r.Target_Object__c, Target_Field__c, Source_Field__c from Field_Map__c
             where Object_Map__r.Name = :'TNV_SFDC_OPPORTUNITY_EXT_PKG Line Item']) {
            if (oFieldMap.Default_Value__c != null)
            mapDefaultValue.put(oFieldMap.Target_Field__c, oFieldMap.Default_Value__c);
            else if (oFieldMap.Source_Field__c != null && oFieldMap.Source_Field__c != '')
            mapTargetSourceField.put(oFieldMap.Target_Field__c, oFieldMap.Source_Field__c);
        }


        for (String sTargetField : mapTargetSourceField.keySet()) {
            for (Apttus_Config2__LineItem__c oLineItem : newListLineItems) {
                for (Integer iCount = 0; iCount<LineItemHelper_v1.LineItemList.size(); iCount++) {
                    if (LineItemHelper_v1.LineItemList.get(iCount).PriceBookEntry.Product2Id == oLineItem.Apttus_Config2__ProductId__c &&
                        LineItemHelper_v1.LineItemList.get(iCount).Quantity == oLineItem.Apttus_Config2__Quantity__c) {
                        String sSourceField = mapTargetSourceField.get(sTargetField);
                        system.debug('------sSourceField-----' + LineItemHelper_v1.LineItemList.get(iCount).get(sSourceField));
                        Object oSourceFieldValue = LineItemHelper_v1.LineItemList.get(iCount).get(sSourceField);
                        if (oSourceFieldValue != null) {
                            try {
                                String sDataType = XMLUtility.getDataType('Apttus_Config2__LineItem__c', sTargetField);
                                setFieldValue(sDataType, oSourceFieldValue, sTargetField, oLineItem);
                            } catch(exception ex) {
                                if (ex.getMessage() != '') {
                                    WS_Interface_Log__c oWSInterfaceLog = WS_Interface_Log.createLog('LineItemHelper', 'processRenewalLineItem', ex.getMessage(),
                                                                                                     ex.getTypeName() + '\n' + ex.getCause() + '\n' + ex.getStackTraceString(), '');
                                    lstLogs.add(oWSInterfaceLog);
                                }
                            }
                        }
                    }
                }
            }
        }

        for (String sTargetField : mapDefaultValue.keySet()) {
            for (Apttus_Config2__LineItem__c oLineItem : newListLineItems) {
                String sFieldValue = mapDefaultValue.get(sTargetField);
                if (sFieldValue != null) {
                    try {
                        String sDataType = XMLUtility.getDataType('Apttus_Config2__LineItem__c', sTargetField);
                        setFieldValue(sDataType, sFieldValue, sTargetField, oLineItem);
                    } catch(exception ex) {
                        if (ex.getMessage() != '') {
                            WS_Interface_Log__c oWSInterfaceLog = WS_Interface_Log.createLog('LineItemHelper', 'processRenewalLineItem', ex.getMessage(),
                                                                                             ex.getTypeName() + '\n' + ex.getCause() + '\n' + ex.getStackTraceString(), '');
                            lstLogs.add(oWSInterfaceLog);
                        }
                    }
                }
            }
            if (lstLogs.size()> 0) {
                insert lstLogs;
            }
        }
    }

    public static void setFieldValue(String sDataType, Object oSourceFieldValue, String sTargetField, Apttus_Config2__LineItem__c oLineItem) {
        if (sDataType == 'TEXT') {
            String sFieldValue = (String) oSourceFieldValue;
            oLineItem.put(sTargetField, sFieldValue);
        } else if (sDataType == 'DATETIME') {
            oLineItem.put(sTargetField, (DateTime) oSourceFieldValue);
        } else if (sDataType == 'DATE') {
            oLineItem.put(sTargetField, (Date) oSourceFieldValue);
        } else if (sDataType == 'DECIMAL') {
            oLineItem.put(sTargetField, (sTargetField == 'Apttus_Config2__NetAdjustmentPercent__c' ? - 1 * (Decimal) oSourceFieldValue : (Decimal) oSourceFieldValue));
        } else if (sDataType == 'BOOLEAN') {
            String sFieldValue = (String) oSourceFieldValue;
            if (sFieldValue.equals('Yes') || sFieldValue.equals('YES') ||
                sFieldValue.equals('1') || sFieldValue.equals('true') ||
                sFieldValue.equals('True') || sFieldValue.equals('TRUE'))
            oLineItem.put(sTargetField, true);
            else
            oLineItem.put(sTargetField, false);
        } else if (sDataType == 'REFERENCE') {
            String sFieldValue = (String) oSourceFieldValue;
            oLineItem.put(sTargetField, (Id) sFieldValue);
        }
    }

    /* Added for TT# 101380
      Summary : to vlaidate the Qty data is non-integer for Product Category Type = Sofwtare/ Hardware
      Added by : Srini Babu 
      Dated on : 03/29/2016 */

    public static void validateQtydata(List<Apttus_Config2__LineItem__c> newListLineItems, Map<Id, Apttus_Config2__LineItem__c> oldMapLineItems) {
        Decimal dcQty;
        try {
            for (Apttus_Config2__LineItem__c oLineItem : newListLineItems) {
                if (oLineItem.Apttus_Config2__Quantity__c != 0 && (oldMapLineItems.get(oLineItem.Id).PPM_Item__c == '' || (oldMapLineItems.get(oLineItem.Id).PPM_Item__c != Null && oldMapLineItems.get(oLineItem.Id).PPM_Item__c == 'N'))) {
                    dcQty = oLineItem.Apttus_Config2__Quantity__c.Divide(oLineItem.Apttus_Config2__Quantity__c.intValue(), 5);
                    if (dcQty > 1) {
                        oLineItem.Apttus_Config2__Quantity__c.addError('Non-integer value is not allowed for this item');
                    }
                }
            }
        }
        catch(System.DmlException dmlexp) {
            system.debug('dmlexp ==>' + dmlexp);
            ExceptionUtils.captureException(dmlexp, true);
        }
    }

    /*Method to handle all Line Item related Insert
      Added by : Prince leo 
      Dated on : 03/03/2019 */
    public static void LineItemBeforeInsertMethods(Map<Id, Apttus_Config2__LineItem__c> newMapLineItems)
    {
        // variable Declaration
        Set<Id> setConfigurationIds = new Set<Id> ();
        Map<Id, Apttus_Config2__ProductConfiguration__c> mapConfigAddress = new Map<Id, Apttus_Config2__ProductConfiguration__c> ();

        // Filling up the Map Values  
        try {
            for (Apttus_Config2__LineItem__c co : newMapLineItems.values()) {
                setConfigurationIds.add(co.Apttus_Config2__ConfigurationId__c);
            }

            Map<Id, Apttus_Config2__ProductConfiguration__c> mapConfigure = new Map<Id, Apttus_Config2__ProductConfiguration__c> ();
            mapConfigure = Product_Config_DMO.fetch_ProductConfigUsingIds(setConfigurationIds);

            for (Apttus_Config2__ProductConfiguration__c config : mapConfigure.values()) {
                mapConfigAddress.put(config.Id, config);
            }

            for (Apttus_Config2__LineItem__c oLineItem : newMapLineItems.values()) {
                if (mapConfigAddress.get(oLineItem.Apttus_Config2__ConfigurationId__c) != null) {
                    oLineItem.Industry__c = mapConfigAddress.get(oLineItem.Apttus_Config2__ConfigurationId__c).Apttus_QPConfig__Proposald__r.Industry__c;
                    if (oLineItem.Bill_To_Address__c == Null) oLineItem.Bill_To_Address__c = mapConfigAddress.get(oLineItem.Apttus_Config2__ConfigurationId__c).Apttus_QPConfig__Proposald__r.Bill_to_Address__c;
                    if (oLineItem.Ship_To_Address1__c == Null) oLineItem.Ship_To_Address1__c = mapConfigAddress.get(oLineItem.Apttus_Config2__ConfigurationId__c).Apttus_QPConfig__Proposald__r.Ship_to_Address1__c;
                }

                // This code is to check if the Cart is Already Approved and no change done to initiate the current approval process 
                if ((oLineItem.Apttus_Config2__NetAdjustmentPercent__c< 0 || oLineItem.Apttus_Config2__NetAdjustmentPercent__c> 0) && oLineItem.Apttus_CQApprov__Approval_Status__c == Null)
                oLineItem.WF_Skip_Approvals__c = True;
            }
        }
        catch(System.DmlException dmlexp) {
            system.debug('dmlexp ==>' + dmlexp);
            ExceptionUtils.captureException(dmlexp, true);
        }
    }


    /*Method to handle all Line Item related Updates
      Added by : Prince leo 
      Dated on : 03/03/2019 */
    public static void LineItemBeforeUpdateMethods(Map<Id, Apttus_Config2__LineItem__c> newMapLineItems, Map<Id, Apttus_Config2__LineItem__c> oldMapLineItems)
    {
        // Variable declaration 
        Set<Id> setConfigurationIds = new Set<Id> ();
        Set<ID> setLineIds = new Set<ID> ();
        Map<Id, Id> mapConfigureOwner = new Map<Id, Id> ();
        Map<Id, Id> mapConfigManager = new Map<Id, Id> ();
        Map<Id, String> mapConfigsalesRep = new Map<Id, String> ();
        Map<Id, String> mapOppSubType = new Map<Id, String> ();
        Map<Id, Id> mapOpportunityIds = new Map<Id, Id> ();
        Map<Id, Apttus_Config2__ProductConfiguration__c> mapConfigAddress = new Map<Id, Apttus_Config2__ProductConfiguration__c> ();
        Set<ID> setOpportunityIds = new Set<ID> ();
        List<Opportunity> lstOpportunities = new List<Opportunity> ();

        //Custom Pricing for Option Lines. 
        try {
            for (Apttus_Config2__LineItem__c oLineItem : newMapLineItems.values()) {
                if (oLineItem.Apttus_Config2__LineType__c == 'Option' && oLineItem.Apttus_Config2__IsCustomPricing__c == True)
                {
                    oLineItem.Apttus_Config2__ExtendedPrice__c = oLineItem.Apttus_Config2__ListPrice__c * oLineItem.Apttus_Config2__Quantity__c;
                    if (oLineItem.Apttus_Config2__NetAdjustmentPercent__c != Null)
                    oLineItem.Apttus_Config2__NetPrice__c = (oLineItem.Apttus_Config2__ListPrice__c * oLineItem.Apttus_Config2__Quantity__c) + ((oLineItem.Apttus_Config2__NetAdjustmentPercent__c / 100) * oLineItem.Apttus_Config2__ListPrice__c);
                    else
                    oLineItem.Apttus_Config2__NetPrice__c = (oLineItem.Apttus_Config2__ListPrice__c * oLineItem.Apttus_Config2__Quantity__c);
                    oLineItem.Apttus_Config2__BaseExtendedPrice__c = oLineItem.Apttus_Config2__ListPrice__c * oLineItem.Apttus_Config2__Quantity__c;
                    oLineItem.Apttus_Config2__BasePrice__c = oLineItem.Apttus_Config2__ListPrice__c * oLineItem.Apttus_Config2__Quantity__c;
                    oLineItem.Apttus_Config2__BasePriceOverride__c = oLineItem.Apttus_Config2__ListPrice__c * oLineItem.Apttus_Config2__Quantity__c;
                }
            }

            // Filling up the Map Values    
            for (Apttus_Config2__LineItem__c oLineItem : newMapLineItems.values()) {
                setConfigurationIds.add(oLineItem.Apttus_Config2__ConfigurationId__c);
            }

            Map<Id, Apttus_Config2__ProductConfiguration__c> mapConfig = new Map<Id, Apttus_Config2__ProductConfiguration__c> ();

            mapConfig = Product_Config_DMO.fetch_ProductConfigUsingIds(setConfigurationIds);

            for (Apttus_Config2__ProductConfiguration__c config : mapConfig.values()) {
                mapConfigureOwner.put(config.Id, config.Apttus_QPConfig__Proposald__r.OwnerId);
                mapConfigAddress.put(config.Id, config);
            }
            Map<Id, User> mapUsers = new Map<Id, User> ([Select Id, Legal_Entity__c from User where Id IN :mapConfigureOwner.values()]);
            //for(Apttus_Config2__LineItem__c Line : [SELECT Id, Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__c, Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.Account_Sub_Type__c, createdby.Managerid, Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Ownerid, Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Owner.userName, Apttus_Config2__ConfigurationId__r.Sales_Rep_Manager__c FROM Apttus_Config2__LineItem__c WHERE Id IN:newMapLineItems.values()])
            for (Apttus_Config2__LineItem__c oLineItem : LineItem_DMO.fetch_LineItemsUsingIds(newMapLineItems.values()))
            {

                if (oLineItem.Apttus_Config2__ConfigurationId__r.Sales_Rep_Manager__c != NULL)
                mapConfigManager.put(oLineItem.id, oLineItem.Apttus_Config2__ConfigurationId__r.Sales_Rep_Manager__c);
                if (oLineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Ownerid != Null)
                mapConfigsalesRep.put(oLineItem.id, oLineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Owner.username);
                if (oLineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.Account_Sub_Type__c != Null)
                mapOppSubType.put(oLineItem.id, oLineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.Account_Sub_Type__c);
                if (oLineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__c != Null)
                mapOpportunityIds.put(oLineItem.id, oLineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__c);
            }

            //MEP NA Skip Approval Process logic 
            for (Apttus_Config2__LineItem__c oLineItem : newMapLineItems.values())
            {

                if (oldMapLineItems.get(oLineItem.id).Apttus_Config2__NetPrice__c != newMapLineItems.get(oLineItem.id).Apttus_Config2__NetPrice__c)
                oLineItem.WF_Skip_Approvals__c = False;
                oLineItem.Sales_Rep_Manager__c = mapConfigManager.get(oLineItem.id);
                if (mapConfigsalesRep.get(oLineItem.id) != Null && mapConfigsalesRep.get(oLineItem.id).touppercase().contains(Label.Trade_Service_Approval_Exclusion.touppercase()))
                {
                    oLineItem.Skip_Trade_Service_Approval__c = True;
                }
                else
                {
                    oLineItem.Skip_Trade_Service_Approval__c = False;
                }
                if ((mapOppSubType.get(oLineItem.id) != Null && (mapOppSubType.get(oLineItem.id) == 'Education/Donation' || mapOppSubType.get(oLineItem.id) == 'Reconfigure/Damaged/Lost Device/License Transfers' || mapOppSubType.get(oLineItem.id) == 'Trial' || mapOppSubType.get(oLineItem.id) == 'Crossgrade')) || oLineItem.WF_Skip_Approvals__c == True)
                {
                    oLineItem.WF_Skip_Approvals__c = True;
                    setOpportunityIds.add(mapOpportunityIds.get(oLineItem.id));
                }
                else
                {
                    oLineItem.WF_Skip_Approvals__c = False;
                }

                // This block is to replace the Workflow Rule with Trigger to overcome the execution sequence issue 
                List<Skip_Apttus_Approval_Process__c> mcs1 = Skip_Apttus_Approval_Process__c.getall().values();
                boolean MakeTrue = False;
                Skip_Apttus_Approval_Process__c mcsPro = Skip_Apttus_Approval_Process__c.getinstance(oLineItem.Apttus_Config2__ProductId__c);
                Skip_Apttus_Approval_Process__c mcsOpt = Skip_Apttus_Approval_Process__c.getinstance(oLineItem.Apttus_Config2__OptionId__c);
                Skip_Apttus_Approval_Process__c cs;

                if (mcsPro != Null)
                cs = mcsPro;
                else if (mcsOpt != Null)
                cs = McsOpt;

                if (cs != Null) {
                    if (oLineItem.Apttus_Config2__ProductId__c == cs.Product_ID__c && ((cs.Net_Price__c != Null && cs.Net_Price__c.split(';').contains(String.valueof(oLineItem.Apttus_Config2__NetPrice__c))) ||
                    (cs.Discount__c != Null && oLineItem.Apttus_Config2__NetAdjustmentPercent__c != Null && oLineItem.Apttus_Config2__NetAdjustmentPercent__c == cs.Discount__c)))
                    {
                        oLineItem.WF_Skip_Approvals__c = True;
                        setOpportunityIds.add(mapOpportunityIds.get(oLineItem.id));
                        MakeTrue = True;
                    }

                    if (oLineItem.Apttus_Config2__OptionId__c == cs.Product_ID__c && ((cs.Net_Price__c != Null && cs.Net_Price__c.split(';').contains(String.valueof(oLineItem.Apttus_Config2__NetPrice__c))) ||
                    (cs.Discount__c != Null && oLineItem.Apttus_Config2__NetAdjustmentPercent__c != Null && oLineItem.Apttus_Config2__NetAdjustmentPercent__c == cs.Discount__c)))
                    {

                        oLineItem.WF_Skip_Approvals__c = True;
                        setOpportunityIds.add(mapOpportunityIds.get(oLineItem.id));
                        MakeTrue = True;

                    }

                    if (oLineItem.Apttus_Config2__ProductId__c == cs.Product_ID__c && ((cs.Net_Price__c != Null && !cs.Net_Price__c.split(';').contains(String.valueof(oLineItem.Apttus_Config2__NetPrice__c))) ||
                    (cs.Discount__c != Null && oLineItem.Apttus_Config2__NetAdjustmentPercent__c != Null && oLineItem.Apttus_Config2__NetAdjustmentPercent__c != cs.Discount__c)))

                    {

                        oLineItem.WF_Skip_Approvals__c = False;

                    }

                    if (oLineItem.Apttus_Config2__OptionId__c == cs.Product_ID__c && ((cs.Net_Price__c != Null && !cs.Net_Price__c.split(';').contains(String.valueof(oLineItem.Apttus_Config2__NetPrice__c))) ||
                    (cs.Discount__c != Null && oLineItem.Apttus_Config2__NetAdjustmentPercent__c != Null && oLineItem.Apttus_Config2__NetAdjustmentPercent__c != cs.Discount__c)))
                    {
                        oLineItem.WF_Skip_Approvals__c = False;

                    }

                }

            }

            for (Id opportunityId : setOpportunityIds)
            {
                Opportunity oOpportunity = new Opportunity(id = opportunityId);
                oOpportunity.Approval_Skipped__c = True;
                //Opp.Approval_Skip_Reason__c='None';
                if (oOpportunity.id != Null) lstOpportunities.add(oOpportunity);
            }


            if (lstOpportunities.size() > 0)
            {
                CreateRenewalOpportunityFromEBS.runOpportunityTrigger = False;
                Update lstOpportunities;
            }

            for (Apttus_Config2__LineItem__c oLineItem : newMapLineItems.values()) {
                setLineIds.add(oLineItem.id);
                //checking if account lookup is null or not null
                if (oLineItem.Account_lookup__c == null) {
                    //Assigning id to shipping Account field
                    oLineItem.Account_lookup__c = oLineItem.AccountIdfortrigger__c;
                }

                if (mapUsers != null && mapUsers.size() > 0 && mapConfigureOwner.size() > 0 && mapConfigureOwner.containsKey(oLineItem.Apttus_Config2__ConfigurationId__c) && mapUsers.containsKey(mapConfigureOwner.get(oLineItem.Apttus_Config2__ConfigurationId__c))) {
                    oLineItem.Users_Legal_Entity__c = mapUsers.get(mapConfigureOwner.get(oLineItem.Apttus_Config2__ConfigurationId__c)).Legal_Entity__c;
                }
                if (oLineItem.Industry__c == Null) oLineItem.Industry__c = mapConfigAddress.get(oLineItem.Apttus_Config2__ConfigurationId__c).Apttus_QPConfig__Proposald__r.Industry__c;
                if (oLineItem.Bill_To_Address__c == Null) oLineItem.Bill_To_Address__c = mapConfigAddress.get(oLineItem.Apttus_Config2__ConfigurationId__c).Apttus_QPConfig__Proposald__r.Bill_to_Address__c;
                if (oLineItem.Ship_To_Address1__c == Null) oLineItem.Ship_To_Address1__c = mapConfigAddress.get(oLineItem.Apttus_Config2__ConfigurationId__c).Apttus_QPConfig__Proposald__r.Ship_to_Address1__c;

            }
        }
        catch(System.DmlException dmlexp) {
            system.debug('dmlexp ==>' + dmlexp);
            ExceptionUtils.captureException(dmlexp, true);
        }
    }

    /*Summary : To Check if the Sequence of the lines are changed and update the flag on Quote Header
      Added by : Prince leo 
      Dated on : 03/03/2019 */
    public static void LineSequenceLogicAndBillToChanged(Map<Id, Apttus_Config2__LineItem__c> newMapLineItems, Map<Id, Apttus_Config2__LineItem__c> oldMapLineItems)
    {
        Set<Id> setProductConfigIdsLineSeq = new Set<Id> ();
        Boolean blnLineSequence = False;
        Boolean blnAdvancePricing = False;
        for (Apttus_Config2__LineItem__c oLineItem : newMapLineItems.values()) {
            if (oldMapLineItems.get(oLineItem.id).Apttus_Config2__LineSequence__c != newMapLineItems.get(oLineItem.id).Apttus_Config2__LineSequence__c)
            {
                setProductConfigIdsLineSeq.add(oLineItem.Apttus_Config2__ConfigurationId__c);
                blnLineSequence = True;
            }
            if (oldMapLineItems.get(oLineItem.id).Bill_To_Address__c != newMapLineItems.get(oLineItem.id).Bill_To_Address__c || oldMapLineItems.get(oLineItem.id).Apttus_Config2__Quantity__c != newMapLineItems.get(oLineItem.id).Apttus_Config2__Quantity__c)
            {
                setProductConfigIdsLineSeq.add(oLineItem.Apttus_Config2__ConfigurationId__c);
                blnAdvancePricing = True;
            }
        }

        //added for Line Sequence Logic - Kit EBS Line Order  and Invoke Advance Pricing On Change of Quantity and Bill to Address
        if (setProductConfigIdsLineSeq.size() > 0) {
            // Query Proposal IDs
            Set<Id> setProposalIDs = new Set<Id> ();

            for (Apttus_Config2__ProductConfiguration__c pConf : Product_Config_DMO.fetch_ProductConfigUsingIdsList(setProductConfigIdsLineSeq)) {
                setProposalIDs.add(pConf.Apttus_QPConfig__Proposald__c);
            }
            List<Apttus_Proposal__Proposal__c> lstProposals = [SELECT Id, Bill_to_Address_Changed__c, Cart_Line_Sequence_Changed__c FROM Apttus_Proposal__Proposal__c WHERE Id IN :setProposalIDs];

            for (Apttus_Proposal__Proposal__c oProposal : lstProposals) {

                if (blnLineSequence == True) oProposal.Cart_Line_Sequence_Changed__c = true;
                if (blnAdvancePricing == True) oProposal.Bill_to_Address_Changed__c = true;

            }

            try {
                // Update Quote/Proposals with Bill to Address Changed
                update lstProposals;
            }
            catch(System.DmlException dmlexp) {
                system.debug('dmlexp ==>' + dmlexp);
                ExceptionUtils.captureException(dmlexp, true);
            }
        }

    }

    Public Static void DeleteLineitemMethod(Map<Id, Apttus_Config2__LineItem__c> oldMapLineItems)
    {
        try
        {
            set<String> setParentLineNumber = new set<String> ();
            List<Apttus_Config2__LineItem__c> lstLineItems = new List<Apttus_Config2__LineItem__c> ();

            for (Apttus_Config2__LineItem__c oLineItem : oldMapLineItems.values()) {
                if (oLineItem.Parent_Line_Number__c != Null && oLineItem.Parent_Line_Number__c != '') setParentLineNumber.add(oLineItem.Parent_Line_Number__c);
            }

            for (Apttus_Config2__LineItem__c oLineItem : oldMapLineItems.values()) {
                if (oLineItem.Type__c == 'Renewal' && !setParentLineNumber.contains(oLineItem.Name) && (oLineItem.Parent_Line_Number__c == Null || oLineItem.Parent_Line_Number__c == '')) {
                    oLineItem.addError('Renewal Lines cannot be deleted!');
                } else if (oLineItem.Type__c == 'Renewal' && setParentLineNumber.contains(oLineItem.Name)) {
                    Apttus_Config2__LineItem__c oLineItemNew = new Apttus_Config2__LineItem__c();
                    oLineItemNew = oLineItem.clone(false, true, false, false);
                    lstLineItems.add(oLineItemNew);
                }
            }
            if (lstLineItems.size() > 0) insert lstLineItems;
        }


        catch(System.DmlException dmlexp) {
            system.debug('dmlexp ==>' + dmlexp);
            ExceptionUtils.captureException(dmlexp, true);
        }
    }

    /**
     * @description : This method used to restrict applying Discounts/Price Override for specific products. APP-5838 : Prevent Item BASECAMP-MEPNA form beeing discounted
     * @param lstNewLineItems 
     * @param mapOldLineItems 
     *
      public static void RestrictDiscounts_PriceOverride(List<Apttus_Config2__LineItem__c> lstNewLineItems, Map<Id, Apttus_Config2__LineItem__c> mapOldLineItems) {
      if (launchControl.get('RestrictDiscounts_PriceOverride') < 1) {
      launchControl.put('RestrictDiscounts_PriceOverride', launchControl.get('RestrictDiscounts_PriceOverride') + 1);
     
      //    APP-5838 : Prevent Item BASECAMP-MEPNA form beeing discounted
      System.debug('ENTRY Restrict Discount .............');
     
      Map<Id, Boolean> mapRestrictDiscountEnabled = new Map<Id, Boolean> ();
      for (Apttus_Config2__LineItem__c liCheckRestrict :[SELECT Apttus_Config2__ProductId__c, Apttus_Config2__ProductId__r.Restrict_Discount_PriceOverride__c FROM Apttus_Config2__LineItem__c WHERE Id IN :mapOldLineItems.keySet()]) {
      mapRestrictDiscountEnabled.put(liCheckRestrict.Apttus_Config2__ProductId__c, liCheckRestrict.Apttus_Config2__ProductId__r.Restrict_Discount_PriceOverride__c);
      }
     
      for (Apttus_Config2__LineItem__c li : lstNewLineItems) {
      System.debug(' li.Apttus_Config2__AdjustmentType__c ==========>'+li.Apttus_Config2__AdjustmentType__c);
      System.debug(' li.Apttus_Config2__AdjustmentAmount__c ==========>'+li.Apttus_Config2__AdjustmentAmount__c);
      System.debug(' li.Apttus_Config2__NetAdjustmentPercent__c ==========>'+li.Apttus_Config2__NetAdjustmentPercent__c);
      System.debug(' li.Apttus_Config2__GroupAdjustmentPercent__c ==========>'+li.Apttus_Config2__GroupAdjustmentPercent__c);
      System.debug(' li.Manual_Discount_Amount__c ==========>'+li.Manual_Discount_Amount__c);
     
      if (mapRestrictDiscountEnabled.containsKey(li.Apttus_Config2__ProductId__c) && mapRestrictDiscountEnabled.get(li.Apttus_Config2__ProductId__c)) {
      li.Apttus_Config2__AdjustmentType__c = null;
      li.Apttus_Config2__AdjustmentAmount__c = null;
      li.Apttus_Config2__NetAdjustmentPercent__c = 0.0000;
      li.Apttus_Config2__GroupAdjustmentPercent__c = 0.0000;
      li.Manual_Discount_Amount__c = null;
      }
      }
      // END
      }
      }
     */
}