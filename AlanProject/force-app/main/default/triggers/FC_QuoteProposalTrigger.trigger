trigger FC_QuoteProposalTrigger on Apttus_Proposal__Proposal__c (before insert, before update, after update) {
    private static final String REST_OF_WORLD = 'Rest of World';
    Map<Id, Apttus_Proposal__Proposal__c> enhancedProps;
    Map<String, Country_To_BU_Map__c> countryBUMap;
    Map<String, Reseller_LE_and_OU__c> resellerBUMap;
    
    if (Trigger.isBefore) {
        bulkBefore();
        for (Apttus_Proposal__Proposal__c prop : Trigger.new) {
            setPPMBusinessUnit(prop);
            if (String.isBlank(prop.Revenue_Arrangement_Number__c)) {
                prop.Revenue_Arrangement_Number__c = defaultArrangementNumber(prop);
            }
        }
    }
    
    if (Trigger.isAfter) {
        bulkAfter();
        // Only do one record.  If more than one, then do not make callout
        if (Trigger.new.size() == 1) {
            Apttus_Proposal__Proposal__c oldProposal = Trigger.old[0];
            Apttus_Proposal__Proposal__c newProposal = Trigger.new[0];
            if (oldProposal.Revenue_Arrangement_Number__c != newProposal.Revenue_Arrangement_Number__c && oldProposal.Revenue_Arrangement_Number__c!=Null && 
                String.isNotBlank(newProposal.Revenue_Arrangement_Number__c)) {
                    FC_QuoteProposalHandler.updatePPM(newProposal.Id);
                    
                    if (!Test.isRunningTest()) {
                        // CreditCheckEmailService Revenue = new CreditCheckEmailService();
                        CreditCheckEmailService.CallEBSForSubmitOrder(newProposal.Id,'3');
                    }
                }
        }
    }
    
    private void bulkBefore() {
        countryBUMap = Country_To_BU_Map__c.getAll();
        resellerBUMap = Reseller_LE_and_OU__c.getAll();
        
        enhancedProps = new Map<Id, Apttus_Proposal__Proposal__c>([select Initial_Quote_Proposal__r.Name,Apttus_QPConfig__PriceListId__r.Division__c,Apttus_QPConfig__BillToAccountId__r.Name,
                                                                   Initial_Quote_Proposal__r.Revenue_Arrangement_Number__c,Bill_to_Address__r.Country__c,Ship_to_Address1__r.Country__c,
                                                                   Apttus_QPConfig__BillToAccountId__r.EBS_Legal_Entity__c,Apttus_QPConfig__BillToAccountId__r.Enterprise_Party_Number__c,
                                                                   Apttus_QPConfig__BillToAccountId__c from Apttus_Proposal__Proposal__c where Id IN: Trigger.new]);
        
        system.debug('>>>>>>>>>CountryValueBefore>>>>>'+trigger.new.get(0).Bill_to_Address__c);
    }
    
    private void bulkAfter() {
        system.debug('>>>>>>>>>CountryValueAfter>>>>>'+trigger.new.get(0).Bill_to_Address__c);
    }
    
    private void setPPMBusinessUnit(Apttus_Proposal__Proposal__c proposal) {
        Apttus_Proposal__Proposal__c enhancedProposal = enhancedProps.get(proposal.Id);
        system.debug('enhancedProposal >>>>'+enhancedProposal);
        String billToCountry, shipToCountry;
        String billToLegalEntity;
        String PriceListDivision;
        //String billToAccountName;
        String billToAccountID;
        Map<String,Reseller_LE_and_OU__c> mapResellerLEOU = new Map<String,Reseller_LE_and_OU__c>(); 
        if(enhancedProposal != null){
            try {
                system.debug('--------------------' + proposal);
                for(Reseller_LE_and_OU__c reseller : resellerBUMap.values()){
                    mapResellerLEOU.put(reseller.Account_Id__c, reseller);
                }
                system.debug('--------------------' + proposal.Bill_to_Address__c);
                //billToAccountName = enhancedProposal.Apttus_QPConfig__BillToAccountId__r.Name;
                billToAccountID = enhancedProposal.Apttus_QPConfig__BillToAccountId__c;
                billToLegalEntity = enhancedProposal.Apttus_QPConfig__BillToAccountId__r.EBS_Legal_Entity__c;
                PriceListDivision = enhancedProposal.Apttus_QPConfig__PriceListId__r.Division__c;
                Map<Id,Address__c> addressMap = new Map<Id,Address__c>([select ID,Country__c from Address__c where Id =: proposal.Bill_to_Address__c or Id =: proposal.Ship_to_Address1__c]);
                if(addressMap.containsKey(proposal.Bill_to_Address__c))billToCountry = addressMap.get(proposal.Bill_to_Address__c).Country__c;
                if(addressMap.containsKey(proposal.Ship_to_Address1__c))shipToCountry = addressMap.get(proposal.Ship_to_Address1__c).Country__c;
                
            } catch (System.NullPointerException ex) {
                //billToAccountName = null;
                billToAccountID = null;
                billToCountry = null;
                shipToCountry = null;
                billToLegalEntity = null;
            }
        }
        
        // Additional COnditions added for MEP NA 
        if(PriceListDivision != Null && PriceListDivision != '' && String.isNotBlank(billToCountry) && PriceListDivision == 'MEP NA' && billToCountry == 'United States')
        {
         proposal.Legal_Entity_CFD__c = 'Trimble Inc.';
         
        }
       else if(PriceListDivision != Null && PriceListDivision != '' && String.isNotBlank(billToCountry) && PriceListDivision == 'MEP NA' && billToCountry != 'United States')
        {
         proposal.Legal_Entity_CFD__c = 'Trimble Europe B.V.';
         
        } 
        if(mapResellerLEOU.containsKey(billToAccountID)){
            proposal.Legal_Entity_CFD__c = mapResellerLEOU.get(billToAccountID).Legal_Entity__c;
        }else if(String.isNotBlank(billToLegalEntity)){
            proposal.Legal_Entity_CFD__c = billToLegalEntity;
        }else {
            if(String.isNotBlank(billToCountry) && billToCountry == shipToCountry) {
                Country_To_BU_Map__c record = countryBUMap.get(billToCountry);
                // Bill To and Ship To are same and not in Lookup 
                if (record == null) {
                    record = countryBUMap.get(REST_OF_WORLD);
                }
                if (record != null) {
                    proposal.Legal_Entity_CFD__c = record.Legal_Entity__c;
                }
            }
            // Bill To and Ship To are different and Not in Lookup 
            else 
            {
                Country_To_BU_Map__c record = countryBUMap.get(REST_OF_WORLD);
                if(record != null)
                proposal.Legal_Entity_CFD__c = record.Legal_Entity__c;
            }
        }
    }
    
    private String defaultArrangementNumber(Apttus_Proposal__Proposal__c prop) {
        if (prop.Initial_Quote_Proposal__r.Revenue_Arrangement_Number__c != null) {
            return enhancedProps.get(prop.Id).Initial_Quote_Proposal__r.Revenue_Arrangement_Number__c;   
        } else {
            return prop.Name;
        }
        return null;
    }
}