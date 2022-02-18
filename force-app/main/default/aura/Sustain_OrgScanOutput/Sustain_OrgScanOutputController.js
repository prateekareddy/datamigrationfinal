({
    doInit : function(component, event, helper) {
        helper.showSpinner(component);
        
        var action = component.get("c.fetchOrgScanDetails");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // set org information on orgScanOutput attribute
                component.set("v.orgscanoutput", storeResponse);                        
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
    handleProceed : function(component,event,helper){
        component.set("v.showmodalpopup" , false) ;
        component.set("v.skipClicked" , false) ;
        var componentEvent=component.getEvent("handleProceedEvent");
        componentEvent.fire();
    }        
})