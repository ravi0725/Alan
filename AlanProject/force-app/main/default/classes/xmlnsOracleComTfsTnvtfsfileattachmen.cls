//Generated by wsdl2apex

public class xmlnsOracleComTfsTnvtfsfileattachmen {
    public class process_element {
        public Integer TFSID;
        public String FileName;
        public String FileType;
        public String Content;
        public String Comments;
        public String ProjectName;
        public String Division;
        private String[] TFSID_type_info = new String[]{'TFSID','http://xmlns.oracle.com/TFS/TNVTFSFileAttachmentComposite/tnvtfsfileattachmentService',null,'1','1','false'};
        private String[] FileName_type_info = new String[]{'FileName','http://xmlns.oracle.com/TFS/TNVTFSFileAttachmentComposite/tnvtfsfileattachmentService',null,'1','1','false'};
        private String[] FileType_type_info = new String[]{'FileType','http://xmlns.oracle.com/TFS/TNVTFSFileAttachmentComposite/tnvtfsfileattachmentService',null,'1','1','false'};
        private String[] Content_type_info = new String[]{'Content','http://xmlns.oracle.com/TFS/TNVTFSFileAttachmentComposite/tnvtfsfileattachmentService',null,'1','1','false'};
        private String[] Comments_type_info = new String[]{'Comments','http://xmlns.oracle.com/TFS/TNVTFSFileAttachmentComposite/tnvtfsfileattachmentService',null,'1','1','false'};
        private String[] ProjectName_type_info = new String[]{'ProjectName','http://xmlns.oracle.com/TFS/TNVTFSFileAttachmentComposite/tnvtfsfileattachmentService',null,'1','1','false'};
        private String[] Division_type_info = new String[]{'Division','http://xmlns.oracle.com/TFS/TNVTFSFileAttachmentComposite/tnvtfsfileattachmentService',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://xmlns.oracle.com/TFS/TNVTFSFileAttachmentComposite/tnvtfsfileattachmentService','true','false'};
        private String[] field_order_type_info = new String[]{'TFSID','FileName','FileType','Content','Comments','ProjectName','Division'};
    }
    public class processResponse_element {
        public String Status;
        public Integer TFSID;
        private String[] Status_type_info = new String[]{'Status','http://xmlns.oracle.com/TFS/TNVTFSFileAttachmentComposite/tnvtfsfileattachmentService',null,'1','1','false'};
        private String[] TFSID_type_info = new String[]{'TFSID','http://xmlns.oracle.com/TFS/TNVTFSFileAttachmentComposite/tnvtfsfileattachmentService',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://xmlns.oracle.com/TFS/TNVTFSFileAttachmentComposite/tnvtfsfileattachmentService','true','false'};
        private String[] field_order_type_info = new String[]{'Status','TFSID'};
    }
    public class tnvtfsfileattachmentService_pt {
        public String endpoint_x = IntegrationConfig.getEndPointURL('TFS_Attachment');
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://xmlns.oracle.com/TFS/TNVTFSFileAttachmentComposite/tnvtfsfileattachmentService', 'xmlnsOracleComTfsTnvtfsfileattachmen'};
        public xmlnsOracleComTfsTnvtfsfileattachmen.processResponse_element process(Integer TFSID,String FileName,String FileType,String Content,String Comments,String ProjectName,String Division) {
            xmlnsOracleComTfsTnvtfsfileattachmen.process_element request_x = new xmlnsOracleComTfsTnvtfsfileattachmen.process_element();
            request_x.TFSID = TFSID;
            request_x.FileName = FileName;
            request_x.FileType = FileType;
            request_x.Content = Content;
            request_x.Comments = Comments;
            request_x.ProjectName = ProjectName;
            request_x.Division = Division;
            xmlnsOracleComTfsTnvtfsfileattachmen.processResponse_element response_x;
            Map<String, xmlnsOracleComTfsTnvtfsfileattachmen.processResponse_element> response_map_x = new Map<String, xmlnsOracleComTfsTnvtfsfileattachmen.processResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'process',
              'http://xmlns.oracle.com/TFS/TNVTFSFileAttachmentComposite/tnvtfsfileattachmentService',
              'process',
              'http://xmlns.oracle.com/TFS/TNVTFSFileAttachmentComposite/tnvtfsfileattachmentService',
              'processResponse',
              'xmlnsOracleComTfsTnvtfsfileattachmen.processResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
    }
}