({
	loadData: function(component, event, helper) {
        //call apex class method
        var action = component.get("c.getAllMapping");         
        
        // set the parameters to method  
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                var resultData = response.getReturnValue();                
                //set response value in wrapperList attribute on component.
                
                component.set("v.selectedObject" , true);
                
                component.set('v.wrapperList', resultData.objMappingList);
				var scroller = document.getElementById("verticalList");
				scroller.scrollTop = 0;
                component.set('v.fieldMappingList', resultData.fieldMappingList);
                var wrapperListId =  resultData.objMappingList;
                component.set("v.objectId", wrapperListId[0].Id);
                var objName= wrapperListId[0].Migration_Util__Target_Object__c;
                var fieldList= [];
                var fieldListMap = component.get("v.fieldMappingList");
                var setVar=[];
               
                for(var i=0; i<fieldListMap.length; i++){
                    if(fieldListMap[i].Migration_Util__Object_Mapping__c===wrapperListId[0].Id){
                        fieldList.push(fieldListMap[i]);
                    }
                    if(fieldListMap[i].Migration_Util__Required__c=== true && fieldListMap[i].Migration_Util__Custom_Field__c===true && fieldListMap[i].Migration_Util__Mapping_Included__c=== false){
                        setVar.push(fieldListMap[i]);
                    }
                }
                component.set("v.affectedfFieldMappingList",fieldList);
                component.set("v.updatedSet",setVar);
             
                component.set("v.filtertedList",fieldList);
                if(fieldList.length>= 10){
                     var cmpTarget = component.find("myTable");
                    $A.util.removeClass(cmpTarget, 'tableFixHead1');
                    $A.util.addClass(cmpTarget, 'tableFixHead');
                }
                else{
                    var cmpTarget = component.find("myTable"); 
                    $A.util.removeClass(cmpTarget, 'tableFixHead');
                     $A.util.addClass(cmpTarget, 'tableFixHead1');
                }
                component.set("v.selectedObject" , true);
                helper.getCustFields(component,event, objName);
                helper.getAllMappingRecords(component,event,helper);
            }
            
        });
        $A.enqueueAction(action);
    },
    filterMethodHelper:function(component, event, objName, selectedMapping){
        var selValue=component.find("select1").get("v.value");
        var affectedList=component.get("v.affectedfFieldMappingList");
        var cmpTarget = component.find("myTable"); 
        var temp=[];
        if(selValue==='All'){
            component.set("v.filtertedList",affectedList);
        }
        else if(selValue==='To Be Reviewed'){
            for(var i=0;i<affectedList.length;i++){
                if(affectedList[i].Migration_Util__To_Review__c===true){
                    temp.push(affectedList[i]);
                }
            }
            component.set("v.filtertedList",temp);
        }
        if(temp.length>= 10){
            $A.util.removeClass(cmpTarget, 'tableFixHead1');
            $A.util.addClass(cmpTarget, 'tableFixHead');
        }
        else{
            $A.util.removeClass(cmpTarget, 'tableFixHead'); 
            $A.util.addClass(cmpTarget, 'tableFixHead1');
        }
        if(selectedMapping === false){
            if(affectedList[0].Migration_Util__Object_Mapping__r.Migration_Util__Total_To_Review_Fields__c === 0){
                var toastEvent = $A.get("e.force:showToast");                    
                                toastEvent.setParams({
                                    message: $A.get("$Label.c.Sustain_UpdateFieldMappingLabel"),
                                    duration:' 5000',
                                    key: 'info_alt',
                                    type: 'info',
                                    mode: 'pester'
                                });
                                toastEvent.fire(); 
            }
        }
    },
    getCustFields :function(component, event, objName){
        var action = component.get("c.getAllCustomFields");
        action.setParams({ objName : objName});
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                
                // Alert the user with the value returned 
                // from the server
                component.set("v.custFieldList",response.getReturnValue());
                var fullMap=component.get("v.custFieldFullMap");
                var custFieldList=component.get("v.custFieldList");
                //add it to array
                fullMap.push({key: objName, value: custFieldList});
                component.set("v.custFieldFullMap",fullMap);                
            }
        });
        $A.enqueueAction(action);
    },
     saveMappingHelper :function(component,event){
        // create a one-time use instance of the serverEcho action
        // in the server-side controller      
        var varSet=component.get("v.updatedSet");
        var action = component.get("c.updateFieldMapping");
        action.setParams({ fieldMappingList : varSet});
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
    
    getAllMappingRecords :function(component, event, helper){
        var action = component.get("c.getAllMappings");
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                
                component.set("v.allMappingList",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },    
})