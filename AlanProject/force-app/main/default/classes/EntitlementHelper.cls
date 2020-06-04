global class EntitlementHelper{   
    
    global EntitlementHelper(){
       
    }        
    
    @future
    public static void processEntitlements(Set<Id> entitlementSet){
       try{
           Set<Id> accountIdSet = new Set<Id>();         
           Map<Id, Entitlement> entitlementMap = new Map<Id, Entitlement>();
           entitlementMap = new Map<Id, Entitlement>([Select Id, AccountId from Entitlement where Id IN: entitlementSet]);
           List<Entitlement> entList = new List<Entitlement>();
           entList = entitlementMap.values();
           
           for(Entitlement ent : entList){
              accountIdSet.add(ent.AccountId); 
           }
         
           Set<String> cadValues;
           Set<String> IESValues;
           Set<String> Assetidset;
           Set<String> teklaValues;
           Set<String> businessValues;
           Set<String> hardwareValues;
           Set<String> productfamilycheck = new Set<String>();
           Set<String> productTypeSet = new Set<String>{Label.Hotline, Label.Update, Label.Update_Hotline};
           Set<String> productFamilySet = new Set<String>{Label.CAD_Software, Label.Business_Software, Label.Hardware, Label.Tekla, Label.IES};
              
           List<Account> acctlist = new List<Account>();                 
         
           //query all the account records alongwith its associated Entitlement records.       
              
           for(Account account : [Select Id,Name, CAD_Software__c, Business_Software__c, Hardware__c, Tekla__c, 
                                     (Select Id, Status, Product_Family__c, Type,Type_MEP__c,supported_Product_Family_Roll_up__c,Entitlement_Product__c,
                                     AssetId,EntitlementActive__c,Asset_Effectivity__c from Entitlements where Type_MEP__c IN: productTypeSet AND 
                                     supported_Product_Family_Roll_up__c IN: productFamilySet AND EntitlementActive__c =: true) from Account where 
                                     Id IN: accountIdSet]){     
               cadValues = new Set<String>();
               businessValues = new Set<String>();
               hardwareValues = new Set<String>();
               teklaValues = new Set<String>();
               IESValues = new Set<String>();
               
               //loop through the  related entitlement of account
               system.debug('****account.Entitlements: '+account.Entitlements.size());
               for(Entitlement ent : account.Entitlements){  
                  /** check for CAD Software, if the Product Family belongs to CAD Software, 
                    * and Type Mep field is Update, Hotline, or Update and Hotline, 
                    * then account's CAD Software should contain those corresponding values
                    */                     
                  if(ent.supported_Product_Family_Roll_up__c == Label.CAD_Software){                     
                     if(ent.Type_MEP__c == Label.Update_Hotline){
                        cadValues.add(Label.Update);
                        cadValues.add(Label.Hotline);    
                     }else{                 
                        cadValues.add(ent.Type_MEP__c );                                                        
                     }                                                       
                  }
                  /** check for CAD Software, if the Product Family belongs to Business Software, 
                    * and Type Mep field is Update, Hotline, or Update and Hotline, 
                    * then account's Business Software should contain those corresponding values
                    */
                  if(ent.supported_Product_Family_Roll_up__c == Label.Business_Software){ 
                    if(ent.Type_MEP__c  == Label.Update_Hotline){
                        businessValues.add(Label.Update);
                        businessValues.add(Label.Hotline);    
                     }else{                 
                        businessValues.add(ent.Type_MEP__c );                                                       
                     }                                                         
                  }
                  /** check for CAD Software, if the Product Family belongs to Hardware, 
                    * and Type Mep field is Update, Hotline, or Update and Hotline, 
                    * then account's Hardware should contain those corresponding values
                    */
                  if(ent.supported_Product_Family_Roll_up__c == Label.Hardware){ 
                    if(ent.Type_MEP__c == Label.Update_Hotline){
                        hardwareValues.add(Label.Update);
                        hardwareValues.add(Label.Hotline);    
                    }else{                  
                        hardwareValues.add(ent.Type_MEP__c );                                                       
                    }                                              
                  }
                  /** check for CAD Software, if the Product Family belongs to Tekla, 
                    * and Type Mep field is Update, Hotline, or Update and Hotline, 
                    * then account's Tekla should contain those corresponding values
                    */
                  if(ent.supported_Product_Family_Roll_up__c == Label.Tekla){             
                    if(ent.Type_MEP__c == Label.Update_Hotline){
                        teklaValues.add(Label.Update);
                        teklaValues.add(Label.Hotline);    
                    }else{                  
                        teklaValues.add(ent.Type_MEP__c ); 
                    }                                    
                  }
                  /** check for CAD Software, if the Product Family belongs to IES, 
                    * and Type Mep field is Update, Hotline, or Update and Hotline, 
                    * then account's IES should contain those corresponding values
                    */ 
                  if(ent.supported_Product_Family_Roll_up__c == Label.IES){ 
                    if(ent.Type_MEP__c == Label.Update_Hotline){
                        IESValues.add(Label.Update);
                        IESValues.add(Label.Hotline);    
                    }else{                  
                        IESValues.add(ent.Type_MEP__c );                                                      
                    }                                    
                  } 
               }
               //Seperate the set values with ; seperated, to accomodate these values in a multi-select picklist
               String cads, bss, hdc, tkl,ie; 
               for(String cad : cadValues){
                  if(cads == null){
                     cads = cad;
                  }else{
                    cads += ';'+cad;
                  }
               }
               for(String bs : businessValues){
                  if(bss == null){
                     bss = bs;
                  }else{
                     bss += ';'+bs;
                  }
               }
               for(String hw : hardwareValues){
                  if(hdc == null){
                     hdc = hw;
                  }else{
                     hdc += ';'+hw;
                  }
               }
               for(String tv : teklaValues){
                  if(tkl == null){
                     tkl = tv;
                  }else{
                    tkl += ';'+tv;
                  }
               }
               for(String et : IESValues){
                  if(ie == null){
                     ie = et;
                  }else{
                    ie += ';'+et;
                  }
               }
               //if(cads != null ){
                  account.CAD_Software__c = cads;     
               //}
               
               //if(bss != null){
                  account.Business_Software__c = bss;
               //}
              
               //if(hdc != null ){
                  account.Hardware__c = hdc;      
               //}    
            
               //if(tkl != null){
                  account.Tekla__c = tkl;           
               //}
               
               //if(ie != null ){
                  account.IES__c = ie;           
               //}   
               
               acctlist.add(account);    
         } 
         
         if(acctlist.size() > 0){ 
            RecursiveTriggerUtility.isAccountRecursive = false;
            update acctlist;   
         }   
      }catch(Exception e){
         System.debug(e.getMessage());
      }      
   }        
}