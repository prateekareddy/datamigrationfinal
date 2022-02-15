({
    doInit : function(component, event, helper) {
        helper.showSpinner(component);
        //component.set("v.spinner", true); 
        var action = component.get("c.fetchOrgScanDetails");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // set org information on orgScanOutput attribute
                component.set("v.orgscanoutput", storeResponse);  
                //component.set("v.spinner", false);                
            }
            helper.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    onCheck  : function(component,event,helper){
        if(component.get("v.checkboxChecked") === true)
            component.set( "v.checkboxChecked",false);
        else
            component.set("v.checkboxChecked",true); 
        
    },
    // this function automatic call by aura:waiting event  
    //showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
         //component.set("v.spinner", true); 
    //},
     
  // this function automatic call by aura:doneWaiting event 
    //hideSpinner : function(component,event,helper){
      // make Spinner attribute to false for hide loading spinner    
        //component.set("v.spinner", false);
     //},
     openHelpPage : function(component,event, helper) {        
        window.open($A.get("$Label.c.Sustain_helpPageURL"));
     } ,
     openVendorPage : function(component,event, helper) {
            var action = component.get("c.getListViews");
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    var listviews = response.getReturnValue();
                    window.open('/lightning/o/Migration_Util__Vendor__c/list?filterName='+listviews.Id);
                }
            });
            $A.enqueueAction(action);
     } ,
     // this function automatic call by aura:waiting event  
    /*handleNext: function(component, event, helper) {
        var action = component.get("c.redirectToObjectMappings");
        action.setParams({ migStage : "Review/Update Data Mappings" });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // set current user information on userInfo attribute
                //component.set("v.orgScanOutput", storeResponse);
            }
        });
        $A.enqueueAction(action);
    }  */  
    handleProceed : function(component,event,helper){
        component.set("v.showmodalpopup" , false) ;
        component.set("v.skipClicked" , false) ;
        var componentEvent=component.getEvent("handleProceedEvent");
        componentEvent.fire();
    }
        
})