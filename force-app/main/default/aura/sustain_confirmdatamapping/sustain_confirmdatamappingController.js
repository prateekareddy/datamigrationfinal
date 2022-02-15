({
    doInit : function(component, event, helper) {
        var action = component.get("c.getDataMappingDetails");         
        action.setCallback(this, function(response){
            var state = response.getState();             
            if(state==='SUCCESS'){                
                var result = response.getReturnValue();   
                component.set('v.dataMappingDetails', result);              
            }
        });
        $A.enqueueAction(action);
    },
    viewObject : function(component, event, helper) {    
        event.preventDefault();
        var ctarget = event.currentTarget.dataset.value; 
        var ctargetName = event.currentTarget.dataset.name;
        var action = component.get("c.updateMigrationStatus");
        action.setParams({ stepNo : 'step3'});
        action.setCallback(this, function(response){
            var state = response.getState();             
            if(state==='SUCCESS'){                
                var isUpdated=response.getReturnValue();
                if(isUpdated){ 
                    var cmpEvent =  $A.get("e.c:Sustain_RefreshParentCompoment");  
                    cmpEvent.setParams({"recordId" :ctarget,"targetObjName" : ctargetName}); 
                    cmpEvent.fire();  
                }
            }
        });
        $A.enqueueAction(action);
        
    }
})