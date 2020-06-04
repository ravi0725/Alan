trigger DealRegLineTrigger on Deal_Registration_Line__c (after insert) {
    String familyName, hdName = 'test', sfName = 'test';
    
    String dealRegId = Trigger.new[0].Deal_Registration__c;
    List<Deal_Registration_Line__c> dealRegLineList = new List<Deal_Registration_Line__c>();
    dealRegLineList = [Select Id, Product__c from Deal_Registration_Line__c where Deal_Registration__c =: dealRegId];

    List<Id> productIDList = new List<Id>();
    for(Deal_Registration_Line__c line : dealRegLineList){
       productIDList.add(line.Product__c);         
    }
    
    List<Product2> productList = new List<Product2>();
    productList = [Select Id, Family from Product2 where Id IN: productIDList];
    
    Map<Id, String> productMap = new Map<Id, String>();
    for(Product2 product : productList){
       productMap.put(product.Id, product.Family);
    }
     
    for(Deal_Registration_Line__c line : dealRegLineList){
       if(productMap.get(line.Product__c) == 'Hardware'){
          hdName = 'Hardware';
       }else if(productMap.get(line.Product__c) == 'Software'){
          sfName = 'Software';
       } 
       //dealRegId = line.Deal_Registration__c;                       
    }
    if(hdName == 'Hardware'){
       familyName = 'Hardware';
    }
    if(sfName == 'Software'){ 
       familyName = 'Software';
    }
    if(hdName == 'Hardware' && sfName == 'Software'){
       familyName = 'Both';
    }
    
    Deal_Registration__c deal = [Select Id, Family_Name__c from Deal_Registration__c where Id =: dealRegId];
    deal.Family_Name__c = familyName;
    update deal;    
}