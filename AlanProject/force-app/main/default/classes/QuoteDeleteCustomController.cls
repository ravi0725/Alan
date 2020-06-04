/*****************************************************************************************
    Name        : FinalizeOpportunityCustomController 
    Desc        :Used for update Opportunity's "Stage" field to "6 - Closed Won" and update Quote/Proposal "Approval Stage" = Order Submitted.
    Project Item : ITEM-00763, ITEM-00800
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Chandrakant Dwivedi     11/29/2013          Created
******************************************************************************************/
public class QuoteDeleteCustomController{
    
    public String quoteId{get;set;}
    public String oppid;
    public decimal taxAmount;
    public boolean taxFlag{get;set;}
    public boolean quoteFlag{get;set;}
    public boolean recalculateTax{get;set;}
    public String errorMsg{get;set;}
    public Boolean errorPopup{get;set;}
    List<opportunity> opplist=new List<opportunity>();
    List<Apttus_Proposal__Proposal__c> quotelist=new List<Apttus_Proposal__Proposal__c>();
    List<Apttus_Proposal__Proposal_Line_Item__c> lineitemlist=new List<Apttus_Proposal__Proposal_Line_Item__c>();
    List<Apttus_Config2__LineItem__c> proposalsumm=new List<Apttus_Config2__LineItem__c>();
    List<Apttus_QPConfig__ProposalSummaryGroup__c> summgrplist=new List<Apttus_QPConfig__ProposalSummaryGroup__c>();
    List<Apttus_Config2__ProductConfiguration__c> prodconflist=new List<Apttus_Config2__ProductConfiguration__c>();
    QuotePropCalcTax qpct = new QuotePropCalcTax ();
    
    /**
     * Method name  : FinalizeOpportunityCustomController
     * Description  : Constructor of the Controller class - Initializes all the variables.                
     * Return Type  : 
     * Parameter    : 
     **/
    public QuoteDeleteCustomController(){
       quoteId= System.currentPageReference().getParameters().get('id');
    }
    
    /**
     * Method name  : cancelquote
     * Description  : This method is used to redirect the page from current page back to quote record     
     * Return Type  : PageReference
     * Parameter    : 
     **/    
    public PageReference cancelquote(){
       return  new PageReference('/'+quoteId);     
    }
    
    /**
     * Method name  : updateopportunity
     * Description  : This method is used to update opportunity record with stage name to be set to 6 - Closed Won
     *                It also updates Quote record with the Apttus_Proposal__Approval_Stage__c set to Order Submitted
     * Return Type  : PageReference
     * Parameter    : 
     **/
    public PageReference Deletequote(){
       try{
         prodconflist =[select id from Apttus_Config2__ProductConfiguration__c where Apttus_QPConfig__Proposald__c =:quoteId];
         if(prodconflist.size()>0){
          Delete prodconflist;
         }
         quotelist=[select Apttus_Proposal__Opportunity__c from Apttus_Proposal__Proposal__c where id=:quoteId];
         if(quotelist.size()>0){
           Delete quotelist;
       }
       }catch(Exception e){
          ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
          ApexPages.addMessage(msg); 
          return null;
       }  
       return  new PageReference('/a1S/o'); 
    }
    
   
}