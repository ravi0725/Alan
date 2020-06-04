({
	getEventData : function(component) {
		var action = component.get("c.getEventData");    
        action.setParams({
            "eventId":recId
        });
        // Callback function to get the response
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                var eventData = response.getReturnValue();
                console.log('eventData @@@@@ - '+JSON.stringify( response.getReturnValue()));
                component.set("v.trainingEvent",eventData);
            }
            else {
                alert('Error in getting data');
            }
        });
        // Queue this action to send to the server
        $A.enqueueAction(action);
	}
})