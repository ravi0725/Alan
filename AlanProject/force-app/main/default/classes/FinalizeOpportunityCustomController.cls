/*****************************************************************************************
    Name        : FinalizeOpportunityCustomController 
    Desc        :Used for update Opportunity's "Stage" field to "6 - Closed Won" and update Quote/Proposal "Approval Stage" = Order Submitted.
    Project Item : ITEM-00763, ITEM-00800
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Chandrakant Dwivedi     11/29/2013          Created
******************************************************************************************/
public class FinalizeOpportunityCustomController{
    public string QuoteName{get;set;}
    public boolean ProfessionalService {get;set;}
    public boolean creditcheck{get;set;}
    public String quoteId{get;set;}
    public String oppid;
    public decimal taxAmount;
    public boolean taxFlag{get;set;}
    public boolean quoteFlag{get;set;}
    List<opportunity> opplist=new List<opportunity>();
    List<Apttus_Proposal__Proposal__c> quotelist=new List<Apttus_Proposal__Proposal__c>();
    QuotePropCalcTax qpct = new QuotePropCalcTax ();
    public boolean errorPopUp{get;set;}
    public string errorMessage{get;set;}
    public boolean orderSubmitted{get;set;}
    public boolean ValidationCheck {get;set;}
    Public String ShippingMethod{get;set;}
    Public String FriTerms{get;set;}
    Public boolean MEPNAValidationCheck{get;set;}
    /**
     * Method name  : FinalizeOpportunityCustomController
     * Description  : Constructor of the Controller class - Initializes all the variables.                
     * Return Type  : 
     * Parameter    : 
     **/
    public FinalizeOpportunityCustomController(){
        String profileName = [select Id,Name from Profile where Id =: userinfo.getProfileId()].Name;
        taxFlag = false;
        quoteFlag = false;
        orderSubmitted = false;
        errorPopUp = false; //Added to have a pop up if an error occurs on submitting order
        quoteId= System.currentPageReference().getParameters().get('id');  
        taxAmount = [Select tax__c from Apttus_Proposal__Proposal__c where id =:quoteId].tax__c;
        ShippingMethod = [Select Freight_Method__c from Apttus_Proposal__Proposal__c where id =:quoteId].Freight_Method__c;
        FriTerms =[Select Freight_Terms__c from Apttus_Proposal__Proposal__c where id =:quoteId].Freight_Terms__c;
        if(profileName == 'MEPNA - Sales Ops' && (ShippingMethod== Null || ShippingMethod =='' || FriTerms ==Null || FriTerms ==''))
        {
          ValidationCheck = True;
        }
        else 
         ValidationCheck = False;
        if(taxAmount==null){
            taxFlag = false;
            
        }else{
            quoteFlag = false;
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
    public PageReference updateopportunity(){
     try{
     if(ValidationCheck == False){
       qpct.UpdateTax('1');
       QuoteName = qpct.QuoteName;
       //Added to have a pop up if an error occurs on submitting order
       if(qpct.errorPopup == true)
        errorPopUp = true;
       if(qpct.errorMsg != null || qpct.errorMsg !='')
        errorMessage = qpct.errorMsg;       
       
       if(errorPopup != true && errorMessage== null && qpct.CreditCheck != true){
           orderSubmitted = true;
           quotelist=[select Apttus_Proposal__Opportunity__c from Apttus_Proposal__Proposal__c where id=:quoteId];
           opplist =[select Name,StageName from opportunity where id=:quotelist.get(0).Apttus_Proposal__Opportunity__c ];
           if(opplist.size()>0){
              for(opportunity op:opplist ){
                op.StageName = Label.X6_Closed_Won;            
              }
              update opplist;
           }
           if(quotelist.size()>0){
              for(Apttus_Proposal__Proposal__c quote:quotelist){
                 quote.Apttus_Proposal__Approval_Stage__c = Label.Order_Submitted;             
              }
              update quotelist;
           }
       
       //return new PageReference('/'+quoteId);
       return null; 
       }
       else if(qpct.CreditCheck == true){
       
        CreditCheck = True;
        return null; 
       }
       else if(qpct.ProfessionalService==true){
       ProfessionalService = True;
       return null;
       }
       else
       {
       return null;
       }
     }
     else 
     {
     MEPNAValidationCheck = True;
     return null;
     }
     }
     catch(Exception e) {
         //throw new MerchandiseException(
                //'Merchandise item could not be inserted.', e);
         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
         return null;
     }
     
   }
}