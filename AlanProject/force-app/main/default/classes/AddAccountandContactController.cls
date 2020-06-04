/*
 * Company     : Trimble Software Technology Pvt Ltd.,
 * Description : Controller for Page AddAccountContactController to Add Multiple Contact to Single Account
 * History     : 
 * [10.MAR.2014] Prince Leo - Code Created.
 */
 
public class AddAccountandContactController {
    Public List<Account>SearchResult{get;set;}
    Public List<Contact>ContactList{get;Set;}
    public string SearchText{ get; set; }
    Public Account SelectedAccount{get;set;}
    Public Boolean DisplayAccount{get;set;}
    Public Boolean DisplayContact{get;set;}
    Public ID eventID{get; set;}    
    Public ID SelectedAccountId {get;set;}
    Public Boolean showInFo {get;set;}
    Public List<ContactWrapper> ContList;
    Set<ID>CeAccId = new Set<ID>();
    List<Customer_Event__c> CustomerEv = new List<Customer_Event__c>();
    
    public AddAccountandContactController(ApexPages.StandardController controller) {
        eventId = System.currentPageReference().getParameters().get('id');
    }
    
    public List<ContactWrapper> getContList() {
        return ContList;
    }

    public void setContList(List<ContactWrapper> s) {
        ContList= s;
    }
    
    public pageReference Search(){
        CustomerEv =[select id,Account__c, Contact_Names__c from Customer_Event__c where Event_Id__c =:eventId];
        for(Customer_Event__c ce : CustomerEv)
        {
            if(string.isNotBlank(ce.Contact_Names__c)){
                CeAccId.add(ce.Account__c);
            }
        }
        DisplayContact = False;
        string inVar=(this.SearchText != null?this.SearchText:'');
        inVar = invar.replace('*','');
        string tempInput = '%' + inVar + '%';
        SearchResult = [select id, Name,BillingStreet,BillingState,BillingCountry,BillingCity from account where Name like : tempInput and id !=:CeAccId Limit 50];
        DisplayAccount = true;
        return null;
    }
    
    public PageReference SearchContact(){
        DisplayAccount = false;
        DisplayContact = True;

        SelectedAccountId = System.currentPageReference().getParameters().get('selectedCategoryId');
        system.debug('&&&&&&&&&'+SelectedAccountId);
        ContactList =[select id, Name,Country_Code__c,Phone,Email,Accountid from contact where Accountid=:SelectedAccountId];
        
        if(this.ContList == null)
            this.ContList = new List<ContactWrapper>();
        else
        {
            this.contList.clear();
        }

        for(contact con : ContactList)
        {
            ContactWrapper cw = new ContactWrapper();
            cw.checked=false;
            cw.cat = con;
            system.debug('^^^^^^^^^^'+ContList);
            system.debug('^^^^^^^^^^'+cw);
            ContList.add(cw);  
        }

        if(contList.size()==0)
        {
            showInFo = True;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,Label.Info_Message));
            return null;
        }
        return null;
    }
    
    Public PageReference SelectedContact(){

        List<ContactWrapper> selcw = this.ContList;
        system.debug('^^^^^^'+selcw);
        Set<ID>ContId = new Set<Id>();
        for(ContactWrapper cw :selcw)
        {
            if(cw.checked!=False)
            {
                ContId.add(cw.cat.id);
                SelectedAccountId = cw.cat.Accountid;
            }
        }

        List<Customer_Event__c> ceInsertList = new List<Customer_Event__c>();
        for(Id contactId: contId){ //---by chandrakanth-----
            Customer_Event__c cEvent = new Customer_Event__c();
            cEvent.Account__c=SelectedAccountId;
            cEvent.Event_Id__c=eventId;
            cEvent.Event_Contact__c = contactId;
            ceInsertList.add(cEvent);
        }

        if(ceInsertList.size() > 0)insert ceInsertList;

        PageReference FinalPage;
        FinalPage= new PageReference('/'+eventId);
        return FinalPage;
    }

    public class ContactWrapper {
        public Boolean checked { get; set; }
        public Contact cat { get; set; }

        public ContactWrapper(){
            cat = new Contact();
            checked = false;
        }

        public ContactWrapper(Contact c){
            cat = c;
            checked = false;
        }

        public ContactWrapper(Contact c, Boolean checked){
            cat = c;
            this.checked = checked ;
        }
    }

}