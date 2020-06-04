/*****************************************************************************************
    Name        : FinalizeOpportunityCustomController 
    Desc        :Used for update Opportunity's "Stage" field to "6 - Closed Won" and update Quote/Proposal "Approval Stage" = Order Submitted.
    Project Item : ITEM-00763, ITEM-00800
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Chandrakant Dwivedi     11/29/2013          Created
Prince Leo              10/19/2014          Modified
******************************************************************************************/
public class AcceptaggrementCheckController{
    
    public String quoteId{get;set;}
    public String oppid;
    public decimal taxAmount;
    public boolean taxFlag{get;set;}
    public boolean quoteFlag{get;set;}
    public boolean recalculateTax{get;set;}
    public String errorMsg{get;set;}
    public Boolean errorPopup{get;set;}
    public boolean checkaggrflag{get;set;}
    List<opportunity> opplist=new List<opportunity>();
    List<Apttus_Proposal__Proposal__c> quotelist=new List<Apttus_Proposal__Proposal__c>();
    QuotePropCalcTax qpct = new QuotePropCalcTax ();
    
    /**
     * Method name  : FinalizeOpportunityCustomController
     * Description  : Constructor of the Controller class - Initializes all the variables.                
     * Return Type  : 
     * Parameter    : 
     **/
    public AcceptaggrementCheckController(){
        taxFlag = false;
        //quoteFlag = false;
        recalculateTax = false;
        quoteId= System.currentPageReference().getParameters().get('id');
        List<Apttus_Proposal__Proposal__c> quoteList = new List<Apttus_Proposal__Proposal__c>();
        List<Attachment> attachlist=new List<Attachment>();
        quoteList = [Select Tax__c, Recalculate_tax__c,Custom_T_C__c from Apttus_Proposal__Proposal__c where id =:quoteId]; 
        attachlist=[select id,Name from attachment where Parentid =: quoteId];
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
        system.debug('attachlist'+attachlist);
        if(attachlist.size()>0){
           for(Attachment at:attachlist){
              String name=at.Name.toLowerCase();
              String containcheck=System.Label.Attachement_Word.toLowerCase();
              String[] selectedvalues = containcheck.split(',');
              for (String selectedvalue: selectedvalues){
              system.debug('containcheck'+containcheck);
              system.debug('name'+name);
              if(at.Name !=null){
              // && (at.Name.toLowerCase().contains(selectedvalue))){ (Validation Removed as per TT 76145)
                 checkaggrflag =true;
                }
              }
           }
        
        }
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
        Proposallist = [Select Tax__c, Recalculate_tax__c,Initial_Price__c,Standard_T_Cs__c from Apttus_Proposal__Proposal__c where id =:quoteId];  
        PageReference pageprop;
        system.debug('taxAmount '+Proposallist.get(0).Initial_Price__c);
        system.debug('checkaggrflag '+checkaggrflag );
        system.debug('Proposallist.get(0).Standard_T_Cs__c'+Proposallist.get(0).Standard_T_Cs__c);
        if(Proposallist.get(0).Standard_T_Cs__c ==true && checkaggrflag ==true){
            system.debug('reched tax');
            pageprop = new PageReference('/apex/AcceptRedirect?id='+quoteId);
            pageprop.setRedirect(true);
            return pageprop;
        }else{
             system.debug('taxAmount '+Proposallist.get(0).Initial_Price__c);
             errorPopup = true;     
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