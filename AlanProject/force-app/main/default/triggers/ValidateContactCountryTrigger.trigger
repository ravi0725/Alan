/*****************************************************************************************
    Name    : ValidateContactCountryTrigger
    Desc    : This trigger validates the countries entered by the user.
                            
    Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Sagar Mehta           1/31/2014          Created
******************************************************************************************/
trigger ValidateContactCountryTrigger on Contact (before insert, before update) {
    if(userinfo.getName() != 'Data Administrator'){
        system.debug('-------------' + trigger.new);
        //validation for account records, if Country is not properly matched with Country Region Mapping custom setting, then it will throw error.    
        for (Contact contact : trigger.new){
           try{
                 List<Country_Region_Mapping__c> Lrm = new List<Country_Region_Mapping__c>();  
            Set<String>CountrySet = new Set<String>();               
                Lrm = Country_Region_Mapping__c.getall().values();
                for(Country_Region_Mapping__c crm : Lrm)
                {
                 CountrySet.add(crm.Name.touppercase());
                }
                if(contact.MailingCountry != Null && !CountrySet.Contains(contact.MailingCountry.touppercase()))
                {
                  contact.addError(Label.Validate_Country_Name);
                }              
              }
           catch(Exception e){
              contact.addError(e.getMessage());
           }  
       }  
    }  
}