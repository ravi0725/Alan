/*****************************************************************************************
    Name        : AddressChangePopupController
    Desc        : Used for Brining Popup when Address is changed and Configure Product is clicked
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
 Prince Leo           19/01/2016          Created
******************************************************************************************/
public class AddressChangePopupController{
    public String quoteId{get;set;}
    public String oppid;
    public string flowUI;
     public AddressChangePopupController(){
     quoteId= System.currentPageReference().getParameters().get('id');
     flowUI = System.currentPageReference().getParameters().get('flow'); 
     }
     
      Public Pagereference ChangeAddress(){
     List<Apttus_Config2__ProductConfiguration__c> ProductConfig = new List<Apttus_Config2__ProductConfiguration__c>([select id from Apttus_Config2__ProductConfiguration__c where (Apttus_Config2__Status__c ='New' or Apttus_Config2__Status__c ='Saved') and Apttus_QPConfig__Proposald__c =:quoteId Limit 1]);
     List<Apttus_Config2__ProductConfiguration__c> ProductConfigFinalize = new List<Apttus_Config2__ProductConfiguration__c>([select id from Apttus_Config2__ProductConfiguration__c where (Apttus_Config2__Status__c ='Finalized') and Apttus_QPConfig__Proposald__c =:quoteId ORDER BY Apttus_Config2__VersionNumber__c DESC Limit 1]);
     
     List<Apttus_Proposal__Proposal__c> Proposallist= new List<Apttus_Proposal__Proposal__c>();
     List<Apttus_Config2__LineItem__c> LineList = new List<Apttus_Config2__LineItem__c>();
     List<Apttus_Config2__LineItem__c> LineListFin = new List<Apttus_Config2__LineItem__c>();
     List<Apttus_Config2__LineItem__c> UpLineList = new List<Apttus_Config2__LineItem__c>();
     if(ProductConfig.size()>0){
     LineList = [select id,Bill_To_Address__c,Ship_To_Address1__c from Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c =:ProductConfig.get(0).id];
     Proposallist = [Select Address_Changed__c,Ship_to_Address1__c,Bill_to_Address__c from Apttus_Proposal__Proposal__c where id =:quoteId];
     
     Proposallist.get(0).Address_Changed__c = False;
     update Proposallist.get(0);
     
     system.debug('>>>>>>>>>>ProductConfig.get(0).id>>>>>'+ProductConfig.get(0).id);
     system.debug('>>>>>>>>>>Proposallist.get(0).Bill_to_Address__c>>>>>'+Proposallist.get(0).Bill_to_Address__c);
     system.debug('>>>>>>>>>>Proposallist.get(0).Ship_to_Address1__c>>>>>'+Proposallist.get(0).Ship_to_Address1__c);
     for(Apttus_Config2__LineItem__c Li : LineList)
     {
      if(Proposallist.get(0).Bill_to_Address__c!= NUll) Li.Bill_To_Address__c = Proposallist.get(0).Bill_to_Address__c;
      if(Proposallist.get(0).Ship_to_Address1__c!= NUll) Li.Ship_To_Address1__c = Proposallist.get(0).Ship_to_Address1__c;
      UpLineList.add(Li);
     }
     
     if(UpLineList.size()>0) {
        LineItemHelper.launchControl.put('validateAssetQuantity',1);
        LineItemHelper.launchControl.put('configLineItem',1);
        LineItemHelper.LineItemList = null;
        RecursiveTriggerUtility.recursiveCallLineItemTrigger = true;
     update UpLineList;
     }
     }
     else if(ProductConfigFinalize.size()>0)
     {
     LineListFin = [select id,Bill_To_Address__c,Ship_To_Address1__c from Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c =:ProductConfigFinalize.get(0).id];
     Proposallist = [Select Address_Changed__c,Ship_to_Address1__c,Bill_to_Address__c from Apttus_Proposal__Proposal__c where id =:quoteId];
     
     Proposallist.get(0).Address_Changed__c = False;
     update Proposallist.get(0);
     
     system.debug('>>>>>>>>>>ProductConfigFinalize.get(0).id>>>>>'+ProductConfigFinalize.get(0).id);
     system.debug('>>>>>>>>>>Proposallist.get(0).Bill_to_Address__c>>>>>'+Proposallist.get(0).Bill_to_Address__c);
     system.debug('>>>>>>>>>>Proposallist.get(0).Ship_to_Address1__c>>>>>'+Proposallist.get(0).Ship_to_Address1__c);
     for(Apttus_Config2__LineItem__c Li : LineListFin)
     {
      if(Proposallist.get(0).Bill_to_Address__c!= NUll) Li.Bill_To_Address__c = Proposallist.get(0).Bill_to_Address__c;
      if(Proposallist.get(0).Ship_to_Address1__c!= NUll) Li.Ship_To_Address1__c = Proposallist.get(0).Ship_to_Address1__c;
      UpLineList.add(Li);
     }
     
     if(UpLineList.size()>0) {
        LineItemHelper.launchControl.put('validateAssetQuantity',1);
        LineItemHelper.launchControl.put('configLineItem',1);
        LineItemHelper.LineItemList = null;
        RecursiveTriggerUtility.recursiveCallLineItemTrigger = true;
     update UpLineList;
     }
     }
     
     PageReference pageprop;
     pageprop = new PageReference('/apex/CustomConfigProductPage?id='+quoteId+'&flow='+flowUI);
     pageprop.setRedirect(true);
     return pageprop;
     }
     
     Public Pagereference SkipChange(){
     List<Apttus_Proposal__Proposal__c> Proposallist= new List<Apttus_Proposal__Proposal__c>();
     Proposallist = [Select Address_Changed__c,Apttus_Proposal__Opportunity__r.Bill_to_Address__c,Apttus_Proposal__Opportunity__r.Ship_to_Address1__c,Apttus_Proposal__Opportunity__r.Bill_To_Account__c,Apttus_Proposal__Opportunity__r.Ship_To_Account__c,
                     Bill_to_Address__c,Ship_to_Address1__c from Apttus_Proposal__Proposal__c where id =:quoteId]; 
     
     Proposallist.get(0).Bill_to_Address__c = Proposallist.get(0).Apttus_Proposal__Opportunity__r.Bill_to_Address__c;
     //Proposallist.get(0).Ship_to_Address1__c  = Proposallist.get(0).Apttus_Proposal__Opportunity__r.Ship_to_Address1__c;
     Proposallist.get(0).Apttus_QPConfig__BillToAccountId__c = Proposallist.get(0).Apttus_Proposal__Opportunity__r.Bill_To_Account__c;
     //Proposallist.get(0).Ship_To_Account__c = Proposallist.get(0).Apttus_Proposal__Opportunity__r.Ship_To_Account__c;
     Proposallist.get(0).Address_Changed__c = False;
     update Proposallist.get(0);
     
     PageReference pageprop;
     pageprop = new PageReference('/apex/CustomConfigProductPage?id='+quoteId+'&flow='+flowUI);
     pageprop.setRedirect(true);
     return pageprop;
     }
    }