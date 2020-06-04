trigger EmailAlert on Event(after insert, after update){
  Public Boolean ExeTrigger = False; 
  List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();  
  List<Case> caselist=new List<Case>();
  List<Event> InsertEventList = new List<Event>();
  List<Event> DeleteEventList = new List<Event>();
  List<RecordType> recordTypeList = new List<RecordType>();  
  recordTypeList = [Select Id from RecordType where DeveloperName =: Label.OnsiteTechSupport];
  
  List<Id> caseIdList = new List<Id>();
  for(Event ev : Trigger.new){
     caseIdList.add(ev.WhatId); 
  }
  
  Map<Id, Case> caseMap = new Map<Id, Case>();
  caseMap = new Map<Id, Case>([Select Id, Owner.Email, CaseNumber, OwnerId from Case where Id IN: caseIdList]);
  
  if(Trigger.new.size() == 1 && recordTypeList.size() > 0 && caseMap.size() > 0){
   List<EmailTemplate> templateList = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName =: Label.Completed_Onsite_Tech_Support_Activity]; 
   if(templateList.size() > 0){ 
   for (Event ev : Trigger.new){    
     if(ev.Status__c == Label.Completed && ev.RecordTypeId == recordTypeList.get(0).Id) {                                    
        if(caseMap.containsKey(ev.WhatId)){  
           Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();           
           String[] toAddresses = new String[] {caseMap.get(ev.WhatId).Owner.Email};  
           mail.setToAddresses(toAddresses);
           mail.setSenderDisplayName(Label.Salesforce_Support); 
           String subject = templateList.get(0).Subject;
           subject = subject.replace('{!Case.CaseNumber}', caseMap.get(ev.WhatId).CaseNumber);
           String htmlBody = templateList.get(0).Body;
           htmlBody = htmlBody.replace('{!Case.CaseNumber}', caseMap.get(ev.WhatId).CaseNumber);
           htmlBody = htmlBody.replace('{!Case.Link}', 'https://'+System.URL.getSalesforceBaseURL().getHost()+'/'+caseMap.get(ev.WhatId).Id);
           mail.setBccSender(false);
           mail.setSubject(subject);
           mail.setPlainTextBody(htmlBody);
           emailList.add(mail);                               
       }
     }  
   }
   }
  } 
  if(emailList.size() > 0){
     Messaging.sendEmail(emailList);
  } 
  
  if(Trigger.IsInsert && ExeTrigger == False)
  {
  String UserName;
  List<User> UserList = new list<User>();
  for(Event Ev : Trigger.New)
  {
  if(Ev.Training_Room__c != null)
  {
  UserName = Ev.Training_Room__c;
  }
  }
  UserList = [select id from User where Name =: UserName];
  If(UserList.size()==1)
          {
          for(Event Ev : Trigger.New)
          {
              Event even = new Event();
              even.OwnerId= UserList[0].Id;
              even.StartDateTime = Ev.StartDateTime;
              even.Subject = Ev.Subject;
              even.Type = Ev.Type;
              even.EndDateTime = Ev.EndDateTime;
              even.Training_Room_Record__c = True;
              even.Ref_Event__c = Ev.Id;
              InsertEventList.add(even);
              ExeTrigger = True;
          }
          }
   if(InsertEventList.size()>0)
   Insert InsertEventList;
   
  } 
  
  if(Trigger.Isupdate && ExeTrigger == False)
  {
   String UserName;
  List<User> UserList = new list<User>();
  List<Event>DelEv = new List<Event>();
  for(Event Ev : Trigger.New)
  {
    if(trigger.oldmap.get(Ev.Id).StartDateTime != trigger.newmap.get(Ev.Id).StartDateTime || trigger.oldmap.get(Ev.Id).EndDateTime != trigger.newmap.get(Ev.Id).EndDateTime || trigger.oldmap.get(Ev.Id).Training_Room__c != trigger.newmap.get(Ev.Id).Training_Room__c)
    {
   DelEv = [select id from event where Ref_Event__c =: Ev.id and Training_Room_Record__c = True];
   if(DelEv.size()>0)
   delete DelEv;
   
   if(Ev.Training_Room__c != null)
  {
  UserName = Ev.Training_Room__c;
  }
  UserList = [select id from User where Name =: UserName];
  If(UserList.size()==1)
          {
         
              Event even = new Event();
              even.OwnerId= UserList[0].Id;
              even.StartDateTime = Ev.StartDateTime;
              even.Subject = Ev.Subject;
              even.Type = Ev.Type;
              even.EndDateTime = Ev.EndDateTime;
              even.Training_Room_Record__c = True;
              even.Ref_Event__c = Ev.Id;
              InsertEventList.add(even);
              ExeTrigger = True;
      }
  
    }
  }
  if(InsertEventList.size()>0)
  Insert InsertEventList;
  }
}