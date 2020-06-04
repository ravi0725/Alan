/**
 * Company     : Trimble Software Technology Pvt Ltd.,
 * Description : 
 * History     :  

 * [3.5.2015] Ankur Patel  Created
 */
 @isTest(seeAllData = true)
public class TestMetadataService{

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
            else if(request instanceof  MetadataService.createMetadata_element)
                response.put('response_x', new MetadataService.createMetadataResponse_element());
            else if(request instanceof MetadataService.deleteMetadata_element)
                response.put('response_x', new MetadataService.deleteMetadataResponse_element());
            return;
        }
    }

    private static testmethod void TestMetadataService1(){
        MetadataService temp1 = new MetadataService();
        MetadataService.MetadataWithContent temp2 = new MetadataService.MetadataWithContent();
        MetadataService.Attachment temp3 = new MetadataService.Attachment();
        MetadataService.createMetadata_element temp4 = new MetadataService.createMetadata_element();
        MetadataService.createMetadataResponse_element temp5 = new MetadataService.createMetadataResponse_element();
        MetadataService.deleteMetadata_element temp6 = new MetadataService.deleteMetadata_element();
        MetadataService.deleteMetadataResponse_element temp7 = new MetadataService.deleteMetadataResponse_element();
        MetadataService.DeleteResult temp8 = new MetadataService.DeleteResult();
        MetadataService.SaveResult temp9 = new MetadataService.SaveResult();
        MetadataService.EmailTemplate temp10 = new MetadataService.EmailTemplate();
        MetadataService.Error temp11 = new MetadataService.Error();
        MetadataService.Metadata temp13 = new MetadataService.Metadata();
        List<MetadataService.Metadata> tempList = new List<MetadataService.Metadata>();
        tempList.add(temp13);
        MetadataService.PackageVersion temp15 = new MetadataService.PackageVersion();
        MetadataService.SessionHeader_element temp14 = new MetadataService.SessionHeader_element();
        MetadataService.MetadataPort temp12 = new MetadataService.MetadataPort();  
        MetadataService.MetadataWithContent temp48 = new MetadataService.MetadataWithContent();  
        //MetadataService.IReadResult temp16 = new MetadataService.IReadResult();  
        MetadataService.PackageVersion  temp17 = new MetadataService.PackageVersion  ();  
        //MetadataService.IReadResponseElement temp18 = new MetadataService.IReadResponseElement ();  
        MetadataService.readMetadata_element temp19 = new MetadataService.readMetadata_element();  
        MetadataService.ListView temp20 = new MetadataService.ListView();  
        MetadataService.SharedTo temp21 = new MetadataService.SharedTo ();  
        MetadataService.ListViewFilter  temp22 = new MetadataService.ListViewFilter ();  
        MetadataService.CustomObject temp23 = new MetadataService.CustomObject ();  
        MetadataService.ActionOverride temp24 = new MetadataService.ActionOverride ();  
        MetadataService.ArticleTypeChannelDisplay temp25 = new MetadataService.ArticleTypeChannelDisplay ();  
        MetadataService.ArticleTypeTemplate temp26 = new MetadataService.ArticleTypeTemplate ();  
        MetadataService.BusinessProcess temp27 = new MetadataService.BusinessProcess ();  
        MetadataService.RecordTypePicklistValue temp28 = new MetadataService.RecordTypePicklistValue ();  
        MetadataService.CompactLayout temp29 = new MetadataService.CompactLayout ();  
        MetadataService.FieldSet temp30 = new MetadataService.FieldSet ();  
        MetadataService.FieldSetItem temp31 = new MetadataService.FieldSetItem ();  
        MetadataService.CustomField temp32 = new MetadataService.CustomField (); 
        MetadataService.LookupFilter temp33 = new MetadataService.LookupFilter (); 
        MetadataService.HistoryRetentionPolicy temp34 = new MetadataService.HistoryRetentionPolicy (); 
        MetadataService.RecordType temp35 = new MetadataService.RecordType  (); 
        MetadataService.SearchLayouts temp36 = new MetadataService.SearchLayouts ();  
        MetadataService.SharingReason temp37 = new MetadataService.SharingReason  ();  
        MetadataService.ValidationRule temp38 = new MetadataService.ValidationRule ();  
        MetadataService.WebLink temp39 = new MetadataService.WebLink ();  
        MetadataService.PicklistValue temp40 = new MetadataService.PicklistValue ();  
        MetadataService.Picklist temp41 = new MetadataService.Picklist ();  
        MetadataService.FilterItem temp42 = new MetadataService.FilterItem ();  
        MetadataService.SharingRecalculation temp43 = new MetadataService.SharingRecalculation ();  
        MetadataService.ReadCustomObjectResult temp44 = new MetadataService.ReadCustomObjectResult ();  
        MetadataService.readCustomObjectResponse_element temp45 = new MetadataService.readCustomObjectResponse_element();  
        MetadataService.SearchLayouts temp46 = new MetadataService.SearchLayouts ();  
        MetadataService.SearchLayouts temp47 = new MetadataService.SearchLayouts (); 
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        MetadataService.MetadataPort metaDataPort = new MetadataService.MetadataPort();
        metaDataPort.readMetadata('',null); 
        metaDataPort.deleteMetadata('',null); 
        metaDataPort.createMetadata(null); 
    }
}