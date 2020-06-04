@isTest
private class savep1test
{
    
    
	private static testMethod void testAutoRun() 
	{
		Case cs = new Case();
        //cs.AccountId = GeneratetestData.acct.Id;
        //cs.ContactId = GeneratetestData.ct.Id; 
        cs.Status = 'New';
        cs.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('GCCM - Support Case Record Type').getRecordTypeId();                
        cs.Product__c = 'Prolog Manager';
        cs.Origin = 'Chat';
        cs.Serial_Number__c = '12345';        
        cs.TFS_Id__c = '123456';   
        cs.P1_Customer_Follow_up_Notes__c = 'Notes';     
        insert cs;

		test.startTest();
		
			
			PageReference pageRef = Page.p1casefields;
			Test.setCurrentPage(pageRef);
			
			pageRef.getParameters().put('id',cs.id);
			ApexPages.StandardController sc = new ApexPages.standardController(cs);
			
			savep1  controller = new savep1(sc);
			controller.savep1();

		test.stopTest();
	}

}