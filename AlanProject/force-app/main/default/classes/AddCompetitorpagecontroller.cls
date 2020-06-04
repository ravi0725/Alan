/*****************************************************************************************
    Name         : CartViewRelatedListController 
    Desc         : Used for displaying approval request related to a Quote/Proposal record in its related list of Approval Requests.
    Project Item : ITEM-00816
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Sagar Mehta          01/15/2014          Created
******************************************************************************************/
public class AddCompetitorpagecontroller{ 
    
    public boolean statusFlag{get;set;}
    public string optyid{get;set;}
    public string accountname{get;set;}
    public List<clsLeadWrapper> competitorAssetsList{get;set;}
    
    /**
     * Class Constructor 
     * @param stdController the standard controller
     */
    public AddCompetitorpagecontroller() {       
       List<Competitor_Owned_Assets__c> compassetlist = new List<Competitor_Owned_Assets__c>();
       competitorAssetsList = new List<clsLeadWrapper>();   
       statusFlag = true;
       if(System.currentPageReference().getParameters().get('id') != null){
          optyId = System.currentPageReference().getParameters().get('id');    
          List<Opportunity> opptylist = new List<Opportunity>();
          opptylist  =[select Id, Accountid,Account.Name from Opportunity where Id =: optyId];
          accountname = opptylist.get(0).Account.Name;
          if(opptylist.size() > 0){
             compassetlist = [Select Id, Name, Competitor_Company__r.Name, Number_of_Licenses__c, Product_Version__c, Yearly_Subscription_Cost__c, 
             Install_Date__c, Expiration_Date__c from Competitor_Owned_Assets__c where Account__c =: opptylist.get(0).Accountid and Expiration_Date__c >=: date.today()];
             for(Competitor_Owned_Assets__c compAsset : compassetlist){
               clsLeadWrapper wrapper = new clsLeadWrapper();
               wrapper.isSelected = false;
               wrapper.asset = compAsset;
               competitorAssetsList.add(wrapper); 
             } 
          }else{
             ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, Label.No_Records_Found);
             ApexPages.addMessage(msg);    
          }  
       }else{
          ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, Label.No_Records_Found);
          ApexPages.addMessage(msg);
       }       
    }
    
    public class clsLeadWrapper{
       public boolean isSelected{get;set;}
       public Competitor_Owned_Assets__c asset{get;set;}
    }
   
    public PageReference updatecompetitor(){
       try{
           boolean flag = true;       
           statusFlag = true;
           List<Competitor_Owned_Assets__c> compownasset=new List<Competitor_Owned_Assets__c>();
           for(clsLeadWrapper wrap : competitorAssetsList){
              if(wrap.isSelected){
                flag = false;           
                wrap.asset.Opportunity__c = optyId;
                compownasset.add(wrap.asset);
              }            
           }
           if(flag){
              statusFlag = false;
              ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Mandatory_Comp_Assets);
              ApexPages.addMessage(msg);
              return null;
           }
           update compownasset;        
       }catch(Exception e){
           ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
           ApexPages.addMessage(msg);
           return null;
       }   
       return new PageReference('/'+optyid);
    }  
    
    public pagereference pageredirect(){    
       PageReference reference=new PageReference('/apex/CompAssetsOptyPage?id='+optyid+'&ret=1');
       reference.setRedirect(true);
       return reference;    
    }                   
    
    public PageReference cancel(){
       return new PageReference('/'+optyid);
    }
 }