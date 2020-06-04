/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class CustomCaseApprovalEmailControllerTest {
     

    public static Country_Region_Mapping__c cust;
    public static Geospatial_Country_Region_Mapping__c custRegMap ;
    public static UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
    public static Profile profile = [Select Id from Profile where name = 'System Administrator'];
    public static User thisUser;
    public static User portalAccountOwner ;
    
    static void setUpData(){
    
        cust = new Country_Region_Mapping__c(name='India',Region__c='India');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='India',Region__c='India');
        insert custRegMap;
        
        thisUser = [ select Id , name from User where Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            portalAccountOwner = new User(UserRoleId = portalRole.Id,ProfileId = profile.Id,Username = System.now().millisecond() + 'test2@test.com',
                Alias = 'Test', Email='test@test.com',EmailEncodingKey='UTF-8', Firstname='Test',Lastname='Suite',LanguageLocaleKey='en_US',
                LocaleSidKey='en_US',TimeZoneSidKey='America/Chicago',Country='India');
            //insert portalAccountOwner;
        }   
    }       
    /**
     * Class Constructor
     */
    private CustomCaseApprovalEmailControllerTest() {
    }
    
    /**
     * Tests the controller
     */
    static testmethod void test1() {
        
        CustomCaseApprovalEmailControllerTest testController = new CustomCaseApprovalEmailControllerTest();
        
        // test the approval email 
        testController.testApprovalEmail1();
        
    }
    
    /**
     * Test the approval email 
     */
    private void testApprovalEmail1() {
        setUpData();
        // STEP I - Create a new case
        Case caseSO = new Case(Status = 'New', 
                               Origin = 'Web', 
                               Type = 'Other', 
                               Subject = 'Test Case', 
                               Description = 'Test Case', 
                               Reason = 'Other');
        
        insert caseSO;
        
        // STEP II - Create a new process
        Apttus_Approval__Approval_Process__c processSO = Apttus_Approval.TestSupport.createApprovalProcess('TEST-' + Datetime.now().format(), 
                                                                                                           1,
                                                                                                           'Case',
                                                                                                           null,
                                                                                                           null,
                                                                                                           null,
                                                                                                           null, 
                                                                                                           null, 
                                                                                                           true);
                                                              
        // STEP III - Create approval users
        User userSO = thisUser;
        User userSO2 = null;
        //User thisUser = [ select Id from User where Id = :UserInfo.getUserId()];
        /*System.runAs(thisUser) {
            userSO = Apttus_Approval.TestSupport.createUser('assignee1@approvals.xyz.com', 
                                                            'ast1', 
                                                            'assignee1',
                                                            'tester',
                                                            'assignee1@approvals.xyz.com',
                                                            ID.valueOf(UserInfo.getProfileId()));
                                         
            // fetch the assignee 
            userSO = Apttus_Approval.TestSupport.getUserSO(userSO.Id);
            
            userSO2 = Apttus_Approval.TestSupport.createUser('assignee2@approvals.xyz.com', 
                                                             'ast2', 
                                                             'assignee2',
                                                             'tester',
                                                             'assignee2@approvals.xyz.com',
                                                             ID.valueOf(UserInfo.getProfileId()));
                                                                                                              
            // fetch the assignee 
            userSO2 = Apttus_Approval.TestSupport.getUserSO(userSO2.Id);
        
        }*/
                                                                                                                                                                                                                                               
        // STEP IV - Create a new approval request
        Apttus_Approval__Approval_Request__c requestSO = Apttus_Approval.TestSupport.createAssignmentRequest(userSO, 
                                                                                                             processSO.Id, 
                                                                                                             caseSO.Id, 
                                                                                                             'Case-3456');
        
        /*Apttus_Approval__Approval_Request__c requestSO2 = Apttus_Approval.TestSupport.createAssignmentRequest(userSO2, 
                                                                                                              processSO.Id, 
                                                                                                              caseSO.Id, 
                                                                                                              'Case-3457');*/
        
        // STEP V - Create the controller
        // Create the email component controller
        CustomCaseApprovalEmailController controller = new CustomCaseApprovalEmailController();
        
        // STEP VI - Test methods
        
        // start the test
        Test.startTest();
        
        // get the context
        Apttus_Approval.ContextApprovalEmailController context = controller.getContext();
        
        context.setRequestSO(requestSO);
        context.setRecipientSO(userSO);
        
        // request and recipient paraneters
        System.assertNotEquals(context.getRequestSO(), null);
        System.assertNotEquals(context.getRecipientSO(), null);
        
        // status
        System.assert(context.getAreActionsSupported());
        System.assert(!context.getIsStatusCancelled());
        
        // case sobject
        System.assertNotEquals(controller.getCaseSO(), null);
        
        // email response
        System.debug('EmailApprovalResponseEnabled=' + context.getIsEmailApprovalResponseEnabled());
        
        // email links
        System.debug('ReassignPageUrl=' + context.getReassignPageUrl());
        System.debug('ApproveRejectPageUrl=' + context.getApproveRejectPageUrl());
        System.debug('AddCommentPageUrl=' + context.getAddCommentPageUrl());
        System.debug('ContextPageUrl=' + context.getContextPageUrl());
        System.debug('ContextLinkInstruction=' + context.getContextLinkInstruction());
        
        // approval history
        //System.assert(!context.getApprovalHistory().isEmpty());
        
        // end the test 
        Test.stopTest();
        
    }
    
    
}