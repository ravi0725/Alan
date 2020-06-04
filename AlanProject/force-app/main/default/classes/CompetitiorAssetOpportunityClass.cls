/************************************************************************************
* Name          :    CompetitiorAssetOpportunityClass
* Description   :    Used to display custom CompetitiorAsset related list on Opportunity.
* Author        :    Sagar Mehta

Modification Log
------------------------------------------------------------------------------------------
Date             Developer                Comments
------------------------------------------------------------------------------------------
02/18/2014       Sagar Mehta              Created  
******************************************************************************************/
public class CompetitiorAssetOpportunityClass{    
    
    public Integer totalSize{get;set;}
    public Integer remainder{get;set;}
    
    public boolean addError{get;set;}    
    public boolean loadMore{get;set;}
    public boolean statusFlag{get;set;}
    
    public String optyId{get;set;}
    public String opptyId{get;set;}
    public String assetId{get;set;}
    public String companyid{get;set;}
    public String productId{get;set;}
    public String productIds{get;set;}
    public String compassetid{get;set;}
    public string accountname{get;set;}
    public String compassetdelid{get;set;}
    
    public List<SelectOption> productoption{get;set;}       
    public List<SelectOption> Currencyoptions {get;set;}
    public List<clsLeadWrapper> competitorAssetsList{get;set;}
    
    public Competitor_Owned_Assets__c assets{get;set;}
    public Competitor_Assets_Junction__c assetJunction{get;set;}
    
    public CompetitiorAssetOpportunityClass(){
        addError = true;
        assets = new Competitor_Owned_Assets__c();
        //opportunityMap = new Map<Id, String>();
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
    
    public CompetitiorAssetOpportunityClass(ApexPages.StandardController controller){
        remainder = 0;      
        loadMore = false;
        //gets the record Id of the opportunity record.
        optyId = (String)controller.getRecord().Id;
    }
    
   /**
     *Return Type: getRelatedCompetitorAsset
     *Return Type: List<Competitor_Owned_Assets__c>
     *Purpose: This method used to get the first 10 comp assets related to an opportunity record.
     *It is also used to rerender the list when the user clicks on link Show (n) more >> in UI.
     **/ 
    public List<Competitor_Assets_Junction__c> getRelatedCompetitorAsset(){
        List<Competitor_Assets_Junction__c> CompAssetList = new List<Competitor_Assets_Junction__c>();
        try{
          //query all the opportunity records matching for the account record.
          CompAssetList = [SELECT Id, Competitor_Assets__r.Name, Competitor_Assets__r.Product__r.Name, Competitor_Assets__r.Competitor_Company__c, 
          Competitor_Assets__r.Competitor_Company__r.Name, Competitor_Assets__r.Number_of_Licenses__c, Competitor_Assets__r.Product_Version__c, 
          Competitor_Assets__r.Yearly_Subscription_Cost__c, Competitor_Assets__r.Install_Date__c, Competitor_Assets__r.Expiration_Date__c 
          FROM Competitor_Assets_Junction__c where Opportunity__c =: optyId order by Competitor_Assets__r.Product__r.Name];                                                                                     
        }catch(Exception e){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING, e.getMessage());
            ApexPages.addMessage(msg);
        }                    
        return CompAssetList;        
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
           opptyId = ApexPages.currentPage().getParameters().get('id');
           List<Opportunity> opptylist = new List<Opportunity>();
           opptylist  =[select Id, AccountId from Opportunity where Id =: opptyId];           
           if(opptylist.size() > 0)
              assetJunction.Account__c = opptylist.get(0).AccountId;  
           assetJunction.Opportunity__c = opptyId;                   
       }else{
          addError = false;
          ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.No_Records_Found);
          ApexPages.addMessage(msg);
       }
    }           
    
    /**
     *Return Type: getCompetitorAssetList
     *Return Type: List<Competitor_Owned_Assets__c>
     *Purpose: This method used to get all the comp assets related to an opportunity record.     
     **/ 
    public List<Competitor_Owned_Assets__c> getCompetitorAssetList(){       
        List<Competitor_Owned_Assets__c> CompAssetList = new List<Competitor_Owned_Assets__c>();
        try{
          //null check for Id
          if(Apexpages.currentpage().getparameters().get('id') != null){
             String oId = Apexpages.currentpage().getparameters().get('id');
             CompAssetList = [SELECT Id,Product__r.Name, Competitor_Company__c, Number_of_Licenses__c, Product_Version__c, 
                              Yearly_Subscription_Cost__c, Install_Date__c, Expiration_Date__c, Opportunity__c FROM Competitor_Owned_Assets__c
                              where Opportunity__c =: oId order by Product__r.Name];                                                                                
          }
        }catch(Exception e){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING, e.getMessage());
            ApexPages.addMessage(msg);
        }                 
        return CompAssetList;        
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
           opptyid = ApexPages.currentPage().getParameters().get('aId');          
           List<Competitor_Owned_Assets__c> assetList = new List<Competitor_Owned_Assets__c>();
           //query all the opportunity records matching for the account record.
           assetList = [SELECT Id, Name, Product__r.Name, Competitor_Company__c, Competitor_Company__r.Name, Number_of_Licenses__c, Product_Family__c, 
                        Lead__c, Product_Version__c, Account__c, Yearly_Subscription_Cost__c, Install_Date__c, Expiration_Date__c FROM Competitor_Owned_Assets__c                          
                        where Id =: assetId order by Product__r.Name];            
           if(assetList.size() > 0){
              assets = assetList.get(0);
              productIds = assets.Product__c;                                                     
              assetJunction.Opportunity__c = opptyid;
              List<Opportunity> opptylist = new List<Opportunity>();
              opptylist  =[select Id, AccountId from Opportunity where Id =: opptyid];     
              if(opptylist.size() > 0)
                 assetJunction.Account__c = opptylist.get(0).AccountId;           
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
      return new PageReference('/'+opptyid);
    }
    
    public PageReference deleteCompetitorAsset(){
       List<Competitor_Assets_Junction__c> cajList = new List<Competitor_Assets_Junction__c>();
       cajList = [Select Id from Competitor_Assets_Junction__c where Competitor_Assets__c =: assetId and Opportunity__c =: opptyId];
       delete cajList;
       return new PageReference('/'+opptyId);
    }
   
    public PageReference redirectToNew(){
       PageReference pr = Page.CompAssetsOptyPage;
       pr.getParameters().put('id', optyId);
       return pr;
    }
   
    public void loadAddCompetitorAsset(){
       List<Competitor_Assets_Junction__c> compassetlist = new List<Competitor_Assets_Junction__c>();
       List<Competitor_Assets_Junction__c> cajNewList = new List<Competitor_Assets_Junction__c>();
       competitorAssetsList = new List<clsLeadWrapper>();   
       if(System.currentPageReference().getParameters().get('id') != null){
          optyId = System.currentPageReference().getParameters().get('id');    
          List<Opportunity> opptylist = new List<Opportunity>();
          opptylist  =[select Id, Accountid,Account.Name from Opportunity where Id =: optyId];
          accountname = opptylist.get(0).Account.Name;
          if(opptylist.size() > 0){
             compassetlist = [Select Id, Opportunity__c, Account__c, Competitor_Assets__c, Competitor_Assets__r.Name, 
             Competitor_Assets__r.Competitor_Company__r.Name, Competitor_Assets__r.Number_of_Licenses__c, 
             Competitor_Assets__r.Product_Version__c, Competitor_Assets__r.Yearly_Subscription_Cost__c, Competitor_Assets__r.Install_Date__c, 
             Competitor_Assets__r.Expiration_Date__c from Competitor_Assets_Junction__c where Account__c =: opptylist.get(0).Accountid];
             
             Map<Id, Competitor_Assets_Junction__c> compMap = new Map<Id, Competitor_Assets_Junction__c>();
             for(Competitor_Assets_Junction__c caj : compassetlist){
               compMap.put(caj.Competitor_Assets__c, caj);
             } 
             if(compMap.size() > 0)
               cajNewList = compMap.values();
             
             for(Competitor_Assets_Junction__c compAsset : cajNewList){
               clsLeadWrapper wrapper = new clsLeadWrapper();
               wrapper.isSelected = false;
               wrapper.asset = compAsset;
               competitorAssetsList.add(wrapper); 
             } 
          }else{
             ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, Label.No_Records_Found);
             ApexPages.addMessage(msg);    
          }  
       }else{
          ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, Label.No_Records_Found);
          ApexPages.addMessage(msg);
       }
    }
   
    public class clsLeadWrapper{
      public boolean isSelected{get;set;}
      public Competitor_Assets_Junction__c asset{get;set;}
    }
   
    public PageReference updatecompetitor(){
      try{
          boolean flag = true;                 
          List<Competitor_Assets_Junction__c> compownassetList = new List<Competitor_Assets_Junction__c>();
          List<Competitor_Assets_Junction__c> updateassetList = new List<Competitor_Assets_Junction__c>();
          Competitor_Assets_Junction__c junc;
          for(clsLeadWrapper wrap : competitorAssetsList){
             if(wrap.isSelected){
               flag = false;           
               if(wrap.asset.Opportunity__c == null){
                 junc = wrap.asset; 
                 junc.Opportunity__c = optyId;
                 updateassetList.add(junc);  
               }else{
                 junc = new Competitor_Assets_Junction__c();
                 junc.Opportunity__c = optyId;
                 junc.Account__c = wrap.asset.Account__c;
                 junc.Competitor_Assets__c = wrap.asset.Competitor_Assets__c;
                 compownassetList.add(junc);
               }                                             
             }            
          }
          if(flag){
              ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Mandatory_Comp_Assets);
              ApexPages.addMessage(msg);
              return null;
          }
          if(updateassetList.size() > 0)
             update updateassetList;    
                
          if(compownassetList.size() > 0)
             insert compownassetList;    
      }catch(Exception e){
         ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
         ApexPages.addMessage(msg);
         return null;
      }   
      return new PageReference('/'+optyid);
    }  
    
    public pagereference pageredirect(){    
       PageReference reference=new PageReference('/apex/CompAssetsOptyPage?id='+optyid+'&ret=1');
       reference.setRedirect(true);
       return reference;    
    }                   
    
    public PageReference cancel(){
       return new PageReference('/'+optyid);
    }
   
    public PageReference cancelPage(){
       return new PageReference('/'+opptyid);
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
      return new PageReference('/'+opptyId);
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
       for(Product_competitor__c  pc: [Select Id, Name From Product_Competitor__c where Competitor_Account__c =: companyid]){
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
       pList = [Select Id, Product_Family__c From Product_Competitor__c where Id =: productId];
       if(pList.size() > 0){
         Product_competitor__c  pc = pList.get(0);
         assets.Product_Family__c = pc.Product_Family__c;
       }else{
         assets.Product_Family__c = '';
       }                   
    }
}