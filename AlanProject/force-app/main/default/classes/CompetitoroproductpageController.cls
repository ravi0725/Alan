/*****************************************************************************************
    Name    :     CompetitoroproductpageController
    Desc    :     Used for implementing cusotm visualforce page logic for competitor assets related list on Account and Lead.  
                  The new button in Competitor Assets related list on Account and lead is overridden here and the functionality is implemented in this class                
    Project ITEM: ITEM-00703, ITEM-00779                            
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Sagar Mehta           10/27/2013          Created
******************************************************************************************/
public class CompetitoroproductpageController{
   
   public Product_competitor__c prodcomp{get;set;}
   public Id accountId;
   public List<SelectOption> Currencyoptions {get;set;}
   public string acctname{get;set;}
   public String username{get;set;}
   Map<String, boolean> currencyMap = new Map<String, boolean>();
   /**
     * Method name  : CompetitoroproductpageController
     * Description  : Constructor of the Controller class - Initializes all the variables.
     *                Populates appropriate data like currencies, products.
     * Return Type  : Void
     * Parameter    : StandardController
     **/    
   public CompetitoroproductpageController(ApexPages.StandardSetController controller){
       prodcomp = new Product_competitor__c();  
       List<Account> acctlist=new List<Account>();     
       accountId = ApexPages.currentPage().getParameters().get('id');
       prodcomp.Competitor_Account__c = accountId ;
       prodcomp.ownerid =Userinfo.getuserid();
       username = Userinfo.getFirstName()+'  '+userinfo.getLastName() ;
       Currencyoptions = new List<SelectOption>();
      
       List<CurrencyType> currencyList = [Select IsoCode, IsActive, Id From CurrencyType];
       
       for(CurrencyType curr : currencyList){
         currencyMap.put(curr.IsoCode, curr.IsActive);
       }
       if(accountId !=null){
         acctlist =[select id,name from Account where id=:accountId];
       }
       if(acctlist.size()>0){
         acctname = acctlist.get(0).Name;
       }
       //Fetch all currency data using Currency Fielddescription 
       Schema.DescribeFieldResult CurrencyFieldDescription = CurrencyType.IsoCode.getDescribe();
       for (Schema.Picklistentry picklistEntry:CurrencyFieldDescription.getPicklistValues()){
           if(currencyMap.keyset().contains(pickListEntry.getValue()) && currencyMap.get(pickListEntry.getValue())){
              Currencyoptions.add(new SelectOption(pickListEntry.getValue(),pickListEntry.getLabel()));
           } 
           prodcomp.CurrencyIsoCode = UserInfo.getDefaultCurrency();
        }
       
   }
   
   /**
     * Method name  : newCompetitor
     * Description  : This method is used to insert new Competitor Assets record related to a Account     
     * Return Type  : PageReference
     * Parameter    : 
     **/
   public PageReference newCompetitor(){
      try{
         
         insert prodcomp;
      }catch(Exception e){
         System.debug(e.getMessage());
      }
      return new PageReference('/'+accountId);
   }
   
   /**
     * Method name  : cancel
     * Description  : This method is used to redirect the page from competitorAssetsAcount page back to account record     
     * Return Type  : PageReference
     * Parameter    : 
     **/
   public PageReference cancel(){
       return new PageReference('/'+accountId);
   }
   
 
}