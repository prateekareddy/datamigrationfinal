({
	retrieveObjMapping : function(component, event, helper) {
        // create a one-time use instance of the serverEcho action
        // in the server-side controller
        var action = component.get("c.getObjMapping");
        
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               
                component.set("v.wrapObject",response.getReturnValue());
               
                var wrapObject=component.get("v.wrapObject");
                var objMap = [];
                for(var key in wrapObject.coreObjectMap){
                    objMap.push({key: key, value: wrapObject.coreObjectMap[key]});
                }
                component.set("v.objMap",objMap);
                if(response.getReturnValue().stdObjList !== undefined && response.getReturnValue().stdObjList.length>6 ) {
                    var cmpTarget2 = component.find("myTable2"); 
                    $A.util.addClass(cmpTarget2, 'scrollbar');                      
                }
                
                if(response.getReturnValue().stdObjwithCustFieldList !== undefined && response.getReturnValue().stdObjwithCustFieldList.length>6) {
                    var cmpTarget = component.find("myTable"); //This code works if we remove the Main aura if from cmp
                    $A.util.addClass(cmpTarget, 'scrollbar');                    
                }
                    
                if( response.getReturnValue().customObjList !== undefined && response.getReturnValue().customObjList.length > 6 ) {
                    var cmpTarget1 = component.find("myTable1"); //This code works if we remove the Main aura if from cmp
                    $A.util.addClass(cmpTarget1, 'scrollbar');                    
               	 }
                     
            }
        });
       
        $A.enqueueAction(action);
    },
    saveMappingHelper :function(component,event){
        // create a one-time use instance of the serverEcho action
        // in the server-side controller      
        var varSet=component.get("v.updatedSet");
        var action = component.get("c.updateObjMapping");
        action.setParams({ objMappingMap : varSet});
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               var toastEvent = $A.get("e.force:showToast");
               toastEvent.setParams({
                     title: 'Success!',
                   	 type : 'success',
                     message : 'Object Mapping Saved!!!'
               });
               toastEvent.fire();
            }
        });
      
        $A.enqueueAction(action);
    },
    showSpinner: function(component) {
        var spinnerMain =  component.find("Spinner");
        $A.util.removeClass(spinnerMain, "slds-hide");
    },
        
    hideSpinner : function(component) {
    var spinnerMain =  component.find("Spinner");
    $A.util.addClass(spinnerMain, "slds-hide");
    }
})