/*
 * Data Model Object class for ProductConfig object
 * 
*/
public class Product_Config_DMO {
  
    /*
     * Method Name  :  fetch_ProductConfig_UsingIds
     * Param    :  lstNewItemIDs (list of ProductConfig IDs)
     * Return    :  Map of Product Config records
  */
    public static Map<Id,Apttus_Config2__ProductConfiguration__c> fetch_ProductConfigUsingIds(Set<ID> lstNewItemIDs){
    Map<Id,Apttus_Config2__ProductConfiguration__c>mapResult = new Map<Id,Apttus_Config2__ProductConfiguration__c>([SELECT Id, Apttus_QPConfig__Proposald__r.OwnerId,Apttus_QPConfig__Proposald__r.Bill_to_Address__c,Apttus_QPConfig__Proposald__r.Service_Start_Date__c,Apttus_QPConfig__Proposald__r.Service_End_Date__c,Apttus_QPConfig__Proposald__r.Bill_To_Contact__c,
                Apttus_QPConfig__Proposald__r.Ship_to_Address1__c,Apttus_QPConfig__Proposald__r.Industry__c,Apttus_QPConfig__Proposald__r.Apttus_Proposal__Primary_Contact__c from Apttus_Config2__ProductConfiguration__c where Id IN: lstNewItemIDs]);
        return mapResult;
        
        }
        
  
    /*
     * Method Name  :  fetch_ProductConfig_UsingIdsList
     * Param    :  lstNewItemIDs (list of ProductConfig IDs)
     * Return    :  List of Product Config records
  */
    public static List<Apttus_Config2__ProductConfiguration__c> fetch_ProductConfigUsingIdsList(Set<ID> lstNewItemIDs){
    
        return [SELECT Id, Apttus_QPConfig__Proposald__c FROM Apttus_Config2__ProductConfiguration__c WHERE Id IN: lstNewItemIDs];
        
        }
}