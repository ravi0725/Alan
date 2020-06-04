@isTest
private class DefectSearchControllerTester {
	private static final String caseSubject = 'TestCase1';
    private static final String caseDescription = 'Case description';
    private static final String projectName = 'Call Center';
    private static final String defectStatus = 'In Progress';
    private static final String assignedDefectToken = DefectFacadeMock.CreatedDefectToken;

    private static DefectFacadeMock defectFacadeMockValue;
    private static Settings settingsValue;
    private static Case caseData;

    static testMethod void emptyCriteriaSearchTest() {
    	DefectSearchController controller = getControllerWithoutAssignedDefect();
    	
    	controller.searchForDefects();

    }

    static testMethod void emptyResultSearchTest() {
    	DefectSearchController controller = getControllerWithoutAssignedDefect();
    	defectFacadeMockValue.foundDefects = new List<Defect>();

    	controller.getSearchCriteria().queryString = 'test';
    	controller.getSearchCriteria().includeClosedDefects = false;
    	controller.getSearchCriteria().searchIn = 'fieldsList';
    	controller.searchForDefects();

    }

    static testMethod void searchFailureTest() {
    	DefectSearchController controller = getControllerWithoutAssignedDefect();
    	defectFacadeMockValue.addException(DefectFacadeMock.SEARCH_EXCEPTION, new IntegrationException());


    	controller.getSearchCriteria().queryString = 'test';
    	controller.getSearchCriteria().includeClosedDefects = false;
    	controller.getSearchCriteria().searchIn = 'fieldsList';
    }

    static testMethod void nonEmptyResultSearchTest() {
    	DefectSearchController controller = getControllerWithoutAssignedDefect();
    	setupFoundDefect();

    	controller.getSearchCriteria().queryString = caseSubject;
    	controller.getSearchCriteria().includeClosedDefects = false;
    	controller.getSearchCriteria().searchIn = 'fieldsList';
    	controller.searchForDefects();

    }

    static testMethod void assignDefectFailureTest() {
    	DefectSearchController controller = getControllerWithoutAssignedDefect();
    	defectFacadeMockValue.addException(DefectFacadeMock.ASSIGN_DEFECT_TO_CASE_EXCEPTION, new IntegrationException());
    	controller.assignedDefectToken = assignedDefectToken;
    	setupFoundDefect();

    	controller.getSearchCriteria().queryString = caseSubject;
    	controller.getSearchCriteria().includeClosedDefects = false;
    	controller.getSearchCriteria().searchIn = 'fieldsList';
    	controller.searchForDefects();
    	controller.assignDefectToCase();

    }

    static testMethod void assignDefectWarningTest() {
    	DefectSearchController controller = getControllerWithoutAssignedDefect();
    	//defectFacadeMockValue.setAssignDefectToCaseException(new IntegrationException('', Severity.WARNING));
    	defectFacadeMockValue.addException(DefectFacadeMock.ASSIGN_DEFECT_TO_CASE_EXCEPTION, new IntegrationException('', Severity.WARNING));
    	controller.assignedDefectToken = assignedDefectToken;
    	setupFoundDefect();

    	controller.getSearchCriteria().queryString = caseSubject;
    	controller.getSearchCriteria().includeClosedDefects = false;
    	controller.getSearchCriteria().searchIn = 'fieldsList';
    	controller.searchForDefects();
    	controller.assignDefectToCase();

    }

    static testmethod void assignDefectTest() {
    	DefectSearchController controller = getControllerWithoutAssignedDefect();
    	controller.assignedDefectToken = assignedDefectToken;
    	setupFoundDefect();

    	controller.getSearchCriteria().queryString = caseSubject;
    	controller.getSearchCriteria().includeClosedDefects = false;
    	controller.getSearchCriteria().searchIn = 'fieldsList';
    	controller.searchForDefects();
    	controller.assignDefectToCase();

    }

    static testMethod void unassignDefectFailureTest() {
    	DefectSearchController controller = getControllerWithAssignedDefect();
    	//defectFacadeMockValue.setUnassignDefectFromCaseException(new IntegrationException());
    	defectFacadeMockValue.addException(DefectFacadeMock.UNASSIGN_DEFECT_FROM_CASE_EXCEPTION, new IntegrationException());

    	controller.unassignDefectFromCase();

    }

    static testMethod void unassignDefectTest() {
    	DefectSearchController controller = getControllerWithAssignedDefect();

    	controller.unassignDefectFromCase();

    }

    static testMethod void getFieldsListTest() {
    	DefectSearchController controller = getControllerWithoutAssignedDefect();
    	IDefectFacade facade = new DefectFacade(new V1ConnectorMock(), settingsValue);
    	controller.defectFacade = facade;
    	List<Selectoption> options = controller.getFieldsList();

	}

    private static void setupFoundDefect() {
    	defectFacadeMockValue.foundDefects = new List<Defect>();
    	Defect foundDefect = new Defect(caseSubject, caseDescription);
    	foundDefect.token = assignedDefectToken;
    	foundDefect.status = defectStatus;
    	defectFacadeMockValue.foundDefects.clear();
    	defectFacadeMockValue.foundDefects.add(foundDefect);

    }


    private static DefectSearchController getControllerWithoutAssignedDefect() {
        caseData = new Case(Subject = caseSubject, Description = caseDescription);
        insert new Case[] {caseData};

        caseData = [SELECT V1Association__c FROM Case WHERE Id = :caseData.Id];
        
        return getController();
    }

    private static DefectSearchController getControllerWithAssignedDefect() {
        caseData = new Case(Subject = caseSubject, Description = caseDescription, V1Association__c = true, V1DefectId__c = assignedDefectToken);
        insert new Case[] { caseData };

        caseData = [SELECT V1Association__c FROM Case WHERE Id = :caseData.Id];
        return getController();
    }

    private static DefectSearchController getController() {
        defectFacadeMockValue = new DefectFacadeMock();
        settingsValue = Settings.getTestSettings();
        settingsValue.setProjectName(projectName);
        DefectSearchController controller = new DefectSearchController(caseData);
        controller.defectFacade = defectFacadeMockValue;
        controller.Settings = settingsValue;

        return controller;
    }
}