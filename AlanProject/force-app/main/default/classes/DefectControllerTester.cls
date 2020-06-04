@isTest
private class DefectControllerTester {
    private static final String CASE_SUBJECT = 'TestCase1';
    private static final String CASE_DESCRIPTION = 'Description 123';
    private static final String PROJECT_NAME = 'project name';
    private static final String DEFECT_TOKEN = DefectFacadeMock.CreatedDefectToken;
    private static final String SF_PRODUCT_ID = 'GC1020';

    static testMethod void mainTest() {
        DefectController controller = getControllerWithoutAssignedDefect();

        Defect defect = controller.getCreatingDefect();
        
        controller.showForm();
        
        controller.refreshWidow();
        
    }

    static testMethod void createDefectTest() {
        DefectController controller = getControllerWithoutAssignedDefect();
        controller.createDefect();
        Defect defect = controller.getCreatingDefect();

    }

    static testMethod void createDefectWithExceptionTest() {
        DefectController controller = getControllerWithoutAssignedDefect();
        DefectFacadeMock facade = (DefectFacadeMock)controller.defectFacade;
        facade.addException(DefectFacadeMock.CREATE_DEFECT_IN_V1_EXCEPTION, new IntegrationException('test exception'));
        controller.defectFacade = facade;
        controller.createDefect();
        Defect defect = controller.getCreatingDefect();
        
    }

    static testMethod void getAssignedDefectTest() {
        DefectController controller = getControllerWithAssignedDefect();

        Defect defectData = controller.getAssignedDefect();
        
    }

    static testMethod void getAssignedDefectWithExceptionTest() {
        DefectController controller = getControllerWithAssignedDefect();
        DefectFacadeMock facade = (DefectFacadeMock)controller.defectFacade;
        facade.addException(DefectFacadeMock.DEFECT_BY_ID_EXCEPTION, new IntegrationException('test exception'));
        controller.defectFacade = facade;

        Defect defectData = controller.getAssignedDefect();
        
    }

    static testMethod void getAssignedDefectWithoutRequestToV1Test() {
        DefectController controller = getControllerWithAssignedDefect();
        controller.createDefect();
        controller.defectFacade = null;
        Defect defectData = controller.getAssignedDefect();
        
    }

    static testMethod void getAssignedDefectWhenDefectIsNotAssignedTest() {
        DefectController controller = getControllerWithoutAssignedDefect();

        Defect defectData = controller.getAssignedDefect();
        
    }

    static testMethod void unassignDefectTest() {
        DefectController controller = getControllerWithAssignedDefect();

        controller.unassignDefect();
        
    }

    static testMethod void unassignDefectWithExeptionTest() {
        DefectController controller = getControllerWithAssignedDefect();
        DefectFacadeMock facade = (DefectFacadeMock)controller.defectFacade;
        facade.addException(DefectFacadeMock.UNASSIGN_DEFECT_FROM_CASE_EXCEPTION, new IntegrationException('test exception'));
        controller.defectFacade = facade;

        controller.unassignDefect();
        
    }

    static testMethod void publishStatusTest() {
        DefectController controller = getControllerWithAssignedDefect();

        controller.publishStatus();
        
    }

    static testMethod void publishStatusWithExceptionTest() {
        DefectController controller = getControllerWithAssignedDefect();
        DefectFacadeMock facade = (DefectFacadeMock)controller.defectFacade;
        facade.addException(DefectFacadeMock.PUBLISH_STATUS_EXCEPTION, new IntegrationException('test exception'));
        controller.defectFacade = facade;

        controller.publishStatus();
        
    }

    static testMethod void cancelFormTest() {
        String newTitle = 'new title';
        String newDescription = 'new description';
        DefectController controller = getControllerWithoutAssignedDefect();

        controller.getCreatingDefect().title = newTitle;
        controller.getCreatingDefect().description = newDescription;
        Defect defect = controller.getCreatingDefect();
        controller.isEditForm = true;

        controller.cancelForm();
        defect = controller.getCreatingDefect();
       
    }

    private static DefectController getControllerWithoutAssignedDefect() {
        Case caseData = new Case(Subject = CASE_SUBJECT, Description = CASE_DESCRIPTION, Product__c = SF_PRODUCT_ID);
        insert new Case[] {caseData};

        caseData = [SELECT V1Association__c FROM Case WHERE Id = :caseData.Id];
        return getController(caseData);
    }

    private static DefectController getControllerWithAssignedDefect() {
        Case caseData = new Case(Subject = CASE_SUBJECT, Description = CASE_DESCRIPTION, V1Association__c = true, V1DefectId__c = DEFECT_TOKEN, Product__c = SF_PRODUCT_ID);
        insert new Case[] {caseData};

        caseData = [SELECT V1Association__c FROM Case WHERE Id = :caseData.Id];
       
        return getController(caseData);
    }

    private static DefectController getController(Case caseData) {
        DefectFacadeMock facade = new DefectFacadeMock();
        Settings settingsData = Settings.getTestSettings();
        settingsData.setProjectName(PROJECT_NAME);
        DefectController controller = new DefectController(caseData);
        controller.defectFacade = facade;
        controller.settings = settingsData;

        
        return controller;
    }
}