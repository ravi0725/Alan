/*****************************************************************************************
    Name    : DealRegProductLineController 
    Desc    : 
                            
Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Sagar Mehta       4/27/2013          Created
******************************************************************************************/
public class DealRegProductLineController{
      
   public List<Deal_Registration_Line__c> dealRegLineList{get;set;}
   public String dealRegId{get;set;}
   public String dealRegStatus{get;set;}
   public DealRegProductLineController(ApexPages.StandardController controller) {   
       Deal_Registration__c dealReg = (Deal_Registration__c)controller.getRecord();
       dealRegLineList = new List<Deal_Registration_Line__c>();
       dealRegStatus = '';
       if(dealReg != null){
          dealRegId = dealReg.Id;
          Deal_Registration__c deal = [Select Id, Approval_Status__c from Deal_Registration__c where Id =: dealRegId];
          dealRegStatus = deal.Approval_Status__c; 
          dealRegLineList = [Select Id, Name, Customer_Adjusted_Extended_Price__c, Customer_Unit_Price__c, Discount__c, Dealer_Adjusted_Extended_Price__c, 
                             Sale_Price_Per_Unit__c, Deal_Registration__c, Total_Price__c, Unit_Price__c, Product__c, Product__r.Name, Product__r.ProductCode, Product_Authorization__c,
                             Quantity__c, Standard_Dealer_Discount__c, Standard_Dealer_Extended_Price__c, Standard_Dealer_Unit_Price__c from Deal_Registration_Line__c 
                             where Deal_Registration__c =: dealReg.Id];
       }else{
          //error msg
       }
   }
    
   public PageReference newDealRegLineItem(){
      PageReference pageRef = Page.DealRegLineItems_PartnerUser;
      pageRef.getParameters().put('id', dealRegId);    
      return pageRef;
   }         
}