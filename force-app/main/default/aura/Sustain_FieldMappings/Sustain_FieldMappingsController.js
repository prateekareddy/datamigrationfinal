({
    getList : function(component, event, helper) {        
        // Helper function - fetchContacts called for interaction with server
        helper.loadData(component, event, helper);
        
    },
    
    refreshComponent : function(component, event,helper) {       
        var selValue=component.find("select1").get("v.value");
        var message = event.getParam("recordId");        
        var objName=event.getParam("targetObjName");
        
        var fieldList= [];
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
                component.set('v.fieldMappingList', resultData.fieldMappingList);
                var wrapperListId =  resultData.objMappingList;
                component.set("v.objectId", message);
                var fieldList= [];
                var fieldListMap = component.get("v.fieldMappingList");
                for(var i=0; i<fieldListMap.length; i++){
                    if(fieldListMap[i].Migration_Util__Object_Mapping__c===message){
                        fieldList.push(fieldListMap[i]);
                    }
                }
                component.set("v.affectedfFieldMappingList",fieldList);
                var temp=[];
                if(selValue==='All'){
                    component.set("v.filtertedList",fieldList);
                }
                else if(selValue==='To Be Reviewed'){                    
                    for(var i=0;i<fieldList.length;i++){
                        if(fieldList[i].To_Review__c===true){
                            temp.push(fieldList[i]);
                        }
                    }
                    component.set("v.filtertedList",temp);
                }
                if(fieldList.length>= 10){
                    var cmpTarget = component.find("myTable");
                    $A.util.addClass(cmpTarget, 'tableFixHead');
                    $A.util.removeClass(cmpTarget, 'tableFixHead1');
                }
                else{
                    var cmpTarget = component.find("myTable");
                    $A.util.addClass(cmpTarget, 'tableFixHead1');
                    $A.util.removeClass(cmpTarget, 'tableFixHead');
                }
                component.set("v.selectedObject" , true);
                helper.getCustFields(component,event, objName);
            }
            
        });
        $A.enqueueAction(action);
        var fieldListMap = component.get("v.fieldMappingList");
        for(var i=0; i<fieldListMap.length; i++){
            if(fieldListMap[i].Migration_Util__Object_Mapping__c===message){
                fieldList.push(fieldListMap[i]);
            }
        }
        component.set("v.affectedfFieldMappingList",fieldList);
        var temp=[];
        if(selValue==='All'){
            component.set("v.filtertedList",fieldList);
        }
        else if(selValue==='To Be Reviewed'){           
            for(var i=0;i<fieldList.length;i++){
                if(fieldList[i].Migration_Util__To_Review__c===true){
                    temp.push(fieldList[i]);
                }
            }
            component.set("v.filtertedList",temp);
        }
        if(fieldList.length>= 10){
            var cmpTarget = component.find("myTable"); 
            $A.util.removeClass(cmpTarget, 'tableFixHead1');
            $A.util.addClass(cmpTarget, 'tableFixHead');
        }
        component.set("v.selectedObject" , true);
        component.set("v.objectId", message);
        var fullMap=component.get("v.custFieldFullMap");
        var found=false;
        for(var i=0; i<fullMap.length;i++){
            if(fullMap[i].key===objName){
                component.set("v.custFieldList",fullMap[i].value);
                found=true;
                break;
            }
        }
        if(!found){
            helper.getCustFields(component,event, objName);
        }
        var reloadparent = component.getEvent("reloadparent");
        reloadparent.setParams({
            "stapeName" : "step3"
        });
        reloadparent.fire();
        var filteredList=component.get("v.filtertedList");
        if(filteredList.length >= 10){
            var cmpTarget = component.find("myTable"); 
            $A.util.removeClass(cmpTarget, 'tableFixHead1');
            $A.util.addClass(cmpTarget, 'tableFixHead');
        }
        else{
            var cmpTarget = component.find("myTable"); 
            $A.util.removeClass(cmpTarget, 'tableFixHead');
            $A.util.addClass(cmpTarget, 'tableFixHead1');
        }
        
    },
    
    handleRemoveItem :function(component, event, helper){
        var recordId= event.getSource().get("v.value");
        var wrapList=component.get("v.affectedfFieldMappingList");
        var setVar=component.get("v.updatedSet");
        var filterList=component.get("v.filtertedList");
        for(var i=0; i<wrapList.length; i++){
            if(wrapList[i].Id===recordId){
                wrapList[i].Migration_Util__Mapping_Included__c=false;
                wrapList[i].Migration_Util__Comments__c='Removed';
                wrapList[i].Migration_Util__Target_Field_Label__c =null;
                wrapList[i].Migration_Util__Target_Field__c =null;
                wrapList[i].Migration_Util__Target_Field_Type__c =null;
                wrapList[i].Migration_Util__New_Field__c=false;
                var isPresent=false;
                for(var j=0; j<setVar.length; j++){
                    if(setVar[j].Id===recordId){
                        setVar[j].Migration_Util__Mapping_Included__c=false;
                        setVar[j].Migration_Util__Comments__c='Removed';
                        setVar[j].Migration_Util__Target_Field_Label__c =null;
                        setVar[j].Migration_Util__Target_Field__c =null;
                        setVar[j].Migration_Util__Target_Field_Type__c =null;
                        setVar[j].Migration_Util__New_Field__c=false;
                        isPresent=true;
                        break;
                    }
                }
                if(!isPresent){
                    setVar.push(wrapList[i]);
                }
                component.set("v.updatedSet",setVar);
                break;
            }
        }
        for(var i=0; i<filterList.length; i++){
            if(filterList[i].Id===recordId){
                filterList[i].Migration_Util__Mapping_Included__c=false;
                filterList[i].Migration_Util__Comments__c='Removed';
                filterList[i].Migration_Util__Target_Field_Label__c =null;
                filterList[i].Migration_Util__Target_Field__c =null;
                filterList[i].Migration_Util__Target_Field_Type__c =null;
                filterList[i].Migration_Util__New_Field__c=false;
                break;
            }
        }
        component.set("v.filtertedList",filterList);
        component.set("v.affectedfFieldMappingList",wrapList);        
    },
    handleAddItem :function(component, event, helper){
        var recordId= event.getSource().get("v.value");
        var selectedValue=document.getElementById(recordId).value;
        var selValue=[];
        var noneValue;
        var noneFlag=false;
        if(selectedValue.includes(",")){
            selValue=selectedValue.split(",");
        }
        else{
            noneValue=selectedValue;
        }
        console.log(selValue);
        var wrapList=component.get("v.affectedfFieldMappingList");
        var setVar=component.get("v.updatedSet");
        var filterList=component.get("v.filtertedList");
		console.log(filterList);        
        var noIssue=false;
        var nonduplicate =true;
        var allMappingList=component.get("v.allMappingList");
        for(var i=0; i<filterList.length; i++){
            
            if(filterList[i].Id!==recordId && selValue.length>0 && filterList[i].Migration_Util__Target_Field__c===selValue[0]){
                nonduplicate =false;
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Error!',
                    type : 'Error',
                    message : 'Same field cannot be mapped twice.'
                });
                toastEvent.fire();
                break;
            }
        }
        if(nonduplicate){
            for(var i=0; i<wrapList.length; i++){
                if(wrapList[i].Id===recordId){
                    if(noneValue==="None"){
                        if(wrapList[i].Migration_Util__Reference_To__c!==undefined && wrapList[i].Migration_Util__Reference_To__c.startsWith("sustain_app__")){
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title: 'Error!',
                                type : 'Error',
                                message : 'Cannot create new fields of type reference in standard objects as part of migration.'
                            });
                            toastEvent.fire();
                        }
                        else{
                            noneFlag=true;
                            wrapList[i].Migration_Util__Mapping_Included__c=true;
                            wrapList[i].Migration_Util__New_Field__c=true;
                            wrapList[i].Migration_Util__Comments__c='New Field';
                            var isPresent=false;
                            for(var j=0; j<setVar.length; j++){
                                if(setVar[j].Id===recordId){
                                    setVar[j].Migration_Util__Mapping_Included__c=true;
                                    setVar[j].Migration_Util__New_Field__c=true;
                                    setVar[j].Migration_Util__Comments__c='New Field';
                                    isPresent=true;
                                    break;
                                }
                            }
                            if(!isPresent){
                                setVar.push(wrapList[i]);
                            }
                            component.set("v.updatedSet",setVar);
                        }
                    }
                    //new mapping Added 
                     else if( selValue[2] != null && (wrapList[i].Migration_Util__Source_Field_Type__c === selValue[2] || 
							(wrapList[i].Migration_Util__Source_Field_Type__c == 'Picklist' && selValue[2] == 'String') ||
							(wrapList[i].Migration_Util__Source_Field_Type__c == 'Double' && selValue[2] == 'String') ||
							(JSON.stringify(wrapList[i].Migration_Util__Source_Field_Type__c).includes("Number") && selValue[2] == 'String') ||
                            (JSON.stringify(wrapList[i].Migration_Util__Source_Field_Type__c).includes("Text") && selValue[2] == 'String') ||
							(wrapList[i].Migration_Util__Source_Field_Type__c == 'Phone' && selValue[2] == 'String')
                      )){
                         if(selValue[2]==='Reference' && selValue[3]!=wrapList[i].Migration_Util__Reference_To__c && !allMappingList.includes(wrapList[i].Migration_Util__Reference_To__c+''+selValue[3])){
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title: 'Error!',
                                type : 'Error',
                                message : 'Reference Source type and Reference Target type are not same.'
                            });
                            toastEvent.fire();
                        }
                        else{
                            noIssue=true;
                            wrapList[i].Migration_Util__New_Field__c=false;
                            wrapList[i].Migration_Util__Mapping_Included__c=true;
                            wrapList[i].Migration_Util__Target_Field__c=selValue[0];
                            wrapList[i].Migration_Util__Target_Field_Label__c=selValue[1];
                            wrapList[i].Migration_Util__Target_Field_Type__c=selValue[2];
                            wrapList[i].Migration_Util__Comments__c='Field Mapped';
                            var isPresent=false;
                            var index;
                            for(var j=0; j<setVar.length; j++){
                                if(setVar[j].Id===recordId){
                                    setVar[j].Migration_Util__New_Field__c=false;
                                    setVar[j].Migration_Util__Mapping_Included__c=true;
                                    setVar[j].Migration_Util__Target_Field__c=selValue[0];
                                    setVar[j].Migration_Util__Target_Field_Label__c=selValue[1];
                                    setVar[j].Migration_Util__Target_Field_Type__c=selValue[2];
                                    setVar[j].Migration_Util__Comments__c='Field Mapped';
                                    isPresent=true;
                                    break;
                                }
                            }
                            if(!isPresent){
                                setVar.push(wrapList[i]);
                            }
                            component.set("v.updatedSet",setVar);
                        }
                    }
                        else if(selValue[2] === null ){
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title: 'Error!',
                                type : 'Error',
                                message : 'Select valid value.'
                            });
                            toastEvent.fire();
                        }
                            else{
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    title: 'Error!',
                                    type : 'Error',
                                    message : 'Source type and Target type are not same.'
                                });
                                toastEvent.fire();
                            }
                    break;
                }
            }
            if(noIssue){
                for(var i=0; i<filterList.length; i++){
                    if(filterList[i].Id===recordId){
                        filterList[i].Migration_Util__Mapping_Included__c=true;
                        filterList[i].Migration_Util__New_Field__c=false;
                        filterList[i].Migration_Util__Target_Field__c=selValue[0];
                        filterList[i].Migration_Util__Target_Field_Label__c=selValue[1];
                        filterList[i].Migration_Util__Target_Field_Type__c=selValue[2];
                        filterList[i].Migration_Util__Comments__c='Field Mapped';
                        break;
                    }
                }
                component.set("v.filtertedList",filterList);
            }
            if(noneFlag){
                for(var i=0; i<filterList.length; i++){
                    if(filterList[i].Id===recordId){
                        filterList[i].Migration_Util__Mapping_Included__c=true;
                        filterList[i].Migration_Util__New_Field__c=true;
                        filterList[i].Migration_Util__Comments__c='New Field';
                        break;
                    }
                }
                component.set("v.filtertedList",filterList);
            }
            component.set("v.affectedfFieldMappingList",wrapList);                     
        }        
    },
    handlerightcomponent : function(component, event, helper) {
        var objectMappingSel = true;
        component.set("v.objectId", event.target.dataset.num);
        var objName=event.target.dataset.target;
        var fieldList= [];
        var fieldListMap = component.get("v.fieldMappingList");
        for(var i=0; i<fieldListMap.length; i++){
            if(fieldListMap[i].Migration_Util__Object_Mapping__c===event.target.dataset.num){
                fieldList.push(fieldListMap[i]);
            }
        }
        component.set("v.affectedfFieldMappingList",fieldList);
        //calling filtering method
        helper.filterMethodHelper(component, event, helper, true);
        var filteredList=component.get("v.filtertedList");
        if(filteredList.length >= 10){
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
        var fullMap=component.get("v.custFieldFullMap");
        var found=false;
        for(var i=0; i<fullMap.length;i++){
            if(fullMap[i].key===objName){
                component.set("v.custFieldList",fullMap[i].value);
                found=true;
                break;
            }
        }
        if(!found){
            helper.getCustFields(component,event, objName);
        }
    },
    handleFilterChange:function(component, event, helper){
        helper.filterMethodHelper(component, event, helper,false);
    },
    handleAuraMethod:function(component, event, helper){
        var varSet=component.get("v.updatedSet");
        var params = event.getParam("arguments");
        var callback;
        var serverCall=true;
        if (params) {
            callback = params.callback;
        }
        
        for(var i=0; i<varSet.length; i++){
            if(varSet[i].Migration_Util__Required__c=== true && varSet[i].Migration_Util__Mapping_Included__c=== false){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Error!',
                    type : 'Error',
                    message : 'Please map all required fields on Source Object:'+varSet[i].Migration_Util__Object_Mapping__r.Migration_Util__Source_Object_Label__c+' and Target Object:'+varSet[i].Migration_Util__Object_Mapping__r.Migration_Util__Destination_Object_Label__c
                });
                toastEvent.fire();
                serverCall=false;
                break;
            }
        }
       
        console.log('407 '+varSet.length);
        if(serverCall && varSet.length>0){
            // create a one-time use instance of the serverEcho action
            // in the server-side controller 
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
                        message : 'Field Mapping Saved.'
                    });
                    toastEvent.fire();
                    if (callback){
                        callback('Completed');
                    } 
                }
            });
            
            // $A.enqueueAction adds the server-side action to the queue.
            $A.enqueueAction(action);
        }        
        else if(!serverCall || varSet.length===0){
            if (callback){
                callback('Completed');
            } 
        }
        
    },
    handleSelectChange : function(component, event, helper){
        component.set("v.picklistValueChange", true);
    },
    handleAuraforPicklistChangefunction : function(component, event, helper){
        var flag=component.get("v.picklistValueChange");
        var params = event.getParam("arguments");
        var callback;
        if (params) {
            callback = params.callback;
        }
        if (callback){
            callback(flag);
        }
    }
})