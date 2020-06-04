/*****************************************************************************************
  Name    : MepNaHardwareKit
  Desc    : Used to display the MEPNA Hardware Kit. User can select and add them to cart.                              
  Modification Log : 
  ---------------------------------------------------------------------------
  Developer              Date            Description
  ---------------------------------------------------------------------------
  Prince Leo           10/12/2018          Created
  Suresh Babu Murugan  14 Nov 2018         Modified - Adding Guided selling with 3rd Wizard
 ******************************************************************************************/
public class MepNaHardwareKit {

	public Id CartDetailView { get; set; }
	public ID configRequestId { get; set; }
	public String ProductCode { get; set; }
	public ID ProposalID { get; set; }
	public ID cartId { get; set; }
	public Boolean hasPendingItems { get; set; }
	public Boolean disableWizardONE { get; set; }
	public Boolean readOnlyWizardONE { get; set; }
	public boolean readOnlyWizardTWO { get; set; }
	public boolean disableWizardTWO { get; set; }
	public boolean readOnlyWizardTHREE { get; set; }
	public boolean disableWizardTHREE { get; set; }
	public boolean wizard3 { get; set; }
	public boolean actionPollerActive { get; set; }
	Apttus_CpqApi.CPQ.UpdatePriceRequestDO requestPrice;
	Apttus_CpqApi.CPQ.UpdatePriceResponseDO resultPrice;

	Apttus_CpqApi.CPQ.UpdatePriceRequestDO request1;
	Apttus_CpqApi.CPQ.UpdatePriceResponseDO result1;
	Map<ID, List<Apttus_Config2__ProductOptionComponent__c>> mapProdOptions = new Map<ID, List<Apttus_Config2__ProductOptionComponent__c>> ();
	Public List<Product2> ProdRecList { get; set; }
	Public List<Product2> ProdRecList2 { get; set; }
	Public List<Product2> ProdRecList3 { get; set; }
	List<String> beforeList = new List<String> ();
	List<String> afterList = new List<String> ();
	List<String> prodList = new List<String> ();
	List<String> prodList2 = new List<String> ();
	List<String> prodList3 = new List<String> ();
	public String wizard { get; set; }

	Map<String, String> ProductCodeIDMap = new Map<String, String> ();

	Set<ID> ProdID = new Set<ID> ();
	public Id selectedAssetId { get; set; }
	public boolean proposalTypeUpdateFlag = false;

	public String SelectedProdID { get; set; }
	public String SelectedProdID1 { get; set; }
	public String SelectedProdID2 { get; set; }
	public Boolean loadCartPage { get; set; }
	public MepNaHardwareKit() {
		disableWizardONE = True;
		loadCartPage = false;
		configRequestId = ApexPages.CurrentPage().getParameters().get('configRequestId');
		cartId = ApexPages.CurrentPage().getParameters().get('id');

		ProductCode = System.currentPageReference().getParameters().get('ProductCode');

		MEPNA_Hardware_Kit__c Mepnakit = [SELECT Id, Before__c, After__c, Products__c, Selection_Wizard__c FROM MEPNA_Hardware_Kit__c WHERE Name = :ProductCode];
		wizard = Mepnakit.Selection_Wizard__c;

		system.debug('----------------cartId-----------------' + cartId);
		/* Apttus_Config2__TempObject__c Config = [Select id,Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c,
		  Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__c from 
		  Apttus_Config2__TempObject__c where id =: configRequestId];*/

		if (Mepnakit.Before__c != Null) beforeList = Mepnakit.Before__c.split(';');
		if (Mepnakit.After__c != Null) afterList = Mepnakit.After__c.split(';');
		if (wizard == '1')
		prodList = Mepnakit.Products__c.split(';');
		else
		{
			prodList = Mepnakit.Products__c.split('#');
			prodList3 = (prodList.size() == 3 ? prodList.get(2).split(';') : null);
			prodList2 = prodList.get(1).split(';');
			prodList = prodList.get(0).split(';');
			system.debug('>>>>>ProdList1>>>>>>>>' + prodList);
			system.debug('>>>>>prodList2>>>>>>>>' + prodList2);
			system.debug('>>>>>ProdList3>>>>>>>>' + prodList3);
		}

		ProdRecList = new List<Product2> ();
		ProdRecList2 = new List<Product2> ();
		ProdRecList3 = new List<Product2> ();

		ProdRecList = [SELECT Id, Name, ProductCode FROM Product2 WHERE ProductCode IN :prodList];
		ProdRecList2 = [SELECT Id, Name, ProductCode FROM Product2 WHERE ProductCode IN :prodList2];
		if (prodList3 != null) {
			ProdRecList3 = [SELECT Id, Name, ProductCode FROM Product2 WHERE ProductCode IN :prodList3];
		}

		List<Product2> BeforeAfter = new List<Product2> ();
		BeforeAfter = [SELECT Id, Name, ProductCode FROM Product2 WHERE ProductCode IN :beforeList OR ProductCode IN :afterList];

		system.debug('>>>>>>>prodList>>>>>>>>>' + prodList);
		system.debug('>>>>>>>ProdRecList>>>>>>>>>' + ProdRecList);

		for (Product2 Pr : ProdRecList) {
			ProductCodeIDMap.put(Pr.ProductCode, Pr.Id);
		}

		for (Product2 Pr : BeforeAfter) {
			ProductCodeIDMap.put(Pr.ProductCode, Pr.Id);
		}

		for (Product2 Pr : ProdRecList2) {
			ProductCodeIDMap.put(Pr.ProductCode, Pr.Id);
		}

		for (Product2 Pr : ProdRecList3) {
			ProductCodeIDMap.put(Pr.ProductCode, Pr.Id);
		}

		List<Apttus_Config2__ProductOptionComponent__c> lstpOptionComponents = [SELECT Id, Apttus_Config2__ComponentProductId__c, Apttus_Config2__ParentProductId__c FROM Apttus_Config2__ProductOptionComponent__c WHERE Apttus_Config2__ParentProductId__c = :ProductCodeIDMap.values() ORDER BY Apttus_Config2__ParentProductId__c ASC];
		for (Apttus_Config2__ProductOptionComponent__c pOption : lstpOptionComponents) {
			List<Apttus_Config2__ProductOptionComponent__c> tempOptionComps = new List<Apttus_Config2__ProductOptionComponent__c> ();
			if (mapProdOptions.containsKey(pOption.Apttus_Config2__ParentProductId__c)) {
				tempOptionComps = mapProdOptions.get(pOption.Apttus_Config2__ParentProductId__c);
				tempOptionComps.add(pOption);
				mapProdOptions.put(pOption.Apttus_Config2__ParentProductId__c, tempOptionComps);
			}
			else {
				tempOptionComps.add(pOption);
				mapProdOptions.put(pOption.Apttus_Config2__ParentProductId__c, tempOptionComps);
			}
		}

		for (String pCodeID : ProductCodeIDMap.values()) {
			if (!mapProdOptions.containsKey(pCodeID)) {
				List<Apttus_Config2__ProductOptionComponent__c> tempOptionComps = new List<Apttus_Config2__ProductOptionComponent__c> ();
				mapProdOptions.put(pCodeID, tempOptionComps);
			}
		}
		/*
		  for(String Str : ProductCodeIDMap.keyset()){
		  mapProdOptions.put(ProductCodeIDMap.get(Str),[select id,Apttus_Config2__ComponentProductId__c from Apttus_Config2__ProductOptionComponent__c where Apttus_Config2__ParentProductId__c =: ProductCodeIDMap.get(Str)]);
		  }
		 */
	}

	Public Void AddbeforeProducts() {
		//Add Before 
		SelectedProdID = ApexPages.CurrentPage().getParameters().get('SelectedProdID');
		system.debug('>>>>SelectedProduct>>>>>>>' + SelectedProdID);
		system.debug('>>>>>before>>>>>>>' + beforeList);

		for (String Str : beforeList) {
			if (Str != Null && Str != '') {
				system.debug('>>>>>>Str>>>>>>>>' + Str);
				Apttus_CPQApi.CPQ.AddBundleRequestDO request = new Apttus_CPQApi.CPQ.AddBundleRequestDO();
				request.CartId = CartId;
				request.SelectedBundle = new Apttus_CPQApi.CPQ.SelectedBundleDO();
				request.SelectedBundle.SelectedProduct = new Apttus_CPQApi.CPQ.SelectedProductDO();
				request.SelectedBundle.SelectedProduct.ProductId = ProductCodeIDMap.get(Str);
				request.SelectedBundle.SelectedProduct.Quantity = 1;
				// Apttus_CPQApi.CPQ.AddBundleResponseDO response = Apttus_CPQApi.CPQWebService.addBundle(request);
				// system.debug('--------------------' + response);

				List<Apttus_CPQApi.CPQ.SelectedOptionDO> options = new List<Apttus_CPQApi.CPQ.SelectedOptionDO> ();

				system.debug('>>>>Outside Option>>>>>>' + ProductCodeIDMap.get(Str));
				system.debug('>>>>Outside Option>>>>>>' + mapProdOptions.get(ProductCodeIDMap.get(Str)));
				system.debug('>>>>Outside Option>>>>>>' + mapProdOptions);

				if (ProductCodeIDMap.get(Str) != Null && mapProdOptions.get(ProductCodeIDMap.get(Str)) != Null) {
					for (Apttus_Config2__ProductOptionComponent__c Opt : mapProdOptions.get(ProductCodeIDMap.get(Str))) {

						system.debug('>>>>Inside Option>>>>>>' + Opt);
						Apttus_CPQApi.CPQ.SelectedOptionDO objSelectedOptionDO = new Apttus_CPQApi.CPQ.SelectedOptionDO();
						objSelectedOptionDO.ComponentId = Opt.id;
						objSelectedOptionDO.ComponentProductId = Opt.Apttus_Config2__ComponentProductId__c;
						objSelectedOptionDO.Quantity = 1;
						options.Add(objSelectedOptionDO);
					}
				}
				if (options.size() > 0)
				{
					request.SelectedBundle.SelectedOptions = options;
				}

				Apttus_CPQApi.CPQWebService.addBundle(request);
			}
		}
	}

	public Void AddselectedProductWizard3() {
		readOnlyWizardONE = true;
		readOnlyWizardTWO = true;
		readOnlyWizardTHREE = true;
		disableWizardONE = false;
		disableWizardTWO = false;
		disableWizardTHREE = false;
		system.debug('>>>>>>>CartId>>>>>>>' + CartId);
		system.debug('>>>>>>>SelectedProdID2>>>>>>>' + SelectedProdID2);
		if (SelectedProdID2 != Null && SelectedProdID2 != '') {
			Apttus_CPQApi.CPQ.AddBundleRequestDO request = new Apttus_CPQApi.CPQ.AddBundleRequestDO();
			request.CartId = CartId;
			request.SelectedBundle = new Apttus_CPQApi.CPQ.SelectedBundleDO();
			request.SelectedBundle.SelectedProduct = new Apttus_CPQApi.CPQ.SelectedProductDO();
			request.SelectedBundle.SelectedProduct.ProductId = ProductCodeIDMap.get(SelectedProdID2);
			request.SelectedBundle.SelectedProduct.Quantity = 1;
			List<Apttus_CPQApi.CPQ.SelectedOptionDO> options = new List<Apttus_CPQApi.CPQ.SelectedOptionDO> ();

			system.debug('>>>>Outside Option>>>>>>' + ProductCodeIDMap.get(SelectedProdID2));
			system.debug('>>>>Outside Option>>>>>>' + mapProdOptions.get(ProductCodeIDMap.get(SelectedProdID2)));
			system.debug('>>>>Outside Option>>>>>>' + mapProdOptions);

			if (ProductCodeIDMap.get(SelectedProdID2) != Null && mapProdOptions.get(ProductCodeIDMap.get(SelectedProdID2)) != Null) {
				for (Apttus_Config2__ProductOptionComponent__c Opt : mapProdOptions.get(ProductCodeIDMap.get(SelectedProdID2))) {

					system.debug('>>>>Inside Option>>>>>>' + Opt);
					Apttus_CPQApi.CPQ.SelectedOptionDO objSelectedOptionDO = new Apttus_CPQApi.CPQ.SelectedOptionDO();
					objSelectedOptionDO.ComponentId = Opt.id;
					objSelectedOptionDO.ComponentProductId = Opt.Apttus_Config2__ComponentProductId__c;
					objSelectedOptionDO.Quantity = 1;
					options.Add(objSelectedOptionDO);
				}
			}
			if (options.size() > 0)
			{
				request.SelectedBundle.SelectedOptions = options;
			}

			Apttus_CPQApi.CPQWebService.addBundle(request);
		}
		hasPendingItems = false;
		// create the update price request 
		requestPrice = new Apttus_CpqApi.CPQ.UpdatePriceRequestDO();
		// add request parameters 
		requestPrice.CartId = cartid;
		// update price for the cart 
		resultPrice = Apttus_CpqApi.CPQWebService.updatePriceForCart(requestPrice);
		hasPendingItems = resultPrice.IsPricePending;
		system.debug(resultPrice.PendingLineNumbers + '-------hasPendingItems----------' + hasPendingItems);
		system.debug(resultPrice.CompletedLineNumbers + '-------hasPendingItems----------' + hasPendingItems);

		AddAfterProducts();
	}

	public Void AddselectedProductWizard2() {
		disableWizardONE = false;
		readOnlyWizardONE = true;
		readOnlyWizardTWO = true;
		disableWizardTWO = false;
		if (wizard == '3') {
			disableWizardTHREE = true;
		}
		system.debug('>>>>>>>CartId>>>>>>>' + CartId);
		system.debug('>>>>>>>SelectedProdID1>>>>>>>' + SelectedProdID1);
		if (SelectedProdID1 != Null && SelectedProdID1 != '') {
			Apttus_CPQApi.CPQ.AddBundleRequestDO request = new Apttus_CPQApi.CPQ.AddBundleRequestDO();
			request.CartId = CartId;
			request.SelectedBundle = new Apttus_CPQApi.CPQ.SelectedBundleDO();
			request.SelectedBundle.SelectedProduct = new Apttus_CPQApi.CPQ.SelectedProductDO();
			request.SelectedBundle.SelectedProduct.ProductId = ProductCodeIDMap.get(SelectedProdID1);
			request.SelectedBundle.SelectedProduct.Quantity = 1;
			List<Apttus_CPQApi.CPQ.SelectedOptionDO> options = new List<Apttus_CPQApi.CPQ.SelectedOptionDO> ();

			system.debug('>>>>Outside Option>>>>>>' + ProductCodeIDMap.get(SelectedProdID1));
			system.debug('>>>>Outside Option>>>>>>' + mapProdOptions.get(ProductCodeIDMap.get(SelectedProdID1)));
			system.debug('>>>>Outside Option>>>>>>' + mapProdOptions);

			if (ProductCodeIDMap.get(SelectedProdID1) != Null && mapProdOptions.get(ProductCodeIDMap.get(SelectedProdID1)) != Null) {
				for (Apttus_Config2__ProductOptionComponent__c Opt : mapProdOptions.get(ProductCodeIDMap.get(SelectedProdID1))) {

					system.debug('>>>>Inside Option>>>>>>' + Opt);
					Apttus_CPQApi.CPQ.SelectedOptionDO objSelectedOptionDO = new Apttus_CPQApi.CPQ.SelectedOptionDO();
					objSelectedOptionDO.ComponentId = Opt.id;
					objSelectedOptionDO.ComponentProductId = Opt.Apttus_Config2__ComponentProductId__c;
					objSelectedOptionDO.Quantity = 1;
					options.Add(objSelectedOptionDO);
				}
			}
			if (options.size() > 0)
			{
				request.SelectedBundle.SelectedOptions = options;
			}

			Apttus_CPQApi.CPQWebService.addBundle(request);
		}
		if (wizard == '2') {
			hasPendingItems = false;
			// create the update price request 
			requestPrice = new Apttus_CpqApi.CPQ.UpdatePriceRequestDO();
			// add request parameters 
			requestPrice.CartId = cartid;
			// update price for the cart 
			resultPrice = Apttus_CpqApi.CPQWebService.updatePriceForCart(requestPrice);
			hasPendingItems = resultPrice.IsPricePending;
			system.debug(resultPrice.PendingLineNumbers + '-------hasPendingItems----------' + hasPendingItems);
			system.debug(resultPrice.CompletedLineNumbers + '-------hasPendingItems----------' + hasPendingItems);

			AddAfterProducts();
		}
	}

	Public Void AddselectedProduct() {
		disableWizardONE = false;
		readOnlyWizardONE = true;
		if (wizard == '2' || wizard == '3') {
			disableWizardTWO = true;
		}
		system.debug('>>>>>>>>readOnlyWizardONE>>>' + readOnlyWizardONE);
		system.debug('>>>>>>>>disableWizardTWO >>>' + disableWizardTWO);
		AddbeforeProducts();
		system.debug('>>>>>>>CartId>>>>>>>' + CartId);
		system.debug('>>>>>>>SelectedProdID>>>>>>>' + SelectedProdID);
		if (SelectedProdID != Null && SelectedProdID != '' && ProductCode != 'SUB-ANY- ESTCM-SUITE-ADDON-D') {
			Apttus_CPQApi.CPQ.AddBundleRequestDO request = new Apttus_CPQApi.CPQ.AddBundleRequestDO();
			request.CartId = CartId;
			request.SelectedBundle = new Apttus_CPQApi.CPQ.SelectedBundleDO();
			request.SelectedBundle.SelectedProduct = new Apttus_CPQApi.CPQ.SelectedProductDO();
			request.SelectedBundle.SelectedProduct.ProductId = ProductCodeIDMap.get(SelectedProdID);
			request.SelectedBundle.SelectedProduct.Quantity = 1;
			List<Apttus_CPQApi.CPQ.SelectedOptionDO> options = new List<Apttus_CPQApi.CPQ.SelectedOptionDO> ();

			system.debug('>>>>Outside Option>>>>>>' + ProductCodeIDMap.get(SelectedProdID));
			system.debug('>>>>Outside Option>>>>>>' + mapProdOptions.get(ProductCodeIDMap.get(SelectedProdID)));
			system.debug('>>>>Outside Option>>>>>>' + mapProdOptions);

			if (ProductCodeIDMap.get(SelectedProdID) != Null && mapProdOptions.get(ProductCodeIDMap.get(SelectedProdID)) != Null) {
				for (Apttus_Config2__ProductOptionComponent__c Opt : mapProdOptions.get(ProductCodeIDMap.get(SelectedProdID))) {

					system.debug('>>>>Inside Option>>>>>>' + Opt);
					Apttus_CPQApi.CPQ.SelectedOptionDO objSelectedOptionDO = new Apttus_CPQApi.CPQ.SelectedOptionDO();
					objSelectedOptionDO.ComponentId = Opt.id;
					objSelectedOptionDO.ComponentProductId = Opt.Apttus_Config2__ComponentProductId__c;
					objSelectedOptionDO.Quantity = 1;
					options.Add(objSelectedOptionDO);
				}
			}
			if (options.size() > 0)
			{
				request.SelectedBundle.SelectedOptions = options;
				//Apttus_CPQApi.CPQ.AddOptionsResponseDO addOptRespDO = Apttus_CPQApi.CPQWebService.addOptions(cartId, 1, options);
			}
			Apttus_CPQApi.CPQWebService.addBundle(request);
		}

		else if (ProductCode == 'SUB-ANY- ESTCM-SUITE-ADDON-D')
		{
			system.debug('>>>>>>>ProductCode>>>>>>>>>' + ProductCode);
			system.debug('>>>>>>>SelectedProdID>>>>>>>>>' + SelectedProdID);
			Set<String> ProductCodeSet = new Set<String> ();

			if (SelectedProdID == 'SUB-TS-SX-SUBMAN-EL')
			{
				ProductCodeSet.add('SUB-TS-SX-SUBMAN-EL');
				ProductCodeSet.add('SUB-TS-ICT-ADDON-D');
			}
			else if (SelectedProdID == 'SUB-TS-SX-SUBMAN-P')
			{
				ProductCodeSet.add('SUB-TS-SX-SUBMAN-P');
			}
			List<Apttus_CPQApi.CPQ.SelectedOptionDO> options = new List<Apttus_CPQApi.CPQ.SelectedOptionDO> ();

			for (Apttus_Config2__ProductOptionComponent__c Opt :[select id, Apttus_Config2__ParentProductId__c, Apttus_Config2__ComponentProductId__c from Apttus_Config2__ProductOptionComponent__c where Apttus_Config2__ParentProductId__r.ProductCode = :ProductCode and Apttus_Config2__ComponentProductId__r.ProductCode in :ProductCodeSet]) {

				system.debug('>>>>Inside Option>>>>>>' + Opt);
				Apttus_CPQApi.CPQ.SelectedOptionDO objSelectedOptionDO = new Apttus_CPQApi.CPQ.SelectedOptionDO();
				objSelectedOptionDO.ComponentId = Opt.id;
				objSelectedOptionDO.ComponentProductId = Opt.Apttus_Config2__ComponentProductId__c;
				objSelectedOptionDO.Quantity = 1;
				options.Add(objSelectedOptionDO);
			}

			if (options.size() > 0)
			{
				List<Apttus_Config2__LineItem__c> LineList = [select id, Apttus_Config2__LineNumber__c from Apttus_Config2__LineItem__c where Apttus_Config2__ProductId__r.ProductCode = :ProductCode order by Apttus_Config2__LineNumber__c ASC Limit 1];
				//request.SelectedBundle.SelectedOptions = options ;
				//Apttus_CPQApi.CPQ.AddOptionsResponseDO addOptRespDO = Apttus_CPQApi.CPQWebService.addOptions(cartId, 1, options);
				if (LineList.size() > 0 && !test.isrunningtest()) Apttus_CPQApi.CPQ.AddOptionsResponseDO addOptRespDO = Apttus_CPQApi.CPQWebService.addOptions(cartId, Integer.valueof(LineList.get(0).Apttus_Config2__LineNumber__c), options);
			}

		}
		if (wizard == '1') {
			hasPendingItems = false;
			// create the update price request 
			requestPrice = new Apttus_CpqApi.CPQ.UpdatePriceRequestDO();
			// add request parameters 
			requestPrice.CartId = cartid;
			// update price for the cart 
			resultPrice = Apttus_CpqApi.CPQWebService.updatePriceForCart(requestPrice);
			hasPendingItems = resultPrice.IsPricePending;
			system.debug(resultPrice.PendingLineNumbers + '-------hasPendingItems----------' + hasPendingItems);
			system.debug(resultPrice.CompletedLineNumbers + '-------hasPendingItems----------' + hasPendingItems);

			AddAfterProducts();
		}
	}

	Public Void AddAfterProducts() {
		hasPendingItems = false;
		// create the update price request 
		requestPrice = new Apttus_CpqApi.CPQ.UpdatePriceRequestDO();
		// add request parameters 
		requestPrice.CartId = cartid;
		// update price for the cart 
		resultPrice = Apttus_CpqApi.CPQWebService.updatePriceForCart(requestPrice);
		hasPendingItems = resultPrice.IsPricePending;

		//Add After
		for (String Str : afterList) {
			Apttus_CPQApi.CPQ.AddBundleRequestDO request = new Apttus_CPQApi.CPQ.AddBundleRequestDO();
			request.CartId = CartId;
			request.SelectedBundle = new Apttus_CPQApi.CPQ.SelectedBundleDO();
			request.SelectedBundle.SelectedProduct = new Apttus_CPQApi.CPQ.SelectedProductDO();
			request.SelectedBundle.SelectedProduct.ProductId = ProductCodeIDMap.get(Str);
			request.SelectedBundle.SelectedProduct.Quantity = 1;
			List<Apttus_CPQApi.CPQ.SelectedOptionDO> options = new List<Apttus_CPQApi.CPQ.SelectedOptionDO> ();

			system.debug('>>>>Outside Option>>>>>>' + ProductCodeIDMap.get(Str));
			system.debug('>>>>Outside Option>>>>>>' + mapProdOptions.get(ProductCodeIDMap.get(Str)));
			system.debug('>>>>Outside Option>>>>>>' + mapProdOptions);

			if (ProductCodeIDMap.get(Str) != Null && mapProdOptions.get(ProductCodeIDMap.get(Str)) != Null) {
				for (Apttus_Config2__ProductOptionComponent__c Opt : mapProdOptions.get(ProductCodeIDMap.get(Str))) {
					system.debug('>>>>Inside Option>>>>>>' + Opt);
					Apttus_CPQApi.CPQ.SelectedOptionDO objSelectedOptionDO = new Apttus_CPQApi.CPQ.SelectedOptionDO();
					objSelectedOptionDO.ComponentId = Opt.id;
					objSelectedOptionDO.ComponentProductId = Opt.Apttus_Config2__ComponentProductId__c;
					objSelectedOptionDO.Quantity = 1;
					options.Add(objSelectedOptionDO);
				}
			}
			if (options.size() > 0)
			{
				request.SelectedBundle.SelectedOptions = options;
			}

			Apttus_CPQApi.CPQWebService.addBundle(request);

			hasPendingItems = false;
			// create the update price request 
			requestPrice = new Apttus_CpqApi.CPQ.UpdatePriceRequestDO();
			// add request parameters 
			requestPrice.CartId = cartid;
			// update price for the cart 
			resultPrice = Apttus_CpqApi.CPQWebService.updatePriceForCart(requestPrice);
			hasPendingItems = resultPrice.IsPricePending;
			system.debug(resultPrice.PendingLineNumbers + '-------hasPendingItems----------' + hasPendingItems);
			system.debug(resultPrice.CompletedLineNumbers + '-------hasPendingItems----------' + hasPendingItems);
		}
	}

	Public Pagereference GotoCart() {
		List<Apttus_Config2__LineItem__c> UpdateLines = new List<Apttus_Config2__LineItem__c> ();
		UpdateLines = [select id, Hardware_Bundle_Selection__c from Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c = :cartId];
		for (Apttus_Config2__LineItem__c Li : UpdateLines)
		{
			li.Hardware_Bundle_Selection__c = True;
		}
		update UpdateLines;

		hasPendingItems = false;
		// create the update price request 
		requestPrice = new Apttus_CpqApi.CPQ.UpdatePriceRequestDO();
		// add request parameters 
		requestPrice.CartId = cartid;
		// update price for the cart 
		resultPrice = Apttus_CpqApi.CPQWebService.updatePriceForCart(requestPrice);
		hasPendingItems = resultPrice.IsPricePending;
		system.debug(resultPrice.PendingLineNumbers + '-------hasPendingItems----------' + hasPendingItems);
		system.debug(resultPrice.CompletedLineNumbers + '-------hasPendingItems----------' + hasPendingItems);
		//AddAfterProducts();

		/*Integer start = System.Now().millisecond();
		  while(System.Now().millisecond()< start+250){ 
		  }*/
		//loadCartPage = true;

		return new Pagereference('/apex/AdvancepricingPage?id=' + cartId + '&configRequestId=' + configRequestId + '&flow=Angular&URLParam=Completed');
	}
}