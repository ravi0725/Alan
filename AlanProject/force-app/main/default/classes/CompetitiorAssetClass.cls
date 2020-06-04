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
public class CompetitiorAssetClass{
    public Id accountId{get;set;}
    
    public boolean oppFlag{get;set;}    
    public boolean addError{get;set;}
    public boolean loadMore{get;set;}

    public Integer totalSize{get;set;}    
    public Integer remainder{get;set;}    
    
    public String accId{get;set;}    
    public String assetId{get;set;}
    public String companyid{get;set;}
    public String productId{get;set;}
    public String productIds{get;set;}
    public String compassetid{get;set;}
    public String compassetdelid{get;set;} 
    
    public List<Competitor_Assets_Junction__c> opportunityList{get;set;}
    public List<SelectOption> productoption {get;set;}       
    public List<SelectOption> Currencyoptions {get;set;}
    
    public Competitor_Owned_Assets__c assets{get;set;}
    public Competitor_Assets_Junction__c assetJunction{get;set;}
    
    public CompetitiorAssetClass(){
        addError = true;
        assets = new Competitor_Owned_Assets__c();
        opportunityList = new List<Competitor_Assets_Junction__c>();
        assetJunction = new Competitor_Assets_Junction__c();
        Currencyoptions = new List<SelectOption>();
        Map<String, boolean> currencyMap = new Map<String, boolean>();      
        List<CurrencyType> currencyList = [Select IsoCode, IsActive, Id From CurrencyType];       
        for(CurrencyType curr : currencyList){
          currencyMap.put(curr.IsoCode, curr.IsActive);
        }        
        //Fetch all currency data using Currency Fielddescription 
        Schema.DescribeFieldResult CurrencyFieldDescription = CurrencyType.IsoCode.getDescribe();
        for(Schema.Picklistentry picklistEntry:CurrencyFieldDescription.getPicklistValues()){
          if(currencyMap.keyset().contains(pickListEntry.getValue()) && currencyMap.get(pickListEntry.getValue())){
             Currencyoptions.add(new SelectOption(pickListEntry.getValue(),pickListEntry.getLabel()));
          } 
          assets.CurrencyIsoCode = UserInfo.getDefaultCurrency();
        }
    }
    
    public CompetitiorAssetClass(ApexPages.StandardController controller){
        remainder = 0;      
        loadMore = false;
        //gets the record Id of the account record.
        accId = (String)controller.getRecord().Id;
    }
    
   /**
     *Return Type: getRelatedCompetitorAsset
     *Return Type: List<Competitor_Assets_Junction__c>
     *Purpose: This method used to get the first 10 opportunities related to an account record.
     *It is also used to rerender the list when the user clicks on link Show (n) more >> in UI.
     **/ 
    public List<Competitor_Assets_Junction__c> getRelatedCompetitorAsset(){
        List<Competitor_Assets_Junction__c> cajList = new List<Competitor_Assets_Junction__c>();
        List<Competitor_Assets_Junction__c> cajNewList = new List<Competitor_Assets_Junction__c>();
        try{
           //query all the opportunity records matching for the account record.           
           cajList = [Select Id, Competitor_Assets__c, Competitor_Assets__r.Name, Competitor_Assets__r.Product__r.Name, 
           Competitor_Assets__r.Competitor_Company__c, Competitor_Assets__r.Competitor_Company__r.Name, Competitor_Assets__r.Number_of_Licenses__c, 
           Competitor_Assets__r.Product_Version__c, Competitor_Assets__r.Yearly_Subscription_Cost__c, Competitor_Assets__r.Install_Date__c,
           Competitor_Assets__r.Expiration_Date__c from Competitor_Assets_Junction__c where Account__c =: accId order by Competitor_Assets__r.Product__r.Name];                
           
           Map<Id, Competitor_Assets_Junction__c> compMap = new Map<Id, Competitor_Assets_Junction__c>();
           for(Competitor_Assets_Junction__c caj : cajList){
              compMap.put(caj.Competitor_Assets__c, caj);
           }
           if(compMap.size() > 0)
              cajNewList = compMap.values();
        }catch(Exception e){
           ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING, e.getMessage());
           ApexPages.addMessage(msg);
        }                    
        return cajNewList;                
    }                
    
    /**
     * Method name  : loadCompetitorAsset
     * Description  : This method is used to populate products in Products picklist based on the competitor selected by user in Competitor Account lookp field     
     * Return Type  : void
     * Parameter    : 
     **/
    public void loadCompetitorAsset(){
       assetJunction = new Competitor_Assets_Junction__c();       
       if(ApexPages.currentPage().getParameters().get('id') != null){
           accountId = ApexPages.currentPage().getParameters().get('id');           
           assetJunction.Account__c = accountId;                   
       }else{
          addError = false;
          ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.No_Records_Found);
          ApexPages.addMessage(msg);
       }
    }           
    
    /**
     * Method name  : editCompAsset
     * Description  : This method is used to populate products in Products picklist based on the competitor selected by user in Competitor Account lookp field     
     * Return Type  : void
     * Parameter    : 
     **/
    public void editCompAsset(){
       if(ApexPages.currentPage().getParameters().get('id') != null && ApexPages.currentPage().getParameters().get('aId') != null){
           assetId = ApexPages.currentPage().getParameters().get('id');
           accountId = ApexPages.currentPage().getParameters().get('aId');          
           List<Competitor_Owned_Assets__c> assetList = new List<Competitor_Owned_Assets__c>();
           //query all the opportunity records matching for the account record.
           assetList = [SELECT Id, Name, Product__r.Name, Competitor_Company__c, Competitor_Company__r.Name, Number_of_Licenses__c, Product_Family__c, 
                        Lead__c, Product_Version__c, Account__c, Yearly_Subscription_Cost__c, Install_Date__c, Expiration_Date__c  FROM Competitor_Owned_Assets__c                          
                        where Id =: assetId order by Product__r.Name];            
           if(assetList.size() > 0){
              assets = assetList.get(0);
              productIds = assets.Product__c;                         
              List<Competitor_Assets_Junction__c> cajList = new List<Competitor_Assets_Junction__c>();
              cajList = [Select Id, Account__c, Opportunity__c, Opportunity__r.Name, Competitor_Assets__c from Competitor_Assets_Junction__c where Competitor_Assets__c =: assetId and Account__c =: accountId];
              for(Competitor_Assets_Junction__c caj : cajList){
                 opportunityList.add(caj);
              }             
              if(opportunityList.size() > 0){
                 oppFlag = true;
              }else{
                 oppFlag = false;
              }              
              assetJunction.Account__c = accountId;                   
              productoption = new List<SelectOption>();
              productoption.add(new selectoption('','---Select--'));
              for(Product_competitor__c  pc: [Select Id,name From Product_competitor__c where Competitor_Account__c =: assets.Competitor_Company__c]){
                productoption.add(new SelectOption(pc.id, pc.name));
              }
           }else{
              addError = false;
              ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.No_Records_Found);
              ApexPages.addMessage(msg);
           }   
       }else{
          addError = false;
          ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.No_Records_Found);
          ApexPages.addMessage(msg);
       }
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
       for(Product_competitor__c  pc: [Select Id, Name From Product_competitor__c where Competitor_Account__c =: companyid]){
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
       List<Product_competitor__c> pList = new List<Product_competitor__c>();
       pList = [Select Id, Product_Family__c From Product_competitor__c where Id =: productId];
       if(pList.size() > 0){
         Product_competitor__c  pc = pList.get(0);
         assets.Product_Family__c = pc.Product_Family__c;
       }else{
         assets.Product_Family__c = '';
       }                   
    }
    
    /**
     * Method name  : cancel
     * Description  : This method is used to redirect the page from competitorAssetsAcount page back to account record     
     * Return Type  : PageReference
     * Parameter    : 
     **/
    public PageReference cancel(){
       return new PageReference('/'+accountId);
    }
    
    /**
     * Method name  : newAssets
     * Description  : This method is used to insert new Competitor Assets record related to a Account     
     * Return Type  : PageReference
     * Parameter    : 
     **/
    public PageReference newAssets(){
      try{
         if(productIds == 'None'){
           ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Product_Assets_Mandatory); 
           ApexPages.addMessage(msg); 
           return null;
         }           
         assets.Product__c = productIds;
         insert assets;
         
         assetJunction.Competitor_Assets__c = assets.Id;
         insert assetJunction;
      }catch(Exception e){
         System.debug(e.getMessage());
      }
      return new PageReference('/'+accountId);
    }
    
    /**
     * Method name  : newAssets
     * Description  : This method is used to insert new Competitor Assets record related to a Account     
     * Return Type  : PageReference
     * Parameter    : 
     **/
    public PageReference updateAssets(){
      if(productId == ''){
          ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Product_Assets_Mandatory);
          ApexPages.addMessage(msg); 
          return null;
      }      
      try{
         assets.Product__c = productIds;
         update assets;
      }catch(Exception e){
         ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, Label.Unexpected_Error);
         ApexPages.addMessage(msg); 
         return null;
      }
      return new PageReference('/'+accountId);
    }
    
    /**
     * Method name  : deleteCompetitorAsset
     * Description  : This method is used to delete Competitor Assets record related to a Account     
     * Return Type  : PageReference
     * Parameter    : 
     **/
     public PageReference deleteCompetitorAsset(){
       try{
          List<Competitor_Owned_Assets__c> deletecompassetlist = new List<Competitor_Owned_Assets__c>();
          deletecompassetlist =[select id from Competitor_Owned_Assets__c where Id =: assetId];
          List<Competitor_Assets_Junction__c> cajList = new List<Competitor_Assets_Junction__c>();
          cajList = [Select Id, Account__c from Competitor_Assets_Junction__c where Competitor_Assets__c =: assetId and Account__c =: accountId];
          delete cajList;
          delete deletecompassetlist;          
       }catch(Exception e){
          ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, Label.Unexpected_Error);
          ApexPages.addMessage(msg); 
          return null;
       } 
       return new PageReference('/'+accountId);       
    }
    
    public class clsCompeAsset{
       public Id juntionId{get;set;}
       public Competitor_Owned_Assets__c asset{get;set;}
    }
}