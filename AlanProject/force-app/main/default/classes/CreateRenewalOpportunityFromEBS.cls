/*****************************************************************************************
  Name    : CreateRenewalOpportunityFromEBS
  Desc    : Used for Renewal Opportunity and Opportunity Line Item creation
 
  Modification Log : 
  ---------------------------------------------------------------------------
  Developer                 Date            Description
  ---------------------------------------------------------------------------
  Ankur Patel               12/11/2013      Created
  Suresh Babu Murugan       22-JULY-2019    Modified : APP-8123-Changes needed for Auto-Generated SSM Renewals
 ******************************************************************************************/
public class CreateRenewalOpportunityFromEBS {
	public static Map<String, Integer> launchControl;
	// Static initialize
	static {
		resetLaunchControl();
	}

	// Reset Trigger control (e.g. for testing)
	public static void resetLaunchControl() {
		launchControl = new Map<String, Integer> ();
		launchControl.put('processRenewalOpporutnity', 0);
	}

	// Reset Trigger control (e.g. for testing)
	public static void setLaunchControl() {
		launchControl = new Map<String, Integer> ();
		launchControl.put('processRenewalOpporutnity', 1);

	}

	public static boolean runOpportunityTrigger = true;
	public static boolean runOpportunityLineItemTrigger = true;
	public static Map<String, String> contractNoLineIdMap;
	public static Set<String> setCoveredLineIds;

	//Configure Renewal Opportunity
	public static void createOpportuntiy(String interfaceName, List<sObject> sObjectList) {
		Map<Id, Id> addIdFCHIdMap = new Map<Id, Id> ();
		Map<Id, String> priceListMap = new Map<Id, String> ();

		for (sObject obj : sObjectList) {
			if (obj.get('Price_List__c') != null) {
				priceListMap.put((Id) obj.get('Price_List__c'), '');
			}

			if (obj.get('Service_Contract__c') != null) {
				String ContractId = (String) obj.get('Service_Contract__c');
				obj.put('Service_Contract__c', ContractId);
			}

			if (obj.get('Bill_to_Address__c') != null)
			addIdFCHIdMap.put((Id) obj.get('Bill_to_Address__c'), null);
			if (obj.get('Ship_to_Address1__c') != null)
			addIdFCHIdMap.put((Id) obj.get('Ship_to_Address1__c'), null);
		}
		system.debug('------addIdFCHIdMap------' + addIdFCHIdMap);
		for (Apttus_Config2__PriceList__c acprc :[select Id, CurrencyIsoCode from Apttus_Config2__PriceList__c where Id IN :priceListMap.keySet()]) {
			priceListMap.put(acprc.Id, acprc.CurrencyIsoCode);
		}

		for (sObject obj : sObjectList) {
			if (obj.get('Price_List__c') != null) {
				if (priceListMap.containsKey((Id) obj.get('Price_List__c'))) {
					obj.put('CurrencyIsoCode', priceListMap.get((Id) obj.get('Price_List__c')));
				}
			}
		}

		for (Address__c add :[select Id, Account__c from Address__c where Id in :addIdFCHIdMap.keySet()]) {
			addIdFCHIdMap.put(add.Id, add.Account__c);
		}

		Map<String, Id> BookMap = new Map<String, Id> ();
		for (PriceBook2 Pr :[Select Id, Name from PriceBook2]) {
			BookMap.put(Pr.Name, Pr.Id);
		}

		system.debug('------addIdFCHIdMap------' + addIdFCHIdMap);
		for (sObject obj : sObjectList) {
			String serviceStartYear = String.valueof(Date.today().year()); // TT 124925 Renewals 2.0 - Opportunity Name
			if (obj.get('Service_End_Date__c') != null) {
				obj.put('CloseDate', ((Date) obj.get('Service_Start_Date__c')) - 1);
				serviceStartYear = String.valueof(((Date) obj.get('Service_Start_Date__c')).year()); // TT 124925 Renewals 2.0 - Opportunity Name
			}

			system.debug('--sellingDivision--' + obj.get('Selling_Division__c'));
			if (obj.get('Selling_Division__c') == 'MEP') {
				obj.put('PriceBook2Id', BookMap.get('Plancal Standard Pricebook'));
			} else if (obj.get('Selling_Division__c') == 'MEP NA') { // Renewal 3.5 - Set Opportunity Name
				obj.put('PriceBook2Id', BookMap.get('MEP NA'));
				obj.put('Name', serviceStartYear + ' Renewal');
				obj.put('Industry__c', 'MEP'); // Suresh Babu: APP-8123 -Default Industry for MEPNA Renewal Opps
				obj.put('LeadSource', 'Current Customer');
			} else if (obj.get('Selling_Division__c') == 'GCCM') {
				obj.put('PriceBook2Id', BookMap.get('GCCM Price Book'));

				obj.put('Opportunity_Product__c', 'SSM');

				//String oppName = date.today().year() + ' Trimble Renewal';
				String oppName = serviceStartYear + ' Trimble Renewal'; // TT 124925 Renewals 2.0 - Opportunity Name
				obj.put('Name', oppName);
				obj.put('LeadSource', 'Current Customer'); // Suresh Babu: TT:121271 - GCCM Renewal Opportunity LeadSource:Current Customer
				obj.put('Add_to_Forecast__c', true); // Suresh Babu: TT:144680 - GCCM Renewal Opportunities Add to Forecast: true
			} else if (obj.get('Selling_Division__c') == 'RE&WS') {
				obj.put('PriceBook2Id', BookMap.get('Manhattan Standard Price Book'));
				obj.put('Opportunity_Product__c', '');
				//obj.put('StageName', '2 - Needs Analysis'); // TT:124262 - As Requested by RE&WS BU, to view Renewal Opportunity in Reports
				obj.put('StageName', '3 - Value Proposition'); // APP-20514 - As Requested by RE&WS BU, to view Renewal Opportunity in Reports
				//String oppName = date.today().year() + ' Renewal';
				String oppName = serviceStartYear + ' Renewal'; // TT 124925 Renewals 2.0 - Opportunity Name
				obj.put('Name', oppName);
			}

			if (addIdFCHIdMap.containsKey((Id) obj.get('Bill_to_Address__c')))
			obj.put('Bill_To_Account__c', addIdFCHIdMap.get((Id) obj.get('Bill_to_Address__c')));
			system.debug('------addIdFCHIdMap------' + addIdFCHIdMap.containsKey((Id) obj.get('Ship_to_Address1__c')));
			if (addIdFCHIdMap.containsKey((Id) obj.get('Ship_to_Address1__c')))
			obj.put('Ship_To_Account__c', addIdFCHIdMap.get((Id) obj.get('Ship_to_Address1__c')));
		}
		system.debug('------responseMap------' + XMLUtility.responseMap);
		system.debug('------XMLUtility.uniqueIdentifier------' + XMLUtility.uniqueIdentifier);

		upsertRecord(interfaceName, 'Opportunity', sObjectList);
	}

	//Renewal 3.5 - Delete Renewal Opportunity Line Items when it is DELETED in Oracle
	public static void deleteMEPNAOpportuntiy() {
		delete[SELECT ID FROM OpportunityLineItem WHERE CoveredLineID__c IN : setCoveredLineIds];
	}

	//Renewal 3.5 - Update Renewal Opportunity Stage to Closed Lost when it is CANCELLED in Oracle
	public static void updateMEPNAOpportuntiy(String interfaceName, List<sObject> sObjectList) {
		set<String> contractIds = new set<String> ();
		for (sObject obj : sObjectList) {
			system.debug('-------Service_Contract__c----------' + obj.get('Service_Contract__c'));
			if (obj.get('Service_Contract__c') != null) {
				contractIds.add(string.valueOf(obj.get('Service_Contract__c')));
			}
		}
		system.debug('-------contractIds----------' + contractIds);
		List<Opportunity> oppList = [select ID from Opportunity where Service_Contract__c in :contractIds];
		for (Opportunity opp : oppList) {
			opp.StageName = 'Closed Lost';
		}
		Integer i = 0;
		String finalResponse = '';
		List<WS_Interface_Log__c> logList = new List<WS_Interface_Log__c> ();
		for (Database.saveResult result : Database.update(oppList, false)) {
			system.debug('-------result----------' + result);
			system.debug('-------i++----------' + sObjectList.get(i));
			String uniqueIdentifierValue = (String) sObjectList.get(i).get(XMLUtility.uniqueIdentifier);
			system.debug('----unique----' + uniqueIdentifierValue + '\n----responseMap---' + XMLUtility.responseMap);
			system.debug('---------------result.isSuccess()---------' + result.isSuccess());
			system.debug(uniqueIdentifierValue + '---------------XMLUtility.responseMap---------' + XMLUtility.responseMap.keySet());
			if (result.isSuccess() && XMLUtility.responseMap.containsKey(uniqueIdentifierValue)) {
				system.debug('---------------finalResponse---------' + finalResponse);
				finalResponse = finalResponse + '<ROW>' + XMLUtility.responseMap.get(uniqueIdentifierValue);
				system.debug('---------------finalResponse---------' + finalResponse);
				finalResponse = finalResponse + additionalResponse('Opportunity');
				system.debug('---------------finalResponse---------' + finalResponse);
				finalResponse = finalResponse + '<STATUS>SUCCESS</STATUS><ERRORMESSAGE/></ROW>';
				system.debug('---------------finalResponse---------' + finalResponse);
				XMLUtility.setResultMap(uniqueIdentifierValue, finalResponse);
				finalResponse = '';
				system.debug('---------------finalResponse---------' + finalResponse);
				//}else if(XMLUtility.responseMap.containsKey(uniqueIdentifierValue)){
			} else if (!result.isSuccess()) {
				String msg = '';
				String erMsg = '';
				for (Database.Error er : result.getErrors()) {
					if (XMLUtility.responseMap.containsKey(uniqueIdentifierValue)) {
						msg += 'Error (' + er.getStatusCode() + '):' + er.getMessage();
						msg += '\r\n';
						erMsg += er.getMessage() + '\n';
					}
					finalResponse = finalResponse + '<ROW>' + XMLUtility.responseMap.get(uniqueIdentifierValue);
					finalResponse = finalResponse + additionalResponse('Opportunity');
					finalResponse = finalResponse + '<STATUS>FAILED</STATUS><ERRORMESSAGE>' + msg + '</ERRORMESSAGE></ROW>';
					system.debug(uniqueIdentifierValue + '------finalResponse------' + finalResponse);
				}
				XMLUtility.setResultMap(uniqueIdentifierValue, finalResponse);
				system.debug('-------XMLUtility----------' + XMLUtility.resultMap);

				if (erMsg != '') {
					logList.add(WS_Interface_Log.createLog('CreateRenewalOpportunityFromEBS', 'upsertRecord', erMsg,
					                                       msg, XMLUtility.responseMap.get(uniqueIdentifierValue)));
				}

				finalResponse = '';
			}
			system.debug('-------i++----------' + i);
			i++;
		}
		if (logList.size() > 0) {
			insert logList;
		}
	}

	//Configure Renewal Opportunity Line Item
	public static void createOpportuntiyLineItem(String interfaceName, List<sObject> sObjectList) {
		system.debug('------sObjectList------' + sObjectList);
		Map<String, Id> contractOppIdMap = new Map<String, Id> ();
		Map<String, String> OppPriceBookMap = new Map<String, String> ();
		Map<String, Id> prdPriceBookEntryMap = new Map<String, Id> ();
		Map<String, PriceBookEntry> updatePriceBookEntryMap = new Map<String, PriceBookEntry> ();
		List<PriceBookEntry> updatepriceBookEntryList = new List<PriceBookEntry> ();
		set<String> serviceItems = new Set<String> ();
		List<Integer> indexList = new List<Integer> ();
		List<PriceBookEntry> pbeList = new List<PriceBookEntry> ();
		Map<String, String> prdIdMap = new Map<String, String> ();
		Integer cnt = 0;
		Id stdPriceBookId = null;

		for (sObject oppLineItem : sObjectList) {
			if (oppLineItem.get('Contract__c') != null)
			contractOppIdMap.put((String) oppLineItem.get('Contract__c'), null);
			if (oppLineItem.get('Service_Item_Id__c') != null)
			serviceItems.add((String) oppLineItem.get('Service_Item_Id__c'));
		}
		system.debug('------contractOppIdMap------' + contractOppIdMap);

		for (PriceBookEntry pbe :[select Id, IsActive, PriceBook2.Name, Product2Id, PriceBook2Id, Product2.Oracle_ID__c, CurrencyIsoCode from PriceBookEntry where
		     Product2.Oracle_ID__c in :serviceItems]) {
			system.debug(pbe.Product2.Oracle_ID__c + '------contractOppIdMap------' + pbe.PriceBook2Id);
			if (pbe.IsActive) prdPriceBookEntryMap.put(pbe.Product2.Oracle_ID__c + '-' + pbe.PriceBook2Id + '-' + pbe.CurrencyIsoCode, pbe.Id);
			else updatePriceBookEntryMap.put(pbe.Product2.Oracle_ID__c + '-' + pbe.PriceBook2Id + '-' + pbe.CurrencyIsoCode, pbe);
		}
		system.debug('------updatePriceBookEntryMap------' + updatePriceBookEntryMap);
		system.debug('------contractOppIdMap------' + contractOppIdMap.keySet());
		for (Opportunity opp :[select Id, Contract__c, PriceBook2Id, CurrencyIsoCode from Opportunity where Contract__c in :contractOppIdMap.keySet()]) {
			system.debug('------contractOppIdMap------' + opp);
			contractOppIdMap.put(string.valueof(opp.Contract__c), opp.Id);
			OppPriceBookMap.put(string.valueof(opp.Contract__c), opp.PriceBook2Id + '-' + opp.CurrencyIsoCode);
		}
		system.debug('------OppPriceBookMap------' + OppPriceBookMap);
		for (sObject oppLineItem : sObjectList) {
			if (oppLineItem.get('Contract__c') != null ? contractOppIdMap.containsKey((String) oppLineItem.get('Contract__c')) : false) {
				oppLineItem.put('OpportunityId', contractOppIdMap.get((String) oppLineItem.get('Contract__c')));
			}

			if (oppLineItem.get('Service_Item_Id__c') != null && oppLineItem.get('Contract__c') != null ?
			    OppPriceBookMap.containsKey((string) oppLineItem.get('Contract__c')) :
			    false) {
				if (prdPriceBookEntryMap.containsKey((String) oppLineItem.get('Service_Item_Id__c') + '-' + OppPriceBookMap.get((string) oppLineItem.get('Contract__c')))) {
					oppLineItem.put('PriceBookEntryId', prdPriceBookEntryMap.get((String) oppLineItem.get('Service_Item_Id__c') + '-' + OppPriceBookMap.get((string) oppLineItem.get('Contract__c'))));
				} else {
					indexList.add(cnt);
				}
			}
			cnt++;
		}
		system.debug('--------indexList-------' + indexList);
		if (indexList.size() > 0) {
			for (Product2 prd :[select ID, Product2.Oracle_ID__c from Product2 where Oracle_ID__c in :serviceItems]) {
				prdIdMap.put(prd.Oracle_ID__c, prd.Id);
			}
			system.debug('--------prdIdMap-------' + prdIdMap.keySet());
			set<String> keySet = new set<String> ();
			stdPriceBookId = [select Id from PriceBook2 where Name = 'Standard Price Book'].Id;
			for (cnt = 0; cnt<indexList.size(); cnt++) {
				system.debug('--------sObjectList[cnt]-------' + sObjectList[indexList[cnt]]);
				system.debug('--------sObjectList[cnt]-------' + sObjectList[indexList[cnt]].get('Service_Item_Id__c'));
				system.debug('--------sObjectList[cnt]-------' + OppPriceBookMap.get((string) sObjectList[indexList[cnt]].get('Contract__c')).split('-').get(1));
				system.debug('--------sObjectList[cnt]-------' + OppPriceBookMap.get((string) sObjectList[indexList[cnt]].get('Contract__c')).split('-').get(0));

				if (!updatePriceBookEntryMap.containsKey(((String) sObjectList[indexList[cnt]].get('Service_Item_Id__c'))
				                                         + '-' + OppPriceBookMap.get((string) sObjectList[indexList[cnt]].get('Contract__c')).split('-').get(0)
				                                         + '-' + OppPriceBookMap.get((string) sObjectList[indexList[cnt]].get('Contract__c')).split('-').get(1))) {
					if (!keySet.contains(prdIdMap.get((String) sObjectList[indexList[cnt]].get('Service_Item_Id__c'))
					                     + '-' + stdPriceBookId
					                     + '-' + OppPriceBookMap.get((string) sObjectList[indexList[cnt]].get('Contract__c')).split('-').get(1))) {
						PriceBookEntry pbe = new PriceBookEntry();
						pbe.Product2Id = prdIdMap.get((String) sObjectList[indexList[cnt]].get('Service_Item_Id__c'));
						pbe.CurrencyIsoCode = OppPriceBookMap.get((string) sObjectList[indexList[cnt]].get('Contract__c')).split('-').get(1);
						pbe.Pricebook2Id = stdPriceBookId;
						pbe.UnitPrice = 0;
						pbe.IsActive = true;
						pbeList.add(pbe);
						keySet.add(prdIdMap.get((String) sObjectList[indexList[cnt]].get('Service_Item_Id__c'))
						           + '-' + stdPriceBookId
						           + '-' + OppPriceBookMap.get((string) sObjectList[indexList[cnt]].get('Contract__c')).split('-').get(1));
					}

					if (!keySet.contains(prdIdMap.get((String) sObjectList[indexList[cnt]].get('Service_Item_Id__c'))
					                     + '-' + OppPriceBookMap.get((string) sObjectList[indexList[cnt]].get('Contract__c')).split('-').get(0)
					                     + '-' + OppPriceBookMap.get((string) sObjectList[indexList[cnt]].get('Contract__c')).split('-').get(1))) {
						PriceBookEntry pbe = new PriceBookEntry();
						pbe.Product2Id = prdIdMap.get((String) sObjectList[indexList[cnt]].get('Service_Item_Id__c'));
						pbe.CurrencyIsoCode = OppPriceBookMap.get((string) sObjectList[indexList[cnt]].get('Contract__c')).split('-').get(1);
						pbe.Pricebook2Id = OppPriceBookMap.get((string) sObjectList[indexList[cnt]].get('Contract__c')).split('-').get(0);
						pbe.UnitPrice = 0;
						pbe.IsActive = true;
						pbeList.add(pbe);
						keySet.add(prdIdMap.get((String) sObjectList[indexList[cnt]].get('Service_Item_Id__c'))
						           + '-' + OppPriceBookMap.get((string) sObjectList[indexList[cnt]].get('Contract__c')).split('-').get(0)
						           + '-' + OppPriceBookMap.get((string) sObjectList[indexList[cnt]].get('Contract__c')).split('-').get(1));
					}
				} else {
					PriceBookEntry pbe = updatePriceBookEntryMap.get(((String) sObjectList[indexList[cnt]].get('Service_Item_Id__c'))
					                                                 + '-' + OppPriceBookMap.get((string) sObjectList[indexList[cnt]].get('Contract__c')).split('-').get(0)
					                                                 + '-' + OppPriceBookMap.get((string) sObjectList[indexList[cnt]].get('Contract__c')).split('-').get(1));
					pbe.IsActive = true;
					system.debug('--------pbe-------' + pbe);
					pbeList.add(pbe);
				}

				if (updatePriceBookEntryMap.containsKey(((String) sObjectList[indexList[cnt]].get('Service_Item_Id__c'))
				                                        + '-' + stdPriceBookId
				                                        + '-' + OppPriceBookMap.get((string) sObjectList[indexList[cnt]].get('Contract__c')).split('-').get(1))) {
					updatePriceBookEntryMap.get(((String) sObjectList[indexList[cnt]].get('Service_Item_Id__c'))
					                            + '-' + stdPriceBookId
					                            + '-' + OppPriceBookMap.get((string) sObjectList[indexList[cnt]].get('Contract__c')).split('-').get(1)).isActive = true;
					pbeList.add(updatePriceBookEntryMap.get(((String) sObjectList[indexList[cnt]].get('Service_Item_Id__c'))
					                                        + '-' + stdPriceBookId
					                                        + '-' + OppPriceBookMap.get((string) sObjectList[indexList[cnt]].get('Contract__c')).split('-').get(1)));
				}
			}
			system.debug('--------pbeList-------' + pbeList);
			Integer i = 0;
			for (Database.upsertResult result : Database.upsert(pbeList, false)) {
				system.debug(result.isSuccess() + '--------result.isSuccess()-------' + pbeList[i]);
				if (result.isSuccess()) {
					for (cnt = 0; cnt<indexList.size(); cnt++) {
						system.debug('--------split 1------' + OppPriceBookMap.get((string) sObjectList[indexList[cnt]].get('Contract__c')).split('-').get(1));
						system.debug('--------currency iso code------' + pbeList[i].CurrencyIsoCode);
						system.debug('--------split 0------' + OppPriceBookMap.get((string) sObjectList[indexList[cnt]].get('Contract__c')).split('-').get(0));
						system.debug('--------pricebook2Id------' + pbeList[i].PriceBook2Id);
						system.debug('--------service item id------' + prdIdMap.get((String) sObjectList[indexList[cnt]].get('Service_Item_Id__c')));
						system.debug('--------product2id------' + pbeList[i].Product2Id);
						if (OppPriceBookMap.get((string) sObjectList[indexList[cnt]].get('Contract__c')).split('-').get(1) == pbeList[i].CurrencyIsoCode &&
						    OppPriceBookMap.get((string) sObjectList[indexList[cnt]].get('Contract__c')).split('-').get(0) == pbeList[i].PriceBook2Id &&
						    prdIdMap.get((String) sObjectList[indexList[cnt]].get('Service_Item_Id__c')) == pbeList[i].Product2Id) {
							sObjectList[indexList[cnt]].put('PriceBookEntryId', result.getId());
							system.debug('--------prdIdMap-------' + sObjectList[indexList[cnt]].get('PriceBookEntryId'));
						}
					}
				}
				i++;
			}
		}

		system.debug('------responseMap------' + XMLUtility.responseMap);
		system.debug('------XMLUtility.uniqueIdentifier------' + XMLUtility.uniqueIdentifier);
		upsertRecord(interfaceName, 'OpportunityLineItem', sObjectList);


		List<Opportunity> updateOpList = new List<Opportunity> ();
		List<Opportunity> opList = [select Id, Name, Selling_Division__c, OwnerId, Opportunity_Product__c, Bill_to_Address__r.Country__c, Renewal_Lines_Count__c, Renewal_Status__c, (select Id, PricebookEntry.Product2.Type__c from OpportunityLineItems) from Opportunity where Renewal_Status__c = 'New'];
		for (Opportunity opp : opList) {
			if (opp.OpportunityLineItems != null) {
				String productGroup = '';
				if (opp.Selling_Division__c == 'GCCM') {
					for (OpportunityLineItem oppLiTm : opp.OpportunityLineItems) {
						String prdGroup = oppLiTm.PricebookEntry.Product2.Type__c.replaceAll('GC/CM-', '');
						if (productGroup == '') {
							productGroup = prdGroup;
						} else if (productGroup != prdGroup) {
							productGroup = 'Trimble';
							break;
						}
					}
				}
				system.debug(opp.Renewal_Lines_Count__c + '----------------' + opp.Id + '-----------------' + opp.OpportunityLineItems.size());
				if (opp.Renewal_Lines_Count__c == opp.OpportunityLineItems.size()) {
					opp.Renewal_Status__c = 'Ready To Create Proposal';
					if (opp.Selling_Division__c == 'MEP NA') opp.Renewal_Status__c = 'Complete';
					if (opp.Selling_Division__c == 'GCCM') opp.Name = opp.Name.replace('Trimble', productGroup);
					updateOpList.add(opp);
				}
			}
		}
		runOpportunityLineItemTrigger = false;
		runOpportunityTrigger = false;
		if (updateOpList.size()> 0) update updateOpList;
	}

	//Insert/Update Opporutnity and Opportunity Line Item
	public static void upsertRecord(String interfaceName, String sObjectType, List<sObject> objList) {
		if (objList.size()> 0) {
			Integer i = 0;
			List<sObject> sObjectList = XMLUtility.validateRequiredField(interfaceName, sObjectType, objList);
			system.debug('***************sObjectListSize()*******' + sObjectList.size());

			//Renewal 3.5 - Update existing Renewal Opportunity for MEPNA 
			Map<String, Id> mapKeyIds = new Map<String, Id> ();
			String uniqueKey = '';
			boolean bFlag = false;
			String sQuerFilter = '';
			if (sObjectType == 'Opportunity') {
				uniqueKey = 'Contract__c';
				sQuerFilter = ' and Account_Sub_Type__c =\'Renewal\' and Selling_Division__c = \'MEP NA\'';
			} else if (sObjectType == 'OpportunityLineItem') {
				uniqueKey = 'CoveredLineId__c';
				sQuerFilter = ' and Opportunity.Account_Sub_Type__c =\'Renewal\' and Opportunity.Selling_Division__c = \'MEP NA\'';
			}

			system.debug('-------uniqueKey----------' + uniqueKey);

			if (uniqueKey != '') {
				for (sObject obj : sObjectList) {
					if (obj.get(uniqueKey) != null) {
						mapKeyIds.put(String.valueOf(obj.get(uniqueKey)), null);
					}
				}

				set<string> setUniqueKeys = new set<string> ();
				setUniqueKeys = mapKeyIds.keySet();
				system.debug('-------setUniqueKeys----------' + setUniqueKeys);
				system.debug('-------uniqueKey----------' + 'select ID,' + uniqueKey + ' from ' + sObjectType + ' where ' + uniqueKey + ' in : setUniqueKeys' + sQuerFilter);
				for (sObject obj : Database.query('select ID,' + uniqueKey + ' from ' + sObjectType + ' where ' + uniqueKey + ' in : setUniqueKeys' + sQuerFilter)) {
					bFlag = true;
					mapKeyIds.put(String.valueOf(obj.get(uniqueKey)), (Id) obj.get('Id'));
				}
			}
			system.debug('-------bFlag----------' + bFlag);
			if (bFlag) {
				for (String sContractId : mapKeyIds.keyset()) {
					if (mapKeyIds.get(sContractId) != null) {
						for (sObject obj : sObjectList) {
							system.debug('-------obj----------' + obj.get('Name'));
							system.debug(String.valueOf(obj.get(uniqueKey)) + '-------result----------' + sContractId);
							if (String.valueOf(obj.get(uniqueKey)) == sContractId) {
								system.debug('-------result----------' + sContractId);
								obj.put('Id', mapKeyIds.get(sContractId));
							}
						}
					}
				}
			}

			String finalResponse = '';
			if (sObjectType == 'OpportunityLineItem') {
				runOpportunityLineItemTrigger = true;
			}
			else {
				runOpportunityLineItemTrigger = false;
			}
			runOpportunityTrigger = false;
			set<Id> oppIds = new set<Id> ();
			List<WS_Interface_Log__c> logList = new List<WS_Interface_Log__c> ();

			List<SObject> castRecords = (List<SObject>) Type.forName('List<' + sObjectType + '>').newInstance();
			castRecords.addAll(sObjectList);

			for (Database.UpsertResult result : Database.upsert(castRecords, false)) {
				system.debug('-------obj----------' + castRecords.get(i).get('Name'));
				system.debug('-------result----------' + result);
				system.debug('-------i++----------' + sObjectList.get(i));
				String uniqueIdentifierValue = (String) sObjectList.get(i).get(XMLUtility.uniqueIdentifier);
				system.debug('----unique----' + uniqueIdentifierValue + '\n----responseMap---' + XMLUtility.responseMap);
				system.debug('---------------result.isSuccess()---------' + result.isSuccess());
				system.debug(uniqueIdentifierValue + '---------------XMLUtility.responseMap---------' + XMLUtility.responseMap.keySet());
				if (result.isSuccess() && XMLUtility.responseMap.containsKey(uniqueIdentifierValue)) {
					system.debug('---------------finalResponse---------' + finalResponse);
					finalResponse = finalResponse + '<ROW>' + XMLUtility.responseMap.get(uniqueIdentifierValue);
					system.debug('---------------finalResponse---------' + finalResponse);
					finalResponse = finalResponse + additionalResponse(sObjectType);
					system.debug('---------------finalResponse---------' + finalResponse);
					finalResponse = finalResponse + '<STATUS>SUCCESS</STATUS><ERRORMESSAGE/></ROW>';
					system.debug('---------------finalResponse---------' + finalResponse);
					XMLUtility.setResultMap(uniqueIdentifierValue, finalResponse);
					finalResponse = '';
					system.debug('---------------finalResponse---------' + finalResponse);
					//}else if(XMLUtility.responseMap.containsKey(uniqueIdentifierValue)){
				} else if (!result.isSuccess()) {
					String msg = '';
					String erMsg = '';
					for (Database.Error er : result.getErrors()) {
						if (XMLUtility.responseMap.containsKey(uniqueIdentifierValue)) {
							msg += 'Error (' + er.getStatusCode() + '):' + er.getMessage();
							msg += '\r\n';
							erMsg += er.getMessage() + '\n';
						}
						finalResponse = finalResponse + '<ROW>' + XMLUtility.responseMap.get(uniqueIdentifierValue);
						finalResponse = finalResponse + additionalResponse(sObjectType);
						finalResponse = finalResponse + '<STATUS>FAILED</STATUS><ERRORMESSAGE>' + msg + '</ERRORMESSAGE></ROW>';
						system.debug(uniqueIdentifierValue + '------finalResponse------' + finalResponse);
					}
					XMLUtility.setResultMap(uniqueIdentifierValue, finalResponse);
					system.debug('-------XMLUtility----------' + XMLUtility.resultMap);

					if (erMsg != '') {
						logList.add(WS_Interface_Log.createLog('CreateRenewalOpportunityFromEBS', 'upsertRecord', erMsg,
						                                       msg, XMLUtility.responseMap.get(uniqueIdentifierValue)));
					}

					finalResponse = '';
					if ((sObjectType == 'OpportunityLineItem' ? sObjectList.get(i).get('OpportunityId') != null : false) &&
					    interfaceName == 'TNV_SFDC_OPPORTUNITY_EXT_PKG') {
						oppIds.add((Id) sObjectList.get(i).get('OpportunityId'));
					}
					system.debug('--error--OppIds--' + oppIds);
				}
				system.debug('-------i++----------' + i);
				i++;
			}
			if (logList.size() > 0) {
				insert logList;
			}

			system.debug('--OppIds--' + oppIds.size());
			if (oppIds.size() > 0) {
				UpdateRenewalStatusOfOpportunity(oppIds);
			}
		}
	}

	//Update renewal status to Failed if opportunity line item failed to create
	public static void UpdateRenewalStatusOfOpportunity(set<Id> oppIds) {
		List<Opportunity> oppList = new List<Opportunity> ();
		for (Id oppId : oppIds) {
			Opportunity opp = new Opportunity();
			opp.Id = oppId;
			opp.Renewal_Status__c = 'Failed';
			OppList.add(opp);
		}
		system.debug('--OppList--' + oppList.size());
		runOpportunityLineItemTrigger = false;
		runOpportunityTrigger = false;
		database.update(oppList);
	}

	//Configure response
	public static String additionalResponse(String sObjectType) {
		if (sObjectType == 'Opportunity') {
			return '<DATA_TYPE>H</DATA_TYPE>';
		} else if (sObjectType == 'OpportunityLineItem') {
			return '<DATA_TYPE>L</DATA_TYPE>';
		}
		return '';
	}

	//Populate Opportunity Owner, Name, Sell_Through__c etc on Renewal Opportunity
	public static void processRenewalOpporutnity(List<Opportunity> newOppList) {
		if (launchControl.get('processRenewalOpporutnity') < 1) {
			launchControl.put('processRenewalOpporutnity', 1);
			Map<String, Id> owners = new Map<String, Id> ();
			for (User usr :[select Id, Username, Email from User where Username IN :Renewal_Opportunity_Owner_Config__c.getAll().keySet() AND isActive = true]) {
				owners.put(usr.Username, usr.Id);
			}
			system.debug('----------owners-----------' + owners);
			Map<String, String> ownerMap = new Map<String, String> ();
			for (Renewal_Opportunity_Owner_Config__c config : Renewal_Opportunity_Owner_Config__c.getAll().values()) {
				if (config.ContractGroups__c != null && config.ContractGroups__c != '') {
					for (String sContractGroup : config.ContractGroups__c.split(','))
					ownerMap.put(config.Division__c + sContractGroup, config.Name);
				} else if (config.Countries__c == null || config.Countries__c == '') {
					ownerMap.put(config.Division__c, config.Name);
				} else {
					for (String str : config.Countries__c.split(',')) {
						ownerMap.put(config.Division__c + str.toUpperCase(), config.Name);
					}
				}
			}
			system.debug('----------ownerMap-----------' + ownerMap);
			system.debug('----------newOppList-----------' + newOppList);
			for (Opportunity opp : newOppList) {
				if (String.isNotBlank(opp.Staging__c)) {
					if (!opp.Name.contains(opp.Account_Name__c)) opp.Name = opp.Name + '-' + opp.Account_Name__c;
					opp.Sell_Through__c = opp.Sell_Through_Renewal__c;
					String country = (opp.BillToAccountCountry__c != null ? opp.BillToAccountCountry__c.toUpperCase() : '');
					String contractGroup = (opp.ContractGroup__c != null ? opp.ContractGroup__c.toUpperCase() : '');
					String priceListName = opp.Price_List_Name__c;
					system.debug('----------priceListName -----------' + (opp.Selling_Division__c + contractGroup));
					if (priceListName.contains('PROLIANCE')) {
						opp.OwnerId = owners.get(ownerMap.get('GCCM'));
					} else if (ownerMap.containsKey(opp.Selling_Division__c + contractGroup)) {
						opp.OwnerId = owners.get(ownerMap.get(opp.Selling_Division__c + contractGroup));
					} else if (ownerMap.containsKey(opp.Selling_Division__c + country)) {
						opp.OwnerId = owners.get(ownerMap.get(opp.Selling_Division__c + country));
					} else if (ownerMap.containsKey(opp.Selling_Division__c)) {
						opp.OwnerId = owners.get(ownerMap.get(opp.Selling_Division__c));
					} else if (ownerMap.containsKey('DEFAULT')) {
						opp.OwnerId = owners.get(ownerMap.get('DEFAULT'));
					}
				}
			}
		}
	}
}