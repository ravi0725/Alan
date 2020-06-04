public class SelfRegistrationController 
{
    public boolean submitMsg{get;set;}
    public string firstname{get;set;}
    public string lastname{get;set;}
    public string companyname{get;set;}
    public string email{get;set;}
    public string MobilePhone{get;set;}
    public string MailingStreet{get;set;}
    public string MailingPostalCode{get;set;}
    public string MailingCity{get;set;}
    public string MailingState{get;set;}
    public string MailingCountry{get;set;}
    public string SerialNumber{get;set;}
    public string localeVal{get;set;}
    public string timeZone{get;set;}
    public string password{get;set;}
    public string selectedProduct{get;set;}
    public boolean showSuccessSection{get;set;}
    public boolean showCaseSuccessSection{get;set;}
    public List<SelectOption> locales{get;set;}
    public List<SelectOption> countryvalues{get;set;}
    public List<SelectOption> timezones{get;set;}
    // Constructor 
    public SelfRegistrationController(){
        selectedProduct = System.currentPageReference().getParameters().get('Product');
        string s= ''; 
        MailingCountry = 'United States';
        timeZone = 'America/Denver';
        localeVal = 'en_US';
        CountryValues();
        timezones();
        locales();
    }
    
    // method to get the values for the picklist Timezone
    public void timezones(){
        Map<string,string> timeZoneMap = new map<string,string>();
        timezones = new List<SelectOption>();
        timezones.add(new SelectOption('','--None--'));
        for(Schema.PicklistEntry p : Schema.SObjectType.User.fields.TimeZoneSidKey.PicklistValues){
            timeZoneMap.put(p.getlabel(),p.getValue());
        }
        timezones.addAll(sortList(timeZoneMap));
    } 
    
    public List<selectOption> sortList(Map<string,string> tempMap){
        List<selectOption> tempOptions = new List<SelectOption>();
        List<string> tempList = new List<string>();
        tempList.addAll(tempMap.keyset());
        tempList.sort();
        for(String key : tempList){
            tempOptions.add(new SelectOption(tempMap.get(key) , key));
        }
        
        return tempOptions;
    }
    
    
    // method that refreshes the page when clicking back button
    public PageReference login(){
        submitMsg=true;
        PageReference pageref = new PageReference('/clientsupport/customloginpage');
        pageref.setRedirect(true);
        return pageref;
    }
    
    
    // method to get the values for the picklist Locale
    public void locales(){
        Map<string,string> localeMap = new map<string,string>();
        locales = new List<SelectOption>();
        locales.add(new SelectOption('','--None--'));
        for( Schema.PicklistEntry p : Schema.SObjectType.User.fields.LocaleSidKey.PicklistValues){
            localeMap.put(p.getlabel(),p.getValue());
        }       
        locales.addAll(sortList(localeMap));
    }
    
    
    // method to get the values for the picklist Country
    public void CountryValues(){
        Map<string,string> countryMap = new map<string,string>();
        countryvalues = new List<SelectOption>();
        countryvalues.add(new SelectOption('','--None--'));
        for(string p : Country_Region_Mapping__c.getAll().keyset()){
            countryMap.put(p,p);
        }   
        countryvalues.addAll(sortList(countryMap));
    }
    
    // method to send the email with the details collected in the form  
    public void submitForm(){
        try{
            Datetime dt = datetime.now();
            boolean foundContact = false;
            boolean foundEntitltment = false;
            boolean foundAccount = false;
            List<Contact> conList = new List<Contact>();
            Profile pf = [SELECT Id FROM profile WHERE name='GCCM - Customer Portal' limit 1];
            conList = [select Id, Email, AccountId,Account.Name, FirstName, LastName from Contact where 
                       (Email =: Email and Account.name like: ('%' + CompanyName + '%')) 
                       or (LastName like : ('%' + LastName + '%') and Account.name like: ('%' + CompanyName + '%') and Email != '' and Email != null) limit 1];
            if(conList.size() == 1){
                Contact con = conList.get(0);
                if([select Id from Entitlement where AccountId =: con.AccountId and Entitlement_Product__r.Product_Line__c like '%PROJECTSIGHT%'].size() > 0){
                    boolean foundUser = false;
                    for(User ur : [select Id, Email, AccountId,isActive from User where ContactId =: con.Id and AccountId =: con.AccountId limit 1]){
                        ur = setUserDetails(ur , '');
                        update ur;
                        System.resetPassword(ur.Id,true);
                        showSuccessSection = true;
                        showCaseSuccessSection = false;
                        submitMsg=true;
                        foundUser = true;
                    }
                    if(!foundUser){
                        User ur = setUserDetails(new User() , con.Account.Name); 
                        ur.profileid = pf.Id;
                        ur.contactId=con.Id;
                        ur.communityNickname = LastName + '_' + dt.hour() + '' + dt.minute() + '' + dt.second();
                        ur.alias = (string.isNotBlank(FirstName) ? FirstName.substring(0,1) : '') + LastName.substring(0,1) + dt.hour() + '' + dt.minute() + '' + dt.second();
                        insert ur;
                        showSuccessSection = true;
                        showCaseSuccessSection = false;
                        submitMsg=true;
                    }
                }else{
                    submitCase();
                }
            }else{
                submitCase();
            }
           
        }Catch(exception e){  
            submitCase();
            submitMsg=true;
            showSuccessSection = false;
            showCaseSuccessSection = true;
        }
    }
    
    public void submitCase(){
        try{
            String description = 'The User with the below details is requesting to register for customer portal\n';
            description +='\n   First Name:\t'   + noNull(FirstName);
            description +='\n   Last Name:\t'   + noNull(LastName);
            description +='\n   Company:\t'+ noNull(CompanyName);
            description +='\n   Email:\t'   +  noNull(Email);
            description +='\n   Mobile Number:\t'   +  noNull(MobilePhone);
            description +='\n   Mailing Street:\t'   +  noNull(MailingStreet);
            description +='\n   Mailing City:\t'   +  noNull(MailingCity);
            description +='\n   Mailing State/Province:\t'   +  noNull(MailingState);
            description +='\n   Mailing Zip/Postal Code:\t'   +  noNull(MailingPostalCode);
            description +='\n   Mailing Country:\t'   +  noNull(MailingCountry);
            description +='\n   Time Zone:\t'   +  noNull(timeZone);
            description +='\n   Locale:\t'   +  noNull(localeVal);
            Case cs = new Case();
            cs.Subject = 'New User : ';
            cs.Description = description;
            cs.Product__c= selectedProduct;
            cs.RecordTypeId = [select ID from RecordType where Name = 'Case (Trimble Internal Support) Record Type' limit 1].Id;
            cs.Origin = 'Portal';
            cs.I_need_assistance_with__c = selectedProduct+' Portal Access';
            cs.Type = 'Portal Access Request';
            cs.Severity_Level__c = 'Level 4: Medium';
            insert cs;
            submitMsg=true;
            showSuccessSection = false;
            showCaseSuccessSection = true;
        }Catch(exception e){  
            submitMsg=false;
            showSuccessSection = false;
            showCaseSuccessSection = false;
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, e.getMessage()));
        }
    }
    
    // convert null to ''
    public static String noNull(String var) {
        if (var == null)
            return '';
        else
            return var;
    }
    
    public User setUserDetails(User u , String accName){
        User ur = u;
        ur.username=Email; 
        ur.firstname=FirstName;
        ur.lastname=LastName; 
        ur.email=Email;
        if(accName != ''){
            for(UserRole r : [select Id from UserRole where Name =: (accName + ' Customer User')])
                ur.UserRoleId = r.Id;
        }
        ur.emailencodingkey='UTF-8';
        ur.languagelocalekey='en_US'; 
        ur.localesidkey=localeVal;
        ur.timezonesidkey=timeZone;
        ur.Country = MailingCountry;
        ur.State = MailingState;
        ur.Street = MailingStreet;
        ur.PostalCode = MailingPostalCode;
        ur.City = MailingCity;
        ur.MobilePhone = MobilePhone;
        ur.IsActive = true;
        ur.Division__c = 'GCCM';
        return ur;
    }
}