/*****************************************************************************************
  Name        : Address_validate_PageExt
  Desc        : Used as Controller class for Page Address_validate_Page and invokes the Address Doctor Webservice
  ---------------------------------------------------------------------------
  Developer              Date            Description
  ---------------------------------------------------------------------------
  Prince Leo              29/03/2016       Created
  ******************************************************************************************/
public class Address_validate_PageExt {
	Public String AddressId { get; set; }
	Public List<BuildWrapper> OutPutAddress { get; set; }
	Private final Address__c Addrs;
	Public String GlobalRecordID { get; set; }
	public Boolean isAddressSelected { get; set; }
	public String JobTokenInput { get; set; }
	public Address_validate_PageExt(ApexPages.StandardController stdController) {
		isAddressSelected = false;

		AddressId = System.currentPageReference().getParameters().get('id');
		this.Addrs = (Address__c) stdController.getRecord();

		JobTokenInput = ([select id, Job_Token__c from Address__c where id = :AddressId]).Job_Token__c;
	}

	Public void makecallout() {
		try {
			xmlnsOracleComFchTnvcusbpeladdressdo.AddressOutputType Outp = new xmlnsOracleComFchTnvcusbpeladdressdo.AddressOutputType();
			xmlnsOracleComFchTnvcusbpeladdressdo.tnvcusbpelAddressDoctorProcess_pt CallEBS = new xmlnsOracleComFchTnvcusbpeladdressdo.tnvcusbpelAddressDoctorProcess_pt();
			xmlnsOracleComFchTnvcusbpeladdressdo.LocationType InputAddress = new xmlnsOracleComFchTnvcusbpeladdressdo.LocationType();
			xmlnsOracleComFchTnvcusbpeladdressdo.LocationType[] LineOut = new xmlnsOracleComFchTnvcusbpeladdressdo.LocationType[] { };
			InputAddress.AddressLine1 = Addrs.Address_Line1__c;
			InputAddress.AddressLine2 = Addrs.Address_Line2__c;
			InputAddress.AddressLine3 = Addrs.Address_Line3__c;
			InputAddress.AddressLine4 = Addrs.Address_Line4__c;
			InputAddress.City = Addrs.City__c;
			InputAddress.State = Addrs.State__c;
			InputAddress.Province = '';
			InputAddress.StateCode = '';
			InputAddress.County = Addrs.County__c;
			InputAddress.Country = Addrs.Country__c;
			InputAddress.CountryISOCode = '';
			InputAddress.PostalCode = Addrs.Zip__c;

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
				TestOutp.ValidatedAddress[0].AddressLine2 = 'Test1';
				TestOutp.ValidatedAddress[0].AddressLine3 = 'Test1';
				TestOutp.ValidatedAddress[0].AddressLine4 = 'Test1';
				TestOutp.ValidatedAddress[0].city = 'Test1';
				TestOutp.ValidatedAddress[0].State = 'Test1';
				TestOutp.ValidatedAddress[0].Country = 'Test1';
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
					bw.State = (Outp.ValidatedAddress.get(i).state != '' ? Outp.ValidatedAddress.get(i).state : (Outp.ValidatedAddress.get(i).stateCode != '' ? Outp.ValidatedAddress.get(i).stateCode : ''));
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
				Address__c Ad = new Address__c(id = Addrs.id);
				Ad.Address_Line1__c = Bw.AddressLine1;
				Ad.Address_Line2__c = Bw.AddressLine2;
				Ad.Address_Line3__c = Bw.AddressLine3;
				Ad.Address_Line4__c = Bw.AddressLine4;
				Ad.City__c = Bw.City;
				Ad.State__c = Bw.State;
				Ad.Country__c = Bw.Country;
				Ad.County__c = Bw.County;
				Ad.ZIP__c = Bw.PostalCode;
				Ad.Validation_Status_Code__c = (Bw.StatusCode != Null ? Bw.StatusCode.substring(0, 2) : Bw.StatusCode);
				Ad.Job_Token__c = Bw.JobToken;
				if (Bw.StatusCode != Null) {
					String Temp = Bw.StatusCode.substring(0, 2);
					system.debug('------^^^^^^-------' + Ad.Validation_Status__c);
					if (Temp == 'C1' || Temp == 'C2' || Temp == 'C3' || Temp == 'C4' || Temp == 'V1' || Temp == 'V2' || Temp == 'V3' || Temp == 'V4')
					Ad.Validation_Status__c = 'Corrected';
					else
					Ad.Validation_Status__c = 'Not Corrected';

					system.debug('------^^^^^^-------' + Ad.Validation_Status__c);
				}
				AddressHandler.launchControl.put('resetStatusFlag', 1);
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