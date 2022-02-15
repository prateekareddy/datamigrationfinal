({
	loadData : function(component, event, helper) {
        var action = component.get("c.getDataMappingDetails");         
         action.setCallback(this, function(response) {
               var state = response.getState();
            if (state === "SUCCESS") {
                var resultData = response.getReturnValue();
                component.set('v.wrapperList', resultData);
            }   
        });
        $A.enqueueAction(action);
        var action2 = component.get("c.getLatestDataLoad");         
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resultData = response.getReturnValue();
                component.set('v.dLR', resultData);
            }   
        });
        $A.enqueueAction(action2);
    },
     checkCurRunJobIsSampleFinal : function(component, event, helper) {
        var getRunningJobAction = component.get("c.checkRunningJobIsSampleFinal");
        
        getRunningJobAction.setCallback(this, function(response) {
            if (component.isValid() && response !== null && response.getState() == 'SUCCESS') {
                
                component.set("v.displaySampleLoadButton", response.getReturnValue());
            }
            
        });
        $A.enqueueAction(getRunningJobAction);
        
    }
})