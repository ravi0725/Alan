/*****************************************************************************************
    Name    : LoanerRentalHistoryListner 
    Desc    : Used to invoke LoanerRentalHistoryHandler Class
                            
Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Prince Leo          11/09/2017          Created
******************************************************************************************/
trigger LoanerRentalHistoryListner on Loaner_Rental_History__c (before insert, before update, after insert,after update,after delete) {

  if(trigger.isAfter && trigger.isInsert){
           LoanRrentalHistoryHandler.updateStartdateEnddate(trigger.new);
        }
}