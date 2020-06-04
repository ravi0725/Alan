@isTest(SeeAllData = true)

private class UpdateCompanyNameonLeadEvents_Test
{
    static testMethod void UpdateCompanyNameonLeadEvents_Test1()
    {
        Id leadRcTypeID = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Lead (Customer) Record Type').getRecordTypeId();
        
        Lead ld = new Lead(LastName = 'TestClassLead',RecordtypeId = leadRcTypeID,Company='TestClassNew', Country ='France', Country__c ='France' );
        
        insert ld;    
        
        Event eventObj = new Event();
        eventObj.Subject= '';
        eventObj.WhoId = ld.Id;
        eventObj.Type = 'Other';
        eventObj.ActivityDate = date.today();
        eventObj.DurationInMinutes = 30;
        eventObj.ActivityDateTime = datetime.now();
        insert eventObj;
            
        ld.Company='TestLead Company Name';
        update ld;
    }
}