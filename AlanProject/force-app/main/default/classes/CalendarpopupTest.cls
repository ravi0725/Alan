@isTest
private class CalendarpopupTest{
    Public static Account acct;
    public static Country_Region_Mapping__c cust;
    public static Geospatial_Country_Region_Mapping__c custRegMap ;
    private static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    static testmethod void testcalendarpopup(){
    ID oid = UserInfo.getUserId();
    DateTime StatT = system.Now();
    DateTime EndT = system.now().addminutes(30);
    
    cust = new Country_Region_Mapping__c(name='India',Region__c='India');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='India',Region__c='India');
        insert custRegMap;
        
    Account account = new Account();
        account.Name = 'Sagar Mehta Test2';
        account.Requested_Account_Record_Type__c = 'Customer';
        account.CurrencyIsoCode = 'USD';
        account.BillingCountry = 'India';
        account.BillingCity = 'Pune';
        account.BillingStreet = 'A-202';
        account.FCH_Party_ID__c='100';
        account.Phone='111-111-1111';
        account.BillingState='Goa';
        account.BillingPostalCode ='343220';
        insert account;
Event Ev = new Event(Subject='Sample Event', Type='Other',OwnerID=oid,StartDateTime=StatT,EndDateTime=EndT);
insert Ev;

         
Customer_Event__c oCustEvent = new Customer_Event__c(Account__c=account.id,Event_Id__c=Ev.id);
insert oCustEvent;

ApexPages.currentPage().getParameters().put('Id',Ev.id);
ApexPages.StandardController controller = new ApexPages.StandardController(Ev);
CalendarPopupExt bsExt = new CalendarPopupExt(controller);
//bsExt.Loaddata();

        
 }
 }