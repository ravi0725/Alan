({
    jsLoaded : function(component, event, helper) {
        var prpList=component.get("v.Resources");
        console.log('prpList @@@'+ prpList)
        if(!prpList.length)
        {
            helper.getReasource(component, event);
            
        }
    },
    openModel: function(component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.isModalOpen", true);
   },
  
   closeModel: function(component, event, helper) {
       // Set isModalOpen attribute to false  
       component.set("v.isModalOpen", false);
   },
  
   submitDetails: function(component, event, helper) {
       // Set isModalOpen attribute to false
       //Add your code to call apex method or do some processing
       component.set("v.isModalOpen", false);
   },
    
    // function automatic called by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for displaying loading spinner 
        component.set("v.spinner", true); 
    },
     
    // function automatic called by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hiding loading spinner    
        component.set("v.spinner", false);
    }
    
})