/*****************************************************************************************
  Name        : MavenLinkProjectConvention
  Desc        : Web service class that is invoked from Create MavenLink Project button on 
  Opportunity to create Project in Mavenlink   
  ---------------------------------------------------------------------------
  Developer              Date            Description
  ---------------------------------------------------------------------------
  Ankur Patel           15/05/2019          Created
 ******************************************************************************************/
global with sharing class MavenLinkProjectConvention {

	/*
	 * Make callout to create project in Mavenlink
	 */
	webservice static string createMavenLinkProject(ID opportunityId, String sSellingDivision) {
		String sProjectId = '';
		String sDynamicFields = '';
		String sErrorMessage = '';
		String sRequiredFields = '';
		if (sSellingDivision != 'RE&WS')
		sSellingDivision = 'GCCM';

		String sMavenlinkProject = 'MavenLinkProject-' + sSellingDivision;

		List<Field_Map__c> lstFieldMaps = [select Id, Note__c, CustomLogic__c, Reference_Field__c, Unique_Identifier__c, Default_Value__c, Reference_Query__c, Object_Map__r.Source_Object__c,
		                                   Object_Map__r.Target_Object__c, Target_Field__c, Source_Field__c, Object_Map__r.Source_Type__c, Object_Map__r.Required_Fields__c from Field_Map__c
		                                   where Object_Map__r.Name = :sMavenlinkProject];
		for (Field_Map__c oFieldMap : lstFieldMaps) {
			sRequiredFields = oFieldMap.Object_Map__r.Required_Fields__c;
			if (!oFieldMap.CustomLogic__c && oFieldMap.Source_Field__c != null && oFieldMap.Source_Field__c != '')
			sDynamicFields += oFieldMap.Source_Field__c + ',';
		}
		system.debug('--------sDynamicFields----------' + sDynamicFields);
		Opportunity oOpportunity = database.query('Select ' + sDynamicFields + 'Id,Price_List__r.CurrencyISOCode,Legal_Entity__c,Selling_Division__c,Account.EBS_Account_Number__c,Account.Name,' +
		                                          'Bill_To_Account__r.EBS_Account_Number__c,Bill_To_Account__r.Name,Ship_To_Account__r.EBS_Account_Number__c,Ship_To_Account__r.Name,' +
		                                          'Bill_to_Address__r.Bill_To_Location__c,Bill_to_Address__r.Country__c,Bill_to_Address__r.Ship_To_Location__c,Ship_to_Address1__r.Bill_To_Location__c,Ship_to_Address1__r.Ship_To_Location__c,' +
		                                          'Bill_To_Contact__c,Bill_To_Contact__r.Name,Bill_To_Contact__r.Enterprise_Contact_Number__c from Opportunity where Id =: opportunityId');
		Map<String, String> mapProjectAttributes = prepareProjectAttributes(oOpportunity);
		try {
			WorkSpace prj = new WorkSpace();
			prj.custom_fields = new List<CustomAttribute> ();
			String workspaceJS = '{"workspace" : {';
			for (Field_Map__c oFieldMap : lstFieldMaps) {
				if (oFieldMap.Note__c != null ? oFieldMap.Note__c.equalsIgnoreCase('Standard Attribute') : false) {
					if (oFieldMap.Default_Value__c != '' && oFieldMap.Default_Value__c != null)
					workspaceJS += '"' + oFieldMap.Target_Field__c + '" : "' + oFieldMap.Default_Value__c + '",';
					else if (!oFieldMap.CustomLogic__c && oOpportunity.get(oFieldMap.Source_Field__c) != null)
					workspaceJS += '"' + oFieldMap.Target_Field__c + '" : "' + String.valueOf(oOpportunity.get(oFieldMap.Source_Field__c)) + '",';
					else if (oFieldMap.CustomLogic__c && (mapProjectAttributes.containsKey(oFieldMap.Source_Field__c) ? mapProjectAttributes.get(oFieldMap.Source_Field__c) != null && mapProjectAttributes.get(oFieldMap.Source_Field__c) != '' : false))
					workspaceJS += '"' + oFieldMap.Target_Field__c + '" : "' + mapProjectAttributes.get(oFieldMap.Source_Field__c) + '",';
					else if (sRequiredFields.contains(oFieldMap.Target_Field__c))
					sErrorMessage += 'Required field missing ' + oFieldMap.Reference_Field__c + '.\n';
				} else {
					if (oFieldMap.Default_Value__c != '' && oFieldMap.Default_Value__c != null)
					prj.custom_fields.add(new CustomAttribute(oFieldMap.Target_Field__c, oFieldMap.Default_Value__c));
					else if (!oFieldMap.CustomLogic__c && oOpportunity.get(oFieldMap.Source_Field__c) != null)
					prj.custom_fields.add(new CustomAttribute(oFieldMap.Target_Field__c, String.valueOf(oOpportunity.get(oFieldMap.Source_Field__c))));
					else if (oFieldMap.CustomLogic__c && (mapProjectAttributes.containsKey(oFieldMap.Source_Field__c) ? mapProjectAttributes.get(oFieldMap.Source_Field__c) != null && mapProjectAttributes.get(oFieldMap.Source_Field__c) != '' : false))
					prj.custom_fields.add(new CustomAttribute(oFieldMap.Target_Field__c, mapProjectAttributes.get(oFieldMap.Source_Field__c)));
					else if (sRequiredFields.contains(oFieldMap.Target_Field__c))
					sErrorMessage += 'Required field missing ' + oFieldMap.Reference_Field__c + '.\n';
				}

			}

			if (sErrorMessage != '')
			return 'Error\n' + sErrorMessage;

			workspaceJS += '"custom_fields":' + JSON.serialize(prj.custom_fields) + '}}';



			HttpRequest req = new HttpRequest();
			req.setHeader('Authorization', 'Bearer ' + System_Integration_Config__c.getAll().get(sMavenlinkProject).Password__c);
			req.setHeader('Content-Type', 'application/json');
			req.setEndpoint(System_Integration_Config__c.getAll().get(sMavenlinkProject).End_Point_URL__c);
			req.setBody(workspaceJS);
			req.setMethod('POST');


			HttpResponse res = new HTTP().send(req);

			if (res.getStatusCode() != 200) {
				WS_Interface_Log__c log = WS_Interface_Log.createLog('MavenLinkProject', 'createMavenLinkProject', res.getStatusCode() + '-' + res.getStatus(), res.getBody(), workspaceJS);
				insert log;
				return 'Error : ' + res.getStatusCode() + ' - ' + res.getStatus();
			} else {
				WS_Interface_Log__c log = WS_Interface_Log.createLog('MavenLinkProject', 'createMavenLinkProject', '', '', workspaceJS);
				insert log;
			}

			JSONParser parser = JSON.createParser(res.getBody());
			while (parser.nextToken() != null) {
				if (parser.getText() == 'id') {
					parser.nextToken();
					sProjectId = parser.getText();
					break;
				}
			}
		} catch(exception ex) {
			return 'Error : ' + ex.getMessage();
		}

		String sResult = updateOpportunity(opportunityId, sProjectId, mapProjectAttributes.get('sSellingDivision'), mapProjectAttributes.get('sBillToLocation'), mapProjectAttributes.get('sShipToLocation'));
		if (!sResult.equals('success')) {
			return 'Error : ' + sResult;
		}
		return sProjectId;
	}

	/*
	 * Update opportunity and populate Mavenlink Project number, Bill To/Ship To location, Business Area etc.
	 */
	public static String updateOpportunity(ID opportunityId, String sProjectId, String sSellingDivision, String sBillToLocation, String sShipToLocation) {
		try {
			Opportunity oOpprtunity = new Opportunity();
			oOpprtunity.Id = opportunityId;
			oOpprtunity.Mavenlink_Project_Number__c = sProjectId;
			oOpprtunity.Business_Area__c = sSellingDivision;
			oOpprtunity.Bill_To_Location__c = sBillToLocation;
			oOpprtunity.Ship_To_Location__c = sShipToLocation;
			update oOpprtunity;
		} catch(Exception ex) {
			return ex.getMessage();
		}
		return 'success';
	}

	/*
	 * Method to configure request data to create project in Mavenlink
	 */
	public static Map<String, String> prepareProjectAttributes(Opportunity oOpportunity) {
		Map<String, String> mapProjectAttributes = new Map<String, String> ();

		//Variable Declaration 
		String sSellingDivision = '';
		String sCustomer = '';
		String sBillToCustomer = '';
		String sShipToCustomer = '';
		String sBillToLocation = '';
		String sShipToLocation = '';
		String sOperatingUnit = '';
		String sBillToContact = '';
		String sLegalEntity = '';
		String sTaskBillingMode = '';
		String sCurrencyISOCode = '';
		for (Country_To_BU_Map__c oCountryToBUMap : Country_To_BU_Map__c.getAll().values()) {
			if (oOpportunity.Legal_Entity__c != null ? oOpportunity.Legal_Entity__c.equals(oCountryToBUMap.Legal_Entity__c) : false) {
				sOperatingUnit = oCountryToBUMap.Operating_Unit__c;
				sLegalEntity = oCountryToBUMap.Owning_Org__c + ' | ' + oOpportunity.Legal_Entity__c;
				break;
			}
		}
		sCurrencyISOCode = oOpportunity.Price_List__r.CurrencyISOCode;
		system.debug('--------sOperatingUnit--------' + sOperatingUnit);
		List<Selling_Division_BA_mapping__mdt> lstSellingDivisions = new List<Selling_Division_BA_mapping__mdt> ();

		//Deriving Values
		if (oOpportunity.Selling_Division__c != Null) {
			lstSellingDivisions = [Select id, Business_Area__c, TaskBillingMode__c, Org_Id__c from Selling_Division_BA_mapping__mdt where label = :oOpportunity.Selling_Division__c];
			if (lstSellingDivisions.size() > 0) {
				sSellingDivision = lstSellingDivisions.get(0).Org_Id__c + ' | ' + lstSellingDivisions.get(0).Business_Area__c;
				sTaskBillingMode = String.valueOf(lstSellingDivisions.get(0).TaskBillingMode__c);
			}
		}

		if (oOpportunity.Bill_To_Contact__c != null)
		sBillToContact = (oOpportunity.Bill_To_Contact__r.Enterprise_Contact_Number__c != null ? oOpportunity.Bill_To_Contact__r.Enterprise_Contact_Number__c : '')
		+ ' | ' + oOpportunity.Bill_To_Contact__r.Name;
		sCustomer = oOpportunity.Account.EBS_Account_Number__c + ' | ' + oOpportunity.Account.Name;
		sBillToCustomer = oOpportunity.Bill_To_Account__r.EBS_Account_Number__c + ' | ' + oOpportunity.Bill_To_Account__r.Name;
		sShipToCustomer = oOpportunity.Ship_To_Account__r.EBS_Account_Number__c + ' | ' + oOpportunity.Ship_To_Account__r.Name;

		if (oOpportunity.Bill_to_Address__r.Bill_To_Location__c != Null && sOperatingUnit != '') {
			sBillToLocation = getLocation(oOpportunity.Bill_to_Address__r.Bill_To_Location__c, sOperatingUnit);
		}
		if (oOpportunity.Ship_to_Address1__r.Ship_To_Location__c != Null && sOperatingUnit != '') {
			sShipToLocation = getLocation(oOpportunity.Ship_to_Address1__r.Ship_To_Location__c, sOperatingUnit);
		}

		mapProjectAttributes.put('sCustomer', sCustomer);
		mapProjectAttributes.put('sSellingDivision', sSellingDivision);
		mapProjectAttributes.put('sBillToCustomer', sBillToCustomer);
		mapProjectAttributes.put('sShipToCustomer', sShipToCustomer);
		mapProjectAttributes.put('sBillToLocation', sBillToLocation);
		mapProjectAttributes.put('sShipToLocation', sShipToLocation);
		mapProjectAttributes.put('sBillToContact', sBillToContact);
		mapProjectAttributes.put('sLegalEntity', sLegalEntity);
		mapProjectAttributes.put('sTaskBillingMode', sTaskBillingMode);
		mapProjectAttributes.put('sCurrencyISOCode', sCurrencyISOCode);
		return mapProjectAttributes;
	}

	/*
	 * Get location based on Operating Unit
	 */
	public static String getLocation(String sLocation, String sOperatingUnit) { // sLocation
		integer[] iChars = sLocation.getChars();
		for (integer i = 0; i<iChars.size(); i++) {
			if (iChars[i] == 124)
			iChars[i] = 61;
		}
		sLocation = String.fromCharArray(iChars);
		for (String sTemp : sLocation.split('=')) {
			if (sTemp.split('-') [0] == sOperatingUnit) {
				return(sTemp.split('-').size()> 1 ? sTemp.split('-') [1] : '');
			}
		}
		return '';
	}

	/*
	 * Class to hold Mavenlink custom attributes
	 */
	public class WorkSpace {
		public List<CustomAttribute> custom_fields;
	}

	/*
	 * Class to hold Custom field Id and value for Mavenlink project custom attributes
	 */
	public class CustomAttribute {
		public string custom_field_id;
		public string value;

		public CustomAttribute(string fieldAPI, string fieldValue) {
			custom_field_id = fieldAPI;
			value = fieldValue;
		}
	}
}