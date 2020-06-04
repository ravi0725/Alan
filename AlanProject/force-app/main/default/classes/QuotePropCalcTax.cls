/*****************************************************************************************
  Name    : QuotePropCalcTax
  Desc    : Used to invoke Oracle EBS Integration1 webserice to calculate tax and submit order
 
 
  Modification Log :
  ---------------------------------------------------------------------------
  Developer              Date            Description
  ---------------------------------------------------------------------------
  Ashfaq Mohammed       12/10/2013          Created
  Suresh Babu Murugan	16-Mar-2019			APP-13638 : Upgrade Order Tax mismatch issue
 ******************************************************************************************/
public class QuotePropCalcTax {
	Public Boolean creditcheck { get; set; }
	public Boolean ProfessionalService { get; set; }
	public class customexception extends exception { }
	public string OracleIntegrationError { get; set; }
	public String quoteId { get; set; }
	public List<Apttus_Proposal__Proposal__c> QuoteList = new List<Apttus_Proposal__Proposal__c> ();
	public List<Apttus_Proposal__Proposal_Line_Item__c> QuoteLineList = new List<Apttus_Proposal__Proposal_Line_Item__c> ();
	public String QuoteName { get; set; }
	public string priceListName;
	public ID PriceListId;
	public string firstName;
	public string salesRep;
	public string emailID;
	public string shippingInstructions;
	public ID productID;
	public ID Account_ID;
	public ID parentAccountId;
	public string accountOracleId;
	public string ParentAccOraId;
	public string partyID;
	public List<Apttus_Config2__PriceList__c> PriceListList = new List<Apttus_Config2__PriceList__c> ();
	public List<Account> acctList = new List<Account> ();
	public List<Account> parentAcctList = new List<Account> ();
	public Boolean errorPopup { get; set; }
	public String errorMsg { get; set; }
	public String paymentTerm;
	public Boolean stopLoading;
	public map<String, String> mapLineitemIdwoOpt = new map<String, String> ();
	List<Apttus__APTS_Agreement__c> AggList = new List<Apttus__APTS_Agreement__c> ();
	public map<String, String> mapLineitemIdwithOpt = new map<String, ID> ();
	public map<ID, string> prodIDCodeMap = new map<ID, string> ();
	public List<Apttus_Proposal__Proposal_Line_Item__c> lstLineItem;
	public string shipToEntMastID;
	public string ResellerFCHPartyID;
	public string ShiptoAddFCHID;
	public string BilltoAddFCHID;
	public string customerPO;
	Public Decimal Negative_Selling_Price;
	Public Boolean NegativeQty;
	Public String ordertype;
	Public String billingFrequency;
	Public Decimal duration;
	Public String FrgMethod;
	Public String FrgTerms;
	Public String SalesChnl;
	public string Division;
	Public String Businessarea;
	public String durationUOM;
	public string RelatedQuoteNo;
	public string RevArrangementNum;
	public string RelatedQtOption;
	Public string ProjectNumber;
	Public Decimal AggValue;
	public DateTime AggStartDate;
	public DateTime AggEndDate;
	public string billtocontactFCHID;
	public string shiptocontactFCHID;
	public string creditstatus;
	public string creditApproved;
	public string creditmessage;
	public string Aggpstype;
	public String Partner1;
	public String Partner2;
	public String BillToContactId;
	public String PaymentType;
	Public String RenBillToID;
	public String RenBillToSiteID;
	public String renewalBillTo;
	public String NONSTDCONT;
	public String PricelistDivision;
	public Boolean SequenceChanged { get; set; }
	public ID OpptyID;
	Public List<echosign_dev1__SIGN_Agreement__c> AdobeList = new List<echosign_dev1__SIGN_Agreement__c> ();
	public String AdditionalLicense { get; set; }


	Map<String, String> ParMap = new Map<String, String> ();
	public xmlnsOracleComAppsOntSoaproviderPl_v10.OutputParameters_element o;
	/*
	 * Method name  : QuotePropCalcTax
	 * Description  : Constructor to initilize the values
	 * Return Type  : NA
	 * Parameter    : NA
	 */
	public QuotePropCalcTax() {

		//get the quote id from the Quote\Proposal Page
		quoteId = System.currentPageReference().getParameters().get('id');
		//get the data into the list from Apttus_Proposal__Proposal__c
		QuoteList = [Select id, Cart_Line_Sequence_Changed__c, Apttus_QPConfig__PriceListId__r.Division__c, Additional_License__c, Non_Standard_Contract__c, Renewal_Bill_To__c, Partner_2__r.FCH_Party_ID__c, Payment_Method__c, Partner_2__r.Name, Credit_Approved__c, Apttus_Proposal__Account__r.FCH_Party_ID__c, Credit_Message__c, Credit_Status__c, Name, Bill_To_Contact__r.FCH_Contact_Id__c, Apttus_Proposal__Primary_Contact__r.FCH_Contact_Id__c, Initial_Agreement__r.Total_Agreement_Value_Formula__c, Initial_Agreement__r.Apttus__Contract_Start_Date__c, Initial_Agreement__r.Apttus__Contract_End_Date__c, Initial_Agreement__r.Fusion_Project_Number__c, Is_Related_to_Another_Quote__c, Revenue_Arrangement_Number__c, Initial_Quote_Proposal__r.Name, Duration_UOM__c, Apttus_QPConfig__PriceListId__r.Business_Area__c, Apttus_Proposal__Opportunity__r.Selling_Division__c, Customer_PO__c, Order_Type__c, Billing_Frequency__c, Duration__c, Freight_Method__c, Freight_Terms__c, Sales_Channel__c, Bill_to_Address__r.FCH_Party_Site_ID__c, Reseller__r.Name, Reseller__r.FCH_Party_ID__c, Ship_to_Address1__r.FCH_Party_Site_ID__c, Apttus_Proposal__Opportunity__r.Owner.Name, Apttus_Proposal__Opportunity__r.Owner.Email, Apttus_Proposal__Opportunity__r.Owner.Country, Apttus_Proposal__Opportunity__r.Owner.LastName, Apttus_Proposal__Opportunity__r.Owner.FirstName, Apttus_Proposal__Account__c, Apttus_QPConfig__PriceListId__r.Name, Apttus_QPConfig__PriceListId__r.Apttus_Config2__Description__c, Payment_Terms_Oppty__c, Shipping_Instructions__c, Ship_To_Account__r.Enterprise_Party_Number__c FROM Apttus_Proposal__Proposal__c WHERE Id = :quoteId];
		//get the data into the list from Apttus_Proposal__Proposal_Line_Item__c
		System.debug('<<<<<<<<<<<<<<<<<<<<<<QuoteList>>>>>>>>>>>>>>>>>>' + QuoteList);
		QuoteLineList = [Select Name, Line_Sequence__c, Apttus_Proposal__Product__r.ICC_Type__c, Apttus_Proposal__Product__r.Business_Area__c, Industry__c, Apttus_QPConfig__DerivedFromId__r.Name, Apttus_Proposal__Product__r.Product_Category_Type__c, Type__c, Apttus_QPConfig__AssetId__c, Apttus_Proposal__Product__r.Contract_Item_Type_Code__c, Apttus_Proposal__Product__r.Oracle_ID__c, Apttus_QPConfig__NetAdjustmentPercent__c, Apttus_Proposal__Product__r.Product_Line_Description__c, Parent_Line_Number__c, Actual_List_Price__c, Pre_Billing__c, Manual_Discount_Amount__c, Defer_Billing__c, Duration_Sequence__c, Duration__c, Duration_UOM__c, Line_Item_Description__c, Customer_PO__c, Bill_to_Address__r.FCH_Party_Site_ID__c, Ship_to_Address1__r.FCH_Party_Site_ID__c, Schedule_Ship_Date__c, Service_Start_Date__c, Service_End_Date__c, Apttus_Proposal__Product__c, Unit_Selling_Price__c, Apttus_Proposal__Product__r.Name, Apttus_Proposal__Product__r.ProductCode, Apttus_Proposal__Product__r.Description, Apttus_QPConfig__OptionId__r.Contract_Item_Type_Code__c, Apttus_Proposal__Quantity__c, Apttus_QPConfig__Quantity2__c, Apttus_QPConfig__PriceUom__c, Apttus_QPConfig__ListPrice__c, Apttus_QPConfig__NetPrice__c, Apttus_QPConfig__SellingTerm__c, Apttus_QPConfig__SellingFrequency__c, Apttus_QPConfig__LineType__c, Apttus_QPConfig__OptionId__r.ProductCode, Apttus_QPConfig__OptionId__r.Name, Asset_Oracle_ID__c, Apttus_QPConfig__LineNumber__c, Apttus_QPConfig__AdjustmentType__c, Apttus_Proposal__Product__r.SKIP_Advanced_Pricing__c, Ship_to_Address1__r.Account__r.AnnualRevenue, Ship_to_Address1__r.Account__r.CurrencyIsoCode, Apttus_Proposal__Proposal__r.Project_Construction_Value__c, Product_Code__c, Apttus_QPConfig__PriceListId__r.Division__c, Apttus_Proposal__Proposal__r.Surcharge_Percentage__c FROM Apttus_Proposal__Proposal_Line_Item__c WHERE Apttus_Proposal__Proposal__c = :quoteId AND((Apttus_QPConfig__ChargeType__c = 'Maintenance Fee' AND Apttus_QPConfig__LineType__c = 'Product/Service' AND(Asset_Oracle_ID__c != null OR Apttus_Proposal__Product__r.Product_Category_Type__c = 'SaaS' OR Apttus_Proposal__Product__r.Product_Category_Type__c = 'Rental' OR Apttus_Proposal__Product__r.Product_Category_Type__c = 'Subscription' OR Apttus_Proposal__Product__r.Product_Category_Type__c = 'Maintenance')) OR(Apttus_QPConfig__LineType__c != 'Option' AND Apttus_QPConfig__ChargeType__c != 'Maintenance Fee' AND Apttus_Proposal__Product__r.SKIP_Advanced_Pricing__c = FALSE) OR(Apttus_QPConfig__LineType__c = 'Option' AND(Apttus_QPConfig__OptionId__r.Contract_Item_Type_Code__c = 'WARRANTY' OR Apttus_QPConfig__OptionId__r.Contract_Item_Type_Code__c = 'SERVICE' OR Apttus_Proposal__Product__r.SKIP_Advanced_Pricing__c = TRUE))) order by Name, Duration_Sequence__c ASC];
		System.debug('<<<<<<<<<<<<<<<<<<<<<<QuoteLineList>>>>>>>>>>>>>>>>>>' + QuoteLineList);

		AggList = [Select id, ProServ_Type__c, Apttus__Status_Category__c, Credit_Approved__c, Apttus__Status__c, CREDIT_LIMIT_AVAILABLE__C, CREDIT_EXISTING_EXPOSURE__C, CREDIT_CALCULATED_EXPOSURE__c, CREDIT_TOTAL_EXPOSURE__c, Credit_Status__c, Fusion_Project_Number__c, Total_Agreement_Value_Formula__c, Apttus__Contract_Start_Date__c, Send_to_Enterprise_Contracts__c, Apttus__Contract_End_Date__c from Apttus__APTS_Agreement__c where Apttus_QPComply__RelatedProposalId__c = :quoteid and Apttus__Status_Category__c = 'In Effect' and Apttus__Status__c = 'Activated'];
		System.debug('<<<<<<<<<<<<<<<<<<<<<<AggList>>>>>>>>>>>>>>>>>>' + AggList);

		if (QuoteList.size() > 0) OpptyID = QuoteList.get(0).Apttus_Proposal__Opportunity__c;
		if (OpptyID != Null) AdobeList = [select id, echosign_dev1__Document__c from echosign_dev1__SIGN_Agreement__c where echosign_dev1__Opportunity__c = :OpptyID and echosign_dev1__Status__c = 'Signed' order by createddate LIMIT 1];

		//Initialize the values from Apttus_Proposal__Proposal__c to the variables
		for (Apttus_Proposal__Proposal__c ap : QuoteList) {
			QuoteName = ap.name;
			Account_ID = ap.Apttus_Proposal__Account__c;
			PriceListId = ap.Apttus_QPConfig__PriceListId__c;
			paymentTerm = ap.Payment_Terms_Oppty__c;
			salesRep = ap.Apttus_Proposal__Opportunity__r.Owner.Name;
			emailID = ap.Apttus_Proposal__Opportunity__r.Owner.Email;
			shippingInstructions = ap.Shipping_Instructions__c;
			shipToEntMastID = ap.Ship_To_Account__r.Enterprise_Party_Number__c;
			ResellerFCHPartyID = ap.Apttus_Proposal__Account__r.FCH_Party_ID__c;
			ShiptoAddFCHID = ap.Ship_to_Address1__r.FCH_Party_Site_ID__c;
			BilltoAddFCHID = ap.Bill_to_Address__r.FCH_Party_Site_ID__c;
			customerPO = ap.Customer_PO__c;
			ordertype = ap.Order_Type__c;
			billingFrequency = ap.Billing_Frequency__c;
			duration = ap.Duration__c;
			durationUOM = ap.Duration_UOM__c;
			FrgMethod = ap.Freight_Method__c;
			FrgTerms = ap.Freight_Terms__c;
			SalesChnl = ap.Sales_Channel__c;
			Division = ap.Apttus_Proposal__Opportunity__r.Selling_Division__c;
			businessarea = ap.Apttus_QPConfig__PriceListId__r.Business_Area__c;
			RelatedQuoteNo = ap.Initial_Quote_Proposal__r.Name;
			RevArrangementNum = ap.Revenue_Arrangement_Number__c;
			RelatedQtOption = (ap.Is_Related_to_Another_Quote__c == True) ? 'Yes' : 'No';
			creditstatus = ap.Credit_Status__c;
			creditApproved = ap.Credit_Approved__c;
			creditmessage = ap.Credit_Message__c;
			PaymentType = ap.Payment_Method__c;
			renewalBillTo = ap.Renewal_Bill_To__c;
			NONSTDCONT = (ap.Non_Standard_Contract__c == 'Yes') ? 'Y' : 'N';
			AdditionalLicense = (ap.Additional_License__c == True) ? 'Y' : 'N';
			SequenceChanged = ap.Cart_Line_Sequence_Changed__c;

			ProjectNumber = (AggList.size() > 0) ? AggList.get(0).Fusion_Project_Number__c : '0';
			AggValue = (AggList.size() > 0) ? AggList.get(0).Total_Agreement_Value_Formula__c : 0.0;
			AggStartDate = (AggList.size() > 0) ? AggList.get(0).Apttus__Contract_Start_Date__c : null;
			AggEndDate = (AggList.size() > 0) ? AggList.get(0).Apttus__Contract_End_Date__c : null;
			Aggpstype = (AggList.size() > 0) ? AggList.get(0).ProServ_Type__c : 'None';

			billtocontactFCHID = ap.Bill_To_Contact__r.FCH_Contact_Id__c;
			shiptocontactFCHID = ap.Apttus_Proposal__Primary_Contact__r.FCH_Contact_Id__c;

			partner1 = ap.Reseller__r.FCH_Party_ID__c;
			partner2 = ap.Partner_2__r.FCH_Party_ID__c;

			PricelistDivision = ap.Apttus_QPConfig__PriceListId__r.Division__c;

		}


		acctList = [Select Name, Parent_Account_ID__c, Enterprise_Party_Number__c from Account where id = :Account_ID];
		//get the parent account id and FCH party id for the account
		for (Account a : acctList) {
			parentAccountId = a.Parent_Account_ID__c;
			accountOracleId = a.Enterprise_Party_Number__c;

		}

		if (parentAccountId != null) {
			parentAcctList = [Select Name, Parent_Account_ID__c, Enterprise_Party_Number__c from Account where id = :parentAccountId];

			for (Account pAcct : parentAcctList) {
				ParentAccOraId = pAcct.Enterprise_Party_Number__c;
			}

		}

		//If parent account id is null then assign the Oracle id as the party id else assign the parent account id as party id
		if (parentAccountId != null) {

			partyID = ParentAccOraId;
		} else {
			partyID = accountOracleId;
		}

		system.debug('partyID' + partyID);

		//get the pricelist name of the quote/proposal
		PriceListList = [Select name from Apttus_Config2__PriceList__c where id = :PriceListId];
		for (Apttus_Config2__PriceList__c pid : PriceListList) {
			priceListName = pid.Name;
		}

		//Variables for error pop up
		errorPopup = false;
		stopLoading = false;

		//Fill the map based on chargeType
		lstLineItem = [Select Name, Apttus_QPConfig__OptionId__r.ProductCode, Apttus_Proposal__Product__c, Unit_Selling_Price__c, Apttus_Proposal__Product__r.Name, Apttus_QPConfig__OptionId__r.Name, Apttus_Proposal__Product__r.ProductCode, Apttus_Proposal__Product__r.Description, Apttus_QPConfig__OptionId__r.Contract_Item_Type_Code__c, Apttus_Proposal__Quantity__c, Apttus_QPConfig__Quantity2__c, Apttus_QPConfig__PriceUom__c, Apttus_QPConfig__ListPrice__c, Apttus_QPConfig__NetPrice__c, Apttus_QPConfig__SellingTerm__c, Apttus_QPConfig__SellingFrequency__c, Apttus_QPConfig__LineType__c, Apttus_QPConfig__OptionId__c, Apttus_QPConfig__ChargeType__c, Asset_Oracle_ID__c, Apttus_QPConfig__LineNumber__c FROM Apttus_Proposal__Proposal_Line_Item__c WHERE Apttus_Proposal__Proposal__c = :quoteId order by Apttus_QPConfig__LineNumber__c asc];
		for (Apttus_Proposal__Proposal_Line_Item__c propLineItem : lstLineItem) {
			system.debug('propLineItem' + propLineItem.Apttus_QPConfig__OptionId__c);
			if (propLineItem.Apttus_QPConfig__OptionId__c == NULL && propLineItem.Apttus_QPConfig__ChargeType__c != 'Maintenance Fee') {
				mapLineitemIdwoOpt.put(propLineItem.Apttus_Proposal__Product__r.Name + propLineItem.Apttus_QPConfig__LineNumber__c, propLineItem.Name);
			}
			else if (propLineItem.Apttus_QPConfig__OptionId__c != NULL && propLineItem.Apttus_QPConfig__ChargeType__c == 'Maintenance Fee' && (propLineItem.Asset_Oracle_ID__c == null || propLineItem.Asset_Oracle_ID__c == '')) {

				mapLineitemIdwithOpt.put(propLineItem.Name, propLineItem.Apttus_QPConfig__OptionId__c);

				prodIDCodeMap.put(propLineItem.Apttus_QPConfig__OptionId__c, propLineItem.Apttus_QPConfig__OptionId__r.ProductCode);

			}
		}


	}

	/*
	 * Method name  : UpdateTax
	 * Description  : gets the quote details from Oracle EBS by invoking the webservcie class and updates the tax in salesforce
	 * Return Type  : boolean
	 * Parameter    : isOrder
	 */

	public Boolean UpdateTax(string isOrder) {
		Try {
			/* if(partyID=='' || partyID==null)
			  throw new customexception('Accounts Enterprise Master ID is blank. Please provide Enterprise Master ID and try again.');
			 
			  if(shipToEntMastID=='' || shipToEntMastID==null)
			  throw new customexception('Ship To Enterprise Master ID is blank.Please provide Enterprise Master ID and try again.'); */
			List<Apttus_Proposal__Proposal_Line_Item__c> UpdateLineList = new List<Apttus_Proposal__Proposal_Line_Item__c> ();
			if (QuoteLineList.size() == 0)
			throw new customexception(Label.Quote_Error);
			if (paymentTerm == '' || paymentTerm == null)
			throw new customexception('Mandatory field Payment Terms not provided.');
			//Assigning values for Quote/Proposal (Header) to invoke the Oracle EBS webserivce
			xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_HEADER_REC_TYPE hitem = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_HEADER_REC_TYPE();
			hitem.IS_ORDER = isOrder;
			hitem.ORIG_SYS_DOCUMENT_REF = QuoteName;
			hitem.ORDERED_DATE = system.now();
			hitem.PRICE_LIST = priceListName;
			hitem.CONVERSION_RATE_DATE = system.now();
			hitem.SALESREP = salesRep;
			hitem.SALESREP_EMAIL_ID = emailID;
			hitem.PAYMENT_TERM = paymentTerm;
			//hitem.SOLD_TO_ORG =partyID;
			hitem.INVOICE_TO_SITE = partyID;
			hitem.SHIP_TO_SITE = shipToEntMastID;
			hitem.PRICING_DATE = system.now();
			hitem.SHIPPING_INSTRUCTIONS = shippingInstructions;
			hitem.SOLD_TO_ORG = ResellerFCHPartyID;
			hitem.SHIP_TO_SITE = ShiptoAddFCHID;
			hitem.INVOICE_TO_SITE = BilltoAddFCHID;
			hitem.CUST_PO_NUMBER = customerPO;
			hitem.ORDER_TYPE = ordertype;
			hitem.BILLING_FREQUENCY = billingFrequency;
			hitem.DURATION = duration;
			hitem.FREIGHT_METHOD = FrgMethod;
			hitem.FREIGHT_TERM = FrgTerms;
			hitem.SALES_CHANNEL = SalesChnl;
			hitem.DIVISION = division;
			hitem.BUSINESS_AREA = businessarea;
			hitem.DURATION_UOM = durationuom;
			hitem.RELATED_QUOTE_OPTION = RelatedQtOption;
			hitem.RELATED_QUOTE_NUMBER = RelatedQuoteNo;
			hitem.REV_ARRANGEMENT_NUMBER = RevArrangementNum;
			hitem.PROJECT_NUMBER = ProjectNumber;
			hitem.AGREEMENT_VALUE = AggValue.setScale(2);
			hitem.AGREEMENT_START_DATE = AggStartDate;
			hitem.AGREEMENT_END_DATE = AggEndDate;
			hitem.BILL_TO_CONTACT_ID = billtocontactFCHID;
			hitem.SHIP_TO_CONTACT_ID = shiptocontactFCHID;
			hitem.AGREEMENT_PS_TYPE = Aggpstype;

			system.debug('hitem' + hitem);
			// Added 'Maintenance' as part of multiyear Renewal Split Line Issue.
			for (Apttus_Proposal__Proposal_Line_Item__c quoLine : QuoteLineList) {
				if (quoLine.Parent_Line_Number__c == Null && (quoLine.Apttus_Proposal__Product__r.Product_Category_Type__c == 'Rental' || quoLine.Apttus_Proposal__Product__r.Product_Category_Type__c == 'SaaS' || quoLine.Apttus_Proposal__Product__r.Product_Category_Type__c == 'Subscription' || quoLine.Apttus_Proposal__Product__r.Product_Category_Type__c == 'Maintenance'))
				parMap.put(quoLine.Apttus_QPConfig__DerivedFromId__r.Name, quoLine.Name);
				system.debug('>>>>>>ParMap>>>>>' + ParMap);
			}
			xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINE_TBL_TYPE tblt = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINE_TBL_TYPE();

			//xmlnsOracleComAppsOntSoaproviderPl_v10.InputParameters_element COMPOSITEId = xmlnsOracleComAppsOntSoaproviderPl_v10.InputParameters_element();

			//Assigning values for Quote/Proposal Line Item (Footer) to invoke the Oracle EBS webserivce
			xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINE_REC_TYPE[] rect = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINE_REC_TYPE[] { };
			for (Apttus_Proposal__Proposal_Line_Item__c quoLine : QuoteLineList) {

				xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINE_REC_TYPE LineItem = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINE_REC_TYPE();
				LineItem.ORIG_SYS_LINE_REF = quoLine.Name;
				LineItem.PRICING_QUANTITY = quoLine.Apttus_QPConfig__Quantity2__c;
				LineItem.UNIT_LIST_PRICE = (quoLine.Actual_List_Price__c != null ? quoLine.Actual_List_Price__c : quoLine.Apttus_QPConfig__ListPrice__c);
				LineItem.UNIT_SELLING_PRICE = quoLine.Unit_Selling_Price__c;
				LineItem.ORDERED_QUANTITY = quoLine.Apttus_QPConfig__Quantity2__c;
				LineItem.MANUAL_DISCOUNT_PERCENT = (quoLine.Apttus_QPConfig__NetAdjustmentPercent__c != Null ? - 1 * quoLine.Apttus_QPConfig__NetAdjustmentPercent__c : 0);

				LineItem.SERVICE_REF_INSTANCE_NUM = quoLine.Asset_Oracle_ID__c;
				// Workaround Code to accept negative Quantity
				if (quoLine.Apttus_QPConfig__Quantity2__c< 0 && isOrder == '0')
				{
					LineItem.PRICING_QUANTITY = - 1 * quoLine.Apttus_QPConfig__Quantity2__c;
					LineItem.UNIT_LIST_PRICE = (quoLine.Actual_List_Price__c != null ? quoLine.Actual_List_Price__c : quoLine.Apttus_QPConfig__ListPrice__c);
					LineItem.UNIT_SELLING_PRICE = - 1 * quoLine.Unit_Selling_Price__c;
					LineItem.ORDERED_QUANTITY = - 1 * quoLine.Apttus_QPConfig__Quantity2__c;
					LineItem.attribute1 = quoLine.Asset_Oracle_ID__c;
					if (quoLine.Apttus_QPConfig__ListPrice__c == 0 && quoLine.Apttus_QPConfig__AssetId__c != null) {
						LineItem.MANUAL_DISCOUNT_PERCENT = 100;
					}
					else {
						LineItem.MANUAL_DISCOUNT_PERCENT = (LineItem.UNIT_LIST_PRICE != 0 ? ((quoLine.Apttus_QPConfig__NetPrice__c / quoLine.Apttus_QPConfig__Quantity2__c) / LineItem.UNIT_LIST_PRICE) * 100 : 0);
					}
					LineItem.SERVICE_REF_INSTANCE_NUM = Null;
				}
				else if (quoLine.Apttus_QPConfig__Quantity2__c< 0 && isOrder == '1')
				{
					LineItem.PRICING_QUANTITY = quoLine.Apttus_QPConfig__Quantity2__c;
					LineItem.UNIT_LIST_PRICE = (quoLine.Actual_List_Price__c != null ? quoLine.Actual_List_Price__c : quoLine.Apttus_QPConfig__ListPrice__c);
					LineItem.UNIT_SELLING_PRICE = quoLine.Unit_Selling_Price__c;
					LineItem.ORDERED_QUANTITY = quoLine.Apttus_QPConfig__Quantity2__c;
					LineItem.attribute1 = quoLine.Asset_Oracle_ID__c;
					LineItem.MANUAL_DISCOUNT_PERCENT = (LineItem.UNIT_LIST_PRICE != 0 ? ((quoLine.Apttus_QPConfig__NetPrice__c / quoLine.Apttus_QPConfig__Quantity2__c) / LineItem.UNIT_LIST_PRICE) * 100 : 0);
					LineItem.SERVICE_REF_INSTANCE_NUM = Null;
				}





				LineItem.ORDERED_QUANTITY_UOM = quoLine.Apttus_QPConfig__PriceUom__c;

				LineItem.REQUEST_DATE = system.now();
				LineItem.SERVICE_DURATION = quoLine.Apttus_QPConfig__SellingTerm__c;
				LineItem.SERVICE_PERIOD = quoLine.Apttus_QPConfig__SellingFrequency__c;
				LineItem.USER_ITEM_DESCRIPTION = quoLine.Apttus_Proposal__Product__r.Description;
				//LineItem.SERVICE_REF_INSTANCE_NUM = quoLine.Asset_Oracle_ID__c;
				LineItem.Duration = quoLine.Duration__c;
				LineItem.Duration_UOM = quoLine.Duration_UOM__c;
				LineItem.USER_ITEM_DESCRIPTION = quoLine.Line_Item_Description__c;
				LineItem.CUST_PO_NUMBER = quoLine.Customer_PO__c;
				if (quoLine.Bill_to_Address__r.FCH_Party_Site_ID__c != null) {
					LineItem.FCH_BILL_SITE_ID = quoLine.Bill_to_Address__r.FCH_Party_Site_ID__c;
				}
				if (quoLine.Ship_to_Address1__r.FCH_Party_Site_ID__c != null) {
					LineItem.FCH_SHIP_SITE_ID = quoLine.Ship_to_Address1__r.FCH_Party_Site_ID__c;
				}
				LineItem.SCHEDULE_SHIP_DATE = (isorder == '1') ? quoLine.Schedule_Ship_Date__c : null;

				LineItem.SERVICE_START_DATE = quoLine.Service_Start_Date__c;
				LineItem.SERVICE_END_DATE = quoLine.Service_End_Date__c;

				if (PricelistDivision == 'MEP NA' && isorder == '1') {
					if (quoLine.Service_Start_Date__c<system.today()) {
						quoLine.Service_end_Date__c = quoLine.Service_End_Date__c + quoLine.Service_Start_Date__c.daysBetween(system.today());
						quoLine.Service_Start_Date__c = system.today();
						LineItem.SERVICE_END_DATE = quoLine.Service_End_Date__c + quoLine.Service_Start_Date__c.daysBetween(system.today());
						LineItem.SERVICE_START_DATE = system.today();
					}
					UpdateLineList.add(quoLine);
				}

				/*    if((quoLine.Apttus_Proposal__Product__r.ICC_Type__c != Null && (quoLine.Apttus_Proposal__Product__r.ICC_Type__c=='Scheduled Publications' || quoLine.Apttus_Proposal__Product__r.ICC_Type__c=='Unscheduled Publications')) && quoLine.Apttus_Proposal__Product__r.Business_Area__c != Null && quoLine.Apttus_Proposal__Product__r.Business_Area__c=='TRADE SERVICE')
				  {
				  LineItem.SERVICE_START_DATE = system.today();
				  LineItem.SERVICE_END_DATE = system.today().addyears(1) -1;
				  }*/

				LineItem.PRE_BILLING = ((quoLine.Pre_Billing__c) == True ? 'Y' : 'N');
				if ((quoLine.Apttus_QPConfig__OptionId__r.Contract_Item_Type_Code__c != Null && quoLine.Apttus_QPConfig__OptionId__r.Contract_Item_Type_Code__c == 'SERVICE') || (quoLine.Apttus_Proposal__Product__r.Contract_Item_Type_Code__c != Null && quoLine.Apttus_Proposal__Product__r.Contract_Item_Type_Code__c == 'SERVICE'))
				LineItem.DEFER_BILLING = 'N';
				else
				LineItem.DEFER_BILLING = ((quoLine.Defer_Billing__c) == True ? 'Y' : 'N');
				LineItem.DURATION_SEQ = quoLine.Duration_Sequence__c;
				LineItem.MANUAL_DISCOUNT_AMOUNT = quoLine.Manual_Discount_Amount__c;

				if (quoLine.Parent_Line_Number__c != Null && (quoLine.Apttus_Proposal__Product__r.Product_Category_Type__c == 'Rental' || quoLine.Apttus_Proposal__Product__r.Product_Category_Type__c == 'SaaS' || quoLine.Apttus_Proposal__Product__r.Product_Category_Type__c == 'Subscription' || quoLine.Apttus_Proposal__Product__r.Product_Category_Type__c == 'Maintenance')) {
					system.debug('>>>>>>ParMap>>>>>' + ParMap.get(quoLine.Parent_Line_Number__c));
					LineItem.SAAS_REFERENCE_LINE = ParMap.get(quoLine.Parent_Line_Number__c);

				}
				if (prodIDCodeMap.get(quoLine.Apttus_QPConfig__OptionId__c) != null) {

					LineItem.SERVICE_REFERENCE_LINE = mapLineitemIdwoOpt.get(quoLine.Apttus_Proposal__Product__r.Name + quoLine.Apttus_QPConfig__LineNumber__c);
					LineItem.ORDERED_ITEM = prodIDCodeMap.get(quoLine.Apttus_QPConfig__OptionId__c);

				} else {
					LineItem.ORDERED_ITEM = (quoLine.Apttus_Proposal__Product__r.SKIP_Advanced_Pricing__c == true ? quoLine.Apttus_QPConfig__OptionId__r.ProductCode : quoLine.Apttus_Proposal__Product__r.ProductCode);
				}
				if (LineItem.ORDERED_ITEM == null || LineItem.ORDERED_ITEM == '')
				throw new customexception('Mandatory field Product not provided.');
				// Added to Prevent sending 0 Quantity to EBS

				system.debug('&*&*&*&*&*&*& No Of Line Items' + quoLine.Name);

				rect.add(LineItem);
			}



			tblt.P_SFDC_LINE_TBL_ITEM = rect;

			xmlnsOracleComAppsOntSoaproviderPl_v10.OutputParameters_element op = new xmlnsOracleComAppsOntSoaproviderPl_v10.OutputParameters_element();
			xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_COL_EXTN_TBL_TYPE Samp = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_COL_EXTN_TBL_TYPE();
			xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_COL_EXTN_REC_TYPE[] LineInp = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_COL_EXTN_REC_TYPE[] { };

			//Building Header Details
			xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_COL_EXTN_REC_TYPE Header = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_COL_EXTN_REC_TYPE();
			Header.CONTEXT_NAME = 'QH';
			Header.CONTEXT_VALUE = QuoteName;
			Header.COL_VALUE = partner1;
			Header.COL_NAME = 'DEALER1';
			LineInp.add(Header);
			xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_COL_EXTN_REC_TYPE Header1 = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_COL_EXTN_REC_TYPE();
			Header1.CONTEXT_NAME = 'QH';
			Header1.CONTEXT_VALUE = QuoteName;
			Header1.COL_VALUE = partner2;
			Header1.COL_NAME = 'DEALER2';
			LineInp.add(Header1);
			xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_COL_EXTN_REC_TYPE Header2 = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_COL_EXTN_REC_TYPE();
			Header2.CONTEXT_NAME = 'QH';
			Header2.CONTEXT_VALUE = QuoteName;
			Header2.COL_VALUE = PaymentType;
			Header2.COL_NAME = 'PAYMENT_TYPE';
			LineInp.add(Header2);
			xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_COL_EXTN_REC_TYPE Header3 = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_COL_EXTN_REC_TYPE();
			Header3.CONTEXT_NAME = 'QH';
			Header3.CONTEXT_VALUE = QuoteName;
			Header3.COL_VALUE = NONSTDCONT;
			Header3.COL_NAME = 'NONSTDCONT';
			LineInp.add(Header3);

			xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_COL_EXTN_REC_TYPE Header6 = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_COL_EXTN_REC_TYPE();
			Header6.CONTEXT_NAME = 'QH';
			Header6.CONTEXT_VALUE = QuoteName;
			Header6.COL_VALUE = renewalBillTo;
			Header6.COL_NAME = 'RENEWAL_BILL_TO';
			LineInp.add(Header6);

			if (AdobeList.size()> 0 && AdobeList.get(0).echosign_dev1__Document__c != Null) {
				String Strvalue = AdobeList.get(0).echosign_dev1__Document__c; // '<a href="https://secure.na1.echosign.com/document/cp/3AAABLblqZhCrQ-D4CDRDJAs5jC3mj-yCFklVUbECNCQ1JtU-SEE6HWEnJdmcka3tAkQIkpACN6OEFyfdEBXwos9GhMHMlvNr/document.pdf" target="_blank"><img src="https://secure.echosignforsalesforce.com/images/salesforce-pdf-icon.gif" alt="PDF" border="0"/> Trimble RTS Adobe Sign Agreement - signed.pdf</a>';
				List<String> AbobeURL = Strvalue.split('<');
				system.debug('>>>>>>' + AbobeURL);
				String FinalURL = AbobeURL[1].replaceall('"', '').replaceall('a href=', '').replaceall('target=_blank>', '');
				system.debug('>>>>>>' + FinalURL);
				xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_COL_EXTN_REC_TYPE Header5 = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_COL_EXTN_REC_TYPE();
				Header5.CONTEXT_NAME = 'QH';
				Header5.CONTEXT_VALUE = QuoteName;
				Header5.COL_VALUE = FinalURL; //'https://secure.na1.echosign.com/document/cp/3AAABLblqZhCrQ-D4CDRDJAs5jC3mj-yCFklVUbECNCQ1JtU-SEE6HWEnJdmcka3tAkQIkpACN6OEFyfdEBXwos9GhMHMlvNr/document.pdf';
				Header5.COL_NAME = 'SIGNED_PROPOSAL_LINK';
				LineInp.add(Header5);
			}

			Map<String, ProjectSight_Discounting_Matrix__mdt> mapPSDiscMatrix = new Map<String, ProjectSight_Discounting_Matrix__mdt> ();
			List<ProjectSight_Discounting_Matrix__mdt> lstProjectSightDicMatrix = [SELECT MasterLabel, DeveloperName, Item_Code__c, Object_API_Name__c, Matrix_Based_on_Field_API__c FROM ProjectSight_Discounting_Matrix__mdt];
			for (ProjectSight_Discounting_Matrix__mdt pDM : lstProjectSightDicMatrix) {
				mapPSDiscMatrix.put(pDM.Item_Code__c, pDM);
			}

			//Building Line Details
			for (Apttus_Proposal__Proposal_Line_Item__c quoLine : QuoteLineList) {
				xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_COL_EXTN_REC_TYPE LineItem = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_COL_EXTN_REC_TYPE();
				LineItem.CONTEXT_NAME = 'QL';
				LineItem.CONTEXT_VALUE = (quoLine.Name);
				LineItem.COL_VALUE = (quoLine.Type__c).touppercase();
				LineItem.COL_NAME = 'TYPE';
				LineInp.add(LineItem);
				xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_COL_EXTN_REC_TYPE LineItem1 = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_COL_EXTN_REC_TYPE();
				LineItem1.CONTEXT_NAME = 'QL';
				LineItem1.CONTEXT_VALUE = (quoLine.Name);
				LineItem1.COL_VALUE = quoLine.Industry__c;
				LineItem1.COL_NAME = 'INDUSTRY';
				LineInp.add(LineItem1);


				if ((quoLine.Apttus_Proposal__Product__r.ICC_Type__c != Null && (quoLine.Apttus_Proposal__Product__r.ICC_Type__c == 'Scheduled Publications' || quoLine.Apttus_Proposal__Product__r.ICC_Type__c == 'Unscheduled Publications')) && quoLine.Apttus_Proposal__Product__r.Business_Area__c != Null && quoLine.Apttus_Proposal__Product__r.Business_Area__c == 'TRADE SERVICE')
				{
					xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_COL_EXTN_REC_TYPE LineItem2 = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_COL_EXTN_REC_TYPE();
					LineItem2.CONTEXT_NAME = 'QL';
					LineItem2.CONTEXT_VALUE = (quoLine.Name);
					LineItem2.COL_VALUE = AdditionalLicense;
					LineItem2.COL_NAME = 'SUBSCR_ADD_SHIP_SCH';
					LineInp.add(LineItem2);
				}

				if (SequenceChanged == True)
				{
					xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_COL_EXTN_REC_TYPE LineItem3 = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_COL_EXTN_REC_TYPE();
					LineItem3.CONTEXT_NAME = 'QL';
					LineItem3.CONTEXT_VALUE = (quoLine.Name);
					LineItem3.COL_VALUE = String.valueof((quoLine.Line_Sequence__c));
					LineItem3.COL_NAME = 'SFDC_LINE_SEQ';
					LineInp.add(LineItem3);
				}
				// Discount matrix depends on Company Annual Revenue
				if (quoLine.Ship_to_Address1__r.Account__r.AnnualRevenue != null && quoLine.Ship_to_Address1__r.Account__r.CurrencyIsoCode == 'USD' && mapPSDiscMatrix.containsKey(quoLine.Product_Code__c) && mapPSDiscMatrix.get(quoLine.Product_Code__c) != null && mapPSDiscMatrix.get(quoLine.Product_Code__c).Matrix_Based_on_Field_API__c == 'AnnualRevenue') {
					xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_COL_EXTN_REC_TYPE LineItem4 = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_COL_EXTN_REC_TYPE();
					LineItem4.CONTEXT_NAME = 'QL';
					LineItem4.CONTEXT_VALUE = (quoLine.Name);
					LineItem4.COL_VALUE = String.valueof((quoLine.Ship_to_Address1__r.Account__r.AnnualRevenue));
					LineItem4.COL_NAME = 'SFDC_COMPANY_REVENUE';
					LineInp.add(LineItem4);
				}
				// Discount matrix depends on Project Construction Value
				if (quoLine.Apttus_Proposal__Proposal__r.Project_Construction_Value__c != null && mapPSDiscMatrix.containsKey(quoLine.Product_Code__c) && mapPSDiscMatrix.get(quoLine.Product_Code__c) != null && mapPSDiscMatrix.get(quoLine.Product_Code__c).Matrix_Based_on_Field_API__c == 'Project_Construction_Value__c') {
					xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_COL_EXTN_REC_TYPE LineItem6 = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_COL_EXTN_REC_TYPE();
					LineItem6.CONTEXT_NAME = 'QL';
					LineItem6.CONTEXT_VALUE = (quoLine.Name);
					LineItem6.COL_VALUE = String.valueof((quoLine.Apttus_Proposal__Proposal__r.Project_Construction_Value__c));
					LineItem6.COL_NAME = 'SFDC_PROJECT_VALUE';
					LineInp.add(LineItem6);
				}
				// APP-6137 : Surcharge information for GCCM Quotes

				if (quoLine.Apttus_Proposal__Proposal__r.Surcharge_Percentage__c != null && quoLine.Apttus_QPConfig__PriceListId__r.Division__c == 'GCCM') {
					xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_COL_EXTN_REC_TYPE LineItem7 = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_COL_EXTN_REC_TYPE();
					LineItem7.CONTEXT_NAME = 'QL';
					LineItem7.CONTEXT_VALUE = (quoLine.Name);
					if (quoLine.Apttus_Proposal__Proposal__r.Surcharge_Percentage__c == '3%') {
						LineItem7.COL_VALUE = 'GCSURCHARGE03';
					}
					if (quoLine.Apttus_Proposal__Proposal__r.Surcharge_Percentage__c == '5%') {
						LineItem7.COL_VALUE = 'GCSURCHARGE05';
					}
					if (quoLine.Apttus_Proposal__Proposal__r.Surcharge_Percentage__c == '7%') {
						LineItem7.COL_VALUE = 'GCSURCHARGE07';
					}
					if (quoLine.Apttus_Proposal__Proposal__r.Surcharge_Percentage__c == '10%') {
						LineItem7.COL_VALUE = 'GCSURCHARGE10';
					}
					LineItem7.COL_NAME = 'SFDC_SURCHARGE';
					LineInp.add(LineItem7);
				}
			}
			Samp.P_SFDC_COL_EXT_TBL_ITEM = LineInp;

			xmlnsOracleComPlancalNewTnvpltaxand_v10.tnvplTaxAndShippingQuoteToOrderService_pt targetportvar = new xmlnsOracleComPlancalNewTnvpltaxand_v10.tnvplTaxAndShippingQuoteToOrderService_pt();
			targetportvar.timeout_x = integer.valueof(Label.EBS_SOA_SFDC_TIMEOUT);
			if (!Test.isRunningTest()) {
				op = targetportvar.process(hitem, tblt, Samp);
			} else {
				/*op = new xmlnsOracleComAppsOntSoaproviderPl_v10.OutputParameters_element();
				  op.X_STATUS ='SUCCESS';
				  op.X_MESSAGE ='Success';*/
				op = o;
			}

			Map<String, String> LineOutMap = new Map<String, String> ();
			Map<String, xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINEOUT_REC_TYPE> EbsResponse = new Map<String, xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINEOUT_REC_TYPE> ();
			xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINEOUT_TBL_TYPE temp = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINEOUT_TBL_TYPE();
			xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINEOUT_REC_TYPE[] lineout = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINEOUT_REC_TYPE[] { };

			temp = op.X_SFDC_LINEOUT_TBL;
			if (temp != Null) {
				lineout = temp.X_SFDC_LINEOUT_TBL_ITEM;

				system.debug('-------------------temp----------' + temp.X_SFDC_LINEOUT_TBL_ITEM);
				system.debug('-------------------lineout----------' + lineout);
				String ConfigID;

				for (xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINEOUT_REC_TYPE intr : lineout)
				{
					// xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINEOUT_REC_TYPE lineItem = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINEOUT_REC_TYPE();
					if (intr.PROPOSAL_LINE_ID != Null && intr.SELLING_PRICE_EBS_CALCULATED != Null)
					LineOutMap.put(intr.PROPOSAL_LINE_ID, intr.SELLING_PRICE_EBS_CALCULATED);
					EbsResponse.put(intr.PROPOSAL_LINE_ID, intr);
				}

				system.debug('EBS Output Map----------' + LineOutMap);
				//List<Apttus_Proposal__Proposal_Line_Item__c> UpdateLineList = new List<Apttus_Proposal__Proposal_Line_Item__c>();
				List<Apttus_Proposal__Proposal_Line_Item__c> LineList = new List<Apttus_Proposal__Proposal_Line_Item__c> ();
				LineList = [select id, Name, Apttus_QPConfig__BaseExtendedPrice__c, Apttus_QPConfig__AssetId__c, Apttus_QPConfig__ListPrice__c, Apttus_QPConfig__Quantity2__c, Apttus_QPConfig__NetPrice__c, Apttus_QPConfig__ExtendedPrice__c from Apttus_Proposal__Proposal_Line_Item__c where Name in :LineOutMap.keyset()];
				for (Apttus_Proposal__Proposal_Line_Item__c li : LineList)
				{
					if (Decimal.valueof(LineOutMap.get(Li.Name)) >= 0) {
						Li.Apttus_QPConfig__ListPrice__c = Decimal.valueof(LineOutMap.get(Li.Name));
						li.Apttus_QPConfig__NetPrice__c = Decimal.valueof(LineOutMap.get(Li.Name)) * Li.Apttus_QPConfig__Quantity2__c;
						li.Apttus_QPConfig__ExtendedPrice__c = Decimal.valueof(LineOutMap.get(Li.Name)) * Li.Apttus_QPConfig__Quantity2__c;
						li.Apttus_QPConfig__BaseExtendedPrice__c = Decimal.valueof(LineOutMap.get(Li.Name)) * Li.Apttus_QPConfig__Quantity2__c;
					}
					system.debug('>>>>>>>>>>>>>Service_Start_Date__c>>>>>>>>>>>>>>>' + EbsResponse.get(li.Name).SERV_START_DATE);
					system.debug('>>>>>>>>>>>>>Service_End_Date__c>>>>>>>>>>>>>>>' + EbsResponse.get(li.Name).SERV_END_DATE);
					li.Service_Start_Date__c = Date.valueof(EbsResponse.get(li.Name).SERV_START_DATE);
					li.Service_End_Date__c = date.valueof(EbsResponse.get(li.Name).SERV_END_DATE);
					// UpdateLineList.add(Li);
				}

				/* if(UpdateLineList.size()>0){
				  // update UpdateLineList;
				 
				  } */
			}
			//op=targetportvar.process(hitem,tblt);
			system.debug('op==>' + op);
			QuoteList = [Select Name, Apttus_Proposal__Account__c, Apttus_QPConfig__PriceListId__r.Name, Apttus_QPConfig__PriceListId__r.Apttus_Config2__Description__c, Shipping_Instructions__c FROM Apttus_Proposal__Proposal__c WHERE Id = :quoteId];
			Apttus_Proposal__Proposal__c appQ = [SELECT Tax__c, Quote_Validated__c, CREDIT_LIMIT_AVAILABLE__C, CREDIT_EXISTING_EXPOSURE__C, CREDIT_CALCULATED_EXPOSURE__c, CREDIT_TOTAL_EXPOSURE__c, Oracle_Error__c, Shipping_Instructions__c, Oracle_Account_Number__c FROM Apttus_Proposal__Proposal__c WHERE Id = :quoteId];

			appQ.Oracle_Error__c = '';
			appQ.Oracle_Account_Number__c = op.X_EBS_ACCOUNT_NUMBER;
			update appQ;
			if (op.X_STATUS == 'ERROR') {
				if (op.X_CREDIT_STATUS == 'N' && isorder == '1') {
					//sendEmail(op.X_CREDIT_STATUS);
					appQ.Credit_Status__c = op.X_CREDIT_STATUS;
					AggList.get(0).Credit_Status__c = op.X_CREDIT_STATUS;
					appQ.Apttus_Proposal__Approval_Stage__c = 'Credit Check Hold';
					AggList.get(0).Apttus__Status_Category__c = 'Credit Check Hold';
					AggList.get(0).Apttus__Status__c = 'Hold';
					creditcheck = True;
				}
				appQ.addError(op.X_MESSAGE);
				appQ.Oracle_Error__c = op.X_MESSAGE;
				update appQ;
				errorPopup = true;
				errorMsg = op.X_MESSAGE;
				stopLoading = true;

			} else {
				if (op.X_TAX_AMOUNT != null) {
					appQ.Quote_Validated__c = True;
					appQ.Tax__c = op.X_TAX_AMOUNT;
				}

				// This Code is Added for GCCM Upgrade Process to reduce the Available Quantity on Asset.
				if (isorder == '1' && op.X_STATUS == 'SUCCESS') {
					Set<ID> AssetId = new Set<ID> ();
					Map<Id, Apttus_Proposal__Proposal_Line_Item__c> AssetMap = new Map<Id, Apttus_Proposal__Proposal_Line_Item__c> ();
					List<Asset> updateAssetList = new List<Asset> ();
					for (Apttus_Proposal__Proposal_Line_Item__c li : QuoteLineList)
					{
						if (Li.Apttus_QPConfig__AssetId__c != Null) { AssetId.add(Li.Apttus_QPConfig__AssetId__c);
							AssetMap.put(li.Apttus_QPConfig__AssetId__c, Li);
						}
					}

					List<Asset> AssRec = [select id, Available_Quantity__c from Asset where id in :AssetId];
					for (Asset Ass : AssRec)
					{
						if (Ass.Available_Quantity__c != Null && AssetMap.get(Ass.id).Apttus_QPConfig__Quantity2__c != Null) {
							Ass.Available_Quantity__c = Ass.Available_Quantity__c + AssetMap.get(Ass.id).Apttus_QPConfig__Quantity2__c;
							updateAssetList.add(Ass);
						}
					}
					if (updateAssetList.size()> 0)
					update updateAssetList;
				}

				appQ.Oracle_Error__c = op.X_STATUS;


				if ((op.X_CREDIT_STATUS == 'Y' || op.X_CREDIT_STATUS == 'X') && isorder == '1') {
					AggList.get(0).Credit_Status__c = op.X_CREDIT_STATUS;
					AggList.get(0).Send_to_Enterprise_Contracts__c = True;
					appQ.Credit_Status__c = op.X_CREDIT_STATUS;
					if (op.X_CREDIT_STATUS == 'X')
					ProfessionalService = True;
					// AggList.get(0).Credit_Approved__c = 'Y';
					// appQ.Credit_Approved__c = 'Y';

				}


			}
			if (isorder == '1' && AggList.size()> 0)
			{
				appQ.CREDIT_LIMIT_AVAILABLE__C = op.X_CREDIT_LIMIT_AVAILABLE;
				appQ.CREDIT_EXISTING_EXPOSURE__C = op.X_CREDIT_EXISTING_EXPOSURE;
				appQ.CREDIT_CALCULATED_EXPOSURE__c = op.X_CREDIT_CALCULATED_EXPOSURE;
				appQ.CREDIT_TOTAL_EXPOSURE__c = op.X_CREDIT_TOTAL_EXPOSURE;
				AggList.get(0).CREDIT_LIMIT_AVAILABLE__C = op.X_CREDIT_LIMIT_AVAILABLE;
				AggList.get(0).CREDIT_EXISTING_EXPOSURE__C = op.X_CREDIT_EXISTING_EXPOSURE;
				AggList.get(0).CREDIT_CALCULATED_EXPOSURE__c = op.X_CREDIT_CALCULATED_EXPOSURE;
				AggList.get(0).CREDIT_TOTAL_EXPOSURE__c = op.X_CREDIT_TOTAL_EXPOSURE;

				CreditHistoryLogs ch = new CreditHistoryLogs();
				String CreditStatus = (op.X_CREDIT_STATUS == null ? ' ' : op.X_CREDIT_STATUS);
				Decimal CreditTotExp = (op.X_CREDIT_TOTAL_EXPOSURE == null ? 0 : op.X_CREDIT_TOTAL_EXPOSURE);
				Decimal creditcalcExp = (op.X_CREDIT_CALCULATED_EXPOSURE == null ? 0 : op.X_CREDIT_CALCULATED_EXPOSURE);
				Decimal creditLimtAv = (op.X_CREDIT_LIMIT_AVAILABLE == null ? 0 : op.X_CREDIT_LIMIT_AVAILABLE);
				Decimal creditExtExp = (op.X_CREDIT_EXISTING_EXPOSURE == null ? 0 : op.X_CREDIT_EXISTING_EXPOSURE);
				String LogStr = 'CREDIT_STATUS : ' + CreditStatus + '; CREDIT_TOTAL_EXPOSURE : ' + CreditTotExp + '; CREDIT_CALCULATED_EXPOSURE : ' + creditcalcExp + '; CREDIT_LIMIT_AVAILABLE : ' + creditLimtAv + '; CREDIT_EXISTING_EXPOSURE : ' + creditExtExp;
				ch.CreateLog(LogStr, appQ.Id, AggList.get(0).Id);
			}
			update appQ;
			if (AggList.size() > 0)
			update AggList.get(0);
			if (UpdateLineList.size() > 0) update UpdateLineList;
			if (op.X_STATUS == 'ERROR') {
				if (op.X_CREDIT_STATUS == 'N' && isorder == '1') {
					sendEmail(op.X_CREDIT_STATUS);
				}
			}
		} catch(CalloutException cex) {
			errorPopup = true;
			errorMsg = cex.getMessage();
			stopLoading = true;
			String ExString = cex.getmessage();
			if (ExString.contains('Read timed out')) {
				cex.setMessage(Label.Read_Timed_Out_Message);
				errorMsg = Label.Read_Timed_Out_Message;
			}
			ebsExceptionCall(QuoteName, cex.getMessage(), cex.getStackTraceString(), 'SYSTEM_ERROR', '');
			doSendMail(cex.getMessage());
		} catch(Exception ex) {
			system.debug('exception =====' + ex);
			system.debug('exception =====' + ex.getStackTraceString());
			errorPopup = true;
			errorMsg = ex.getMessage();
			stopLoading = true;

			ebsExceptionCall(QuoteName, ex.getMessage(), ex.getStackTraceString(), 'SYSTEM_ERROR', '');
		}
		return errorPopup;

	}


	Public void SendEmail(String Cr)
	{

		String AggId = (AggList.size() > 0) ? AggList.get(0).Id : '';
		SendEmailonSubmitOrderController email = new SendEmailonSubmitOrderController();
		email.SendEmailToCredit(quoteId, AggId);
	}


	/*
	 * Method name  : ebsExceptionCall
	 * Description  : Future method to invoke oracle email exceptoin class
	 * Return Type  : Void
	 * Parameter    : string QuoId, string exMessage, string exStackTrace, string ErrType, string ResStatus
	 */

	@Future(callout = true)
	public static void ebsExceptionCall(string QuoId, string exMessage, string exStackTrace, string ErrType, string ResStatus) {
		try {



			trimblecorpComTnvreceiveexternalerrors.MessageTransactions[] mtArr = new trimblecorpComTnvreceiveexternalerrors.MessageTransactions[] { };
			trimblecorpComTnvreceiveexternalerrors.MessageTransactions mt = new trimblecorpComTnvreceiveexternalerrors.MessageTransactions();
			trimblecorpComTnvreceiveexternalerrors.MessageTransactionData mtd = new trimblecorpComTnvreceiveexternalerrors.MessageTransactionData();
			mtd.Name = 'Quote/Proposal ID';
			mtd.Value = QuoId; //Actual Quote proposal id ex: Q-000001
			mt.MessageTXNData = mtd;
			mtArr.add(mt);

			trimblecorpComTnvreceiveexternalerrors.ErrorCodes[] erArr = new trimblecorpComTnvreceiveexternalerrors.ErrorCodes[] { };
			trimblecorpComTnvreceiveexternalerrors.ErrorCodes er = new trimblecorpComTnvreceiveexternalerrors.ErrorCodes();
			//trimblecorpComTnvreceiveexternalerrors.MessageTransactionData mtd = new trimblecorpComTnvreceiveexternalerrors.MessageTransactionData();
			er.Error_Code = 'QP-1001';
			er.Error_Message = exMessage;
			er.Error_Trace = exStackTrace;
			//mt.MessageTXNData = mtd;
			erArr.add(er);

			trimblecorpComTnvreceiveexternalerrors.ErrorType et = new trimblecorpComTnvreceiveexternalerrors.ErrorType();
			et.Interface_Name = 'TNV Tax and Quote To Order Interface';
			et.Source_System = 'SFDC';
			et.Composite_Name = 'SFDC ' + label.SandboxName + ': QuotePropCalcTax.class';
			et.Composite_Instance_Id = '';
			et.Timestamp = string.valueof(system.now());
			et.Error_Type = ErrType; //'BUSINESS ERROR/SYSTEM ERROR';
			et.Error_Resolution_Status = ResStatus; //'BUSINESS_ERROR'; //SYSTEM_ERROR
			et.Reprocess = '';
			et.Reprocess_Status = '';
			et.MessageTransaction = mtArr;
			et.ErrorCodes = erArr;


			trimblecorpComTnvreceiveexternalerrors.Response op = new trimblecorpComTnvreceiveexternalerrors.Response();
			trimblecorpComBpelTnvreceiveexternale.tnvReceiveExternalErrorsBPELProcess_pt targetportvar = new trimblecorpComBpelTnvreceiveexternale.tnvReceiveExternalErrorsBPELProcess_pt();
			op = targetportvar.process(et);
			system.debug('EBS Exception==>' + op);

		} catch(Exception ex) {
			system.debug('exception =====' + ex);
			system.debug('exception =====' + ex.getStackTraceString());
		}
	}

	/*
	 * Method name  : doSendMail
	 * Description  : Method to send email
	 * Return Type  : Void
	 * Parameter    : string exMessage
	 */
	public void doSendMail(string exMessage) {
		try {


			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

			String emailAddr = label.EBS_SOA_SFDC_EMAILADD;
			String newOwnerName = label.EBS_SOA_SFDC_EMAILNAME;

			String[] toAddresses = new String[] { emailAddr };
			mail.setToAddresses(toAddresses);

			mail.setSubject(label.EBS_SOA_SFDC_EMAILSUBJECT);

			mail.setPlainTextBody(label.EBS_SOA_SFDC_EMAILBODY);
			//mail.setHtmlBody('EBS SOA Server not responding <b>'  + '</b> and tax calculation is failed <b>' +  '</b>' + '<b> Error Message: </b>' + exMessage );

			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		} catch(Exception ex) {
			system.debug('exception =====' + ex);
			system.debug('exception =====' + ex.getStackTraceString());
		}
	}

	/*
	 * Method name  : callActionMethod
	 * Description  : Calls the UpdateTax method when the user clicks on calculate tax button in the Quote/Proposal UI
	 * Return Type  : pageReference
	 * Parameter    : NA
	 */
	public pageReference callActionMethod() {

		if (stopLoading == false)
		UpdateTax('0');
		if (errorPopup == true) {
			return null;
		}
		else {
			return new PageReference('/' + quoteId);
		}
	}

	/*
	 * Method name  : cancelquote
	 * Description  : to cancel the calculate tax and redirect back to Quote/Proposal Page
	 * Return Type  : pageReference
	 * Parameter    : NA
	 */
	public PageReference cancelquote() {
		return new PageReference('/' + quoteId);
	}

	public boolean displayPopup { get; set; }

	/*
	 * Method name  : closePopup
	 * Description  : to close the error pop up
	 * Return Type  : void
	 * Parameter    : NA
	 */
	public void closePopup() {
		displayPopup = false;
	}

	/*
	 * Method name  : closePopup
	 * Description  : to show the error pop up
	 * Return Type  : void
	 * Parameter    : NA
	 */
	public void showPopup() {
		displayPopup = true;
	}
}