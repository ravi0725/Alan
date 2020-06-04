/*****************************************************************************************
Name        : MockJIRAMonitorClass 
Description : Mock test class for JIRA Monitor class
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
Suresh Babu         29/Mar/2017          Created
******************************************************************************************/
@isTest
global class MockJIRAMonitorClass implements HttpCalloutMock {
    protected Integer expectedCode;

    global MockJIRAMonitorClass (Integer expectedCode){
        this.expectedCode = expectedCode;
    }

    global HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();
        system.debug('req ===>'+req);
        system.debug('req ===>'+req.getEndpoint());
        if(req.getEndpoint().endsWith('session')){ // Credential validation
            if(this.expectedCode == 200){
                res.setStatusCode(200);
                res.setBody('{"issueKey":"SFUST-42","errors":[]}');
            }
            else if(this.expectedCode == 401){
                res.setStatusCode(401);
                res.setBody('{"issueKey":"SFUST-42","errors":[]}');
            }
            else if(this.expectedCode == 404){
                res.setStatusCode(404);
                res.setBody('{"issueKey":"SFUST-42","errors":[]}');
            }
            else{
                res.setStatusCode(501);
                res.setBody('{"issueKey":"SFUST-42","errors":[]}');
            }
        }
        else if(req.getEndpoint().endsWith(JIRATextFixture.jIssueKey)){ // Issue validation
            if(this.expectedCode == 200){
                res.setStatusCode(200);
                res.setBody('{"issueKey":"SFUST-42","errors":[]}');
            }
            else if(this.expectedCode == 404){
                res.setStatusCode(404);
                res.setBody('{"issueKey":"SFUST-42","errors":[]}');
            }
            else{
                res.setStatusCode(501);
                res.setBody('{"issueKey":"SFUST-42","errors":[]}');
            }
        }
        else if(req.getEndpoint().endsWith('synchronize.json')){ // Sync validation
            if(this.expectedCode == 200){
                res.setStatusCode(200);
                res.setBody('{"issueKey":"SFUST-42","errors":[]}');
            }
            else if(this.expectedCode == 500){
                res.setStatusCode(500);
                res.setBody('{"issueKey":"SFUST-42","errors":[]}');
            }
            else{
                res.setStatusCode(501);
                res.setBody('{"issueKey":"SFUST-42","errors":[]}');
            }
        }
        else if(req.getEndpoint().endsWith('transitions')){ // Transition validation
            if(this.expectedCode == 200){
                res.setStatusCode(200);
                res.setBody('{"expand":"transitions","transitions":[{"id":"101","name":"Backlog","to":{"self":"https://ejira.trimble.com/rest/api/2/status/10018","description":"This status is managed internally by JIRA Software","iconUrl":"https://ejira.trimble.com/images/icons/subtask.gif","name":"Backlog","id":"10018","statusCategory":{"self":"https://ejira.trimble.com/rest/api/2/statuscategory/2","id":2,"key":"new","colorName":"blue-gray","name":"To Do"}}}]}');
            }
            else if(this.expectedCode == 400){
                res.setStatusCode(400);
                res.setBody('{"expand":"transitions","transitions":[{"id":"101","name":"Backlog","to":{"self":"https://ejira.trimble.com/rest/api/2/status/10018","description":"This status is managed internally by JIRA Software","iconUrl":"https://ejira.trimble.com/images/icons/subtask.gif","name":"Backlog","id":"10018","statusCategory":{"self":"https://ejira.trimble.com/rest/api/2/statuscategory/2","id":2,"key":"new","colorName":"blue-gray","name":"To Do"}}},{"id":"111","name":"Closed No Fix","to":{"self":"https://ejira.trimble.com/rest/api/2/status/11471","description":"This status is managed internally by JIRA Software","iconUrl":"https://ejira.trimble.com/","name":"Closed No Fix","id":"11471","statusCategory":{"self":"https://ejira.trimble.com/rest/api/2/statuscategory/3","id":3,"key":"done","colorName":"green","name":"Done"}}}]}');
            }
        }
        else{ // dummy response
            res.setStatusCode(200);
            res.setBody('{"issueKey":"SFUST-42","errors":[]}');
        }
        return res;
    }

}