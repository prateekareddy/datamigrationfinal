({
    redirect : function(component, event, helper) {
        
        if(component.get("v.readyToLaunch") === true){
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:Sustain_DataMigrationWizard"
            });
            //alert('Hi1');
            evt.fire();
            // alert('Hi2');
        }else{            
            var toastEvent = $A.get("e.force:showToast");                    
            toastEvent.setParams({
                title : 'Error',
                message: $A.get("$Label.c.Sustain_InstallationStepsLabel"),
                duration:' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();    
        }
        
    },
    doInit : function(component, event, helper) {
        //helper.showSpinner(component);
        var getSettingsAction = component.get("c.getMigrationStatus");
        
        getSettingsAction.setCallback(this, function(response) {
            if (component.isValid() && response !== null && response.getState() == 'SUCCESS') {
                component.set("v.readyToLaunch", response.getReturnValue());
                if(response.getReturnValue()===true){
                    component.set("v.showButton",true);
                }
                else{
                    component.set("v.prerequisiteButtonLabel",'Complete Prerequisite');
                    component.set("v.showButton",false);
                }
                
            }
        });
        $A.enqueueAction(getSettingsAction);
    },
    showPage: function(component, event, helper) {
        component.set("v.showPrerequisitePage",true);
        var childComponent = component.find("completePrerequisiteComp");
        var message = childComponent.openModal();
    }
})