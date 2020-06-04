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
public class EditCompetitorClass{
   
   public Competitor__c comp{get;set;}
   public Id opportunityId;
   public Id compId;
   public List<SelectOption> Currencyoptions {get;set;}
   public String companyid{get;set;}
   public String productId{get;set;}
   public String productIds{get;set;}
   public List<SelectOption> productoption {get;set;}
   Map<String, boolean> currencyMap = new Map<String, boolean>();
   
   /**
     * Method name  : CompetitorAssetsAccountController
     * Description  : Constructor of the Controller class - Initializes all the variables.
     *                Populates appropriate data like currencies, products.
     * Return Type  : Void
     * Parameter    : StandardController
     **/    
   public EditCompetitorClass(ApexPages.StandardSetController controller){
       comp = new Competitor__c();       
       //opportunityId = ApexPages.currentPage().getParameters().get('id');
       compId = Apexpages.currentpage().getparameters().get('id');
       //comp.Opportunity__c = opportunityId ;
       Currencyoptions = new List<SelectOption>();
       List<Competitor__c> complist=new List<Competitor__c>();
       complist =[select Comments__c,CompetitorName__c,Competitor_Product__c,Competitor_Type__c,Opportunity__c,Strengths__c,Weaknesses__c from Competitor__c where id =:compId];
       if(complist.size()>0){
        comp = complist.get(0);
        opportunityId =comp.Opportunity__c;
       }
       productIds = comp.Competitor_Product__c;
       productoption = new List<SelectOption>();
       productoption.add(new selectoption('','---Select--'));
       for(Product_competitor__c  pc: [Select Id,name From Product_competitor__c where Competitor_Account__c =: comp.CompetitorName__c]){
           productoption.add(new SelectOption(pc.id, pc.name));
       }
   }
   
   /**
     * Method name  : newAssets
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
         //assets.Product__c = productIds;
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
   
      /**
     * Method name  : newAssets
     * Description  : This method is used to insert new Competitor Assets record related to a Account     
     * Return Type  : PageReference
     * Parameter    : 
     **/
   public PageReference updateCompetitor(){
      if(productId == ''){
          ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Product_Assets_Mandatory);
          ApexPages.addMessage(msg); 
          return null;
      }
      try{
         comp.Competitor_Product__c = productIds;
         update comp;
      }catch(Exception e){
         ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, Label.Unexpected_Error);
         ApexPages.addMessage(msg); 
         return null;
      }
      return new PageReference('/'+comp.opportunity__c);
   }
}