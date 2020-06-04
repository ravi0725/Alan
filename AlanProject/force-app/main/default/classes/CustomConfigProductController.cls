/*****************************************************************************************
Name    : CustomConfigProductController
Desc    : Checks if the Logged in User is GCCM Division  and Turns the Advance Pricing Flag as False


Modification Log : 
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
Prince Leo           27/05/2016          Created
******************************************************************************************/
Public class CustomConfigProductController{
    public string config{get;set;}
    public string tempcpqid {get;set;}
    public boolean errorPopup {get;set;}
    public boolean AdvancedPricingflag{get;set;}
    public boolean BilltoChangedflag{get;set;}
    Public String quoteId {get;set;}
    Public String ApproalStage{get;set;}
    public Apttus_Config2__ProductConfiguration__c con;
    public boolean FinalizeError{get;set;}
    public string flowUI;
    public CustomConfigProductController(){
        
        quoteId = System.currentPageReference().getParameters().get('id'); 
        flowUI = System.currentPageReference().getParameters().get('flow'); 
    }
    
    Public PageReference UpdateAdvancedPricingFlags()
    {
     User usrProfileName = [select u.Profile.Name,u.Division__c from User u where u.id = :Userinfo.getUserId()];
     String Division = usrProfileName.Division__c;
    Apttus_Proposal__Proposal__c QuoteRec = new Apttus_Proposal__Proposal__c(id=quoteId);
     
    //QuoteRec.Bill_to_Address_Changed__c = True;
    if(Division =='GCCM'){
    QuoteRec.Advanced_Pricing_Completed__c = False; 
    }
    QuoteRec.Apttus_Proposal__Approval_Stage__c = 'Draft'; 
    update QuoteRec;
    
     PageReference pageprop;
     if(flowUI == 'Angular')
     pageprop = new PageReference('/apex/Apttus_QPConfig__ProposalConfiguration?id='+quoteId+'&useAdvancedApproval=true&flow=Angular');
     else
     pageprop = new PageReference('/apex/Apttus_QPConfig__ProposalConfiguration?id='+quoteId+'&useAdvancedApproval=true');
     pageprop.setRedirect(true);
     return pageprop;
    }
  }