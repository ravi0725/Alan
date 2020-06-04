/*
* Author:         Ankur
* Last Update:    Aug 8, 2017
* Version:        1.0
* Description:    Agreement PDF controller
*
* History:      

    Aug 8, 2017 Version - 1.0 - Kumar: Agreement PDF controller
*/
public class AgreementPDFController {
    public List<Loaner_Rental_History__c> loanerList{get;set;}
    public Case cs{get;set;}
    public AgreementPDFController(ApexPages.StandardController controller){
        cs = [select Id,CaseNumber,Account.Name, Selected_Shipping_Address__c, Contact.Name,Contact.Phone,Contact.Email
              from Case where Id =: controller.getId()];
        getLoanerList();
    }
    
    public void getLoanerList(){
        loanerList = new List<Loaner_Rental_History__c>();
        loanerList = [select Name,Account__c,Alltrak_ID__c,Case__c,Check_In_Date__c,Check_Out_Date__c,Loaner_Rentals__c,Loaner_Rentals__r.Name,
                      Model__c,Opportunity__c,Serial_Number__c from Loaner_Rental_History__c where Case__c =: cs.Id];
    }
}