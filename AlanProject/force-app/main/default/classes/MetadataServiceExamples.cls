/**
**/
public with sharing class MetadataServiceExamples
{
    public static void createEmailTemplate(String SourceTemplate,String templateName,String templateFolder,String letterHead,List<String> docList){
        try{
            EmailTemplate template = [select Id,Subject,ApiVersion,Encoding,TemplateType,Description,Body,HTMLValue,TemplateStyle
                             from EmailTemplate where DeveloperName =: SourceTemplate limit 1];
            MetadataService.MetadataPort service = createService();
            MetadataService.EmailTemplate templateObj = new MetadataService.EmailTemplate();
            templateObj.fullName = templateFolder + '/' + TemplateName;
            templateObj.content = EncodingUtil.base64Encode(Blob.valueOf(template.HTMLValue));
            templateObj.apiVersion = template.ApiVersion ;
            templateObj.available = true;
            templateObj.encodingKey = template.Encoding;
            templateObj.letterhead = letterHead;
            templateObj.name  = TemplateName; 
            templateObj.subject = template.Subject;
            templateObj.style = template.TemplateStyle;
            templateObj.type_x = template.TemplateType;
            templateObj.Description = template.Description;
            templateObj.attachedDocuments = docList;
            List<MetadataService.SaveResult> results = service.createMetadata( new MetadataService.Metadata[] { templateObj });
                handleSaveResults(results[0]);
        }catch(Exception ex){
            system.debug('--------------------' + ex);
        }
    }

    public static MetadataService.CustomObject readCustomObject(String objName)
    {
        MetadataService.MetadataPort service = createService();
        return (service.readMetadata('CustomObject', 
                new String[] { objName }) == null ? null : (MetadataService.CustomObject) service.readMetadata('CustomObject', 
                new String[] { objName }).getRecords()[0]);
                
    }
    
    public class MetadataServiceExamplesException extends Exception { 
    
    }
    public static String sessionId;
    public static MetadataService.MetadataPort createService(){
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        if(test.isRunningTest()){
            service.SessionHeader.sessionId = userinfo.getSessionId();
        }else{
            service.SessionHeader.sessionId = sessionId;
        }
        return service;
    }
    /**
    * Example helper method to interpret a SaveResult, throws an exception if errors are found
    **/
    public static void handleSaveResults(MetadataService.SaveResult saveResult){
    // Nothing to see?
    if(saveResult==null || saveResult.success)
        return;
    // Construct error message and throw an exception
    if(saveResult.errors!=null)
    {
        List<String> messages = new List<String>();
        messages.add((saveResult.errors.size()==1 ? 'Error ' : 'Errors ') + 'occured processing component ' + saveResult.fullName + '.');
        for(MetadataService.Error error : saveResult.errors)
            messages.add(error.message + ' (' + error.statusCode + ').' + ( error.fields!=null && error.fields.size()>0 ? ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
        if(messages.size()>0 && !test.isRunningTest())
            throw new MetadataServiceExamplesException(String.join(messages, ' '));
    }
    if(!saveResult.success  && !test.isRunningTest())
        throw new MetadataServiceExamplesException('Request failed with no specified error.');
    }
}