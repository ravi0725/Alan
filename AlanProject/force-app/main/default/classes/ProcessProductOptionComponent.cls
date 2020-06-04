/*****************************************************************************************
    Name    : ProcessProductOptionComponent 
    Desc    : Used to update fields on Product and Proposal Line Item object
                            
    Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Sagar Mehta         05/29/2014          Created
******************************************************************************************/
public class ProcessProductOptionComponent {
    
    public static void processProductOptionComponent(Set<ID> productIdSet, boolean productOptionComponentTriggerFlag,Map<ID,Decimal> QuantityMap){
        List<Product2> productList = new List<Product2>();
        Map<Id, String> deProductMap = new Map<Id, String>();
        Map<Id, String> enProductMap = new Map<Id, String>();
        Map<Id, String> frProductMap = new Map<Id, String>();
        List<Apttus_Proposal__Proposal_Line_Item__c> lineItemList = new List<Apttus_Proposal__Proposal_Line_Item__c>();
        
        List<Apttus_Config2__ProductOptionComponent__c> productOptionComponentList = new List<Apttus_Config2__ProductOptionComponent__c>();
        
        try{
            productOptionComponentList = [Select Id, 
                                                 Apttus_Config2__ComponentProductId__c, 
                                                 Apttus_Config2__ComponentProductId__r.Product_Name_DE__c, 
                                                 Apttus_Config2__ComponentProductId__r.Product_Name_EN__c,  
                                                 Apttus_Config2__ComponentProductId__r.Product_Name_FR__c,
                                                 Apttus_Config2__ComponentProductId__r.Long_Desc_DE__c,
                                                 Apttus_Config2__ComponentProductId__r.Long_Desc_EN__c,
                                                 Apttus_Config2__ComponentProductId__r.Long_Desc_FR__c, 
                                                 Apttus_Config2__ParentProductId__c,
                                                 Apttus_Config2__Sequence__c   
                                          from Apttus_Config2__ProductOptionComponent__c 
                                          where Apttus_Config2__ParentProductId__c IN: productIdSet ORDER BY Apttus_Config2__Sequence__c ASC];
            
            for(Apttus_Config2__ProductOptionComponent__c component : productOptionComponentList){
                if(!deProductMap.keySet().contains(component.Apttus_Config2__ParentProductId__c)){
                    deProductMap.put(component.Apttus_Config2__ParentProductId__c, '');
                }
                if(!enProductMap.keySet().contains(component.Apttus_Config2__ParentProductId__c)){
                    enProductMap.put(component.Apttus_Config2__ParentProductId__c, '');
                }
                if(!frProductMap.keySet().contains(component.Apttus_Config2__ParentProductId__c)){
                    frProductMap.put(component.Apttus_Config2__ParentProductId__c, '');
                }
                String de = deProductMap.get(component.Apttus_Config2__ParentProductId__c);
                de = de + Integer.valueof(QuantityMap.get(component.Apttus_Config2__ComponentProductId__c)) + ' Stk. ' +component.Apttus_Config2__ComponentProductId__r.Product_Name_DE__c +'\n';
                if(component.Apttus_Config2__ComponentProductId__r.Long_Desc_DE__c !=null)
                de = de + component.Apttus_Config2__ComponentProductId__r.Long_Desc_DE__c + '\n';
                de = de.replace('null','0');
                deProductMap.put(component.Apttus_Config2__ParentProductId__c, de);
                    
                String en = enProductMap.get(component.Apttus_Config2__ParentProductId__c);
                en = en + Integer.valueof(QuantityMap.get(component.Apttus_Config2__ComponentProductId__c)) +' Pcs. ' +component.Apttus_Config2__ComponentProductId__r.Product_Name_EN__c +'\n';
                if(component.Apttus_Config2__ComponentProductId__r.Long_Desc_EN__c !=null)
                en = en + component.Apttus_Config2__ComponentProductId__r.Long_Desc_EN__c + '\n';  
                en = en.replace('null','0');          
                enProductMap.put(component.Apttus_Config2__ParentProductId__c, en);
                    
                String fr = frProductMap.get(component.Apttus_Config2__ParentProductId__c);
                fr = fr + Integer.valueof(QuantityMap.get(component.Apttus_Config2__ComponentProductId__c)) + ' Pcs. ' +component.Apttus_Config2__ComponentProductId__r.Product_Name_FR__c +'\n';
                if(component.Apttus_Config2__ComponentProductId__r.Long_Desc_FR__c !=null)
                fr = fr + component.Apttus_Config2__ComponentProductId__r.Long_Desc_FR__c + '\n'; 
                fr = fr.replace('null','0');             
                frProductMap.put(component.Apttus_Config2__ParentProductId__c, fr);
            }           
            
            if(productOptionComponentTriggerFlag){                                  
                productList = [Select Id, 
                                      Option_Name_DE__c, 
                                      Option_Name_EN__c, 
                                      Option_Name_FR__c 
                               from Product2 
                               where Id IN: productIdSet];
                for(Product2 product : productList){
                    if(deProductMap.containsKey(product.Id)){
                        if(deProductMap.get(product.Id) != null && deProductMap.get(product.Id) != ''){
                            product.Option_Name_DE__c = deProductMap.get(product.Id).trim();                    
                        }
                    }
                    if(enProductMap.containsKey(product.Id)){ 
                        if(enProductMap.get(product.Id) != null && enProductMap.get(product.Id) != ''){
                            product.Option_Name_EN__c = enProductMap.get(product.Id).trim();                    
                        }
                    }
                    if(frProductMap.containsKey(product.Id)){
                        if(frProductMap.get(product.Id) != null && frProductMap.get(product.Id) != ''){
                            product.Option_Name_FR__c = frProductMap.get(product.Id).trim();                    
                        }
                    }   
                }
                if(productList.size() > 0)
                  update productList;
            }else{
                lineItemList = [Select Id, 
                                      Option_Name_DE__c, 
                                      Option_Name_EN__c, 
                                      Option_Name_FR__c, 
                                      Apttus_Proposal__Product__c,
                                      Apttus_QPConfig__OptionId__c 
                               from Apttus_Proposal__Proposal_Line_Item__c 
                               where Apttus_Proposal__Product__c IN: productIdSet];
                               
                for(Apttus_Proposal__Proposal_Line_Item__c proposal : lineItemList){
                    if(deProductMap.containsKey(proposal.Apttus_Proposal__Product__c)){
                        if(deProductMap.get(proposal.Apttus_Proposal__Product__c) != null && deProductMap.get(proposal.Apttus_Proposal__Product__c) != ''){
                            proposal.Option_Name_DE__c = deProductMap.get(proposal.Apttus_Proposal__Product__c).trim();                 
                        }
                    }
                    if(enProductMap.containsKey(proposal.Apttus_Proposal__Product__c)){ 
                        if(enProductMap.get(proposal.Apttus_Proposal__Product__c) != null && enProductMap.get(proposal.Apttus_Proposal__Product__c) != ''){
                            proposal.Option_Name_EN__c = enProductMap.get(proposal.Apttus_Proposal__Product__c).trim();                 
                        }
                    }
                    if(frProductMap.containsKey(proposal.Apttus_Proposal__Product__c)){
                        if(frProductMap.get(proposal.Apttus_Proposal__Product__c) != null && frProductMap.get(proposal.Apttus_Proposal__Product__c) != ''){
                            proposal.Option_Name_FR__c = frProductMap.get(proposal.Apttus_Proposal__Product__c).trim();                 
                        }
                    }   
                }
                
                if(lineItemList.size() > 0){
                     RecursiveTriggerUtility.isProposalLineItemRecursive = false;
                     update lineItemList;
                }                 
            }                                   
            
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }   
}