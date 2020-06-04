/*****************************************************************************************
    Name    : EntitlementHelper
    Desc    : This class we are using to update the entitlement record as well as account record
                            
    Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Ashfaq Mohammed       4/22/2014          Created

******************************************************************************************/
global class EntitlementproductHelper{   
    
    global EntitlementproductHelper(){
       
    }        
    
    @future
    public static void processEntitlementsproduct(List<Id> productid,String prodsub ){
     List<Entitlement> Entitlementlist=new List<Entitlement>();
     set<Id> acctids =new set<id>();
     List<Account> acctlist=new List<Account>();
     Map<String,Entitlement> entidrecord=new Map<string,Entitlement>();
     try{
     Entitlementlist =[select id,accountid from Entitlement where Entitlement_Product__c IN:productid or Asset.Product2Id IN:productid];
       for(Entitlement ent:Entitlementlist){
          acctids.add(ent.accountid); 
          entidrecord.put(ent.id,ent);
       }
       //update Entitlementlist;
       acctlist =[select id,IES__c,Hardware__c,CAD_Software__c,Business_Software__c,Tekla__c from account where id IN:acctids];
      //Checking for the old sub type of current product and making it blank in account record
       for(Account acct:acctlist){
         if(prodsub == Label.CAD_Software && acct.CAD_Software__c != null){
           acct.CAD_Software__c ='';
         }
         if(prodsub == Label.Business_Software && acct.Business_Software__c != null){
           acct.Business_Software__c ='';
         }
         if(prodsub == Label.Tekla && acct.Tekla__c != null){
           acct.Tekla__c  ='';
         }
         if(prodsub == Label.Hardware && acct.Hardware__c != null){
           acct.Hardware__c ='';
         }
         if(prodsub == Label.IES_Software && acct.IES__c != null){
           acct.IES__c ='';
         }
       }          
      //Updating acctlist and entitlementlist
       update acctlist;
       update Entitlementlist;
     }catch(Exception e){
        System.debug(e.getMessage());
     }
   }  
}