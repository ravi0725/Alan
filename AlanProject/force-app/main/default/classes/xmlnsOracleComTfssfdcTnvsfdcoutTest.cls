/*
****************************************************************************************
 Name Controller        : xmlnsOracleComTfssfdcTnvsfdcoutTest 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
 P M Mamata           29/08/2015          created
*****************************************************************************************
*/
@istest(seealldata=true)
private class xmlnsOracleComTfssfdcTnvsfdcoutTest {
    private class WebServiceMockImpl implements WebServiceMock{
        public void doInvoke(Object stub, Object request, Map<String, Object> response,
                String endpoint, String soapAction, String requestName,
                String responseNS, String responseName, String responseType){
                    response.put('response_x', new xmlnsOracleComTfssfdcTnvsfdcoutbound.processResponse_element());
                return;
                    
        }
    }
    
    static testMethod void shouldBeAbleToGetData(){

        //GenerateTestData.createAccount();        
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());                  
        xmlnsOracleComTfssfdcTnvsfdcoutbound xmb = new xmlnsOracleComTfssfdcTnvsfdcoutbound();
        xmlnsOracleComTfssfdcTnvsfdcoutbound.processError_element pr = new xmlnsOracleComTfssfdcTnvsfdcoutbound.processError_element();
        xmlnsOracleComTfssfdcTnvsfdcoutbound.process_element pe = new xmlnsOracleComTfssfdcTnvsfdcoutbound.process_element();
        xmlnsOracleComTfssfdcTnvsfdcoutbound.CaseParamsResultType cprt = new xmlnsOracleComTfssfdcTnvsfdcoutbound.CaseParamsResultType();
        xmlnsOracleComTfssfdcTnvsfdcoutbound.CaseParamsType cpt = new xmlnsOracleComTfssfdcTnvsfdcoutbound.CaseParamsType();
        xmlnsOracleComTfssfdcTnvsfdcoutbound.processResponse_element pre = new xmlnsOracleComTfssfdcTnvsfdcoutbound.processResponse_element();
        xmlnsOracleComTfssfdcTnvsfdcoutbound.TnvSfdcOutboundToTfsBPELProcess_pt xm = new xmlnsOracleComTfssfdcTnvsfdcoutbound.TnvSfdcOutboundToTfsBPELProcess_pt();    
        xmlnsOracleComTfssfdcTnvsfdcoutbound.CaseParamsType CaseParams; 
        xmlnsOracleComTfssfdcTnvsfdcoutbound.CaseParamsResultType response = xm.process(CaseParams);
    }
}