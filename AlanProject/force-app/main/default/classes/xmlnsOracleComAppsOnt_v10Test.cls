/*
****************************************************************************************
 Name Controller        : xmlnsOracleComAppsOnt_v10Test 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
 P M Mamata           31/07/2015          created
*****************************************************************************************
*/
@istest(seealldata=true)



private class xmlnsOracleComAppsOnt_v10Test {
    static testmethod void xmlnsoraclemeth(){
        xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_HEADER_REC_TYPE xm = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_HEADER_REC_TYPE();
        xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINE_TBL_TYPE xo = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINE_TBL_TYPE();
        xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINEOUT_TBL_TYPE xa = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINEOUT_TBL_TYPE();
        xmlnsOracleComAppsOntSoaproviderPl_v10.OutputParameters_element xot = new xmlnsOracleComAppsOntSoaproviderPl_v10.OutputParameters_element();
        xmlnsOracleComAppsOntSoaproviderPl_v10.InputParameters_element xi = new xmlnsOracleComAppsOntSoaproviderPl_v10.InputParameters_element();
        xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINE_REC_TYPE xap = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINE_REC_TYPE();
        xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINEOUT_REC_TYPE xapp = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINEOUT_REC_TYPE();
        xmlnsOracleComAppsOntSoaproviderPl_v10.InputParametersSFDC_element xin = new xmlnsOracleComAppsOntSoaproviderPl_v10.InputParametersSFDC_element();
    }

}