/*****************************************************************************************
Name    : CustomLeadConversionController 
Desc    : Used in the Custom Lead conversion page which includes all the functionality used in custom lead
conversion process


Modification Log : 
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
Vikram Mandla       31/10/2013          Created
Sunay Prasad R K    28/02/2014          Modified
Pardeep Rao         Mar/22/2014         Modified added displayMDMResults = true; on line # 103
Pardeep Rao         Mar/22/2014         Added code to get default recordtype for current user profile
Sagar Mehta         May/08/2014         Add ship to account field value on newly created opportunity
Unni Tom            Mar/24/2015         Replaced reference to "Product Family" field on Lead with "Opportunity Product".
                                        Replaced references of  User Division picklist value: "OWNERS" with "RE&WS".
                                        Modified the condition, so that Validation of Fields while Lead Conversion 
                                        is done for ALL divisions.
Aditya M            Aug/25/2018         Addition of validation relaxation logic for PocketMobile to convert lead without
                                        adding Opportunity Product (initial setup) to Lead if Tracking_Division__c = 'PocketMobile' 
                                        Line Appended - "&& (u.division__c != 'PocketMobile' || leadobj.Tracking_Division__c != 'PocketMobile')" 
                                        
                                                                                
******************************************************************************************/
public class CustomLeadConversionController {
    public id leadid;
    public id orgid{get;set;}
    public id tempid{get;set;} 
    public string convertedAccId {get; set;}  //used to update account description with Lead description for MEP Division
    
    public lead leadobjvar{get;set;}
    public lead leadobj{get;set;}
    public Task Taskobj{get;set;}
    public Event Eventobj{get;set;}
    
    public integer count;
    
    public string SelUserValue{get;set;}
    public string SelAccountName{get;set;}
    public string SelContactName{get;set;}
    public string StrAccountId{get;set;}
    public string BaseUrlVar{get;set;}
    public string stroppname{get;set;}
    public string strconverStatus{get;set;}
    public string StrSubject{get;set;}
    public string StrComments{get;set;}
    public string selectedtime{get;set;}
    public string StrAddress1{get;set;}
    public string StrAddress2{get;set;}
    public string StrAddress3{get;set;}
    public string StrAddress4{get;set;}
    public string Strcity{get;set;}
    public string Strstate{get;set;}
    public string Strcountry{get;set;}
    public string Strpostalcode{get;set;}
    public string strCountryCode{get;set;}
    public boolean NoResultsDisplay{get;set;}
    //values to get from customer master data
    public string StrAccountName{get;set;}
    public string straddress{get;set;}
    public string SelAccId{get;set;}
    public string strleadphone{get;set;}
    public string Strleadcompany{get;set;}
    public string StrLeadNmae{get;set;}
    public Boolean customerDataHubRecord{get;set;}
    public Boolean duplicateContact{get;set;}
    public boolean AttchtoExisting{get;set;}
    public boolean AttachtoConExisting{get;set;}
    public boolean OppConExisting{get;set;}
    public String compName{get;set;}
    public Boolean dupeCon{get;set;}
    public Boolean setConID{get;set;}
    
    public boolean convertAssets{get;set;} 
    public boolean stopAction{get;set;} 
    public boolean ischecked{get;set;}
    public boolean createOpp{get;set;}
    public boolean SendNotificMail{get;set;} 
    public boolean Setreminder{get;set;} 
    public boolean displayPopup {get; set;}
    public boolean DisplaySearchMDMDataPage{get;set;}  
    public boolean DisplayCreateLeadPage{get;set;}
    public boolean displayMDMResults{get;set;}
    public boolean SelAccName{get;set;}
    public boolean AccSelectedByUser;
    public boolean Setcontinueuserselection;
    public boolean SetCreatenewAccount;
    public boolean DispEnterAddressFields{get;set;}
    public boolean showCompAssetsPopUp{get;set;}
    public string Changedpicklistval{get;set;}
    public List<SelectOption> conOptions{get;set;}
    
    public list<wrappersearchresults> wrapperlist{get;set;}
    public list<trimblecorpComCmdm_v2.OrganizationPartyType> resplist;
    public List<SelectOption> options{get;set;}
    public List<Competitor_Owned_Assets__c> compAssetsAccountList{get;set;}
    public Map<Id, Competitor_Assets_Junction__c> cajMap{get;set;}
    public List<clsLeadWrapper> compAssetsLeadList{get;set;}
    public boolean InactiveUser = false;
    public Boolean validation{get;set;}//Used to avoid lead conversion in case of errors
    public Boolean validateAddress{get;set;}
    public User u;
    public class myexception extends Exception{}
    
    map<string,Task> TaskObjMap = new map<string,Task>(); 
    
    //Standard constructor to get data on page load
    public CustomLeadConversionController(ApexPages.StandardController controller) {
        
        //orgid = UserInfo.getOrganizationId();
        // BaseUrlVar = URL.getSalesforceBaseUrl().toExternalForm() + '/';
        duplicateContact = false;
        showCompAssetsPopUp = false; 
        convertAssets = false;
        displayMDMResults = true; //added by pardeep
        convertedAccId = '';  //used to updated account description with Lead description for MEP Division
        cajMap = new Map<Id, Competitor_Assets_Junction__c>();
        this.leadobjvar = (Lead)controller.getRecord();
        //system.debug('--Description--'+this.leadobjvar.Description);
        leadid = Apexpages.currentpage().getParameters().get('id');   
        if(leadid!=null){        
            leadobj = [select id,Name,FirstName,LastName,Marketing_Industry__c,Sub_Industry__c,Opportunity_Product__c , Selling_division__c, Tracking_Division__c, Email,Company,Country_Code__c ,Contact_Phone_Country_Code__c ,ownerid,street,city,state,postalcode,country,Phone,Address1__c,Address2__c,Address3__c,Address4__c from lead where id=:leadid];
        } 
        
        if(leadobj!=null ) 
        {   
            integer count = [select count() from User where IsActive=true And id=:leadobj.ownerid];
            if(count>0)          
                SelUserValue = [select id,Name,IsActive from User where IsActive=true And id=:leadobj.ownerid].Name;
            else
                //InactiveUser = true;
                SelUserValue = [select id,Name,IsActive from User where IsActive=true And id=:UserInfo.getUserId()].Name;
            
            //strcountry = leadobj.country; 
        }   
        
        u = [Select id,Name,Division__c from User where id=:UserInfo.getUserId()];
        
        if(InactiveUser == false)
        {   
            Taskobj = new task();
            Eventobj = new Event();
            stroppname = leadobj.company;
            //straddress  = leadobj.street+','+leadobj.city+','+leadobj.state+','+leadobj.postalcode+','+leadobj.country;
            //straddress  = leadobj.Address1__c+' \r\n' +leadobj.Address2__c+' \r\n' +leadobj.Address3__c+' \r\n' +leadobj.Address4__c;
            straddress  = leadobj.Address1__c;
            if(leadobj.Address2__c!=null && leadobj.Address2__c!='')
                straddress  += +' \r\n' +leadobj.Address2__c;
            if(leadobj.Address3__c!=null && leadobj.Address3__c!='')
                straddress  += +' \r\n' +leadobj.Address3__c;
            if(leadobj.Address4__c!=null && leadobj.Address4__c!='')
                straddress  += +' \r\n' +leadobj.Address4__c;
            
            StrLeadNmae = leadobj.Name;
            Strleadcompany = leadobj.Company;
            strleadphone = leadobj.Phone;
            Strcity = leadobj.city;
            Strstate = leadobj.state;
            Strcountry = leadobj.country;
            Strpostalcode = leadobj.postalcode;
            strCountryCode = leadobj.Country_Code__c;
            
            
            integer count = [select count() from Account where name=:leadobj.company];
            //if(count>0)
            //{
            DisplaySearchMDMDataPage=false;
            DisplayCreateLeadPage = true;
            /*}
else
{            
DisplaySearchMDMDataPage=true;
DisplayCreateLeadPage = false;
}*/
            validation = false;
            validateAddress = false;
            prepareaccounts();
            preparecontacts();
            DispEnterAddressFields = false;
            //DisplayUserErrors();
            //system.debug('Changedpicklistval===='+Changedpicklistval); 
        }
    }
    
    
    public CustomLeadConversionController(){}
    
    /*
* Method name  : DisplayUserErrors
* Description  : Method used to display errors to the user on page load
* Return Type  : pageReference
* Parameter    : NA
*/
    public pagereference DisplayUserErrors()
    {   
        try{
            system.debug('InactiveUser====='+InactiveUser);
            //if(InactiveUser == true)
            //throw new myexception('Please select a Active User to convert the lead');
            
            //validation = false;                  
            System.debug('VALIDATION1'+validation);
            
            //First Name is mandatory for Lead Conversion
            if(leadobj.FirstName == null || leadobj.FirstName ==''){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Lead must have First Name. Please return to the lead by clicking the cancel button below and update the First Name.'));
                validation = true;  
            } 
            
            //if(validateAddress == true){      
            //Checking for all the values in lead which needs to be populated before conversion of a lead  
            if(u.Division__c == 'RE&WS' || u.Division__c == 'Geospatial' || u.Division__c == 'GCCM'){
                if(leadobj.city == null || leadobj.city ==''){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Lead must have valid city. Please return to the lead by clicking the cancel button below and update the city.'));
                    validation = true;                                       
                } 
                if(leadobj.street == null || leadobj.street ==''){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Lead must have valid street. Please return to the lead by clicking the cancel button below and update the street.'));
                    validation = true;
                }
                else{
                    validateAddress = false;
                    validation = false;
                }
            }               
            
            if(leadobj.Marketing_Industry__c == null || leadobj.Marketing_Industry__c ==''){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Lead must have valid marketing industry. Please return to the lead by clicking the cancel button below and update the industry.'));
                validation = true;  
            }   
            
            if(leadobj.city == null || leadobj.city ==''){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Lead must have valid city. Please return to the lead by clicking the cancel button below and update the city.'));
                validation = true;
            }  
            
            if(leadobj.street == null || leadobj.street ==''){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Lead must have valid street.  Please return to the lead by clicking the cancel button below and update the street.'));
                validation = true;
            }    
            
            if(leadobj.postalcode == null || leadobj.postalcode ==''){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Lead must have valid postal code. Please return to the lead by clicking the cancel button below and update the postal code.')); 
                validation = true;
            }               
            If(u.division__c != 'PocketMobile' || leadobj.Selling_division__c != 'PocketMobile'){
            if(leadobj.Opportunity_Product__c == null || leadobj.Opportunity_Product__c =='' ) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Lead must have valid Opportunity Product. Please return to the lead by clicking the cancel button below and update the Opportunity Product.'));
                validation = true; 
                system.debug('-------------------->'+validation);
            }    
            }
            if(leadobj.Email == null || leadobj.Email ==''){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Lead must have valid email address. Please return to the lead by clicking the cancel button below and update the email address.'));
                validation = true;   
            } 
            
            if(leadobj.Phone == null || leadobj.Phone ==''){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Lead must have valid phone number. Please return to the lead by clicking the cancel button below and update the phone number.')); 
                validation = true;
            } 
            
            else{
                validateAddress = false;
                validation = false;
            }   
            
            //}
        }catch(exception ex){
            Apexpages.addMessages(ex);
        }
        pagereference p = new pagereference('/'+leadobj.id);
        p.setredirect(false);
        //return p;
        return null;
    }
    
    /*
* Method name  : prepareaccounts
* Description  : Method used to get the accounts based on the lead company name and show it as the attach to existing option
* Return Type  : List<SelectOption>
* Parameter    : NA
*/
    public List<SelectOption> prepareaccounts() {
        string strAccountName,strAccountName2,strAccountName3;
        string NewAccName;
        string splitAccName;
        string strAccountName1 = leadobj.company;
        options = new List<SelectOption>();
        List<String> existingaccList = new List<String>();
        List<Account> accountList;
        //integer count = [select count() from Account where name=:strAccountName and BillingStreet  = : leadobj.street and BillingCity = : leadobj.city and BillingState = :leadobj.state and BillingPostalCode =:leadobj.postalcode and BillingCountry =: leadobj.country ];
        /* if(SelAccId!=null && SelAccId!=''  && AccSelectedByUser == true)
{
integer AcCount = [select count() from Account where Name=:SelAccId];
if(AcCount>0)
{
NewAccName = [select Name from Account where Name=:SelAccId].Name;
strAccountName3 = 'Create New Account : '+NewAccName;
}
if(strAccountName3!=null && strAccountName3!='')
options.add(new SelectOption(strAccountName3,strAccountName3));
stroppname = NewAccName;
}
else{*/
        system.debug('changedvalue========'+changedvalue);
        if(changedvalue!=null && changedvalue!='')
        {
            
            integer AcCount = [select count() from Account where Name=:changedvalue];
            if(AcCount > 0)
            {
                //NewAccName = [select Name from Account where Name=:changedvalue limit 1].Name;
                //strAccountName3 = 'Attach to Existing: '+NewAccName;
                for(Account acc:[select Name from Account where Name=:changedvalue]){
                    existingaccList.add(acc.Name);
                    //strContactName = 'Attach to Existing : '+existingConName;
                } 
                for(String str:existingaccList){
                    strAccountName3 = 'Attach to Existing: '+str;
                    options.add(new SelectOption(strAccountName3,strAccountName3));
                }
            }
            //if(strAccountName3!=null && strAccountName3!='')
            // options.add(new SelectOption(strAccountName3,strAccountName3));
            
            preparecontacts();
        }
        
        integer count = [select count() from Account where name=:leadobj.company];
        if(count>0)
        {
            strAccountName2 = 'Create New Account: '+strAccountName1;
            accountList = [Select Name from Account where Name LIKE :leadobj.company];
            for(Account acc:accountList){
                existingaccList.add(acc.Name);
                //strContactName = 'Attach to Existing : '+existingConName;
            } 
            System.debug(existingaccList);
            for(String str:existingaccList){
                strAccountName = 'Attach to Existing: '+str;
                options.add(new SelectOption(strAccountName,strAccountName));
            }
            //strAccountName = 'Attach to Existing: '+strAccountName1;
        }
        else{
            strAccountName = 'Create New Account: '+strAccountName1;                               
            
            options.add(new SelectOption(strAccountName,strAccountName));
        }    
        if(strAccountName2!=null && strAccountName2!='')
            options.add(new SelectOption(strAccountName2,strAccountName2));
        //}
        
        system.debug('options====='+options);
        return options;
    }
    
    /*
* Method name  : preparecontacts
* Description  : Method used to get the accounts based on the lead company name and show it as the attach to existing option
* Return Type  : List<SelectOption>
* Parameter    : NA
*/
    public List<SelectOption> preparecontacts() {
        string strContactName,strContactName2,strContactName3;
        string NewConName;
        string existingConName;
        string FirstNewConName;
        string SecondNewConName;
        string strContactName1;
        if(leadobj.FirstName!=Null)
            strContactName1 = leadobj.FirstName + ' ' + leadobj.LastName;
        else
            strContactName1 = leadobj.LastName;
        conOptions = new List<SelectOption>();
        List<String> existingconList = new List<String>();
        integer count;          
        List<Contact> contactList;
        
        if(changedConvalue!=null && changedConvalue!='')
        {
            
            integer ConCount = [select count() from Contact where Name=:changedConvalue];
            if(ConCount>0)
            {
                //FirstNewConName = [select Name from Contact where Name=:changedConvalue limit 1].FirstName; 
                //SecondNewConName = [select Name from Contact where Name=:changedConvalue limit 1].LastName;
                //if(FirstNewConName!=null)
                // NewConName = FirstNewConName + ' ' + SecondNewConName;
                // else
                // NewConName = SecondNewConName;
                for(Contact con:[select Name,FirstName,LastName from Contact where Name=:changedConvalue]){
                    if(con.FirstName!=null)
                        existingconList.add(con.FirstName + ' ' + con.LastName);
                    else
                        existingconList.add(con.LastName);
                    //strContactName = 'Attach to Existing : '+existingConName;
                } 
                for(String str:existingconList){
                    strContactName3 = 'Attach to Existing: '+str;
                    conOptions.add(new SelectOption(strContactName3,strContactName3));
                }
                //System.debug(NewConName);
                //strContactName3 = 'Attach to Existing: '+NewConName;
            }
            //if(strContactName3!=null && strContactName3!='')
            //conOptions.add(new SelectOption(strContactName3,strContactName3));
        }
        if(SelAccId != NULL)
            count = [select count() from Contact where (FirstName=:leadobj.FirstName OR LastName=:leadobj.LastName OR FirstName=:leadobj.LastName OR LastName=:leadobj.FirstName) AND Account.FCH_Party_ID__c =:SelAccId.trim()];
        else if(changedvalue == null)
            count = [select count() from Contact where (FirstName=:leadobj.FirstName OR LastName=:leadobj.LastName OR FirstName=:leadobj.LastName OR LastName=:leadobj.FirstName) AND Account.Name =:leadobj.Company];
        else if(compName != null)
            count = [select count() from Contact where (FirstName=:leadobj.FirstName OR LastName=:leadobj.LastName OR FirstName=:leadobj.LastName OR LastName=:leadobj.FirstName) AND Account.Name =:compName];
        else
            count = [select count() from Contact where (FirstName=:leadobj.FirstName OR LastName=:leadobj.LastName OR FirstName=:leadobj.LastName OR LastName=:leadobj.FirstName) AND Account.Name =:changedvalue];
        
        if(count>0)
        {
            if(SelAccId != NULL)
                contactList = [select Name,FirstName,LastName from Contact where (FirstName=:leadobj.FirstName OR LastName=:leadobj.LastName OR FirstName=:leadobj.LastName OR LastName=:leadobj.FirstName) AND Account.FCH_Party_ID__c =:SelAccId.trim()];
            else if(changedvalue == null)
                contactList = [select Name,FirstName,LastName from Contact where (FirstName=:leadobj.FirstName OR LastName=:leadobj.LastName OR FirstName=:leadobj.LastName OR LastName=:leadobj.FirstName) AND Account.Name = :leadobj.Company];
            else if(compName != null)
                contactList = [select Name,FirstName,LastName from Contact where (FirstName=:leadobj.FirstName OR LastName=:leadobj.LastName OR FirstName=:leadobj.LastName OR LastName=:leadobj.FirstName) AND Account.Name =:compName];
            else
                contactList = [select Name,FirstName,LastName from Contact where (FirstName=:leadobj.FirstName OR LastName=:leadobj.LastName OR FirstName=:leadobj.LastName OR LastName=:leadobj.FirstName) AND Account.Name = :changedvalue];
            
            strContactName2 = 'Create New Contact: '+strContactName1;
            for(Contact con:contactList){
                if(con.FirstName!=null)
                    existingconList.add(con.FirstName + ' ' + con.LastName);
                else
                    existingconList.add(con.LastName);
                //strContactName = 'Attach to Existing : '+existingConName;
            }   
            System.debug('existingList===='+existingconList);
            for(String str:existingconList){
                strContactName = 'Attach to Existing: '+str;
                conOptions.add(new SelectOption(strContactName,strContactName));
            }
        }
        else
            strContactName = 'Create New Contact: '+strContactName1;                               
        
        //conOptions.add(new SelectOption(strContactName,strContactName));
        if(strContactName2!=null && strContactName2!='')
            conOptions.add(new SelectOption(strContactName2,strContactName2));
        //}
        
        system.debug('conOptions====='+conOptions);
        return conOptions;
    }
    
    /*
* Method name  : gettimes
* Description  : Method used to get the times to display in reminder section of the page
* Return Type  : List<SelectOption>
* Parameter    : NA
*/
    public List<SelectOption> gettimes() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('12:00 AM','12:00 AM'));
        options.add(new SelectOption('12:30 AM','12:30 AM'));
        for(integer i=1;i<24;i++)
        {
            if(i<12)
            {
                string str = string.valueof(i)+':00 AM';
                string str1 = string.valueof(i)+':30 AM';        
                options.add(new SelectOption(str,str));
                options.add(new SelectOption(str1,str1));
            }
            if(i>=12)
            {
                if(i==12)
                {
                    string str = string.valueof(i)+':00 PM';
                    string str1 = string.valueof(i)+':30 PM';        
                    options.add(new SelectOption(str,str));
                    options.add(new SelectOption(str1,str1));    
                }
                else{
                    integer p = i-12;
                    string str = string.valueof(p)+':00 PM';
                    string str1 = string.valueof(p)+':30 PM';        
                    options.add(new SelectOption(str,str));
                    options.add(new SelectOption(str1,str1));
                }
            }
        }
        return options;
    }    
    
    Public pagereference cancel(){
        pagereference p = new pagereference('/'+leadobj.id);
        p.setredirect(true);
        return p;
    }    
    
    /*
* Method name  : SearchCustomerMaster
* Description  : Method used to search for Customer data in FCH server/Customer Data Hub
* Return Type  : pageReference
* Parameter    : NA
*/ 
    public pagereference SearchCustomerMaster()
    {     
        String NoResults = System.Label.No_records_found;
        wrapperlist = new list<wrappersearchresults>();   
        NoResultsDisplay = false;
        
        try{
            if(Strcountry == null || Strcountry =='')
                throw new myexception('Please enter a valid Country name');
            if(Strcountry!=null && Strcountry!='')
            {                   
                Country_Region_Mapping__c CountryObj = Country_Region_Mapping__c.getValues(Strcountry);
                
                if(CountryObj==null )
                {
                    throw new myexception('Please enter a valid Country name');
                }
            }
            if(straddress == null || straddress =='')
                throw new myexception('Please enter a valid Address');
            if(strcity == null || strcity =='')
                throw new myexception('Please enter a valid City name');
            list<trimblecorpComCmdm_v2.OrganizationPartyType> responselist = searchinMDMdata();
            
            //This code is used to display the message if no records is found on search from MDM
            if(resplist.size()==0)
                NoResultsDisplay = true;   
            
            for(trimblecorpComCmdm_v2.OrganizationPartyType respvar : resplist)
            {
                //system.debug('respvar======'+respvar);
                String SiteName;
                string street = respvar.partysite.location.address1;
                if(respvar.partysite.location.address2!=null && respvar.partysite.location.address2!='')
                    street += +','+respvar.partysite.location.address2;
                if(respvar.partysite.location.address3!=null && respvar.partysite.location.address3!='')
                    street += +','+respvar.partysite.location.address3;
                if(respvar.partysite.location.address4!=null && respvar.partysite.location.address4!='')
                    street += +','+respvar.partysite.location.address4;
                
                /*String[] cName = respvar.organizationname.split('-');
String orgName = cName[0];

if(cName.size()>1){
if(cName[1] != NULL || cName[1]!='')
SiteName = cName[1];
}*/
                String orgName = respvar.organizationname;
                SiteName = respvar.partysite.PartySiteName;
                wrapperlist.add(new wrappersearchresults(orgName,SiteName,street,respvar.partysite.location.city,respvar.partysite.location.state,respvar.partysite.location.country,respvar.partysite.location.PostalCode,respvar.PrimaryPhoneNumber,respvar.PartyId,respvar.EnterprisePartyNumber));
            }
            displayMDMResults = true;
        }
        catch(Exception ex)
        {
            Apexpages.addmessages(ex);
            return null;
        }
        return null;
    }
    
    /*
* Method name  : searchinMDMdata
* Description  : Method used to search for Customer data in FCH server/Customer Data Hub which will return the results if found
* Return Type  : list<trimblecorpComCmdm_v2.OrganizationPartyType>
* Parameter    : NA
*/
    public list<trimblecorpComCmdm_v2.OrganizationPartyType> searchinMDMdata()
    {
        resplist = new list<trimblecorpComCmdm_v2.OrganizationPartyType>();
        //string strstreet,strcity,strstate,strCountry,StrPostalacode;
        list<string> strAddLength = new list<string>();//to check the address length       
        
        //construction of the webservice to initiate the call to FCH server
        invokewebserviceForSearchBeforeCreate invokeclsvar = new invokewebserviceForSearchBeforeCreate();
        system.debug('StrLeadNmae===='+StrLeadNmae+'=====Strleadcompany===='+Strleadcompany+'=====straddress===='+straddress+'=====strleadphone===='+strleadphone);     
        //resplist = invokeclsvar.SearchForAccount(string.valueof(leadobj.name), '', string.valueof(leadobj.city),string.valueof(leadobj.state), string.valueof(leadobj.country), string.valueof(leadobj.postalcode),string.valueof(leadobj.company),string.valueof(leadobj.phone));
        
        try{
            /* if(straddress!=null && straddress!='')    
{
if(straddress.indexof(',')>0)
strAddLength = straddress.split(','); 
integer Addlength = (strAddLength!=null && strAddLength.size()>0)?strAddLength.size():0;
system.debug('Addlength======'+Addlength);
if(Addlength!=5)
throw new myexception('please enter a valid address separated by comma In the format street,city,state,postal code,country');

}
else
throw new myexception('please enter a valid address separated by comma In the format street,city,state,postal code,country');
*/
            //method to invoke the webservice 
            resplist = invokeclsvar.SearchForAccount(StrLeadNmae, straddress, strcity,strstate, strCountry, StrPostalcode,Strleadcompany,strleadphone);
            // resplist = invokeclsvar.SearchForAccount(StrLeadNmae,  '', string.valueof(leadobj.city),string.valueof(leadobj.state), string.valueof(leadobj.country), string.valueof(leadobj.postalcode),Strleadcompany,strleadphone);
        }
        catch(exception ex)
        {
            Apexpages.addmessages(ex);
            return null;
        }
        return resplist;
    }
    
    /*
* Method name  : continuetoPage
* Description  : Method used to do the lead conversion by calling convert lead method
* Return Type  : pageReference
* Parameter    : NA
*/ 
    public pagereference continuetoPage(){        
        //system.debug('tempid====='+SelAccId);
        //DisplaySearchMDMDataPage=false;
        //DisplayCreateLeadPage = true;
        pagereference pageref;
        string URLvar;
        String str;
        try{
            //if(strleadphone!=null && strleadphone!='')
            if(strCountryCode!=null && strCountryCode!='')
            {
                if(strCountryCode.indexOf('+')<0)
                    throw new myexception('Country code must begin with "+"');
            }
            if(Strcountry == null || Strcountry =='')
                throw new myexception('Please enter a valid Country name');
            if(Strcountry!=null && Strcountry!='')
            {                   
                Country_Region_Mapping__c CountryObj = Country_Region_Mapping__c.getValues(Strcountry);
                
                if(CountryObj==null )
                {
                    throw new myexception('Please enter a valid Country name');
                }
            }
            if(straddress == null || straddress =='')
                throw new myexception('Please enter a valid Address');
            if(strcity == null || strcity =='')
                throw new myexception('Please enter a valid City name');
            /*if(((strCountryCode!=null && strCountryCode!='') && (strleadphone==null || strleadphone=='')) || ((strCountryCode==null && strCountryCode=='') && (strleadphone!=null && strleadphone!='')))
{
throw new myexception('Country Code and Phone must be populated together.');
}
*/
            SetCreatenewAccount = true;  
            dupecon = false;     
            convertAssets = true;
            pageref =  ConvertLead();
            
            //for Record locking error
            /*    URLvar = 'setup/ui/recordtypeselect.jsp?ent=Account&retURL=%2F001%2Fo&save_new_url=%2F001%2Fe%3FretURL%3D%252F001%252Fo&nooverride=1';


if(Strleadcompany!=null && Strleadcompany!='')
URLvar +='&'+Label.Account_Name_ID+'='+Strleadcompany; 

if(StrCountryCode!=null && StrCountryCode!='')
URLvar +='&'+Label.Country_Code_Id+'='+'%2B'+StrCountryCode.trim();

if(strleadphone!=null && strleadphone!='')
URLvar +='&'+Label.Phone_Id+'='+strleadphone;

if(strcountry!=null && strcountry!='')
URLvar +='&'+Label.Country+'='+strcountry;

if(straddress!=null && straddress!='')
URLvar +='&'+Label.Sreet_Address+'='+straddress;

if(strcity!=null && strcity!='')
URLvar +='&'+Label.City+'='+strcity;

if(strpostalcode!=null && strpostalcode!='')
URLvar +='&'+Label.Zip+'='+strpostalcode;

if(strstate!=null && strstate!='')
URLvar +='&'+Label.State+'='+strstate;

pageref = new pagereference('/'+URLvar);

pageref.setredirect(true);*/
            
            //End of record lockng issue
        }
        catch(exception ex)
        {
            Apexpages.addMessages(ex);
            
            pageref = null;
            
        }      
        
        //if(u.Division__c == 'MEP'){
        updateConvertedAccount();  //used to updated account description with Lead description for MEP Division
        //}
        return pageref;    
    }    
    
    /*
* Method name  : COntinueWithUserSelection
* Description  : Method to use the account retrieved from Customer data hub
* Return Type  : pageReference
* Parameter    : NA
*/
    public pagereference COntinueWithUserSelection()
    {
        AccSelectedByUser = true;
        customerDataHubRecord = false;
        dupecon = true;
        pagereference pageref;
        try{
            if(SelAccId == '' || SelAccId == NULL)
                throw new myexception('Please select An account to proceed with continue');
            Setcontinueuserselection = true;
            customerDataHubRecord = true;
            //OppConExisting = true;
            convertAssets = true;
            pageref =  ConvertLead();    
            if(u.Division__c == 'MEP'){
                updateConvertedAccount();  //used to updated account description with Lead description for MEP Division
            }
            return pageref;  
        }
        catch(Exception ex)
        {
            Apexpages.addMessages(ex);
            system.debug('exception======'+ex);
            system.debug('exception======'+ex.getstacktracestring());
            pageref=null;
        }
        return pageref;           
        
    }
    
    /*
* Method name  : validateCompetitorAssets
* Description  : Method to validate competitor assets on a lead and selected account record.
* Return Type  : void
* Parameter    : NA
*/
    public void validateCompetitorAssets(){
        boolean AttchtoExisting;
        compAssetsAccountList = new List<Competitor_Owned_Assets__c>();
        compAssetsLeadList = new List<clsLeadWrapper>();
        
        if(!validation){    
            if(SelAccountName!=null && SelAccountName!='' ){   
                if(SelAccountName.contains(':')){
                    string[] stracc = SelAccountName.split(':');
                    SelAccountName = stracc[1];               
                    stracc[0] = stracc[0].trim();
                    if(stracc[0]!=null && stracc[0]!='' && stracc[0].equalsIgnoreCase('Attach to Existing') )
                        AttchtoExisting = true;
                    else
                        AttchtoExisting = false; 
                }else{
                    if(SetCreatenewAccount == true){
                        AttchtoExisting = false;
                        validateAddress = true;
                    }
                }
            }
            
            
            List<Account> accList = new List<Account>();
            accList = [select Id from Account where Name =: SelAccountName.trim() limit 1];  
            Set<Id> compAssetIdSet = new Set<Id>();
            List<Competitor_Assets_Junction__c> cajList = new List<Competitor_Assets_Junction__c>();                      
            cajList = [Select Id, Competitor_Assets__c, Account__c, Opportunity__c from Competitor_Assets_Junction__c where Lead__c =: leadid];
            
            for(Competitor_Assets_Junction__c caj : cajList){
                compAssetIdSet.add(caj.Competitor_Assets__c);
                cajMap.put(caj.Competitor_Assets__c, caj);
            }
            
            List<Competitor_Owned_Assets__c> leadList = new List<Competitor_Owned_Assets__c>();
            leadList = [SELECT Id, Name, Product__r.Name, Competitor_Company__c, Competitor_Company__r.Name, Number_of_Licenses__c, 
                        Product_Version__c, Yearly_Subscription_Cost__c, Install_Date__c, Expiration_Date__c FROM 
                        Competitor_Owned_Assets__c where Id IN: compAssetIdSet order by Product__r.Name];
            
            for(Competitor_Owned_Assets__c compAsset : leadList){
                clsLeadWrapper wrapper = new clsLeadWrapper();
                wrapper.isSelected = false;
                wrapper.asset = compAsset;
                compAssetsLeadList.add(wrapper); 
            }          
            if(accList.size() > 0){                   
                Id acId = accList.get(0).Id;
                Set<Id> compAssetSet = new Set<Id>(); 
                List<Competitor_Assets_Junction__c> cajAccountList = new List<Competitor_Assets_Junction__c>();
                cajAccountList = [Select Id, Competitor_Assets__c from Competitor_Assets_Junction__c where Account__c =: acId];
                
                for(Competitor_Assets_Junction__c caj : cajAccountList){
                    compAssetSet.add(caj.Competitor_Assets__c);
                }          
                compAssetsAccountList = [SELECT Id, Name, Product__r.Name, Competitor_Company__c, Competitor_Company__r.Name, Number_of_Licenses__c, 
                                         Product_Version__c, Yearly_Subscription_Cost__c, Install_Date__c, Expiration_Date__c FROM Competitor_Owned_Assets__c 
                                         where Id IN: compAssetSet order by Product__r.Name];
            }  
            
            if(AttchtoExisting && compAssetsAccountList.size() > 0){        
                Integer compCount = [Select count() from Competitor_Assets_Junction__c where Lead__c =: leadid];
                if(compCount > 0){
                    showCompAssetsPopUp = true;
                }else{
                    showCompAssetsPopUp = false;
                }
            }else{
                showCompAssetsPopUp = false;
            }
        }    
    }
    
    
    /*
* Method name  : convertFromContact
* Description  : Method to call the convert lead method if a duplicate contact is found
* Return Type  : pageReference
* Parameter    : NA
*/
    public pagereference convertFromContact()
    {        
        pagereference pageref;
        try{
            if(AttachtoConExisting == false)
                AttchtoExisting = true;
            else
                AttchtoExisting = false;
            
            AttachtoConExisting = false;
            dupeCon = false;
            if(customerDataHubRecord == true)
                Setcontinueuserselection = true;
            duplicateContact = false;
            convertAssets = true;
            pageref =  ConvertLead();    
            if(u.Division__c == 'MEP'){
                updateConvertedAccount();  //used to updated account description with Lead description for MEP Division
            }
            return pageref;  
        }
        catch(Exception ex)
        {
            Apexpages.addMessages(ex);
            system.debug('exception======'+ex);
            system.debug('exception======'+ex.getstacktracestring());
            pageref=null;
        }
        return pageref;           
        
    }
    
    /*
* Method name  : ConvertLead
* Description  : Method used to the convert the lead
* Return Type  : pageReference
* Parameter    : NA
*/
    Public pagereference ConvertLead(){
        boolean createCon;
        boolean convert;
        string accid;
        string struserid;
        string contactid;
        integer hourvar;
        integer minutevar;
        integer secondsvar = 0;
        integer millisecondsvar = 0;
        Database.LeadConvertResult lcr;
        Database.LeadConvert lc = new Database.LeadConvert();
        id straccid;
        pagereference p;
        
        //DisplayUserErrors();
        
        //AttchtoExisting = false;
        System.debug('VALIDATION'+validation);
        if(validation == false){ 
            system.debug('SelAccountName=========='+SelAccountName+'======SelUserValue====='+SelUserValue+'showCompAssetsPopUp==='+showCompAssetsPopUp);
            
            integer usercount = [select count() from user where IsActive=true And name=: SelUserValue AND UserRoleId != NULL];
            
            // code to get default record type for the user profile
            Id recordTypeId =null;
            for (Schema.RecordTypeInfo rtInfo : Account.SObjectType.getDescribe().getRecordTypeInfos()) {
                
                if (rtInfo.isDefaultRecordTypeMapping()) {
                    recordTypeId =rtInfo.getRecordTypeId();
                }
            }
            
            /*/old code 

Id recordTypeId = [Select Id from RecordType where DeveloperName = 'Account_Pending_Record_Type' Limit 1].Id;
*/                     
            if(usercount > 0){
                List<User> userList = new List<User>();            
                userList = [select id, Name from user where IsActive=true And name =: SelUserValue AND UserRoleId != NULL];                        
                if(userList.size() > 0)
                    struserid = userList.get(0).id;
            }
            AttachtoConExisting = false;
            createCon = false;
            try{
                if(SelAccountName!=null && SelAccountName!='' ){   
                    if(SelAccountName.contains(':')){
                        string[] stracc = SelAccountName.split(':');
                        SelAccountName = stracc[1];
                        system.debug('Pardeep =SelAccountName='+SelAccountName+'AND FCH_Party_ID__c ='+SelAccId);
                        stracc[0] = stracc[0].trim();
                        if(stracc[0]!=null && stracc[0]!='' && stracc[0].equalsIgnoreCase('Attach to Existing') ){
                            AttchtoExisting = true;
                            dupecon = true;
                        } 
                        else{
                            AttchtoExisting = false;
                            validateAddress = true;
                        }   
                    }else{
                        if(SetCreatenewAccount == true){
                            AttchtoExisting = false;
                            validateAddress = true;
                        }
                    }
                }
                System.debug('VALIDATEADDRESS'+validateAddress);
                if(validateAddress == true)
                    DisplayUserErrors();
                
                if(validateAddress == false){
                    if(SelContactName!=null && SelContactName!=''){
                        if(SelContactName.contains(':')){
                            string[] stracc = SelContactName.split(':');
                            SelContactName = stracc[1];
                            stracc[0] = stracc[0].trim();
                            if(stracc[0]!=null && stracc[0]!='' && stracc[0].equalsIgnoreCase('Attach to Existing') ){
                                AttachtoConExisting = true;
                                Setcontinueuserselection = false;
                                dupecon = true;
                            }    
                            else{
                                AttachtoConExisting = false; 
                                //AttchtoExisting = true;
                                createCon = true;
                                OppConExisting = false;
                            }
                        }
                    }
                    
                    //for loop to get the tasks if the details are entered in the page
                    for(Task taskobjvar:[select id,Description,IsReminderSet,WhoId,OwnerId,ReminderDateTime from Task where whoid = : leadobj.id]){
                        TaskObjMap.put(taskobjvar.WhoId,taskobjvar);
                    }
                    
                    
                    system.debug('leadid'+leadid+'=='+AttachtoConExisting +'==============='+OppConExisting +'==============='+ Setcontinueuserselection+'=============='+SetCreatenewAccount+'====='+AttchtoExisting+'======'+SelAccountName);      
                    if(leadid!=null){
                        lc.setLeadId(leadid);
                        
                        if(createOpp == true)
                            lc.setDoNotCreateOpportunity(True);
                        if(SendNotificMail == true)
                            lc.setsendNotificationEmail(true);
                        if(stroppname!=null && stroppname!='' && stroppname!= leadobj.company)
                            lc.setopportunityname(stroppname);
                        
                        system.debug('Pardeep =SelAccountName='+SelAccountName+'AND FCH_Party_ID__c ='+SelAccId);
                        
                        if((AttchtoExisting == true || OppConExisting == true || AttachtoConExisting == true) && SelAccountName != null && (dupeCon==true || createCon == true) && Setcontinueuserselection != true){
                            
                            if(SelAccId != NUll){
                                List<Account> accList = new List<Account>();
                                accList = [select id,name from Account where FCH_Party_ID__c = :SelAccId.trim() order by CreatedDate  limit 1];
                                if(!accList.isEmpty()){
                                    accid = accList[0].Id; 
                                }
                            }else{
                                List<Account> accList = new List<Account>();
                                accList = [select id,name from Account where Name = :SelAccountName.trim() order by CreatedDate  limit 1 ];
                                if(!accList.isEmpty()){
                                    accid = accList[0].Id; 
                                }                                                                
                            }                           
                            
                            List<Account> accList = [select id,name,type,Sub_type__c from Account where id = :accid];
                            
                            if(accid!=null && accid!='')
                            {
                                lc.setaccountId(accid);
                            }
                            preparecontacts();
                            integer concount = [select count() from contact where AccountId = :accid AND (FirstName =:leadobj.FirstName OR LastName =:leadobj.LastName OR FirstName =:leadobj.LastName OR LastName =:leadobj.FirstName)];
                            if(concount>0 && ((AttachtoConExisting == false && createCon == false) || OppConExisting == true)){
                                //contactid = [select id,Name,AccountId from contact where AccountId = :accid AND (FirstName =:leadobj.FirstName OR LastName =:leadobj.LastName) limit 1].id;
                                //lc.setcontactId(contactid);
                                showCompAssetsPopUp = false;
                                duplicateContact = true;
                                convert = false;
                                AttchtoExisting = true;
                            }else{
                                convert = true;
                                OppConExisting = false;
                            }    
                            System.debug('Pardeep+accid'+accid+'duplicateContact='+duplicateContact+'AttachtoConExisting='+AttachtoConExisting);
                            System.debug(duplicateContact);
                            System.debug(AttachtoConExisting);
                            System.debug(SelContactName);
                            if(AttachtoConExisting == true){
                                List<Contact> contList = [select id,Name,AccountId from contact where AccountId = :accid AND Name = :SelContactName.trim() limit 1];
                                if(!contList.isEmpty()){
                                    contactid = contList[0].Id;
                                }
                                
                                lc.setcontactId(contactid);
                                duplicateContact = false;
                                convert = true;
                            }
                            
                            if(Taskobj !=null){   
                                if(TaskObjMap.get(leadobj.id)!=null)
                                    Taskobj = TaskObjMap.get(leadobj.id);
                                
                                Taskobj.Description = StrComments;
                                Taskobj.IsReminderSet = true;
                                Taskobj.WhoId = leadobj.id;
                                Taskobj.WhatId = straccid;
                                Taskobj.OwnerId = struserid;
                                if(Setreminder == true){
                                    date datevar = Eventobj.Activitydate;
                                    if(selectedtime!=null && selectedtime!=''){
                                        string[] timesplitArr = selectedtime.split(':');
                                        hourvar = integer.valueof(timesplitArr[0]);
                                        
                                        string[] timesplitArr1 = timesplitArr[1].split(' ');
                                        minutevar = integer.valueof(timesplitArr1[0]);                       
                                    }    
                                    if(Eventobj.Activitydate!=null)
                                        Taskobj.ReminderDateTime = Datetime.newinstance(Eventobj.Activitydate,Time.newInstance(hourvar ,minutevar ,secondsvar ,millisecondsvar ));
                                }    
                            }
                            if(Taskobj!=null && taskobj.subject!=null && taskobj.subject!='')
                                upsert Taskobj;
                            
                            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1]; 
                            lc.setConvertedStatus(convertStatus.MasterLabel);
                            
                            if(struserid!=null && struserid!='')
                                lc.setOwnerId(struserid);
                            
                            System.debug(convert+'======'+OppConExisting);
                            if(convert == true && OppConExisting == false){
                                
                                lcr = Database.convertLead(lc);
                                System.assert(lcr.isSuccess());
                                /*if(!accList.isEmpty()){
if(accList[0].type == null || accList[0].type=='')
accList[0].type = 'Customer';
accList[0].Sell_ToFlag__c = true; */
                                
                                
                                /*if(acc.sub_type__c == null || acc.sub_type__c=='')
acc.sub_type__c = 'Division Key Account';
*/
                                
                                /*system.debug('accList[0]>>>>'+accList[0]);
update accList[0];
}*/
                                straccid = lcr.getaccountid();
                                convertedAccId = String.valueOf(straccid);  //used to updated account description with Lead description for MEP Division
                                
                                if(accid!=null && accid!='')
                                    straccid = accid ;
                                convertedAccId = String.valueOf(straccid);  //used to updated account description with Lead description for MEP Division
                                //for task creation
                                
                                p = new pagereference('/'+straccid);
                                p.setredirect(true);
                                //return p; 
                            }                       
                        }
                        
                        System.debug(Setcontinueuserselection+'======'+duplicateContact+'======'+AttachtoConExisting);
                        if(Setcontinueuserselection == true && duplicateContact == false && AttachtoConExisting == false){
                            Account acc; 
                            
                            list<trimblecorpComCmdm_v2.OrganizationPartyType> responselist1 = searchinMDMdata();
                            
                            Set<String> enterpriseMasterId = new Set<String>();
                            
                            for(trimblecorpComCmdm_v2.OrganizationPartyType respvar : responselist1){
                                if(respvar.PartyId != NULL || respvar.PartyId != '')
                                    enterpriseMasterId.add(respvar.PartyId);
                                
                            }
                            System.debug(SelAccId);
                            
                            List<Account> accList = [Select id,FCH_Party_ID__c,Name from Account where FCH_Party_ID__c =:SelAccId.trim()];
                            
                            if(accList.size()>0){
                                acc = accList[0];
                                compName = accList[0].Name;
                                
                                if(dupeCon == true){
                                    preparecontacts();
                                    integer concount = [select count() from contact where AccountId = :accList[0].Id AND (FirstName =:leadobj.FirstName OR LastName =:leadobj.LastName OR FirstName =:leadobj.LastName OR LastName =:leadobj.FirstName)];
                                    if(concount>0){
                                        duplicateContact = true;
                                        setConID = true;
                                    }   
                                    else
                                        duplicateContact = false;
                                }
                                else{
                                    duplicateContact = false;
                                    setConID = false;
                                }
                                
                                if(duplicateContact == false){
                                    lc.setaccountId(acc.id);
                                    LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1]; 
                                    
                                    lc.setConvertedStatus(convertStatus.MasterLabel);
                                    system.debug('Pardeep setConID acc.id='+acc.id+'SelContactName='+SelContactName+'setConID='+setConID+'createCon='+createCon);
                                    if(setConID == true){
                                        system.debug('Pardeep acc.id='+acc.id+'SelContactName='+SelContactName);
                                        contactid = [select id,Name,AccountId from contact where AccountId = :acc.id AND Name = :SelContactName.trim() limit 1].id;
                                        lc.setcontactId(contactid);
                                        
                                    }
                                    if(struserid!=null && struserid!='')
                                        lc.setOwnerId(struserid);
                                    system.debug('pardeep1 =lc.getAccountId()='+lc.getAccountId()+'lc.getContactId()='+lc.getContactId());
                                    lcr = Database.convertLead(lc);
                                    System.debug('LCR'+lcr);
                                    System.assert(lcr.isSuccess());
                                    
                                    system.debug('pardeep2 =lc.getaccountid()='+lcr.getaccountid());
                                    straccid = lcr.getaccountid();
                                    convertedAccId = String.valueOf(straccid);  //used to updated account description with Lead description for MEP Division
                                }   
                            }else{
                                for(trimblecorpComCmdm_v2.OrganizationPartyType respvar : responselist1){
                                    if(respvar.PartyId == SelAccId.trim()){
                                        acc = new Account();
                                        /*String[] cName = respvar.organizationname.split('-');
acc.Name = cName[0];

if(cName.size()>1){
if(cName[1] != NULL || cName[1]!='')
acc.Site_Name__c = cName[1];
}*/
                                        acc.Name = respvar.organizationname;
                                        acc.Site_Name__c = respvar.partysite.PartySiteName;
                                        acc.BillingCity = respvar.partysite.location.city;  
                                        acc.billingstate = respvar.partysite.location.state;                
                                        acc.billingcountry = respvar.partysite.location.country;
                                        acc.phone = respvar.PrimaryPhoneNumber; 
                                        
                                        acc.Address1__c = respvar.partysite.location.address1;
                                        acc.Address2__c = respvar.partysite.location.address2;
                                        acc.Address3__c = respvar.partysite.location.address3;
                                        acc.Address4__c = respvar.partysite.location.address4;
                                        acc.BillingStreet = respvar.partysite.location.address1;
                                        
                                        
                                        if(acc.type == null || acc.type=='')
                                            acc.type = 'Customer';
                                        /*if(acc.sub_type__c == null || acc.sub_type__c=='')
acc.sub_type__c = 'Division Key Account';
*/
                                        acc.Account_Status__c = 'Active';
                                        acc.FCH_Party_ID__c =respvar.PartyId;
                                        acc.Parent_Account_ID__c =respvar.Parent_PartyId;
                                        
                                        acc.Lifecycle_Stage__c = respvar.LifecycleStage_c;
                                        acc.sub_type__c = respvar.CustomerLevel_c;
                                        System.debug('customerDataHubRecord'+customerDataHubRecord);
                                        if(customerDataHubRecord == false){
                                            acc.Record_Lock__c = TRUE;
                                        }else{
                                            acc.Record_Lock__c = FALSE;
                                        }   
                                        
                                        acc.Enterprise_Party_Number__c = respvar.EnterprisePartyNumber;
                                        acc.Region__c = respvar.PrimaryRegion_c;
                                        acc.Global_Opt_Out__c = (respvar.GlobalOptOut_c!=null && respvar.GlobalOptOut_c!='')?(respvar.GlobalOptOut_c.equalsIgnoreCase('yes')?true:false):false;
                                        acc.Restricted_Entity__c = (respvar.RestrictedPartyIndicator_c!=null && respvar.RestrictedPartyIndicator_c!='')?(respvar.RestrictedPartyIndicator_c.equalsIgnoreCase('yes')?Label.Restricted:Label.Not_Restricted):Label.Not_Restricted;
                                        acc.DUNS__c = respvar.DUNSNumberC;
                                        acc.Vertical_Classification__c = respvar.VerticalClassification_c;
                                        acc.Credit_Check_Status__c = respvar.CreditStatus_c;
                                        acc.Bill_To_Flag__c = (respvar.BilltoUsage_c!=null && respvar.BilltoUsage_c!='')?(respvar.BilltoUsage_c.equalsIgnoreCase('yes')?true:false):false;
                                        acc.Ship_To_Flag__c = (respvar.ShiptoUsage_c!=null && respvar.ShiptoUsage_c!='')?(respvar.ShiptoUsage_c.equalsIgnoreCase('yes')?true:false):false;
                                        acc.End_User_Flag__c = (respvar.EndUser_c!=null && respvar.EndUser_c!='')?(respvar.EndUser_c.equalsIgnoreCase('yes')?true:false):false;
                                        acc.Installed_At_Flag__c = (respvar.Installedat_c!=null && respvar.Installedat_c!='')?(respvar.Installedat_c.equalsIgnoreCase('yes')?true:false):false;
                                        acc.Sell_ToFlag__c = (respvar.SelltoFlag!=null && respvar.SelltoFlag!='')?(respvar.SelltoFlag.equalsIgnoreCase('yes')?true:false):false;
                                        acc.Phone = respvar.PrimaryPhoneNumber;
                                        acc.Bill_To_Flag__c = True;
                                        acc.Ship_To_Flag__c = True;
                                        //acc.Email_Domain__C = respvar.EmailAddress;
                                        //acc.Email__c = respvar.email.emailaddress;
                                        acc.Email__c = respvar.PrimaryEMail_c;
                                        acc.AddressValidated__c = (respvar.ValidatedFlag!=null && respvar.ValidatedFlag!='')?(respvar.ValidatedFlag.equalsIgnoreCase('yes')?true:false):false;        
                                    }
                                }
                                //DML statement to insert an account from customer data hub
                                if(acc!=null)
                                    database.insert(acc); 
                                
                                lc.setaccountId(acc.id);
                                
                                LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1]; 
                                lc.setConvertedStatus(convertStatus.MasterLabel);
                                
                                if(struserid!=null && struserid!='')
                                    lc.setOwnerId(struserid);
                                
                                lcr = Database.convertLead(lc);
                                System.assert(lcr.isSuccess());
                                
                                //DML statement to update an account from customer data hub
                                if(struserid!=null && struserid!='')
                                    if(acc.ownerid!=id.valueof(struserid)){
                                        acc.ownerid = id.valueof(struserid);
                                        if(customerDataHubRecord == true)
                                            acc.Record_Lock__c = TRUE;
                                        /*if(acc.type == null || acc.type=='')
acc.type = 'Customer';
if(acc.sub_type__c == null || acc.sub_type__c=='')
acc.sub_type__c = 'Division Key Account';*/
                                        system.debug('acc>>>>>>'+acc);
                                        database.update(acc);
                                    }
                                
                                straccid = lcr.getaccountid();
                                convertedAccId = String.valueOf(straccid);  //used to updated account description with Lead description for MEP Division
                            }
                            if(duplicateContact == false){
                                p = new pagereference('/'+straccid);
                                p.setredirect(true);
                            }
                        }
                        if(SetCreatenewAccount == true && (AttchtoExisting == false || AttchtoExisting == null)){
                            //for task creation
                            if(Taskobj !=null){   
                                if(TaskObjMap.get(leadobj.id)!=null)
                                    Taskobj = TaskObjMap.get(leadobj.id);
                                
                                Taskobj.Description = StrComments;
                                Taskobj.IsReminderSet = true;
                                Taskobj.WhoId = leadobj.id;
                                Taskobj.WhatId = straccid;
                                Taskobj.OwnerId = struserid;
                                if(Setreminder == true){
                                    date datevar = Eventobj.Activitydate;
                                    if(selectedtime!=null && selectedtime!=''){
                                        string[] timesplitArr = selectedtime.split(':');
                                        hourvar = integer.valueof(timesplitArr[0]);
                                        
                                        string[] timesplitArr1 = timesplitArr[1].split(' ');
                                        minutevar = integer.valueof(timesplitArr1[0]);                       
                                    }    
                                    
                                    if(Eventobj.Activitydate!=null)
                                        Taskobj.ReminderDateTime = Datetime.newinstance(Eventobj.Activitydate,Time.newInstance(hourvar ,minutevar ,secondsvar ,millisecondsvar ));
                                }    
                            }
                            //DML operation to upsert the task record
                            if(Taskobj!=null && taskobj.subject!=null && taskobj.subject!='')
                                upsert Taskobj;
                            
                            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1]; 
                            lc.setConvertedStatus(convertStatus.MasterLabel);
                            
                            if(struserid!=null && struserid!='')
                                lc.setOwnerId(struserid);
                            
                            lcr = Database.convertLead(lc);
                            System.assert(lcr.isSuccess());
                            
                            straccid = lcr.getaccountid();  
                            convertedAccId = String.valueOf(straccid);  //used to updated account description with Lead description for MEP Division
                            //Retrieve the account record to update few fields after conversion
                            account accvar = [select id,Lifecycle_Stage__c,Name,Country_Code__c,ownerid,type,sub_type__c,BillingCity,BillingCountry,BillingPostalCode,BillingState,BillingStreet,Record_Lock__c from Account where id=:straccid];
                            
                            if(accvar.type == null || accvar.type=='')
                                accvar.type = 'Customer';
                            accvar.Lifecycle_Stage__c = 'Prospect';
                            accvar.Country_Code__c = strCountryCode;
                            accvar.Phone = strleadphone;
                            accvar.Record_Lock__c = TRUE;
                            accvar.Account_Status__c = 'Pending';
                            accvar.RecordTypeId = recordTypeId;
                            //address fields
                            /*accvar.BillingCity = strcity;
accvar.BillingCountry = strcountry;
accvar.BillingPostalCode = strpostalcode;
accvar.BillingState = strstate;
*/
                            accvar.BillingStreet = straddress;               
                            
                            
                            list<string> addlist = straddress.split('[\n\r]');
                            //system.debug('addlist====='+addlist);
                            //system.debug('addlist====='+addlist.size());
                            
                            for (Integer i = 0; i < addlist.size(); i++) {
                                if (addlist.get(i).equals('')) {
                                    addlist.remove(i);
                                    i--; //Decrement counter since we removed an empty item from the list
                                }
                            }
                            
                            accvar.Address1__c = (addlist!=null && addlist.size()>0)?addlist[0]:'';
                            accvar.Address2__c = (addlist!=null && addlist.size()>0)?(addlist.size()>=2?addlist[1]:''):'';
                            accvar.Address3__c = (addlist!=null && addlist.size()>0)?(addlist.size()>=3?addlist[2]:''):'';
                            accvar.Address4__c = (addlist!=null && addlist.size()>0)?(addlist.size()>=4?addlist[3]:''):'';
                            
                            if(struserid!=null && struserid!='')
                                if(accvar.ownerid!=id.valueof(struserid)){
                                    accvar.ownerid = id.valueof(struserid);                
                                }
                            system.debug('accvar>>>>'+accvar);
                            database.update(accvar); 
                            Map<String, Id> recordTypeMap = RecursiveTriggerUtility.loadRecordTypeMap(Account.SObjectType);
                            String pendingRecId = recordTypeMap.get(Label.Account_Pending_Record_Type);
                            
                            if(accvar.RecordTypeId == pendingRecId){
                                List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest> ();
                                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                                req.setComments(Label.Submitted_Approval_Message);
                                req.setObjectId(accvar.ID);
                                requests.add(req);      
                                if(requests.size() > 0)
                                    Approval.ProcessResult[] result = Approval.process(requests);
                            }
                            
                            p = new pagereference('/'+straccid);
                            //p = new pagereference('/001/e?retURL=%2F001%2Fo&RecordType='+recordTypeId+'&ent=Account&nooverride=1');
                            p.setredirect(true);
                            system.debug('pagereference======'+p);
                        }
                        if((AttchtoExisting == false && Setcontinueuserselection == false && SetCreatenewAccount == false && convert!= true) || (AttchtoExisting == false && Setcontinueuserselection == null && SetCreatenewAccount == null && convert!= true)){
                            DisplaySearchMDMDataPage=true;
                            DisplayCreateLeadPage = false; 
                            p = null;               
                        }
                        /*
* Added by sagar
* The requirement is to associate competitor assets to selected 
* account records, when a lead is being converted.
* ITEM-00385
*/
                        
                        if(convertAssets && lcr != null && lcr.isSuccess()){
                            
                            List<Competitor_Assets_Junction__c> compList = new List<Competitor_Assets_Junction__c>();
                            System.debug('***compAssetsAccountList: '+compAssetsAccountList.size());
                            if(compAssetsAccountList.size() <= 0){
                                for(clsLeadWrapper wrapper : compAssetsLeadList){ 
                                    if(cajMap.containsKey(wrapper.asset.Id)){
                                        Competitor_Assets_Junction__c junc = cajMap.get(wrapper.asset.Id);  
                                        junc.Account__c = lcr.getAccountId();
                                        if(lcr.getOpportunityId() != null){
                                            junc.Opportunity__c = lcr.getOpportunityId();      
                                        }
                                        compList.add(junc);
                                    }
                                }      
                            }else{
                                for(clsLeadWrapper wrapper : compAssetsLeadList){
                                    if(wrapper.isSelected && cajMap.containsKey(wrapper.asset.Id)){
                                        Competitor_Assets_Junction__c junc = cajMap.get(wrapper.asset.Id);
                                        if(lcr.getOpportunityId() != null){
                                            junc.Opportunity__c = lcr.getOpportunityId();      
                                        }
                                        junc.Account__c = lcr.getAccountId();
                                        
                                        compList.add(junc);
                                        
                                    }
                                }   
                            } 
                            if(compList.size() > 0)    
                                update compList;     
                        } 
                        /*
* Added by Sagar Mehta on 8 May, 2014
* Associate ship to account on newly created opportunity
*/                     
                        if(lcr != null && lcr.isSuccess() && lcr.getopportunityid() != null){
                            if(lcr.getaccountid() != null){
                                String optyId = lcr.getopportunityid();
                                String acccId = lcr.getaccountid();
                                Opportunity oppty = new Opportunity();
                                Account account = [Select Id, Restricted_Entity__c from Account where Id =: acccId];
                                if(account.Restricted_Entity__c != 'Restricted'){
                                    oppty = [Select Id, Ship_To_Account__c from Opportunity where Id =: optyId];
                                    oppty.Ship_To_Account__c = acccId;
                                    update oppty;                              
                                }   
                            }   
                        }               
                    }                              
                }             
            }catch(exception ex){
                System.debug('ERRRRRORRRR'+ex.getMessage()+'Pardeep=Line number='+ex.getLineNumber());
                //new code
                /*Integer numErrors = ex.getNumDml();
System.debug('getNumDml=' + numErrors);
for(Integer i=0;i<numErrors;i++) {
System.debug('pardeep getDmlFieldNames=' + ex.getDmlFieldNames(i));
System.debug('pardeep getDmlMessage=' + ex.getDmlMessage(i));  
}*/
                //end of new code
                if(ex.getMessage().contains('You do not have the required permission')||ex.getMessage().contains('Record Locked'))
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You cannot attach a lead to a locked account.  Please contact your Order Admin for assistance.')); 
                else    
                    ApexPages.addMessages(ex);
                system.debug('exception===='+ex);
                system.debug('exception===='+ex.getStackTraceString());
                p = null;
            }
        }    
        system.debug('------------P-----------'+p);
        system.debug('------------DisplaySearchMDMDataPage-----------'+p);
        system.debug('-----------duplicateContact------------'+duplicateContact);
        system.debug('-----------------------'+p);
        return p;
    }
    
    /*
* Method Name  : updateConvertedAccount
* Description  : Method to update Account Description from Lead while converting
* Return Type  : NA
* Parameter    : NA
* Method Author: Chandrakanth Malayathi
* Updated By   : Ankur Kumar Patel
* Update Reason: To Bypass standard Duplicates rules for lead conversion
*/
    public void updateConvertedAccount(){
        Lead ld = [select Id, ConvertedAccountId, ConvertedContactId, Description, Description__c, OwnerId from Lead where Id =: leadid limit 1];
        system.debug('---AccId---'+convertedAccId+'--Lead-----'+ld);
        if(String.isNotBlank(ld.ConvertedAccountId)){
            Account acc = [select Id, Description from Account where Id =: ld.ConvertedAccountId limit 1];
            if((String.isNotBlank(ld.Description) || String.isNotBlank(ld.Description__c)) && acc.Description != '' && u.Division__c == 'MEP'){
                acc.Description = (ld.Description__c != ''?ld.Description__c:ld.Description);
            }
            acc.Bypass_Duplicate_Rules__c = false;
            /*Database.DMLOptions dml = new Database.DMLOptions();
dml.DuplicateRuleHeader.AllowSave = true;
*/
            //acc.setOptions(dml);
            AccountHelper.setLaunchControl();
            RecursiveTriggerUtility.isAccountRecursive = false;
            Database.update(acc);
        } 
        
        system.debug('--convertedContactId--'+ld.ConvertedContactId);
        if(String.isNotBlank(ld.ConvertedContactId)){
            Contact con = new Contact();
            con.Id = ld.ConvertedContactId;
            con.Bypass_Duplicate_Rules__c = false;
            /*Database.DMLOptions dmlc = new Database.DMLOptions();
dmlc.DuplicateRuleHeader.AllowSave = true;
*/
            //con.setOptions(dmlc);
            ContactHandler.setLaunchControl();
            AccountCreationCalloutEX.recursiveCallFlag = true;
            Database.update(con);
        }
    }
    
    
    /*
* Method name  : cancelAction
* Description  : Method to cancel the action on click of cancel button
* Return Type  : pageReference
* Parameter    : NA
*/  
    public pagereference cancelAction()
    {
        /*DisplaySearchMDMDataPage=false;
DisplayCreateLeadPage = true;
displayMDMResults = false;*/
        //pagereference p = new pagereference('/apex/CustomLeadConversionPage?id='+leadobj.id);
        pagereference p = new pagereference('/'+leadobj.id);
        p.setredirect(true);
        return p; 
    }
    
    
    public class wrappersearchresults{
        
        public string orgname{get;set;}
        public string siteName{get;set;}
        public string billlingstreet{get;set;}
        public string billlingcity{get;set;}
        public string billlingstate{get;set;}
        public string billlingcountry{get;set;}
        public string phoneno{get;set;}
        public string enterprisemasterid{get;set;}
        public string enterprisepartynumber{get;set;}
        public string billingpostalcode{get;set;}
        
        public wrappersearchresults(String orgname,String siteName,String billlingstreet,String billlingcity,String billlingstate,String billlingcountry,String billingpostalcode,string phoneno,string enterprisemasterid,string enterprisepartynumber){
            
            this.orgname=orgName;
            this.siteName = SiteName;
            
            this.billlingstreet=billlingstreet;
            
            this.billlingcity=billlingcity;
            
            this.billlingstate=billlingstate;
            
            this.billlingcountry=billlingcountry;
            this.billingpostalcode=billingpostalcode;
            this.phoneno=phoneno;
            this.enterprisemasterid = enterprisemasterid;
            this.enterprisepartynumber = enterprisepartynumber;
        }       
    } 
    public string changedvalue{get;set;}
    public void reorderpickValues(){
        system.debug('changedvalue===='+changedvalue);
        prepareaccounts();
        //return null;
    }
    
    public string changedConvalue{get;set;}
    public void reorderConPickValues(){
        prepareContacts();
    }
    
    
    public class clsLeadWrapper{
        public boolean isSelected{get;set;}
        public Competitor_Owned_Assets__c asset{get;set;}
    }
    
    public void cancelpopup(){
        showCompAssetsPopUp =false;
    }
    
}