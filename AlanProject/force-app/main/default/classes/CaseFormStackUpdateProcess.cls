public class CaseFormStackUpdateProcess {
 @InvocableMethod(label='Remove unwanted text received from FormStack' description='Update only seleted value to Case record from FormStack')
    public static void removeUnwantedString(List<Id> caseIDs){
        List<Case> cases = [SELECT Id, Subject, Representative_Knowledge__c, Product_Satisfaction__c, Response_Time__c, Support_Time__c FROM Case WHERE Id IN: caseIDs];
        system.debug(' cases - size ========================>'+cases.size());
        for(Case cs : cases){
            if(cs.Representative_Knowledge__c.contains('='))
             cs.Representative_Knowledge__c = cs.Representative_Knowledge__c.substringAfter('=').trim();
            if(cs.Product_Satisfaction__c.contains('='))
             cs.Product_Satisfaction__c  = cs.Product_Satisfaction__c.substringAfter('=').trim();
            if(cs.Response_Time__c.contains('='))
             cs.Response_Time__c    = cs.Response_Time__c.substringAfter('=').trim();
            if(cs.Support_Time__c.contains('='))
             cs.Support_Time__c    = cs.Support_Time__c.substringAfter('=').trim();
        }
        system.debug('cases =========>'+cases);
        update cases;
    }
}