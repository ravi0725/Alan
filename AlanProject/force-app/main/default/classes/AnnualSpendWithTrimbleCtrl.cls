/*****************************************************************************************
  Name        : AnnualSpendWithTrimbleCtrl
  Desc        : Annual Spend with Trimble calculation on Acconnt level
  ---------------------------------------------------------------------------
  Developer              Date            Description
  ---------------------------------------------------------------------------
  Suresh Babu Murugan    16/Oct/2019        Created
 ******************************************************************************************/
public class AnnualSpendWithTrimbleCtrl {
	public Account acc { get; set; }
	public Map<String, Map<String, SummaryWrapper>> mapRevenueCollection { get; set; }
	public Map<String, List<SummaryWrapper>> mapRevenueCollection_Results { get; set; }
	public Map<String, String> mapRevenueCollection_TotalAmount { get; set; }
	public Set<String> setBusinessArea { get; set; }
	public List<SummaryWrapper> lstRevenueResults { get; set; }
	public Map<String, Decimal> conversion_rates = new Map<String, Decimal> ();
	public Boolean is2ndCurrencyNeed { get; set; }

	public AnnualSpendWithTrimbleCtrl(ApexPages.StandardController con) {
		for (DatedConversionRate curr :[SELECT Id, IsoCode, ConversionRate, StartDate, NextStartDate FROM DatedConversionRate WHERE NextStartDate > TODAY AND StartDate <= TODAY ORDER BY IsoCode DESC]) {
			conversion_rates.put(curr.IsoCode, curr.ConversionRate);
		}
		acc = (Account) con.getRecord();
		List<Account> accList = [SELECT Id, CurrencyIsoCode FROM Account WHERE Id = :acc.Id];
		if (accList.size() == 1) {
			acc = accList[0];
		} else {
			acc = new Account();
		}
		lstRevenueResults = new List<SummaryWrapper> ();

		mapRevenueCollection = new Map<String, Map<String, SummaryWrapper>> ();
		mapRevenueCollection_Results = new Map<String, List<SummaryWrapper>> ();
		mapRevenueCollection_TotalAmount = new Map<String, String> ();
		setBusinessArea = new Set<String> ();
		is2ndCurrencyNeed = ((UserInfo.getDefaultCurrency() == acc.CurrencyIsoCode) ? false : true);

		List<OpportunityLineItem> lstOptyLines = [SELECT CurrencyIsoCode, ProductCode, Product2.Business_Area__c, TotalPrice, Extended_Price__c, Opportunity.Name, Opportunity.StageName, Opportunity.Selling_Division__c, Opportunity.Amount, Opportunity.CloseDate FROM OpportunityLineItem WHERE Opportunity.AccountId = :acc.Id AND Opportunity.IsClosed = TRUE AND Opportunity.ForecastCategory = 'Closed' AND(Opportunity.CloseDate = LAST_N_YEARS : 2 OR Opportunity.CloseDate = THIS_YEAR) ORDER BY Opportunity.CloseDate ASC, OpportunityId LIMIT 49999];

		for (OpportunityLineItem opLine : lstOptyLines) {
			if (String.isNotBlank(opLine.Product2.Business_Area__c)) {
				String rYear = String.valueOf(opLine.Opportunity.CloseDate.year());
				SummaryWrapper swtemp = new SummaryWrapper();
				Map<String, SummaryWrapper> mapTmp = new Map<String, SummaryWrapper> ();
				if (mapRevenueCollection.get(rYear) != null)
				{
					mapTmp = mapRevenueCollection.get(rYear);
					if (mapTmp.get(opLine.Product2.Business_Area__c) != null)
					{
						swtemp = mapTmp.get(opLine.Product2.Business_Area__c);
						swtemp.revenueAmount += (opLine.TotalPrice != null ? getTargetCurrencyValue(acc.CurrencyIsoCode, opLine.CurrencyIsoCode, opLine.TotalPrice) : 0.0);
						swtemp.revenueYear = rYear;
					}
					else
					{
						swtemp.businessArea = opLine.Product2.Business_Area__c;
						swtemp.revenueAmount += (opLine.TotalPrice != null ? getTargetCurrencyValue(acc.CurrencyIsoCode, opLine.CurrencyIsoCode, opLine.TotalPrice) : 0.0);
						swtemp.revenueYear = rYear;
					}
					mapTmp.put(swtemp.businessArea, swtemp);
				}
				else
				{
					swtemp.businessArea = opLine.Product2.Business_Area__c;
					swtemp.revenueYear = rYear;
					swtemp.revenueAmount += (opLine.TotalPrice != null ? getTargetCurrencyValue(acc.CurrencyIsoCode, opLine.CurrencyIsoCode, opLine.TotalPrice) : 0.0);
					mapTmp.put(swtemp.businessArea, swtemp);
				}
				mapRevenueCollection.put(rYear, mapTmp);
			}
		}
		System.debug(' mapRevenueCollection ::::::::::' + mapRevenueCollection.values());
		for (String keyYear : mapRevenueCollection.keySet()) {
			System.debug(' keyYear :::' + keyYear);
			Decimal totalAmountTemp = 0.0;
			for (SummaryWrapper sWrap : mapRevenueCollection.get(keyYear).values()) {
				setBusinessArea.add(sWrap.businessArea);
				if (is2ndCurrencyNeed) {
					sWrap.revenueAmountDisp = acc.CurrencyIsoCode + ' ' + formatCurrency(sWrap.revenueAmount.setScale(2, RoundingMode.HALF_UP)) + ' (' + String.valueOf(UserInfo.getDefaultCurrency()) + ' ' + formatCurrency(getTargetCurrencyValue(UserInfo.getDefaultCurrency(), acc.CurrencyIsoCode, sWrap.revenueAmount).setScale(2, RoundingMode.HALF_UP)) + ')';
				}
				else {
					sWrap.revenueAmountDisp = acc.CurrencyIsoCode + ' ' + formatCurrency(sWrap.revenueAmount.setScale(2, RoundingMode.HALF_UP));
				}
				totalAmountTemp += sWrap.revenueAmount;
				System.debug(' sWrap :::' + sWrap);
				lstRevenueResults.add(sWrap);
			}
			mapRevenueCollection_Results.put(keyYear, lstRevenueResults);
			String yearlyTotal;
			if (is2ndCurrencyNeed) {
				yearlyTotal = acc.CurrencyIsoCode + ' ' + formatCurrency(totalAmountTemp.setScale(2, RoundingMode.HALF_UP)) + ' (' + String.valueOf(UserInfo.getDefaultCurrency()) + ' ' + formatCurrency(getTargetCurrencyValue(UserInfo.getDefaultCurrency(), acc.CurrencyIsoCode, totalAmountTemp).setScale(2, RoundingMode.HALF_UP)) + ')';
			}
			else {
				yearlyTotal = acc.CurrencyIsoCode + ' ' + formatCurrency(totalAmountTemp.setScale(2, RoundingMode.HALF_UP));
			}
			mapRevenueCollection_TotalAmount.put(keyYear, yearlyTotal);
		}
	}

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

	private String formatCurrency(Decimal dInput) {
		if (dInput != null) {
			return dInput.format();
		}
		else {
			return String.valueOf(0.00);
		}
	}

	public boolean getMapIsEmpty() {
		return mapRevenueCollection_Results.size() == 0;
	}

	public class SummaryWrapper {
		public String revenueYear { get; set; }
		public String businessArea { get; set; }
		public Decimal revenueAmount { get; set; }
		public String revenueAmountDisp { get; set; }

		public SummaryWrapper(String strAccountCurrencyCode) {
			revenueYear = '';
			businessArea = '';
			revenueAmount = 0.0;
			revenueAmountDisp = '';
		}

		public SummaryWrapper() {
			revenueYear = '';
			businessArea = '';
			revenueAmount = 0.0;
			revenueAmountDisp = '';
		}
	}
}