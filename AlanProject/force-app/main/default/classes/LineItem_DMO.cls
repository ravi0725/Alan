/*
 * Data Model Object class for LineItem object
 * 
*/
public class LineItem_DMO {
	
    /*
     * Method Name	:	fetch_LineItemsUsingIds
     * Param		:	lstNewItemIDs (list of LineItem IDs)
     * Return		:	List of LineItem records
	*/
    public static List<Apttus_Config2__LineItem__c> fetch_LineItemsUsingIds(List<Apttus_Config2__LineItem__c> lstNewItemIDs){
        return [SELECT 
                Id, Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__c, 
                Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.Account_Sub_Type__c, createdby.Managerid, 
                Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Ownerid, Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Owner.userName, 
                Apttus_Config2__ConfigurationId__r.Sales_Rep_Manager__c 
                FROM 
                Apttus_Config2__LineItem__c 
                WHERE
                Id IN : lstNewItemIDs];
    }
}