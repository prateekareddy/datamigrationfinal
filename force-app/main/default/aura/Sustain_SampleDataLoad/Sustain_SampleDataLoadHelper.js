({
    searchHelper : function(component,event,getInputkeyWord) {
        var action = component.get("c.fetchLookUpValues");
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'allAssetRecords':component.get("v.allAssetRecords")
        });
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
           // alert('value of state'+state);
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                /*if (storeResponse.length === 0) {
                    component.set("v.Message", 'No Records Found...');
                } else {
                    component.set("v.Message", '');
                    // set searchResult list with return value from server.
                }*/
                component.set("v.listOfAssetRecords", storeResponse);
                //alert('valueof '+component.get("v.listOfAssetRecords"));
            }
        });
        // enqueue the Action  
        $A.enqueueAction(action);
        
    },
    subscribe: function (component, event, helper) {
    // Get the empApi component.
     //alert('inside subscribe');
    const empApi = component.find("empApi");
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