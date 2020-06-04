public class LinkAccountController {
    public string EBSAccountId{get;set;}
    public transient string EBSAccAddresses{get;set;}
    public transient string EBSAccTableCaption{get;set;}
    public string FCHAccountId{get;set;}
    public transient string SFDCAccTableCaption{get;set;}
    public string SFDCAccountId{get;set;}
    public transient string SFDCAccountName{get;set;}
    public transient string SFDCAccAddresses{get;set;} 
    public string selectedAcc{get;set;}
    public string selectedAddresses{get;set;}
    public string JSONmergeIds {get; set;}
    private static JSONGenerator gen;
    public static boolean LinkAccountCall = false;
    public string statusMessage{get;set;}
    public List<LinkedAddress> linkRds;
    public LinkAccountController(){
        EBSAccountId= '';
        SFDCAccountId = '';
        JSONmergeIds = '';
        SFDCAccountId = Apexpages.currentPage().getParameters().get('accId');
        EBSAccountId = '';
        if(EBSAccountId != null && EBSAccountId != '')searchEBSAccount();
        if(SFDCAccountId != null && SFDCAccountId != '')searchSFDCAccount();
    }
    
    public void searchEBSAccount(){
        if(EBSAccountId != null && EBSAccountId != ''){
            try{
                trimblecorpComCmdm_v1.CommonData_element response;
                if(!test.isRunningTest()){
                    xmlnsOracleComCusthubnewversionTnvcu_v1.tnvCustGetFCHDetailsByEANProcess_pt searchFCHAcc = new xmlnsOracleComCusthubnewversionTnvcu_v1.tnvCustGetFCHDetailsByEANProcess_pt();
                    response = searchFCHAcc.process(EBSAccountId,'','');
                }else{
                    response = new trimblecorpComCmdm_v1.CommonData_element();
                    response.OrganizationParty = new trimblecorpComCmdm_v1.OrganizationPartyType();
                    response.OrganizationParty.AccountName = 'test';
                    response.OrganizationParty.FchPartyID = '11111';
                    response.OrganizationParty.EnterpriseAccountNumber = '12345';
                    response.OrganizationParty.PartySite = new List<trimblecorpComCmdm_v1.PartySiteType>();
                    
                    trimblecorpComCmdm_v1.PartySiteType partySite = new trimblecorpComCmdm_v1.PartySiteType();
                    response.OrganizationParty.PartySite.add(partySite);
                }
                system.debug('----------response.OrganizationParty---------' + response.OrganizationParty);
                if(response.OrganizationParty != null){
                    EBSAccTableCaption = response.OrganizationParty.AccountName + ' (Enterprise Account Number : ' + response.OrganizationParty.EnterpriseAccountNumber +
                        '   |   FCH Party Id : ' + response.OrganizationParty.FchPartyID + ')' ;
                    FCHAccountId = response.OrganizationParty.FchPartyID;
                    gen = JSON.createGenerator(true);
                    gen.writeStartArray();
                    system.debug('----------response.OrganizationParty.PartySite---------' + response.OrganizationParty.PartySite);
                    if(response.OrganizationParty.PartySite != null){
                        for(trimblecorpComCmdm_v1.PartySiteType add : response.OrganizationParty.PartySite){
                            gen.writeStartObject();
                            gen.writeStringField('FCH_Address_Id', (add.FchPartySiteID == null ? '' : add.FchPartySiteID));
                            gen.writeStringField('EBS_Address_Id', (add.EnterpriseAddressNumber == null ? '' : add.EnterpriseAddressNumber));
                            gen.writeStringField('Street_1', (add.AddressLine1 == null ? '' : add.AddressLine1));
                            gen.writeStringField('Street_2', (add.AddressLine2 == null ? '' : add.AddressLine2));
                            gen.writeStringField('Street_3', (add.AddressLine3 == null ? '' : add.AddressLine3));
                            gen.writeStringField('Street_4', (add.AddressLine4 == null ? '' : add.AddressLine4));
                            gen.writeStringField('City', (add.City == null ? '' : add.City));
                            gen.writeStringField('State', (add.State == null ? '' : add.State));
                            gen.writeStringField('Country', (add.Country == null ? '' : add.Country));
                            gen.writeStringField('County', (add.County == null ? '' : add.County));
                            gen.writeStringField('Zip', (add.Zip == null ? '' : add.Zip));
                            gen.writeEndObject();
                        }
                        gen.writeEndArray();
                        EBSAccAddresses = gen.getAsString();
                        system.debug('----------EBSAccAddresses--------' + EBSAccAddresses);
                    }else{
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Integration Search : No related addree found for Account ' + response.OrganizationParty.AccountName + '.'));
                    }
                }else{
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Integration Search : No Account exist with ' + EBSAccountId + ' Enterprise Account Number.'));
                }
                system.debug('----------response---------' + response);
            }catch(Exception ex){
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));               
            }
        }else{
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Integration Search : Please enter valid Enterprise Account Number.'));               
        }
        system.debug('---------EBSAccAddresses---------' + EBSAccAddresses);
    }
    
    public void searchSFDCAccount(){
        if(SFDCAccountId != null && SFDCAccountId != ''){
            for(Account acc : [select Id,Name,(Select Id,Name,Address_Line1__c,Address_Line2__c,Address_Line3__c,Address_Line4__c, 
                              City__c,Country__c,County__c,State__c,Zip__c,FCH_Party_Site_ID__c,Enterprise_Address_Number__c
                                  from Account.Addresses__r where Account__c =: SFDCAccountId and FCH_Party_Site_ID__c = null) from Account where 
                                        iD =: SFDCAccountId and FCH_Party_ID__c = null]){
                SFDCAccountName = acc.Name;                  
                SFDCAccTableCaption = SFDCAccountName + ' (Account SFDC Id : ' + acc.Id + ')';
                if(acc.Addresses__r.size() > 0){
                    gen = JSON.createGenerator(true);
                    gen.writeStartArray();
            
                    for(Address__c add : acc.Addresses__r){
                        gen.writeStartObject();
                        gen.writeStringField('SFDC_Id', (add.Id == null ? '' : add.Id));
                        gen.writeStringField('Street_1', (add.Address_Line1__c == null ? '' : add.Address_Line1__c));
                        gen.writeStringField('Street_2', (add.Address_Line2__c == null ? '' : add.Address_Line2__c));
                        gen.writeStringField('Street_3', (add.Address_Line3__c == null ? '' : add.Address_Line3__c));
                        gen.writeStringField('Street_4', (add.Address_Line4__c == null ? '' : add.Address_Line4__c));
                        gen.writeStringField('City', (add.City__c == null ? '' : add.City__c));
                        gen.writeStringField('State', (add.State__c == null ? '' : add.State__c));
                        gen.writeStringField('Country', (add.Country__c == null ? '' : add.Country__c));
                        gen.writeStringField('County', (add.County__c == null ? '' : add.County__c));
                        gen.writeStringField('Zip', (add.Zip__c == null ? '' : add.Zip__c));
                        gen.writeEndObject();
                    }
                    gen.writeEndArray();
                    SFDCAccAddresses = gen.getAsString();
                }else{
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'SFDC : No related addree found for selected Account.'));
                }
            }
        }else{
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'SFDC : Please select Account.'));               
        }
        system.debug('---------SFDCAccAddresses---------' + SFDCAccAddresses);
    }
    
    public void makeCallOut(){
        try{
            system.debug('--------FCHAccountId---------' + FCHAccountId);
            List<xmlnsOracleComFchTnvcusbpelfchosrsyn_v1.OriginalSystemReferenceType> requestData = new List<xmlnsOracleComFchTnvcusbpelfchosrsyn_v1.OriginalSystemReferenceType>();
            xmlnsOracleComFchTnvcusbpelfchosrsyn_v1.OriginalSystemReferenceType data = new xmlnsOracleComFchTnvcusbpelfchosrsyn_v1.OriginalSystemReferenceType();
            data.OrigSystem = 'SFDC';
            data.OrigSystemReference = SFDCAccountId;
            data.OwnerTableName = 'HZ_PARTIES';
            data.OwnerTableId = Long.valueOf(FCHAccountId);
            data.Status = 'A';
            data.CreatedByModule = 'TNV_CMDM';
            requestData.add(data);
            system.debug('--------data.OrigSystemReference---------' + data.OrigSystemReference);
            
            system.debug('--------JSONmergeIds---------' + JSONmergeIds);
            JSONParser parser = JSON.createParser(JSONmergeIds);
            linkRds = (List<LinkedAddress>)parser.readValueAs(List<LinkedAddress>.class);
            system.debug('--deserialized--'+linkRds);   
            if(linkRds.size() > 0){
                for(LinkedAddress rd : linkRds){
                    data = new xmlnsOracleComFchTnvcusbpelfchosrsyn_v1.OriginalSystemReferenceType();
                    data.OrigSystem = 'SFDC';
                    data.OrigSystemReference = rd.SFDC_Id;
                    data.OwnerTableName = 'HZ_PARTY_SITES';
                    data.OwnerTableId = Long.valueOf(rd.FCH_Address_Id);
                    data.Status = 'A';
                    data.CreatedByModule = 'TNV_CMDM';
                    requestData.add(data);
                }
            }
            
            xmlnsOracleComCmdmnewTnvcusbpelfchos_v1.FCHOSRService_pt request = new xmlnsOracleComCmdmnewTnvcusbpelfchos_v1.FCHOSRService_pt();
            request.timeout_x = 60000;
            xmlnsOracleComFchTnvcusbpelfchosrsyn_v1.processResponse_element response;
            if(!test.isRunningTest())response = request.process('Create', requestData);
            else{
                response = new xmlnsOracleComFchTnvcusbpelfchosrsyn_v1.processResponse_element();
                response.status = 'Success';
            } 
            
            system.debug('--------response--------' + response);
            if(response.status != 'Success'){
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, response.errorMessage));
            }else{
                statusMessage = 'Success';
                LinkAccountCall = true;
                List<Address__c> updateAddrsList = new List<Address__c>();
                Account acc = new Account();
                acc.Id = SFDCAccountId;
                acc.FCH_Party_ID__c = FCHAccountId;
                acc.Enterprise_Party_Number__c = EBSAccountId;
                update acc;    
                
                if(linkRds.size() > 0){
                    for(LinkedAddress addWrap : linkRds){
                        Address__c add = new Address__c();
                        add.Id = addWrap.SFDC_ID;
                        add.FCH_Party_Site_Id__c = addWrap.FCH_Address_Id;
                        add.Enterprise_Address_Number__c = addWrap.EBS_Address_Id;
                        updateAddrsList.add(add);
                    }
                    
                    if(updateAddrsList.size() > 0){
                        update updateAddrsList;
                    }
                }
            }
        }catch(Exception ex){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
    }
    
    public void Save(){
        try{
            if(EBSAccountId != null && EBSAccountId != '')searchEBSAccount();
            if(SFDCAccountId != null && SFDCAccountId != '')searchSFDCAccount();
            statusMessage = 'Link process completed successfully.';
        }catch(Exception ex){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
    }
    
    public class LinkedAddress{
        public string FCH_Address_Id;
        public string EBS_Address_Id;
        public string SFDC_Id;
    }
}