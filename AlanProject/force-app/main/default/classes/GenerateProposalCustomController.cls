/*****************************************************************************************
    Name        : FinalizeOpportunityCustomController 
    Desc        :Used for update Opportunity's "Stage" field to "6 - Closed Won" and update Quote/Proposal "Approval Stage" = Order Submitted.
    Project Item : ITEM-00763, ITEM-00800
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Chandrakant Dwivedi     11/29/2013          Created
******************************************************************************************/
public class GenerateProposalCustomController{
    
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
    QuotePropCalcTax qpct = new QuotePropCalcTax ();
    
    /**
     * Method name  : FinalizeOpportunityCustomController
     * Description  : Constructor of the Controller class - Initializes all the variables.                
     * Return Type  : 
     * Parameter    : 
     **/
    public GenerateProposalCustomController(){
        taxFlag = false;
        //quoteFlag = false;
        recalculateTax = false;
        quoteId= System.currentPageReference().getParameters().get('id');
        List<Apttus_Proposal__Proposal__c> quoteList = new List<Apttus_Proposal__Proposal__c>();
        quoteList = [Select Tax__c, Recalculate_tax__c from Apttus_Proposal__Proposal__c where id =:quoteId];  
        /**if(quoteList.size() > 0){
          taxAmount = quoteList.get(0).Tax__c;
          if(taxAmount == null || quoteList.get(0).Recalculate_tax__c ){
             taxFlag = true;       
          }else{
             system.debug('Reached Here');
             generateprop();
             //quoteFlag = true;
          }
                                    
        }**/
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
    public PageReference generateprop(){
        List<Apttus_Proposal__Proposal__c> Proposallist= new List<Apttus_Proposal__Proposal__c>();
        Proposallist = [Select Tax__c, Recalculate_tax__c, Quote_Validated__c, PriceList_Division__c from Apttus_Proposal__Proposal__c where id =:quoteId];  
        PageReference pageprop;
        system.debug('taxAmount '+Proposallist.get(0).Tax__c);
        if(Proposallist.get(0).Tax__c!= null && (Proposallist.get(0).Quote_Validated__c || Proposallist.get(0).PriceList_Division__c == 'RE&WS')){
            system.debug('reched tax');
            pageprop = new PageReference('/apex/Apttus_Proposal__ProposalGenerate?id='+quoteId);
            pageprop.setRedirect(true);
            return pageprop;
        }else{
             taxFlag = true;     
        } 
        return null;
     }
     /**
     * Method name  : calculateTax
     * Description  : This method calculates Tax such that the quote is ready to be submitted for order.
     * Return Type  : void
     * Parameter    : 
     **/
    public PageReference calculateTax(){
        //quoteFlag = true;
        QuotePropCalcTax qt=new QuotePropCalcTax();
        boolean error = qt.UpdateTax('0');
        PageReference pageprop;
        system.debug('error from class'+error );
         Apttus_Proposal__Proposal__c ppq = [SELECT  Tax__c ,Oracle_Error__c FROM Apttus_Proposal__Proposal__c WHERE Id  =: quoteId ]; 
        if(error && ppq.Tax__c ==null){
           errorPopup=True;
           taxFlag= false;
           Apttus_Proposal__Proposal__c appQ = [SELECT  Tax__c ,Oracle_Error__c FROM Apttus_Proposal__Proposal__c WHERE Id  =: quoteId ];           
           if(appQ.Oracle_Error__c !=null){
             errorPopup=True;
             errorMsg = appQ.Oracle_Error__c;
           }
        } 
        else{
            if(ppq.Tax__c !=null){
            taxFlag= false;
            pageprop = new PageReference('/apex/Apttus_Proposal__ProposalGenerate?id='+quoteId);
            pageprop.setRedirect(true);
            return pageprop;
            }
            else{
            taxFlag= true;
            }
          }
        return null;
    }
}