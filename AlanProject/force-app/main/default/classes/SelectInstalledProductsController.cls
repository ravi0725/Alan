/*****************************************************************************************
    Name         : SelectInstalledProductsController
    Desc         : Used for displaying Asset Line Item record related to a account of a quote record.
    Project Item : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Sagar Mehta           01/29/2014          Created
******************************************************************************************/
public class SelectInstalledProductsController{
    
    public String configId;
    public String accountId;
    public String selectedAsset{get;set;}
    public List<Apttus_Config2__AssetLineItem__c> lineItemList{get;set;}
    
    /**
     * Class Constructor 
     * @param stdController the standard controller
     */
     public SelectInstalledProductsController(){
        
        //not null check for Id
        if(ApexPages.CurrentPage().getParameters().get('id') == null){
           ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.No_Records_Found);
           ApexPages.addMessage(msg); 
           return;  
        }
        accountId = 'test';
        configId = ApexPages.CurrentPage().getParameters().get('id');
        lineItemList = new List<Apttus_Config2__AssetLineItem__c>();
            
        List<Apttus_Config2__ProductConfiguration__c> configList = new List<Apttus_Config2__ProductConfiguration__c>();
        configList = [Select Id, Name, Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__c from Apttus_Config2__ProductConfiguration__c  where Id =: configId];   
        
        if(configList.size() > 0){                     
           accountId = configList.get(0).Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__c;
           if(accountId != 'test'){
              /*lineItemList = [Select Id, Name, Apttus_Config2__ProductId__r.Name, Apttus_Config2__Quantity__c, Apttus_Config2__AllowedActions__c, 
                              Apttus_Config2__LocationId__r.Name, Apttus_Config2__ChargeType__c, Apttus_Config2__SellingTerm__c, 
                              Apttus_Config2__SellingFrequency__c, Apttus_Config2__StartDate__c, Apttus_Config2__EndDate__c, 
                              Apttus_Config2__NetPrice__c, Apttus_Config2__AssetStatus__c from Apttus_Config2__AssetLineItem__c 
                              where Apttus_Config2__AccountId__c =: accountId];*/                                                     
           }                    
        }        
        
     }
     
     public List<SelectOption> getAssetOption(){
     	List<SelectOption> assetList = new List<SelectOption>();
     	List<Apttus_Config2__AssetLineItem__c> accountAssetList = new List<Apttus_Config2__AssetLineItem__c>();
     	assetList.add(new SelectOption('None', '--None--'));
     	if(accountId != 'test'){
     	   accountAssetList = [Select Id, Name from Apttus_Config2__AssetLineItem__c where Apttus_Config2__AccountId__c =: accountId];
     	   for(Apttus_Config2__AssetLineItem__c asset : accountAssetList){
     	   	  assetList.add(new SelectOption(asset.Id, asset.Name));	   	
     	   }
     	}	
     	return assetList;  	
     }
}