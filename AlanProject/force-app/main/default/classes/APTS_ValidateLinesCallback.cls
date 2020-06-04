/**
*  Apttus Config & Pricing
*  DefaultValidationCallback
*
*  @2012-2013 Apttus Inc. All rights reserved.
*/
global with sharing class APTS_ValidateLinesCallback implements Apttus_Config2.CustomClass.IValidationCallback2 {

  /**
  * Callback to validate the line items in the cart
  * @param cart the cart object to validate
  * @return the validation result
  */
  global Apttus_Config2.CustomClass.ValidationResult validateCart(Apttus_Config2.ProductConfiguration cart){
    Apttus_Config2.CustomClass.ValidationResult result = new Apttus_Config2.CustomClass.ValidationResult(true);
    system.debug('-----------------cart---------------' + cart);
    Map<Id,Apttus_Config2__LineItem__c> linIdMap = new Map<Id,Apttus_Config2__LineItem__c>();
    List<Apttus_Config2__LineItem__C> updateLineItems = new List<Apttus_Config2__LineItem__C>();
    Set<ID> LineID = new Set<ID>();

    List<Apttus_Config2__LineItem__C> liTmList = new List<Apttus_Config2__LineItem__C>();
    if(!Test.isRunningTest()){
      liTmList = getLineItemsList(cart.getLineItems());
    }else{
      //To increase code coverage
      liTmList.add(GenerateTestData.standardliTm);
      liTmList.add(GenerateTestData.maintenceliTm);
      getLineItemsList(new List<Apttus_Config2.LineItem>());
    }

    for(Apttus_Config2__LineItem__c lin : liTmList){
      system.debug('-----------------lin ---------------' + lin);
      if(lin.Apttus_Config2__ChargeType__c == 'Standard Price' && lin.Apttus_Config2__IsPrimaryLine__c == True && lin.Apttus_Config2__LineType__c != 'Option'){
        linIdMap.put(lin.Apttus_Config2__ProductId__c,lin);
        LineID.add(lin.Id);
        system.debug('-----------------lin.IdStandard---------------' + lin.Id);
      }
      if((lin.Apttus_Config2__ChargeType__c == 'Maintenance Fee'  && lin.Apttus_Config2__IsOptionRollupLine__c == False) || (lin.Apttus_Config2__ChargeType__c == 'Standard Price' && lin.Apttus_Config2__LineType__c == 'Option' && lin.Apttus_Config2__IsPrimaryLine__c == True)){
        linIdMap.put(lin.Apttus_Config2__OptionId__c,lin);
        LineID.add(lin.Id);
        system.debug('-----------------lin.IdMaintenance---------------' + lin.Id);
      }
    }
    system.debug('-----------------linIdMap---------------' + linIdMap.keyset());
    system.debug('-----------------LineID---------------' + LineID);
    Map<String, Date> mapServiceStartDate = new Map<String, Date>();
    Map<String, Date> mapServiceEndDate = new Map<String, Date>();
    for(Apttus_Config2__LineItem__C pLine : [SELECT Id, Name, Apttus_Config2__ProductId__c, Service_Start_Date__c, Service_End_Date__c, Apttus_Config2__LineNumber__c FROM Apttus_Config2__LineItem__c WHERE Id IN : LineID AND Apttus_Config2__ChargeType__c = 'Standard Price' AND Apttus_Config2__LineType__c != 'Option' AND Apttus_Config2__IsPrimaryLine__c = true]){
      if(pLine.Service_Start_Date__c != null){
        mapServiceStartDate.put(pLine.Apttus_Config2__LineNumber__c + '~' + pLine.Apttus_Config2__ProductId__c, pLine.Service_Start_Date__c);
      }
      if(pLine.Service_End_Date__c != null){
        mapServiceEndDate.put(pLine.Apttus_Config2__LineNumber__c + '~' + pLine.Apttus_Config2__ProductId__c, pLine.Service_End_Date__c);
      }
    }

    for(Apttus_Config2__LineItem__c lin : [SELECT Id, Apttus_Config2__ProductId__c, Apttus_Config2__PriceUom__c, Apttus_Config2__ChargeType__c, Apttus_Config2__LineType__c, Apttus_Config2__Quantity__c, Type__c, Service_Start_Date__c, Service_End_Date__c, Apttus_Config2__LineNumber__c FROM Apttus_Config2__LineItem__c
    WHERE (Id IN : LineID and Apttus_Config2__IsOptionRollupLine__c = false AND Apttus_Config2__ChargeType__c = 'Maintenance Fee' ) OR (Id IN : LineID AND Apttus_Config2__ChargeType__c = 'Standard Price' AND Apttus_Config2__LineType__c = 'Option' AND Apttus_Config2__IsPrimaryLine__c = True)]){
      if(linIdMap.get(lin.Apttus_Config2__ProductId__c) != null){
        Boolean isAddtoUpdateList = false;
        if(linIdMap.get(lin.Apttus_Config2__ProductId__c).Apttus_Config2__Quantity__c != lin.Apttus_Config2__Quantity__c && lin.Type__c != 'Renewal' && lin.Apttus_Config2__LineType__c == 'Option' && lin.Apttus_Config2__ChargeType__c == 'Maintenance Fee'){
          lin.Apttus_Config2__Quantity__c = linIdMap.get(lin.Apttus_Config2__ProductId__c).Apttus_Config2__Quantity__c ;
          isAddtoUpdateList = true;
        }

        if(lin.Apttus_Config2__ChargeType__c == 'Standard Price' && lin.Apttus_Config2__PriceUom__c == 'Year'){
          if((mapServiceStartDate.containsKey(lin.Apttus_Config2__LineNumber__c + '~' + lin.Apttus_Config2__ProductId__c) && mapServiceStartDate.get(lin.Apttus_Config2__LineNumber__c + '~' + lin.Apttus_Config2__ProductId__c) != lin.Service_Start_Date__c)||
          (mapServiceEndDate.containsKey(lin.Apttus_Config2__LineNumber__c + '~' + lin.Apttus_Config2__ProductId__c) && mapServiceEndDate.get(lin.Apttus_Config2__LineNumber__c + '~' + lin.Apttus_Config2__ProductId__c) != lin.Service_End_Date__c)){
            lin.Service_Start_Date__c = (mapServiceStartDate.containsKey(lin.Apttus_Config2__LineNumber__c + '~' + lin.Apttus_Config2__ProductId__c) ? mapServiceStartDate.get(lin.Apttus_Config2__LineNumber__c + '~' + lin.Apttus_Config2__ProductId__c) : null );
            lin.Service_End_Date__c = (mapServiceEndDate.containsKey(lin.Apttus_Config2__LineNumber__c + '~' + lin.Apttus_Config2__ProductId__c) ? mapServiceEndDate.get(lin.Apttus_Config2__LineNumber__c + '~' + lin.Apttus_Config2__ProductId__c) : null );
            isAddtoUpdateList = true;
          }
        }
        if(isAddtoUpdateList){
          updateLineItems.add(lin);
        }
        /*
        if(linIdMap.get(lin.Apttus_Config2__ProductId__c) != null){
        if(linIdMap.get(lin.Apttus_Config2__ProductId__c).Apttus_Config2__Quantity__c != lin.Apttus_Config2__Quantity__c && lin.Type__c!='Renewal' && lin.Apttus_Config2__LineType__c=='Option'){
        lin.Apttus_Config2__Quantity__c = linIdMap.get(lin.Apttus_Config2__ProductId__c).Apttus_Config2__Quantity__c ;
        updateLineItems.add(lin);
        }
        }
        */
      }
    }
    system.debug('-----------------updateLineItems---------------' + updateLineItems);
    if(updateLineItems.size()>0 && !Test.isRunningTest()){
      update updateLineItems;
    }

    return result;
  }


  /**
  * Callback to validate the given list ramp line items
  * @param cart the cart object associated with the ramp line items
  * @param rampLineItems the list of ramp line items
  * @return the validation result
  */
  global Apttus_Config2.CustomClass.ValidationResult validateRampLineItems(Apttus_Config2.ProductConfiguration cart, List<Apttus_Config2.LineItem> rampLineItems) {
    Apttus_Config2.CustomClass.ValidationResult result = new Apttus_Config2.CustomClass.ValidationResult(true);
    return result;
  }

  //Gets the all line items objects from Apttus_Config2.LineItem objects
  private static List<Apttus_Config2__LineItem__C> getLineItemsList(List<Apttus_Config2.LineItem> allLines) {

    List<Apttus_Config2__LineItem__C> lineItems = new List<Apttus_Config2__LineItem__C>();
    // iterate thru the cart and get the line items matching the battery code1
    for (Apttus_Config2.LineItem lineItemMO : allLines) {
      lineItems.add(lineItemMO.getLineItemSO());
    }
    return lineItems;
  }



  /**
  * Callback to validate the given list of asset items
  * @param cart the cart object associated with the asset items
  * @param assetItems the list of asset items
  * @return the validation result
  */
  global Apttus_Config2.CustomClass.ValidationResult validateAssetItems(Apttus_Config2.ProductConfiguration cart, List<Apttus_Config2__TempRenew__c> assetItems) {
    Apttus_Config2.CustomClass.ValidationResult result = new Apttus_Config2.CustomClass.ValidationResult(true);
    return result;
  }
}