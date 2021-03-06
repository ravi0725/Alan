public class QuotePlancalController {
    
    String defaultPriceList;
    String ProflieName;
    List<Apttus_Config2__PriceList__c> apptusPriceList;
    //ApexPages.StandardController controller;
    public QuotePlancalController(ApexPages.StandardController cont){
        //this.controller = controller;
        String UserId=userinfo.getUserId();
        List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        ProflieName = PROFILE[0].Name;
        List<User> listuser=[select Id from user where Id=:UserId limit 1];
        //defaultPriceList = listuser.get(0).Default_Pricelist__c;
        apptusPriceList = new List<Apttus_Config2__PriceList__c>();
        apptusPriceList = [select id,Name from Apttus_Config2__PriceList__c where Name =: defaultPriceList];
        
        
    }
    
    public PageReference redirectToquote(){
         PageReference page = new PageReference('/a1F/e?retURL=%2F006%2Fo&nooverride=1');
         if(ProflieName.contains('MEP')){
            if(apptusPriceList.size() > 0){
                page = new PageReference('/a1F/e?CF00Nc0000000kUEI_lkid='+apptusPriceList.get(0).id+'&CF00Nc0000000kUEI='+apptusPriceList.get(0).Name+'&retURL=%2Fa1F%2Fo&nooverride=1');
            }else{
                page = new PageReference('/a1F/e?retURL=%2Fa1F%2Fo&nooverride=1');
            }
         }else{
            String recordType;
            if(ApexPages.CurrentPage().getParameters().get('RecordType') != null){
                recordType = ApexPages.CurrentPage().getParameters().get('RecordType'); 
                page = new PageReference('/a1F/e?retURL=%2Fa1F%2Fo&RecordType='+recordType+'&nooverride=1');
            }else{
                page = new PageReference('/a1F/e?retURL=%2Fa1F%2Fo&nooverride=1');
            }
         }
         return page;
    }
}