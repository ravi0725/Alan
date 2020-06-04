/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.

 */
@isTest(SeeAllData=true)
public class ResourceCalenderDetailViewCtrlTestClass {

    static testMethod void TestPageCustomController() {
    
        Test.StartTest();
        
        Pagereference pgRef = Page.ResourceCalenderDetailView;
        pgRef.getParameters().put('NewVal','New Value');
        Test.setCurrentPage(pgRef);
            
        ResourceCalenderDetailViewCtrl testContClass = new ResourceCalenderDetailViewCtrl();
        testContClass.sSelectView = 'Plancal_Support_Group_CH';
        testContClass.AddEvent();
        testContClass.getSelectViewList();
        testContClass.pageLoad();
        testContClass.toggleEvents();
        
        Test.StopTest();
    }
}