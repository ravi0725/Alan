//Generated by wsdl2apex

public class xmlnsOracleComCmdmnewTnvcusbpelfchos_v1 {
    public class FCHOSRService_pt {
        public String endpoint_x = IntegrationConfig.getEndPointURL('Link_Account_Update');
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://xmlns.oracle.com/cmdmNew/tnvCusBpelFchOsrSync/FCHOSRService', 'xmlnsOracleComCmdmnewTnvcusbpelfchos_v1', 'http://xmlns.oracle.com/fch/tnvCusBpelFchOsrSync/tnvCusBpelFchOsrSync', 'xmlnsOracleComFchTnvcusbpelfchosrsyn_v1', 'http://www.trimble.com/SOA/11g/fch/CustomReusableVariables', 'wwwTrimbleComSoa11gFchCustomreusab_v1'};
        public xmlnsOracleComFchTnvcusbpelfchosrsyn_v1.processResponse_element process(String operation,xmlnsOracleComFchTnvcusbpelfchosrsyn_v1.OriginalSystemReferenceType[] OriginalSysRef) {
            xmlnsOracleComFchTnvcusbpelfchosrsyn_v1.OriginalSystemReference_element request_x = new xmlnsOracleComFchTnvcusbpelfchosrsyn_v1.OriginalSystemReference_element();
            request_x.operation = operation;
            request_x.OriginalSysRef = OriginalSysRef;
            xmlnsOracleComFchTnvcusbpelfchosrsyn_v1.processResponse_element response_x;
            Map<String, xmlnsOracleComFchTnvcusbpelfchosrsyn_v1.processResponse_element> response_map_x = new Map<String, xmlnsOracleComFchTnvcusbpelfchosrsyn_v1.processResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'process',
              'http://xmlns.oracle.com/fch/tnvCusBpelFchOsrSync/tnvCusBpelFchOsrSync',
              'OriginalSystemReference',
              'http://xmlns.oracle.com/fch/tnvCusBpelFchOsrSync/tnvCusBpelFchOsrSync',
              'processResponse',
              'xmlnsOracleComFchTnvcusbpelfchosrsyn_v1.processResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
    }
}