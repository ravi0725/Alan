/*****************************************************************************************
    Name        : OpportunityPlancalController 
    Desc        : Used to populate Price List on User record				                                    
    Project ITEM: ITEM-00764                         
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Chandrakant Dwivedi     11/29/2013          Created
******************************************************************************************/
public class OpportunityPlancalController {
    
    String defaultPriceList;
    String ProflieName;
    List<Apttus_Config2__PriceList__c> apptusPriceList;
    
    /**
     * Method name  : OpportunityPlancalController
     * Description  : Constructor of the Controller class - Initializes all the variables.                
     * Return Type  : 
     * Parameter    : ApexPages.StandardController
     **/
    public OpportunityPlancalController(ApexPages.StandardController cont){
        //this.controller = controller;
        String UserId=userinfo.getUserId();
        List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        ProflieName = PROFILE[0].Name;
        List<User> listuser=[select Id from user where Id=:UserId limit 1];
        apptusPriceList = new List<Apttus_Config2__PriceList__c>();
        apptusPriceList = [select id,Name from Apttus_Config2__PriceList__c where Name =: defaultPriceList];
    }
    
    /**
     * Method name  : redirectToOpportunity
     * Description  : This method is used to redirect to opportunity new detail page.
     *         		  This method retrieves record type selected by the user and associate the record type to opportunty record.  
     * Return Type  : PageReference
     * Parameter    : 
     **/
    public PageReference redirectToOpportunity(){
         String recordType;
         PageReference page = new PageReference('/006/e?retURL=%2F006%2Fo&nooverride=1');
         if(ProflieName.contains('MEP')){            
            if(apptusPriceList.size() > 0){
                if(ApexPages.CurrentPage().getParameters().get('RecordType') != null){
                   recordType = ApexPages.CurrentPage().getParameters().get('RecordType'); 
                   page = new PageReference('/006/e?CF00Nc0000000kUEI_lkid='+apptusPriceList.get(0).id+'&CF00Nc0000000kZcl='+apptusPriceList.get(0).Name+'&retURL=%2F006%2Fo&RecordType='+recordType+'&nooverride=1');                                   
                }else{
                   page = new PageReference('/006/e?CF00Nc0000000kUEI_lkid='+apptusPriceList.get(0).id+'&CF00Nc0000000kZcl='+apptusPriceList.get(0).Name+'&retURL=%2F006%2Fo&nooverride=1');         
                }                
            }else{
                if(ApexPages.CurrentPage().getParameters().get('RecordType') != null){
                   recordType = ApexPages.CurrentPage().getParameters().get('RecordType'); 
                   page = new PageReference('/006/e?retURL=%2F006%2Fo&RecordType='+recordType+'&nooverride=1');                                   
                }else{                
                   page = new PageReference('/006/e?retURL=%2F006%2Fo&nooverride=1');
                }   
            }
         }else{            
            if(ApexPages.CurrentPage().getParameters().get('RecordType') != null){
                recordType = ApexPages.CurrentPage().getParameters().get('RecordType'); 
                page = new PageReference('/006/e?retURL=%2F006%2Fo&RecordType='+recordType+'&nooverride=1');
            }else{
                page = new PageReference('/006/e?retURL=%2F006%2Fo&nooverride=1');
            }
         }
         return page;
    }
}