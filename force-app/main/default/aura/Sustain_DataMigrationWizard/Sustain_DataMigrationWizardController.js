({
    doInit : function(component, event, helper) {
        helper.showSpinner(component);		
        helper.getStage(component, event, helper);  
        helper.runningjobStatus(component, event, helper);        
    },
    refreshParent : function(component, event, helper) {
        component.set("v.selectedStep",event.getParam("stapeName"));
        helper.getStage(component, event, helper);
    },
    handleNext : function(component,event,helper){
        helper.showSpinner(component);
        var getselectedStep = component.get("v.selectedStep");
        if(getselectedStep === "step1"){
            component.set("v.selectedStep", "step2");
        }
        else if(getselectedStep === "step2"){
            //Call Child aura method
            var childComponent = component.find("migrationWizardCmp");
            var message = childComponent.saveMapping();
            component.set("v.selectedStep", "step3");
            component.find("fieldMappingCmp").reloadChild();
            helper.hideSpinner(component);
            
        }
        else if(getselectedStep === "step3"){
            var childComponent = component.find("fieldMappingCmp");
            var message = childComponent.handleChange(function(flagResult) {
                if(flagResult===true){
                    component.set("v.showConfirmDialogOfFieldMap", true);                      
                }
                else{
                    var message = childComponent.saveMapping(function(result) {
                        if(result==="Completed"){
                            getselectedStep = "step4";
                            component.set("v.selectedStep",getselectedStep);
                            helper.updateStage(component, event, helper,getselectedStep);
                            component.find("confirmDataMap").reloadChild();                           
                        }
                    });
                }
            });
        }
        else if(getselectedStep === "step4"){
            //component.set("v.selectedStep", "step5");
            helper.getMapping(component, event, helper);
        }
        else if(getselectedStep === "step5"){
            component.set("v.selectedStep", "step6");
        }
        getselectedStep = component.get("v.selectedStep");
        if(getselectedStep !== "step3"){
            helper.updateStage(component, event, helper,getselectedStep);   
        }  
    },
    handleConfirmDialogYesFieldMap: function(component,event,helper){
       component.set('v.showConfirmDialogOfFieldMap', false);
        var getselectedStep = "step3";  
        var childComponent = component.find("fieldMappingCmp");

        var message = childComponent.saveMapping(function(result) {
                    if(result==="Completed"){
                        getselectedStep = "step4";
                        component.set("v.selectedStep",getselectedStep);
                        helper.updateStage(component, event, helper,getselectedStep);
                        component.find("confirmDataMap").reloadChild();
                        // $A.get('e.force:refreshView').fire();
                    }
                });
        helper.hideSpinner(component);
	},
    SubmitConfirmDataScreen: function(component,event,helper){
        component.set('v.Mappingfound', false);
        component.set("v.selectedStep", "step5");
        var getselectedStep = component.get("v.selectedStep");
        helper.updateStage(component, event, helper,getselectedStep);
	},
    handleStart: function(component,event,helper){
        component.set("v.displayStartbutton",false);
        component.set("v.displayRevertbutton",false);
        getselectedStep = component.get("v.selectedStep");
        if(getselectedStep === "step6") {
            //var action = component.get("c.getCurrentStage");
            var action = component.get("c.startFinalDataLoad");
            
            // Create a callback that is executed after 
            // the server-side action returns
            action.setCallback(this, function(response) {
                 if (response !== null && response.getState() === 'SUCCESS') {
                      var response=response.getReturnValue();
                 }
            });
            $A.enqueueAction(action);
        }
    },
    handlePrev : function(component,event,helper){
        helper.showSpinner(component);
        var getselectedStep = component.get("v.selectedStep");
        if(getselectedStep === "step2"){            
            helper.getMigrationJobStatus(component, event, helper);
            component.set("v.selectedStep", "step1");
        }
        else if(getselectedStep === "step3"){
            component.set("v.selectedStep", "step2");
        }
        else if(getselectedStep === "step4"){
            component.set("v.selectedStep", "step3");
            component.find("fieldMappingCmp").reloadChild();
        }
        else if(getselectedStep === "step5"){
            component.set("v.selectedStep", "step4");
        }
        else if(getselectedStep === "step6"){
            component.set("v.selectedStep", "step5");
        }
        getselectedStep = component.get("v.selectedStep");
        helper.updateStage(component, event, helper,getselectedStep);
    },
    
    handleFinish : function(component,event,helper){
        //component.set("v.selectedStep", "step1");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/lightning/page/home"
        });
        urlEvent.fire();
    },
    
    selectStep1 : function(component,event,helper){
        //helper.showSpinner(component);
        if(component.get("v.displayBackbutton") && !component.get("v.metadataRunningJobFlag")){
	        var getselectedStep="step1";
	        component.set("v.selectedStep", "step1");
	        helper.updateStage(component, event, helper,getselectedStep);
            helper.getMigrationJobStatus(component, event, helper);
        }
        else{
            helper.showToastMsg(component, event, helper);
        }
    },
    selectStep2 : function(component,event,helper){
        //helper.showSpinner(component);
        //helper.runningjobStatus(component, event, helper);
        if(!component.get("v.checkboxChecked")){
            helper.showPrerequisiteToastMsg(component, event, helper);    
        }else if(component.get("v.displayBackbutton") && !component.get("v.metadataRunningJobFlag")){
	        var getselectedStep="step2";
	        component.set("v.selectedStep", "step2");
	        helper.updateStage(component, event, helper,getselectedStep);
        }
        else{
            helper.showToastMsg(component, event, helper);
        }
    },
    selectStep3 : function(component,event,helper){
        //helper.showSpinner(component);
        //helper.runningjobStatus(component, event, helper);
        if(!component.get("v.checkboxChecked")){
            helper.showPrerequisiteToastMsg(component, event, helper);    
        }else if(component.get("v.displayBackbutton") && !component.get("v.metadataRunningJobFlag")){
	        var getselectedStep="step3";
	        component.set("v.selectedStep", "step3");
	        component.find("fieldMappingCmp").reloadChild();
        
	        helper.updateStage(component, event, helper,getselectedStep);
        }
        else{
            helper.showToastMsg(component, event, helper);
        }
    },
    selectStep4 : function(component,event,helper){
        //helper.runningjobStatus(component, event, helper);
        if(!component.get("v.checkboxChecked")){
            helper.showPrerequisiteToastMsg(component, event, helper);    
        }else if(component.get("v.displayBackbutton") && !component.get("v.metadataRunningJobFlag")){
	        var getselectedStep="step4";   
	        component.set("v.selectedStep", "step4");
	        helper.updateStage(component, event, helper,getselectedStep);
	        component.find("confirmDataMap").reloadChild(); 
        }
        else{
            helper.showToastMsg(component, event, helper);
        }
    },
    selectStep5 : function(component,event,helper){
        if(!component.get("v.checkboxChecked")){
            helper.showPrerequisiteToastMsg(component, event, helper);    
        }else if(component.get("v.displayBackbutton") && !component.get("v.metadataRunningJobFlag")){
		var getselectedStep="step5";
		let selectedStep = component.get("v.selectedStep");
	        helper.getMigrationStatus(component,event,helper);
	        let isDiaplyNextStep = component.get("v.isDiaplyNextButton");
	        if((selectedStep==="step4" && isDiaplyNextStep) || selectedStep!=="step4") {
	            component.set("v.selectedStep", "step5");
	            helper.updateStage(component, event, helper,getselectedStep);
	        }
	        else if(isDiaplyNextStep === false){
	            var toastEvent = $A.get("e.force:showToast");                    
	                            toastEvent.setParams({
	                                title : 'Warning',
	                                message: 'Metadata should be created in \'Confirm Data Mapping\' before initiating sample load',
	                                duration:' 5000',
	                                key: 'info_alt',
	                                type: 'Warning',
	                                mode: 'pester'
	                            });
	                            toastEvent.fire();           
	        }
        }
        else{
            helper.showToastMsg(component, event, helper);
        }
    },
    selectStep6 : function(component,event,helper){
        //helper.runningjobStatus(component, event, helper);
        if(!component.get("v.checkboxChecked")){
            helper.showPrerequisiteToastMsg(component, event, helper);    
        }else if(component.get("v.displayBackbutton") && !component.get("v.metadataRunningJobFlag")){
	        var getselectedStep="step6";
	        let selectedStep = component.get("v.selectedStep");
	        helper.objectMappingStatusCount(component,event,helper);
	        helper.getMigrationStatus(component,event,helper);
	        let isDiaplyNextStep = component.get("v.isDiaplyNextButton");
	        if((selectedStep==="step4" && isDiaplyNextStep) || selectedStep!=="step4") {
	            component.set("v.selectedStep", "step6");
	            helper.updateStage(component, event, helper,getselectedStep);
	        }
	        else if(isDiaplyNextStep === false){
	            var toastEvent = $A.get("e.force:showToast");                    
	                            toastEvent.setParams({
	                                title : 'Warning',
	                                message: 'Metadata should be created in \'Confirm Data Mapping\' before initiating sample load',
	                                duration:' 5000',
	                                key: 'info_alt',
	                                type: 'Warning',
	                                mode: 'pester'
	                            });
	                            toastEvent.fire();           
	        }
        }
        else{
            helper.showToastMsg(component, event, helper);
        }
    },
    handleJobExecution : function(component,event,helper){
        component.set("v.showConfirmDialog", true);
    },
    
    handleConfirmDialogYes : function(component, event, helper) {
        component.set("v.metadataRunningJobFlag", true);
        component.set("v.isDiaplyConfirmButton", true);
        component.set('v.showConfirmDialog', false);
        var action = component.get("c.executeBatchJob");       
        action.setCallback(this, function(response){
            var state = response.getState();             
            if(state==='SUCCESS'){                
                var isUpdated=response.getReturnValue();
                if(typeof isUpdated === 'undefined' || isUpdated === null){
                  //  console.log('Not able to update migration status custom setting record');
                } else {
                    let getSettingsAction = component.get("c.getMigrationStatusSetting");        
                    getSettingsAction.setCallback(this, function(response) {
                        if (component.isValid() && response !== null && response.getState() === 'SUCCESS') {
                            component.set("v.isDiaplyNextButton", response.getReturnValue());
                            var toastEvent = $A.get("e.force:showToast");                    
                            toastEvent.setParams({
                                title : 'Success',
                                message: 'The records have been updated successfully.',
                                duration:' 5000',
                                key: 'info_alt',
                                type: 'success',
                                mode: 'pester'
                            });
                            toastEvent.fire();
                        }  else {
                            var toastEvent = $A.get("e.force:showToast");                    
                            toastEvent.setParams({
                                title : 'Error',
                                message: 'There is a problem. Please contact System Admin.',
                                duration:' 5000',
                                key: 'info_alt',
                                type: 'error',
                                mode: 'pester'
                            });
                            toastEvent.fire();
                        }
                    });
                    $A.enqueueAction(getSettingsAction);
                    helper.getMetadataJobStatus(component, event, helper);
                }
            }
        });        
        $A.enqueueAction(action);   
    },     
    handleConfirmDialogNo : function(component, event, helper) {
        component.set('v.showConfirmDialog', false);
        helper.hideSpinner(component);

    },
    handleConfirmDialogNoFieldMap : function(component, event, helper) {
        component.set('v.showConfirmDialogOfFieldMap', false);
		component.set('v.Mappingfound', false);
        helper.hideSpinner(component);
    },
    deleteLoad : function(component,event,helper){
        component.set("v.displayStartbutton",false);
        component.set("v.displayRevertbutton",false);
        var action = component.get("c.deleteDataLoadReq");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                
                if (component.isValid() && response !== null && response.getState() === 'SUCCESS') {
                    var toastEvent = $A.get("e.force:showToast");                    
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'Delete migrated data job has been initiated, we will notify you once its done.',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }  else {
                    var toastEvent = $A.get("e.force:showToast");                    
                    toastEvent.setParams({
                        title : 'Error',
                        message: 'There is a problem. Please contact System Admin.',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
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
    },
	handleRefreshEvent : function(component,event,helper){
    	helper.runningjobStatus(component, event, helper);	    
    },
    handleProceed : function(component,event,helper){
        component.set("v.showmodalpopup" , false) ;
        component.set("v.skipClicked" , false) ;
        var componentEvent=component.getEvent("handleProceedEvent");
        componentEvent.fire();
    },
    onCheck  : function(component,event,helper){
        console.log('checking',v.checkboxChecked);
        if(component.get("v.checkboxChecked") === true)
            component.set( "v.checkboxChecked",false);
        else
            component.set("v.checkboxChecked",true); 
        
    },
})