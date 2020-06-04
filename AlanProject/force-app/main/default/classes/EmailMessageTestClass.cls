/************************************************************************************
* Name          :    EmailMessageTestClass 
* Description   :    
* Author        :    Chandrakant

Modification Log
------------------------------------------------------------------------------------------
Date             Developer                Comments
------------------------------------------------------------------------------------------
05/28/2014       Chandrakant                  Created
****************************************************************************************/

@isTest(seealldata=false)
public class EmailMessageTestClass {
    
    static testMethod void testEmailMessageTrigger() {
        
        //Creation of test data
        
        datetime dt = system.Now();
        List<Case> lstNewCase = new List<Case>();
        Case newCase = new Case();
        newCase.Origin='Phone';
        newCase.Status = 'Open';
        newCase.status_reason__c='New Unassigned';
        newCase.Subject ='XYZZ';
        newCase.Description='Xyz Description';
        newCase.To_Address__c='XYZ';
        newCase.status_reason__c ='Waiting for Client Response';
        newCase.RecordTypeId = '01231000000tYGq';
        newCase.Product_Group__c = 'Vico';
        lstNewCase.add(newCase);
        Case newCase1 = new Case();
        newCase1.Origin='Phone';
        newCase1.Status = 'Open';
        newCase1.status_reason__c='New Unassigned';
        newCase1.Subject ='XYZZ';
        newCase1.Description='Xyz Description';
        newCase1.To_Address__c='XYZ';
        newCase1.status_reason__c ='Waiting for Client Response';
        newCase1.RecordTypeId = '01231000000tYGq';
        newCase1.Product_Group__c = 'Vico';
        lstNewCase.add(newCase1);
        
        insert lstNewCase;
        
        User u = [select firstname from user where id=:userinfo.getuserid()];
        task t=new task();
        t.type='Call';
        t.ActivityDate=Date.Today();
        t.Status='New';
        t.Priority ='Normal';
        t.WhatId=lstNewCase[0].id;
        t.ownerid=u.id;
        insert t;
        
        task t2=new task();
        t2.type='Call';
        t2.ActivityDate=Date.Today();
        t2.Status='New';
        t2.Priority ='Normal';
        t2.WhatId=lstNewCase[1].id;
        t2.ownerid=u.id;
        insert t2;
        
        List<EmailMessage> lstEM= new List<EmailMessage>();
        EmailMessage em= new EmailMessage();
        em.ParentId= lstNewCase[0].id;
        em.ActivityId =t.id;
        em.ToAddress ='satyamrgpv@gmail.com';
        em.Incoming = false;
        em.Status = '0';
        em.subject = 'XYZ';
        em.TextBody = 'Test XYZ';
        lstEM.add(em);
        
        /* EmailMessage em1= new EmailMessage();
em1.ParentId= lstNewCase[1].id;
em1.ActivityId =t.id;
em1.ToAddress ='satyamrgpv2@gmail.com';
em1.Incoming = true;
em1.Status = '0';
em1.Subject = 'XYZ 1';
em1.TextBody = 'Test XYZ 1';
lstEM.add(em1); */
        EmailMessage email = new EmailMessage();
        email.FromAddress = 'test@abc.org';
        email.Incoming = True;
        email.ToAddress= 'test@xyz.org';
        email.Subject = 'Test email';
        email.HtmlBody = 'Test email body';
        email.ParentId = lstNewCase[1].Id; 
        email.ActivityId =t2.id;
        lstEM.add(email);
        
        insert lstEM;
        /*system.debug('--listEm--'+lstEM);
em = [select Id,ParentId from EmailMessage where Incoming = True and id in: lstEM];  
system.debug('---emlist--'+em);*/
        test.startTest();
        EmailMessageHandler.setLaunchControl();
        Test.stopTest();        
    }
    
    static testMethod void testEmailMessageTrigger2() {
        
        //Creation of test data
        
        datetime dt = system.Now();
        List<Case> lstNewCase = new List<Case>();
        Case newCase = new Case();
        newCase.Origin='Phone';
        newCase.Status = 'Open';
        newCase.status_reason__c='New Unassigned';
        newCase.Subject ='XYZZ';
        newCase.Description='Xyz Description';
        newCase.To_Address__c='';
        newCase.status_reason__c ='Waiting for Client Response';
        newCase.RecordTypeId = '01231000000tYGq';
        newCase.Product_Group__c = 'Vico';
        lstNewCase.add(newCase);
        Case newCase1 = new Case();
        newCase1.Origin='Phone';
        newCase1.Status = 'Inprogress';
        newCase1.status_reason__c='New Unassigned';
        newCase1.Subject ='XYZZ';
        newCase1.Description='Xyz Description';
        newCase1.To_Address__c='';
        newCase1.status_reason__c ='Waiting for Client Response';
        newCase1.RecordTypeId = '01231000000tYGq';
        newCase1.Product_Group__c = 'Vico';
        lstNewCase.add(newCase1);
        
        insert lstNewCase;
        
        User u = [select firstname from user where id=:userinfo.getuserid()];
        task t=new task();
        t.type='Call';
        t.ActivityDate=Date.Today();
        t.Status='New';
        t.Priority ='Normal';
        t.WhatId=lstNewCase[0].id;
        t.ownerid=u.id;
        insert t;
        
        task t2=new task();
        t2.type='Call';
        t2.ActivityDate=Date.Today();
        t2.Status='New';
        t2.Priority ='Normal';
        t2.WhatId=lstNewCase[1].id;
        t2.ownerid=u.id;
        insert t2;
        
        List<EmailMessage> lstEM= new List<EmailMessage>();
        EmailMessage em= new EmailMessage();
        em.ParentId= lstNewCase[0].id;
        em.ActivityId =t.id;
        em.ToAddress ='';
        em.Incoming = false;
        em.Status = '0';
        em.subject = 'XYZ';
        em.TextBody = 'Test XYZ';
        lstEM.add(em);
        
        EmailMessage email = new EmailMessage();
        email.FromAddress = 'test@abc.org';
        email.Incoming = True;
        email.ToAddress= 'test@xyz.org';
        email.Subject = 'Test email';
        email.HtmlBody = 'Test email body';
        email.ParentId = lstNewCase[1].Id; 
        email.ActivityId =t2.id;
        lstEM.add(email);
        
        insert lstEM;
        
        test.startTest();
        EmailMessageHandler.setLaunchControl();
        Test.stopTest();        
    }
    
    static testMethod void testEmailMessageTrigger3() {
        
        //Creation of test data
        
        datetime dt = system.Now();
        List<Case> lstNewCase = new List<Case>();
        Case newCase = new Case();
        newCase.Origin='Phone';
        newCase.Status = 'Open';
        newCase.status_reason__c='New Unassigned';
        newCase.Subject ='XYZZ';
        newCase.Description='Xyz Description';
        newCase.To_Address__c='';
        newCase.status_reason__c ='Waiting for Client Response';
        newCase.RecordTypeId = '01231000000tYGq';
        newCase.Product_Group__c = 'Vico';
        lstNewCase.add(newCase);
        
        insert lstNewCase;
        
        List<EmailMessage> lstEM= new List<EmailMessage>();
        
        EmailMessage email = new EmailMessage();
        email.FromAddress = 'test@abc.org';
        email.Incoming = True;
        email.ToAddress= 'test@xyz.org';
        email.Subject = 'Test email';
        email.HtmlBody = 'Test email body';
        email.ParentId = lstNewCase[0].Id; 
        lstEM.add(email);
        
        User user1 = new User();
        user1.Username = 'sagaaaaaaaa23@deloitte.com.a123';
        user1.Email = 'sagamehta@deloitte.com';
        user1.LastName = 'Administrator';
        user1.FirstName = 'Data';
        user1.Alias = 'Test123';
        user1.ProfileID = [select Id from Profile where Name =: 'System Administrator' limit 1].Id;
        user1.LocaleSidKey = 'en_US';
        user1.LanguageLocaleKey = 'en_US';
        user1.Country = 'India';
        user1.Division__c = 'Infrastructure';
        user1.TimeZoneSidKey = 'America/Los_Angeles';
        user1.EmailEncodingKey='UTF-8';
        
        System.runAs(user1){
            insert lstEM;
            update lstEM;
        }   
    }
}