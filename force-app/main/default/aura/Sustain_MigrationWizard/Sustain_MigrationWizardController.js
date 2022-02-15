({
	doInit : function(component, event, helper) {
        helper.showSpinner(component);
		helper.retrieveObjMapping(component, event, helper);
        helper.hideSpinner(component);
	},
    handleRemoveItem :function(component, event, helper){
        var recordId= event.getSource().get("v.value");
        var wrapList=component.get("v.wrapObject");
        var setVar=component.get("v.updatedSet");
        for(var i=0; i<wrapList.customObjList.length; i++){
            if(wrapList.customObjList[i].Id===recordId){
                wrapList.customObjList[i].Migration_Util__Mapping_Included__c=false;
                var isPresent=false;
                for(var i=0; i<setVar.length; i++){
                    if(setVar[i].Id===recordId){
                        setVar[i].Migration_Util__Mapping_Included__c=false;
                        isPresent=true;
                    }
                }
                if(!isPresent){
                    setVar.push(wrapList.customObjList[i]);
                }
                component.set("v.updatedSet",setVar);
            }
        }
        component.set("v.wrapObject",wrapList);
        //helper.removeMapping(component,event,recordId);
    },
    handleAddItem :function(component, event, helper){
        var recordId= event.getSource().get("v.value");
        var selValue=document.getElementById(recordId).value.split(",");
        var wrapList=component.get("v.wrapObject");
        var setVar=component.get("v.updatedSet");
        var nonduplicate =true;
       // console.log('selValue',selValue);
       // console.log('wrapList',wrapList);
       // console.log('setVar',setVar);

        for(var i=0; i<wrapList.customObjList.length; i++){
           // console.log('wrapList.customObjList[i].Source_Object__c' +wrapList.customObjList[i].Source_Object__c);
           // console.log('wrapList.customObjList[i].Target_Object__c' +wrapList.customObjList[i].Target_Object__c);
           // console.log('selValue',selValue[1]);

            if(wrapList.customObjList[i].Id!==recordId && wrapList.customObjList[i].Migration_Util__Target_Object__c===selValue[1]){
                nonduplicate =false;
                var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title: 'Error!',
                                type : 'Error',
                                message : 'Same Object cannot be mapped twice.'
                            });
                toastEvent.fire();
               // break;
                
            }
            
        }
        // console.log('nonduplicate',nonduplicate);
																																																			
        if(nonduplicate){

        for(var i=0; i<wrapList.customObjList.length; i++){
            if(wrapList.customObjList[i].Id===recordId){
                if(wrapList.customObjList[i].Migration_Util__Source_Object__c === selValue[1]){
                     var toastEvent = $A.get("e.force:showToast");
               		toastEvent.setParams({
                     title: 'Error!',
                   	 type : 'Error',
                     message : 'Source and Target Object cannot be the same.'
               });
               toastEvent.fire();
                }
                else{
                    wrapList.customObjList[i].Migration_Util__Mapping_Included__c=true;
                    wrapList.customObjList[i].Migration_Util__Destination_Object_Label__c=selValue[0];
                wrapList.customObjList[i].Migration_Util__Target_Object__c=selValue[1];  
                var isPresent=false;
                for(var i=0; i<setVar.length; i++){
                    if(setVar[i].Id===recordId){
                        setVar[i].Migration_Util__Mapping_Included__c=true;
                        setVar[i].Migration_Util__Destination_Object_Label__c=selValue[0];
                        setVar[i].Migration_Util__Target_Object__c=selValue[1];
                        isPresent=true;
                    }
                }
                if(!isPresent){
                    setVar.push(wrapList.customObjList[i]);
                }
                component.set("v.updatedSet",setVar);
                }
                
            }
        }
        component.set("v.wrapObject",wrapList);
        //helper.addMapping(component,event,recordId,selValue);
        }
        },
    handleAuraMethod:function(component, event, helper){
        var varSet=component.get("v.updatedSet");
        if(varSet.length>0){
        	helper.saveMappingHelper(component, event);
        }
    }
})