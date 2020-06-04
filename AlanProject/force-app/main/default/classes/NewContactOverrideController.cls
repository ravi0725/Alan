public class NewContactOverrideController{
    public NewContactOverrideController(Apexpages.StandardController controller){
        
    }
    
    // This method used to redirect to case creation page
    public PageReference continueContactCreation(){
        
        String urlParams = ''; 
        for(String key : Apexpages.currentpage().getparameters().keySet()){
            system.debug(key + '-----------key-----------' + Apexpages.currentpage().getparameters().get(key));
            if(key != 'save_new')urlParams = urlParams + '&' + key + '=' + EncodingUtil.urlEncode(Apexpages.currentpage().getparameters().get(key),'UTF-8');
        }
        
        
        User ur = [select Id,LanguageLocaleKey, Division__c from User where Id =: userinfo.getUserId()]; 
        string url = '';
        if(ur.Division__c == 'MEP NA'){    
            if(ur.LanguageLocaleKey == 'en_US'){ 
                url = '/003/e?00Ni000000EFLel=American English' ; 
            }else if(ur.LanguageLocaleKey == 'de'){ 
                url = '/003/e?00Ni000000EFLel=German' ; 
            }else if(ur.LanguageLocaleKey == 'es'){ 
                url = '/003/e?00Ni000000EFLel=Spanish' ; 
            }else if(ur.LanguageLocaleKey == 'fr'){ 
                url = '/003/e?00Ni000000EFLel=French' ; 
            }else if(ur.LanguageLocaleKey == 'it'){ 
                url = '/003/e?00Ni000000EFLel=Italian' ; 
            }else if(ur.LanguageLocaleKey == 'ja'){ 
                url = '/003/e?00Ni000000EFLel=Japanese' ; 
            }else if(ur.LanguageLocaleKey == 'sv'){ 
                url = '/003/e?00Ni000000EFLel=Swedish' ; 
            }else if(ur.LanguageLocaleKey == 'ko'){ 
                url = '/003/e?00Ni000000EFLel=Korean' ; 
            }else if(ur.LanguageLocaleKey == 'zh_CN'){ 
                url = '/003/e?00Ni000000EFLel=Simplified Chinese' ; 
            }else if(ur.LanguageLocaleKey == 'pt_BR'){ 
                url = '/003/e?00Ni000000EFLel=Brazilian Portuguese' ; 
            }else if(ur.LanguageLocaleKey == 'nl_NL'){ 
                url = '/003/e?00Ni000000EFLel=Dutch' ; 
            }else if(ur.LanguageLocaleKey == 'da'){ 
                url = '/003/e?00Ni000000EFLel=Danish' ; 
            }else if(ur.LanguageLocaleKey == 'th'){ 
                url = '/003/e?00Ni000000EFLel=Thai' ; 
            }else if(ur.LanguageLocaleKey == 'fi'){ 
                url = '/003/e?00Ni000000EFLel=Finnish' ; 
            }else if(ur.LanguageLocaleKey == 'ru'){ 
                url = '/003/e?00Ni000000EFLel=Russian' ; 
            }else if(ur.LanguageLocaleKey == 'no'){ 
                url = '/003/e?00Ni000000EFLel=Norwegian' ; 
            }else{ 
                url = '/003/e?00Ni000000EFLel=American English' ; 
            } 
            url = url + '&' + urlParams;
        }else{
            url='/003/e?'+ urlParams;
        }
        
        if(!Apexpages.currentpage().getparameters().containsKey('con4') && Apexpages.currentpage().getparameters().containsKey('CF' + Label.Contact_Account_Address_Field_Id + '_lkid')){
            for(Address__c add : [select ID,Account__c,Account__r.Name from Address__c where Id =: Apexpages.currentpage().getparameters().get('CF' + Label.Contact_Account_Address_Field_Id + '_lkid') limit 1]){
                url = url + '&con4=' + EncodingUtil.urlEncode(add.Account__r.Name,'UTF-8') + '&con4_lkid=' + add.Account__c;
            }
        }
        
        //if(ur.Division__c == 'TAP')
        url = url + '&' + Label.TAP_Job_Role+'=Other';
        system.debug('-------------' + ur.Division__c);
        
        if(ur.Division__c == 'TAP' && Apexpages.currentpage().getparameters().containsKey('CF' + Label.Contact_Account_Address_Field_Id + '_lkid')){ 
            
            url = url + '&saveURL=' + Apexpages.currentpage().getparameters().get('CF' + Label.Contact_Account_Address_Field_Id + '_lkid');
            url = url + '&cencelURL=' + Apexpages.currentpage().getparameters().get('CF' + Label.Contact_Account_Address_Field_Id + '_lkid');
            
        }
        
        PageReference pRef = new PageReference(url);
        pRef.getParameters().put('nooverride', '1');
        pRef.getParameters().put('sfdc.override', '0');
        pRef.setRedirect(true);
        return pRef;
    }
}