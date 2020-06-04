({
	doInit : function(component, event, helper) {
        console.log('Inside Doinit:::::');
        var TopicId = component.get("v.TopicId");
        console.log('Inside Doinit:::::'+TopicId);
        var action = component.get("c.getTopicName");
        action.setParams({
            recordId: TopicId
        });
        
        action.setCallback(this, function(response) {
            //var result = JSON.parse(response.getReturnValue());
            console.log('response:::::'+response);
            var result = response.getReturnValue();
            component.set("v.TopicName", result);
            //console.log('SalesOrderMap:::::'+component.get("v.SalesOrderMap"));
            console.log('result:::::'+result);
            console.log('result:::::'+JSON.stringify(result));
            
           // component.set('v.lstKey', arrayOfMapKeys);
        })
        $A.enqueueAction(action);
    },
    
    postQuestionHelper : function(component, event, helper) {
        
        console.log('Inside postQuestionHelper:::::');
        var TopicId = component.get("v.TopicId");
        console.log('Inside postQuestionHelper:::::'+TopicId);
        var QuestionVal = component.get("v.QuestionVal");
        console.log('Inside postQuestionHelper:::::'+QuestionVal);
        var action = component.get("c.postQuestionOnTopic");
        action.setParams({
            recordId: TopicId,
            QuestionBody : QuestionVal
        });
        action.setCallback(this, function(response) {
            console.log('response:::::'+response);
            var result = response.getReturnValue();
            console.log('result:::::'+JSON.stringify(result));
            var body = JSON.stringify(result);
            if(body.indexOf('Error') != -1)
                alert('Error Occure while posting question'+body);
            else{
                var finalURL = window.location.href;
                finalURL = finalURL.substring(0,finalURL.indexOf('/s/'));
                window.location.href = finalURL +'/s/question/'+result+'/';
            }
            	
        })
        $A.enqueueAction(action);
    },
})