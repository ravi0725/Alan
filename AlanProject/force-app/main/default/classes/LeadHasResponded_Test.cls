@isTest(SeeAllData = true)

private class LeadHasResponded_Test
{


    static testMethod void updateLead()
    {
        Id leadRcTypeID = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Lead (Marketing) Record Type').getRecordTypeId();
        
        Lead ld = new Lead(LastName = 'TestClassLead',RecordtypeId = leadRcTypeID,Company='TestClassNew', Country ='United States', Country__c ='United States' );
        
        insert ld;    

    }
    
    
}