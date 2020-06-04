({
    getReasource: function(component,event){
        var action = component.get("c.getEvents");
        console.log('action @@2'+action);
        var self = this;
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                console.log('action @@3'+action);
                var eventArr = response.getReturnValue();
                self.jsLoaded(component,eventArr);
                component.set("v.Resources", response.getReturnValue());
            }
            
        });
        $A.enqueueAction(action);  
    },
    jsLoaded : function(component,events){
        
        $(document).ready(function(){
            
            (function($) { 
                "use strict";
                var tempR = events;
                var calFul = $("#calendar");
                var initialLocaleCode = 'en';
                var timeZone = 'Africa/Addis_Ababa';
                var now = moment().add(moment.tz(timeZone).utcOffset(), "m");
                var now1 = moment.tz.setDefault(timeZone);
                var localeSelectorEl = $("#locale-selector");
                var jsnResourcesArray = [];
                var jsnEventsArray = [];
                
                for(var i = 0;i < tempR.length;i++){
                    jsnResourcesArray.push({
                        'title':tempR[i].Name,
                        'id':i
                    });
                    for(var k=0;k < tempR[i].Instructor_In_Sessions__r.length ; k++){
                        for(var m=0;m < tempR[i].Training_Events__r.length ; m++){
                            jsnEventsArray.push({
                                'resourceId': i,
                                'id': tempR[i].Training_Events__r[m].Id,
                                'title':tempR[i].Training_Events__r[m].Name,
                                'start': $A.localizationService.formatDateTime(tempR[i].Instructor_In_Sessions__r[k].Start__c, "MMMM dd yyyy, hh:mm:ss a"),
                                //'start': parseDateTime(tempR[i].Instructor_In_Sessions__r[k].Start__c,local),
                                'end': $A.localizationService.formatDateTime(tempR[i].Instructor_In_Sessions__r[k].End__c, "MMMM dd yyyy, hh:mm:ss a"),
                                //'end': parseDateTime(tempR[i].Instructor_In_Sessions__r[k].End__c),
                                'Description':'Cource : ' + tempR[i].Training_Events__r[m].Course__r.Name + '</br>' + 'Booked : ' + tempR[i].Training_Events__r[m].Booked__c,
                                'color' : myEventColor(tempR[i].Training_Events__r[m].Type__c),
                            });
                        }
                    }
                }
                calFul.fullCalendar({
                    schedulerLicenseKey: 'GPL-My-Project-Is-Open-Source',
                    defaultView: 'timelineMonth',
                    plugins: [ 'momentTimezone' ],
                    locale: initialLocaleCode,
                    center: 'Event Calendar',
                    resourceAreaWidth: '12%',
                    resourceLabelText: 'Instructors',
                    timeZone: now1,
                    timeFormat: 'HH:mm',
                    views: {                        
                        
                    },
                    eventMouseover: function (data, event, view) {
                        var tooltip = '<div class="tooltiptopicevent slds-popover slds-popover_tooltip slds-nubbin_bottom-left" style="position:absolute;z-index:10001;color:white;padding:1%">' + 'Title ' + ': ' + data.title + '</br>' + 'Start ' + ': ' + $A.localizationService.formatDate(data.start, "MMMM dd yyyy, hh:mm:ss a") + '</br>' + 'End ' + ': ' + $A.localizationService.formatDate(data.end, "MMMM dd yyyy, hh:mm:ss a") + '</br>'+ data.Description + '</div>';
                        
                        $("body").append(tooltip);
                        $(this).mouseover(function (e) {
                            $(this).css('z-index', 10000);
                            $('.tooltiptopicevent').fadeIn('400','linear');
                            $('.tooltiptopicevent').fadeTo('10', 1.9);
                        }).mousemove(function (e) {
                            $('.tooltiptopicevent').css('top', e.pageY + -140);
                            $('.tooltiptopicevent').css('left', e.pageX + 10);
                        });
                    },
                    eventMouseout: function (data, event, view) {
                        $(this).css('z-index', 8);
                        $('.tooltiptopicevent').remove();
                    },
                    eventRender: function(event, el) {
                        // render the timezone offset below the event title
                        if (event.start.hasZone()) {
                            el.find('.fc-title').after(
                                $('<div class="tzo"/>').text(event.start.format('Z'))
                            );
                        }
                    },
                    
                    resources:jsnResourcesArray,
                    events: jsnEventsArray,
                    eventClick: function(event) {
                        component.set('v.isModalOpen',true);
                        var eventId = event.id;
                        component.set('v.sessionVal',eventId);
                    }
                });
                
            })(jQuery);
            
        });
        
        // load the list of available timezones, build the <select> options
        $.getJSON('/resource/1590754322000/timezoneJson', function(timezones) {
            $.each(timezones, function(i, timezone) {
                $('#timezone-selector').append(
                        $("<option/>").text(timezone).attr('value', timezone)
                    );
            });
        });
        
        $('#timezone-selector').on('change', function() {
            var calTimeZone = $('#calendar');
            var self = this;
            calTimeZone.fullCalendar('option', 'timezone', self.value || false);
         });
        
        function myEventColor(status) {
            if(status === 'Private'){
                return 'Green'; 
            }
            else if (status === 'Public') {
                return 'Blue';
            } else if (status === 'HOLIDAY') {
                return 'Red';
            } else  {  //Cancelled 
                return '#ff0000';
            } 
		}
    },
})