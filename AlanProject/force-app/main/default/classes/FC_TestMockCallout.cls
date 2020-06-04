@isTest
global class FC_TestMockCallout implements HttpCalloutMock {
    private Map<String, FC_TestEndPointMock> endPointMock;
    
    public class FC_TestEndPointMock {
	    protected String responseBody;
	    protected Integer responseSC;
	    protected String contentType = 'text/html';
	    
	    public FC_TestEndPointMock(String responseStr, Integer responseStatusCode) { 
	        this.responseBody = responseStr;
	        this.responseSC = responseStatusCode;
	        if(this.responseSC == null) this.responseSC = 200; //default ok
	        if(this.responseBody == null) this.responseBody = ''; //default empty string
	    }	
	    
	    public void setContentTypeJSON(){
	    	this.contentType = 'application/json';
	    }
	
	    public void setContentTypeXML(){
	    	this.contentType = 'text/xml';
	    }    
    }
    
    public FC_TestMockCallout() {
    	this.endPointMock = new Map<String, FC_TestEndPointMock>();
    }

    public void addEndpointMock(String endPointString, FC_TestEndPointMock endPointMock) {
    	this.endPointMock.put(endPointString, endPointMock);
    }
    
    global HttpResponse respond(HttpRequest request) {
        String endPointStr = request.getEndpoint();
        System.debug('++++++ Request Endpoint :'+endPointStr);
        
        FC_TestEndPointMock findMock = this.endPointMock.get(endPointStr);
        HttpResponse response = new HttpResponse();
        if(findMock != null){
        	System.debug('++++++ Request Endpoint Found!');
	        response.setHeader('Content-Type', findMock.contentType);
	        response.setBody(findMock.responseBody);
	        response.setStatusCode(findMock.responseSC);
        }else{
        	System.debug('++++++ Request Endpoint Not Found !!!!');
        	//defaults if not found
	        response.setHeader('Content-Type', 'text/html');
	        response.setBody('');
	        response.setStatusCode(404);        	
        }
        return response;
    }
    
}