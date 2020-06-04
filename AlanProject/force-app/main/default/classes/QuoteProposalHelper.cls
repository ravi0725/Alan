global class QuoteProposalHelper{

    public QuoteProposalHelper(){
        
    }
    
    webservice static string configureProducts(Id a){
        String url = 'test';
        List<Apttus_Config2__ProductConfiguration__c> productConfigList = new List<Apttus_Config2__ProductConfiguration__c>();        
        productConfigList = [Select Id, Name, Apttus_QPConfig__Proposald__c, Apttus_CQApprov__Approval_Status__c From 
        Apttus_Config2__ProductConfiguration__c where Apttus_QPConfig__Proposald__c =: a order by Apttus_Config2__VersionNumber__c desc];        

        if(productConfigList.size() > 0){
            Apttus_Config2__ProductConfiguration__c productConfig = new Apttus_Config2__ProductConfiguration__c();
            productConfig = productConfigList.get(0);
            
            List<Apttus_Config2__TempObject__c> tempList = new List<Apttus_Config2__TempObject__c>();
            
            tempList = [Select Id, Name, Apttus_Config2__ConfigurationId__c From Apttus_Config2__TempObject__c where Apttus_Config2__ConfigurationId__c
                       =: productConfig.Id];
                       
            if(tempList.size() > 0){
               url = 'id='+productConfig.Id+'&configRequestId='+tempList.get(0).Id+'&ret=1';
            }else{
               url = 'id='+productConfig.Id+'&ret=1';
            }           
        }
        return url;
    }    
    
    
}