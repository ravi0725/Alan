/*****************************************************************************************
    Name    :     CompetitorAssetsAccountController 
    Desc    :     Used for implementing cusotm visualforce page logic for competitor assets related list on Account and Lead.  
                  The new button in Competitor Assets related list on Account and lead is overridden here and the functionality is implemented in this class                
    Project ITEM: ITEM-00703, ITEM-00779                            
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Sagar Mehta           10/27/2013          Created
******************************************************************************************/
public class MultipleAssetsAndCasesController{
    
    public Id caseId{get;set;}
    public String caseName{get;set;}
    public Multiple_Assets_Case_Junction__c assets{get;set;}
    public List<SelectOption> Currencyoptions {get;set;}    
    Map<String, boolean> currencyMap = new Map<String, boolean>();
    public List<SelectOption> assetOptions {get;set;}   
    
    /**
     * Method name  : CompetitorAssetsAccountController
     * Description  : Constructor of the Controller class - Initializes all the variables.
     *                Populates appropriate data like currencies, products.
     * Return Type  : Void
     * Parameter    : StandardController
     **/    
   public MultipleAssetsAndCasesController(ApexPages.StandardSetController controller){
       String accountId;
       caseId = ApexPages.currentPage().getParameters().get('id');
       List<Case> caseList = new List<Case>();
       caseList = [Select Id, CaseNumber, AccountId from Case where Id =: caseId];
       if(caseList.size() > 0){
           caseName = caseList.get(0).CaseNumber;
           accountId = caseList.get(0).AccountId;
       }
       assets = new Multiple_Assets_Case_Junction__c();
       Currencyoptions = new List<SelectOption>();
       assets.Case__c = caseId;
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
       
       List<Asset> assetList = new List<Asset>();
       assetOptions = new List<SelectOption>();
       assetList = [Select Id, Name from Asset where AccountId =: accountId];
       for(Asset a : assetList){
           assetOptions.add(new SelectOption(a.Id, a.Name));
       }       
   }
   
   /**
     * Method name  : newAssets
     * Description  : This method is used to insert new Competitor Assets record related to a Account     
     * Return Type  : PageReference
     * Parameter    : 
     **/
   public PageReference newAssets(){
      try{         
         insert assets;
      }catch(Exception e){
         System.debug(e.getMessage());
      }
      return new PageReference('/'+caseId);
   }
   
   /**
     * Method name  : cancel
     * Description  : This method is used to redirect the page from competitorAssetsAcount page back to account record     
     * Return Type  : PageReference
     * Parameter    : 
     **/
   public PageReference cancel(){
       return new PageReference('/'+caseId);
   }
}