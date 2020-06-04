/*****************************************************************************************
    Name    : ValidateLeadCountryTrigger
    Desc    : This trigger validates the countries entered by the user.
                            
    Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Sagar Mehta           1/31/2014          Created
******************************************************************************************/
trigger ValidateLeadCountryTrigger on Lead (before insert, before update) {
    List<MEPEuropeSalesRegion_del_del__c> listCodes = new List<MEPEuropeSalesRegion_del_del__c>();
    listCodes = MEPEuropeSalesRegion_del_del__c.getAll().values();
    
    List<Paris_Region_Mapping__c> franceCodes = new List<Paris_Region_Mapping__c>();
    franceCodes = Paris_Region_Mapping__c.getAll().values();
    
    List<User>  userList = new List<User>();
    userList = [select Id, MEP_Europe_Sales_Region__c from User where Id =: UserInfo.getUserID()];
    
    if(Trigger.isBefore){
            //validation for account records, if Country is not properly matched with Country Region Mapping custom setting, then it will throw error.    
            for (Lead lead : trigger.new){
               try{
                  if(lead.Country != null){    
                     String Country = lead.Country;             
                     Country_Region_Mapping__c countryMap = Country_Region_Mapping__c.getInstance(Country);   
                     if(countryMap == null){                    
                        lead.addError(Label.Validate_Country_Name);
                     }else if(countryMap.ISO_Currency_Code__c != null){ 
                        lead.CurrencyIsoCode = countryMap.ISO_Currency_Code__c;
                     }
                  }
                  
               /*
                  * ITEM-00810
                  * Populate MEP Europe Sales Region from Custom setting based on the country specified by user.          
                  */                         
                 if(lead.Country != null){
                    String MEDregion;
                    boolean franceZipFlag = true;
                    if(lead.Country == Label.France && lead.PostalCode != null && lead.PostalCode.length() >= 2 && lead.PostalCode.substring(0, 2) == '75'){
                       franceZipFlag = false;
                    }
                    if(franceZipFlag){
                      for(MEPEuropeSalesRegion_del_del__c mep : listCodes){                   
                        if(mep.Country__c == lead.Country){
                            lead.MEP_Europe_Sales_Region__c = mep.MEP_Europe_Sales_Region__c;
                            if(mep.Zip__c != null && lead.PostalCode != null){
                              if((lead.Country == Label.France || lead.Country == Label.Germany) && lead.PostalCode != null && lead.PostalCode.length() >= 2){
                                String code = lead.PostalCode.substring(0, 2);
                                if(mep.Zip__c.contains(code)){
                                      lead.MEP_Europe_Sales_Region__c = mep.MEP_Europe_Sales_Region__c;                                
                                      break;
                                    }else{
                                      lead.MEP_Europe_Sales_Region__c = '';
                                    }
                              }else{
                                   if(mep.Zip__c.contains(lead.PostalCode)){
                                     lead.MEP_Europe_Sales_Region__c = mep.MEP_Europe_Sales_Region__c;                                
                                     break;
                                   }else{
                                     lead.MEP_Europe_Sales_Region__c = '';
                                   }
                              }    
                            }else{
                               break;  
                            }
                        }else{
                            lead.MEP_Europe_Sales_Region__c = '';
                        }
                      }
                    }else{
                      for(Paris_Region_Mapping__c code : franceCodes){
                          if(code.Country__c == lead.Country){                             
                             if(code.Zip_Postal_Code__c != null && lead.PostalCode != null){
                                if(code.Zip_Postal_Code__c.contains(lead.PostalCode)){
                                    lead.MEP_Europe_Sales_Region__c = code.MEP_Europe_Sales_Region__c;                                
                                    break;
                                }
                            }else{
                               break;  
                            }
                          }else{
                            lead.MEP_Europe_Sales_Region__c = '';
                          }
                      }  
                      
                    } 
                 }
             
             /*
              * ITEM-00823
              * Account Region Report - Set Is_Account_User_Region_Match__c to TRUE when the Account's MED_Europe_Sales_Region__c field and the User's MEP_Europe_Sales_Region__c field is matching.          
              */
              //System.debug('**acc.MED_Europe_Sales_Region__c: '+acc.MED_Europe_Sales_Region__c+' userList.get(0).MEP_Europe_Sales_Region__c.contains(acc.MED_Europe_Sales_Region__c): '+userList.get(0).MEP_Europe_Sales_Region__c.contains(acc.MED_Europe_Sales_Region__c));
              if(userList.size() > 0 && lead.MEP_Europe_Sales_Region__c != '' && lead.MEP_Europe_Sales_Region__c != null  && userList.get(0).MEP_Europe_Sales_Region__c!=null && userList.get(0).MEP_Europe_Sales_Region__c!=''){             
                if( userList.get(0).MEP_Europe_Sales_Region__c.contains(lead.MEP_Europe_Sales_Region__c))
                 lead.User_Lead_Region_Match__c = true;
              }else{
                 if(lead.User_Lead_Region_Match__c){
                    lead.User_Lead_Region_Match__c = false;
                 }
              }                  
              }catch(Exception e){
               lead.addError(e.getMessage());
               system.debug('exception e==='+e);
               system.debug('exception e==='+e.getStackTraceString());
          } 
    }
  }
}