/*****************************************************************************************
    Name    : DealRegLineItems_PartnerUserController 
    Desc    : 
                            
Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Ashfaq Mohammed       4/27/2013          Created
******************************************************************************************/
public with sharing class DealRegLineItems_PartnerUserController {

    public integer quantity { get; set; }
    public boolean updatedealline{get;set;}
    public id dealId{get;set;}
    public id deallineId{get;set;}
    public Deal_Registration__c dealReg{get;set;}
    public Deal_Registration_Line__c dealRegLine{get;set;}    
    public Deal_Registration_Line__c drl;
    public  Map<Id,string> mapPrdIdUnitPrice;
    public integer UnitPrice{get;set;}
    
    public List<Product2> results{get;set;} // search results
    public string searchString{get;set;} // search keyword
    List<PricebookEntry> priceBookList = new List<PricebookEntry>();
   
    public DealRegLineItems_PartnerUserController(){
        dealId = ApexPages.currentPage().getParameters().get('id');   
        system.debug('dealId - > ' + dealId);
        deallineId =  ApexPages.currentPage().getParameters().get('lineid'); 
        system.debug('deallineId - > ' + deallineId);
        updatedealline = false;
        dealRegLine = new Deal_Registration_Line__c();
        if(dealid !=null){
            dealReg = [Select id,Name from Deal_registration__c where id=: dealId];
        }
        if(deallineId !=null){
            dealRegLine = [SELECT Deal_Registration__c,Id,Name,Part_Number__c, Standard_Dealer_Discount__c , Product__c,Discount__c,Product_Authorization__c,Quantity__c,Total_Price__c,Unit_Price__c FROM Deal_Registration_Line__c where id=:deallineId ];
            dealReg = [Select id,Name from Deal_registration__c where id=: dealRegLine.Deal_Registration__c];
            quantity = integer.valueof(dealRegLine.Quantity__c);
            UnitPrice = integer.valueof(dealRegLine.Unit_Price__c);
            updatedealline = true;
        }       
        system.debug('dealReg - > ' + dealReg);
        system.debug('dealRegLine - > ' + dealRegLine);
        priceBookList  = new List<PricebookEntry>();
        PriceBook2 pbe2 = new PriceBook2();
        pbe2 = [Select id,name from PriceBook2 where name='GCCM Price Book' limit 1];
        priceBookList  = [Select id,Product2Id,unitprice from PricebookEntry where Pricebook2Id =: pbe2.Id ];
        mapPrdIdUnitPrice = new Map<Id,string>();
        if(!priceBookList.isEmpty()){
            for( PricebookEntry pbe : priceBookList ){            
                mapPrdIdUnitPrice.put(pbe.Product2Id,string.valueof(pbe.UnitPrice));
            }
        }
    }    
    
    public PageReference Save() {
        boolean flag = false;
        if(dealRegLine.Product__c == null){
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Product is a required field.'));
        	flag = true;
        }
        /*if(dealRegLine.Part_Number__c == null){
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Part Number is a required field.'));
        	flag = true;
        }*/
    	if(!dealRegLine.Product_Authorization__c){
        	if(quantity == 0){
        		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Quantity is a required field.'));
        		flag = true;
        	}
        	
        	if(dealregline.discount__c == 0.00){
        		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Discount is a required field.'));
        		flag = true; 
        	}
        	
        	if(dealregline.unit_price__c == 0.00){
        		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unit Price is a required field.'));
        		flag = true;
        	}
        }
        if(flag){
        	return null;
        } 
        if(dealId !=null){
          try{	
            drl = new Deal_Registration_Line__c();   
            //drl.Product__c = product;
            system.debug('dealRegLine.Product__c - > ' + dealRegLine.Product__c);
            system.debug('mapPrdIdUnitPrice - > ' + mapPrdIdUnitPrice);
                        
            drl.Discount__c = dealregline.discount__c;
            drl.Quantity__c = quantity;
            drl.Part_Number__c = dealRegLine.Part_Number__c;
            drl.Unit_Price__c = dealregline.unit_price__c;
            drl.Product_Authorization__c = dealRegLine.Product_Authorization__c;
            drl.Product__c = dealRegLine.Product__c;
            drl.Standard_Dealer_Discount__c = dealRegLine.Standard_Dealer_Discount__c;
            drl.Deal_Registration__c = dealId;
            insert drl;
          }catch(Exception e){
          	 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
          	 return null;
          }  
          return new pagereference ('/'+ dealId);
        }else{
			dealRegLine.Discount__c = dealregline.discount__c;
            dealRegLine.Quantity__c = quantity ;
            dealRegLine.Part_Number__c = dealRegLine.Part_Number__c;
                //dealRegLine.Unit_Price__c = Decimal.valueof(mapPrdIdUnitPrice.get(dealRegLine.Product__c));
            dealRegLine.Unit_Price__c = dealregline.unit_price__c;            	
            dealRegLine.Product_Authorization__c = dealRegLine.Product_Authorization__c;
            dealRegLine.Product__c = dealRegLine.Product__c;
            update dealRegLine;
            return new pagereference ('/'+ dealRegLine.id);
        }                
    }
    
    public pagereference cancel(){
        if(dealId != null)
            return new pagereference ('/'+ dealId);
        else{
            return new pagereference ('/'+ deallineId );
        }
    }
    
    public PageReference deleteRegLineItem(){
        if(ApexPages.currentPage().getParameters().get('lineid') != null){
             String dealRegLineId = ApexPages.currentPage().getParameters().get('lineid');
             String dealRegId;
             List<Deal_Registration_Line__c> dealRegLineList = new List<Deal_Registration_Line__c>();
             dealRegLineList = [Select Id, Deal_Registration__c from Deal_Registration_Line__c where Id =: dealRegLineId];
             if(dealRegLineList.size() > 0){
             	dealRegId = dealRegLineList.get(0).Deal_Registration__c;
        		delete dealRegLineList;      	
        		return new pagereference ('/'+ dealRegId);
             }else{
             	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No records found'));
          	    return null;
             }
        }
        return null;     
    }

}