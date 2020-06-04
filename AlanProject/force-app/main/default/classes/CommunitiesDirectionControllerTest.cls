/**
 * An apex page controller that exposes the site login functionality
 */
@IsTest global with sharing class CommunitiesDirectionControllerTest {
    @IsTest(SeeAllData=false) 
    global static void testCommunitiesDirectionController() 
    {
        
        CommunitiesDirectionController controller = new CommunitiesDirectionController();
        controller.strUname = 'test@salesforce.com';
        controller.strPassword = '123456'; 
        
        System.assertEquals(controller.login(),null);                           
    }    
}