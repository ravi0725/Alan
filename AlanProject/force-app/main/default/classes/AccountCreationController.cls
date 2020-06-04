/*****************************************************************************************
    Name    : AccountCreationController 
    Desc    : Used in the Account creation page which will search for Accounts from SFDC and customer data hub and also
              help to create a new account if not found
                            
Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Vikram Mandla       11/11/2013          Created
Sunay Prasad R K    24/02/2014          Modified
Pardep Rao          Mar/22/2014         Modified (Added  displaycreateselected=true; on search account)
******************************************************************************************/
public with sharing class AccountCreationController {
    public string AccName{get;set;}
    public string AccPhone{get;set;}
    public string AccWebSite{get;set;}
    public string Street{get;set;}
    public string city{get;set;}
    public string postalcode{get;set;}
    public string country{get;set;}
    public string state{get;set;}
    public string strquery;
    public string straddress{get;set;}
    public String County{get;set;}
    public String currentAccountId{get;set;}
    public string SelAccEnterPriseMasterId{get;set;}
    public string SelAccFCHId{get;set;}
    public string SelAddEnterPriseMasterId{get;set;}
    public string SelAddFCHId{get;set;}
    public Id selSFDCAccId{get;set;}
    public Id selSFDCAddId{get;set;}
    public String Profile {get;set;}
    Map<String,String> FCHPartyIdMap;
    Map<String,String> EnterprisePartyNumberMap; 

    public string StrCountryCode{get;set;}
    
    public boolean DIsplayResults{get;set;}
    public boolean NoResultsDisplay{get;set;}
    public boolean displaysearchbutton{get;set;}  
    public boolean DisplayMDMResults{get;set;}
    public boolean displaycreateselected{get;set;}  
    public boolean MDMSearchDone{get;set;}
    
    public list<account> accountlist{get;set;}
    public list<wrappersearchresults> wrapperlist{get;set;}
    Map<Integer,list<wrappersearchresults>> pgNumberWrapperMap{get;set;}
    public id tempid;
    public class myexception extends Exception{}
    
    //Pagging variables
    public Integer currentPage{get;set;}
    public Integer totalPage{get;set;}
    public Integer perPageRecords{get;set;}
    public Integer totalRecords{get;set;}
    public List<String> countries{get;set;}
    public Id custRecordTypeId = [select Id from RecordType where Name = 'Account (Customer) Record Type'].Id;
    public user userobj;
    public pagereference ref{get;set;}
    public boolean errorFlag{get;set;}
    public boolean duplicateValidationSkipFlag{get;set;}
    public boolean enableDuplicateValidationSkipButton{get;set;}
    //Constructor method to set values on page load
    public AccountCreationController(ApexPages.StandardController controller) {
        errorFlag = false;
        duplicateValidationSkipFlag = false;
        enableDuplicateValidationSkipButton = false;
        userobj = [select id,Name,Country,division__c,Profile.Name from user where id=:userinfo.getUserid()];
        country = userobj.Country; 
        Profile = userobj.Profile.Name;
        perPageRecords = Integer.valueOf(VF_Page_Paggination_Config__c.getAll().get('Search_Account').Records_Per_Page__c);
        totalRecords = 0;
        totalPage = 0;
        currentPage = 0;
        //pagetitle = 'Search for SFDC.com Account';
        //DIsplayResults = false;
        NoResultsDisplay = false;
        displaysearchbutton = false;
        DisplayMDMResults = false;
        displaycreateselected =false;
        
        if(Apexpages.currentpage().getparameters().containsKey('AccName')){
            AccName = Apexpages.currentpage().getparameters().get('AccName');
        }
        
        if(Apexpages.currentpage().getparameters().containsKey('Country')){
            country = Apexpages.currentpage().getparameters().get('Country');
        }
        
        if(Apexpages.currentpage().getparameters().containsKey('Phone')){
            AccPhone = Apexpages.currentpage().getparameters().get('Phone');
        }
        
        if(Apexpages.currentpage().getparameters().containsKey('Address')){
            straddress = Apexpages.currentpage().getparameters().get('Address');
        }
        
        if(Apexpages.currentpage().getparameters().containsKey('City')){
            city = Apexpages.currentpage().getparameters().get('City');
        }
        
        if(Apexpages.currentpage().getparameters().containsKey('State')){
            State = Apexpages.currentpage().getparameters().get('State');
        }
        
        if(Apexpages.currentpage().getparameters().containsKey('County')){
            County = Apexpages.currentpage().getparameters().get('County');
        }
        
        if(Apexpages.currentpage().getparameters().containsKey('PostalCode')){
            Postalcode = Apexpages.currentpage().getparameters().get('PostalCode');
        }
        
        if(Apexpages.currentpage().getparameters().containsKey('CurrentAccountId')){
            currentAccountId = Apexpages.currentpage().getparameters().get('CurrentAccountId');
        }
        
        if(Apexpages.currentpage().getparameters().containsKey('DupCheck')){
            SearchSFDCData();
        }
    }
    
     /*
     * Method name  : SearchSFDCData
     * Description  : Method to search Salesforce for Account Records before searching in customer data hub
     * Return Type  : pagereference
     * Parameter    : NA
     */ 
    public pagereference SearchSFDCData()
    {   
        duplicateValidationSkipFlag = false;
        enableDuplicateValidationSkipButton = false;
        list<string> strAddLength = new list<string>();//to check the address length       
        
        strquery = 'select Name,Sell_To__c,id,Account_Name__c,Account__r.FCH_Party_Id__c,POS_Flag__c,Account__r.Industry,FCH_Party_Site_ID__c,Account__r.Enterprise_Party_Number__c,Account__r.EBS_Account_Number__c,Enterprise_Address_Number__c,Account__c,Site_Name__c,Address_Line1__c,Address_Line2__c,Address_Line3__c,Address_Line4__c,City__c,State__c,Country__c,County__c,Zip__c from Address__c';
        try{
            system.debug('straddress======'+straddress);

            country=country.trim();
            if((country == null || country=='') && !Profile.contains('TAP'))
            throw new myexception('Please enter a valid country Name');
            if(country!=null && country!='')
            {  
            List<Country_Region_Mapping__c> Lrm = new List<Country_Region_Mapping__c>();  
            Set<String>CountrySet = new Set<String>();               
                Lrm = Country_Region_Mapping__c.getall().values();
                for(Country_Region_Mapping__c crm : Lrm)
                {
                 CountrySet.add(crm.Name.touppercase());
                }
                if(!CountrySet.Contains(Country.touppercase()))
                {
                    throw new myexception('Please enter a valid Country name');
                }
            }
            list<string> addlist = straddress.split('[\n\r]');
            
            for (Integer i = 0; i < addlist.size(); i++) {
                if (addlist.get(i).equals('')) {
                    addlist.remove(i);
                    i--; //Decrement counter since we removed an empty item from the list
                }
            }
            
            system.debug('addlist====='+addlist);
            system.debug('addlist====='+addlist.size());
            
            if(addlist!=null && addlist.size()>0)
            {
                if(addlist.size()>4)
                throw new myexception('Maximum of 4 lines allowed for Street Address.Please enter only 4 lines of address');
            }
                        
            integer listsize = addlist.size();
            
            string stradd1 = (addlist!=null && addlist.size()>0)?addlist[0]:'';
            string stradd2 = (addlist!=null && addlist.size()>0)?(listsize>=2?addlist[1]:''):'';
            string stradd3 = (addlist!=null && addlist.size()>0)?(listsize>=3?addlist[2]:''):'';
            string stradd4 = (addlist!=null && addlist.size()>0)?(listsize>=4?addlist[3]:''):'';            
            
            if(AccName!=null && AccName!=''){
                if(AccName.contains('\'')){
                    AccName = AccName.replace('\'', '\\\'');
                }
                strquery += ' where Account_Name__c like \'%' + AccName.trim()+ '%\'';
            }
            
            if(street!=null && street!=''){
                if(strquery.indexof('where')>0){
                    strquery += ' and ('+'Address_Line1__c like \'%' + street.trim()+ '%\''; 
                    strquery += ' or '+'Address_Line2__c like \'%' + street.trim()+ '%\'';
                    strquery += ' or '+'Address_Line3__c like \'%' + street.trim()+ '%\'';
                    strquery += ' or '+'Address_Line4__c like \'%' + street.trim()+ '%\')'; 
                }else{
                    strquery += ' where (Address_Line1__clike \'%' + street.trim()+ '%\''; 
                    strquery += ' or '+'Address_Line2__c like \'%' + street.trim()+ '%\'';
                    strquery += ' or '+'Address_Line3__c like \'%' + street.trim()+ '%\'';
                    strquery += ' or '+'Address_Line4__c like \'%' + street.trim()+ '%\')'; 
                }
            }
            
            if(city!=null && city!=''){
                if(strquery.indexof('where')>0)
                strquery += ' and City__c like \'%' + city.trim()+ '%\'';
                else
                strquery += ' where City__c like \'%' + city.trim()+ '%\'';
            }
            
            if(state!=null && state!=''){
                if(strquery.indexof('where')>0)
                strquery += ' and State__c  like \'%' + state.trim()+ '%\'';
                else
                strquery += ' where State__c like \'%' + state.trim()+ '%\'';
            }
            
            if(country!=null && country!=''){
                if(strquery.indexof('where')>0)
                strquery += ' and Country__c like \'%' + country.trim()+ '%\'';
                else
                strquery += ' where Country__c like \'%' + country.trim()+ '%\'';        
            }
           
            if(postalcode!=null && postalcode!=''){
                if(strquery.indexof('where')>0)
                strquery += ' and ZIP__c like \'%' + postalcode.trim()+ '%\'';
                else
                strquery += ' where ZIP__c like \'%' + postalcode.trim()+ '%\'';
            }
            
            if(stradd1!=null && stradd1!=''){
                if(strquery.indexof('where')>0)
                strquery += ' and Address_Line1__c like \'%' + stradd1.trim()+ '%\'';
                else
                strquery += ' where Address_Line1__c like \'%' + stradd1.trim()+ '%\'';
            }
            
            if(stradd2!=null && stradd2!=''){
                if(strquery.indexof('where')>0)
                strquery += ' and Address_Line2__c like \'%' + stradd2.trim()+ '%\'';
                else
                strquery += ' where Address_Line2__c like \'%' + stradd2.trim()+ '%\'';
            }
            if(stradd3!=null && stradd3!=''){
                if(strquery.indexof('where')>0)
                strquery += ' and Address_Line3__c like \'%' + stradd3.trim()+ '%\'';
                else
                strquery += ' where Address_Line3__c like \'%' + stradd3.trim()+ '%\'';
            }
            if(stradd4!=null && stradd4!=''){
                if(strquery.indexof('where')>0)
                strquery += ' and Address_Line4__c like \'%' + stradd4.trim()+ '%\'';
                else
                strquery += ' where Address_Line4__c like \'%' + stradd4.trim()+ '%\'';
            }
            
            if(County!=null && County!=''){
                if(strquery.indexof('where')>0)
                strquery += ' and County__c like \'%' + County.trim()+ '%\'';
                else
                strquery += ' where County__c like \'%' + County.trim()+ '%\'';
            }
               
            strquery += 'Order by State__c NULLS LAST limit 1000';
            

            
            system.debug('strquery========='+strquery);
            if(strquery!=null && strquery!=''){
                Map<Id,List<Address__c>> acccIdAddressListMap = new Map<Id,List<Address__c>>();
                List<Id> accIds = new List<Id>(); 
                for(Address__c add : Database.query(strquery)){
                    if(currentAccountId != add.Account__c){
                        if(!acccIdAddressListMap.containskey(add.Account__c)){
                            acccIdAddressListMap.put(add.Account__c,new List<Address__c>());
                            accIds.add(add.Account__c);
                        } 
                        acccIdAddressListMap.get(add.Account__c).add(add);
                    }
                }
                system.debug('acccIdAddressListMap========='+acccIdAddressListMap.keySet());
                pgNumberWrapperMap = new Map<Integer,List<wrappersearchresults>>();
                Integer cnt = 1;
                currentPage = 1;
                totalRecords = 0;
                Account acc;
                for(Id accId : accIds){
                    if(acccIdAddressListMap.get(accId).size() > 0){
                        if(!pgNumberWrapperMap.containsKey(currentPage))
                            pgNumberWrapperMap.put(currentPage,new List<wrappersearchresults>());
                        cnt++;    
                        
                        acc = new Account();
                        acc.Id = accId;
                        acc.Name = acccIdAddressListMap.get(accId).get(0).Account_Name__c;
                        acc.Enterprise_Party_Number__c = acccIdAddressListMap.get(accId).get(0).Account__r.Enterprise_Party_Number__c;
                        acc.EBS_Account_Number__c = acccIdAddressListMap.get(accId).get(0).Account__r.EBS_Account_Number__c;
                        acc.FCH_Party_ID__c = acccIdAddressListMap.get(accId).get(0).Account__r.FCH_Party_ID__c;
                        acc.Industry = acccIdAddressListMap.get(accId).get(0).Account__r.Industry;
                        pgNumberWrapperMap.get(currentPage).add(new wrappersearchresults(acc,acccIdAddressListMap.get(accId)));
                        if(pgNumberWrapperMap.get(currentPage).size() == VF_Page_Paggination_Config__c.getAll().get('Search_Account').Records_Per_Page__c){
                            cnt = 1;
                            currentPage++;
                        }
                        totalRecords++;
                    }
                }                
                system.debug('wrapperlist========='+pgNumberWrapperMap.keySet());
                wrapperlist = new list<wrappersearchresults>();
                if(pgNumberWrapperMap.size() > 0){
                    currentPage = 1;
                    wrapperlist.addAll(pgNumberWrapperMap.get(1));
                    totalPage = pgNumberWrapperMap.size();
                }
                system.debug('wrapperlist========='+wrapperlist );
                DIsplayResults = false;
                DisplayMDMResults = true;
                displaycreateselected = true;
                displaysearchbutton = true;
                if(wrapperlist.size()==0){
                    DIsplayResults = false;
                    NoResultsDisplay = true;
                    DisplayMDMResults = false;
                    //displaycreateselected=true; //added by pardeep to display create new button
                }else{   
                    DIsplayResults = true;
                    NoResultsDisplay = false;
                    DisplayMDMResults = false;
                   // displaycreateselected=true; //added by pardeep to display create new button
                }  
            }else{   
                DIsplayResults = false;
                NoResultsDisplay = true;
                DisplayMDMResults = false;
                //displaycreateselected=true; //added by pardeep to display create new button
            }
            
            // remove the wild character for single Quote
            if(AccName!=null && AccName!='' && AccName.contains('\\\'')){
                AccName = AccName.replace('\\\'', '\'');
            }
        }
        catch(Exception ex)
        {
            system.debug(ex);
            system.debug(ex.getStackTraceString());
            Apexpages.addMessages(ex);
            return null;
        }
        return null;
    }
    
    /*
     * Method name  : GoToRecord
     * Description  : Method to redirect the user to an account
     * Return Type  : pagereference
     * Parameter    : NA
     */ 
    public pagereference GoToRecord()
    {
        tempid = Apexpages.Currentpage().getparameters().get('StrAccountName');
        pagereference p;
        if(tempid!=null)
        {
            p = new pagereference('/'+tempid);
            p.setredirect(true);
            return p;
        }
        return null;
    }
    
    /*
     * Method name  : SearchMDMData
     * Description  : Method to search Account Records in customer data hub
     * Return Type  : pagereference
     * Parameter    : NA
     */
    public pagereference SearchMDMData(){
        duplicateValidationSkipFlag = false;
        enableDuplicateValidationSkipButton = false;
        MDMSearchDone = true;
        wrapperlist = new list<wrappersearchresults>();
        try{
            country=country.trim();
             if((country == null || country=='') && !Profile.contains('TAP'))
            throw new myexception('Please enter a valid country Name'); 
            
            if(country!=null && country!=''){                   
                List<Country_Region_Mapping__c> Lrm = new List<Country_Region_Mapping__c>();  
            Set<String>CountrySet = new Set<String>();               
                Lrm = Country_Region_Mapping__c.getall().values();
                for(Country_Region_Mapping__c crm : Lrm)
                {
                 CountrySet.add(crm.Name.touppercase());
                }
                if(!CountrySet.Contains(Country.touppercase()))
                {
                    throw new myexception('Please enter a valid Country name');
                }
            }
            String NoResults = System.Label.No_records_found;
        
            //Original Response
            pgNumberWrapperMap = new Map<Integer,List<wrappersearchresults>>();
            Integer cnt = 1;
            currentPage = 1;
            totalRecords = 0;
            list<trimblecorpComCmdm_v4.OrganizationPartyType> responselist = searchinMDMdata();    
            
            FCHPartyIdMap = new Map<String,String>();
            EnterprisePartyNumberMap = new Map<String,String>(); 
            for(trimblecorpComCmdm_v4.OrganizationPartyType respvar : responselist){
                system.debug('-------------------' + respvar.PartyId);
                system.debug('-------------------' + respvar.EnterprisePartyNumber);
                FCHPartyIdMap.put(respvar.PartyId,'');
                EnterprisePartyNumberMap.put(respvar.EnterprisePartyNumber,'');
                if(respvar.PartySite != null){
                    List<String> stateList = new List<String>();
                    Map<String,List<trimblecorpComCmdm_v4.PartySite_element>> searchResult = new Map<String,List<trimblecorpComCmdm_v4.PartySite_element>>();
                    for(trimblecorpComCmdm_v4.PartySite_element partySiteEle : respvar.PartySite){
                        if(!searchResult.containsKey(partySiteEle.Location.State)){
                            searchResult.put(partySiteEle.Location.State, new List<trimblecorpComCmdm_v4.PartySite_element>());
                        }
                        searchResult.get(partySiteEle.Location.State).add(partySiteEle);
                    }
                    stateList.addAll(searchResult.keySet());
                    stateList.sort();
                    
                    respvar.PartySite = new List<trimblecorpComCmdm_v4.PartySite_element>();
                    for(String state : stateList){
                        if(state != '' && state != null){
                            if(searchResult.containsKey(state)){
                                respvar.PartySite.addAll(searchResult.get(state));
                            }
                        }
                    }
                    if(searchResult.containsKey('')){
                        respvar.PartySite.addAll(searchResult.get(''));
                    }
                    
                    if(searchResult.containsKey(null)){
                        respvar.PartySite.addAll(searchResult.get(null));
                    }
                    
                    for(Integer i = 0 ; i < respvar.PartySite.size() ; i++){
                        trimblecorpComCmdm_v4.PartySite_element partySiteEle = respvar.PartySite[i];
                        if(partySiteEle.Location != null){
                            system.debug('-------------------' + partySiteEle.PartySiteId);
                            system.debug('-------------------' + partySiteEle.EnterprisePartySiteNumber);
                            FCHPartyIdMap.put(partySiteEle.PartySiteId,'');
                            EnterprisePartyNumberMap.put(partySiteEle.EnterprisePartySiteNumber,'');
                        }
                    }
                }
            }
            system.debug(FCHPartyIdMap + '-------------------' + EnterprisePartyNumberMap);
            for(Account acc : [select Id,FCH_Party_ID__c,Enterprise_Party_Number__c,EBS_Account_Number__c from Account where 
                    Enterprise_Party_Number__c in : EnterprisePartyNumberMap.keySet() or FCH_Party_ID__c in : FCHPartyIdMap.keySet()]){
                if(acc.FCH_Party_ID__c != null && acc.FCH_Party_ID__c != '')FCHPartyIdMap.put(acc.FCH_Party_ID__c,acc.Id);
                if(acc.Enterprise_Party_Number__c != null && acc.Enterprise_Party_Number__c != '')EnterprisePartyNumberMap.put(acc.Enterprise_Party_Number__c,acc.Id);
            }
            
            for(Address__c add : [select Id,FCH_Party_Site_ID__c,Enterprise_Address_Number__c,Account__r.EBS_Account_Number__c from Address__c where 
                Enterprise_Address_Number__c in : EnterprisePartyNumberMap.keySet() or FCH_Party_Site_ID__c in : FCHPartyIdMap.keySet()]){
                if(add.FCH_Party_Site_ID__c != null && add.FCH_Party_Site_ID__c != '')FCHPartyIdMap.put(add.FCH_Party_Site_ID__c,add.Id);
                if(add.Enterprise_Address_Number__c != null && add.Enterprise_Address_Number__c != '')EnterprisePartyNumberMap.put(add.Enterprise_Address_Number__c,add.Id);
            }
            
            system.debug( '----------------------' + responselist.size());
            for(trimblecorpComCmdm_v4.OrganizationPartyType respvar : responselist){
                system.debug( respvar.AccountName + '----------------------' + respvar);
                String orgName = respvar.AccountName;   
                Account acc = new Account();
                system.debug(FCHPartyIdMap.keySet() + '----------------------' + EnterprisePartyNumberMap.keySet());
                system.debug(respvar.PartyId + '----------------------' + respvar.EnterprisePartyNumber);
                system.debug(respvar.PartyId + '----------------------' + FCHPartyIdMap.get(respvar.PartyId));
                system.debug(respvar.PartyId + '----------------------' + EnterprisePartyNumberMap.get(respvar.EnterprisePartyNumber));
                if((respvar.PartyId != null && respvar.PartyId != '') || (respvar.EnterprisePartyNumber != null &&  respvar.EnterprisePartyNumber != '')){
                    system.debug('------ValidID-------' + ((FCHPartyIdMap.get(respvar.PartyId) != '' && FCHPartyIdMap.get(respvar.PartyId) != null) ? (Id)FCHPartyIdMap.get(respvar.PartyId) : 
                                ((EnterprisePartyNumberMap.get(respvar.EnterprisePartyNumber) != '' && EnterprisePartyNumberMap.get(respvar.EnterprisePartyNumber) != null) ? 
                        EnterprisePartyNumberMap.get(respvar.EnterprisePartyNumber) : null)));
                    Id accId = ((FCHPartyIdMap.get(respvar.PartyId) != '' && FCHPartyIdMap.get(respvar.PartyId) != null) ? (Id)FCHPartyIdMap.get(respvar.PartyId) : 
                                ((EnterprisePartyNumberMap.get(respvar.EnterprisePartyNumber) != '' && EnterprisePartyNumberMap.get(respvar.EnterprisePartyNumber) != null) ? 
                        EnterprisePartyNumberMap.get(respvar.EnterprisePartyNumber) : null));
                    system.debug('------ValidID-------' + accId);
                    if(accId != null ? 
                        Schema.getGlobalDescribe().get('Account').getDescribe().getKeyPrefix() == String.valueOf(accId).subString(0,3)
                         : false)acc.Id = accId;
                }
                System.debug('acc--------'+acc);
                acc.FCH_Party_ID__c =(respvar.PartyId == null ? '' : respvar.PartyId);
                acc.Enterprise_Party_Number__c = (respvar.EnterprisePartyNumber == null ? '' : respvar.EnterprisePartyNumber );
                acc.Name = respvar.AccountName;
                System.debug('LIFECYCLESTAGE--------'+respvar.LifecycleStage_c);       
                acc.Lifecycle_Stage__c = (respvar.LifecycleStage_c != null ? respvar.LifecycleStage_c : '');
                acc.sub_type__c = (respvar.CustomerLevel_c != null? respvar.CustomerLevel_c : '');
                acc.Region__c = (respvar.PrimaryRegion_c != null ? respvar.PrimaryRegion_c : '');
                acc.Global_Opt_Out__c = (respvar.GlobalOptOut_c!=null && respvar.GlobalOptOut_c!='')?(respvar.GlobalOptOut_c.equalsIgnoreCase('yes')?true:false):false;
                acc.DUNS__c = respvar.DUNSNumberC;
                acc.Vertical_Classification__c = respvar.VerticalClassification_c;
                acc.Bill_To_Flag__c = (respvar.BilltoUsage_c!=null && respvar.BilltoUsage_c!='')?(respvar.BilltoUsage_c.equalsIgnoreCase('yes')?true:false):false;
                acc.Ship_To_Flag__c = (respvar.ShiptoUsage_c!=null && respvar.ShiptoUsage_c!='')?(respvar.ShiptoUsage_c.equalsIgnoreCase('yes')?true:false):false;
                acc.End_User_Flag__c = (respvar.EndUser_c!=null && respvar.EndUser_c!='')?(respvar.EndUser_c.equalsIgnoreCase('yes')?true:false):false;
                acc.Installed_At_Flag__c = (respvar.Installedat_c!=null && respvar.Installedat_c!='')?(respvar.Installedat_c.equalsIgnoreCase('yes')?true:false):false;
                acc.Sell_ToFlag__c = (respvar.SelltoFlag!=null && respvar.SelltoFlag!='')?(respvar.SelltoFlag.equalsIgnoreCase('yes')?true:false):false;
                acc.Phone = respvar.PrimaryPhoneNumber;
                acc.Email__c = respvar.PrimaryEMail_c;
                acc.AddressValidated__c = (respvar.ValidatedFlag!=null && respvar.ValidatedFlag!='')?(respvar.ValidatedFlag.equalsIgnoreCase('yes')?true:false):false;

                acc.Parent_Account_ID__c =respvar.Parent_PartyId;
                acc.Account_Status__c = 'Active';
                acc.Restricted_Entity__c = (respvar.RestrictedPartyIndicator_c!=null && respvar.RestrictedPartyIndicator_c!='')?(respvar.RestrictedPartyIndicator_c.equalsIgnoreCase('yes')?Label.Restricted:Label.Not_Restricted):Label.Not_Restricted;
                acc.Credit_Check_Status__c = respvar.CreditStatus_c;
                system.debug('--------acc-----------' + acc);
                List<Address__c> addressList = new List<Address__c>();
                Address__c add = new Address__c();
                if(respvar.PartySite != null){
                    system.debug('-------------------' + respvar.PartySite.size());
                    for(Integer i = 0 ; i < respvar.PartySite.size() ; i++){
                        trimblecorpComCmdm_v4.PartySite_element partySiteEle = respvar.PartySite[i];
                        if(partySiteEle.Location != null){
                            add = new Address__c();
                            system.debug('----------FCHPartyIdMap---------' + FCHPartyIdMap);
                            system.debug('----------partySiteEle.PartySiteId---------' + partySiteEle.PartySiteId);
                            system.debug('----------partySiteEle.PartySiteId---------' + partySiteEle.PartySiteId);
                            system.debug('----------FCHPartyIdMap.containsKey(partySiteEle.PartySiteId)---------' + FCHPartyIdMap.get(partySiteEle.PartySiteId));
                            system.debug('----------FCHPartyIdMap.containsKey(partySiteEle.EnterprisePartySiteNumber)---------' + FCHPartyIdMap.get(partySiteEle.PartySiteId));
                            
                            if((partySiteEle.PartySiteId != null && partySiteEle.PartySiteId != '') || (partySiteEle.EnterprisePartySiteNumber != null &&  partySiteEle.EnterprisePartySiteNumber != '')){
                                system.debug('------AddValidID-------' + ((FCHPartyIdMap.get(partySiteEle.PartySiteId) != '' && FCHPartyIdMap.get(partySiteEle.PartySiteId) != null ) ? (Id)FCHPartyIdMap.get(partySiteEle.PartySiteId) : 
                                            ((EnterprisePartyNumberMap.get(partySiteEle.EnterprisePartySiteNumber) != '' && EnterprisePartyNumberMap.get(partySiteEle.EnterprisePartySiteNumber) != null) ? 
                                    (Id)EnterprisePartyNumberMap.get(partySiteEle.EnterprisePartySiteNumber) : null)));
                                Id addId = ((FCHPartyIdMap.get(partySiteEle.PartySiteId) != '' && FCHPartyIdMap.get(partySiteEle.PartySiteId) != null ) ? (Id)FCHPartyIdMap.get(partySiteEle.PartySiteId) : 
                                            ((EnterprisePartyNumberMap.get(partySiteEle.EnterprisePartySiteNumber) != '' && EnterprisePartyNumberMap.get(partySiteEle.EnterprisePartySiteNumber) != null) ? 
                                    (Id)EnterprisePartyNumberMap.get(partySiteEle.EnterprisePartySiteNumber) : null));
                                if(addId != null ? 
                                    Schema.getGlobalDescribe().get('Address__c').getDescribe().getKeyPrefix() == String.valueOf(addId).subString(0,3)
                                     : false)add.Id = addId;
                            }
                            
                            add.FCH_Party_Site_ID__c = (partySiteEle.PartySiteId == null ? '' : partySiteEle.PartySiteId);
                            add.Enterprise_Address_Number__c = (partySiteEle.EnterprisePartySiteNumber == null ? '' : partySiteEle.EnterprisePartySiteNumber);
                            add.Name = partySiteEle.PartySiteName;
                            add.Site_Name__c = partySiteEle.PartySiteName;
                            add.Tax_Reg_Number__c = partySiteEle.TaxID;
                            add.Account__r = new Account(Enterprise_Party_Number__c = respvar.EnterprisePartyNumber);
                            add.Address_line1__c = partySiteEle.Location.Address1;
                            add.Address_line2__c = partySiteEle.Location.Address2;
                            add.Address_line3__c = partySiteEle.Location.Address3;
                            add.Address_line4__c = partySiteEle.Location.Address4;
                            add.City__c = partySiteEle.Location.City;
                            add.State__c = partySiteEle.Location.State;
                            add.County__c = partySiteEle.Location.County;
                            add.Country__c = partySiteEle.Location.Country;
                            add.Zip__c = partySiteEle.Location.PostalCode;
    
                            acc.BillingCity = add.city__c;  
                            acc.billingstate = add.state__c;                
                            acc.billingcountry = add.country__c;
                             
                            acc.BillingStreet = partySiteEle.Location.address1 + ' \r\n' + partySiteEle.Location.address2 + ' \r\n' + partySiteEle.Location.address3 + ' \r\n' + partySiteEle.Location.address4;
                            acc.type = 'Customer';
                            acc.Address1__c = partySiteEle.Location.address1;
                            acc.Address2__c = partySiteEle.Location.address2;
                            acc.Address3__c = partySiteEle.Location.address3;
                            acc.Address4__c = partySiteEle.Location.address4;
                            acc.BillingPostalCode = partySiteEle.Location.PostalCode;
                            addressList.add(add);
                            
                        }
                    }
                }
                if(!pgNumberWrapperMap.containsKey(currentPage))
                    pgNumberWrapperMap.put(currentPage,new List<wrappersearchresults>());
                cnt++;
                pgNumberWrapperMap.get(currentPage).add(new wrappersearchresults(acc,addressList));
                if(pgNumberWrapperMap.get(currentPage).size() == VF_Page_Paggination_Config__c.getAll().get('Search_Account').Records_Per_Page__c){
                    cnt = 1;
                    currentPage++;
                }
                totalRecords++;
            }
            
            if(pgNumberWrapperMap.size() > 0){
                currentPage = 1;
                wrapperlist.addAll(pgNumberWrapperMap.get(1));
                totalPage = pgNumberWrapperMap.size();
            }
    
            DIsplayResults = false;
            DisplayMDMResults = true;
            displaycreateselected = true;
            if(wrapperlist.size()==0){
                DisplayMDMResults = false;
                NoResultsDisplay = true;
            }
            else{   
                NoResultsDisplay = false;
            }  
             
        }catch(exception ex){
            Apexpages.addMessages(ex);
            return null;
        }
        return null;
    }
    
    public void previous(){
        currentPage--;
        if(pgNumberWrapperMap.containsKey(currentPage)){
            wrapperlist = new List<wrappersearchresults>();
            wrapperlist.addAll(pgNumberWrapperMap.get(currentPage));
            if(wrapperlist.size()==0){
                NoResultsDisplay = true;
            }
            else{   
                NoResultsDisplay = false;
            }
                
        }
    }
    
    public void first(){
        duplicateValidationSkipFlag = false;
        enableDuplicateValidationSkipButton = false;
        currentPage = 1;
        if(pgNumberWrapperMap.containsKey(currentPage)){
            wrapperlist = new List<wrappersearchresults>();
            wrapperlist.addAll(pgNumberWrapperMap.get(currentPage));
            if(wrapperlist.size()==0){
                NoResultsDisplay = true;
            }
            else{   
                NoResultsDisplay = false;
            }
                
        }
    }
    
    public void next(){
        duplicateValidationSkipFlag = false;
        enableDuplicateValidationSkipButton = false;
        currentPage++;
        if(pgNumberWrapperMap.containsKey(currentPage)){
            wrapperlist = new List<wrappersearchresults>();
            wrapperlist.addAll(pgNumberWrapperMap.get(currentPage));
            if(wrapperlist.size()==0){
                NoResultsDisplay = true;
            }
            else{   
                NoResultsDisplay = false;
            }
                
        }
    }
    
    public void last(){
        duplicateValidationSkipFlag = false;
        enableDuplicateValidationSkipButton = false;
        currentPage = totalPage;
        if(pgNumberWrapperMap.containsKey(currentPage)){
            wrapperlist = new List<wrappersearchresults>();
            wrapperlist.addAll(pgNumberWrapperMap.get(currentPage));
            if(wrapperlist.size()==0){
                NoResultsDisplay = true;
            }
            else{   
                NoResultsDisplay = false;
            }
                
        }
    }
    
    /*
     * Method name  : createNewaccount
     * Description  : Method to create new Account if no data is found in customer data hub
     * Return Type  : pagereference
     * Parameter    : NA
     */
    public pagereference createNewaccount(){
        duplicateValidationSkipFlag = false;
        enableDuplicateValidationSkipButton = false;
        pagereference p;
        string URLvar;
         
         try{
            
            if(strCountryCode!=null && strCountryCode!='')
            {
                if(strCountryCode.indexOf('+')<0)
                throw new myexception('Country code must begin with "+"');
            }
            URLvar = 'setup/ui/recordtypeselect.jsp?ent=Account&retURL=%2F001%2Fo&save_new_url=%2F001%2Fe%3FretURL%3D%252F001%252Fo&nooverride=1';
            
            
            if(AccName!=null && AccName!='')
            AccName = EncodingUtil.urlencode(AccName,'UTF-8');
            URLvar +='&'+Label.Account_Name_ID+'='+AccName; 
            
           if(StrCountryCode!=null && StrCountryCode!='')
            URLvar +='&'+Label.Country_Code_Id+'='+'%2B'+StrCountryCode.trim();
            
            if(AccPhone!=null && AccPhone!='')
            URLvar +='&'+Label.Phone_Id+'='+AccPhone;
            
            if(country!=null && country!='')
            URLvar +='&'+Label.Country+'='+country;
            
            if(straddress!=null && straddress!='')
            URLvar +='&'+Label.Sreet_Address+'='+straddress;
            
             if(city!=null && city!='')
            URLvar +='&'+Label.City+'='+city;
            
             if(Postalcode!=null && Postalcode!='')
            URLvar +='&'+Label.Zip+'='+Postalcode;
            
             if(State!=null && State!='')
            URLvar +='&'+Label.State+'='+State;
            
             if(County != null && County != ''){
            URLvar +='&' + Label.County_Field_Id_Account + '='+County;     
             }
             String division = [select Id,Division__c from User where Id =: userinfo.getUserID()].Division__c;
             system.debug('-------------------' + division);
             system.debug('-------------------' + Label.Account_Division);
             if(division=='TAP')
             URLvar +='&'+Label.Life_Cycle_Stage +'='+'Customer';
             
             if(division != null && division != ''){
            URLvar +='&' + Label.Account_Division + '='+ EncodingUtil.urlEncode(division, 'UTF-8');     
             }
             system.debug('---------Account_Division----------' + Label.Account_Division);
             
            //p = new pagereference('/'+'setup/ui/recordtypeselect.jsp?ent=Account&retURL=%2F001%2Fo&save_new_url=%2F001%2Fe%3FretURL%3D%252F001%252Fo&nooverride=1');
            p = new pagereference('/'+URLvar);
           
            p.setredirect(true);
        }
        catch(exception ex)
        {
            Apexpages.addMessages(ex);
            system.debug('exception ====='+ex);
            system.debug('exception ====='+ex.getStackTraceString());
            p = null;
        } 
        
        return p;
        //return null;
    }
    
    /*
     * Method name  : updateForeignKeys
     * Description  : Method to update updateForeignKeys on Address
     * Return Type  : pagereference
     * Parameter    : NA
     */
    public pageReference createSellToAccount(){
        duplicateValidationSkipFlag = false;
        enableDuplicateValidationSkipButton = false;
        System.debug('---------selSFDCAccId---------' + selSFDCAccId);
        List<Address__c> addList = [select Id,Tax_Reg_Number__c,Restricted_Party_Indicator__c,Site_Name__c,Anniversary_Date__c,Location_ID__c,Party_Site_Number__c,Address_line1__c,Address_line2__c,Address_line3__c,
                                Address_line4__c,City__c,County__c,Country__c,State__c,Zip__c,Bill_to__c,Ship_to__c,Installed_at__c,End_User__c,
                                Sell_to__c,Address_Region__c,Account__r.EBS_Account_Number__c,Account__r.Sell_ToFlag__c,Account__c,Enterprise_Address_Number__c,Address_Validated_Flag__c,
                                 FCH_Party_Site_ID__c
                                from Address__c where Account__c =: selSFDCAccId];
        String URL;
        System.debug('---------addList---------' + addList);
        if(addList.size() > 1){
            Address__c add = new Address__c();
            for(Address__c addObj : addList){
                if(addObj.Id == selSFDCAddId){
                    add = addObj;
                    break;
                }
            }
            
            AccountCreationCalloutEX.recursiveCallFlag = true;
            AccountHelper.launchControl.put('CreateAddressRdFromBillToAddress',1);
            Account acc = new Account();
            
            acc = database.query(Utils.getCreatableFieldsSOQL('Account', 'Id =\'' + selSFDCAccId + '\''));
            
            Account cloneAcc = acc.Clone(false, true, false, false);
            System.debug('-----------cloneAcc---------' + cloneAcc);
            cloneAcc.Name = acc.Name;
            cloneAcc.Enterprise_Party_Number__c = '';
            cloneAcc.FCH_Party_ID__c = '';
            cloneAcc.FchReportingEntityNumber__c = '';
            cloneAcc.FchReportingEntityPartyID__c = '';
            String address = (add.address_line1__c != null && add.address_line1__c != '' ? add.address_line1__c : '');
            address = (address != null && address != '' ? address + ',' : '') + (add.address_line2__c != null && add.address_line2__c != '' ? add.address_line2__c : '');
            address = (address != null && address != '' ? address + ',' : '') + (add.address_line3__c != null && add.address_line3__c != '' ? add.address_line3__c : '');
            address = (address != null && address != '' ? address + ',' : '') + (add.address_line4__c != null && add.address_line4__c != '' ? add.address_line4__c : '');
            
            cloneAcc.BillingStreet = address;
            cloneAcc.BillingCity = add.City__c;
            cloneAcc.BillingCountry = add.Country__c;
            cloneAcc.County__c = add.County__c;
            cloneAcc.BillingState = add.State__c;
            cloneAcc.BillingPostalCode = add.Zip__c;
            cloneAcc.Account_Country_Region__c = add.Address_Region__c ;
            cloneAcc.Bill_To_Flag__c = add.Bill_To__c;
            cloneAcc.Ship_To_Flag__c = add.Ship_To__c;
            cloneAcc.Sell_ToFlag__c = true;
            cloneAcc.End_User_Flag__c = add.End_User__c;
            cloneAcc.Installed_At_Flag__c = add.Installed_at__c;
            cloneAcc.End_User_Flag__c = add.End_User__c; 
            cloneAcc.Annual_Support_Date__c  = add.Anniversary_Date__c;
            if(add.Tax_Reg_Number__c != null && add.Tax_Reg_Number__c != '')
                cloneAcc.Tax_Reg_Number__c = add.Tax_Reg_Number__c; 
            cloneAcc.RecordTypeId = custRecordTypeId;
            cloneAcc.Lifecycle_Stage__c = 'Customer';
            cloneAcc.Account_Status__c = 'Active';
            insert cloneAcc;
            System.debug('---------cloneAcc---------' + cloneAcc);

            Address__c cloneAdd = add.Clone(false, true, false, false);
            cloneAdd.Account__c = cloneAcc.ID;
            cloneAdd.Enterprise_Address_Number__c = '';
            cloneAdd.FCH_Party_Site_ID__c = '';
            cloneAdd.Location_ID__c = '';
            cloneAdd.FCH_Party_Site_ID__c = '';
            cloneAdd.Party_Site_Number__c = '';
            cloneAdd.Sell_To__c = true;
            insert cloneAdd;
            
            AccountCreationCalloutEX.makeCallOut(new List<String>{cloneAcc.Id},'Create','NoOp','Create',new set<String>(),new set<String>{cloneAdd.Id},new Set<String>());
            
            URL = cloneAcc.Id;
        }else if(addList.size() == 1){
            System.debug('-----------selSFDCAddId---------' + selSFDCAddId);
            AccountCreationCalloutEX.recursiveCallFlag = true;
            Account acc = new Account();
            String accOpt = 'NoOp';
            acc.Id = addList.get(0).Account__c;
            if(!addList.get(0).Account__r.Sell_ToFlag__c){
                acc.Sell_ToFlag__c = true;
                update acc;
                accOpt = 'Update';
            }
            
            Address__c add = new Address__c();
            add.Id = selSFDCAddId;
            add.Sell_To__c = true;
            update add;
            
            AccountCreationCalloutEX.makeCallOut(new List<String>{acc.Id},accOpt,'NoOp','Update',new set<String>(),new set<String>{add.Id},new Set<String>());
            
            URL = selSFDCAccId;
        }
        System.debug('-----------URL---------' + URL);
        pagereference p = new pagereference('/' + URL);
        p.setredirect(true);
       
        return p;
    }
    
    /*
     * Method name  : createAccountWithUserSelected
     * Description  : Method to create an Account with a record found from customer data hub
     * Return Type  : pagereference
     * Parameter    : NA
     */
    List<xmlnsOracleComFchTnvcusbpelfchosrsyn_v1.OriginalSystemReferenceType> requestData;
    public void createAccountWithUserSelected()
    {       
        errorFlag = false;
        Account acc;   
        Address__c address;
        boolean accInsertFlag = false;
        try{
            system.debug(SelAccEnterPriseMasterId+ '-----SelAccEnterPriseMasterId------' + SelAccEnterPriseMasterId);
            System.debug('SelAccFCHId-------------'+SelAccFCHId);
            System.debug('SelAccEnterPriseMasterId-------------'+SelAccEnterPriseMasterId);
            System.debug('SelAddFCHId-------------'+SelAddFCHId);
            System.debug('SelAddEnterPriseMasterId-------------'+SelAddEnterPriseMasterId);
            
            System.debug(FCHPartyIdMap.keyset() + 'SelAddEnterPriseMasterId-------------' + EnterprisePartyNumberMap.keyset());
             
            for(wrappersearchresults wrapperObj : wrapperlist){
                if(wrapperObj.accObj.Enterprise_Party_Number__c == SelAccEnterPriseMasterId || 
                    wrapperObj.accObj.FCH_Party_ID__c == SelAccFCHId){
                    acc = wrapperObj.accObj;
                    if(acc.Id == null)accInsertFlag = true;
                    for(Address__c add : wrapperObj.addressList){
                        if(add.FCH_Party_Site_ID__c == SelAddFCHId || add.Enterprise_Address_Number__c == SelAddEnterPriseMasterId){
                            address = add;
                            address.Name = acc.Name;
                            if(accInsertFlag){
                                acc.BillingStreet = address.Address_line1__c + '\n' +
                                                      (address.Address_line2__c != null && address.Address_line2__c != '' ? address.Address_line2__c + '\n'  : '' ) +
                                                      (address.Address_line3__c != null && address.Address_line3__c != '' ? address.Address_line3__c + '\n'  : '' ) +
                                                      (address.Address_line4__c != null && address.Address_line4__c != '' ? address.Address_line4__c   : '' );
                                acc.BillingCity = address.City__c;
                                acc.BillingState = address.State__c;
                                acc.BillingCountry = address.Country__c;
                                acc.County__c = address.County__c;
                                acc.BillingPostalCode = address.Zip__c;
                                acc.Account_Country_Region__c = address.Address_Region__c;
                                acc.Bill_To_Flag__c = true;
                                acc.Ship_To_Flag__c = true;
                                acc.Sell_ToFlag__c = address.Sell_To__c;
                                acc.End_User_Flag__c = address.End_User__c;
                                acc.Installed_at_Flag__c =address.Installed_At__c;
                                acc.End_User_Flag__c = address.End_User__c;
                                acc.Sell_ToFlag__c = True;
                                acc.Annual_Support_Date__c= address.Anniversary_Date__c;
                                acc.RecordTypeId = custRecordTypeId;
                                acc.Lifecycle_Stage__c = 'Customer';
                                acc.Account_Status__c = 'Active';
                                acc.Account_Division__c = userobj.Division__c;
                                if(address.Tax_Reg_Number__c != null && address.Tax_Reg_Number__c != '')
                                        acc.Tax_Reg_Number__c = address.Tax_Reg_Number__c;
                            }
                        }
                    }
                }
            } 
            
            RecursiveTriggerUtility.isAccountRecursive = false;
            String accOpr = 'NoOp';
            String erMsg = '';
            if(accInsertFlag){
                AccountHelper.launchControl.put('CreateAddressRdFromBillToAddress', 1);
                system.debug('---------duplicateValidationSkipFlag-----------' + duplicateValidationSkipFlag);
                if(duplicateValidationSkipFlag){
                    duplicateValidationSkipFlag = false;
                    enableDuplicateValidationSkipButton = false;
                    Database.DMLOptions dmlc = new Database.DMLOptions();
                    dmlc.DuplicateRuleHeader.AllowSave = true; 
                    acc.setOptions(dmlc);
                    acc.Bypass_Duplicate_Rules__c = true;
                }
                system.debug('---------acc-----------' + acc);
                Database.upsertResult result = Database.upsert(acc);
            }
            if(address != null){
                if(address.Id == null){
                    address.Bill_To__c = true;
                    address.Ship_To__c = true;
                    address.Sell_To__c = true;
                }
                RecursiveTriggerUtility.isAccountRecursive = false;
                LinkAccountController.LinkAccountCall = true;
                upsert address;
                system.debug('----------------' + address.Id);
                
                requestData = new List<xmlnsOracleComFchTnvcusbpelfchosrsyn_v1.OriginalSystemReferenceType>();
                xmlnsOracleComFchTnvcusbpelfchosrsyn_v1.OriginalSystemReferenceType data = new xmlnsOracleComFchTnvcusbpelfchosrsyn_v1.OriginalSystemReferenceType();
                data.OrigSystem = 'SFDC';
                data.OrigSystemReference = acc.Id;
                data.OwnerTableName = 'HZ_PARTIES';
                data.OwnerTableId = Long.valueOf(SelAccFCHId);
                data.Status = 'A';
                data.CreatedByModule = 'TNV_CMDM';
                requestData.add(data);
                System.debug('------data-------' + data);
                data = new xmlnsOracleComFchTnvcusbpelfchosrsyn_v1.OriginalSystemReferenceType();
                data.OrigSystem = 'SFDC';
                data.OrigSystemReference = address.Id;
                data.OwnerTableName = 'HZ_PARTY_SITES';
                data.OwnerTableId = Long.valueOf(SelAddFCHId);
                data.Status = 'A';
                data.CreatedByModule = 'TNV_CMDM';
                requestData.add(data);
                System.debug('------data-------' + data);                    
                
                ref = new pagereference('/'+address.id + '/e?retURL=/' + address.Id);
                ref.setredirect(true);
            }

        }catch(DmlException ex){
            system.debug('----------------' + ex);
            if(ex.getMessage().contains('duplicate')){
                enableDuplicateValidationSkipButton = true;
            }
            Apexpages.addMessages(ex);
            errorFlag = true;
        }catch(Exception ex){
            system.debug('----------------' + ex);
            Apexpages.addMessages(ex);
            errorFlag = true;
        }
    }
    
    
    public pageReference callLinkAccWebService(){
        system.debug('--------------------' + requestData);
        xmlnsOracleComCmdmnewTnvcusbpelfchos_v1.FCHOSRService_pt request = new xmlnsOracleComCmdmnewTnvcusbpelfchos_v1.FCHOSRService_pt();
        request.timeout_x = 60000;
        xmlnsOracleComFchTnvcusbpelfchosrsyn_v1.processResponse_element response;
        response = request.process('Create', requestData);
        system.debug('--------------------' + response);
        return ref;
    }
    
    /*
     * Method name  : searchinMDMdata
     * Description  : Method to call the webservice to search for account from customer data hub
     * Return Type  : list<trimblecorpComCmdm_v4_v2.OrganizationPartyType>
     * Parameter    : NA
     */
    public list<trimblecorpComCmdm_v4.OrganizationPartyType> searchinMDMdata(){
        list<trimblecorpComCmdm_v4.OrganizationPartyType> resplist = new list<trimblecorpComCmdm_v4.OrganizationPartyType>();
        list<string> StrAddressList;
        string StrStreet,Strcity,StrState,StrPincode,StrCountry;
       
        xmlnsTrimbleComTrimblenavigationFch_v4.searchOrganizationParty_pt invokeclsvar = new xmlnsTrimbleComTrimblenavigationFch_v4.searchOrganizationParty_pt();
        try{
            system.debug('straddress====='+straddress+'=====Strcity==='+city+'====StrState==='+State+'====StrPincode==='+postalcode+'====StrCountry===='+Country); 
            system.debug('AccName========='+AccName+'======AccPhone============='+AccPhone);
            List<trimblecorpComCmdm_v4.PartySite_element> partyEleList = new List<trimblecorpComCmdm_v4.PartySite_element>();
            trimblecorpComCmdm_v4.PartySite_element partyEle = new trimblecorpComCmdm_v4.PartySite_element();
            trimblecorpComCmdm_v4.LocationType locationParam = new trimblecorpComCmdm_v4.LocationType();
            list<string> addlist = straddress.split('[\n\r]');
            
            for (Integer i = 0; i < addlist.size(); i++) {
                if (addlist.get(i).equals('')) {
                    addlist.remove(i);
                    i--; //Decrement counter since we removed an empty item from the list
                }
            }
            locationParam.Address1 = (addlist!=null && addlist.size()>0)?addlist[0]:'';
            locationParam.Address2 = (addlist!=null && addlist.size()>1)?addlist[1]:'';
            locationParam.Address3 = (addlist!=null && addlist.size()>2)?addlist[2]:'';
            locationParam.Address4 = (addlist!=null && addlist.size()>3)?addlist[3]:''; 
            locationParam.City = city;
            locationParam.State = State;
            locationParam.County = County;
            locationParam.Country = Country;
            locationParam.PostalCode = postalcode;
            partyEle.Location = locationParam;
            partyEleList.add(partyEle);
            resplist = invokeclsvar.process('','','',AccName,AccName,'','','','','','','','','','','','','','','',AccPhone,'','','', partyEleList,null); 
            system.debug('resplist-------------' + resplist);
        }catch(Exception ex){
             Apexpages.addMessages(ex);
             return null;
        
        }    
        return (resplist == null ? new list<trimblecorpComCmdm_v4.OrganizationPartyType>() : resplist);
    }
    
    
    
    //Wrapper class to pass the values into different variables which will be used in the Apex class
    public class wrappersearchresults{
        public Account accObj{get;set;}
        public List<Address__c> addressList{get;set;}

        public wrappersearchresults(Account acc, List<Address__c> addList){
            accObj = new Account();
            addressList = new List<Address__c>();
            accObj = acc;
            addressList = addList;
        }
             
   }
   
   /*
     * Method name  : cancel
     * Description  : Method to cancel the transaction at any given point of time
     * Return Type  : pagereference
     * Parameter    : NA
     */
    Public pagereference cancel(){
        pagereference p = new pagereference('/001/o');
        p.setredirect(true);
        return p;
    }
   
    
}