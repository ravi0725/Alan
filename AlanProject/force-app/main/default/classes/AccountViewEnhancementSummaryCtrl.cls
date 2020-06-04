/*****************************************************************************************
  Name        : AccountViewEnhancementSummaryCtrl
  Desc        : Entitlement summary calculation on Acconnt level
  ---------------------------------------------------------------------------
  Developer              Date            Description
  ---------------------------------------------------------------------------
  Prince Leo             25/05/2016        Created
  Suresh Babu Murugan    11/10/2019        MODIFIED: for ARR calculation
 ******************************************************************************************/
public class AccountViewEnhancementSummaryCtrl {

	public Account acc { get; set; }
	public Map<String, SummaryWrapper> EnhancementMap { get; set; }
	public List<SummaryWrapper> EnhancementList {
		get { return EnhancementMap.values(); }
		set;
	}
	public User runningUser { get; set; }
	public Boolean is2ndCurrencyNeed { get; set; }
	public Decimal dTotalCost { get; set; }
	public String totalConvertedAmount {
		get {
			if (is2ndCurrencyNeed) {
				return acc.CurrencyIsoCode + ' ' + formatCurrency(dTotalCost.setScale(2, RoundingMode.HALF_UP)) + ' (' + String.valueOf(UserInfo.getDefaultCurrency()) + ' ' + formatCurrency(getTargetCurrencyValue(UserInfo.getDefaultCurrency(), acc.CurrencyIsoCode, dTotalCost).setScale(2, RoundingMode.HALF_UP)) + ')';
			}
			else {
				return acc.CurrencyIsoCode + ' ' + formatCurrency(dTotalCost.setScale(2, RoundingMode.HALF_UP));
			}
		}
		set;
	}

	public class SummaryWrapper {
		public Decimal corporatePrice { get; set; }
		public Decimal UserCurrencyPrice { get; set; }
		public Decimal AccountCurrencyPrice { get; set; }
		public Double AccountCurrencyPriceDouble { get { return(double) AccountCurrencyPrice.setScale(2, RoundingMode.HALF_UP); } set; }

		//
		public Account objDummyAccount {
			get {
				objDummyAccount.AnnualRevenue = (double) AccountCurrencyPrice.setScale(2, RoundingMode.HALF_UP);
				return objDummyAccount;
			}
			set; } //This dummy account record will be used to bind Entitlement Amount field on Vf page. We will be using AnnualRevenue field as it is Std. Currency type of field on Account object. If currency field is rendered using outputField tag, default currency formating for that user will be used by Vf page.

		public Double corporatePriceDouble { get { return(double) corporatePrice.setScale(2, RoundingMode.HALF_UP); } set; }
		public Double UserCurrencyPriceDouble { get { return(double) UserCurrencyPrice.setScale(2, RoundingMode.HALF_UP); } set; }
		public String prodGroup { get; set; }
		public String prodGroupAmount { get; set; }
		public Integer noOfSeats { get; set; }
		public Set<String> typeSet { get; set; }
		public String AccountCurrencyPrice_Display { get; set; }
		public String type {
			get {
				String strtemp = '';
				for (String sx : typeSet) {
					strtemp += sx + ';';
				}
				strtemp = strtemp.substringBeforeLast(';');
				return strtemp;
			}
			set;
		}
		public SummaryWrapper(String strAccountCurrencyCode) {
			corporatePrice = 0;
			UserCurrencyPrice = 0;
			AccountCurrencyPrice = 0;
			prodGroup = '';
			prodGroupAmount = '';
			noOfSeats = 0;
			type = '';
			typeSet = new set<string> ();
			AccountCurrencyPrice_Display = '';
			objDummyAccount = new Account(); //initializing dummy Account
			if (strAccountCurrencyCode != null)
			objDummyAccount.CurrencyIsoCode = strAccountCurrencyCode;
		}
	}
	public Map<String, Decimal> conversion_rates = new Map<String, Decimal> ();

	public Decimal getCorporateCurrencyValue(string fromCurrency, Decimal value) {
		return getTargetCurrencyValue('USD', fromCurrency, value);
	}

	public Decimal getTargetCurrencyValue(string toCurrency, string fromCurrency, Decimal value) {
		Decimal returnValue = 0;
		Decimal rate = conversion_rates.get(fromCurrency);
		returnValue = (value != null ? value : 0) / (rate != null ? rate : 1);
		rate = conversion_rates.get(toCurrency);
		returnValue = returnValue * (rate != null ? rate : 0);
		return returnValue;
	}

	public AccountViewEnhancementSummaryCtrl(ApexPages.StandardController con) {
		dTotalCost = 0.0;
		for (DatedConversionRate curr :[SELECT Id, IsoCode, ConversionRate, StartDate, NextStartDate FROM DatedConversionRate WHERE NextStartDate > TODAY AND StartDate <= TODAY ORDER BY IsoCode DESC]) {
			conversion_rates.put(curr.IsoCode, curr.ConversionRate);
		}
		/*
		  for (CurrencyType curr :[SELECT IsoCode, ConversionRate FROM CurrencyType]) {
		  conversion_rates.put(curr.IsoCode, curr.ConversionRate);
		  }
		 */
		acc = (Account) con.getRecord();
		List<Account> accList = [SELECT Id, CurrencyIsoCode FROM Account WHERE Id = :acc.Id];
		if (accList.size() == 1) {
			acc = accList[0];
		} else {
			acc = new Account();
		}
		EnhancementMap = new Map<String, SummaryWrapper> ();
		List<Entitlement> lstEntitlements = [SELECT
		                                     Name, AccountId, Id, Status, Entitlement_Product_Sub_Group__c, Type, Type_MEP__c, EntitlementActive__c, Asset_Product_Group__c,
		                                     Asset_Product_Sub_Group__c, supported_Product_Family_Roll_up__c, Annual_Cost__c, CurrencyIsoCode, StartDate, EndDate,
		                                     Asset_Oracle_Number__c, Asset_Sequence__c, Contract_Number__c, AssetId
		                                     FROM
		                                     Entitlement
		                                     WHERE
		                                     accountID = :acc.Id AND Status = 'Active' AND StartDate != null AND EndDate != null AND Annual_Cost__c != null LIMIT 49999];
		Set<Id> setAssetIDs = new Set<Id> ();
		runningUser = [SELECT Id, DefaultCurrencyIsoCode, CurrencyIsoCode FROM User WHERE Id = :UserInfo.getUserId()];
		is2ndCurrencyNeed = ((runningUser.DefaultCurrencyIsoCode == acc.CurrencyIsoCode) ? false : true);

		for (Entitlement ex : lstEntitlements) {
			Decimal cAnnualCost = calculateARR(ex.StartDate, ex.EndDate, ex.Annual_Cost__c, ex.Asset_Oracle_Number__c, ex.Status);
			if (String.isNotBlank(ex.supported_Product_Family_Roll_up__c)) {
				groupingLogic(ex.supported_Product_Family_Roll_up__c, acc.CurrencyIsoCode, ex.CurrencyIsoCode, ex.Annual_Cost__c, ex.Type_MEP__c);
			}
			else if (String.isNotBlank(ex.Entitlement_Product_Sub_Group__c)) {
				groupingLogic(ex.Entitlement_Product_Sub_Group__c, acc.CurrencyIsoCode, ex.CurrencyIsoCode, ex.Annual_Cost__c, ex.Type_MEP__c);
			}
			if (ex.AssetId != null) setAssetIDs.add(ex.AssetId);
		}

		for (SummaryWrapper sumWrap : EnhancementMap.values()) {
			if (is2ndCurrencyNeed) {
				sumWrap.AccountCurrencyPrice_Display = acc.CurrencyIsoCode + ' ' + formatCurrency(sumWrap.AccountCurrencyPrice.setScale(2, RoundingMode.HALF_UP)) + ' (' + String.valueOf(UserInfo.getDefaultCurrency()) + ' ' + formatCurrency(getTargetCurrencyValue(UserInfo.getDefaultCurrency(), sumWrap.objDummyAccount.CurrencyIsoCode, sumWrap.AccountCurrencyPrice).setScale(2, RoundingMode.HALF_UP)) + ')';
			}
			else {
				sumWrap.AccountCurrencyPrice_Display = acc.CurrencyIsoCode + ' ' + formatCurrency(sumWrap.AccountCurrencyPrice.setScale(2, RoundingMode.HALF_UP));
			}
		}

		for (Asset asRec :[SELECT Id, Product2.Seat_Count__c, Asset.Product2.sub_type__c, Quantity FROM Asset WHERE Id IN :setAssetIDs]) {
			if (EnhancementMap.containsKey(asRec.Product2.sub_type__c)) {
				SummaryWrapper swtemp = new SummaryWrapper(acc.CurrencyIsoCode);
				swtemp = EnhancementMap.get(asRec.Product2.sub_type__c);
				if (asRec.Product2.Seat_Count__c != null && asRec.Quantity != null) {
					swtemp.noOfSeats += Decimal.valueOf(asRec.Product2.Seat_Count__c).intValue() * asRec.Quantity.intValue();
				}
			}
		}
	}

	private void groupingLogic(String productFamily, String accCurrencyCode, String exCurrencyCode, Decimal annualCost, String exType) {
		SummaryWrapper swtemp = new SummaryWrapper(accCurrencyCode);
		if (EnhancementMap.get(productFamily) != null) {
			swtemp = EnhancementMap.get(productFamily);

			if (annualCost != null) {
				swtemp.corporatePrice += (annualCost != null ? (getCorporateCurrencyValue(exCurrencyCode, annualCost)) : 0);
				swtemp.UserCurrencyPrice += (annualCost != null ? (getTargetCurrencyValue(runningUser.DefaultCurrencyIsoCode, exCurrencyCode, annualCost)) : 0);
				swtemp.AccountCurrencyPrice += (annualCost != null ? (getTargetCurrencyValue(accCurrencyCode, exCurrencyCode, annualCost)) : 0);

				dTotalCost += (annualCost != null ? (getTargetCurrencyValue(accCurrencyCode, exCurrencyCode, annualCost)) : 0);
			}
			if (String.isNotBlank(exType)) { swtemp.typeSet.add(exType); }
		} else {
			swtemp.prodGroup = productFamily;
			swtemp.prodGroupAmount = 'Annual ' + productFamily + ' Ent. Amount';
			if (annualCost != null) {
				swtemp.corporatePrice += (annualCost != null ? (getCorporateCurrencyValue(exCurrencyCode, annualCost)) : 0);
				swtemp.UserCurrencyPrice += (annualCost != null ? (getTargetCurrencyValue(runningUser.DefaultCurrencyIsoCode, exCurrencyCode, annualCost)) : 0);
				swtemp.AccountCurrencyPrice += (annualCost != null ? (getTargetCurrencyValue(accCurrencyCode, exCurrencyCode, annualCost)) : 0);

				dTotalCost += (annualCost != null ? (getTargetCurrencyValue(accCurrencyCode, exCurrencyCode, annualCost)) : 0);
			}
			if (String.isNotBlank(exType)) { swtemp.typeSet.add(exType); }
		}
		EnhancementMap.put(swtemp.prodGroup, swtemp);
	}

	private String formatCurrency(Decimal dInput) {
		if (dInput != null) {
			/*
			List<String> args = new String[] { '0', 'number', '###,###,##0.00' };
			String formatted = String.format(dInput.format(), args);
			if (formatted.contains('.')) {
				List<String> lstDecAmounts = formatted.split('\\.');
				if (lstDecAmounts[1].length() == 1) {
					formatted = formatted + '0';
				}
			}
			else {
				formatted = formatted + '.00';
			}
			return formatted;
			*/
			return dInput.format();
		}
		else {
			return String.valueOf(0.00);
		}
	}

	public static Decimal calculateARR(Date sDate, Date eDate, Decimal cAnnualCost, String aOracleNumber, String eStatus) {
		Decimal returnARR = 0.0;
		String sOutput = CalculateDuration.MonthsandDays(sDate, eDate);
		List<String> lstOutputs = (sOutput.contains(':') ? sOutput.split(':') : null);

		// Un-Grouped contracts : "Oracle Unique Identifier" will not be EMPTY
		// Grouped contracts : "Asset_Oracle_Number__c" ends with "G"
		Integer iMonths = 0, iDays = 0;
		if (lstOutputs != null && lstOutputs.size() == 2) {
			iMonths = Integer.valueof(lstOutputs.get(0));
			iDays = Integer.valueof(lstOutputs.get(1));
		}
		if (aOracleNumber != null && aOracleNumber.endsWithIgnoreCase('G') && eStatus != null && eStatus == 'Active') { // Grouped Contracts
			returnARR = cAnnualCost;
		}
		else if (eStatus != null && eStatus == 'Active') { // Un-Grouped Contracts
			returnARR = cAnnualCost;
		}
		else if (aOracleNumber == null) { // for Subscription Service-Contracts
			returnARR = cAnnualCost;
		}
		return returnARR;
	}
}