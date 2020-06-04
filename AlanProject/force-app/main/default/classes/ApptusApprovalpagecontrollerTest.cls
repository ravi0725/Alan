@isTest
private class ApptusApprovalpagecontrollerTest{
    
    public static Group grp;
    public static Groupmember grpMember;
    public static List<Apttus_Approval__Approval_Request__c> appovalLst = new List<Apttus_Approval__Approval_Request__c>() ;
    
    static void setUpData(){
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            grp = new Group(Name = 'Apttus Approval Group');
            insert grp;
            
            grpMember = new Groupmember(GroupId=grp.id,UserOrGroupId=UserInfo.getUserId());
            insert grpMember;
        }
        
        appovalLst.add(new Apttus_Approval__Approval_Request__c(Apttus_Approval__Approval_Status__c='Assigned',Apttus_Approval__Assigned_To_Type__c='User' ,
                        Apttus_Approval__Assigned_To_Id__c=UserInfo.getUserId()));
        appovalLst.add(new Apttus_Approval__Approval_Request__c(Apttus_Approval__Approval_Status__c='Assigned',Apttus_Approval__Assigned_To_Type__c='Queue'));
        insert appovalLst;      
        
    }
    
    private static testmethod void testApprovalRequestListnew(){
        
        setUpData();           
        Test.startTest();   
            ApptusApprovalpagecontroller cont = new ApptusApprovalpagecontroller();
        Test.stopTest();
    }

}