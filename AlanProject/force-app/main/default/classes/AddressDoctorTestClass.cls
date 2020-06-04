/*
 * Description: AddressDoctorTestClass 
 * Created By: Prince Leo
 * Date: 25-04-2016
 * 
*/

@isTest(seealldata = true)
Private class AddressDoctorTestClass {

	static testmethod void AccountValidateTest() {

		xmlnsOracleComFchTnvcusbpeladdressdo temp = new xmlnsOracleComFchTnvcusbpeladdressdo();
		xmlnsOracleComFchTnvcusbpeladdressdo.AddressOutputType temp1 = new xmlnsOracleComFchTnvcusbpeladdressdo.AddressOutputType();
		xmlnsOracleComFchTnvcusbpeladdressdo.AddressType temp2 = new xmlnsOracleComFchTnvcusbpeladdressdo.AddressType();
		xmlnsOracleComFchTnvcusbpeladdressdo.LocationType temp3 = new xmlnsOracleComFchTnvcusbpeladdressdo.LocationType();
		xmlnsOracleComFchTnvcusbpeladdressdo.tnvcusbpelAddressDoctorProcess_pt temp4 = new xmlnsOracleComFchTnvcusbpeladdressdo.tnvcusbpelAddressDoctorProcess_pt();
		//temp4.process('30000000','30000000','SFDC','09873289732ydh','',temp3,'','','','','');

		GenerateTestData.createAccount();
		ApexPages.StandardController sc = new ApexPages.StandardController(GenerateTestData.acc);
		System.currentPageReference().getParameters().put('id', GenerateTestData.acc.Id);
		Account_Address_validate_PageExt apc = new Account_Address_validate_PageExt(sc);
		apc.GlobalRecordID = '1';
		Account_Address_validate_PageExt.BuildWrapper bw = new Account_Address_validate_PageExt.BuildWrapper();
		bw.RecordID = '1';
		bw.AddressLine1 = 'test1';
		bw.AddressLine2 = 'test1';
		bw.AddressLine3 = 'test1';
		bw.AddressLine4 = 'test1';
		bw.city = 'citytest';
		bw.State = 'California';
		bw.county = 'testcounty';
		bw.Country = 'United States';
		bw.PostalCode = '12345';
		bw.statuscode = 'C2';
		bw.JobToken = '12334refrr444';

		// apc.OutPutAddress.add(bw);
		apc.makecallout();
		apc.SaveChanges();
		apc.CancelChanges();

		bw.getItems();
		apc.OneAddressValidation();
	}
	static testmethod void LeadValidateTest() {

		GenerateTestData.createLead();
		ApexPages.StandardController sc = new ApexPages.StandardController(GenerateTestData.LeadObj);
		System.currentPageReference().getParameters().put('id', GenerateTestData.LeadObj.Id);
		Lead_Address_validate_PageExt apc = new Lead_Address_validate_PageExt(sc);

		apc.GlobalRecordID = '1';
		Lead_Address_validate_PageExt.BuildWrapper bw = new Lead_Address_validate_PageExt.BuildWrapper();
		bw.RecordID = '1';
		bw.AddressLine1 = 'test1';
		bw.AddressLine2 = 'test1';
		bw.AddressLine3 = 'test1';
		bw.AddressLine4 = 'test1';
		bw.city = 'citytest';
		bw.State = 'California';
		bw.county = 'testcounty';
		bw.Country = 'United States';
		bw.PostalCode = '12345';
		bw.statuscode = 'C2';
		bw.JobToken = '12334refrr444';

		apc.makecallout();
		apc.SaveChanges();
		apc.CancelChanges();

		bw.getItems();
		apc.OneAddressValidation();
	}

	static testmethod void ContactValidateTest() {
		GenerateTestData.createAccount();
		GenerateTestData.createContact();
		ApexPages.StandardController sc = new ApexPages.StandardController(GenerateTestData.Ct);
		System.currentPageReference().getParameters().put('id', GenerateTestData.Ct.Id);
		Contact_Address_validate_PageExt apc = new Contact_Address_validate_PageExt(sc);

		apc.GlobalRecordID = '1';
		Contact_Address_validate_PageExt.BuildWrapper bw = new Contact_Address_validate_PageExt.BuildWrapper();
		bw.RecordID = '1';
		bw.AddressLine1 = 'test1';
		bw.AddressLine2 = 'test1';
		bw.AddressLine3 = 'test1';
		bw.AddressLine4 = 'test1';
		bw.city = 'citytest';
		bw.State = 'California';
		bw.county = 'testcounty';
		bw.Country = 'United States';
		bw.PostalCode = '12345';
		bw.statuscode = 'C2';
		bw.JobToken = '12334refrr444';

		apc.makecallout();
		apc.SaveChanges();
		apc.CancelChanges();

		bw.getItems();
		apc.OneAddressValidation();
	}

	static testmethod void AddressValidateTest() {
		GenerateTestData.createAccount();
		GenerateTestData.createAddress();
		ApexPages.StandardController sc = new ApexPages.StandardController(GenerateTestData.adrs);
		System.currentPageReference().getParameters().put('id', GenerateTestData.adrs.Id);
		Address_validate_PageExt apc = new Address_validate_PageExt(sc);

		apc.GlobalRecordID = '1';
		Address_validate_PageExt.BuildWrapper bw = new Address_validate_PageExt.BuildWrapper();
		bw.RecordID = '1';
		bw.AddressLine1 = 'test1';
		bw.AddressLine2 = 'test1';
		bw.AddressLine3 = 'test1';
		bw.AddressLine4 = 'test1';
		bw.city = 'citytest';
		bw.State = 'California';
		bw.county = 'testcounty';
		bw.Country = 'United States';
		bw.PostalCode = '12345';
		bw.statuscode = 'C2';
		bw.JobToken = '12334refrr444';

		apc.makecallout();
		apc.SaveChanges();
		apc.CancelChanges();

		bw.getItems();
		apc.OneAddressValidation();
	}

	private class WebServiceMockImpl implements WebServiceMock {
		public void doInvoke(Object stub, Object request, Map<String, Object> response,
		                     String endpoint, String soapAction, String requestName,
		                     String responseNS, String responseName, String responseType) {
			response.put('response_x', new xmlnsOracleComFchTnvcusbpeladdressdo.AddressOutputType());
			return;
		}
	}

	static testMethod void shouldBeAbleToGetData() {

		//GenerateTestData.createAccount();        
		Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
		xmlnsOracleComFchTnvcusbpeladdressdo temp = new xmlnsOracleComFchTnvcusbpeladdressdo();
		xmlnsOracleComFchTnvcusbpeladdressdo.AddressOutputType temp1 = new xmlnsOracleComFchTnvcusbpeladdressdo.AddressOutputType();
		xmlnsOracleComFchTnvcusbpeladdressdo.AddressType temp2 = new xmlnsOracleComFchTnvcusbpeladdressdo.AddressType();
		xmlnsOracleComFchTnvcusbpeladdressdo.LocationType temp3 = new xmlnsOracleComFchTnvcusbpeladdressdo.LocationType();
		xmlnsOracleComFchTnvcusbpeladdressdo.tnvcusbpelAddressDoctorProcess_pt temp4 = new xmlnsOracleComFchTnvcusbpeladdressdo.tnvcusbpelAddressDoctorProcess_pt();
		temp4.process('30000000', '30000000', 'SFDC', '09873289732ydh', '', temp3, '', '', '', '', '');

	}
}