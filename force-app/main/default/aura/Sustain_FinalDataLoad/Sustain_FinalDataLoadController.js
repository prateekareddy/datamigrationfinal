({
	init : function(component, event, helper) {
		helper.loadData(component, event, helper);
        helper.checkCurRunJobIsSampleFinal(component, event, helper);
	},
    startLoad : function(component, event, helper) {
    component.set("v.startClicked",true);
            component.set("v.deleteClicked",false);            
            var action = component.get("c.startFinalDataLoad");            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                    var compEvent = component.getEvent("handleRefreshEvent");
                    compEvent.fire();
                }
            });
            $A.enqueueAction(action);
    },
    deleteLoad : function(component,event,helper){
        component.set("v.startClicked",false);
        component.set("v.deleteClicked",true);
        var action = component.get("c.deleteDataLoadReq");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();                
                component.set("v.displaybuttons",storeResponse);
                var compEvent = component.getEvent("handleRefreshEvent");
                compEvent.fire();                       
            }
        });
        $A.enqueueAction(action);
    },

    deleteErrorLoad : function(component,event,helper){
        component.set("v.startClicked",false);
        component.set("v.deleteClicked",true);
        var action = component.get("c.deleteErrorDataLoadReq");
        action.setParams({
            "isErrorRevertOnly": true
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();                
                component.set("v.displaybuttons",storeResponse);
                var compEvent = component.getEvent("handleRefreshEvent");
                compEvent.fire();                       
            }
        });
        $A.enqueueAction(action);
    },
    
    viewReportPage :  function(component,event,helper){        
        event.preventDefault();
        var ctarget = event.currentTarget.dataset.value; 
        var ctargetName = event.currentTarget.dataset.name;
        var srcApiName;
        var srcRcdType;
        if(ctargetName !== '' && ctargetName !==null) {
            let list = ctargetName.split("-");
            srcApiName = list[0];
            srcRcdType = list[1];            
            var action = component.get("c.getREportIdByObjName");
            action.setParams({ srcApiName : srcApiName},{ srcRcdType : srcRcdType});
            action.setCallback(this, function(response) {
                var state = response.getState();               
                if (state === "SUCCESS") {
                    var reportId = response.getReturnValue();
                    var urlEvent = $A.get("e.force:navigateToURL");                  
                   if(reportId != null && reportId != undefined){
                    window.open('/lightning/r/Report/'+reportId + '/view?reportFilters=OR[{"operator":"equals","value":"Error Occurred","column":"'+srcApiName+'.Migration_Util__Migration_Status__c"}]','_blank');
                   }else{
                       var toastEvent = $A.get("e.force:showToast");                    
                            toastEvent.setParams({
                                title : 'Error',
                                message: 'Report not found for this source object. Reports are available only for managed package object by default. Please contact System Admin.',
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
        }
    },
    handleFinish : function(component,event,helper){        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/lightning/page/home"
        });
        urlEvent.fire();
    }
})