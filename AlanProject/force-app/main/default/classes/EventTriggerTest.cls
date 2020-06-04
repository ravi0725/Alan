/**
 * Company     : Trimble Software Technology Pvt Ltd.,
 * Description : Controller class for CreateSSM
 * History     :  

 * [16.10.2014] Ankur Patel  Created
 */
 @isTest(seeAllData=true)
public class EventTriggerTest{
    private static testmethod void TestEventTrigger1(){
        Test.startTest();
            //GenerateTestData.customSettingRds();
            GenerateTestData.createPriceList();
            GenerateTestData.createAccount();
            GenerateTestData.createAddress();
            GenerateTestData.createOpportunity();
            GenerateTestData.createProposal();
            GenerateTestData.createEvent();
            update GenerateTestData.eventObj;
        Test.stopTest();
    }   
    
    private static testmethod void TestEventTrigger2(){
        Test.startTest();
            //GenerateTestData.customSettingRds();
            GenerateTestData.createlead();
            
            Event eventObj = new Event();
            eventObj.Subject= '';
            eventObj.WhoId = GenerateTestData.LeadObj.Id;
            eventObj.Type = 'Other';
            eventObj.ActivityDate = date.today();
            eventObj.DurationInMinutes = 30;
            eventObj.ActivityDateTime = datetime.now();
            insert eventObj;
        Test.stopTest();
    }   
    
    private static testmethod void TestEventTrigger3(){
        Test.startTest();
            //GenerateTestData.customSettingRds();
            GenerateTestData.createlead();
            GenerateTestData.createAccount();
            
            Event eventObj = new Event();
            eventObj.Subject= '';
            eventObj.Type = 'Other';
            eventObj.ActivityDate = date.today();
            eventObj.DurationInMinutes = 30;
            eventObj.ActivityDateTime = datetime.now();
            insert eventObj;
            
            eventObj.WhatId = GenerateTestData.acc.Id;
            update eventObj;
        Test.stopTest();
    }
    
    private static testmethod void TestEventTrigger4(){
        Test.startTest();
            GenerateTestData.createAccount();
            
            Event eventObj = new Event();
            eventObj.Subject= 'Event Test Subject';
            eventObj.Type = 'Other';
            eventObj.ActivityDate = date.today() + 2;
            eventObj.DurationInMinutes = 30;
            eventObj.ActivityDateTime = datetime.now();
            insert eventObj;
            
            eventObj.WhatId = GenerateTestData.acc.Id;
            update eventObj;
            
            List<Event> evList = new List<Event>();
            evList.add(eventObj);
        
        	EventHelper.EventBeforeUpdateHandler(evList);
        Test.stopTest();
    } 
    
    private static testmethod void TestEventTrigger5(){
        
        Id leadRcTypeID = Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get('Lead (Marketing) Record Type').getRecordTypeId();
        Id eventRcdTypeId  = Schema.Sobjecttype.Event.getRecordTypeInfosByName().get('Sales Event').getRecordTypeId();
        Lead ld = new Lead(LastName = 'TestClassLead',RecordtypeId = leadRcTypeID,Company='TestClassNew', Phone='89898997', MobilePhone='9090909009',Country ='India', Country__c ='India', Email='test@rest.com', Street='AvenueStreet', City='Pune', State='Andhra', PostalCode='516434');
        insert ld;    
        
        DateTime dtStart = System.now();        
        DateTime dtEnd = dtStart.addDays(1);        
        Event leadEvt = new Event(Type = 'Meeting - Demo',StartDateTime = dtStart, Description='````````````Lead Info````````````'+'\n'+'Country: India'+'\n'+'````````````````````````````````````````````````````'+'\n', EndDateTime = dtEnd, WhoId = ld.Id, Subject = 'Hardware Installation', RecordTypeId = eventRcdTypeId);
        insert leadEvt;
        
        leadEvt.Subject = 'Hardware Installation Lead Event';
        update leadEvt;
    }
}