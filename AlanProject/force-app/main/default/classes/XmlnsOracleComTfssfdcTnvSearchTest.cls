/*
****************************************************************************************
 Name Controller        : XmlnsOracleComTfssfdcTnvSearchTest 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
 P M Mamata           29/08/2015          created
*****************************************************************************************
*/
@istest(seealldata=true)
private class XmlnsOracleComTfssfdcTnvSearchTest {
	private class WebServiceMockImpl implements WebServiceMock{
        public void doInvoke(Object stub, Object request, Map<String, Object> response,
                String endpoint, String soapAction, String requestName,
                String responseNS, String responseName, String responseType){
                    response.put('response_x', new XmlnsOracleComTfssfdcTnvSearch.processResponse_element());
                return;
                    
        }
    }
	static testMethod void shouldBeAbleToGetData(){

        //GenerateTestData.createAccount();        
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());                  
        XmlnsOracleComTfssfdcTnvSearch stc = new XmlnsOracleComTfssfdcTnvSearch();
        XmlnsOracleComTfssfdcTnvSearch.processError_element pee = new XmlnsOracleComTfssfdcTnvSearch.processError_element();
        XmlnsOracleComTfssfdcTnvSearch.SearchParamsType spt = new XmlnsOracleComTfssfdcTnvSearch.SearchParamsType();
        XmlnsOracleComTfssfdcTnvSearch.process_element pe = new XmlnsOracleComTfssfdcTnvSearch.process_element();
        XmlnsOracleComTfssfdcTnvSearch.processResponse_element pre = new XmlnsOracleComTfssfdcTnvSearch.processResponse_element();
        XmlnsOracleComTfssfdcTnvSearch.SearchParamsResultType sprt = new XmlnsOracleComTfssfdcTnvSearch.SearchParamsResultType();
        XmlnsOracleComTfssfdcTnvSearch.TfsWorkItemBean tfs = new XmlnsOracleComTfssfdcTnvSearch.TfsWorkItemBean();    
        XmlnsOracleComTfssfdcTnvSearch.TnvSfdcOutboundSearchtoTfsBPELProcess_pt xm =  new XmlnsOracleComTfssfdcTnvSearch.TnvSfdcOutboundSearchtoTfsBPELProcess_pt();
        XmlnsOracleComTfssfdcTnvSearch.SearchParamsType SearchParams;
        XmlnsOracleComTfssfdcTnvSearch.SearchParamsResultType response = xm.process(SearchParams);
		
    }    
	
}