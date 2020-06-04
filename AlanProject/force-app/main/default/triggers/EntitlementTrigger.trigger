/*****************************************************************************************
    Name    :     Entitlement Trigger
    Desc    :    Used to populate the entitlement summary fields by product family and by entitlement type on Account object
    Project ITEM: ITEM-00789
                            
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Sagar Mehta           10/27/2013          Created
Prince Leo            10/07/2014          Modified
Divya                 06/04/2015          Modified Owner.Division__C = Owners to RE&WS

******************************************************************************************/
trigger EntitlementTrigger on Entitlement(after insert,after update){
    if(RecursiveTriggerUtility.isAccountRecursive){
    RecursiveTriggerUtility.isAccountRecursive = False;
    Profile prof = [Select id,Name from Profile where Id = :UserInfo.getProfileId()];
    system.debug('>>>>>>>>>>>>>>>>>>> prof');
    if(prof.Name != Label.API_Only){
     Set<Id> accountIdSet = new Set<Id>();
     boolean flag = true;
     for(Entitlement ent : Trigger.new){
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
     /*List<Account> accountList = [Select Id, CAD_Software__c, Business_Software__c, Hardware__c, Tekla__c, 
                                 (Select Id, Status, Product_Family__c, Type,Type_MEP__c,supported_Product_Family_Roll_up__c,Entitlement_Product__c,
                                 AssetId,EntitlementActive__c,Asset_Effectivity__c from Entitlements where Type_MEP__c IN: productTypeSet AND 
                                 supported_Product_Family_Roll_up__c IN: productFamilySet AND EntitlementActive__c =: true) from Account where 
                                 Id IN: accountIdSet];                                 
     */
          
     for(Account account : [Select Id, Name, CAD_Software__c, Business_Software__c, Hardware__c, Tekla__c, IES__c,Creator_s_Division__c,   
                           (Select Id,Entitlement_Product__c, Type_MEP__c,supported_Product_Family_Roll_up__c from Entitlements where Type_MEP__c IN: productTypeSet AND 
                             supported_Product_Family_Roll_up__c IN: productFamilySet AND EntitlementActive__c =: true) from Account where 
                             Id IN: accountIdSet]){  
                             
                 
       cadValues = new Set<String>();
       businessValues = new Set<String>();
       hardwareValues = new Set<String>();
       teklaValues = new Set<String>();
       IESValues = new Set<String>();
       
       //loop through the  related entitlement of account       
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
       account.CAD_Software__c = cads;     
       
       account.Business_Software__c = bss;
      
       account.Hardware__c = hdc;      
    
       account.Tekla__c = tkl;           
       
       account.IES__c = ie;           
       
       acctlist.add(account);    
     } 
     
    
     
     if(acctlist.size() > 0)  
        update acctlist; 
    }  
    
    // Added for GCCM Division 
    // Updates List Price of Price List Entry record as the Entitlement List Price 
    system.debug('>>>>>>>>>>>>>>>>>>> GCCM Update');
    List<Entitlement> updateList = new List<Entitlement>();
     Set<ID> ProID = new Set<ID>();
     List<Entitlement> Entli= new List<Entitlement>();
     Set<ID> EntID = new Set<ID>();
    
     for(Entitlement e : Trigger.New)
         {
         EntID.add(e.Id);
         }
         system.debug('>>>>>>>>>>>>>>>>>>> GCCM Update' + EntID);
     Entli = [select id,account.CurrencyIsoCode,Account.Owner.Division__c,Product_Product_Type__c,Asset.Quantity,Entitlement_Product__c,List_Price__c  from Entitlement where id in: EntID AND Entitlement_Product__r.IsActive = TRUE]; 
    
        for(Entitlement e : Entli)
         {
          ProID.add(e.Entitlement_Product__c);
         }
       List<PricebookEntry> PriceBookEn = new List<PricebookEntry>([Select id,Product2id,pricebook2id,UnitPrice from PriceBookEntry where Product2id in:ProID and Pricebook2.Name='GCCM Price Book']); 
       Map<ID,PriceBookEntry>ProdEntry = new Map<ID,PriceBookEntry>();
       for(PricebookEntry pr : PriceBookEn)
       {
       ProdEntry.put(pr.Product2id,pr);
       }
     // List<PricebookEntry> Entry = [Select id,CurrencyIsoCode,UnitPrice,Product2Id from PricebookEntry where Product2Id =: e.Entitlement_Product__c and Pricebook2.Name='GCCM Price Book' and IsActive = TRUE and CurrencyIsoCode =: e.account.CurrencyIsoCode];
         if(ProdEntry.values().size() > 0){
               for(Entitlement e : Entli)
             {

                 if( (e.Account.Owner.Division__c=='GCCM' || e.Account.Owner.Division__c=='RE&WS') && ProdEntry.get(e.Entitlement_Product__c) != Null){
                    e.List_Price__c = ProdEntry.get(e.Entitlement_Product__c).UnitPrice;
                   system.debug('>>>>>>>>>>>>>>>>>>>'+e.List_Price__c);
                    updateList.add(e);
                   }
              /*   if(e.Product_Product_Type__c =='Prolog' && (e.Account.Owner.Division__c=='GCCM' || e.Account.Owner.Division__c=='Owners'))
                 {
                   e.Quantity__c = e.Asset.Quantity;
                   system.debug('>>>>>>>>>>>>>>>>>>>'+ e.Quantity__c);
                 } */
                  
             }
         }
             if(updateList.size()>0)
             update updateList;
     
    
    }
}