/*****************************************************************************************
  Name    : CreateorUpdateEntitlements 
  Desc    : Used implementing the inbound to SFDC from Oracle EBS for Entitlement Object
 
 
  Modification Log : 
  ---------------------------------------------------------------------------
  Developer              Date            Description
  ---------------------------------------------------------------------------
  Vikram Mandla			02/12/2013      Created
  Sunay Prasad R K		21/02/2014      Modified
  Deepak Kumar			03/04/2014      Modified for PLN-ISSUE[13574]
  Sunay Prasad R K		15/04/2014      Modified to add the exception handling along with email notification
  Suresh Babu Murugan	03/04/2014      Modified for APP-14204 : Please bring Industry back into SFDC from the Entitlement
 ******************************************************************************************/
global class CreateorUpdateEntitlements {

	public class soapexception extends exception { }
	/*
	 * Method name  : CreateServiceLine
	 * Description  : Webserice method to load Entitlement data from Oracle EBS to SFDC standard object Entitlement
	 * Return Type  : list<ResponseWraperClass>
	 * Parameter    : requesrwrapervar
	 */

	webService static list<ResponseWraperClass> CreateServiceLine(list<requestdata> requesrwrapervar)
	{
		list<Entitlement> Entitlementlist = new list<Entitlement> ();
		List<list<Database.UpsertResult>> MastersrList = new List<list<Database.UpsertResult>> ();
		Entitlement entVar;
		date startdate, enddate;
		ResponseWraperClass respvar;
		string assetid;

		list<ResponseWraperClass> respvarlist = new list<ResponseWraperClass> ();
		Database.UpsertResult[] srList;
		boolean blnFinalResult = false;
		boolean blnSystemException = false;
		boolean throwEx = false;

		map<string, asset> assetmap = new map<string, asset> ();
		set<string> assetNamesSet = new set<string> ();
		map<string, Entitlement> BuEntitlementmap = new map<String, Entitlement> ();
		map<string, Entitlement> PlancalBumap = new map<String, Entitlement> ();
		map<string, Entitlement> Entitlementmap = new map<string, Entitlement> ();
		map<string, Account> accountmap = new map<string, Account> ();
		map<string, product2> productmap = new map<string, product2> ();
		set<string> EntitlementNamesSet = new set<string> ();
		set<string> AccountNamesSet = new set<string> ();
		set<String> attribute5Set = new Set<String> ();
		set<string> EntTypeSet = new set<string> ();
		set<string> productNamesSet = new set<string> ();
		set<string> assetSequenceSet = new set<string> ();
		set<string> customerMasterIdSet = new set<String> ();
		Set<Id> entitlementIdSet = new Set<Id> ();
		map<string, Address__c> Addressmap = new map<string, Address__c> ();
		set<string> AddressIDset = new Set<String> ();

		String ErrorRespString;


		//Iterate over the request data and validate the values sent and also add them into sets
		for (requestdata reqvar : requesrwrapervar)
		{
			/*
			  if(reqvar.EntitlementAsset == null || reqvar.EntitlementAsset == ''){
			  blnFinalResult = true;
			  respvar = new ResponseWraperClass();  
			  respvar.result ='Failure';
			  respvar.ErrorMessage = 'EntitlementAsset does not have a value. Please check the data';
			  respvar.Errorcode = 'SL-ERR-107';
			  respvar.TransactionNameAndValue = reqvar.EntitlementAsset;
			  respvarlist.add(respvar);
			  }
			 */


			if ((reqvar.EntitlementName == null || reqvar.EntitlementName == '') && (reqvar.attribute5 == null || reqvar.attribute5 == '')) {
				blnFinalResult = true;
				respvar = new ResponseWraperClass();
				respvar.result = 'Failure';
				respvar.ErrorMessage = 'EntitlementName and Oracle Identifier does not have a value. Please check the data';
				respvar.Errorcode = 'SL-ERR-107';
				respvar.TransactionNameAndValue = reqvar.EntitlementName;
				respvarlist.add(respvar);
			}
			else if (reqvar.EntitlementAccountName == null || reqvar.EntitlementAccountName == '') {
				blnFinalResult = true;
				respvar = new ResponseWraperClass();
				respvar.result = 'Failure';
				respvar.ErrorMessage = 'EntitlementAccountName does not have a value. Please check the data';
				respvar.Errorcode = 'SL-ERR-107';
				respvar.TransactionNameAndValue = reqvar.EntitlementAccountName;
				respvarlist.add(respvar);
			}
			/*
			  else if(reqvar.EntitlementType == null || reqvar.EntitlementType == ''){
			  blnFinalResult = true;
			  respvar = new ResponseWraperClass();  
			  respvar.result ='Failure';
			  respvar.ErrorMessage = 'EntitlementType does not have a value. Please check the data';
			  respvar.Errorcode = 'SL-ERR-107';
			  respvarlist.add(respvar);
			  }
			 */
			else if (reqvar.ProductCode == null || reqvar.ProductCode == '') {
				blnFinalResult = true;
				respvar = new ResponseWraperClass();
				respvar.result = 'Failure';
				respvar.ErrorMessage = 'ProductCode does not have a value. Please check the data';
				respvar.Errorcode = 'SL-ERR-107';
				respvar.TransactionNameAndValue = reqvar.ProductCode;
				respvarlist.add(respvar);
			}
			else if (reqvar.AssetSequence == null || reqvar.AssetSequence == '') {
				blnFinalResult = true;
				respvar = new ResponseWraperClass();
				respvar.result = 'Failure';
				respvar.ErrorMessage = 'AssetSequence does not have a value. Please check the data';
				respvar.Errorcode = 'SL-ERR-107';
				respvar.TransactionNameAndValue = reqvar.AssetSequence;
				respvarlist.add(respvar);
			}
			else if (reqvar.EntitlementAccountMasterID == null || reqvar.EntitlementAccountMasterID == '') {
				blnFinalResult = true;
				respvar = new ResponseWraperClass();
				respvar.result = 'Failure';
				respvar.ErrorMessage = 'EntitlementAccountMasterID does not have a value. Please check the data';
				respvar.Errorcode = 'SL-ERR-107';
				respvar.TransactionNameAndValue = reqvar.EntitlementAccountMasterID;
				respvarlist.add(respvar);
			}
			else {
				assetNamesSet.add(reqvar.EntitlementAsset.trim());
				EntitlementNamesSet.add(reqvar.EntitlementName.trim());
				AccountNamesSet.add(reqvar.EntitlementAccountName.trim());
				//EntTypeSet.add(reqvar.EntitlementType.trim());
				productNamesSet.add(reqvar.ProductCode.trim());
				assetSequenceSet.add(reqvar.AssetSequence.trim());
				customerMasterIdSet.add(reqvar.EntitlementAccountMasterID.trim());
				if (reqvar.BillToFCHPartyID != Null && reqvar.BillToFCHPartyID != '') CustomerMasterIDSet.add(reqvar.BillToFCHPartyID.trim());
				if (reqvar.ShipToFCHPartyID != Null && reqvar.ShipToFCHPartyID != '') CustomerMasterIDSet.add(reqvar.ShipToFCHPartyID.trim());
				if (reqvar.BillToFCHPartySiteID != Null && reqvar.BillToFCHPartySiteID != '') AddressIdset.add(reqvar.BillToFCHPartySiteID.trim());
				if (reqvar.ShipToFCHPartySiteID != Null && reqvar.ShipToFCHPartySiteID != '') AddressIdset.add(reqvar.ShipToFCHPartySiteID.trim());
				if (reqvar.attribute5 != Null && reqvar.attribute5 != '')
				attribute5Set.add(reqvar.attribute5.trim());
			}
		}


		//for(entitlement entvar1 : [Select Id, IsDeleted,Asset_Sequence__c,Product_Code__c,Contract_Number__c, Name, CurrencyIsoCode, CreatedDate, Account.Name,Account.FCH_Party_ID__c,CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, AccountId, Type, ServiceContractId, ContractLineItemId, AssetId, StartDate, EndDate, SlaProcessId, BusinessHoursId, IsPerIncident, CasesPerEntitlement, RemainingCases, Status, Annual_Cost__c, Asset_Effectivity__c,   Asset_Effectivity_End_Date__c,   Asset_Effectivity_Start_Date__c FROM Entitlement  where Contract_Number__c in :EntitlementNamesSet and Account.FCH_Party_ID__c in :customerMasterIdSet and type in :EntTypeSet AND Asset_Sequence__c in:assetSequenceSet])
		for (entitlement entvar1 :[Select Id, IsDeleted, Oracle_Unique_Identifier__c, Asset_Sequence__c, Product_Code__c, Contract_Number__c, Name, Quantity__c, Asset_Quantity__c, Contract_Details__c, Serial_Number__c, CurrencyIsoCode, CreatedDate, Account.Name, Account.FCH_Party_ID__c, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, AccountId, Type, ServiceContractId, ContractLineItemId, AssetId, StartDate, EndDate, SlaProcessId, BusinessHoursId, IsPerIncident, CasesPerEntitlement, RemainingCases, Status, Annual_Cost__c, Asset_Effectivity__c, Asset_Effectivity_End_Date__c, Asset_Effectivity_Start_Date__c FROM Entitlement where Contract_Number__c in :EntitlementNamesSet])
		{
			//System.debug('entvar1::'+entvar1);
			//Entitlementmap.put(string.valueof(entvar1.Contract_Number__c)+string.valueof(entvar1.Account.FCH_Party_ID__c)+string.valueof(entvar1.type)+string.valueof(entvar1.Asset_Sequence__c),entvar1);
			Entitlementmap.put(string.valueof(entvar1.Contract_Number__c) + string.valueof(entvar1.Account.FCH_Party_ID__c) + string.valueof(entvar1.Asset_Sequence__c), entvar1);
			if (entvar1.Contract_Number__c != NUll && entvar1.Contract_Number__c != '' && entvar1.Product_Code__c != Null && entvar1.Product_Code__c != '')
			BuEntitlementmap.put(string.valueof(entvar1.Contract_Number__c), entvar1);

		}
		for (entitlement entvar1 :[Select Id, IsDeleted, Oracle_Unique_Identifier__c, Asset_Sequence__c, Product_Code__c, Contract_Number__c, Name, Quantity__c, Asset_Quantity__c, Contract_Details__c, Serial_Number__c, CurrencyIsoCode, CreatedDate, Account.Name, Account.FCH_Party_ID__c, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, AccountId, Type, ServiceContractId, ContractLineItemId, AssetId, StartDate, EndDate, SlaProcessId, BusinessHoursId, IsPerIncident, CasesPerEntitlement, RemainingCases, Status, Annual_Cost__c, Asset_Effectivity__c, Asset_Effectivity_End_Date__c, Asset_Effectivity_Start_Date__c FROM Entitlement where Oracle_Unique_Identifier__c in :attribute5Set])
		{
			if (entvar1.Oracle_Unique_Identifier__c != NUll && entvar1.Oracle_Unique_Identifier__c != '')
			PlancalBuMap.put(string.valueof(entvar1.Oracle_Unique_Identifier__c), entvar1);
		}

		//For loop to fill asset map
		for (asset assetobj :[Select Id, Asset_Oracle_ID__c, ContactId, AccountId, Product2Id, IsCompetitorProduct, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, IsDeleted, CurrencyIsoCode, Name, SerialNumber, InstallDate, PurchaseDate, UsageEndDate, Status, Price, Quantity, Description, City__c, Country__c, Name__c, Product_Version__c, State__c, Street_Address__c, Zip_Code__c FROM Asset where Asset_Oracle_ID__c in :assetNamesSet])
		{
			assetmap.put(assetobj.Asset_Oracle_ID__c, assetobj);
		}
		//For loop to fill Account map
		for (Account acc :[select id, name, FCH_Party_ID__c from Account where FCH_Party_ID__c in :customerMasterIdSet])
		{
			accountmap.put(acc.FCH_Party_ID__c, acc);
		}

		for (Address__c Add :[select id, FCH_Party_Site_ID__c from Address__c where FCH_Party_Site_ID__c in :AddressIdset FOR UPDATE])
		{
			Addressmap.put(string.valueof(Add.FCH_Party_Site_ID__c), Add);
		}

		//For loop to fill Product map
		for (product2 prodvar :[select id, Name, productcode, ICC_Type__c, Product_Family_Description__c, Business_Area__c from product2 where productcode in :productNamesSet])
		{
			productmap.put(prodvar.productcode, prodvar);
		}

		try {
			system.debug('requesrwrapervar=====' + requesrwrapervar.size());
			system.debug('requesrwrapervar=====' + requesrwrapervar);
			//Iterate over the data received from Oracle for creating or updating the Entitlement records

			for (requestdata reqvar : requesrwrapervar)
			{
				ErrorRespString = ' ';
				system.debug('********Stage1**********' + ErrorRespString);
				// Assign the value of Entitlement Name and Pass in response at time of System Error.
				ErrorRespString = reqvar.EntitlementName;
				respvar = new ResponseWraperClass();
				//Validate and map the fields from Oracle to Asset object   
				system.debug('********Stage2**********' + reqvar.AssetEffectivityStartdate);
				system.debug('********Stage3**********' + reqvar.AssetEffectivityEnddate);
				system.debug('********Stage4**********' + PlancalBuMap);
				//if(Entitlementmap!=null && (reqvar.EntitlementName!=null && reqvar.EntitlementName!='' )&& (reqvar.EntitlementAccountMasterID!=null && reqvar.EntitlementAccountMasterID!='') && (reqvar.EntitlementType!=null && reqvar.EntitlementType!='') && Entitlementmap.get(reqvar.EntitlementName+reqvar.EntitlementAccountMasterID+reqvar.EntitlementType+reqvar.AssetSequence)!=null){
				if (BuEntitlementmap.size() > 0 && BuEntitlementmap.get(reqvar.EntitlementName) != Null && (reqvar.EntitlementName != null && reqvar.EntitlementName != '') && productmap != Null && productmap.get(reqvar.ProductCode).Business_Area__c != Null &&
				(productmap.get(reqvar.ProductCode).Business_Area__c == 'GC PROJECT SOFTWARE' || productmap.get(reqvar.ProductCode).Business_Area__c == 'CONTRACTOR PROJECT SOFTWARE' || productmap.get(reqvar.ProductCode).Business_Area__c == 'VICO SOFTWARE' ||
				 productmap.get(reqvar.ProductCode).Business_Area__c == 'PROJECT SOFTWARE SOLUTIONS' || productmap.get(reqvar.ProductCode).Business_Area__c == 'MANHATTAN SOFTWARE'))
				{
					entvar = BuEntitlementmap.get(reqvar.EntitlementName);
					if (assetmap != null && reqvar.EntitlementAsset != null && reqvar.EntitlementAsset != '' && assetmap.get(reqvar.EntitlementAsset) != null)
					assetid = assetmap.get(reqvar.EntitlementAsset).id;
				}
				else if (PlancalBuMap.size() > 0 && PlancalBuMap.get(reqvar.attribute5) != Null && (reqvar.attribute5 != null && reqvar.attribute5 != '') && productmap != Null && productmap.get(reqvar.ProductCode).Business_Area__c != Null &&
				(productmap.get(reqvar.ProductCode).Business_Area__c == 'Plancal' || productmap.get(reqvar.ProductCode).Business_Area__c == 'MEP ESTIMATING' || productmap.get(reqvar.ProductCode).Business_Area__c == 'ACCUBID' ||
				 productmap.get(reqvar.ProductCode).Business_Area__c == 'QUICKPEN' || productmap.get(reqvar.ProductCode).Business_Area__c == 'TRADE SERVICE' || productmap.get(reqvar.ProductCode).Business_Area__c == 'MIXED REALITY FTG' ||
				 productmap.get(reqvar.ProductCode).Business_Area__c == 'MEP BUILDING DATA' || productmap.get(reqvar.ProductCode).Business_Area__c == 'BUILDING CONSTRUCTION' || productmap.get(reqvar.ProductCode).Business_Area__c == 'MEP PROFESSIONAL SERVICES' ||
				 productmap.get(reqvar.ProductCode).Business_Area__c == 'SECO' || productmap.get(reqvar.ProductCode).Business_Area__c == 'SURVEY SOLUTIONS' || productmap.get(reqvar.ProductCode).Business_Area__c == 'MOBILE COMPUTING' ||
				 productmap.get(reqvar.ProductCode).Business_Area__c == 'TRIMBLE POSITIONING SERVICES' || productmap.get(reqvar.ProductCode).Business_Area__c == 'OMNISTAR' || productmap.get(reqvar.ProductCode).Business_Area__c == 'TPS ACQUIRED NETWORKS' || productmap.get(reqvar.ProductCode).Business_Area__c == 'AXIO-NET'))
				{
					entvar = PlancalBuMap.get(reqvar.attribute5);
					if (assetmap != null && reqvar.EntitlementAsset != null && reqvar.EntitlementAsset != '' && assetmap.get(reqvar.EntitlementAsset) != null)
					assetid = assetmap.get(reqvar.EntitlementAsset).id;
				}
				else
				entvar = new Entitlement();

				if (assetmap != null && reqvar.EntitlementAsset != null && reqvar.EntitlementAsset != '' && assetmap.get(reqvar.EntitlementAsset) != null)
				entvar.Assetid = assetmap.get(reqvar.EntitlementAsset).id;
				else if (productmap != Null && (productmap.get(reqvar.ProductCode).ICC_Type__c == 'Scheduled Publications' || productmap.get(reqvar.ProductCode).ICC_Type__c == 'Unscheduled Publications') && productmap.get(reqvar.ProductCode).Business_Area__c == 'TRADE SERVICE') {
					system.debug('>>>>>>>Inside 1st elseif>>>>>>>>' + productmap.get(reqvar.ProductCode).ICC_Type__c + '>>>>>>>' + entvar);
					entvar.Assetid = Null;
				}
				else {
					system.debug('>>>>>>>Inside else>>>>>>>>' + productmap.get(reqvar.ProductCode).ICC_Type__c);
					//throw new soapexception('invalid installbase details.please check the data');
					respvar.result = 'Failure';
					blnFinalResult = true;
					respvar.Errorcode = 'SL-ERR-101';
					respvar.ErrorMessage = 'Failure: Invalid installbase details. Asset ' + reqvar.EntitlementAsset + ' does not exist .Please check the data';
					respvar.TransactionNameAndValue = 'Entitlement:' + reqvar.EntitlementName;
					respvar.ebs_asset_number = reqvar.EntitlementAsset;
					respvar.ebs_contract_number = reqvar.EntitlementName;
					respvar.ebs_sequence_number = reqvar.AssetSequence;
					respvarlist.add(respvar);
				}

				if (reqvar.EntitlementAccountMasterID != null && reqvar.EntitlementAccountMasterID != '' && accountmap != null && accountmap.get(reqvar.EntitlementAccountMasterID) != null)
				entvar.Accountid = accountmap.get(reqvar.EntitlementAccountMasterID).id;
				//if(reqvar.EntitlementAccountMasterID == null || reqvar.EntitlementAccountMasterID == ''){
				else {
					blnFinalResult = true;
					//throwEx = true;
					respvar.result = 'Failure';
					respvar.Errorcode = 'SL-ERR-102';
					respvar.ErrorMessage = 'Failure: Invalid service details. Account Master ID ' + reqvar.EntitlementAccountMasterID + ' does not exist. Please check the data';
					respvar.TransactionNameAndValue = 'Entitlement: ' + reqvar.EntitlementName;
					respvar.ebs_asset_number = reqvar.EntitlementAsset;
					//respvar.sfdc_asset_number
					respvar.ebs_contract_number = reqvar.EntitlementName;
					respvar.ebs_sequence_number = reqvar.AssetSequence;
					respvarlist.add(respvar);
				}
				if (reqvar.AssetEffectivity != null && reqvar.AssetEffectivity.length() > 30) {
					blnFinalResult = true;
					//throwEx = true;
					respvar.result = 'Failure';
					respvar.Errorcode = 'SL-ERR-103';
					respvar.ErrorMessage = 'Failure: Invalid service details. Asset Effectivity can not be more than 30 characters. Please check the data';
					respvar.TransactionNameAndValue = 'Asset Effectivity: ' + reqvar.AssetEffectivity + 'cannot be more than 30 characters';
					respvar.ebs_asset_number = reqvar.EntitlementAsset;
					//respvar.sfdc_asset_number
					respvar.ebs_contract_number = reqvar.EntitlementName;
					respvar.ebs_sequence_number = reqvar.AssetSequence;
					respvarlist.add(respvar);
				}
				if ((reqvar.EntitlementName == null || reqvar.EntitlementName == '') && (reqvar.attribute5 == null || reqvar.attribute5 == '')) {
					blnFinalResult = true;
					//throwEx = true;
					respvar.result = 'Failure';
					respvar.Errorcode = 'SL-ERR-104';
					respvar.ErrorMessage = 'Failure: Invalid service details. Name and Oracle Identifier can not be null. Please check the data';
					respvar.TransactionNameAndValue = 'EntitlementName: ' + reqvar.EntitlementName;
					respvar.ebs_asset_number = reqvar.EntitlementAsset;
					//respvar.sfdc_asset_number
					respvar.ebs_contract_number = reqvar.EntitlementName;
					respvar.ebs_sequence_number = reqvar.AssetSequence;
					respvarlist.add(respvar);
				}
				else
				entvar.Contract_Number__c = reqvar.EntitlementName; // Entitlement name passed currently will be saved as contract number 
				entvar.Asset_Sequence__c = reqvar.AssetSequence;

				/*
				  if(throwEx == true){
				  throw new soapexception('');
				  }
				 */

				system.debug('>>>>>>>>>>PrintAssetEffectivity>>>>>>' + reqvar.EntitlementStatus);
				system.debug('>>>>>>>>>>PrintAssetEffectivity>>>>>>' + reqvar.AssetEffectivity);

				if (reqvar.EntitlementStatus != null && reqvar.EntitlementStatus != '')
				{
					entvar.Asset_Effectivity__c = reqvar.EntitlementStatus;
				}
				if (reqvar.AssetEffectivity != Null && reqvar.AssetEffectivity != '' && reqvar.AssetEffectivity == 'TERMINATED')
				{
					entvar.Asset_Effectivity__c = reqvar.AssetEffectivity;
				}

				if (reqvar.AssetEffectivity != NUll && reqvar.AssetEffectivity != '' && productmap.get(reqvar.ProductCode) != Null && (productmap.get(reqvar.ProductCode).Business_Area__c == 'TRIMBLE POSITIONING SERVICES' || productmap.get(reqvar.ProductCode).Business_Area__c == 'OMNISTAR' || productmap.get(reqvar.ProductCode).Business_Area__c == 'TPS ACQUIRED NETWORKS' || productmap.get(reqvar.ProductCode).Business_Area__c == 'AXIO-NET'))
				{
					entvar.Asset_Effectivity__c = reqvar.AssetEffectivity;
				}
				//To derive the product name based on the product code
				if (productmap != null && productmap.size() > 0 && reqvar.ProductCode != null && reqvar.ProductCode != '' && productmap.get(reqvar.ProductCode) != null) {
					entvar.Name = productmap.get(reqvar.ProductCode).Name;
					//PLN-ISSUE[13574] - START
					entvar.Entitlement_Product__c = productmap.get(reqvar.ProductCode).Id;
					entvar.Type = productmap.get(reqvar.ProductCode).Product_Family_Description__c;
					//PLN-ISSUE[13574] - END
				}

				if (reqvar.ATTRIBUTE1 != Null && reqvar.ATTRIBUTE1 != '' && !String.isblank(reqvar.ATTRIBUTE1)) entvar.Quantity__c = Decimal.valueof(reqvar.ATTRIBUTE1.trim());
				if (reqvar.ATTRIBUTE2 != Null && reqvar.ATTRIBUTE2 != '') entvar.Asset_Quantity__c = reqvar.ATTRIBUTE2;
				if (reqvar.ATTRIBUTE3 != Null && reqvar.ATTRIBUTE3 != '') entvar.Contract_Details__c = reqvar.ATTRIBUTE3;
				if (reqvar.ATTRIBUTE4 != Null && reqvar.ATTRIBUTE4 != '') entvar.Serial_Number__c = reqvar.ATTRIBUTE4;

				//TAP Attribute mapping
				if (reqvar.TAP_HOURS_USED != Null && reqvar.TAP_HOURS_USED != '') entvar.Hours_Used__c = reqvar.TAP_HOURS_USED;
				if (reqvar.TAP_PRICING_REGION != Null && reqvar.TAP_PRICING_REGION != '') entvar.Pricing_Region__c = reqvar.TAP_PRICING_REGION;
				if (reqvar.TAP_GEOFENCE_REGION != Null && reqvar.TAP_GEOFENCE_REGION != '') entvar.Geofence_Region__c = reqvar.TAP_GEOFENCE_REGION;
				if (reqvar.TAP_RENEWAL_ORDER != Null && reqvar.TAP_RENEWAL_ORDER != '') entvar.Renewal_Order_Number__c = reqvar.TAP_RENEWAL_ORDER;

				//Bill To Account
				if (reqvar.BillToFCHPartyID != Null && reqvar.BillToFCHPartyID != '' && accountmap.get(reqvar.BillToFCHPartyID) != Null)
				entvar.Bill_To_Account__c = accountmap.get(reqvar.BillToFCHPartyID).id;

				if (reqvar.BillToFCHPartyID != Null && reqvar.BillToFCHPartyID != '')
				entvar.Bill_To_FCH_Party_ID__c = reqvar.BillToFCHPartyID;

				//Ship To Account
				if (reqvar.ShipToFCHPartyID != Null && reqvar.ShipToFCHPartyID != '' && accountmap.get(reqvar.ShipToFCHPartyID) != Null)
				entvar.Ship_To_Account__c = accountmap.get(reqvar.ShipToFCHPartyID).id;

				if (reqvar.ShipToFCHPartyID != Null && reqvar.ShipToFCHPartyID != '')
				entvar.Ship_To_FCH_Party_ID__c = reqvar.ShipToFCHPartyID;

				//Bill To Address
				if (reqvar.BillToFCHPartySiteID != Null && reqvar.BillToFCHPartySiteID != '' && addressmap.get(reqvar.BillToFCHPartySiteID) != Null)
				entvar.Bill_To_Address__c = addressmap.get(reqvar.BillToFCHPartySiteID).id;

				if (reqvar.BillToFCHPartySiteID != Null && reqvar.BillToFCHPartySiteID != '')
				entvar.Bill_To_FCH_Party_Site_ID__c = reqvar.BillToFCHPartySiteID;

				//Ship To Address
				if (reqvar.ShipToFCHPartySiteID != Null && reqvar.ShipToFCHPartySiteID != '' && addressmap.get(reqvar.ShipToFCHPartySiteID) != Null)
				entvar.Ship_To_Address__c = addressmap.get(reqvar.ShipToFCHPartySiteID).id;

				if (reqvar.ShipToFCHPartySiteID != Null && reqvar.ShipToFCHPartySiteID != '')
				entvar.Ship_To_FCH_Party_Site_ID__c = reqvar.ShipToFCHPartySiteID;


				/*
				  if(reqvar.EntitlementStatus!=null && reqvar.EntitlementStatus!='')
				  {
				  entvar.Status = reqvar.EntitlementStatus;
				  }
				 */

				if (reqvar.AssetEffectivityStartdate != null && reqvar.AssetEffectivityStartdate != '' && productmap.get(reqvar.ProductCode).Business_Area__c != Null && (productmap.get(reqvar.ProductCode).Business_Area__c == 'Plancal' || productmap.get(reqvar.ProductCode).Business_Area__c == 'MEP ESTIMATING' || productmap.get(reqvar.ProductCode).Business_Area__c == 'ACCUBID' || productmap.get(reqvar.ProductCode).Business_Area__c == 'QUICKPEN' || productmap.get(reqvar.ProductCode).Business_Area__c == 'TRADE SERVICE' || productmap.get(reqvar.ProductCode).Business_Area__c == 'MIXED REALITY FTG' || productmap.get(reqvar.ProductCode).Business_Area__c == 'MEP BUILDING DATA' || productmap.get(reqvar.ProductCode).Business_Area__c == 'BUILDING CONSTRUCTION' || productmap.get(reqvar.ProductCode).Business_Area__c == 'MEP PROFESSIONAL SERVICES' || productmap.get(reqvar.ProductCode).Business_Area__c == 'SECO' || productmap.get(reqvar.ProductCode).Business_Area__c == 'SURVEY SOLUTIONS' || productmap.get(reqvar.ProductCode).Business_Area__c == 'MOBILE COMPUTING' || productmap.get(reqvar.ProductCode).Business_Area__c == 'TRIMBLE POSITIONING SERVICES' || productmap.get(reqvar.ProductCode).Business_Area__c == 'OMNISTAR' || productmap.get(reqvar.ProductCode).Business_Area__c == 'TPS ACQUIRED NETWORKS' || productmap.get(reqvar.ProductCode).Business_Area__c == 'AXIO-NET'))
				{
					string str = reqvar.AssetEffectivityStartdate;
					list<string> li = str.split('T');

					startdate = date.valueof(li[0]);
					//entvar.Asset_Effectivity_Start_Date__c= date.valueof(li[0]);
					entvar.StartDate = date.valueof(li[0]);
				}
				else if (reqvar.AssetEffectivityStartdate != null && reqvar.AssetEffectivityStartdate != '' && productmap != Null && productmap.get(reqvar.ProductCode).Business_Area__c != Null && (productmap.get(reqvar.ProductCode).Business_Area__c == 'GC PROJECT SOFTWARE' || productmap.get(reqvar.ProductCode).Business_Area__c == 'CONTRACTOR PROJECT SOFTWARE' || productmap.get(reqvar.ProductCode).Business_Area__c == 'VICO SOFTWARE' || productmap.get(reqvar.ProductCode).Business_Area__c == 'PROJECT SOFTWARE SOLUTIONS' || productmap.get(reqvar.ProductCode).Business_Area__c == 'MANHATTAN SOFTWARE'))
				{
					string str = reqvar.AssetEffectivityStartdate;
					list<string> li = str.split('T');

					startdate = date.valueof(li[0]);
					//entvar.Asset_Effectivity_Start_Date__c= date.valueof(li[0]);
					entvar.Contract_Start_Date__c = date.valueof(li[0]);
				}

				if (reqvar.AssetEffectivityEnddate != null && reqvar.AssetEffectivityEnddate != '' && productmap.get(reqvar.ProductCode).Business_Area__c != Null && (productmap.get(reqvar.ProductCode).Business_Area__c == 'Plancal' || productmap.get(reqvar.ProductCode).Business_Area__c == 'MEP ESTIMATING' || productmap.get(reqvar.ProductCode).Business_Area__c == 'ACCUBID' || productmap.get(reqvar.ProductCode).Business_Area__c == 'QUICKPEN' || productmap.get(reqvar.ProductCode).Business_Area__c == 'TRADE SERVICE' || productmap.get(reqvar.ProductCode).Business_Area__c == 'MIXED REALITY FTG' || productmap.get(reqvar.ProductCode).Business_Area__c == 'MEP BUILDING DATA' || productmap.get(reqvar.ProductCode).Business_Area__c == 'BUILDING CONSTRUCTION' || productmap.get(reqvar.ProductCode).Business_Area__c == 'MEP PROFESSIONAL SERVICES' || productmap.get(reqvar.ProductCode).Business_Area__c == 'SECO' || productmap.get(reqvar.ProductCode).Business_Area__c == 'SURVEY SOLUTIONS' || productmap.get(reqvar.ProductCode).Business_Area__c == 'MOBILE COMPUTING' || productmap.get(reqvar.ProductCode).Business_Area__c == 'TRIMBLE POSITIONING SERVICES' || productmap.get(reqvar.ProductCode).Business_Area__c == 'OMNISTAR' || productmap.get(reqvar.ProductCode).Business_Area__c == 'TPS ACQUIRED NETWORKS' || productmap.get(reqvar.ProductCode).Business_Area__c == 'AXIO-NET'))
				{
					string str = reqvar.AssetEffectivityEnddate;
					list<string> li = str.split('T');

					enddate = date.valueof(li[0]);
					//entvar.Asset_Effectivity_End_Date__c=date.valueof(li[0]);
					entvar.EndDate = date.valueof(li[0]);
				}
				else if (reqvar.AssetEffectivityEnddate != null && reqvar.AssetEffectivityEnddate != '' && productmap != Null && productmap.get(reqvar.ProductCode).Business_Area__c != Null && (productmap.get(reqvar.ProductCode).Business_Area__c == 'GC PROJECT SOFTWARE' || productmap.get(reqvar.ProductCode).Business_Area__c == 'CONTRACTOR PROJECT SOFTWARE' || productmap.get(reqvar.ProductCode).Business_Area__c == 'VICO SOFTWARE' || productmap.get(reqvar.ProductCode).Business_Area__c == 'PROJECT SOFTWARE SOLUTIONS' || productmap.get(reqvar.ProductCode).Business_Area__c == 'MANHATTAN SOFTWARE'))
				{
					string str = reqvar.AssetEffectivityEnddate;
					list<string> li = str.split('T');

					enddate = date.valueof(li[0]);
					//entvar.Asset_Effectivity_End_Date__c=date.valueof(li[0]);
					entvar.Contract_End_Date__c = date.valueof(li[0]);
				}

				if (reqvar.EntitlementStartDate != null && reqvar.EntitlementStartDate != '' && productmap.get(reqvar.ProductCode).Business_Area__c != Null && (productmap.get(reqvar.ProductCode).Business_Area__c == 'Plancal' || productmap.get(reqvar.ProductCode).Business_Area__c == 'MEP ESTIMATING' || productmap.get(reqvar.ProductCode).Business_Area__c == 'ACCUBID' || productmap.get(reqvar.ProductCode).Business_Area__c == 'QUICKPEN' || productmap.get(reqvar.ProductCode).Business_Area__c == 'TRADE SERVICE' || productmap.get(reqvar.ProductCode).Business_Area__c == 'MIXED REALITY FTG' || productmap.get(reqvar.ProductCode).Business_Area__c == 'MEP BUILDING DATA' || productmap.get(reqvar.ProductCode).Business_Area__c == 'BUILDING CONSTRUCTION' || productmap.get(reqvar.ProductCode).Business_Area__c == 'MEP PROFESSIONAL SERVICES' || productmap.get(reqvar.ProductCode).Business_Area__c == 'SECO' || productmap.get(reqvar.ProductCode).Business_Area__c == 'SURVEY SOLUTIONS' || productmap.get(reqvar.ProductCode).Business_Area__c == 'MOBILE COMPUTING' || productmap.get(reqvar.ProductCode).Business_Area__c == 'TRIMBLE POSITIONING SERVICES' || productmap.get(reqvar.ProductCode).Business_Area__c == 'OMNISTAR' || productmap.get(reqvar.ProductCode).Business_Area__c == 'TPS ACQUIRED NETWORKS' || productmap.get(reqvar.ProductCode).Business_Area__c == 'AXIO-NET'))
				{
					string str = reqvar.EntitlementStartDate;
					list<string> li = str.split('T');

					//entvar.Asset_Effectivity_Start_Date__c= date.valueof(li[0]);
					entvar.Contract_Start_Date__c = date.valueof(li[0]);

				}
				else if (reqvar.EntitlementStartDate != null && reqvar.EntitlementStartDate != '' && productmap != Null && productmap.get(reqvar.ProductCode).Business_Area__c != Null && (productmap.get(reqvar.ProductCode).Business_Area__c == 'GC PROJECT SOFTWARE' || productmap.get(reqvar.ProductCode).Business_Area__c == 'CONTRACTOR PROJECT SOFTWARE' || productmap.get(reqvar.ProductCode).Business_Area__c == 'VICO SOFTWARE' || productmap.get(reqvar.ProductCode).Business_Area__c == 'PROJECT SOFTWARE SOLUTIONS' || productmap.get(reqvar.ProductCode).Business_Area__c == 'MANHATTAN SOFTWARE'))
				{
					string str = reqvar.EntitlementStartDate;
					list<string> li = str.split('T');

					//entvar.Asset_Effectivity_Start_Date__c= date.valueof(li[0]);
					entvar.Startdate = date.valueof(li[0]);

				}

				if (reqvar.EntitlementEndDate != null && reqvar.EntitlementEndDate != '' && productmap.get(reqvar.ProductCode).Business_Area__c != Null && (productmap.get(reqvar.ProductCode).Business_Area__c == 'Plancal' || productmap.get(reqvar.ProductCode).Business_Area__c == 'MEP ESTIMATING' || productmap.get(reqvar.ProductCode).Business_Area__c == 'ACCUBID' || productmap.get(reqvar.ProductCode).Business_Area__c == 'QUICKPEN' || productmap.get(reqvar.ProductCode).Business_Area__c == 'TRADE SERVICE' || productmap.get(reqvar.ProductCode).Business_Area__c == 'MIXED REALITY FTG' || productmap.get(reqvar.ProductCode).Business_Area__c == 'MEP BUILDING DATA' || productmap.get(reqvar.ProductCode).Business_Area__c == 'BUILDING CONSTRUCTION' || productmap.get(reqvar.ProductCode).Business_Area__c == 'MEP PROFESSIONAL SERVICES' || productmap.get(reqvar.ProductCode).Business_Area__c == 'SECO' || productmap.get(reqvar.ProductCode).Business_Area__c == 'SURVEY SOLUTIONS' || productmap.get(reqvar.ProductCode).Business_Area__c == 'MOBILE COMPUTING' || productmap.get(reqvar.ProductCode).Business_Area__c == 'TRIMBLE POSITIONING SERVICES' || productmap.get(reqvar.ProductCode).Business_Area__c == 'OMNISTAR' || productmap.get(reqvar.ProductCode).Business_Area__c == 'TPS ACQUIRED NETWORKS' || productmap.get(reqvar.ProductCode).Business_Area__c == 'AXIO-NET'))
				{
					string str = reqvar.EntitlementEndDate;
					list<string> li = str.split('T');

					//entvar.Asset_Effectivity_End_Date__c = date.valueof(li[0]);
					entvar.Contract_End_Date__c = date.valueof(li[0]);

				}
				else if (reqvar.EntitlementEndDate != null && reqvar.EntitlementEndDate != '' && productmap != Null && productmap.get(reqvar.ProductCode).Business_Area__c != Null && (productmap.get(reqvar.ProductCode).Business_Area__c == 'GC PROJECT SOFTWARE' || productmap.get(reqvar.ProductCode).Business_Area__c == 'CONTRACTOR PROJECT SOFTWARE' || productmap.get(reqvar.ProductCode).Business_Area__c == 'VICO SOFTWARE' || productmap.get(reqvar.ProductCode).Business_Area__c == 'PROJECT SOFTWARE SOLUTIONS' || productmap.get(reqvar.ProductCode).Business_Area__c == 'MANHATTAN SOFTWARE'))
				{
					string str = reqvar.EntitlementEndDate;
					list<string> li = str.split('T');

					//entvar.Asset_Effectivity_End_Date__c = date.valueof(li[0]);
					entvar.Enddate = date.valueof(li[0]);

				}

				if (reqvar.AnnualCost != null && reqvar.AnnualCost != '' && !String.isblank(reqvar.AnnualCost)) // && reqvar.AnnualCostCurrency!=null && reqvar.AnnualCostCurrency!='')
				{
					//entvar.Annual_Cost__c = reqvar.AnnualCostCurrency + decimal.valueOf(reqvar.AnnualCost);
					entvar.Annual_Cost__c = decimal.valueOf(reqvar.AnnualCost.trim());
				}
				if (reqvar.ProductCode != null && reqvar.ProductCode != '')
				{
					entvar.Product_Code__c = reqvar.ProductCode;
				}
				if (reqvar.AnnualCostCurrency != null && reqvar.AnnualCostCurrency != '')
				{
					entvar.CurrencyISOCode = reqvar.AnnualCostCurrency;
				}

				//Mapping Oracle Unique Identifier with attribute5
				if (reqvar.attribute5 != Null && reqvar.attribute5 != '')
				entVar.Oracle_Unique_Identifier__c = reqvar.attribute5;

				// Mapping MEPNA- Industry with ATTRIBUTE8
				if (reqvar.attribute8 != Null && reqvar.attribute8 != '')
				entVar.Industry__c = reqvar.attribute8;

				//entvar.StartDate = (reqvar.EntitlementStartDate!=null && reqvar.EntitlementStartDate!='')?startdate:null;
				//entvar.EndDate = (reqvar.EntitlementEndDate!=null && reqvar.EntitlementEndDate!='')?enddate:null;
				if (entvar.Accountid != null)
				Entitlementlist.add(entvar);
			}

			//To upsert data into Entitlement object
			/*
			  if(Entitlementlist!=null && Entitlementlist.size()>0){
			  srList = Database.upsert(Entitlementlist,Entitlement.Fields.Id,false);
			  }
			 */

			set<id> succEntitleIdSet = new set<id> ();

			//To upsert data into Entitlement object
			if (Entitlementlist != null && Entitlementlist.size() > 0) {
				srList = Database.upsert(Entitlementlist, Entitlement.Fields.Id, false);
				MastersrList.add(srList);
			}

			for (list<Database.UpsertResult> srval : MastersrList) {
				for (Database.UpsertResult sr : srval) {
					succEntitleIdSet.add(sr.getid());
				}
			}

			map<id, string> Ent_ID_EntNum_Map = new map<id, string> ();
			map<id, string> Ent_ID_ContNum_Map = new map<id, string> ();
			map<id, string> Ent_ID_Seq_Map = new map<id, string> ();

			for (Entitlement ent :[Select ID, Contract_Number__c, Asset_Sequence__c from Entitlement where id IN :succEntitleIdSet]) {
				Ent_ID_ContNum_Map.put(ent.id, ent.Contract_Number__c);
				Ent_ID_Seq_Map.put(ent.id, ent.Asset_Sequence__c);
			}

			if (srList != null && srList.size() > 0) {
				Integer cnt = 0;
				for (list<Database.UpsertResult> srval : MastersrList) {
					for (Database.UpsertResult sr : srval) {
						if (sr.isSuccess()) {
							respvar = new ResponseWraperClass();
							respvar.result = 'Success';
							respvar.Errorcode = 'SL-SUCC-111';
							respvar.ErrorMessage = 'Success for';
							respvar.TransactionNameAndValue = 'Entitlement:' + sr.getid();
							//respvar.ebs_asset_number 
							//respvar.sfdc_asset_number

							if (Ent_ID_ContNum_Map.get(sr.getid()) != null) {
								respvar.ebs_contract_number = Ent_ID_ContNum_Map.get(sr.getid());
							}

							//respvar.sfdc_contract_number
							if (Ent_ID_Seq_Map.get(sr.getid()) != null) {
								respvar.ebs_sequence_number = Ent_ID_Seq_Map.get(sr.getid());
							}

							//respvar.sfdc_sequence_number 
							entitlementIdSet.add(sr.getid());
							respvarlist.add(respvar);
						}
						else {
							// Operation failed, so get all errors                
							for (Database.Error err : sr.getErrors()) {
								respvar = new ResponseWraperClass();
								respvar.result = 'Failure';
								blnFinalResult = true;
								respvar.Errorcode = 'SL-ERR-105' + err.getStatusCode();
								respvar.ErrorMessage = 'Failure: ' + err.getMessage();
								respvar.TransactionNameAndValue = 'Entitlement:' + sr.getid();
								//respvar.ebs_asset_number 
								//respvar.sfdc_asset_number
								system.debug(cnt + '--------cnt-------' + Ent_ID_ContNum_Map.get(sr.getid()));
								if (Ent_ID_ContNum_Map.get(sr.getid()) != null) {
									respvar.ebs_contract_number = Ent_ID_ContNum_Map.get(sr.getid());
								} else if (cnt<Entitlementlist.size()) {
									respvar.ebs_contract_number = Entitlementlist[cnt].Contract_Number__c;
								}

								//respvar.sfdc_contract_number
								if (Ent_ID_Seq_Map.get(sr.getid()) != null) {
									respvar.ebs_sequence_number = Ent_ID_Seq_Map.get(sr.getid());
								}

								//respvar.sfdc_sequence_number    
								respvarlist.add(respvar);
							}
						}
						cnt++;
					}
				}
			}
			//added by sagar on 03/19/2014.
			if (entitlementIdSet.size()> 0) {
				EntitlementHelper.processEntitlements(entitlementIdSet);
			}

		}
		catch(Exception ex)
		{
			respvar.result = 'Failure';
			blnFinalResult = true;
			blnSystemException = true;
			respvar.Errorcode = 'SL-ERR-106';
			respvar.ErrorMessage = 'Failure: The exception is ' + string.valueof(ex);
			respvar.TransactionNameAndValue = ErrorRespString;
			respvarlist.add(respvar);
		}

		//Passing final result for the entire load, if there in on failure then Final Result will be Filaure 
		//and all are success the final result will be passed as Success 
		if (blnFinalResult == true) {
			respvar = new ResponseWraperClass();
			respvar.FinalResult = 'Failure';
			respvarlist.add(respvar);
		} else {
			respvar = new ResponseWraperClass();
			respvar.FinalResult = 'Success';
			respvarlist.add(respvar);
		}
		System.debug(respvarlist);
		return respvarlist;
	}

	//global class to expose parameters to Oracle to accept Entitlement data
	global class requestdata
	{
		//Entitlement data
		webservice String EntitlementAsset;
		webservice String EntitlementAccountMasterID;
		webservice String EntitlementAccountName;
		webservice String EntitlementName;
		webservice String EntitlementType;
		webservice String EntitlementProductFamily;
		webservice String EntitlementStatus;
		webservice String EntitlementStartDate;
		webservice String EntitlementEndDate;
		webservice String AssetEffectivity;
		webservice String AssetEffectivityStartdate;
		webservice String AssetEffectivityEnddate;
		webservice String AnnualCost;
		webservice String AssetSequence;
		webservice String AnnualCostCurrency;
		webservice String ProductCode;
		webservice string ServiceProductId;
		webservice string ContractModifier;
		webservice String ShipToFCHPartyID;
		webservice String ShipToFCHPartySiteID;
		webservice String BillToFCHPartyID;
		webservice String BillToFCHPartySiteID;

		//Created for TAP Division
		webservice String TAP_HOURS_USED;
		webservice String TAP_PRICING_REGION;
		webservice String TAP_GEOFENCE_REGION;
		webservice String TAP_RENEWAL_ORDER;

		webservice string attribute1;
		webservice string attribute2;
		webservice string attribute3;
		webservice string attribute4;
		webservice string attribute5;
		webservice string attribute6;
		webservice string attribute7;
		webservice string attribute8;
		webservice string attribute9;
		webservice string attribute10;
		webservice string attribute11;
		webservice string attribute12;
		webservice string attribute13;
		webservice string attribute14;
		webservice string attribute15;
		webservice string attribute16;
		webservice string attribute17;
		webservice string attribute18;
		webservice string attribute19;
		webservice string attribute20;
	}

	//Response class to send the success or failure detail back to oracle EBS 
	global class ResponseWraperClass
	{
		webservice String Result { get; set; }
		webservice String FinalResult { get; set; }
		webservice String Errorcode { get; set; }
		webservice String ErrorMessage { get; set; }
		webservice String TransactionNameAndValue { get; set; }
		//webservice String TransactionValue{get;set;}  
		webservice String ebs_asset_number { get; set; }
		webservice String sfdc_asset_number { get; set; }
		webservice String ebs_contract_number { get; set; }
		webservice String sfdc_contract_number { get; set; }
		webservice String ebs_sequence_number { get; set; }
		webservice String sfdc_sequence_number { get; set; }
	}
}