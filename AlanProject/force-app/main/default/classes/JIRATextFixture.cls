/*****************************************************************************************
Name        : JIRATextFixture 
Description : Mock test class for JIRA ticket creating from SFDC 
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
Suresh Babu         29/Sep/2016          Created
******************************************************************************************/
@isTest public with sharing class JIRATextFixture {
    
    // All fields in this class are used only in unit tests.
    // No need to change, but make sure to change the unit tests respectively if you change these values.
    public static String baseUrl = 'http://jira.com';
    public static String systemId = '1';
    public static String username = 'yourJIRAusername';
    public static String password = 'yourJIRApassword';
    
    public static String objectType = 'Case';
    public static String objectId = '1';
    public static String projectKey = 'salesforce';
    public static String issueType = 'bug';
    public static String caseId = '1';
    public static String jIssueKey = 'SFUST-42';
    public static String sCode = '11';
    public static String bAuth = JIRAConnectorClass.authHeader(username, password);
    
    public static String jiraFetchResponseBody = '[{"summary": "Project One", "project": "project one", ' +
        '"reporter": "admin@gmail.com", "key": "PO-1", "status": "open", ' +
        '"resolution": "yes", "url": "www.google.com", "type": "bug", "assignee": "admin", ' +
        '"description": "issue 1", "priority": "high", "due_date": "12-12-2015" },' +
        '{"summary": "Project Two", "project": "project two"}]';
    
    public static String jiraCreateResponseBody = '{"issueKey":"SFUST-42","errors":[]}';
    
    public static String jiraAllStatusResponse = '{"expand":"transitions","transitions":[{"id":"11","name":"To Do","to":{"self":"https://ejira.trimble.com/rest/api/2/status/10001",'+
        '"description":"","iconUrl":"https://ejira.trimble.com/images/icons/subtask.gif","name":"To Do","id":"10001","statusCategory":{"self":"https://ejira.trimble.com/rest/api/2/statuscategory/2","id":2,'+
        '"key":"new","colorName":"blue-gray","name":"To Do"}}},{"id":"71","name":"Backlog","to":{"self":"https://ejira.trimble.com/rest/api/2/status/11395",'+
        '"description":"This status is managed internally by JIRA Agile","iconUrl":"https://ejira.trimble.com/","name":"Backlog","id":"11395","statusCategory":{"self":"https://ejira.trimble.com/rest/api/2/statuscategory/4",'+
        '"id":4,"key":"indeterminate","colorName":"yellow","name":"In Progress"}}}]}';
}