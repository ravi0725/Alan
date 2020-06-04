/*****************************************************************************************
    Name        : ApprovalSkipReasonCOntroller
    Desc        : Used to update the Approval Skip Reason field on Opportunity     
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Prince Leo           21/06/2018          Created
******************************************************************************************/
public class ApprovalSkipReasonCOntroller{

public String OppID{get;set;}
public string errorMsg{get;set;}
public boolean errorPopup{get;set;}
public Boolean EntpriseID {get;set;}
Public String EnterPriseErr {get;set;}
Public String Comments {get;set;}
public ApprovalSkipReasonCOntroller(){
       OppID = System.currentPageReference().getParameters().get('id');
       
       }
    
    public boolean displayPopup {get; set;}     
    
    public PageReference closePopup() {    
    Opportunity Opp  = new Opportunity(id=OppID);
    Opp.Reason_for_Discount__c =Comments;
   
    update Opp;
    
        displayPopup = false;  
       return new PageReference('/'+Opp.id); 
    }  
   
    public void showPopup() {   
       
        displayPopup = true;    
               
    }    
  
}