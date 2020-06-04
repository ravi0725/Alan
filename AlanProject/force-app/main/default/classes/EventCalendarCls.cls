/*
 @Author : RS
 @Description : Display Instructors and Sessions on Calendar.
 @Lightning Component : EventCalendar.cmp
 @Test Class : CertificateAttachmentTest 
 */
public class EventCalendarCls {
	@AuraEnabled
    public static List<TTraining_Instructors__c> getEvents(){
        /*List<TTraining_Instructors__c> instructors =[select id,name ,
                                                     (SELECT Name,Sessions__r.Start__c,Sessions__r.End__c,Sessions__r.status__c
                                                      FROM Instructor_In_Sessions__r 
                                                      where CALENDAR_YEAR(Sessions__r.Start__c)= 2020) 
                                                      from TTraining_Instructors__c]; */
      	List<TTraining_Instructors__c> instructors =[select id,name ,
                                                     (SELECT Id,Name,Start__c,End__c,status__c 
                                                      FROM Instructor_In_Sessions__r 
                                                      where CALENDAR_YEAR(Sessions__r.Start__c)= 2020),
                                                     (Select Id,Name,Type__c,Booked__c,Course__r.Name 
                                                      from Training_Events__r) 
                                                     from TTraining_Instructors__c];
        
       /* List<TTraining_Instructors__c> instructors = [select id,name,
                                                     (SELECT Id,Name,Classroom_End__c,Classroom_Start__c,Type__c,Booked__c,Course__r.Name 
                                                      FROM Training_Events__r where CALENDAR_YEAR(Classroom_Start__c)= 2020) 
                                                      from TTraining_Instructors__c];*/
        return instructors; 
    }
    
    @AuraEnabled
    public static List<TTraining_Events__c> getEventData(Id eventId){
       List<TTraining_Events__c> tainingEvent = [SELECT Id,Name,Classroom_End__c,Classroom_Start__c,
                                                Type__c,Booked__c,Course__r.Name 
                                                FROM TTraining_Events__c
                                                where Id =: eventId];
        return tainingEvent; 
    }
}