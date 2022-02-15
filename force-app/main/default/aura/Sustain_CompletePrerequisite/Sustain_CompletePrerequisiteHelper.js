({
	/*scheduleCreateFieldBatch : function(component, event, helper) {
		//call apex class method
         var action = component.get("c.createSourceIDField");
         
         //var tabName = component.find()
         // set the parameters to method  
         action.setCallback(this, function(response) {
             //store state of response
             var state = response.getState();
             if (state === "SUCCESS") {
                 var resultData = response.getReturnValue();                
             }
         });
         $A.enqueueAction(action);
	},*/
    getFactorList : function(component, event, helper) {
		//call apex class method
         var action = component.get("c.getAllEmissionFactors");
         
         //var tabName = component.find()
         // set the parameters to method  
         action.setCallback(this, function(response) {
             //store state of response
             var state = response.getState();
             if (state === "SUCCESS") {
                 var resultData = response.getReturnValue();
                 //set response value in wrapperList attribute on component.                 
                 component.set("v.fctrWrap" , resultData);
                 helper.getVersionFlag(component, event, helper);
             }
         });
         $A.enqueueAction(action);
	},
    getVersionFlag : function(component, event, helper) {
		//call apex class method
         var action = component.get("c.getSCPackageVersion");
         
         //var tabName = component.find()
         // set the parameters to method  
         action.setCallback(this, function(response) {
             //store state of response
             var state = response.getState();
             if (state === "SUCCESS") {
                 var resultData = response.getReturnValue();
                 //set response value in wrapperList attribute on component.                 
                 component.set("v.correctVersion" , resultData);
                 //component.set("v.correctVersion" , false);
             }
         });
         $A.enqueueAction(action);
	},
    createSettingRecords:function(component, event, helper) {
		//call apex class method
         var action = component.get("c.createEmissionFactorRecords");
         action.setParams({ emissionFactorMap : component.get("v.fctrMap")});
         //var tabName = component.find()
         // set the parameters to method  
         action.setCallback(this, function(response) {
             //store state of response
             var state = response.getState();
             if (state === "SUCCESS") {
                 var resultData = response.getReturnValue();
                 var toastEvent = $A.get("e.force:showToast");
                 toastEvent.setParams({
                     title: 'Success!',
                     type : 'success',
                     message : 'Saved Successfully!!!'
                 });
                 toastEvent.fire();
                 component.set("v.showModal",false);
                 window.location.reload();
                 //set response value in wrapperList attribute on component.
             }
         });
         $A.enqueueAction(action);
	},
})