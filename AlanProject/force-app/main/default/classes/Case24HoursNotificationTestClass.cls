/************************************************************************************
* Name          :    Case24HoursNotificationTestClass
* Description   :    
* Author        :    Ashfaq

Modification Log
----------------
Date             Developer                Comments
------------------------------------------------------------------------------------------
10/3/2013                   Ashfaq                  Created
*/

@isTest
public class Case24HoursNotificationTestClass {
	
	static testMethod void testCaseTrigger() {
		
		//Creation of test data
				
		datetime dt = system.Now();
		
		Case newCase = new Case();
		newCase.Origin='Phone';
		newCase.Status = 'Open';
		newCase.status_reason__c='New Unassigned';
		newCase.Subject ='XYZ';
		newCase.Description='Xyz Description';
		insert newCase;
				
		test.startTest();
		newCase.Case24HoursTimeStamp__c = dt;
		//insert c;
		system.assert(newCase.Case24HoursTimeStamp__c == dt); 
		Test.stopTest();
		
		
	}


}