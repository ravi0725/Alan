public class CaseFormStackUpdateContactDate {
	@InvocableMethod(label='Update Contat Last Email Send Date' description='Update Contat Last Email Send Date')
    public static void updateContactSurveySentDate(List<Id> caseIDs){
        List<Case> updatedCases = [SELECT Id, ContactId, Contact.Last_Case_Survey_Sent__c FROM Case WHERE Id IN: caseIDs];
        Set<Id> ContactIDs = new Set<Id>();
        for(Case cs : updatedCases){
            ContactIDs.add(cs.ContactId);
        }
        
        List<Contact> lstContacts = [SELECT Id, Last_Case_Survey_Sent__c FROM Contact WHERE Id IN : ContactIDs];
        for(Contact ct : lstContacts){
            ct.Last_Case_Survey_Sent__c = system.today();
        }
        if(lstContacts.size() > 0)
        	update lstContacts;
    }
}