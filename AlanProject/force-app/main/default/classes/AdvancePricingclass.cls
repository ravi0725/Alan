/*****************************************************************************************
  Name    : AdvancePricingclass
  Desc    : Used to invoke Oracle EBS webserice to calculate Advance Pricing Discount Amount
 
  Modification Log :
  ---------------------------------------------------------------------------
  Developer              Date            Description
  ---------------------------------------------------------------------------
  Prince Leo            03/07/2015      Created
  Suresh Babu Murugan   16-Mar-2019     APP-13638 : Upgrade Order Tax mismatch issue
  Suresh Babu Murugan   20-Nov-2019     CRMS-8 : ARR - Calculation Implementation
 ******************************************************************************************/
global class AdvancePricingclass {
	public Date MaxDate { get; set; }
	public Decimal SplitYear { get; set; }
	Public boolean ItemNotSplited { get; set; }
	Public boolean finalRes { get; set; }
	public static boolean Prebilling;
	Public Boolean creditcheck { get; set; }
	public Boolean ProfessionalService { get; set; }
	public class customexception extends exception { }
	public string OracleIntegrationError { get; set; }
	public Boolean hasPendingItems { get; set; }
	public String quoteId { get; set; }
	public string config { get; set; }
	public string tempcpqid { get; set; }
	global string tempcpqidClonePage { get; set; }
	global string configclonePage { get; set; }
	public List<Apttus_Proposal__Proposal__c> QuoteList = new List<Apttus_Proposal__Proposal__c> ();
	public List<Apttus_Config2__LineItem__c> QuoteLineList = new List<Apttus_Config2__LineItem__c> ();
	public List<Apttus_Config2__LineItem__c> LineList = new List<Apttus_Config2__LineItem__c> ();
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
	public List<Apttus_Config2__LineItem__c> lstLineItem;
	public string shipToEntMastID;
	public string ResellerFCHPartyID;
	public string ShiptoAddFCHID;
	public string BilltoAddFCHID;
	public string customerPO;
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
	Public String Aggpstype;
	public String Partner1;
	public String Partner2;
	public String BillToContactId;
	public String PaymentType;
	Public String RenBillToID;
	public String RenBillToSiteID;
	public String NONSTDCONT;
	Public Boolean PriceListSplit { get; set; }
	public String retURL { get; set; }
	Apttus_CpqApi.CPQ.UpdatePriceRequestDO request;
	Apttus_CpqApi.CPQ.UpdatePriceResponseDO result;
	public xmlnsOracleComAppsOntSoaproviderPl_v10.OutputParameters_element o;
	Map<String, Decimal> QtyMap = new Map<String, Decimal> ();
	Public String BilltoChanged { get; set; }
	Public boolean AdvancedPricingflag { get; set; }
	public string url;
	public string lineitemId;
	public string flowUI;
	public String renewalBillTo;
	public String AdditionalLicense { get; set; }
	public boolean SequenceChanged { get; set; }
	public Boolean isRenewal { get; set; } // This boolean denotes Renewal Quote
	Public String ProductCodeMEPNA { get; set; }
	public String URLParam { get; set; }
	/*
	 * Method name  : AdvancePricingclass
	 * Description  : Constructor to initilize the values
	 * Return Type  : NA
	 * Parameter    : NA
	 */
	public AdvancePricingclass() {
		//get the quote id from the Quote\Proposal Page
		url = System.currentPageReference().getParameters().get('retHref');
		if (url == null) url = 'CartDetailView';
		Config = System.currentPageReference().getParameters().get('id');
		Configclonepage = System.currentPageReference().getParameters().get('id');
		lineitemId = System.currentPageReference().getParameters().get('lineitemid');
		flowUI = System.currentPageReference().getParameters().get('flow');
		URLParam = System.currentPageReference().getParameters().get('URLParam');

		tempcpqid = System.currentPageReference().getParameters().get('configRequestId');
		tempcpqidclonePage = System.currentPageReference().getParameters().get('configRequestId');
		isRenewal = FALSE; // This flag is enabled only for Renewal Quotes
		AdvancePricingclassConstructor();
	}

	/*
	 * Method name  : AdvancePricingclass
	 * Param        : passing param from BatchApex
	 * Description  : Constructor to initilize the values
	 * Return Type  : NA
	 * Parameter    : NA
	 */
	public AdvancePricingclass(Map<String, String> pageParams) {
		url = 'CartDetailView';
		config = pageParams.get('id'); // ConfigID
		Configclonepage = pageParams.get('id'); // ConfigID
		flowUI = pageParams.get('flow');
		tempcpqid = pageParams.get('configRequestId'); // TempObjID
		tempcpqidclonePage = pageParams.get('configRequestId'); // TempObjID

		isRenewal = TRUE; // As this method will initiate from Batch, set Renewal flag as TRUE
		AdvancePricingclassConstructor();
	}

	public void AdvancePricingclassConstructor() {
		/*
		  //get the quote id from the Quote\Proposal Page
		  url = System.currentPageReference().getParameters().get('retHref');
		  if(url == null) url = 'CartDetailView';
		  Config = System.currentPageReference().getParameters().get('id');
		  Configclonepage = System.currentPageReference().getParameters().get('id');
		  lineitemId = System.currentPageReference().getParameters().get('lineitemid');
		  flowUI = System.currentPageReference().getParameters().get('flow');
		 */

		Apttus_Config2__ProductConfiguration__c con = [select id, Apttus_QPConfig__Proposald__r.Bill_to_Address_Changed__c, Apttus_QPConfig__Proposald__r.Advanced_Pricing_Completed__c, Apttus_Config2__PriceListId__r.Name, Apttus_QPConfig__Proposald__c from Apttus_Config2__ProductConfiguration__c where id = :Config];
		quoteId = con.Apttus_QPConfig__Proposald__c;
		BilltoChanged = String.valueof(con.Apttus_QPConfig__Proposald__r.Bill_to_Address_Changed__c);
		AdvancedPricingflag = con.Apttus_QPConfig__Proposald__r.Advanced_Pricing_Completed__c;
		//tempcpqid = System.currentPageReference().getParameters().get('configRequestId');
		//tempcpqidclonePage = System.currentPageReference().getParameters().get('configRequestId');
		PriceListSplit = (con.Apttus_Config2__PriceListId__r.Name.contains('TIBV') ? True : False);
		String profileName = [select Id, Name from Profile where Id = :userinfo.getProfileId()].Name;

		//get the data into the list from Apttus_Proposal__Proposal__c
		QuoteList = [Select id, Cart_Line_Sequence_Changed__c, Non_Standard_Contract__c, Additional_License__c, Renewal_Bill_To__c, Partner_2__r.FCH_Party_ID__c, Payment_Method__c, Credit_Approved__c, Apttus_Proposal__Account__r.FCH_Party_ID__c, Credit_Message__c, Credit_Status__c, Name, Bill_To_Contact__r.FCH_Contact_Id__c, Apttus_Proposal__Primary_Contact__r.FCH_Contact_Id__c, Initial_Agreement__r.Total_Agreement_Value_Formula__c, Initial_Agreement__r.Apttus__Contract_Start_Date__c, Initial_Agreement__r.Apttus__Contract_End_Date__c, Initial_Agreement__r.Fusion_Project_Number__c, Is_Related_to_Another_Quote__c, Revenue_Arrangement_Number__c, Initial_Quote_Proposal__r.Name, Duration_UOM__c, Apttus_QPConfig__PriceListId__r.Business_Area__c, Apttus_Proposal__Opportunity__r.Selling_Division__c, Customer_PO__c, Order_Type__c, Billing_Frequency__c, Duration__c, Freight_Method__c, Freight_Terms__c, Sales_Channel__c, Bill_to_Address__r.FCH_Party_Site_ID__c, Reseller__r.FCH_Party_ID__c, Ship_to_Address1__r.FCH_Party_Site_ID__c, Apttus_Proposal__Opportunity__r.Owner.Name, Apttus_Proposal__Opportunity__r.Owner.Email, Apttus_Proposal__Opportunity__r.Owner.Country, Apttus_Proposal__Opportunity__r.Owner.LastName, Apttus_Proposal__Opportunity__r.Owner.FirstName, Apttus_Proposal__Account__c, Apttus_QPConfig__PriceListId__r.Name, Apttus_QPConfig__PriceListId__r.Apttus_Config2__Description__c, Payment_Terms_Oppty__c, Shipping_Instructions__c, Ship_To_Account__r.Enterprise_Party_Number__c FROM Apttus_Proposal__Proposal__c WHERE Id = :quoteId];
		//get the data into the list from Apttus_Config2__LineItem__c
		QuoteLineList = [Select Name, Industry__c, Hardware_Bundle_Selection__c, Apttus_Config2__ProductId__r.ICC_Type__c, Apttus_Config2__ProductID__r.Business_Area__c, Must_Prorate__c, Apttus_Config2__LineSequence__c, Apttus_Config2__PriceListId__r.Division__c, Apttus_Config2__PriceListItemId__r.Apttus_Config2__ListPrice__c, Type__c, EBS_Discount_Percentage__c, Apttus_Config2__ProductId__r.Product_Category_Type__c, Apttus_Config2__ProductId__r.Contract_Item_Type_Code__c, Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_QPConfig__PriceListId__r.Name, Apttus_Config2__ProductId__r.Product_Line_Description__c, Apttus_Config2__ProductId__r.Product_Line__c, Actual_List_Price__c, Bill_to_Address__r.FCH_Party_Site_ID__c, Ship_to_Address1__r.FCH_Party_Site_ID__c, Apttus_Config2__ProductId__r.Name, Apttus_Config2__ProductId__r.ProductCode, Apttus_Config2__ProductId__r.Description, Apttus_Config2__OptionId__r.Contract_Item_Type_Code__c, Apttus_Config2__OptionId__r.ProductCode, Apttus_Config2__OptionId__r.Name, of_License__c, X1st_Software_License__c, AccountIdfortrigger__c, Account_Name__c, Apttus_Config2__AddedBy__c, Apttus_Config2__AddedByRuleInfo__c, Apttus_Config2__AdjustedPrice__c, Apttus_Config2__AdjustmentAmount__c,
		                 Apttus_Config2__AdjustmentType__c, Advance_Pricing_Status__c, Apttus_Config2__AllocateGroupAdjustment__c, Apttus_Config2__AllowableAction__c, Apttus_Config2__AllowProration__c, Apttus_Config2__AllowRemoval__c,
		                 Approval_Status_Custom__c, Apttus_CQApprov__Approval_Status__c, Apttus_Config2__AssetId__c, Apttus_Config2__AssetLineItemId__c, Asset_Oracle_ID__c, Apttus_Config2__AssetQuantity__c, Apttus_Config2__AttributeValueId__c,
		                 Apttus_Config2__BaseCost__c, Apttus_Config2__BaseCostOverride__c, Apttus_Config2__BaseExtendedCost__c, Apttus_Config2__BaseExtendedPrice__c, Apttus_Config2__BasePrice__c, Apttus_Config2__BasePriceOverride__c,
		                 Apttus_Config2__BasePriceMethod__c, Apttus_Config2__BaseProductId__c, Apttus_Config2__BillingFrequency__c, Apttus_Config2__BillingPreferenceId__c, Apttus_Config2__BillingRule__c, Apttus_Config2__BillToAccountId__c,
		                 Bill_To_Address__c, Apttus_Config2__ClassificationId__c, Category_Approval__c, Apttus_Config2__ClassificationHierarchy__c, Apttus_Config2__ClassificationHierarchyInfo__c, Category_Hierarchy_Name__c,
		                 Category_Name__c, Apttus_Config2__ChargeGroupId__c, Apttus_Config2__ChargeType__c, Apttus_Config2__Comments__c, Apttus_Config2__CommitmentQuantity__c, Apttus_Config2__ConfigStatus__c, Apttus_Config2__ConfigurationId__c,
		                 Apttus_Config2__ConstraintCheckStatus__c, Apttus_Config2__ContractNumbers__c, Apttus_Config2__CopySourceBundleNumber__c, Apttus_Config2__CopySourceNumber__c, Apttus_Config2__Cost__c, Customer_PO__c,
		                 Apttus_Config2__Customizable__c, Defer_Billing__c, Apttus_Config2__DerivedFromId__c, Apttus_Config2__Description__c, Duration__c, Duration_Sequence__c, Duration_UOM__c, Apttus_Config2__EndDate__c,
		                 Apttus_Config2__ExtendedCost__c, Apttus_Config2__ExtendedDescription__c, Apttus_Config2__ExtendedPrice__c, Apttus_Config2__ExtendedQuantity__c, Apttus_Config2__FlatOptionPrice__c, Apttus_Config2__GroupAdjustmentPercent__c,
		                 Apttus_Config2__Guidance__c, Apttus_Config2__HasAttributes__c, Parent_Line_Number__c, Apttus_Config2__HasBaseProduct__c, Apttus_Config2__HasDefaults__c, Apttus_Config2__HasOptions__c, Apttus_Config2__HasTieredPrice__c,
		                 Apttus_Config2__HideCopyAction__c, Apttus_Config2__HideInvoiceDisplay__c, Apttus_Config2__IsAssetPricing__c, Apttus_Config2__IsCustomPricing__c, Apttus_Config2__IsOptionRollupLine__c, Apttus_Config2__IsPrimaryLine__c,
		                 Apttus_Config2__IsPrimaryRampLine__c, Apttus_Config2__IsQuantityModifiable__c, Apttus_Config2__IsReadOnly__c, Apttus_Config2__IsSellingTermReadOnly__c, Apttus_Config2__IsUsageTierModifiable__c,
		                 Apttus_Config2__ItemSequence__c, Legal_Entity_Pricelist__c, Line_Item_Description__c, Apttus_Config2__LineNumber__c, Apttus_Config2__LineStatus__c, Apttus_Config2__LineType__c, Apttus_Config2__ListPrice__c,
		                 Apttus_Config2__LocationId__c, Apttus_Config2__MaxPrice__c, Apttus_Config2__MaxUsageQuantity__c, Apttus_Config2__MinMaxPriceAppliesTo__c, Apttus_Config2__MinPrice__c, Apttus_Config2__MinUsageQuantity__c,
		                 Apttus_Config2__NetAdjustmentPercent__c, Apttus_Config2__NetPrice__c, New_Net_Discount__c, Apttus_Config2__OptionId__c, Apttus_Config2__OptionCost__c, Apttus_Config2__OptionGroupLabel__c, Apttus_Config2__OptionPrice__c,
		                 Apttus_Config2__ParentBundleNumber__c, Apttus_Config2__PaymentTermId__c, Apttus_Config2__RelatedPercent__c, Apttus_Config2__RelatedPercentAppliesTo__c, Pre_Billing__c, Apttus_Config2__PriceAdjustment__c,
		                 Apttus_Config2__PriceAdjustmentAmount__c, Apttus_Config2__PriceAdjustmentAppliesTo__c, Apttus_Config2__PriceAdjustmentType__c, Apttus_Config2__PriceGroup__c, Apttus_Config2__PriceIncludedInBundle__c,
		                 Apttus_Config2__PriceListId__c, Apttus_Config2__PriceListItemId__c, Apttus_Config2__PriceMethod__c, Apttus_Config2__PriceType__c, Apttus_Config2__PricingDate__c, Apttus_Config2__Frequency__c,
		                 Apttus_Config2__PricingGuidance__c, Apttus_Config2__PricingStatus__c, Apttus_Config2__PricingSteps__c, Apttus_Config2__Term__c, Apttus_Config2__PriceUom__c, Apttus_Config2__PrimaryLineNumber__c,
		                 Apttus_Config2__ProductId__c, Product_Name_DE__c, Product_Name_EN__c, Product_Name_FR__c, Apttus_Config2__ProductOptionId__c, Product_or_Option_name__c, Apttus_Config2__Uom__c, Qty_for_1st_license__c,
		                 Apttus_Config2__Quantity__c, recordid__c, Apttus_Config2__RelatedAdjustmentAmount__c, Apttus_Config2__RelatedAdjustmentAppliesTo__c, Apttus_Config2__RelatedAdjustmentType__c, Apttus_Config2__RelatedItemId__c,
		                 Apttus_Config2__RollupPriceMethod__c, Apttus_Config2__RollupPriceToBundle__c, Schedule_Ship_Date__c, Apttus_Config2__SellingFrequency__c, Apttus_Config2__SellingTerm__c, Apttus_Config2__OptionSequence__c,
		                 Service_End_Date__c, Service_Start_Date__c, Apttus_Config2__ShipToAccountId__c, Ship_to_Account_Oracle_ID__c, Account_lookup__c, Ship_To_Address1__c, Ship_To_Address1__r.Country__c, Apttus_Config2__StartDate__c, Apttus_Config2__SummaryGroupId__c,
		                 Apttus_Config2__SyncStatus__c, Apttus_Config2__Taxable__c, Apttus_Config2__TaxCodeId__c, Apttus_Config2__TaxInclusive__c, Apttus_Config2__AdHocGroupId__c, Apttus_Config2__TotalQuantity__c,
		                 Unit__c, Users_Legal_Entity__c, Apttus_Config2__ProductId__r.SKIP_Advanced_Pricing__c, Ship_to_Address1__r.Account__r.AnnualRevenue, Ship_to_Address1__r.Account__r.CurrencyIsoCode,
		                 Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Project_Construction_Value__c, Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Surcharge_Percentage__c, Product_Code__c FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__ConfigurationId__c = :Config AND((Apttus_Config2__ChargeType__c = 'Maintenance Fee' AND Apttus_Config2__LineType__c = 'Product/Service' AND(Asset_Oracle_ID__c != null OR Apttus_Config2__ProductId__r.Product_Category_Type__c = 'SaaS' OR Apttus_Config2__ProductId__r.Product_Category_Type__c = 'Rental' OR Apttus_Config2__ProductId__r.Product_Category_Type__c = 'Subscription' OR Apttus_Config2__ProductId__r.Product_Category_Type__c = 'Maintenance')) OR(Apttus_Config2__LineType__c != 'Option' AND Apttus_Config2__ChargeType__c != 'Maintenance Fee' AND Apttus_Config2__ProductId__r.SKIP_Advanced_Pricing__c = FALSE) OR(Apttus_Config2__LineType__c = 'Option' AND(Apttus_Config2__OptionId__r.Contract_Item_Type_Code__c = 'WARRANTY' OR Apttus_Config2__OptionId__r.Contract_Item_Type_Code__c = 'SERVICE' OR Apttus_Config2__ProductId__r.SKIP_Advanced_Pricing__c = TRUE)))];

		LineList = [Select Name, Industry__c, Hardware_Bundle_Selection__c, Apttus_Config2__ProductId__r.ICC_Type__c, Must_Prorate__c, Apttus_Config2__LineSequence__c, Actual_List_Price__c, Apttus_Config2__PriceListItemId__r.Apttus_Config2__ListPrice__c, Apttus_Config2__PriceListId__r.Division__c, EBS_Discount_Percentage__c, Apttus_Config2__ProductId__r.Product_Category_Type__c, Type__c, Apttus_Config2__ProductId__r.Contract_Item_Type_Code__c, Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_QPConfig__PriceListId__r.Name, Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__c, Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Bill_to_Address__r.Account__c, Apttus_Config2__ProductId__r.Product_Line__c, Parent_Line_Number__c, Apttus_Config2__ProductId__r.Product_Line_Description__c, Bill_to_Address__r.FCH_Party_Site_ID__c, Ship_to_Address1__r.FCH_Party_Site_ID__c, Apttus_Config2__ProductId__r.Name,
		            Apttus_Config2__ProductId__r.ProductCode, Apttus_Config2__ProductId__r.Description, Apttus_Config2__OptionId__r.Contract_Item_Type_Code__c, Apttus_Config2__OptionId__r.ProductCode, Apttus_Config2__OptionId__r.Name,
		            of_License__c, X1st_Software_License__c, AccountIdfortrigger__c, Account_Name__c, Apttus_Config2__AddedBy__c, Apttus_Config2__AddedByRuleInfo__c, Apttus_Config2__AdjustedPrice__c, Apttus_Config2__AdjustmentAmount__c,
		            Apttus_Config2__AdjustmentType__c, Advance_Pricing_Status__c, Apttus_Config2__AllocateGroupAdjustment__c, Apttus_Config2__AllowableAction__c, Apttus_Config2__AllowProration__c, Ship_To_Address1__r.Country__c, Apttus_Config2__AllowRemoval__c,
		            Approval_Status_Custom__c, Apttus_CQApprov__Approval_Status__c, Apttus_Config2__AssetId__c, Apttus_Config2__AssetLineItemId__c, Asset_Oracle_ID__c, Apttus_Config2__AssetQuantity__c, Apttus_Config2__AttributeValueId__c,
		            Apttus_Config2__BaseCost__c, Apttus_Config2__BaseCostOverride__c, Apttus_Config2__BaseExtendedCost__c, Apttus_Config2__BaseExtendedPrice__c, Apttus_Config2__BasePrice__c, Apttus_Config2__BasePriceOverride__c,
		            Apttus_Config2__BasePriceMethod__c, Apttus_Config2__BaseProductId__c, Apttus_Config2__BillingFrequency__c, Apttus_Config2__BillingPreferenceId__c, Apttus_Config2__BillingRule__c, Apttus_Config2__BillToAccountId__c,
		            Bill_To_Address__c, Apttus_Config2__ClassificationId__c, Apttus_Config2__ProductId__r.Business_Area__c, Category_Approval__c, Apttus_Config2__ClassificationHierarchy__c, Apttus_Config2__ClassificationHierarchyInfo__c, Category_Hierarchy_Name__c,
		            Category_Name__c, Apttus_Config2__ChargeGroupId__c, Apttus_Config2__ChargeType__c, Apttus_Config2__Comments__c, Apttus_Config2__CommitmentQuantity__c, Apttus_Config2__ConfigStatus__c, Apttus_Config2__ConfigurationId__c,
		            Apttus_Config2__ConstraintCheckStatus__c, Apttus_Config2__ContractNumbers__c, Apttus_Config2__CopySourceBundleNumber__c, Apttus_Config2__CopySourceNumber__c, Apttus_Config2__Cost__c, Customer_PO__c,
		            Apttus_Config2__Customizable__c, Defer_Billing__c, Apttus_Config2__DerivedFromId__c, Apttus_Config2__Description__c, Duration__c, Duration_Sequence__c, Duration_UOM__c, Apttus_Config2__EndDate__c,
		            Apttus_Config2__ExtendedCost__c, Apttus_Config2__ExtendedDescription__c, Apttus_Config2__ExtendedPrice__c, Apttus_Config2__ExtendedQuantity__c, Apttus_Config2__FlatOptionPrice__c, Apttus_Config2__GroupAdjustmentPercent__c,
		            Apttus_Config2__Guidance__c, Apttus_Config2__HasAttributes__c, Apttus_Config2__HasBaseProduct__c, Apttus_Config2__HasDefaults__c, Apttus_Config2__HasOptions__c, Apttus_Config2__HasTieredPrice__c,
		            Apttus_Config2__HideCopyAction__c, Apttus_Config2__HideInvoiceDisplay__c, Apttus_Config2__IsAssetPricing__c, Apttus_Config2__IsCustomPricing__c, Apttus_Config2__IsOptionRollupLine__c, Apttus_Config2__IsPrimaryLine__c,
		            Apttus_Config2__IsPrimaryRampLine__c, Apttus_Config2__IsQuantityModifiable__c, Apttus_Config2__IsReadOnly__c, Apttus_Config2__IsSellingTermReadOnly__c, Apttus_Config2__IsUsageTierModifiable__c,
		            Apttus_Config2__ItemSequence__c, Legal_Entity_Pricelist__c, Line_Item_Description__c, Apttus_Config2__LineNumber__c, Apttus_Config2__LineStatus__c, Apttus_Config2__LineType__c, Apttus_Config2__ListPrice__c,
		            Apttus_Config2__LocationId__c, Apttus_Config2__MaxPrice__c, Apttus_Config2__MaxUsageQuantity__c, Apttus_Config2__MinMaxPriceAppliesTo__c, Apttus_Config2__MinPrice__c, Apttus_Config2__MinUsageQuantity__c,
		            Apttus_Config2__NetAdjustmentPercent__c, Apttus_Config2__NetPrice__c, New_Net_Discount__c, Apttus_Config2__OptionId__c, Apttus_Config2__OptionCost__c, Apttus_Config2__OptionGroupLabel__c, Apttus_Config2__OptionPrice__c,
		            Apttus_Config2__ParentBundleNumber__c, Apttus_Config2__PaymentTermId__c, Apttus_Config2__RelatedPercent__c, Apttus_Config2__RelatedPercentAppliesTo__c, Pre_Billing__c, Apttus_Config2__PriceAdjustment__c,
		            Apttus_Config2__PriceAdjustmentAmount__c, Apttus_Config2__PriceAdjustmentAppliesTo__c, Apttus_Config2__PriceAdjustmentType__c, Apttus_Config2__PriceGroup__c, Apttus_Config2__PriceIncludedInBundle__c,
		            Apttus_Config2__PriceListId__c, Apttus_Config2__PriceListItemId__c, Apttus_Config2__PriceMethod__c, Apttus_Config2__PriceType__c, Apttus_Config2__PricingDate__c, Apttus_Config2__Frequency__c,
		            Apttus_Config2__PricingGuidance__c, Apttus_Config2__PricingStatus__c, Apttus_Config2__PricingSteps__c, Apttus_Config2__Term__c, Apttus_Config2__PriceUom__c, Apttus_Config2__PrimaryLineNumber__c,
		            Apttus_Config2__ProductId__c, Product_Name_DE__c, Product_Name_EN__c, Product_Name_FR__c, Apttus_Config2__ProductOptionId__c, Product_or_Option_name__c, Apttus_Config2__Uom__c, Qty_for_1st_license__c,
		            Apttus_Config2__Quantity__c, recordid__c, Apttus_Config2__RelatedAdjustmentAmount__c, Apttus_Config2__RelatedAdjustmentAppliesTo__c, Apttus_Config2__RelatedAdjustmentType__c, Apttus_Config2__RelatedItemId__c,
		            Apttus_Config2__RollupPriceMethod__c, Apttus_Config2__RollupPriceToBundle__c, Schedule_Ship_Date__c, Apttus_Config2__SellingFrequency__c, Apttus_Config2__SellingTerm__c, Apttus_Config2__OptionSequence__c,
		            Service_End_Date__c, Service_Start_Date__c, Apttus_Config2__ShipToAccountId__c, Ship_to_Account_Oracle_ID__c, Account_lookup__c, Ship_To_Address1__c, Apttus_Config2__StartDate__c, Apttus_Config2__SummaryGroupId__c,
		            Apttus_Config2__SyncStatus__c, Apttus_Config2__Taxable__c, Apttus_Config2__TaxCodeId__c, Apttus_Config2__TaxInclusive__c, Apttus_Config2__AdHocGroupId__c, Apttus_Config2__TotalQuantity__c,
		            Unit__c, Users_Legal_Entity__c FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__ConfigurationId__c = :Config];

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


			billtocontactFCHID = ap.Bill_To_Contact__r.FCH_Contact_Id__c;
			shiptocontactFCHID = ap.Apttus_Proposal__Primary_Contact__r.FCH_Contact_Id__c;

			partner1 = ap.Reseller__r.FCH_Party_ID__c;
			partner2 = ap.Partner_2__r.FCH_Party_ID__c;
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
		lstLineItem = [Select Name, Apttus_Config2__OptionId__r.ProductCode, Apttus_Config2__ProductId__c, Apttus_Config2__ProductId__r.Name, Apttus_Config2__OptionId__r.Name, Apttus_Config2__ProductId__r.ProductCode, Apttus_Config2__ProductId__r.Description, Apttus_Config2__OptionId__r.Contract_Item_Type_Code__c, Apttus_Config2__Quantity__c, Apttus_Config2__PriceUom__c, Apttus_Config2__ListPrice__c, Apttus_Config2__NetPrice__c, Apttus_Config2__SellingTerm__c, Apttus_Config2__SellingFrequency__c, Apttus_Config2__LineType__c, Apttus_Config2__OptionId__c, Apttus_Config2__ChargeType__c, Asset_Oracle_ID__c, Apttus_Config2__LineNumber__c FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__ConfigurationId__c = :config order by Apttus_Config2__LineSequence__c, Apttus_Config2__LineNumber__c asc];
		for (Apttus_Config2__LineItem__c propLineItem : lstLineItem) {
			system.debug('propLineItem' + propLineItem.Apttus_Config2__OptionId__c);
			if (propLineItem.Apttus_Config2__OptionId__c == NULL && propLineItem.Apttus_Config2__ChargeType__c != 'Maintenance Fee') {
				mapLineitemIdwoOpt.put(propLineItem.Apttus_Config2__ProductId__r.Name + propLineItem.Apttus_Config2__LineNumber__c, propLineItem.Name);
			}
			else if (propLineItem.Apttus_Config2__OptionId__c != NULL && propLineItem.Apttus_Config2__ChargeType__c == 'Maintenance Fee' && (propLineItem.Asset_Oracle_ID__c == null || propLineItem.Asset_Oracle_ID__c == '')) {

				mapLineitemIdwithOpt.put(propLineItem.Name, propLineItem.Apttus_Config2__OptionId__c);

				prodIDCodeMap.put(propLineItem.Apttus_Config2__OptionId__c, propLineItem.Apttus_Config2__OptionId__r.ProductCode);

			}
		}



		/* Boolean res = false;
		  res = updateTax('0');*/
	}

	public Pagereference callHardwareKitpage()
	{
		return new Pagereference('/apex/MepNaHardwareKitPage?id=' + config + '&configRequestId=' + tempcpqid + '&ProductCode=' + ProductCodeMEPNA + '&flow=' + flowUI);

	}

	Public PageReference Temp() {
		Boolean MEPNAHardwareKit = false;
		List<String> StrProdCode = new list<String> ();
		for (Apttus_Config2__LineItem__c li : LineList)
		{
			if (li.Hardware_Bundle_Selection__c == False)
			StrProdCode.add(li.Apttus_Config2__ProductId__r.ProductCode);

		}

		system.debug('*************&&&&&&&&&&&&&&&************' + StrProdCode);

		for (MEPNA_Hardware_Kit__c hKit :[SELECT Name, Selection_Wizard__c, Products__c, Before__c, After__c FROM MEPNA_Hardware_Kit__c]) {
			if (StrProdCode.contains(hKit.Name)) {

				MEPNAHardwareKit = True;
				ProductCodeMEPNA = hKit.Name;
				break;
			}
		}

		system.debug('*************&&&&&&MEPNAHardwareKit &&&&&&&&&************' + MEPNAHardwareKit);
		system.debug('*************&&&&&&&ProductCodeMEPNA &&&&&&&&************' + ProductCodeMEPNA);
		if (MEPNAHardwareKit == True && URLParam != 'Completed')
		{
			PageReference pageRef;
			pageRef = callHardwareKitpage();
			pageRef.setRedirect(true);
			return pageRef;
		}

		else {
			Temp1();
			return Null;
		}
	}

	public void Temp1()
	{
		if (url.contains('ProductAttributeDetail'))
		AdvancePricingclassConstructor();

		//To Validate unsplited Line Items
		for (Apttus_Config2__LineItem__c lin : LineList) {
			if (lin.Apttus_Config2__IsOptionRollupLine__c == False && Lin.Duration_UOM__c == 'Year' && Lin.Duration__c > 1) {
				ItemNotSplited = True;
				system.debug('>>>>>>>>>>>>>>ItemNotSplited>>>>>>>>' + ItemNotSplited);
				// return Null;
			}
		}
		// Pagereference res ;
		updateTax('0');
		// return res;

	}
	public void updateDiscountAndDuration() {
		List<Apttus_Config2__LineItem__c> updateList = new List<Apttus_Config2__LineItem__c> ();
		Apttus_Config2__LineItem__c litmObj = new Apttus_Config2__LineItem__c();
		for (Apttus_Config2__LineItem__c lin : LineList) {
			boolean updateFlag = false;
			litmObj = new Apttus_Config2__LineItem__c();
			litmObj.Id = lin.Id;
			String key = lin.Apttus_Config2__ProductId__c + string.valueof(lin.Apttus_Config2__LineNumber__c) +
			String.valueof(lin.Apttus_Config2__PrimaryLineNumber__c) + string.valueof(lin.Apttus_Config2__ItemSequence__c);
			String key1 = String.valueof(lin.Apttus_Config2__ProductId__c) + String.valueof(lin.Apttus_Config2__LineNumber__c);
			system.debug(oldLineMapStatic.keySet() + '----------------------' + key);
			if (oldLineMapStatic.get(key) != null && lin.Apttus_Config2__IsOptionRollupLine__c == True &&
			    lin.Duration__c != Null && lin.Duration_UOM__c != Null && lin.Duration_UOM__c == 'Year') {
				system.debug(oldLineMapStatic.get(key).Duration_UOM__c + '----------------------' + oldLineMapStatic.get(key).Duration__c);
				litmObj.Duration__c = oldLineMapStatic.get(key).Duration__c;
				litmObj.Duration_UOM__c = oldLineMapStatic.get(key).Duration_UOM__c;
				//lin.Apttus_Config2__AdjustmentType__c = '% Discount';
				updateFlag = true;
				system.debug('-----------oldLineclonemapStatic-----------' + oldLineclonemapStatic);

			}
			decimal discount = 0;
			decimal cnt = 0;
			system.debug(oldLineclonemapStatic.keySet() + '-----------key1-----------' + key1);
			if (oldLineclonemapStatic.get(key1) != null && lin.Apttus_Config2__ChargeType__c == 'Maintenance Fee'
			    && lin.Apttus_Config2__IsOptionRollupLine__c) {
				for (Apttus_Config2__LineItem__c lin1 : oldLineclonemapStatic.get(key1)) {
					system.debug('-----------lin1.Apttus_Config2__NetAdjustmentPercent__c-----------' + lin1.Apttus_Config2__NetAdjustmentPercent__c);
					if (lin1.Apttus_Config2__AdjustmentAmount__c != null) {
						discount = discount + lin1.Apttus_Config2__AdjustmentAmount__c;
					}
					cnt++;
				}
				system.debug(cnt + '-----------cnt-----------' + discount);
				if (cnt != 0 && discount != 0) {
					litmObj.Apttus_Config2__NetAdjustmentPercent__c = - 1 * (discount / cnt);
					litmObj.Apttus_Config2__AdjustmentType__c = '% Discount';
					litmObj.Apttus_Config2__AdjustmentAmount__c = (discount / cnt);
					updateFlag = true;
					//lin.Apttus_Config2__GroupAdjustmentPercent__c = lin.Apttus_Config2__NetAdjustmentPercent__c;
					system.debug(cnt + '-----------lin.Apttus_Config2__GroupAdjustmentPercent__c-----------' + lin.Apttus_Config2__GroupAdjustmentPercent__c);
				} else {
					litmObj.Apttus_Config2__NetAdjustmentPercent__c = 0;
					updateFlag = true;
					// lin.Apttus_Config2__GroupAdjustmentPercent__c = 0;
				}
			}
			if (!updateFlag) {
				updateList.add(litmObj);
			}
			system.debug('----------------------' + lin.Apttus_Config2__NetAdjustmentPercent__c);
		}
		if (updateList.size() > 0) {
			update updateList;
		}
	}

	public static Map<String, Apttus_Config2__LineItem__c> oldLineMapStatic;
	public static Map<String, List<Apttus_Config2__LineItem__c>> oldLineclonemapStatic;
	public pagereference rollupDiscount() {
		ItemNotSplited = false;
		oldLineMapStatic = new Map<String, Apttus_Config2__LineItem__c> ();
		oldLineclonemapStatic = new Map<String, List<Apttus_Config2__LineItem__c>> ();
		//To Validate unsplited Line Items
		for (Apttus_Config2__LineItem__c lin : LineList) {
			if (lin.Apttus_Config2__IsOptionRollupLine__c == False && Lin.Duration_UOM__c == 'Year' && Lin.Duration__c > 1) {
				ItemNotSplited = True;
				return null;
			}
		}

		for (Apttus_Config2__LineItem__c lin : LineList) {
			system.debug(lin.Apttus_Config2__AdjustmentAmount__c + '-----------lin-----------' + lin.Apttus_Config2__AdjustmentType__c);
			if (lin.Apttus_Config2__IsOptionRollupLine__c == True && lin.Duration__c != Null && lin.Duration_UOM__c != Null && lin.Duration_UOM__c == 'Year') {
				oldLineMapStatic.put(lin.Apttus_Config2__ProductId__c + string.valueof(lin.Apttus_Config2__LineNumber__c) + String.valueof(lin.Apttus_Config2__PrimaryLineNumber__c) + string.valueof(lin.Apttus_Config2__ItemSequence__c), lin);
			}

			if (lin.Apttus_Config2__ChargeType__c == 'Maintenance Fee' && lin.Apttus_Config2__IsOptionRollupLine__c == False
			    && lin.Apttus_Config2__AdjustmentAmount__c != null && lin.Apttus_Config2__AdjustmentType__c == '% Discount') {
				String key = String.valueof(lin.Apttus_Config2__ProductId__c) + String.valueof(lin.Apttus_Config2__LineNumber__c);
				system.debug('-----------key-----------' + key);

				if (oldLineclonemapStatic.get(key) == null) {
					oldLineclonemapStatic.put(key, new List<Apttus_Config2__LineItem__c> ());
				}
				oldLineclonemapStatic.get(key).add(lin);
			}
		}

		system.debug(oldLineclonemapStatic + '----------------------' + oldLineMapStatic.keySet());
		updateDiscountAndDuration();
		if (flowUI == 'Angular')
		retURL = '/apex/Apttus_Config2__Cart?id=' + config + '&configRequestId=' + tempcpqid + '&flow=' + flowUI;
		else if (flowUI == 'ngCPQ')
		return new Pagereference('/apex/Apttus_Config2__Cart?id=' + config + '&configRequestId=' + tempcpqid + '&flow=' + flowUI + '&launchState=cart#/cartgrid');
		else
		return new Pagereference('/apex/Apttus_Config2__CartDetailView?id=' + config + '&configRequestId=' + tempcpqid + '&flow=Default');

		if (flowUI == 'Angular')
		return new Pagereference('/apex/Apttus_Config2__Cart?id=' + config + '&configRequestId=' + tempcpqid + '&flow=' + flowUI);
		else if (flowUI == 'ngCPQ')
		return new Pagereference('/apex/Apttus_Config2__Cart?id=' + config + '&configRequestId=' + tempcpqid + '&flow=' + flowUI + '&launchState=cart#/cartgrid');
		else
		return new Pagereference('/apex/Apttus_Config2__CartDetailView?id=' + config + '&configRequestId=' + tempcpqid + '&flow=Default');


	}

	Public void Reprice() {
		List<Apttus_Config2__LineItem__c> OptionList = new List<Apttus_Config2__LineItem__c> ([select id, Apttus_Config2__ListPrice__c, Apttus_Config2__BasePrice__c from Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c = :config and Apttus_Config2__LineType__c = 'Option']);
		List<Apttus_Config2__LineItem__c> UpList = new List<Apttus_Config2__LineItem__c> ();

		try {
			Apttus_Config2.CPQWebService.validateCart(config);

			hasPendingItems = false;
			// create the update price request
			request = new Apttus_CpqApi.CPQ.UpdatePriceRequestDO();
			// add request parameters
			request.CartId = config;
			// update price for the cart


			result = Apttus_CpqApi.CPQWebService.updatePriceForCart(request);
			hasPendingItems = result.IsPricePending;
			system.debug(result.PendingLineNumbers + '-------hasPendingItems----------' + hasPendingItems);
			system.debug(result.CompletedLineNumbers + '-------hasPendingItems----------' + hasPendingItems);
			system.debug(BillToChanged + '-------BillToChanged  ----------' + BillToChanged);

			if (BilltoChanged == 'True')
			retURL = '/apex/AdvancePricingPage?id=' + config + '&configRequestId=' + tempcpqid + '&flow=' + flowUI;
			else if (!AdvancedPricingflag)
			retURL = '/apex/AdvancePricingPage?id=' + config + '&configRequestId=' + tempcpqid + '&flow=' + flowUI;
			else {
				for (Apttus_Config2__LineItem__c li : OptionList) {
					li.Apttus_Config2__ListPrice__c = li.Apttus_Config2__BasePrice__c;
					UpList.add(li);
				}
				if (UpList.size() > 0)
				update UpList;
				if (flowUI == 'Angular')
				retURL = '/apex/Apttus_Config2__Cart?id=' + config + '&configRequestId=' + tempcpqid + '&flow=' + flowUI;

				else if (flowUI == 'ngCPQ')
				retURL = '/apex/Apttus_Config2__Cart?id=' + config + '&configRequestId=' + tempcpqid + '&flow=' + flowUI + '&launchState=cart#/cartgrid';
				else
				retURL = '/apex/Apttus_Config2__CartDetailView?id=' + config + '&configRequestId=' + tempcpqid + '&flow=Default';

			}
			//  retURL = '/apex/AdvancePricingPage?id='+config+'&configRequestId='+tempcpqid+'&flow=Default';
		}
		catch(Exception e)
		{
			errorpopup = True;
			errorMsg = e.getMessage();
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: ' + e);
			ApexPages.addMessage(myMsg);
		}
	}

	Public void Reprice2() {
		List<Apttus_Config2__LineItem__c> OptionList = new List<Apttus_Config2__LineItem__c> ([select id, Apttus_Config2__ListPrice__c, Apttus_Config2__BasePrice__c from Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c = :config and Apttus_Config2__LineType__c = 'Option']);
		List<Apttus_Config2__LineItem__c> UpList = new List<Apttus_Config2__LineItem__c> ();

		try {

			hasPendingItems = false;
			// create the update price request
			request = new Apttus_CpqApi.CPQ.UpdatePriceRequestDO();
			// add request parameters
			request.CartId = config;
			// update price for the cart
			result = Apttus_CpqApi.CPQWebService.updatePriceForCart(request);
			hasPendingItems = result.IsPricePending;
			system.debug(result.PendingLineNumbers + '-------hasPendingItems----------' + hasPendingItems);
			system.debug(result.CompletedLineNumbers + '-------hasPendingItems----------' + hasPendingItems);

			for (Apttus_Config2__LineItem__c li : OptionList) {
				li.Apttus_Config2__ListPrice__c = li.Apttus_Config2__BasePrice__c;
				UpList.add(li);
			}
			if (UpList.size() > 0)
			update UpList;
			if (flowUI == 'Angular')
			retURL = '/apex/Apttus_Config2__Cart?id=' + config + '&configRequestId=' + tempcpqid + '&flow=' + flowUI;
			else if (flowUI == 'ngCPQ')
			retURL = '/apex/Apttus_Config2__Cart?id=' + config + '&configRequestId=' + tempcpqid + '&flow=' + flowUI + '&launchState=cart#/cartgrid';
			else
			retURL = '/apex/Apttus_Config2__CartDetailView?id=' + config + '&configRequestId=' + tempcpqid + '&flow=Default';

		}
		catch(Exception e)
		{
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: ' + e);
			ApexPages.addMessage(myMsg);
		}
	}

	Public Pagereference Split()
	{

		Map<Id, Apttus_Config2__LineItem__c> linIdMap = new Map<Id, Apttus_Config2__LineItem__c> ();
		Map<String, Apttus_Config2__LineItem__c> OldLineMap = new Map<String, Apttus_Config2__LineItem__c> ();
		List<Apttus_Config2__LineItem__C> updateLineItems = new List<Apttus_Config2__LineItem__C> ();
		List<Apttus_Config2__LineItem__C> updateLineItemsMaint = new List<Apttus_Config2__LineItem__C> ();
		List<Apttus_Config2__LineItem__C> DelLineItems = new List<Apttus_Config2__LineItem__C> ();
		Boolean enableAdvancedPricing = false;
		Map<String, ProjectSight_Discounting_Matrix__mdt> mapPSDiscMatrix = new Map<String, ProjectSight_Discounting_Matrix__mdt> ();
		List<ProjectSight_Discounting_Matrix__mdt> lstProjectSightDicMatrix = [SELECT MasterLabel, DeveloperName, Item_Code__c, Object_API_Name__c, Matrix_Based_on_Field_API__c FROM ProjectSight_Discounting_Matrix__mdt];
		for (ProjectSight_Discounting_Matrix__mdt pDM : lstProjectSightDicMatrix) {
			mapPSDiscMatrix.put(pDM.Item_Code__c, pDM);
		}

		//Validating based on Service End Date and Scheduled Shiped Date
		for (Apttus_Config2__LineItem__c lin : LineList) {
			system.debug(lin.Apttus_Config2__IsOptionRollupLine__c + '--------lin-------' + lin);
			system.debug(lin.Duration__c + '--------lin-------' + lin.Duration_UOM__c);
			system.debug(lin.Duration__c + '--------lin-------' + lin.Apttus_Config2__ChargeType__c);
			if (/*lin.Type__c!='Renewal' &&*/ lin.Apttus_Config2__IsOptionRollupLine__c == True && lin.Duration__c != Null && lin.Duration_UOM__c != Null && lin.Duration_UOM__c == 'Year' && (lin.Apttus_Config2__ChargeType__c != 'Standard Price' || (lin.Apttus_Config2__ChargeType__c == 'Standard Price' && lin.Apttus_Config2__ProductId__r.Product_Category_Type__c == 'SaaS')))

			{

				/*   ValidateEndDate ved = new ValidateEndDate();
				  Boolean Res = ved.Check(lin.Duration__c,lin.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__c,lin.Apttus_Config2__ProductId__r.Product_Line__c,lin.Apttus_Config2__ProductId__c);
				  system.debug('>>>>>>>>>>ResValue>>>>>>>>>'+Res);
				  MaxDate = ved.MaxDate;
				  system.debug('>>>>>>>>>>MaxDate>>>>>>>>>'+MaxDate);
				  MaxDate = ved.MaxDate;
				  SplitYear = ved.SplitYear;
				  if(Res==True)
				  {
				  finalRes = Res;
				 
				  return null;
				  }
				  else*/ if (PriceListSplit == True)
				return null;

				system.debug('>>>>>>>>>>PriceLsit>>>>>>' + PriceListSplit);
			}

			if (/*lin.Type__c!='Renewal' && */(lin.Apttus_Config2__ProductId__r.Product_Category_Type__c == 'Rental' || lin.Apttus_Config2__ProductId__r.Product_Category_Type__c == 'SaaS' || lin.Apttus_Config2__ProductId__r.Product_Category_Type__c == 'Subscription' || lin.Apttus_Config2__ProductId__r.Product_Category_Type__c == 'Maintenance') && lin.Duration__c != Null && lin.Duration_UOM__c == 'Year')
			{
				/* ValidateEndDate ved = new ValidateEndDate();
				  Boolean Res = ved.CheckSAAS(lin.Duration__c,lin.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__c,lin.Apttus_Config2__ProductId__r.Product_Line__c,lin.Apttus_Config2__ProductId__r.Business_Area__c);
				  system.debug('>>>>>>>>>>ResValue>>>>>>>>>'+Res);
				  MaxDate = ved.MaxDate;
				  system.debug('>>>>>>>>>>MaxDate>>>>>>>>>'+MaxDate);
				  MaxDate = ved.MaxDate;
				  SplitYear = ved.SplitYear;
				  if(Res==True)
				  {
				  finalRes = Res;
				 
				  return null;
				  }
				  else */ if (PriceListSplit == True)
				return null;


				system.debug('>>>>>>>>>>PriceLsit>>>>>>' + PriceListSplit);
			}

		}

		// Deleting Old Line Items befor eSpliting
		DelLineItems = [select id from Apttus_Config2__LineItem__C where Parent_Line_Number__c != Null and Apttus_Config2__ConfigurationId__c = :config];
		if (DelLineItems.size() > 0)
		Delete DelLineItems;


		Set<ID> LineID = new Set<ID> ();
		List<Apttus_Config2__LineItem__C> liTmList = new List<Apttus_Config2__LineItem__C> ();
		List<Apttus_Config2__LineItem__C> DurList = new List<Apttus_Config2__LineItem__C> ();
		Map<String, Apttus_Config2__LineItem__C> lineclonemap = new Map<String, Apttus_Config2__LineItem__C> ();

		for (Apttus_Config2__LineItem__c lin : LineList) {

			system.debug('-----------------lin ---------------' + lin);
			if (lin.Apttus_Config2__ChargeType__c == 'Standard Price' && lin.Apttus_Config2__IsPrimaryLine__c == True) {
				linIdMap.put(lin.Apttus_Config2__ProductId__c, lin);
				LineID.add(lin.Id);
				system.debug('-----------------lin.IdStandard---------------' + lin.Id);
			}
			if (lin.Apttus_Config2__ChargeType__c == 'Maintenance Fee' && lin.Apttus_Config2__IsOptionRollupLine__c == False) {
				linIdMap.put(lin.Apttus_Config2__OptionId__c, lin);
				lineclonemap.put(String.valueof(lin.Apttus_Config2__ProductId__c) + String.valueof(lin.Apttus_Config2__OptionId__c) + String.valueof(lin.Apttus_Config2__LineNumber__c), lin);
				LineID.add(lin.Id);
				system.debug('-----------------lin.IdMaintenance---------------' + lin.Id);
			}
		}
		system.debug('-----------------linIdMap---------------' + linIdMap.keyset());
		system.debug('-----------------LineID---------------' + LineID);


		Apttus_Config2__LineItem__C nLi = new Apttus_Config2__LineItem__C();
		Set<ID> TempId = new Set<ID> ();
		Decimal Yr = 0;
		Map<String, Decimal> YrMap = new Map<String, Decimal> ();
		Map<String, Boolean> PreBillingMap = new Map<String, Boolean> ();
		system.debug('------------LineList---------' + LineList.size());

		// Getting Summary Maintaiance Item Record
		for (Apttus_Config2__LineItem__c lin : LineList) {

			if (lin.Apttus_Config2__IsOptionRollupLine__c == True && lin.Duration__c != Null && lin.Duration_UOM__c != Null && lin.Duration_UOM__c == 'Year' && (lin.Apttus_Config2__ChargeType__c != 'Standard Price' || (lin.Apttus_Config2__ChargeType__c == 'Standard Price' && lin.Apttus_Config2__ProductId__r.Product_Category_Type__c == 'SaaS')))

			{
				oldLineMap.put(lin.Apttus_Config2__ProductId__c + string.valueof(lin.Apttus_Config2__LineNumber__c) + String.valueof(lin.Apttus_Config2__PrimaryLineNumber__c) + string.valueof(lin.Apttus_Config2__ItemSequence__c), lin);
				YrMap.put(lin.Apttus_Config2__ProductId__r.Name + 'false', lin.Duration__c);
				PreBillingMap.put(lin.Apttus_Config2__ProductId__r.Name + 'false', lin.Pre_Billing__c);

			}
		}
		Integer count = 0;
		// Suresh Babu (30/11/2017) : REQ-125621 - SFDC Cart: Parent Line Reference Update
		Integer PrimaryLineReferenceCnt = 0;
		////
		// Getting Bundled Maintaiance Records
		for (Apttus_Config2__LineItem__c lin : LineList) {

			if (lin.Apttus_Config2__IsOptionRollupLine__c == false && lin.Parent_Line_Number__c == Null && lin.Apttus_Config2__ChargeType__c == 'Maintenance Fee' && lin.Apttus_Config2__LineType__c == 'Option') {
				yr = yrMap.get(lin.Apttus_Config2__ProductId__r.Name + 'false');
				system.debug('------------Duration__c ---------' + lin.Apttus_Config2__OptionId__c);
				system.debug('------------Duration__c ---------' + yr);

				lin.Duration__c = 1;
				lin.Duration_UOM__c = 'Year';
				lin.Duration_Sequence__c = 1;

				//lin.Pre_billing__c = PreBillingMap.get(lin.Apttus_Config2__ProductId__r.Name+'false');

				if (yr != null && lin.Parent_Line_Number__c == Null && linIdMap.get(lin.Apttus_Config2__ProductId__c) != null && linIdMap.get(lin.Apttus_Config2__ProductId__c).Apttus_Config2__ProductId__c == lin.Apttus_Config2__ProductId__c) {
					system.debug('------------Inside For ---------' + yr);
					// Suresh Babu (30/11/2017) : REQ-125621 - SFDC Cart: Parent Line Reference Update
					PrimaryLineReferenceCnt += 100;
					////
					Boolean isFirstYearSplit = true;
					for (Integer i = 0; i<Yr - 1; i++)
					{

						Apttus_Config2__LineItem__C nLin = new Apttus_Config2__LineItem__C();
						nLi = lineclonemap.get(String.valueof(lin.Apttus_Config2__ProductId__c) + String.valueof(lin.Apttus_Config2__OptionId__c) + string.valueof(lin.Apttus_Config2__LineNumber__c));
						nLin = nLi.clone(false, true, false, false);
						nLin.Duration__c = 1;
						if (i == 0 && lin.Service_Start_Date__c != Null && lin.Service_End_Date__c != Null) {

							nlin.Service_Start_Date__c = lin.Service_End_Date__c.adddays(1);
							nlin.Service_End_Date__c = lin.Service_End_Date__c.addyears(1);
						}
						else if (nlin.Service_Start_Date__c != Null && nLin.Service_End_Date__c != Null)
						{
							nlin.Service_Start_Date__c = lin.Service_End_Date__c.addyears((i)) + 1;
							nlin.Service_End_Date__c = lin.Service_End_Date__c.addyears((i + 1));
						}
						//Proration Logic
						if (nlin.service_Start_date__c != Null && nlin.Service_End_date__c != Null && nlin.Apttus_Config2__PriceListId__r.Division__c != Null && nlin.Apttus_Config2__PriceListId__r.Division__c != 'Plancal') {
							Integer NoMonths = 0;
							Integer NoDays = 0;
							Date startDate = nlin.service_Start_date__c;
							Date endDate = nlin.Service_End_date__c;
							String Output = CalculateDuration.MonthsandDays(startDate, endDate);
							List<String> OutputList = Output.split(':');
							NoMonths = Integer.valueof(OutputList.get(0));
							NoDays = Integer.valueof(OutputList.get(1));

							Decimal Monthlyprice = 0;

							if(nLin.Type__c == 'Renewal' && NoMonths == 12){ // If Renewal line is splited
								if (nlin.EBS_Discount_Percentage__c != Null && nlin.Apttus_Config2__PriceUom__c == 'Year') {
									Monthlyprice = nlin.Apttus_Config2__ListPrice__c + (nlin.Apttus_Config2__ListPrice__c * (nlin.EBS_Discount_Percentage__c / 100));
									Monthlyprice = Monthlyprice / 12;
								}
								else if (nlin.Apttus_Config2__PriceUom__c == 'Year')
								MonthlyPrice = nlin.Apttus_Config2__ListPrice__c / 12;
								else if (nlin.Apttus_Config2__PriceUom__c == 'Month')
								MonthlyPrice = nlin.Apttus_Config2__ListPrice__c;
							}
							else{ // NEW BUY Lines
								if (nlin.EBS_Discount_Percentage__c != Null && nlin.Apttus_Config2__PriceUom__c == 'Year') {
									Monthlyprice = nlin.Actual_List_Price__c + (nlin.Actual_List_Price__c * (nlin.EBS_Discount_Percentage__c / 100));
									Monthlyprice = Monthlyprice / 12;
								}
								else if (nlin.Apttus_Config2__PriceUom__c == 'Year')
								MonthlyPrice = nlin.Actual_List_Price__c / 12;
								else if (nlin.Apttus_Config2__PriceUom__c == 'Month')
								MonthlyPrice = nlin.Actual_List_Price__c;
							}

							Decimal DailyPrice = Monthlyprice / 30;
							Decimal ListPriceMonthly = NoMonths * Monthlyprice;
							Decimal ListPriceDaily = NoDays * DailyPrice;
							Decimal ListPr = ListPriceMonthly + ListPriceDaily;


							system.debug('--------NoMonths -------' + NoMonths);
							system.debug('--------NoDays -------' + NoDays);
							system.debug('--------Monthlyprice -------' + Monthlyprice);
							system.debug('--------DailyPrice -------' + DailyPrice);
							system.debug('--------ListPriceMonthly -------' + ListPriceMonthly);
							system.debug('--------ListPriceDaily -------' + ListPriceDaily);
							system.debug('--------ListPr -------' + ListPr);

							nlin.Apttus_Config2__ListPrice__c = ListPr;
							nlin.Apttus_Config2__NetPrice__c = ListPr * nlin.Apttus_Config2__Quantity__c;
							nlin.Apttus_Config2__BaseExtendedPrice__c = ListPr * nlin.Apttus_Config2__Quantity__c;
							nlin.Apttus_Config2__BasePrice__c = ListPr;
							nlin.Apttus_Config2__BasePriceOverride__c = ListPr;
							nlin.Apttus_Config2__ExtendedPrice__c = ListPr * nlin.Apttus_Config2__Quantity__c;
						}
						//if(nLin.Type__c =='Renewal') nLin.Service_end_Date__c = nLin.Service_end_Date__c.addyears(i+1);
						nlin.Apttus_Config2__ConfigurationId__c = config;
						nLin.Duration_Sequence__c = i + 2;
						/*  if(count == 0){
						  //nLin.Apttus_Config2__LineNumber__c = nLin.Apttus_Config2__ItemSequence__c+1+i;
						  nLin.Apttus_Config2__PrimaryLineNumber__c = nLin.Apttus_Config2__ItemSequence__c+i;  //lin.Apttus_Config2__PrimaryLineNumber__c + 1;
						  nLin.Apttus_Config2__ItemSequence__c = nLin.Apttus_Config2__ItemSequence__c+1+i;
						  }
						  else
						  {
						  //nLin.Apttus_Config2__LineNumber__c = nLin.Apttus_Config2__ItemSequence__c+1+i;
						  nLin.Apttus_Config2__PrimaryLineNumber__c = nLin.Apttus_Config2__ItemSequence__c+i;  //lin.Apttus_Config2__PrimaryLineNumber__c + i +count;
						  nLin.Apttus_Config2__ItemSequence__c = nLin.Apttus_Config2__ItemSequence__c+1+i+nLin.Apttus_Config2__LineNumber__c;
						  }*/
						if (i == 0) {
							//nLin.Apttus_Config2__LineNumber__c = nLin.Apttus_Config2__ItemSequence__c+count+i;
							// Suresh Babu (30/11/2017) : REQ-125621 - SFDC Cart: Parent Line Reference Update
							//nLin.Apttus_Config2__PrimaryLineNumber__c = nLin.Apttus_Config2__PrimaryLineNumber__c+100;  //lin.Apttus_Config2__PrimaryLineNumber__c + i +count;
							nLin.Apttus_Config2__PrimaryLineNumber__c = nLin.Apttus_Config2__PrimaryLineNumber__c + PrimaryLineReferenceCnt;
							////
							nLin.Apttus_Config2__ItemSequence__c = nLin.Apttus_Config2__ItemSequence__c + 1;
						}
						else
						{
							// Suresh Babu (30/11/2017) : REQ-125621 - SFDC Cart: Parent Line Reference Update\
							//nLin.Apttus_Config2__PrimaryLineNumber__c = nLin.Apttus_Config2__LineNumber__c + nLin.Apttus_Config2__ItemSequence__c + nLin.Apttus_Config2__PrimaryLineNumber__c+i+100;  //lin.Apttus_Config2__PrimaryLineNumber__c + i +count;
							nLin.Apttus_Config2__PrimaryLineNumber__c = nLin.Apttus_Config2__LineNumber__c + nLin.Apttus_Config2__ItemSequence__c + nLin.Apttus_Config2__PrimaryLineNumber__c + i + PrimaryLineReferenceCnt;
							////
							nLin.Apttus_Config2__ItemSequence__c = nLin.Apttus_Config2__LineNumber__c + nLin.Apttus_Config2__ItemSequence__c + i + 1;
						}

						if (isFirstYearSplit) {
							isFirstYearSplit = false;
							nLin.Include_ARR_Calculation__c = true;
							Lin.Include_ARR_Calculation__c = false;
						}
						else {
							nLin.Include_ARR_Calculation__c = false;
							Lin.Include_ARR_Calculation__c = false;
						}

						nLin.Apttus_Config2__LineType__c = 'Option';
						nLin.Apttus_Config2__ChargeType__c = 'Maintenance Fee';
						nLin.Duration_UOM__c = 'Year';
						nLin.Parent_Line_Number__c = lin.Name;
						/*
						  if(lin.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_QPConfig__PriceListId__r.Name.contains('MEP NA'))
						  {
						  nlin.Apttus_Config2__ListPrice__c = nlin.Actual_List_Price__c;
						  nlin.Apttus_Config2__NetPrice__c = nlin.Actual_List_Price__c * nlin.Apttus_Config2__Quantity__c;
						  nlin.Apttus_Config2__BaseExtendedPrice__c = nlin.Actual_List_Price__c * nlin.Apttus_Config2__Quantity__c;
						  nlin.Apttus_Config2__BasePrice__c = nlin.Actual_List_Price__c;
						  nlin.Apttus_Config2__BasePriceOverride__c = nlin.Actual_List_Price__c;
						  nlin.Apttus_Config2__ExtendedPrice__c = nlin.Actual_List_Price__c * nlin.Apttus_Config2__Quantity__c;
						  //nlin.MEP_NA_Multi_Year_Line__c = True;
						  }
						 */
						//nLin.Pre_billing__c = PreBillingMap.get(lin.Apttus_Config2__ProductId__r.Name+'false');
						TempId.add(linIdMap.get(lin.Apttus_Config2__ProductId__c).id);
						DurList.add(nLin);
					}
					count = count + 1;

				}
				updateLineItems.add(Lin);
			}

			system.debug('-----------------' + Durlist);
			system.debug('>>>updateLineItems>>>' + updateLineItems);
		}
		Integer TotalLoopSize = LineList.size();
		// This Block is to Split SAAS Items
		for (Apttus_Config2__LineItem__c lin : LineList) {
			if ((lin.Apttus_Config2__ProductId__r.Product_Category_Type__c == 'Rental' || lin.Apttus_Config2__ProductId__r.Product_Category_Type__c == 'SaaS' || lin.Apttus_Config2__ProductId__r.Product_Category_Type__c == 'Subscription' || lin.Apttus_Config2__ProductId__r.Product_Category_Type__c == 'Maintenance' || (lin.Apttus_Config2__ProductId__r.Contract_Item_Type_Code__c != Null && lin.Apttus_Config2__ProductId__r.Contract_Item_Type_Code__c == 'SERVICE' && lin.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_QPConfig__PriceListId__r.Name.Contains('MANHATTAN'))) && lin.Duration__c != Null && lin.Duration_UOM__c == 'Year')
			{

				Decimal TempYr = lin.Duration__c;
				lin.Duration__c = 1;
				lin.Duration_UOM__c = 'Year';
				lin.Duration_Sequence__c = 1;
				Boolean isFirstYearSplit = true;
				for (Integer i = 0; i<TempYr - 1; i++)
				{
					Apttus_Config2__LineItem__C nLin = new Apttus_Config2__LineItem__C();
					// nLi =  lineclonemap.get(String.valueof(lin.Apttus_Config2__ProductId__c)+String.valueof(lin.Apttus_Config2__OptionId__c)+string.valueof(lin.Apttus_Config2__LineNumber__c));
					nLin = Lin.clone(false, true, false, false);
					nLin.Duration__c = 1;
					if (i == 0 && nlin.Service_Start_Date__c != Null && nLin.Service_End_Date__c != Null) {

						nlin.Service_Start_Date__c = nLin.Service_End_Date__c.adddays(1);
						nlin.Service_End_Date__c = nLin.Service_End_Date__c.addyears(1);
					}
					else if (nlin.Service_Start_Date__c != Null && nLin.Service_End_Date__c != Null)
					{
						nlin.Service_Start_Date__c = nLin.Service_End_Date__c.addyears((i)) + 1;
						nlin.Service_End_Date__c = nLin.Service_End_Date__c.addyears((i + 1));
					}
					//Proration Logic
					if (nlin.service_Start_date__c != Null && nlin.Service_End_date__c != Null && nlin.Apttus_Config2__PriceListId__r.Division__c != Null && nlin.Apttus_Config2__PriceListId__r.Division__c != 'Plancal' && nlin.Must_Prorate__c == True) {
						Integer NoMonths = 0;
						Integer NoDays = 0;
						Date startDate = nlin.service_Start_date__c;
						Date endDate = nlin.Service_End_date__c;
						String Output = CalculateDuration.MonthsandDays(startDate, endDate);
						List<String> OutputList = Output.split(':');
						NoMonths = Integer.valueof(OutputList.get(0));
						NoDays = Integer.valueof(OutputList.get(1));

						Decimal Monthlyprice = 0;

						if(nLin.Type__c == 'Renewal' && NoMonths == 12){ // If Renewal line is splited
							if (nlin.EBS_Discount_Percentage__c != Null && nlin.Apttus_Config2__PriceUom__c == 'Year') {
								Monthlyprice = nlin.Apttus_Config2__ListPrice__c + (nlin.Apttus_Config2__ListPrice__c * (nlin.EBS_Discount_Percentage__c / 100));
								Monthlyprice = Monthlyprice / 12;
							}
							else if (nlin.Apttus_Config2__PriceUom__c == 'Year')
							MonthlyPrice = nlin.Apttus_Config2__ListPrice__c / 12;
							else if (nlin.Apttus_Config2__PriceUom__c == 'Month')
							MonthlyPrice = nlin.Apttus_Config2__ListPrice__c;
						}
						else{ // NEW BUY Lines
							if (nlin.EBS_Discount_Percentage__c != Null && nlin.Apttus_Config2__PriceUom__c == 'Year') {
								Monthlyprice = nlin.Actual_List_Price__c + (nlin.Actual_List_Price__c * (nlin.EBS_Discount_Percentage__c / 100));
								Monthlyprice = Monthlyprice / 12;
							}
							else if (nlin.Apttus_Config2__PriceUom__c == 'Year')
							MonthlyPrice = nlin.Actual_List_Price__c / 12;
							else if (nlin.Apttus_Config2__PriceUom__c == 'Month')
							MonthlyPrice = nlin.Actual_List_Price__c;
						}

						Decimal DailyPrice = Monthlyprice / 30;
						Decimal ListPriceMonthly = NoMonths * Monthlyprice;
						Decimal ListPriceDaily = NoDays * DailyPrice;
						Decimal ListPr = ListPriceMonthly + ListPriceDaily;


						system.debug('--------NoMonths -------' + NoMonths);
						system.debug('--------NoDays -------' + NoDays);
						system.debug('--------Monthlyprice -------' + Monthlyprice);
						system.debug('--------DailyPrice -------' + DailyPrice);
						system.debug('--------ListPriceMonthly -------' + ListPriceMonthly);
						system.debug('--------ListPriceDaily -------' + ListPriceDaily);
						system.debug('--------ListPr -------' + ListPr);

						nlin.Apttus_Config2__ListPrice__c = ListPr;
						nlin.Apttus_Config2__NetPrice__c = ListPr * nlin.Apttus_Config2__Quantity__c;
						nlin.Apttus_Config2__BaseExtendedPrice__c = ListPr * nlin.Apttus_Config2__Quantity__c;
						nlin.Apttus_Config2__BasePrice__c = ListPr;
						nlin.Apttus_Config2__BasePriceOverride__c = ListPr;
						nlin.Apttus_Config2__ExtendedPrice__c = ListPr * nlin.Apttus_Config2__Quantity__c;
					}
					enableAdvancedPricing = (nLin.Apttus_Config2__ProductId__c != null && nLin.Apttus_Config2__ProductId__r.ProductCode != null && mapPSDiscMatrix.containsKey(nLin.Apttus_Config2__ProductId__r.ProductCode) ? TRUE : FALSE);
					if (enableAdvancedPricing) {
						nLin.Apttus_Config2__NetAdjustmentPercent__c = 0.0000;
					}

					nlin.Apttus_Config2__ConfigurationId__c = config;
					nLin.Duration_Sequence__c = i + 2;
					nLin.Apttus_Config2__LineType__c = 'Product/Service';
					//nLin.Apttus_Config2__ChargeType__c ='Standard Price';
					nLin.Duration_UOM__c = 'Year';
					nLin.Parent_Line_Number__c = lin.Name;
					nLin.Apttus_Config2__PrimaryLineNumber__c = 500 + i + TotalLoopSize; //lin.Apttus_Config2__PrimaryLineNumber__c + 1;
					nLin.Apttus_Config2__ItemSequence__c = 1;
					nLin.Apttus_Config2__LineNumber__c = 500 + i + TotalLoopSize;
					nLin.Apttus_Config2__LineSequence__c = lin.Apttus_Config2__LineSequence__c;
					/*
					  if(lin.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_QPConfig__PriceListId__r.Name.contains('MEP NA'))
					  {
					  nlin.Apttus_Config2__ListPrice__c = nlin.Actual_List_Price__c;
					  nlin.Apttus_Config2__NetPrice__c = nlin.Actual_List_Price__c * nlin.Apttus_Config2__Quantity__c;
					  nlin.Apttus_Config2__BaseExtendedPrice__c = nlin.Actual_List_Price__c * nlin.Apttus_Config2__Quantity__c;
					  nlin.Apttus_Config2__BasePrice__c = nlin.Actual_List_Price__c;
					  nlin.Apttus_Config2__BasePriceOverride__c = nlin.Actual_List_Price__c;
					  nlin.Apttus_Config2__ExtendedPrice__c = nlin.Actual_List_Price__c * nlin.Apttus_Config2__Quantity__c;
					  //nlin.MEP_NA_Multi_Year_Line__c = True;
					  }
					 */
					// if(nLin.Type__c=='Renewal') nLin.Apttus_Config2__LineNumber__c = nLin.Apttus_Config2__ItemSequence__c+i+1;
					if (isFirstYearSplit) {
						isFirstYearSplit = false;
						nLin.Include_ARR_Calculation__c = true;
						Lin.Include_ARR_Calculation__c = false;
					}
					else {
						nLin.Include_ARR_Calculation__c = false;
						Lin.Include_ARR_Calculation__c = false;
					}

					DurList.add(nLin);
				}
				updateLineItems.add(Lin);

			}
			TotalLoopSize = TotalLoopSize + 50;
		}

		system.debug('Duration Number' + DurList.size());

		try {
			if (DurList.size()> 0 && updateLineItems.size()> 0) {
				Insert DurList;
				Update updateLineItems;
				if (enableAdvancedPricing) {
					for (Apttus_Proposal__Proposal__c qUpdate : QuoteList) {
						qUpdate.Advanced_Pricing_Completed__c = false;
					}
					update QuoteList;
				}
				system.debug('-----------------' + Durlist);
				Boolean hasPendingItems = false;
				// create the update price request
				request = new Apttus_CpqApi.CPQ.UpdatePriceRequestDO();
				// add request parameters
				request.CartId = config;
				// update price for the cart
				result = Apttus_CpqApi.CPQWebService.updatePriceForCart(request);
				hasPendingItems = result.IsPricePending;
				system.debug('-------hasPendingItems----------' + hasPendingItems);
			}
		}
		catch(Exception ex) {
			system.debug('exception =====' + ex);
			system.debug('exception =====' + ex.getStackTraceString());
			errorPopup = true;
			errorMsg = ex.getMessage();
			stopLoading = true;
			return null;

		}
		if (flowUI == 'Angular')
		retURL = '/apex/Apttus_Config2__Cart?id=' + config + '&configRequestId=' + tempcpqid + '&flow=' + flowUI;
		else if (flowUI == 'ngCPQ')
		retURL = '/apex/Apttus_Config2__Cart?id=' + config + '&configRequestId=' + tempcpqid + '&flow=' + flowUI + '&launchState=cart#/cartgrid';
		else
		retURL = '/apex/Apttus_Config2__CartDetailView?id=' + config + '&configRequestId=' + tempcpqid + '&flow=Default';
		if (flowUI == 'Angular')
		return new Pagereference('/apex/Apttus_Config2__Cart?id=' + config + '&configRequestId=' + tempcpqid + '&flow=' + flowUI);
		else if (flowUI == 'ngCPQ')
		return new Pagereference('/apex/Apttus_Config2__Cart?id=' + config + '&configRequestId=' + tempcpqid + '&flow=' + flowUI + '&launchState=cart#/cartgrid');
		else
		return new Pagereference('/apex/Apttus_Config2__CartDetailView?id=' + config + '&configRequestId=' + tempcpqid + '&flow=Default');

	}

	// invoke the following in a new transaction using action poller
	public void doUpdatePrice() {
		// update price for the cart
		result = Apttus_CpqApi.CPQWebService.updatePriceForCart(request);
		hasPendingItems = result.IsPricePending;
		// stop the action poller this.actionPollerActive = this.hasPendingItems;
	}


	public Pagereference cancelPage()
	{
		if (url.contains('CartDetailView') && flowUI == 'Angular')
		return new Pagereference('/apex/Apttus_Config2__Cart?id=' + config + '&configRequestId=' + tempcpqid + '&flow=' + flowUI);
		else if (url.contains('CartDetailView') && flowUI == 'Default')
		return new Pagereference('/apex/Apttus_Config2__CartDetailView?id=' + config + '&configRequestId=' + tempcpqid + '&flow=Default');
		else if (url.contains('CartDetailView') && flowUI == 'ngCPQ')
		return new Pagereference('/apex/Apttus_Config2__Cart?id=' + config + '&configRequestId=' + tempcpqid + '&flow=' + flowUI + '&launchState=cart#/cartgrid');

		else if (url.contains('ProductAttributeDetail') && flowUI == 'Angular')
		return new Pagereference('/apex/Apttus_Config2__Cart?callerPage=ViewConfig&configRequestId=' + tempcpqid + '&id=' + lineitemid + '&flow=' + flowUI + '&launchState=attributes');
		else if (url.contains('ProductAttributeDetail') && flowUI == 'Default')
		return new Pagereference('/apex/ProductAttributeDetailCustom?callerPage=ViewConfig&configRequestId=' + tempcpqid + '&id=' + lineitemid + '&flow=Default&launchState=attributes');

		else if (url.contains('Bundle') && flowUI == 'Angular')
		return new Pagereference('/apex/Apttus_Config2__Cart?id=' + config + '&configRequestId=' + tempcpqid + '&launchState=catalog' + '&flow=' + flowUI);
		else if (url.contains('Bundle') && flowUI == 'Default')
		return new Pagereference('/apex/Apttus_Config2__SelectConfigProductsFilterView?id=' + config + '&configRequestId=' + tempcpqid + '&launchState=catalog');

		else if (flowUI == 'Angular')
		return new Pagereference('/apex/Apttus_Config2__Cart?id=' + config + '&configRequestId=' + tempcpqid + '&launchState=catalog' + '&flow=' + flowUI);
		else
		return new Pagereference('/apex/Apttus_Config2__SelectConfigProductsFilterView?id=' + config + '&configRequestId=' + tempcpqid + '&launchState=catalog');

	}

	public Pagereference cancelPagecart()
	{
		if (flowUI == 'Angular')
		return new Pagereference('/apex/Apttus_Config2__Cart?id=' + config + '&configRequestId=' + tempcpqid + '&flow=' + flowUI);
		else
		return new Pagereference('/apex/Apttus_Config2__CartDetailView?id=' + config + '&configRequestId=' + tempcpqid + '&flow=Default');

	}
	/*
	 
	 
	 * Method name  : UpdateTax
	 * Description  : gets the quote details from Oracle EBS by invoking the webservcie class and updates the tax in salesforce
	 * Return Type  : Pagereference
	 * Parameter    : isOrder
	 */

	public void UpdateTax(string isOrder) {
		Try {
			/* if(partyID=='' || partyID==null)
			  throw new customexception('Accounts Enterprise Master ID is blank. Please provide Enterprise Master ID and try again.');
			 
			  if(shipToEntMastID=='' || shipToEntMastID==null)
			  throw new customexception('Ship To Enterprise Master ID is blank.Please provide Enterprise Master ID and try again.'); */
			Integer Subscription = 0;
			for (Apttus_Config2__LineItem__c quoLine : QuoteLineList) {
				if ((quoLine.Apttus_Config2__ProductId__r.ICC_Type__c != Null && (quoLine.Apttus_Config2__ProductId__r.ICC_Type__c == 'Scheduled Publications' || quoLine.Apttus_Config2__ProductId__r.ICC_Type__c == 'Unscheduled Publications')) && quoLine.Apttus_Config2__ProductId__r.Business_Area__c != Null && quoLine.Apttus_Config2__ProductId__r.Business_Area__c == 'TRADE SERVICE')
				{
					Subscription = Subscription + 1;
				}
			}

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
			if (Subscription > 0) {
				hitem.BILLING_FREQUENCY = 'Month';
			}
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
			xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINE_TBL_TYPE tblt = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINE_TBL_TYPE();

			//xmlnsOracleComAppsOntSoaproviderPl_v10.InputParameters_element COMPOSITEId = xmlnsOracleComAppsOntSoaproviderPl_v10.InputParameters_element();

			//Assigning values for Quote/Proposal Line Item (Footer) to invoke the Oracle EBS webserivce
			xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINE_REC_TYPE[] rect = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINE_REC_TYPE[] { };
			system.debug('------' + QuoteLineList);
			for (Apttus_Config2__LineItem__c quoLine : QuoteLineList) {
				// if(quoLine.Type__c!='Renewal'){
				QtyMap.Put(quoLine.Name, quoLine.Apttus_Config2__Quantity__c);
				xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINE_REC_TYPE LineItem = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINE_REC_TYPE();
				system.debug('------' + quoLine);
				LineItem.ORIG_SYS_LINE_REF = quoLine.Name;
				LineItem.PRICING_QUANTITY = quoLine.Apttus_Config2__Quantity__c;
				system.debug('------' + quoLine.Apttus_Config2__Quantity__c);
				LineItem.UNIT_LIST_PRICE = (quoLine.Actual_List_Price__c != null ? quoLine.Actual_List_Price__c : quoLine.Apttus_Config2__ListPrice__c);
				system.debug('------' + quoLine.Apttus_Config2__NetPrice__c);
				LineItem.UNIT_SELLING_PRICE = (quoLine.Apttus_Config2__NetPrice__c != null && quoLine.Apttus_Config2__Quantity__c != 0 ? quoLine.Apttus_Config2__NetPrice__c / quoLine.Apttus_Config2__Quantity__c : 0);
				system.debug('------' + quoLine.Apttus_Config2__Quantity__c);
				LineItem.ORDERED_QUANTITY = quoLine.Apttus_Config2__Quantity__c;
				LineItem.SERVICE_REF_INSTANCE_NUM = quoLine.Asset_Oracle_ID__c;
				// Workaround Code to accept negative Quantity
				system.debug('------' + quoLine.Apttus_Config2__Quantity__c);
				if (quoLine.Apttus_Config2__Quantity__c< 0)
				{
					LineItem.PRICING_QUANTITY = - 1 * quoLine.Apttus_Config2__Quantity__c;
					LineItem.UNIT_LIST_PRICE = (quoLine.Actual_List_Price__c != null ? quoLine.Actual_List_Price__c : quoLine.Apttus_Config2__ListPrice__c);
					LineItem.UNIT_SELLING_PRICE = - 1 * (quoLine.Apttus_Config2__NetPrice__c / quoLine.Apttus_Config2__Quantity__c);
					LineItem.ORDERED_QUANTITY = - 1 * quoLine.Apttus_Config2__Quantity__c;
					LineItem.attribute1 = quoLine.Asset_Oracle_ID__c;
					LineItem.SERVICE_REF_INSTANCE_NUM = Null;
					if (quoLine.Apttus_Config2__ListPrice__c == 0 && quoLine.Apttus_Config2__AssetId__c != null) LineItem.MANUAL_DISCOUNT_PERCENT = 100.00;
					// LineItem.MANUAL_DISCOUNT_PERCENT = (LineItem.UNIT_LIST_PRICE!=0 ? ((quoLine.Apttus_Config2__NetPrice__c /quoLine.Apttus_Config2__Quantity__c)/LineItem.UNIT_LIST_PRICE)*100 : 0);

				}
				else
				{
					system.debug('--------------' + quoLine.Apttus_Config2__NetAdjustmentPercent__c);
					LineItem.MANUAL_DISCOUNT_PERCENT = (quoLine.New_Net_Discount__c != Null ? quoLine.New_Net_Discount__c : 0);
				}
				system.debug('------------------------------' + quoLine.Apttus_Config2__PriceUom__c);
				LineItem.ORDERED_QUANTITY_UOM = quoLine.Apttus_Config2__PriceUom__c;
				LineItem.REQUEST_DATE = system.now();
				//  LineItem.SERVICE_DURATION =quoLine.Duration__c;
				LineItem.SERVICE_PERIOD = (quoLine.Apttus_Config2__ChargeType__c == 'Maintenance Fee') ? 'Once' : quoLine.Apttus_Config2__SellingFrequency__c;
				LineItem.USER_ITEM_DESCRIPTION = quoLine.Apttus_Config2__ProductId__r.Description;

				LineItem.DURATION = quoLine.Duration__c;
				LineItem.DURATION_UOM = quoLine.Duration_UOM__c;
				LineItem.USER_ITEM_DESCRIPTION = quoLine.Line_Item_Description__c;
				LineItem.CUST_PO_NUMBER = quoLine.Customer_PO__c;
				LineItem.PRE_BILLING = ((quoLine.Pre_Billing__c) == True ? 'Y' : 'N');
				LineItem.DEFER_BILLING = ((quoLine.Defer_Billing__c) == True ? 'Y' : 'N');
				LineItem.DURATION_SEQ = quoLine.Duration_Sequence__c;
				LineItem.SERVICE_START_DATE = quoLine.Service_Start_Date__c;
				LineItem.SERVICE_END_DATE = quoLine.Service_End_Date__c;

				/*  if((quoLine.Apttus_Config2__ProductId__r.ICC_Type__c != Null && (quoLine.Apttus_Config2__ProductId__r.ICC_Type__c=='Scheduled Publications' || quoLine.Apttus_Config2__ProductId__r.ICC_Type__c=='Unscheduled Publications')) && quoLine.Apttus_Config2__ProductId__r.Business_Area__c != Null && quoLine.Apttus_Config2__ProductId__r.Business_Area__c=='TRADE SERVICE')
				  {
				  LineItem.SERVICE_START_DATE = system.today();
				  LineItem.SERVICE_END_DATE = system.today().addyears(1) -1;
				  }*/

				if (quoLine.Bill_to_Address__r.FCH_Party_Site_ID__c != null) {
					LineItem.FCH_BILL_SITE_ID = quoLine.Bill_to_Address__r.FCH_Party_Site_ID__c;
				}
				if (quoLine.Ship_to_Address1__r.FCH_Party_Site_ID__c != null) {
					LineItem.FCH_SHIP_SITE_ID = quoLine.Ship_to_Address1__r.FCH_Party_Site_ID__c;
				}
				LineItem.SCHEDULE_SHIP_DATE = (isorder == '1') ? quoLine.Schedule_Ship_Date__c : null;

				if (prodIDCodeMap.get(quoLine.Apttus_Config2__OptionId__c) != null) {

					LineItem.SERVICE_REFERENCE_LINE = mapLineitemIdwoOpt.get(quoLine.Apttus_Config2__ProductId__r.Name + quoLine.Apttus_Config2__LineNumber__c);
					LineItem.ORDERED_ITEM = prodIDCodeMap.get(quoLine.Apttus_Config2__OptionId__c);

				} else {
					LineItem.ORDERED_ITEM = (quoLine.Apttus_Config2__ProductId__r.SKIP_Advanced_Pricing__c == true ? quoLine.Apttus_Config2__OptionId__r.ProductCode : quoLine.Apttus_Config2__ProductId__r.ProductCode);
				}
				if (LineItem.ORDERED_ITEM == null || LineItem.ORDERED_ITEM == '')
				throw new customexception('Mandatory field Product not provided.');

				if (quoLine.Apttus_Config2__ProductId__r.Product_Category_Type__c == 'Rental' || quoLine.Apttus_Config2__ProductId__r.Product_Category_Type__c == 'SaaS' || quoLine.Apttus_Config2__ProductId__r.Product_Category_Type__c == 'Subscription' || quoLine.Apttus_Config2__ProductId__r.Product_Category_Type__c == 'Maintenance')
				LineItem.SAAS_REFERENCE_LINE = quoLine.Parent_Line_Number__c;

				system.debug('>>>>>LineItem.ORDERED_QUANTITY_UOM>>>>>>' + LineItem.ORDERED_QUANTITY_UOM);

				system.debug('>>>>>LiLineItem.DURATION_UOM >>>>>>' + LineItem.DURATION_UOM);
				system.debug('>>>>>quoLine>>>>>>' + quoLine.Name);

				rect.add(LineItem);

			}
			system.debug('------' + rect);


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

			xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_COL_EXTN_REC_TYPE Header5 = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_COL_EXTN_REC_TYPE();
			Header5.CONTEXT_NAME = 'QH';
			Header5.CONTEXT_VALUE = QuoteName;
			Header5.COL_VALUE = renewalBillTo;
			Header5.COL_NAME = 'RENEWAL_BILL_TO';
			LineInp.add(Header5);

			Map<String, ProjectSight_Discounting_Matrix__mdt> mapPSDiscMatrix = new Map<String, ProjectSight_Discounting_Matrix__mdt> ();
			List<ProjectSight_Discounting_Matrix__mdt> lstProjectSightDicMatrix = [SELECT MasterLabel, DeveloperName, Item_Code__c, Object_API_Name__c, Matrix_Based_on_Field_API__c FROM ProjectSight_Discounting_Matrix__mdt];
			for (ProjectSight_Discounting_Matrix__mdt pDM : lstProjectSightDicMatrix) {
				mapPSDiscMatrix.put(pDM.Item_Code__c, pDM);
			}
			//Building Line Details
			for (Apttus_Config2__LineItem__c quoLine : QuoteLineList) {
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

				if ((quoLine.Apttus_Config2__ProductId__r.ICC_Type__c != Null && (quoLine.Apttus_Config2__ProductId__r.ICC_Type__c == 'Scheduled Publications' || quoLine.Apttus_Config2__ProductId__r.ICC_Type__c == 'Unscheduled Publications')) && quoLine.Apttus_Config2__ProductId__r.Business_Area__c != Null && quoLine.Apttus_Config2__ProductId__r.Business_Area__c == 'TRADE SERVICE')
				{
					xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_COL_EXTN_REC_TYPE LineItem2 = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_COL_EXTN_REC_TYPE();
					LineItem2.CONTEXT_NAME = 'QL';
					LineItem2.CONTEXT_VALUE = (quoLine.Name);
					LineItem2.COL_VALUE = AdditionalLicense;
					LineItem2.COL_NAME = 'SUBSCR_ADD_SHIP_SCH';
					LineInp.add(LineItem2);
				}

				system.debug('>>>>>InsideLoop>>>>' + SequenceChanged);
				if (SequenceChanged == True)
				{
					xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_COL_EXTN_REC_TYPE LineItem3 = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_COL_EXTN_REC_TYPE();
					LineItem3.CONTEXT_NAME = 'QL';
					LineItem3.CONTEXT_VALUE = (quoLine.Name);
					LineItem3.COL_VALUE = String.valueof((quoLine.Apttus_Config2__LineSequence__c));
					LineItem3.COL_NAME = 'SFDC_LINE_SEQ';
					LineInp.add(LineItem3);
				}

				// Discount matrix depends on Company Annual Revenue
				if (quoLine.Ship_to_Address1__r.Account__r.AnnualRevenue != null && mapPSDiscMatrix.containsKey(quoLine.Product_Code__c) && mapPSDiscMatrix.get(quoLine.Product_Code__c) != null && mapPSDiscMatrix.get(quoLine.Product_Code__c).Matrix_Based_on_Field_API__c == 'AnnualRevenue') {
					xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_COL_EXTN_REC_TYPE LineItem4 = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_COL_EXTN_REC_TYPE();
					LineItem4.CONTEXT_NAME = 'QL';
					LineItem4.CONTEXT_VALUE = (quoLine.Name);
					LineItem4.COL_VALUE = String.valueof((quoLine.Ship_to_Address1__r.Account__r.AnnualRevenue));
					LineItem4.COL_NAME = 'SFDC_COMPANY_REVENUE';
					LineInp.add(LineItem4);
				}
				// Discount matrix depends on Project Construction Value
				if (quoLine.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Project_Construction_Value__c != null && mapPSDiscMatrix.containsKey(quoLine.Product_Code__c) && mapPSDiscMatrix.get(quoLine.Product_Code__c) != null && mapPSDiscMatrix.get(quoLine.Product_Code__c).Matrix_Based_on_Field_API__c == 'Project_Construction_Value__c') {
					xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_COL_EXTN_REC_TYPE LineItem6 = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_COL_EXTN_REC_TYPE();
					LineItem6.CONTEXT_NAME = 'QL';
					LineItem6.CONTEXT_VALUE = (quoLine.Name);
					LineItem6.COL_VALUE = String.valueof((quoLine.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Project_Construction_Value__c));
					LineItem6.COL_NAME = 'SFDC_PROJECT_VALUE';
					LineInp.add(LineItem6);
				}
				// APP-6137 : Surcharge information for GCCM Quotes
				if (quoLine.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Surcharge_Percentage__c != null && quoLine.Apttus_Config2__PriceListId__r.Division__c == 'GCCM') {
					xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_COL_EXTN_REC_TYPE LineItem7 = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_COL_EXTN_REC_TYPE();
					LineItem7.CONTEXT_NAME = 'QL';
					LineItem7.CONTEXT_VALUE = (quoLine.Name);
					if (quoLine.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Surcharge_Percentage__c == '3%') {
						LineItem7.COL_VALUE = 'GCSURCHARGE03';
					}
					if (quoLine.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Surcharge_Percentage__c == '5%') {
						LineItem7.COL_VALUE = 'GCSURCHARGE05';
					}
					if (quoLine.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Surcharge_Percentage__c == '7%') {
						LineItem7.COL_VALUE = 'GCSURCHARGE07';
					}
					if (quoLine.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Surcharge_Percentage__c == '10%') {
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
				op = o;
			}

			Map<String, String> LineOutMap = new Map<String, String> ();
			Map<String, xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINEOUT_REC_TYPE> EbsResponse = new Map<String, xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINEOUT_REC_TYPE> ();
			xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINEOUT_TBL_TYPE temp = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINEOUT_TBL_TYPE();
			xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINEOUT_REC_TYPE[] lineout = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINEOUT_REC_TYPE[] { };

			temp = op.X_SFDC_LINEOUT_TBL;
			if (temp != Null) {
				lineout = temp.X_SFDC_LINEOUT_TBL_ITEM;

				/* system.debug('-------------------temp----------'+temp.X_SFDC_LINEOUT_TBL_ITEM);
				  system.debug('-------------------lineout----------'+lineout);*/
				String ConfigID;
				if (lineout != Null) {
					for (xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINEOUT_REC_TYPE intr : lineout)
					{
						// xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINEOUT_REC_TYPE lineItem = new xmlnsOracleComAppsOntSoaproviderPl_v10.APPS_TNVCUST_SFDC_LINEOUT_REC_TYPE();
						if (Label.Enable_Debug == 'Yes') { system.debug('EBS Output Map----------' + intr.PROPOSAL_LINE_ID);
							system.debug('EBS Output Map----------' + intr.SELLING_PRICE_EBS_CALCULATED); }
						if (intr.PROPOSAL_LINE_ID != Null && intr.SELLING_PRICE_EBS_CALCULATED != Null)
						LineOutMap.put(intr.PROPOSAL_LINE_ID, intr.SELLING_PRICE_EBS_CALCULATED);
						EbsResponse.put(intr.PROPOSAL_LINE_ID, intr);
					}
					if (Label.Enable_Debug == 'Yes') { system.debug('EBS Output Map----------' + LineOutMap);
						system.debug('EBS Response Map----------' + EbsResponse); }
					List<Apttus_Config2__LineItem__c> UpdateLineList = new List<Apttus_Config2__LineItem__c> ();
					List<Apttus_Config2__LineItem__c> LineList = new List<Apttus_Config2__LineItem__c> ();
					LineList = [SELECT Id, Name, Apttus_Config2__LineType__c, New_Net_Discount__c, Apttus_Config2__BaseExtendedPrice__c, Apttus_Config2__ListPrice__c, Apttus_Config2__Quantity__c, Apttus_Config2__NetPrice__c, Apttus_Config2__ExtendedPrice__c FROM Apttus_Config2__LineItem__c WHERE Name IN :LineOutMap.keyset()];
					for (Apttus_Config2__LineItem__c li : LineList)
					{
						if (Decimal.valueof(LineOutMap.get(Li.Name))> = 0 && (Li.New_Net_Discount__c == Null || (Li.New_Net_Discount__c != Null && Li.New_Net_Discount__c == 0))) {

							Li.Apttus_Config2__ListPrice__c = Decimal.valueof(LineOutMap.get(Li.Name));
							li.Apttus_Config2__NetPrice__c = Decimal.valueof(LineOutMap.get(Li.Name)) * QtyMap.get(Li.Name);
							li.Apttus_Config2__ExtendedPrice__c = Decimal.valueof(LineOutMap.get(Li.Name)) * QtyMap.get(Li.Name);
							Li.Apttus_Config2__BaseExtendedPrice__c = Decimal.valueof(LineOutMap.get(Li.Name)) * QtyMap.get(Li.Name);
							Li.Apttus_Config2__BasePrice__c = Decimal.valueof(LineOutMap.get(Li.Name));
							Li.Apttus_Config2__BasePriceOverride__c = Decimal.valueof(LineOutMap.get(Li.Name));
						}
						if (Label.Enable_Debug == 'Yes') { system.debug('>>>>>>>>>>>>>li.Apttus_Config2__NetPrice__c>>>>>>>>>>>>>>>' + li.Apttus_Config2__NetPrice__c);
							system.debug('>>>>>>>>>>>>>Apttus_Config2__ExtendedPrice__c >>>>>>>>>>>>>>>' + li.Apttus_Config2__ExtendedPrice__c);
							system.debug('>>>>>>>>>>>>>Qty>>>>>>>>>>>>>>>' + QtyMap.get(Li.Name));
							system.debug('>>>>>>>>>>>>>Service_Start_Date__c>>>>>>>>>>>>>>>' + EbsResponse.get(li.Name).SERV_START_DATE);
							system.debug('>>>>>>>>>>>>>Service_End_Date__c>>>>>>>>>>>>>>>' + EbsResponse.get(li.Name).SERV_END_DATE); }
						li.Service_Start_Date__c = Date.valueof(EbsResponse.get(li.Name).SERV_START_DATE);
						li.Service_End_Date__c = date.valueof(EbsResponse.get(li.Name).SERV_END_DATE);
						if (EbsResponse.get(li.Name).DISCOUNT_EBS_CALCULATED != Null)
						li.EBS_Discount_Percentage__c = decimal.valueof(EbsResponse.get(li.Name).DISCOUNT_EBS_CALCULATED);
						if (li.Apttus_Config2__LineType__c != 'Option' && li.Apttus_Config2__IsOptionRollupLine__c == FALSE) li.Apttus_Config2__IsCustomPricing__c = True;


						system.debug('>>>>>>>>>>>>>li>>>>>>>>>>>>>>>' + li);
						UpdateLineList.add(Li);
					}

					if (UpdateLineList.size() > 0) {
						LineItemHelper_v1.launchControl.put('configLineItem', 1);
						update UpdateLineList;

						/* Boolean hasPendingItems = false;
						  // create the update price request
						  request = new Apttus_CpqApi.CPQ.UpdatePriceRequestDO();
						  // add request parameters
						  request.CartId = config;
						  // update price for the cart
						  result = Apttus_CpqApi.CPQWebService.updatePriceForCart(request);
						  hasPendingItems = result.IsPricePending;
						  system.debug('-------hasPendingItems----------'+hasPendingItems);*/
					}
				}
			}
			system.debug('-------------------lineout ----------' + lineout);
			system.debug('-------------------LineOutMap----------' + LineOutMap);

			system.debug('op==>' + op);
			// QuoteList = [Select Name,Apttus_Proposal__Account__c,Advanced_Pricing_Completed__c,Apttus_QPConfig__PriceListId__r.Name,Apttus_QPConfig__PriceListId__r.Apttus_Config2__Description__c,Shipping_Instructions__c FROM Apttus_Proposal__Proposal__c  WHERE Id  =: quoteId];
			Apttus_Proposal__Proposal__c appQ = [SELECT Tax__c, Bill_to_Address_Changed__c, CREDIT_LIMIT_AVAILABLE__C, CREDIT_EXISTING_EXPOSURE__C, CREDIT_CALCULATED_EXPOSURE__c, CREDIT_TOTAL_EXPOSURE__c, Oracle_Error__c, Shipping_Instructions__c, Oracle_Account_Number__c FROM Apttus_Proposal__Proposal__c WHERE Id = :quoteId];

			appQ.Oracle_Error__c = '';
			appQ.Oracle_Account_Number__c = op.X_EBS_ACCOUNT_NUMBER;
			update appQ;
			if (op.X_STATUS == 'ERROR') {
				if (!isRenewal) {
					appQ.addError(op.X_MESSAGE);
				}
				appQ.Oracle_Error__c = op.X_MESSAGE;
				update appQ;
				errorPopup = true;
				errorMsg = op.X_MESSAGE;
				stopLoading = true;
				// return Null;

			} else {
				/*  if(op.X_TAX_AMOUNT!=null){
				  appQ.Tax__c = op.X_TAX_AMOUNT;
				  }*/
				if (op.X_STATUS == 'SUCCESS') {
					appQ.Advanced_Pricing_Completed__c = True;
					appQ.Bill_to_Address_Changed__c = False;

					system.debug(' Advance Pricing completed :::::::::::::::: ' + appQ.Name + ' :::::::: ' + isRenewal);
					// If Advanced pricing is completed, Finalize the cart for Renewal 2.0 Quotes
					if (isRenewal) {
						system.debug(' Finalize starts :::::::::::::::: ' + appQ.Name);
						Apttus_CpqApi.CPQ.FinalizeCartRequestDO finalizeCartREQ = new Apttus_CpqApi.CPQ.FinalizeCartRequestDO();
						finalizeCartREQ.CartId = config;
						Apttus_CpqApi.CPQ.FinalizeCartResponseDO finalizeCartRESP = Apttus_CpqApi.CPQWebService.finalizeCart(finalizeCartREQ); // Finalize the Cart
					}
				}
				appQ.Oracle_Error__c = op.X_STATUS;
			}
			update appQ;
		}
		catch(Exception ex) {
			system.debug('exception =====' + ex);
			system.debug('exception =====' + ex.getStackTraceString());
			errorPopup = true;
			errorMsg = ex.getMessage();
			stopLoading = true;
			String ExString = ex.getmessage();
			if (ExString.contains('Read timed out')) {
				ex.setMessage(Label.Read_Timed_Out_Message);
				errorMsg = Label.Read_Timed_Out_Message;
				// return Null;
			}

		}
		if (flowUI == 'Angular')
		retURL = '/apex/Custom_Reprice2?id=' + config + '&configRequestId=' + tempcpqid + '&flow=' + flowUI;
		else if (flowUI == 'ngCPQ')
		retURL = '/apex/Custom_Reprice2?id=' + config + '&configRequestId=' + tempcpqid + '&flow=' + flowUI + '&launchState=cart#/cartgrid';
		else
		retURL = '/apex/Custom_Reprice2?id=' + config + '&configRequestId=' + tempcpqid + '&flow=Default';

		// return new Pagereference('/apex/Apttus_Config2__CartDetailView?id='+config+'&configRequestId='+tempcpqid+'&flow=Default');
		// retun null;

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
	public PageReference closePopup() {
		displayPopup = false;
		if (flowUI == 'Angular')
		return new Pagereference('/apex/Apttus_Config2__Cart?id=' + config + '&configRequestId=' + tempcpqid + '&flow=' + flowUI);
		else if (flowUI == 'ngCPQ')
		return new Pagereference('/apex/Apttus_Config2__Cart?id=' + config + '&configRequestId=' + tempcpqid + '&flow=' + flowUI + '&launchState=cart#/cartgrid');
		else
		return new Pagereference('/apex/Apttus_Config2__CartDetailView?id=' + config + '&configRequestId=' + tempcpqid + '&flow=Default');

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