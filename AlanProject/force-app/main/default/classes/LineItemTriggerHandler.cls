/*****************************************************************************************
  Name    : LineItemTriggerHandler 
  Desc    : LineItem Global Handler invoked from LineItemTrigger_V1
  Modification Log : 
  ---------------------------------------------------------------------------
  Developer                 Date            Description
  ---------------------------------------------------------------------------
  Prince Leo                04/Mar/2019     Created
  ******************************************************************************************/
public class LineItemTriggerHandler implements ITriggerHandler
{
    // Allows unit tests (or other code) to disable this trigger for the transaction
    public static Boolean TriggerDisabled = false;

    /*
      Checks to see if the trigger has been disabled either by custom setting or by running code
    */
    public Boolean IsDisabled()
    {
        /* 
          To Stop Trigger execution on Unit test class use below code
          AccountTriggerHandler.TriggerDisabled = true;*/
        List<TriggerSettings__mdt> SettingsObj = [Select MasterLabel, Disable_Line_Item_Triggers__c from TriggerSettings__mdt Where MasterLabel = 'Admin'];
        if (SettingsObj.size() > 0 && SettingsObj.get(0).Disable_Line_Item_Triggers__c == true)
        return true;
        else
        return TriggerDisabled;
    }

    /* Method will be Invoked from Line Item Trigger to handle Logics on Before Insert Scenario
      Parent Class: ITriggerHandler
      Invoking Trigger : LineItemTrigger_V1 
    */
    public void BeforeInsert(List<SObject> newItems)
    {
        //List Typecasting
        List<Apttus_Config2__LineItem__c> NewLineItemList = (List<Apttus_Config2__LineItem__c>) newItems;
        if (LineItemHelper_v1.LineItemList != null) LineItemHelper_v1.processRenewalLineItem(NewLineItemList);
    }

    /* Method will be Invoked from Line Item Trigger to handle Logics on Before Update Scenario
      Parent Class: ITriggerHandler
      Invoking Trigger : LineItemTrigger_V1 
    */
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {

        // Map<id,Apttus_Config2__LineItem__c>NewMap = new Map<Id,Apttus_Config2__LineItem__c>(newItems);

        //Map Typecasting
        Map<id, Apttus_Config2__LineItem__c> NewLineItemMap = (Map<id, Apttus_Config2__LineItem__c>) newItems;
        Map<id, Apttus_Config2__LineItem__c> OldLineItemMap = (Map<id, Apttus_Config2__LineItem__c>) oldItems;

        //Map to List Conversion
        List<Apttus_Config2__LineItem__c> NewLineItemList = NewLineItemMap.values();

        // Method used to validate the Asset Quanity is Greater than the New Buy Quantity of Line Item
        LineItemHelper_v1.validateAssetQuantity(NewLineItemMap, OldLineItemMap);

        //Method Used to Check Custom Validations for the Line Type = renewal
        LineItemHelper_v1.RenewalValidation(NewLineItemList, OldLineItemMap);

        //Method Used to check Non Interger Quantity for Line Item specific for PPM (Professional Service Items) 
        LineItemHelper_v1.validateQtydata(NewLineItemList, OldLineItemMap);

        //Method Used to check if the Line Sequence / Bill to Address / Quantity of Line Item is changed
        LineItemHelper_v1.LineSequenceLogicAndBillToChanged(NewLineItemMap, OldLineItemMap);

        if (!RecursiveTriggerUtility.stopLineItemTrigger_ApprovalRequestListener)
        {
            RecursiveTriggerUtility.recursiveCallLineItemTrigger = true;
            LineItemHelper_v1.configLineItem(NewLineItemMap, OldLineItemMap);
        }

        //Method to execute all Line Item updates on before Update Event
        LineItemHelper_v1.LineItemBeforeUpdateMethods(NewLineItemMap, oldLineItemMap);

        /*
        // Method to Restrict Discount/PriceOverride for specific item(s)
        LineItemHelper_v1.RestrictDiscounts_PriceOverride(NewLineItemList, OldLineItemMap);
        */
    }

    /* Method will be Invoked from Line Item Trigger to handle Logics on Before Delete Scenario
      Parent Class: ITriggerHandler
      Invoking Trigger : LineItemTrigger_V1 
    */
    public void BeforeDelete(Map<Id, SObject> oldItems) {

        //Map Typecasting
        Map<id, Apttus_Config2__LineItem__c> OldLineItemMap = (Map<id, Apttus_Config2__LineItem__c>) oldItems;

        LineItemHelper_v1.DeleteLineitemMethod(oldLineItemMap);
    }

    public void AfterInsert(Map<Id, SObject> newItems) { }

    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) { }

    public void AfterDelete(Map<Id, SObject> oldItems) { }

    public void AfterUndelete(Map<Id, SObject> oldItems) { }
}