public class RentalCheckOutController {
    public Flow.Interview.Check_Out_Loaner_Rental rentalCheckOut { get; set; }
    public Apttus_Proposal__Proposal__c getProposal(){
        Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c();
        if(rentalCheckOut != null){
            proposal.Service_Start_Date__c = rentalCheckOut.ProposalServiceStartDate;
            proposal.Service_End_Date__c = rentalCheckOut.ProposalServiceEndDate;
            system.debug('---------proposal----------' + proposal);
            if(proposal.Service_Start_Date__c == null || proposal.Service_End_Date__c == null){
                system.debug('---------proposal----------' + proposal);
                for(Apttus_Config2__LineItem__c	lineItem : [select Id,Service_Start_Date__c,Service_End_Date__c from Apttus_Config2__LineItem__c where 
                     Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__c =: rentalCheckOut.OpportunityId and Apttus_Config2__ConfigurationId__r.Apttus_Config2__Status__c != 'Abandoned' and 
                     Apttus_Config2__ConfigurationId__r.Apttus_Config2__Status__c != 'Superseded' and 
                     Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Primary__c = true
                     order by Apttus_Config2__ConfigurationId__r.Apttus_Config2__VersionNumber__c Desc limit 1]){
                         system.debug(lineItem.Service_End_Date__c + '---------lineItem----------' + lineItem.Service_Start_Date__c);
                    proposal.Service_Start_Date__c = lineItem.Service_Start_Date__c;
                    proposal.Service_End_Date__c = lineItem.Service_End_Date__c;     
                }
            }
        }
        system.debug('---------proposal----------' + proposal);
        return proposal;
    }
    
    @InvocableMethod
   public static List<Loaner_Rentals__c> getLonerRentalRds() {
      
      return [select Id,Name,Display_Field__c,Alltrak_ID__c from Loaner_Rentals__c limit 1];
   }
    
    
    public RentalCheckOutController(Apexpages.StandardController controller){
    }
}