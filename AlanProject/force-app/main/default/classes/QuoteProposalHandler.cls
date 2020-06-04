/**
 * Company     : Trimble Software Technology Pvt Ltd.,
 * Description : Proposal trigger handler class 
 * History     :  
 
 * [16.10.2014] Ankur Patel  Created
 * [19.09.2018] Suresh Babu Murugan  Modified : TT-139229 Default Care Pack Term for Plancal Quotes
 * [25.03.2019] Suresh Babu Murugan  Modified : APP-3806 : update Lines if Quote Address/Account changed
 */

public Class QuoteProposalHandler {
    public static Map<String, Integer> launchControl;

    // Static initialize
    static {
        resetLaunchControl();
    }

    // Reset Trigger control (e.g. for testing)
    public static void resetLaunchControl() {
        launchControl = new Map<String, Integer> ();
        launchControl.put('makeProposalPrimary', 0);
        launchControl.put('validateRenewalProposal', 0);
        launchControl.put('defaultCarePackTerm', 0);
        launchControl.put('syncPropsalLinesAddressAndAccounts', 0);
    }

    //If proposal is clonned then make original Proposal as Obsolete
    public static void makeQuoteProposalObsolete(list<Apttus_Proposal__Proposal__c> proposalList, Map<Id, Apttus_Proposal__Proposal__c> propposalMap) {
        set<String> nameList = new set<String> ();
        List<Apttus_Proposal__Proposal__c> updateProposalList = new List<Apttus_Proposal__Proposal__c> ();
        for (Apttus_Proposal__Proposal__c temp : proposalList) {
            system.debug(temp.Name + '----------temp.Clone_Id__c------------' + temp.Clone_Id__c);
            if (temp.Clone_Id__c != temp.Name && temp.Clone_Id__c != null) {
                nameList.add(temp.Clone_Id__c);
                temp.Clone_Id__c = temp.Name;
                temp.Apttus_Proposal__Primary__c = true;
            }
            if (temp.Obsolete_Quote__c) {
                temp.Obsolete_Quote__c = false;
            }
        }
        system.debug('----------nameList------------' + nameList);
        if (nameList.size() > 0) {
            for (Apttus_Proposal__Proposal__c temp :[select Id from Apttus_Proposal__Proposal__c where
                 NAme in :nameList and Obsolete_Quote__c != true]) {
                temp.Obsolete_Quote__c = true;
                temp.Apttus_Proposal__Primary__c = false;
                system.debug('----------temp------------' + temp);
                updateProposalList.add(temp);
            }
            if (updateProposalList.size() > 0) {
                system.debug('----------updateProposalList------------' + updateProposalList);
                update updateProposalList;
            }
        }
    }


    public static void SyncWithOpportunity(list<Apttus_Proposal__Proposal__c> proposalList, Map<Id, Apttus_Proposal__Proposal__c> propposalMap) {
        for (Apttus_Proposal__Proposal__c Proposal : proposalList) {
            system.debug(Proposal.Apttus_QPApprov__Approval_Status__c + '----------updateProposalList------------' + Proposal.Apttus_Proposal__Primary__c);
            if (Proposal.Apttus_Proposal__Primary__c == True && Proposal.Apttus_Proposal__Approval_Stage__c == 'Approved' && checkRecursive.SyncisFirstRun()) {
                checkRecursive.setSyncFirstRunFalse();
                ApexPages.StandardController sc = new ApexPages.StandardController(Proposal);
                SyncWithOpportunityExt syncOpp = new SyncWithOpportunityExt(sc);
                syncOpp.UpdateOppty();
            }
        }
    }


    public static void proposalAccessValidation(list<Apttus_Proposal__Proposal__c> proposalList) {
        if ([select Division__c from User where id = :userinfo.getUserId()].Division__c == 'RE&WS') {

            set<Id> roleIds = new set<Id> ();
            for (UserRole r :[select Id, ParentRoleId from UserRole where ParentRoleId = :
            [select ParentRoleId from UserRole where Id = :userinfo.getUserRoleId()].ParentRoleId]) {
                roleIds.add(r.Id);
            }
            system.debug('----------roleIds------------' + roleIds);
            for (Apttus_Proposal__Proposal__c Proposal : proposalList) {
                system.debug(roleIds + '----------roleIds------------' + Proposal.Owner_s_Role_Id__c);
                if (roleIds.contains(Proposal.Owner_s_Role_Id__c) && proposal.ownerID != userinfo.getUserId()) {
                    proposal.addError('Insufficient Priviledge.');
                }
            }
        }
    }

    public static void makeProposalPrimary(List<Apttus_Proposal__Proposal__c> proposalList, Map<Id, Apttus_Proposal__Proposal__c> oldProposalMap) {
        if (launchControl.get('makeProposalPrimary') < 1) {
            launchControl.put('makeProposalPrimary', launchControl.get('makeProposalPrimary') + 1);
            List<Apttus_Proposal__Proposal__c> updateProposalList = new List<Apttus_Proposal__Proposal__c> ();
            set<Id> oppIds = new set<Id> ();
            for (Apttus_Proposal__Proposal__c proposal : proposalList) {
                if ((oldProposalMap.size() > 0 ? proposal.Apttus_Proposal__Primary__c != oldProposalMap.get(proposal.Id).Apttus_Proposal__Primary__c : true) && proposal.Apttus_Proposal__Primary__c) {
                    oppIds.add(proposal.Apttus_Proposal__Opportunity__c);
                    proposal.Obsolete_Quote__c = false;
                }
            }

            for (Apttus_Proposal__Proposal__c proposal :[select Id from Apttus_Proposal__Proposal__c where Apttus_Proposal__Opportunity__c in :oppIds and Id not in :oldProposalMap.keySet()
                 and Apttus_Proposal__Primary__c = true]) {
                proposal.Obsolete_Quote__c = true;
                proposal.Apttus_Proposal__Primary__c = false;
                updateProposalList.add(proposal);
            }

            if (updateProposalList.size() > 0) {
                update updateProposalList;
            }
        }
    }

    //Only System Administrator and Data Administrator profile user can delete Renewal Proposal
    public static void validateRenewalProposal(List<Apttus_Proposal__Proposal__c> oldProposalList) {
        if (launchControl.get('validateRenewalProposal') < 1) {
            launchControl.put('validateRenewalProposal', launchControl.get('validateRenewalProposal') + 1);
            for (Apttus_Proposal__Proposal__c Proposal : oldProposalList) {
                String profileName = [select Name from Profile where Id = :Userinfo.getProfileId()].Name;
                Id EBSAPIUserId = [SELECT Id, Name FROM User WHERE Name = 'EBS API User' limit 1].Id;
                system.debug('Proposal.CreatedBy.Name ===>' + Proposal.CreatedBy.Name);
                if (Proposal.Is_Renewal_Proposal__c && Proposal.CreatedById == EBSAPIUserId) {
                    if (profileName != 'System Administrator' && profileName != 'Data Administrator') {
                        Proposal.addError('Renewal Proposal cannot be deleted.');
                    }
                }
                else {
                    if (Proposal.Apttus_Proposal__Approval_Stage__c == 'Order Submitted' && !profileName.contains('Administrator')) {
                        Proposal.addError('You do not have the permission to delete this quote. Please contact your admin for more info.');
                    }
                    else if (Proposal.CreatedById != Userinfo.getUserId() && !profileName.contains('Administrator') && !profileName.contains('Sales Ops')) {
                        Proposal.addError('You do not have the permission to delete this quote. Please contact your admin for more info.');
                    }
                }
            }
        }
    }

    public static void defaultCarePackTerm(List<Apttus_Proposal__Proposal__c> newProposalList) {
        if (launchControl.get('defaultCarePackTerm') < 1) {
            launchControl.put('defaultCarePackTerm', launchControl.get('defaultCarePackTerm') + 1);

            Map<Id, Integer> mapCarePackItemCount = new Map<Id, Integer> ();
            Map<Id, String> mapQuoteCustomerType = new Map<Id, String> ();
            Set<Id> setProposalIDs = new Set<Id> ();
            Boolean isTIBVQuote = false;
            for (Apttus_Proposal__Proposal__c proposal : newProposalList) {
                if (proposal.Pricelist_Name__c != Null && proposal.Pricelist_Name__c.startsWith('TIBV CH') && proposal.Count_of_Proposal_Term__c == 0 && proposal.Custom_T_C__c == false) {
                    mapCarePackItemCount.put(proposal.Id, 0);
                    setProposalIDs.add(proposal.Id);
                    isTIBVQuote = true;
                }
            }

            if (isTIBVQuote) {
                List<Apttus_Proposal__Proposal_Line_Item__c> lstProposalLineItems = [SELECT Id, Product_Code__c, Apttus_Proposal__Proposal__c, Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__r.Type FROM Apttus_Proposal__Proposal_Line_Item__c WHERE Apttus_Proposal__Proposal__c IN :setProposalIDs AND(Product_Code__c LIKE '%CP-H' OR Product_Code__c LIKE '%CP-U' OR Product_Code__c LIKE '%CP-HU' OR Product_Code__c LIKE '%CP-T')];
                List<Term__c> TermtoUpdate = [SELECT Id, Name, Proposal_Type__c, Description__c, Customer_Type__c, Term_Name__c, Related_Product_Category__c, Editable__c, Title__c, Sequence__c FROM Term__c WHERE Term_Name__c IN('CHAF-10', 'CHQF-6', 'CHA-10', 'CHQ-6') AND Title__c = 'Care Pack'];
                List<Proposal_Term__c> lstTermUpdate = new List<Proposal_Term__c> ();

                for (Apttus_Proposal__Proposal_Line_Item__c pLineItem : lstProposalLineItems) {
                    if (mapCarePackItemCount.containsKey(pLineItem.Apttus_Proposal__Proposal__c)) {
                        Integer cCount = mapCarePackItemCount.get(pLineItem.Apttus_Proposal__Proposal__c) + 1;
                        mapCarePackItemCount.put(pLineItem.Apttus_Proposal__Proposal__c, cCount);
                    }
                    mapQuoteCustomerType.put(pLineItem.Apttus_Proposal__Proposal__c, pLineItem.Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__r.Type);
                }
                for (Apttus_Proposal__Proposal__c proposal : newProposalList) {
                    if (mapCarePackItemCount.containsKey(proposal.Id) && mapCarePackItemCount.get(proposal.Id) > 0) {

                        // Insert Term
                        String CustType = (mapQuoteCustomerType.containsKey(proposal.Id) ? mapQuoteCustomerType.get(proposal.Id).substringBefore(' ') : '');
                        Integer index = 0;
                        for (Term__c trm : TermtoUpdate) {
                            Proposal_Term__c pt = new Proposal_Term__c();
                            pt.Name = trm.Term_Name__c;
                            pt.Title__c = trm.Title__c;
                            pt.Description__c = trm.Description__c;
                            pt.Related_Product_Category__c = trm.Related_Product_Category__c;
                            pt.Quote_Proposal_ID__c = proposal.Id;
                            pt.Order_Number__c = index;
                            pt.EditableTerm__c = trm.Editable__c;
                            index++;

                            if (trm.Term_Name__c == 'CHA-10' && CustType == trm.Customer_Type__c) {
                                lstTermUpdate.add(pt);
                            }
                            else if (trm.Term_Name__c != 'CHA-10') {
                                lstTermUpdate.add(pt);
                            }
                        }
                    }
                }
                if (lstTermUpdate.size() > 0) {
                    insert lstTermUpdate;
                }
            }
        }
    }

    /*
     * This method used to sync Bill To, Ship To Address/Account to Quote Lines & Cart lines when Quote details are changed.
     */
    public static void syncPropsalLinesAddressAndAccounts(List<Apttus_Proposal__Proposal__c> lstProposals, Map<Id, Apttus_Proposal__Proposal__c> mapOldProposals) {
        if (launchControl.get('syncPropsalLinesAddressAndAccounts') < 1) {
            launchControl.put('syncPropsalLinesAddressAndAccounts', launchControl.get('syncPropsalLinesAddressAndAccounts') + 1);

            Set<Id> setPropodalIds = new Set<Id> (); // This set contains the Proposal IDs, those are Finalized
            Map<Id, Id> mapBillToAddress = new Map<Id, Id> ();
            Map<Id, Id> mapShipToAddress = new Map<Id, Id> ();
            List<Apttus_Config2__LineItem__c> lstUPDATEConfigLineItems = new List<Apttus_Config2__LineItem__c> ();
            List<Apttus_Proposal__Proposal_Line_Item__c> lstUPDATEProposalLineItems = new List<Apttus_Proposal__Proposal_Line_Item__c> ();

            for (Apttus_Proposal__Proposal__c prop : lstProposals) {
                if (prop.Apttus_QPConfig__ConfigurationFinalizedDate__c != null && prop.PriceList_Division__c == 'MEP NA' && prop.Bill_to_Address__c != null && prop.Ship_to_Address1__c != null &&
                (mapOldProposals.get(prop.Id).Bill_to_Address__c != prop.Bill_to_Address__c || mapOldProposals.get(prop.Id).Ship_to_Address1__c != prop.Ship_to_Address1__c)) {
                    setPropodalIds.add(prop.Id);
                    mapBillToAddress.put(prop.Id, prop.Bill_to_Address__c);
                    mapShipToAddress.put(prop.Id, prop.Ship_to_Address1__c);

                    prop.Tax__c = null;
                    prop.Validate_Status__c = false;
                    prop.Address_Changed__c = false;
                    prop.Quote_Validated__c = false;
                }
            }
            if (setPropodalIds.size() > 0) {
                Map<Id, Id> mapProductConfigs = new Map<Id, Id> ();
                // Update latest Product Configuration's Line Items.
                List<Apttus_Config2__ProductConfiguration__c> lstProductConfigs = [SELECT Id, Apttus_QPConfig__Proposald__c, Apttus_Config2__Status__c, Apttus_Config2__VersionNumber__c FROM Apttus_Config2__ProductConfiguration__c WHERE Apttus_QPConfig__Proposald__c IN :setPropodalIds AND Apttus_Config2__Status__c != 'Superseded' ORDER BY Apttus_Config2__VersionNumber__c ASC];
                for (Apttus_Config2__ProductConfiguration__c pConfig : lstProductConfigs) {
                    mapProductConfigs.put(pConfig.Apttus_QPConfig__Proposald__c, pConfig.Id);
                }

                List<Apttus_Config2__LineItem__c> lstConfigLines = [SELECT Id, Bill_To_Address__c, Ship_To_Address1__c, Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__ConfigurationId__c IN :mapProductConfigs.values()];
                for (Apttus_Config2__LineItem__c cLine : lstConfigLines) {
                    Boolean isReadytoUpdate = false;
                    if (mapBillToAddress.containsKey(cLine.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c)) {
                        cLine.Bill_To_Address__c = mapBillToAddress.get(cLine.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c);
                        isReadytoUpdate = true;
                    }
                    if (mapShipToAddress.containsKey(cLine.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c)) {
                        cLine.Ship_To_Address1__c = mapShipToAddress.get(cLine.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c);
                        isReadytoUpdate = true;
                    }
                    if (isReadytoUpdate) {
                        lstUPDATEConfigLineItems.add(cLine);
                    }
                }

                List<Apttus_Proposal__Proposal_Line_Item__c> lstPropLineItems = [SELECT Name, Bill_To_Address__c, Ship_To_Address1__c, Apttus_Proposal__Proposal__c FROM Apttus_Proposal__Proposal_Line_Item__c WHERE Apttus_Proposal__Proposal__c IN :setPropodalIds];
                for (Apttus_Proposal__Proposal_Line_Item__c pLine : lstPropLineItems) {
                    Boolean isReadytoUpdate = false;
                    if (mapBillToAddress.containsKey(pLine.Apttus_Proposal__Proposal__c)) {
                        pLine.Bill_To_Address__c = mapBillToAddress.get(pLine.Apttus_Proposal__Proposal__c);
                        isReadytoUpdate = true;
                    }
                    if (mapShipToAddress.containsKey(pLine.Apttus_Proposal__Proposal__c)) {
                        pLine.Ship_To_Address1__c = mapShipToAddress.get(pLine.Apttus_Proposal__Proposal__c);
                        isReadytoUpdate = true;
                    }
                    if (isReadytoUpdate) {
                        lstUPDATEProposalLineItems.add(pLine);
                    }
                }
                if (lstUPDATEConfigLineItems.size() > 0) {
                    LineItemHelper_v1.launchControl.put('validateAssetQuantity', 1);
                    LineItemHelper_v1.launchControl.put('configLineItem', 1);
                    RecursiveTriggerUtility.recursiveCallLineItemTrigger = true;
                    update lstUPDATEConfigLineItems;
                }
                if (lstUPDATEProposalLineItems.size() > 0) {
                    LineItemHelper_v1.launchControl.put('validateAssetQuantity', 1);
                    LineItemHelper_v1.launchControl.put('configLineItem', 1);
                    RecursiveTriggerUtility.isProposalLineItemRecursive = false;
                    RecursiveTriggerUtility.recursiveCallLineItemTrigger = true;
                    update lstUPDATEProposalLineItems;
                }
            }
        }
    }
}