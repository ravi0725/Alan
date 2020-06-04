@isTest(Seealldata=true)
public class testCase24HoursNotificationtrigger{

/*
static  testmethod void testcase24(){

 Profile p = [select id from profile where name='RE&WS - Customer Portal'];
 
 Account aa =[Select id,name from account LIMIT 1];
 // new Account (name='asd' );
 //       insert aa;

  
 Contact co =  [select id,name from contact where accountid=:aa.id LIMIT 1];
 //new Contact(firstname='asd', lastname = 'deneme',email ='dasd@asd.com' ,accountid=aa.id);
   //     insert co;
        
   User u = new User(alias = 'u1', email='u1@testorg.com',
           emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
           localesidkey='en_US', profileid = p.Id, country='United States',
          timezonesidkey='America/Los_Angeles', username='u1a@testorg.com',contactId = co.Id);

   insert  u;
   
   
   System.runAs(u){
   
   Case c = new Case(Status = Label.Case_Status_Open,status_reason__c = Label.Case_Status_Reason_New_Unassigned);
   insert c;
   
   }

}
*/

// Added by Jiten

public static testMethod void testRunAs(){

Account acc = new Account();
        acc.Name = 'Dummy Account';
        acc.BillingCountry = 'India';
        acc.BillingCity ='Chennai';
        acc.BillingStreet ='Tidel Park';
        acc.Bill_To_Flag__c  = TRUE;
Database.Insert(acc);

Contact con = new Contact();
        con.LastName = 'Dummy';
        con.FirstName = 'User';
        con.AccountId = acc.Id;
        con.MailingCountry = 'India';
Database.Insert(con);
              
Profile p = [SELECT Id FROM Profile WHERE Name='RE&WS - Customer Portal']; 
      User u = new User();
           u.Alias = 'standt';
           u.Email='testUser@trimble.com';
           u.EmailEncodingKey='UTF-8';
           u.LastName='Dummy';
           u.LanguageLocaleKey='en_US';
           u.LocaleSidKey='en_US';
           u.ProfileId = p.Id;
           u.TimeZoneSidKey='America/Los_Angeles';
           u.UserName='testUser@trimble.com.uat';
           u.contactId = con.id;
           u.Division__c = 'RE&WS';
           

      System.runAs(u) {
         System.debug('Current User: ' + UserInfo.getUserName());
         System.debug('Current Profile: ' + UserInfo.getProfileId()); 
       Case c = new Case(Status = Label.Case_Status_Open,status_reason__c = Label.Case_Status_Reason_New_Unassigned);
       Database.insert(c);         
      }


}


}