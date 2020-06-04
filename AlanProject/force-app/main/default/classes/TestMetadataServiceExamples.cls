/**
 * Company     : Trimble Software Technology Pvt Ltd.,
 * Description : 
 * History     :  

 * [12.5.2015] Ankur Patel  Created
 */
  @isTest(seeAllData=true)
public class TestMetadataServiceExamples {
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

    private static testmethod void TestMetadataServiceExamples1(){
        MetadataService.SaveResult saveResult = new MetadataService.SaveResult();
        saveResult.success = true;
        MetadataServiceExamples.handleSaveResults(saveResult);
    }
    private static testmethod void TestMetadataServiceExamples2(){
        MetadataService.SaveResult saveResult = new MetadataService.SaveResult();
        saveResult.success = false;
        MetadataService.Error error = new MetadataService.Error();
        saveResult.errors = new List<MetadataService.Error>();
        saveResult.errors.add(error);
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        MetadataServiceExamples.handleSaveResults(saveResult);
        MetadataServiceExamples.readCustomObject('Account');
        MetadataServiceExamples.createEmailTemplate('','Test','','','Account'.split(','));
        EmailTemplate e = [select DeveloperName from EmailTemplate limit 1];
        MetadataServiceExamples.createEmailTemplate(e.DeveloperName,'Test','','','Account'.split(','));
    }
}