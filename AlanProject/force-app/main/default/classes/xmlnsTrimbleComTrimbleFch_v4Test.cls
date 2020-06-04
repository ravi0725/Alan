/*
****************************************************************************************
    Name Controller        : xmlnsTrimbleComTrimbleFch_v4Test 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
 P M Mamata           21/07/2015          Created
*****************************************************************************************
*/
@isTest(seeAllData=true)
private class xmlnsTrimbleComTrimbleFch_v4Test {
    private class WebServiceMockImpl implements WebServiceMock{
        public void doInvoke(Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType){
                response.put('response_x', new trimblecorpComCmdm_v4.OrganizationPartyResultType());
            return;
        }
    }

    static testMethod void shouldBeAbleToGetData(){

        String PartyId;
        String Parent_PartyId;
        String EnterprisePartyNumber;
        String AccountName;
        String OrganizationName;
        String LifecycleStage_c;
        String CustomerLevel_c;
        String Channel_c;
        String PrimaryRegion_c;
        String GlobalOptOut_c;
        String RestrictedPartyIndicator_c;
        String DUNSNumberC;
        String Language;
        String VerticalClassification_c;
        String CreditStatus_c;
        String BilltoUsage_c;
        String ShiptoUsage_c;
        String EndUser_c;
        String Installedat_c;
        String SelltoFlag;
        String PrimaryPhoneNumber;
        String PrimaryEMail_c;
        String AccountOwnerEmail_c;
        String ValidatedFlag;
        trimblecorpComCmdm_v4.PartySite_element[] PartySite = new List<trimblecorpComCmdm_v4.PartySite_element>();
        trimblecorpComCmdm_v4.OriginalSystemReferenceType[] OriginalSystemReference = new List<trimblecorpComCmdm_v4.OriginalSystemReferenceType>();
        
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());                  
        xmlnsTrimbleComTrimblenavigationFch_v4.searchOrganizationParty_pt xm = new xmlnsTrimbleComTrimblenavigationFch_v4.searchOrganizationParty_pt();                   
        trimblecorpComCmdm_v4.OrganizationPartyType[] response = xm.process(PartyId,Parent_PartyId,EnterprisePartyNumber,AccountName,OrganizationName,LifecycleStage_c,CustomerLevel_c,Channel_c,PrimaryRegion_c,GlobalOptOut_c,RestrictedPartyIndicator_c,DUNSNumberC,Language,VerticalClassification_c,CreditStatus_c,BilltoUsage_c,ShiptoUsage_c,EndUser_c,Installedat_c,SelltoFlag,PrimaryPhoneNumber,PrimaryEMail_c,AccountOwnerEmail_c,ValidatedFlag,PartySite,OriginalSystemReference);    
    }
    
    
}