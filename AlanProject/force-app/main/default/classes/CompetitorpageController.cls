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
public class CompetitorpageController{
   
   public Competitor__c comp{get;set;}
   public Id opportunityId;
   public List<SelectOption> Currencyoptions {get;set;}
   public String companyid{get;set;}
   public String productId{get;set;}
   public String productIds{get;set;}
   public List<SelectOption> productoption {get;set;}
   Map<String, boolean> currencyMap = new Map<String, boolean>();
   
   /**
     * Method name  : CompetitorpageController
     * Description  : Constructor of the Controller class - Initializes all the variables.
     *                Populates appropriate data like currencies, products.
     * Return Type  : Void
     * Parameter    : StandardController
     **/    
   public CompetitorpageController(ApexPages.StandardSetController controller){
       comp = new Competitor__c();       
       opportunityId = ApexPages.currentPage().getParameters().get('id');
       comp.Opportunity__c = opportunityId ;
       Currencyoptions = new List<SelectOption>();
      
       /**List<CurrencyType> currencyList = [Select IsoCode, IsActive, Id From CurrencyType];
       
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
        }**/
   }
   
   /**
     * Method name  : newCompetitor
     * Description  : This method is used to insert new Competitor Assets record related to a Account     
     * Return Type  : PageReference
     * Parameter    : 
     **/
   public PageReference newCompetitor(){
      try{
         if(productIds == 'None'){
           ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Product_Assets_Mandatory); 
           ApexPages.addMessage(msg); 
           return null;
         } 
         comp.Competitor_Product__c = productIds;
         insert comp;
      }catch(Exception e){
         System.debug(e.getMessage());
      }
      return new PageReference('/'+opportunityId);
   }
   
   /**
     * Method name  : cancel
     * Description  : This method is used to redirect the page from competitorAssetsAcount page back to account record     
     * Return Type  : PageReference
     * Parameter    : 
     **/
   public PageReference cancel(){
       return new PageReference('/'+opportunityId);
   }
   
   /**
     * Method name  : populateproduct
     * Description  : This method is used to populate products in Products picklist based on the competitor selected by user in Competitor Account lookp field     
     * Return Type  : void
     * Parameter    : 
     **/
   public void populateproduct(){
      productoption = new List<SelectOption>();
      productoption.add(new selectoption('None','---Select--'));
      for(Product_competitor__c  pc: [Select Id,name From Product_competitor__c where Competitor_Account__c =: companyid]){
          productoption.add(new SelectOption(pc.id, pc.name));
      }
   }
   
   /**
     * Method name  : populateProductFamily
     * Description  : This method is used to populate product family based on the product selected by user in Product picklist field.     
     * Return Type  : void
     * Parameter    : 
     **/
   public void populateProductFamily(){ 
     /**  List<Product_competitor__c> pList = new List<Product_competitor__c>();
       pList = [Select Id, Product_Family__c From Product_competitor__c where Id =: productId];
       if(pList.size() > 0){
         Product_competitor__c  pc = pList.get(0);
         assets.Product_Family__c = pc.Product_Family__c;
       }else{
         assets.Product_Family__c = '';
       }   **/                
   }
}