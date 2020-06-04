/*
****************************************************************************************
 Name Controller        : xmlnsOracleComTfsTnvtfsfileattachmenTest 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
 P M Mamata           29/08/2015          created
*****************************************************************************************
*/
@istest(seealldata=true)
private class xmlnsOracleComTfsTnvtfsfileattachmenTest {
    private class WebServiceMockImpl implements WebServiceMock{
        public void doInvoke(Object stub, Object request, Map<String, Object> response,
                String endpoint, String soapAction, String requestName,
                String responseNS, String responseName, String responseType){
                    response.put('response_x', new xmlnsOracleComTfsTnvtfsfileattachmen.processResponse_element());
                return;
                    
        }
    }
    
    static testMethod void shouldBeAbleToGetData(){

        //GenerateTestData.createAccount();        
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());   
        xmlnsOracleComTfsTnvtfsfileattachmen.process_element pe = new xmlnsOracleComTfsTnvtfsfileattachmen.process_element();
        xmlnsOracleComTfsTnvtfsfileattachmen.processResponse_element pr = new xmlnsOracleComTfsTnvtfsfileattachmen.processResponse_element();
        xmlnsOracleComTfsTnvtfsfileattachmen.tnvtfsfileattachmentService_pt xm = new xmlnsOracleComTfsTnvtfsfileattachmen.tnvtfsfileattachmentService_pt();
        Integer TFSID = 1;String FileName = 'filename';String FileType = 'filetype';String Content = 'content';String Comments = 'comments';String ProjectName = 'projectname';String Division = 'division';
        xmlnsOracleComTfsTnvtfsfileattachmen.processResponse_element response = xm.process(TFSID,FileName,FileType,Content,Comments,ProjectName,Division); 
    }  
}