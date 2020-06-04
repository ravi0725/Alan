@isTest
public class ApptusApproveRejectControllernewTest{

    private static List<Apttus_Approval__Approval_Request__c> appovalLst = new List<Apttus_Approval__Approval_Request__c>() ;
    private static attachment attach;
        
    static void setUpData(){
        
        appovalLst.add(new Apttus_Approval__Approval_Request__c(Apttus_Approval__Approval_Status__c='Assigned',Apttus_Approval__Assigned_To_Type__c='User' ,
                            Apttus_Approval__Assigned_To_Id__c=UserInfo.getUserId()));
        appovalLst.add(new Apttus_Approval__Approval_Request__c(Apttus_Approval__Approval_Status__c='Assigned',Apttus_Approval__Assigned_To_Type__c='Queue'));
        insert appovalLst;  
        
        attach = new Attachment(name='Test Attach',ParentId=appovalLst[0].Id,body=blob.valueOf('my attachment text'));
        insert attach;      
    }
    
    private static testmethod void testapprvedstatus(){
        
        setUpData();
        Test.startTest();        
            Pagereference pgRef = Page.CustomApprovePage;
            pgRef.getParameters().put('id',appovalLst[0].id);                         
            Test.setCurrentPage(pgRef);
            
            ApptusApproveRejectControllernew cont = new ApptusApproveRejectControllernew(new ApexPages.StandardController(appovalLst[0]));
            cont.apprvedstatus();
            System.assertEquals(cont.approval.Apttus_Approval__Approval_Status__c ,'Approved');

        Test.stopTest();
        
    }  
    
    private static testmethod void testrejectstatus(){
        
        setUpData();
        Test.startTest();        
            Pagereference pgRef = Page.CustomApprovePage;
            pgRef.getParameters().put('id',appovalLst[0].id);                         
            Test.setCurrentPage(pgRef);
            
            ApptusApproveRejectControllernew cont = new ApptusApproveRejectControllernew(new ApexPages.StandardController(appovalLst[0]));
            cont.rejectstatus();
            System.assertEquals(cont.approval.Apttus_Approval__Approval_Status__c ,'Rejected');

        Test.stopTest();
        
    }  
    
    
    private static testmethod void testpageReference(){
        
        setUpData();
        Test.startTest();        
            Pagereference pgRef = Page.CustomApprovePage;
            pgRef.getParameters().put('id',appovalLst[0].id);                         
            Test.setCurrentPage(pgRef);
            
            ApptusApproveRejectControllernew cont = new ApptusApproveRejectControllernew(new ApexPages.StandardController(appovalLst[0]));
            System.assertNotEquals(cont.addcomment(),null);
            System.assertNotEquals(cont.attachfile(),null);
            System.assertEquals(cont.getAttach().size(),1);
        Test.stopTest();
        
    }  

}