@isTest(seeAllData=true)
public class TestLinkAccountController {
    static testmethod void accountHelperMeth1(){
        GenerateTestData.createAccount();
        GenerateTestData.createAddress();
        system.currentPageReference().getParameters().put('accId', GenerateTestData.acct.Id);
        LinkAccountController temp1 = new LinkAccountController();
        temp1.searchEBSAccount();
        temp1.searchSFDCAccount();
        temp1.Save();
        temp1.makeCallOut();
            
        LinkAccontLookupController temp = new LinkAccontLookupController();
        temp.searchString = 'acc';
        temp.search();
        
        temp1.EBSAccTableCaption = 'sdgds';
        temp1.SFDCAccTableCaption = 'sdgds';
        temp1.SFDCAccountName = 'sdgds';
        temp1.selectedAcc= 'sdgds';
        temp1.selectedAddresses= 'sdgds';
        
        temp1.EBSAccountId = '12345';
        temp1.searchEBSAccount();
        temp1.SFDCAccountId = GenerateTestData.acct.Id;
        temp1.searchSFDCAccount();
        temp1.JSONmergeIds = '[{"FCH_Address_Id":"300000001697541","SFDC_Id":"a5Of00000005HPBEA2","Street_1":"15274 Salano Creek Dr"}]';
        temp1.makeCallOut();
        temp1.Save();
        
        trimblecorpComCmdm_v1.AddrDestinationType temp2 = new trimblecorpComCmdm_v1.AddrDestinationType();
        trimblecorpComCmdm_v1.FlexAttributeType temp3 = new trimblecorpComCmdm_v1.FlexAttributeType();
        trimblecorpComCmdm_v1.RelationshipObjType temp4 = new trimblecorpComCmdm_v1.RelationshipObjType();
        trimblecorpComCmdm_v1.ContactPointType temp5 = new trimblecorpComCmdm_v1.ContactPointType();
        trimblecorpComCmdm_v1.FlexType temp6 = new trimblecorpComCmdm_v1.FlexType();
        trimblecorpComCmdm_v1.OriginalSystemReferenceAttType temp7 = new trimblecorpComCmdm_v1.OriginalSystemReferenceAttType();
        trimblecorpComCmdm_v1.SiteUsageType temp8 = new trimblecorpComCmdm_v1.SiteUsageType();
        trimblecorpComCmdm_v1.FlexAttributeType temp9 = new trimblecorpComCmdm_v1.FlexAttributeType();
        trimblecorpComCmdm_v1.RelationshipAttributeType temp10 = new trimblecorpComCmdm_v1.RelationshipAttributeType();
        trimblecorpComCmdm_v1.AddrDestAttrType temp11 = new trimblecorpComCmdm_v1.AddrDestAttrType();
        trimblecorpComCmdm_v1.DivisionType temp12 = new trimblecorpComCmdm_v1.DivisionType();
        trimblecorpComCmdm_v1.HeaderType temp13 = new trimblecorpComCmdm_v1.HeaderType();
        trimblecorpComCmdm_v1.ContactPointAttributeType temp14 = new trimblecorpComCmdm_v1.ContactPointAttributeType();
        trimblecorpComCmdm_v1.SiteUsageAttributeType temp15 = new trimblecorpComCmdm_v1.SiteUsageAttributeType();
        trimblecorpComCmdm_v1.OriginalSystemReferenceType temp16 = new trimblecorpComCmdm_v1.OriginalSystemReferenceType();
        trimblecorpComCmdm_v1.DestinationType temp17 = new trimblecorpComCmdm_v1.DestinationType();
        trimblecorpComCmdm_v1.PartyPersonType temp18 = new trimblecorpComCmdm_v1.PartyPersonType();
        trimblecorpComCmdm_v1.process_element temp19 = new trimblecorpComCmdm_v1.process_element();
        
        
        xmlnsOracleComFchTnvcusbpelfchosrsyn_v1.SourceSystemRefInformationType t1 = new xmlnsOracleComFchTnvcusbpelfchosrsyn_v1.SourceSystemRefInformationType();
        xmlnsOracleComFchTnvcusbpelfchosrsyn_v1.OriginalSystemReference_element t2 = new xmlnsOracleComFchTnvcusbpelfchosrsyn_v1.OriginalSystemReference_element();
        xmlnsOracleComFchTnvcusbpelfchosrsyn_v1.detail t3 = new xmlnsOracleComFchTnvcusbpelfchosrsyn_v1.detail();
        xmlnsOracleComFchTnvcusbpelfchosrsyn_v1.OriginalSystemReferenceType t4 = new xmlnsOracleComFchTnvcusbpelfchosrsyn_v1.OriginalSystemReferenceType();
        xmlnsOracleComFchTnvcusbpelfchosrsyn_v1.processResponse_element t5 = new xmlnsOracleComFchTnvcusbpelfchosrsyn_v1.processResponse_element();
        xmlnsOracleComFchTnvcusbpelfchosrsyn_v1.errordetails t6 = new xmlnsOracleComFchTnvcusbpelfchosrsyn_v1.errordetails();
        
    }
    
	static testmethod void accountHelperMeth2(){
    	System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl1());
        xmlnsOracleComCusthubnewversionTnvcu_v1.tnvCustGetFCHDetailsByEANProcess_pt temp21 = new xmlnsOracleComCusthubnewversionTnvcu_v1.tnvCustGetFCHDetailsByEANProcess_pt();
        temp21.Process('12345', '', '');
    }
    
    static testmethod void accountHelperMeth3(){
    	System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl2());
        xmlnsOracleComCmdmnewTnvcusbpelfchos_v1.FCHOSRService_pt temp20 = new xmlnsOracleComCmdmnewTnvcusbpelfchos_v1.FCHOSRService_pt(); 
        temp20.process('Create', new List<xmlnsOracleComFchTnvcusbpelfchosrsyn_v1.OriginalSystemReferenceType>());
    }
    
    private class WebServiceMockImpl1 implements WebServiceMock{
        public void doInvoke(Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType){
                response.put('response_x', new trimblecorpComCmdm_v1.CommonData_element());
            return;
        }
    }
    
    
    private class WebServiceMockImpl2 implements WebServiceMock{
        public void doInvoke(Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType){
                response.put('response_x', new xmlnsOracleComFchTnvcusbpelfchosrsyn_v1.processResponse_element());
            return;
        }
    }
}