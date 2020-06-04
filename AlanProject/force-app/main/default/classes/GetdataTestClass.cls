/*
 * Description: GetdataTestClass 
 * Created By: Prince Leo
 * Date: 08-07-2016
 * 
*/

@isTest(seealldata=true)
Private class GetdataTestClass {

   
    static testmethod void AccountgetdataTest(){
      Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
      User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
      LocaleSidKey='en_US', ProfileId = p.Id,
      TimeZoneSidKey='America/Los_Angeles', UserName='standarduser09878987@testorg.com');

     System.runAs(u) {

    GenerateTestData.createAccount();
    
    PageReference myVfPage = Page.InvokeOraclePage;
    Test.setCurrentPage(myVfPage);
    
    ApexPages.currentPage().getParameters().put('id',GenerateTestData.acct.id);
   
    InvokeOraccle ivo = new InvokeOraccle();
    ivo.ValidateAccount();
    }
   } 
     static testmethod void AddressgetdataTest(){
     Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
      User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
      LocaleSidKey='en_US', ProfileId = p.Id,
      TimeZoneSidKey='America/Los_Angeles', UserName='standarduser0987658987@testorg.com');

     System.runAs(u) {
    GenerateTestData.createAccount();
    GenerateTestData.createAddress();
     Test.setCurrentPageReference(Page.InvokeOraclePage); // use setCurrentPageReference,
    ApexPages.currentPage().getParameters().put('id',GenerateTestData.adrs.id);
    InvokeOraccle ivo = new InvokeOraccle();
    ivo.ValidateAccount();
    }
    }
    
     
     private class WebServiceMockImpl implements WebServiceMock{
        public void doInvoke(Object stub, Object request, Map<String, Object> response,
                String endpoint, String soapAction, String requestName,
                String responseNS, String responseName, String responseType){
                    response.put('response_x', new xmlnsOracleComAppsHzSoaproviderPls.OutputParameters_element());
                return;
           }         
        }
        
         static testMethod void shouldBeAbleToGetData(){

        //GenerateTestData.createAccount();        
    Test.setMock(WebServiceMock.class, new WebServiceMockImpl());                  
    xmlnsOracleComAppsHzSoaproviderPls.OutputParameters_element OutVal = new xmlnsOracleComAppsHzSoaproviderPls.OutputParameters_element();
    xmlnsTrimbleComCusthubTnvcustebsacco sd = new xmlnsTrimbleComCusthubTnvcustebsacco();
    xmlnsTrimbleComCusthubTnvcustebsacco.tnvCustEBSAccountTrigger_pt sw = new xmlnsTrimbleComCusthubTnvcustebsacco.tnvCustEBSAccountTrigger_pt();
    OutVal = sw.process('12345');    
    OutVal.X_STATUS_CODE ='S';
    }    
    }