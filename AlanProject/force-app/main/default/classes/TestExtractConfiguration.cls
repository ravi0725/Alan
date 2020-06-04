/**
 * Company     : Trimble Software Technology Pvt Ltd.,
 * Description : 
 * History     :  

 * [3.5.2015] Ankur Patel  Created
 */
 @isTest(seeAllData = true)
public class TestExtractConfiguration{

    /**
     * Dummy Metadata API web service mock class (see MetadataCreateJobTest.cls for a better example)
     **/
    private class WebServiceMockImpl implements WebServiceMock 
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType) 
        {
            if(request instanceof MetadataService.readMetadata_element)
                response.put('response_x', new MetadataService.readCustomObjectResponse_element());
            return;
        }
    }
    
    private static testmethod void TestExtractConfiguration1(){
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        ExtractConfiguration temp = new ExtractConfiguration();
        temp.profileSelected = userinfo.getPRofileId();
        temp.FolderId     = [select Id from Folder where Type = 'Report' limit 1].Id;
        temp.getObjectList();
        temp.getFolderList();
        temp.getProfileList();
        temp.clearList();
        temp.getReportDetails();
        temp.getObjectPermissions();
        temp.getFieldPermissions();
        temp.getObjectListViews();
        temp.getObjectValidationRules();
        temp.pageLoadType = 'Excel';
        temp.loadType('Excel');
        temp.pageLoadType = 'Doc';
        temp.loadType('Excel');
        temp.pageLoadType = 'VF Page';
        temp.loadType('Excel');
        temp.pageLoadType = 'PDF';
        temp.loadType('Excel');
        temp.pageLoadType = 'CSV';
        temp.loadType('Excel');
    }
}