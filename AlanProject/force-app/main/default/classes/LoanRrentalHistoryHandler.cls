/*****************************************************************************************
    Name    : LoanRentalHistoryHandler 
    Desc    : Used to execute logic from LoanerRentalHistoryListner Trigger on various events
                            
Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Prince Leo          11/09/2017          Created
******************************************************************************************/
Public class LoanRrentalHistoryHandler {

Public static void updateStartdateEnddate(List<Loaner_Rental_History__c> RentalList){
Map<Id,Date> RentalMap = new Map<Id,Date>();
List<Loaner_Rental_History__c> NewRentalList = new List<Loaner_Rental_History__c>();
Set<ID>RentalID = new Set<ID>();
List<Apttus_Proposal__Proposal__c>ProposalList = new List<Apttus_Proposal__Proposal__c>();
List<Apttus_Config2__ProductConfiguration__c> ProdConfigList = new List<Apttus_Config2__ProductConfiguration__c>();
List<Apttus_Config2__LineItem__c> LineItem = new List<Apttus_Config2__LineItem__c>();
List<Apttus_Proposal__Proposal_Line_Item__c> ProposalLineItem = new List<Apttus_Proposal__Proposal_Line_Item__c>();
List<Apttus_Config2__LineItem__c> UpdateLineItem = new List<Apttus_Config2__LineItem__c>();
List<Apttus_Proposal__Proposal_Line_Item__c> UpdateProposalLineItem = new List<Apttus_Proposal__Proposal_Line_Item__c>();
Set<ID> ProposalID = new Set<ID>();
Set<ID>ProductConfigID = new Set<ID>();
Set<ID>OPPID = new Set<ID>();
 for(Loaner_Rental_History__c Ren : RentalList)
 {
  RentalID.add(Ren.id);
 }
 
 NewRentalList = [Select id,Opportunity__c,Loaner_Rentals__r.Product__c,Check_Out_Date__c from Loaner_Rental_History__c where id in: RentalID];
 
 for(Loaner_Rental_History__c Ren : NewRentalList)
 {
    if(Ren.Loaner_Rentals__r.Product__c != Null && Ren.Check_Out_Date__c != Null)
          {
               RentalMap.put(Ren.Loaner_Rentals__r.Product__c,Ren.Check_Out_Date__c);
          }
     if(Ren.Opportunity__c != Null)
         {
               OPPID.add(Ren.Opportunity__c);
         }
 }
 
        for(Apttus_Proposal__Proposal__c Pro : [select id from Apttus_Proposal__Proposal__c where Apttus_Proposal__Opportunity__c IN: OPPID and Apttus_Proposal__Primary__c =TRUE])
           {
                ProposalID.add(Pro.Id);
           }      
           
        for(Apttus_Config2__ProductConfiguration__c Config : [Select id from Apttus_Config2__ProductConfiguration__c where Apttus_QPConfig__Proposald__c IN: ProposalID and Apttus_Config2__Status__c='Finalized'])
           {
                ProductConfigID.add(Config.Id);
           }   
  LineItem = [select id,Service_Start_Date__c,Service_End_date__c,Apttus_Config2__ProductId__c from Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c IN:ProductConfigID];
  ProposalLineItem = [select id,Service_Start_Date__c,Service_End_date__c,Apttus_Proposal__Product__c from Apttus_Proposal__Proposal_Line_Item__c where Apttus_Proposal__Proposal__c IN: ProposalID];
          for(Apttus_Config2__LineItem__c Li : LineItem)
          { 
             if(RentalMap.get(Li.Apttus_Config2__ProductId__c) != Null)
                {
                  Li.Service_Start_Date__c = RentalMap.get(Li.Apttus_Config2__ProductId__c);
                  Li.Service_End_date__c = Li.Service_Start_date__c.addmonths(12) - 1;
                  UpdateLineItem.add(Li);
                } 
          }
  
  
          for(Apttus_Proposal__Proposal_Line_Item__c ProLi : ProposalLineItem)
          { 
             if(RentalMap.get(ProLi.Apttus_Proposal__Product__c) != Null)
                {
                  ProLi.Service_Start_Date__c = RentalMap.get(ProLi.Apttus_Proposal__Product__c);
                  ProLi.Service_End_date__c = ProLi.Service_Start_date__c.addmonths(12) - 1;
                  UpdateProposalLineItem.add(ProLi);
                } 
          }
          
          system.debug('>>>>>>>>>RentalMap>>>>>>>>>>>>>'+RentalMap);
          system.debug('>>>>>>>>>OPPID>>>>>>>>>>>>>'+OPPID);
          system.debug('>>>>>>>>>ProposalID>>>>>>>>>>>>>'+ProposalID);
          system.debug('>>>>>>>>>ProductConfigID>>>>>>>>>>>>>'+ProductConfigID);
          system.debug('>>>>>>>>>UpdateLineItem>>>>>>>>>>>>>'+UpdateLineItem);
          system.debug('>>>>>>>>>UpdateProposalLineItem>>>>>>>>>>>>>'+UpdateProposalLineItem);
          
          
        if(UpdateLineItem.size()>0) update UpdateLineItem;
        if(UpdateProposalLineItem.size()>0) update UpdateProposalLineItem;
}
}