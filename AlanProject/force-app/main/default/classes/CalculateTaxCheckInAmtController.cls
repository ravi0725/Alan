/*****************************************************************************************
    Name        : FinalizeOpportunityCustomController 
    Desc        :Used for update Opportunity's "Stage" field to "6 - Closed Won" and update Quote/Proposal "Approval Stage" = Order Submitted.
    Project Item : ITEM-00763, ITEM-00800
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Chandrakant Dwivedi     11/29/2013          Created
******************************************************************************************/
public class CalculateTaxCheckInAmtController{
    
    public String quoteId{get;set;}
    public String oppid;
    public decimal taxAmount;
    public boolean taxFlag{get;set;}
    public boolean quoteFlag{get;set;}
    public boolean recalculateTax{get;set;}
    public String errorMsg{get;set;}
    public Boolean errorPopup{get;set;}
    public Boolean addrChange {get; set;}
    List<opportunity> opplist=new List<opportunity>();
    List<Apttus_Proposal__Proposal__c> quotelist=new List<Apttus_Proposal__Proposal__c>();
    QuotePropCalcTax qpct = new QuotePropCalcTax ();
    
    /**
     * Method name  : FinalizeOpportunityCustomController
     * Description  : Constructor of the Controller class - Initializes all the variables.                
     * Return Type  : 
     * Parameter    : 
     **/
    public CalculateTaxCheckInAmtController(){
        taxFlag = false;
        //quoteFlag = false;
        recalculateTax = false;
        addrChange = false;
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
       List<Apttus_Proposal__Proposal__c> Proposallist= new List<Apttus_Proposal__Proposal__c>();
       Proposallist = [Select Tax__c,Bill_to_Address__c ,Apttus_Proposal__Opportunity__r.Bill_To_Account__c,Apttus_QPConfig__BillToAccountId__c ,Address_Changed__c, Apttus_Proposal__Opportunity__r.Bill_to_Address__c,Recalculate_tax__c,Initial_Price__c from Apttus_Proposal__Proposal__c where id =:quoteId];  
       Proposallist.get(0).Bill_to_Address__c = Proposallist.get(0).Apttus_Proposal__Opportunity__r.Bill_to_Address__c;
     //Proposallist.get(0).Ship_to_Address1__c  = Proposallist.get(0).Apttus_Proposal__Opportunity__r.Ship_to_Address1__c;
       Proposallist.get(0).Apttus_QPConfig__BillToAccountId__c = Proposallist.get(0).Apttus_Proposal__Opportunity__r.Bill_To_Account__c;
       ProposalList.get(0).Address_Changed__c = False;
       Update ProposalList.get(0);
      PageReference pageprop;
        pageprop = new PageReference('/apex/QuoteProposalCalculateTax?id='+quoteId);
            pageprop.setRedirect(true);
            return pageprop;
       
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
        Proposallist = [Select Tax__c,Address_Changed__c, Recalculate_tax__c,Initial_Price__c from Apttus_Proposal__Proposal__c where id =:quoteId];  
        //PageReference pageprop;
        system.debug('taxAmount '+Proposallist.get(0).Initial_Price__c);
         if(Proposallist.get(0).Address_Changed__c == true){
            addrChange = true;
            return null;
            /*pageprop = new PageReference('/apex/CalculateTaxCheckInAmt?id='+quoteId);
            pageprop.setRedirect(true);
            return pageprop;*/
        }else
        {
            system.debug('reched tax');
            PageReference pageprop;
            pageprop = new PageReference('/apex/QuoteProposalCalculateTax?id='+quoteId);
            pageprop.setRedirect(true);
            return pageprop;
            }
            
            
     }
     
    public pageReference openCalculateTax(){
        PageReference pageprop;
        pageprop = new PageReference('/apex/CalculateTaxCheckInAmt?id='+quoteId);
        pageprop.setRedirect(true);
        return pageprop;
    }
     
      /**
     * Method name  : UpdateAddressofLines
     * Description  : This method is used to update Proposal Lines and Line Items related to an Proposal
     *                
     * Parameter    : 
     **/
    public pageReference UpdateAddressofLines(){
        system.debug('--updateEntered--');
        List<Apttus_Proposal__Proposal__c> Proposallist= new List<Apttus_Proposal__Proposal__c>();
        List<Apttus_Proposal__Proposal_Line_Item__c> ProposalLines = new List<Apttus_Proposal__Proposal_Line_Item__c>();
        List<Apttus_Config2__LineItem__c> Lines = new List<Apttus_Config2__LineItem__c>();
        Proposallist = [Select Tax__c,Apttus_QPConfig__BillToAccountId__c,Bill_to_Address__c,ship_to_Address1__c,Recalculate_tax__c,Initial_Price__c from Apttus_Proposal__Proposal__c where id =:quoteId];  
        ProposalLines = [select id,Bill_To_Address__c,Ship_To_Address1__c from Apttus_Proposal__Proposal_Line_Item__c where Apttus_Proposal__Proposal__c=:quoteId];
        Lines = [select id,Bill_To_Address__c,Ship_To_Address1__c from Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c=:quoteId];
        
        for(Apttus_Proposal__Proposal_Line_Item__c PrLines : ProposalLines)
        {
        Prlines.Bill_To_Address__c = Proposallist.get(0).Bill_to_Address__c;
        PrLines.Ship_To_Address1__c = Proposallist.get(0).ship_to_Address1__c;
       
        }
        
        for(Apttus_Config2__LineItem__c Li : Lines)
        {
        Li.Bill_To_Address__c = Proposallist.get(0).Bill_to_Address__c;
        Li.Ship_To_Address1__c = Proposallist.get(0).ship_to_Address1__c;
        }
        system.debug('--ProposalLines.size()--'+ProposalLines.size()+'--Lines.size()--'+Lines.size());
        if(ProposalLines.size()>0 && Lines.size()>0){
        ProposalList.get(0).Address_Changed__c = False;
        Update ProposalList.get(0);
        update ProposalLines;
        update Lines;
        
        }
         
        PageReference pageprop;
        pageprop = new PageReference('/apex/QuoteProposalCalculateTax?id='+quoteId);
        pageprop.setRedirect(true);
        return pageprop;
        
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