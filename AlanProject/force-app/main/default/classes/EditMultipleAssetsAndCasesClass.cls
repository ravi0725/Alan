/************************************************************************************
* Name          :    CompetitiorAssetClass
* Description   :    to display custom CompetitiorAsset related list
* Author        :    Chandrakant

Modification Log
----------------
Date             Developer                Comments
------------------------------------------------------------------------------------------
                   Chandrakant      Created  07/1/2014
******************************************************************************************/
public class EditMultipleAssetsAndCasesClass{
    
    public String accountId;
    public Id caseId{get;set;}
    public String assetId{get;set;}
    public Multiple_Assets_Case_Junction__c assets{get;set;}
    public List<SelectOption> Currencyoptions{get;set;}
    Map<String, boolean> currencyMap = new Map<String, boolean>();
    public List<SelectOption> assetOptions {get;set;}
    
    public EditMultipleAssetsAndCasesClass(){ 
       
       if(Apexpages.currentpage().getparameters().get('id') != null){
          assetId = Apexpages.currentpage().getparameters().get('id');
       }
       List<Multiple_Assets_Case_Junction__c> competitorAssetList = new List<Multiple_Assets_Case_Junction__c>();
       competitorAssetList = [SELECT Id, Name, Case__c, Case__r.AccountId, Case__r.CaseNumber, Account__r.Name, Asset__r.Name FROM Multiple_Assets_Case_Junction__c where Id =: assetId]; 
       if(competitorAssetList.size() <= 0){
          ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING, Label.No_Records_Found);
          ApexPages.addMessage(msg);             
       }
       if(competitorAssetList.size() > 0){
          assets = competitorAssetList.get(0); 
         caseId = competitorAssetList.get(0).Case__c;       
          accountId = assets.Case__r.AccountId;          
          Currencyoptions = new List<SelectOption>();
      
          List<CurrencyType> currencyList = [Select IsoCode, IsActive, Id From CurrencyType];
        
          for(CurrencyType curr : currencyList){
             currencyMap.put(curr.IsoCode, curr.IsActive);
          }
       
          //Fetch all currency data using Currency Fielddescription 
          Schema.DescribeFieldResult CurrencyFieldDescription = CurrencyType.IsoCode.getDescribe();
          for (Schema.Picklistentry picklistEntry:CurrencyFieldDescription.getPicklistValues()){
            if(currencyMap.keyset().contains(pickListEntry.getValue()) && currencyMap.get(pickListEntry.getValue())){
              Currencyoptions.add(new SelectOption(pickListEntry.getValue(),pickListEntry.getLabel()));
            } 
            assets.CurrencyIsoCode = UserInfo.getDefaultCurrency();
          }
       }
       
       List<Asset> assetList = new List<Asset>();
       assetOptions = new List<SelectOption>();
       assetList = [Select Id, Name from Asset where AccountId =: accountId];
       for(Asset a : assetList){
           assetOptions.add(new SelectOption(a.Id, a.Name));
       }
    }
    
    /**
     * Method name  : cancel
     * Description  : This method is used to redirect the page from competitorAssetsAcount page back to account record     
     * Return Type  : PageReference
     * Parameter    : 
     **/
   public PageReference cancel(){
       return new PageReference('/'+assets.Case__c);
   }  
   
   /**
     * Method name  : newAssets
     * Description  : This method is used to insert new Competitor Assets record related to a Account     
     * Return Type  : PageReference
     * Parameter    : 
     **/
   public PageReference updateAssets(){      
      try{
         update assets;
      }catch(Exception e){
         ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, Label.Unexpected_Error);
         ApexPages.addMessage(msg); 
         return null;
      }
      return new PageReference('/'+assets.Case__c);
   }    
}