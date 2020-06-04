@isTest
private class MultipleAssetsAndCasesControllerTest{
    
     private static Case cs;
     
     static void setUpData(){
     
        cs = new Case();
        cs.Origin='Phone';
        cs.Status = 'Open';
        cs.status_reason__c='New Unassigned';
        cs.Subject ='XYZ';
        cs.Description='Xyz Description';
        insert cs;
    }
    
    private static testmethod void testNewAsset(){
        
        setUpData();
        Test.startTest();   
            
            Pagereference pgRef = Page.multipleAssetsAndCasesPage;
            pgRef.getParameters().put('id',cs.Id);
            Test.setCurrentPage(pgRef);
            
            MultipleAssetsAndCasesController cont = new MultipleAssetsAndCasesController(new ApexPages.StandardSetController([Select id from case where id=:cs.id]));
            System.assertNotEquals(cont.newAssets(),null);
            System.assertNotEquals(cont.cancel(),null);   
            
        Test.stopTest();
    }       
}