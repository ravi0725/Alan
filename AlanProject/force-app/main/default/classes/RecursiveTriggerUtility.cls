/************************************************************************************
* Name          :    RecursiveTriggerUtility
* Description   :    Global class to use static variables to stop iterative triggers and to load recordType in a map.
* Author        :    Sagar

Modification Log
----------------
Date             Developer                Comments
------------------------------------------------------------------------------------------
                   Sagar         Created    06/10/2013
10/23/2015      Suresh Babu              Added line # 18 to restrict Address Trigger Recurrence
******************************************************************************************/
global class RecursiveTriggerUtility{

    public static boolean isTriggerExecute = false;
    public static boolean isBatchExecute = true;
    public static boolean isAccountRecursive = true;
    public static boolean isAccountMergeRecursive = false;
    public static boolean isAddressRecursive = true;
    public static boolean isEntitlementRecursive = true;
    public static boolean isProposalLineItemRecursive = true;
    public static boolean isLeadUpdateExecute;
    public static boolean recursiveCallLineItemTrigger = false;
    public static boolean isBeforeInsertQuoteProposalTrigger = false;
    public static boolean isBeforeUpdateQuoteProposalTrigger = false;
    public static boolean isAfterInsertQuoteProposalTrigger = false;
    public static boolean isAfterUpdateQuoteProposalTrigger = false;
    public static boolean isBeforeAssignSelectedProductList = false;
    public static boolean lineitemafter = false;
    public static boolean approvallistner = false;
    public static boolean stopLineItemTrigger_ApprovalRequestListener = false;
    public static Map<String, Id> recordTypeMap;
    public static Boolean PPMJIRA_UpdateStatus = false;
    public static Boolean PPMJIRA_UpdateComponent = false;
    public static Boolean PPMJIRA_Create = false;
    public static Boolean PPMJIRA_Push = false;
	public static Boolean isSetPriceBookDefaultTriggerRecursive = false;

    static {
        recursiveCallLineItemTrigger = false;
        isAfterInsertQuoteProposalTrigger = true;
        isBeforeInsertQuoteProposalTrigger = false;
        isBeforeUpdateQuoteProposalTrigger = false;
        isAfterUpdateQuoteProposalTrigger = false;
        isBeforeAssignSelectedProductList = false;
        isAccountMergeRecursive = false;
    }

    /**
     * Method name  : loadRecordTypeMap
     * Description  : This method returns the record type of the SObject passed in the argument.
     * Return Type  : Map<String, Id>
     * Parameter    : Schema.SObjectType
     **/
    public static Map<String, Id> loadRecordTypeMap(Schema.SObjectType token){
        if(recordTypeMap == null){
            recordTypeMap = new Map<String, Id>();
            // Get the Describe Result
            Schema.DescribeSObjectResult obj = token.getDescribe();

            // Obtain ALL Active Record Types for the given SObjectType token
            String soql =
                'SELECT Id, DeveloperName '
                + 'FROM RecordType '
                + 'WHERE SObjectType = \'' + String.escapeSingleQuotes(obj.getName()) + '\' '
                + 'AND IsActive = TRUE';
            List<RecordType> results;
            try {
                results = Database.query(soql);
            } catch (Exception ex) {
                System.debug(ex.getMessage());
                results = new List<SObject>();
            }
            for (RecordType recordType : results) {
                recordTypeMap.put(recordType.DeveloperName, recordType.Id);
            }
        }
        return recordTypeMap;
    }
}