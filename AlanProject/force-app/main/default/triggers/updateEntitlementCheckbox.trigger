/*****************************************************************************************
    Name    : updateEntitlementCheckbox 
    Desc    :This trigger used for updating the entitlement and account related to the particular entitlement if product sub type changed
                            
    Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Chandrakant       2/21/2013          Created
******************************************************************************************/
trigger updateEntitlementCheckbox on Product2 (after update) {
     List<id> productid= new list<id>();
     String prodsub ;
     
     for (Product2 pro : trigger.new){
         Product2 oldproduct= Trigger.oldMap.get(pro.id);
         if(oldproduct.sub_type__c != pro.sub_type__c){
         productid.add(pro.id);
         prodsub = oldproduct.sub_type__c;
         }
       }
     if(trigger.isupdate && productid.size()>0){       
     EntitlementproductHelper.processEntitlementsproduct(productid,prodsub);   
     }    
}