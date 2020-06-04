/*****************************************************************************************
  Name        : Contact_Address_validate_PageExt
  Desc        : Used as Controller class for Page Contact_Address_validate_Page and invokes the Address Doctor Webservice
  ---------------------------------------------------------------------------
  Developer              Date            Description
  ---------------------------------------------------------------------------
  Prince Leo              29/03/2016       Created
  ******************************************************************************************/
public class Contact_Address_validate_PageExt {
	Public String ContactId { get; set; }
	Public List<BuildWrapper> OutPutAddress { get; set; }
	Private final Contact Addrs;
	Public String GlobalRecordID { get; set; }
	public Boolean isAddressSelected { get; set; }
	public String JobTokenInput { get; set; }
	Public String Line1 { get; set; }
	Public String Line2 { get; set; }
	Public String Line3 { get; set; }
	Public String Line4 { get; set; }
	public Contact_Address_validate_PageExt(ApexPages.StandardController stdController) {
		isAddressSelected = false;
		ContactId = System.currentPageReference().getParameters().get('id');
		this.Addrs = (Contact) stdController.getRecord();
		if (Addrs.MailingStreet != null) {
			list<string> LineList = Addrs.MailingStreet.split('[\n]');
			Line1 = (LineList != null && LineList.size() > 0) ? LineList[0] : '';
			Line2 = (LineList != null && LineList.size() > 1) ? LineList[1] : '';
			Line3 = (LineList != null && LineList.size() > 2) ? LineList[2] : '';
			Line4 = (LineList != null && LineList.size() > 3) ? LineList[3] : '';
		}
		JobTokenInput = ([select id, Job_Token__c from Contact where id = :ContactId]).Job_Token__c;


	}

	Public void makecallout() {
		try {
			xmlnsOracleComFchTnvcusbpeladdressdo.AddressOutputType Outp = new xmlnsOracleComFchTnvcusbpeladdressdo.AddressOutputType();
			xmlnsOracleComFchTnvcusbpeladdressdo.tnvcusbpelAddressDoctorProcess_pt CallEBS = new xmlnsOracleComFchTnvcusbpeladdressdo.tnvcusbpelAddressDoctorProcess_pt();
			xmlnsOracleComFchTnvcusbpeladdressdo.LocationType InputAddress = new xmlnsOracleComFchTnvcusbpeladdressdo.LocationType();
			xmlnsOracleComFchTnvcusbpeladdressdo.LocationType[] LineOut = new xmlnsOracleComFchTnvcusbpeladdressdo.LocationType[] { };
			list<string> addlist = Addrs.MailingStreet.split('[\n]');
			InputAddress.AddressLine1 = (addlist != null && addlist.size() > 0) ? addlist[0] : '';
			InputAddress.AddressLine2 = (addlist != null && addlist.size() > 1) ? addlist[1] : '';
			InputAddress.AddressLine3 = (addlist != null && addlist.size() > 2) ? addlist[2] : '';
			InputAddress.AddressLine4 = (addlist != null && addlist.size() > 3) ? addlist[3] : '';

			InputAddress.City = Addrs.MailingCity;
			InputAddress.State = Addrs.MailingState;
			InputAddress.Province = '';
			InputAddress.StateCode = '';
			InputAddress.County = Addrs.County__c;
			InputAddress.Country = Addrs.MailingCountry;
			InputAddress.CountryISOCode = '';
			InputAddress.PostalCode = Addrs.MailingPostalCode;

			if (!Test.isRunningTest()) {
				CallEBS.timeout_x = 60000;
				Outp = CallEBS.process('30000000', '30000000', 'SFDC', '09873289732ydh', JobTokenInput, InputAddress, '', '', '', '', '');

			} else {
				xmlnsOracleComFchTnvcusbpeladdressdo.AddressOutputType TestOutp = new xmlnsOracleComFchTnvcusbpeladdressdo.AddressOutputType();
				xmlnsOracleComFchTnvcusbpeladdressdo.LocationType DummyAddress = new xmlnsOracleComFchTnvcusbpeladdressdo.LocationType();
				TestOutp.ValidatedAddress = new List<xmlnsOracleComFchTnvcusbpeladdressdo.LocationType> ();
				TestOutp.ValidatedAddress.add(DummyAddress);
				TestOutp.AddressCheckResults = 'C2';
				TestOutp.JobToken = '';
				TestOutp.ValidatedAddress[0].AddressLine1 = 'Test1';
				TestOutp.ValidatedAddress[0].AddressLine2 = 'Test1';
				TestOutp.ValidatedAddress[0].AddressLine3 = 'Test1';
				TestOutp.ValidatedAddress[0].AddressLine4 = 'Test1';
				TestOutp.ValidatedAddress[0].city = 'Test1';
				TestOutp.ValidatedAddress[0].State = 'California';
				TestOutp.ValidatedAddress[0].Country = 'United States';
				TestOutp.ValidatedAddress[0].County = 'Test1';
				TestOutp.ValidatedAddress[0].PostalCode = '12345';
				Outp = TestOutp;

			}

			system.debug('^^^^^^^^' + Outp.AddressCheckResults);
			system.debug('^^^^^^^^' + Outp.Jobtoken);

			if (Outp.ValidatedAddress != Null)
			{
				OutPutAddress = new List<BuildWrapper> ();
				for (integer i = 0; i<Outp.ValidatedAddress.size(); i++) {
					// bw.Isselected = True;
					BuildWrapper bw = new BuildWrapper();
					bw.RecordID = String.valueof(i + 1);
					bw.AddressLine1 = Outp.ValidatedAddress.get(i).AddressLine1;
					bw.AddressLine2 = Outp.ValidatedAddress.get(i).AddressLine2;
					bw.AddressLine3 = Outp.ValidatedAddress.get(i).AddressLine3;
					bw.AddressLine4 = Outp.ValidatedAddress.get(i).AddressLine4;
					bw.city = Outp.ValidatedAddress.get(i).city;
					bw.County = Outp.ValidatedAddress.get(i).county;
					bw.Country = Outp.ValidatedAddress.get(i).country;
					bw.State = (Outp.ValidatedAddress.get(i).state != '' ? Outp.ValidatedAddress.get(i).state : Outp.ValidatedAddress.get(i).stateCode != '' ? Outp.ValidatedAddress.get(i).stateCode : '');
					bw.PostalCode = Outp.ValidatedAddress.get(i).PostalCode;
					bw.statuscode = Outp.AddressCheckResults;
					bw.JobToken = Outp.Jobtoken;
					bw.status = Outp.ValidatedAddress.get(i).status;
					OutPutAddress.add(bw);
				}

			}
			if (Outp.ValidatedAddress == Null) {
				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'No Matching Records Found.');
				ApexPages.addMessage(myMsg);
				OutPutAddress = new List<BuildWrapper> ();
				BuildWrapper bw = new BuildWrapper();
				bw.Isselected = False;
				bw.AddressLine1 = 'No Match Found';
				bw.AddressLine2 = 'No Match Found';
				bw.AddressLine3 = 'No Match Found';
				bw.AddressLine4 = 'No Match Found';
				bw.city = 'No Match Found';
				bw.County = 'No Match Found';
				bw.Country = 'No Match Found';
				bw.State = 'No Match Found';
				bw.PostalCode = 'No Match Found';
				OutPutAddress.add(bw);
			}
		}

		Catch(Exception e) {
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: ' + e);
			ApexPages.addMessage(myMsg);
		}
	}

	Public Pagereference CancelChanges() {
		PageReference AddPage = new PageReference('/' + Addrs.Id);
		AddPage.setRedirect(true);
		return AddPage;

	}
	Public Pagereference SaveChanges() {
		for (BuildWrapper Bw : OutPutAddress)
		{
			system.debug('8888888888' + Bw.Isselected);
			system.debug('8888888888' + Bw.AddressLine1);
			system.debug('8888GlobalRecordID888888' + GlobalRecordID);
			system.debug('888888RecordID8888' + Bw.RecordID);
			if (Bw.RecordID == GlobalRecordID)
			{
				Contact Ad = new Contact(id = Addrs.id);
				Ad.MailingStreet = Bw.AddressLine1 + '\n' +
				(Bw.AddressLine2 != null && Bw.AddressLine1 != '' ? Bw.AddressLine2 + '\n' : '') +
				(Bw.AddressLine3 != null && Bw.AddressLine2 != '' ? Bw.AddressLine3 + '\n' : '') +
				(Bw.AddressLine4 != null && Bw.AddressLine3 != '' ? Bw.AddressLine4 : '');

				Ad.Mailingcity = Bw.City;
				Ad.MailingState = Bw.State;
				Ad.MailingCountry = Bw.Country;
				Ad.County__c = Bw.County;
				Ad.MailingPostalCode = Bw.PostalCode;
				Ad.Validation_Status_Code__c = (Bw.StatusCode != Null ? Bw.StatusCode.substring(0, 2) : Bw.StatusCode);
				Ad.Job_Token__c = Bw.JobToken;
				system.debug('JobToken-----------' + Bw.JobToken);
				system.debug('StatusCode-----------' + Bw.StatusCode);
				system.debug('Validation_Status_Code__c-----------' + Ad.Validation_Status_Code__c);
				if (Bw.StatusCode != Null) {
					String Temp = Bw.StatusCode.substring(0, 2);
					if (Temp == 'C1' || Temp == 'C2' || Temp == 'C3' || Temp == 'C4' || Temp == 'V1' || Temp == 'V2' || Temp == 'V3' || Temp == 'V4')
					Ad.Validation_Status__c = 'Corrected';
					else
					Ad.Validation_Status__c = 'Not Corrected';
				}
				AddressHandler.launchControl.put('resetStatusFlag', 1);
				AccountHelper.launchControl.put('resetStatusFlag', 1);
				Update Ad;
			}
		}
		PageReference AddPage = new PageReference('/' + Addrs.Id);
		AddPage.setRedirect(true);
		return AddPage;


	}

	public PageReference OneAddressValidation() {
		isAddressSelected = true;

		return null;
	}

	Public class BuildWrapper {
		public List<SelectOption> getItems() {
			List<SelectOption> options = new List<SelectOption> ();

			options.add(new SelectOption('True', 'True'));
			options.add(new SelectOption('False', 'False'));
			return options;
		}

		Public Boolean Isselected { get; set; }
		Public String RecordID { get; set; }
		Public String AddressLine1 { get; set; }
		Public String AddressLine2 { get; set; }
		Public String AddressLine3 { get; set; }
		Public String AddressLine4 { get; set; }
		Public String City { get; set; }
		Public String State { get; set; }
		Public String Country { get; set; }
		Public String County { get; set; }
		Public String PostalCode { get; set; }
		public string statuscode { get; set; }
		Public String JobToken { get; set; }
		public String status { get; set; }
		public BuildWrapper() {
			Isselected = false;
		}

	}
}