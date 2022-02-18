({
    getStage : function(component, event, helper) {     
        // create a one-time use instance of the serverEcho action       
        var action = component.get("c.getCurrentStage");
        
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {              
                var storedValue=response.getReturnValue();
                if(storedValue!==null){
                    component.set("v.selectedStep",storedValue);                    
                }
                else{
                    component.set("v.selectedStep",step1);
                }
                
                let getSettingsAction = component.get("c.getMigrationStatusSetting");        
                getSettingsAction.setCallback(this, function(response) {
                    if (component.isValid() && response !== null && response.getState() === 'SUCCESS') {
                        component.set("v.isDiaplyNextButton", response.getReturnValue());
                        component.set("v.isDiaplyConfirmButton", response.getReturnValue());                        
                        var isDiaplyNextButton = component.get("v.isDiaplyNextButton");                       
                    }                     
                });               
                
                $A.enqueueAction(getSettingsAction);
            }
        });
        
        // $A.enqueueAction adds the server-side action to the queue.
        $A.enqueueAction(action);
        helper.getMetadataJobStatus(component, event, helper);
        helper.getMigrationJobStatus(component, event, helper);
    },
    updateStage : function(component, event, helper,getselectedStep) {     
        // create a one-time use instance of the serverEcho action
        // in the server-side controller
        var action = component.get("c.updateMigrationStatus");
        action.setParams({ stepNo : getselectedStep});
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {      
                // Alert the user with the value returned 
                // from the server
                var isUpdated=response.getReturnValue();
                if(!isUpdated){
                  
                } 
                let getSettingsAction = component.get("c.getMigrationStatusSetting");        
                getSettingsAction.setCallback(this, function(response) {
                    //component.isValid() && response !== null && 
                    if (response.getState() === 'SUCCESS') {
                        //$A.util.addClass(spinner, "slds-hide");
                        component.set("v.isDiaplyNextButton", response.getReturnValue());
                        component.set("v.isDiaplyConfirmButton", response.getReturnValue());
                        var isDiaplyNextStep = component.get("v.isDiaplyNextButton");
                    } 
                });
                $A.enqueueAction(getSettingsAction);                
                // You would typically fire a event here to trigger                
            }
        });       
        $A.enqueueAction(action);
        helper.getMetadataJobStatus(component, event, helper);
    },
    getMigrationStatus : function(component, event, helper,getselectedStep) {        
        let getSettingsAction = component.get("c.getMigrationStatusSetting");        
        getSettingsAction.setCallback(this, function(response) {                   
            if (component.isValid() && response !== null && response.getState() === 'SUCCESS') {
                component.set("v.isDiaplyNextButton", response.getReturnValue()); 
                var isDiaplyNextStep = component.get("v.isDiaplyNextButton");
            }            
        });
        $A.enqueueAction(getSettingsAction);
        
    },
    objectMappingStatusCount : function(component, event, helper,getselectedStep) {
        let getCountAction = component.get("c.getObjectMappingCount");        
        getCountAction.setCallback(this, function(response) {                   
            if (component.isValid() && response !== null && response.getState() === 'SUCCESS') {
                if(response.getReturnValue() > 0){
                    component.set("v.displayRevertbutton", true);
                }
                else{
                    component.set("v.displayRevertbutton", false);
                }
            }  
        });
        $A.enqueueAction(getCountAction);
        
    },
    
    getMapping : function(component, event, helper) {
        var action = component.get("c.getDataMappingDetails");         
        action.setCallback(this, function(response){
            var state = response.getState();             
            if(state==='SUCCESS'){                
                var result = response.getReturnValue();  
                if(result === true){
                    component.set('v.Mappingfound', result); 
                }
                else{
                    component.set("v.selectedStep", "step5");
                    var getselectedStep = component.get("v.selectedStep");
                    helper.updateStage(component, event, helper,getselectedStep);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    showSpinner: function(component) {
        var spinnerMain =  component.find("spinnerId");       
        $A.util.removeClass(spinnerMain, "slds-hide");
        component.set("v.spinner", true); 
    },
    
    hideSpinner : function(component) {
        var spinnerMain =  component.find("spinnerId");        
        $A.util.addClass(spinnerMain, "slds-hide");
        component.set("v.spinner", false); 
    },
    
    runningjobStatus : function(component, event, helper) {
        var getRunningJobAction = component.get("c.getrunningJobStatus");
        helper.showSpinner(component);
        getRunningJobAction.setCallback(this, function(response) {
            if (component.isValid() && response !== null && response.getState() == 'SUCCESS') {                
                component.set("v.displayBackbutton", response.getReturnValue());
                helper.hideSpinner(component);
            }            
        });
        $A.enqueueAction(getRunningJobAction);
        
    },
    showToastMsg : function(component,event,helper){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: 'Error!',
            type : 'Error',
            message : 'Job already in Progress'
        });
        toastEvent.fire();
    },
    showPrerequisiteToastMsg : function(component,event,helper){
        var errmsg =  $A.get("$Label.c.Sustain_acknowledgement_MSG") 
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: 'Error!',
            type : 'Error',
            message :errmsg
        });
        toastEvent.fire();
    },
    
    getMetadataJobStatus : function(component, event, helper) {
        let getFlagAction = component.get("c.getRunningMetadataJobFlag");  
        getFlagAction.setCallback(this, function(response) {
            if (component.isValid() && response !== null && response.getState() == 'SUCCESS') {
                component.set("v.metadataRunningJobFlag", response.getReturnValue());
                helper.hideSpinner(component);               
            }             
        });       
        $A.enqueueAction(getFlagAction);
    },
    getMigrationJobStatus : function(component, event, helper) {
        var actionMig = component.get("c.getMigrationStatusData");
        
        actionMig.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {                       
                var migstatus =response.getReturnValue();
                
                if(migstatus != null){
                    component.set("v.checkboxChecked",migstatus); 
                    component.set("v.migStatusData", migstatus);                   
                }else{
                    component.set("v.checkboxChecked",false);   
                }                      
            }else{
                component.set("v.checkboxChecked",false);
            }
        });
        
        $A.enqueueAction(actionMig);
    }
})