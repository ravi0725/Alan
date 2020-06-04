public with sharing class LineitemtemplateController
{

    public LineitemtemplateController(ApexPages.StandardController controller) {

    }

    public String Curr{get;set;}
    public Id configurationId{get;set;}
    public List<Apttus_Config2__LineItem__c> Lineitemlist{get;set;}
    
    public LineitemtemplateController(){
    }  
    
    public List<Apttus_Config2__LineItem__c> getLineitemlst(){
        Lineitemlist = new List<Apttus_Config2__LineItem__c>();
        Lineitemlist  = [Select Id, Product_or_Option_name__c,Apttus_Config2__ChargeType__c,Apttus_Config2__Quantity__c,Apttus_Config2__ListPrice__c,Apttus_Config2__ExtendedPrice__c,
                         New_Net_Discount__c,Apttus_Config2__NetPrice__c,Apttus_Config2__EndDate__c,CurrencyIsoCode from Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c =: configurationId];
        Curr =Lineitemlist.get(0).CurrencyIsoCode ;  
        return Lineitemlist ;
        
    }
    
    
    
}