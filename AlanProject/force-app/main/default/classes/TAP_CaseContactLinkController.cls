public class TAP_CaseContactLinkController {
    public Id CaseId {get; set;}
    //public string CaseNumber {get; set;}
    public List<Contact> ContList {get; set;}
    pUblic string WebEmail {get; set;} 
    public List<Case> Cslist {get; set;}
    public boolean NoContacts {get; set;}
    public boolean NoWebEmail {get; set;}
    //public boolean NonTapUsersVFnoshowFlag {get; set;}
    //public Id ContactId { get; set; }
    //public Id AccountId { get; set; }
    public boolean ContactAlreadyExists {get; set;}
    
    
    
    public TAP_CaseContactLinkController(ApexPages.StandardController controller) {
    //NonTapUsersVFnoshowFlag = ([select ID, Division__c from User where Id = :UserInfo.getUserId()].Division__c == 'TAP');
    CaseId = controller.getid();
    NoContacts  = FALSE;
    NoWebEmail = FALSE;
    system.debug('NoContacts1-------------->'+NoContacts);    
    Cslist = [SELECT Id, CaseNumber, SuppliedEmail  FROM Case WHERE id =:CaseId  limit 1];  
    ContactAlreadyExists = ([SELECT Id, CaseNumber, ContactId, SuppliedEmail  FROM Case WHERE id =:CaseId  limit 1].ContactId != NULL);
    system.debug('ContactAlreadyExists -------------->'+ContactAlreadyExists );    
        If(cslist.size() == 1){
            for (Case cs: Cslist ){
                If(cs.SuppliedEmail != NULL){
                       ContList = [SELECT Name, email, Account.EAN_OAN__c, Account.name FROM Contact WHERE Email  =  : cs.SuppliedEmail LIMIt 999 ]; 
                       webemail = cs.SuppliedEmail;
                       if (ContList.size() == 0){
                           NoContacts  = TRUE;
                       }
                      }
                    else{
                        NoWebEmail = TRUE;
                        system.debug('NoWebEmail -------------->'+NoWebEmail );    
                    }
                    
            }
        system.debug('NoContacts3-------------->'+NoContacts);    
        system.debug('Case id--->'+CaseId);
        system.debug('Contact List--->'+ContList );
            
        }
    }
}