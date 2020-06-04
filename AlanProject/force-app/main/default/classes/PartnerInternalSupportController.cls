public class PartnerInternalSupportController{

   public String contactId;
   public String accountId;
   public String recordTypeId;
   public String supportType;
   
   public PartnerInternalSupportController(){
       supportType = ApexPages.currentPage().getParameters().get('ctype');
   }
   
   public PageReference redirectToComponent(){
       try{
            if(supportType == '1'){
             List<Account> accountList = new List<Account>();
             accountList = [Select Id from Account where Name =: Label.Trimble];
             if(accountList.size() <= 0){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, Label.Support_Case_Error_Message);
                ApexPages.addMessage(msg);
                return Page.errorMessage; 
             }
             Account account = accountList.get(0);
             accountId = account.Id;
             List<RecordType> recordTypeList = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Case' AND IsActive = TRUE and DeveloperName =: Label.Case_Internal_Record_Type];              
             recordTypeId = recordTypeList.get(0).Id;
             return new PageReference('/500/e?retURL=%2F500%2Fo&RecordType='+recordTypeId+'&cas4_lkid='+accountId);          
           }else{
             List<User> userList = [Select Id, ContactId from User where Id =: UserInfo.getUserId()];
             User user = userList.get(0);
             List<Contact> contactList = [Select Id, AccountId from Contact where Id =: user.ContactId];
             if(contactList.size() <= 0){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, Label.Support_Case_Error_Message);
                ApexPages.addMessage(msg);
                return Page.errorMessage; 
             }
             Contact contact = contactList.get(0);
             contactId = user.ContactId;
             accountId = contact.AccountId;                        
             List<RecordType> recordTypeList = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Case' AND IsActive = TRUE and DeveloperName =: Label.Case_Internal_Record_Type];
             //List<RecordType> recordTypeList = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Case' AND IsActive = TRUE and DeveloperName = 'Case_Partner_Record_Type'];
             if(recordTypeList.size() <= 0){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, Label.Support_Case_Error_Message);
                ApexPages.addMessage(msg);
                return Page.errorMessage; 
             }
             recordTypeId = recordTypeList.get(0).Id;
             return new PageReference('/500/e?retURL=%2F500%2Fo&RecordType='+recordTypeId+'&cas4_lkid='+accountId+'&cas3_lkid='+contactId);
           }
       }catch(Exception e){
           ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, Label.Support_Case_Error_Message);
           ApexPages.addMessage(msg);
           return Page.errorMessage; 
       }
       return null;
   }
}