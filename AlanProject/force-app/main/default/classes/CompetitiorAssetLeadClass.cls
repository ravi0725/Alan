/************************************************************************************
* Name          :    CompetitiorAssetLeadClass
* Description   :    to display custom CompetitiorAsset related list
* Author        :    Chandrakant

Modification Log
----------------
Date             Developer                Comments
------------------------------------------------------------------------------------------
                   Chandrakant      Created  07/1/2014
******************************************************************************************/
public class CompetitiorAssetLeadClass{        
    
    public Id leadId{get;set;}
    
    public boolean oppFlag{get;set;}
    public boolean addError{get;set;}    
    public boolean loadMore{get;set;}
    
    public String accId{get;set;}
    public String assetId{get;set;}
    public String companyid{get;set;}
    public String productId{get;set;}
    public String productIds{get;set;}
    public String compassetid{get;set;}
    public String compassetdelid{get;set;}
    
    public Integer totalSize{get;set;}
    public Integer remainder{get;set;}
    
    public Map<Id, String> opportunityMap{get;set;}
    public List<SelectOption> productoption{get;set;}       
    public List<SelectOption> Currencyoptions {get;set;}
    
    public Competitor_Owned_Assets__c assets{get;set;}
    public Competitor_Assets_Junction__c assetJunction{get;set;}
    
    public CompetitiorAssetLeadClass(){
        addError = true;
        assets = new Competitor_Owned_Assets__c();
        opportunityMap = new Map<Id, String>();
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
        
    /**
     * Method name  : CompetitiorAssetLeadClass
     * Description  : Constructor of the Controller class - Initializes all the variables.
     *                Populates forecast quarter data into forecast list
     * Return Type  : Void
     * Parameter    : StandardController
     **/
    public CompetitiorAssetLeadClass(ApexPages.StandardController controller){
        remainder = 0;      
        loadMore = false;
        //gets the record Id of the account record.
        accId = (String)controller.getRecord().Id;
    }
    
   /**
     *Return Type: getRelatedOpportunities
     *Return Type: List<Competitor_Assets_Junction__c>
     *Purpose: This method used to get the competitor assets related to a lead record.
     *
     **/ 
    public List<Competitor_Assets_Junction__c> getRelatedCompetitorAsset(){
        List<Competitor_Assets_Junction__c> CompAssetList = new List<Competitor_Assets_Junction__c>();
        try{
          //query all the competitor assets records matching for the lead record.
          CompAssetList = [SELECT Id, Competitor_Assets__r.Name, Competitor_Assets__r.Product__r.Name, Competitor_Assets__r.Competitor_Company__c, 
          Competitor_Assets__r.Competitor_Company__r.Name, Competitor_Assets__r.Number_of_Licenses__c, Competitor_Assets__r.Product_Version__c, 
          Competitor_Assets__r.Yearly_Subscription_Cost__c, Competitor_Assets__r.Install_Date__c, Competitor_Assets__r.Expiration_Date__c, 
          Lead__c FROM Competitor_Assets_Junction__c where Lead__c =: accId order by Competitor_Assets__r.Product__r.Name];                                                                                          
        }catch(Exception e){
           ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING, e.getMessage());
           ApexPages.addMessage(msg);
        }                    
        return CompAssetList;         
    }
    
    /**
     *Return Type: loadMoreOpportunities
     *Return Type: void
     *Purpose: This method is called from the visual force page to load more opportunities related to an account record.     
     **/
    public void loadMoreCompAssets(){
       getRelatedCompetitorAsset();
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
           leadId = ApexPages.currentPage().getParameters().get('id');           
           assetJunction.Lead__c = leadId;                   
       }else{
          addError = false;
          ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.No_Records_Found);
          ApexPages.addMessage(msg);
       }
    }           
    
    /**
     *Return Type: getOpportunityList
     *Return Type: List<Opportunity>
     *Purpose: This method used to get all the opportunities related to an account record.     
     **/ 
    public List<Competitor_Owned_Assets__c> getCompetitorAssetList(){       
        List<Competitor_Owned_Assets__c> CompAssetList = new List<Competitor_Owned_Assets__c>();
        try{
          //null check for account Id
          if(Apexpages.currentpage().getparameters().get('id') != null){
             accId = Apexpages.currentpage().getparameters().get('id');
             CompAssetList = [SELECT Id,Product__r.Name, Competitor_Company__c, Number_of_Licenses__c, Product_Version__c, 
                              Yearly_Subscription_Cost__c, Install_Date__c, Expiration_Date__c, Lead__c  FROM Competitor_Owned_Assets__c
                              where Lead__c=: accId order by Product__r.Name];                                                                                
          }
        }catch(Exception e){
          ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING, e.getMessage());
            ApexPages.addMessage(msg);
        }                 
        return CompAssetList;        
    }
    
    public PageReference EditCompetitorAsset(){
       return new PageReference('/apex/EditCompetitorAssetsLeadsPage?id='+compassetid);
    }
    
    public PageReference deleteCompetitorAsset(){       
       List<Competitor_Owned_Assets__c> deletecompassetlist = new List<Competitor_Owned_Assets__c>();
       deletecompassetlist = [select Id from Competitor_Owned_Assets__c where Id =: assetId];

       List<Competitor_Assets_Junction__c> cajList = new List<Competitor_Assets_Junction__c>();
       cajList = [Select Id from Competitor_Assets_Junction__c where Competitor_Assets__c =: assetId and Lead__c =: leadId];
       delete cajList;       
          
       delete deletecompassetlist;
       return new PageReference('/'+leadid);
   }
   
   public PageReference redirectToNew(){
       PageReference pr = Page.competitorAssetsAccountPage;
       pr.getParameters().put('id', accId);
       return pr;
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
     * Description  : This method is used to redirect the page from competitorAssetsLead page back to lead record     
     * Return Type  : PageReference
     * Parameter    : 
     **/
    public PageReference cancel(){
       return new PageReference('/'+leadId);
    }
    
     /**
     * Method name  : newAssets
     * Description  : This method is used to insert new Competitor Assets record related to a Lead     
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
      return new PageReference('/'+leadId);
    }
    
    /**
     * Method name  : editCompAsset
     * Description  : This method is used to populate products in Products picklist based on the 
     *                competitor selected by user in Competitor Account lookp field     
     * Return Type  : void
     * Parameter    : 
     **/
    public void editCompAsset(){
       if(ApexPages.currentPage().getParameters().get('id') != null && ApexPages.currentPage().getParameters().get('aId') != null){
           assetId = ApexPages.currentPage().getParameters().get('id');
           leadId = ApexPages.currentPage().getParameters().get('aId');          
           List<Competitor_Owned_Assets__c> assetList = new List<Competitor_Owned_Assets__c>();
           //query all the opportunity records matching for the account record.
           assetList = [SELECT Id, Name, Product__r.Name, Competitor_Company__c, Competitor_Company__r.Name, Number_of_Licenses__c, Product_Family__c, 
                        Lead__c, Product_Version__c, Account__c, Yearly_Subscription_Cost__c, Install_Date__c, Expiration_Date__c  FROM Competitor_Owned_Assets__c                          
                        where Id =: assetId order by Product__r.Name];            
           if(assetList.size() > 0){
              assets = assetList.get(0);
              productIds = assets.Product__c;                                                     
              assetJunction.Lead__c = leadId;             
              productoption = new List<SelectOption>();
              productoption.add(new selectoption('','---Select--'));
              for(Product_competitor__c  pc: [Select Id, Name From Product_Competitor__c where Competitor_Account__c =: assets.Competitor_Company__c]){
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
      return new PageReference('/'+leadId);
    }
}