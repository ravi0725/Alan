/*****************************************************************************************
    Name        : AcceptProposalCustomController 
    Desc        : Used to merge two vf pages for synchronizing Opportunity with Quotes                                                   
    Project ITEM: ITEM-00758                          
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Chandrakant Dwivedi     11/29/2013          Created
******************************************************************************************/
public class AcceptProposalCustomController{
    
    public String quoteId{get;set;}
    List<Apttus_Proposal__Proposal__c> quotelist{get;set;}
    Public String approvalstatus{get;set;}
    /**
     * Method name  : AcceptProposalCustomController
     * Description  : Constructor of the Controller class - Initializes all the variables.                
     * Return Type  : 
     * Parameter    : 
     **/
    public AcceptProposalCustomController(){
        quotelist=new List<Apttus_Proposal__Proposal__c>();
        quoteId = System.currentPageReference().getParameters().get('id');    
        quotelist =[select id,Apttus_Proposal__Approval_Stage__c from Apttus_Proposal__Proposal__c where id=:quoteId];
        approvalstatus = quotelist.get(0).Apttus_Proposal__Approval_Stage__c ;
        
    }
    
    Public PageReference UpdateStage(){
    //return new PageReference('/apex/Apttus_QPConfig__ProposalAccept?id='+quoteId);
		for(Apttus_Proposal__Proposal__c prop : quotelist){
            prop.Apttus_Proposal__Approval_Stage__c = 'Accepted';
        }
        update quotelist;
        return new PageReference('/'+quoteId);
    }
    
    /**
     * Method name  : callActionMethod
     * Description  : This method is used to redirect the page to quote record.                         
     * Return Type  : PageReference
     * Parameter    : 
     **/
    public PageReference callActionMethod(){
       return  new PageReference('/'+quoteId);     
    }
}