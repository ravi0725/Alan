/**
 * Company     : Trimble Software Technology Pvt Ltd.,
 * Description : .
 * History     :  

 * [16.OCT.2013] Srinivasan Babu  Created
 */
public class ResourceCalenderDetailViewCtrl{
  Public Static String NewVal;
  Public String RetView ;
  
  Public String result ;
    public list<callEvent> listEvents {get;set;}
    public list<callResource> listResources {get;set;}
    public String sSelectView {get;set;}
    public list<EventTypes> listEventTypeColors {get;set;}
    Map<id,Account> AccMap = new Map<id,Account>();
    Map<id,Contact> ConMap = new Map<id,Contact>();
    //The calendar plugin is expecting dates is a certain format. We can use this string to get it formated correctly
    
    private String timeZone = UserInfo.getTimeZone().getID();
    
    Public Boolean FirstAccess=False ;
    public String dtFormat = 'EEE, d MMM yyyy HH:mm:ss';
    private set<Id> setResourceIds;
    
    //To generate JSON data for event records
    public static JSONGenerator gen;
    public static String JsonData{get;set;}
    
    public Integer currentMonth{get;set;}
    public Integer currentDay{get;set;}
    public Integer currentYear{get;set;}
    public String calendarView{get;set;}
    //Constructor
    public ResourceCalenderDetailViewCtrl() {
        calendarView = 'resourceWeek';
        result = UserInfo.getLocale();
        List<Customer_Locale_Configure__c> AllValues = Customer_Locale_Configure__c.getall().values();
        Map<String,String> mapUserLocale = new Map<String,String>();
        for(Customer_Locale_Configure__c cs : AllValues){
            mapUserLocale.put(cs.Code__c,cs.View_Name__c);
        }
        String view = mapUserLocale.get(result);
        system.debug('&&&&&&'+apexpages.currentpage().getparameters());
        RetView = apexpages.currentpage().getparameters().get('NewVal');
        system.debug('&&&&&&'+view);
        if(RetView==''){
            if(view==null){
                view = 'Plancal_Support_Group_CH';
                this.sSelectView = view;
            }else{
                view = view.replaceall(' ','_');
                this.sSelectView = view;
            }
        }else{
            Retview = Retview.replaceall(' ','_');
            this.sSelectView = Retview;
            
        }
        currentMonth = date.today().toStartofWeek().month();
        currentDay = date.today().toStartofWeek().Day();
        currentYear = date.today().toStartofWeek().Year();
     
    }
  
    // Generates resource view dropdown from ResourceCalenderListView settings
    public List<SelectOption> getSelectViewList() {
        List<SelectOption> options = new List<SelectOption>();
        // Find all the ResourceCalenderListView in the custom setting
        Map<String, ResourceCalenderListView__c> mapListView = ResourceCalenderListView__c.getAll();
        // Sort them by name
        List<String> listViewyNames = new List<String>();
        listViewyNames.addAll(mapListView.keySet());
        listViewyNames.sort();
        // Create the Select Options.
        for (String ViewName : listViewyNames) {
            ResourceCalenderListView__c oResView = mapListView.get(ViewName);
            options.add(new SelectOption(oResView.Value__c, oResView.Name));
        }
        return options;
    }
  
    public PageReference pageLoad(){
        NewVal = this.sSelectView;
        fetchUserswithEvents(sSelectView);
        
        return null;
    }
    
    public PageReference toggleEvents() {
        NewVal = this.sSelectView;
        PageReference ReadPage;
        ReadPage= new PageReference('/apex/ResourceCalenderDetailView?NewVal='+NewVal);
        fetchUserswithEvents(sSelectView);
        ReadPage.setRedirect(true);
        return ReadPage;
    }
    
    public PageReference AddEvent(){
        NewVal = this.sSelectView;
        PageReference nextPage;
        
        nextPage = new PageReference('/setup/ui/recordtypeselect.jsp?ent=Event&retURL=%2F/apex/ResourceCalenderDetailView%3F%26NewVal='+NewVal+'&save_new_url=%2F00U%2Fe%3FretURL=/apex/ResourceCalenderDetailView?NewVal='+NewVal);
        nextPage.setRedirect(True);
        
        return nextPage;
    }
    
    public void retrivePrviousMonthData(){
        pageLoad();
    }
    
    public void retriveNextMonthData(){
        pageLoad();
    }
    
    //Class to hold calendar event data
    public class callEvent{
        public String title {get;set;}
        public Boolean allDay {get;set;}
        public String startString {get;private set;}
        public String endString {get;private set;}
        public String url {get;set;}
        public String ourl {get;set;}
        public String className {get;set;}
        public String resource {get;set;}
        public Id eventId {get;set;}
        public String sEvenComma {get;set;}
        public String sEventColor {get;set;}
        Public String CustomerDetails {get;set;}
    }
    //Class to hold resource data
    public class callResource{
        public String name {get;set;}
        public Id Id {get;set;}
        public String sResoComma{get;set;}
    }
    
    public class EventTypes{
        public String TypeName {get;set;}
        public String Colorcode {get;set;}
        public String sClassName {get;set;}
    }
    
    
    private void fetchUserswithEvents(String sDeveloperName){
        this.listEvents = new list<callEvent>();
        this.listResources = new list<callResource>();
        this.setResourceIds = new set<Id>();
        //This will fetch all the users in the list view
        this.listResources = getPlancalListViewUsers(sDeveloperName);
        
        if(!listResources.isEmpty()){ 
            for(callResource oResource : listResources){
                setResourceIds.add(oResource.Id);
            }
        }
        //This will fetch all the events assiciated with the Users
        this.listEvents = getPlancalUserEvents(setResourceIds);
    }
    
    private list<callResource> getPlancalListViewUsers(String sDeveloperName){
        list<callResource> listPlancalListViewUsers = new list<callResource>();
        set<Id> setUserId = new set<Id>();
        Integer iResCount = 0;
        set<ID> RoleID = new Set<ID>();
        set<ID> RelatedId = new Set<ID>();
        try{
            Map<Id, Group> mapGroupId = new Map<Id, Group>([Select Id, Name
                                                            From Group
                                                            Where Type = 'Regular'
                                                            AND DeveloperName =:sDeveloperName]); 
            
            for(GroupMember oGroupMembers : [Select GroupId, UserOrGroupId
                                             From GroupMember
                                             Where GroupId IN: mapGroupId.keySet()]){
                                                 setUserId.add(oGroupMembers.UserOrGroupId);     
                                                 // Finding the Users of a Role added in the Public Group 
                                                 for(Id Uid : setUserid)
                                                 {
                                                     if(string.valueof(Uid).contains('00G'))
                                                     {
                                                         RoleID.add(Uid);
                                                     }
                                                 }      
                                                 if(RoleID.size()>0){
                                                     List<Group> grpList = new List<Group>([Select id,RelatedId,type from Group where Type='Role' and id in: RoleID]);          
                                                     for(Group Rid : grpList)
                                                     {
                                                         if(Rid.RelatedId !=null)
                                                             RelatedId.add(Rid.RelatedId);
                                                     }
                                                     
                                                 }                                         
                                             }                                            
            
            //List<User> listUser = [select Name,Alias, Id from User where (Id IN: setUserId OR userroleid in: RelatedId) and isactive = true ORDER BY Name ASC];
            
            /**Start**to show users on page in a defined custom defined ********/
            Map<String, ResourceCalendarSortUser__c> rcsu = ResourceCalendarSortUser__c.getAll();
            Boolean flag = false;
            for(String rs: rcsu.keySet()){
                if(rs.split(',')[0] == sDeveloperName){
                    flag = true;
                    break;
                }
            }
            
            List<User> listUser = new List<User>();
            if(flag){
                listUser = [select Name,Alias, Id from User where (Id IN: setUserId OR userroleid in: RelatedId) and isactive = true];
                List<User> sortedUsersList = new List<User>();
                
                Map<Integer, User> sortUsersMap = new Map<Integer, User>();
                Map<String, User> listUserMap = new Map<String, User>();
                
                for(User usr: listUser){
                    listUserMap.put(usr.Name, usr);
                }
                
                User us = new User();
                for(String rs: rcsu.keySet()){
                    if(rs.split(',')[0] == sDeveloperName){
                        sortUsersMap.put(Integer.valueOf(rs.split(',')[1]), listUserMap.get(rcsu.get(rs).ResourceView__c));
                    }
                }                
                
                for(Integer i = 0; i < sortUsersMap.keySet().size(); i++){
                    sortedUsersList.add(sortUsersMap.get(i));
                }
                
                listUser = new List<User>();
                listUser = sortedUsersList;
            }else{
                listUser = [select Name,Alias, Id from User where (Id IN: setUserId OR userroleid in: RelatedId) and isactive = true ORDER BY Name ASC];
            }
            /****End**to show users on page in a defined custom defined*****/
                        
            for(User oUser : listUser){
                callResource oResource = new callResource();
                
                oResource.name = oUser.Name;
                oResource.Id = oUser.Id;
                listPlancalListViewUsers.add(oResource);
                
                iResCount++;
                
                if(listUser.size() == iResCount){
                    oResource.sResoComma = '';
                }else{
                    oResource.sResoComma = ',';
                }
            }
            
        }catch(Exception ex){
            system.debug('getPlancalListViewUsers>>>>>>'+ex);   
        }
        return listPlancalListViewUsers;
    }
    
    private list<callEvent> getPlancalUserEvents(set<Id> setUserIds){
        system.debug('timeZone>>>>'+timeZone);
        
        list<callEvent> listPlancalEvents = new list<callEvent>();
        Map<String, Schema.PicklistEntry> mapEventTypes = new Map<String, Schema.PicklistEntry>();
        this.listEventTypeColors = new list<EventTypes>();
        Integer iEvenCount = 0;
        try{
            //To get Event object related field describtions
            Schema.DescribeSObjectResult oEventObj = Event.sObjectType.getDescribe();
            Map<String, Schema.SObjectField> oEventFields = oEventObj.fields.getMap();
            //To get the Type field describtion
            Schema.DescribeFieldResult F = oEventFields.get('Type').getDescribe();
            //To get the avialble Picklist values from Event Type Field  
            List<Schema.PicklistEntry> picklist = F.getPicklistValues();
            
            //To get the Custom Setting data to check it matches with Event Type values
            Map<String, ResourceCalendarEventTypeC__c> mapTypeColorView = ResourceCalendarEventTypeC__c.getAll();  
            List<String>EventTypeValues = new List<String>();
            system.debug('mapTypeColorView>>>>'+mapTypeColorView);
            For(Schema.PicklistEntry sPicValue : picklist){  
                if(mapTypeColorView.ContainsKey(sPicValue.getValue())){
                    EventTypes eventTypes = new EventTypes();
                    if(result=='fr_FR')
                        eventTypes.TypeName = mapTypeColorView.get(sPicValue.getValue()).French__c;
                    else if ((result=='de_AT') || (result =='de_DE') || (result == 'de_CH'))
                        eventTypes.TypeName = mapTypeColorView.get(sPicValue.getValue()).German__c;
                    else
                        eventTypes.TypeName = mapTypeColorView.get(sPicValue.getValue()).Name;
                    
                    eventTypes.Colorcode = mapTypeColorView.get(sPicValue.getValue()).Color_Code__c; 
                    
                    String strValue = mapTypeColorView.get(sPicValue.getValue()).Name;
                    eventTypes.sClassName = 'event-'+strValue.replaceAll( '\\s+', '');
                    EventTypeValues.add(mapTypeColorView.get(sPicValue.getValue()).Name);
                    listEventTypeColors.add(eventTypes);
                }
                mapEventTypes.put(sPicValue.getValue(), sPicValue);
            }
            
            Map<String, List<Event>> mapDt_Event = new Map<String, List<Event>>();
            List<Event> listNestedEvents = new List<Event>();
            for(Id tempId : setUserIds){
                system.debug('-----------test-------------' + tempId);
            }
            for(String type: EventTypeValues){
                system.debug('-----------type-------------' + type);
            }
            
            system.debug(setUserIds.contains('005i0000003Gwk3AAC') + '*&*&*&*&*&*&*&*&'+setUserIds);
            
            Date firstDate; 
            Date lastDate;  

            if(calendarView == 'resourceWeek'){
                firstDate = date.newInstance(currentYear,currentMonth,currentDay);
                lastDate = firstDate.addDays(6);
            }else if(calendarView == 'resourceNextWeeks'){
                firstDate = date.newInstance(currentYear,currentMonth,currentDay);
                lastDate = firstDate.addDays(27);
            }else{
                firstDate = date.newInstance(currentYear,currentMonth,1);
                lastDate = firstDate.addDays(Date.daysInMonth(currentYear, currentMonth));
            }
            
            List<Event> listEventsForLoop = [select Id, RecordType.Name, Reserved__c, Delivery_Slip_Color_Map__c,Account.Enterprise_Party_Number__c, Subject, Earlier_Requested_Date__c,
                                             isAllDayEvent, whatId, What.Name,Contract_Number__c,Service_Location__c, StartDateTime, EndDateTime, Type,OwnerId, Billing_Status__c,
                                             Related_To_Proposal__c, Related_To_Proposal__r.Name
                                             from Event 
                                             where OwnerId IN: setUserIds and 
                                             Type in:EventTypeValues AND 
                                             ((EndDateTime >=: firstDate AND EndDateTime <=: lastDate) OR (StartDateTime >=: firstDate AND StartDateTime <=: lastDate) OR (StartDateTime <=: firstDate AND EndDateTime >=: lastDate))];
            
            for(Event oEvent: listEventsForLoop){
                List<Event> listEventDtKey = mapDt_Event.get(String.valueOf(oEvent.StartDateTime.format('yyyy-MM-dd')));
                system.debug('listEventDtKey>>>'+listEventDtKey);
                if(listEventDtKey == null){
                    listEventDtKey = new List<Event>();
                    system.debug('listEventDtKey>>>'+listEventDtKey);
                    mapDt_Event.put(String.valueOf(oEvent.StartDateTime.format('yyyy-MM-dd')), listEventDtKey);
                }
                system.debug('listEventDtKey>>>'+listEventDtKey);
                listEventDtKey.add(oEvent);
                
                if(!listEventDtKey.isEmpty() || listEventDtKey != null){
                    
                }
            }
            
            
            //for(Event oEvent: listNestedEvents){
            for(Event oEvent: listEventsForLoop ){
                
                DateTime startDT = oEvent.StartDateTime;
                DateTime endDT = (oEvent.IsAllDayEvent ? oEvent.EndDateTime.addHours(24 - oEvent.EndDateTime.hour() - 1) : oEvent.EndDateTime);
                
                callEvent oInnerEvent = new callEvent();
                if(oEvent.RecordType.Name == 'Onsite Tech Support'){
                    oInnerEvent.title = (oEvent.WhatId != null ? (((String)oEvent.WhatId).startswith('001') ? (oEvent.Account.Enterprise_Party_Number__c != null ? oEvent.Account.Enterprise_Party_Number__c : '') : '') : '') + '-~~-' + 
                                        (oEvent.Contract_Number__c == null ? '' : oEvent.Contract_Number__c) + '-~~-' + 
                                        (oEvent.Related_To_Proposal__c == null ? '' : oEvent.Related_To_Proposal__r.Name) + '-~~-' + 
                                        (oEvent.Delivery_Slip_Color_Map__c == null ? '' : 'background-color:' + oEvent.Delivery_Slip_Color_Map__c) + '-~~-' + 
                                        /*ADDED By Suresh*/(oEvent.Billing_Status__c == null ? '' : (oEvent.Billing_Status__c == 'Closed' ? 'Closed' : '')) + '-~~-' + 
                                        (oEvent.WhatId != null ? (((String)oEvent.WhatId).startswith('001') ? oEvent.What.Name : '') : '') + '-~~-' + 
                                        (oEvent.Service_Location__c != null ? oEvent.Service_Location__c : '') + '-~~-' +
                                        (oEvent.Subject != null ? oEvent.Subject : '') + '-~~-' +
                                        (calendarView == 'resourceWeek'? 'TableView':'TextView') + '-~~-' +
                                        (oEvent.Reserved__c?'violetClass':'blank');
                }else{
                    oInnerEvent.title = '-~~-' + '-~~-' + '-~~-' + '-~~-' +  '-~~-' +  '-~~-' + '-~~-' +
                                    (oEvent.Subject != null ? oEvent.Subject : '') + '-~~-' +
                                    ('TextView') + '-~~-' +
                                    ('');
                }
                system.debug('---oInnerEvent--'+oInnerEvent.title);
                oInnerEvent.allDay = oEvent.isAllDayEvent;
                oInnerEvent.startString = startDT.format(dtFormat, timeZone);
                system.debug('oInnerEvent.startString>>>>'+oInnerEvent.startString);
                oInnerEvent.endString = endDT.format(dtFormat, timeZone);
                system.debug('oInnerEvent.endString>>>>'+oInnerEvent.endString);
                oInnerEvent.url = '/' + oEvent.Id;
                oInnerEvent.ourl =  ''+oEvent.Id;
                
                if(mapEventTypes.ContainsKey(oEvent.Type)){
                    String str = mapEventTypes.get(oEvent.Type).getValue();
                    oInnerEvent.className = 'event-'+str.replaceAll( '\\s+', '');
                    oInnerEvent.sEventColor = (oEvent.RecordType.Name == 'Onsite Tech Support' && oEvent.Earlier_Requested_Date__c == true ? '#C0392B' : mapTypeColorView.get(oEvent.Type).Color_Code__c);
                }  
                
                if(setUserIds.contains(oEvent.OwnerId)){
                    oInnerEvent.resource = oEvent.OwnerId; 
                }
                oInnerEvent.eventId = oEvent.Id;
                listPlancalEvents.add(oInnerEvent);
                
                iEvenCount++;
                
                system.debug('listEventsForLoop.size()>>>'+listEventsForLoop.size());
                system.debug('iEvenCount>>>>'+iEvenCount);
                if(listEventsForLoop.size() == iEvenCount){
                    oInnerEvent.sEvenComma = '';
                }else{
                    oInnerEvent.sEvenComma = ',';
                }
                
            }
            system.debug('-------listPlancalEvents----------' + listPlancalEvents);
            // if(listEventsForLoop.size() > 0){
            generateJsonString(listPlancalEvents);
            //}
            
            system.debug('--------JSON------------' + JsonData);
            
        }
        
        catch(Exception ex){
            system.debug('getPlancalUserEvents>>>>>'+ex);
        }
        
        return listPlancalEvents;
    }
    
    
    public void generateJsonString(List<CallEvent> listPlancalEvents){
        gen = JSON.createGenerator(true);
        //gen.writefield('test');
        gen.writeStartArray();
        for(CallEvent temp : listPlancalEvents){
            system.debug('temp ===>'+temp);
            system.debug('temp.title ===>'+temp.title);

            gen.writeStartObject();
            gen.writeStringField('title', (temp.title == null ? '' : temp.title));
            gen.writeStringField('start', (temp.startString == null ? '' : temp.startString ));
            gen.writeStringField('end', (temp.endString == null ? '' : temp.endString ));
            gen.writeStringField('url', (temp.url == null ? '' : temp.url ));
            gen.writeStringField('ourl', (temp.ourl == null ? '' : temp.ourl ));
            gen.writeBooleanField('allDay', (temp.allDay == null ? false : temp.allDay ));
            gen.writeStringField('className', (temp.className == null ? '' : temp.className ));
            gen.writeStringField('resource', (temp.resource == null ? '' : temp.resource ));
            gen.writeStringField('color', (temp.sEventColor == null ? '' : temp.sEventColor ));
            gen.writeEndObject();
        }
        
        
        gen.writeEndArray();
        JsonData = gen.getAsString();
        system.debug('------------------------' + JsonData);
    }
}